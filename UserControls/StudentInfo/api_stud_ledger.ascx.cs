using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_api_stud_ledger : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
        lbl_header.Text = string.Format("STUDENT LEDGER FOR [{0}]", Session["regno"].ToString()).ToUpper();
        
    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/API/doc_verification.aspx?doc=StudentLedger&reg=" + Session["regno"].ToString());
    }
    protected void gvLedger_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}