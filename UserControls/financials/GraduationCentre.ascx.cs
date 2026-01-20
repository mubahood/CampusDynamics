using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ResultsDataTableAdapters;

public partial class UserControls_Results_GraduationCentre : System.Web.UI.UserControl
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

        
        try
        {
            if (txtProgramme.Value.ToString() == "-")
            {
                cmdRefresh.Enabled = false;
            }
            else
            {
                cmdRefresh.Enabled = true;
            }
        }
        catch (Exception) { cmdRefresh.Enabled = false; }
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        GVE_Marksheets.WriteXlsToResponse(string.Format("{2} Graduation {0}_{1}", txtAcadYear.Text, txtYear.Text, txtStatus.Text), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    protected void cmdProbs_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.ContentUrl = "";
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        Session["stud_name"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "stud_name");

        pop_details.Width = 1000;
        pop_details.Height = 400;
        pop_details.DataBind();
        pop_details.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        acad_Get_GraduationCompletionDataTableAdapter COMP = new acad_Get_GraduationCompletionDataTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name,Comm="No Student Selected";
        int noRows = gvMarksheetInfo.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String stat = gvMarksheetInfo.GetRowValues(i, "comp").ToString();
                if (stat != "COMPLETED")
                {
                    if (txtStatus.Text == "ALL")
                    {
                        Comm = "SORRY, ONLY COMPLETED Students can Graduate";
                    }
                    else
                    {
                        //Comm = COMP.acad_RemoveGraduand(gvMarksheetInfo.GetRowValues(i, "regno").ToString(), usr).ToString();
                    }
                }
                else
                {
                    /*Comm = COMP.acad_AddGraduand(gvMarksheetInfo.GetRowValues(i,"regno").ToString(),txtAcadYear.Text,
                        double.Parse(gvMarksheetInfo.GetRowValues(i,"cgpa").ToString()),
                        gvMarksheetInfo.GetRowValues(i, "AwardClass").ToString(), gvMarksheetInfo.GetRowValues(i, "stud_name").ToString(),
                        txtProgramme.Value.ToString(), usr).ToString();*/
                }
            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = "GraduationLists";
        Session["acad"]=txtAcadYear.Text;
        Session["prog"]=txtProgramme.Value;
        Session["yr"]=txtYear.Text;
        Session["cat"] = txtStatus.Text;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        pop_details.Width = 1000;
        pop_details.Height = 500;
        pop_details.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();

    }
    protected void cmdProfile_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 500;
        Session["regno"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "stud_reg_no");
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
        if (txtProgramme.Text == "-")
        {
            cmdRefresh.Enabled = false;
        }
        else {
            cmdRefresh.Enabled = true;
        }
    }
    protected void cmdRefresh_Click(object sender, EventArgs e)
    {
        try
        {
            GraduationFinanceTableAdapters.acad_graduation_clearanceTableAdapter COMP = new GraduationFinanceTableAdapters.acad_graduation_clearanceTableAdapter();
            String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected";
            COMP.fin_CreateGraduationClearanceList(txtAcadYear.Text);
            lbl_msg.Text = "Clearance List Refreshed Successfully";
            gvMarksheetInfo.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Refresh Error! ["+ex.Message+"]";
        }
        pop_msgBox.ShowOnPageLoad = true;
    }
    protected void cmdClear_Click(object sender, EventArgs e)
    {
        ClearanceUpdate("Clearance");
    }
    public void ClearanceUpdate(string type)
    {
        GraduationFinanceTableAdapters.acad_graduation_clearanceTableAdapter COMP = 
            new GraduationFinanceTableAdapters.acad_graduation_clearanceTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected";
        int counter=0;
        int noRows = gvMarksheetInfo.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String bal = gvMarksheetInfo.GetRowValues(i, "cur_balance").ToString();
                if (bal.Contains("CREDIT"))
                {
                    String ID = gvMarksheetInfo.GetRowValues(i, "ID").ToString();
                    if (type == "Clearance")
                    {
                        counter++;
                        COMP.UpdateStatus("Cleared", usr, DateTime.Now, int.Parse(ID));
                        Comm = "Status Updated to CLEARED for "+counter+" students";
                    }
                    else
                    {
                        counter++;
                        COMP.UpdateStatus("Pending", "", null, int.Parse(ID));
                        Comm = "Status Updated to PENDING for " + counter + " students";
                    }
                }
                else
                {
                    Comm = "SORRY, ONLY 0 Balance or Credit Students can be Cleared";

                }
            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void cmdCancel_Click(object sender, EventArgs e)
    {
        ClearanceUpdate("Pending");
    }
}