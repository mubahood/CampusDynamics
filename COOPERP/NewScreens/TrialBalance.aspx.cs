using System;
using System.Data;
using System.Web.UI;

/// <summary>
/// Trial Balance — DR vs CR totals for a date range.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ Calendar-year default → FinancePeriod.GetDefaultDateRange
///  ✓ No error handling → try/catch + FinanceLogger.LogError
///  ✓ No audit trail → FinanceLogger.LogReportGenerated
/// </summary>
public partial class COOPERP_NewScreens_TrialBalance : System.Web.UI.Page
{
    private const string PAGE_NAME = "TrialBalance";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            var range = FinancePeriod.GetDefaultDateRange();
            txtStartDate.Text = range.Item1.ToString("yyyy-MM-dd");
            txtEndDate.Text = range.Item2.ToString("yyyy-MM-dd");
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        LoadTrialBalance();
    }

    private void LoadTrialBalance()
    {
        try
        {
            DateTime startDate, endDate;
            if (!DateTime.TryParse(txtStartDate.Text, out startDate))
                startDate = new DateTime(DateTime.Today.Year, 1, 1);
            if (!DateTime.TryParse(txtEndDate.Text, out endDate))
                endDate = DateTime.Today;

            DataTable dt = FinanceDB.ExecuteSP("fin_TrialBalance",
                FinanceDB.P("@sDate", startDate.ToString("yyyy-MM-dd")),
                FinanceDB.P("@eDate", endDate.ToString("yyyy-MM-dd")));

            gridTrialBalance.DataSource = dt;
            gridTrialBalance.DataBind();

            // Compute totals
            decimal totalDR = 0, totalCR = 0;
            foreach (DataRow row in dt.Rows)
            {
                decimal dr = 0, cr = 0;
                decimal.TryParse(row["DRBalance"].ToString(), out dr);
                decimal.TryParse(row["CRBalance"].ToString(), out cr);
                totalDR += dr;
                totalCR += cr;
            }

            decimal diff = Math.Abs(totalDR - totalCR);

            litTotalDR.Text = totalDR.ToString("N2");
            litTotalCR.Text = totalCR.ToString("N2");
            litDifference.Text = diff.ToString("N2");
            litAccountCount.Text = dt.Rows.Count.ToString();

            litPeriodStart.Text = startDate.ToString("dd MMM yyyy");
            litPeriodEnd.Text = endDate.ToString("dd MMM yyyy");
            litGenDate.Text = DateTime.Now.ToString("dd MMM yyyy HH:mm");

            // Balance status
            if (diff < 0.01m)
            {
                pnlBalanceStatus.CssClass = "tb-status-banner tb-status-ok";
                litBalanceStatus.Text = "&#10004; Trial Balance is BALANCED - Total Debits equal Total Credits.";
                spanDiff.Attributes["class"] = "tb-summary-value tb-balanced";
            }
            else
            {
                pnlBalanceStatus.CssClass = "tb-status-banner tb-status-err";
                litBalanceStatus.Text = "&#9888; Trial Balance is UNBALANCED - Difference of " + diff.ToString("N2") + " detected.";
                spanDiff.Attributes["class"] = "tb-summary-value tb-unbalanced";
            }

            pnlReport.Visible = true;
            FinanceLogger.LogReportGenerated(PAGE_NAME, startDate.ToString("yyyy-MM-dd") + " to " +
                endDate.ToString("yyyy-MM-dd") + " DR=" + totalDR.ToString("N2") + " CR=" + totalCR.ToString("N2"));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadTrialBalance", ex);
        }
    }
}
