using CoopERPDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_StudentReceipt : System.Web.UI.Page
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
        lbl_msg.Text = "New Receipt Created Successfully. Add Details to proceed";
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
        try
        {
            // B9 FIX: Block transactions outside open financial period
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
                lbl_msg.Text = "Error! Please select a Student Account";
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }
            if (txtPayee.Value == null || string.IsNullOrEmpty(txtPayee.Value.ToString()))
            {
                lbl_msg.Text = "Error! Please select a Payment Method";
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

            // C1 FIX: Wrap all DB writes in TransactionScope — either all succeed or all roll back
            using (TransactionScope scope = new TransactionScope())
            {
                LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtAccount.Value.ToString(),
                txtAccount.SelectedItem.GetValue("category").ToString(), gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid Thru " + txtPayee.Text, "CR");

                LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtPayee.Value.ToString(),
                "Chart Account", gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid By " + txtAccount.Text, "DR");

                string Particulars = gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid By " + txtAccount.Text + "" + " Paid Thru " + txtPayee.Text;
                int JNO = int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString());
                JN.UpdateParticulars(Particulars, JNO);
                JN.UpdateJournalAmounts(decimal.Parse(txtAmount.Text.Replace(",", "")), decimal.Parse(txtAmount.Text.Replace(",", "")), JNO.ToString());

                scope.Complete();
            }

            gvParticulars.DataBind();
            gvDetails.DataBind();
            lbl_msg.Text = "Receipt Details Added Successfully";
        }
        catch (Exception ex)
        {
            // B5 FIX: Show actual error instead of generic message
            lbl_msg.Text = "Error: " + ex.Message;
        }
        pop_messagebox.ShowOnPageLoad = true;
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
                    lbl_msg.Text = LEDGER.fin_ApproveJournal(int.Parse(Session["jno"].ToString()), HttpContext.Current.User.Identity.Name, "Normal Journal").ToString();
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


            if (ApprovalStat == "Posted" || ApprovalStat==null)
            {
                cmdApproveJournal.Text = "Create New";
                cmdAddItem.Visible = false;
                gvDetails.SettingsContextMenu.Enabled = false;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Inline;

            }
            else
            {
                cmdApproveJournal.Text = "Approve Receipt";
                cmdAddItem.Visible = true;
                gvDetails.SettingsContextMenu.Enabled = true;
                gvDetails.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
                gvParticulars.SettingsEditing.Mode = DevExpress.Web.GridViewEditingMode.Batch;
            }
        }
        catch (Exception)
        {
            // B5 FIX: ButtonManager failure is non-critical — default to Create New
            cmdApproveJournal.Text = "Create New";
        }
    }
    // B9 FIX: Financial period validation
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
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
}