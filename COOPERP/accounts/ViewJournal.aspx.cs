using CoopERPDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_ViewJournal : System.Web.UI.Page
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
        string refNo = gvParticulars.GetRowValues(0, "RefNo").ToString();

        
        fin_ledgerTableAdapter LEDGER = new fin_ledgerTableAdapter();
        LEDGER.AddJournalDetails(int.Parse(gvParticulars.GetRowValues(0, "JournalNo").ToString()), Session["username"].ToString(), txtAccount.Value.ToString(),
        txtAccount.SelectedItem.GetValue("category").ToString(), gvParticulars.GetRowValues(0, "journalParticulars").ToString(), txtTransactionType.Text, refNo);
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
        try
        {
            // Check financial period
            string errorMsg;
            if (!IsInOpenFinancialPeriod(out errorMsg))
            {
                lbl_msg.Text = errorMsg;
                pop_messagebox.ShowOnPageLoad = true;
                return;
            }
            if (HttpContext.Current.User.IsInRole("Administrator") || HttpContext.Current.User.IsInRole("Bursar"))
            {
                fin_journalnumbersTableAdapter LEDGER = new fin_journalnumbersTableAdapter();
                lbl_msg.Text = LEDGER.fin_ApproveJournal_Safe(int.Parse(Session["jno"].ToString()), HttpContext.Current.User.Identity.Name,rb_openingBalance.SelectedItem.ToString()).ToString();
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
                cmdApproveJournal.Text = "Create Receipt";
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
        catch (Exception)
        {
            // B5 FIX: ButtonManager failure is non-critical — default to safe state
            cmdApproveJournal.Text = "Create Receipt";
        }
    }
    protected void gvParticulars_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
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
            errorMessage = "Ooops! Cannot Post Transcation. Accounting Period Closed. The Date Ranges are: "
                           + periodStart.ToString("dd/MM/yyyy") + " - " + periodEnd.ToString("dd/MM/yyyy") + ".";
            return false;
        }


        return true;
    }

}