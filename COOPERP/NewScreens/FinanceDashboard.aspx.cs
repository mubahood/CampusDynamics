using System;
using System.Data;
using System.Text;
using System.Web.UI;

/// <summary>
/// Finance Dashboard — overview with KPIs, alerts, and recent journals.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ LoadPeriodDates → FinancePeriod.GetOpenPeriod
///  ✓ Duplicate unposted journals query (LoadUnpostedJournals + LoadAlerts) → single query
///  ✓ GetDouble for money → decimal via MoneyHelper
///  ✓ 65-line HTML builder → cleaner StringBuilder with HtmlEncode
///  ✓ Unbounded unbalanced-voucher scan → bounded LIMIT
///  ✓ No error logging → FinanceLogger.LogError
///  ✓ Better separation: each section in its own method
/// </summary>
public partial class COOPERP_NewScreens_FinanceDashboard : System.Web.UI.Page
{
    private const string PAGE_NAME = "FinanceDashboard";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDashboard();
        }
    }

    private void LoadDashboard()
    {
        try
        {
            // 1. Get current open financial period
            var period = FinancePeriod.GetOpenPeriod();
            DateTime periodStart = period != null ? period.StartDate : DateTime.Today.AddMonths(-12);
            DateTime periodEnd = period != null ? period.EndDate : DateTime.Today;

            // Period badge
            if (period != null)
                litPeriodBadge.Text = "<span class='fs-badge fs-badge--green' style='font-size:10px;padding:4px 10px;'>" +
                    System.Web.HttpUtility.HtmlEncode(period.Label) + " &bull; Open</span>";

            // 2. Period totals (DR/CR)
            LoadPeriodTotals(periodStart, periodEnd);

            // 3. Unposted journals — single query, reused for KPI + alerts
            int unpostedCount = FinanceDB.ExecuteScalar<int>(
                "SELECT COUNT(*) FROM fin_journalnumbers WHERE PostStatus = 'New'");
            lblUnpostedJournals.Text = unpostedCount.ToString("N0");

            // 4. Total accounts
            lblTotalAccounts.Text = FinanceDB.ExecuteScalar<int>(
                "SELECT COUNT(*) FROM fin_subaccounts").ToString("N0");

            // 5. Financial periods list
            DataTable periods = FinancePeriod.GetRecentPeriods(5);
            rptPeriods.DataSource = periods;
            rptPeriods.DataBind();

            // 6. Alerts
            LoadAlerts(unpostedCount);

            // 7. Recent journals
            LoadRecentJournals();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadDashboard", ex);
            litAlerts.Text = "<div class='fn-alert fn-alert--danger'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>" +
                "Error loading dashboard: " + System.Web.HttpUtility.HtmlEncode(ex.Message) + "</div>";
        }
    }

    private void LoadPeriodTotals(DateTime start, DateTime end)
    {
        var row = FinanceDB.ExecuteAggregateRow(
            @"SELECT 
                COALESCE(SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END), 0) AS TotalDR,
                COALESCE(SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END), 0) AS TotalCR
              FROM fin_ledger 
              WHERE transactionDate BETWEEN @sDate AND @eDate",
            FinanceDB.P("@sDate", start),
            FinanceDB.P("@eDate", end));

        decimal totalDR = MoneyHelper.ToDecimal(row.ContainsKey("TotalDR") ? row["TotalDR"] : 0);
        decimal totalCR = MoneyHelper.ToDecimal(row.ContainsKey("TotalCR") ? row["TotalCR"] : 0);
        lblTotalDR.Text = MoneyHelper.FormatNumber(totalDR);
        lblTotalCR.Text = MoneyHelper.FormatNumber(totalCR);
    }

    /// <summary>
    /// Builds alert HTML. Receives unposted count to avoid duplicate query.
    /// </summary>
    private void LoadAlerts(int unpostedCount)
    {
        var sb = new StringBuilder();

        // Unbalanced vouchers (bounded scan)
        int unbalanced = FinanceDB.ExecuteScalar<int>(
            @"SELECT COUNT(*) FROM (
                SELECT voucherNo FROM fin_ledger 
                GROUP BY voucherNo 
                HAVING ABS(SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END) 
                         - SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END)) > 0.01
                LIMIT 1000
              ) t");

        if (unbalanced > 0)
            sb.AppendFormat("<div class='fn-alert fn-alert--danger'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>" +
                "<strong>{0}</strong> unbalanced voucher(s) detected in the ledger.</div>", unbalanced);

        // Unposted journals (reused from caller)
        if (unpostedCount > 0)
            sb.AppendFormat("<div class='fn-alert fn-alert--warning'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'/><line x1='12' y1='9' x2='12' y2='13'/><line x1='12' y1='17' x2='12.01' y2='17'/></svg>" +
                "<strong>{0}</strong> journal(s) pending approval/posting.</div>", unpostedCount);

        // Financial period status
        int openPeriods = FinanceDB.ExecuteScalar<int>(
            "SELECT COUNT(*) FROM fin_financial_years WHERE status = 'Open'");

        if (openPeriods == 0)
            sb.Append("<div class='fn-alert fn-alert--danger'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>" +
                "No open financial period! Transactions cannot be posted.</div>");
        else if (openPeriods > 1)
            sb.AppendFormat("<div class='fn-alert fn-alert--warning'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'/><line x1='12' y1='9' x2='12' y2='13'/><line x1='12' y1='17' x2='12.01' y2='17'/></svg>" +
                "<strong>{0}</strong> financial periods are currently open. Consider closing older periods.</div>", openPeriods);
        else
            sb.Append("<div class='fn-alert fn-alert--info'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg>" +
                "Financial period is active and open.</div>");

        litAlerts.Text = sb.Length > 0 ? sb.ToString()
            : "<div class='fn-alert fn-alert--info'>" +
              "<svg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg>" +
              "All systems normal. No alerts at this time.</div>";
    }

    private void LoadRecentJournals()
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            @"SELECT j.JournalNo, j.journalType, j.journalDate, j.RefNo, j.journalParticulars, 
                     j.GL_VoucherNo, j.Teller, j.PostStatus,
                     COALESCE(SUM(CASE WHEN d.transactionType='DR' THEN d.transaction_amount ELSE 0 END),0) AS TotalDR,
                     COALESCE(SUM(CASE WHEN d.transactionType='CR' THEN d.transaction_amount ELSE 0 END),0) AS TotalCR
              FROM fin_journalnumbers j
              LEFT JOIN fin_journal_details d ON j.JournalNo = d.journal_no
              GROUP BY j.JournalNo
              ORDER BY j.JournalNo DESC 
              LIMIT 20");

        litJournalCount.Text = dt.Rows.Count + " journals shown";

        var sb = new StringBuilder();
        foreach (DataRow r in dt.Rows)
        {
            string status = r["PostStatus"].ToString();
            string badgeCls = status == "Approved" ? "fs-badge--green" : "fs-badge--amber";
            string jDate = r["journalDate"] != DBNull.Value
                ? Convert.ToDateTime(r["journalDate"]).ToString("dd MMM yyyy") : "\u2014";
            decimal dr = MoneyHelper.ToDecimal(r["TotalDR"]);
            decimal cr = MoneyHelper.ToDecimal(r["TotalCR"]);

            sb.Append("<tr>");
            sb.AppendFormat("<td style='font-weight:600;color:#05275C;'>{0}</td>",
                System.Web.HttpUtility.HtmlEncode(r["JournalNo"].ToString()));
            sb.AppendFormat("<td>{0}</td>", System.Web.HttpUtility.HtmlEncode(r["journalType"].ToString()));
            sb.AppendFormat("<td>{0}</td>", jDate);
            sb.AppendFormat("<td>{0}</td>", System.Web.HttpUtility.HtmlEncode(r["RefNo"].ToString()));
            sb.AppendFormat("<td style='max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;'>{0}</td>",
                System.Web.HttpUtility.HtmlEncode(r["journalParticulars"].ToString()));
            sb.AppendFormat("<td>{0}</td>", System.Web.HttpUtility.HtmlEncode(r["GL_VoucherNo"].ToString()));
            sb.AppendFormat("<td style='text-align:right;font-family:Consolas,monospace;font-size:10px;'>{0}</td>",
                MoneyHelper.FormatNumber(dr));
            sb.AppendFormat("<td style='text-align:right;font-family:Consolas,monospace;font-size:10px;'>{0}</td>",
                MoneyHelper.FormatNumber(cr));
            sb.AppendFormat("<td>{0}</td>", System.Web.HttpUtility.HtmlEncode(r["Teller"].ToString()));
            sb.AppendFormat("<td><span class='fs-badge {0}'>{1}</span></td>", badgeCls,
                System.Web.HttpUtility.HtmlEncode(status));
            sb.Append("</tr>");
        }

        if (dt.Rows.Count == 0)
            sb.Append("<tr><td colspan='10' style='text-align:center;padding:24px;color:#999;font-size:12px;'>No journal entries found.</td></tr>");

        litRecentJournalRows.Text = sb.ToString();
    }
}
