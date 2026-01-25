using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using admission_dataTableAdapters;
using System.IO;
using DevExpress.XtraPrinting;

public partial class UserControls_Admissions_applications : System.Web.UI.UserControl
{
    securityBLL sec = new securityBLL();
    acad_applicant_choicesTableAdapter choice = new acad_applicant_choicesTableAdapter();
    acad_applicationsTableAdapter appl = new acad_applicationsTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["stud_entry_no"] = "-";
        
        cmdUpdate.Enabled = sec.AdmissionsCheck();
        txtNewStatus.Enabled = sec.AdmissionsCheck();
        if (!IsPostBack)
        {
            txtProg.Value = "BBA";
            txtEntryYear.DataSource = CommonRoutines.ReturnYears();
            txtEntryYear.DataBind();
            txtEntryYear.Text = DateTime.Today.Year.ToString();
            gv_ApplicantInfo.DataBind();

            Session["stud_entry_no"] = gv_ApplicantInfo.GetRowValues(0, "stud_entry_no");
            Session["stud_name"] = gv_ApplicantInfo.GetRowValues(0, "stud_name");
            txtFaculty.SelectedIndex = 0;

        }
    }
    protected void cbk_applications_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        if (e.Parameter == "EntryYearChange")
        {
            gv_ApplicantInfo.DataBind();
            txt_letter.DataBind();
        }
        else if (e.Parameter == "UpdateStatus")
        {
            int Rowcount = gv_ApplicantInfo.VisibleRowCount;
            int count = 0;
            for (int i = 0; i < Rowcount; i++)
            {
                if (gv_ApplicantInfo.Selection.IsRowSelected(i))
                {
                    count++;
                    string entno = gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString();
                    string usernm = HttpContext.Current.User.Identity.Name;
                    lbl_comments.Text = choice.UpdateApplicantStatus(entno, int.Parse(txtNewStatus.Value.ToString()), usernm, txtEntryYear.Text).ToString();
                    //if (txtNewStatus.Text.Contains("Admit"))
                    //{
                       // string regno = appl.CreateRegNo(entno).ToString();
                        //appl.UpdateRegistrationNo(regno, entno);
                        //appl.UpdateApplicantHall(entno);
                        //appl.acad_RegisterApplicant(int.Parse(txtEntryYear.Text), entno, HttpContext.Current.User.Identity.Name);
                    //}
                }

            }
            gv_ApplicantInfo.DataBind();
            if (count == 0)
                lbl_comments.Text = "Please First Select the Applicants.";
            else
            lbl_comments.Text = string.Format("{0} {1}", count, lbl_comments.Text);
            pop_response.ShowOnPageLoad = true;

        }
        else if (e.Parameter == "AddApplicant")
        {
            gv_ApplicantInfo.AddNewRow();
        }
        else if (e.Parameter == "FocusedRowChange")
        {
            Session["stud_entry_no"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_entry_no");
            Session["stud_name"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_name");

        }
        else if (e.Parameter == "AssignHall")
        {
            int Rowcount = gv_ApplicantInfo.VisibleRowCount;
            int count = 0;
            for (int i = 0; i < Rowcount; i++)
            {
                if (gv_ApplicantInfo.Selection.IsRowSelected(i))
                {
                    count++;
                    string entno = gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString();
                    string usernm = HttpContext.Current.User.Identity.Name;
                    if (txtStatus.Text.Contains("Admit"))
                    {
                        appl.UpdateApplicantHall(entno);
                        lbl_comments.Text = count + " Hall Changes Completed";
                    }
                }

            }
            pop_response.ShowOnPageLoad = true;
        }

    }
    protected void gv_ApplicantInfo_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["stud_entry_year"] = DateTime.Now.Year;
        e.NewValues["stud_intake"] = txtIntake.Text;
        e.NewValues["stud_entry_no"] = "AUTO";
    }
    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }

    protected void gv_ApplicantInfo_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        //if (e.ErrorText.StartsWith("Exception has been thrown by the target of an invocation") && e.Exception.InnerException != null)
        //{
        //    e.ErrorText = e.Exception.InnerException.Message;
        //}
        //else
        e.ErrorText = UnwrapExceptionMessage(e.Exception);
                
                //"An Error was encoutered.Please Contact your systems Administrator for Assistance.";
    }

    protected void cmdUpdateList_Click(object sender, EventArgs e)
    {

    }
    protected void cmdClearList_Click(object sender, EventArgs e)
    {

    }

    protected void btnDetails_Click(object sender, ImageClickEventArgs e)
    {
        popup_applicants.ContentUrl = "~/COOPERP/Admissions/ApplicantDetails.aspx";
        Session["stud_entry_no"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_entry_no");
        Session["stud_name"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_name");
        popup_applicants.Width = 800;
        popup_applicants.Height = 600;
        popup_applicants.ShowOnPageLoad = true;
    }
    protected void cmdSMS_Click(object sender, EventArgs e)
    {

    }
    protected void cmdPrintLetters_Click(object sender, EventArgs e)
    {
        if (txt_letter.Text == "" || txtProg.Text == "-") 
        { 
            lbl_comments.Text = "Error! Specify the programme and letter Template";
            pop_response.ShowOnPageLoad = true;
        }
        else
        {
            Session["entno"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_entry_no");
            Session["prog"] = txtProg.Value;
            Session["Report"] = 3;
            Session["Letter"] = txt_letter.Value;
            Session["intk"] = txtIntake.Text;
            popup_applicants.ContentUrl = "~/COOPERP/Admissions/XtraReports/Reports.aspx";
            popup_applicants.Width = 1000;
            popup_applicants.Height = 600;
            popup_applicants.ShowOnPageLoad = true;
        }
        
    }
    protected void gv_ApplicantInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void gv_ApplicantInfo_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        /*acad_applicationsTableAdapter APP = new acad_applicationsTableAdapter();
        acad_applicant_choicesTableAdapter ch = new acad_applicant_choicesTableAdapter();
        string newregNo=APP.CreateEntryNo(txtEntryYear.Text).ToString();
        e.NewValues["stud_entry_no"] = newregNo;
        ch.Insert(newregNo, 1, txtProg.Value.ToString(), 0, "DAY", "13");*/
        e.NewValues["prog"] = txtProg.Value.ToString();
    }
    protected void cmdUpdate_Click(object sender, EventArgs e)
    {

    }
    protected void cmdChangeCourse_Click(object sender, EventArgs e)
    {
        popup_changeCourse.ShowOnPageLoad = true;
    }
    protected void cmdChangeProgramme_Click(object sender, EventArgs e)
    {
        acad_applicant_choicesTableAdapter CH = new acad_applicant_choicesTableAdapter();
        int noRows = gv_ApplicantInfo.VisibleRowCount,counter=0;
        for (int i = 0; i < noRows; i++)
        {
            if (gv_ApplicantInfo.Selection.IsRowSelected(i))
            {
                CH.acad_ChangeApplicCourse(gv_ApplicantInfo.GetRowValues(i,"stud_entry_no").ToString(),txtNewProg.Value.ToString(),txtSession.Text,int.Parse(txtNewSpec.Value.ToString()));
                counter++;
            }
        }

        lbl_comments.Text = counter+" Course Changes Completed";
        pop_response.ShowOnPageLoad = true;
        gv_ApplicantInfo.DataBind();
    }

    protected void cmdSendELetter_Click(object sender, EventArgs e)
    {
        int noRows = gv_ApplicantInfo.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            if (gv_ApplicantInfo.Selection.IsRowSelected(i)==true)
            {
                SendLetter(gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString(),
                    gv_ApplicantInfo.GetRowValues(i, "stud_email").ToString(), gv_ApplicantInfo.GetRowValues(i, "stud_name").ToString(),
                    gv_ApplicantInfo.GetRowValues(i, "stud_phone").ToString());
                pop_response.ShowOnPageLoad = true;

            }
        }
    }
    void SendLetter(string entno, string email, string stud_name,string phone)
    {
        try
        {
            acad_admissionlettersTableAdapter letter = new acad_admissionlettersTableAdapter();
            acad_GetAdmissionListingTableAdapter listing = new acad_GetAdmissionListingTableAdapter();
            admission_data ds = new admission_data();

            letter.Fill_AdmissionDetails(ds.acad_admissionletters, txt_letter.Value.ToString());
            listing.SingleAdmissionLetter(ds.acad_GetAdmissionListing, entno, txtProg.Value.ToString());
            OnlineAdmissionLetter admletter = new OnlineAdmissionLetter();
            admletter.DataSource = ds;

            using (MemoryStream ms = new MemoryStream())
            {
                admletter.ExportToPdf(ms, new PdfExportOptions() { ShowPrintDialogOnOpen = false });
                File.WriteAllBytes(Server.MapPath("~/COOPERP/Admissions/Docs/" + entno + ".pdf"), ms.ToArray());
                string emailText = "-";
                emailText = "Hullo " + stud_name + 
                    ",\n Please receive the attached letter to confirm your admission to Clarke International University.\nPlease read the letter and follow the instructions and policies indicated there in. Welcome to the Clarke International University\nPlease confirm receipt of this email. Thank You.\n\n Academic Registrar";
                lbl_comments.Text = EmailSenderProtocol.SendAttachedMail(email, "Admission Letter", "Academic Registrar Clarke International University", emailText,
                Server.MapPath("~/COOPERP/Admissions/Docs/" + entno + ".pdf"));
                //SMSSendingBLL SMS = new SMSSendingBLL();
                //SMS.SMSSending("Clarke Int. University Admissions", "Hullo " + stud_name + ",\n Please check email for your Admission Letter",phone);
            }
            lbl_comments.ForeColor = System.Drawing.Color.Blue;
        }
        catch (Exception ex)
        {
            lbl_comments.ForeColor = System.Drawing.Color.Red;
            lbl_comments.Text = "Email Error [" + ex.Message + "]";
        }
    }

    protected void cmdBillingUpdate_Click(object sender, EventArgs e)
    {
        pop_billing.ShowOnPageLoad = true;
    }
    protected void cmdApplyBilling_Click(object sender, EventArgs e)
    {
        int noRows = gv_ApplicantInfo.VisibleRowCount, counter = 0;
        StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
        StudentDataTableAdapters.acad_applicationsTableAdapter applic = new StudentDataTableAdapters.acad_applicationsTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            if (gv_ApplicantInfo.Selection.IsRowSelected(i))
            {
                try
                {
                    STUD.UpdateBillingID(int.Parse(txtBillingSystem.Value.ToString()), gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString());
                    applic.UpdateApplicantBillingID(int.Parse(txtBillingSystem.Value.ToString()), gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString());
                    counter++;
                }
                catch (Exception) { }
            }
        }
        gv_ApplicantInfo.DataBind();
        lbl_bill_comment.Text = counter + " Applicant(s) Set to " + txtBillingSystem.Text;
    }
    
}