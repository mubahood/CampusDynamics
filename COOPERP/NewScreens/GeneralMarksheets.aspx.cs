using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_GeneralMarksheets : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    protected void Page_Init(object sender, EventArgs e)
    {
        if (IsPostBack)
        {
            gvMarksheets.DataSource = CreateEmptyMarksheetTable();
            gvMarksheets.DataBind();
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFaculties();
            LoadAcademicYears();
            LoadCampuses();
            
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
        }
    }
    
    private void LoadFaculties()
    {
        ddlFaculty.Items.Clear();
        ddlFaculty.Items.Add(new ListItem("-- All Faculties --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string username = HttpContext.Current.User.Identity.Name;
                
                string userFacultySql = @"SELECT f.faculty_name, uf.fax_code
                                          FROM my_aspnet_user_faculties uf
                                          INNER JOIN acad_faculty f ON f.faculty_code = uf.fax_code
                                          WHERE LOWER(TRIM(uf.user_name)) = LOWER(TRIM(@unm))
                                          ORDER BY f.faculty_name";

                using (MySqlCommand cmd = new MySqlCommand(userFacultySql, conn))
                {
                    cmd.Parameters.AddWithValue("@unm", username);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string code = reader["fax_code"].ToString();
                            string name = reader["faculty_name"].ToString();
                            ddlFaculty.Items.Add(new ListItem(code + " - " + name, code));
                        }
                    }
                }
                
                if (ddlFaculty.Items.Count == 1)
                {
                    using (MySqlCommand cmd = new MySqlCommand("SELECT fax_code, faculty_name FROM acad_faculty ORDER BY faculty_name", conn))
                    {
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string code = reader["fax_code"].ToString();
                                string name = reader["faculty_name"].ToString();
                                ddlFaculty.Items.Add(new ListItem(code + " - " + name, code));
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading faculties: " + ex.Message, "error");
        }
    }
    
    private void LoadAcademicYears()
    {
        ddlAcadYear.Items.Clear();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT DISTINCT acadyear FROM acad_examresults_faculty_settings WHERE acadyear IS NOT NULL AND acadyear != '' ORDER BY acadyear DESC";
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
        
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 5; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            if (ddlAcadYear.Items.FindByValue(acadYear) == null)
                ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
        }
        
        string defaultYear = AcademicYearHelper.GetCurrentAcademicYear();
        ListItem item = ddlAcadYear.Items.FindByValue(defaultYear);
        if (item != null)
            ddlAcadYear.SelectedValue = defaultYear;
    }
    
    // Academic year logic centralised in AcademicYearHelper
    
    private void LoadCampuses()
    {
        ddlCampus.Items.Clear();
        ddlCampus.Items.Add(new ListItem("-- All Campuses --", "0"));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT ID, campus_name FROM acad_campuses ORDER BY campus_name";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlCampus.Items.Add(new ListItem(reader["campus_name"].ToString(), reader["ID"].ToString()));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void UpdateDisplayLabels()
    {
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
    }
    
    private void LoadStats()
    {
        // Initialize stats to 0 - marksheet tracking requires additional table setup
        litPendingCount.Text = "0";
        litSubmittedCount.Text = "0";
        litApprovedCount.Text = "0";
        litCapturedCount.Text = "0";
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                string facultyValue = ddlFaculty.SelectedValue;
                string acadYear = ddlAcadYear.SelectedValue;
                string semester = ddlSemester.SelectedValue;
                string campus = ddlCampus.SelectedValue;
                
                // Count total exam settings configured for this period
                List<string> conditions = new List<string>();
                conditions.Add("e.acadyear = @acad");
                conditions.Add("e.semester = @sem");
                
                if (!string.IsNullOrEmpty(facultyValue))
                    conditions.Add("p.fax_code = @fax");
                
                string baseWhere = "WHERE " + string.Join(" AND ", conditions.ToArray());
                
                string countQuery = @"SELECT COUNT(*) FROM acad_examresults_faculty_settings e 
                                    INNER JOIN acad_programme p ON e.progid = p.progcode 
                                    " + baseWhere;
                
                using (MySqlCommand cmd = new MySqlCommand(countQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@acad", acadYear);
                    cmd.Parameters.AddWithValue("@sem", int.Parse(semester));
                    if (!string.IsNullOrEmpty(facultyValue))
                        cmd.Parameters.AddWithValue("@fax", facultyValue);
                    
                    int total = Convert.ToInt32(cmd.ExecuteScalar());
                    litPendingCount.Text = total.ToString(); // Show total as "pending" for now
                }
            }
        }
        catch { }
    }
    
    private void AddStatsParams(MySqlCommand cmd, string faculty, string acadYear, string semester, string campus)
    {
        cmd.Parameters.AddWithValue("@acad", acadYear);
        cmd.Parameters.AddWithValue("@sem", int.Parse(semester));
        if (!string.IsNullOrEmpty(faculty))
            cmd.Parameters.AddWithValue("@fax", faculty);
        if (campus != "0")
            cmd.Parameters.AddWithValue("@campus", int.Parse(campus));
    }
    
    private DataTable CreateEmptyMarksheetTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ID", typeof(int));
        dt.Columns.Add("courseID", typeof(string));
        dt.Columns.Add("course_name", typeof(string));
        dt.Columns.Add("classname", typeof(string));
        dt.Columns.Add("cyear", typeof(int));
        dt.Columns.Add("stream", typeof(string));
        dt.Columns.Add("EntryYear", typeof(int));
        dt.Columns.Add("intake", typeof(string));
        dt.Columns.Add("stud_session", typeof(string));
        dt.Columns.Add("emp_name", typeof(string));
        dt.Columns.Add("dateCreated", typeof(DateTime));
        dt.Columns.Add("dateSubmitted", typeof(DateTime));
        dt.Columns.Add("sheet_status", typeof(string));
        dt.Columns.Add("prog_id", typeof(string));
        dt.Columns.Add("acad_year", typeof(string));
        dt.Columns.Add("semester", typeof(int));
        dt.Columns.Add("ExamFormat", typeof(string));
        dt.Columns.Add("practical_percent", typeof(double));
        return dt;
    }
    
    private void BindGrid()
    {
        DataTable dt = CreateEmptyMarksheetTable();
        
        try
        {
            string connStr = ConnectionString;
            if (!connStr.Contains("Allow User Variables"))
                connStr = connStr.TrimEnd(';') + ";Allow User Variables=True;";
            
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                
                string facultyValue = ddlFaculty.SelectedValue;
                string acadYear = ddlAcadYear.SelectedValue;
                string semester = ddlSemester.SelectedValue;
                string status = ddlStatus.SelectedValue;
                string campus = ddlCampus.SelectedValue;
                
                List<string> conditions = new List<string>();
                conditions.Add("e.acadyear = @acad");
                conditions.Add("e.semester = @sem");
                
                if (!string.IsNullOrEmpty(facultyValue))
                    conditions.Add("p.fax_code = @fax");
                
                string whereClause = "WHERE " + string.Join(" AND ", conditions.ToArray());
                
                // Query the settings table - use row number as pseudo ID
                string sql = @"SELECT 
                    (@row_number:=@row_number+1) as ID, 
                    e.course_id as courseID, c.courseName as course_name, p.progname as classname,
                    1 as cyear, '' as stream, 0 as EntryYear, '' as intake, e.stud_session,
                    '' as emp_name,
                    NOW() as dateCreated, NOW() as dateSubmitted, 
                    'NEW' as sheet_status,
                    e.progid as prog_id, e.acadyear as acad_year, e.semester, '' as ExamFormat, 
                    e.coursework_ratio as practical_percent
                    FROM acad_examresults_faculty_settings e
                    CROSS JOIN (SELECT @row_number:=0) AS r
                    INNER JOIN acad_programme p ON e.progid = p.progcode
                    LEFT JOIN acad_course c ON e.course_id = c.courseID
                    " + whereClause + @"
                    ORDER BY p.progname, c.courseName
                    LIMIT 500";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@acad", acadYear);
                    cmd.Parameters.AddWithValue("@sem", int.Parse(semester));
                    
                    if (!string.IsNullOrEmpty(facultyValue))
                        cmd.Parameters.AddWithValue("@fax", facultyValue);
                    
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        DataTable resultDt = new DataTable();
                        adapter.Fill(resultDt);
                        
                        if (resultDt.Columns.Contains("ID"))
                            dt = resultDt;
                    }
                }
                
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("No marksheets found for the selected filters.", "warning");
                }
                else
                {
                    lblMessage.Text = string.Format("Showing {0} marksheets", dt.Rows.Count);
                    lblMessage.ForeColor = System.Drawing.Color.FromArgb(21, 87, 36);
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, "error");
        }
        
        gvMarksheets.DataSource = dt;
        gvMarksheets.DataBind();
    }
    
    protected string GetStatusBadge(object status)
    {
        string statusStr = (status != null) ? status.ToString() : "NEW";
        string cssClass = "gm-status-badge--pending";
        string displayText = statusStr;
        
        switch (statusStr.ToUpper())
        {
            case "NEW":
                cssClass = "gm-status-badge--pending";
                displayText = "PENDING";
                break;
            case "SUBMITTED":
                cssClass = "gm-status-badge--submitted";
                break;
            case "APPROVED":
                cssClass = "gm-status-badge--approved";
                break;
            case "CAPTURED":
                cssClass = "gm-status-badge--captured";
                break;
        }
        
        return string.Format("<span class=\"gm-status-badge {0}\">{1}</span>", cssClass, displayText);
    }
    
    private void ShowMessage(string message, string type)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "gm-message show gm-message--" + type;
        litMessage.Text = message;
    }
    
    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
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
    
    protected void ddlCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnApproveSelected_Click(object sender, EventArgs e)
    {
        if (!RoleAccessService.IsInRoleCompat("Dean") && !RoleAccessService.IsInRoleCompat("Administrator"))
        {
            ShowMessage("Only Dean or Administrator can approve marksheets.", "error");
            return;
        }
        
        List<object> selectedIds = gvMarksheets.GetSelectedFieldValues("ID");
        if (selectedIds.Count == 0)
        {
            ShowMessage("Please select marksheets to approve.", "warning");
            return;
        }
        
        // Note: The acad_examresults_faculty_settings table is for ratio configuration only.
        // Marksheet approval functionality requires additional database table setup.
        ShowMessage("Marksheet approval functionality requires additional configuration. Please contact system administrator.", "info");
        
        gvMarksheets.Selection.UnselectAll();
    }
    
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;
        string status = ddlStatus.SelectedValue;
        
        string fileName = string.Format("{0}_MarksheetList_{1}_Sem{2}", status, acadYear.Replace("/", "-"), semester);
        
        gvExporter.WriteXlsToResponse(fileName);
    }
    
    protected void gvMarksheets_RowCommand(object sender, ASPxGridViewRowCommandEventArgs e)
    {
        if (e.CommandArgs.CommandName == "ViewDetails")
        {
            int rowIndex = e.VisibleIndex;
            
            Session["mid"] = gvMarksheets.GetRowValues(rowIndex, "ID");
            Session["acad"] = gvMarksheets.GetRowValues(rowIndex, "acad_year");
            Session["sem"] = gvMarksheets.GetRowValues(rowIndex, "semester");
            Session["csid"] = gvMarksheets.GetRowValues(rowIndex, "courseID");
            Session["cyr"] = gvMarksheets.GetRowValues(rowIndex, "cyear");
            Session["status"] = ddlStatus.SelectedValue;
            Session["CourseName"] = gvMarksheets.GetRowValues(rowIndex, "course_name");
            Session["Exam_format"] = gvMarksheets.GetRowValues(rowIndex, "ExamFormat");
            Session["practical_percent"] = gvMarksheets.GetRowValues(rowIndex, "practical_percent");
            
            object classObj = gvMarksheets.GetRowValues(rowIndex, "classname");
            object sessionObj = gvMarksheets.GetRowValues(rowIndex, "stud_session");
            object cyearObj = gvMarksheets.GetRowValues(rowIndex, "cyear");
            
            string className = classObj != null ? classObj.ToString() : "";
            string studSession = sessionObj != null ? sessionObj.ToString() : "";
            string cyear = cyearObj != null ? cyearObj.ToString() : "";
            
            Session["headerText"] = string.Format("{0} [{1}] :: {2}, SEMESTER {3}",
                gvMarksheets.GetRowValues(rowIndex, "course_name"),
                gvMarksheets.GetRowValues(rowIndex, "courseID"),
                Session["acad"], Session["sem"]);
            
            popDetails.HeaderText = string.Format("MARKSHEET FOR {0} [{1}] - YEAR {2}", className, studSession, cyear);
            popDetails.ContentUrl = ResolveUrl("~/COOPERP/Results/MarkSheetDetails.aspx");
            popDetails.ShowOnPageLoad = true;
        }
    }
}
