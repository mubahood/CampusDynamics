using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Skipped-Billing Reconciliation Wizard.
/// Finds students who have a semester registration but were never billed
/// (the gap between admin enrolment, which creates UNREGISTERED stubs with no bill,
/// and portal self-registration, which sets REGISTERED + bills), then lets an admin
/// preview and bill them in controlled, idempotent batches.
///
/// Scopes (alumni / staff / discontinued are ALWAYS excluded):
///   safe : only students already REGISTERED/LATE/CLEARED but unbilled (bill only).
///   paid : safe + UNREGISTERED students who have already paid money (register + bill).
///   all  : safe + every UNREGISTERED ACTIVE/ADMITTED student (register + bill).
/// </summary>
public partial class COOPERP_NewScreens_BillingReconciliation : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    private const string ACCT_DB = "campus_dynamics_accounts";

    // ── Fixer floor — the reconciliation/backfill must NEVER work backwards. ────────────────────
    // Older academic years and pre-2026 entrants are where fee structures changed over time, so
    // re-billing them produced DUPLICATE bills: the fixer saw the old (different-amount) bill, judged
    // the student "unbilled", and raised a second bill without removing the first. To stop that for
    // good, fixers operate only on 2026/2027 onward AND only for students who entered in 2026+.
    // (acad_year is 'YYYY/YYYY' so an ordinal string compare orders correctly.)
    private const string MIN_FIX_ACADYEAR  = "2026/2027";
    private const int    MIN_FIX_ENTRYYEAR = 2026;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (HandleAjaxRequest()) return;

        if (!IsPostBack)
        {
            LoadAcademicYears();
            int curSem = AcademicYearHelper.GetCurrentSemester();
            if (curSem >= 1 && curSem <= 3)
                ddlSemester.SelectedValue = curSem.ToString();
        }
    }

    private void LoadAcademicYears()
    {
        // Default to the current academic year (this is a one-period reconciliation tool).
        AcademicYearHelper.PopulateDropDown(ddlAcadYear, false, true);
    }

    private string GetCurrentUser()
    {
        if (Session["username"] != null && Session["username"].ToString().Trim() != "")
            return Session["username"].ToString().Trim();
        if (HttpContext.Current.User.Identity.IsAuthenticated)
            return HttpContext.Current.User.Identity.Name;
        return "system";
    }

    // ===================================================================
    // AJAX DISPATCH
    // ===================================================================

    private bool HandleAjaxRequest()
    {
        string action = Request.QueryString["action"];
        if (string.IsNullOrEmpty(action)) return false;

        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        try
        {
            switch (action)
            {
                case "preview":       HandlePreview();      break;
                case "process_batch": HandleProcessBatch(); break;
                default: Response.Write("{\"error\":\"Unknown action\"}"); break;
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEncode(ex.Message) + "\"}");
        }
        try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
        return true;
    }

    // ===================================================================
    // CANDIDATE QUERY
    // ===================================================================

    /// <summary>
    /// Builds the FROM/WHERE that selects skipped-billing candidates for a period.
    /// Common guards: not alumni, not staff, not discontinued/halted/dead, and NO existing
    /// Bill row for that exact (regno, acad_year, semester).
    /// </summary>
    private string BuildCandidateFromWhere(string scope)
    {
        var sb = new StringBuilder(@"
            FROM acad_registration r
            JOIN acad_student s ON s.regno = r.regno
            LEFT JOIN acad_programme p ON p.progcode = s.progid
            LEFT JOIN (
                SELECT regno, SUM(amount) total, COUNT(*) c
                FROM " + ACCT_DB + @".fin_studentfeestracking
                WHERE trans_type = 'Payment'
                GROUP BY regno
            ) pay ON pay.regno = COALESCE(NULLIF(TRIM(s.regno), ''), TRIM(r.regno))
            WHERE r.acad_year = @ay AND r.semester = @sem
              -- Fixer floor: never touch pre-2026/2027 years or pre-2026 entrants (avoids duplicate bills).
              AND r.acad_year >= '" + MIN_FIX_ACADYEAR + @"'
              AND CAST(NULLIF(TRIM(s.entryyear), '') AS UNSIGNED) >= " + MIN_FIX_ENTRYYEAR + @"
              AND UPPER(TRIM(IFNULL(s.new_status, ''))) <> 'ALUMNI'
              AND UPPER(TRIM(IFNULL(r.regstatus, ''))) NOT IN ('DISCONTINUED','HALTED','DEAD YEAR')
              AND NOT EXISTS (
                    SELECT 1 FROM " + ACCT_DB + @".fin_studentfeestracking b
                    WHERE b.regno = COALESCE(NULLIF(TRIM(s.regno), ''), TRIM(r.regno))
                      AND b.acadyear = r.acad_year AND b.semester = r.semester
                      AND b.trans_type = 'Bill'
                  )
              AND NOT EXISTS (
                    SELECT 1 FROM hrm_employee e
                    WHERE LOWER(TRIM(e.EMP_CODE))  = LOWER(TRIM(r.regno))
                       OR LOWER(TRIM(e.usernames)) = LOWER(TRIM(r.regno))
                  )
              AND (
                    UPPER(TRIM(IFNULL(r.regstatus, ''))) IN ('REGISTERED','LATE REGISTERED','CLEARED')");

        if (scope == "paid")
            sb.Append(@"
                    OR (UPPER(TRIM(IFNULL(r.regstatus, ''))) = 'UNREGISTERED' AND COALESCE(pay.c, 0) > 0)");
        else if (scope == "all")
            sb.Append(@"
                    OR (UPPER(TRIM(IFNULL(r.regstatus, ''))) = 'UNREGISTERED'
                        AND UPPER(TRIM(IFNULL(s.new_status, ''))) IN ('ACTIVE','ADMITTED'))");
        // scope == "safe": registered-only, no extra branch.

        sb.Append(")");
        return sb.ToString();
    }

    private static string NormScope(string s)
    {
        s = (s ?? "").Trim().ToLowerInvariant();
        return (s == "safe" || s == "all") ? s : "paid";
    }

    private void HandlePreview()
    {
        string ay  = (Request.QueryString["ay"] ?? "").Trim();
        int sem    = SafeInt(Request.QueryString["sem"], 0);
        string scope = NormScope(Request.QueryString["scope"]);

        if (string.IsNullOrEmpty(ay) || sem < 1 || sem > 3)
        {
            Response.Write("{\"error\":\"Please choose an academic year and semester.\"}");
            return;
        }
        if (string.Compare(ay, MIN_FIX_ACADYEAR, StringComparison.Ordinal) < 0)
        {
            Response.Write("{\"error\":\"Billing reconciliation only runs for " + MIN_FIX_ACADYEAR + " onward. Earlier years are no longer auto-billed here (it caused duplicate bills when fee structures changed).\"}");
            return;
        }

        string fromWhere = BuildCandidateFromWhere(scope);
        var sb = new StringBuilder();
        sb.Append("{");
        sb.AppendFormat("\"acadYear\":\"{0}\",\"semester\":{1},\"scope\":\"{2}\",", JsEncode(ay), sem, scope);

        int total = 0, willRegister = 0, billOnly = 0, alreadyPaidCount = 0;
        decimal totalPaid = 0m;
        var rows = new List<string>();

        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = @"
                SELECT r.ID,
                    COALESCE(NULLIF(TRIM(s.regno), ''), TRIM(r.regno)) AS regno,
                    NULLIF(TRIM(CONCAT_WS(' ', NULLIF(s.firstname,''), NULLIF(s.othername,''))), '') AS name,
                    COALESCE(NULLIF(s.progid,''), '') AS prog,
                    COALESCE(NULLIF(p.progname,''), '') AS progname,
                    COALESCE(s.entryyear, '') AS entryyear,
                    COALESCE(s.new_status, '') AS sstatus,
                    COALESCE(r.regstatus, '') AS regstatus,
                    COALESCE(r.studyyear, 0) AS studyyear,
                    COALESCE(pay.total, 0) AS paid
                " + fromWhere + @"
                ORDER BY (UPPER(TRIM(IFNULL(r.regstatus,''))) = 'UNREGISTERED'),
                         s.firstname, s.othername";
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@ay", ay);
                cmd.Parameters.AddWithValue("@sem", sem);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        total++;
                        string regstatus = rdr["regstatus"].ToString().Trim().ToUpperInvariant();
                        bool isRegistered = regstatus == "REGISTERED" || regstatus == "LATE REGISTERED" || regstatus == "CLEARED";
                        string act = isRegistered ? "bill" : "register_bill";
                        if (isRegistered) billOnly++; else willRegister++;

                        decimal paid = 0m;
                        decimal.TryParse(rdr["paid"].ToString(), out paid);
                        totalPaid += paid;
                        if (paid > 0) alreadyPaidCount++;

                        if (rows.Count < 3000)
                        {
                            rows.Add(string.Format(
                                "{{\"id\":{0},\"regno\":\"{1}\",\"name\":\"{2}\",\"prog\":\"{3}\",\"entry\":\"{4}\",\"sstatus\":\"{5}\",\"regstatus\":\"{6}\",\"paid\":{7},\"act\":\"{8}\"}}",
                                Convert.ToInt32(rdr["ID"]),
                                JsEncode(rdr["regno"]),
                                JsEncode((rdr["name"] == DBNull.Value ? "" : rdr["name"].ToString())),
                                JsEncode(rdr["prog"]),
                                JsEncode(rdr["entryyear"]),
                                JsEncode(rdr["sstatus"]),
                                JsEncode(rdr["regstatus"]),
                                paid.ToString("0"),
                                act));
                        }
                    }
                }
            }
        }

        sb.AppendFormat("\"total\":{0},\"willRegister\":{1},\"billOnly\":{2},\"alreadyPaid\":{3},\"totalPaid\":{4},",
            total, willRegister, billOnly, alreadyPaidCount, totalPaid.ToString("0"));
        sb.Append("\"rows\":[");
        sb.Append(string.Join(",", rows.ToArray()));
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    // ===================================================================
    // BATCH PROCESSING
    // ===================================================================

    private void HandleProcessBatch()
    {
        string body;
        using (var reader = new StreamReader(Request.InputStream)) body = reader.ReadToEnd();

        int start = body.IndexOf('[');
        int end = body.IndexOf(']');
        if (start < 0 || end < 0 || end <= start)
        {
            Response.Write("{\"error\":\"Invalid request body\"}");
            return;
        }
        var ids = new List<int>();
        foreach (string s in body.Substring(start + 1, end - start - 1).Split(','))
        {
            int id;
            if (int.TryParse(s.Trim(), out id) && id > 0) ids.Add(id);
        }
        if (ids.Count == 0) { Response.Write("{\"registered\":0,\"billed\":0,\"skipped\":0,\"errors\":0,\"results\":[]}"); return; }

        string user = GetCurrentUser();
        int registered = 0, billed = 0, skipped = 0, errors = 0;
        var results = new List<string>();

        foreach (int id in ids)
        {
            try
            {
                var outcome = ProcessOne(id, user);
                switch (outcome.Status)
                {
                    case "registered_billed": registered++; billed++; break;
                    case "billed":            billed++;            break;
                    case "skip":              skipped++;           break;
                    default:                  errors++;            break;
                }
                results.Add(string.Format("{{\"id\":{0},\"s\":\"{1}\",\"m\":\"{2}\"}}",
                    id, outcome.Status, JsEncode(outcome.Message)));
            }
            catch (Exception ex)
            {
                errors++;
                results.Add(string.Format("{{\"id\":{0},\"s\":\"error\",\"m\":\"{1}\"}}", id, JsEncode(ex.Message)));
            }
        }

        Response.Write(string.Format(
            "{{\"registered\":{0},\"billed\":{1},\"skipped\":{2},\"errors\":{3},\"results\":[{4}]}}",
            registered, billed, skipped, errors, string.Join(",", results.ToArray())));
    }

    private sealed class Outcome
    {
        public string Status;   // registered_billed | billed | skip | error
        public string Message;
        public Outcome(string s, string m) { Status = s; Message = m; }
    }

    /// <summary>
    /// Processes one acad_registration row: validates eligibility, optionally promotes
    /// UNREGISTERED -> REGISTERED, then bills and verifies a Bill row exists.
    /// Idempotent (skips anyone already billed). Rolls back the status promotion if
    /// billing cannot be confirmed, so it never leaves a registered-but-unbilled student.
    /// </summary>
    private Outcome ProcessOne(int id, string user)
    {
        string regno = "", acadYear = "", regstatus = "", newStatus = "", residence = "", entryYear = "";
        int semester = 0;

        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"
                SELECT r.regno, r.acad_year, r.semester,
                       COALESCE(r.regstatus,'') AS regstatus,
                       COALESCE(r.residence_status,'') AS residence,
                       COALESCE(s.new_status,'') AS new_status,
                       COALESCE(s.entryyear,'') AS entryyear
                FROM acad_registration r
                LEFT JOIN acad_student s ON s.regno = r.regno
                WHERE r.ID = @id LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (!rdr.Read()) return new Outcome("error", "Registration record not found.");
                    regno     = rdr["regno"].ToString().Trim();
                    acadYear  = rdr["acad_year"].ToString().Trim();
                    semester  = Convert.ToInt32(rdr["semester"]);
                    regstatus = rdr["regstatus"].ToString().Trim().ToUpperInvariant();
                    residence = rdr["residence"].ToString().Trim();
                    newStatus = rdr["new_status"].ToString().Trim().ToUpperInvariant();
                    entryYear = rdr["entryyear"].ToString().Trim();
                }
            }

            if (string.IsNullOrEmpty(regno)) return new Outcome("error", "Missing registration number.");

            // Fixer floor (defence in depth — never bill backwards, avoids the duplicate-bill trap).
            if (string.Compare(acadYear, MIN_FIX_ACADYEAR, StringComparison.Ordinal) < 0)
                return new Outcome("skip", "Excluded: before " + MIN_FIX_ACADYEAR + ".");
            int ey; if (!int.TryParse(entryYear, out ey) || ey < MIN_FIX_ENTRYYEAR)
                return new Outcome("skip", "Excluded: entry year before " + MIN_FIX_ENTRYYEAR + ".");

            // Re-validate guards (defence in depth against stale client lists)
            if (newStatus == "ALUMNI") return new Outcome("skip", "Excluded: alumni.");
            if (regstatus == "DISCONTINUED" || regstatus == "HALTED" || regstatus == "DEAD YEAR")
                return new Outcome("skip", "Excluded: " + regstatus + ".");
            if (IsStaffRegno(conn, regno)) return new Outcome("skip", "Excluded: staff account.");

            // Idempotency — already billed for this period?
            if (HasBill(regno, acadYear, semester)) return new Outcome("skip", "Already billed.");

            bool needRegister = !(regstatus == "REGISTERED" || regstatus == "LATE REGISTERED" || regstatus == "CLEARED");
            bool didRegister = false;

            if (needRegister)
            {
                using (var up = new MySqlCommand(@"
                    UPDATE acad_registration
                    SET regstatus = 'REGISTERED',
                        conducted_new_registration = 'Yes',
                        examClearance = CASE WHEN IFNULL(TRIM(examClearance),'') = '' THEN 'UNCLEARED' ELSE examClearance END,
                        registeredBy  = CASE WHEN IFNULL(TRIM(registeredBy),'')  = '' THEN @user ELSE registeredBy END
                    WHERE ID = @id
                      AND UPPER(TRIM(IFNULL(regstatus,''))) NOT IN ('REGISTERED','LATE REGISTERED','CLEARED')", conn))
                {
                    up.Parameters.AddWithValue("@user", user);
                    up.Parameters.AddWithValue("@id", id);
                    didRegister = up.ExecuteNonQuery() > 0;
                }
            }

            // Bill (+ verify). Rollback registration if billing cannot be confirmed.
            bool billedOk = BillAndVerify(regno, acadYear, semester, residence, user);
            if (!billedOk)
            {
                if (didRegister)
                {
                    using (var rb = new MySqlCommand(
                        "UPDATE acad_registration SET regstatus='UNREGISTERED', conducted_new_registration='No' WHERE ID=@id", conn))
                    {
                        rb.Parameters.AddWithValue("@id", id);
                        rb.ExecuteNonQuery();
                    }
                }
                LogActivity(conn, user, regno, acadYear, semester, "FAILED", "Billing could not be confirmed");
                return new Outcome("error", "Billing could not be confirmed (rolled back).");
            }

            LogActivity(conn, user, regno, acadYear, semester,
                didRegister ? "REGISTERED+BILLED" : "BILLED", "Skipped-billing reconciliation");
            return didRegister
                ? new Outcome("registered_billed", "Registered and billed.")
                : new Outcome("billed", "Billed.");
        }
    }

    // ===================================================================
    // BILLING (primary SP + fallback, with verification)
    // ===================================================================

    private bool BillAndVerify(string regno, string acadYear, int semester, string residence, string user)
    {
        // Primary: fin_AutoBillOnRegistration (idempotent — skips already-billed items).
        try { RunAutoBillOnRegistration(regno, acadYear, semester, user); } catch { }
        if (HasBill(regno, acadYear, semester)) return true;

        // Fallback: fin_Autobilling REG (+ ACCOMO for residents).
        try { RunFallbackBilling(regno, acadYear, semester, residence, user); } catch { }
        return HasBill(regno, acadYear, semester);
    }

    private void RunAutoBillOnRegistration(string regno, string acadYear, int semester, string user)
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("fin_AutoBillOnRegistration", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@p_regno", regno);
                cmd.Parameters.AddWithValue("@p_acadyear", acadYear);
                cmd.Parameters.AddWithValue("@p_semester", semester);
                cmd.Parameters.AddWithValue("@p_user", user);
                using (var rdr = cmd.ExecuteReader()) { while (rdr.NextResult()) { } }
            }
        }
    }

    private void RunFallbackBilling(string regno, string acadYear, int semester, string residence, string user)
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("CALL fin_Autobilling(@reg,@acad,@sem,@typ,@usr,@src)", conn))
            {
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@reg", regno);
                cmd.Parameters.AddWithValue("@acad", acadYear);
                cmd.Parameters.AddWithValue("@sem", semester);
                cmd.Parameters.AddWithValue("@typ", "REG");
                cmd.Parameters.AddWithValue("@usr", user);
                cmd.Parameters.AddWithValue("@src", "AUTO");
                using (var rdr = cmd.ExecuteReader()) { while (rdr.NextResult()) { } }
            }

            if (string.Equals(residence, "RESIDENT", StringComparison.OrdinalIgnoreCase))
            {
                using (var cmd = new MySqlCommand("CALL fin_Autobilling(@reg,@acad,@sem,@typ,@usr,@src)", conn))
                {
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.AddWithValue("@reg", regno);
                    cmd.Parameters.AddWithValue("@acad", acadYear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    cmd.Parameters.AddWithValue("@typ", "ACCOMO");
                    cmd.Parameters.AddWithValue("@usr", user);
                    cmd.Parameters.AddWithValue("@src", "AUTO");
                    using (var rdr = cmd.ExecuteReader()) { while (rdr.NextResult()) { } }
                }
            }
        }
    }

    private bool HasBill(string regno, string acadYear, int semester)
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"
                SELECT COUNT(*) FROM fin_studentfeestracking
                WHERE TRIM(regno) = TRIM(@r) AND acadyear = @a AND semester = @s
                  AND UPPER(TRIM(trans_type)) = 'BILL'", conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                cmd.Parameters.AddWithValue("@a", acadYear);
                cmd.Parameters.AddWithValue("@s", semester);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
    }

    private bool IsStaffRegno(MySqlConnection conn, string regno)
    {
        try
        {
            using (var cmd = new MySqlCommand(@"
                SELECT COUNT(*) FROM hrm_employee
                WHERE LOWER(TRIM(EMP_CODE))  = LOWER(TRIM(@r))
                   OR LOWER(TRIM(usernames)) = LOWER(TRIM(@r))", conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch { return false; }
    }

    private void LogActivity(MySqlConnection conn, string user, string regno, string acadYear, int semester, string result, string comment)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date) VALUES (@u, 'Billing Reconciliation', @par, @c, NOW())", conn))
            {
                cmd.Parameters.AddWithValue("@u", user);
                cmd.Parameters.AddWithValue("@par", string.Format("{0} | {1} Sem {2} | {3}", regno, acadYear, semester, result));
                cmd.Parameters.AddWithValue("@c", comment);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    // ===================================================================
    // UTILITIES
    // ===================================================================

    private int SafeInt(string val, int def)
    {
        int r; return int.TryParse(val, out r) ? r : def;
    }

    protected string JsEncode(object val)
    {
        string s = (val == null || val == DBNull.Value) ? "" : val.ToString();
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "");
    }
}
