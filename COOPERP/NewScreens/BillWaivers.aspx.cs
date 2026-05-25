using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Web.Script.Serialization;

/// <summary>
/// Bill Waivers — allows finance staff to waive specific bills from a student's account.
/// 
/// Wizard Flow:
///   Step 1: Search & select student → loads their bills
///   Step 2: Select one or more bills to waive → shows line items with amounts
///   Step 3: Choose waiver category + free-text reason
///   Step 4: Review summary → confirm
///   Step 5: System creates credit transaction in fin_studentfeestracking + fin_ledger,
///           records waiver in fin_bill_waivers + fin_bill_waiver_items.
///
/// AJAX Endpoints (via ?ajax=...):
///   ?ajax=search&amp;q=...          — student search (name or regno)
///   ?ajax=bills&amp;regno=...       — load all DR bills for a student
///   ?ajax=apply                     — POST: apply the waiver (JSON body)
///
/// Tables Used:
///   fin_studentfeestracking — read bills, write credit entry
///   fin_ledger              — write GL credit entry
///   fin_bill_waivers        — waiver header
///   fin_bill_waiver_items   — waiver line items
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// </summary>
public partial class COOPERP_NewScreens_BillWaivers : System.Web.UI.Page
{
    // ─────────────────────── Connection Strings ──────────────────────────

