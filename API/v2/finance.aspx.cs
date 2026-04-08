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
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: ledger, balance, fees_structure, payment_history, billing_summary, fee_status, bulk_fee_check", "INVALID_ACTION");
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
}
