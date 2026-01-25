using admission_dataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Admissions_RegistrationNoCentre : System.Web.UI.UserControl
{
    securityBLL sec = new securityBLL();
    acad_applicant_choicesTableAdapter choice = new acad_applicant_choicesTableAdapter();
    acad_applicationsTableAdapter appl = new acad_applicationsTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        //Session["stud_entry_no"] = "-";

        cmdUpdate.Enabled = sec.AdmissionsCheck();
        if (!IsPostBack)
        {
            //txtProg.Value = "BNS";
            //txtProg.Text = "BNS";
            txtEntryYear.DataSource = CommonRoutines.ReturnYears();
            txtEntryYear.DataBind();
            txtEntryYear.Text = DateTime.Today.Year.ToString();
            //txtSession.Value = "Full time";
            //txtSession.Text = "Full time";
            gv_ApplicantInfo.DataBind();

          

        }
    }
   
   
    protected void gv_ApplicantInfo_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if ( e.Exception.InnerException != null)
         e.ErrorText = e.Exception.InnerException.Message;
    }

    protected void cmdUpdateList_Click(object sender, EventArgs e)
    {

    }
    protected void cmdClearList_Click(object sender, EventArgs e)
    {

    }

    protected void btnDetails_Click(object sender, ImageClickEventArgs e)
    {
        Session["stud_entry_no"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_entry_no");
        Session["stud_name"] = gv_ApplicantInfo.GetRowValues(gv_ApplicantInfo.FocusedRowIndex, "stud_name");
        popup_applicants.Width = 800;
        popup_applicants.Height = 600;
        popup_applicants.ShowOnPageLoad = true;
    }
    protected void cmdSMS_Click(object sender, EventArgs e)
    {

    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_print.Width = 900;
        pop_print.Height = 600;
        Session["Report"] = "2";
        Session["entyear"] = txtEntryYear.Text;
        Session["programme"] = txtProg.Value;
        Session["Sess"] = txtSession.Value;
        Session["intake"] = txtIntake.Value;
        Session["campus"] = "01";
        pop_print.ShowOnPageLoad = true;
    }
    protected void cmdUpdate_Click(object sender, EventArgs e)
    {
        try
        {
            acad_applicationsTableAdapter APP = new acad_applicationsTableAdapter();
            int noRows = gv_ApplicantInfo.VisibleRowCount, counter = 0;
            string comm = "No Student Selected";
            for (int i = 0; i < noRows; i++)
            {
                if (gv_ApplicantInfo.Selection.IsRowSelected(i))
                {
                    counter++;
                    string regno = appl.CreateRegNo(gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString()).ToString();
                    appl.UpdateRegistrationNo(regno, gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString());
                    APP.acad_RegisterApplicant(int.Parse(txtEntryYear.Text), gv_ApplicantInfo.GetRowValues(i, "stud_entry_no").ToString(), HttpContext.Current.User.Identity.Name);
                    comm = counter + " Applicant(s) Successfully Registered";
                }
            }
            gv_ApplicantInfo.DataBind();
            lbl_comments.Text = comm;
        }
        catch (Exception ex)
        {
            lbl_comments.Text = "Error: " + ex.Message;
        }
        pop_response.ShowOnPageLoad = true;
    }
    protected void gv_ApplicantInfo_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}