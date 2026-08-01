using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_ResultsRelease : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFaculties();
            LoadAcademicYears();
            LoadProgrammes();
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
        }
    }
    
    #region Data Loading
    
    private void LoadFaculties()
    {
        ddlFaculty.Items.Clear();
        ddlFaculty.Items.Add(new ListItem("-- All Faculties --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("SELECT fax_code, faculty_name FROM acad_faculty ORDER BY faculty_name", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFaculty.Items.Add(new ListItem(reader["faculty_name"].ToString(), reader["fax_code"].ToString()));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadAcademicYears()
    {
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new ListItem("-- All --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT DISTINCT acadyear FROM acad_examresults_faculty WHERE acadyear IS NOT NULL AND acadyear != '' ORDER BY acadyear DESC";
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
        
        // Add generated years as fallback
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 5; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            if (ddlAcadYear.Items.FindByValue(acadYear) == null)
                ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
        }
        
        // Set default to current academic year
        string defaultYear = AcademicYearHelper.GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
            ddlAcadYear.SelectedValue = defaultYear;
    }
    
    // Academic year logic centralised in AcademicYearHelper
    
    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT progcode, progname FROM acad_programme";
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                    sql += " WHERE fax_code = @fax";
                sql += " ORDER BY progname";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                        cmd.Parameters.AddWithValue("@fax", ddlFaculty.SelectedValue);
                    
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
    
    private void UpdateDisplayLabels()
    {
        litAcadYearDisplay.Text = string.IsNullOrEmpty(ddlAcadYear.SelectedValue) ? "All" : ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = string.IsNullOrEmpty(ddlSemester.SelectedValue) ? "All" : ddlSemester.SelectedValue;
    }
    
    private void LoadStats()
    {
        litTotalCount.Text = "0";
        litPendingCount.Text = "0";
        litReleasedCount.Text = "0";
        litHeldCount.Text = "0";
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<string> conditions = new List<string>();
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    conditions.Add("e.acadyear = @acad");
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    conditions.Add("e.semester = @sem");
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    conditions.Add("e.progid = @prog");
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                    conditions.Add("p.fax_code = @fax");
                
                string baseWhere = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions.ToArray()) : "";
                
                string countSql = @"SELECT 
                    COUNT(DISTINCT CONCAT(e.course_id, '-', e.progid, '-', e.acadyear, '-', e.semester)) as total,
                    SUM(CASE WHEN e.approved_by IS NOT NULL AND e.approved_by != '-' AND e.approved_by != '' AND e.approved_by != 'HELD' THEN 1 ELSE 0 END) as approved,
                    SUM(CASE WHEN e.approved_by = 'HELD' THEN 1 ELSE 0 END) as held
                    FROM acad_examresults_faculty e
                    LEFT JOIN acad_programme p ON e.progid = p.progcode
                    " + baseWhere;
                
                using (MySqlCommand cmd = new MySqlCommand(countSql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                        cmd.Parameters.AddWithValue("@fax", ddlFaculty.SelectedValue);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int total = reader["total"] != DBNull.Value ? Convert.ToInt32(reader["total"]) : 0;
                            int approved = reader["approved"] != DBNull.Value ? Convert.ToInt32(reader["approved"]) : 0;
                            int held = reader["held"] != DBNull.Value ? Convert.ToInt32(reader["held"]) : 0;
                            
                            litTotalCount.Text = total.ToString();
                            litReleasedCount.Text = approved.ToString();
                            litHeldCount.Text = held.ToString();
                            litPendingCount.Text = (total - approved - held).ToString();
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    #endregion
    
    #region Grid Binding
    
    private DataTable CreateEmptyTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("row_id", typeof(string));
        dt.Columns.Add("course_id", typeof(string));
        dt.Columns.Add("course_name", typeof(string));
        dt.Columns.Add("progid", typeof(string));
        dt.Columns.Add("prog_name", typeof(string));
        dt.Columns.Add("acadyear", typeof(string));
        dt.Columns.Add("semester", typeof(string));
        dt.Columns.Add("student_count", typeof(int));
        dt.Columns.Add("approved_count", typeof(int));
        dt.Columns.Add("release_status", typeof(string));
        dt.Columns.Add("release_date", typeof(DateTime));
        dt.Columns.Add("released_by", typeof(string));
        return dt;
    }
    
    private void BindGrid()
    {
        DataTable dt = CreateEmptyTable();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<string> conditions = new List<string>();
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    conditions.Add("e.acadyear = @acad");
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    conditions.Add("e.semester = @sem");
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    conditions.Add("e.progid = @prog");
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                    conditions.Add("p.fax_code = @fax");
                
                // Status filter
                if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
                {
                    switch (ddlStatus.SelectedValue)
                    {
                        case "PENDING":
                            conditions.Add("(e.approved_by IS NULL OR e.approved_by = '-' OR e.approved_by = '')");
                            break;
                        case "RELEASED":
                            conditions.Add("e.approved_by IS NOT NULL AND e.approved_by != '-' AND e.approved_by != '' AND e.approved_by != 'HELD'");
                            break;
                        case "HELD":
                            conditions.Add("e.approved_by = 'HELD'");
                            break;
                    }
                }
                
                string whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions.ToArray()) : "";
                
                // Group by course, programme, academic year, semester
                string sql = @"SELECT 
                    CONCAT(e.course_id, '-', e.progid, '-', e.acadyear, '-', e.semester) as row_id,
                    e.course_id, c.courseName as course_name,
                    e.progid, p.progname as prog_name,
                    e.acadyear, e.semester,
                    COUNT(*) as student_count,
                    SUM(CASE WHEN e.approved_by IS NOT NULL AND e.approved_by != '-' AND e.approved_by != '' AND e.approved_by != 'HELD' THEN 1 ELSE 0 END) as approved_count,
                    CASE 
                        WHEN SUM(CASE WHEN e.approved_by = 'HELD' THEN 1 ELSE 0 END) > 0 THEN 'HELD'
                        WHEN SUM(CASE WHEN e.approved_by IS NOT NULL AND e.approved_by != '-' AND e.approved_by != '' AND e.approved_by != 'HELD' THEN 1 ELSE 0 END) = COUNT(*) THEN 'RELEASED'
                        WHEN SUM(CASE WHEN e.approved_by IS NOT NULL AND e.approved_by != '-' AND e.approved_by != '' AND e.approved_by != 'HELD' THEN 1 ELSE 0 END) > 0 THEN 'PARTIAL'
                        ELSE 'PENDING'
                    END as release_status,
                    NOW() as release_date,
                    MAX(CASE WHEN e.approved_by != '-' AND e.approved_by != '' AND e.approved_by != 'HELD' THEN e.approved_by ELSE NULL END) as released_by
                    FROM acad_examresults_faculty e
                    LEFT JOIN acad_course c ON e.course_id = c.courseID
                    LEFT JOIN acad_programme p ON e.progid = p.progcode
                    " + whereClause + @"
                    GROUP BY e.course_id, e.progid, e.acadyear, e.semester
                    ORDER BY e.acadyear DESC, e.semester, p.progname, c.courseName
                    LIMIT 500";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                        cmd.Parameters.AddWithValue("@fax", ddlFaculty.SelectedValue);
                    
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        DataTable resultDt = new DataTable();
                        adapter.Fill(resultDt);
                        if (resultDt.Columns.Contains("course_id"))
                            dt = resultDt;
                    }
                }
                
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("No results found for the selected filters.", "warning");
                }
                else
                {
                    lblMessage.Text = string.Format("Showing {0} course results", dt.Rows.Count);
                    lblMessage.ForeColor = System.Drawing.Color.FromArgb(21, 87, 36);
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, "error");
        }
        
        gvResults.DataSource = dt;
        gvResults.DataBind();
    }
    
    protected string GetStatusBadge(object status)
    {
        string statusStr = (status != null) ? status.ToString() : "PENDING";
        string cssClass = "rr-status-badge--pending";
        string displayText = statusStr;
        
        switch (statusStr.ToUpper())
        {
            case "RELEASED":
                cssClass = "rr-status-badge--released";
                displayText = "RELEASED";
                break;
            case "PARTIAL":
                cssClass = "rr-status-badge--pending";
                displayText = "PARTIAL";
                break;
            case "HELD":
                cssClass = "rr-status-badge--held";
                displayText = "HELD";
                break;
            default:
                cssClass = "rr-status-badge--pending";
                displayText = "PENDING";
                break;
        }
        
        return string.Format("<span class=\"rr-status-badge {0}\">{1}</span>", cssClass, displayText);
    }
    
    #endregion
    
    #region Event Handlers
    
    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void btnReleaseSelected_Click(object sender, EventArgs e)
    {
        // Check permissions
        if (!RoleAccessService.IsInRoleCompat("Dean") && !RoleAccessService.IsInRoleCompat("Administrator") && !RoleAccessService.IsInRoleCompat("Registrar"))
        {
            ShowMessage("Only Dean, Registrar or Administrator can release results.", "error");
            return;
        }
        
        List<object> selectedKeys = gvResults.GetSelectedFieldValues("row_id");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select courses to release.", "warning");
            return;
        }
        
        int released = 0;
        string username = HttpContext.Current.User.Identity.Name;
        string batchId = MarksAuditLogger.NewBatchId();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object keyObj in selectedKeys)
                {
                    // row_id format: course_id-progid-acadyear-semester
                    string rowId = keyObj.ToString();
                    string[] parts = rowId.Split('-');
                    if (parts.Length >= 4)
                    {
                        string courseId = parts[0];
                        string progId = parts[1];
                        string acadYear = parts[2] + "/" + parts[3]; // Reconstruct acadyear like 2025/2026
                        int semester = Convert.ToInt32(parts[parts.Length - 1]);
                        
                        // Update all results for this course/programme/year/semester to mark as approved/released
                        string updateSql = @"UPDATE acad_examresults_faculty 
                            SET approved_by = @user
                            WHERE course_id = @course AND progid = @prog AND acadyear = @acad AND semester = @sem
                            AND (approved_by IS NULL OR approved_by = '-' OR approved_by = '')";
                        
                        using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@user", username);
                            cmd.Parameters.AddWithValue("@course", courseId);
                            cmd.Parameters.AddWithValue("@prog", progId);
                            cmd.Parameters.AddWithValue("@acad", acadYear);
                            cmd.Parameters.AddWithValue("@sem", semester);
                            int affected = cmd.ExecuteNonQuery();
                            released += affected;
                            
                            // Structured audit log for bulk release
                            if (affected > 0)
                                MarksAuditLogger.LogFacultyBulkApproval(conn, "RELEASE",
                                    courseId, progId, acadYear, semester,
                                    username, affected,
                                    "ResultsRelease.aspx", batchId);
                        }
                    }
                }
            }
            
            ShowMessage(string.Format("{0} student result(s) released successfully.", released), "success");
            LogActivity("RELEASE", string.Format("Released {0} results for {1} courses", released, selectedKeys.Count), "", "");
            gvResults.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error releasing results: " + ex.Message, "error");
        }
    }
    
    protected void btnHoldSelected_Click(object sender, EventArgs e)
    {
        // Check permissions
        if (!RoleAccessService.IsInRoleCompat("Dean") && !RoleAccessService.IsInRoleCompat("Administrator") && !RoleAccessService.IsInRoleCompat("Registrar"))
        {
            ShowMessage("Only Dean, Registrar or Administrator can hold results.", "error");
            return;
        }
        
        List<object> selectedKeys = gvResults.GetSelectedFieldValues("row_id");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select courses to hold.", "warning");
            return;
        }
        
        int held = 0;
        string batchId = MarksAuditLogger.NewBatchId();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object keyObj in selectedKeys)
                {
                    // row_id format: course_id-progid-acadyear-semester
                    string rowId = keyObj.ToString();
                    string[] parts = rowId.Split('-');
                    if (parts.Length >= 4)
                    {
                        string courseId = parts[0];
                        string progId = parts[1];
                        string acadYear = parts[2] + "/" + parts[3];
                        int semester = Convert.ToInt32(parts[parts.Length - 1]);
                        
                        // Mark results as HELD (different from pending which is '-')
                        string updateSql = @"UPDATE acad_examresults_faculty 
                            SET approved_by = 'HELD'
                            WHERE course_id = @course AND progid = @prog AND acadyear = @acad AND semester = @sem
                            AND approved_by IS NOT NULL AND approved_by != '-' AND approved_by != '' AND approved_by != 'HELD'";
                        
                        using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@course", courseId);
                            cmd.Parameters.AddWithValue("@prog", progId);
                            cmd.Parameters.AddWithValue("@acad", acadYear);
                            cmd.Parameters.AddWithValue("@sem", semester);
                            int affected = cmd.ExecuteNonQuery();
                            held += affected;
                            
                            // Structured audit log for bulk hold
                            if (affected > 0)
                                MarksAuditLogger.LogFacultyBulkApproval(conn, "HOLD",
                                    courseId, progId, acadYear, semester,
                                    "HELD", affected,
                                    "ResultsRelease.aspx", batchId);
                        }
                    }
                }
            }
            
            ShowMessage(string.Format("{0} student result(s) held successfully.", held), "success");
            LogActivity("HOLD", string.Format("Held {0} results for {1} courses", held, selectedKeys.Count), "", "");
            gvResults.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error holding results: " + ex.Message, "error");
        }
    }
    
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;
        string fileName = string.Format("ResultsRelease_{0}_Sem{1}_{2}", 
            string.IsNullOrEmpty(acadYear) ? "All" : acadYear.Replace("/", "-"), 
            string.IsNullOrEmpty(semester) ? "All" : semester,
            DateTime.Now.ToString("yyyyMMdd"));
        
        gvExporter.WriteXlsToResponse(fileName);
    }
    
    #endregion
    
    #region Helper Methods
    
    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "rr-message show rr-message--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }
    
    private void LogActivity(string action, string details, string courseId, string regNo)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date)
                              VALUES (@user, @func, @par, @comments, NOW())";
                              
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@user", HttpContext.Current.User.Identity.Name);
                    cmd.Parameters.AddWithValue("@func", "ResultsRelease - " + action);
                    cmd.Parameters.AddWithValue("@par", details);
                    cmd.Parameters.AddWithValue("@comments", "IP: " + Request.UserHostAddress);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { /* Silent fail for logging */ }
    }
    
    #endregion
}
