using CoopERPDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_JournalCentre : System.Web.UI.UserControl
{
    string UserName = HttpContext.Current.User.Identity.Name;
    protected void Page_Load(object sender, EventArgs e)
    {
        fin_journalnumbersTableAdapter JN = new fin_journalnumbersTableAdapter();
        JN.CleanJournalDetails();

        if (!IsPostBack)
        {
            if (DateTime.Today.Month < 8)
            {
                txtStartDate.Value = "01/01/" + DateTime.Today.AddYears(-1).Year;
            }
            else
            {
                txtStartDate.Value = "01/01/" + DateTime.Today.Year;
            }
            txtEndDate.Value = DateTime.Today;
            if (Request["j"]!=null) txtJournalType.Text = Request["j"];
            txtJournalType.DataBind();


        }
        if ( Request["j"] == "Receipt")
        {
            txtJournalType.Text = "Receipt";
            //txtJournalType.ReadOnly = true;
            txtJournalType.Enabled = true;
            if (Request.QueryString["j"] == "Receipt")
            {
                txtReceiptType.Enabled = true;
                img_headerimg.ImageUrl = "~/COOPERP/images/header_receiptcentre.png";
                cmdWizard.Text = "Receipt Wizard";

            }
            else
            {
                txtReceiptType.Enabled = false;
                //txtReceiptType.Text="Sponsorship Distribution";
            }
        }
        else
        {
            //txtJournalType.Text = "Journal";
            txtReceiptType.Enabled = false;
        }

    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        Session["JournalType"] =txtJournalType.Text;
        if (Request.QueryString["j"] == "Receipt")
        {
            txtJournalType.Text = "Receipt";
            Session["JournalType"] = "Receipt";

            if (txtReceiptType.Text == "Sponsor Receipt")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/SponsorReceipt.aspx";

            }
            else if (txtJournalType.Text == "Payment")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/PaymentVoucher.aspx";
            }
            else
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/StudentReceipt.aspx";

            }
        }

        else
        {
            if (txtReceiptType.Text == "Sponsorship Distribution")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/CreateDistribution.aspx";
            }
            else if (txtJournalType.Text == "Payment")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/PaymentVoucher.aspx";
            }
            else if (txtJournalType.Text == "Contra")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/ContraVoucher.aspx";
            }
            else
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/CreateJournal.aspx";
            }
        }
        pop_details.ShowOnPageLoad = true;

    }
    protected void gvJournals_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["journalType"] = txtJournalType.Value;
        e.NewValues["Teller"] = UserName;
        e.NewValues["PostStatus"] = "Not Posted";
        e.NewValues["jornalDate"] = DateTime.Today;
    }
    protected void cmdSave_Click(object sender, EventArgs e)
    {
        gvJournals.UpdateEdit();
        //gvJournals.StartEdit(gvJournals.FocusedRowIndex);
    }
    protected void cmdClose_Click(object sender, EventArgs e)
    {
        gvJournals.UpdateEdit();
    }
    protected void cmdDetails_Click(object sender, EventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 600;
        Session["jno"] = gvJournals.GetRowValues(gvJournals.FocusedRowIndex, "JournalNo");
        Session["JournalType"] = txtJournalType.Text;

        if (gvJournals.GetRowValues(gvJournals.FocusedRowIndex, "PostStatus").ToString() != "Posted")
        {
            if (Request.QueryString["j"] == "Receipt")
            {
                if (txtReceiptType.Text == "Sponsor Receipt")
                {
                    pop_details.ContentUrl = "~/COOPERP/accounts/SponsorReceipt.aspx";
                }
                
                else
                {
                    pop_details.ContentUrl = "~/COOPERP/accounts/StudentReceipt.aspx";
                }
            }
            else if (Request.QueryString["j"] == "Payment")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/PaymentVoucher.aspx";
            }
            else if (Request.QueryString["j"] == "Contra")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/ContraVoucher.aspx";
            }
            else
            {
                if (txtJournalType.Text == "Payment")
                {
                    pop_details.ContentUrl = "~/COOPERP/accounts/DisplayPaymentVoucher.aspx";
                }
                else
                {
                    pop_details.ContentUrl = "~/COOPERP/accounts/ViewJournal.aspx";
                }
            }
        }
        else
        {
            if (txtJournalType.Text == "Payment")
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/DisplayPaymentVoucher.aspx";
            }
            else
            {
                pop_details.ContentUrl = "~/COOPERP/accounts/JournalDisplay.aspx";
            }
        }
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdJournalTypes_Click(object sender, EventArgs e)
    {
        pop_details.Width = 400;
        pop_details.Height = 400;
        pop_details.ContentUrl = "~/COOPERP/accounts/JournalTypes.aspx";
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvJournals_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        if (e.Values["PostStatus"].ToString() != "Pending")
        {
            Exception ex = new Exception("ERROR! Only Pending Journals Can be Deleted");
            
            throw ex;

        }
    }
    protected void gvJournals_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }
}