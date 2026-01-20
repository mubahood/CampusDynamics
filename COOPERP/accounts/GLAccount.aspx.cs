using DevExpress.Export;
using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_GLAccount : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        rp_gl_listing.HeaderText = "GENERAL LEDGER FOR THE PERIOD " + Session["s_date"] + " TO " + Session["e_date"] + "";
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        gve_gl_listing.WriteXlsxToResponse(new XlsxExportOptionsEx() { ExportType = ExportType.WYSIWYG });
    }
}