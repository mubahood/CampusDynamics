using System;
using System.Data;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_NewDashboard : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Set date
            lblDate.Text = DateTime.Now.ToString("dddd, MMMM dd, yyyy");
            
            LoadDashboardStats();
        }
    }
    
    private void LoadDashboardStats()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            try
            {
                conn.Open();
                
                // Get Faculties count
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_faculty", conn))
                {
                    lblFaculties.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Get Programmes count
                int totalProgrammes = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programme", conn))
                {
                    totalProgrammes = Convert.ToInt32(cmd.ExecuteScalar());
                    lblProgrammes.Text = totalProgrammes.ToString();
                }
                
                // Get Specialisations count
                int totalSpecs = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation", conn))
                {
                    totalSpecs = Convert.ToInt32(cmd.ExecuteScalar());
                    lblSpecialisations.Text = totalSpecs.ToString();
                }
                
                // Get Courses count
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course", conn))
                {
                    lblCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Get Programme Courses stats
                int totalProgrammeCourses = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses", conn))
                {
                    totalProgrammeCourses = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalProgrammeCourses.Text = totalProgrammeCourses.ToString();
                }
                
                // Get Core Courses count
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE course_type = 'CORE' OR course_type IS NULL", conn))
                {
                    lblCoreCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Get Elective Courses count
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE course_type = 'ELECTIVE'", conn))
                {
                    lblElectiveCourses.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Get Default Specialisations count
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation WHERE spec = 'Default'", conn))
                {
                    lblDefaultSpecs.Text = cmd.ExecuteScalar().ToString();
                }
                
                // Calculate Configuration Progress
                
                // Programmes Fully Configured percentage
                int progsConfigured = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programme WHERE is_fully_set = 'Yes'", conn))
                {
                    progsConfigured = Convert.ToInt32(cmd.ExecuteScalar());
                }
                int progPercent = totalProgrammes > 0 ? (progsConfigured * 100 / totalProgrammes) : 0;
                lblProgConfigured.Text = progPercent.ToString();
                progBar.Style["width"] = progPercent + "%";
                
                // Specialisations Fully Configured percentage
                int specsConfigured = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation WHERE is_fully_set = 'Yes'", conn))
                {
                    specsConfigured = Convert.ToInt32(cmd.ExecuteScalar());
                }
                int specPercent = totalSpecs > 0 ? (specsConfigured * 100 / totalSpecs) : 0;
                lblSpecConfigured.Text = specPercent.ToString();
                specBar.Style["width"] = specPercent + "%";
                
                // Programmes with Courses percentage
                int progsWithCourses = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(DISTINCT progcode) FROM acad_programmecourses", conn))
                {
                    progsWithCourses = Convert.ToInt32(cmd.ExecuteScalar());
                }
                int coursesPercent = totalProgrammes > 0 ? (progsWithCourses * 100 / totalProgrammes) : 0;
                lblProgWithCourses.Text = coursesPercent.ToString();
                coursesBar.Style["width"] = coursesPercent + "%";
            }
            catch (Exception ex)
            {
                // Handle error silently for dashboard - show zeros
                System.Diagnostics.Debug.WriteLine("Dashboard Error: " + ex.Message);
            }
        }
    }
}
