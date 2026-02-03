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
        if (!IsPostBack)
        {
            LoadAcademicYears();
            LoadProgrammes();
            LoadEntryYears();
            
            // Set defaults
            string defaultYear = GetCurrentAcademicYear();
            if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
                ddlAcadYear.SelectedValue = defaultYear;
            
            ddlEntryYear.SelectedValue = DateTime.Now.Year.ToString();
            
            UpdateDisplayLabels();
            LoadCourses();
            LoadStats();
            BindGrid();
        }
    }
    
    private string GetCurrentAcademicYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;
        if (month >= 8)
            return string.Format("{0}/{1}", year, year + 1);
        else
            return string.Format("{0}/{1}", year - 1, year);
    }
    
    private void LoadAcademicYears()
    {
        ddlAcadYear.Items.Clear();
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 10; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
        }
    }
    
    private void LoadEntryYears()
    {
        ddlEntryYear.Items.Clear();
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 10; i--)
        {
            ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }
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
                                 WHERE r.prog = @prog 
                                   AND r.studyyear = @yr
                                   AND r.acadyr = @acad
                                   AND r.regstatus IN ('Registered', 'Cleared')
                                   AND r.regno NOT IN (
                                       SELECT cr.regno FROM acad_course_registration cr
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
            string sqlRegistered = @"SELECT COUNT(*) FROM acad_course_registration cr
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
            string sqlRetake = @"SELECT COUNT(*) FROM acad_course_registration cr
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
                              CONCAT(COALESCE(s.surname,''), ' ', COALESCE(s.othernames,'')) as stud_name,
                              COALESCE(r.specialisation, '-') as spec,
                              'PENDING' as course_status
                       FROM acad_registration r
                       INNER JOIN acad_students s ON r.regno = s.regno
                       WHERE r.prog = @prog 
                         AND r.studyyear = @yr
                         AND r.acadyr = @acad
                         AND r.regstatus IN ('Registered', 'Cleared')
                         AND r.regno NOT IN (
                             SELECT cr.regno FROM acad_course_registration cr
                             WHERE cr.courseID = @course 
                               AND cr.acad_year = @acad 
                               AND cr.semester = @sem
                         )";
                
                // Apply entry year filter
                if (ddlEntryYear.SelectedValue != "-" && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
                {
                    sql += " AND r.entry_year = @entyr";
                }
                
                // Apply intake filter
                if (ddlIntake.SelectedValue != "-")
                {
                    sql += " AND r.intake = @intake";
                }
                
                sql += " ORDER BY s.surname, s.othernames";
                
                btnRegisterSelected.Visible = true;
                btnRemoveSelected.Visible = false;
            }
            else
            {
                // Show students who are already registered in this course
                sql = @"SELECT cr.regno, 
                              CONCAT(COALESCE(s.surname,''), ' ', COALESCE(s.othernames,'')) as stud_name,
                              COALESCE(r.specialisation, '-') as spec,
                              cr.course_status
                       FROM acad_course_registration cr
                       INNER JOIN acad_students s ON cr.regno = s.regno
                       LEFT JOIN acad_registration r ON cr.regno = r.regno AND r.acadyr = cr.acad_year
                       WHERE cr.courseID = @course 
                         AND cr.acad_year = @acad 
                         AND cr.semester = @sem
                         AND cr.prog_id = @prog
                       ORDER BY s.surname, s.othernames";
                
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
        BindGrid();
    }
    
    protected void btnRegisterSelected_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlCourse.SelectedValue))
        {
            ShowMessage("Please select a course first.", "error");
            return;
        }
        
        int count = 0;
        string username = HttpContext.Current.User.Identity.Name;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            List<object> selectedRows = gvCourseReg.GetSelectedFieldValues("regno");
            
            foreach (object row in selectedRows)
            {
                string regno = row.ToString();
                
                // Check if already registered
                string checkSql = @"SELECT COUNT(*) FROM acad_course_registration 
                                   WHERE regno = @regno AND courseID = @course 
                                     AND acad_year = @acad AND semester = @sem";
                
                using (MySqlCommand checkCmd = new MySqlCommand(checkSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regno);
                    checkCmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    checkCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    checkCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    
                    if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                        continue;
                }
                
                // Insert registration
                string insertSql = @"INSERT INTO acad_course_registration 
                                    (regno, courseID, acad_year, semester, course_status, prog_id, stud_session, created_by)
                                    VALUES (@regno, @course, @acad, @sem, 'NORMAL', @prog, @session, @user)";
                
                using (MySqlCommand insertCmd = new MySqlCommand(insertSql, conn))
                {
                    insertCmd.Parameters.AddWithValue("@regno", regno);
                    insertCmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    insertCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    insertCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    insertCmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    insertCmd.Parameters.AddWithValue("@session", "DAY"); // Default session
                    insertCmd.Parameters.AddWithValue("@user", username);
                    
                    insertCmd.ExecuteNonQuery();
                    count++;
                }
            }
        }
        
        if (count > 0)
            ShowMessage(count + " student(s) registered successfully.", "success");
        else
            ShowMessage("No students were registered. They may already be registered.", "info");
        
        gvCourseReg.Selection.UnselectAll();
        LoadStats();
        BindGrid();
    }
    
    protected void btnRemoveSelected_Click(object sender, EventArgs e)
    {
        int count = 0;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            List<object> selectedRows = gvCourseReg.GetSelectedFieldValues("regno");
            
            foreach (object row in selectedRows)
            {
                string regno = row.ToString();
                
                string deleteSql = @"DELETE FROM acad_course_registration 
                                    WHERE regno = @regno AND courseID = @course 
                                      AND acad_year = @acad AND semester = @sem";
                
                using (MySqlCommand deleteCmd = new MySqlCommand(deleteSql, conn))
                {
                    deleteCmd.Parameters.AddWithValue("@regno", regno);
                    deleteCmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    deleteCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    deleteCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    
                    count += deleteCmd.ExecuteNonQuery();
                }
            }
        }
        
        if (count > 0)
            ShowMessage(count + " registration(s) removed successfully.", "success");
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
            return;
        }
        
        if (string.IsNullOrEmpty(txtRetakeRegNo.Text.Trim()))
        {
            ShowMessage("Please enter a student registration number.", "error");
            return;
        }
        
        string regno = txtRetakeRegNo.Text.Trim();
        string username = HttpContext.Current.User.Identity.Name;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Check if student exists
            string checkStudentSql = "SELECT COUNT(*) FROM acad_students WHERE regno = @regno";
            using (MySqlCommand checkCmd = new MySqlCommand(checkStudentSql, conn))
            {
                checkCmd.Parameters.AddWithValue("@regno", regno);
                if (Convert.ToInt32(checkCmd.ExecuteScalar()) == 0)
                {
                    ShowMessage("Student with registration number '" + regno + "' not found.", "error");
                    return;
                }
            }
            
            // Check if already registered
            string checkRegSql = @"SELECT COUNT(*) FROM acad_course_registration 
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
                    return;
                }
            }
            
            // Insert retake registration
            string insertSql = @"INSERT INTO acad_course_registration 
                                (regno, courseID, acad_year, semester, course_status, prog_id, stud_session, created_by)
                                VALUES (@regno, @course, @acad, @sem, 'RETAKE', @prog, @session, @user)";
            
            using (MySqlCommand insertCmd = new MySqlCommand(insertSql, conn))
            {
                insertCmd.Parameters.AddWithValue("@regno", regno);
                insertCmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                insertCmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                insertCmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                insertCmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                insertCmd.Parameters.AddWithValue("@session", "DAY");
                insertCmd.Parameters.AddWithValue("@user", username);
                
                insertCmd.ExecuteNonQuery();
            }
        }
        
        ShowMessage("Retake case added successfully for student: " + regno, "success");
        txtRetakeRegNo.Text = "";
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
}
