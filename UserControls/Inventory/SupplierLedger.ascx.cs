using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraPrinting;
using MySql.Data.MySqlClient;

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
        string errorMsg;
        if (!IsInOpenFinancialPeriod(out errorMsg))
        {
            lbl_msgbox.Text = errorMsg;
            pop_msgbox.ShowOnPageLoad = true;
            return;
        }

        try
        {
            string supplierCode = Session["SupplierCode"].ToString();
            string supplierName = Session["SupplierName"].ToString();
            string txnType      = Session["typ"].ToString();          // "EXPENSE" or "BANK"
            double amount       = double.Parse(txtAmount.Text.Replace(",", ""));
            string particulars  = txtParticulars.Text.Trim();
            string accCode      = txtAccountName.Value.ToString();    // account code
            string accName      = txtAccountName.Text;                // account name
            string user         = HttpContext.Current.User.Identity.Name ?? "SYSTEM";
            DateTime txnDate    = Convert.ToDateTime(txtInvoiceDate.Text);
            string refNo        = txtRefNo.Text.Trim();
            DateTime timeLog    = DateTime.Now;

            long voucherNo = 0;

            FinanceDB.ExecuteInTransaction((conn, tx) =>
            {
                // 1. Create journal header — fin_CreateJournal inserts into fin_journalnumbers
                //    and auto-increments JournalNo; LAST_INSERT_ID() returns the numeric key.
                using (var jCmd = new MySqlCommand("fin_CreateJournal", conn))
                {
                    jCmd.Transaction  = tx;
                    jCmd.CommandType  = System.Data.CommandType.StoredProcedure;
                    jCmd.Parameters.AddWithValue("@typ",   "Supplier");
                    jCmd.Parameters.AddWithValue("@JDate", txnDate.Date);
                    jCmd.Parameters.AddWithValue("@usr",   user);
                    jCmd.ExecuteNonQuery();
                }

                using (var idCmd = new MySqlCommand("SELECT LAST_INSERT_ID()", conn))
                {
                    idCmd.Transaction = tx;
                    voucherNo = Convert.ToInt64(idCmd.ExecuteScalar());
                }

                // 2. Stamp RefNo and particulars onto the journal header
                using (var updJ = new MySqlCommand(
                    "UPDATE fin_journalnumbers SET RefNo = @ref, journalParticulars = @part WHERE JournalNo = @jno", conn))
                {
                    updJ.Transaction = tx;
                    updJ.Parameters.AddWithValue("@ref",  string.IsNullOrEmpty(refNo) ? "SUP-" + voucherNo : refNo);
                    updJ.Parameters.AddWithValue("@part", particulars);
                    updJ.Parameters.AddWithValue("@jno",  voucherNo);
                    updJ.ExecuteNonQuery();
                }

                // 3. Build double-entry GL rows.
                //    EXPENSE (Invoice): DR Expense account / CR Supplier payable
                //    BANK    (Payment): DR Supplier payable / CR Bank account
                string drAccount, drType, drParticulars;
                string crAccount, crType, crParticulars;

                if (txnType == "EXPENSE")
                {
                    drAccount      = accCode;
                    drType         = "Expense";
                    drParticulars  = particulars;
                    crAccount      = supplierCode;
                    crType         = "Supplier";
                    crParticulars  = "Invoice from " + supplierName;
                }
                else // BANK payment
                {
                    drAccount      = supplierCode;
                    drType         = "Supplier";
                    drParticulars  = "Payment to " + supplierName;
                    crAccount      = accCode;
                    crType         = "Bank";
                    crParticulars  = particulars;
                }

                const string insertSql = @"INSERT INTO fin_ledger
                    (transactionDate, accountcode, account_type, particulars, transactionType, transaction_amount,
                     voucherNo, RefNo, teller, timeLog, folio, journal_no, trans_currency, actual_amount, curr_balance, forex_rate, ugx_amount)
                    VALUES
                    (@date, @account, @accType, @particulars, @typ, @amount,
                     @voucherNo, @refNo, @teller, @timeLog, @folio, @journalNo, 'UGX', @actualAmount, '-', 1, @ugxAmount)";

                // DR row
                using (var drCmd = new MySqlCommand(insertSql, conn))
                {
                    drCmd.Transaction = tx;
                    drCmd.Parameters.AddWithValue("@date",        txnDate);
                    drCmd.Parameters.AddWithValue("@account",     drAccount);
                    drCmd.Parameters.AddWithValue("@accType",     drType);
                    drCmd.Parameters.AddWithValue("@particulars", drParticulars);
                    drCmd.Parameters.AddWithValue("@typ",         "DR");
                    drCmd.Parameters.AddWithValue("@amount",      amount);
                    drCmd.Parameters.AddWithValue("@voucherNo",   voucherNo);          // numeric — no type mismatch
                    drCmd.Parameters.AddWithValue("@refNo",       refNo);
                    drCmd.Parameters.AddWithValue("@teller",      user);
                    drCmd.Parameters.AddWithValue("@timeLog",     timeLog);
                    drCmd.Parameters.AddWithValue("@folio",       drAccount);
                    drCmd.Parameters.AddWithValue("@journalNo",   voucherNo.ToString()); // string column
                    drCmd.Parameters.AddWithValue("@actualAmount", amount);
                    drCmd.Parameters.AddWithValue("@ugxAmount",   amount);
                    drCmd.ExecuteNonQuery();
                }

                // CR row
                using (var crCmd = new MySqlCommand(insertSql, conn))
                {
                    crCmd.Transaction = tx;
                    crCmd.Parameters.AddWithValue("@date",        txnDate);
                    crCmd.Parameters.AddWithValue("@account",     crAccount);
                    crCmd.Parameters.AddWithValue("@accType",     crType);
                    crCmd.Parameters.AddWithValue("@particulars", crParticulars);
                    crCmd.Parameters.AddWithValue("@typ",         "CR");
                    crCmd.Parameters.AddWithValue("@amount",      amount);
                    crCmd.Parameters.AddWithValue("@voucherNo",   voucherNo);
                    crCmd.Parameters.AddWithValue("@refNo",       refNo);
                    crCmd.Parameters.AddWithValue("@teller",      user);
                    crCmd.Parameters.AddWithValue("@timeLog",     timeLog);
                    crCmd.Parameters.AddWithValue("@folio",       crAccount);
                    crCmd.Parameters.AddWithValue("@journalNo",   voucherNo.ToString());
                    crCmd.Parameters.AddWithValue("@actualAmount", amount);
                    crCmd.Parameters.AddWithValue("@ugxAmount",   amount);
                    crCmd.ExecuteNonQuery();
                }
            });

            lbl_msgbox.Text = "Transaction Added Successfully. Voucher #" + voucherNo;
            gvLedger.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msgbox.Text = "Transaction Error! [" + ex.Message + "]";
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