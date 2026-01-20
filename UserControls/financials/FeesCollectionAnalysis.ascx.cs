using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_FeesCollectionAnalysis : System.Web.UI.UserControl
{
    StudentAccountingDataTableAdapters.fin_GetFeesAnalysisTableAdapter FEES = new StudentAccountingDataTableAdapters.fin_GetFeesAnalysisTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Date = DateTime.Today.AddMonths(-1);
            txtEndDate.Date = DateTime.Today;

            FEES.fin_UpdateTransactionFaculties();
        }
    }
    protected void cmdRefresh_Click(object sender, EventArgs e)
    {
        lp_fees.Modal = true;
        FEES.fin_UpdateTransactionFaculties();
        PG_FeesAnalysis.DataBind();
    }
    protected void cmdExportExcel_Click(object sender, EventArgs e)
    {
        //lp_fees.Modal = false;
        PE_FeesAnalysis.ExportXlsToResponse(txtType.Text + " Analysis", true);
    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {

    }
    protected void gvDrillDownList_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
   
}