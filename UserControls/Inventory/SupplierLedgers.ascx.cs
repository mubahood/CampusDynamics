using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraPrinting;
using DevExpress.Export.Xl;

public partial class UserControls_Inventory_SupplierLedgers : System.Web.UI.UserControl
{
    // Cache: supplier code -> final balance string (e.g. "24,402,741CR")
    private Dictionary<string, string> _supplierBalances;

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

    private InventoryAccountingTableAdapters.fin_GetLimitedSupplierLedgerTableAdapter _ledgerAdapter;

    private string GetSupplierBalance(string supplierCode)
    {
        if (_supplierBalances == null)
            _supplierBalances = new Dictionary<string, string>();

        if (_supplierBalances.ContainsKey(supplierCode))
            return _supplierBalances[supplierCode];

        string finalBalance = "0";
        try
        {
            if (_ledgerAdapter == null)
                _ledgerAdapter = new InventoryAccountingTableAdapters.fin_GetLimitedSupplierLedgerTableAdapter();

            DateTime sDate = txtStartDate.Date;
            DateTime eDate = txtEndDate.Date;
            DataTable dt = _ledgerAdapter.GetData(supplierCode, sDate, eDate);
            if (dt.Rows.Count > 0)
            {
                object lastBalance = dt.Rows[dt.Rows.Count - 1]["curr_balance"];
                if (lastBalance != DBNull.Value && !string.IsNullOrEmpty(lastBalance.ToString()))
                    finalBalance = lastBalance.ToString();
            }
        }
        catch { }

        _supplierBalances[supplierCode] = finalBalance;
        return finalBalance;
    }

