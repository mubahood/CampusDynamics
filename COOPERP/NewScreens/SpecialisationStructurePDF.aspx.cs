using System;
using System.Data;
using System.Text;
using System.Configuration;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_SpecialisationStructurePDF : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            int specId = 0;
            if (Request.QueryString["specId"] != null)
            {
                int.TryParse(Request.QueryString["specId"], out specId);
            }
            
            string specName = Request.QueryString["specName"] ?? "";
            string progName = Request.QueryString["progName"] ?? "";
            
            litSpecName.Text = Server.HtmlEncode(specName);
            litProgName.Text = Server.HtmlEncode(progName);
            litDate.Text = DateTime.Now.ToString("dd MMM yyyy HH:mm");
            
            if (specId > 0)
            {
                GenerateStructure(specId);
            }
        }
    }

    private void GenerateStructure(int specId)
    {
        StringBuilder sb = new StringBuilder();
        int totalCourses = 0;
        double totalCredits = 0;
        
        sb.Append("<table class='structure-table'>");
        sb.Append("<tr><th class='course-code'>Code</th><th class='course-name'>Course Name</th><th class='credits'>Credits</th></tr>");
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            for (int year = 1; year <= 5; year++)
            {
                // Check if year has courses
                bool yearHasCourses = false;
                using (MySqlCommand checkCmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_programmecourses WHERE specialisation_id = @specId AND study_year = @year", conn))
                {
                    checkCmd.Parameters.AddWithValue("@specId", specId);
                    checkCmd.Parameters.AddWithValue("@year", year);
                    yearHasCourses = Convert.ToInt32(checkCmd.ExecuteScalar()) > 0;
                }
                
                if (!yearHasCourses) continue;
                
                sb.Append("<tr><th colspan='3' class='year-header'>YEAR " + year + "</th></tr>");
                
                for (int sem = 1; sem <= 2; sem++)
                {
                    using (MySqlCommand cmd = new MySqlCommand(
                        "SELECT pc.course_code, c.courseName, COALESCE(c.CreditUnit, 0) as CreditUnit " +
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
                            bool semHasCourses = false;
                            StringBuilder semCourses = new StringBuilder();
                            double semCredits = 0;
                            int semCount = 0;
                            
                            while (reader.Read())
                            {
                                semHasCourses = true;
                                string courseCode = reader["course_code"].ToString();
                                string courseName = reader["courseName"] != DBNull.Value ? reader["courseName"].ToString() : "";
                                double credits = reader["CreditUnit"] != DBNull.Value ? Convert.ToDouble(reader["CreditUnit"]) : 0;
                                
                                semCourses.Append("<tr class='course-row'>");
                                semCourses.Append("<td class='course-code'>" + courseCode + "</td>");
                                semCourses.Append("<td class='course-name'>" + courseName + "</td>");
                                semCourses.Append("<td class='credits'>" + credits + "</td>");
                                semCourses.Append("</tr>");
                                
                                semCredits += credits;
                                semCount++;
                                totalCourses++;
                                totalCredits += credits;
                            }
                            
                            if (semHasCourses)
                            {
                                sb.Append("<tr><td colspan='3' class='semester-header'>Semester " + sem + " (" + semCount + " courses, " + semCredits + " CU)</td></tr>");
                                sb.Append(semCourses.ToString());
                            }
                        }
                    }
                }
            }
        }
        
        sb.Append("</table>");
        litStructure.Text = sb.ToString();
        
        // Summary
        StringBuilder summary = new StringBuilder();
        summary.Append("<div class='summary-row'><span><strong>Total Courses:</strong></span><span>" + totalCourses + "</span></div>");
        summary.Append("<div class='summary-row'><span><strong>Total Credit Units:</strong></span><span>" + totalCredits + "</span></div>");
        litSummary.Text = summary.ToString();
    }
}
