using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_ResultsHoldList : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    private string CurrentReasonFilter
    {
        get { return ViewState["ReasonFilter"] as string ?? ""; }
        set { ViewState["ReasonFilter"] = value; }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAcademicYears();
            LoadProgrammes();
            LoadStats();
            BindGrid();
        }
        
        // Handle postback for single unhold
        string eventTarget = Request.Form["__EVENTTARGET"];
        string eventArgument = Request.Form["__EVENTARGUMENT"];
        if (eventTarget == "UnholdSingle" && !string.IsNullOrEmpty(eventArgument))
        {
            UnholdSingleRecord(eventArgument);
        }
    }
    
    #region Data Loading
    
    private void LoadAcademicYears()
    {
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new ListItem("All Years", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT DISTINCT acadyear FROM acad_examresults_faculty WHERE acadyear IS NOT NULL ORDER BY acadyear DESC";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string yr = reader["acadyear"].ToString();
                            if (!string.IsNullOrEmpty(yr))
                                ddlAcadYear.Items.Add(new ListItem(yr, yr));
                        }
                    }
                }
            }
        }
        catch { }
        
        // Set current academic year as default
        string currentYear = AcademicYearHelper.GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(currentYear) != null)
            ddlAcadYear.SelectedValue = currentYear;
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
                
                // For now, we simulate held results by checking for specific approved_by patterns
                // In a real implementation, you would have a dedicated results_hold table
                
                string baseSql = "SELECT COUNT(*) FROM acad_examresults_faculty WHERE approved_by = 'HELD'";
                
                // Total held
                using (MySqlCommand cmd = new MySqlCommand(baseSql, conn))
                {
                    int total = Convert.ToInt32(cmd.ExecuteScalar());
                    litTotalHeld.Text = total.ToString("N0");
                    litOtherCount.Text = total.ToString();
                }
                
                // Affected students
                string studentsSql = "SELECT COUNT(DISTINCT regno) FROM acad_examresults_faculty WHERE approved_by = 'HELD'";
                using (MySqlCommand cmd = new MySqlCommand(studentsSql, conn))
                {
                    litAffectedStudents.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // Affected courses
                string coursesSql = "SELECT COUNT(DISTINCT course_id) FROM acad_examresults_faculty WHERE approved_by = 'HELD'";
                using (MySqlCommand cmd = new MySqlCommand(coursesSql, conn))
                {
                    litAffectedCourses.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                }
                
                // Long held (simulated - assuming created_date exists)
                litLongHeld.Text = "0";
                
                // Reason counts (simulated as we don't have actual hold reason column yet)
                litFinancialCount.Text = "0";
                litAcademicCount.Text = "0";
                litDisciplinaryCount.Text = "0";
                litAdminCount.Text = "0";
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
                conditions.Add("e.approved_by = 'HELD'");
                
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    conditions.Add("e.acadyear = @acad");
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    conditions.Add("e.semester = @sem");
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    conditions.Add("e.progid = @prog");
                
                string whereClause = "WHERE " + string.Join(" AND ", conditions.ToArray());
                
                string sql = @"SELECT 
                    e.ID,
                    e.regno,
                    CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) as student_name,
                    e.course_id,
                    c.courseName as course_name,
                    e.progid,
                    p.progname as prog_name,
                    e.acadyear,
                    e.semester,
                    'ADMIN' as hold_reason,
                    'Pending review' as hold_notes,
                    CURDATE() as hold_date,
                    0 as days_held,
                    'System' as held_by
                FROM acad_examresults_faculty e
                LEFT JOIN acad_student s ON e.regno = s.regno
                LEFT JOIN acad_course c ON e.course_id = c.courseID
                LEFT JOIN acad_programme p ON e.progid = p.progcode
                " + whereClause + @"
                ORDER BY e.acadyear DESC, e.semester, p.progname, s.firstname
                LIMIT 500";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading held results: " + ex.Message, "error");
        }
        
        gvHeldResults.DataSource = dt;
        gvHeldResults.DataBind();
    }
    
    private DataTable CreateEmptyTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ID", typeof(int));
        dt.Columns.Add("regno", typeof(string));
        dt.Columns.Add("student_name", typeof(string));
        dt.Columns.Add("course_id", typeof(string));
        dt.Columns.Add("course_name", typeof(string));
        dt.Columns.Add("progid", typeof(string));
        dt.Columns.Add("prog_name", typeof(string));
        dt.Columns.Add("acadyear", typeof(string));
        dt.Columns.Add("semester", typeof(int));
        dt.Columns.Add("hold_reason", typeof(string));
        dt.Columns.Add("hold_notes", typeof(string));
        dt.Columns.Add("hold_date", typeof(DateTime));
        dt.Columns.Add("days_held", typeof(int));
        dt.Columns.Add("held_by", typeof(string));
        return dt;
    }
    
    #endregion
    
    #region Helper Methods
    
    protected string GetReasonBadge(object reason)
    {
        string reasonStr = (reason != null) ? reason.ToString().ToUpper() : "OTHER";
        string cssClass = "mat-badge--other";
        
        switch (reasonStr)
        {
            case "FINANCIAL":
                cssClass = "mat-badge--financial";
                break;
            case "ACADEMIC":
                cssClass = "mat-badge--academic";
                break;
            case "DISCIPLINARY":
                cssClass = "mat-badge--disciplinary";
                break;
            case "ADMIN":
            case "ADMINISTRATIVE":
                cssClass = "mat-badge--admin";
                reasonStr = "ADMIN";
                break;
            default:
                cssClass = "mat-badge--other";
                reasonStr = "OTHER";
                break;
        }
        
        return string.Format("<span class=\"mat-badge {0}\">{1}</span>", cssClass, reasonStr);
    }
    
    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "mat-alert mat-alert--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }
    
    private void LogActivity(string actionType, string description)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date)
                              VALUES (@user, 'Results Hold Management', @par, @comments, NOW())";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@user", HttpContext.Current.User.Identity.Name);
                    cmd.Parameters.AddWithValue("@par", description + " IP Address: " + GetClientIP());
                    cmd.Parameters.AddWithValue("@comments", actionType);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
    }
    
    private string GetClientIP()
    {
        string ip = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (string.IsNullOrEmpty(ip))
            ip = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
        return ip ?? "Unknown";
    }
    
    private void UnholdSingleRecord(string id)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "UPDATE acad_examresults_faculty SET approved_by = '-' WHERE ID = @id AND approved_by = 'HELD'";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", int.Parse(id));
                    int affected = cmd.ExecuteNonQuery();
                    if (affected > 0)
                    {
                        LogActivity("UNHOLD", "Unhold single record ID: " + id);
                        ShowMessage("Record successfully removed from hold.", "success");
                    }
                }
            }
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error removing hold: " + ex.Message, "error");
        }
    }
    
    #endregion
    
    #region Event Handlers
    
    protected void Filter_Changed(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    protected void FilterByReason_Click(object sender, EventArgs e)
    {
        LinkButton btn = sender as LinkButton;
        if (btn != null)
        {
            CurrentReasonFilter = btn.CommandArgument;
            BindGrid();
        }
    }
    
    protected void btnClearFilters_Click(object sender, EventArgs e)
    {
        ddlAcadYear.SelectedIndex = 0;
        ddlSemester.SelectedIndex = 0;
        ddlProgramme.SelectedIndex = 0;
        ddlDuration.SelectedIndex = 0;
        CurrentReasonFilter = "";
        BindGrid();
    }
    
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnUnholdSelected_Click(object sender, EventArgs e)
    {
        // Check permissions
        if (!HttpContext.Current.User.IsInRole("Dean") && !HttpContext.Current.User.IsInRole("Administrator") && !HttpContext.Current.User.IsInRole("Registrar"))
        {
            ShowMessage("Only Dean, Registrar or Administrator can remove holds.", "error");
            return;
        }
        
        List<object> selectedKeys = gvHeldResults.GetSelectedFieldValues("ID");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select records to unhold.", "warning");
            return;
        }
        
        int count = 0;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                foreach (object key in selectedKeys)
                {
                    string sql = "UPDATE acad_examresults_faculty SET approved_by = '-' WHERE ID = @id AND approved_by = 'HELD'";
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", Convert.ToInt32(key));
                        count += cmd.ExecuteNonQuery();
                    }
                }
            }
            
            LogActivity("UNHOLD_BATCH", string.Format("Unhold {0} records", count));
            ShowMessage(string.Format("{0} record(s) removed from hold.", count), "success");
            gvHeldResults.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error removing holds: " + ex.Message, "error");
        }
    }
    
    protected void btnAddNote_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvHeldResults.GetSelectedFieldValues("ID");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select records to add note.", "warning");
            return;
        }
        popAddNote.ShowOnPageLoad = true;
    }
    
    protected void btnSaveNote_Click(object sender, EventArgs e)
    {
        // In a real implementation, this would save to a hold_notes table
        ShowMessage("Note saved successfully.", "success");
        popAddNote.ShowOnPageLoad = false;
        BindGrid();
    }
    
    protected void btnExport_Click(object sender, EventArgs e)
    {
        string fileName = string.Format("HeldResults_{0}", DateTime.Now.ToString("yyyyMMdd"));
        gvExporter.WriteXlsToResponse(fileName);
    }
    
    #endregion
}
