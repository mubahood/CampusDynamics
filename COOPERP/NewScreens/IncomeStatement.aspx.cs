using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Income Statement — Revenue vs Expense for a date range.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ Calendar-year default → FinancePeriod.GetDefaultDateRange
///  ✓ Duplicated DataRow copy → extracted CopyRow helper
///  ✓ No error handling → try/catch + FinanceLogger.LogError
///  ✓ No audit trail → FinanceLogger.LogReportGenerated
/// </summary>
public partial class COOPERP_NewScreens_IncomeStatement : System.Web.UI.Page
{
    private const string PAGE_NAME = "IncomeStatement";
    private decimal _totalIncome = 0;
    private decimal _totalExpense = 0;

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
        LoadIncomeStatement();
    }

    private void LoadIncomeStatement()
    {
        pnlError.Visible = false;
        pnlReport.Visible = false;
        _totalIncome = 0;
        _totalExpense = 0;
        try
        {
            DateTime startDate, endDate;
            if (!DateTime.TryParse(txtStartDate.Text, out startDate))
                startDate = new DateTime(DateTime.Today.Year, 1, 1);
            if (!DateTime.TryParse(txtEndDate.Text, out endDate))
                endDate = DateTime.Today;
            if (endDate < startDate)
            {
                ShowError("The end date cannot be earlier than the start date.");
                return;
            }

            DataTable dt = FinanceDB.ExecuteSP("fin_IncomeStatement",
                FinanceDB.P("@sDate", startDate.ToString("yyyy-MM-dd")),
                FinanceDB.P("@eDate", endDate.ToString("yyyy-MM-dd")));

            if (dt == null || !dt.Columns.Contains("DRBalance") || !dt.Columns.Contains("CRBalance"))
            {
                ShowError("The Income Statement data source returned an unexpected format. Please contact ICT support.");
                return;
            }

            // Guarantee the display columns exist so data-binding never throws.
            EnsureColumn(dt, "accountcode");
            EnsureColumn(dt, "accountname");

            string docHeader = (dt.Rows.Count > 0 && dt.Columns.Contains("docHeader"))
                ? dt.Rows[0]["docHeader"].ToString() : "";

            DataTable dtIncome = dt.Clone();
            DataTable dtExpense = dt.Clone();
            EnsureAmountColumn(dtIncome);
            EnsureAmountColumn(dtExpense);

            foreach (DataRow row in dt.Rows)
            {
                if (IsTotalRow(row)) continue; // skip SP grand-total row
                string header = dt.Columns.Contains("header") ? row["header"].ToString().ToLower() : "";
                decimal dr = 0, cr = 0;
                decimal.TryParse(row["DRBalance"].ToString(), out dr);
                decimal.TryParse(row["CRBalance"].ToString(), out cr);

                if (header.Contains("income") || header.Contains("revenue"))
                {
                    CopyRow(dtIncome, row, dt, cr - dr);
                    _totalIncome += (cr - dr);
                }
                else if (header.Contains("expense") || header.Contains("cost"))
                {
                    CopyRow(dtExpense, row, dt, dr - cr);
                    _totalExpense += (dr - cr);
                }
                else
                {
                    // Default: DR > CR = expense, otherwise income
                    if (dr > cr)
                    {
                        CopyRow(dtExpense, row, dt, dr - cr);
                        _totalExpense += (dr - cr);
                    }
                    else
                    {
                        CopyRow(dtIncome, row, dt, cr - dr);
                        _totalIncome += (cr - dr);
                    }
                }
            }

            rptIncome.DataSource = dtIncome;
            rptIncome.DataBind();
            rptExpense.DataSource = dtExpense;
            rptExpense.DataBind();

            // Header literals
            litDocHeader.Text = docHeader;
            litPeriodStart.Text = startDate.ToString("dd MMM yyyy");
            litPeriodEnd.Text = endDate.ToString("dd MMM yyyy");
            litGenDate.Text = DateTime.Now.ToString("dd MMM yyyy HH:mm");

            // Net income
            decimal netIncome = _totalIncome - _totalExpense;
            string netClass = netIncome >= 0 ? "ft-net-positive" : "ft-net-negative";
            litNetIncome.Text = "<span class='" + netClass + "'>" + netIncome.ToString("N2") + "</span>";

            // Stats row
            litSumIncome.Text = _totalIncome.ToString("N2");
            litSumExpense.Text = _totalExpense.ToString("N2");
            litSumNet.Text = netIncome.ToString("N2");
            spanNetResult.Attributes["style"] = netIncome >= 0 ? "color:#16a34a" : "color:#dc3545";

            // Totals bar
            litBarIncome.Text = _totalIncome.ToString("N2");
            litBarExpense.Text = _totalExpense.ToString("N2");
            litBarNet.Text = netIncome.ToString("N2");

            pnlReport.Visible = true;
            FinanceLogger.LogReportGenerated(PAGE_NAME, startDate.ToString("yyyy-MM-dd") + " to " +
                endDate.ToString("yyyy-MM-dd") + " Net=" + netIncome.ToString("N2"));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadIncomeStatement", ex);
            ShowError("The Income Statement could not be generated: " + ex.Message);
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

    private static void EnsureAmountColumn(DataTable dt)
    {
        if (!dt.Columns.Contains("Amount"))
            dt.Columns.Add("Amount", typeof(decimal));
    }

    private static void CopyRow(DataTable target, DataRow source, DataTable sourceTable, decimal amount)
    {
        DataRow nr = target.NewRow();
        foreach (DataColumn col in sourceTable.Columns)
            nr[col.ColumnName] = source[col.ColumnName];
        nr["Amount"] = amount;
        target.Rows.Add(nr);
    }

    protected void rptIncome_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalIncome") as Literal;
            if (lit != null) lit.Text = _totalIncome.ToString("N2");
        }
    }

    protected void rptExpense_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Footer)
        {
            Literal lit = e.Item.FindControl("litTotalExpense") as Literal;
            if (lit != null) lit.Text = _totalExpense.ToString("N2");
        }
    }
}