    protected void gv_supplier_CustomUnboundColumnData(object sender, DevExpress.Web.ASPxGridViewColumnDataEventArgs e)
    {
        if (e.Column.FieldName == "FinalBalance")
        {
            string supplierCode = e.GetListSourceFieldValue("SupplierCode").ToString();
            e.Value = GetSupplierBalance(supplierCode);
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

    protected void cmdExport_Click(object sender, EventArgs e)
    {
        DataTable dtAll = BuildAllLedgersData();
        gv_allLedgers.DataSource = dtAll;
        gv_allLedgers.DataBind();
        ExporterAll.Styles.Header.BackColor = Color.FromArgb(44, 62, 80);
        ExporterAll.Styles.Header.ForeColor = Color.White;
        ExporterAll.Styles.Header.Font.Name = "Calibri";
        ExporterAll.Styles.Header.Font.Size = 10;
        ExporterAll.Styles.Header.Font.Bold = true;
        ExporterAll.Styles.Cell.Font.Name = "Calibri";
        ExporterAll.Styles.Cell.Font.Size = 9;
        ExporterAll.WriteXlsxToResponse("All_Supplier_Ledgers_" + txtStartDate.Date.ToString("dd-MM-yyyy") + "_" + txtEndDate.Date.ToString("dd-MM-yyyy"),
            new XlsxExportOptions { ExportMode = XlsxExportMode.SingleFile });
    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        DataTable dtAll = BuildAllLedgersData();
        Session["AllSupplierLedgersData"] = dtAll;
        Session["sDate"] = txtStartDate.Date;
        Session["eDate"] = txtEndDate.Date;
        Session["Report"] = "AllSupplierLedgers";
        pop_details.Width = 950;
        pop_details.Height = 650;
        pop_details.HeaderText = "All Supplier Ledgers";
        pop_details.ContentUrl = "~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx";
        pop_details.ShowOnPageLoad = true;
    }

    private DataTable BuildAllLedgersData()
    {
        DataTable dtAll = new DataTable();
        dtAll.Columns.Add("RowID", typeof(int));
        dtAll.Columns.Add("SupplierName", typeof(string));
        dtAll.Columns.Add("EntryDate", typeof(string));
        dtAll.Columns.Add("InvoiceDate", typeof(string));
        dtAll.Columns.Add("Particulars", typeof(string));
        dtAll.Columns.Add("VoucherNo", typeof(string));
        dtAll.Columns.Add("DR", typeof(string));
        dtAll.Columns.Add("CR", typeof(string));
        dtAll.Columns.Add("Balance", typeof(string));

        DateTime sDate = txtStartDate.Date;
        DateTime eDate = txtEndDate.Date;
        int rowId = 0;
        int supplierIndex = 0;

        InventoryAccountingTableAdapters.fin_GetLimitedSupplierLedgerTableAdapter ledgerAdapter =
            new InventoryAccountingTableAdapters.fin_GetLimitedSupplierLedgerTableAdapter();

        InventoryDataTableAdapters.inv_supplierdetailsTableAdapter suppAdapter =
            new InventoryDataTableAdapters.inv_supplierdetailsTableAdapter();
        DataTable dtSuppliers = suppAdapter.GetData();

        double totalClosingDR = 0;
        double totalClosingCR = 0;
        double grandTotalDR = 0;
        double grandTotalCR = 0;

        // GENERAL OPENING BALANCE row
        rowId++;
        DataRow genOpenRow = dtAll.NewRow();
        genOpenRow["RowID"] = rowId;
        genOpenRow["SupplierName"] = "";
        genOpenRow["Particulars"] = "GENERAL OPENING BALANCE";
        genOpenRow["DR"] = "0";
        genOpenRow["CR"] = "0";
        genOpenRow["Balance"] = "0";
        dtAll.Rows.Add(genOpenRow);
        int genOpenIdx = dtAll.Rows.Count - 1;

        double totalOpeningDR = 0;
        double totalOpeningCR = 0;

        foreach (DataRow suppRow in dtSuppliers.Rows)
        {
            string supplierCode = suppRow["SupplierCode"].ToString();
            string supplierName = suppRow["SupplierName"].ToString();

            try
            {
                DataTable dtLedger = ledgerAdapter.GetData(supplierCode, sDate, eDate);
                if (dtLedger.Rows.Count > 0)
                {
                    supplierIndex++;
                    string supplierLabel = supplierName + " [" + supplierCode + "]";
                    string openingBalance = "0";
                    bool isFirstRow = true;
                    double suppDR = 0;
                    double suppCR = 0;

                    // Get opening balance (first row)
                    if (dtLedger.Rows[0]["curr_balance"] != DBNull.Value &&
                        !string.IsNullOrEmpty(dtLedger.Rows[0]["curr_balance"].ToString()))
                        openingBalance = dtLedger.Rows[0]["curr_balance"].ToString();

                    // Parse supplier opening balance as numeric
                    double suppOpeningValue = 0;
                    try
                    {
                        string ob = openingBalance.Replace(",", "");
                        if (ob.EndsWith("CR"))
                        {
                            suppOpeningValue = double.Parse(ob.Replace("CR", ""));
                            totalOpeningCR += suppOpeningValue;
                        }
                        else if (ob.EndsWith("DR"))
                        {
                            suppOpeningValue = -double.Parse(ob.Replace("DR", ""));
                            totalOpeningDR += double.Parse(ob.Replace("DR", ""));
                        }
                    }
                    catch { }

                    // Add all transaction rows
                    foreach (DataRow ledgerRow in dtLedger.Rows)
                    {
                        rowId++;
                        DataRow newRow = dtAll.NewRow();
                        newRow["RowID"] = rowId;

                        // Show supplier name only on first row, then just index
                        if (isFirstRow)
                        {
                            newRow["SupplierName"] = supplierLabel;
                            isFirstRow = false;
                        }
                        else
                        {
                            newRow["SupplierName"] = "[" + supplierCode + "]";
                        }

                        newRow["EntryDate"] = ledgerRow["formated_date"] != DBNull.Value ? ledgerRow["formated_date"].ToString() : "";
                        newRow["InvoiceDate"] = ledgerRow["InvoiceDate"] != DBNull.Value ? Convert.ToDateTime(ledgerRow["InvoiceDate"]).ToString("dd/MM/yyyy") : "";
                        newRow["Particulars"] = ledgerRow["particulars"] != DBNull.Value ? ledgerRow["particulars"].ToString() : "";
                        newRow["VoucherNo"] = ledgerRow["voucherNo"] != DBNull.Value ? ledgerRow["voucherNo"].ToString() : "";
                        newRow["DR"] = (ledgerRow["dr_amount"] != DBNull.Value && !string.IsNullOrEmpty(ledgerRow["dr_amount"].ToString())) ? ledgerRow["dr_amount"].ToString() : "";
                        newRow["CR"] = (ledgerRow["cr_amount"] != DBNull.Value && !string.IsNullOrEmpty(ledgerRow["cr_amount"].ToString())) ? ledgerRow["cr_amount"].ToString() : "";
                        newRow["Balance"] = (ledgerRow["curr_balance"] != DBNull.Value && !string.IsNullOrEmpty(ledgerRow["curr_balance"].ToString())) ? ledgerRow["curr_balance"].ToString() : "0";
                        dtAll.Rows.Add(newRow);

                        // Accumulate grand total DR and CR and per-supplier
                        try
                        {
                            string drVal = (ledgerRow["dr_amount"] != DBNull.Value) ? ledgerRow["dr_amount"].ToString().Replace(",", "") : "0";
                            string crVal = (ledgerRow["cr_amount"] != DBNull.Value) ? ledgerRow["cr_amount"].ToString().Replace(",", "") : "0";
                            double drNum = 0, crNum = 0;
                            double.TryParse(drVal, out drNum);
                            double.TryParse(crVal, out crNum);
                            grandTotalDR += drNum;
                            grandTotalCR += crNum;
                            suppDR += drNum;
                            suppCR += crNum;
                        }
                        catch { }
                    }

                    // Per-supplier Closing = Opening + (Total CR - Total DR)
                    double suppClosingValue = suppOpeningValue + (suppCR - suppDR);
                    string closingBalance = string.Format("{0:N0}{1}", Math.Abs(suppClosingValue), suppClosingValue >= 0 ? "CR" : "DR");

                    // CLOSING BALANCE row for this supplier
                    rowId++;
                    DataRow closeRow = dtAll.NewRow();
                    closeRow["RowID"] = rowId;
                    closeRow["SupplierName"] = "[" + supplierCode + "]";
                    closeRow["Particulars"] = "CLOSING BALANCE";
                    closeRow["Balance"] = closingBalance;
                    dtAll.Rows.Add(closeRow);

                    // Blank separator row
                    rowId++;
                    DataRow blankRow = dtAll.NewRow();
                    blankRow["RowID"] = rowId;
                    blankRow["SupplierName"] = "";
                    dtAll.Rows.Add(blankRow);
                }
            }
            catch { }
        }

        // Update GENERAL OPENING BALANCE row
        double netOpening = totalOpeningCR - totalOpeningDR;
        string generalOpen = string.Format("{0:N0}{1}", Math.Abs(netOpening), netOpening >= 0 ? "CR" : "DR");
        dtAll.Rows[genOpenIdx]["Balance"] = generalOpen;

        // GENERAL CLOSING BALANCE = Opening + (Total CR - Total DR)
        double openingValue = netOpening; // positive = CR, negative = DR
        double netClose = openingValue + (grandTotalCR - grandTotalDR);
        string generalClose = string.Format("{0:N0}{1}", Math.Abs(netClose), netClose >= 0 ? "CR" : "DR");

        rowId++;
        DataRow genCloseRow = dtAll.NewRow();
        genCloseRow["RowID"] = rowId;
        genCloseRow["SupplierName"] = "";
        genCloseRow["Particulars"] = "GENERAL CLOSING BALANCE";
        genCloseRow["Balance"] = generalClose;
        dtAll.Rows.Add(genCloseRow);

        return dtAll;
    }

    protected void gv_allLedgers_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        // Style special rows (OPENING/CLOSING BALANCE, separator)
        string particulars = e.GetValue("Particulars") != null ? e.GetValue("Particulars").ToString() : "";
        string supplierName = e.GetValue("SupplierName") != null ? e.GetValue("SupplierName").ToString() : "";

        if (particulars.Contains("GENERAL"))
        {
            e.Cell.BackColor = Color.FromArgb(44, 62, 80);
            e.Cell.ForeColor = Color.White;
            e.Cell.Font.Bold = true;
        }
        else if (particulars == "CLOSING BALANCE" || particulars == "Opening Balance")
        {
            e.Cell.BackColor = Color.FromArgb(245, 245, 220);
            e.Cell.Font.Bold = true;
        }
        else if (supplierName.Length > 10 && !supplierName.StartsWith("["))
        {
            // First row of a supplier (has full name)
            e.Cell.BackColor = Color.FromArgb(214, 234, 248);
            e.Cell.Font.Bold = true;
        }
    }
}