using System;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Collections.Generic;

public partial class COOPERP_NewScreens_NewDashboard : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadDashboardStats();
        }
    }
    
    private string GetCurrentAcademicYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;
        
        if (month >= 8)
            return year + "/" + (year + 1);
        else
            return (year - 1) + "/" + year;
    }
    
    private void LoadDashboardStats()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            try
            {
                conn.Open();
                
                string currentYear = GetCurrentAcademicYear();
                lblCurrentYear.Text = currentYear;
                
                // ========== STUDENT METRICS ==========
                
                // Total Students
                int totalStudents = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student", conn))
                {
                    totalStudents = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalStudents.Text = String.Format("{0:N0}", totalStudents);
                }
                
                // Male Students
                int maleStudents = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student WHERE gender = 'Male'", conn))
                {
                    maleStudents = Convert.ToInt32(cmd.ExecuteScalar());
                    lblMaleStudents.Text = String.Format("{0:N0}", maleStudents);
                    hfMaleCount.Value = maleStudents.ToString();
                }
                
                // Female Students
                int femaleStudents = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student WHERE gender = 'Female'", conn))
                {
                    femaleStudents = Convert.ToInt32(cmd.ExecuteScalar());
                    lblFemaleStudents.Text = String.Format("{0:N0}", femaleStudents);
                    hfFemaleCount.Value = femaleStudents.ToString();
                }
                
                // Gender Ratio
                if (femaleStudents > 0)
                {
                    double ratio = Math.Round((double)maleStudents / femaleStudents, 2);
                    lblGenderRatio.Text = ratio.ToString("0.00") + ":1";
                }
                
                // Current Year Enrollments
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_registration WHERE acad_year = @year", conn))
                {
                    cmd.Parameters.AddWithValue("@year", currentYear);
                    int currentEnrollments = Convert.ToInt32(cmd.ExecuteScalar());
                    lblCurrentEnrollments.Text = String.Format("{0:N0}", currentEnrollments);
                }
                
                // Total Registrations
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_registration", conn))
                {
                    int totalReg = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalRegistrations.Text = String.Format("{0:N0}", totalReg);
                }
                
                // Applications
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_applications", conn))
                {
                    int apps = Convert.ToInt32(cmd.ExecuteScalar());
                    lblApplications.Text = String.Format("{0:N0}", apps);
                }
                
                // Exam Results
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_results", conn))
                {
                    int results = Convert.ToInt32(cmd.ExecuteScalar());
                    lblExamResults.Text = String.Format("{0:N0}", results);
                }
                
                // ========== ACADEMIC STRUCTURE ==========
                
                // Faculties
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_faculty", conn))
                {
                    lblFaculties.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Programmes
                int totalProgrammes = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programme", conn))
                {
                    totalProgrammes = Convert.ToInt32(cmd.ExecuteScalar());
                    lblProgrammes.Text = totalProgrammes.ToString();
                }
                
                // Specialisations
                int totalSpecs = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation", conn))
                {
                    totalSpecs = Convert.ToInt32(cmd.ExecuteScalar());
                    lblSpecialisations.Text = totalSpecs.ToString();
                }
                
                // Courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course", conn))
                {
                    lblCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // ========== COURSE STATISTICS ==========
                
                // Programme Courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses", conn))
                {
                    lblTotalProgrammeCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Core Courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE course_type = 'CORE' OR course_type IS NULL", conn))
                {
                    lblCoreCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Elective Courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE course_type = 'ELECTIVE'", conn))
                {
                    lblElectiveCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Default Specialisations
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation WHERE spec = 'Default'", conn))
                {
                    lblDefaultSpecs.Text = cmd.ExecuteScalar().ToString();
                }
                
                // ========== CONFIGURATION STATUS ==========
                
                // Programmes Configured
                int progsConfigured = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programme WHERE is_fully_set = 'Yes'", conn))
                {
                    progsConfigured = Convert.ToInt32(cmd.ExecuteScalar());
                }
                int progPercent = totalProgrammes > 0 ? (progsConfigured * 100 / totalProgrammes) : 0;
                lblProgConfigured.Text = progPercent.ToString();
                progBar.Style["width"] = progPercent + "%";
                lblUnConfiguredProgs.Text = (totalProgrammes - progsConfigured).ToString();
                
                // Specialisations Configured
                int specsConfigured = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation WHERE is_fully_set = 'Yes'", conn))
                {
                    specsConfigured = Convert.ToInt32(cmd.ExecuteScalar());
                }
                int specPercent = totalSpecs > 0 ? (specsConfigured * 100 / totalSpecs) : 0;
                lblSpecConfigured.Text = specPercent.ToString();
                specBar.Style["width"] = specPercent + "%";
                lblUnConfiguredSpecs.Text = (totalSpecs - specsConfigured).ToString();
                
                // Programmes with Courses
                int progsWithCourses = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(DISTINCT progcode) FROM acad_programmecourses", conn))
                {
                    progsWithCourses = Convert.ToInt32(cmd.ExecuteScalar());
                }
                int coursesPercent = totalProgrammes > 0 ? (progsWithCourses * 100 / totalProgrammes) : 0;
                lblProgWithCourses.Text = coursesPercent.ToString();
                coursesBar.Style["width"] = coursesPercent + "%";
                
                // ========== ENROLLMENT BY YEAR (for table and chart) ==========
                
                DataTable dtEnrollments = new DataTable();
                List<object> chartData = new List<object>();
                
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT acad_year, COUNT(*) as count FROM acad_registration " +
                    "GROUP BY acad_year ORDER BY acad_year DESC LIMIT 5", conn))
                {
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtEnrollments);
                    }
                }
                
                // Bind to repeater (newest first)
                rptEnrollmentsByYear.DataSource = dtEnrollments;
                rptEnrollmentsByYear.DataBind();
                
                // Build chart data (oldest first for chart)
                for (int i = dtEnrollments.Rows.Count - 1; i >= 0; i--)
                {
                    DataRow row = dtEnrollments.Rows[i];
                    chartData.Add(new { 
                        year = row["acad_year"].ToString(), 
                        count = Convert.ToInt32(row["count"]) 
                    });
                }
                
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                hfEnrollmentData.Value = serializer.Serialize(chartData);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Dashboard Error: " + ex.Message);
            }
        }
    }
}
