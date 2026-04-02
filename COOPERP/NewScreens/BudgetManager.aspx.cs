using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Budget Manager — Plan, track and control departmental budgets.
/// 
/// NEW FEATURE (Phase 2):
///  ✓ Full CRUD for budget line items per financial year
///  ✓ Initialize budget from chart of accounts using existing SP fin_CreateBudget
///  ✓ KPI summary (planned / actual / variance)
///  ✓ Utilization bar per item
///  ✓ CSV export
///  ✓ Category filter (Income / Expenditure)
///  ✓ Year selector from financial periods
///  ✓ Uses FinanceDB, FinancePeriod, MoneyHelper, AccountCache, FinanceLogger
/// </summary>
public partial class COOPERP_NewScreens_BudgetManager : System.Web.UI.Page
{
    private const string PAGE_NAME = "BudgetManager";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadYears();
            AccountCache.BindAccountDropDownWithSelect(ddlAccount, "-- Select Account --");
            LoadBudget();
        }
    }

    private void LoadYears()
    {
        // Populate year dropdown from financial periods + extra years
        ddlYear.Items.Clear();
        int thisYear = DateTime.Today.Year;
        for (int y = thisYear + 1; y >= thisYear - 5; y--)
            ddlYear.Items.Add(new ListItem(y.ToString(), y.ToString()));

        // Default to current financial period year if open
        var period = FinancePeriod.GetOpenPeriod();
        if (period != null)
        {
            string yr = period.EndDate.Year.ToString();
            if (ddlYear.Items.FindByValue(yr) != null)
                ddlYear.SelectedValue = yr;
        }
        else
        {
            ddlYear.SelectedValue = thisYear.ToString();
        }
    }

    private int SelectedYear
    {
        get
        {
            int yr;
            return int.TryParse(ddlYear.SelectedValue, out yr) ? yr : DateTime.Today.Year;
        }
    }

    private string SelectedCategory
    {
        get { return ddlCategory.SelectedValue; }
    }

    protected void ddlYear_Changed(object sender, EventArgs e)
    {
        LoadBudget();
    }

    protected void ddlCategory_Changed(object sender, EventArgs e)
    {
        LoadBudget();
    }

    private void LoadBudget()
    {
        try
        {
            int year = SelectedYear;
            string cat = SelectedCategory;

            string sql = "SELECT ID, item_code, details, planned_amount, actual_amount, vote_status, item_category " +
                         "FROM fin_budget WHERE budget_year = @yr";
            if (!string.IsNullOrEmpty(cat))
                sql += " AND item_category = @cat";
            sql += " ORDER BY item_category, item_code";

            DataTable dt;
            if (!string.IsNullOrEmpty(cat))
                dt = FinanceDB.ExecuteDataTable(sql, FinanceDB.P("@yr", year), FinanceDB.P("@cat", cat));
            else
                dt = FinanceDB.ExecuteDataTable(sql, FinanceDB.P("@yr", year));

            rptBudget.DataSource = dt;
            rptBudget.DataBind();

            // Compute KPIs
            decimal totalPlanned = 0, totalActual = 0;
            foreach (DataRow row in dt.Rows)
            {
                totalPlanned += MoneyHelper.ToDecimal(row["planned_amount"]);
                totalActual += MoneyHelper.ToDecimal(row["actual_amount"]);
            }
            decimal variance = totalPlanned - totalActual;

            litPlanned.Text = MoneyHelper.FormatNumber(totalPlanned);
            litActual.Text = MoneyHelper.FormatNumber(totalActual);
            litVariance.Text = MoneyHelper.FormatNumber(variance);
            litItemCount.Text = dt.Rows.Count.ToString("N0");

            litTotalPlanned.Text = totalPlanned.ToString("N0");
            litTotalActual.Text = totalActual.ToString("N0");
            litTotalVariance.Text = variance.ToString("N0");

            litBadge.Text = string.Format("<span class='ft-card__meta'>{0} items &bull; FY {1}</span>", dt.Rows.Count, year);
            litFooter.Text = string.Format("Showing <strong>{0}</strong> budget item(s) for {1}", dt.Rows.Count, year);

            // Period badge
            litPeriodBadge.Text = string.Format(
                "<span style='background:rgba(255,255,255,.15);padding:4px 10px;font-size:10px;border-radius:3px;'>FY {0}</span>", year);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadBudget", ex);
            ShowMessage("Error loading budget: " + ex.Message, false);
        }
    }

    protected void btnInitBudget_Click(object sender, EventArgs e)
    {
        try
        {
            int year = SelectedYear;

            // Check if budget already exists for this year
            int existing = FinanceDB.ExecuteScalar<int>(
                "SELECT COUNT(*) FROM fin_budget WHERE budget_year = @yr",
                FinanceDB.P("@yr", year));

            if (existing > 0)
            {
                ShowMessage("Budget for " + year + " already has " + existing + " items. To reinitialize, delete existing items first.", false);
                return;
            }

            // Call existing SP — creates budget items from chart of accounts
            FinanceDB.ExecuteNonQuerySP("fin_CreateBudget",
                FinanceDB.P("@yr", year),
                FinanceDB.P("@cat", ddlCategory.SelectedValue == "" ? "ALL" : ddlCategory.SelectedValue));

            FinanceLogger.LogAction(PAGE_NAME, "InitializeBudget", "Year=" + year);
            ShowMessage("Budget initialized for " + year + ".", true);
            LoadBudget();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnInitBudget_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnSaveItem_Click(object sender, EventArgs e)
    {
        string accountCode = ddlAccount.SelectedValue;
        string details = txtDetails.Text.Trim();
        string category = ddlItemCategory.SelectedValue;
        decimal planned = MoneyHelper.ParseMoney(txtPlannedAmount.Text);
        string editId = hdnEditId.Value;

        if (string.IsNullOrEmpty(accountCode))
        {
            ShowMessage("Please select an account.", false);
            return;
        }

        try
        {
            if (string.IsNullOrEmpty(editId))
            {
                FinanceDB.ExecuteNonQuery(
                    @"INSERT INTO fin_budget (item_code, details, planned_amount, actual_amount, vote_status, item_category, budget_year)
                      VALUES (@code, @det, @planned, 0, 'Normal', @cat, @yr)",
                    FinanceDB.P("@code", accountCode),
                    FinanceDB.P("@det", string.IsNullOrEmpty(details) ? accountCode : details),
                    FinanceDB.P("@planned", planned),
                    FinanceDB.P("@cat", category),
                    FinanceDB.P("@yr", SelectedYear));

                FinanceLogger.LogAction(PAGE_NAME, "AddBudgetItem",
                    "Code=" + accountCode + " Planned=" + planned + " Year=" + SelectedYear);
                ShowMessage("Budget item added.", true);
            }
            else
            {
                FinanceDB.ExecuteNonQuery(
                    "UPDATE fin_budget SET item_code=@code, details=@det, planned_amount=@planned, item_category=@cat WHERE ID=@id",
                    FinanceDB.P("@code", accountCode),
                    FinanceDB.P("@det", details),
                    FinanceDB.P("@planned", planned),
                    FinanceDB.P("@cat", category),
                    FinanceDB.P("@id", int.Parse(editId)));

                FinanceLogger.LogAction(PAGE_NAME, "UpdateBudgetItem", "ID=" + editId + " Planned=" + planned);
                ShowMessage("Budget item updated.", true);
            }

            ClearForm();
            LoadBudget();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnSaveItem_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void rptBudget_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "EditItem")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            if (parts.Length >= 5)
            {
                hdnEditId.Value = parts[0];
                if (ddlAccount.Items.FindByValue(parts[1]) != null)
                    ddlAccount.SelectedValue = parts[1];
                txtDetails.Text = parts[2];
                txtPlannedAmount.Text = parts[3];
                if (ddlItemCategory.Items.FindByValue(parts[4]) != null)
                    ddlItemCategory.SelectedValue = parts[4];
                btnSaveItem.Text = "Update Item";
                btnCancelEdit.Visible = true;
            }
        }
        else if (e.CommandName == "DeleteItem")
        {
            try
            {
                string id = e.CommandArgument.ToString();
                FinanceDB.ExecuteNonQuery("DELETE FROM fin_budget WHERE ID = @id",
                    FinanceDB.P("@id", int.Parse(id)));

                FinanceLogger.LogAction(PAGE_NAME, "DeleteBudgetItem", "ID=" + id);
                ShowMessage("Budget item deleted.", true);
                LoadBudget();
            }
            catch (Exception ex)
            {
                FinanceLogger.LogError(PAGE_NAME, "DeleteBudgetItem", ex);
                ShowMessage("Error: " + ex.Message, false);
            }
        }
    }

    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        ClearForm();
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        try
        {
            int year = SelectedYear;
            DataTable dt = FinanceDB.ExecuteDataTable(
                "SELECT item_code, details, item_category, planned_amount, actual_amount, vote_status " +
                "FROM fin_budget WHERE budget_year = @yr ORDER BY item_category, item_code",
                FinanceDB.P("@yr", year));

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition", "attachment;filename=Budget_" + year + ".csv");

            var sb = new StringBuilder();
            sb.AppendLine("Account Code,Details,Category,Planned Amount,Actual Amount,Variance,Status");
            foreach (DataRow r in dt.Rows)
            {
                decimal p = MoneyHelper.ToDecimal(r["planned_amount"]);
                decimal a = MoneyHelper.ToDecimal(r["actual_amount"]);
                sb.AppendFormat("\"{0}\",\"{1}\",\"{2}\",{3},{4},{5},\"{6}\"\r\n",
                    r["item_code"], r["details"], r["item_category"],
                    p, a, p - a, r["vote_status"]);
            }

            Response.Write(sb.ToString());
            Response.End();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnExport_Click", ex);
            ShowMessage("Export error: " + ex.Message, false);
        }
    }

    /// <summary>Renders a utilization bar for the repeater.</summary>
    protected string GetUtilBar(object plannedObj, object actualObj)
    {
        decimal planned = MoneyHelper.ToDecimal(plannedObj);
        decimal actual = MoneyHelper.ToDecimal(actualObj);
        if (planned <= 0) return "<span style='color:#999;font-size:10px;'>N/A</span>";

        double pct = (double)(actual / planned) * 100;
        if (pct > 100) pct = 100;
        string cls = pct <= 75 ? "bm-var-fill--ok" : pct <= 95 ? "bm-var-fill--warn" : "bm-var-fill--over";
        return string.Format(
            "<span style='font-size:10px;font-family:Consolas,monospace;'>{0:F0}%</span>" +
            "<span class='bm-var-bar'><span class='bm-var-fill {1}' style='width:{0:F0}%'></span></span>",
            pct, cls);
    }

    private void ClearForm()
    {
        hdnEditId.Value = "";
        txtPlannedAmount.Text = "";
        txtDetails.Text = "";
        ddlAccount.SelectedIndex = 0;
        ddlItemCategory.SelectedIndex = 0;
        btnSaveItem.Text = "+ Add Item";
        btnCancelEdit.Visible = false;
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        pnlMsg.CssClass = isSuccess ? "bm-msg bm-msg-ok" : "bm-msg bm-msg-err";
        litMsg.Text = HttpUtility.HtmlEncode(msg);
    }
}
