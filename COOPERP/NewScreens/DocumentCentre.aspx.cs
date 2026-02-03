using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_DocumentCentre : System.Web.UI.Page
{
    private string connectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilters();
            SetDefaultValues();
        }
    }

    protected void LoadFilters()
    {
        // Load Programmes
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();
            string sql = "SELECT progcode, progname FROM acad_programme ORDER BY progname";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlProgramme.Items.Clear();
                    ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
                    while (dr.Read())
                    {
                        string code = dr["progcode"].ToString();
                        string name = dr["progname"].ToString();
                        ddlProgramme.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
        }

        // Load Academic Years (programmatically)
        ddlAcadYear.Items.Clear();
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 10; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
        }

        // Load Entry Years
        ddlEntryYear.Items.Clear();
        ddlEntryYear.Items.Add(new ListItem("-- All --", ""));
        for (int i = currentYear; i >= currentYear - 10; i--)
        {
            ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }
    }

    protected void SetDefaultValues()
    {
        // Set default academic year
        string defaultYear = GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
        {
            ddlAcadYear.SelectedValue = defaultYear;
        }

        // Update display
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
    }

    private string GetCurrentAcademicYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;

        // If we're in the second half of the year (August onwards), the academic year is current/next
        if (month >= 8)
            return string.Format("{0}/{1}", year, year + 1);
        else
            return string.Format("{0}/{1}", year - 1, year);
    }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
    }

    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
    }

    protected void btnPreview_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            ShowMessage("Please select a programme.", "warning");
            return;
        }

        // Set session variables for report
        SetReportSession();

        // Open preview popup
        popPreview.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        popPreview.ShowOnPageLoad = true;
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            ShowMessage("Please select a programme.", "warning");
            return;
        }

        // Set session variables for report
        SetReportSession();

        // Open in new window for printing
        string script = "window.open('" + ResolveUrl("~/COOPERP/XtraReports/Default.aspx") + "', '_blank', 'width=1000,height=700');";
        ScriptManager.RegisterStartupScript(this, GetType(), "print", script, true);
    }

    private void SetReportSession()
    {
        Session["prog"] = ddlProgramme.SelectedValue;
        Session["yr"] = ddlStudyYear.SelectedValue;
        Session["sem"] = ddlSemester.SelectedValue;
        Session["acad"] = ddlAcadYear.SelectedValue;
        Session["Report"] = hdnDocumentType.Value;
        Session["intk"] = ddlIntake.SelectedValue;
        Session["sess"] = ""; // Study session if needed
        Session["entyr"] = ddlEntryYear.SelectedValue;
        Session["cat"] = "LIST";
    }

    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "dc-message dc-message--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }
}
