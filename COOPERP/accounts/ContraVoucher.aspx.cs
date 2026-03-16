using CoopERPDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_PaymentVoucher : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtType.Text = Session["JournalType"].ToString();
        }
        ButtonManager();
    }
    protected void CreateReceipt()
    {
        fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
        JN.fin_CreateJournal(txtType.Text, DateTime.Today, HttpContext.Current.User.Identity.Name);
        gvParticulars.DataBind();
        Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        gvDetails.DataBind();
        lbl_msg.Text = "New Voucher Created Successfully. Add Details to proceed";
    }
    protected void cmdAddItem_Click(object sender, EventArgs e)
    {
        if (gvParticulars.GetRowValues(0, "journalParticulars").ToString() == "-")
        {
            lbl_msg.Text = "Error! Enter Voucher Memo first";
            pop_messagebox.ShowOnPageLoad = true;
        }
        else
        {
            pop_NewDetail.ShowOnPageLoad = true;
        }
    }
    protected void gvParticulars_DataBound(object sender, EventArgs e)
    {
        Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        //gvDetails.DataBind();
    }
    protected void AddNewItem_Click(object sender, EventArgs e)
    {
        try
        {
            // B12 FIX: Block transactions outside open financial period
            string periodError;
            if (!IsInOpenFinancialPeriod(out periodError))
            {
                lbl_msg.Text = periodError;
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }

            // C7 FIX: Input validation
            if (txtSourceAccount.Value == null || string.IsNullOrEmpty(txtSourceAccount.Value.ToString()))
            {
                lbl_msg.Text = "Error! Please select a Source Account";
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }
            if (txtDestAccount.Value == null || string.IsNullOrEmpty(txtDestAccount.Value.ToString()))
            {
                lbl_msg.Text = "Error! Please select a Destination Account";
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }
            decimal amount;
            if (!decimal.TryParse(txtAmount.Text.Replace(",", ""), out amount) || amount <= 0)
            {
                lbl_msg.Text = "Error! Enter a valid amount greater than zero";
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }
            if (amount > 10000000000m)
            {
                lbl_msg.Text = "Error! Amount exceeds maximum allowed (10 Billion UGX)";
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }

            if (txtSourceAccount.Text == txtDestAccount.Text)
            {
                lbl_msg.Text = "Error! Source and Destination Accounts should be different";
            }
            else
            {
                fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
                fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();

                // C5 FIX: Wrap all DB writes in TransactionScope — either all succeed or all roll back
                using (TransactionScope scope = new TransactionScope())
                {
                    LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtDestAccount.Value.ToString(),
                    "Chart Account", gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Transferred from " + txtSourceAccount.Value.ToString(), "DR", "");

                    LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtSourceAccount.Value.ToString(),
                    "Chart Account", gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid to " + txtDestAccount.Text, "CR", "");

                    string Particulars = gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid Thru " + txtDestAccount.Text;
                    int JNO = int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString());

                    JN.UpdateJournalAmounts(decimal.Parse(txtAmount.Text.Replace(",", "")), decimal.Parse(txtAmount.Text.Replace(",", "")), JNO.ToString());

                    scope.Complete();
                }

                gvParticulars.DataBind();
                gvDetails.DataBind();
                lbl_msg.Text = "Voucher Details Added Successfully";
            }
        }
        catch (Exception)
        {
            lbl_msg.Text = "Error! Check your details and try again";
        }
        pop_messagebox.ShowOnPageLoad = true;
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        //txtAccount.DataBind();
        //txtAccount.SelectedIndex = 0;
    }
    protected void gvParticulars_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void gvDetails_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
        int noRows = gvDetails.VisibleRowCount;
        for (int i = 0; i < noRows; i++)
        {
            LEDGER.ClearBalance(int.Parse(gvDetails.GetRowValues(i, "TID").ToString()));
            LEDGER.fin_UpdateAllLedgerBalances();
        }
        gvDetails.DataBind();



    }
    protected void cmdPrintJournal_Click(object sender, EventArgs e)
    {

        Session["Report"] = "Payment Voucher";
        Session["accno"] = gvParticulars.GetRowValues(0, "JournalNo");
        Response.Redirect("~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx");
        
    }


    protected void cmdCurrencyInfo_Click(object sender, EventArgs e)
    {
        pop_messagebox.Width = 600;
        pop_messagebox.Height = 350;
        pop_messagebox.ContentUrl = "~/ERP/accounts/CurrencyData.aspx";
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void gvDetails_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void cmdApproveJournal_Click(object sender, EventArgs e)
    {
        try
        {
            if (HttpContext.Current.User.IsInRole("Administrator") || HttpContext.Current.User.IsInRole("Bursar"))
            {
                if (cmdApproveJournal.Text == "Create New")
                {
                    CreateReceipt();
                }
                else
                {
                    fin_journalnumbersTableAdapter LEDGER = new fin_journalnumbersTableAdapter();
                    lbl_msg.Text = LEDGER.fin_ApproveJournal(int.Parse(Session["jno"].ToString()), HttpContext.Current.User.Identity.Name,"Normal Journal").ToString();
                }
                gvParticulars.DataBind();
                ButtonManager();
            }
            else
            {
                lbl_msg.Text = "Sorry. Only Bursar Approve Journals. See Your Bursar";
            }
        }
        catch (Exception) { }
        pop_messagebox.ShowOnPageLoad = true;
    }

    void ButtonManager()
    {
        try
        {

            fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
            Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
            string ApprovalStat = JN.GetApprovalStatus(int.Parse(Session["jno"].ToString()));

            if (txtType.Text == "Receipt")
            {

                cmdPrintJournal.Text = "Print Receipt";

            }

            

            if (ApprovalStat == "Posted" || ApprovalStat == null)
            {
                cmdApproveJournal.Text = "Create New";
                cmdAddItem.Visible = false;
                gvDetails.SettingsContextMenu.Enabled = false;
                gvParticulars.SettingsContextMenu.Enabled = false;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;

            }
            else
            {
                cmdApproveJournal.Text = "Approve Voucher";
                cmdAddItem.Visible = true;
                gvDetails.SettingsContextMenu.Enabled = true;
                gvParticulars.SettingsContextMenu.Enabled = false;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
            }
        }
        catch (Exception)
        {
            cmdApproveJournal.Text = "Create New";
        }
    }
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
    protected void gvParticulars_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        gvParticulars.DataBind();
    }
    protected void gvParticulars_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();

        string journal_currency = e.NewValues["journal_currency"].ToString();
        if (journal_currency != "UGX")
        {
            fin_currencyTableAdapter CURR = new fin_currencyTableAdapter();
            DataTable tb_forex_rates = CURR.GetGetCurrencyRates(journal_currency);
            string buy_rate = tb_forex_rates.Rows[0]["buy_rates"].ToString();
            string sell_rate = tb_forex_rates.Rows[0]["rates"].ToString();

            if (IsPostBack)
            {
                JN.UpdateForexRate(decimal.Parse(buy_rate), int.Parse(Session["jno"].ToString()));
            }

        }
        else
        {

            if (IsPostBack)
            {
                JN.UpdateForexRate(1, int.Parse(Session["jno"].ToString()));
            }
        }
    }
    // B12 FIX: Financial period validation
    private bool IsInOpenFinancialPeriod(out string errorMessage)
    {
        errorMessage = "";
        fin_financial_yearsTableAdapter FY = new fin_financial_yearsTableAdapter();
        var dtOpen = FY.GetFinicalPeriodStatus();
        if (dtOpen.Rows.Count == 0)
        {
            errorMessage = "Error! No financial year is currently Open. Cannot create transactions.";
            return false;
        }
        DateTime periodStart = Convert.ToDateTime(dtOpen.Rows[0]["start_date"]);
        DateTime periodEnd = Convert.ToDateTime(dtOpen.Rows[0]["end_date"]);
        DateTime today = DateTime.Today;
        if (today < periodStart || today > periodEnd)
        {
            errorMessage = "Error! Cannot Add Transaction. Accounting Period Closed. The Date Ranges are: "
                           + periodStart.ToString("dd/MM/yyyy") + " - " + periodEnd.ToString("dd/MM/yyyy") + ".";
            return false;
        }
        return true;
    }
}