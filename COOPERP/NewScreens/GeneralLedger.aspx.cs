using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

/// <summary>
/// General Ledger — primary transaction viewer with filtering and pagination.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB.AcctConnStr
///  ✓ Inline LoadAccountsDropDown → AccountCache.BindAccountDropDown
///  ✓ Calendar-month defaults → FinancePeriod.GetDefaultDateRange
///  ✓ Inline FormatCurrency → MoneyHelper.FormatUGX
///  ✓ Inline BuildPagerHtml → PaginationHelper.BuildPagerHtml
///  ✓ 120-line god method → decomposed into BuildWhereClause, LoadStats, LoadPageData
///  ✓ Dead conditional (same netClass both branches) → fixed
///  ✓ No error handling → try/catch + FinanceLogger.LogError
///  ✓ Swallowed pageSize exception → PaginationHelper.ParsePageSize
///  ✓ Inline SVG moved to ternary (markup stays in .aspx where possible)
/// </summary>
public partial class COOPERP_NewScreens_GeneralLedger : System.Web.UI.Page
{
    private const string PAGE_NAME = "GeneralLedger";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Default dates from open financial period (not calendar month)
            var range = FinancePeriod.GetDefaultDateRange();
            txtStartDate.Text = range.Item1.ToString("yyyy-MM-dd");
            txtEndDate.Text   = range.Item2.ToString("yyyy-MM-dd");

            // Cached account dropdown — single DB hit shared across pages
            AccountCache.BindAccountDropDown(ddlAccount, includeAll: true, allText: "All Accounts");

