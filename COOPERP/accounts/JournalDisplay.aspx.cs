using CoopERPDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_JournalDisplay : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtType.Text = Session["JournalType"].ToString();
        }
        ButtonManager();
    }
    protected void cmdCreateNew_Click(object sender, EventArgs e)
    {
        fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
        JN.fin_CreateJournal(txtType.Text, DateTime.Today, HttpContext.Current.User.Identity.Name);
        gvParticulars.DataBind();
        Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        gvDetails.DataBind();
    }
    
    protected void gvParticulars_DataBound(object sender, EventArgs e)
    {
        Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        gvDetails.DataBind();
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
        if (txtType.Text == "Receipt")
        {
            Session["Report"] = "Receipt";
            Session["accno"] = gvParticulars.GetRowValues(0, "GL_VoucherNo");
            Response.Redirect("~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx");
        }
        else if (txtType.Text == "Student")
        {
            Session["Report"] = "Journal";
            Session["accno"] = gvParticulars.GetRowValues(0, "JournalNo");
            Response.Redirect("~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx");
        }
        else
        {
            Session["Report"] = "Journal";
            Session["accno"] = gvParticulars.GetRowValues(0, "JournalNo");
            Response.Redirect("~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx");
        }
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
        int batchId = -1;
        int transactionCount = 0;
        decimal totalDebit = 0m;
        decimal totalCredit = 0m;

        try
        {
            if (HttpContext.Current.User.IsInRole("Administrator") || HttpContext.Current.User.IsInRole("Bursar"))
            {
                int journalNo = int.Parse(Session["jno"].ToString());
                string currentUser = HttpContext.Current.User.Identity.Name;
                string journalTypeParam = rb_openingBalance.SelectedItem.ToString();

                using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
                {
                    conn.Open();

                    batchId = FinanceSystemRealignmentHelper.CreateTransactionBatch(
                        conn,
                        "JournalEntry",
                        currentUser,
                        "Journal Entry #" + journalNo,
                        "JournalDisplay");

                    string validationMessage;
                    bool isReadyForApproval = FinanceSystemRealignmentHelper.TryPrepareBatchForVoucher(
                        conn,
                        "fin_ledger",
                        "voucherNo",
                        journalNo,
                        batchId,
                        out transactionCount,
                        out totalDebit,
                        out totalCredit,
                        out validationMessage);

                    if (!isReadyForApproval)
                    {
                        if (batchId > 0)
                            FinanceSystemRealignmentHelper.MarkBatchFailed(conn, batchId, validationMessage);

                        lbl_msg.Text = validationMessage;
                        pop_messagebox.ShowOnPageLoad = true;
                        return;
                    }

                    fin_journalnumbersTableAdapter LEDGER = new fin_journalnumbersTableAdapter();
                    lbl_msg.Text = LEDGER.fin_ApproveJournal_Safe(journalNo, currentUser, journalTypeParam).ToString();

                    if (batchId > 0)
                    {
                        FinanceSystemRealignmentHelper.LogAction(
                            conn,
                            "Validate",
                            "fin_ledger",
                            journalNo,
                            batchId,
                            currentUser,
                            "POST_APPROVAL",
                            "Journal entry passed pre-posting double-entry validation and was approved.");

                        FinanceSystemRealignmentHelper.MarkBatchComplete(conn, batchId, transactionCount, totalDebit, totalCredit);
                    }
                }
                gvParticulars.DataBind();
                ButtonManager();
            }
            else
            {
                lbl_msg.Text = "Sorry. Only Bursar Approve Journals. See Your Bursar";
            }
        }
        catch (Exception ex)
        {
            if (batchId > 0)
            {
                try
                {
                    using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
                    {
                        conn.Open();
                        FinanceSystemRealignmentHelper.MarkBatchFailed(conn, batchId, ex.Message);
                    }
                }
                catch { }
            }

            // B5 FIX: Show approval error instead of swallowing silently
            lbl_msg.Text = "Approval Error: " + ex.Message;
        }
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
                gvDetails.SettingsContextMenu.Enabled = false;
                gvDetails.Enabled = false;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;

            }
            else
            {

                gvDetails.SettingsContextMenu.Enabled = true;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
            }
        }
        catch (Exception)
        {
            // B5 FIX: ButtonManager failure is non-critical
        }
    }
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
}