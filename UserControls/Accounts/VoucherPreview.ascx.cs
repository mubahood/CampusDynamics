using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CoopERPDataTableAdapters;

public partial class UserControls_Accounts_VoucherPreview : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        Session["Report"] = "Voucher";
        Response.Redirect("~/COOPERP/XtraReports/Default.aspx");
    }
}