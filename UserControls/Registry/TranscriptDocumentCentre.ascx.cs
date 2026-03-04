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
            txtMastersSenatDate.Date = DateTime.Today;
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
        // For Masters Letter, show the popup to collect additional info
        if (txtDocument.Text.Contains("Masters"))
        {
            pop_masters_letter.ShowOnPageLoad = true;
            return;
        }

        Session["acad"] = txtAcadYear.Text;
        Session["prog"] = txtProgramme.Value;
        Session["cat"] = txtDocument.Text;
        Session["reg"] = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno");
        Session["Report"] = txtDocument.Value;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        pop_details.Width = 1000;
        pop_details.Height = 500;
        pop_details.ShowOnPageLoad = true;
        gvMarksheetInfo.DataBind();
       
    }
    protected void cmdGenerateMastersLetter_Click(object sender, EventArgs e)
    {
        try
        {
            // Validate required selections
            if (string.IsNullOrEmpty(txtAcadYear.Text))
            {
                lbl_msg.Text = "Please select an Academic Year";
                pop_msgBox.ShowOnPageLoad = true;
                return;
            }

            if (txtProgramme.Value == null || string.IsNullOrEmpty(txtProgramme.Value.ToString()))
            {
                lbl_msg.Text = "Please select a Programme";
                pop_msgBox.ShowOnPageLoad = true;
                return;
            }

            if (gvMarksheetInfo.FocusedRowIndex < 0)
            {
                lbl_msg.Text = "Please select a student from the list";
                pop_msgBox.ShowOnPageLoad = true;
                return;
            }

            // Validate senate date — the only field collected from the popup
            if (txtMastersSenatDate.Date == DateTime.MinValue)
            {
                lbl_msg.Text = "Please enter the Senate Meeting Date";
                pop_msgBox.ShowOnPageLoad = true;
                return;
            }

            string reg = gvMarksheetInfo.GetRowValues(gvMarksheetInfo.FocusedRowIndex, "regno").ToString().Trim();

            // Senate date from popup — the only user-provided value
            string senateDate = txtMastersSenatDate.Date.ToString("dd MMMM, yyyy");

            // Reference number and letter date are auto-generated — no user input required
            string refNumber  = string.Format("MLA/{0}/{1}", reg, DateTime.Now.Year);
            string letterDate = DateTime.Now.ToString("dd MMMM, yyyy");

            // Store in Session (Default.aspx.cs reads these to populate report parameters)
            Session["Report"]              = "Masters Letter of Award";
            Session["acad"]                = txtAcadYear.Text;
            Session["prog"]                = txtProgramme.Value;
            Session["cat"]                 = "Masters Letter of Award";
            Session["reg"]                 = reg;
            Session["masters_ref"]         = refNumber;
            Session["masters_senate_date"] = senateDate;
            Session["masters_letter_date"] = letterDate;
            Session["masters_grad_date"]   = "";  // derived from dataset (formated_grad_date column)
            Session["masters_honours"]     = "";  // not collected

            // Open report viewer popup
            pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
            pop_details.Width  = 1000;
            pop_details.Height = 500;
            pop_details.ShowOnPageLoad       = true;
            pop_masters_letter.ShowOnPageLoad = false;
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error: " + ex.Message;
            pop_msgBox.ShowOnPageLoad = true;
        }
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
                    String docType = "Certificate";
                    if (txtDocument.Text.Contains("Masters"))
                        docType = "Masters";
                    Comm = COMP.acad_ReverseDocStatus(reg, docType, stat, usr).ToString();
                }
            }
        }
        lbl_msg.Text = Comm;
        pop_msgBox.ShowOnPageLoad = true;
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
                    String docType = "Certificate";
                    if (txtDocument.Text.Contains("Masters"))
                        docType = "Masters";
                    Comm = COMP.acad_UpdateDocStatus(reg, docType, stat, usr).ToString();
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

    protected void cmdGradDate_Click(object sender, EventArgs e)
    {
        pop_set_gradinfo.ShowOnPageLoad = true;
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