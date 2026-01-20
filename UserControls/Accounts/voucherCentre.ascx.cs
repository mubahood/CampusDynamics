using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_accounts_voucherCentre : System.Web.UI.UserControl
{
    string UserName = HttpContext.Current.User.Identity.Name;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Value = DateTime.Today;
            txtEndDate.Value = DateTime.Today;
        }
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter VC = new CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter();
        VC.Insert(UserName,"New",txtJournalType.Value.ToString(),DateTime.Today);
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
        Session["VNO"] = gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "VoucherNo");
        Session["PostStatus"] = gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "PostStatus");
        Session["header"] = string.Format("DETAILS FOR {1} NO. {0}", gvVouchers.GetRowValues(gvVouchers.FocusedRowIndex, "VoucherNo"), txtJournalType.Text.ToUpper());
        pop_details.ShowOnPageLoad = true;
    }
}