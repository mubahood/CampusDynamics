using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_ReceiptCentre : System.Web.UI.UserControl
{
    string UserName = HttpContext.Current.User.Identity.Name;
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!IsPostBack)
        {
            txtStartDate.Value = DateTime.Today.AddDays(-7);
            txtEndDate.Value = DateTime.Today;
        }
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter VC = new CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter();
        VC.Insert(UserName, "New", txtJournalType.Value.ToString(), DateTime.Today);
        gvVouchers.DataBind();
        gvVouchers.StartEdit(0);

    }
    public void gvJournals_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["journalType"] = txtJournalType.Value;
        e.NewValues["Teller"] = UserName;
        e.NewValues["PostStatus"] = "Not Posted";
        e.NewValues["jornalDate"] = DateTime.Today;
    }
    protected void cmdSave_Click(object sender, EventArgs e)
    {
        gvVouchers.UpdateEdit();
        //gvJournals.StartEdit(gvJournals.FocusedRowIndex);
    }
    protected void cmdClose_Click(object sender, EventArgs e)
    {
        gvVouchers.UpdateEdit();
    }
    protected void cmdDetails_Click(object sender, EventArgs e)
    {
        pop_details.Width = 900;
        pop_details.Height = 600;
        if (txtJournalType.Text.Contains("Student"))
        {
            pop_details.ContentUrl = "~/COOPERP/accounts/SponsorReceiptDetails.aspx";
        }
        else
        {
            pop_details.ContentUrl = "~/COOPERP/accounts/ReceiptDetails.aspx";
        }
        Session["VNO"] = gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "VoucherNo");
        Session["PostStatus"] = gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "PostStatus");
        Session["receiptDate"] = gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "voucherDate");
        Session["header"] = string.Format("DETAILS FOR {1} NO. {0}", gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "VoucherNo"), txtJournalType.Text.ToUpper());
        pop_details.ShowOnPageLoad = true;
    }


    protected void cmdEdit_Click(object sender, ImageClickEventArgs e)
    {
        gvVouchers.StartEdit(gvVouchers.FocusedRowIndex);
    }
    protected void cmdDelete_Click(object sender, ImageClickEventArgs e)
    {
        CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter Vouchers = new CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter();
        try
        {
            Vouchers.fin_ReceiptRemover(int.Parse(gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex,"VoucherNo").ToString()), HttpContext.Current.User.Identity.Name);
            lbl_msg.Text = "Receipt Deleted.";
            gvVouchers.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error! "+ex.Message;
        }
        pop_messagebox.ShowOnPageLoad = true;
    }
}