using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Results_ResultsDocCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
        txtAcadYear.DataBind();
        if (!IsPostBack)
        {
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
        }

    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        Session["prog"] = txtProgramme.Value;
        Session["yr"] = txtYear.Text;
        Session["sem"] = txtSemester.Text;
        Session["acad"] = txtAcadYear.Text;
        Session["Report"] = txtDocument.Value;
        Session["intk"] = txtIntake.Text;
        Session["sess"] = txtSession.Text;
        Session["entyr"] = txt_entry_year.Text;
        //if (txtDocument.Text.Contains("Graduation"))
        //{
            Session["cat"] = "LIST";
            pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        //}
        //else
        //{
        //    pop_details.ContentUrl = "~/COOPERP/Results/Reports/PrintCentre.aspx";
        //}
        pop_details.ShowOnPageLoad = true;
    }
   
}