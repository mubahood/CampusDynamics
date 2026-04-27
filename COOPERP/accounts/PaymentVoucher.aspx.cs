using CoopERPDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

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
        UpdateBalanceIndicator();
    }
    protected void AddNewItem_Click(object sender, EventArgs e)
    {
        try
        {
            // B11 FIX: Block transactions outside open financial period
            string periodError;
            if (!IsInOpenFinancialPeriod(out periodError))
            {
                lbl_msg.Text = periodError;
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }

            // C7 FIX: Input validation
            if (txtAccount.Value == null || string.IsNullOrEmpty(txtAccount.Value.ToString()))
            {
                lbl_msg.Text = "Error! Please select a Payment Account";
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }
            if (txtPayees.Value == null || string.IsNullOrEmpty(txtPayees.Value.ToString()))
            {
                lbl_msg.Text = "Error! Please select a Payee";
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

            fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
            fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
            string refNo = txtRefNo.Text.Trim();

            // B1 FIX: CR entry must ALWAYS be created (double-entry rule: every DR must have a CR)
            // Previously skipped CR when rb_payeetype.SelectedIndex != 0 (Multiple Payee)
            LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtAccount.Value.ToString(),
            "Chart Account", gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid to " + txtPayees.Text, "CR", refNo);

            LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtPayees.Value.ToString(),
            txtPayees.SelectedItem.GetValue("category").ToString(), gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid thru " + txtAccount.Text, "DR", refNo);

            string Particulars = gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid Thru " + txtAccount.Text;
            int JNO = int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString());

            JN.UpdateJournalAmounts(decimal.Parse(txtAmount.Text.Replace(",", "")), decimal.Parse(txtAmount.Text.Replace(",", "")), JNO.ToString());

            gvParticulars.DataBind();
            gvDetails.DataBind();
            UpdateBalanceIndicator();
            lbl_msg.Text = "Voucher Details Added Successfully";
            // F6: Audit log - payment voucher created
            AuditLogger.Log("VOUCHER_CREATED",
                string.Format("PaymentAccount={0}, Payee={1}", txtAccount.Value, txtPayees.Value),
                int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()),
                amount);
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
                    int journalNo = int.Parse(Session["jno"].ToString());
                    string currentUser = HttpContext.Current.User.Identity.Name;

                    using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
                    {
                        conn.Open();

                        batchId = FinanceSystemRealignmentHelper.CreateTransactionBatch(
                            conn,
                            "PaymentVoucher",
                            currentUser,
                            "Payment Voucher #" + journalNo,
                            "PaymentVoucher");

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
                                "Payment voucher passed pre-posting double-entry validation and was approved.");

                            FinanceSystemRealignmentHelper.MarkBatchComplete(conn, batchId, transactionCount, totalDebit, totalCredit);
                        }
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
                catch
                {
                }
            }

            // B6 FIX: Show approval error instead of swallowing silently
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
            // B6 FIX: ButtonManager failure is non-critical - default to Create New
            cmdApproveJournal.Text = "Create New";
        }
    }
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
    protected void gvParticulars_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {

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

            gvParticulars.DataBind();

        }
        else
        {

            if (IsPostBack)
            {
                JN.UpdateForexRate(1, int.Parse(Session["jno"].ToString()));
                gvParticulars.DataBind();
            }
        }
    }
    // G3: DR/CR balance indicator
    private void UpdateBalanceIndicator()
    {
        try
        {
            if (Session["jno"] == null || Session["jno"].ToString() == "0") return;
            int jno = int.Parse(Session["jno"].ToString());

            string sql = @"SELECT
                SUM(CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END) AS total_dr,
                SUM(CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END) AS total_cr,
                COUNT(*) AS line_count
                FROM fin_ledger WHERE voucherNo = @jno";

            string connStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString;
            decimal dr = 0, cr = 0; int lines = 0;
            using (var conn = new MySqlConnection(connStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@jno", jno);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read() && reader["total_dr"] != DBNull.Value)
                        {
                            dr = Convert.ToDecimal(reader["total_dr"]);
                            cr = Convert.ToDecimal(reader["total_cr"]);
                            lines = Convert.ToInt32(reader["line_count"]);
                        }
                    }
                }
            }

            if (lines == 0) { litBalance.Text = ""; return; }

            bool balanced = (dr == cr) && lines >= 2;
            string balColor = balanced ? "#28a745" : "#dc3545";
            string balText  = balanced ? "BALANCED ✓" : string.Format("IMBALANCE: {0:N0}", Math.Abs(dr - cr));
            litBalance.Text = string.Format(
                "<div style='background:#f8f9fa;border:1px solid {0};border-radius:4px;padding:8px 14px;margin:4px 0;font-size:12px;font-family:Segoe UI,Arial'>" +
                "<strong>Journal Balance</strong> &nbsp;|&nbsp; " +
                "DR: <strong>{1:N0}</strong> &nbsp;|&nbsp; " +
                "CR: <strong>{2:N0}</strong> &nbsp;|&nbsp; " +
                "<span style='color:{0};font-weight:700'>{3}</span>" +
                "</div>",
                balColor, dr, cr, balText);
        }
        catch { litBalance.Text = ""; }
    }

    // B11 FIX: Financial period validation
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