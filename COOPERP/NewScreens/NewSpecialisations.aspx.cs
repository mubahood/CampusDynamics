using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_NewSpecialisations : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            UpdateTotalCount();
        }
    }

    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvMain.AddNewRow();
    }

    protected void gvMain_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
    }

    protected void gvMain_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
    }

    protected void gvMain_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int specId = Convert.ToInt32(e.Keys["spec_id"]);
        int courseCount = GetCourseCountForSpec(specId);
        if (courseCount > 0)
        {
            e.Cancel = true;
            throw new Exception("Cannot delete specialisation with " + courseCount + " courses. Please remove or reassign courses first.");
        }
    }

    protected void gvMain_CustomErrorText(object sender, ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.Exception != null)
        {
            e.ErrorText = e.Exception.Message;
        }
    }

    private void UpdateTotalCount()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT COUNT(*) FROM acad_specialisation";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalCount.Text = count.ToString();
                }
            }
        }
        catch (Exception)
        {
            lblTotalCount.Text = "0";
        }
    }

    private int GetCourseCountForSpec(int specId)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId", conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    protected void btnManageCourses_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        string[] args = btn.CommandArgument.Split('|');
        int specId = Convert.ToInt32(args[0]);
        string specName = args[1];
        string progCode = args[2];
        
        hdnSpecId.Value = specId.ToString();
        hdnProgCode.Value = progCode;
        lblSpecName.Text = specName;
        
        // Get programme name
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT progname FROM acad_programme WHERE progcode = @progcode", conn))
            {
                cmd.Parameters.AddWithValue("@progcode", progCode);
                object result = cmd.ExecuteScalar();
                lblProgName.Text = result != null ? result.ToString() : progCode;
            }
        }
        
        // Reset batch add form - clear all year-semester fields
        txtY1S1.Text = ""; txtY1S2.Text = ""; txtY1S3.Text = "";
        txtY2S1.Text = ""; txtY2S2.Text = ""; txtY2S3.Text = "";
        txtY3S1.Text = ""; txtY3S2.Text = ""; txtY3S3.Text = "";
        txtY4S1.Text = ""; txtY4S2.Text = ""; txtY4S3.Text = "";
        pnlBatchSummary.Visible = false;
        ddlSetFullySet.SelectedValue = "No";
        
        // Load course structure
        LoadCourseStructure(specId);
        
        // Load courses grid
        LoadSpecCoursesGrid(specId);
        
        popManageCourses.ShowOnPageLoad = true;
    }
    
    protected void btnPrintStructure_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        string[] args = btn.CommandArgument.Split('|');
        int specId = Convert.ToInt32(args[0]);
        string specName = args[1];
        string progName = args[2];
        
        // Open PDF viewer in new window
        string url = "SpecialisationStructurePDF.aspx?specId=" + specId + "&specName=" + Server.UrlEncode(specName) + "&progName=" + Server.UrlEncode(progName);
        ScriptManager.RegisterStartupScript(this, GetType(), "openPdf", "window.open('" + url + "', '_blank');", true);
    }

    // Helper class to store year-semester data
    private class YearSemesterData
    {
        public int Year { get; set; }
        public int Semester { get; set; }
        public string Courses { get; set; }
        public int Credits { get; set; }
        public string CourseType { get; set; }
        public TextBox CoursesControl { get; set; }
        public Panel ResultPanel { get; set; }
    }

    private List<YearSemesterData> GetAllYearSemesterData()
    {
        return new List<YearSemesterData>
        {
            new YearSemesterData { Year = 1, Semester = 1, Courses = txtY1S1.Text.Trim(), Credits = ParseCredits(txtY1S1CU.Text), CourseType = ddlY1S1Type.SelectedValue, CoursesControl = txtY1S1, ResultPanel = pnlY1S1Result },
            new YearSemesterData { Year = 1, Semester = 2, Courses = txtY1S2.Text.Trim(), Credits = ParseCredits(txtY1S2CU.Text), CourseType = ddlY1S2Type.SelectedValue, CoursesControl = txtY1S2, ResultPanel = pnlY1S2Result },
            new YearSemesterData { Year = 1, Semester = 3, Courses = txtY1S3.Text.Trim(), Credits = ParseCredits(txtY1S3CU.Text), CourseType = ddlY1S3Type.SelectedValue, CoursesControl = txtY1S3, ResultPanel = pnlY1S3Result },
            new YearSemesterData { Year = 2, Semester = 1, Courses = txtY2S1.Text.Trim(), Credits = ParseCredits(txtY2S1CU.Text), CourseType = ddlY2S1Type.SelectedValue, CoursesControl = txtY2S1, ResultPanel = pnlY2S1Result },
            new YearSemesterData { Year = 2, Semester = 2, Courses = txtY2S2.Text.Trim(), Credits = ParseCredits(txtY2S2CU.Text), CourseType = ddlY2S2Type.SelectedValue, CoursesControl = txtY2S2, ResultPanel = pnlY2S2Result },
            new YearSemesterData { Year = 2, Semester = 3, Courses = txtY2S3.Text.Trim(), Credits = ParseCredits(txtY2S3CU.Text), CourseType = ddlY2S3Type.SelectedValue, CoursesControl = txtY2S3, ResultPanel = pnlY2S3Result },
            new YearSemesterData { Year = 3, Semester = 1, Courses = txtY3S1.Text.Trim(), Credits = ParseCredits(txtY3S1CU.Text), CourseType = ddlY3S1Type.SelectedValue, CoursesControl = txtY3S1, ResultPanel = pnlY3S1Result },
            new YearSemesterData { Year = 3, Semester = 2, Courses = txtY3S2.Text.Trim(), Credits = ParseCredits(txtY3S2CU.Text), CourseType = ddlY3S2Type.SelectedValue, CoursesControl = txtY3S2, ResultPanel = pnlY3S2Result },
            new YearSemesterData { Year = 3, Semester = 3, Courses = txtY3S3.Text.Trim(), Credits = ParseCredits(txtY3S3CU.Text), CourseType = ddlY3S3Type.SelectedValue, CoursesControl = txtY3S3, ResultPanel = pnlY3S3Result },
            new YearSemesterData { Year = 4, Semester = 1, Courses = txtY4S1.Text.Trim(), Credits = ParseCredits(txtY4S1CU.Text), CourseType = ddlY4S1Type.SelectedValue, CoursesControl = txtY4S1, ResultPanel = pnlY4S1Result },
            new YearSemesterData { Year = 4, Semester = 2, Courses = txtY4S2.Text.Trim(), Credits = ParseCredits(txtY4S2CU.Text), CourseType = ddlY4S2Type.SelectedValue, CoursesControl = txtY4S2, ResultPanel = pnlY4S2Result },
            new YearSemesterData { Year = 4, Semester = 3, Courses = txtY4S3.Text.Trim(), Credits = ParseCredits(txtY4S3CU.Text), CourseType = ddlY4S3Type.SelectedValue, CoursesControl = txtY4S3, ResultPanel = pnlY4S3Result }
        };
    }

    private int ParseCredits(string text)
    {
        int credits;
        return int.TryParse(text, out credits) ? credits : 3;
    }

    protected void cmdValidateAll_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        var allData = GetAllYearSemesterData();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            foreach (var data in allData)
            {
                ValidateYearSemester(conn, specId, data);
            }
        }
        
        popManageCourses.ShowOnPageLoad = true;
    }

    private void ValidateYearSemester(MySqlConnection conn, int specId, YearSemesterData data)
    {
        // Clear previous result
        data.ResultPanel.Controls.Clear();
        data.ResultPanel.CssClass = "batch-validation-result";
        
        // Skip empty fields
        if (string.IsNullOrEmpty(data.Courses))
        {
            return;
        }
        
        // Split only by comma - preserve spaces inside course codes
        string[] codes = data.Courses.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        List<string> validCourses = new List<string>();
        List<string> invalidCourses = new List<string>();
        List<string> duplicateCourses = new List<string>();
        
        foreach (string code in codes)
        {
            string trimmedCode = code.Trim().ToUpper();
            if (string.IsNullOrEmpty(trimmedCode)) continue;
            
            // Check if course exists
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE courseID = @code", conn))
            {
                cmd.Parameters.AddWithValue("@code", trimmedCode);
                int exists = Convert.ToInt32(cmd.ExecuteScalar());
                
                if (exists == 0)
                {
                    invalidCourses.Add(trimmedCode);
                    continue;
                }
            }
            
            // Check if already added to this specialisation (any year/semester)
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId AND course_code = @code", conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                cmd.Parameters.AddWithValue("@code", trimmedCode);
                int duplicate = Convert.ToInt32(cmd.ExecuteScalar());
                
                if (duplicate > 0)
                {
                    duplicateCourses.Add(trimmedCode);
                    continue;
                }
            }
            
            validCourses.Add(trimmedCode);
        }
        
        // Build result message
        StringBuilder sb = new StringBuilder();
        string resultClass = "batch-validation-result has-result ";
        
        if (invalidCourses.Count == 0 && duplicateCourses.Count == 0 && validCourses.Count > 0)
        {
            resultClass += "valid";
            sb.Append("✓ " + validCourses.Count + " valid: " + string.Join(", ", validCourses));
        }
        else if (validCourses.Count == 0 && (invalidCourses.Count > 0 || duplicateCourses.Count > 0))
        {
            resultClass += "invalid";
            if (invalidCourses.Count > 0) sb.Append("✗ Invalid: " + string.Join(", ", invalidCourses) + " ");
            if (duplicateCourses.Count > 0) sb.Append("⚠ Exists: " + string.Join(", ", duplicateCourses));
        }
        else
        {
            resultClass += "mixed";
            if (validCourses.Count > 0) sb.Append("✓ " + validCourses.Count + " valid ");
            if (invalidCourses.Count > 0) sb.Append("✗ " + invalidCourses.Count + " invalid ");
            if (duplicateCourses.Count > 0) sb.Append("⚠ " + duplicateCourses.Count + " exist");
        }
        
        data.ResultPanel.CssClass = resultClass;
        data.ResultPanel.Controls.Add(new LiteralControl(sb.ToString()));
    }

    protected void cmdAddAllBatch_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        string progCode = hdnProgCode.Value;
        var allData = GetAllYearSemesterData();
        
        int totalAdded = 0;
        int totalSkipped = 0;
        int totalInvalid = 0;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            foreach (var data in allData)
            {
                // Skip empty fields
                if (string.IsNullOrEmpty(data.Courses)) continue;
                
                // Split only by comma - preserve spaces inside course codes
                string[] codes = data.Courses.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                
                foreach (string code in codes)
                {
                    string trimmedCode = code.Trim().ToUpper();
                    if (string.IsNullOrEmpty(trimmedCode)) continue;
                    
                    // Check if course exists in acad_course table
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE courseID = @code", conn))
                    {
                        cmd.Parameters.AddWithValue("@code", trimmedCode);
                        int exists = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (exists == 0)
                        {
                            totalInvalid++;
                            continue;
                        }
                    }
                    
                    // Check if already added to this specialisation with same year/semester
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId AND course_code = @code AND study_year = @year AND semester = @sem", conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", specId);
                        cmd.Parameters.AddWithValue("@code", trimmedCode);
                        cmd.Parameters.AddWithValue("@year", data.Year);
                        cmd.Parameters.AddWithValue("@sem", data.Semester);
                        int duplicate = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (duplicate > 0)
                        {
                            // Already exists with exact same settings - skip
                            totalSkipped++;
                            continue;
                        }
                    }
                    
                    // Check if course exists in programme (any specialisation or no specialisation)
                    using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE course_code = @code AND progcode = @progcode AND CurriculumID = 0", conn))
                    {
                        cmd.Parameters.AddWithValue("@code", trimmedCode);
                        cmd.Parameters.AddWithValue("@progcode", progCode);
                        int existsInProg = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (existsInProg > 0)
                        {
                            // Course exists in programme - UPDATE it with new specialisation settings
                            using (MySqlCommand updateCmd = new MySqlCommand("UPDATE acad_programmecourses SET specialisation_id = @specId, study_year = @year, semester = @sem, course_type = @courseType WHERE course_code = @code AND progcode = @progcode AND CurriculumID = 0", conn))
                            {
                                updateCmd.Parameters.AddWithValue("@specId", specId);
                                updateCmd.Parameters.AddWithValue("@year", data.Year);
                                updateCmd.Parameters.AddWithValue("@sem", data.Semester);
                                updateCmd.Parameters.AddWithValue("@courseType", data.CourseType);
                                updateCmd.Parameters.AddWithValue("@code", trimmedCode);
                                updateCmd.Parameters.AddWithValue("@progcode", progCode);
                                updateCmd.ExecuteNonQuery();
                            }
                            totalAdded++;  // Count as added (updated)
                            
                            // Update course credits if specified
                            if (data.Credits > 0)
                            {
                                using (MySqlCommand credCmd = new MySqlCommand("UPDATE acad_course SET CreditUnit = @credits WHERE courseID = @code AND (CreditUnit IS NULL OR CreditUnit = 0)", conn))
                                {
                                    credCmd.Parameters.AddWithValue("@credits", data.Credits);
                                    credCmd.Parameters.AddWithValue("@code", trimmedCode);
                                    credCmd.ExecuteNonQuery();
                                }
                            }
                            continue;
                        }
                    }
                    
                    // Course doesn't exist - INSERT new record
                    using (MySqlCommand cmd = new MySqlCommand("INSERT INTO acad_programmecourses (progcode, course_code, study_year, semester, CurriculumID, specialisation_id, course_type) VALUES (@progcode, @code, @year, @sem, 0, @specId, @courseType)", conn))
                    {
                        cmd.Parameters.AddWithValue("@progcode", progCode);
                        cmd.Parameters.AddWithValue("@code", trimmedCode);
                        cmd.Parameters.AddWithValue("@year", data.Year);
                        cmd.Parameters.AddWithValue("@sem", data.Semester);
                        cmd.Parameters.AddWithValue("@specId", specId);
                        cmd.Parameters.AddWithValue("@courseType", data.CourseType);
                        cmd.ExecuteNonQuery();
                    }
                    
                    // Update course credits if specified
                    if (data.Credits > 0)
                    {
                        using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_course SET CreditUnit = @credits WHERE courseID = @code AND (CreditUnit IS NULL OR CreditUnit = 0)", conn))
                        {
                            cmd.Parameters.AddWithValue("@credits", data.Credits);
                            cmd.Parameters.AddWithValue("@code", trimmedCode);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    
                    totalAdded++;
                }
                
                // Clear the input field after processing
                data.CoursesControl.Text = "";
                data.ResultPanel.Controls.Clear();
                data.ResultPanel.CssClass = "batch-validation-result";
            }
            
            // Update is_fully_set if selected
            string fullySetValue = ddlSetFullySet.SelectedValue;
            if (fullySetValue == "Yes")
            {
                using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_specialisation SET is_fully_set = @value WHERE spec_id = @specId", conn))
                {
                    cmd.Parameters.AddWithValue("@value", fullySetValue);
                    cmd.Parameters.AddWithValue("@specId", specId);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        
        // Show summary
        StringBuilder summary = new StringBuilder();
        summary.Append("<strong>Batch Add Complete:</strong> ");
        summary.Append("<span style='color:#28a745'>Added: " + totalAdded + "</span>");
        if (totalSkipped > 0) summary.Append(" | <span style='color:#856404'>Skipped (duplicates): " + totalSkipped + "</span>");
        if (totalInvalid > 0) summary.Append(" | <span style='color:#dc3545'>Invalid: " + totalInvalid + "</span>");
        if (ddlSetFullySet.SelectedValue == "Yes") summary.Append(" | <span style='color:#174DA4'>Marked as Fully Set</span>");
        
        litBatchSummary.Text = summary.ToString();
        pnlBatchSummary.Visible = true;
        
        // Refresh structure and grid
        LoadCourseStructure(specId);
        LoadSpecCoursesGrid(specId);
        
        // Refresh main grid to update course counts
        gvMain.DataBind();
        
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void cmdRefreshStructure_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        LoadCourseStructure(specId);
        popManageCourses.ShowOnPageLoad = true;
    }

    private void LoadCourseStructure(int specId)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table class='year-sem-table'>");
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Get max year
            int maxYear = 5;
            
            for (int year = 1; year <= maxYear; year++)
            {
                sb.Append("<tr><th colspan='2' class='year-sem-header'>Year " + year + "</th></tr>");
                
                for (int sem = 1; sem <= 2; sem++)
                {
                    sb.Append("<tr><th style='width:100px;'>Semester " + sem + "</th><td>");
                    
                    using (MySqlCommand cmd = new MySqlCommand(
                        "SELECT pc.ID, pc.course_code, c.courseName, c.CreditUnit " +
                        "FROM acad_programmecourses pc " +
                        "LEFT JOIN acad_course c ON pc.course_code = c.courseID " +
                        "WHERE pc.specialisation_id = @specId AND pc.study_year = @year AND pc.semester = @sem " +
                        "ORDER BY pc.course_code", conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", specId);
                        cmd.Parameters.AddWithValue("@year", year);
                        cmd.Parameters.AddWithValue("@sem", sem);
                        
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            bool hasCourses = false;
                            while (reader.Read())
                            {
                                hasCourses = true;
                                string courseCode = reader["course_code"].ToString();
                                string courseName = reader["courseName"] != DBNull.Value ? reader["courseName"].ToString() : "";
                                string credits = reader["CreditUnit"] != DBNull.Value ? reader["CreditUnit"].ToString() : "0";
                                
                                sb.Append("<div class='course-item'>");
                                sb.Append("<span><strong>" + courseCode + "</strong> " + courseName + "</span>");
                                sb.Append("<span class='credits'>" + credits + " CU</span>");
                                sb.Append("</div>");
                            }
                            
                            if (!hasCourses)
                            {
                                sb.Append("<div style='color:#999;font-style:italic;font-size:11px;padding:8px;'>No courses assigned</div>");
                            }
                        }
                    }
                    
                    sb.Append("</td></tr>");
                }
            }
        }
        
        sb.Append("</table>");
        litCourseStructure.Text = sb.ToString();
    }

    private void LoadSpecCoursesGrid(int specId)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT pc.ID, pc.course_code, pc.study_year, pc.semester, pc.course_type, c.courseName, c.CreditUnit " +
                        "FROM acad_programmecourses pc " +
                        "LEFT JOIN acad_course c ON pc.course_code = c.courseID " +
                        "WHERE pc.specialisation_id = @specId " +
                        "ORDER BY pc.study_year, pc.semester, pc.course_code";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvSpecCourses.DataSource = dt;
                    gvSpecCourses.DataBind();
                }
            }
        }
    }

    protected void gvSpecCourses_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        int year = Convert.ToInt32(e.NewValues["study_year"]);
        int semester = Convert.ToInt32(e.NewValues["semester"]);
        int credits = e.NewValues["CreditUnit"] != null ? Convert.ToInt32(e.NewValues["CreditUnit"]) : 0;
        string courseType = e.NewValues["course_type"] != null ? e.NewValues["course_type"].ToString() : "CORE";
        string courseCode = e.OldValues["course_code"].ToString();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            // Update programme course year/semester/course_type
            using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_programmecourses SET study_year = @year, semester = @sem, course_type = @courseType WHERE ID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@year", year);
                cmd.Parameters.AddWithValue("@sem", semester);
                cmd.Parameters.AddWithValue("@courseType", courseType);
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
            
            // Update course credits
            using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_course SET CreditUnit = @credits WHERE courseID = @code", conn))
            {
                cmd.Parameters.AddWithValue("@credits", credits);
                cmd.Parameters.AddWithValue("@code", courseCode);
                cmd.ExecuteNonQuery();
            }
        }
        
        e.Cancel = true;
        gvSpecCourses.CancelEdit();
        
        int specId = Convert.ToInt32(hdnSpecId.Value);
        LoadSpecCoursesGrid(specId);
        LoadCourseStructure(specId);
        
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void gvSpecCourses_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int id = Convert.ToInt32(e.Keys["ID"]);
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("DELETE FROM acad_programmecourses WHERE ID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
        }
        
        e.Cancel = true;
        
        int specId = Convert.ToInt32(hdnSpecId.Value);
        LoadSpecCoursesGrid(specId);
        LoadCourseStructure(specId);
        gvMain.DataBind();
        
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void cmdPrintStructure_Click(object sender, EventArgs e)
    {
        int specId = Convert.ToInt32(hdnSpecId.Value);
        string specName = lblSpecName.Text;
        string progName = lblProgName.Text;
        
        // Generate PDF - redirect to a PDF generation page
        string url = "SpecialisationStructurePDF.aspx?specId=" + specId + "&specName=" + Server.UrlEncode(specName) + "&progName=" + Server.UrlEncode(progName);
        ScriptManager.RegisterStartupScript(this, GetType(), "openPdf", "window.open('" + url + "', '_blank');", true);
        
        popManageCourses.ShowOnPageLoad = true;
    }
}
