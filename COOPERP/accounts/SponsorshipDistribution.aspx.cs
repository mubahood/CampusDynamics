using CoopERPDataTableAdapters;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_SponsorshipDistribution : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtType.Text = Session["JournalType"].ToString();
            txtAcademicYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtAcademicYear.DataBind();
            txtAcademicYear.Text = CommonRoutines.DefaultAcadYear();

            txtTerm.Text = StudentBillsPaymentBLL.DefaultTerm();
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
    protected void cmdAddItem_Click(object sender, EventArgs e)
    {
        if (gvParticulars.GetRowValues(0, "journalParticulars").ToString() == "-")
        {
            lbl_msg.Text = "Error! Enter Journal Memo first";
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
        gvDetails.DataBind();
    }
    protected void AddNewItem_Click(object sender, EventArgs e)
    {
        fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
        LEDGER.fin_AddSponsorJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtAccount.Value.ToString(),
        gvParticulars.GetRowValues(0, "journalParticulars").ToString(),double.Parse(txtAmount.Text.Replace(",","")),txtAcademicYear.Text,txtTerm.Text);
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
        if (txtType.Text == "Receipt")
        {
            Session["Report"] = "Receipt";
            Session["accno"] = gvParticulars.GetRowValues(0, "GL_VoucherNo");
            Response.Redirect("~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx");
        }
        else if(txtType.Text == "Student")
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

                using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
                {
                    conn.Open();

                    batchId = FinanceSystemRealignmentHelper.CreateTransactionBatch(
                        conn,
                        "SponsorshipDistribution",
                        currentUser,
                        "Sponsorship Distribution #" + journalNo,
                        "SponsorshipDistribution");

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
                    lbl_msg.Text = LEDGER.fin_ApproveJournal_Safe(journalNo, currentUser, "Normal Journal").ToString();

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
                            "Sponsorship distribution passed pre-posting double-entry validation and was approved.");

                        FinanceSystemRealignmentHelper.MarkBatchComplete(conn, batchId, transactionCount, totalDebit, totalCredit);
                    }
                }
                gvParticulars.DataBind();
                ButtonManager();
            }
            else
            {
                lbl_msg.Text = "Sorry. Only Bursar Approves Journals. See Your Bursar";
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
                cmdApproveJournal.Text = "Create Receipt";
                cmdAddItem.Visible = false;
                cmdClearDistro.Enabled = false;
                gvDetails.SettingsContextMenu.Enabled = false;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;

            }
            else
            {

                cmdAddItem.Visible = true;
                cmdClearDistro.Enabled = true;
                gvDetails.SettingsContextMenu.Enabled = true;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
            }
        }
        catch (Exception) { }
    }
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
    protected void cmdClearDistro_Click(object sender, EventArgs e)
    {

    }
}