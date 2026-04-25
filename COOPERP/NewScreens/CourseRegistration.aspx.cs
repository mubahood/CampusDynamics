using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.XtraPrinting;

public partial class COOPERP_NewScreens_CourseRegistration : System.Web.UI.Page
{
    private const int QueryPageSize = 50;

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        // Master page has EnableViewState="false", so dynamic dropdowns must
        // be repopulated on EVERY request and selections restored from POST data.
        LoadAcademicYears();
        LoadProgrammes();
        LoadEntryYears();
        LoadQuickEditDropdowns();
        
        if (!IsPostBack)
        {
            // Set defaults on first load
            string defaultYear = AcademicYearHelper.GetCurrentAcademicYear();
            if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
                ddlAcadYear.SelectedValue = defaultYear;
            
            ddlEntryYear.SelectedValue = "-";

            ApplyFiltersFromQueryString();
            
            // Courses depend on programme/study-year/semester
            LoadCourses();
            ApplyCourseFromQueryString();
            
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
        }
        else
        {
            // Restore posted selections for dynamic dropdowns
            RestoreDropDownFromPost(ddlAcadYear);
            RestoreDropDownFromPost(ddlProgramme);
            RestoreDropDownFromPost(ddlEntryYear);
            
            // Static dropdowns (ddlStudyYear, ddlSemester, ddlIntake, ddlStatus)
            // are restored automatically by ASP.NET from markup + POST data.
            
            // Courses depend on programme/study-year/semester, reload then restore
            LoadCourses();
            RestoreDropDownFromPost(ddlCourse);
            
            UpdateDisplayLabels();
            
            // With ViewState off, SelectedIndexChanged never fires for dynamic
            // dropdowns (ddlAcadYear, ddlProgramme, ddlEntryYear, ddlCourse)
            // because RestoreDropDownFromPost already sets the value before
            // ASP.NET's 2nd ProcessPostData pass can detect a change.
            // Detect filter-dropdown postbacks and refresh the grid here.
            string eventTarget = Request.Form["__EVENTTARGET"] ?? "";
            bool isFilterChange = eventTarget.Contains("ddlAcadYear")
                               || eventTarget.Contains("ddlProgramme")
                               || eventTarget.Contains("ddlStudyYear")
                               || eventTarget.Contains("ddlSemester")
                               || eventTarget.Contains("ddlEntryYear")
                               || eventTarget.Contains("ddlIntake")
                               || eventTarget.Contains("ddlCourse")
                               || eventTarget.Contains("ddlStatus");
            
            if (isFilterChange)
            {
                LoadStats();
                BindGrid();
            }
            // Button clicks (Register, Remove, Retake) handle BindGrid themselves
            // after their work - don't call it here or it would wipe checkbox selections.
        }
    }
    
    /// <summary>
    /// Restores a dropdown's SelectedValue from the form POST data.
    /// Needed because EnableViewState="false" on the master page form means
    /// dynamically-populated dropdown items are lost on postback.
    /// </summary>
    private void RestoreDropDownFromPost(DropDownList ddl)
    {
        string posted = Request.Form[ddl.UniqueID];
        if (!string.IsNullOrEmpty(posted) && ddl.Items.FindByValue(posted) != null)
            ddl.SelectedValue = posted;
    }
    
    // Academic year logic centralised in AcademicYearHelper
    
    private void LoadAcademicYears()
    {
        AcademicYearHelper.PopulateDropDown(ddlAcadYear, false, false);
    }
    
    private void LoadEntryYears()
    {
        ddlEntryYear.Items.Clear();
        ddlEntryYear.Items.Add(new ListItem("-- All --", "-"));
        int cy = DateTime.Now.Year;
        for (int i = cy + 1; i >= cy - 10; i--)
            ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
    }
    
    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            // Get user's programmes using the stored procedure
            string username = HttpContext.Current.User.Identity.Name;
            
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
                        ddlProgramme.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
            
            // If no programmes found via permissions, load all programmes
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
                            ddlProgramme.Items.Add(new ListItem(code + " - " + name, code));
                        }
                    }
                }
            }
        }
    }
    
    private void LoadCourses()
    {
        ddlCourse.Items.Clear();
        ddlCourse.Items.Add(new ListItem("-- Select Course --", ""));
        
        if (string.IsNullOrEmpty(ddlProgramme.SelectedValue))
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
                cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                cmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedValue));
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["course_code"].ToString();
                        string name = reader["course_name"].ToString();
                        ddlCourse.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
        }
    }

    private void ApplyFiltersFromQueryString()
    {
        SetDropDownFromQuery(ddlAcadYear, "acad");
        SetDropDownFromQuery(ddlProgramme, "prog");
        SetDropDownFromQuery(ddlStudyYear, "yr");
        SetDropDownFromQuery(ddlSemester, "sem");
        SetDropDownFromQuery(ddlEntryYear, "entyr");
        SetDropDownFromQuery(ddlIntake, "intake");
        SetDropDownFromQuery(ddlStatus, "status");
        txtStudentFilter.Text = (Request.QueryString["student"] ?? string.Empty).Trim();
    }

    private void ApplyCourseFromQueryString()
    {
        SetDropDownFromQuery(ddlCourse, "course");
    }

    private void SetDropDownFromQuery(DropDownList ddl, string key)
    {
        string value = Request.QueryString[key];
        if (!string.IsNullOrEmpty(value) && ddl.Items.FindByValue(value) != null)
            ddl.SelectedValue = value;
    }
    
    private void UpdateDisplayLabels()
    {
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = "Yr " + ddlStudyYear.SelectedValue + ", Sem " + ddlSemester.SelectedValue;
    }
    
    private void LoadStats()
    {
        bool hasProgramme = !string.IsNullOrEmpty(ddlProgramme.SelectedValue);
        bool hasCourse = !string.IsNullOrEmpty(ddlCourse.SelectedValue);
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Count pending students (registered in programme but not course-registered)
            string sqlPending = @"SELECT COUNT(*) FROM acad_registration r
                                 INNER JOIN acad_student s ON r.regno = s.regno
                                 WHERE s.progid = @prog 
                                   AND r.studyyear = @yr
                                   AND r.acad_year = @acad
                                   AND r.regstatus IN ('REGISTERED', 'CLEARED', 'LATE REGISTERED')
                                   AND r.regno NOT IN (
                                       SELECT cr.regno FROM campus_dynamics_portal.acad_course_registration cr
                                       WHERE cr.courseID = @course 
                                         AND cr.acad_year = @acad 
                                         AND cr.semester = @sem
                                   )";
            
            if (hasProgramme && hasCourse)
            {
                using (MySqlCommand cmd = new MySqlCommand(sqlPending, conn))
                {
                    cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    cmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedValue));
                    cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    litPendingCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
                }
            }
            else
            {
                litPendingCount.Text = "0";
            }
            
            // Count registered students (Normal/Regular)
                        string sqlRegistered = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr
                                                                        WHERE cr.acad_year = @acad 
                                                                            AND cr.semester = @sem
                                                                            AND (@prog='' OR cr.prog_id = @prog)
                                                                            AND (@course='' OR cr.courseID = @course)
                                                                            AND (cr.course_status = 'NORMAL' OR cr.course_status = 'REGULAR')";
            
            using (MySqlCommand cmd = new MySqlCommand(sqlRegistered, conn))
            {
                cmd.Parameters.AddWithValue("@course", hasCourse ? ddlCourse.SelectedValue : "");
                cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                cmd.Parameters.AddWithValue("@prog", hasProgramme ? ddlProgramme.SelectedValue : "");
                litRegisteredCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
            
            // Count retake students
                        string sqlRetake = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr
                                                                WHERE cr.acad_year = @acad 
                                                                    AND cr.semester = @sem
                                                                    AND (@prog='' OR cr.prog_id = @prog)
                                                                    AND (@course='' OR cr.courseID = @course)
                                                                    AND cr.course_status = 'RETAKE'";
            
            using (MySqlCommand cmd = new MySqlCommand(sqlRetake, conn))
            {
                cmd.Parameters.AddWithValue("@course", hasCourse ? ddlCourse.SelectedValue : "");
                cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                cmd.Parameters.AddWithValue("@prog", hasProgramme ? ddlProgramme.SelectedValue : "");
                litRetakeCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
        }
    }
    
    private void BindGrid()
    {
        bool hasProgramme = !string.IsNullOrEmpty(ddlProgramme.SelectedValue);
        bool hasCourse = !string.IsNullOrEmpty(ddlCourse.SelectedValue);
        string studentTerm = (txtStudentFilter.Text ?? string.Empty).Trim();
        int requestedPage = GetRequestedPage();
        
        DataTable dt = new DataTable();
        int totalRows = 0;
        int totalPages = 1;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "";
            
            if (ddlStatus.SelectedValue == "Pending" && hasProgramme && hasCourse)
            {
                // Show students who are registered in the programme but not in this course
                sql = @"SELECT r.regno, 
                              CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) as stud_name,
                              COALESCE(sp.spec, NULLIF(s.specialisation, ''), '-') AS spec_name,
                              @course AS course_code,
                              @acad AS acad_year,
                              @sem AS semester,
                              COALESCE(s.entryyear, 0) AS entryyear,
                              COALESCE(s.intake, '-') AS intake,
                              COALESCE(r.regstatus, 'REGISTERED') AS reg_status,
                              'PENDING' as course_status
                       FROM acad_registration r
                       INNER JOIN acad_student s ON r.regno = s.regno
                       LEFT JOIN acad_specialisation sp ON s.specialisation = CAST(sp.spec_id AS CHAR)
                       WHERE s.progid = @prog 
                         AND r.studyyear = @yr
                         AND r.acad_year = @acad
                         AND r.regstatus IN ('REGISTERED', 'CLEARED', 'LATE REGISTERED')
                         AND r.regno NOT IN (
                             SELECT cr.regno FROM campus_dynamics_portal.acad_course_registration cr
                             WHERE cr.courseID = @course 
                               AND cr.acad_year = @acad 
                               AND cr.semester = @sem
                         )";

                                if (!string.IsNullOrEmpty(studentTerm))
                                {
                                        sql += " AND (r.regno LIKE @studentLike OR CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) LIKE @studentLike)";
                                }
                
                // Apply entry year filter
                if (ddlEntryYear.SelectedValue != "-" && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
                {
                    sql += " AND s.entryyear = @entyr";
                }
                
                // Apply intake filter
                if (ddlIntake.SelectedValue != "-")
                {
                    sql += " AND s.intake = @intake";
                }
                
                                sql += " ORDER BY s.firstname, s.othername";
                
                                btnRegisterSelected.Visible = true;
                                btnRemoveSelected.Visible = false;
            }
            else
            {
                                // Default/simple view: show already registered rows (all when no course/programme selected)
                                                                sql = @"SELECT cr.regno, 
                                                            CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) as stud_name,
                                                            COALESCE(sp.spec, NULLIF(s.specialisation, ''), '-') AS spec_name,
                                                            cr.courseID AS course_code,
                                                            cr.acad_year AS acad_year,
                                                            cr.semester AS semester,
                                                            COALESCE(s.entryyear, 0) AS entryyear,
                                                            COALESCE(s.intake, '-') AS intake,
                                                            'REGISTERED' AS reg_status,
                                                            cr.course_status
                       FROM campus_dynamics_portal.acad_course_registration cr
                       INNER JOIN acad_student s ON cr.regno = s.regno
                       LEFT JOIN acad_specialisation sp ON s.specialisation = CAST(sp.spec_id AS CHAR)
                                             WHERE cr.acad_year = @acad 
                         AND cr.semester = @sem
                                                 AND (@prog = '' OR cr.prog_id = @prog)
                                                 AND (@course = '' OR cr.courseID = @course)
                                                 AND (@entyr = 0 OR s.entryyear = @entyr)
                                                 AND (@intake = '-' OR s.intake = @intake)
                                                 AND (@student = '' OR cr.regno LIKE @studentLike OR CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) LIKE @studentLike)
                                             ORDER BY cr.acad_year DESC, cr.semester DESC, s.firstname, s.othername";
                
                                btnRegisterSelected.Visible = false;
                                btnRemoveSelected.Visible = hasCourse;
            }

            string countSql = "SELECT COUNT(*) FROM (" + sql + ") AS x";
            using (MySqlCommand countCmd = new MySqlCommand(countSql, conn))
            {
                AddGridParameters(countCmd, hasProgramme, hasCourse, studentTerm);
                totalRows = Convert.ToInt32(countCmd.ExecuteScalar());
            }

            totalPages = totalRows > 0 ? (int)Math.Ceiling(totalRows / (double)QueryPageSize) : 1;
            if (requestedPage > totalPages)
                requestedPage = totalPages;

            int offset = (requestedPage - 1) * QueryPageSize;
            string pagedSql = sql + " LIMIT @offset, @pageSize";
            
            using (MySqlCommand cmd = new MySqlCommand(pagedSql, conn))
            {
                AddGridParameters(cmd, hasProgramme, hasCourse, studentTerm);
                cmd.Parameters.AddWithValue("@offset", offset);
                cmd.Parameters.AddWithValue("@pageSize", QueryPageSize);
                
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }
        }
        
        gvCourseReg.DataSource = dt;
        gvCourseReg.DataBind();
        RenderQueryPager(requestedPage, totalPages, totalRows);
    }

    private void AddGridParameters(MySqlCommand cmd, bool hasProgramme, bool hasCourse, string studentTerm)
    {
        cmd.Parameters.AddWithValue("@prog", hasProgramme ? ddlProgramme.SelectedValue : "");
        cmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedValue));
        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
        cmd.Parameters.AddWithValue("@course", hasCourse ? ddlCourse.SelectedValue : "");
        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
        cmd.Parameters.AddWithValue("@student", studentTerm);
        cmd.Parameters.AddWithValue("@studentLike", string.IsNullOrEmpty(studentTerm) ? "%" : ("%" + studentTerm + "%"));

        if (ddlEntryYear.SelectedValue != "-" && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
            cmd.Parameters.AddWithValue("@entyr", int.Parse(ddlEntryYear.SelectedValue));
        else
            cmd.Parameters.AddWithValue("@entyr", 0);

        if (ddlIntake.SelectedValue != "-")
            cmd.Parameters.AddWithValue("@intake", ddlIntake.SelectedValue);
        else
            cmd.Parameters.AddWithValue("@intake", "-");
    }

    private int GetRequestedPage()
    {
        int page;
        if (int.TryParse(Request.QueryString["page"], out page) && page > 0)
            return page;
        return 1;
    }

    private void RenderQueryPager(int page, int totalPages, int totalRows)
    {
        if (totalRows <= QueryPageSize)
        {
            litQueryPager.Text = string.Empty;
            return;
        }

        StringBuilder html = new StringBuilder();
        html.Append("<div class='cr-query-pager'>");
        html.AppendFormat("<span class='meta'>Total: {0}</span>", totalRows);

        if (page > 1)
            html.AppendFormat("<a href='{0}'>&laquo; Prev</a>", BuildPagerUrl(page - 1));

        int start = Math.Max(1, page - 2);
        int end = Math.Min(totalPages, start + 4);
        start = Math.Max(1, end - 4);

        for (int i = start; i <= end; i++)
        {
            if (i == page)
                html.AppendFormat("<span class='active'>{0}</span>", i);
            else
                html.AppendFormat("<a href='{0}'>{1}</a>", BuildPagerUrl(i), i);
        }

        if (page < totalPages)
            html.AppendFormat("<a href='{0}'>Next &raquo;</a>", BuildPagerUrl(page + 1));

        html.AppendFormat("<span class='meta'>Page {0} of {1}</span>", page, totalPages);
        html.Append("</div>");
        litQueryPager.Text = html.ToString();
    }

    private string BuildPagerUrl(int page)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);
        query["page"] = page.ToString();
        query["acad"] = ddlAcadYear.SelectedValue;

        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            query["prog"] = ddlProgramme.SelectedValue;
        if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
            query["yr"] = ddlStudyYear.SelectedValue;
        if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
            query["sem"] = ddlSemester.SelectedValue;
        if (!string.IsNullOrEmpty(ddlEntryYear.SelectedValue) && ddlEntryYear.SelectedValue != "-")
            query["entyr"] = ddlEntryYear.SelectedValue;
        if (!string.IsNullOrEmpty(ddlIntake.SelectedValue) && ddlIntake.SelectedValue != "-")
            query["intake"] = ddlIntake.SelectedValue;
        if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
            query["course"] = ddlCourse.SelectedValue;
        if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
            query["status"] = ddlStatus.SelectedValue;
        if (!string.IsNullOrEmpty(txtStudentFilter.Text))
            query["student"] = txtStudentFilter.Text.Trim();

        return Request.Path + "?" + query.ToString();
    }
    
    protected string GetCourseStatusBadge(object status)
    {
        string statusStr = (status != null) ? status.ToString() : "PENDING";
        string cssClass = "cr-status-badge--pending";
        
        switch (statusStr.ToUpper())
        {
            case "REGISTERED":
            case "NORMAL":
            case "REGULAR":
                cssClass = "cr-status-badge--registered";
                statusStr = "REGISTERED";
                break;
            case "RETAKE":
                cssClass = "cr-status-badge--retake";
                break;
            case "PENDING":
            default:
                cssClass = "cr-status-badge--pending";
                break;
        }
        
        return string.Format("<span class=\"cr-status-badge {0}\">{1}</span>", cssClass, statusStr);
    }
    
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
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
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlEntryYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlIntake_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnRegisterSelected_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlCourse.SelectedValue))
        {
            ShowMessage("Please select a course first.", "error");
            LoadStats();
            BindGrid();
            return;
        }

        // Enforce semester active status — block registration if the semester is closed
        int semNumReg;
        if (!int.TryParse(ddlSemester.SelectedValue, out semNumReg) || !AcademicYearHelper.IsSemesterActive(semNumReg))
        {
            ShowMessage(string.Format(
                "Semester {0} is not currently open for course registration. " +
                "An administrator must set Semester {0} as active on the Academic Years page before registration can proceed.",
                ddlSemester.SelectedValue), "error");
            LoadStats();
            BindGrid();
            return;
        }

        int count = 0;
        int skipped = 0;
        List<string> errors = new List<string>();
        string username = HttpContext.Current.User.Identity.Name;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                List<object> selectedRows = gvCourseReg.GetSelectedFieldValues("regno");

                if (selectedRows.Count == 0)
                {
                    ShowMessage("No students selected. Please tick the checkboxes next to students you want to register.", "error");
                    LoadStats();
                    BindGrid();
                    return;
                }

                foreach (object row in selectedRows)
                {
                    string regno = row.ToString();
                    
                    try
                    {
                        // Check if already registered
                        string checkSql = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration 
                                           WHERE regno = @regno AND courseID = @course 
                                             AND acad_year = @acad AND semester = @sem";
                        
                        using (MySqlCommand checkCmd = new MySqlCommand(checkSql, conn))
                        {
                            checkCmd.Parameters.AddWithValue("@regno", regno);
                            checkCmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                            checkCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                            checkCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                            
                            if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                            {
                                skipped++;
                                continue;
                            }
                        }
                        
                        // Use the existing stored procedure for proper registration + logging
                        // Must use ExecuteReader to consume the SELECT result set the proc returns
                        using (MySqlCommand spCmd = new MySqlCommand("acad_CourseRegister", conn))
                        {
                            spCmd.CommandType = CommandType.StoredProcedure;
                            spCmd.Parameters.AddWithValue("@reg", regno);
                            spCmd.Parameters.AddWithValue("@csid", ddlCourse.SelectedValue);
                            spCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                            spCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                            spCmd.Parameters.AddWithValue("@cs_stat", "REGULAR");
                            spCmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                            spCmd.Parameters.AddWithValue("@usr", username);
                            spCmd.Parameters.AddWithValue("@act", "Pending");
                            using (MySqlDataReader rdr = spCmd.ExecuteReader())
                            {
                                // Consume the stored proc result set (the COMMIT runs after SELECT)
                                while (rdr.Read()) { }
                            }
                            count++;
                        }
                    }
                    catch (Exception ex)
                    {
                        errors.Add(regno + ": " + ex.Message);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Database error: " + ex.Message, "error");
            LoadStats();
            BindGrid();
            return;
        }
        
        // Build result message
        string msg = "";
        if (count > 0)
            msg += count + " student(s) registered successfully. ";
        if (skipped > 0)
            msg += skipped + " already registered (skipped). ";
        if (errors.Count > 0)
            msg += "Errors: " + string.Join("; ", errors.ToArray());
        
        if (errors.Count > 0)
            ShowMessage(msg, "error");
        else if (count > 0)
            ShowMessage(msg, "success");
        else
            ShowMessage("No students were registered. " + msg, "info");
        
        gvCourseReg.Selection.UnselectAll();
        LoadStats();
        BindGrid();
    }
    
    protected void btnRemoveSelected_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlCourse.SelectedValue))
        {
            ShowMessage("Please select a course first.", "error");
            LoadStats();
            BindGrid();
            return;
        }

        int count = 0;
        List<string> errors = new List<string>();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<object> selectedRows = gvCourseReg.GetSelectedFieldValues("regno");
                
                if (selectedRows.Count == 0)
                {
                    ShowMessage("No students selected. Please tick the checkboxes next to students you want to remove.", "error");
                    LoadStats();
                    BindGrid();
                    return;
                }
                
                string username = HttpContext.Current.User.Identity.Name;
                
                foreach (object row in selectedRows)
                {
                    string regno = row.ToString();
                    
                    try
                    {
                        // Use stored proc for proper de-registration + logging
                        using (MySqlCommand spCmd = new MySqlCommand("acad_CourseRegister", conn))
                        {
                            spCmd.CommandType = CommandType.StoredProcedure;
                            spCmd.Parameters.AddWithValue("@reg", regno);
                            spCmd.Parameters.AddWithValue("@csid", ddlCourse.SelectedValue);
                            spCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                            spCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                            spCmd.Parameters.AddWithValue("@cs_stat", "NORMAL");
                            spCmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                            spCmd.Parameters.AddWithValue("@usr", username);
                            spCmd.Parameters.AddWithValue("@act", "Registered");
                            using (MySqlDataReader rdr = spCmd.ExecuteReader())
                            {
                                while (rdr.Read()) { }
                            }
                            count++;
                        }
                    }
                    catch (Exception ex)
                    {
                        errors.Add(regno + ": " + ex.Message);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Database error: " + ex.Message, "error");
            LoadStats();
            BindGrid();
            return;
        }
        
        string msg = "";
        if (count > 0)
            msg += count + " registration(s) removed successfully. ";
        if (errors.Count > 0)
            msg += "Errors: " + string.Join("; ", errors.ToArray());
        
        if (errors.Count > 0)
            ShowMessage(msg, "error");
        else if (count > 0)
            ShowMessage(msg, "success");
        else
            ShowMessage("No registrations were removed.", "info");
        
        gvCourseReg.Selection.UnselectAll();
        LoadStats();
        BindGrid();
    }
    
    protected void btnAddRetake_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlCourse.SelectedValue))
        {
            ShowMessage("Please select a course first.", "error");
            LoadStats();
            BindGrid();
            return;
        }
        
        if (string.IsNullOrEmpty(txtRetakeRegNo.Text.Trim()))
        {
            ShowMessage("Please enter a student registration number.", "error");
            LoadStats();
            BindGrid();
            return;
        }
        
        string regno = txtRetakeRegNo.Text.Trim();
        string recordType = (ddlNewRecordType.SelectedValue ?? "REGULAR").Trim().ToUpper();
        if (recordType != "RETAKE") recordType = "REGULAR";
        string username = HttpContext.Current.User.Identity.Name;

        // Enforce semester active status — block retake registration if semester is closed
        int semNumRtk;
        if (!int.TryParse(ddlSemester.SelectedValue, out semNumRtk) || !AcademicYearHelper.IsSemesterActive(semNumRtk))
        {
            ShowMessage(string.Format(
                "Semester {0} is not currently open for course registration. " +
                "An administrator must set Semester {0} as active on the Academic Years page before registration can proceed.",
                ddlSemester.SelectedValue), "error");
            LoadStats();
            BindGrid();
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Check if student exists and get programme
                string studentProg = "";
                string checkStudentSql = "SELECT progid FROM acad_student WHERE regno = @regno LIMIT 1";
                using (MySqlCommand checkCmd = new MySqlCommand(checkStudentSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regno);
                    object progObj = checkCmd.ExecuteScalar();
                    if (progObj == null || progObj == DBNull.Value)
                    {
                        ShowMessage("Student with registration number '" + regno + "' not found.", "error");
                        LoadStats();
                        BindGrid();
                        return;
                    }
                    studentProg = progObj.ToString();
                }

                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue)
                    && !string.Equals(ddlProgramme.SelectedValue, studentProg, StringComparison.OrdinalIgnoreCase))
                {
                    ShowMessage("Selected student does not belong to the selected programme.", "error");
                    LoadStats();
                    BindGrid();
                    return;
                }

                if (recordType == "REGULAR")
                {
                    string checkSemesterRegSql = @"SELECT COUNT(*) FROM acad_registration
                                                   WHERE regno=@regno
                                                     AND acad_year=@acad
                                                     AND studyyear=@yr
                                                     AND regstatus IN ('REGISTERED','CLEARED','LATE REGISTERED')";
                    using (MySqlCommand semCmd = new MySqlCommand(checkSemesterRegSql, conn))
                    {
                        semCmd.Parameters.AddWithValue("@regno", regno);
                        semCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                        semCmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedValue));
                        if (Convert.ToInt32(semCmd.ExecuteScalar()) == 0)
                        {
                            ShowMessage("Student is not semester-registered for the selected academic year/study year.", "error");
                            LoadStats();
                            BindGrid();
                            return;
                        }
                    }
                }
                
                // Check if already registered for this course
                string checkRegSql = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration 
                                      WHERE regno = @regno AND courseID = @course 
                                        AND acad_year = @acad AND semester = @sem";
                
                using (MySqlCommand checkCmd = new MySqlCommand(checkRegSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regno);
                    checkCmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    checkCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    checkCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    
                    if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                    {
                        ShowMessage("Student is already registered for this course in the selected year/semester.", "error");
                        LoadStats();
                        BindGrid();
                        return;
                    }
                }
                
                // Use stored procedure for proper registration handling + logging
                using (MySqlCommand spCmd = new MySqlCommand("acad_CourseRegister", conn))
                {
                    spCmd.CommandType = CommandType.StoredProcedure;
                    spCmd.Parameters.AddWithValue("@reg", regno);
                    spCmd.Parameters.AddWithValue("@csid", ddlCourse.SelectedValue);
                    spCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    spCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    spCmd.Parameters.AddWithValue("@cs_stat", recordType);
                    spCmd.Parameters.AddWithValue("@prog", !string.IsNullOrEmpty(ddlProgramme.SelectedValue) ? ddlProgramme.SelectedValue : studentProg);
                    spCmd.Parameters.AddWithValue("@usr", username);
                    spCmd.Parameters.AddWithValue("@act", "Pending");
                    using (MySqlDataReader rdr = spCmd.ExecuteReader())
                    {
                        while (rdr.Read()) { }
                    }
                }
            }
            
            ShowMessage((recordType == "RETAKE" ? "Retake" : "Regular") + " record added successfully for student: " + regno, "success");
            txtRetakeRegNo.Text = "";
            ScriptManager.RegisterStartupScript(this, GetType(), "closeRetakeModal", "closeRetakeModal();", true);
        }
        catch (Exception ex)
        {
            ShowMessage("Error adding new record: " + ex.Message, "error");
        }
        
        LoadStats();
        BindGrid();
    }
    
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        string fileName = string.Format("CourseRegistration_{0}_{1}_Sem{2}", 
            ddlProgramme.SelectedValue, ddlAcadYear.SelectedValue.Replace("/", "-"), ddlSemester.SelectedValue);
        gvExporter.WriteXlsxToResponse(fileName, new XlsxExportOptionsEx { ExportType = DevExpress.Export.ExportType.WYSIWYG });
    }
    
    protected void gvCourseReg_CustomCallback(object sender, DevExpress.Web.ASPxGridViewCustomCallbackEventArgs e)
    {
        BindGrid();
    }
    
    private void ShowMessage(string message, string type)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "cr-message show cr-message--" + type;
        litMessage.Text = message;
    }
    
    // ===============================================================
    //  QUICK EDIT MODAL
    // ===============================================================
    
    private void LoadQuickEditDropdowns()
    {
        // Sessions
        ddlQeSession.Items.Clear();
        
        // Campuses
        ddlQeCampus.Items.Clear();
        
        // Entry Years
        ddlQeEntryYear.Items.Clear();
        ddlQeEntryYear.Items.Add(new ListItem("-- Select Year --", ""));
        int cy = DateTime.Now.Year;
        for (int y = cy + 1; y >= cy - 20; y--)
            ddlQeEntryYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        
        // Billing (from accounts database)
        ddlQeBilling.Items.Clear();
        ddlQeBilling.Items.Add(new ListItem("-- Select --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Sessions
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT DISTINCT studsesion FROM acad_student WHERE studsesion != '' ORDER BY studsesion", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeSession.Items.Add(new ListItem(
                            rdr["studsesion"].ToString(), rdr["studsesion"].ToString()));
                
                // Campuses
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT campus_code, campus_name FROM acad_campuses WHERE campus_code != '00' ORDER BY campus_name", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeCampus.Items.Add(new ListItem(
                            rdr["campus_name"].ToString(), rdr["campus_code"].ToString()));
                
            }
        }
        catch { }
        
        // Billing systems (separate database)
        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT ID, bs_name FROM fin_billing_systems ORDER BY bs_name", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeBilling.Items.Add(new ListItem(
                            rdr["bs_name"].ToString(), rdr["ID"].ToString()));
            }
        }
        catch { }
    }
    
    protected void btnQeLoad_Click(object sender, EventArgs e)
    {
        string regno = (hfQeRegNo.Value ?? "").Trim();
        if (string.IsNullOrEmpty(regno)) return;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                string sql = @"SELECT regno, entryno, firstname, othername, gender,
                                      dob, national_id, studPhone, email, nationality,
                                      religion, progid, studsesion,
                                      studCampus, entryyear, entrymethod, intake,
                                      billingID, stud_status, new_status, home_dist
                               FROM acad_student
                               WHERE regno = @rn LIMIT 1";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@rn", regno);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                        {
                            QeMsg("Student not found: " + regno, "err");
                            return;
                        }
                        
                        // Populate read-only fields via JS
                        string regNoVal = rdr["regno"].ToString();
                        string entryNoVal = rdr["entryno"] != DBNull.Value ? rdr["entryno"].ToString() : "-";
                        
                        // Personal fields
                        txtQeFirstName.Text = rdr["firstname"] != DBNull.Value ? rdr["firstname"].ToString() : "";
                        txtQeOtherName.Text = rdr["othername"] != DBNull.Value ? rdr["othername"].ToString() : "";
                        
                        string gender = rdr["gender"] != DBNull.Value ? rdr["gender"].ToString() : "MALE";
                        if (ddlQeGender.Items.FindByValue(gender) != null)
                            ddlQeGender.SelectedValue = gender;
                        
                        if (rdr["dob"] != DBNull.Value)
                        {
                            DateTime dob = Convert.ToDateTime(rdr["dob"]);
                            txtQeDOB.Text = dob.ToString("yyyy-MM-dd");
                        }
                        else
                        {
                            txtQeDOB.Text = "";
                        }
                        
                        txtQeNIN.Text = rdr["national_id"] != DBNull.Value ? rdr["national_id"].ToString() : "";
                        txtQePhone.Text = rdr["studPhone"] != DBNull.Value ? rdr["studPhone"].ToString() : "";
                        txtQeEmail.Text = rdr["email"] != DBNull.Value ? rdr["email"].ToString() : "";
                        txtQeNationality.Text = rdr["nationality"] != DBNull.Value ? rdr["nationality"].ToString() : "";
                        txtQeDistrict.Text = rdr["home_dist"] != DBNull.Value ? rdr["home_dist"].ToString() : "";
                        
                        string religion = rdr["religion"] != DBNull.Value ? rdr["religion"].ToString() : "-";
                        if (ddlQeReligion.Items.FindByValue(religion) != null)
                            ddlQeReligion.SelectedValue = religion;
                        
                        // Academic fields
                        string session = rdr["studsesion"] != DBNull.Value ? rdr["studsesion"].ToString() : "";
                        if (ddlQeSession.Items.FindByValue(session) != null)
                            ddlQeSession.SelectedValue = session;
                        
                        // Campus: DB stores int (1,2), dropdown values are zero-padded ("01","02")
                        int campusInt = 0;
                        if (rdr["studCampus"] != DBNull.Value)
                            int.TryParse(rdr["studCampus"].ToString(), out campusInt);
                        if (campusInt > 0)
                        {
                            string campusPad = campusInt.ToString().PadLeft(2, '0');
                            if (ddlQeCampus.Items.FindByValue(campusPad) != null)
                                ddlQeCampus.SelectedValue = campusPad;
                        }
                        
                        int entryYr = 0;
                        if (rdr["entryyear"] != DBNull.Value)
                            int.TryParse(rdr["entryyear"].ToString(), out entryYr);
                        if (entryYr > 0)
                        {
                            string eyStr = entryYr.ToString();
                            if (ddlQeEntryYear.Items.FindByValue(eyStr) == null)
                                ddlQeEntryYear.Items.Insert(0, new ListItem(eyStr, eyStr));
                            ddlQeEntryYear.SelectedValue = eyStr;
                        }
                        
                        string entryMethod = rdr["entrymethod"] != DBNull.Value ? rdr["entrymethod"].ToString() : "DIRECT";
                        if (ddlQeEntryMethod.Items.FindByValue(entryMethod) != null)
                            ddlQeEntryMethod.SelectedValue = entryMethod;
                        
                        string intake = rdr["intake"] != DBNull.Value ? rdr["intake"].ToString() : "AUGUST";
                        if (ddlQeIntakeEdit.Items.FindByValue(intake) != null)
                            ddlQeIntakeEdit.SelectedValue = intake;
                        
                        int billingId = 0;
                        if (rdr["billingID"] != DBNull.Value)
                            int.TryParse(rdr["billingID"].ToString(), out billingId);
                        if (billingId > 0 && ddlQeBilling.Items.FindByValue(billingId.ToString()) != null)
                            ddlQeBilling.SelectedValue = billingId.ToString();
                        
                        // Status
                        string studStatus = rdr["stud_status"] != DBNull.Value ? rdr["stud_status"].ToString() : "ACTIVE";
                        if (ddlQeStatus.Items.FindByValue(studStatus) != null)
                            ddlQeStatus.SelectedValue = studStatus;
                        
                        string newStatus = rdr["new_status"] != DBNull.Value ? rdr["new_status"].ToString() : "ADMITTED";
                        if (ddlQeNewStatus.Items.FindByValue(newStatus) != null)
                            ddlQeNewStatus.SelectedValue = newStatus;
                        
                        // Set JS-side fields and show modal
                        string jsRegNo = regNoVal.Replace("'", "\\'");
                        string jsEntryNo = entryNoVal.Replace("'", "\\'");
                        
                        ScriptManager.RegisterStartupScript(this, GetType(), "qeShow",
                            "document.getElementById('qeRegNo').value='" + jsRegNo + "';" +
                            "document.getElementById('qeEntryNo').value='" + jsEntryNo + "';" +
                            "document.getElementById('qeTitle').innerText='Quick Edit: " + jsRegNo + "';" +
                            "showQuickEditModal();", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            QeMsg("Error loading student: " + ex.Message, "err");
        }
    }
    
    protected void btnQeSave_Click(object sender, EventArgs e)
    {
        string regno = (hfQeRegNo.Value ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            QeMsg("No student selected.", "err");
            return;
        }
        
        try
        {
            // --- Gather & sanitise all form values ---
            string firstName = (txtQeFirstName.Text ?? "").Trim().ToUpper();
            string otherName = (txtQeOtherName.Text ?? "").Trim().ToUpper();
            string gender = ddlQeGender.SelectedValue ?? "MALE";
            string dobStr = (txtQeDOB.Text ?? "").Trim();
            string nin = (txtQeNIN.Text ?? "").Trim().ToUpper();
            string phone = (txtQePhone.Text ?? "").Trim();
            string email = (txtQeEmail.Text ?? "").Trim();
            string nationality = (txtQeNationality.Text ?? "").Trim().ToUpper();
            string district = (txtQeDistrict.Text ?? "").Trim().ToUpper();
            string religion = ddlQeReligion.SelectedValue ?? "-";
            string session = ddlQeSession.SelectedValue ?? "";
            string entryMethod = ddlQeEntryMethod.SelectedValue ?? "DIRECT";
            string intake = ddlQeIntakeEdit.SelectedValue ?? "AUGUST";
            string studStatus = ddlQeStatus.SelectedValue ?? "ACTIVE";
            string newStatus = ddlQeNewStatus.SelectedValue ?? "ADMITTED";
            
            // --- Validation ---
            if (string.IsNullOrEmpty(firstName))
            { QeMsg("First Name is required.", "err"); return; }
            if (string.IsNullOrEmpty(phone))
            { QeMsg("Phone number is required.", "err"); return; }
            if (string.IsNullOrEmpty(session))
            { QeMsg("Please select a Study Session.", "err"); return; }

            // Campus: dropdown value "01" → int 1 for DB
            int campusInt = 1;
            string campusVal = ddlQeCampus.SelectedValue;
            if (!string.IsNullOrEmpty(campusVal))
                int.TryParse(campusVal, out campusInt);
            if (campusInt <= 0) campusInt = 1;
            
            // Entry year
            int entryYear = DateTime.Now.Year;
            string eyVal = ddlQeEntryYear.SelectedValue;
            if (!string.IsNullOrEmpty(eyVal))
                int.TryParse(eyVal, out entryYear);
            
            // Billing
            int billingId = 1;
            string billVal = ddlQeBilling.SelectedValue;
            if (!string.IsNullOrEmpty(billVal))
                int.TryParse(billVal, out billingId);
            if (billingId <= 0) billingId = 1;
            
            // Parse DOB safely
            DateTime dob = new DateTime(1980, 1, 1);
            if (!string.IsNullOrEmpty(dobStr))
            {
                DateTime parsed;
                if (DateTime.TryParse(dobStr, out parsed))
                    dob = parsed;
            }

            // Default empty fields
            if (string.IsNullOrEmpty(nationality)) nationality = "UGANDAN";
            if (string.IsNullOrEmpty(district)) district = "UGANDA";

            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // --- UPDATE acad_student ---
                string sql = @"UPDATE acad_student SET
                    firstname      = @firstName,
                    othername      = @otherName,
                    gender         = @gender,
                    dob            = @dob,
                    national_id    = @nin,
                    studPhone      = @phone,
                    email          = @email,
                    nationality    = @nationality,
                    religion       = @religion,
                    studsesion     = @session,
                    studCampus     = @campus,
                    entryyear      = @entryYear,
                    entrymethod    = @entryMethod,
                    intake         = @intake,
                    billingID      = @billingId,
                    stud_status    = @studStatus,
                    new_status     = @newStatus,
                    home_dist      = @district
                WHERE regno = @regno";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 30;
                    cmd.Parameters.AddWithValue("@firstName",   firstName);
                    cmd.Parameters.AddWithValue("@otherName",   otherName);
                    cmd.Parameters.AddWithValue("@gender",      gender);
                    cmd.Parameters.AddWithValue("@dob",         dob);
                    cmd.Parameters.AddWithValue("@nin",         nin);
                    cmd.Parameters.AddWithValue("@phone",       phone);
                    cmd.Parameters.AddWithValue("@email",       email);
                    cmd.Parameters.AddWithValue("@nationality", nationality);
                    cmd.Parameters.AddWithValue("@religion",    religion);
                    cmd.Parameters.AddWithValue("@session",     session);
                    cmd.Parameters.AddWithValue("@campus",      campusInt);
                    cmd.Parameters.AddWithValue("@entryYear",   entryYear);
                    cmd.Parameters.AddWithValue("@entryMethod", entryMethod);
                    cmd.Parameters.AddWithValue("@intake",      intake);
                    cmd.Parameters.AddWithValue("@billingId",   billingId);
                    cmd.Parameters.AddWithValue("@studStatus",  studStatus);
                    cmd.Parameters.AddWithValue("@newStatus",   newStatus);
                    cmd.Parameters.AddWithValue("@district",    district);
                    cmd.Parameters.AddWithValue("@regno",       regno);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows == 0)
                    {
                        QeMsg("Student record not found. It may have been deleted.", "err");
                        return;
                    }
                }

                // --- Also update acad_applications if record exists ---
                try
                {
                    string entryNo = "";
                    using (MySqlCommand cmd2 = new MySqlCommand(
                        "SELECT entryno FROM acad_student WHERE regno=@r LIMIT 1", conn))
                    {
                        cmd2.Parameters.AddWithValue("@r", regno);
                        object val = cmd2.ExecuteScalar();
                        if (val != null && val != DBNull.Value)
                            entryNo = val.ToString();
                    }

                    if (!string.IsNullOrEmpty(entryNo) && entryNo != "-")
                    {
                        using (MySqlCommand cmd3 = new MySqlCommand(@"
                            UPDATE acad_applications SET
                                stud_name        = @name,
                                stud_sex         = @sex,
                                stud_nationality = @nationality,
                                stud_religion    = @religion,
                                stud_phone       = @phone,
                                stud_email       = @email,
                                stud_birthdate   = @dob,
                                stud_campus      = @campus,
                                stud_intake      = @intake,
                                national_id      = @nin,
                                home_district    = @district,
                                billingID        = @billingId
                            WHERE stud_entry_no = @eno", conn))
                        {
                            cmd3.CommandTimeout = 15;
                            cmd3.Parameters.AddWithValue("@name",        firstName + " " + otherName);
                            cmd3.Parameters.AddWithValue("@sex",         gender);
                            cmd3.Parameters.AddWithValue("@nationality", nationality);
                            cmd3.Parameters.AddWithValue("@religion",    religion);
                            cmd3.Parameters.AddWithValue("@phone",       phone);
                            cmd3.Parameters.AddWithValue("@email",       email);
                            cmd3.Parameters.AddWithValue("@dob",         dob);
                            cmd3.Parameters.AddWithValue("@campus",      campusVal ?? "01");
                            cmd3.Parameters.AddWithValue("@intake",      intake);
                            cmd3.Parameters.AddWithValue("@nin",         nin);
                            cmd3.Parameters.AddWithValue("@district",    district);
                            cmd3.Parameters.AddWithValue("@billingId",   billingId);
                            cmd3.Parameters.AddWithValue("@eno",         entryNo);
                            cmd3.ExecuteNonQuery();
                        }
                    }
                }
                catch { /* application sync failure should not block save */ }
            }
            
            QeMsg("Student updated successfully.", "ok");
            
            // Refresh the grid to show updated data
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            QeMsg("Error saving: " + ex.Message, "err");
        }
    }

    /// <summary>Show a message inside the quick-edit modal.</summary>
    private void QeMsg(string msg, string type)
    {
        string safeMsg = msg.Replace("'", "").Replace("\\", "").Replace("\r", "").Replace("\n", " ");
        ScriptManager.RegisterStartupScript(this, GetType(), "qeMsg",
            "qeShowMsg('" + safeMsg + "','" + type + "');showQuickEditModal();", true);
    }

    protected void btnPrintResults_Click(object sender, EventArgs e)
    {
        string regno = hfQeRegNo.Value;
        if (string.IsNullOrEmpty(regno))
            return;

        Session["regno"] = regno;
        Session["Report"] = "ResultStatement";

        string script = "window.open('../XtraReports/Default.aspx', 'PrintResults', 'width=1050,height=780,scrollbars=yes,resizable=yes');";
        ScriptManager.RegisterStartupScript(this, GetType(), "printResults", script, true);
    }
}
