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
    
    private static readonly string ResultsFilter = @"page_function IN (
        'Marks Entry Portal','Marks Update','Marks Approval',
        'Results Marks Entry','Results Marks Update','Results Marks Approval',
        'Results Hold Management','Results Release','Results Update',
        'Mark Request Approve','Mark Request Reject','Mark Request Force Close',
        'Mark Request Reopen','Mark Request Marks Update','Mark Request Batch',
        'Marks Published to Results')";

    private void LoadUsers()
    {
        ddlUser.Items.Clear();
        ddlUser.Items.Add(new ListItem("All Users", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"SELECT DISTINCT user_id FROM acad_activity_log 
                              WHERE " + ResultsFilter + @" AND user_id IS NOT NULL 
                              ORDER BY user_id";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string user = reader["user_id"].ToString();
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
                string sqlTotal = @"SELECT COUNT(*) FROM acad_activity_log WHERE " + ResultsFilter;
                using (MySqlCommand cmd = new MySqlCommand(sqlTotal, conn))
                {
                    litTotalActions.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // Today's actions
                string sqlToday = @"SELECT COUNT(*) FROM acad_activity_log 
                                   WHERE " + ResultsFilter + @" AND DATE(access_date) = CURDATE()";
                using (MySqlCommand cmd = new MySqlCommand(sqlToday, conn))
                {
                    litTodayActions.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // This week's actions
                string sqlWeek = @"SELECT COUNT(*) FROM acad_activity_log 
                                  WHERE " + ResultsFilter + @" AND access_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)";
                using (MySqlCommand cmd = new MySqlCommand(sqlWeek, conn))
                {
                    litWeekActions.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // Critical actions — mark changes, rejections, force-closes, publications
                string sqlCritical = @"SELECT COUNT(*) FROM acad_activity_log
                                      WHERE " + ResultsFilter + @"
                                      AND (page_function LIKE '%Update%' OR page_function LIKE '%Approval%'
                                           OR page_function IN ('Mark Request Reject','Mark Request Force Close',
                                              'Mark Request Marks Update','Marks Published to Results'))";
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
                conditions.Add(ResultsFilter);
                
                if (dtFrom.Date != DateTime.MinValue)
                    conditions.Add("access_date >= @dateFrom");
                if (dtTo.Date != DateTime.MinValue)
                    conditions.Add("access_date <= @dateTo");
                if (!string.IsNullOrEmpty(ddlActionType.SelectedValue))
                    conditions.Add("page_function LIKE @actionType");
                if (!string.IsNullOrEmpty(ddlUser.SelectedValue))
                    conditions.Add("user_id = @user");
                if (!string.IsNullOrEmpty(txtSearch.Text))
                    conditions.Add("(comments LIKE @search OR par LIKE @search OR user_id LIKE @search)");
                
                string whereClause = "WHERE " + string.Join(" AND ", conditions.ToArray());
                
                string sql = @"SELECT 
                    logid AS ID,
                    access_date as action_date,
                    page_function as action_type,
                    user_id as performed_by,
                    'Staff' as user_role,
                    page_function as target_entity,
                    '' as programme,
                    1 as affected_records,
                    COALESCE(comments, '') as description,
                    CASE 
                        WHEN page_function LIKE '%Update%' THEN 'high'
                        WHEN page_function LIKE '%Approval%' THEN 'medium'
                        WHEN page_function LIKE '%Hold%' OR page_function LIKE '%Release%' THEN 'critical'
                        ELSE 'low'
                    END as severity,
                    COALESCE(NULLIF(TRIM(SUBSTRING_INDEX(par, 'IP Address:', -1)), ''), 'N/A') as ip_address
                FROM acad_activity_log
                " + whereClause + @"
                ORDER BY access_date DESC
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
        string action = (actionType != null) ? actionType.ToString() : "";
        string upper  = action.ToUpper();
        string cssClass = "ral-action-badge--edit";
        string displayText;

        // New mark-request actions (exact match first for precision)
        if (action == "Marks Published to Results")
        { cssClass = "ral-action-badge--release"; displayText = "PUBLISHED"; }
        else if (action == "Mark Request Approve")
        { cssClass = "ral-action-badge--approve"; displayText = "APPROVED"; }
        else if (action == "Mark Request Reject")
        { cssClass = "ral-action-badge--delete"; displayText = "REJECTED"; }
        else if (action == "Mark Request Force Close")
        { cssClass = "ral-action-badge--delete"; displayText = "FORCED"; }
        else if (action == "Mark Request Reopen")
        { cssClass = "ral-action-badge--unhold"; displayText = "REOPENED"; }
        else if (action == "Mark Request Marks Update")
        { cssClass = "ral-action-badge--edit"; displayText = "MK UPDATE"; }
        else if (action == "Mark Request Batch")
        { cssClass = "ral-action-badge--edit"; displayText = "BATCH"; }
        // Legacy / existing action types
        else if (upper.Contains("APPROVE"))
        { cssClass = "ral-action-badge--approve"; displayText = "APPROVE"; }
        else if (upper.Contains("RELEASE"))
        { cssClass = "ral-action-badge--release"; displayText = "RELEASE"; }
        else if (upper.Contains("UNHOLD"))
        { cssClass = "ral-action-badge--unhold"; displayText = "UNHOLD"; }
        else if (upper.Contains("HOLD"))
        { cssClass = "ral-action-badge--hold"; displayText = "HOLD"; }
        else if (upper.Contains("REJECT") || upper.Contains("FORCE") || upper.Contains("DELETE") || upper.Contains("REMOVE"))
        { cssClass = "ral-action-badge--delete"; displayText = "REMOVED"; }
        else if (upper.Contains("EDIT") || upper.Contains("CHANG") || upper.Contains("UPDATE"))
        { cssClass = "ral-action-badge--edit"; displayText = "EDIT"; }
        else if (upper.Contains("CREATE") || upper.Contains("INSERT") || upper.Contains("ADD"))
        { cssClass = "ral-action-badge--create"; displayText = "CREATE"; }
        else
        { displayText = action.Length > 12 ? action.Substring(0, 12) : action; }

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
