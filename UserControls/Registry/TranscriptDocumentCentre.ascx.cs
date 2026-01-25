using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ResultsDataTableAdapters;

public partial class UserControls_Registry_TranscriptDocumentCentre : System.Web.UI.UserControl
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
   
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = txtDocument.Text;
        String TransStat = "Ready", CertStatus="Ready";
        try
        {
            TransStat = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "trans_status").ToString();
            CertStatus = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "cert_status").ToString();
        }
        catch (Exception) { 

        }
            if (txtDocument.Text.Contains("Trans") && TransStat != "Ready")
            {
                lbl_msg.Text = "Transcript Already Printed";
                pop_msgBox.ShowOnPageLoad = true;
            }
            else if (txtDocument.Text.Contains("Cert") && CertStatus != "Ready")
            {
                lbl_msg.Text = "Certificate Already Printed";
                pop_msgBox.ShowOnPageLoad = true;
            }
            else
            {
                
                Session["acad"] = txtAcadYear.Text;
                Session["prog"] = txtProgramme.Value;
                Session["cat"] = txtDocument.Text;
                Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
                //if (txtDocument.Text.Contains("Certificate") || txtDocument.Text.Contains("Letter") )
                //{
                    Session["Report"] = txtDocument.Value;
                    pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
                //}
                //else
                //{
                //    pop_details.ContentUrl = "~/COOPERP/Results/Reports/PrintCentre.aspx";
                //}
                pop_details.Width = 1000;
                pop_details.Height = 500;
                pop_details.ShowOnPageLoad = true;

            }
            gvMarksheetInfo.DataBind();
       
    }
    protected void cmdUpdateStatus_Click(object sender, EventArgs e)
    {
        acad_Get_GraduationCompletionDataTableAdapter COMP = new acad_Get_GraduationCompletionDataTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected", stat="-";
        int noRows = gvMarksheetInfo.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String reg = gvMarksheetInfo.GetRowValues(i, "regno").ToString();
                if(txtDocument.Text.Contains("Transcript"))
                {
                    stat = gvMarksheetInfo.GetRowValues(i, "trans_status").ToString();
                    Comm = COMP.acad_UpdateDocStatus(reg, "Transcript", stat, usr).ToString();
                }
                else
                {
                    stat = gvMarksheetInfo.GetRowValues(i, "cert_status").ToString();
                    Comm = COMP.acad_UpdateDocStatus(reg, "Certificate", stat, usr).ToString();
                }
               
            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void txtDocument_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvMarksheetInfo.DataBind();
    }
    protected void txtAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvMarksheetInfo.DataBind();
    }
    protected void cmdGradDate_Click(object sender, EventArgs e)
    {
        pop_set_gradinfo.ShowOnPageLoad = true;
    }
    protected void cmdCompDate_Click(object sender, EventArgs e)
    {
        acad_Get_GraduationCompletionDataTableAdapter COMP = new acad_Get_GraduationCompletionDataTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected";
        int noRows = gvMarksheetInfo.VisibleRowCount, counter = 0;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String reg = gvMarksheetInfo.GetRowValues(i, "regno").ToString();
                counter++;
                COMP.SetCompletionDate(DateTime.Parse(txtGradDate.Value.ToString()), reg).ToString();
                Comm = "Completion Date Set for " + counter + " Student(s)";
            }

        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void cmdReverseStatus_Click(object sender, EventArgs e)
    {
        acad_Get_GraduationCompletionDataTableAdapter COMP = new acad_Get_GraduationCompletionDataTableAdapter();
        String usr = HttpContext.Current.User.Identity.Name, Comm = "No Student Selected", stat = "-";
        int noRows = gvMarksheetInfo.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                String reg = gvMarksheetInfo.GetRowValues(i, "regno").ToString();
                if (txtDocument.Text.Contains("Transcript"))
                {
                    stat = gvMarksheetInfo.GetRowValues(i, "trans_status").ToString();
                    Comm = COMP.acad_ReverseDocStatus(reg, "Transcript", stat, usr).ToString();
                }
                else
                {
                    stat = gvMarksheetInfo.GetRowValues(i, "cert_status").ToString();
                    Comm = COMP.acad_ReverseDocStatus(reg, "Certificate", stat, usr).ToString();
                }

            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
    }
    protected void gvMarksheetInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdRefreshTranscript_Click(object sender, EventArgs e)
    {
        TranscriptSetupDataTableAdapters.acad_transcript_format_detailTableAdapter TRANS = new TranscriptSetupDataTableAdapters.acad_transcript_format_detailTableAdapter();
        int noRows = gvMarksheetInfo.VisibleRowCount,counter=0;
        for (int i = 0; i < noRows; i++)
        {
            if (gvMarksheetInfo.Selection.IsRowSelected(i))
            {
                TRANS.acad_CreateTranscript(gvMarksheetInfo.GetRowValues(i, "regno").ToString(), rb_type.Value.ToString(),
                    int.Parse(txtTranscriptFormat.Value.ToString()));
                counter++;
            }
        }
        lbl_msg.Text = counter+" Transcripts Processed";
        pop_msgBox.ShowOnPageLoad = true;
    }
    protected void cmdTranscriptConfig_Click(object sender, EventArgs e)
    {
        pop_create_transcripts.ShowOnPageLoad = true;
    }
    protected void rb_type_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (rb_type.SelectedItem.Value.ToString() == "Custom")
        {
            
        }
        else
        {
        }
    }
    protected void txtProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtTranscriptFormat.DataBind();
        txtTranscriptFormat.SelectedIndex = 0;
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
    protected void cmdResultsSync_Click(object sender, EventArgs e)
    {
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        pop_details.ContentUrl = "~/COOPERP/Results/ResultsRearrangement.aspx";
       
        pop_details.Width = 800;
        pop_details.Height = 600;
        pop_details.ShowOnPageLoad = true;

    }
}