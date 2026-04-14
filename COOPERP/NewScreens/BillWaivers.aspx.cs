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
        if (ajax == "apply")
        {
            HandleApplyWaiver();
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
                      WHERE w.regno = @r AND w.status = 'Active' AND w.waiver_category != 'Reversal'", conn))
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

                // Load all Posted Bill entries for the student
                string sql = @"SELECT t.TID, t.amount, t.item_code, t.detail, t.trans_date,
                                      t.acadyear, t.semester,
                                      COALESCE(b.ItemName, 'Unknown') AS item_name
                               FROM fin_studentfeestracking t
                               LEFT JOIN academicbillingitems b ON b.ItemCode = t.item_code
                               WHERE t.regno = @r 
                                 AND t.trans_type = 'Bill'
                                 AND t.post_status = 'Posted'
                                 AND t.amount > 0
                               ORDER BY t.trans_date DESC, t.TID DESC";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    StringBuilder json = new StringBuilder("{\"bills\":[");
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            int tid = Convert.ToInt32(rdr["TID"]);
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat(
                                "{{\"tid\":{0},\"amount\":{1},\"item_code\":{2},\"item_name\":\"{3}\",\"detail\":\"{4}\",\"date\":\"{5}\",\"acadyear\":\"{6}\",\"semester\":{7},\"already_waived\":{8}}}",
                                tid,
                                Convert.ToDouble(rdr["amount"]).ToString("F0"),
                                (rdr["item_code"] != DBNull.Value ? Convert.ToInt32(rdr["item_code"]) : 0),
                                JsEsc(rdr["item_name"].ToString()),
                                JsEsc(rdr["detail"].ToString()),
                                Convert.ToDateTime(rdr["trans_date"]).ToString("dd/MM/yyyy"),
                                JsEsc(rdr["acadyear"].ToString()),
                                (rdr["semester"] != DBNull.Value ? Convert.ToInt32(rdr["semester"]) : 0),
                                waivedTIDs.Contains(tid) ? "true" : "false");
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
    // AJAX: Apply Waiver (?ajax=apply, POST)
    // Expects JSON body: { regno, category, reason, acadyear, semester, items: [{tid, amount},...] }
    //
    // TRANSACTION:
    //   1. INSERT credit into fin_studentfeestracking (trans_type='Payment', detail='Bill Waiver: ...')
    //   2. INSERT GL credit into fin_ledger (transactionType='CR')
    //   3. INSERT fin_bill_waivers header
    //   4. INSERT fin_bill_waiver_items for each waived bill
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
            if (string.IsNullOrEmpty(regno))   throw new Exception("Student registration number is required.");
            if (string.IsNullOrEmpty(category)) throw new Exception("Waiver category is required.");
            if (string.IsNullOrEmpty(reason))  throw new Exception("Waiver reason is required.");
            if (string.IsNullOrEmpty(acadyear)) throw new Exception("Academic year is required.");
            if (semester <= 0)                 throw new Exception("Semester is required.");

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
                            if (tid > 0 && amt > 0)
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

            // Build the credit detail string
            string creditDetail = String.Format("Bill Waiver ({0}): {1}", category, reason);
            if (creditDetail.Length > 250) creditDetail = creditDetail.Substring(0, 247) + "...";

            long newCreditTID = 0;
            long newGLTID = 0;
            long newWaiverID = 0;

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                MySqlTransaction tx = conn.BeginTransaction();
                try
                {
                    // ── Step 1: Validate all TIDs exist, belong to student, and amounts are valid ──
                    foreach (WaiverItem wi in items)
                    {
                        // FOR UPDATE locks the bill row to prevent concurrent waiver of the same bill
                        double actualBillAmt = 0;
                        using (MySqlCommand chk = new MySqlCommand(
                            @"SELECT TID, amount FROM fin_studentfeestracking 
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
                            }
                        }

                        // Validate waive amount: must be > 0 and <= bill amount
                        if (wi.Amount <= 0)
                            throw new Exception(String.Format("Waive amount for TID {0} must be greater than zero.", wi.TID));
                        if (wi.Amount > actualBillAmt + 0.01) // small tolerance for floating point
                            throw new Exception(String.Format("Waive amount ({0:N0}) for TID {1} exceeds the bill amount ({2:N0}).", wi.Amount, wi.TID, actualBillAmt));
                        // Cap at exact bill amount to prevent tiny floating-point overages
                        if (wi.Amount > actualBillAmt)
                            wi.Amount = actualBillAmt;

                        // Check not already waived
                        using (MySqlCommand chk2 = new MySqlCommand(
                            @"SELECT COUNT(*) FROM fin_bill_waiver_items wi
                              INNER JOIN fin_bill_waivers w ON w.waiver_id = wi.waiver_id
                              WHERE wi.original_tid = @tid AND w.status = 'Active' AND w.waiver_category != 'Reversal'",
                            conn, tx))
                        {
                            chk2.Parameters.AddWithValue("@tid", wi.TID);
                            long cnt2 = Convert.ToInt64(chk2.ExecuteScalar());
                            if (cnt2 > 0)
                                throw new Exception(String.Format("Bill TID {0} has already been waived.", wi.TID));
                        }
                    }

                    // ── Step 2: Create credit entry in fin_studentfeestracking ──
                    // This is a Payment/Credit entry that reduces the student's balance
                    using (MySqlCommand ins = new MySqlCommand(
                        @"INSERT INTO fin_studentfeestracking 
                            (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
                          VALUES (@r, @s, @y, @a, 0, 'Payment', @d, @dt, 'Posted')",
                        conn, tx))
                    {
                        ins.Parameters.AddWithValue("@r", regno);
                        ins.Parameters.AddWithValue("@s", semester);
                        ins.Parameters.AddWithValue("@y", acadyear);
                        ins.Parameters.AddWithValue("@a", totalAmount);
                        ins.Parameters.AddWithValue("@d", creditDetail);
                        ins.Parameters.AddWithValue("@dt", now.ToString("yyyy-MM-dd"));
                        ins.ExecuteNonQuery();
                        newCreditTID = ins.LastInsertedId;
                    }

                    // ── Step 3: Mirror to fin_ledger (GL) — CR entry ──
                    using (MySqlCommand gl = new MySqlCommand(
                        @"INSERT INTO fin_ledger
                            (accountcode, account_type, transactionType, transaction_amount, particulars,
                             voucherNo, transactionDate, teller, timeLog, folio,
                             journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
                          VALUES (@ac, 'Student', 'CR', @amt, @part, @vno, @td, @user, @tl, @fo, '-', 'UGX', @amt, 0, 1, @amt)",
                        conn, tx))
                    {
                        gl.Parameters.AddWithValue("@ac", regno);
                        gl.Parameters.AddWithValue("@amt", totalAmount);
                        gl.Parameters.AddWithValue("@part", creditDetail);
                        gl.Parameters.AddWithValue("@vno", newCreditTID);
                        gl.Parameters.AddWithValue("@td", now.ToString("yyyy-MM-dd"));
                        gl.Parameters.AddWithValue("@user", user);
                        gl.Parameters.AddWithValue("@tl", now);
                        gl.Parameters.AddWithValue("@fo", regno);
                        gl.ExecuteNonQuery();
                        newGLTID = gl.LastInsertedId;
                    }

                    // ── Step 4: Create fin_bill_waivers header ──
                    using (MySqlCommand wh = new MySqlCommand(
                        @"INSERT INTO fin_bill_waivers
                            (regno, waiver_category, waiver_reason, total_amount, credit_tid, credit_gl_tid,
                             acadyear, semester, status, created_by, created_at)
                          VALUES (@r, @cat, @rsn, @amt, @ctid, @gltid, @y, @s, 'Active', @user, @now)",
                        conn, tx))
                    {
                        wh.Parameters.AddWithValue("@r", regno);
                        wh.Parameters.AddWithValue("@cat", category);
                        wh.Parameters.AddWithValue("@rsn", reason);
                        wh.Parameters.AddWithValue("@amt", totalAmount);
                        wh.Parameters.AddWithValue("@ctid", newCreditTID);
                        wh.Parameters.AddWithValue("@gltid", newGLTID);
                        wh.Parameters.AddWithValue("@y", acadyear);
                        wh.Parameters.AddWithValue("@s", semester);
                        wh.Parameters.AddWithValue("@user", user);
                        wh.Parameters.AddWithValue("@now", now);
                        wh.ExecuteNonQuery();
                        newWaiverID = wh.LastInsertedId;
                    }

                    // ── Step 5: Insert waiver line items ──
                    foreach (WaiverItem wi in items)
                    {
                        // Get original bill detail
                        string origDetail = "";
                        double origAmount = 0;
                        using (MySqlCommand rd = new MySqlCommand(
                            "SELECT amount, detail FROM fin_studentfeestracking WHERE TID = @tid", conn, tx))
                        {
                            rd.Parameters.AddWithValue("@tid", wi.TID);
                            using (MySqlDataReader rdr = rd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    origAmount = Convert.ToDouble(rdr["amount"]);
                                    origDetail = rdr["detail"] != DBNull.Value ? rdr["detail"].ToString() : "";
                                }
                            }
                        }

                        using (MySqlCommand li = new MySqlCommand(
                            @"INSERT INTO fin_bill_waiver_items
                                (waiver_id, original_tid, bill_amount, waived_amount, bill_detail)
                              VALUES (@wid, @tid, @bamt, @wamt, @det)",
                            conn, tx))
                        {
                            li.Parameters.AddWithValue("@wid", newWaiverID);
                            li.Parameters.AddWithValue("@tid", wi.TID);
                            li.Parameters.AddWithValue("@bamt", origAmount);
                            li.Parameters.AddWithValue("@wamt", wi.Amount);
                            li.Parameters.AddWithValue("@det", origDetail);
                            li.ExecuteNonQuery();
                        }
                    }

                    tx.Commit();

                    // Success response
                    Response.Write(String.Format(
                        "{{\"ok\":true,\"waiver_id\":{0},\"credit_tid\":{1},\"gl_tid\":{2},\"total\":{3},\"message\":\"Waiver #{0} applied successfully. Credit of UGX {4} posted to {5}.\"}}",
                        newWaiverID, newCreditTID, newGLTID, totalAmount.ToString("F0"),
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
                             DATE_FORMAT(w.created_at, '%d/%m/%Y %H:%i') AS created_fmt,
                             COALESCE(w.reversed_by, '') AS reversed_by,
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
                        json.AppendFormat("\"reversed_by\":\"{0}\",", JsEsc(rdr["reversed_by"].ToString()));
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

                    // ── Step 1: Create DR (Bill) entry to reverse the credit ──
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
                        "UPDATE fin_bill_waivers SET status = 'Reversed', reversed_by = @user, reversed_at = @now WHERE waiver_id = @id",
                        conn, tx))
                    {
                        upd.Parameters.AddWithValue("@user", user);
                        upd.Parameters.AddWithValue("@now", now);
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
                        "{{\"ok\":true,\"new_waiver_id\":{0},\"debit_tid\":{1},\"gl_tid\":{2},\"total\":{3},\"message\":\"Waiver #{4} reversed successfully. Debit of UGX {5} posted to {6}. Reversal waiver #{0} created.\"}}",
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
            string sql = @"SELECT w.waiver_id, w.regno, w.waiver_category, w.waiver_reason,
                                  w.total_amount, w.credit_tid, w.acadyear, w.semester,
                                  w.status, w.created_by,
                                  DATE_FORMAT(w.created_at, '%d/%m/%Y %H:%i') AS created_fmt,
                                  TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                                  (SELECT COUNT(*) FROM fin_bill_waiver_items wi WHERE wi.waiver_id = w.waiver_id) AS item_count
                           FROM fin_bill_waivers w
                           LEFT JOIN campus_dynamics.acad_student s ON s.regno = w.regno
                           ORDER BY w.created_at DESC
                           LIMIT 200";

            DataTable dt = new DataTable();
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlDataAdapter da = new MySqlDataAdapter(sql, conn))
                {
                    da.Fill(dt);
                }
            }

            if (dt.Rows.Count == 0)
            {
                litHistory.Text = "<div style='padding:24px;text-align:center;color:#888;font-size:12px;'>No waivers have been created yet. Use the <strong>New Waiver</strong> button above to get started.</div>";
                litStats.Text = BuildStats(0, 0, 0, 0);
                return;
            }

            // Compute stats
            int total = dt.Rows.Count;
            int active = 0;
            int reversed = 0;
            double totalVal = 0;
            foreach (DataRow r in dt.Rows)
            {
                string st = r["status"] != DBNull.Value ? r["status"].ToString() : "";
                double amt = r["total_amount"] != DBNull.Value ? Convert.ToDouble(r["total_amount"]) : 0;
                if (st == "Active") { active++; totalVal += amt; }
                else if (st == "Reversed") reversed++;
            }
            litStats.Text = BuildStats(total, active, reversed, totalVal);

            // Build table
            StringBuilder html = new StringBuilder();
            html.Append("<table class='bw-table'><thead><tr>");
            html.Append("<th>#</th><th>Date</th><th>Student</th><th>RegNo</th><th>Category</th><th>Bills</th><th class='bw-table--right'>Amount</th><th>Credit TID</th><th>Status</th><th>By</th><th style='text-align:center;'>Actions</th>");
            html.Append("</tr></thead><tbody>");

            int row = 0;
            foreach (DataRow r in dt.Rows)
            {
                row++;
                string wid = r["waiver_id"].ToString();
                string date = r["created_fmt"] != DBNull.Value ? r["created_fmt"].ToString() : "";
                string name = r["student_name"] != DBNull.Value ? r["student_name"].ToString() : "";
                string reg = r["regno"] != DBNull.Value ? r["regno"].ToString() : "";
                string cat = r["waiver_category"] != DBNull.Value ? r["waiver_category"].ToString() : "";
                double amt = r["total_amount"] != DBNull.Value ? Convert.ToDouble(r["total_amount"]) : 0;
                string ctid = r["credit_tid"] != DBNull.Value ? r["credit_tid"].ToString() : "-";
                string status = r["status"] != DBNull.Value ? r["status"].ToString() : "";
                string by = r["created_by"] != DBNull.Value ? r["created_by"].ToString() : "";
                int items = r["item_count"] != DBNull.Value ? Convert.ToInt32(r["item_count"]) : 0;

                string statusBadge = status == "Active"
                    ? "<span class='fs-badge--green'>" + HttpUtility.HtmlEncode(status) + "</span>"
                    : "<span class='fs-badge--red'>" + HttpUtility.HtmlEncode(status) + "</span>";

                string catBadge = GetCategoryBadge(cat);

                string oddClass = (row % 2 == 0) ? " class='bw-row--alt'" : "";
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
                html.Append("<button type='button' class='bw-btn-action bw-btn-action--view' onclick='viewWaiver(" + wid + ")' title='View Details'><svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z'/><circle cx='12' cy='12' r='3'/></svg></button>");
                if (status == "Active")
                {
                    html.Append(" <button type='button' class='bw-btn-action bw-btn-action--reverse' onclick='openReverse(" + wid + ")' title='Reverse Waiver'><svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='1 4 1 10 7 10'/><path d='M3.51 15a9 9 0 1 0 2.13-9.36L1 10'/></svg></button>");
                }
                html.Append("</td>");
                html.Append("</tr>");
            }

            html.Append("</tbody></table>");
            litHistory.Text = html.ToString();
        }
        catch (Exception ex)
        {
            litHistory.Text = "<div class='fs-toast fs-toast--error'>Error loading waiver history: " + HttpUtility.HtmlEncode(ex.Message) + "</div>";
            litStats.Text = BuildStats(0, 0, 0, 0);
        }
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
            }
        }
        catch
        {
            // Silently ignore — tables likely already exist
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
        else if (cat == "Reversal") cssClass = "fs-badge--red";
        return "<span class='" + cssClass + "'>" + HttpUtility.HtmlEncode(cat) + "</span>";
    }

    /// <summary>Simple DTO for waiver item parsing.</summary>
    private class WaiverItem
    {
        public int TID { get; set; }
        public double Amount { get; set; }
    }
}
