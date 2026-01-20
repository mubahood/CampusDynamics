using DevExpress.Export;
using DevExpress.Web;
using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_GLDrillDown : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_msgbox.HeaderText = "Campus Dynamics ERP";
        if (!IsPostBack)
        {
            if (DateTime.Today.Month > 7)
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }
            else
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year - 1); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }

            txtEndDate.Value = DateTime.Today;
        }
    }
   
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        gve_budget.WriteXlsxToResponse(new XlsxExportOptionsEx() { ExportType = ExportType.WYSIWYG });
    }

    protected void gvGeneralLedger_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
    protected void gvDetails_BeforePerformDataSelect(object sender, EventArgs e)
    {
        Session["subacc_code"] = (sender as ASPxGridView).GetMasterRowFieldValues("accountcode");
    }
    protected void gvDetails_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height=30;
    }
    protected void gvDetails_BeforePerformDataSelect1(object sender, EventArgs e)
    {
        Session["acc_code"] = (sender as ASPxGridView).GetMasterRowFieldValues("accountcode");
    }
    protected void cmdExpandAll_Click(object sender, EventArgs e)
    {
        for (int i = 0; i < gvGeneralLedger.VisibleRowCount; i++)
        {
            var keyValue = gvGeneralLedger.GetRowValues(i, gvGeneralLedger.KeyFieldName);
            gvGeneralLedger.DetailRows.ExpandRow(i);
        }
    }
    protected void cmdViewGL_Click(object sender, EventArgs e)
    {
        pop_gl_listing.ContentUrl = "~/COOPERP/accounts/GLAccount.aspx";
        pop_gl_listing.Width = 1000;
        pop_gl_listing.Height = 600;
        Session["s_date"] = txtStartDate.Date.ToString("yyyy-MM-dd");
        Session["e_date"] = txtEndDate.Date.ToString("yyyy-MM-dd");
        pop_gl_listing.ShowOnPageLoad = true;
    }
}