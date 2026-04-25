using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class API_v2_finance : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "ledger":
                    HandleLedger();
                    break;
                case "balance":
                    HandleBalance();
                    break;
                case "fees_structure":
                    HandleFeesStructure();
                    break;
                case "payment_history":
                    HandlePaymentHistory();
                    break;
                case "billing_summary":
                    HandleBillingSummary();
                    break;
                case "fee_status":
                    HandleFeeStatus();
                    break;
                case "bulk_fee_check":
                    HandleBulkFeeCheck();
                    break;
                case "access_status":
                    HandleAccessStatus();
                    break;
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: ledger, balance, fees_structure, payment_history, billing_summary, fee_status, bulk_fee_check, access_status", "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private string GetStudentRegNo(out TokenInfo auth)
    {
        auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return null;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", "")
            : auth.UserId;

        if (auth.UserType == "student")
            regno = auth.UserId;

        if (string.IsNullOrEmpty(regno))
        {
            ApiHelper.Error(Response, "Student registration number required. Pass ?regno= parameter.", "MISSING_PARAM");
            return null;
        }

        return regno;
    }

    private void HandleLedger()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter LEDGER = new MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter();
            DataTable dt = LEDGER.GetData(regno);

            var entries = ApiHelper.TableToList(dt);

            // Calculate running balance
            decimal totalDebit = 0, totalCredit = 0;
            foreach (DataRow row in dt.Rows)
            {
                decimal debit = 0, credit = 0;
                if (row.Table.Columns.Contains("debit") && row["debit"] != DBNull.Value)
                    decimal.TryParse(row["debit"].ToString(), out debit);
                if (row.Table.Columns.Contains("credit") && row["credit"] != DBNull.Value)
                    decimal.TryParse(row["credit"].ToString(), out credit);
                totalDebit += debit;
                totalCredit += credit;
            }

            var data = new Dictionary<string, object>
            {
                { "balance", totalDebit - totalCredit },
                { "total_charges", totalDebit },
                { "total_payments", totalCredit },
                { "currency", "UGX" },
                { "entries", entries }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching ledger: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleBalance()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter LEDGER = new MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter();
            DataTable dt = LEDGER.GetData(regno);

            decimal totalDebit = 0, totalCredit = 0;
            foreach (DataRow row in dt.Rows)
            {
                decimal debit = 0, credit = 0;
                if (row.Table.Columns.Contains("debit") && row["debit"] != DBNull.Value)
                    decimal.TryParse(row["debit"].ToString(), out debit);
                if (row.Table.Columns.Contains("credit") && row["credit"] != DBNull.Value)
                    decimal.TryParse(row["credit"].ToString(), out credit);
                totalDebit += debit;
                totalCredit += credit;
            }

            var data = new Dictionary<string, object>
            {
                { "balance", totalDebit - totalCredit },
                { "total_charges", totalDebit },
                { "total_payments", totalCredit },
                { "currency", "UGX" },
                { "last_payment_date", GetLastPaymentDate(dt) }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching balance: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleFeesStructure()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            // Get student's programme to fetch fees structure
            DataTable studentDt = ApiHelper.Query(
                @"SELECT s.progid, 
                        COALESCE((SELECT MAX(r.studyyear) FROM acad_registration r WHERE r.regno = s.regno), 1) AS study_year,
                        s.studsesion, s.studCampus, s.nationality 
                  FROM acad_student s WHERE s.regno = @reg",
                new MySqlParameter("@reg", regno)
            );

            if (studentDt.Rows.Count == 0)
            {
                ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
                return;
            }

            string progcode = studentDt.Rows[0]["progid"].ToString();
            string studyYear = studentDt.Rows[0]["study_year"].ToString();
            string nationality = studentDt.Rows[0]["nationality"] != DBNull.Value ? studentDt.Rows[0]["nationality"].ToString() : "";

            // Determine fee category based on nationality
            string feeCategory = nationality.ToLower().Contains("ugand") ? "Ugandan" : "International";

            DataTable feesDt = ApiHelper.QueryAccounts(
                @"SELECT f.ItemCode, f.amount, f.study_year, f.semester
                  FROM fin_fees_structure f 
                  WHERE f.progid = @prog AND (f.study_year = @yr OR f.study_year = 0)
                  ORDER BY f.ItemCode",
                new MySqlParameter("@prog", progcode),
                new MySqlParameter("@yr", studyYear)
            );

            decimal totalFees = 0;
            var items = new List<Dictionary<string, object>>();
            foreach (DataRow row in feesDt.Rows)
            {
                decimal amount = 0;
                if (row["amount"] != DBNull.Value)
                    decimal.TryParse(row["amount"].ToString(), out amount);
                totalFees += amount;

                items.Add(new Dictionary<string, object>
                {
                    { "item", row["ItemCode"] },
                    { "amount", amount },
                    { "semester", row["semester"] }
                });
            }

            var data = new Dictionary<string, object>
            {
                { "programme_code", progcode },
                { "study_year", studyYear },
                { "fee_category", feeCategory },
                { "currency", "UGX" },
                { "total_fees", totalFees },
                { "items", items }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching fees structure: " + ex.Message, "SERVER_ERROR");
        }
    }

    private string GetLastPaymentDate(DataTable dt)
    {
        string lastDate = "";
        foreach (DataRow row in dt.Rows)
        {
            decimal credit = 0;
            if (row.Table.Columns.Contains("credit") && row["credit"] != DBNull.Value)
                decimal.TryParse(row["credit"].ToString(), out credit);

            if (credit > 0 && row.Table.Columns.Contains("trans_date") && row["trans_date"] != DBNull.Value)
            {
                lastDate = row["trans_date"].ToString();
            }
        }
        return lastDate;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  NEW FINANCE ENDPOINTS
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns only payment (credit) entries from the student's ledger.
    /// Useful for displaying payment receipts or payment history screens.
    /// </summary>
    private void HandlePaymentHistory()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter LEDGER = new MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter();
            DataTable dt = LEDGER.GetData(regno);

            var payments = new List<Dictionary<string, object>>();
            decimal totalPayments = 0;

            foreach (DataRow row in dt.Rows)
            {
                decimal credit = 0;
                if (row.Table.Columns.Contains("credit") && row["credit"] != DBNull.Value)
                    decimal.TryParse(row["credit"].ToString(), out credit);

                if (credit > 0)
                {
                    var payment = new Dictionary<string, object>();
                    foreach (DataColumn col in dt.Columns)
                    {
                        object val = row[col];
                        if (val is DBNull) val = null;
                        payment[col.ColumnName] = val;
                    }
                    payments.Add(payment);
                    totalPayments += credit;
                }
            }

            var data = new Dictionary<string, object>
            {
                { "total_payments", totalPayments },
                { "payment_count", payments.Count },
                { "currency", "UGX" },
                { "payments", payments }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching payment history: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// Returns a billing summary grouped by academic year and semester.
    /// Gives a high-level view of charges vs payments per period.
    /// </summary>
    private void HandleBillingSummary()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter LEDGER = new MobileDataTableAdapters.fin_GetStudentLedgerTableAdapter();
            DataTable dt = LEDGER.GetData(regno);

            // Aggregate by academic year if the column exists
            var periodMap = new Dictionary<string, decimal[]>(); // key -> [charges, payments]
            decimal grandCharges = 0, grandPayments = 0;
            bool hasAcadCol = dt.Columns.Contains("acad_year");
            bool hasSemCol = dt.Columns.Contains("semester");

            foreach (DataRow row in dt.Rows)
            {
                decimal debit = 0, credit = 0;
                if (row.Table.Columns.Contains("debit") && row["debit"] != DBNull.Value)
                    decimal.TryParse(row["debit"].ToString(), out debit);
                if (row.Table.Columns.Contains("credit") && row["credit"] != DBNull.Value)
                    decimal.TryParse(row["credit"].ToString(), out credit);

                grandCharges += debit;
                grandPayments += credit;

                string periodKey = "overall";
                if (hasAcadCol && row["acad_year"] != DBNull.Value)
                {
                    periodKey = row["acad_year"].ToString();
                    if (hasSemCol && row["semester"] != DBNull.Value)
                        periodKey += "_S" + row["semester"].ToString();
                }

                if (!periodMap.ContainsKey(periodKey))
                    periodMap[periodKey] = new decimal[] { 0, 0 };

                periodMap[periodKey][0] += debit;
                periodMap[periodKey][1] += credit;
            }

            var periods = new List<Dictionary<string, object>>();
            foreach (var kv in periodMap)
            {
                periods.Add(new Dictionary<string, object>
                {
                    { "period", kv.Key },
                    { "charges", kv.Value[0] },
                    { "payments", kv.Value[1] },
                    { "balance", kv.Value[0] - kv.Value[1] }
                });
            }

            var data = new Dictionary<string, object>
            {
                { "overall_charges", grandCharges },
                { "overall_payments", grandPayments },
                { "overall_balance", grandCharges - grandPayments },
                { "currency", "UGX" },
                { "periods", periods }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching billing summary: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// ODEL: Get fee clearance status for a student.
    /// Returns cleared/partial/not_cleared status with amounts.
    /// Used by Moodle to gate access to resources based on payment.
    /// </summary>
    private void HandleFeeStatus()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        string semester = ApiHelper.Param(Request, "semester", "");

        try
        {
            // Get total charges and payments from the ledger
            string sql;
            MySqlParameter[] parms;

            if (!string.IsNullOrEmpty(acadYear))
            {
                sql = @"SELECT 
                          COALESCE(SUM(CASE WHEN debit > 0 THEN debit ELSE 0 END), 0) AS total_fees,
                          COALESCE(SUM(CASE WHEN credit > 0 THEN credit ELSE 0 END), 0) AS amount_paid,
                          MAX(CASE WHEN credit > 0 THEN trans_date END) AS last_payment_date
                        FROM fm_student_ledger
                        WHERE regno = @reg AND academic_year = @ay";

                if (!string.IsNullOrEmpty(semester))
                {
                    sql += " AND semester = @sem";
                    parms = new MySqlParameter[] {
                        new MySqlParameter("@reg", regno),
                        new MySqlParameter("@ay", acadYear),
                        new MySqlParameter("@sem", semester)
                    };
                }
                else
                {
                    parms = new MySqlParameter[] {
                        new MySqlParameter("@reg", regno),
                        new MySqlParameter("@ay", acadYear)
                    };
                }
            }
            else
            {
                sql = @"SELECT 
                          COALESCE(SUM(CASE WHEN debit > 0 THEN debit ELSE 0 END), 0) AS total_fees,
                          COALESCE(SUM(CASE WHEN credit > 0 THEN credit ELSE 0 END), 0) AS amount_paid,
                          MAX(CASE WHEN credit > 0 THEN trans_date END) AS last_payment_date
                        FROM fm_student_ledger
                        WHERE regno = @reg";
                parms = new MySqlParameter[] { new MySqlParameter("@reg", regno) };
            }

            DataTable dt = ApiHelper.QueryAccounts(sql, parms);

            decimal totalFees = 0;
            decimal amountPaid = 0;
            string lastPaymentDate = "";

            if (dt.Rows.Count > 0)
            {
                totalFees = Convert.ToDecimal(dt.Rows[0]["total_fees"]);
                amountPaid = Convert.ToDecimal(dt.Rows[0]["amount_paid"]);
                if (dt.Rows[0]["last_payment_date"] != DBNull.Value)
                    lastPaymentDate = Convert.ToDateTime(dt.Rows[0]["last_payment_date"]).ToString("yyyy-MM-dd");
            }

            decimal balance = totalFees - amountPaid;
            string feeStatus;
            if (balance <= 0)
                feeStatus = "cleared";
            else if (amountPaid > 0)
                feeStatus = "partial";
            else
                feeStatus = "not_cleared";

            // Check if student has a financial lock
            bool hasLock = false;
            try
            {
                DataTable dtLock = ApiHelper.Query(
                    "SELECT studLock FROM acad_student WHERE regno = @reg",
                    new MySqlParameter("@reg", regno)
                );
                if (dtLock.Rows.Count > 0)
                {
                    string lockVal = Convert.ToString(dtLock.Rows[0]["studLock"]).ToLower();
                    hasLock = (lockVal == "1" || lockVal == "true" || lockVal == "yes" || lockVal == "locked");
                }
            }
            catch { }

            var data = new Dictionary<string, object>
            {
                { "regno", regno },
                { "fee_status", feeStatus },
                { "total_fees", totalFees },
                { "amount_paid", amountPaid },
                { "balance", balance },
                { "currency", "UGX" },
                { "last_payment_date", lastPaymentDate },
                { "has_financial_lock", hasLock },
                { "academic_year", acadYear },
                { "semester", semester }
            };
            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error checking fee status: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// ODEL: Check fee status for multiple students in one request.
    /// Staff only. POST with JSON body: {"students": ["REG001", "REG002", ...]}
    /// Used by Moodle for bulk enrollment checks.
    /// </summary>
    private void HandleBulkFeeCheck()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "Only staff can perform bulk fee checks.", "ACCESS_DENIED");
            return;
        }

        string acadYear = ApiHelper.Param(Request, "acad_year", "");

        // Read POST body for student list
        string body = "";
        try
        {
            using (var reader = new System.IO.StreamReader(Request.InputStream))
            {
                body = reader.ReadToEnd();
            }
        }
        catch { }

        List<string> studentIds = new List<string>();

        if (!string.IsNullOrEmpty(body))
        {
            try
            {
                JavaScriptSerializer ser = new JavaScriptSerializer();
                var parsed = ser.Deserialize<Dictionary<string, object>>(body);
                if (parsed != null && parsed.ContainsKey("students"))
                {
                    var arr = parsed["students"] as System.Collections.ArrayList;
                    if (arr != null)
                    {
                        foreach (object item in arr)
                            studentIds.Add(Convert.ToString(item));
                    }
                }
            }
            catch { }
        }

        // Also accept comma-separated query param as fallback
        if (studentIds.Count == 0)
        {
            string studentsParam = ApiHelper.Param(Request, "students", "");
            if (!string.IsNullOrEmpty(studentsParam))
            {
                foreach (string s in studentsParam.Split(','))
                {
                    string trimmed = s.Trim();
                    if (!string.IsNullOrEmpty(trimmed))
                        studentIds.Add(trimmed);
                }
            }
        }

        if (studentIds.Count == 0)
        {
            ApiHelper.Error(Response, "No student IDs provided. Send JSON body with 'students' array or comma-separated 'students' parameter.", "MISSING_PARAM");
            return;
        }

        if (studentIds.Count > 200)
        {
            ApiHelper.Error(Response, "Maximum 200 students per request.", "VALIDATION_ERROR");
            return;
        }

        var results = new List<Dictionary<string, object>>();

        foreach (string sid in studentIds)
        {
            try
            {
                string sql;
                MySqlParameter[] parms;

                if (!string.IsNullOrEmpty(acadYear))
                {
                    sql = @"SELECT 
                              COALESCE(SUM(CASE WHEN debit > 0 THEN debit ELSE 0 END), 0) AS total_fees,
                              COALESCE(SUM(CASE WHEN credit > 0 THEN credit ELSE 0 END), 0) AS amount_paid
                            FROM fm_student_ledger
                            WHERE regno = @reg AND academic_year = @ay";
                    parms = new MySqlParameter[] {
                        new MySqlParameter("@reg", sid),
                        new MySqlParameter("@ay", acadYear)
                    };
                }
                else
                {
                    sql = @"SELECT 
                              COALESCE(SUM(CASE WHEN debit > 0 THEN debit ELSE 0 END), 0) AS total_fees,
                              COALESCE(SUM(CASE WHEN credit > 0 THEN credit ELSE 0 END), 0) AS amount_paid
                            FROM fm_student_ledger
                            WHERE regno = @reg";
                    parms = new MySqlParameter[] { new MySqlParameter("@reg", sid) };
                }

                DataTable dt = ApiHelper.QueryAccounts(sql, parms);

                decimal totalFees = 0;
                decimal amountPaid = 0;
                if (dt.Rows.Count > 0)
                {
                    totalFees = Convert.ToDecimal(dt.Rows[0]["total_fees"]);
                    amountPaid = Convert.ToDecimal(dt.Rows[0]["amount_paid"]);
                }

                decimal balance = totalFees - amountPaid;
                string feeStatus;
                if (balance <= 0)
                    feeStatus = "cleared";
                else if (amountPaid > 0)
                    feeStatus = "partial";
                else
                    feeStatus = "not_cleared";

                results.Add(new Dictionary<string, object>
                {
                    { "regno", sid },
                    { "fee_status", feeStatus },
                    { "total_fees", totalFees },
                    { "amount_paid", amountPaid },
                    { "balance", balance }
                });
            }
            catch
            {
                results.Add(new Dictionary<string, object>
                {
                    { "regno", sid },
                    { "fee_status", "error" },
                    { "total_fees", 0 },
                    { "amount_paid", 0 },
                    { "balance", 0 }
                });
            }
        }

        var data = new Dictionary<string, object>
        {
            { "academic_year", acadYear },
            { "total_checked", results.Count },
            { "currency", "UGX" },
            { "results", results }
        };
        ApiHelper.Success(Response, data);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    //  ACCESS STATUS — Evaluates student against the active fee-access policy
    // ═══════════════════════════════════════════════════════════════════════════

    private void HandleAccessStatus()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            string acctConn = System.Configuration.ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString;
            string mainConn = System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

            DateTime evaluatedAt = DateTime.UtcNow;

            // ── Student profile (name, programme, study year) ───────
            string studentName = "", programme = "", programmeCode = "";
            int studyYear = 0;
            try
            {
                DataTable dtStudent = ApiHelper.Query(
                    "SELECT CONCAT(COALESCE(s.surname,''),' ',COALESCE(s.othernames,'')) AS full_name, " +
                    "s.progid, COALESCE(p.progname,'') AS programme_name, " +
                    "COALESCE((SELECT MAX(r.studyyear) FROM acad_registration r WHERE r.regno = s.regno),1) AS study_year " +
                    "FROM acad_student s LEFT JOIN acad_programme p ON p.progID = s.progid " +
                    "WHERE s.regno = @reg",
                    new MySqlParameter("@reg", regno));
                if (dtStudent.Rows.Count > 0)
                {
                    studentName = dtStudent.Rows[0]["full_name"].ToString().Trim();
                    programmeCode = dtStudent.Rows[0]["progid"] != DBNull.Value ? dtStudent.Rows[0]["progid"].ToString() : "";
                    programme = dtStudent.Rows[0]["programme_name"].ToString();
                    int.TryParse(dtStudent.Rows[0]["study_year"].ToString(), out studyYear);
                }
            }
            catch { /* student info is supplementary — don't fail */ }

            var studentInfo = new Dictionary<string, object>
            {
                { "regno", regno },
                { "name", studentName },
                { "programme", programme },
                { "programme_code", programmeCode },
                { "study_year", studyYear }
            };

            // ── Load active policy ──────────────────────────────────
            DataTable dtPolicy;
            try
            {
                dtPolicy = ApiHelper.QueryAccounts(
                    "SELECT * FROM fin_fee_access_policy WHERE is_active = 'yes' ORDER BY updated_at DESC, policy_id DESC LIMIT 1");
            }
            catch
            {
                dtPolicy = new DataTable(); // Table may not exist yet
            }

            if (dtPolicy.Rows.Count == 0)
            {
                // No active policy — access granted, no restrictions.
                var noPolicyCriteria = new List<Dictionary<string, object>>();
                noPolicyCriteria.Add(new Dictionary<string, object> {
                    { "rule", "No Active Restriction" },
                    { "passed", true },
                    { "enabled", false },
                    { "detail", "Fee access policy is currently disabled. No restrictions are being enforced." },
                    { "threshold", (object)null }
                });
                var noPolicy = new Dictionary<string, object>
                {
                    { "access_allowed", true },
                    { "has_policy", false },
                    { "verdict", "granted" },
                    { "verdict_reason", "No active fee access policy. All students are granted full access." },
                    { "student", studentInfo },
                    { "policy", (object)null },
                    { "finance", new Dictionary<string, object> {
                        { "total_bill", 0 }, { "total_paid", 0 }, { "balance", 0 },
                        { "percentage_paid", 0 }, { "currency", "UGX" }
                    }},
                    { "bursary", new Dictionary<string, object> {
                        { "status", "None" }, { "scheme_name", "" },
                        { "amount_offered", 0 }, { "coverage_percent", 0 }
                    }},
                    { "criteria", noPolicyCriteria },
                    { "summary", new Dictionary<string, object> {
                        { "total_rules", 0 }, { "rules_passed", 0 }, { "rules_failed", 0 },
                        { "enabled_rules", new List<string>() }
                    }},
                    { "guidance", "No active fee access restrictions. All students are granted access." },
                    { "evaluated_at", evaluatedAt.ToString("yyyy-MM-ddTHH:mm:ssZ") }
                };
                ApiHelper.Success(Response, noPolicy);
                return;
            }

            DataRow pol = dtPolicy.Rows[0];
            string policyTitle = SafeStr(pol, "policy_title");
            string acadYear = SafeStr(pol, "academic_year");
            int semester = SafeInt(pol, "semester");
            string logic = SafeStr(pol, "rule_logic").ToUpper() == "ANY" ? "ANY" : "ALL";
            string policyNotes = SafeStr(pol, "notes");
            string policyUpdatedAt = "";
            try { DateTime upd; if (DateTime.TryParse(SafeStr(pol, "updated_at"), out upd)) policyUpdatedAt = upd.ToString("yyyy-MM-ddTHH:mm:ssZ"); } catch { }

            bool balEnabled = SafeStr(pol, "rule_min_balance_enabled") == "yes";
            decimal balMax = SafeDec(pol, "rule_min_balance_amount");
            bool winEnabled = SafeStr(pol, "rule_payment_window_enabled") == "yes";
            decimal winMinAmt = SafeDec(pol, "rule_payment_min_amount");
            DateTime? winStart = SafeDate(pol, "rule_payment_window_start");
            DateTime? winEnd = SafeDate(pol, "rule_payment_window_end");
            bool pctEnabled = SafeStr(pol, "rule_pct_paid_enabled") == "yes";
            decimal pctMin = SafeDec(pol, "rule_pct_paid_minimum");
            bool bursaryExempt = SafeStr(pol, "rule_bursary_exempt") == "yes";
            decimal bursaryMinCoverage = SafeDec(pol, "rule_bursary_min_coverage");
            bool regRequired = SafeStr(pol, "rule_require_registration") == "yes";

            // Build policy configuration object
            var enabledRuleNames = new List<string>();
            if (balEnabled) enabledRuleNames.Add("Balance Threshold");
            if (winEnabled) enabledRuleNames.Add("Payment Window");
            if (pctEnabled) enabledRuleNames.Add("Percentage Paid");
            if (bursaryExempt) enabledRuleNames.Add("Bursary Exemption");
            if (regRequired) enabledRuleNames.Add("Registration");

            var policyConfig = new Dictionary<string, object>
            {
                { "policy_id", SafeInt(pol, "policy_id") },
                { "title", policyTitle },
                { "academic_year", acadYear },
                { "semester", semester },
                { "combination_logic", logic },
                { "combination_logic_description", logic == "ANY"
                    ? "Student passes if ANY one enabled rule is satisfied"
                    : "Student must satisfy ALL enabled rules to pass" },
                { "notes", policyNotes },
                { "updated_at", policyUpdatedAt },
                { "rules_enabled", new Dictionary<string, object> {
                    { "balance_threshold", balEnabled },
                    { "payment_window", winEnabled },
                    { "percentage_paid", pctEnabled },
                    { "bursary_exemption", bursaryExempt },
                    { "registration", regRequired }
                }},
                { "thresholds", new Dictionary<string, object> {
                    { "max_balance", balEnabled ? (object)balMax : null },
                    { "payment_window_min_amount", winEnabled ? (object)winMinAmt : null },
                    { "payment_window_start", winEnabled && winStart.HasValue ? (object)winStart.Value.ToString("yyyy-MM-dd") : null },
                    { "payment_window_end", winEnabled && winEnd.HasValue ? (object)winEnd.Value.ToString("yyyy-MM-dd") : null },
                    { "min_percentage_paid", pctEnabled ? (object)pctMin : null },
                    { "bursary_min_coverage", bursaryExempt ? (object)bursaryMinCoverage : null }
                }}
            };

            // ── Financial totals ────────────────────────────────────
            DataTable dtFin = ApiHelper.QueryAccounts(
                "SELECT " +
                "  COALESCE(SUM(dr_amount), 0) AS total_bill, " +
                "  COALESCE(SUM(cr_amount), 0) AS total_paid " +
                "FROM ( " +
                "  SELECT " +
                "    CASE WHEN fl.transactionType='DR' THEN fl.transaction_amount ELSE 0 END AS dr_amount, " +
                "    CASE WHEN fl.transactionType='CR' THEN fl.transaction_amount ELSE 0 END AS cr_amount " +
                "  FROM fin_ledger fl " +
                "  WHERE fl.accountcode = @reg AND fl.transaction_amount > 0 " +
                "  UNION ALL " +
                "  SELECT " +
                "    CASE WHEN t.trans_type='Bill' THEN t.amount ELSE 0 END AS dr_amount, " +
                "    CASE WHEN t.trans_type='Payment' THEN t.amount ELSE 0 END AS cr_amount " +
                "  FROM fin_studentfeestracking t " +
                "  WHERE t.regno = @reg AND t.post_status = 'Posted' " +
                "    AND NOT EXISTS ( " +
                "      SELECT 1 FROM fin_ledger fl2 " +
                "      WHERE fl2.accountcode = t.regno " +
                "        AND ( " +
                "          fl2.voucherNo = CAST(t.TID AS CHAR) " +
                "          OR fl2.folio = CONCAT('BillNo:', CAST(t.TID AS CHAR)) " +
                "          OR ( " +
                "            fl2.transaction_amount = t.amount " +
                "            AND DATE(fl2.transactionDate) = DATE(t.trans_date) " +
                "            AND fl2.transactionType = CASE WHEN t.trans_type='Payment' THEN 'CR' ELSE 'DR' END " +
                "            AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '') " +
                "          ) " +
                "        ) " +
                "    ) " +
                ") AS combined",
                new MySqlParameter("@reg", regno));

            decimal totalBill = 0, totalPaid = 0;
            if (dtFin.Rows.Count > 0)
            {
                totalBill = Convert.ToDecimal(dtFin.Rows[0]["total_bill"]);
                totalPaid = Convert.ToDecimal(dtFin.Rows[0]["total_paid"]);
            }
            decimal balance = totalBill - totalPaid;
            decimal pctPaidOverall = totalBill > 0 ? Math.Round(totalPaid / totalBill * 100, 1) : (totalPaid > 0 ? 100 : 0);

            var financeData = new Dictionary<string, object>
            {
                { "total_bill", totalBill },
                { "total_paid", totalPaid },
                { "balance", -balance },
                { "amount_owing", balance > 0 ? balance : 0 },
                { "credit_balance", balance < 0 ? Math.Abs(balance) : 0 },
                { "percentage_paid", pctPaidOverall },
                { "currency", "UGX" }
            };

            string bursaryStatus = "None";
            string bursarySchemeName = "";
            decimal bursaryOffered = 0;
            decimal bursaryCoverage = 0;
            var criteria = new List<Dictionary<string, object>>();
            bool bursaryShortCircuit = false;

            // ── Bursary exemption ───────────────────────────────────
            if (bursaryExempt)
            {
                DataTable dtBur = ApiHelper.QueryAccounts(
                    "SELECT ss.amount_offered, s.scholarshipName " +
                    "FROM scholarshipstudents ss " +
                    "JOIN scholarships s ON s.scholarshipID = ss.scholarshipID " +
                    "WHERE ss.adm_no = @reg AND ss.scholarhipYear = @ay AND ss.scholarhipTerm = @sem AND ss.status = 'Approved' LIMIT 1",
                    new MySqlParameter("@reg", regno),
                    new MySqlParameter("@ay", acadYear),
                    new MySqlParameter("@sem", semester));

                if (dtBur.Rows.Count > 0)
                {
                    bursaryOffered = Convert.ToDecimal(dtBur.Rows[0]["amount_offered"]);
                    bursarySchemeName = dtBur.Rows[0]["scholarshipName"] != null ? dtBur.Rows[0]["scholarshipName"].ToString() : "Scholarship";
                    bursaryStatus = "Active: " + bursarySchemeName;
                    bursaryCoverage = totalBill > 0 ? Math.Round(bursaryOffered / totalBill * 100, 1) : 100;
                    if (bursaryCoverage >= bursaryMinCoverage)
                    {
                        bursaryShortCircuit = true;
                        criteria.Add(new Dictionary<string, object> {
                            { "rule", "Bursary Exemption" },
                            { "passed", true },
                            { "enabled", true },
                            { "detail", string.Format("Bursary/scholarship ({0}) with {1:F0}% coverage — exempt.", bursarySchemeName, bursaryCoverage) },
                            { "threshold", string.Format("Min coverage: {0:F0}%", bursaryMinCoverage) },
                            { "actual_value", string.Format("{0:F0}%", bursaryCoverage) }
                        });
                    }
                    else
                    {
                        criteria.Add(new Dictionary<string, object> {
                            { "rule", "Bursary Exemption" },
                            { "passed", false },
                            { "enabled", true },
                            { "detail", string.Format("Bursary coverage {0:F0}% below required {1:F0}%.", bursaryCoverage, bursaryMinCoverage) },
                            { "threshold", string.Format("Min coverage: {0:F0}%", bursaryMinCoverage) },
                            { "actual_value", string.Format("{0:F0}%", bursaryCoverage) }
                        });
                    }
                }
                else
                {
                    bursaryStatus = "None";
                    criteria.Add(new Dictionary<string, object> {
                        { "rule", "Bursary Exemption" },
                        { "passed", false },
                        { "enabled", true },
                        { "detail", string.Format("No approved bursary found for {0} Semester {1}.", acadYear, semester) },
                        { "threshold", string.Format("Min coverage: {0:F0}%", bursaryMinCoverage) },
                        { "actual_value", "No bursary" }
                    });
                }
            }

            if (!bursaryShortCircuit)
            {
                // ── Rule 1: Balance ─────────────────────────────────
                if (balEnabled)
                {
                    bool pass = balance <= balMax;
                    string balDetail;
                    if (balance <= 0)
                        balDetail = string.Format("Student has a credit balance of {0:N0}. No outstanding fees.", Math.Abs(balance));
                    else if (pass)
                        balDetail = string.Format("Outstanding balance of {0:N0} is within the allowed maximum of {1:N0}.", balance, balMax);
                    else
                        balDetail = string.Format("Outstanding balance of {0:N0} exceeds the allowed maximum of {1:N0}.", balance, balMax);
                    criteria.Add(new Dictionary<string, object> {
                        { "rule", "Balance Threshold" },
                        { "passed", pass },
                        { "enabled", true },
                        { "detail", balDetail },
                        { "threshold", string.Format("Max balance: UGX {0:N0}", balMax) },
                        { "actual_value", string.Format("UGX {0:N0}", balance) }
                    });
                }

                // ── Rule 2: Payment Window ──────────────────────────
                if (winEnabled && winStart.HasValue && winEnd.HasValue)
                {
                    DataTable dtWin = ApiHelper.QueryAccounts(
                        "SELECT COALESCE(SUM(fl.transaction_amount), 0) AS window_payments " +
                        "FROM fin_ledger fl " +
                        "WHERE fl.accountcode = @reg AND fl.transactionType = 'CR' AND fl.transaction_amount > 0 " +
                        "  AND fl.transactionDate >= @ws AND fl.transactionDate <= @we",
                        new MySqlParameter("@reg", regno),
                        new MySqlParameter("@ws", winStart.Value),
                        new MySqlParameter("@we", winEnd.Value));

                    decimal windowPaid = dtWin.Rows.Count > 0 ? Convert.ToDecimal(dtWin.Rows[0]["window_payments"]) : 0;
                    bool pass = windowPaid >= winMinAmt;
                    criteria.Add(new Dictionary<string, object> {
                        { "rule", "Payment Window" },
                        { "passed", pass },
                        { "enabled", true },
                        { "detail", pass
                            ? string.Format("Paid {0:N0} between {1:yyyy-MM-dd} and {2:yyyy-MM-dd} (required: {3:N0}).", windowPaid, winStart.Value, winEnd.Value, winMinAmt)
                            : string.Format("Only paid {0:N0} between {1:yyyy-MM-dd} and {2:yyyy-MM-dd} (required: {3:N0}).", windowPaid, winStart.Value, winEnd.Value, winMinAmt) },
                        { "threshold", string.Format("Min UGX {0:N0} between {1:yyyy-MM-dd} and {2:yyyy-MM-dd}", winMinAmt, winStart.Value, winEnd.Value) },
                        { "actual_value", string.Format("UGX {0:N0}", windowPaid) }
                    });
                }

                // ── Rule 3: Percentage ──────────────────────────────
                if (pctEnabled)
                {
                    decimal pctPaid = totalBill > 0 ? Math.Round(totalPaid / totalBill * 100, 1) : 100;
                    bool pass = pctPaid >= pctMin;
                    criteria.Add(new Dictionary<string, object> {
                        { "rule", "Percentage Paid" },
                        { "passed", pass },
                        { "enabled", true },
                        { "detail", pass
                            ? string.Format("{0:F1}% of total fees paid (required: {1:F0}%).", pctPaid, pctMin)
                            : string.Format("Only {0:F1}% of total fees paid (required: {1:F0}%).", pctPaid, pctMin) },
                        { "threshold", string.Format("Min {0:F0}% paid", pctMin) },
                        { "actual_value", string.Format("{0:F1}%", pctPaid) }
                    });
                }

                // ── Rule 4: Registration ────────────────────────────
                if (regRequired)
                {
                    DataTable dtReg = ApiHelper.Query(
                        "SELECT regno FROM acad_registration WHERE regno = @reg AND acad_year = @ay AND semester = @sem AND regstatus = 'Registered' LIMIT 1",
                        new MySqlParameter("@reg", regno),
                        new MySqlParameter("@ay", acadYear),
                        new MySqlParameter("@sem", semester));

                    bool pass = dtReg.Rows.Count > 0;
                    criteria.Add(new Dictionary<string, object> {
                        { "rule", "Registration" },
                        { "passed", pass },
                        { "enabled", true },
                        { "detail", pass
                            ? string.Format("Student is registered for {0} Semester {1}.", acadYear, semester)
                            : string.Format("Student is NOT registered for {0} Semester {1}.", acadYear, semester) },
                        { "threshold", string.Format("Registered for {0} Sem {1}", acadYear, semester) },
                        { "actual_value", pass ? "Registered" : "Not registered" }
                    });
                }
            }

            // ── Combine ─────────────────────────────────────────────
            bool allowed;
            if (bursaryShortCircuit)
            {
                allowed = true;
            }
            else if (criteria.Count == 0)
            {
                allowed = true;
            }
            else if (logic == "ANY")
            {
                allowed = false;
                foreach (var cr in criteria)
                {
                    if ((bool)cr["passed"]) { allowed = true; break; }
                }
            }
            else // ALL
            {
                allowed = true;
                foreach (var cr in criteria)
                {
                    if (!(bool)cr["passed"]) { allowed = false; break; }
                }
            }

            // ── Summary counters ────────────────────────────────────
            int rulesPassed = 0, rulesFailed = 0;
            foreach (var cr in criteria) { if ((bool)cr["passed"]) rulesPassed++; else rulesFailed++; }

            // ── Guidance ────────────────────────────────────────────
            var tips = new List<string>();
            if (!allowed)
            {
                foreach (var cr in criteria)
                {
                    if (!(bool)cr["passed"])
                    {
                        string rule = cr["rule"].ToString();
                        if (rule == "Balance Threshold" && balance > balMax)
                        {
                            decimal excess = balance - balMax;
                            tips.Add(string.Format("Pay at least UGX {0:N0} to reduce the outstanding balance to the allowed maximum of UGX {1:N0}.", excess, balMax));
                        }
                        else if (rule == "Payment Window" && winEnd.HasValue)
                            tips.Add(string.Format("Make a payment of at least UGX {0:N0} before {1:yyyy-MM-dd}.", winMinAmt, winEnd.Value));
                        else if (rule == "Percentage Paid")
                        {
                            decimal needed = (pctMin / 100 * totalBill) - totalPaid;
                            if (needed > 0) tips.Add(string.Format("Pay an additional UGX {0:N0} to reach the required {1:F0}%.", needed, pctMin));
                        }
                        else if (rule == "Registration")
                            tips.Add(string.Format("Complete your registration for {0} Semester {1} at the Academic Registrar's office.", acadYear, semester));
                        else if (rule == "Bursary Exemption")
                            tips.Add("Contact the Scholarships Office about your bursary status.");
                    }
                }
            }

            // ── Verdict reason ──────────────────────────────────────
            string verdictReason;
            if (bursaryShortCircuit)
                verdictReason = string.Format("Student is exempt via bursary/scholarship ({0}).", bursarySchemeName);
            else if (criteria.Count == 0)
                verdictReason = "No rules are enabled in the active policy. All students pass by default.";
            else if (allowed && logic == "ANY")
                verdictReason = string.Format("{0} of {1} rule(s) passed. Policy requires ANY one rule to pass.", rulesPassed, criteria.Count);
            else if (allowed)
                verdictReason = string.Format("All {0} rule(s) passed.", criteria.Count);
            else if (logic == "ANY")
                verdictReason = string.Format("No rules passed (0 of {0}). Policy requires at least one to pass.", criteria.Count);
            else
                verdictReason = string.Format("{0} of {1} rule(s) failed. Policy requires ALL rules to pass.", rulesFailed, criteria.Count);

            var bursaryData = new Dictionary<string, object>
            {
                { "status", bursaryStatus },
                { "scheme_name", bursarySchemeName },
                { "amount_offered", bursaryOffered },
                { "coverage_percent", bursaryCoverage },
                { "exempt", bursaryShortCircuit }
            };

            var summaryData = new Dictionary<string, object>
            {
                { "total_rules", criteria.Count },
                { "rules_passed", rulesPassed },
                { "rules_failed", rulesFailed },
                { "enabled_rules", enabledRuleNames }
            };

            var data = new Dictionary<string, object>
            {
                { "access_allowed", allowed },
                { "has_policy", true },
                { "verdict", allowed ? "granted" : "denied" },
                { "verdict_reason", verdictReason },
                { "student", studentInfo },
                { "policy", policyConfig },
                { "finance", financeData },
                { "bursary", bursaryData },
                { "criteria", criteria },
                { "summary", summaryData },
                { "guidance", string.Join(" ", tips.ToArray()) },
                { "evaluated_at", evaluatedAt.ToString("yyyy-MM-ddTHH:mm:ssZ") }
            };
            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error evaluating access status: " + ex.Message, "ACCESS_STATUS_ERROR");
        }
    }

    // ─── Helpers for access_status ───────────────────────────────────────

    private static string SafeStr(DataRow row, string col)
    {
        if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return "";
        return row[col].ToString();
    }

    private static int SafeInt(DataRow row, string col)
    {
        if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return 0;
        int v;
        return int.TryParse(row[col].ToString(), out v) ? v : 0;
    }

    private static decimal SafeDec(DataRow row, string col)
    {
        if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return 0;
        decimal v;
        return decimal.TryParse(row[col].ToString(), out v) ? v : 0;
    }

    private static DateTime? SafeDate(DataRow row, string col)
    {
        if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return null;
        DateTime v;
        if (DateTime.TryParse(row[col].ToString(), out v)) return v;
        return null;
    }
}
