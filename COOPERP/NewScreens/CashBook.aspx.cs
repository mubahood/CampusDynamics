using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Cash Book — Bank &amp; cash account transaction register.
/// 
/// NEW FEATURE (Phase 2):
///  ✓ Bank/cash account selector (from chart of accounts)
///  ✓ Date-range filter with financial-period defaults
///  ✓ Ledger grid: DR/CR columns + server-computed running balance
///  ✓ KPIs: Opening balance, total DR, total CR, closing balance
///  ✓ CSV export &amp; browser print
///  ✓ Uses FinanceDB, FinancePeriod, MoneyHelper, FinanceLogger
/// </summary>
public partial class COOPERP_NewScreens_CashBook : System.Web.UI.Page
{
    private const string PAGE_NAME = "CashBook";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAccounts();
            SetDefaultDates();
            LoadLedger();
        }
    }

    /// <summary>Populates dropdown with bank and cash accounts.</summary>
    private void LoadAccounts()
    {
        ddlAccount.Items.Clear();
        ddlAccount.Items.Add(new ListItem("-- Select Account --", ""));

        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                @"SELECT sa.accountCode, CONCAT(sa.accountCode,' - ',sa.accountName) AS display
                  FROM fin_subAccounts sa
                  INNER JOIN fin_mainaccounts ma ON sa.MainAccountCode = ma.AccountCode
                  WHERE ma.AccountName LIKE '%Bank%' OR ma.AccountName LIKE '%Cash%'
                  ORDER BY sa.accountName");

            foreach (DataRow row in dt.Rows)
                ddlAccount.Items.Add(new ListItem(row["display"].ToString(), row["accountCode"].ToString()));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadAccounts", ex);
        }
    }

    /// <summary>Sets start/end dates from financial period or academic year default.</summary>
    private void SetDefaultDates()
    {
        DateTime start, end;
        FinancePeriod.GetDefaultDateRange(out start, out end);
        txtStartDate.Text = start.ToString("yyyy-MM-dd");
        txtEndDate.Text = end.ToString("yyyy-MM-dd");

        // Period badge
        var period = FinancePeriod.GetOpenPeriod();
        if (period != null)
        {
            litPeriodBadge.Text = string.Format(
                "<span style='background:rgba(255,255,255,.15);padding:4px 10px;font-size:10px;border-radius:3px;'>{0}</span>",
                period.Name);
        }
    }

    protected void ddlAccount_Changed(object sender, EventArgs e)
    {
        LoadLedger();
    }

    protected void btnLoad_Click(object sender, EventArgs e)
    {
        LoadLedger();
    }

    /// <summary>Main data loader — queries fin_ledger with running balance.</summary>
    private void LoadLedger()
    {
        string accCode = ddlAccount.SelectedValue;
        if (string.IsNullOrEmpty(accCode))
        {
            rptLedger.DataSource = null;
            rptLedger.DataBind();
            ClearKPIs();
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
            startDate = new DateTime(DateTime.Today.Year, 1, 1);
        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
            endDate = DateTime.Today;

        try
        {
            // Opening balance: sum of all transactions before start date
            decimal openingBalance = ComputeBalance(accCode, null, startDate.AddDays(-1));

            // Transactions in the date range
            DataTable dt = FinanceDB.ExecuteDataTable(
                @"SELECT TID, transactionDate, voucherNo, particulars, folio,
                         transactionType, transaction_amount
                  FROM fin_ledger
                  WHERE accountcode = @acc AND account_type = 'Chart Account'
                    AND transactionDate BETWEEN @s AND @e
                  ORDER BY transactionDate, TID",
                FinanceDB.P("@acc", accCode),
                FinanceDB.P("@s", startDate),
                FinanceDB.P("@e", endDate));

            // Compute running balance in-memory (avoids SP side-effects)
            dt.Columns.Add("running_balance", typeof(string));
            decimal balance = openingBalance;
            decimal totalDR = 0, totalCR = 0;

            foreach (DataRow row in dt.Rows)
            {
                decimal amt = MoneyHelper.ToDecimal(row["transaction_amount"]);
                string txType = row["transactionType"].ToString().Trim().ToUpper();

                if (txType == "DR")
                {
                    balance += amt;
                    totalDR += amt;
                }
                else
                {
                    balance -= amt;
                    totalCR += amt;
                }

                row["running_balance"] = MoneyHelper.FormatNumber(balance);
            }

            decimal closingBalance = balance;

            rptLedger.DataSource = dt;
            rptLedger.DataBind();

            // KPIs
            litOpening.Text = MoneyHelper.FormatNumber(openingBalance);
            litTotalDR.Text = MoneyHelper.FormatNumber(totalDR);
            litTotalCR.Text = MoneyHelper.FormatNumber(totalCR);
            litClosing.Text = MoneyHelper.FormatNumber(closingBalance);

            // Footer totals (inside tfoot of table)
            litFootDR.Text = MoneyHelper.FormatNumber(totalDR);
            litFootCR.Text = MoneyHelper.FormatNumber(totalCR);
            litFootBal.Text = MoneyHelper.FormatNumber(closingBalance);

            litFooter.Text = string.Format("Showing <strong>{0}</strong> transaction(s)  &bull;  {1:dd/MM/yyyy} to {2:dd/MM/yyyy}",
                dt.Rows.Count, startDate, endDate);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadLedger", ex);
            ShowMessage("Error loading ledger: " + ex.Message, false);
        }
    }

    /// <summary>Computes DR minus CR balance up to a date for an account.</summary>
    private static decimal ComputeBalance(string accCode, DateTime? fromDate, DateTime toDate)
    {
        string sql;
        if (fromDate.HasValue)
        {
            sql = @"SELECT IFNULL(SUM(IF(transactionType='DR', transaction_amount, 0)),0) -
                           IFNULL(SUM(IF(transactionType='CR', transaction_amount, 0)),0)
                    FROM fin_ledger
                    WHERE accountcode = @acc AND account_type = 'Chart Account'
                      AND transactionDate BETWEEN @s AND @e";
            return FinanceDB.ExecuteScalar<decimal>(sql,
                FinanceDB.P("@acc", accCode),
                FinanceDB.P("@s", fromDate.Value),
                FinanceDB.P("@e", toDate));
        }
        else
        {
            sql = @"SELECT IFNULL(SUM(IF(transactionType='DR', transaction_amount, 0)),0) -
                           IFNULL(SUM(IF(transactionType='CR', transaction_amount, 0)),0)
                    FROM fin_ledger
                    WHERE accountcode = @acc AND account_type = 'Chart Account'
                      AND transactionDate <= @e";
            return FinanceDB.ExecuteScalar<decimal>(sql,
                FinanceDB.P("@acc", accCode),
                FinanceDB.P("@e", toDate));
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        string accCode = ddlAccount.SelectedValue;
        if (string.IsNullOrEmpty(accCode)) return;

        DateTime startDate, endDate;
        DateTime.TryParse(txtStartDate.Text, out startDate);
        DateTime.TryParse(txtEndDate.Text, out endDate);

        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                @"SELECT transactionDate, voucherNo, particulars, folio, transactionType, transaction_amount
                  FROM fin_ledger
                  WHERE accountcode = @acc AND account_type = 'Chart Account'
                    AND transactionDate BETWEEN @s AND @e
                  ORDER BY transactionDate, TID",
                FinanceDB.P("@acc", accCode),
                FinanceDB.P("@s", startDate),
                FinanceDB.P("@e", endDate));

            decimal bal = ComputeBalance(accCode, null, startDate.AddDays(-1));

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition",
                "attachment;filename=CashBook_" + accCode + "_" + startDate.ToString("yyyyMMdd") + ".csv");

            var sb = new StringBuilder();
            sb.AppendLine("Date,Voucher No,Particulars,Folio,Debit,Credit,Balance");

            // Opening balance row
            sb.AppendFormat(",,,Opening Balance,,,{0}\r\n", bal);

            foreach (DataRow r in dt.Rows)
            {
                decimal amt = MoneyHelper.ToDecimal(r["transaction_amount"]);
                string typ = r["transactionType"].ToString().Trim().ToUpper();
                decimal dr = typ == "DR" ? amt : 0;
                decimal cr = typ == "CR" ? amt : 0;
                bal += (typ == "DR" ? amt : -amt);

                sb.AppendFormat("{0:dd/MM/yyyy},\"{1}\",\"{2}\",\"{3}\",{4},{5},{6}\r\n",
                    r["transactionDate"], r["voucherNo"], 
                    (r["particulars"] ?? "").ToString().Replace("\"", "'"),
                    r["folio"], dr, cr, bal);
            }

            Response.Write(sb.ToString());
            Response.End();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnExport_Click", ex);
        }
    }

    // ── Repeater formatting helpers ─────────────────────────────

    protected string FormatDR(object transType, object amount)
    {
        if (transType == null) return "";
        if (transType.ToString().Trim().ToUpper() == "DR")
            return MoneyHelper.FormatNumber(MoneyHelper.ToDecimal(amount));
        return "";
    }

    protected string FormatCR(object transType, object amount)
    {
        if (transType == null) return "";
        if (transType.ToString().Trim().ToUpper() == "CR")
            return MoneyHelper.FormatNumber(MoneyHelper.ToDecimal(amount));
        return "";
    }

    private void ClearKPIs()
    {
        litOpening.Text = "0";
        litTotalDR.Text = "0";
        litTotalCR.Text = "0";
        litClosing.Text = "0";
        litFootDR.Text = "";
        litFootCR.Text = "";
        litFootBal.Text = "";
        litFooter.Text = "";
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        pnlMsg.CssClass = isSuccess ? "cb-msg cb-msg-ok" : "cb-msg cb-msg-err";
        litMsg.Text = HttpUtility.HtmlEncode(msg);
    }
}
