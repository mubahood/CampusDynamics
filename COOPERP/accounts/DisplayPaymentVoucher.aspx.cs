using CoopERPDataTableAdapters;
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
            fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
            string refNo = txtRefNo.Text.Trim();

            if (rb_payeetype.SelectedIndex == 0)
            {

                LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtAccount.Value.ToString(),
                "Chart Account", gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid to " + txtPayees.Text, "CR", refNo);
            }

            LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtPayees.Value.ToString(),
            txtPayees.SelectedItem.GetValue("category").ToString(), gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid thru " + txtAccount.Text, "DR", refNo);

            fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
            string Particulars = gvParticulars.GetRowValues(0, "journalParticulars").ToString() + " Paid Thru " + txtAccount.Text;
            int JNO = int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString());
            //JN.UpdateParticulars(Particulars, JNO);

            JN.UpdateJournalAmounts(decimal.Parse(txtAmount.Text.Replace(",", "")), decimal.Parse(txtAmount.Text.Replace(",", "")), JNO.ToString());
            gvParticulars.DataBind();
            gvDetails.DataBind();
            lbl_msg.Text = "Voucher Details Added Successfully";
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
        catch (Exception)
        {
            cmdApproveJournal.Text = "Create New";
        }
    }
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
}