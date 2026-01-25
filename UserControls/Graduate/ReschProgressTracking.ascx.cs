using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Graduate_ReschProgressTracking : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        txtMark.Text = Session["mark"].ToString();
        if (!IsPostBack)
        {
            txtAcademicYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtAcademicYear.DataBind();
            txtAcademicYear.Text = CommonRoutines.DefaultAcadYear();
        }
    }
    protected void ASPxButton1_Click(object sender, EventArgs e)
    {
        ProgTrackingGV.AddNewRow();
    }
    protected void ProgTrackingGV_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["Rid"] = Session["ReschID"];
    }
    protected void Btn_Print_doc_Click(object sender, EventArgs e)
    {
        Session["Reportname"] = ReportComboBox.SelectedIndex;
        Response.Redirect("~/COOPERP/Graduate/GraduateReports.aspx");
    }
    protected void ReportComboBox_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        try
        {
            GraduateDataTableAdapters.acad_GetGraduateResearchCoursesTableAdapter RES = new GraduateDataTableAdapters.acad_GetGraduateResearchCoursesTableAdapter();
            RES.acad_CaptureResearchResults(HttpContext.Current.User.Identity.Name, Session["regno"].ToString(), txtCourseCode.Value.ToString(), txtAcademicYear.Text,
                int.Parse(txtMark.Text), int.Parse(txtStudyYear.Text));
            lbl_pop.Text = "Results Approved Successfully";
        }
        catch (Exception ex) { lbl_pop.Text = "Error! ["+ex.Message+"]"; }
        pop_msgbox.ShowOnPageLoad = true;
    }
}