using CoopERPDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_CreateJournal : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        txtType.Text = Session["JournalType"].ToString();
        ButtonManager();

    }
    protected void cmdCreateNew_Click(object sender, EventArgs e)
    {
        // Check if the current date is in an open financial period
        string errorMsg;  // declare the variable first
        if (!IsInOpenFinancialPeriod(out errorMsg))
        {
            lbl_msg.Text = errorMsg;
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }

        // Get user input for RefNo
        string refNo = txtRefNo.Text.Trim();

        // Create the journal
        fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
        JN.fin_CreateJournal(txtType.Text, DateTime.Today, HttpContext.Current.User.Identity.Name);

        gvParticulars.DataBind();
        int journalNo = int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString());
        Session["jno"] = journalNo;

        if (!string.IsNullOrWhiteSpace(refNo) && refNo != "-")
        {
            // Update the RefNo for this JournalNo
            JN.UpdateRefNo(refNo, journalNo);
        }

        gvDetails.DataBind();
        ButtonManager();
    }
    protected void cmdAddItem_Click(object sender, EventArgs e)
    {
        // Check financial period first
        string errorMsg;
        if (!IsInOpenFinancialPeriod(out errorMsg))
        {
            lbl_msg.Text = errorMsg;
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }
        if (string.IsNullOrEmpty(txtRefNo.Text.Trim()) || txtRefNo.Text.Trim() == "-")
        {
            lbl_msg.Text = "Error! Enter Journal Reference number first";
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }

        if (gvParticulars.GetRowValues(0, "journalParticulars").ToString() == "-")
        {
            lbl_msg.Text = "Error! Enter Journal Memo first";
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }


        pop_NewDetail.ShowOnPageLoad = true;
    }
    protected void gvParticulars_DataBound(object sender, EventArgs e)
    {
        Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        gvDetails.DataBind();
    }
    protected void AddNewItem_Click(object sender, EventArgs e)
    {
        fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();

        // Get reference number from the input
        string refNo = txtRefNo.Text;

        LEDGER.AddJournalDetails(
            int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), // Journal No
            Session["username"].ToString(),                                  // User
            txtAccount.Value.ToString(),                                      // Account code
            txtAccount.SelectedItem.GetValue("category").ToString(),          // Account type
            gvParticulars.GetRowValues(0, "journalParticulars").ToString(),   // Details / Memo
            txtTransactionType.Text,                                          // Transaction type
            refNo                                                             // Reference No
        );

        gvDetails.DataBind();
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        txtAccount.DataBind();
        txtAccount.SelectedIndex = 0;
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
        Session["xtraReport"] = "Journal";
        Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        Response.Redirect("~/ERP/accounts/xtraReports/xtraReportCentre.aspx");
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
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
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
                cmdCreateNew.Text = "New Receipt";
            }
            string journal_currency = gvParticulars.GetRowValues(0, "journal_currency").ToString();
            if (journal_currency != "UGX")
            {
                fin_currencyTableAdapter CURR = new fin_currencyTableAdapter();
                DataTable tb_forex_rates = CURR.GetGetCurrencyRates(journal_currency);
                string buy_rate = tb_forex_rates.Rows[0]["buy_rates"].ToString();
                string sell_rate = tb_forex_rates.Rows[0]["rates"].ToString();
                if (rb_forex_op.Value.ToString() == "Buying")
                {
                    if (IsPostBack)
                    {
                        JN.UpdateForexRate(decimal.Parse(buy_rate), int.Parse(Session["jno"].ToString()));
                    }
                    txtForexRate.Text = double.Parse(buy_rate).ToString("0.00");

                }
                else
                {
                    if (IsPostBack)
                    {
                        JN.UpdateForexRate(decimal.Parse(sell_rate), int.Parse(Session["jno"].ToString()));
                    }
                    txtForexRate.Text = double.Parse(sell_rate).ToString("0.00");
                }
                gvParticulars.DataBind();
                rb_forex_op.Enabled = true;
                txtForexRate.Enabled = true;
            }
            else
            {
                rb_forex_op.Enabled = false;
                txtForexRate.Text = "1";
                if (IsPostBack)
                {
                    JN.UpdateForexRate(1, int.Parse(Session["jno"].ToString()));
                    gvParticulars.DataBind();
                }
                txtForexRate.Enabled = false;
            }

            if (ApprovalStat == "Posted")
            {

                cmdAddItem.Visible = false;
                gvDetails.SettingsContextMenu.Enabled = false;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
                

            }
            else
            {

                cmdAddItem.Visible = true;
                gvDetails.SettingsContextMenu.Enabled = true;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
            }
        }
        catch (Exception) { }
    }

    protected void cmdDelete_Click(object sender, EventArgs e)
    {
        int jno = int.Parse(Session["jno"].ToString());
        int TID = int.Parse(gvDetails.GetRowValues(gvDetails.FocusedRowIndex, "TID").ToString());
        fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
        LEDGER.fin_Delete_journal_item(TID, jno);
        gvDetails.DataBind();
    }
    protected void txtRefNo_TextChanged(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(txtRefNo.Text)) return;

        fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
        int journalNo = int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString());

        JN.UpdateRefNo(txtRefNo.Text.Trim(), journalNo);
    }

    private bool IsInOpenFinancialPeriod(out string errorMessage)
{
    errorMessage = "";
    fin_financial_yearsTableAdapter FY = new fin_financial_yearsTableAdapter();
    var dtOpen = FY.GetFinicalPeriodStatus(); // get Open period

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