using System;

public partial class COOPERP_NewScreens_ChartOfAccounts : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Response.Redirect("~/COOPERP/NewScreens/MainAccountsController.aspx", false);
        Context.ApplicationInstance.CompleteRequest();
    }
}
