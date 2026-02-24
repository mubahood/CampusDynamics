using DevExpress.XtraPrinting;
using ResultsDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Results_BestPerformersAnnual : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcadYear.DataSource = SettingsFile.ReturnAcademicYrs();
            txtAcadYear.DataBind();
            txtAcadYear.Text = SettingsFile.ReturnDefaultGraduationYr();
        }
        pop_details.HeaderText = SettingsFile.AppName;

        
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        GVE_Marksheets.WriteXlsToResponse(string.Format("{0} BEST PERFORMERS_{1}_{2}", txtAcadYear.Text, txtGender.Text,txtFaculty.Text), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        acad_Get_GraduationCompletionDataTableAdapter COMP = new acad_Get_GraduationCompletionDataTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected";
        int noRows = gvMarksheetInfo.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String stat = gvMarksheetInfo.GetRowValues(i, "comp").ToString();
                if (stat != "COMPLETED")
                {
                    if (txtGender.Text == "ALL")
                    {
                        Comm = "SORRY, ONLY COMPLETED Students can Graduate";
                    }
                    else
                    {
                        Comm = COMP.acad_RemoveGraduand(gvMarksheetInfo.GetRowValues(i, "regno").ToString(), usr).ToString();
                    }
                }
                else
                {
                    Comm = COMP.acad_AddGraduand(gvMarksheetInfo.GetRowValues(i, "regno").ToString(), txtAcadYear.Text,
                        double.Parse(gvMarksheetInfo.GetRowValues(i, "cgpa").ToString()),
                        gvMarksheetInfo.GetRowValues(i, "AwardClass").ToString(), gvMarksheetInfo.GetRowValues(i, "stud_name").ToString(),
                        txtFaculty.Value.ToString(), usr, gvMarksheetInfo.GetRowValues(i, "gender").ToString()).ToString();
                }
            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    
    protected void cmdProfile_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 500;
        Session["regno"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        pop_details.ContentUrl = "~/COOPERP/StudentInfo/StudentProfile.aspx";
        pop_details.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void cmdAlign_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 580;
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        Session["stud_name"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "stud_name");
        pop_details.ContentUrl = "~/COOPERP/Results/ResultsRearrangement.aspx";
        pop_details.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        
            
    }
    protected void txtStatus_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void gvMarksheetInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}