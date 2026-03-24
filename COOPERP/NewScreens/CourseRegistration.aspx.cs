using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.XtraPrinting;

public partial class COOPERP_NewScreens_CourseRegistration : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
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
            
            // Courses depend on programme/study-year/semester
            LoadCourses();
            
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
            // after their work — don't call it here or it would wipe checkbox selections.
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
    
    private void UpdateDisplayLabels()
    {
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
    }
    
    private void LoadStats()
    {
        if (string.IsNullOrEmpty(ddlProgramme.SelectedValue) || string.IsNullOrEmpty(ddlCourse.SelectedValue))
        {
            litPendingCount.Text = "0";
            litRegisteredCount.Text = "0";
            litRetakeCount.Text = "0";
            return;
        }
        
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
            
            using (MySqlCommand cmd = new MySqlCommand(sqlPending, conn))
            {
                cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                cmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedValue));
                cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                litPendingCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
            
            // Count registered students (Normal/Regular)
            string sqlRegistered = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr
                                    WHERE cr.courseID = @course 
                                      AND cr.acad_year = @acad 
                                      AND cr.semester = @sem
                                      AND cr.prog_id = @prog
                                      AND (cr.course_status = 'NORMAL' OR cr.course_status = 'REGULAR')";
            
            using (MySqlCommand cmd = new MySqlCommand(sqlRegistered, conn))
            {
                cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                litRegisteredCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
            
            // Count retake students
            string sqlRetake = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr
                                WHERE cr.courseID = @course 
                                  AND cr.acad_year = @acad 
                                  AND cr.semester = @sem
                                  AND cr.prog_id = @prog
                                  AND cr.course_status = 'RETAKE'";
            
            using (MySqlCommand cmd = new MySqlCommand(sqlRetake, conn))
            {
                cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                litRetakeCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
        }
    }
    
    private void BindGrid()
    {
        if (string.IsNullOrEmpty(ddlProgramme.SelectedValue) || string.IsNullOrEmpty(ddlCourse.SelectedValue))
        {
            gvCourseReg.DataSource = null;
            gvCourseReg.DataBind();
            return;
        }
        
        DataTable dt = new DataTable();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "";
            
            if (ddlStatus.SelectedValue == "Pending")
            {
                // Show students who are registered in the programme but not in this course
                sql = @"SELECT r.regno, 
                              CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) as stud_name,
                              COALESCE(sp.spec, NULLIF(s.specialisation, ''), '-') AS spec_name,
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
                // Show students who are already registered in this course
                sql = @"SELECT cr.regno, 
                              CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) as stud_name,
                              COALESCE(sp.spec, NULLIF(s.specialisation, ''), '-') AS spec_name,
                              cr.course_status
                       FROM campus_dynamics_portal.acad_course_registration cr
                       INNER JOIN acad_student s ON cr.regno = s.regno
                       LEFT JOIN acad_specialisation sp ON s.specialisation = CAST(sp.spec_id AS CHAR)
                       WHERE cr.courseID = @course 
                         AND cr.acad_year = @acad 
                         AND cr.semester = @sem
                         AND cr.prog_id = @prog
                       ORDER BY s.firstname, s.othername";
                
                btnRegisterSelected.Visible = false;
                btnRemoveSelected.Visible = true;
            }
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                cmd.Parameters.AddWithValue("@yr", int.Parse(ddlStudyYear.SelectedValue));
                cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                
                if (ddlEntryYear.SelectedValue != "-" && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
                    cmd.Parameters.AddWithValue("@entyr", int.Parse(ddlEntryYear.SelectedValue));
                
                if (ddlIntake.SelectedValue != "-")
                    cmd.Parameters.AddWithValue("@intake", ddlIntake.SelectedValue);
                
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }
        }
        
        gvCourseReg.DataSource = dt;
        gvCourseReg.DataBind();
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
        string username = HttpContext.Current.User.Identity.Name;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Check if student exists
                string checkStudentSql = "SELECT COUNT(*) FROM acad_student WHERE regno = @regno";
                using (MySqlCommand checkCmd = new MySqlCommand(checkStudentSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regno);
                    if (Convert.ToInt32(checkCmd.ExecuteScalar()) == 0)
                    {
                        ShowMessage("Student with registration number '" + regno + "' not found.", "error");
                        LoadStats();
                        BindGrid();
                        return;
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
                        ShowMessage("Student is already registered for this course.", "error");
                        LoadStats();
                        BindGrid();
                        return;
                    }
                }
                
                // Use stored procedure for proper retake handling (acc_redo_info, acad_results, logging)
                using (MySqlCommand spCmd = new MySqlCommand("acad_CourseRegister", conn))
                {
                    spCmd.CommandType = CommandType.StoredProcedure;
                    spCmd.Parameters.AddWithValue("@reg", regno);
                    spCmd.Parameters.AddWithValue("@csid", ddlCourse.SelectedValue);
                    spCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    spCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    spCmd.Parameters.AddWithValue("@cs_stat", "RETAKE");
                    spCmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    spCmd.Parameters.AddWithValue("@usr", username);
                    spCmd.Parameters.AddWithValue("@act", "Pending");
                    using (MySqlDataReader rdr = spCmd.ExecuteReader())
                    {
                        while (rdr.Read()) { }
                    }
                }
            }
            
            ShowMessage("Retake case added successfully for student: " + regno, "success");
            txtRetakeRegNo.Text = "";
        }
        catch (Exception ex)
        {
            ShowMessage("Error adding retake: " + ex.Message, "error");
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
    
    // ═══════════════════════════════════════════════════════════════
    //  QUICK EDIT MODAL
    // ═══════════════════════════════════════════════════════════════
    
    private void LoadQuickEditDropdowns()
    {
        // Specialisations
        ddlQeSpec.Items.Clear();
        ddlQeSpec.Items.Add(new ListItem("-- None --", ""));
        
        // Sessions
        ddlQeSession.Items.Clear();
        
        // Campuses
        ddlQeCampus.Items.Clear();
        
        // Entry Years
        ddlQeEntryYear.Items.Clear();
        int cy = DateTime.Now.Year;
        for (int y = cy + 1; y >= cy - 20; y--)
            ddlQeEntryYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        
        // Billing
        ddlQeBilling.Items.Clear();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Specialisations (active, non-dash)
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT spec_id, spec, prog_id FROM acad_specialisation WHERE spec != '-' AND is_active='Active' ORDER BY spec", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeSpec.Items.Add(new ListItem(
                            rdr["spec"].ToString(), rdr["spec_id"].ToString()));
                
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
                
                // Billing
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT billingID, billingName FROM acc_billing_system ORDER BY billingName", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeBilling.Items.Add(new ListItem(
                            rdr["billingName"].ToString(), rdr["billingID"].ToString()));
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
                
                string sql = @"SELECT s.regno, s.entryno, s.firstname, s.othername, s.gender,
                                      s.dob, s.national_id, s.studPhone, s.email, s.nationality,
                                      s.religion, s.progid, s.specialisation, s.studsesion,
                                      s.studCampus, s.entryyear, s.entrymethod, s.intake,
                                      s.billingID, s.stud_status, s.new_status,
                                      p.prog_name
                               FROM acad_student s
                               LEFT JOIN acad_programme p ON s.progid = p.prog_code
                               WHERE s.regno = @rn LIMIT 1";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@rn", regno);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                        {
                            ScriptManager.RegisterStartupScript(this, GetType(), "qeErr",
                                "qeShowMsg('Student not found: " + regno.Replace("'", "") + "','err');showQuickEditModal();", true);
                            return;
                        }
                        
                        // Populate read-only fields via JS
                        string regNoVal = rdr["regno"].ToString();
                        string entryNoVal = rdr["entryno"] != DBNull.Value ? rdr["entryno"].ToString() : "-";
                        string progDisplay = rdr["progid"].ToString();
                        if (rdr["prog_name"] != DBNull.Value && rdr["prog_name"].ToString() != "")
                            progDisplay = rdr["progid"].ToString() + " - " + rdr["prog_name"].ToString();
                        
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
                        
                        string religion = rdr["religion"] != DBNull.Value ? rdr["religion"].ToString() : "-";
                        if (ddlQeReligion.Items.FindByValue(religion) != null)
                            ddlQeReligion.SelectedValue = religion;
                        
                        // Academic fields
                        // Specialisation: DB stores spec_id as string. Try numeric match first.
                        string specVal = rdr["specialisation"] != DBNull.Value ? rdr["specialisation"].ToString() : "";
                        bool specFound = false;
                        int specIdNum;
                        if (int.TryParse(specVal, out specIdNum) && specIdNum > 0)
                        {
                            if (ddlQeSpec.Items.FindByValue(specIdNum.ToString()) != null)
                            {
                                ddlQeSpec.SelectedValue = specIdNum.ToString();
                                specFound = true;
                            }
                        }
                        if (!specFound)
                        {
                            // Try matching by name (for text-based data)
                            foreach (ListItem item in ddlQeSpec.Items)
                            {
                                if (item.Text == specVal)
                                {
                                    ddlQeSpec.SelectedValue = item.Value;
                                    break;
                                }
                            }
                        }
                        
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
                        string jsProg = progDisplay.Replace("'", "\\'");
                        
                        ScriptManager.RegisterStartupScript(this, GetType(), "qeShow",
                            "document.getElementById('qeRegNo').value='" + jsRegNo + "';" +
                            "document.getElementById('qeEntryNo').value='" + jsEntryNo + "';" +
                            "document.getElementById('qeProgDisplay').value='" + jsProg + "';" +
                            "document.getElementById('qeTitle').innerText='Quick Edit: " + jsRegNo + "';" +
                            "showQuickEditModal();", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "qeErr",
                "qeShowMsg('Error loading student: " + ex.Message.Replace("'", "") + "','err');showQuickEditModal();", true);
        }
    }
    
    protected void btnQeSave_Click(object sender, EventArgs e)
    {
        string regno = (hfQeRegNo.Value ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "qeErr",
                "qeShowMsg('No student selected.','err');showQuickEditModal();", true);
            return;
        }
        
        try
        {
            string firstName = (txtQeFirstName.Text ?? "").Trim().ToUpper();
            string otherName = (txtQeOtherName.Text ?? "").Trim().ToUpper();
            string gender = ddlQeGender.SelectedValue;
            string dobStr = (txtQeDOB.Text ?? "").Trim();
            string nin = (txtQeNIN.Text ?? "").Trim().ToUpper();
            string phone = (txtQePhone.Text ?? "").Trim();
            string email = (txtQeEmail.Text ?? "").Trim();
            string nationality = (txtQeNationality.Text ?? "").Trim().ToUpper();
            string religion = ddlQeReligion.SelectedValue;
            string session = ddlQeSession.SelectedValue;
            string entryMethod = ddlQeEntryMethod.SelectedValue;
            string intake = ddlQeIntakeEdit.SelectedValue;
            string studStatus = ddlQeStatus.SelectedValue;
            string newStatus = ddlQeNewStatus.SelectedValue;
            
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
            
            // Resolve specialisation: spec_id → plain text name
            string specName = "";
            string specIdStr = ddlQeSpec.SelectedValue;
            int specId;
            if (int.TryParse(specIdStr, out specId) && specId > 0)
            {
                ListItem specItem = ddlQeSpec.Items.FindByValue(specIdStr);
                if (specItem != null)
                    specName = specItem.Text;
            }
            
            // Parse DOB
            DateTime dob = new DateTime(1980, 1, 1);
            if (!string.IsNullOrEmpty(dobStr))
            {
                DateTime parsed;
                if (DateTime.TryParse(dobStr, out parsed))
                    dob = parsed;
            }
            
            if (string.IsNullOrEmpty(firstName))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "qeErr",
                    "qeShowMsg('First Name is required.','err');showQuickEditModal();", true);
                return;
            }
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
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
                    specialisation = @specName,
                    studsesion     = @session,
                    studCampus     = @campus,
                    entryyear      = @entryYear,
                    entrymethod    = @entryMethod,
                    intake         = @intake,
                    billingID      = @billingId,
                    stud_status    = @studStatus,
                    new_status     = @newStatus
                WHERE regno = @regno";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@firstName",   firstName);
                    cmd.Parameters.AddWithValue("@otherName",   otherName);
                    cmd.Parameters.AddWithValue("@gender",      gender);
                    cmd.Parameters.AddWithValue("@dob",         dob);
                    cmd.Parameters.AddWithValue("@nin",         nin);
                    cmd.Parameters.AddWithValue("@phone",       phone);
                    cmd.Parameters.AddWithValue("@email",       email);
                    cmd.Parameters.AddWithValue("@nationality", nationality);
                    cmd.Parameters.AddWithValue("@religion",    religion);
                    cmd.Parameters.AddWithValue("@specName",    specName);
                    cmd.Parameters.AddWithValue("@session",     session);
                    cmd.Parameters.AddWithValue("@campus",      campusInt);
                    cmd.Parameters.AddWithValue("@entryYear",   entryYear);
                    cmd.Parameters.AddWithValue("@entryMethod", entryMethod);
                    cmd.Parameters.AddWithValue("@intake",      intake);
                    cmd.Parameters.AddWithValue("@billingId",   billingId);
                    cmd.Parameters.AddWithValue("@studStatus",  studStatus);
                    cmd.Parameters.AddWithValue("@newStatus",   newStatus);
                    cmd.Parameters.AddWithValue("@regno",       regno);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ScriptManager.RegisterStartupScript(this, GetType(), "qeOk",
                "qeShowMsg('Student updated successfully.','ok');showQuickEditModal();", true);
            
            // Refresh the grid to show updated data
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "qeErr",
                "qeShowMsg('Error saving: " + ex.Message.Replace("'", "").Replace("\\", "") + "','err');showQuickEditModal();", true);
        }
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
