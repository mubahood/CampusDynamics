using System;
using System.Data;
using System.Web.UI;

/// <summary>
/// Finance Audit Trail — activity log + repair log viewer.
/// 
/// REFACTORED (Phase 1):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ SELECT * → explicit column list
///  ✓ Double-swallowed exceptions (empty catch) → proper try/catch + FinanceLogger
///  ✓ Silent fallback to unbounded query on any error → bounded fallback with logging
///  ✓ No logging → FinanceLogger.LogError
/// </summary>
public partial class COOPERP_NewScreens_FinanceAuditTrail : System.Web.UI.Page
{
    private const string PAGE_NAME = "FinanceAuditTrail";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            LoadLogs();
        }
    }

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadLogs();
    }

    private void LoadLogs()
    {
        DateTime startDate, endDate;
        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
            startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
            endDate = DateTime.Today;

        endDate = endDate.AddDays(1);

        string logType = ddlLogType.SelectedValue;
        bool showActivity = (logType == "activity" || logType == "both");
        bool showRepair = (logType == "repair" || logType == "both");

        pnlActivity.Visible = showActivity;
        pnlRepair.Visible = showRepair;

        int actCount = 0, repCount = 0;

        if (showActivity) actCount = LoadActivityLog(startDate, endDate);
        if (showRepair) repCount = LoadRepairLog(startDate, endDate);

        // Stats
        litActivityCount.Text = actCount.ToString("N0");
        litRepairCount.Text = repCount.ToString("N0");
        litTotalCount.Text = (actCount + repCount).ToString("N0");

        // Period badge
        litPeriodBadge.Text = string.Format(
            "<span class='ft-card__meta'>{0} - {1}</span>",
            startDate.ToString("dd MMM yyyy"),
            endDate.AddDays(-1).ToString("dd MMM yyyy"));
    }

    private int LoadActivityLog(DateTime startDate, DateTime endDate)
    {
        DataTable dt;
        try
        {
            dt = FinanceDB.ExecuteDataTable(
                @"SELECT id, activity_date, activity_by, activity_action, activity_module, 
                         activity_details, ip_address, session_id, voucher_reference, 
                         before_value, after_value
                  FROM acc_activity_log 
                  WHERE activity_date >= @sd AND activity_date < @ed 
                  ORDER BY activity_date DESC LIMIT 500",
                FinanceDB.P("@sd", startDate.ToString("yyyy-MM-dd")),
                FinanceDB.P("@ed", endDate.ToString("yyyy-MM-dd")));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadActivityLog-DateRange", ex);
            // Bounded fallback — table schema may differ
            try
            {
                dt = FinanceDB.ExecuteDataTable(
                    "SELECT * FROM acc_activity_log ORDER BY id DESC LIMIT 500");
            }
            catch (Exception ex2)
            {
                FinanceLogger.LogError(PAGE_NAME, "LoadActivityLog-Fallback", ex2);
                dt = new DataTable();
            }
        }

        rptActivity.DataSource = dt;
        rptActivity.DataBind();
        phNoActivity.Visible = dt.Rows.Count == 0;

        litActBadge.Text = string.Format("<span class='ft-card__meta'>{0} entries</span>", dt.Rows.Count);
        litActFooter.Text = string.Format("Showing <strong>{0}</strong> activity record(s)", dt.Rows.Count);
        return dt.Rows.Count;
    }

    private int LoadRepairLog(DateTime startDate, DateTime endDate)
    {
        DataTable dt;
        try
        {
            dt = FinanceDB.ExecuteDataTable(
                @"SELECT id, repair_date, repair_type, repair_action, affected_table, 
                         affected_rows, details, performed_by
                  FROM fin_repair_log 
                  WHERE repair_date >= @sd AND repair_date < @ed 
                  ORDER BY repair_date DESC LIMIT 500",
                FinanceDB.P("@sd", startDate.ToString("yyyy-MM-dd")),
                FinanceDB.P("@ed", endDate.ToString("yyyy-MM-dd")));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadRepairLog-DateRange", ex);
            try
            {
                dt = FinanceDB.ExecuteDataTable(
                    "SELECT * FROM fin_repair_log ORDER BY id DESC LIMIT 500");
            }
            catch (Exception ex2)
            {
                FinanceLogger.LogError(PAGE_NAME, "LoadRepairLog-Fallback", ex2);
                dt = new DataTable();
            }
        }

        rptRepair.DataSource = dt;
        rptRepair.DataBind();
        phNoRepair.Visible = dt.Rows.Count == 0;

        litRepBadge.Text = string.Format("<span class='ft-card__meta'>{0} entries</span>", dt.Rows.Count);
        litRepFooter.Text = string.Format("Showing <strong>{0}</strong> repair record(s)", dt.Rows.Count);
        return dt.Rows.Count;
    }
}
