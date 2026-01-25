using System;
using System.Web.UI;
using System.Data;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_SidebarMaster : System.Web.UI.MasterPage
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Set footer text
        lbl_footer.Text = "© " + DateTime.Now.Year + " Mutesa I Royal University - Powered by Campus Dynamics";
        
        // Set brand link
        linkBrand.HRef = ResolveUrl("~/COOPERP/NewScreens/NewDashboard.aspx");
        
        // Set dynamic page title based on current page
        SetPageTitle();
        
        // Load dropdowns
        if (!IsPostBack)
        {
            LoadAcademicYears();
            LoadSemesters();
        }
    }
    
    private void SetPageTitle()
    {
        string pageName = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);
        string title = "Dashboard";
        
        switch (pageName.ToLower())
        {
            case "newdashboard":
                title = "Dashboard";
                break;
            case "newfaculties":
                title = "Faculties";
                break;
            case "newfacultyprogrammes":
                title = "Programmes";
                break;
            case "newspecialisations":
                title = "Specialisations";
                break;
            case "newprogrammecourses":
                title = "Programme Courses";
                break;
            default:
                title = pageName.Replace("New", "").Replace("_", " ");
                break;
        }
        
        lblPageTitle.Text = title;
    }
    
    /// <summary>
    /// Gets the current academic year based on the date.
    /// Academic year runs from approximately August to July.
    /// Example: In January 2026, current academic year is 2025/2026
    /// </summary>
    private string GetCurrentAcademicYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;
        
        // If we're in months Jan-July, academic year started previous calendar year
        // If we're in months Aug-Dec, academic year started this calendar year
        if (month >= 8) // August onwards = new academic year
        {
            return year + "/" + (year + 1);
        }
        else // January to July = academic year that started last year
        {
            return (year - 1) + "/" + year;
        }
    }
    
    private void LoadAcademicYears()
    {
        ddlAcademicYear.Items.Clear();
        
        // Add empty option first
        ddlAcademicYear.Items.Add(new System.Web.UI.WebControls.ListItem("-", ""));
        
        string currentAcadYear = GetCurrentAcademicYear();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                // Get years from database, filter to not show future academic years
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT DISTINCT acadyear FROM acad_acadyears WHERE acadyear <= @currentYear ORDER BY acadyear DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@currentYear", currentAcadYear);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string year = reader["acadyear"].ToString();
                            ddlAcademicYear.Items.Add(new System.Web.UI.WebControls.ListItem(year, year));
                        }
                    }
                }
            }
        }
        catch
        {
            // Fallback - add current and past 5 years if database fails
            int year = DateTime.Now.Year;
            int month = DateTime.Now.Month;
            int startYear = (month >= 8) ? year : year - 1;
            
            for (int i = 0; i < 6; i++)
            {
                string acadYear = (startYear - i) + "/" + (startYear - i + 1);
                ddlAcademicYear.Items.Add(new System.Web.UI.WebControls.ListItem(acadYear, acadYear));
            }
        }
        
        // Set selected academic year from session, or default to current year
        if (Session["SelectedAcademicYear"] != null && !string.IsNullOrEmpty(Session["SelectedAcademicYear"].ToString()))
        {
            string savedYear = Session["SelectedAcademicYear"].ToString();
            if (ddlAcademicYear.Items.FindByValue(savedYear) != null)
            {
                ddlAcademicYear.SelectedValue = savedYear;
            }
        }
        else
        {
            // Default to current academic year
            if (ddlAcademicYear.Items.FindByValue(currentAcadYear) != null)
            {
                ddlAcademicYear.SelectedValue = currentAcadYear;
                Session["SelectedAcademicYear"] = currentAcadYear;
            }
        }
    }
    
    private void LoadSemesters()
    {
        ddlSemester.Items.Clear();
        
        // Add empty option first
        ddlSemester.Items.Add(new System.Web.UI.WebControls.ListItem("-", ""));
        
        // Add semesters 1-3
        ddlSemester.Items.Add(new System.Web.UI.WebControls.ListItem("Sem 1", "1"));
        ddlSemester.Items.Add(new System.Web.UI.WebControls.ListItem("Sem 2", "2"));
        ddlSemester.Items.Add(new System.Web.UI.WebControls.ListItem("Sem 3", "3"));
        
        // Set selected semester from session if available
        if (Session["SelectedSemester"] != null && !string.IsNullOrEmpty(Session["SelectedSemester"].ToString()))
        {
            string savedSem = Session["SelectedSemester"].ToString();
            if (ddlSemester.Items.FindByValue(savedSem) != null)
            {
                ddlSemester.SelectedValue = savedSem;
            }
        }
    }
    
    protected void ddlAcademicYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Save selected academic year to session
        Session["SelectedAcademicYear"] = ddlAcademicYear.SelectedValue;
    }
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Save selected semester to session
        Session["SelectedSemester"] = ddlSemester.SelectedValue;
    }
}
