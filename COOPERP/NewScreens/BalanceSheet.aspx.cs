using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Balance Sheet — As-At-Date financial position report.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ Hardcoded year-2000 start → FinancePeriod.GetCumulativeRange
///  ✓ Duplicated DataRow copy ×5 → extracted CopyRow helper
///  ✓ No error handling → try/catch + FinanceLogger.LogError
///  ✓ No audit trail → FinanceLogger.LogReportGenerated
/// </summary>
public partial class COOPERP_NewScreens_BalanceSheet : System.Web.UI.Page
{
    private const string PAGE_NAME = "BalanceSheet";
    private decimal _totalAssets = 0;
    private decimal _totalLiabilities = 0;
    private decimal _totalEquity = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAsAtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        LoadBalanceSheet();
    }

    private void LoadBalanceSheet()
    {
        pnlError.Visible = false;
        pnlReport.Visible = false;
        _totalAssets = 0;
        _totalLiabilities = 0;
        _totalEquity = 0;
        try
        {
            DateTime asAtDate;
            if (!DateTime.TryParse(txtAsAtDate.Text, out asAtDate))
                asAtDate = DateTime.Today;

            // Use earliest financial period start rather than hardcoded year-2000
            DateTime startDate = FinancePeriod.GetCumulativeRange().Item1;

            DataTable dt = FinanceDB.ExecuteSP("fin_BalanceSheet",
                FinanceDB.P("@sDate", startDate.ToString("yyyy-MM-dd")),
                FinanceDB.P("@eDate", asAtDate.ToString("yyyy-MM-dd")));

            if (dt == null || !dt.Columns.Contains("DRBalance") || !dt.Columns.Contains("CRBalance"))
            {
                ShowError("The Balance Sheet data source returned an unexpected format. Please contact ICT support.");
                return;
            }

            // Guarantee the display columns exist so data-binding never throws.
            EnsureColumn(dt, "accountcode");
            EnsureColumn(dt, "accountname");

            string docHeader = (dt.Rows.Count > 0 && dt.Columns.Contains("docHeader"))
                ? dt.Rows[0]["docHeader"].ToString() : "";

            // Separate into Assets, Liabilities, Equity
            DataTable dtAssets = dt.Clone();
            DataTable dtLiabilities = dt.Clone();
            DataTable dtEquity = dt.Clone();

            EnsureAmountColumn(dtAssets);
            EnsureAmountColumn(dtLiabilities);
            EnsureAmountColumn(dtEquity);

            foreach (DataRow row in dt.Rows)
            {
                if (IsTotalRow(row)) continue; // skip SP grand-total row
                string header = dt.Columns.Contains("header") ? row["header"].ToString().ToLower() : "";
                decimal dr = 0, cr = 0;
                decimal.TryParse(row["DRBalance"].ToString(), out dr);
                decimal.TryParse(row["CRBalance"].ToString(), out cr);

                if (header.Contains("asset"))
                {
                    CopyRow(dtAssets, row, dt, dr - cr);
                    _totalAssets += (dr - cr);
                }
                else if (header.Contains("liabilit"))
                {
                    CopyRow(dtLiabilities, row, dt, cr - dr);
                    _totalLiabilities += (cr - dr);
                }
                else if (header.Contains("equity") || header.Contains("capital") || header.Contains("retained"))
                {
                    CopyRow(dtEquity, row, dt, cr - dr);
                    _totalEquity += (cr - dr);
                }
                else
                {
                    // Fallback: DR balance = Asset, CR balance = Liability
                    if (dr >= cr)
                    {
                        CopyRow(dtAssets, row, dt, dr - cr);
                        _totalAssets += (dr - cr);
                    }
                    else
                    {
                        CopyRow(dtLiabilities, row, dt, cr - dr);
                        _totalLiabilities += (cr - dr);
                    }
                }
            }

            rptAssets.DataSource = dtAssets;
            rptAssets.DataBind();
            rptLiabilities.DataSource = dtLiabilities;
            rptLiabilities.DataBind();
            rptEquity.DataSource = dtEquity;
            rptEquity.DataBind();

            // Header info
            litDocHeader.Text = docHeader;
            litAsAtDate.Text = asAtDate.ToString("dd MMM yyyy");
            litGenDate.Text = DateTime.Now.ToString("dd MMM yyyy HH:mm");

            // Equation bar & stats
            litEqAssets.Text = _totalAssets.ToString("N2");
            litEqLiabilities.Text = _totalLiabilities.ToString("N2");
            litEqEquity.Text = _totalEquity.ToString("N2");
            litStatAssets.Text = _totalAssets.ToString("N2");
            litStatLiab.Text = _totalLiabilities.ToString("N2");
            litStatEquity.Text = _totalEquity.ToString("N2");

            // Balance check: Assets = Liabilities + Equity
            decimal diff = Math.Abs(_totalAssets - (_totalLiabilities + _totalEquity));
            if (diff < 0.01m)
            {
                pnlBalanceStatus.CssClass = "ft-status ft-status--ok";
                litBalanceStatus.Text = "&#10004; Balance Sheet is BALANCED &mdash; Assets = Liabilities + Equity.";
                litStatBalance.Text = "Balanced";
                litBalIcon.Text = "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='#16a34a' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'/><polyline points='22 4 12 14.01 9 11.01'/></svg>";
            }
            else
            {
                pnlBalanceStatus.CssClass = "ft-status ft-status--err";
                litBalanceStatus.Text = "&#9888; UNBALANCED &mdash; Difference of " + diff.ToString("N2");
                litStatBalance.Text = "Off by " + diff.ToString("N2");
                litBalIcon.Text = "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='#dc3545' stroke-width='2'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>";
            }

            pnlReport.Visible = true;
            FinanceLogger.LogReportGenerated(PAGE_NAME, "AsAt=" + asAtDate.ToString("yyyy-MM-dd") +
                " Assets=" + _totalAssets.ToString("N2") + " L+E=" + (_totalLiabilities + _totalEquity).ToString("N2"));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadBalanceSheet", ex);
            ShowError("The Balance Sheet could not be generated: " + ex.Message);
        }
    }

    private void ShowError(string message)
    {
        pnlReport.Visible = false;
        pnlError.Visible = true;
        litError.Text = "&#9888; " + Server.HtmlEncode(message);
    }

    private static void EnsureColumn(DataTable dt, string name)
    {
        if (dt != null && !dt.Columns.Contains(name))
            dt.Columns.Add(name, typeof(string));
    }

    /// <summary>True for a stored-procedure grand-total / summary row.</summary>
    private static bool IsTotalRow(DataRow row)
    {
        if (!row.Table.Columns.Contains("accountcode")) return false;
        string code = System.Convert.ToString(row["accountcode"]).Trim();
        return string.Equals(code, "TOTALS", StringComparison.OrdinalIgnoreCase)
            || string.Equals(code, "TOTAL",  StringComparison.OrdinalIgnoreCase)
            || string.Equals(code, "GRAND TOTAL", StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>Ensures the cloned table has an Amount column.</summary>
    private static void EnsureAmountColumn(DataTable dt)
    {
        if (!dt.Columns.Contains("Amount"))
            dt.Columns.Add("Amount", typeof(decimal));
    }

    /// <summary>Copies a DataRow into target table with computed Amount — eliminates ×5 duplication.</summary>
    private static void CopyRow(DataTable target, DataRow source, DataTable sourceTable, decimal amount)
    {
        DataRow nr = target.NewRow();
        foreach (DataColumn col in sourceTable.Columns)
            nr[col.ColumnName] = source[col.ColumnName];
        nr["Amount"] = amount;
        target.Rows.Add(nr);
    }

    protected void rptAssets_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalAssets") as Literal;
            if (lit != null) lit.Text = _totalAssets.ToString("N2");
        }
    }

    protected void rptLiabilities_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalLiabilities") as Literal;
            if (lit != null) lit.Text = _totalLiabilities.ToString("N2");
        }
    }

    protected void rptEquity_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalEquity") as Literal;
            if (lit != null) lit.Text = _totalEquity.ToString("N2");
        }
    }
}
