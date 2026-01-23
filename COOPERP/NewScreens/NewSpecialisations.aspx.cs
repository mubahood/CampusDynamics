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

    protected void cmbProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        string progCode = cmbProgramme.Value != null ? cmbProgramme.Value.ToString() : string.Empty;
        
        if (!string.IsNullOrEmpty(progCode))
        {
            dsMain.SelectCommand = "SELECT s.spec_id, s.prog_id, s.spec, s.abbrev, p.progname, COALESCE(c.course_count, 0) as course_count FROM acad_specialisation s LEFT JOIN acad_programme p ON s.prog_id = p.progcode LEFT JOIN (SELECT specialisation_id, COUNT(*) as course_count FROM acad_programmecourses GROUP BY specialisation_id) c ON s.spec_id = c.specialisation_id WHERE s.prog_id = @prog_id ORDER BY s.spec";
            dsMain.SelectParameters.Clear();
            dsMain.SelectParameters.Add("prog_id", progCode);
            lblFilterInfo.Text = "Filtered by: " + cmbProgramme.Text;
        }
        else
        {
            dsMain.SelectCommand = "SELECT s.spec_id, s.prog_id, s.spec, s.abbrev, p.progname, COALESCE(c.course_count, 0) as course_count FROM acad_specialisation s LEFT JOIN acad_programme p ON s.prog_id = p.progcode LEFT JOIN (SELECT specialisation_id, COUNT(*) as course_count FROM acad_programmecourses GROUP BY specialisation_id) c ON s.spec_id = c.specialisation_id ORDER BY p.progname, s.spec";
            dsMain.SelectParameters.Clear();
            lblFilterInfo.Text = "";
        }
        
        gvMain.DataBind();
        UpdateTotalCount();
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
                
                string progCode = cmbProgramme.Value != null ? cmbProgramme.Value.ToString() : string.Empty;
                if (!string.IsNullOrEmpty(progCode))
                {
                    sql += " WHERE prog_id = @prog_id";
                }
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(progCode))
                    {
                        cmd.Parameters.AddWithValue("@prog_id", progCode);
                    }
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
        
        // Reset batch add form
        txtBatchCourses.Text = "";
        pnlValidationResult.Visible = false;
        pnlBatchResult.Visible = false;
        
        // Load course structure
        LoadCourseStructure(specId);
        
        // Load courses grid
        LoadSpecCoursesGrid(specId);
        
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void cmdValidateBatch_Click(object sender, EventArgs e)
    {
        string courseCodes = txtBatchCourses.Text.Trim();
        if (string.IsNullOrEmpty(courseCodes))
        {
            lblValidationResult.Text = "<span class='validation-error'>Please enter course codes.</span>";
            pnlValidationResult.Visible = true;
            return;
        }
        
        string[] codes = courseCodes.Split(new char[] { ',', ' ', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
        List<string> validCourses = new List<string>();
        List<string> invalidCourses = new List<string>();
        List<string> duplicateCourses = new List<string>();
        
        int specId = Convert.ToInt32(hdnSpecId.Value);
        int curriculumId = cmbBatchCurriculum.Value != null ? Convert.ToInt32(cmbBatchCurriculum.Value) : 0;
        int year = Convert.ToInt32(cmbBatchYear.Value);
        int semester = Convert.ToInt32(cmbBatchSemester.Value);
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
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
                
                // Check if already added to this specialisation
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId AND course_code = @code AND CurriculumID = @currId AND study_year = @year AND semester = @sem", conn))
                {
                    cmd.Parameters.AddWithValue("@specId", specId);
                    cmd.Parameters.AddWithValue("@code", trimmedCode);
                    cmd.Parameters.AddWithValue("@currId", curriculumId);
                    cmd.Parameters.AddWithValue("@year", year);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    int duplicate = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    if (duplicate > 0)
                    {
                        duplicateCourses.Add(trimmedCode);
                        continue;
                    }
                }
                
                validCourses.Add(trimmedCode);
            }
        }
        
        StringBuilder sb = new StringBuilder();
        if (validCourses.Count > 0)
        {
            sb.Append("<span class='validation-success'>Valid courses (" + validCourses.Count + "): " + string.Join(", ", validCourses) + "</span><br/>");
        }
        if (invalidCourses.Count > 0)
        {
            sb.Append("<span class='validation-error'>Invalid courses (" + invalidCourses.Count + "): " + string.Join(", ", invalidCourses) + "</span><br/>");
        }
        if (duplicateCourses.Count > 0)
        {
            sb.Append("<span class='validation-error'>Already exists (" + duplicateCourses.Count + "): " + string.Join(", ", duplicateCourses) + "</span>");
        }
        
        lblValidationResult.Text = sb.ToString();
        pnlValidationResult.Visible = true;
        popManageCourses.ShowOnPageLoad = true;
    }

    protected void cmdAddBatch_Click(object sender, EventArgs e)
    {
        string courseCodes = txtBatchCourses.Text.Trim();
        if (string.IsNullOrEmpty(courseCodes))
        {
            lblBatchResult.Text = "<span class='validation-error'>Please enter course codes.</span>";
            pnlBatchResult.Visible = true;
            popManageCourses.ShowOnPageLoad = true;
            return;
        }
        
        int specId = Convert.ToInt32(hdnSpecId.Value);
        string progCode = hdnProgCode.Value;
        int curriculumId = cmbBatchCurriculum.Value != null ? Convert.ToInt32(cmbBatchCurriculum.Value) : 0;
        int year = Convert.ToInt32(cmbBatchYear.Value);
        int semester = Convert.ToInt32(cmbBatchSemester.Value);
        
        if (curriculumId == 0)
        {
            lblBatchResult.Text = "<span class='validation-error'>Please select a curriculum.</span>";
            pnlBatchResult.Visible = true;
            popManageCourses.ShowOnPageLoad = true;
            return;
        }
        
        string[] codes = courseCodes.Split(new char[] { ',', ' ', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
        int added = 0;
        int skipped = 0;
        int invalid = 0;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
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
                        invalid++;
                        continue;
                    }
                }
                
                // Check if already added
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId AND course_code = @code AND CurriculumID = @currId AND study_year = @year AND semester = @sem", conn))
                {
                    cmd.Parameters.AddWithValue("@specId", specId);
                    cmd.Parameters.AddWithValue("@code", trimmedCode);
                    cmd.Parameters.AddWithValue("@currId", curriculumId);
                    cmd.Parameters.AddWithValue("@year", year);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    int duplicate = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    if (duplicate > 0)
                    {
                        skipped++;
                        continue;
                    }
                }
                
                // Insert
                using (MySqlCommand cmd = new MySqlCommand("INSERT INTO acad_programmecourses (progcode, course_code, study_year, semester, CurriculumID, specialisation_id) VALUES (@progcode, @code, @year, @sem, @currId, @specId)", conn))
                {
                    cmd.Parameters.AddWithValue("@progcode", progCode);
                    cmd.Parameters.AddWithValue("@code", trimmedCode);
                    cmd.Parameters.AddWithValue("@year", year);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    cmd.Parameters.AddWithValue("@currId", curriculumId);
                    cmd.Parameters.AddWithValue("@specId", specId);
                    cmd.ExecuteNonQuery();
                    added++;
                }
            }
        }
        
        StringBuilder sb = new StringBuilder();
        sb.Append("<span class='validation-success'>Added: " + added + " courses</span>");
        if (skipped > 0) sb.Append(" | <span style='color:#856404'>Skipped (duplicates): " + skipped + "</span>");
        if (invalid > 0) sb.Append(" | <span class='validation-error'>Invalid: " + invalid + "</span>");
        
        lblBatchResult.Text = sb.ToString();
        pnlBatchResult.Visible = true;
        
        // Refresh structure and grid
        LoadCourseStructure(specId);
        LoadSpecCoursesGrid(specId);
        
        // Clear input
        txtBatchCourses.Text = "";
        pnlValidationResult.Visible = false;
        
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
                                sb.Append("<span><strong>" + courseCode + "</strong> - " + courseName + "</span>");
                                sb.Append("<span style='color:#666;font-size:10px;'>" + credits + " CU</span>");
                                sb.Append("</div>");
                            }
                            
                            if (!hasCourses)
                            {
                                sb.Append("<span style='color:#999;font-style:italic;font-size:11px;'>No courses</span>");
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
            string sql = "SELECT pc.ID, pc.course_code, pc.study_year, pc.semester, c.courseName, c.CreditUnit " +
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
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_programmecourses SET study_year = @year, semester = @sem WHERE ID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@year", year);
                cmd.Parameters.AddWithValue("@sem", semester);
                cmd.Parameters.AddWithValue("@id", id);
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
