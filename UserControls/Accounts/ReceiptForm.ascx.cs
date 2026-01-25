using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_ReceiptForm : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_receipts.Height = 600;
        pop_receipts.Width = 800;
    }
    protected void cmdCreateReceipt_Click(object sender, EventArgs e)
    {
        pop_receipts.ShowOnPageLoad = true;
    }
    protected void cmdPrintReceipt_Click(object sender, EventArgs e)
    {
        pop_receipts.ShowOnPageLoad = true;
    }
}