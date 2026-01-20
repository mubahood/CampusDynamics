using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using admission_dataTableAdapters;
using DevExpress.XtraPrinting;

public partial class UserControls_Admissions_applications : System.Web.UI.UserControl
{
    securityBLL sec = new securityBLL();
    acad_applicant_choicesTableAdapter choice = new acad_applicant_choicesTableAdapter();
    acad_applicationsTableAdapter appl = new acad_applicationsTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["stud_entry_no"] = "-";
        if (!IsPostBack)
        {
            
            txtEntryYear.DataSource = CommonRoutines.ReturnYears();
            txtEntryYear.DataBind();
            txtEntryYear.Text = DateTime.Today.Year.ToString();
            gv_ApplicantInfo.DataBind();

        }
        if (txtStatus.Text == "Pending")
        {
            cmdNew.Text = "Submit & Accept Application";
        }
        else
        {
            cmdNew.Text = "Accept Application";
        }
    }
    
    protected void gv_ApplicantInfo_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
       
    }
    protected void gv_ApplicantInfo_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.StartsWith("Exception has been thrown by the target of an invocation") && e.Exception.InnerException != null)
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
        else
            e.ErrorText = "An Error was encoutered.Please Contact your systems Administrator for Assistance.";
    }

    protected void cmdUpdateList_Click(object sender, EventArgs e)
    {

    }
    protected void cmdClearList_Click(object sender, EventArgs e)
    {

    }

    protected void btnDetails_Click(object sender, ImageClickEventArgs e)
    {
        popup_applicants.ContentUrl = "~/COOPERP/Admissions/OnlineApplicantDetails.aspx";
        Session["formNo"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "form_no");
        Session["applic_name"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "applic_name");
        popup_applicants.Width = 900;
        popup_applicants.Height = 600;
        popup_applicants.ShowOnPageLoad = true;
    }
    protected void cmdSMS_Click(object sender, EventArgs e)
    {

    }
    protected void cmdPrintLetters_Click(object sender, EventArgs e)
    {
       
            Session["entno"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_entry_no");
            Session["Report"] = 3;
            popup_applicants.ContentUrl = "~/COOPERP/Admissions/XtraReports/Reports.aspx";
            popup_applicants.Width = 1000;
            popup_applicants.Height = 600;
            popup_applicants.ShowOnPageLoad = true;
        
        
    }
    protected void gv_ApplicantInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void gv_ApplicantInfo_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
       
    }
    protected void cmdUpdate_Click(object sender, EventArgs e)
    {

    }
    protected void cmdChangeCourse_Click(object sender, EventArgs e)
    {
       
    }
    
    protected void btn_Email_Click(object sender, EventArgs e)
    {

    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
       applic_formTableAdapter APP = new applic_formTableAdapter();
        int noRows = gv_ApplicantInfo.VisibleRowCount, counter = 0;
        string comm = "No Candidates Selected";
        string formno = "",phone,email,email_msg="",stud_name;
        for (int i = 0; i < noRows; i++)
        {
            if (gv_ApplicantInfo.Selection.IsRowSelected(i))
            {
                try
                {
                    counter++;
                    formno = gv_ApplicantInfo.GetRowValues(i, "form_no").ToString();
                    phone = //"0703502258";
                    gv_ApplicantInfo.GetRowValues(i, "applic_phone").ToString();
                    email = //"hammshx@gmail.com";
                        gv_ApplicantInfo.GetRowValues(i, "applic_email").ToString();
                    stud_name = //"Sekalema Hamza";
                        gv_ApplicantInfo.GetRowValues(i, "applic_name").ToString();

                    APP.AcceptApplicant(formno, HttpContext.Current.User.Identity.Name,txtIntake.Text);
                    comm = counter + " Form(s) Accepted";
                    SMSSendingBLL SMS = new SMSSendingBLL();
                    email_msg = string.Format("Dear {0}, Your application has been accepted for processing. Please await confirmation. \n\nACADEMIC REGISTRAR",
                        stud_name);

                   string sms_response=SMS.SMSSending("Clarke Int. Univ", "Your application has been accepted for processing. Thanks", phone);
                   string email_response= EmailSenderProtocol.SendEnquiryMail(email, "Acceptance of Application Form", "Clarke International University Admissions",
                        email_msg);
                   //comm = sms_response + " - " + email_response;
                }
                catch (Exception ex)
                {
                    comm = "Caution! Form No. " + formno + " acceptance has an error [" + ex.Message + "]";
                    break;
                }
            }
        }
        gv_ApplicantInfo.DataBind();
        lbl_comments.Text = comm;
        pop_response.ShowOnPageLoad = true;
        //int noRows = gv_ApplicantInfo.VisibleRowCount;
        //for (int i = 0; i < noRows; i++)
        //{
        //   if(gv_ApplicantInfo.Selection.IsRowSelected(i))
        //   {
        //    acad_applicationsTableAdapter APP = new acad_applicationsTableAdapter();
        //    acad_applicant_choicesTableAdapter ch = new acad_applicant_choicesTableAdapter();
        //    string newEntNo = APP.CreateEntryNo(txtEntryYear.Text).ToString();
        //    APP.Insert(newEntNo,
        //    string regno = appl.CreateRegNo(newEntNo).ToString();
        //   }

        //}
    }
   
    protected void cmdExport_Click(object sender, EventArgs e)
    {
        //GVE_Applicants.WriteXlsToResponse("OnlineApplicList_" , new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
        GVE_Applicants.WriteXlsToResponse("OnlineApplicList_" + txtEntryYear.Text + "_" + txtStatus.Text , new XlsExportOptions { ExportMode = XlsExportMode.SingleFile });
    }
    protected void ASPxButton1_Click(object sender, EventArgs e)
    {
       
        applic_formTableAdapter RJA = new applic_formTableAdapter();

        int rows = gv_ApplicantInfo.VisibleRowCount;
        
        for (int i = 0; i < rows; i++)
        {
            if (gv_ApplicantInfo.Selection.IsRowSelected(i))
            {
                RJA.RejectApplicant(gv_ApplicantInfo.GetRowValues(i, "form_no").ToString());

                
                    
            }
        }
        gv_ApplicantInfo.DataBind();
       
        
    }
    protected void cmd_email_sender_Click(object sender, EventArgs e)
    {
        popup_email_chat.Width = 400;
        string applic_name=gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "applic_name").ToString();
        lbl_applicant_name.Text = applic_name;
        lbl_email.Text= gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "applic_email").ToString();
        string short_name = applic_name.Substring(applic_name.LastIndexOf(' ') + 1);
        txt_email.Html = "<p>Dear " + short_name+
            "<p><p>For any further information, please reply to admissions@ciu.ac.ug. Thank you for choosing Clarke International University.";
        popup_email_chat.ShowOnPageLoad = true; ;

    }
    protected void cmdSendEmail_Click(object sender, EventArgs e)
    {
        try
        {
            if (txt_subject.Text == "")
            {
                lbl_comments.Text = "Error! You MUST enter the subject before sending!";
                pop_response.ShowOnPageLoad = true;
            }
            else
            {
                string email_msg = txt_email.Html;
                string email_response = EmailSenderProtocol.SendHtmlEmail(email_msg,lbl_email.Text, txt_subject.Text, "Clarke International University Admissions");
                lbl_comments.Text = email_response;
                pop_response.ShowOnPageLoad = true;
            }
        }
        catch (Exception ex)
        {
            lbl_comments.Text = "Error! ["+ex.Message+"]";
            pop_response.ShowOnPageLoad = true;
        }
    }
}