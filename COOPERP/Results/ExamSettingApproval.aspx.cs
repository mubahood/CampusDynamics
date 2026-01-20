using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ExamSettingTableAdapters;

public partial class COOPERP_Timetables_ExamSettingApproval : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
            if (HttpContext.Current.User.IsInRole("Academic Registrar"))
            {
                txtStatus.Value = "APPROVED";
                txtStatus.Text = "APPROVED";
                gvMarksheetInfo.Columns["Print"].Visible = true;
            }

        }

        if (HttpContext.Current.User.IsInRole("Academic Registrar"))
        {
            gvMarksheetInfo.Columns["Detail"].Visible = false;
        }
    }

    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {
        Session["mid"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "ID");
        Session["acad"] = txtAcadYear.Text;
        Session["sem"] = txtSemester.Text;
        Session["csid"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "courseID");
        Session["cyr"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "cyear");
        Session["status"] = txtStatus.Value;
        Session["CourseName"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "Course_Name");
       



        pop_details.Width = 1100;
        pop_details.Height = 600;
        pop_details.HeaderText = string.Format("EXAM FOR {0} [{2}] - YEAR {1}",
            txtProgramme.Text , gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "cyear"),gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "stud_session"));

        Session["headerText"] = string.Format("{1} [{0}] :: {2}, SEMESTER {3}",
             gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "courseID"),
             gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "Course_Name").ToString().ToUpper(), txtAcadYear.Text, txtSemester.Text);

        pop_details.ContentUrl = "~/COOPERP/Results/ExamPaperDetail.aspx";
        pop_details.ShowOnPageLoad = true;
    }


    protected void btn_print_Click(object sender, ImageClickEventArgs e)
    {
        acad_examination_papersTableAdapter pap = new acad_examination_papersTableAdapter();
        Session["mid"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "ID");
        pop_print.ContentUrl = "~/COOPERP/Timetables/XtraReports/Default.aspx";
        pop_print.Width = 1000;
        pop_print.Height = 600;
        Session["Report"] = "ExamPaper";

        pop_print.ShowOnPageLoad = true;

        pap.UpdateStatus("PRINTED", int.Parse(gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "ID").ToString()));
    }
    protected void txtStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        if ((txtStatus.Text == "APPROVED" || txtStatus.Text == "PRINTED") && HttpContext.Current.User.IsInRole("Academic Registrar"))
        {
            gvMarksheetInfo.Columns["Print"].Visible = true;
            gvMarksheetInfo.Columns["Detail"].Visible = false;

        }
        else
        {
            gvMarksheetInfo.Columns["Print"].Visible = false;
        }
    }
}