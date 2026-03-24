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

        // Load Academic Years from centralised helper
        AcademicYearHelper.PopulateDropDown(ddlAcadYear, false, false);

        // Load Entry Years
        AcademicYearHelper.PopulateEntryYearDropDown(ddlEntryYear);
        ddlEntryYear.Items.Insert(0, new ListItem("-- All --", ""));
    }

    protected void SetDefaultValues()
    {
        // Set default academic year
        string defaultYear = AcademicYearHelper.GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
        {
            ddlAcadYear.SelectedValue = defaultYear;
        }

        // Update display
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
    }

    // Academic year logic centralised in AcademicYearHelper

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

        // Open preview popup - resolve URL properly for DevExpress control
        popPreview.ContentUrl = ResolveUrl("~/COOPERP/XtraReports/Default.aspx");
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