    private string AcctConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }

    private string MainConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─────────────────────── Page Lifecycle ──────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        // Ensure waiver tables exist before any operation (safe to call every request)
        EnsureWaiverTables();

        // Handle AJAX requests — return JSON, skip page rendering
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (ajax == "search")
        {
            HandleStudentSearch();
            return;
        }
        if (ajax == "bills")
        {
            HandleLoadBills();
            return;
        }
        if (ajax == "balance")
        {
            HandleStudentBalance();
            return;
        }
        if (ajax == "apply")
        {
            HandleApplyWaiver();
            return;
        }
        if (ajax == "apply_fix")
        {
            HandleApplyBalanceFix();
            return;
        }
        if (ajax == "detail")
        {
            HandleWaiverDetail();
            return;
        }
        if (ajax == "reverse")
        {
            HandleReverseWaiver();
            return;
        }

        if (!IsPostBack)
        {
            LoadWaiverHistory();
        }
    }

    // ─────────────────────── Filter / Pagination Events ──────────────────────

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        hidPage.Value = "1";
        LoadWaiverHistory();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlStatus.SelectedIndex = 0;
        ddlCategory.SelectedIndex = 0;
        txtDateFrom.Text = "";
        txtDateTo.Text = "";
        hidPage.Value = "1";
        LoadWaiverHistory();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        hidPage.Value = "1";
        LoadWaiverHistory();
    }

    protected void btnPageNav_Click(object sender, EventArgs e)
    {
        LoadWaiverHistory();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Student Search (?ajax=search&q=...)
    // Returns JSON array of matching students from acad_student (main DB).
    // ═════════════════════════════════════════════════════════════════════

    private void HandleStudentSearch()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        string query = (Request.QueryString["q"] ?? "").Trim();
        if (string.IsNullOrEmpty(query) || query.Length < 2)
        {
            Response.Write("{\"results\":[]}");
            Response.End();
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                string[] terms = query.Split(new char[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                StringBuilder where = new StringBuilder("COALESCE(s.new_status,'') != ''");
                MySqlCommand cmd = new MySqlCommand();

                if (terms.Length == 1)
                {
                    where.Append(" AND (s.regno LIKE @q1 OR s.entryno LIKE @q1 OR s.firstname LIKE @q1 OR s.othername LIKE @q1 OR CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,'')) LIKE @q1)");
                    cmd.Parameters.AddWithValue("@q1", "%" + terms[0] + "%");
                }
                else
                {
                    for (int i = 0; i < terms.Length && i < 5; i++)
                    {
                        string p = "@qt" + i;
                        where.AppendFormat(" AND (s.regno LIKE {0} OR s.entryno LIKE {0} OR s.firstname LIKE {0} OR s.othername LIKE {0})", p);
                        cmd.Parameters.AddWithValue(p, "%" + terms[i] + "%");
                    }
                }

                string sql = String.Format(
                    @"SELECT s.regno,
                             COALESCE(s.entryno,'') AS studno,
                             TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                             COALESCE(p.progname,'N/A') AS programme,
                             COALESCE(s.studsesion,'N/A') AS session_name,
                             COALESCE(s.new_status,'') AS status
                      FROM acad_student s
                      LEFT JOIN acad_programme p ON p.progcode = s.progid
                      WHERE {0}
                      ORDER BY CASE WHEN s.regno LIKE @qStart THEN 0 ELSE 1 END, s.firstname
                      LIMIT 15", where.ToString());

                cmd.CommandText = sql;
                cmd.Connection = conn;
                cmd.Parameters.AddWithValue("@qStart", query + "%");

                StringBuilder json = new StringBuilder("{\"results\":[");
                bool first = true;
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        if (!first) json.Append(",");
                        first = false;
                        json.AppendFormat(
                            "{{\"regno\":\"{0}\",\"studno\":\"{1}\",\"name\":\"{2}\",\"programme\":\"{3}\",\"session\":\"{4}\",\"status\":\"{5}\"}}",
                            JsEsc(rdr["regno"].ToString()), JsEsc(rdr["studno"].ToString()),
                            JsEsc(rdr["student_name"].ToString()), JsEsc(rdr["programme"].ToString()),
                            JsEsc(rdr["session_name"].ToString()), JsEsc(rdr["status"].ToString()));
                    }
                }
                json.Append("]}");
                Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"results\":[],\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Load Student Bills (?ajax=bills&regno=...)
    // Returns all DR (Bill) transactions from fin_studentfeestracking
    // that have post_status='Posted' and trans_type='Bill'.
    // ═════════════════════════════════════════════════════════════════════

    private void HandleLoadBills()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"bills\":[],\"error\":\"No registration number provided.\"}");
            Response.End();
            return;
        }

        try
        {
            // Also load already-waived TIDs to mark them
            HashSet<int> waivedTIDs = new HashSet<int>();
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Get all waived TIDs for this student (Active waivers only)
                using (MySqlCommand wCmd = new MySqlCommand(
                    @"SELECT wi.original_tid 
                      FROM fin_bill_waiver_items wi
                      INNER JOIN fin_bill_waivers w ON w.waiver_id = wi.waiver_id
                        WHERE w.regno = @r AND w.status = 'Active' AND w.waiver_category NOT IN ('Reversal','Balance Fix')", conn))
                {
                    wCmd.Parameters.AddWithValue("@r", regno);
                    using (MySqlDataReader wr = wCmd.ExecuteReader())
                    {
                        while (wr.Read())
                        {
                            int tid = Convert.ToInt32(wr["original_tid"]);
                            waivedTIDs.Add(tid);
                        }
                    }
                }

                // Fetch current balance using the same UNION ALL logic as the student fee statement
                // (fin_ledger + legacy fin_studentfeestracking entries not yet in the GL)
                double currentBalanceForBills = Convert.ToDouble(ComputeUnionAllBalance(conn, regno));

                // Load ALL DR bill entries: fin_ledger DR + tracking entries not already in the GL.
                // Mirrors ComputeUnionAllBalance — so what the student sees matches what can be waived.
                // Ledger-only entries (no tracking row) use negative GL TID as UI key to avoid collisions.
                string sql =
                    "SELECT gl_tid, tid, amount, item_code, item_name, detail, trans_date, acadyear, semester, studyyear, source " +
                    "FROM (" +
                    "  SELECT fl.TID AS gl_tid, COALESCE(t.TID,0) AS tid, fl.transaction_amount AS amount," +
                    "    COALESCE(t.item_code,0) AS item_code, COALESCE(b.ItemName,'General Charge') AS item_name," +
                    "    COALESCE(fl.particulars,'') AS detail, DATE(fl.transactionDate) AS trans_date," +
                    "    COALESCE(t.acadyear,'') AS acadyear, COALESCE(t.semester,0) AS semester," +
                    "    COALESCE(ar.studyyear,0) AS studyyear," +
                    "    CASE WHEN t.TID IS NOT NULL THEN 'tracking' ELSE 'ledger' END AS source" +
                    "  FROM fin_ledger fl" +
                    "  LEFT JOIN fin_studentfeestracking t" +
                    "    ON t.regno=@r AND t.trans_type='Bill' AND t.post_status='Posted'" +
                    "    AND (fl.voucherNo=CAST(t.TID AS CHAR) OR fl.folio=CONCAT('BillNo:',CAST(t.TID AS CHAR)))" +
                    "  LEFT JOIN academicbillingitems b ON b.ItemCode=t.item_code" +
                    "  LEFT JOIN campus_dynamics.acad_registration ar ON ar.regno=t.regno AND ar.acad_year=t.acadyear AND ar.semester=t.semester" +
                    "  WHERE fl.accountcode=@r2 AND fl.transactionType='DR' AND fl.transaction_amount>0" +
                    "  UNION ALL" +
                    "  SELECT 0 AS gl_tid, t.TID AS tid, t.amount, COALESCE(t.item_code,0) AS item_code," +
                    "    COALESCE(b.ItemName,'Unknown') AS item_name, COALESCE(t.detail,'') AS detail," +
                    "    DATE(t.trans_date) AS trans_date, COALESCE(t.acadyear,'') AS acadyear," +
                    "    COALESCE(t.semester,0) AS semester, COALESCE(ar.studyyear,0) AS studyyear, 'tracking' AS source" +
                    "  FROM fin_studentfeestracking t" +
                    "  LEFT JOIN academicbillingitems b ON b.ItemCode=t.item_code" +
                    "  LEFT JOIN campus_dynamics.acad_registration ar ON ar.regno=t.regno AND ar.acad_year=t.acadyear AND ar.semester=t.semester" +
                    "  WHERE t.regno=@r3 AND t.trans_type='Bill' AND t.post_status='Posted' AND t.amount>0" +
                    "  AND NOT EXISTS (" +
                    "    SELECT 1 FROM fin_ledger fl2 WHERE fl2.accountcode=t.regno" +
                    "    AND (fl2.voucherNo=CAST(t.TID AS CHAR) OR fl2.folio=CONCAT('BillNo:',CAST(t.TID AS CHAR))" +
                    "    OR (fl2.transaction_amount=t.amount AND DATE(fl2.transactionDate)=DATE(t.trans_date)" +
                    "        AND fl2.transactionType='DR'" +
                    "        AND (fl2.particulars=t.detail OR t.detail IS NULL OR t.detail='')))" +
                    "  )" +
                    ") AS combined ORDER BY trans_date DESC, tid DESC, gl_tid DESC";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@r",  regno);
                    cmd.Parameters.AddWithValue("@r2", regno);
                    cmd.Parameters.AddWithValue("@r3", regno);
                    StringBuilder json = new StringBuilder("{\"current_balance\":");
                    json.Append(currentBalanceForBills.ToString("F0", System.Globalization.CultureInfo.InvariantCulture));
                    json.Append(",\"bills\":[");
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            int glTid    = rdr["gl_tid"] != DBNull.Value ? Convert.ToInt32(rdr["gl_tid"]) : 0;
                            int trackTid = rdr["tid"]    != DBNull.Value ? Convert.ToInt32(rdr["tid"])    : 0;
                            string source = rdr["source"].ToString();
                            // Ledger-only entries: no tracking row. Use -glTid so the UI has a unique, non-zero key.
                            int uiTid = (source == "ledger") ? -glTid : trackTid;
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat(
                                "{{\"tid\":{0},\"gl_tid\":{1},\"source\":\"{2}\",\"amount\":{3},\"item_code\":{4},\"item_name\":\"{5}\",\"detail\":\"{6}\",\"date\":\"{7}\",\"acadyear\":\"{8}\",\"semester\":{9},\"already_waived\":{10},\"studyyear\":{11}}}",
                                uiTid,
                                glTid,
                                JsEsc(source),
                                Convert.ToDouble(rdr["amount"]).ToString("F0"),
                                (rdr["item_code"] != DBNull.Value ? Convert.ToInt32(rdr["item_code"]) : 0),
                                JsEsc(rdr["item_name"].ToString()),
                                JsEsc(rdr["detail"].ToString()),
                                Convert.ToDateTime(rdr["trans_date"]).ToString("dd/MM/yyyy"),
                                JsEsc(rdr["acadyear"].ToString()),
                                (rdr["semester"] != DBNull.Value ? Convert.ToInt32(rdr["semester"]) : 0),
                                waivedTIDs.Contains(uiTid) ? "true" : "false",
                                (rdr["studyyear"] != DBNull.Value ? Convert.ToInt32(rdr["studyyear"]) : 0));
                        }
                    }
                    json.Append("]}");
                    Response.Write(json.ToString());
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"bills\":[],\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Load Student Balance (?ajax=balance&regno=...)
    // Returns current balance so operator can set target balance.
    // ═════════════════════════════════════════════════════════════════════

    private void HandleStudentBalance()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        string regno = (Request.QueryString["regno"] ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            Response.Write("{\"ok\":false,\"error\":\"Student registration number is required.\"}");
            Response.End();
            return;
        }

        try
        {
            decimal bal = 0;
            string studentName = "";
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                bal = ComputeUnionAllBalance(conn, regno);
            }

            using (MySqlConnection connMain = new MySqlConnection(MainConnStr))
            {
                connMain.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT TRIM(CONCAT(COALESCE(firstname,''),' ',COALESCE(othername,''))) FROM acad_student WHERE regno = @r LIMIT 1",
                    connMain))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    object o = cmd.ExecuteScalar();
                    if (o != null && o != DBNull.Value) studentName = Convert.ToString(o);
                }
            }

            Response.Write(string.Format(
                "{{\"ok\":true,\"regno\":\"{0}\",\"student_name\":\"{1}\",\"current_balance\":\"{2}\",\"current_balance_fmt\":\"{3}\"}}",
                JsEsc(regno), JsEsc(studentName), bal.ToString("F2", CultureInfo.InvariantCulture), JsEsc(FormatBalanceForUi(bal))));
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Apply Waiver (?ajax=apply, POST)
    // Expects JSON body: { regno, category, reason, acadyear, semester, items: [{tid, amount},...] }
    //
    // TRANSACTION:
    //   1. Validate all TIDs, capture bill details into WaiverItem for audit
    //   2. DELETE (full waiver) or UPDATE amount (partial) on fin_studentfeestracking bill rows
    //      + DELETE / UPDATE matching fin_ledger DR entries
    //   3. INSERT fin_bill_waivers header (credit_tid=0 — no offsetting credit created)
    //   4. INSERT fin_bill_waiver_items for each waived bill (using pre-captured details)
    //   All within a single MySQL transaction — all succeed or all fail.
    // ═════════════════════════════════════════════════════════════════════

    private void HandleApplyWaiver()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        try
        {
            // Read JSON body
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream))
            {
                body = sr.ReadToEnd();
            }

            // Parse JSON body using JavaScriptSerializer (robust, handles escapes correctly)
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);
            string regno   = data.ContainsKey("regno") ? Convert.ToString(data["regno"]) : "";
            string category = data.ContainsKey("category") ? Convert.ToString(data["category"]) : "";
            string reason  = data.ContainsKey("reason") ? Convert.ToString(data["reason"]) : "";
            string acadyear = data.ContainsKey("acadyear") ? Convert.ToString(data["acadyear"]) : "";
            int semester   = data.ContainsKey("semester") ? Convert.ToInt32(data["semester"]) : 0;

            // Validate required fields
            if (string.IsNullOrEmpty(regno))    throw new Exception("Student registration number is required.");
            if (string.IsNullOrEmpty(category)) throw new Exception("Waiver category is required.");
            if (string.IsNullOrEmpty(reason))   throw new Exception("Waiver reason is required.");

            // Parse items array from deserialized data
            List<WaiverItem> items = new List<WaiverItem>();
            if (data.ContainsKey("items"))
            {
                System.Collections.ArrayList rawItems = data["items"] as System.Collections.ArrayList;
                if (rawItems != null)
                {
                    foreach (object rawItem in rawItems)
                    {
                        Dictionary<string, object> itemDict = rawItem as Dictionary<string, object>;
                        if (itemDict != null)
                        {
                            int tid = itemDict.ContainsKey("tid") ? Convert.ToInt32(itemDict["tid"]) : 0;
                            double amt = itemDict.ContainsKey("amount") ? Convert.ToDouble(itemDict["amount"]) : 0;
                            if (tid != 0 && amt > 0)
                            {
                                items.Add(new WaiverItem { TID = tid, Amount = amt });
                            }
                        }
                    }
                }
            }
            if (items.Count == 0) throw new Exception("No bills selected for waiver.");

            // Calculate total
            double totalAmount = 0;
            foreach (WaiverItem wi in items) totalAmount += wi.Amount;
            if (totalAmount <= 0) throw new Exception("Total waiver amount must be greater than zero.");

            string user = GetCurrentUser();
            DateTime now = DateTime.Now;
            long newWaiverID = 0;

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                MySqlTransaction tx = conn.BeginTransaction();
                try
                {
                    // ── Fallback: infer acadyear/semester if not supplied (ledger-only entries have none) ──
                    if (string.IsNullOrEmpty(acadyear))
                    {
                        using (MySqlCommand inferCmd = new MySqlCommand(
                            "SELECT acadyear, semester FROM fin_studentfeestracking WHERE regno = @r ORDER BY trans_date DESC, TID DESC LIMIT 1",
                            conn, tx))
                        {
                            inferCmd.Parameters.AddWithValue("@r", regno);
                            using (MySqlDataReader rd = inferCmd.ExecuteReader())
                            {
                                if (rd.Read())
                                {
                                    acadyear = rd["acadyear"] != DBNull.Value ? Convert.ToString(rd["acadyear"]) : "";
                                    if (semester <= 0) semester = rd["semester"] != DBNull.Value ? Convert.ToInt32(rd["semester"]) : 1;
                                }
                            }
                        }
                    }
                    if (string.IsNullOrEmpty(acadyear)) throw new Exception("Academic year is required.");
                    if (semester <= 0)                  throw new Exception("Semester is required.");

                    // ── Step 1: Validate all TIDs; capture bill details before any deletion ──
                    // tid > 0 → tracking entry (fin_studentfeestracking)
                    // tid < 0 → ledger-only entry (fin_ledger.TID = -tid, no tracking row)
                    foreach (WaiverItem wi in items)
                    {
                        double actualBillAmt = 0;
                        string actualDetail  = "";

                        if (wi.TID > 0)
                        {
                            using (MySqlCommand chk = new MySqlCommand(
                                @"SELECT TID, amount, COALESCE(detail,'') AS detail FROM fin_studentfeestracking
                                  WHERE TID = @tid AND regno = @r AND trans_type = 'Bill' AND post_status = 'Posted'
                                  FOR UPDATE",
                                conn, tx))
                            {
                                chk.Parameters.AddWithValue("@tid", wi.TID);
                                chk.Parameters.AddWithValue("@r", regno);
                                using (MySqlDataReader vr = chk.ExecuteReader())
                                {
                                    if (!vr.Read())
                                        throw new Exception(String.Format("Bill TID {0} not found or not valid for student {1}.", wi.TID, regno));
                                    actualBillAmt = Convert.ToDouble(vr["amount"]);
                                    actualDetail  = vr["detail"].ToString();
                                }
                            }
                        }
                        else
                        {
                            // Ledger-only — validate directly against fin_ledger
                            int glTid = -wi.TID;
                            using (MySqlCommand chk = new MySqlCommand(
                                @"SELECT TID, transaction_amount, COALESCE(particulars,'') AS detail FROM fin_ledger
                                  WHERE TID = @gltid AND accountcode = @r AND transactionType = 'DR'
                                  FOR UPDATE",
                                conn, tx))
                            {
                                chk.Parameters.AddWithValue("@gltid", glTid);
                                chk.Parameters.AddWithValue("@r", regno);
                                using (MySqlDataReader vr = chk.ExecuteReader())
                                {
                                    if (!vr.Read())
                                        throw new Exception(String.Format("GL entry TID {0} not found or not valid for student {1}.", glTid, regno));
                                    actualBillAmt = Convert.ToDouble(vr["transaction_amount"]);
                                    actualDetail  = vr["detail"].ToString();
                                }
                            }
                        }

                        if (wi.Amount <= 0)
                            throw new Exception(String.Format("Waive amount for TID {0} must be greater than zero.", wi.TID));
                        if (wi.Amount > actualBillAmt + 0.01)
                            throw new Exception(String.Format("Waive amount ({0:N0}) for TID {1} exceeds the bill amount ({2:N0}).", wi.Amount, wi.TID, actualBillAmt));
                        if (wi.Amount > actualBillAmt) wi.Amount = actualBillAmt;

                        wi.BillAmount = actualBillAmt;
                        wi.OrigDetail = actualDetail;

                        // Already-waived check works for both positive (tracking) and negative (ledger) TIDs
                        using (MySqlCommand chk2 = new MySqlCommand(
                            @"SELECT COUNT(*) FROM fin_bill_waiver_items wi
                              INNER JOIN fin_bill_waivers w ON w.waiver_id = wi.waiver_id
                              WHERE wi.original_tid = @tid AND w.status = 'Active' AND w.waiver_category NOT IN ('Reversal','Balance Fix')",
                            conn, tx))
                        {
                            chk2.Parameters.AddWithValue("@tid", wi.TID);
                            if (Convert.ToInt64(chk2.ExecuteScalar()) > 0)
                                throw new Exception(String.Format("Bill TID {0} has already been waived.", wi.TID));
                        }
                    }

                    // ── Step 2: Delete or reduce the original bill transactions ──
                    foreach (WaiverItem wi in items)
                    {
                        bool isFullWaiver = wi.Amount >= wi.BillAmount - 0.005;

                        if (wi.TID > 0)
                        {
                            // Tracking-backed entry — delete/update tracking row + all linked GL rows
                            string tidStr = wi.TID.ToString(System.Globalization.CultureInfo.InvariantCulture);
                            if (isFullWaiver)
                            {
                                using (MySqlCommand delGl = new MySqlCommand(
                                    "DELETE FROM fin_ledger WHERE voucherNo = @v",
                                    conn, tx))
                                {
                                    delGl.Parameters.AddWithValue("@v", tidStr);
                                    delGl.ExecuteNonQuery();
                                }
                                using (MySqlCommand delGlFolio = new MySqlCommand(
                                    "DELETE FROM fin_ledger WHERE folio = @f",
                                    conn, tx))
                                {
                                    delGlFolio.Parameters.AddWithValue("@f", "BillNo:" + tidStr);
                                    delGlFolio.ExecuteNonQuery();
                                }
                                using (MySqlCommand delBill = new MySqlCommand(
                                    "DELETE FROM fin_studentfeestracking WHERE TID = @tid AND regno = @r AND trans_type = 'Bill'",
                                    conn, tx))
                                {
                                    delBill.Parameters.AddWithValue("@tid", wi.TID);
                                    delBill.Parameters.AddWithValue("@r", regno);
                                    if (delBill.ExecuteNonQuery() == 0)
                                        throw new Exception(String.Format("Bill TID {0} could not be deleted. It may have already been removed or does not belong to this student.", wi.TID));
                                }
                            }
                            else
                            {
                                double remaining = wi.BillAmount - wi.Amount;
                                using (MySqlCommand updGl = new MySqlCommand(
                                    "UPDATE fin_ledger SET transaction_amount = @amt, actual_amount = @amt, ugx_amount = @amt WHERE voucherNo = @v",
                                    conn, tx))
                                {
                                    updGl.Parameters.AddWithValue("@amt", remaining);
                                    updGl.Parameters.AddWithValue("@v", tidStr);
                                    updGl.ExecuteNonQuery();
                                }
                                using (MySqlCommand updGlFolio = new MySqlCommand(
                                    "UPDATE fin_ledger SET transaction_amount = @amt, actual_amount = @amt, ugx_amount = @amt WHERE folio = @f",
                                    conn, tx))
                                {
                                    updGlFolio.Parameters.AddWithValue("@amt", remaining);
                                    updGlFolio.Parameters.AddWithValue("@f", "BillNo:" + tidStr);
                                    updGlFolio.ExecuteNonQuery();
                                }
                                using (MySqlCommand updBill = new MySqlCommand(
                                    "UPDATE fin_studentfeestracking SET amount = @amt WHERE TID = @tid AND regno = @r AND trans_type = 'Bill'",
                                    conn, tx))
                                {
                                    updBill.Parameters.AddWithValue("@amt", remaining);
                                    updBill.Parameters.AddWithValue("@tid", wi.TID);
                                    updBill.Parameters.AddWithValue("@r", regno);
                                    if (updBill.ExecuteNonQuery() == 0)
                                        throw new Exception(String.Format("Bill TID {0} could not be updated. It may have been modified concurrently or does not belong to this student.", wi.TID));
                                }
                            }
                        }
                        else
                        {
                            // Ledger-only entry — operate directly on the fin_ledger row (gl_tid = -tid)
                            int glTid = -wi.TID;
                            if (isFullWaiver)
                            {
                                using (MySqlCommand delGl = new MySqlCommand(
                                    "DELETE FROM fin_ledger WHERE TID = @gltid AND accountcode = @r AND transactionType = 'DR'",
                                    conn, tx))
                                {
                                    delGl.Parameters.AddWithValue("@gltid", glTid);
                                    delGl.Parameters.AddWithValue("@r", regno);
                                    if (delGl.ExecuteNonQuery() == 0)
                                        throw new Exception(String.Format("GL entry TID {0} could not be deleted.", glTid));
                                }
                            }
                            else
                            {
                                double remaining = wi.BillAmount - wi.Amount;
                                using (MySqlCommand updGl = new MySqlCommand(
                                    "UPDATE fin_ledger SET transaction_amount = @amt, actual_amount = @amt, ugx_amount = @amt " +
                                    "WHERE TID = @gltid AND accountcode = @r AND transactionType = 'DR'",
                                    conn, tx))
                                {
                                    updGl.Parameters.AddWithValue("@amt", remaining);
                                    updGl.Parameters.AddWithValue("@gltid", glTid);
                                    updGl.Parameters.AddWithValue("@r", regno);
                                    if (updGl.ExecuteNonQuery() == 0)
                                        throw new Exception(String.Format("GL entry TID {0} could not be updated.", glTid));
                                }
                            }
                        }
                    }

                    // ── Step 3: Create fin_bill_waivers header ──
                    // credit_tid / credit_gl_tid are 0 — no offsetting credit transaction is created
                    using (MySqlCommand wh = new MySqlCommand(
                        @"INSERT INTO fin_bill_waivers
                            (regno, waiver_category, waiver_reason, total_amount, credit_tid, credit_gl_tid,
                             acadyear, semester, status, created_by, created_at)
                          VALUES (@r, @cat, @rsn, @amt, 0, 0, @y, @s, 'Active', @user, @now)",
                        conn, tx))
                    {
                        wh.Parameters.AddWithValue("@r", regno);
                        wh.Parameters.AddWithValue("@cat", category);
                        wh.Parameters.AddWithValue("@rsn", reason);
                        wh.Parameters.AddWithValue("@amt", totalAmount);
                        wh.Parameters.AddWithValue("@y", acadyear);
                        wh.Parameters.AddWithValue("@s", semester);
                        wh.Parameters.AddWithValue("@user", user);
                        wh.Parameters.AddWithValue("@now", now);
                        wh.ExecuteNonQuery();
                        newWaiverID = wh.LastInsertedId;
                    }

                    // ── Step 4: Insert waiver line items using pre-captured data ──
                    // (the original bill rows may already be deleted at this point)
                    foreach (WaiverItem wi in items)
                    {
                        using (MySqlCommand li = new MySqlCommand(
                            @"INSERT INTO fin_bill_waiver_items
                                (waiver_id, original_tid, bill_amount, waived_amount, bill_detail)
                              VALUES (@wid, @tid, @bamt, @wamt, @det)",
                            conn, tx))
                        {
                            li.Parameters.AddWithValue("@wid", newWaiverID);
                            li.Parameters.AddWithValue("@tid", wi.TID);
                            li.Parameters.AddWithValue("@bamt", wi.BillAmount);
                            li.Parameters.AddWithValue("@wamt", wi.Amount);
                            li.Parameters.AddWithValue("@det", wi.OrigDetail);
                            li.ExecuteNonQuery();
                        }
                    }

                    tx.Commit();

                    // Success response
                    Response.Write(String.Format(
                        "{{\"ok\":true,\"waiver_id\":{0},\"total\":{1},\"message\":\"Waiver #{0} applied. {2} bill transaction{3} deleted. UGX {4} waived from {5}.\"}}",
                        newWaiverID, totalAmount.ToString("F0"),
                        items.Count, items.Count == 1 ? "" : "s",
                        totalAmount.ToString("N0"), JsEsc(regno)));
                }
                catch
                {
                    try { tx.Rollback(); } catch { }
                    throw;
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Apply Balance Fix (?ajax=apply_fix, POST)
    // Expects JSON body: { regno, target_balance, target_balance_sign, reason }
    // Computes current balance, posts only the required delta, and records a fix record.
    // ═════════════════════════════════════════════════════════════════════

    private void HandleApplyBalanceFix()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream))
            {
                body = sr.ReadToEnd();
            }

            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);

            string regno = data.ContainsKey("regno") ? Convert.ToString(data["regno"]).Trim() : "";
            long targetMagnitudeInt = 0;
            string reason = data.ContainsKey("reason") ? Convert.ToString(data["reason"]).Trim() : "";

            if (string.IsNullOrEmpty(regno)) throw new Exception("Student registration number is required.");
            string magnitudeError;
            if (!TryParseNonNegativeIntegerMagnitude(data.ContainsKey("target_balance") ? data["target_balance"] : null, out targetMagnitudeInt, out magnitudeError))
                throw new Exception(magnitudeError);
            if (string.IsNullOrEmpty(reason) || reason.Length < 5) throw new Exception("Reason is required (at least 5 characters).");

            // Target balance is ALWAYS positive (student owes) or zero.
            // Credit targets (negative) are never permitted - a student cannot be owed money by the school.
            // Ignore any target_balance_sign sent by client; always force positive.
            decimal targetBalance = Convert.ToDecimal(targetMagnitudeInt, CultureInfo.InvariantCulture);
            if (targetBalance < 0)
                throw new Exception("Target balance cannot be negative. A student account must be outstanding or cleared (zero). Credit targets are not permitted.");

            string user = GetCurrentUser();
            DateTime now = DateTime.Now;

            long newTrackingTid = 0;
            long newGlTid = 0;
            long newFixId = 0;

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                MySqlTransaction tx = conn.BeginTransaction();
                try
                {
                    decimal currentBalance = ComputeUnionAllBalance(conn, regno);
                    decimal delta = currentBalance - targetBalance;
                    decimal absAmount = Math.Abs(delta);

                    if (absAmount < 0.01m)
                        throw new Exception("Current balance already matches target balance. No adjustment is needed.");

                    bool postCredit = delta > 0; // reduce balance => credit/payment
                    string txType = postCredit ? "Payment" : "Bill";
                    string glType = postCredit ? "CR" : "DR";

                    string acadyear = "";
                    int semester = 1;
                    using (MySqlCommand cmdPeriod = new MySqlCommand(
                        @"SELECT acadyear, semester
                          FROM fin_studentfeestracking
                          WHERE regno = @r
                          ORDER BY trans_date DESC, TID DESC
                          LIMIT 1", conn, tx))
                    {
                        cmdPeriod.Parameters.AddWithValue("@r", regno);
                        using (MySqlDataReader rd = cmdPeriod.ExecuteReader())
                        {
                            if (rd.Read())
                            {
                                acadyear = rd["acadyear"] != DBNull.Value ? Convert.ToString(rd["acadyear"]) : "";
                                semester = rd["semester"] != DBNull.Value ? Convert.ToInt32(rd["semester"]) : 1;
                            }
                        }
                    }
                    if (string.IsNullOrEmpty(acadyear))
                        throw new Exception("Cannot infer academic year for this student. Ensure at least one fee transaction exists.");

                    string detail = string.Format(
                        "Balance Fix: {0} -> {1}. Reason: {2}",
                        FormatBalanceSignedForFix(currentBalance),
                        FormatBalanceSignedForFix(targetBalance),
                        reason);
                    if (detail.Length > 250) detail = detail.Substring(0, 247) + "...";

                    using (MySqlCommand ins = new MySqlCommand(
                        @"INSERT INTO fin_studentfeestracking
                            (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
                          VALUES (@r, @s, @y, @a, 0, @tt, @d, @dt, 'Posted')",
                        conn, tx))
                    {
                        ins.Parameters.AddWithValue("@r", regno);
                        ins.Parameters.AddWithValue("@s", semester);
                        ins.Parameters.AddWithValue("@y", acadyear);
                        ins.Parameters.AddWithValue("@a", Convert.ToDouble(absAmount));
                        ins.Parameters.AddWithValue("@tt", txType);
                        ins.Parameters.AddWithValue("@d", detail);
                        ins.Parameters.AddWithValue("@dt", now.ToString("yyyy-MM-dd"));
                        ins.ExecuteNonQuery();
                        newTrackingTid = ins.LastInsertedId;
                    }

                    using (MySqlCommand gl = new MySqlCommand(
                        @"INSERT INTO fin_ledger
                            (accountcode, account_type, transactionType, transaction_amount, particulars,
                             voucherNo, transactionDate, teller, timeLog, folio,
                             journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
                          VALUES (@ac, 'Student', @drcr, @amt, @part, @vno, @td, @user, @tl, @fo, '-', 'UGX', @amt, 0, 1, @amt)",
                        conn, tx))
                    {
                        gl.Parameters.AddWithValue("@ac", regno);
                        gl.Parameters.AddWithValue("@drcr", glType);
                        gl.Parameters.AddWithValue("@amt", Convert.ToDouble(absAmount));
                        gl.Parameters.AddWithValue("@part", detail);
                        gl.Parameters.AddWithValue("@vno", newTrackingTid);
                        gl.Parameters.AddWithValue("@td", now.ToString("yyyy-MM-dd"));
                        gl.Parameters.AddWithValue("@user", user);
                        gl.Parameters.AddWithValue("@tl", now);
                        gl.Parameters.AddWithValue("@fo", regno);
                        gl.ExecuteNonQuery();
                        newGlTid = gl.LastInsertedId;
                    }

                    using (MySqlCommand wh = new MySqlCommand(
                        @"INSERT INTO fin_bill_waivers
                            (regno, waiver_category, waiver_reason, total_amount, credit_tid, credit_gl_tid,
                             acadyear, semester, status, created_by, created_at,
                             fix_previous_balance, fix_target_balance, fix_transaction_type)
                          VALUES (@r, 'Balance Fix', @rsn, @amt, @ctid, @gltid, @y, @s, 'Active', @user, @now, @prev, @target, @kind)",
                        conn, tx))
                    {
                        wh.Parameters.AddWithValue("@r", regno);
                        wh.Parameters.AddWithValue("@rsn", reason);
                        wh.Parameters.AddWithValue("@amt", Convert.ToDouble(absAmount));
                        wh.Parameters.AddWithValue("@ctid", newTrackingTid);
                        wh.Parameters.AddWithValue("@gltid", newGlTid);
                        wh.Parameters.AddWithValue("@y", acadyear);
                        wh.Parameters.AddWithValue("@s", semester);
                        wh.Parameters.AddWithValue("@user", user);
                        wh.Parameters.AddWithValue("@now", now);
                        wh.Parameters.AddWithValue("@prev", Convert.ToDouble(currentBalance));
                        wh.Parameters.AddWithValue("@target", Convert.ToDouble(targetBalance));
                        wh.Parameters.AddWithValue("@kind", glType);
                        wh.ExecuteNonQuery();
                        newFixId = wh.LastInsertedId;
                    }

                    using (MySqlCommand li = new MySqlCommand(
                        @"INSERT INTO fin_bill_waiver_items
                            (waiver_id, original_tid, bill_amount, waived_amount, bill_detail)
                          VALUES (@wid, @tid, @bamt, @wamt, @det)",
                        conn, tx))
                    {
                        li.Parameters.AddWithValue("@wid", newFixId);
                        li.Parameters.AddWithValue("@tid", newTrackingTid);
                        li.Parameters.AddWithValue("@bamt", Convert.ToDouble(absAmount));
                        li.Parameters.AddWithValue("@wamt", Convert.ToDouble(absAmount));
                        li.Parameters.AddWithValue("@det", detail);
                        li.ExecuteNonQuery();
                    }

                    decimal afterBalance = ComputeUnionAllBalance(conn, regno);
                    decimal tolerance = 0.05m; // Allow 0.05 rounding difference
                    if (Math.Abs(afterBalance - targetBalance) > tolerance)
                    {
                        tx.Rollback();
                        throw new Exception(
                            string.Format(
                                "CRITICAL: Balance Fix verification FAILED. Expected balance {0}, but got {1}. " +
                                "Transaction rolled back. Check database integrity and retry.",
                                FormatBalanceSignedForFix(targetBalance),
                                FormatBalanceSignedForFix(afterBalance)));
                    }

                    tx.Commit();

                    Response.Write(string.Format(
                        "{{\"ok\":true,\"fix_id\":{0},\"tracking_tid\":{1},\"gl_tid\":{2},\"amount\":\"{3}\",\"action\":\"{4}\",\"before\":\"{5}\",\"after\":\"{6}\",\"message\":\"Balance fix #{0} posted successfully.\"}}",
                        newFixId,
                        newTrackingTid,
                        newGlTid,
                        absAmount.ToString("F2", CultureInfo.InvariantCulture),
                        JsEsc(glType),
                        JsEsc(FormatBalanceForUi(currentBalance)),
                        JsEsc(FormatBalanceForUi(afterBalance))));
                }
                catch
                {
                    try { tx.Rollback(); } catch { }
                    throw;
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: View Waiver Detail (?ajax=detail&id=...)
    // Returns JSON with full waiver header + line items.
    // ═════════════════════════════════════════════════════════════════════

    private void HandleWaiverDetail()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        try
        {
            int waiverId = 0;
            int.TryParse(Request.QueryString["id"] ?? "", out waiverId);
            if (waiverId <= 0) throw new Exception("Invalid waiver ID.");

            StringBuilder json = new StringBuilder();
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT w.waiver_id, w.regno, w.waiver_category, w.waiver_reason,
                             w.total_amount, w.credit_tid, w.credit_gl_tid,
                             w.acadyear, w.semester, w.status, w.created_by,
                             w.fix_previous_balance, w.fix_target_balance, COALESCE(w.fix_transaction_type,'') AS fix_transaction_type,
                             DATE_FORMAT(w.created_at, '%d/%m/%Y %H:%i') AS created_fmt,
                             COALESCE(w.reversed_by, '') AS reversed_by,
                             COALESCE(w.reversed_reason, '') AS reversed_reason,
                             CASE WHEN w.reversed_at IS NOT NULL THEN DATE_FORMAT(w.reversed_at, '%d/%m/%Y %H:%i') ELSE '' END AS reversed_fmt,
                             TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                             COALESCE(p.progname, 'N/A') AS programme
                      FROM fin_bill_waivers w
                      LEFT JOIN campus_dynamics.acad_student s ON s.regno = w.regno
                      LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = s.progid
                      WHERE w.waiver_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", waiverId);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) throw new Exception("Waiver not found.");
                        json.Append("{");
                        json.AppendFormat("\"waiver_id\":{0},", rdr["waiver_id"]);
                        json.AppendFormat("\"regno\":\"{0}\",", JsEsc(rdr["regno"].ToString()));
                        json.AppendFormat("\"student_name\":\"{0}\",", JsEsc(rdr["student_name"].ToString()));
                        json.AppendFormat("\"programme\":\"{0}\",", JsEsc(rdr["programme"].ToString()));
                        json.AppendFormat("\"waiver_category\":\"{0}\",", JsEsc(rdr["waiver_category"].ToString()));
                        json.AppendFormat("\"waiver_reason\":\"{0}\",", JsEsc(rdr["waiver_reason"].ToString()));
                        json.AppendFormat("\"total_amount\":{0},", Convert.ToDouble(rdr["total_amount"]).ToString("F0"));
                        json.AppendFormat("\"credit_tid\":{0},", rdr["credit_tid"] != DBNull.Value ? rdr["credit_tid"].ToString() : "0");
                        json.AppendFormat("\"credit_gl_tid\":{0},", rdr["credit_gl_tid"] != DBNull.Value ? rdr["credit_gl_tid"].ToString() : "0");
                        json.AppendFormat("\"acadyear\":\"{0}\",", JsEsc(rdr["acadyear"].ToString()));
                        json.AppendFormat("\"semester\":{0},", rdr["semester"]);
                        json.AppendFormat("\"status\":\"{0}\",", JsEsc(rdr["status"].ToString()));
                        json.AppendFormat("\"created_by\":\"{0}\",", JsEsc(rdr["created_by"].ToString()));
                        json.AppendFormat("\"created_at\":\"{0}\",", JsEsc(rdr["created_fmt"].ToString()));
                        json.AppendFormat("\"fix_previous_balance\":\"{0}\",", rdr["fix_previous_balance"] != DBNull.Value ? Convert.ToDecimal(rdr["fix_previous_balance"]).ToString("F2", CultureInfo.InvariantCulture) : "");
                        json.AppendFormat("\"fix_target_balance\":\"{0}\",", rdr["fix_target_balance"] != DBNull.Value ? Convert.ToDecimal(rdr["fix_target_balance"]).ToString("F2", CultureInfo.InvariantCulture) : "");
                        json.AppendFormat("\"fix_transaction_type\":\"{0}\",", JsEsc(rdr["fix_transaction_type"].ToString()));
                        json.AppendFormat("\"reversed_by\":\"{0}\",", JsEsc(rdr["reversed_by"].ToString()));
                        json.AppendFormat("\"reversed_reason\":\"{0}\",", JsEsc(rdr["reversed_reason"].ToString()));
                        json.AppendFormat("\"reversed_at\":\"{0}\",", JsEsc(rdr["reversed_fmt"].ToString()));
                    }
                }
                json.Append("\"items\":[");
                using (MySqlCommand cmd2 = new MySqlCommand(
                    "SELECT item_id, original_tid, bill_amount, waived_amount, bill_detail FROM fin_bill_waiver_items WHERE waiver_id = @id ORDER BY item_id",
                    conn))
                {
                    cmd2.Parameters.AddWithValue("@id", waiverId);
                    bool first = true;
                    using (MySqlDataReader rdr2 = cmd2.ExecuteReader())
                    {
                        while (rdr2.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat(
                                "{{\"item_id\":{0},\"original_tid\":{1},\"bill_amount\":{2},\"waived_amount\":{3},\"bill_detail\":\"{4}\"}}",
                                rdr2["item_id"], rdr2["original_tid"],
                                Convert.ToDouble(rdr2["bill_amount"]).ToString("F0"),
                                Convert.ToDouble(rdr2["waived_amount"]).ToString("F0"),
                                JsEsc(rdr2["bill_detail"] != DBNull.Value ? rdr2["bill_detail"].ToString() : ""));
                        }
                    }
                }
                json.Append("]}");
            }
            Response.Write(json.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Reverse Waiver (?ajax=reverse, POST)
    // Expects JSON body: { waiver_id, reason }
    //
    // TRANSACTION:
    //   1. Validate original waiver is Active (FOR UPDATE lock)
    //   2. INSERT DR (Bill) into fin_studentfeestracking (reverses the credit)
    //   3. INSERT DR into fin_ledger (reverses the CR)
    //   4. UPDATE original waiver → status='Reversed', reversed_by, reversed_at
    //   5. INSERT new waiver with category='Reversal'
    //   6. INSERT reversal waiver items (mirror of original)
    //   All within a single MySQL transaction.
    // ═════════════════════════════════════════════════════════════════════

    private void HandleReverseWaiver()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream))
            {
                body = sr.ReadToEnd();
            }
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);
            int waiverId = data.ContainsKey("waiver_id") ? Convert.ToInt32(data["waiver_id"]) : 0;
            string reason = data.ContainsKey("reason") ? Convert.ToString(data["reason"]).Trim() : "";

            if (waiverId <= 0) throw new Exception("Waiver ID is required.");
            if (string.IsNullOrEmpty(reason) || reason.Length < 5)
                throw new Exception("Reversal reason is required (at least 5 characters).");

            string user = GetCurrentUser();
            DateTime now = DateTime.Now;
            long newBillTID = 0;
            long newGLTID = 0;
            long newWaiverID = 0;

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                MySqlTransaction tx = conn.BeginTransaction();
                try
                {
                    // ── Load & lock original waiver ──
                    string regno = "";
                    string origCategory = "";
                    double totalAmount = 0;
                    string acadyear = "";
                    int semester = 0;
                    using (MySqlCommand cmd = new MySqlCommand(
                        "SELECT waiver_id, regno, waiver_category, total_amount, acadyear, semester FROM fin_bill_waivers WHERE waiver_id = @id AND status = 'Active' FOR UPDATE",
                        conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@id", waiverId);
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (!rdr.Read())
                                throw new Exception(String.Format("Waiver #{0} not found or already reversed.", waiverId));
                            regno = rdr["regno"].ToString();
                            origCategory = rdr["waiver_category"].ToString();
                            totalAmount = Convert.ToDouble(rdr["total_amount"]);
                            acadyear = rdr["acadyear"].ToString();
                            semester = Convert.ToInt32(rdr["semester"]);
                        }
                    }

                    if (origCategory == "Balance Fix")
                    {
                        long originalTrackingTid = 0;
                        long originalGlTid = 0;
                        using (MySqlCommand getIds = new MySqlCommand(
                            "SELECT credit_tid, credit_gl_tid FROM fin_bill_waivers WHERE waiver_id = @id",
                            conn, tx))
                        {
                            getIds.Parameters.AddWithValue("@id", waiverId);
                            using (MySqlDataReader rr = getIds.ExecuteReader())
                            {
                                if (rr.Read())
                                {
                                    originalTrackingTid = rr["credit_tid"] != DBNull.Value ? Convert.ToInt64(rr["credit_tid"]) : 0;
                                    originalGlTid = rr["credit_gl_tid"] != DBNull.Value ? Convert.ToInt64(rr["credit_gl_tid"]) : 0;
                                }
                            }
                        }

                        if (originalTrackingTid <= 0)
                            throw new Exception("Balance fix record does not have a linked transaction to reverse.");

                        int glDeleted = 0;
                        if (originalGlTid > 0)
                        {
                            using (MySqlCommand delGlById = new MySqlCommand(
                                "DELETE FROM fin_ledger WHERE TID = @tid AND accountcode = @reg AND account_type = 'Student' LIMIT 1",
                                conn, tx))
                            {
                                delGlById.Parameters.AddWithValue("@tid", originalGlTid);
                                delGlById.Parameters.AddWithValue("@reg", regno);
                                glDeleted = delGlById.ExecuteNonQuery();
                            }
                        }
                        if (glDeleted == 0)
                        {
                            using (MySqlCommand delGlByVoucher = new MySqlCommand(
                                "DELETE FROM fin_ledger WHERE voucherNo = @v AND accountcode = @reg AND account_type = 'Student' LIMIT 1",
                                conn, tx))
                            {
                                delGlByVoucher.Parameters.AddWithValue("@v", originalTrackingTid);
                                delGlByVoucher.Parameters.AddWithValue("@reg", regno);
                                glDeleted = delGlByVoucher.ExecuteNonQuery();
                            }
                        }

                        int trDeleted = 0;
                        using (MySqlCommand delTrack = new MySqlCommand(
                            "DELETE FROM fin_studentfeestracking WHERE TID = @tid AND regno = @reg AND detail LIKE 'Balance Fix:%' LIMIT 1",
                            conn, tx))
                        {
                            delTrack.Parameters.AddWithValue("@tid", originalTrackingTid);
                            delTrack.Parameters.AddWithValue("@reg", regno);
                            trDeleted = delTrack.ExecuteNonQuery();
                        }
                        if (trDeleted == 0)
                            throw new Exception("Linked balance-fix transaction was not found or is not eligible for deletion.");

                        using (MySqlCommand upd = new MySqlCommand(
                            "UPDATE fin_bill_waivers SET status = 'Reversed', reversed_by = @user, reversed_at = @now, reversed_reason = @rsn WHERE waiver_id = @id",
                            conn, tx))
                        {
                            upd.Parameters.AddWithValue("@user", user);
                            upd.Parameters.AddWithValue("@now", now);
                            upd.Parameters.AddWithValue("@id", waiverId);
                            upd.Parameters.AddWithValue("@rsn", reason);
                            upd.ExecuteNonQuery();
                        }

                        decimal newBalance = ComputeUnionAllBalance(conn, regno);
                        tx.Commit();
                        Response.Write(String.Format(
                            "{{\"ok\":true,\"new_waiver_id\":0,\"debit_tid\":0,\"gl_tid\":0,\"total\":{0},\"message\":\"Balance fix #{1} reversed successfully. Linked transactions were deleted. New balance: {2}.\"}}",
                            totalAmount.ToString("F0"), waiverId, JsEsc(FormatBalanceForUi(newBalance))));
                        Response.End();
                        return;
                    }

                    // ── Load original waiver items ──
                    List<int> itemTIDs = new List<int>();
                    List<double> itemBillAmounts = new List<double>();
                    List<double> itemWaivedAmounts = new List<double>();
                    List<string> itemDetails = new List<string>();
                    using (MySqlCommand cmd = new MySqlCommand(
                        "SELECT original_tid, bill_amount, waived_amount, bill_detail FROM fin_bill_waiver_items WHERE waiver_id = @id",
                        conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@id", waiverId);
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                itemTIDs.Add(Convert.ToInt32(rdr["original_tid"]));
                                itemBillAmounts.Add(Convert.ToDouble(rdr["bill_amount"]));
                                itemWaivedAmounts.Add(Convert.ToDouble(rdr["waived_amount"]));
                                itemDetails.Add(rdr["bill_detail"] != DBNull.Value ? rdr["bill_detail"].ToString() : "");
                            }
                        }
                    }

                    // ── Step 1: Re-insert the bill (waiver deleted it; reversal puts it back) ──
                    string reversalDetail = String.Format("Waiver Reversal (#{0}): {1}", waiverId, reason);
                    if (reversalDetail.Length > 250) reversalDetail = reversalDetail.Substring(0, 247) + "...";

                    using (MySqlCommand ins = new MySqlCommand(
                        @"INSERT INTO fin_studentfeestracking
                            (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
                          VALUES (@r, @s, @y, @a, 0, 'Bill', @d, @dt, 'Posted')",
                        conn, tx))
                    {
                        ins.Parameters.AddWithValue("@r", regno);
                        ins.Parameters.AddWithValue("@s", semester);
                        ins.Parameters.AddWithValue("@y", acadyear);
                        ins.Parameters.AddWithValue("@a", totalAmount);
                        ins.Parameters.AddWithValue("@d", reversalDetail);
                        ins.Parameters.AddWithValue("@dt", now.ToString("yyyy-MM-dd"));
                        ins.ExecuteNonQuery();
                        newBillTID = ins.LastInsertedId;
                    }

                    // ── Step 2: Mirror to fin_ledger (GL) — DR entry ──
                    using (MySqlCommand gl = new MySqlCommand(
                        @"INSERT INTO fin_ledger
                            (accountcode, account_type, transactionType, transaction_amount, particulars,
                             voucherNo, transactionDate, teller, timeLog, folio,
                             journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
                          VALUES (@ac, 'Student', 'DR', @amt, @part, @vno, @td, @user, @tl, @fo, '-', 'UGX', @amt, 0, 1, @amt)",
                        conn, tx))
                    {
                        gl.Parameters.AddWithValue("@ac", regno);
                        gl.Parameters.AddWithValue("@amt", totalAmount);
                        gl.Parameters.AddWithValue("@part", reversalDetail);
                        gl.Parameters.AddWithValue("@vno", newBillTID);
                        gl.Parameters.AddWithValue("@td", now.ToString("yyyy-MM-dd"));
                        gl.Parameters.AddWithValue("@user", user);
                        gl.Parameters.AddWithValue("@tl", now);
                        gl.Parameters.AddWithValue("@fo", regno);
                        gl.ExecuteNonQuery();
                        newGLTID = gl.LastInsertedId;
                    }

                    // ── Step 3: Mark original waiver as Reversed ──
                    using (MySqlCommand upd = new MySqlCommand(
                        "UPDATE fin_bill_waivers SET status = 'Reversed', reversed_by = @user, reversed_at = @now, reversed_reason = @rsn WHERE waiver_id = @id",
                        conn, tx))
                    {
                        upd.Parameters.AddWithValue("@user", user);
                        upd.Parameters.AddWithValue("@now", now);
                        upd.Parameters.AddWithValue("@rsn", reason);
                        upd.Parameters.AddWithValue("@id", waiverId);
                        upd.ExecuteNonQuery();
                    }

                    // ── Step 4: Create reversal waiver record ──
                    string reversalReason = String.Format("Reversal of Waiver #{0} ({1}): {2}", waiverId, origCategory, reason);
                    if (reversalReason.Length > 500) reversalReason = reversalReason.Substring(0, 497) + "...";

                    using (MySqlCommand wh = new MySqlCommand(
                        @"INSERT INTO fin_bill_waivers
                            (regno, waiver_category, waiver_reason, total_amount, credit_tid, credit_gl_tid,
                             acadyear, semester, status, created_by, created_at)
                          VALUES (@r, 'Reversal', @rsn, @amt, @ctid, @gltid, @y, @s, 'Active', @user, @now)",
                        conn, tx))
                    {
                        wh.Parameters.AddWithValue("@r", regno);
                        wh.Parameters.AddWithValue("@rsn", reversalReason);
                        wh.Parameters.AddWithValue("@amt", totalAmount);
                        wh.Parameters.AddWithValue("@ctid", newBillTID);
                        wh.Parameters.AddWithValue("@gltid", newGLTID);
                        wh.Parameters.AddWithValue("@y", acadyear);
                        wh.Parameters.AddWithValue("@s", semester);
                        wh.Parameters.AddWithValue("@user", user);
                        wh.Parameters.AddWithValue("@now", now);
                        wh.ExecuteNonQuery();
                        newWaiverID = wh.LastInsertedId;
                    }

                    // ── Step 5: Insert reversal waiver items ──
                    for (int i = 0; i < itemTIDs.Count; i++)
                    {
                        using (MySqlCommand li = new MySqlCommand(
                            @"INSERT INTO fin_bill_waiver_items
                                (waiver_id, original_tid, bill_amount, waived_amount, bill_detail)
                              VALUES (@wid, @tid, @bamt, @wamt, @det)",
                            conn, tx))
                        {
                            li.Parameters.AddWithValue("@wid", newWaiverID);
                            li.Parameters.AddWithValue("@tid", itemTIDs[i]);
                            li.Parameters.AddWithValue("@bamt", itemBillAmounts[i]);
                            li.Parameters.AddWithValue("@wamt", itemWaivedAmounts[i]);
                            li.Parameters.AddWithValue("@det", itemDetails[i]);
                            li.ExecuteNonQuery();
                        }
                    }

                    tx.Commit();
                    Response.Write(String.Format(
                        "{{\"ok\":true,\"new_waiver_id\":{0},\"debit_tid\":{1},\"gl_tid\":{2},\"total\":{3},\"message\":\"Waiver #{4} reversed. Bill of UGX {5} re-posted to {6}. Reversal waiver #{0} created.\"}}",
                        newWaiverID, newBillTID, newGLTID, totalAmount.ToString("F0"),
                        waiverId, totalAmount.ToString("N0"), JsEsc(regno)));
                }
                catch
                {
                    try { tx.Rollback(); } catch { }
                    throw;
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // Load waiver history grid (PageLoad)
    // ═════════════════════════════════════════════════════════════════════

    private void LoadWaiverHistory()
    {
        try
        {
            // Read filter values from server controls
            string search         = txtSearch.Text.Trim();
            string statusFilter   = ddlStatus.SelectedValue;
            string categoryFilter = ddlCategory.SelectedValue;
            string dateFrom       = txtDateFrom.Text.Trim();
            string dateTo         = txtDateTo.Text.Trim();

            int page = 1;
            int.TryParse(hidPage.Value, out page);
            if (page < 1) page = 1;

            int pageSize = 25;
            int.TryParse(ddlPageSize.SelectedValue, out pageSize);
            if (pageSize < 10) pageSize = 25;
            int offset = (page - 1) * pageSize;

            // Build filter WHERE clause
            StringBuilder where = new StringBuilder("1=1");
            List<MySqlParameter> filterPs = new List<MySqlParameter>();
            BuildFilterClause(search, statusFilter, categoryFilter, dateFrom, dateTo, where, filterPs);

            string fromClause =
                " FROM fin_bill_waivers w" +
                " LEFT JOIN campus_dynamics.acad_student s ON s.regno = w.regno" +
                " WHERE " + where.ToString();

            string countSql = "SELECT COUNT(*)" + fromClause;

            string dataSql =
                "SELECT w.waiver_id, w.regno, w.waiver_category, w.waiver_reason," +
                " w.total_amount, w.credit_tid, w.acadyear, w.semester," +
                " w.status, w.created_by," +
                " DATE_FORMAT(w.created_at, '%d/%m/%Y %H:%i') AS created_fmt," +
                " TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name," +
                " (SELECT COUNT(*) FROM fin_bill_waiver_items wi WHERE wi.waiver_id = w.waiver_id) AS item_count" +
                fromClause +
                " ORDER BY w.created_at DESC LIMIT @pgLimit OFFSET @pgOffset";

            // Stats are always global — institution-wide totals regardless of filter
            const string statsSql =
                "SELECT COUNT(*) AS total," +
                " SUM(CASE WHEN status='Active' THEN 1 ELSE 0 END) AS active," +
                " SUM(CASE WHEN status='Reversed' THEN 1 ELSE 0 END) AS reversed," +
                " SUM(CASE WHEN status='Active' THEN total_amount ELSE 0 END) AS total_val" +
                " FROM fin_bill_waivers";

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // ── Global stats ─────────────────────────────────────────────
                int statsTotal = 0, statsActive = 0, statsReversed = 0;
                double statsTotalVal = 0;
                using (MySqlCommand sc = new MySqlCommand(statsSql, conn))
                using (MySqlDataReader sr = sc.ExecuteReader())
                {
                    if (sr.Read())
                    {
                        statsTotal    = sr["total"]     != DBNull.Value ? Convert.ToInt32(sr["total"])     : 0;
                        statsActive   = sr["active"]    != DBNull.Value ? Convert.ToInt32(sr["active"])    : 0;
                        statsReversed = sr["reversed"]  != DBNull.Value ? Convert.ToInt32(sr["reversed"])  : 0;
                        statsTotalVal = sr["total_val"] != DBNull.Value ? Convert.ToDouble(sr["total_val"]) : 0;
                    }
                }
                litStats.Text = BuildStats(statsTotal, statsActive, statsReversed, statsTotalVal);

                // ── Count filtered rows ──────────────────────────────────────
                int totalCount = 0;
                using (MySqlCommand cc = new MySqlCommand(countSql, conn))
                {
                    foreach (MySqlParameter p in filterPs)
                        cc.Parameters.Add(new MySqlParameter(p.ParameterName, p.Value));
                    object cnt = cc.ExecuteScalar();
                    if (cnt != null && cnt != DBNull.Value) totalCount = Convert.ToInt32(cnt);
                }

                if (totalCount == 0)
                {
                    bool hasFilter = !string.IsNullOrEmpty(search) || !string.IsNullOrEmpty(statusFilter) ||
                                     !string.IsNullOrEmpty(categoryFilter) || !string.IsNullOrEmpty(dateFrom) ||
                                     !string.IsNullOrEmpty(dateTo);
                    litHistory.Text = "<div style='padding:24px;text-align:center;color:#888;font-size:12px;'>" +
                        (hasFilter
                            ? "No waivers found matching the current filters."
                            : "No waivers have been created yet. Use the <strong>New Waiver</strong> button above to get started.") +
                        "</div>";
                    litPagination.Text = "";
                    litResultInfo.Text = "";
                    return;
                }

                // ── Clamp page ───────────────────────────────────────────────
                int totalPages = (int)Math.Ceiling((double)totalCount / pageSize);
                if (page > totalPages)
                {
                    page = totalPages;
                    hidPage.Value = page.ToString();
                    offset = (page - 1) * pageSize;
                }

                int fromRow = offset + 1;
                int toRow   = Math.Min(offset + pageSize, totalCount);
                litResultInfo.Text = string.Format("Showing {0}–{1} of {2}", fromRow, toRow, totalCount);

                // ── Load page data ───────────────────────────────────────────
                DataTable dt = new DataTable();
                using (MySqlCommand dc = new MySqlCommand(dataSql, conn))
                {
                    foreach (MySqlParameter p in filterPs)
                        dc.Parameters.Add(new MySqlParameter(p.ParameterName, p.Value));
                    dc.Parameters.AddWithValue("@pgLimit",  pageSize);
                    dc.Parameters.AddWithValue("@pgOffset", offset);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(dc)) { da.Fill(dt); }
                }

                // ── Build table HTML ─────────────────────────────────────────
                StringBuilder html = new StringBuilder();
                html.Append("<table class='bw-table'><thead><tr>");
                html.Append("<th>#</th><th>Date</th><th>Student</th><th>RegNo</th><th>Category</th><th>Bills</th>" +
                            "<th class='bw-table--right'>Amount</th><th>Credit TID</th><th>Status</th><th>By</th>" +
                            "<th style='text-align:center;'>Actions</th>");
                html.Append("</tr></thead><tbody>");

                int rowNum = offset;
                foreach (DataRow r in dt.Rows)
                {
                    rowNum++;
                    string wid    = r["waiver_id"].ToString();
                    string date   = r["created_fmt"]  != DBNull.Value ? r["created_fmt"].ToString()               : "";
                    string name   = r["student_name"] != DBNull.Value ? r["student_name"].ToString()              : "";
                    string reg    = r["regno"]         != DBNull.Value ? r["regno"].ToString()                     : "";
                    string cat    = r["waiver_category"] != DBNull.Value ? r["waiver_category"].ToString()         : "";
                    double amt    = r["total_amount"]  != DBNull.Value ? Convert.ToDouble(r["total_amount"])       : 0;
                    string ctid   = r["credit_tid"]    != DBNull.Value ? r["credit_tid"].ToString()                : "-";
                    string status = r["status"]        != DBNull.Value ? r["status"].ToString()                    : "";
                    string by     = r["created_by"]    != DBNull.Value ? r["created_by"].ToString()                : "";
                    int items     = r["item_count"]    != DBNull.Value ? Convert.ToInt32(r["item_count"])          : 0;

                    string statusBadge = status == "Active"
                        ? "<span class='fs-badge--green'>" + HttpUtility.HtmlEncode(status) + "</span>"
                        : "<span class='fs-badge--red'>"   + HttpUtility.HtmlEncode(status) + "</span>";

                    string catBadge = GetCategoryBadge(cat);
                    string oddClass = (rowNum % 2 == 0) ? " class='bw-row--alt'" : "";

                    html.Append("<tr" + oddClass + ">");
                    html.Append("<td><span class='fs-code'>#" + HttpUtility.HtmlEncode(wid) + "</span></td>");
                    html.Append("<td>" + HttpUtility.HtmlEncode(date) + "</td>");
                    html.Append("<td><strong>" + HttpUtility.HtmlEncode(name) + "</strong></td>");
                    html.Append("<td><span class='fs-code'>" + HttpUtility.HtmlEncode(reg) + "</span></td>");
                    html.Append("<td>" + catBadge + "</td>");
                    html.Append("<td style='text-align:center;'>" + items + "</td>");
                    html.Append("<td class='bw-table--right'><strong>UGX " + amt.ToString("N0") + "</strong></td>");
                    html.Append("<td><a href='FeesTransactions.aspx?tid=" + HttpUtility.HtmlEncode(ctid) + "' class='bw-link'>" + HttpUtility.HtmlEncode(ctid) + "</a></td>");
                    html.Append("<td>" + statusBadge + "</td>");
                    html.Append("<td>" + HttpUtility.HtmlEncode(by) + "</td>");
                    html.Append("<td style='text-align:center;white-space:nowrap;'>");
                    html.Append("<button type='button' class='bw-btn-action bw-btn-action--view' onclick='viewWaiver(" + wid + ")' title='View Details'>" +
                                "<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>" +
                                "<path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/><circle cx='12' cy='12' r='3'/></svg></button>");
                    if (status == "Active")
                    {
                        html.Append(" <button type='button' class='bw-btn-action bw-btn-action--reverse' onclick='openReverse(" + wid + ")' title='Reverse Waiver'>" +
                                    "<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>" +
                                    "<polyline points='1 4 1 10 7 10'/><path d='M3.51 15a9 9 0 1 0 2.13-9.36L1 10'/></svg></button>");
                    }
                    html.Append("</td></tr>");
                }

                html.Append("</tbody></table>");
                litHistory.Text = html.ToString();

                // ── Pagination ───────────────────────────────────────────────
                litPagination.Text = BuildPagination(totalCount, page, pageSize, totalPages);
            }
        }
        catch (Exception ex)
        {
            litHistory.Text    = "<div class='fs-toast fs-toast--error'>Error loading waiver history: " + HttpUtility.HtmlEncode(ex.Message) + "</div>";
            litStats.Text      = BuildStats(0, 0, 0, 0);
            litPagination.Text = "";
            litResultInfo.Text = "";
        }
    }

    private void BuildFilterClause(string search, string status, string category,
        string dateFrom, string dateTo, StringBuilder where, List<MySqlParameter> ps)
    {
        if (!string.IsNullOrEmpty(search))
        {
            where.Append(" AND (w.regno LIKE @bwSearch OR TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) LIKE @bwSearch)");
            ps.Add(new MySqlParameter("@bwSearch", "%" + search + "%"));
        }
        if (!string.IsNullOrEmpty(status))
        {
            where.Append(" AND w.status = @bwStatus");
            ps.Add(new MySqlParameter("@bwStatus", status));
        }
        if (!string.IsNullOrEmpty(category))
        {
            where.Append(" AND w.waiver_category = @bwCat");
            ps.Add(new MySqlParameter("@bwCat", category));
        }
        if (!string.IsNullOrEmpty(dateFrom))
        {
            where.Append(" AND DATE(w.created_at) >= @bwFrom");
            ps.Add(new MySqlParameter("@bwFrom", dateFrom));
        }
        if (!string.IsNullOrEmpty(dateTo))
        {
            where.Append(" AND DATE(w.created_at) <= @bwTo");
            ps.Add(new MySqlParameter("@bwTo", dateTo));
        }
    }

    private static string BuildPagination(int total, int page, int pageSize, int totalPages)
    {
        if (totalPages <= 1) return "";

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='bw-pagination'>");
        sb.AppendFormat("<div class='bw-pagination__info'>{0} total result{1}</div>", total, total == 1 ? "" : "s");
        sb.Append("<div class='bw-pagination__pages'>");

        // Prev
        if (page > 1)
            sb.AppendFormat("<button type='button' class='bw-page-btn' onclick='bwGoPage({0})'>&#8249;</button>", page - 1);
        else
            sb.Append("<button type='button' class='bw-page-btn' disabled>&#8249;</button>");

        int startPage = Math.Max(1, page - 3);
        int endPage   = Math.Min(totalPages, page + 3);

        if (startPage > 1)
        {
            sb.Append("<button type='button' class='bw-page-btn' onclick='bwGoPage(1)'>1</button>");
            if (startPage > 2) sb.Append("<span class='bw-page-ellipsis'>&#8230;</span>");
        }

        for (int i = startPage; i <= endPage; i++)
        {
            if (i == page)
                sb.AppendFormat("<button type='button' class='bw-page-btn bw-page-btn--active'>{0}</button>", i);
            else
                sb.AppendFormat("<button type='button' class='bw-page-btn' onclick='bwGoPage({0})'>{0}</button>", i);
        }

        if (endPage < totalPages)
        {
            if (endPage < totalPages - 1) sb.Append("<span class='bw-page-ellipsis'>&#8230;</span>");
            sb.AppendFormat("<button type='button' class='bw-page-btn' onclick='bwGoPage({0})'>{0}</button>", totalPages);
        }

        // Next
        if (page < totalPages)
            sb.AppendFormat("<button type='button' class='bw-page-btn' onclick='bwGoPage({0})'>&#8250;</button>", page + 1);
        else
            sb.Append("<button type='button' class='bw-page-btn' disabled>&#8250;</button>");

        sb.Append("</div></div>");
        return sb.ToString();
    }

    // ═════════════════════════════════════════════════════════════════════
    // Table Auto-Migration
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Creates fin_bill_waivers and fin_bill_waiver_items if they don't exist.
    /// Safe to call every request — uses CREATE TABLE IF NOT EXISTS.
    /// </summary>
    private void EnsureWaiverTables()
    {
        try
        {
            string ddl1 = @"CREATE TABLE IF NOT EXISTS fin_bill_waivers (
                waiver_id       INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
                regno           VARCHAR(25)     NOT NULL,
                waiver_category VARCHAR(50)     NOT NULL,
                waiver_reason   VARCHAR(500)    NOT NULL,
                total_amount    DOUBLE          NOT NULL,
                credit_tid      INT UNSIGNED    DEFAULT NULL,
                credit_gl_tid   INT UNSIGNED    DEFAULT NULL,
                acadyear        CHAR(25)        NOT NULL,
                semester        INT UNSIGNED    NOT NULL,
                status          VARCHAR(20)     NOT NULL DEFAULT 'Active',
                created_by      VARCHAR(45)     NOT NULL,
                created_at      DATETIME        NOT NULL,
                reversed_by     VARCHAR(45)     DEFAULT NULL,
                reversed_at     DATETIME        DEFAULT NULL,
                INDEX idx_bw_regno (regno),
                INDEX idx_bw_category (waiver_category),
                INDEX idx_bw_status (status),
                INDEX idx_bw_created (created_at)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8";

            string ddl2 = @"CREATE TABLE IF NOT EXISTS fin_bill_waiver_items (
                item_id         INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
                waiver_id       INT UNSIGNED    NOT NULL,
                original_tid    INT UNSIGNED    NOT NULL,
                bill_amount     DOUBLE          NOT NULL,
                waived_amount   DOUBLE          NOT NULL,
                bill_detail     VARCHAR(250)    DEFAULT NULL,
                INDEX idx_bwi_waiver (waiver_id),
                INDEX idx_bwi_tid (original_tid)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8";

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd1 = new MySqlCommand(ddl1, conn)) { cmd1.ExecuteNonQuery(); }
                using (MySqlCommand cmd2 = new MySqlCommand(ddl2, conn)) { cmd2.ExecuteNonQuery(); }
                AddColumnIfMissing(conn, "fin_bill_waivers", "fix_previous_balance", "DOUBLE NULL");
                AddColumnIfMissing(conn, "fin_bill_waivers", "fix_target_balance", "DOUBLE NULL");
                AddColumnIfMissing(conn, "fin_bill_waivers", "fix_transaction_type", "VARCHAR(4) NULL");
                AddColumnIfMissing(conn, "fin_bill_waivers", "reversed_reason", "VARCHAR(500) NULL");
            }
        }
        catch
        {
            // Silently ignore — tables likely already exist
        }
    }

    private void AddColumnIfMissing(MySqlConnection conn, string table, string column, string ddl)
    {
        using (MySqlCommand chk = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @t AND COLUMN_NAME = @c",
            conn))
        {
            chk.Parameters.AddWithValue("@t", table);
            chk.Parameters.AddWithValue("@c", column);
            long cnt = Convert.ToInt64(chk.ExecuteScalar());
            if (cnt == 0)
            {
                using (MySqlCommand alter = new MySqlCommand(
                    string.Format("ALTER TABLE {0} ADD COLUMN {1} {2}", table, column, ddl), conn))
                {
                    alter.ExecuteNonQuery();
                }
            }
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // Helpers
    // ═════════════════════════════════════════════════════════════════════

    private string GetCurrentUser()
    {
        if (Session != null && Session["ScreenName"] != null) return Session["ScreenName"].ToString();
        if (Session != null && Session["username"] != null) return Session["username"].ToString();
        if (User != null && User.Identity != null && User.Identity.IsAuthenticated)
            return User.Identity.Name;
        if (HttpContext.Current != null && HttpContext.Current.User != null
            && HttpContext.Current.User.Identity != null
            && HttpContext.Current.User.Identity.IsAuthenticated)
            return HttpContext.Current.User.Identity.Name;
        return "Unknown";
    }

    private static string JsEsc(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        return val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }

    /// <summary>
    /// Computes student balance using EXACTLY the same UNION ALL logic as the
    /// student portal (StudentFees.aspx.cs). This guarantees the Balance Fix
    /// always computes the correct delta relative to what the student actually sees.
    ///
    /// Source 1: fin_ledger (all GL entries for the student)
    /// Source 2: fin_studentfeestracking Bill/Payment rows NOT already in fin_ledger
    ///           (legacy entries before dual-write was deployed)
    ///
    /// Balance = SUM(DR) - SUM(CR) across both sources.
    /// Uses the same UNION ALL logic as StudentFees.aspx.cs:
    ///   1. All fin_ledger entries for the student (no account_type filter - matches portal view)
    ///   2. UNION ALL fin_studentfeestracking Posted rows NOT already represented in fin_ledger
    ///      (handles legacy bills created before dual-write was deployed)
    /// This ensures the balance shown here matches the student-facing fee statement exactly.
    /// </summary>
    private decimal ComputeUnionAllBalance(MySqlConnection conn, string regno)
    {
        const string sql =
            "SELECT " +
            "  COALESCE(SUM(dr_amount),0) - COALESCE(SUM(cr_amount),0) " +
            "FROM (" +
            "  SELECT " +
            "    CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END AS dr_amount," +
            "    CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END AS cr_amount " +
            "  FROM fin_ledger " +
            "  WHERE accountcode = @reg AND transaction_amount > 0 " +
            "  UNION ALL " +
            "  SELECT " +
            "    CASE WHEN trans_type='Bill' THEN amount ELSE 0 END AS dr_amount," +
            "    CASE WHEN trans_type='Payment' THEN amount ELSE 0 END AS cr_amount " +
            "  FROM fin_studentfeestracking t " +
            "  WHERE t.regno = @reg2 " +
            "    AND t.post_status = 'Posted' " +
            "    AND NOT EXISTS (" +
            "      SELECT 1 FROM fin_ledger fl2 " +
            "      WHERE fl2.accountcode = t.regno " +
            "        AND (" +
            "          fl2.voucherNo = CAST(t.TID AS CHAR)" +
            "          OR fl2.folio = CONCAT('BillNo:',CAST(t.TID AS CHAR))" +
            "          OR (" +
            "            fl2.transaction_amount = t.amount" +
            "            AND DATE(fl2.transactionDate) = DATE(t.trans_date)" +
            "            AND fl2.transactionType = CASE WHEN t.trans_type='Payment' THEN 'CR' ELSE 'DR' END" +
            "            AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '')" +
            "          )" +
            "        )" +
            "    )" +
            ") AS combined";

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 30;
            cmd.Parameters.AddWithValue("@reg", regno);
            cmd.Parameters.AddWithValue("@reg2", regno);
            object val = cmd.ExecuteScalar();
            return (val != null && val != DBNull.Value) ? Convert.ToDecimal(val) : 0m;
        }
    }

    private string FormatBalanceForUi(decimal balance)
    {
        if (balance > 0) return "UGX " + balance.ToString("N0");
        if (balance < 0) return "UGX -" + Math.Abs(balance).ToString("N0");
        return "UGX 0";
    }

    private string FormatBalanceSignedForFix(decimal balance)
    {
        if (balance > 0) return "UGX " + balance.ToString("N0", CultureInfo.InvariantCulture);
        if (balance < 0) return "UGX -" + Math.Abs(balance).ToString("N0", CultureInfo.InvariantCulture);
        return "UGX 0";
    }

    private bool TryParseNonNegativeIntegerMagnitude(object rawValue, out long magnitude, out string error)
    {
        magnitude = 0;
        error = "";

        string raw = rawValue == null ? "" : Convert.ToString(rawValue, CultureInfo.InvariantCulture);
        if (string.IsNullOrWhiteSpace(raw))
        {
            error = "Target balance amount is required.";
            return false;
        }

        raw = raw.Trim().Replace(",", "");
        if (raw.StartsWith("+") || raw.StartsWith("-")) raw = raw.Substring(1);

        int dotIdx = raw.IndexOf('.');
        if (dotIdx >= 0)
        {
            string fractional = raw.Substring(dotIdx + 1).TrimEnd('0');
            if (fractional.Length > 0)
            {
                error = "Target balance must be a whole number (integer).";
                return false;
            }
            raw = raw.Substring(0, dotIdx);
        }

        if (string.IsNullOrWhiteSpace(raw))
        {
            error = "Target balance amount is required.";
            return false;
        }

        for (int i = 0; i < raw.Length; i++)
        {
            if (!char.IsDigit(raw[i]))
            {
                error = "Target balance must be a whole number (integer).";
                return false;
            }
        }

        long parsed;
        if (!long.TryParse(raw, out parsed))
        {
            error = "Target balance value is too large.";
            return false;
        }

        magnitude = Math.Abs(parsed);
        return true;
    }

    private string BuildStats(int total, int active, int reversed, double totalVal)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<div class='bw-stat bw-stat--total'><div class='bw-stat__icon'>");
        sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/></svg>");
        sb.Append("</div><div><div class='bw-stat__val'>" + total + "</div><div class='bw-stat__label'>Total Waivers</div></div></div>");

        sb.Append("<div class='bw-stat bw-stat--active'><div class='bw-stat__icon'>");
        sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='20 6 9 17 4 12'/></svg>");
        sb.Append("</div><div><div class='bw-stat__val'>" + active + "</div><div class='bw-stat__label'>Active</div></div></div>");

        sb.Append("<div class='bw-stat bw-stat--reversed'><div class='bw-stat__icon'>");
        sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><line x1='18' y1='6' x2='6' y2='18'/><line x1='6' y1='6' x2='18' y2='18'/></svg>");
        sb.Append("</div><div><div class='bw-stat__val'>" + reversed + "</div><div class='bw-stat__label'>Reversed</div></div></div>");

        sb.Append("<div class='bw-stat bw-stat--amount'><div class='bw-stat__icon'>");
        sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><line x1='12' y1='1' x2='12' y2='23'/><path d='M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6'/></svg>");
        sb.Append("</div><div><div class='bw-stat__val'>UGX " + totalVal.ToString("N0") + "</div><div class='bw-stat__label'>Total Waived</div></div></div>");

        return sb.ToString();
    }

    private string GetCategoryBadge(string cat)
    {
        string cssClass = "fs-badge--blue";
        if (cat == "Double Billing") cssClass = "fs-badge--amber";
        else if (cat == "Wrong Billing") cssClass = "fs-badge--red";
        else if (cat == "Bursary Waiver") cssClass = "fs-badge--green";
        else if (cat == "Balance Fix") cssClass = "fs-badge--blue";
        else if (cat == "Reversal") cssClass = "fs-badge--red";
        return "<span class='" + cssClass + "'>" + HttpUtility.HtmlEncode(cat) + "</span>";
    }

    /// <summary>Simple DTO for waiver item parsing.</summary>
    private class WaiverItem
    {
        public int    TID        { get; set; }
        public double Amount     { get; set; } // waived amount (may be capped to bill amount)
        public double BillAmount { get; set; } // original bill amount, captured before deletion
        public string OrigDetail { get; set; } // original bill detail, captured before deletion
    }
}
