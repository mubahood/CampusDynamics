using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_ResultsAuditLog : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Set default date range (last 30 days)
            dtTo.Date = DateTime.Today;
            dtFrom.Date = DateTime.Today.AddDays(-30);
            
            LoadUsers();
            LoadProgrammes();
            LoadStats();
            BindGrid();
        }
    }
    
    #region Data Loading
    
    private void LoadUsers()
    {
        ddlUser.Items.Clear();
        ddlUser.Items.Add(new ListItem("All Users", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"SELECT DISTINCT performed_by FROM acad_activity_log 
                              WHERE module LIKE '%Result%' AND performed_by IS NOT NULL 
                              ORDER BY performed_by";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string user = reader["performed_by"].ToString();
                            if (!string.IsNullOrEmpty(user))
                                ddlUser.Items.Add(new ListItem(user, user));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("All Programmes", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT progcode, progname FROM acad_programme ORDER BY progname";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlProgramme.Items.Add(new ListItem(reader["progname"].ToString(), reader["progcode"].ToString()));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadStats()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Total actions
                string sqlTotal = @"SELECT COUNT(*) FROM acad_activity_log WHERE module LIKE '%Result%'";
                using (MySqlCommand cmd = new MySqlCommand(sqlTotal, conn))
                {
                    litTotalActions.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // Today's actions
                string sqlToday = @"SELECT COUNT(*) FROM acad_activity_log 
                                   WHERE module LIKE '%Result%' AND DATE(log_date) = CURDATE()";
                using (MySqlCommand cmd = new MySqlCommand(sqlToday, conn))
                {
                    litTodayActions.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // This week's actions
                string sqlWeek = @"SELECT COUNT(*) FROM acad_activity_log 
                                  WHERE module LIKE '%Result%' AND log_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
                using (MySqlCommand cmd = new MySqlCommand(sqlWeek, conn))
                {
                    litWeekActions.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // Critical actions (mark changes, deletions)
                string sqlCritical = @"SELECT COUNT(*) FROM acad_activity_log 
                                      WHERE module LIKE '%Result%' 
                                      AND (action_type LIKE '%Delete%' OR action_type LIKE '%Changed%' OR action_type LIKE '%Edit%')";
                using (MySqlCommand cmd = new MySqlCommand(sqlCritical, conn))
                {
                    litCriticalActions.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
            }
        }
        catch { }
    }
    
    #endregion
    
    #region Grid Binding
    
    private void BindGrid()
    {
        DataTable dt = CreateEmptyTable();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<string> conditions = new List<string>();
                conditions.Add("module LIKE '%Result%'");
                
                if (dtFrom.Date != DateTime.MinValue)
                    conditions.Add("log_date >= @dateFrom");
                if (dtTo.Date != DateTime.MinValue)
                    conditions.Add("log_date <= @dateTo");
                if (!string.IsNullOrEmpty(ddlActionType.SelectedValue))
                    conditions.Add("action_type LIKE @actionType");
                if (!string.IsNullOrEmpty(ddlUser.SelectedValue))
                    conditions.Add("performed_by = @user");
                if (!string.IsNullOrEmpty(txtSearch.Text))
                    conditions.Add("(description LIKE @search OR target_entity LIKE @search)");
                
                string whereClause = "WHERE " + string.Join(" AND ", conditions.ToArray());
                
                string sql = @"SELECT 
                    ID,
                    log_date as action_date,
                    action_type,
                    performed_by,
                    'Staff' as user_role,
                    COALESCE(target_entity, module) as target_entity,
                    '' as programme,
                    1 as affected_records,
                    description,
                    CASE 
                        WHEN action_type LIKE '%Delete%' THEN 'critical'
                        WHEN action_type LIKE '%Changed%' OR action_type LIKE '%Edit%' THEN 'high'
                        WHEN action_type LIKE '%Approve%' THEN 'medium'
                        ELSE 'low'
                    END as severity,
                    COALESCE(ip_address, 'N/A') as ip_address
                FROM acad_activity_log
                " + whereClause + @"
                ORDER BY log_date DESC
                LIMIT 1000";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (dtFrom.Date != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@dateFrom", dtFrom.Date);
                    if (dtTo.Date != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@dateTo", dtTo.Date.AddDays(1));
                    if (!string.IsNullOrEmpty(ddlActionType.SelectedValue))
                        cmd.Parameters.AddWithValue("@actionType", "%" + ddlActionType.SelectedValue + "%");
                    if (!string.IsNullOrEmpty(ddlUser.SelectedValue))
                        cmd.Parameters.AddWithValue("@user", ddlUser.SelectedValue);
                    if (!string.IsNullOrEmpty(txtSearch.Text))
                        cmd.Parameters.AddWithValue("@search", "%" + txtSearch.Text + "%");
                    
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading audit log: " + ex.Message, "error");
        }
        
        gvAuditLog.DataSource = dt;
        gvAuditLog.DataBind();
    }
    
    private DataTable CreateEmptyTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ID", typeof(int));
        dt.Columns.Add("action_date", typeof(DateTime));
        dt.Columns.Add("action_type", typeof(string));
        dt.Columns.Add("performed_by", typeof(string));
        dt.Columns.Add("user_role", typeof(string));
        dt.Columns.Add("target_entity", typeof(string));
        dt.Columns.Add("programme", typeof(string));
        dt.Columns.Add("affected_records", typeof(int));
        dt.Columns.Add("description", typeof(string));
        dt.Columns.Add("severity", typeof(string));
        dt.Columns.Add("ip_address", typeof(string));
        return dt;
    }
    
    #endregion
    
    #region Helper Methods
    
    protected string GetActionBadge(object actionType)
    {
        string action = (actionType != null) ? actionType.ToString().ToUpper() : "";
        string cssClass = "ral-action-badge--edit";
        string displayText = action;
        
        if (action.Contains("APPROVE"))
        {
            cssClass = "ral-action-badge--approve";
            displayText = "APPROVE";
        }
        else if (action.Contains("RELEASE"))
        {
            cssClass = "ral-action-badge--release";
            displayText = "RELEASE";
        }
        else if (action.Contains("HOLD") && !action.Contains("UNHOLD"))
        {
            cssClass = "ral-action-badge--hold";
            displayText = "HOLD";
        }
        else if (action.Contains("UNHOLD"))
        {
            cssClass = "ral-action-badge--unhold";
            displayText = "UNHOLD";
        }
        else if (action.Contains("EDIT") || action.Contains("CHANG") || action.Contains("UPDATE"))
        {
            cssClass = "ral-action-badge--edit";
            displayText = "EDIT";
        }
        else if (action.Contains("CREATE") || action.Contains("INSERT") || action.Contains("ADD"))
        {
            cssClass = "ral-action-badge--create";
            displayText = "CREATE";
        }
        else if (action.Contains("DELETE") || action.Contains("REMOVE"))
        {
            cssClass = "ral-action-badge--delete";
            displayText = "DELETE";
        }
        
        return string.Format("<span class=\"ral-action-badge {0}\">{1}</span>", cssClass, displayText);
    }
    
    protected string GetSeverityIndicator(object severity)
    {
        string sev = (severity != null) ? severity.ToString().ToLower() : "low";
        string displayText = char.ToUpper(sev[0]) + sev.Substring(1);
        return string.Format("<div class=\"ral-severity ral-severity--{0}\"><span class=\"ral-severity__dot\"></span>{1}</div>", sev, displayText);
    }
    
    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "ral-message ral-message--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }
    
    #endregion
    
    #region Event Handlers
    
    protected void btnFilter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    protected void btnClearFilter_Click(object sender, EventArgs e)
    {
        dtFrom.Date = DateTime.Today.AddDays(-30);
        dtTo.Date = DateTime.Today;
        ddlActionType.SelectedIndex = 0;
        ddlUser.SelectedIndex = 0;
        ddlProgramme.SelectedIndex = 0;
        txtSearch.Text = "";
        BindGrid();
    }
    
    protected void btnExport_Click(object sender, EventArgs e)
    {
        string fileName = string.Format("ResultsAuditLog_{0}", DateTime.Now.ToString("yyyyMMdd_HHmm"));
        gvExporter.WriteXlsToResponse(fileName);
    }
    
    #endregion
}
