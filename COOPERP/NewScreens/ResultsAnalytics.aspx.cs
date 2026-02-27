using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_ResultsAnalytics : System.Web.UI.Page
{
    private string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    
    // Public properties for grade distribution percentages
    public double FirstClassPct { get; set; } = 0;
    public double UpperSecondPct { get; set; } = 0;
    public double LowerSecondPct { get; set; } = 0;
    public double PassPct { get; set; } = 0;
    public double FailPct { get; set; } = 0;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Security check
        if (Session["UserID"] == null)
        {
            Response.Redirect("~/Default.aspx");
            return;
        }

        if (!IsPostBack)
        {
            LoadAcademicYears();
            LoadFaculties();
            LoadAnalytics();
        }
    }

    #region Data Loading

    private void LoadAcademicYears()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT DISTINCT acad_year FROM acad_examresults_faculty 
                            ORDER BY acad_year DESC LIMIT 10";

            MySqlDataAdapter da = new MySqlDataAdapter(query, conn);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlAcadYear.Items.Clear();
            ddlAcadYear.Items.Add(new ListItem("All Years", ""));
            
            foreach (DataRow row in dt.Rows)
            {
                ddlAcadYear.Items.Add(new ListItem(row["acad_year"].ToString(), row["acad_year"].ToString()));
            }
            
            // Default to current year if available
            if (ddlAcadYear.Items.Count > 1)
                ddlAcadYear.SelectedIndex = 1;
        }
    }

    private void LoadFaculties()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT DISTINCT f.faccode, f.facname 
                            FROM acad_faculty f
                            INNER JOIN acad_programme p ON p.faculty = f.faccode
                            ORDER BY f.facname";

            MySqlDataAdapter da = new MySqlDataAdapter(query, conn);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlFaculty.Items.Clear();
            ddlFaculty.Items.Add(new ListItem("All Faculties", ""));
            
            foreach (DataRow row in dt.Rows)
            {
                ddlFaculty.Items.Add(new ListItem(row["facname"].ToString(), row["faccode"].ToString()));
            }
        }
    }

    private void LoadProgrammes()
    {
        string faculty = ddlFaculty.SelectedValue;
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT progcode, progname FROM acad_programme WHERE status = 'Active'";
            
            if (!string.IsNullOrEmpty(faculty))
            {
                query += " AND faculty = @Faculty";
            }
            
            query += " ORDER BY progname";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            if (!string.IsNullOrEmpty(faculty))
            {
                cmd.Parameters.AddWithValue("@Faculty", faculty);
            }
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("All Programmes", ""));
            
            foreach (DataRow row in dt.Rows)
            {
                ddlProgramme.Items.Add(new ListItem(row["progname"].ToString(), row["progcode"].ToString()));
            }
        }
    }

    private void LoadAnalytics()
    {
        LoadKPIStats();
        LoadGradeDistribution();
        LoadTopStudents();
        LoadProgrammePerformance();
        LoadTrendData();
        LoadProblematicCourses();
    }

    private void LoadKPIStats()
    {
        string whereClause = BuildWhereClause();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = $@"SELECT 
                COUNT(DISTINCT er.reg_no) AS total_students,
                COUNT(DISTINCT er.course_id) AS total_courses,
                SUM(CASE WHEN er.finalmark >= 50 THEN 1 ELSE 0 END) AS pass_count,
                SUM(CASE WHEN er.finalmark < 50 THEN 1 ELSE 0 END) AS fail_count,
                AVG(er.finalmark) AS avg_mark
                FROM acad_examresults_faculty er
                INNER JOIN acad_course c ON c.courseid = er.course_id
                INNER JOIN acad_programme p ON p.progcode = c.programme
                WHERE er.approved_by != '-' AND er.approved_by != 'HELD'
                {whereClause}";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            AddWhereClauseParameters(cmd);
            
            conn.Open();
            MySqlDataReader reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                int totalStudents = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                int totalCourses = reader.IsDBNull(1) ? 0 : reader.GetInt32(1);
                int passCount = reader.IsDBNull(2) ? 0 : Convert.ToInt32(reader.GetDecimal(2));
                int failCount = reader.IsDBNull(3) ? 0 : Convert.ToInt32(reader.GetDecimal(3));
                double avgMark = reader.IsDBNull(4) ? 0 : reader.GetDouble(4);
                
                int total = passCount + failCount;
                double passRate = total > 0 ? (double)passCount / total * 100 : 0;
                double failRate = total > 0 ? (double)failCount / total * 100 : 0;
                
                litTotalStudents.Text = totalStudents.ToString("N0");
                litTotalCourses.Text = totalCourses.ToString("N0");
                litPassRate.Text = passRate.ToString("F1") + "%";
                litFailRate.Text = failRate.ToString("F1") + "%";
                litAvgMark.Text = avgMark.ToString("F1");
            }
        }
    }

    private void LoadGradeDistribution()
    {
        string whereClause = BuildWhereClause();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = $@"SELECT 
                SUM(CASE WHEN er.finalmark >= 75 THEN 1 ELSE 0 END) AS first_class,
                SUM(CASE WHEN er.finalmark >= 65 AND er.finalmark < 75 THEN 1 ELSE 0 END) AS upper_second,
                SUM(CASE WHEN er.finalmark >= 55 AND er.finalmark < 65 THEN 1 ELSE 0 END) AS lower_second,
                SUM(CASE WHEN er.finalmark >= 50 AND er.finalmark < 55 THEN 1 ELSE 0 END) AS pass,
                SUM(CASE WHEN er.finalmark < 50 THEN 1 ELSE 0 END) AS fail,
                COUNT(*) AS total
                FROM acad_examresults_faculty er
                INNER JOIN acad_course c ON c.courseid = er.course_id
                INNER JOIN acad_programme p ON p.progcode = c.programme
                WHERE er.approved_by != '-' AND er.approved_by != 'HELD'
                {whereClause}";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            AddWhereClauseParameters(cmd);
            
            conn.Open();
            MySqlDataReader reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                int firstClass = reader.IsDBNull(0) ? 0 : Convert.ToInt32(reader.GetDecimal(0));
                int upperSecond = reader.IsDBNull(1) ? 0 : Convert.ToInt32(reader.GetDecimal(1));
                int lowerSecond = reader.IsDBNull(2) ? 0 : Convert.ToInt32(reader.GetDecimal(2));
                int pass = reader.IsDBNull(3) ? 0 : Convert.ToInt32(reader.GetDecimal(3));
                int fail = reader.IsDBNull(4) ? 0 : Convert.ToInt32(reader.GetDecimal(4));
                int total = reader.IsDBNull(5) ? 0 : Convert.ToInt32(reader.GetInt64(5));
                
                // Calculate percentages
                if (total > 0)
                {
                    FirstClassPct = Math.Round((double)firstClass / total * 100, 1);
                    UpperSecondPct = Math.Round((double)upperSecond / total * 100, 1);
                    LowerSecondPct = Math.Round((double)lowerSecond / total * 100, 1);
                    PassPct = Math.Round((double)pass / total * 100, 1);
                    FailPct = Math.Round((double)fail / total * 100, 1);
                }
                
                litFirstClass.Text = firstClass.ToString("N0");
                litUpperSecond.Text = upperSecond.ToString("N0");
                litLowerSecond.Text = lowerSecond.ToString("N0");
                litPass.Text = pass.ToString("N0");
                litFail.Text = fail.ToString("N0");
            }
        }
    }

    private void LoadTopStudents()
    {
        string whereClause = BuildWhereClause();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = $@"SELECT 
                er.reg_no AS regno,
                CONCAT(s.firstname, ' ', s.lastname) AS student_name,
                p.progname AS programme,
                AVG(er.finalmark) AS gpa
                FROM acad_examresults_faculty er
                INNER JOIN acad_student s ON s.regno = er.reg_no
                INNER JOIN acad_course c ON c.courseid = er.course_id
                INNER JOIN acad_programme p ON p.progcode = c.programme
                WHERE er.approved_by != '-' AND er.approved_by != 'HELD'
                {whereClause}
                GROUP BY er.reg_no, s.firstname, s.lastname, p.progname
                ORDER BY gpa DESC
                LIMIT 5";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            AddWhereClauseParameters(cmd);
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            rptTopStudents.DataSource = dt;
            rptTopStudents.DataBind();
        }
    }

    private void LoadProgrammePerformance()
    {
        string whereClause = BuildWhereClause();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = $@"SELECT 
                p.progcode,
                p.progname,
                COUNT(DISTINCT er.reg_no) AS total_students,
                SUM(CASE WHEN er.finalmark >= 50 THEN 1 ELSE 0 END) AS pass_count,
                SUM(CASE WHEN er.finalmark < 50 THEN 1 ELSE 0 END) AS fail_count,
                ROUND(SUM(CASE WHEN er.finalmark >= 50 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pass_rate,
                ROUND(AVG(er.finalmark), 1) AS avg_mark,
                SUM(CASE WHEN er.finalmark >= 75 THEN 1 ELSE 0 END) AS first_class,
                SUM(CASE WHEN er.finalmark >= 65 AND er.finalmark < 75 THEN 1 ELSE 0 END) AS upper_second
                FROM acad_programme p
                LEFT JOIN acad_course c ON c.programme = p.progcode
                LEFT JOIN acad_examresults_faculty er ON er.course_id = c.courseid AND er.approved_by != '-' AND er.approved_by != 'HELD'
                WHERE p.status = 'Active'
                {whereClause}
                GROUP BY p.progcode, p.progname
                HAVING total_students > 0
                ORDER BY pass_rate DESC";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            AddWhereClauseParameters(cmd);
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            gvProgrammePerformance.DataSource = dt;
            gvProgrammePerformance.DataBind();
        }
    }

    private void LoadTrendData()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT 
                er.acad_year,
                er.semester,
                CONCAT(er.acad_year, ' S', er.semester) AS semester_label,
                ROUND(SUM(CASE WHEN er.finalmark >= 50 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pass_rate
                FROM acad_examresults_faculty er
                WHERE er.approved_by != '-' AND er.approved_by != 'HELD'
                GROUP BY er.acad_year, er.semester
                ORDER BY er.acad_year DESC, er.semester DESC
                LIMIT 4";

            MySqlDataAdapter da = new MySqlDataAdapter(query, conn);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            // Calculate height percentages based on pass rate
            double maxRate = 100;
            foreach (DataRow row in dt.Rows)
            {
                double rate = row["pass_rate"] != DBNull.Value ? Convert.ToDouble(row["pass_rate"]) : 0;
                row["height"] = (rate / maxRate * 100).ToString("F0");
            }
            
            // Reverse order for display (oldest to newest)
            DataView dv = dt.DefaultView;
            dv.Sort = "acad_year ASC, semester ASC";
            
            rptTrend.DataSource = dv.ToTable();
            rptTrend.DataBind();
        }
    }

    private void LoadProblematicCourses()
    {
        string whereClause = BuildWhereClause();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = $@"SELECT 
                c.courseid AS course_id,
                c.coursename AS course_name,
                COUNT(*) AS total,
                CONCAT(ROUND(SUM(CASE WHEN er.finalmark < 50 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1), '%') AS fail_rate
                FROM acad_course c
                INNER JOIN acad_examresults_faculty er ON er.course_id = c.courseid
                INNER JOIN acad_programme p ON p.progcode = c.programme
                WHERE er.approved_by != '-' AND er.approved_by != 'HELD'
                {whereClause}
                GROUP BY c.courseid, c.coursename
                HAVING SUM(CASE WHEN er.finalmark < 50 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) > 30
                ORDER BY SUM(CASE WHEN er.finalmark < 50 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) DESC
                LIMIT 10";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            AddWhereClauseParameters(cmd);
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);
            
            gvProblematicCourses.DataSource = dt;
            gvProblematicCourses.DataBind();
        }
    }

    #endregion

    #region Helper Methods

    private string BuildWhereClause()
    {
        List<string> conditions = new List<string>();
        
        if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
        {
            conditions.Add("er.acad_year = @AcadYear");
        }
        
        if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
        {
            conditions.Add("er.semester = @Semester");
        }
        
        if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
        {
            conditions.Add("p.faculty = @Faculty");
        }
        
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            conditions.Add("c.programme = @Programme");
        }
        
        if (conditions.Count > 0)
        {
            return " AND " + string.Join(" AND ", conditions);
        }
        
        return "";
    }

    private void AddWhereClauseParameters(MySqlCommand cmd)
    {
        if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@AcadYear", ddlAcadYear.SelectedValue);
        }
        
        if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@Semester", ddlSemester.SelectedValue);
        }
        
        if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@Faculty", ddlFaculty.SelectedValue);
        }
        
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@Programme", ddlProgramme.SelectedValue);
        }
    }

    protected string GetPassRateBadge(object passRate)
    {
        if (passRate == null || passRate == DBNull.Value)
            return "<span class='rad-pass-rate rad-pass-rate--low'>N/A</span>";
            
        double rate = Convert.ToDouble(passRate);
        string cssClass = rate >= 70 ? "rad-pass-rate--high" : (rate >= 50 ? "rad-pass-rate--medium" : "rad-pass-rate--low");
        
        return $"<span class='rad-pass-rate {cssClass}'>{rate:F1}%</span>";
    }

    #endregion

    #region Event Handlers

    protected void Filter_Changed(object sender, EventArgs e)
    {
        LoadAnalytics();
    }

    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes();
        LoadAnalytics();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadAnalytics();
    }

    protected void btnExportProgrammes_Click(object sender, EventArgs e)
    {
        gvExporter.WriteXlsxToResponse("Programme_Performance_" + DateTime.Now.ToString("yyyyMMdd"));
    }

    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        // Export comprehensive Excel report
        gvExporter.WriteXlsxToResponse("Results_Analytics_" + DateTime.Now.ToString("yyyyMMdd"));
    }

    protected void btnExportPDF_Click(object sender, EventArgs e)
    {
        // For PDF export, you might want to use a reporting tool like XtraReports
        // This is a placeholder - implement based on your reporting infrastructure
        ScriptManager.RegisterStartupScript(this, GetType(), "pdfAlert", 
            "alert('PDF export feature coming soon. Please use Excel export for now.');", true);
    }

    #endregion
}
