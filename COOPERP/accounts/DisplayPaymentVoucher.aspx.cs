using CoopERPDataTableAdapters;
using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_DisplayPaymentVoucher : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Prevent browser/popup cache from showing old voucher values
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));

        // This page depends on Session["jno"].
        // If it is missing, the ObjectDataSource can fail and the popup keeps loading.
        if (Session["jno"] == null || string.IsNullOrEmpty(Session["jno"].ToString()))
        {
            lbl_msg.Text = "Error! No voucher selected. Please select a voucher first.";
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }

        if (!IsPostBack)
        {
            if (Session["JournalType"] != null)
            {
                txtType.Text = Session["JournalType"].ToString();
            }
        }

        ButtonManager();
    }

    protected void CreateReceipt()
    {
        fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
        JN.fin_CreateJournal(txtType.Text, DateTime.Today, HttpContext.Current.User.Identity.Name);

        gvParticulars.DataBind();

        if (gvParticulars.VisibleRowCount > 0)
        {
            Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        }

        gvDetails.DataBind();
        lbl_msg.Text = "New Voucher Created Successfully. Add Details to proceed";
    }

    protected void cmdAddItem_Click(object sender, EventArgs e)
    {
        if (gvParticulars.VisibleRowCount == 0)
        {
            lbl_msg.Text = "Error! No voucher selected.";
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }

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
        if (gvParticulars.VisibleRowCount > 0)
        {
            Session["jno"] = gvParticulars.GetRowValues(0, "JournalNo");
        }
    }

    protected void AddNewItem_Click(object sender, EventArgs e)
    {
        try
        {
            if (gvParticulars.VisibleRowCount == 0)
            {
                lbl_msg.Text = "Error! No voucher selected.";
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }

            fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
            string refNo = txtRefNo.Text.Trim();

            // B1 FIX: CR entry must ALWAYS be created (double-entry rule: every DR must have a CR)
            // Previously skipped CR when rb_payeetype.SelectedIndex != 0 (Multiple Payee)
            LEDGER.AddJournalDetails(
                int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()),
                Session["username"].ToString(),
                txtAccount.Value.ToString(),
                "Chart Account",
                gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid to " + txtPayees.Text,
                "CR",
                refNo
            );

            LEDGER.AddJournalDetails(
                int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()),
                Session["username"].ToString(),
                txtPayees.Value.ToString(),
                txtPayees.SelectedItem.GetValue("category").ToString(),
                gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid thru " + txtAccount.Text,
                "DR",
                refNo
            );

            fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
            string Particulars = gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid Thru " + txtAccount.Text;
            int JNO = int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString());
            //JN.UpdateParticulars(Particulars, JNO);

            JN.UpdateJournalAmounts(
                decimal.Parse(txtAmount.Text.Replace(",", "")),
                decimal.Parse(txtAmount.Text.Replace(",", "")),
                JNO.ToString()
            );

            gvParticulars.DataBind();
            gvDetails.DataBind();

            lbl_msg.Text = "Voucher Details Added Successfully";
        }
        catch (Exception ex)
        {
            // B6 FIX: Show actual error instead of generic message
            lbl_msg.Text = "Error: " + ex.Message;
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
        if (e.Exception != null && e.Exception.InnerException != null)
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
        else if (e.Exception != null)
        {
            e.ErrorText = e.Exception.Message;
        }
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
        if (gvParticulars.VisibleRowCount == 0)
        {
            lbl_msg.Text = "Error! No voucher selected.";
            pop_messagebox.ShowOnPageLoad = true;
            return;
        }

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
        if (e.Exception != null && e.Exception.InnerException != null)
        {
            e.ErrorText = e.Exception.InnerException.Message;
        }
        else if (e.Exception != null)
        {
            e.ErrorText = e.Exception.Message;
        }
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
                if (cmdApproveJournal.Text == "Create New")
                {
                    CreateReceipt();
                }
                else
                {
                    if (Session["jno"] == null || string.IsNullOrEmpty(Session["jno"].ToString()))
                    {
                        lbl_msg.Text = "Error! No voucher selected.";
                        pop_messagebox.ShowOnPageLoad = true;
                        return;
                    }

                    int journalNo = int.Parse(Session["jno"].ToString());
                    string currentUser = HttpContext.Current.User.Identity.Name;

                    using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
                    {
                        conn.Open();

                        batchId = FinanceSystemRealignmentHelper.CreateTransactionBatch(
                            conn,
                            "PaymentVoucher",
                            currentUser,
                            "Display Payment Voucher #" + journalNo,
                            "DisplayPaymentVoucher"
                        );

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
                            out validationMessage
                        );

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
                                "Payment voucher passed pre-posting double-entry validation and was approved."
                            );

                            FinanceSystemRealignmentHelper.MarkBatchComplete(conn, batchId, transactionCount, totalDebit, totalCredit);
                        }
                    }
                }

                gvParticulars.DataBind();
                gvDetails.DataBind();
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
                catch
                {
                }
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
            if (gvParticulars.VisibleRowCount == 0)
            {
                cmdApproveJournal.Text = "Create New";
                cmdAddItem.Visible = false;
                return;
            }

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
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
            }
            else
            {
                cmdApproveJournal.Text = "Approve Voucher";
                cmdAddItem.Visible = true;
                gvDetails.SettingsContextMenu.Enabled = true;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
            }
        }
        catch (Exception ex)
        {
            cmdApproveJournal.Text = "Create New";
            lbl_msg.Text = "Button Error: " + ex.Message;
        }
    }

    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
}