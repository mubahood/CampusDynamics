using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Admissions_ApplicantChoices : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cbk_choices_Callback(object sender, DevExpress.Web.CallbackEventArgsBase e)
    {
        if (e.Parameter == "NewChoice")
        {
            gv_choices.AddNewRow();
        }
    }
    protected void gv_choices_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["stud_entry_no"] = Session["stud_entry_no"].ToString();
    }
    protected void gv_choices_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        if (e.ErrorText.StartsWith("Exception has been thrown by the target of an invocation") && e.Exception.InnerException != null)
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
        else
            e.ErrorText = "An Error was encoutered.Please Contact your systems Administrator for Assistance.";
    }
    protected void gv_choices_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
}