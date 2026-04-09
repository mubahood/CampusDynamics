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
            LoadCampuses();
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
            case "newcourses":
                title = "Course Bank";
                break;
            case "newstudentinfo":
                title = "Student Records";
                break;
            // Finance Module
            case "financedashboard":
                title = "Finance Dashboard";
                break;
            case "chartofaccounts":
                title = "Chart of Accounts";
                break;
            case "generalledger":
                title = "General Ledger";
                break;
            case "journalentries":
                title = "Journal Entries";
                break;
            case "paymentvouchers":
                title = "Payment Vouchers";
                break;
            case "studentreceipts":
                title = "Student Receipts";
                break;
            case "contravouchers":
                title = "Contra Vouchers";
                break;
            case "trialbalance":
                title = "Trial Balance";
                break;
            case "incomestatement":
                title = "Income Statement";
                break;
            case "balancesheet":
                title = "Balance Sheet";
                break;
            case "financialperiods":
                title = "Financial Periods";
                break;
            case "ledgercategories":
                title = "Ledger Categories";
                break;
            case "financeaudittrail":
                title = "Finance Audit Trail";
                break;
            case "suppliermanagement":
                title = "Supplier Management";
                break;
            // HR & Payroll Module
            case "hrdashboard":
                title = "HR & Payroll Dashboard";
                break;
            case "hremployees":
                title = "Employee Directory";
                break;
            case "hrcontracts":
                title = "Contracts";
                break;
            case "hrpayroll":
                title = "Payroll Management";
                break;
            case "hrpayslips":
                title = "Payslips";
                break;
            case "hrallowances":
                title = "Allowance Records";
                break;
            case "hrdeductions":
                title = "Deduction Records";
                break;
            case "hrleavemanagement":
                title = "Leave Management";
                break;
            case "hrsettings":
                title = "HR Settings";
                break;
            case "hrconfig":
                title = "Payroll & Tax Config";
                break;
            // System Configuration
            case "academicyears":
                title = "Academic Years";
                break;
            // Marks Module (Batch 13)
            case "teacherdashboard":
                title = "My Marks Dashboard";
                break;
            case "markentry":
                title = "Mark Entry";
                break;
            case "assignmentmanager":
                title = "Teaching Assignments";
                break;
            case "deadlinemanager":
                title = "Deadline Manager";
                break;
            case "deanapproval":
                title = "Dean Approval";
                break;
            case "auditcentre":
                title = "Audit Centre";
                break;
            case "marksalertdashboard":
                title = "Operational Alerts";
                break;
            // Elections Module
            case "electionsdashboard":
                title = "Elections Dashboard";
                break;
            case "electionposts":
                title = "Election Posts";
                break;
            case "electioncandidates":
                title = "Election Candidates";
                break;
            case "electionvoters":
                title = "Election Voters";
                break;
            case "electionresults":
                title = "Election Results";
                break;
            default:
                title = pageName.Replace("New", "").Replace("_", " ");
                break;
        }
        
        lblPageTitle.Text = title;
    }
    
    /// <summary>
    /// Gets the current academic year - now centralised in AcademicYearHelper.
    /// </summary>
    
    private void LoadAcademicYears()
    {
        ddlAcademicYear.Items.Clear();
        
        // Add empty option first
        ddlAcademicYear.Items.Add(new System.Web.UI.WebControls.ListItem("-", ""));
        
        string currentAcadYear = AcademicYearHelper.GetCurrentAcademicYear();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                // Get active years from acad_acadyears, filter to not show future academic years
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT acadyear FROM acad_acadyears WHERE status = 'Active' AND acadyear <= @currentYear ORDER BY acadyear DESC", conn))
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
    
    private void LoadCampuses()
    {
        ddlCampus.Items.Clear();
        
        // Add "No Campus" option first (default - no campus selected)
        ddlCampus.Items.Add(new System.Web.UI.WebControls.ListItem("- No Campus -", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                // Get all campuses excluding ID=0 (usually system/placeholder records)
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT ID, campus_name, campus_short_name FROM acad_campuses WHERE ID != 0 ORDER BY campus_name", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string id = reader["ID"].ToString();
                            string name = reader["campus_name"].ToString();
                            string shortName = reader["campus_short_name"] != DBNull.Value 
                                ? reader["campus_short_name"].ToString() 
                                : "";
                            
                            // Display short name if available, otherwise full name
                            string displayText = !string.IsNullOrEmpty(shortName) ? shortName : name;
                            
                            ddlCampus.Items.Add(new System.Web.UI.WebControls.ListItem(displayText, id));
                        }
                    }
                }
            }
        }
        catch
        {
            // If database fails, just keep the "No Campus" option
        }
        
        // Set selected campus from session if available
        if (Session["SelectedCampus"] != null && !string.IsNullOrEmpty(Session["SelectedCampus"].ToString()))
        {
            string savedCampus = Session["SelectedCampus"].ToString();
            if (ddlCampus.Items.FindByValue(savedCampus) != null)
            {
                ddlCampus.SelectedValue = savedCampus;
            }
        }
        // Otherwise, leave default "No Campus" selected (which has empty value)
    }
    
    protected void ddlCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Save selected campus to session
        Session["SelectedCampus"] = ddlCampus.SelectedValue;
        
        // Also set campusno session variable for compatibility with existing system
        if (!string.IsNullOrEmpty(ddlCampus.SelectedValue))
        {
            Session["campusno"] = ddlCampus.SelectedValue;
        }
        else
        {
            Session["campusno"] = null;
        }
    }
}
