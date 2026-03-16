using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_TransactionDetails : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Accept vno from query string (e.g. from TxnSearch) or from Session
        if (!string.IsNullOrEmpty(Request.QueryString["vno"]))
            Session["Vno"] = Request.QueryString["vno"];
        lbl_header.Text = "TRANSACTION DETAILS FOR VOUCHER NO: " + Session["Vno"];
    }
}