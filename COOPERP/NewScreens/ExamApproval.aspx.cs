using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.XtraPrinting;
using DevExpress.Web;

public partial class COOPERP_NewScreens_ExamApproval : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    protected void Page_Init(object sender, EventArgs e)
    {
        // Bind empty table with proper columns to prevent DevExpress null reference on postback
        if (IsPostBack)
        {
            gvResults.DataSource = CreateEmptyResultsTable();
            gvResults.DataBind();
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCampuses();
            LoadAcademicYears();
            LoadProgrammes();
            
            // Keep All as default for maximum data visibility
            // string defaultYear = GetCurrentAcademicYear();
            // if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
            //     ddlAcadYear.SelectedValue = defaultYear;
            
            LoadCourses();
            CheckUserPermissions();
            BindGrid();
            LoadStats();
            UpdateCurrentUserLabel();
        }
    }
    
    private void UpdateCurrentUserLabel()
    {
        string username = HttpContext.Current.User.Identity.Name;
        string role = "";
        if (RoleAccessService.IsInRoleCompat("Dean"))
            role = "Dean";
        else if (RoleAccessService.IsInRoleCompat("Administrator"))
            role = "Admin";
        else if (RoleAccessService.IsInRoleCompat("Lecturer"))
            role = "Lecturer";
        else
            role = "User";
        
        lblCurrentUser.Text = string.Format("{0} ({1})", username, role);
    }
    
    private void CheckUserPermissions()
    {
        // Enable approve/cancel buttons only for Dean or Administrator
        bool canApprove = RoleAccessService.IsInRoleCompat("Dean") || RoleAccessService.IsInRoleCompat("Administrator");
        btnApproveSelected.Enabled = canApprove;
        btnApproveAll.Enabled = canApprove;
        btnCancelApproval.Enabled = canApprove;
        
        if (!canApprove)
        {
            btnApproveSelected.ToolTip = "Only Dean or Administrator can approve results";
            btnApproveAll.ToolTip = "Only Dean or Administrator can approve results";
            btnCancelApproval.ToolTip = "Only Dean or Administrator can cancel approval";
        }
    }
    
    // Academic year logic centralised in AcademicYearHelper
    
    private void LoadCampuses()
    {
        ddlCampus.Items.Clear();
        
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
                        ddlCampus.Items.Add(new ListEditItem(reader["campus_name"].ToString(), reader["ID"].ToString()));
                    }
                }
            }
        }
        
        if (ddlCampus.Items.Count > 0)
            ddlCampus.SelectedIndex = 0;
    }
    
    private void LoadAcademicYears()
    {
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new ListEditItem("-- All --", ""));
        
        // First try to load academic years that actually have data in the database
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
                                ddlAcadYear.Items.Add(new ListEditItem(yr, yr));
                        }
                    }
                }
            }
        }
        catch
        {
            // Ignore and fall through to generated years
        }
        
        // Always add generated years as fallback options
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 5; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            // Only add if not already in the list
            bool exists = false;
            foreach (ListEditItem item in ddlAcadYear.Items)
            {
                if (item.Value == acadYear)
                {
                    exists = true;
                    break;
                }
            }
            if (!exists)
                ddlAcadYear.Items.Add(new ListEditItem(acadYear, acadYear));
        }
    }

    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListEditItem("-- Select Programme --", ""));
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string username = HttpContext.Current.User.Identity.Name;
            
            // Get user's assigned programmes using the stored procedure
            using (MySqlCommand cmd = new MySqlCommand("myaspnet_GetMyProgrammes", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@usr", username);
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["progcode"].ToString();
                        string name = reader["progname"].ToString();
                        ddlProgramme.Items.Add(new ListEditItem(code + " - " + name, code));
                    }
                }
            }
            
            // If no programmes found via permissions, load all
            if (ddlProgramme.Items.Count == 1)
            {
                string sqlAll = "SELECT progcode, progname FROM acad_programme ORDER BY progname";
                using (MySqlCommand cmd = new MySqlCommand(sqlAll, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string code = reader["progcode"].ToString();
                            string name = reader["progname"].ToString();
                            ddlProgramme.Items.Add(new ListEditItem(code + " - " + name, code));
                        }
                    }
                }
            }
        }
    }
    
    private void LoadCourses()
    {
        ddlCourse.Items.Clear();
        ddlCourse.Items.Add(new ListEditItem("-- Select Course --", ""));
        
        if (string.IsNullOrEmpty(ddlProgramme.SelectedItem != null ? ddlProgramme.SelectedItem.Value.ToString() : ""))
            return;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = @"SELECT DISTINCT pc.course_code, c.courseName as course_name
                          FROM acad_programmecourses pc
                          INNER JOIN acad_course c ON pc.course_code = c.courseID
                          WHERE pc.progcode = @prog 
                            AND pc.study_year = @yr 
                            AND pc.semester = @sem
                          ORDER BY c.courseName";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedItem.Value.ToString());
                cmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedItem.Value.ToString()));
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedItem.Value.ToString()));
                
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["course_code"].ToString();
                        string name = reader["course_name"].ToString();
                        ddlCourse.Items.Add(new ListEditItem(code + " - " + name, code));
                    }
                }
            }
        }
    }
    
    private void LoadStats()
    {
        int total = 0, pending = 0, approved = 0, pass = 0, fail = 0;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Build dynamic WHERE clause based on selected filters
            List<string> conditions = new List<string>();
            
            // Add filters only if selected (all are now optional)
            string acadValue = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
            string semValue = ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "";
            string progValue = ddlProgramme.SelectedItem != null ? ddlProgramme.SelectedItem.Value.ToString() : "";
            string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
            string sessionValue = ddlSession.SelectedItem != null ? ddlSession.SelectedItem.Value.ToString() : "";
            string statusValue = ddlExamStatus.SelectedItem != null ? ddlExamStatus.SelectedItem.Value.ToString() : "";
            string studyYearValue = ddlStudyYear.SelectedItem != null ? ddlStudyYear.SelectedItem.Value.ToString() : "";
            
            if (!string.IsNullOrEmpty(acadValue))
                conditions.Add("acadyear = @acad");
            if (!string.IsNullOrEmpty(semValue))
                conditions.Add("semester = @sem");
            if (!string.IsNullOrEmpty(progValue))
                conditions.Add("progid = @prog");
            if (!string.IsNullOrEmpty(courseValue))
                conditions.Add("course_id = @course");
            if (!string.IsNullOrEmpty(sessionValue))
                conditions.Add("stud_session = @session");
            if (!string.IsNullOrEmpty(statusValue))
                conditions.Add("exam_status = @status");
            if (!string.IsNullOrEmpty(studyYearValue))
                conditions.Add("cyear = @yr");
            
            string baseWhere = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions) : "";
            
            // Total
            string sqlTotal = "SELECT COUNT(*) FROM acad_examresults_faculty " + baseWhere;
            using (MySqlCommand cmd = new MySqlCommand(sqlTotal, conn))
            {
                AddStatsParameters(cmd);
                total = Convert.ToInt32(cmd.ExecuteScalar());
            }
            
            // Pending (not approved)
            string pendingWhere = baseWhere + (baseWhere.Length > 0 ? " AND " : "WHERE ") + "(approved_by = '-' OR approved_by IS NULL OR approved_by = '')";
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_examresults_faculty " + pendingWhere, conn))
            {
                AddStatsParameters(cmd);
                pending = Convert.ToInt32(cmd.ExecuteScalar());
            }
            
            // Approved
            string approvedWhere = baseWhere + (baseWhere.Length > 0 ? " AND " : "WHERE ") + "approved_by != '-' AND approved_by IS NOT NULL AND approved_by != ''";
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_examresults_faculty " + approvedWhere, conn))
            {
                AddStatsParameters(cmd);
                approved = Convert.ToInt32(cmd.ExecuteScalar());
            }
            
            // Pass (total >= 50)
            string passWhere = baseWhere + (baseWhere.Length > 0 ? " AND " : "WHERE ") + "total_mark >= 50";
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_examresults_faculty " + passWhere, conn))
            {
                AddStatsParameters(cmd);
                pass = Convert.ToInt32(cmd.ExecuteScalar());
            }
            
            // Fail
            fail = total - pass;
        }
        
        litTotalCount.Text = total.ToString();
        litPendingCount.Text = pending.ToString();
        litApprovedCount.Text = approved.ToString();
        
        if (total > 0)
            litPassRate.Text = string.Format("{0:0.0}%", (pass * 100.0 / total));
        else
            litPassRate.Text = "0%";
        
        // Show approval summary if there are pending results
        pnlApprovalSummary.Visible = pending > 0;
        litPendingSummary.Text = string.Format("{0} result(s) pending approval", pending);
        
        // Update grid title
        litGridTitle.Text = string.Format("Exam Results ({0} records)", total);
        
        // Update course info
        string courseValue2 = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
        if (!string.IsNullOrEmpty(courseValue2))
        {
            litCourseInfo.Text = string.Format("{0} | {1} | Semester {2} | Year {3}",
                courseValue2,
                ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "",
                ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "",
                ddlStudyYear.SelectedItem != null ? ddlStudyYear.SelectedItem.Value.ToString() : "");
        }
        else
        {
            litCourseInfo.Text = string.Format("{0} | Semester {1}",
                ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "",
                ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "");
        }
    }
    
    private void AddStatsParameters(MySqlCommand cmd)
    {
        string acadValue = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
        string semValue = ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "";
        string progValue = ddlProgramme.SelectedItem != null ? ddlProgramme.SelectedItem.Value.ToString() : "";
        string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
        string sessionValue = ddlSession.SelectedItem != null ? ddlSession.SelectedItem.Value.ToString() : "";
        string statusValue = ddlExamStatus.SelectedItem != null ? ddlExamStatus.SelectedItem.Value.ToString() : "";
        string studyYearValue = ddlStudyYear.SelectedItem != null ? ddlStudyYear.SelectedItem.Value.ToString() : "";
        
        if (!string.IsNullOrEmpty(acadValue))
            cmd.Parameters.AddWithValue("@acad", acadValue);
        if (!string.IsNullOrEmpty(semValue))
            cmd.Parameters.AddWithValue("@sem", int.Parse(semValue));
        if (!string.IsNullOrEmpty(progValue))
            cmd.Parameters.AddWithValue("@prog", progValue);
        if (!string.IsNullOrEmpty(courseValue))
            cmd.Parameters.AddWithValue("@course", courseValue);
        if (!string.IsNullOrEmpty(sessionValue))
            cmd.Parameters.AddWithValue("@session", sessionValue);
        if (!string.IsNullOrEmpty(statusValue))
            cmd.Parameters.AddWithValue("@status", statusValue);
        if (!string.IsNullOrEmpty(studyYearValue))
            cmd.Parameters.AddWithValue("@yr", int.Parse(studyYearValue));
    }
    
    private DataTable CreateEmptyResultsTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ID", typeof(int));
        dt.Columns.Add("regno", typeof(string));
        dt.Columns.Add("stud_name", typeof(string));
        dt.Columns.Add("course_id", typeof(string));
        dt.Columns.Add("course_name", typeof(string));
        dt.Columns.Add("acadyear", typeof(string));
        dt.Columns.Add("semester", typeof(int));
        dt.Columns.Add("cw_mark_entered", typeof(int));
        dt.Columns.Add("exam_mark_entered", typeof(int));
        dt.Columns.Add("total_mark", typeof(int));
        dt.Columns.Add("grade", typeof(string));
        dt.Columns.Add("gradept", typeof(double));
        dt.Columns.Add("exam_status", typeof(string));
        dt.Columns.Add("approved_by", typeof(string));
        dt.Columns.Add("progid", typeof(string));
        return dt;
    }
    
    private void BindGrid()
    {
        DataTable dt = CreateEmptyResultsTable();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Build dynamic WHERE clause based on selected filters
                List<string> conditions = new List<string>();
                
                // Add filters only if selected (all are now optional)
                string acadValue = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
                string semValue = ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "";
                string progValue = ddlProgramme.SelectedItem != null ? ddlProgramme.SelectedItem.Value.ToString() : "";
                string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
                string sessionValue = ddlSession.SelectedItem != null ? ddlSession.SelectedItem.Value.ToString() : "";
                string statusValue = ddlExamStatus.SelectedItem != null ? ddlExamStatus.SelectedItem.Value.ToString() : "";
                string studyYearValue = ddlStudyYear.SelectedItem != null ? ddlStudyYear.SelectedItem.Value.ToString() : "";
                string approvalValue = ddlApprovalFilter.SelectedItem != null ? ddlApprovalFilter.SelectedItem.Value.ToString() : "ALL";
                
                if (!string.IsNullOrEmpty(acadValue))
                    conditions.Add("e.acadyear = @acad");
                if (!string.IsNullOrEmpty(semValue))
                    conditions.Add("e.semester = @sems");
                if (!string.IsNullOrEmpty(progValue))
                    conditions.Add("e.progid = @prog");
                if (!string.IsNullOrEmpty(courseValue))
                    conditions.Add("e.course_id = @csid");
                if (!string.IsNullOrEmpty(sessionValue))
                    conditions.Add("e.stud_session = @sess");
                if (!string.IsNullOrEmpty(statusValue))
                    conditions.Add("e.exam_status = @stat");
                if (!string.IsNullOrEmpty(studyYearValue))
                    conditions.Add("e.cyear = @yr");
                
                // Approval status filter
                if (approvalValue == "PENDING")
                    conditions.Add("(e.approved_by = '-' OR e.approved_by IS NULL OR e.approved_by = '')");
                else if (approvalValue == "APPROVED")
                    conditions.Add("e.approved_by != '-' AND e.approved_by IS NOT NULL AND e.approved_by != ''");
                
                string whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions) : "";
                
                string sql = @"SELECT 
                    e.ID, e.regno, e.course_id, e.acadyear, e.semester,
                    e.cw_mark_entered, e.exam_mark_entered, e.total_mark,
                    e.grade, e.gradept, e.exam_status, e.approved_by, e.progid,
                    CONCAT(s.firstname, ' ', COALESCE(s.othername, '')) as stud_name,
                    c.courseName as course_name
                    FROM acad_examresults_faculty e
                    LEFT JOIN acad_student s ON e.regno = s.regno
                    LEFT JOIN acad_course c ON e.course_id = c.courseID
                    " + whereClause + @"
                    ORDER BY s.firstname, s.othername
                    LIMIT 500";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(acadValue))
                        cmd.Parameters.AddWithValue("@acad", acadValue);
                    if (!string.IsNullOrEmpty(semValue))
                        cmd.Parameters.AddWithValue("@sems", int.Parse(semValue));
                    if (!string.IsNullOrEmpty(progValue))
                        cmd.Parameters.AddWithValue("@prog", progValue);
                    if (!string.IsNullOrEmpty(courseValue))
                        cmd.Parameters.AddWithValue("@csid", courseValue);
                    if (!string.IsNullOrEmpty(sessionValue))
                        cmd.Parameters.AddWithValue("@sess", sessionValue);
                    if (!string.IsNullOrEmpty(statusValue))
                        cmd.Parameters.AddWithValue("@stat", statusValue);
                    if (!string.IsNullOrEmpty(studyYearValue))
                        cmd.Parameters.AddWithValue("@yr", int.Parse(studyYearValue));
                    
                    DataTable resultDt = new DataTable();
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(resultDt);
                    }
                    
                    // Use result table if it has data or has the required columns
                    if (resultDt.Columns.Contains("course_name"))
                        dt = resultDt;
                }
            }
        }
        catch (Exception)
        {
            // Use empty table with proper columns on error
        }
        
        gvResults.DataSource = dt;
        gvResults.DataBind();
    }
    
    protected string GetMarkCellHtml(object mark)
    {
        int totalMark = mark != null && mark != DBNull.Value ? Convert.ToInt32(mark) : 0;
        string cssClass = totalMark >= 50 ? "ea-mark-cell--pass" : "ea-mark-cell--fail";
        return string.Format("<span class=\"ea-mark-cell {0}\">{1}</span>", cssClass, totalMark);
    }
    
    protected string GetApprovalStatusBadge(object approvedBy)
    {
        string approver = (approvedBy != null && approvedBy != DBNull.Value) ? approvedBy.ToString() : "-";
        
        if (approver == "-" || string.IsNullOrEmpty(approver))
        {
            return "<span class=\"ea-badge ea-badge--pending\">PENDING</span>";
        }
        else
        {
            return string.Format("<span class=\"ea-badge ea-badge--approved\">Approved by {0}</span>", approver);
        }
    }
    
    #region Event Handlers
    
    protected void ddlCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStudyYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSession_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlExamStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlApprovalFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    #endregion
    
    #region Approval Actions
    
    protected void btnApproveSelected_Click(object sender, EventArgs e)
    {
        if (!RoleAccessService.IsInRoleCompat("Dean") && !RoleAccessService.IsInRoleCompat("Administrator"))
        {
            ShowMessage("Only Dean or Administrator can approve results.");
            return;
        }
        
        List<object> selectedIds = gvResults.GetSelectedFieldValues("ID");
        if (selectedIds.Count == 0)
        {
            ShowMessage("Please select at least one result to approve.");
            return;
        }
        
        int approvedCount = 0;
        string username = HttpContext.Current.User.Identity.Name;
        string batchId = MarksAuditLogger.NewBatchId();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            foreach (object id in selectedIds)
            {
                int intId = Convert.ToInt32(id);
                
                // Snapshot before change
                DataRow snap = MarksAuditLogger.SnapshotFaculty(conn, intId);
                
                string sql = @"UPDATE acad_examresults_faculty 
                              SET approved_by = @approver 
                              WHERE ID = @id AND (approved_by = '-' OR approved_by IS NULL OR approved_by = '')";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@approver", username);
                    cmd.Parameters.AddWithValue("@id", intId);
                    int affected = cmd.ExecuteNonQuery();
                    if (affected > 0)
                    {
                        approvedCount++;
                        if (snap != null)
                            MarksAuditLogger.LogFacultyApproval("APPROVE", intId,
                                snap["regno"].ToString(), snap["course_id"].ToString(),
                                snap["acadyear"].ToString(), Convert.ToInt32(snap["semester"]),
                                snap["progid"].ToString(), snap["approved_by"].ToString(), username,
                                "ExamApproval.aspx", batchId);
                    }
                }
            }
        }
        
        // Log the activity
        LogActivity("APPROVE_RESULTS", string.Format("Approved {0} results for course {1}", approvedCount, 
            ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : ""));
        
        gvResults.Selection.UnselectAll();
        BindGrid();
        LoadStats();
        
        ShowMessage(string.Format("{0} result(s) approved successfully.", approvedCount));
    }
    
    protected void btnApproveAll_Click(object sender, EventArgs e)
    {
        if (!RoleAccessService.IsInRoleCompat("Dean") && !RoleAccessService.IsInRoleCompat("Administrator"))
        {
            ShowMessage("Only Dean or Administrator can approve results.");
            return;
        }
        
        string progValue = ddlProgramme.SelectedItem != null ? ddlProgramme.SelectedItem.Value.ToString() : "";
        string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
        
        if (string.IsNullOrEmpty(progValue) || string.IsNullOrEmpty(courseValue))
        {
            ShowMessage("Please select a programme and course first.");
            return;
        }
        
        int approvedCount = 0;
        string username = HttpContext.Current.User.Identity.Name;
        string batchId = MarksAuditLogger.NewBatchId();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            string sql = @"UPDATE acad_examresults_faculty 
                          SET approved_by = @approver 
                          WHERE course_id = @csid 
                          AND acadyear = @acad 
                          AND semester = @sems
                          AND progid = @prog
                          AND stud_session = @sess
                          AND cyear = @yr
                          AND exam_status = @stat
                          AND (approved_by = '-' OR approved_by IS NULL OR approved_by = '')";
            
            string courseVal = courseValue;
            string acadVal = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
            int semVal = int.Parse(ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "1");
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@approver", username);
                cmd.Parameters.AddWithValue("@prog", progValue);
                cmd.Parameters.AddWithValue("@acad", acadVal);
                cmd.Parameters.AddWithValue("@sems", semVal);
                cmd.Parameters.AddWithValue("@sess", ddlSession.SelectedItem != null ? ddlSession.SelectedItem.Value.ToString() : "DAY");
                cmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedItem != null ? ddlStudyYear.SelectedItem.Value.ToString() : "1"));
                cmd.Parameters.AddWithValue("@csid", courseVal);
                cmd.Parameters.AddWithValue("@stat", ddlExamStatus.SelectedItem != null ? ddlExamStatus.SelectedItem.Value.ToString() : "REGULAR");
                
                approvedCount = cmd.ExecuteNonQuery();
            }
            
            // Structured audit log for bulk approval
            if (approvedCount > 0)
                MarksAuditLogger.LogFacultyBulkApproval(conn, "APPROVE",
                    courseVal, progValue, acadVal, semVal,
                    username, approvedCount,
                    "ExamApproval.aspx", batchId);
        }
        
        // Log the activity
        LogActivity("APPROVE_ALL_RESULTS", string.Format("Approved all {0} pending results for course {1}", approvedCount, courseValue));
        
        BindGrid();
        LoadStats();
        
        ShowMessage(string.Format("All {0} pending result(s) approved successfully.", approvedCount));
    }
    
    protected void btnCancelApproval_Click(object sender, EventArgs e)
    {
        if (!RoleAccessService.IsInRoleCompat("Dean") && !RoleAccessService.IsInRoleCompat("Administrator"))
        {
            ShowMessage("Only Dean or Administrator can cancel approval.");
            return;
        }
        
        List<object> selectedIds = gvResults.GetSelectedFieldValues("ID");
        if (selectedIds.Count == 0)
        {
            ShowMessage("Please select at least one result to cancel approval.");
            return;
        }
        
        int cancelledCount = 0;
        string batchId = MarksAuditLogger.NewBatchId();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            foreach (object id in selectedIds)
            {
                int intId = Convert.ToInt32(id);
                
                // Snapshot before change
                DataRow snap = MarksAuditLogger.SnapshotFaculty(conn, intId);
                
                string sql = @"UPDATE acad_examresults_faculty 
                              SET approved_by = '-' 
                              WHERE ID = @id AND approved_by != '-' AND approved_by IS NOT NULL AND approved_by != ''";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", intId);
                    int affected = cmd.ExecuteNonQuery();
                    if (affected > 0)
                    {
                        cancelledCount++;
                        if (snap != null)
                            MarksAuditLogger.LogFacultyApproval("UNAPPROVE", intId,
                                snap["regno"].ToString(), snap["course_id"].ToString(),
                                snap["acadyear"].ToString(), Convert.ToInt32(snap["semester"]),
                                snap["progid"].ToString(), snap["approved_by"].ToString(), "-",
                                "ExamApproval.aspx", batchId);
                    }
                }
            }
        }
        
        // Log the activity
        LogActivity("CANCEL_APPROVAL", string.Format("Cancelled approval for {0} results for course {1}", cancelledCount, 
            ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : ""));
        
        gvResults.Selection.UnselectAll();
        BindGrid();
        LoadStats();
        
        ShowMessage(string.Format("{0} approval(s) cancelled successfully.", cancelledCount));
    }
    
    #endregion
    
    #region Print/Export Actions
    
    protected void btnPrintMarksheet_Click(object sender, EventArgs e)
    {
        string progValue = ddlProgramme.SelectedItem != null ? ddlProgramme.SelectedItem.Value.ToString() : "";
        string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
        
        if (string.IsNullOrEmpty(progValue) || string.IsNullOrEmpty(courseValue))
        {
            ShowMessage("Please select a programme and course first.");
            return;
        }
        
        try
        {
            // Create the report instance
            FacultyMarksheet report = new FacultyMarksheet();
            
            // Set parameters
            report.Parameters["prog"].Value = progValue;
            report.Parameters["acad"].Value = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
            report.Parameters["sems"].Value = int.Parse(ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "1");
            report.Parameters["sess"].Value = ddlSession.SelectedItem != null ? ddlSession.SelectedItem.Value.ToString() : "DAY";
            report.Parameters["yr"].Value = int.Parse(ddlStudyYear.SelectedItem != null ? ddlStudyYear.SelectedItem.Value.ToString() : "1");
            report.Parameters["csid"].Value = courseValue;
            report.Parameters["stat"].Value = ddlExamStatus.SelectedItem != null ? ddlExamStatus.SelectedItem.Value.ToString() : "REGULAR";
            
            // Show in document viewer
            docViewer.Report = report;
            docViewer.DataBind();
            
            popPrintPreview.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            ShowMessage("Error generating marksheet: " + ex.Message);
        }
    }
    
    protected void btnPrintBlankSheet_Click(object sender, EventArgs e)
    {
        string progValue = ddlProgramme.SelectedItem != null ? ddlProgramme.SelectedItem.Value.ToString() : "";
        string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
        
        if (string.IsNullOrEmpty(progValue) || string.IsNullOrEmpty(courseValue))
        {
            ShowMessage("Please select a programme and course first.");
            return;
        }
        
        try
        {
            // Create the blank exam sheet report
            BlankExamSheet report = new BlankExamSheet();
            
            // Set parameters (similar to FacultyMarksheet)
            if (report.Parameters["prog"] != null)
                report.Parameters["prog"].Value = progValue;
            if (report.Parameters["acad"] != null)
                report.Parameters["acad"].Value = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
            if (report.Parameters["sems"] != null)
                report.Parameters["sems"].Value = int.Parse(ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "1");
            if (report.Parameters["sess"] != null)
                report.Parameters["sess"].Value = ddlSession.SelectedItem != null ? ddlSession.SelectedItem.Value.ToString() : "DAY";
            if (report.Parameters["yr"] != null)
                report.Parameters["yr"].Value = int.Parse(ddlStudyYear.SelectedItem != null ? ddlStudyYear.SelectedItem.Value.ToString() : "1");
            if (report.Parameters["csid"] != null)
                report.Parameters["csid"].Value = courseValue;
            
            docViewer.Report = report;
            docViewer.DataBind();
            
            popPrintPreview.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            ShowMessage("Error generating blank sheet: " + ex.Message);
        }
    }
    
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
        string acadYear = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
        string semester = ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "";
        string examStatus = ddlExamStatus.SelectedItem != null ? ddlExamStatus.SelectedItem.Value.ToString() : "";
        
        string fileName = string.Format("{0}_Marksheet_{1}_Sem{2}_{3}", examStatus, acadYear.Replace("/", "-"), semester, courseValue);
        
        gvExporter.WriteXlsToResponse(fileName);
    }
    
    protected void btnExportPDF_Click(object sender, EventArgs e)
    {
        string courseValue = ddlCourse.SelectedItem != null ? ddlCourse.SelectedItem.Value.ToString() : "";
        string acadYear = ddlAcadYear.SelectedItem != null ? ddlAcadYear.SelectedItem.Value.ToString() : "";
        string semester = ddlSemester.SelectedItem != null ? ddlSemester.SelectedItem.Value.ToString() : "";
        string examStatus = ddlExamStatus.SelectedItem != null ? ddlExamStatus.SelectedItem.Value.ToString() : "";
        
        string fileName = string.Format("{0}_Marksheet_{1}_Sem{2}_{3}", examStatus, acadYear.Replace("/", "-"), semester, courseValue);
        
        gvExporter.WritePdfToResponse(fileName);
    }
    
    #endregion
    
    protected void gvResults_CustomCallback(object sender, ASPxGridViewCustomCallbackEventArgs e)
    {
        // Handle any custom callbacks from the grid
        BindGrid();
        LoadStats();
    }
    
    private void ShowMessage(string message)
    {
        litMessage.Text = message;
        popMessage.ShowOnPageLoad = true;
    }
    
    private void LogActivity(string activityType, string description)
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
                    cmd.Parameters.AddWithValue("@func", "ExamApproval - " + activityType);
                    cmd.Parameters.AddWithValue("@par", description);
                    cmd.Parameters.AddWithValue("@comments", "IP: " + HttpContext.Current.Request.UserHostAddress);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch
        {
            // Silently fail logging - don't interrupt the main operation
        }
    }
}