            LoadLedger();
        }
    }

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadLedger();
    }

    protected void ddlPageSize_Changed(object sender, EventArgs e)
    {
        hfPageIndex.Value = "0";
        LoadLedger();
    }

    // ───────────────────────── Main Load ──────────────────────────────────

    private void LoadLedger()
    {
        try
        {
            // 1. Parse filter inputs
            DateTime startDate = ParseDate(txtStartDate.Text,
                new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1));
            DateTime endDate = ParseDate(txtEndDate.Text, DateTime.Today);
            string accountCode = ddlAccount.SelectedValue;
            string transType   = ddlType.SelectedValue;

            // 2. Build shared WHERE clause + parameters
            string where;
            var filterParams = BuildWhereClause(startDate, endDate, accountCode, transType, out where);

            // 3. Load aggregate stats (single query)
            long totalRows;
            decimal sumDR, sumCR;
            LoadStats(where, filterParams, out totalRows, out sumDR, out sumCR);

            // 4. Render stats cards + totals bar
            RenderStatsCards(sumDR, sumCR, totalRows);

            // 5. Paging
            int pageSize  = PaginationHelper.ParsePageSize(ddlPageSize.SelectedValue);
            int pageIndex = ResolvePageIndex(pageSize);
            int totalPages = totalRows > 0 ? (int)Math.Ceiling((double)totalRows / pageSize) : 1;
            pageIndex = PaginationHelper.ClampPageIndex(pageIndex, totalPages);
            hfPageIndex.Value = pageIndex.ToString();

            // 6. Load data page
            DataTable dt = LoadPageData(where, filterParams, pageIndex, pageSize);
            rptLedger.DataSource = dt;
            rptLedger.DataBind();
            phNoData.Visible = (dt.Rows.Count == 0);

            // 7. Footer + pager
            lblGridFooter.Text = PaginationHelper.BuildFooterHtml(totalRows, pageIndex, pageSize);
            litPager.Text = PaginationHelper.BuildPagerHtml(pageIndex, totalPages);

            // 8. Period badge
            litPeriodBadge.Text = string.Format(
                "<span class='ft-card__meta'>{0:dd MMM yyyy} - {1:dd MMM yyyy}</span>",
                startDate, endDate);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadLedger", ex);
            phNoData.Visible = true;
        }
    }

    // ───────────────────────── Decomposed Methods ─────────────────────────

    /// <summary>
    /// Builds the parameterised WHERE clause and returns a reusable parameter list.
    /// </summary>
    private static List<MySql.Data.MySqlClient.MySqlParameter> BuildWhereClause(
        DateTime startDate, DateTime endDate, string accountCode, string transType,
        out string where)
    {
        where = " WHERE transactionDate BETWEEN @sDate AND @eDate";
        var parms = new List<MySql.Data.MySqlClient.MySqlParameter>
        {
            FinanceDB.P("@sDate", startDate),
            FinanceDB.P("@eDate", endDate)
        };

        if (!string.IsNullOrEmpty(accountCode))
        {
            where += " AND accountcode = @acc";
            parms.Add(FinanceDB.P("@acc", accountCode));
        }
        if (!string.IsNullOrEmpty(transType))
        {
            where += " AND transactionType = @typ";
            parms.Add(FinanceDB.P("@typ", transType));
        }

        return parms;
    }

    /// <summary>
    /// Single aggregate query for all stats cards.
    /// </summary>
    private static void LoadStats(string where,
        List<MySql.Data.MySqlClient.MySqlParameter> filterParams,
        out long totalRows, out decimal sumDR, out decimal sumCR)
    {
        string sql = "SELECT COUNT(*) AS total_rows,"
            + " SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END) AS sum_dr,"
            + " SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END) AS sum_cr"
            + " FROM fin_ledger" + where;

        var row = FinanceDB.ExecuteAggregateRow(sql, filterParams.ToArray());

        totalRows = row.ContainsKey("total_rows") && row["total_rows"] != null
            ? Convert.ToInt64(row["total_rows"]) : 0;
        sumDR = row.ContainsKey("sum_dr") && row["sum_dr"] != null
            ? MoneyHelper.ToDecimal(row["sum_dr"]) : 0m;
        sumCR = row.ContainsKey("sum_cr") && row["sum_cr"] != null
            ? MoneyHelper.ToDecimal(row["sum_cr"]) : 0m;
    }

    /// <summary>
    /// Renders the four stats cards and the totals bar.
    /// </summary>
    private void RenderStatsCards(decimal sumDR, decimal sumCR, long totalRows)
    {
        litSumDR.Text       = MoneyHelper.FormatUGX(sumDR);
        litSumCR.Text       = MoneyHelper.FormatUGX(sumCR);
        litNetBalance.Text  = MoneyHelper.FormatUGX(MoneyHelper.Difference(sumDR, sumCR));
        litRecordCount.Text = totalRows.ToString("N0");

        litTotalBarDR.Text = MoneyHelper.FormatUGX(sumDR);
        litTotalBarCR.Text = MoneyHelper.FormatUGX(sumCR);

        decimal net = sumDR - sumCR;
        // Fixed: previously both branches had identical class
        string netClass = net >= 0 ? "ft-totals__pill--net-dr" : "ft-totals__pill--net-cr";
        string netLabel = MoneyHelper.NetLabel(sumDR, sumCR);
        string netIcon = net >= 0
            ? "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'><circle cx='12' cy='12' r='10'/><line x1='12' y1='8' x2='12' y2='16'/><line x1='8' y1='12' x2='16' y2='12'/></svg>"
            : "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'><circle cx='12' cy='12' r='10'/><line x1='8' y1='12' x2='16' y2='12'/></svg>";
        litTotalBarNet.Text = string.Format(
            "<span class='ft-totals__pill {0}'>{1} {2}: {3}</span>",
            netClass, netIcon, netLabel, MoneyHelper.FormatUGX(Math.Abs(net)));
    }

    /// <summary>
    /// Loads one page of ledger data using LIMIT/OFFSET.
    /// Uses cloned parameters to avoid reuse conflicts.
    /// </summary>
    private static DataTable LoadPageData(string where,
        List<MySql.Data.MySqlClient.MySqlParameter> filterParams,
        int pageIndex, int pageSize)
    {
        string sql = "SELECT TID, transactionDate, accountcode, account_type, particulars,"
            + " transactionType, transaction_amount, voucherNo, teller"
            + " FROM fin_ledger" + where
            + " ORDER BY transactionDate DESC, TID DESC LIMIT @pgOffset, @pgSize";

        // Clone parameters and add paging params
        var parms = new List<MySql.Data.MySqlClient.MySqlParameter>();
        foreach (var p in filterParams)
            parms.Add(FinanceDB.P(p.ParameterName, p.Value));
        parms.Add(FinanceDB.P("@pgOffset", PaginationHelper.GetOffset(pageIndex, pageSize)));
        parms.Add(FinanceDB.P("@pgSize", pageSize));

        return FinanceDB.ExecuteDataTable(sql, parms.ToArray());
    }

    // ───────────────────────── Utility ─────────────────────────────────────

    /// <summary>
    /// Resolves the current page index from the hidden field, handling
    /// page-size change vs regular navigation.
    /// </summary>
    private int ResolvePageIndex(int pageSize)
    {
        string eventTarget = Request.Form["__EVENTTARGET"] ?? "";
        if (eventTarget == ddlPageSize.UniqueID)
            return 0; // page-size change resets to page 0

        return PaginationHelper.ParsePageIndex(hfPageIndex.Value);
    }

    /// <summary>
    /// Safely parses a date string with a fallback default.
    /// </summary>
    private static DateTime ParseDate(string text, DateTime fallback)
    {
        DateTime dt;
        return DateTime.TryParse(text, out dt) ? dt : fallback;
    }
}
