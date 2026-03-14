using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
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
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: ledger, balance, fees_structure", "INVALID_ACTION");
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
}
