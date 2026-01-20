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

            txtCompDate.Date = DateTime.Today;
            txtGradDate.Date = DateTime.Today;

            txtPrintGradDate.Date = DateTime.Today;

            txtIntake.DataSource = CommonRoutines.ReturnMonths();
            txtIntake.DataBind();
            txtIntake.SelectedIndex = 8;

            txt_entry_year.DataSource = SettingsFile.ReturnYears();
            txt_entry_year.DataBind();
            txt_entry_year.Text = DateTime.Now.Year.ToString();

            txtStatus.Text = "ALL";
            

        }
        pop_details.HeaderText = SettingsFile.AppName;

        if (txtStatus.Text == "ALL")
        {
            cmdApprove.Text = "Add Graduand[s]";
            cmdApprove.ImageUrl = "~/COOPERP/images/tick-button.png";
            cmdPrint.Enabled = false;
            gvMarksheetInfo.Columns["pending"].Visible = true;
            //
        }
        else
        {
            cmdApprove.Text = "Remove Graduand[s]";
            cmdApprove.ImageUrl = "~/COOPERP/images/minus-button.png";
            cmdPrint.Enabled = true;
            gvMarksheetInfo.Columns["pending"].Visible = false;
        }
        try
        {
            if (txtProgramme.Value.ToString() == "-")
            {
                //cmdPrint.Enabled = false;
            }
            else
            {
                cmdPrint.Enabled = true;
            }
        }
        catch (Exception) { //cmdPrint.Enabled = false; 
        }
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        GVE_Marksheets.WriteXlsToResponse(string.Format("{2} GraduationList_{0}_{1}_{2}_Intake", txtAcadYear.Text, txtYear.Text, txtIntake.Text), new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
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
        try
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
                        if (txtStatus.Text == "ALL")
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
                            txtProgramme.Value.ToString(), usr, gvMarksheetInfo.GetRowValues(i, "gen").ToString()).ToString();
                    }
                }
            }
            lbl_msg.Text = Comm;
            
            gvMarksheetInfo.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error: " + ex.Message;
        }
        pop_msgBox.ShowOnPageLoad = true;
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = "GraduationLists";
        Session["acad"]=txtAcadYear.Text;
        Session["prog"]=txtProgramme.Value;
        Session["yr"]=txtYear.Text;
        Session["cat"] = "LIST";
        Session["gdate"] = txtPrintGradDate.Date;
        Session["sems"] = txtSemester.Text;
        Session["intk"] = txtIntake.Text;
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
        if (txtProgramme.Text == "-")
        {
            //cmdPrint.Enabled = false;
        }
        else {
            cmdPrint.Enabled = true;
        }
    }
    protected void cmdSetGraduationInfo_Click(object sender, EventArgs e)
    {
        acad_Get_GraduationCompletionDataTableAdapter COMP = new acad_Get_GraduationCompletionDataTableAdapter();
        acad_GetBatchStudentTranscriptDataTableAdapter GRAD = new acad_GetBatchStudentTranscriptDataTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected";
        int noRows = gvMarksheetInfo.VisibleRowCount, counter = 0;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String reg = gvMarksheetInfo.GetRowValues(i, "regno").ToString();
                counter++;
                COMP.SetCompletionDate(DateTime.Parse(txtCompDate.Value.ToString()), reg).ToString();
                COMP.SetGradDate(DateTime.Parse(txtGradDate.Value.ToString()), reg).ToString();
                GRAD.UpdateConvocation(txtConvocation.Text, reg);
                Comm = "Graduation InfoSet for " + counter + " Student(s)";
            }

        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }

    protected void cmdUpdateEntryMethod_Click(object sender, EventArgs e)
    {
        TranscriptSetupDataTableAdapters.acad_studentTableAdapter STUD = new TranscriptSetupDataTableAdapters.acad_studentTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected";
        int noRows = gvMarksheetInfo.VisibleRowCount, counter = 0;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String reg = gvMarksheetInfo.GetRowValues(i, "regno").ToString();
                counter++;
                STUD.UpdateEntryMethod(txtEntryMethod.Text, reg);
                Comm = "Entry Type Set for " + counter + " Student(s)";
            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void cmdSetEntryType_Click(object sender, EventArgs e)
    {
        pop_set_entry_type.ShowOnPageLoad = true;
    }
}