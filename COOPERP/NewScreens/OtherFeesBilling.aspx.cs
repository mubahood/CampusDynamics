using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_OtherFeesBilling : System.Web.UI.Page
{
    private string AcctConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }
    private string MainConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static bool _tablesChecked;

    protected void Page_Load(object sender, EventArgs e)
    {
        // AJAX routing — return JSON and skip page rendering
        string ajax = Request.QueryString["ajax"];
        if (ajax == "search")       { HandleSearchStudents(); return; }
        if (ajax == "loadstudents") { HandleLoadStudents(); return; }
        if (ajax == "submit")       { HandleSubmitBatch(); return; }
        if (ajax == "jobs")         { HandleGetJobs(); return; }
        if (ajax == "jobdetail")    { HandleGetJobDetail(); return; }

        EnsureBatchBillingTables();
        LoadLookups();
    }

    // ====================================================================
    // Auto-migration — create batch billing tables if they don't exist
    // ====================================================================
    private void EnsureBatchBillingTables()
    {
        if (_tablesChecked) return;
        _tablesChecked = true;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"CREATE TABLE IF NOT EXISTS fin_batch_billing_jobs (
                        job_id          INT AUTO_INCREMENT PRIMARY KEY,
                        job_ref         VARCHAR(20)  NOT NULL DEFAULT '',
                        item_code       INT          NOT NULL,
                        item_name       VARCHAR(100) NOT NULL DEFAULT '',
                        amount          DOUBLE       NOT NULL DEFAULT 0,
                        acad_year       VARCHAR(25)  NOT NULL DEFAULT '',
                        semester        INT          NOT NULL DEFAULT 0,
                        detail          VARCHAR(250) NOT NULL DEFAULT '',
                        selection_mode  VARCHAR(25)  NOT NULL DEFAULT '',
                        selection_criteria TEXT,
                        total_students  INT          NOT NULL DEFAULT 0,
                        total_amount    DOUBLE       NOT NULL DEFAULT 0,
                        success_count   INT          NOT NULL DEFAULT 0,
                        fail_count      INT          NOT NULL DEFAULT 0,
                        skip_count      INT          NOT NULL DEFAULT 0,
                        status          VARCHAR(20)  NOT NULL DEFAULT 'PROCESSING',
                        created_by      VARCHAR(50)  NOT NULL DEFAULT '',
                        created_at      DATETIME     NOT NULL
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8", conn))
                { cmd.ExecuteNonQuery(); }

                using (MySqlCommand cmd = new MySqlCommand(
                    @"CREATE TABLE IF NOT EXISTS fin_batch_billing_items (
                        id              INT AUTO_INCREMENT PRIMARY KEY,
                        job_id          INT          NOT NULL,
                        regno           VARCHAR(25)  NOT NULL,
                        student_name    VARCHAR(100) NOT NULL DEFAULT '',
                        tid             INT UNSIGNED DEFAULT NULL,
                        amount          DOUBLE       NOT NULL DEFAULT 0,
                        status          VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
                        error_msg       VARCHAR(250) NOT NULL DEFAULT '',
                        INDEX idx_job   (job_id),
                        INDEX idx_reg   (regno)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8", conn))
                { cmd.ExecuteNonQuery(); }
            }
        }
        catch { /* non-critical migration */ }
    }

    // ====================================================================
    // AJAX — Student autocomplete search
    // ====================================================================
    private void HandleSearchStudents()
    {
        Response.ContentType = "application/json";
        string q = (Request.QueryString["q"] ?? "").Trim();
        if (q.Length < 2) { Response.Write("[]"); Response.End(); return; }

        try
        {
            StringBuilder sb = new StringBuilder("[");
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                string sql = @"SELECT s.regno, CONCAT(s.firstname,' ',s.othername) AS student_name,
                                      IFNULL(p.progname,'') AS programme, IFNULL(s.progid,'') AS progcode
                               FROM acad_student s
                               LEFT JOIN acad_programme p ON s.progid = p.progcode
                               WHERE s.regno LIKE @q OR CONCAT(s.firstname,' ',s.othername) LIKE @q
                               LIMIT 15";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@q", "%" + q + "%");
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        bool first = true;
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.AppendFormat(
                                "{{\"regno\":\"{0}\",\"name\":\"{1}\",\"programme\":\"{2}\",\"progcode\":\"{3}\"}}",
                                JsEsc(rdr["regno"].ToString()),
                                JsEsc(rdr["student_name"].ToString()),
                                JsEsc(rdr["programme"].ToString()),
                                JsEsc(rdr["progcode"].ToString()));
                        }
                    }
                }
            }
            sb.Append("]");
            Response.Write(sb.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // Shared regstatus filter — includes defensive hyphenated variant
    private const string REG_STATUS_FILTER =
        "r.regstatus IN ('REGISTERED','LATE REGISTERED','LATE-REGISTERED','CLEARED')";

    // ====================================================================
    // AJAX — Load students by criteria (programme/year/conditions)
    // Returns: {"students":[...],"total_reg":N,"params":{...}}
    // ====================================================================
    private void HandleLoadStudents()
    {
        Response.ContentType = "application/json";
        string mode = (Request.QueryString["mode"] ?? "").Trim().ToLower();
        string acadYear = (Request.QueryString["year"] ?? "").Trim();
        int semester = 0;
        int.TryParse(Request.QueryString["sem"] ?? "0", out semester);

        StringBuilder studentsSb = new StringBuilder("[");
        bool first = true;
        int totalReg = -1; // will be set if no results found

        try
        {
            if (mode == "programme")
            {
                string prog = (Request.QueryString["prog"] ?? "").Trim();
                int studyYear = 0;
                int.TryParse(Request.QueryString["yr"] ?? "0", out studyYear);
                string session = (Request.QueryString["sess"] ?? "").Trim();

                using (MySqlConnection conn = new MySqlConnection(MainConnStr))
                {
                    conn.Open();
                    string sql = String.Format(@"SELECT s.regno,
                                          CONCAT(s.firstname,' ',s.othername) AS student_name,
                                          IFNULL(s.progid,'') AS progcode,
                                          r.studyyear,
                                          IFNULL(s.studsesion,'') AS session
                                   FROM acad_registration r
                                   INNER JOIN acad_student s ON s.regno = r.regno
                                   WHERE r.acad_year = @year AND r.semester = @sem
                                     AND {0}
                                     AND (@prog = '' OR s.progid = @prog)
                                     AND (@yr = 0 OR r.studyyear = @yr)
                                     AND (@sess = '' OR s.studsesion = @sess)
                                   ORDER BY s.progid, s.regno
                                   LIMIT 500", REG_STATUS_FILTER);
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@year", acadYear);
                        cmd.Parameters.AddWithValue("@sem", semester);
                        cmd.Parameters.AddWithValue("@prog", prog);
                        cmd.Parameters.AddWithValue("@yr", studyYear);
                        cmd.Parameters.AddWithValue("@sess", session);
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                if (!first) studentsSb.Append(",");
                                first = false;
                                studentsSb.AppendFormat(
                                    "{{\"regno\":\"{0}\",\"name\":\"{1}\",\"progcode\":\"{2}\",\"year\":{3},\"session\":\"{4}\"}}",
                                    JsEsc(rdr["regno"].ToString()),
                                    JsEsc(rdr["student_name"].ToString()),
                                    JsEsc(rdr["progcode"].ToString()),
                                    rdr["studyyear"],
                                    JsEsc(rdr["session"].ToString()));
                            }
                        }
                    }

                    // If no students found, run diagnostic count
                    if (first)
                    {
                        totalReg = RunDiagCount(conn, "acad_registration", "acad_year", acadYear, semester);
                    }
                }
            }
            else if (mode == "balance")
            {
                double threshold = 0;
                double.TryParse(Request.QueryString["threshold"] ?? "0", out threshold);

                using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
                {
                    conn.Open();
                    // Canonical balance: read the materialised dual-source cache so the picker's
                    // "balance" matches StudentLedgers / the portal exactly (all-time owing =
                    // billed - paid). Previously this summed fin_studentfeestracking for @year only,
                    // which contradicted the canonical figure shown elsewhere.
                    string sql = String.Format(@"SELECT DISTINCT s.regno,
                                          CONCAT(s.firstname,' ',s.othername) AS student_name,
                                          IFNULL(s.progid,'') AS progcode,
                                          (IFNULL(c.total_billed,0) - IFNULL(c.total_paid,0)) AS balance
                                   FROM campus_dynamics.acad_registration r
                                   INNER JOIN campus_dynamics.acad_student s ON s.regno = r.regno
                                   LEFT JOIN fin_student_balance_cache c ON c.regno = r.regno
                                   WHERE r.acad_year = @year AND r.semester = @sem
                                     AND {0}
                                     AND (IFNULL(c.total_billed,0) - IFNULL(c.total_paid,0)) > @th
                                   ORDER BY balance DESC
                                   LIMIT 500", REG_STATUS_FILTER);
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@year", acadYear);
                        cmd.Parameters.AddWithValue("@sem", semester);
                        cmd.Parameters.AddWithValue("@th", threshold);
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                if (!first) studentsSb.Append(",");
                                first = false;
                                studentsSb.AppendFormat(
                                    "{{\"regno\":\"{0}\",\"name\":\"{1}\",\"progcode\":\"{2}\",\"balance\":{3}}}",
                                    JsEsc(rdr["regno"].ToString()),
                                    JsEsc(rdr["student_name"].ToString()),
                                    JsEsc(rdr["progcode"].ToString()),
                                    Convert.ToDouble(rdr["balance"]).ToString("F0"));
                            }
                        }
                    }

                    if (first)
                    {
                        totalReg = RunDiagCount(conn, "campus_dynamics.acad_registration", "acad_year", acadYear, semester);
                    }
                }
            }
            else if (mode == "nopayment")
            {
                string dateFrom = (Request.QueryString["from"] ?? "").Trim();
                string dateTo = (Request.QueryString["to"] ?? "").Trim();

                using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
                {
                    conn.Open();
                    string sql = String.Format(@"SELECT s.regno,
                                          CONCAT(s.firstname,' ',s.othername) AS student_name,
                                          IFNULL(s.progid,'') AS progcode
                                   FROM campus_dynamics.acad_registration r
                                   INNER JOIN campus_dynamics.acad_student s ON s.regno = r.regno
                                   WHERE r.acad_year = @year AND r.semester = @sem
                                     AND {0}
                                     AND r.regno NOT IN (
                                         SELECT DISTINCT ft.regno
                                         FROM fin_studentfeestracking ft
                                         WHERE ft.trans_type = 'Payment'
                                           AND ft.trans_date BETWEEN @from AND @to
                                     )
                                   ORDER BY s.progid, s.regno
                                   LIMIT 500", REG_STATUS_FILTER);
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@year", acadYear);
                        cmd.Parameters.AddWithValue("@sem", semester);
                        cmd.Parameters.AddWithValue("@from", dateFrom);
                        cmd.Parameters.AddWithValue("@to", dateTo);
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                if (!first) studentsSb.Append(",");
                                first = false;
                                studentsSb.AppendFormat(
                                    "{{\"regno\":\"{0}\",\"name\":\"{1}\",\"progcode\":\"{2}\"}}",
                                    JsEsc(rdr["regno"].ToString()),
                                    JsEsc(rdr["student_name"].ToString()),
                                    JsEsc(rdr["progcode"].ToString()));
                            }
                        }
                    }

                    if (first)
                    {
                        totalReg = RunDiagCount(conn, "campus_dynamics.acad_registration", "acad_year", acadYear, semester);
                    }
                }
            }
            else if (mode == "retakes")
            {
                string resYear = (Request.QueryString["res_year"] ?? "").Trim();
                int resSem = 0;
                int.TryParse(Request.QueryString["res_sem"] ?? "0", out resSem);

                using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
                {
                    conn.Open();
                    string sql = String.Format(@"SELECT DISTINCT s.regno,
                                          CONCAT(s.firstname,' ',s.othername) AS student_name,
                                          IFNULL(s.progid,'') AS progcode
                                   FROM campus_dynamics_portal.acad_results ar
                                   INNER JOIN campus_dynamics.acad_student s ON s.regno = ar.regno
                                   INNER JOIN campus_dynamics.acad_registration r
                                        ON r.regno = s.regno AND r.acad_year = @curr_year AND r.semester = @curr_sem
                                   WHERE ar.grade = 'F'
                                     AND ar.acad_year = @res_year
                                     AND ar.semester = @res_sem
                                     AND {0}
                                   ORDER BY s.progid, s.regno
                                   LIMIT 500", REG_STATUS_FILTER);
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@curr_year", acadYear);
                        cmd.Parameters.AddWithValue("@curr_sem", semester);
                        cmd.Parameters.AddWithValue("@res_year", resYear);
                        cmd.Parameters.AddWithValue("@res_sem", resSem);
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                if (!first) studentsSb.Append(",");
                                first = false;
                                studentsSb.AppendFormat(
                                    "{{\"regno\":\"{0}\",\"name\":\"{1}\",\"progcode\":\"{2}\"}}",
                                    JsEsc(rdr["regno"].ToString()),
                                    JsEsc(rdr["student_name"].ToString()),
                                    JsEsc(rdr["progcode"].ToString()));
                            }
                        }
                    }

                    if (first)
                    {
                        totalReg = RunDiagCount(conn, "campus_dynamics.acad_registration", "acad_year", acadYear, semester);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
            Response.End();
            return;
        }

        studentsSb.Append("]");

        // Build JSON response: {"students":[...], "total_reg":N, "params":{...}}
        StringBuilder resp = new StringBuilder("{\"students\":");
        resp.Append(studentsSb);
        if (totalReg >= 0)
        {
            resp.AppendFormat(",\"total_reg\":{0}", totalReg);
        }
        resp.AppendFormat(",\"params\":{{\"year\":\"{0}\",\"sem\":{1},\"mode\":\"{2}\"}}",
            JsEsc(acadYear), semester, JsEsc(mode));
        resp.Append("}");

        Response.Write(resp.ToString());
        Response.End();
    }

    /// <summary>Quick diagnostic: count active registrations for the given year/semester.</summary>
    private int RunDiagCount(MySqlConnection conn, string regTable, string yearCol, string acadYear, int semester)
    {
        try
        {
            string sql = String.Format(
                @"SELECT COUNT(DISTINCT r.regno) FROM {0} r
                  WHERE r.{1} = @year AND r.semester = @sem
                    AND r.regstatus IN ('REGISTERED','LATE REGISTERED','LATE-REGISTERED','CLEARED')",
                regTable, yearCol);
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@year", acadYear);
                cmd.Parameters.AddWithValue("@sem", semester);
                object val = cmd.ExecuteScalar();
                return val != null ? Convert.ToInt32(val) : 0;
            }
        }
        catch { return -1; }
    }

    // ====================================================================
    // AJAX POST — Submit batch billing job
    // ====================================================================
    private void HandleSubmitBatch()
    {
        Response.ContentType = "application/json";
        if (Request.HttpMethod != "POST")
        {
            Response.Write("{\"error\":\"POST required\"}");
            Response.End();
            return;
        }

        try
        {
            int itemCode = int.Parse(Request.Form["item_code"] ?? "0");
            double amount = double.Parse(Request.Form["amount"] ?? "0");
            string acadYear = (Request.Form["acad_year"] ?? "").Trim();
            int semester = int.Parse(Request.Form["semester"] ?? "0");
            string detail = (Request.Form["detail"] ?? "").Trim();
            string mode = (Request.Form["mode"] ?? "INDIVIDUAL").Trim();
            string criteria = (Request.Form["criteria"] ?? "").Trim();
            string[] regnos = (Request.Form["students"] ?? "").Split(
                new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            if (regnos.Length == 0)
            {
                Response.Write("{\"error\":\"No students selected\"}");
                Response.End();
                return;
            }

            // Resolve billing item name + GL account code
            string itemName = "";
            string acctCode = "";
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT ItemName, IFNULL(AccountCode,'') AS AccountCode FROM academicbillingitems WHERE ItemCode=@ic", conn))
                {
                    cmd.Parameters.AddWithValue("@ic", itemCode);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            itemName = rdr["ItemName"].ToString();
                            acctCode = rdr["AccountCode"].ToString();
                        }
                    }
                }
            }

            if (string.IsNullOrEmpty(itemName))
            {
                Response.Write("{\"error\":\"Invalid billing item\"}");
                Response.End();
                return;
            }

            string billDetail = string.IsNullOrEmpty(detail) ? itemName : detail;
            string billDate = DateTime.Now.ToString("yyyy-MM-dd");

            // Get current user
            string currentUser = "system";
            if (HttpContext.Current.User != null && HttpContext.Current.User.Identity != null
                && !string.IsNullOrEmpty(HttpContext.Current.User.Identity.Name))
            {
                currentUser = HttpContext.Current.User.Identity.Name;
            }

            // Pre-fetch student names from the academic DB
            Dictionary<string, string> nameMap = new Dictionary<string, string>();
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                // Build safe IN clause
                StringBuilder inSb = new StringBuilder();
                MySqlCommand nameCmd = new MySqlCommand("", conn);
                for (int i = 0; i < regnos.Length; i++)
                {
                    if (i > 0) inSb.Append(",");
                    string pname = "@p" + i;
                    inSb.Append(pname);
                    nameCmd.Parameters.AddWithValue(pname, regnos[i].Trim());
                }
                nameCmd.CommandText = "SELECT s.regno, CONCAT(s.firstname,' ',s.othername) AS name FROM acad_student s WHERE s.regno IN (" + inSb.ToString() + ")";
                using (MySqlDataReader rdr = nameCmd.ExecuteReader())
                {
                    while (rdr.Read())
                        nameMap[rdr["regno"].ToString()] = rdr["name"].ToString();
                }
                nameCmd.Dispose();
            }

            // Create the job record and process in a single connection
            long jobId;
            string jobRef = "";
            int successCount = 0, failCount = 0, skipCount = 0;
            double totalAmount = 0;

            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Create job record
                using (MySqlCommand cmd = new MySqlCommand(
                    @"INSERT INTO fin_batch_billing_jobs
                        (job_ref, item_code, item_name, amount, acad_year, semester, detail,
                         selection_mode, selection_criteria, total_students, status, created_by, created_at)
                      VALUES ('', @ic, @in, @amt, @yr, @sem, @det, @mode, @crit, @cnt, 'PROCESSING', @user, NOW())", conn))
                {
                    cmd.Parameters.AddWithValue("@ic", itemCode);
                    cmd.Parameters.AddWithValue("@in", itemName);
                    cmd.Parameters.AddWithValue("@amt", amount);
                    cmd.Parameters.AddWithValue("@yr", acadYear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    cmd.Parameters.AddWithValue("@det", billDetail);
                    cmd.Parameters.AddWithValue("@mode", mode);
                    cmd.Parameters.AddWithValue("@crit", criteria);
                    cmd.Parameters.AddWithValue("@cnt", regnos.Length);
                    cmd.Parameters.AddWithValue("@user", currentUser);
                    cmd.ExecuteNonQuery();
                    jobId = cmd.LastInsertedId;
                }

                jobRef = "BTH" + jobId.ToString("D6");
                using (MySqlCommand cmd = new MySqlCommand(
                    "UPDATE fin_batch_billing_jobs SET job_ref=@ref WHERE job_id=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@ref", jobRef);
                    cmd.Parameters.AddWithValue("@id", jobId);
                    cmd.ExecuteNonQuery();
                }

                // Process each student
                foreach (string rawReg in regnos)
                {
                    string reg = rawReg.Trim();
                    if (string.IsNullOrEmpty(reg)) continue;

                    string studName = "";
                    if (nameMap.ContainsKey(reg)) studName = nameMap[reg];

                    MySqlTransaction tx = null;
                    try
                    {
                        tx = conn.BeginTransaction();

                        // Duplicate check: same student + year + semester + item + Bill
                        bool exists = false;
                        using (MySqlCommand cmd = new MySqlCommand(
                            @"SELECT TID FROM fin_studentfeestracking
                              WHERE regno=@r AND acadyear=@y AND semester=@s
                                AND item_code=@ic AND trans_type='Bill' LIMIT 1", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@r", reg);
                            cmd.Parameters.AddWithValue("@y", acadYear);
                            cmd.Parameters.AddWithValue("@s", semester);
                            cmd.Parameters.AddWithValue("@ic", itemCode);
                            exists = (cmd.ExecuteScalar() != null);
                        }

                        if (exists)
                        {
                            tx.Rollback();
                            RecordBatchItem(conn, jobId, reg, studName, null, amount, "SKIPPED", "Already billed for this item");
                            skipCount++;
                            continue;
                        }

                        // 1. Insert fee tracking record (Bill)
                        long tid;
                        using (MySqlCommand cmd = new MySqlCommand(
                            @"INSERT INTO fin_studentfeestracking
                                (regno, semester, acadyear, amount, item_code, trans_type, detail, trans_date, post_status)
                              VALUES (@r, @s, @y, @amt, @ic, 'Bill', @d, @dt, 'Posted')", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@r", reg);
                            cmd.Parameters.AddWithValue("@s", semester);
                            cmd.Parameters.AddWithValue("@y", acadYear);
                            cmd.Parameters.AddWithValue("@amt", amount);
                            cmd.Parameters.AddWithValue("@ic", itemCode);
                            cmd.Parameters.AddWithValue("@d", billDetail);
                            cmd.Parameters.AddWithValue("@dt", billDate);
                            cmd.ExecuteNonQuery();
                            tid = cmd.LastInsertedId;
                        }

                        // 2. GL double-entry: DR student (balance increases), CR revenue
                        string folio = "BillNo:" + tid;
                        string now = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

                        // DR — student owes more
                        using (MySqlCommand cmd = new MySqlCommand(
                            @"INSERT INTO fin_ledger
                                (accountcode, account_type, transactionType, transaction_amount, particulars,
                                 voucherNo, transactionDate, teller, timeLog, folio,
                                 journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
                              VALUES (@ac, 'Student', 'DR', @amt, @part, @vno, @td, @user, @tl, @fo,
                                      '-', 'UGX', @amt, 0, 1, @amt)", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@ac", reg);
                            cmd.Parameters.AddWithValue("@amt", amount);
                            cmd.Parameters.AddWithValue("@part", billDetail);
                            cmd.Parameters.AddWithValue("@vno", tid);
                            cmd.Parameters.AddWithValue("@td", billDate);
                            cmd.Parameters.AddWithValue("@user", currentUser);
                            cmd.Parameters.AddWithValue("@tl", now);
                            cmd.Parameters.AddWithValue("@fo", folio);
                            cmd.ExecuteNonQuery();
                        }

                        // CR — revenue account
                        if (!string.IsNullOrEmpty(acctCode))
                        {
                            using (MySqlCommand cmd = new MySqlCommand(
                                @"INSERT INTO fin_ledger
                                    (accountcode, account_type, transactionType, transaction_amount, particulars,
                                     voucherNo, transactionDate, teller, timeLog, folio,
                                     journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
                                  VALUES (@ac, 'Chart Account', 'CR', @amt, @part, @vno, @td, @user, @tl, @fo,
                                          '-', 'UGX', @amt, 0, 1, @amt)", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@ac", acctCode);
                                cmd.Parameters.AddWithValue("@amt", amount);
                                cmd.Parameters.AddWithValue("@part", billDetail + " (" + reg + ")");
                                cmd.Parameters.AddWithValue("@vno", tid);
                                cmd.Parameters.AddWithValue("@td", billDate);
                                cmd.Parameters.AddWithValue("@user", currentUser);
                                cmd.Parameters.AddWithValue("@tl", now);
                                cmd.Parameters.AddWithValue("@fo", folio);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tx.Commit();
                        RecordBatchItem(conn, jobId, reg, studName, tid, amount, "SUCCESS", "");
                        successCount++;
                        totalAmount += amount;
                    }
                    catch (Exception ex)
                    {
                        if (tx != null) try { tx.Rollback(); } catch { }
                        string errMsg = ex.Message;
                        if (errMsg.Length > 250) errMsg = errMsg.Substring(0, 250);
                        RecordBatchItem(conn, jobId, reg, studName, null, amount, "FAILED", errMsg);
                        failCount++;
                    }
                }

                // Update job totals
                string status = failCount == 0 && skipCount == 0 ? "COMPLETED"
                              : successCount == 0 ? "FAILED"
                              : "PARTIAL";
                using (MySqlCommand cmd = new MySqlCommand(
                    @"UPDATE fin_batch_billing_jobs
                      SET total_students=@cnt, total_amount=@total,
                          success_count=@s, fail_count=@f, skip_count=@sk, status=@st
                      WHERE job_id=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@cnt", regnos.Length);
                    cmd.Parameters.AddWithValue("@total", totalAmount);
                    cmd.Parameters.AddWithValue("@s", successCount);
                    cmd.Parameters.AddWithValue("@f", failCount);
                    cmd.Parameters.AddWithValue("@sk", skipCount);
                    cmd.Parameters.AddWithValue("@st", status);
                    cmd.Parameters.AddWithValue("@id", jobId);
                    cmd.ExecuteNonQuery();
                }
            }

            Response.Write(string.Format(
                "{{\"success\":true,\"job_id\":{0},\"job_ref\":\"{1}\",\"total\":{2},\"billed\":{3},\"skipped\":{4},\"failed\":{5},\"total_amount\":{6}}}",
                jobId, JsEsc(jobRef), regnos.Length, successCount, skipCount, failCount, totalAmount));
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    /// <summary>Records a per-student result in the batch items table (outside any transaction).</summary>
    private static void RecordBatchItem(MySqlConnection conn, long jobId, string regno,
        string name, long? tid, double amount, string status, string errorMsg)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            @"INSERT INTO fin_batch_billing_items (job_id, regno, student_name, tid, amount, status, error_msg)
              VALUES (@jid, @r, @n, @tid, @amt, @st, @err)", conn))
        {
            cmd.Parameters.AddWithValue("@jid", jobId);
            cmd.Parameters.AddWithValue("@r", regno);
            cmd.Parameters.AddWithValue("@n", name ?? "");
            cmd.Parameters.AddWithValue("@tid", tid.HasValue ? (object)tid.Value : DBNull.Value);
            cmd.Parameters.AddWithValue("@amt", amount);
            cmd.Parameters.AddWithValue("@st", status);
            cmd.Parameters.AddWithValue("@err", errorMsg ?? "");
            cmd.ExecuteNonQuery();
        }
    }

    // ====================================================================
    // AJAX — Recent batch billing jobs (for page-load history grid)
    // ====================================================================
    private void HandleGetJobs()
    {
        Response.ContentType = "application/json";
        try
        {
            StringBuilder sb = new StringBuilder("[");
            bool first = true;
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT job_id, job_ref, item_name, amount, acad_year, semester,
                             total_students, success_count, fail_count, skip_count,
                             total_amount, status, created_by, created_at
                      FROM fin_batch_billing_jobs
                      ORDER BY created_at DESC
                      LIMIT 50", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        if (!first) sb.Append(",");
                        first = false;
                        sb.AppendFormat(
                            "{{\"id\":{0},\"ref\":\"{1}\",\"item\":\"{2}\",\"amount\":{3},"
                          + "\"year\":\"{4}\",\"sem\":{5},\"total\":{6},\"success\":{7},"
                          + "\"fail\":{8},\"skip\":{9},\"total_amt\":{10},"
                          + "\"status\":\"{11}\",\"user\":\"{12}\",\"date\":\"{13}\"}}",
                            rdr["job_id"],
                            JsEsc(rdr["job_ref"].ToString()),
                            JsEsc(rdr["item_name"].ToString()),
                            Convert.ToDouble(rdr["amount"]).ToString("F0"),
                            JsEsc(rdr["acad_year"].ToString()),
                            rdr["semester"],
                            rdr["total_students"],
                            rdr["success_count"],
                            rdr["fail_count"],
                            rdr["skip_count"],
                            Convert.ToDouble(rdr["total_amount"]).ToString("F0"),
                            JsEsc(rdr["status"].ToString()),
                            JsEsc(rdr["created_by"].ToString()),
                            Convert.ToDateTime(rdr["created_at"]).ToString("dd MMM yyyy HH:mm"));
                    }
                }
            }
            sb.Append("]");
            Response.Write(sb.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ====================================================================
    // AJAX — Job detail (per-student results)
    // ====================================================================
    private void HandleGetJobDetail()
    {
        Response.ContentType = "application/json";
        int jobId = 0;
        int.TryParse(Request.QueryString["id"] ?? "0", out jobId);
        if (jobId == 0) { Response.Write("{\"error\":\"Missing job ID\"}"); Response.End(); return; }

        try
        {
            StringBuilder sb = new StringBuilder("{\"items\":[");
            bool first = true;
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT i.regno, i.student_name, i.tid, i.amount, i.status, i.error_msg
                      FROM fin_batch_billing_items i
                      WHERE i.job_id=@id
                      ORDER BY i.status DESC, i.regno", conn))
                {
                    cmd.Parameters.AddWithValue("@id", jobId);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            string tidStr = rdr["tid"] != DBNull.Value ? rdr["tid"].ToString() : "null";
                            sb.AppendFormat(
                                "{{\"regno\":\"{0}\",\"name\":\"{1}\",\"tid\":{2},\"amount\":{3},\"status\":\"{4}\",\"error\":\"{5}\"}}",
                                JsEsc(rdr["regno"].ToString()),
                                JsEsc(rdr["student_name"].ToString()),
                                tidStr,
                                Convert.ToDouble(rdr["amount"]).ToString("F0"),
                                JsEsc(rdr["status"].ToString()),
                                JsEsc(rdr["error_msg"].ToString()));
                        }
                    }
                }
            }
            sb.Append("]}");
            Response.Write(sb.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ====================================================================
    // Lookups — populate server-side dropdowns
    // ====================================================================
    private void LoadLookups()
    {
        // Billing items
        ddlBillItem.Items.Clear();
        ddlBillItem.Items.Add(new ListItem("-- Select Billing Item --", ""));
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT ItemCode, ItemName, IFNULL(AccountCode,'') AS AccountCode FROM academicbillingitems ORDER BY ItemName", conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                StringBuilder itemJson = new StringBuilder("[");
                bool first = true;
                while (rdr.Read())
                {
                    ddlBillItem.Items.Add(new ListItem(
                        rdr["ItemName"].ToString(),
                        rdr["ItemCode"].ToString()));
                    if (!first) itemJson.Append(",");
                    first = false;
                    itemJson.AppendFormat(
                        "{{\"code\":{0},\"name\":\"{1}\",\"acct\":\"{2}\"}}",
                        rdr["ItemCode"],
                        JsEsc(rdr["ItemName"].ToString()),
                        JsEsc(rdr["AccountCode"].ToString()));
                }
                itemJson.Append("]");
                ScriptManager.RegisterStartupScript(this, GetType(), "billItems",
                    "var _billItems = " + itemJson.ToString() + ";", true);
            }

            // Academic years from fee tracking
            DataTable dtYears = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT DISTINCT acadyear FROM fin_studentfeestracking WHERE acadyear<>''
                  UNION
                  SELECT DISTINCT acad_year FROM campus_dynamics.acad_registration WHERE acad_year<>''
                  ORDER BY 1 DESC", conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dtYears); }

            ddlBillAcadYear.Items.Clear();
            ddlBillAcadYear.Items.Add(new ListItem("-- Select Year --", ""));
            foreach (DataRow r in dtYears.Rows)
            {
                string yr = r[0].ToString();
                ddlBillAcadYear.Items.Add(new ListItem(yr, yr));
            }

            // Programmes
            DataTable dtProgs = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT progcode, progname FROM campus_dynamics.acad_programme ORDER BY progname", conn))
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dtProgs); }

            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("All Programmes", ""));
            foreach (DataRow r in dtProgs.Rows)
                ddlProgramme.Items.Add(new ListItem(r["progname"].ToString(), r["progcode"].ToString()));
        }
    }

    // ====================================================================
    // Helpers
    // ====================================================================
    private static string JsEsc(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        return val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }
}
