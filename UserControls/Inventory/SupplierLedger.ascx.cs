using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraPrinting;

public partial class UserControls_Inventory_SupplierLedger : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        txtAdmNo.Text = Session["SupplierCode"].ToString();
        lbl_header.Text = string.Format("SUPPLIER FEES LEDGER FOR {0} [{1}]", Session["SupplierName"], Session["SupplierCode"]).ToUpper();

    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {

        Session["accno"] = Session["SupplierCode"];
        Session["Report"] = "SupplierLedger";
        Response.Redirect("~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx");
    }

    protected void cmdExport_Click(object sender, EventArgs e)
    {
        string supplierName = Session["SupplierName"] != null ? Session["SupplierName"].ToString() : "Supplier";
        Exporter.WriteXlsxToResponse("Ledger_" + supplierName.Replace(" ", "_"),
            new XlsxExportOptions { ExportMode = XlsxExportMode.SingleFile });
    }
    protected void gvLedger_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdInvoice_Click(object sender, EventArgs e)
    {
        // Check if the current date is in an open financial period
        string errorMsg;
        if (!IsInOpenFinancialPeriod(out errorMsg))
        {
            lbl_msgbox.Text = errorMsg;
            pop_msgbox.ShowOnPageLoad = true;
            return;
        }
        lbl_accountLabel.Text = "EXPENSE ACCOUNT";
        Session["typ"] = "EXPENSE";
        txtAccountName.DataBind();
        txtAccountName.SelectedIndex = 0;
        pop_transactions.ShowOnPageLoad = true;

    }
    protected void cmdPayments_Click(object sender, EventArgs e)
    {
        // Check if the current date is in an open financial period
        string errorMsg;
        if (!IsInOpenFinancialPeriod(out errorMsg))
        {
            lbl_msgbox.Text = errorMsg;
            pop_msgbox.ShowOnPageLoad = true;
            return;
        }
        lbl_accountLabel.Text = "BANK ACCOUNT";
        Session["typ"] = "BANK";
        txtAccountName.DataBind();
        txtAccountName.SelectedIndex = 0;
        pop_transactions.ShowOnPageLoad = true;
    }

    protected void cmdAddTransaction_Click(object sender, EventArgs e)
    {
        // Check if the current date is in an open financial period
        string errorMsg;
        if (!IsInOpenFinancialPeriod(out errorMsg))
        {
            lbl_msgbox.Text = errorMsg;
            pop_msgbox.ShowOnPageLoad = true;
            return;
        }
        InventoryAccountingTableAdapters.fin_GetLimitedSupplierLedgerTableAdapter LEDGER = new InventoryAccountingTableAdapters.fin_GetLimitedSupplierLedgerTableAdapter();
        try
        {
            LEDGER.fin_CreateSupplierTransaction(Session["SupplierCode"].ToString(), Session["SupplierName"].ToString(), Session["typ"].ToString(),
                double.Parse(txtAmount.Text.Replace(",", "")), txtParticulars.Text, txtAccountName.Value.ToString(), txtAccountName.Text, 
                HttpContext.Current.User.Identity.Name,
                    Convert.ToDateTime(txtInvoiceDate.Text),
                    txtRefNo.Text

                );
            lbl_msgbox.Text = "Transaction Added Successfully";
            gvLedger.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msgbox.Text = "Transaction Error! ["+ex.Message+"]";
        }
        
        pop_msgbox.ShowOnPageLoad = true;
    }
    private bool IsInOpenFinancialPeriod(out string errorMessage)
    {
        errorMessage = "";
        InventoryAccountingTableAdapters.fin_financial_yearsTableAdapter FY = new InventoryAccountingTableAdapters.fin_financial_yearsTableAdapter();
        var dtOpen = FY.GetFinicalPeriodStatus(); // Returns only rows where status='Open'


        if (dtOpen.Rows.Count == 0)     
        {
            errorMessage = "Error! No financial year is currently Open. Cannot create or edit journals.";
            return false;
        }

        DateTime periodStart = Convert.ToDateTime(dtOpen.Rows[0]["start_date"]);
        DateTime periodEnd = Convert.ToDateTime(dtOpen.Rows[0]["end_date"]);
        DateTime today = DateTime.Today;

        if (today < periodStart || today > periodEnd)
        {
            // Corrected your custom message
            errorMessage = "Ooops! Cannot Add Transcation. Accounting Period Closed. The Date Ranges are: "
                           + periodStart.ToString("dd/MM/yyyy") + " - " + periodEnd.ToString("dd/MM/yyyy") + ".";
            return false;
        }


        return true;
    }

}