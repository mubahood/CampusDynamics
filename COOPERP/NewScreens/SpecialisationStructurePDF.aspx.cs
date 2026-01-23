using System;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
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
            
            // Set header info
            litInstitution.Text = GetInstitutionName();
            litProgramme.Text = progName;
            litSpecialisation.Text = specName;
            
            // Load logo
            string logoPath = GetLogoPath();
            if (!string.IsNullOrEmpty(logoPath))
            {
                imgLogo.ImageUrl = "~/" + logoPath;
                imgLogo.Visible = true;
            }
            
            if (specId > 0)
            {
                LoadCourseStructure(specId);
            }
            else
            {
                phContent.Controls.Add(new LiteralControl("<div class='no-data'>No specialisation specified.</div>"));
            }
        }
    }

    private void LoadCourseStructure(int specId)
    {
        DataTable dtCourses = GetAllCoursesForSpec(specId);
        
        if (dtCourses.Rows.Count == 0)
        {
            phContent.Controls.Add(new LiteralControl("<div class='no-data'>No courses found for this specialisation.</div>"));
            litTotalCourses.Text = "0";
            litTotalCredits.Text = "0";
            return;
        }
        
        // Calculate totals
        int totalCourses = dtCourses.Rows.Count;
        double totalCredits = 0;
        foreach (DataRow row in dtCourses.Rows)
        {
            totalCredits += row["CreditUnit"] != DBNull.Value ? Convert.ToDouble(row["CreditUnit"]) : 0;
        }
        
        litTotalCourses.Text = totalCourses.ToString();
        litTotalCredits.Text = totalCredits.ToString();
        
        StringBuilder sb = new StringBuilder();
        
        // Group by year and semester
        for (int year = 1; year <= 5; year++)
        {
            DataRow[] yearCourses = dtCourses.Select("study_year = " + year);
            if (yearCourses.Length == 0) continue;
            
            sb.AppendLine("<div class='year-section'>");
            sb.AppendLine("<div class='year-header'>YEAR " + year + "</div>");
            
            for (int sem = 1; sem <= 2; sem++)
            {
                DataRow[] semCourses = dtCourses.Select("study_year = " + year + " AND semester = " + sem);
                if (semCourses.Length == 0) continue;
                
                // Calculate semester credits
                double semCredits = 0;
                foreach (DataRow row in semCourses)
                {
                    semCredits += row["CreditUnit"] != DBNull.Value ? Convert.ToDouble(row["CreditUnit"]) : 0;
                }
                
                sb.AppendLine("<div class='semester-section'>");
                sb.AppendFormat("<div class='semester-header'>Semester {0} ({1} courses, {2} CU)</div>", sem, semCourses.Length, semCredits);
                
                sb.AppendLine("<table>");
                sb.AppendLine("<thead><tr><th class='code'>Code</th><th>Course Name</th><th class='type'>Type</th><th class='cu'>CU</th></tr></thead>");
                sb.AppendLine("<tbody>");
                
                foreach (DataRow row in semCourses)
                {
                    string code = row["course_code"].ToString();
                    string name = row["courseName"] != DBNull.Value ? row["courseName"].ToString() : "";
                    string courseType = row["course_type"] != DBNull.Value ? row["course_type"].ToString() : "CORE";
                    double credits = row["CreditUnit"] != DBNull.Value ? Convert.ToDouble(row["CreditUnit"]) : 0;
                    
                    string typeDisplay = courseType == "ELECTIVE" ? "E" : "C";
                    string typeClass = courseType == "ELECTIVE" ? "type-elective" : "type-core";
                    
                    sb.AppendFormat("<tr><td class='code'>{0}</td><td>{1}</td><td class='type {4}'>{2}</td><td class='cu'>{3}</td></tr>",
                        Server.HtmlEncode(code),
                        Server.HtmlEncode(name),
                        typeDisplay,
                        credits,
                        typeClass);
                }
                
                sb.AppendLine("</tbody></table>");
                sb.AppendLine("</div>"); // semester-section
            }
            
            sb.AppendLine("</div>"); // year-section
        }
        
        phContent.Controls.Add(new LiteralControl(sb.ToString()));
    }

    private DataTable GetAllCoursesForSpec(int specId)
    {
        DataTable dt = new DataTable();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = @"SELECT pc.course_code, c.courseName, COALESCE(c.CreditUnit, 0) as CreditUnit, 
                          pc.study_year, pc.semester, COALESCE(pc.course_type, 'CORE') as course_type
                          FROM acad_programmecourses pc 
                          LEFT JOIN acad_course c ON pc.course_code = c.courseID 
                          WHERE pc.specialisation_id = @specId 
                          ORDER BY pc.study_year, pc.semester, pc.course_code";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        
        return dt;
    }
    
    private string GetInstitutionName()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("SELECT SettingValue FROM sys_setting WHERE SettingKey = 'InstitutionName' LIMIT 1", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        return result.ToString();
                }
            }
        }
        catch { }
        return "Campus Dynamics Institution";
    }
    
    private string GetLogoPath()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("SELECT SettingValue FROM sys_setting WHERE SettingKey = 'LogoPath' LIMIT 1", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        return result.ToString();
                }
            }
        }
        catch { }
        return "";
    }
}
