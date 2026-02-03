using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_ResultsUpdates : System.Web.UI.Page
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
            LoadCourses();
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
        string defaultYear = GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
            ddlAcadYear.SelectedValue = defaultYear;
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
    
    private void LoadCourses()
    {
        ddlCourse.Items.Clear();
        ddlCourse.Items.Add(new ListItem("-- All Courses --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"SELECT DISTINCT e.course_id, c.courseName 
                    FROM acad_examresults_faculty e 
                    LEFT JOIN acad_course c ON e.course_id = c.courseID 
                    WHERE 1=1";
                
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    sql += " AND e.acadyear = @acad";
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    sql += " AND e.semester = @sem";
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    sql += " AND e.progid = @prog";
                
                sql += " ORDER BY c.courseName LIMIT 100";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string courseId = reader["course_id"].ToString();
                            string courseName = reader["courseName"] != DBNull.Value ? reader["courseName"].ToString() : courseId;
                            ddlCourse.Items.Add(new ListItem(string.Format("{0} - {1}", courseId, courseName), courseId));
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
        litApprovedCount.Text = "0";
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<string> conditions = new List<string>();
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    conditions.Add("acadyear = @acad");
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    conditions.Add("semester = @sem");
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    conditions.Add("progid = @prog");
                if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                    conditions.Add("course_id = @course");
                
                string whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions.ToArray()) : "";
                
                string countSql = @"SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN approved_by IS NOT NULL AND approved_by != '-' AND approved_by != '' THEN 1 ELSE 0 END) as approved,
                    SUM(CASE WHEN approved_by IS NULL OR approved_by = '-' OR approved_by = '' THEN 1 ELSE 0 END) as pending
                    FROM acad_examresults_faculty " + whereClause;
                
                using (MySqlCommand cmd = new MySqlCommand(countSql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                        cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litTotalCount.Text = (reader["total"] != DBNull.Value ? Convert.ToInt32(reader["total"]) : 0).ToString();
                            litApprovedCount.Text = (reader["approved"] != DBNull.Value ? Convert.ToInt32(reader["approved"]) : 0).ToString();
                            litPendingCount.Text = (reader["pending"] != DBNull.Value ? Convert.ToInt32(reader["pending"]) : 0).ToString();
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
        dt.Columns.Add("ID", typeof(int));
        dt.Columns.Add("regno", typeof(string));
        dt.Columns.Add("student_name", typeof(string));
        dt.Columns.Add("course_id", typeof(string));
        dt.Columns.Add("course_name", typeof(string));
        dt.Columns.Add("prog_id", typeof(string));
        dt.Columns.Add("prog_name", typeof(string));
        dt.Columns.Add("acadyear", typeof(string));
        dt.Columns.Add("semester", typeof(int));
        dt.Columns.Add("ca_mark", typeof(decimal));
        dt.Columns.Add("exam_mark", typeof(decimal));
        dt.Columns.Add("total_mark", typeof(decimal));
        dt.Columns.Add("grade", typeof(string));
        dt.Columns.Add("gpa", typeof(decimal));
        dt.Columns.Add("approved_by", typeof(string));
        dt.Columns.Add("date_modified", typeof(DateTime));
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
                if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                    conditions.Add("e.course_id = @course");
                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    conditions.Add("(e.regno LIKE @search OR s.firstname LIKE @search OR s.othername LIKE @search)");
                
                string whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions.ToArray()) : "";
                
                string sql = @"SELECT 
                    e.ID, e.regno, 
                    CONCAT(IFNULL(s.firstname,''), ' ', IFNULL(s.othername,'')) as student_name,
                    e.course_id, c.courseName as course_name,
                    e.progid as prog_id, p.progname as prog_name,
                    e.acadyear, e.semester,
                    e.cw_mark as ca_mark, e.ex_mark as exam_mark, e.total_mark, e.grade, e.gradept as gpa,
                    e.approved_by, NOW() as date_modified
                    FROM acad_examresults_faculty e
                    LEFT JOIN acad_course c ON e.course_id = c.courseID
                    LEFT JOIN acad_programme p ON e.progid = p.progcode
                    LEFT JOIN acad_student s ON e.regno = s.regno
                    " + whereClause + @"
                    ORDER BY e.acadyear DESC, e.semester, s.firstname, s.othername
                    LIMIT 500";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                        cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        cmd.Parameters.AddWithValue("@search", "%" + txtSearch.Text.Trim() + "%");
                    
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
                    ShowMessage("No results found for the selected filters.", "warning");
                }
                else
                {
                    lblMessage.Text = string.Format("Showing {0} student results", dt.Rows.Count);
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
    
    protected string GetStatusBadge(object approvedBy)
    {
        string status = (approvedBy != null && approvedBy != DBNull.Value) ? approvedBy.ToString() : "";
        bool isApproved = !string.IsNullOrEmpty(status) && status != "-";
        
        if (isApproved)
            return string.Format("<span class=\"ru-status-badge ru-status-badge--approved\">APPROVED</span>");
        else
            return string.Format("<span class=\"ru-status-badge ru-status-badge--pending\">PENDING</span>");
    }
    
    protected void gvResults_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
    {
        // Custom formatting if needed
    }
    
    #endregion
    
    #region Event Handlers
    
    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes();
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void btnEditSelected_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResults.GetSelectedFieldValues(new string[] { "ID", "regno", "course_id", "student_name", "ca_mark", "exam_mark", "total_mark", "grade" });
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select a result to edit.", "warning");
            return;
        }
        
        if (selectedKeys.Count > 1)
        {
            ShowMessage("Please select only one result to edit at a time.", "warning");
            return;
        }
        
        // Get the first selected record
        object[] values = selectedKeys[0] as object[];
        if (values != null && values.Length >= 8)
        {
            hfResultID.Value = values[0].ToString();
            txtRegNo.Text = values[1] != null ? values[1].ToString() : "";
            txtCourse.Text = values[2] != null ? values[2].ToString() : "";
            litStudentName.Text = values[3] != null ? values[3].ToString() : "";
            txtCoursework.Text = values[4] != null ? values[4].ToString() : "";
            txtExam.Text = values[5] != null ? values[5].ToString() : "";
            txtTotal.Text = values[6] != null ? values[6].ToString() : "";
            txtGrade.Text = values[7] != null ? values[7].ToString() : "";
            
            pnlEdit.Visible = true;
            pnlEdit.CssClass = "ru-edit-panel show";
        }
    }
    
    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        pnlEdit.Visible = false;
        pnlEdit.CssClass = "ru-edit-panel";
        hfResultID.Value = "";
    }
    
    protected void btnSaveUpdate_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hfResultID.Value))
        {
            ShowMessage("No result selected for update.", "error");
            return;
        }
        
        // Validate marks
        decimal camark, exammark;
        if (!decimal.TryParse(txtCoursework.Text, out camark) || !decimal.TryParse(txtExam.Text, out exammark))
        {
            ShowMessage("Please enter valid numeric values for marks.", "error");
            return;
        }
        
        decimal total = camark + exammark;
        string grade = CalculateGrade(total);
        decimal gpa = CalculateGPA(grade);
        string username = HttpContext.Current.User.Identity.Name;
        string reason = txtReason.Text.Trim();
        string remark = ddlRemark.SelectedValue;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Log the original values first
                string logSql = @"INSERT INTO acad_results_audit (result_id, field_changed, old_value, new_value, changed_by, change_reason, change_date)
                    SELECT ID, 'MARKS', CONCAT(ca_mark, '/', exam_mark, '/', total_mark), @newvals, @user, @reason, NOW()
                    FROM acad_examresults_faculty WHERE ID = @id";
                
                try
                {
                    using (MySqlCommand logCmd = new MySqlCommand(logSql, conn))
                    {
                        logCmd.Parameters.AddWithValue("@newvals", string.Format("{0}/{1}/{2}", camark, exammark, total));
                        logCmd.Parameters.AddWithValue("@user", username);
                        logCmd.Parameters.AddWithValue("@reason", reason);
                        logCmd.Parameters.AddWithValue("@id", int.Parse(hfResultID.Value));
                        logCmd.ExecuteNonQuery();
                    }
                }
                catch { /* Audit table may not exist */ }
                
                // Update the result
                string updateSql = @"UPDATE acad_examresults_faculty 
                    SET cw_mark = @ca, ex_mark = @exam, total_mark = @total, grade = @grade, gradept = @gpa
                    WHERE ID = @id";
                
                using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@ca", camark);
                    cmd.Parameters.AddWithValue("@exam", exammark);
                    cmd.Parameters.AddWithValue("@total", total);
                    cmd.Parameters.AddWithValue("@grade", grade);
                    cmd.Parameters.AddWithValue("@gpa", gpa);
                    cmd.Parameters.AddWithValue("@id", int.Parse(hfResultID.Value));
                    cmd.ExecuteNonQuery();
                }
                
                ShowMessage("Result updated successfully.", "success");
                pnlEdit.Visible = false;
                pnlEdit.CssClass = "ru-edit-panel";
                gvResults.Selection.UnselectAll();
                BindGrid();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error updating result: " + ex.Message, "error");
        }
    }
    
    protected void btnApproveSelected_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResults.GetSelectedFieldValues("ID");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select results to approve.", "warning");
            return;
        }
        
        string username = HttpContext.Current.User.Identity.Name;
        int approved = 0;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object idObj in selectedKeys)
                {
                    int id = Convert.ToInt32(idObj);
                    string sql = @"UPDATE acad_examresults_faculty 
                        SET approved_by = @user
                        WHERE ID = @id AND (approved_by IS NULL OR approved_by = '-' OR approved_by = '')";
                    
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@user", username);
                        cmd.Parameters.AddWithValue("@id", id);
                        approved += cmd.ExecuteNonQuery();
                    }
                }
            }
            
            ShowMessage(string.Format("{0} result(s) approved successfully.", approved), "success");
            gvResults.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error approving results: " + ex.Message, "error");
        }
    }
    
    protected void btnRevertSelected_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResults.GetSelectedFieldValues("ID");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select results to revert.", "warning");
            return;
        }
        
        int reverted = 0;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object idObj in selectedKeys)
                {
                    int id = Convert.ToInt32(idObj);
                    string sql = @"UPDATE acad_examresults_faculty 
                        SET approved_by = '-'
                        WHERE ID = @id";
                    
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        reverted += cmd.ExecuteNonQuery();
                    }
                }
            }
            
            ShowMessage(string.Format("{0} result(s) reverted to pending.", reverted), "success");
            gvResults.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error reverting results: " + ex.Message, "error");
        }
    }
    
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;
        string fileName = string.Format("ResultsUpdates_{0}_Sem{1}_{2}", 
            string.IsNullOrEmpty(acadYear) ? "All" : acadYear.Replace("/", "-"), 
            string.IsNullOrEmpty(semester) ? "All" : semester,
            DateTime.Now.ToString("yyyyMMdd"));
        
        gvExporter.WriteXlsToResponse(fileName);
    }
    
    #endregion
    
    #region Helper Methods
    
    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "ru-message show ru-message--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }
    
    private string CalculateGrade(decimal total)
    {
        if (total >= 80) return "A";
        if (total >= 75) return "A-";
        if (total >= 70) return "B+";
        if (total >= 65) return "B";
        if (total >= 60) return "B-";
        if (total >= 55) return "C+";
        if (total >= 50) return "C";
        if (total >= 45) return "C-";
        if (total >= 40) return "D";
        return "E";
    }
    
    private decimal CalculateGPA(string grade)
    {
        switch (grade)
        {
            case "A": return 5.0m;
            case "A-": return 4.5m;
            case "B+": return 4.0m;
            case "B": return 3.5m;
            case "B-": return 3.0m;
            case "C+": return 2.5m;
            case "C": return 2.0m;
            case "C-": return 1.5m;
            case "D": return 1.0m;
            default: return 0.0m;
        }
    }
    
    #endregion
}
