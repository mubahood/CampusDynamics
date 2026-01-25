using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_StudentDocuments : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultGraduationYr();
            txtNationality.Text = "ALL";
            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();
        }
    }
    protected void cmdPrintList_Click(object sender, EventArgs e)
    {
        Session["Report"] = "StudentList";
        Session["DocType"] =txt_Doctype.Value;
        Session["fax"] = txtFaculty.Value;
        Session["prog"]=txtProgramme.Value;
        Session["acad"] = txtAcadYear.Text;
        Session["sem"] = txtSemester.Text;
        Session["sess"] = txtSession.Text;
        Session["intake"] = txtIntake.Text;
        Session["nat"] = txtNationality.Text;
        Session["Campus"] = txtCampus.Value;
        Session["EntYear"] =txt_entry_year.Text;
        pop_details.Width = 1000;
        pop_details.Height = 500;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        pop_details.ShowOnPageLoad = true;

    }
}