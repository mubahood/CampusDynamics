using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Results_ElectronicSheets : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultAcademicYr();
           
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
        Session["CourseName"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "course_name");
        Session["Exam_format"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "ExamFormat");
        Session["practical_percent"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "practical_percent");
        
        

        pop_details.Width = 1100;
        pop_details.Height = 600;
        pop_details.HeaderText = string.Format("MARKSHEET FOR {0} [{2}] - YEAR {1}",
             gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "classname"), gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "cyear"),
             gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "stud_session"));

        Session["headerText"] = string.Format("{1} [{0}] :: {2}, SEMESTER {3}",
             gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "courseID"),
             gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "course_name").ToString().ToUpper(), txtAcadYear.Text, txtSemester.Text);

        pop_details.ContentUrl = "~/COOPERP/Results/MarkSheetDetails.aspx";
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        GVE_Marksheets.WriteXlsToResponse(string.Format("{2} MarksheetList {0}_{1}", txtAcadYear.Text,txtSemester.Text,txtStatus.Text), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
   


    
}