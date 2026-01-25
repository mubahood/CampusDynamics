using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_LedgerTypes : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        gvLedgerTypes.AddNewRow();
    }
    protected void cmdAddCurrency_Click(object sender, EventArgs e)
    {
        gvCurrencyList.AddNewRow();
    }
}