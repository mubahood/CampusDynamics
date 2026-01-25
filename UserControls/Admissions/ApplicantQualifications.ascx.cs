using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Admissions_ApplicantQualifications : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvQualifications.DataBind();
    }
    protected void cbk_qualifications_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        gvQualifications.AddNewRow();
    }
    protected void gvQualifications_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["stud_entry_no"] = Session["stud_entry_no"];
    }
    protected void gvQualifications_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.StartsWith("Exception has been thrown by the target of an invocation") && e.Exception.InnerException != null)
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
        else
            e.ErrorText = "An Error was encoutered.Please Contact your systems Administrator for Assistance.";
    }
}