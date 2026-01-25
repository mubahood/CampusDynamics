using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Admissions_ApplicantResults : System.Web.UI.UserControl
{
    ApplicationsBLL app = new ApplicationsBLL();
    protected void Page_Load(object sender, EventArgs e)
    {
        gv_Results.DataBind();
    }
    protected void cbk_Results_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        if (e.Parameter == "NewResults")
        {
            lbl_response.Text=app.AddApplicantSubjects(Session["stud_entry_no"].ToString(), int.Parse(txt_NoSubs.Text), txt_level.Value.ToString());
            gv_Results.DataBind();
            pop_response.ShowOnPageLoad = true;
            
        }
    }
    protected void cbk_subjects_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        gvSubjects.AddNewRow();
    }
    protected void gv_Results_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.StartsWith("Exception has been thrown by the target of an invocation") && e.Exception.InnerException != null)
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
        else
            e.ErrorText = "An Error was encoutered.Please Contact your systems Administrator for Assistance.";
    }
}