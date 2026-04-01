using System;
using System.Data;
using System.Web.UI;
using DevExpress.Web;

/// <summary>
/// Financial Periods — CRUD for financial years with open/close toggle.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ No overlap validation on add → FinancePeriod.AddPeriod (validates overlaps)
///  ✓ Non-transactional toggle (2-step update) → FinancePeriod.OpenPeriod/ClosePeriod (atomic)
///  ✓ Delete only checks Open status → FinancePeriod.DeletePeriod (checks transactions too)
///  ✓ No audit trail → FinanceLogger.LogAction on every mutation
/// </summary>
public partial class COOPERP_NewScreens_FinancialPeriods : System.Web.UI.Page
{
    private const string PAGE_NAME = "FinancialPeriods";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadPeriods();
        }
    }

    private void LoadPeriods()
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            "SELECT id, finacial_Year, start_date, end_date, status FROM fin_financial_years ORDER BY start_date DESC");
        gridPeriods.DataSource = dt;
        gridPeriods.DataBind();
    }

    protected void btnAddPeriod_Click(object sender, EventArgs e)
    {
        string finYear = txtFinYear.Text.Trim();
        string startStr = txtPeriodStart.Text.Trim();
        string endStr = txtPeriodEnd.Text.Trim();
        string status = ddlStatus.SelectedValue;

        if (string.IsNullOrEmpty(finYear) || string.IsNullOrEmpty(startStr) || string.IsNullOrEmpty(endStr))
        {
            ShowMessage("Please fill in all fields.", false);
            return;
        }

        DateTime startDate, endDate;
        if (!DateTime.TryParse(startStr, out startDate) || !DateTime.TryParse(endStr, out endDate))
        {
            ShowMessage("Invalid date format.", false);
            return;
        }

        if (endDate <= startDate)
        {
            ShowMessage("End date must be after start date.", false);
            return;
        }

        try
        {
            // AddPeriod validates overlaps; returns error message or null on success
            string error = FinancePeriod.AddPeriod(finYear, startDate, endDate, status);
            if (error != null)
            {
                ShowMessage(error, false);
                return;
            }

            FinanceLogger.LogAction(PAGE_NAME, "AddPeriod",
                "Added period '" + finYear + "' (" + startDate.ToString("yyyy-MM-dd") + " to " + endDate.ToString("yyyy-MM-dd") + ") status=" + status);

            ShowMessage("Financial period '" + finYear + "' added successfully.", true);
            txtFinYear.Text = "";
            txtPeriodStart.Text = "";
            txtPeriodEnd.Text = "";
            LoadPeriods();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnAddPeriod_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnToggle_Click(object sender, EventArgs e)
    {
        ASPxButton btn = sender as ASPxButton;
        if (btn == null) return;
        string id = btn.CommandArgument;

        try
        {
            // Get current status
            string currentStatus = FinanceDB.ExecuteScalar<string>(
                "SELECT status FROM fin_financial_years WHERE id = @id",
                FinanceDB.P("@id", id)) ?? "";

            if (currentStatus == "Open")
            {
                // Close this period
                FinancePeriod.ClosePeriod(int.Parse(id));
                FinanceLogger.LogAction(PAGE_NAME, "ClosePeriod", "Closed period id=" + id);
                ShowMessage("Period closed.", true);
            }
            else
            {
                // Open this period (atomically closes all others)
                FinancePeriod.OpenPeriod(int.Parse(id));
                FinanceLogger.LogAction(PAGE_NAME, "OpenPeriod", "Opened period id=" + id + " (others closed)");
                ShowMessage("Period opened. All other periods have been closed.", true);
            }

            LoadPeriods();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnToggle_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        ASPxButton btn = sender as ASPxButton;
        if (btn == null) return;
        string id = btn.CommandArgument;

        try
        {
            // DeletePeriod checks Open status AND existing transactions; returns error or null
            string error = FinancePeriod.DeletePeriod(int.Parse(id));
            if (error != null)
            {
                ShowMessage(error, false);
                return;
            }

            FinanceLogger.LogAction(PAGE_NAME, "DeletePeriod", "Deleted period id=" + id);
            ShowMessage("Financial period deleted.", true);
            LoadPeriods();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnDelete_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void gridPeriods_CustomButtonCallback(object sender, ASPxGridViewCustomButtonCallbackEventArgs e)
    {
        // Not used - using template buttons instead
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        pnlMsg.CssClass = isSuccess ? "fp-msg fp-msg-ok" : "fp-msg fp-msg-err";
        litMsg.Text = msg;
    }
}
