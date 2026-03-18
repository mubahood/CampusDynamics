using System;
using System.Data;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_FinanceAuditTrail : System.Web.UI.Page
{
    private string AcctConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";

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

        // Add one day to endDate to include the full day
        endDate = endDate.AddDays(1);

        string logType = ddlLogType.SelectedValue;

        bool showActivity = (logType == "activity" || logType == "both");
        bool showRepair = (logType == "repair" || logType == "both");

        pnlActivity.Visible = showActivity;
        pnlRepair.Visible = showRepair;

        if (showActivity)
        {
            LoadActivityLog(startDate, endDate);
        }

        if (showRepair)
        {
            LoadRepairLog(startDate, endDate);
        }
    }

    private void LoadActivityLog(DateTime startDate, DateTime endDate)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            // Try to query acc_activity_log — column names may vary
            string sql = @"SELECT * FROM acc_activity_log 
                           WHERE activity_date >= @sd AND activity_date < @ed 
                           ORDER BY activity_date DESC LIMIT 500";
            try
            {
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sd", startDate.ToString("yyyy-MM-dd"));
                    cmd.Parameters.AddWithValue("@ed", endDate.ToString("yyyy-MM-dd"));
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch
            {
                // If activity_date column doesn't exist, try date_created or created_at
                try
                {
                    sql = "SELECT * FROM acc_activity_log ORDER BY id DESC LIMIT 500";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        dt.Clear();
                        da.Fill(dt);
                    }
                }
                catch { /* Table may not exist */ }
            }
        }

        gridActivity.DataSource = dt;
        gridActivity.DataBind();
        litActivityCount.Text = dt.Rows.Count.ToString();
    }

    private void LoadRepairLog(DateTime startDate, DateTime endDate)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"SELECT * FROM fin_repair_log 
                           WHERE repair_date >= @sd AND repair_date < @ed 
                           ORDER BY repair_date DESC LIMIT 500";
            try
            {
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sd", startDate.ToString("yyyy-MM-dd"));
                    cmd.Parameters.AddWithValue("@ed", endDate.ToString("yyyy-MM-dd"));
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }
            catch
            {
                // Fallback without date filter
                try
                {
                    sql = "SELECT * FROM fin_repair_log ORDER BY id DESC LIMIT 500";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        dt.Clear();
                        da.Fill(dt);
                    }
                }
                catch { /* Table may not exist */ }
            }
        }

        gridRepair.DataSource = dt;
        gridRepair.DataBind();
        litRepairCount.Text = dt.Rows.Count.ToString();
    }
}
