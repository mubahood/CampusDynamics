using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Inventory_SupplierLedgers : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {

            if (DateTime.Today.Month < 8)
            {
                txtStartDate.Value = "08/01/" + DateTime.Today.AddYears(-1).Year;
            }
            else
            {
                txtStartDate.Value = "08/01/" + DateTime.Today.Year;
            }
            txtEndDate.Date = DateTime.Today;
        }
    }
    protected void cmdLedger_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Height = 500;
        pop_details.Width = 900;
        pop_details.ContentUrl = "~/COOPERP/Inventory/SupplierLedgerDetails.aspx";
        Session["SupplierCode"] = gv_supplier.GetRowValues(gv_supplier.FocusedRowIndex, "SupplierCode");
        Session["SupplierName"] = gv_supplier.GetRowValues(gv_supplier.FocusedRowIndex, "SupplierName");
        Session["sDate"] = txtStartDate.Date;
        Session["eDate"] = txtEndDate.Date;
        pop_details.ShowOnPageLoad = true;
    }
    protected void txtClass_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void txtYear_NumberChanged(object sender, EventArgs e)
    {

    }
    
   
    protected void gv_supplier_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}