using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Systems.Settings.SD;

public partial class UserControls_Accounts_ReceiptDetails : System.Web.UI.UserControl
{
    CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter VNo = new CoopERPDataTableAdapters.fin_vouchernumbersTableAdapter();
    SettingsFile setting = new SettingsFile();
    protected void Page_Load(object sender, EventArgs e)
    {

        if (!IsPostBack)
        {
            txtDate.Text = DateTime.Today.ToShortDateString();
            txtBankAccount.SelectedIndex = 0;
            txtLedgerType.SelectedIndex = 0;
            txtParticulars.Text = "Being payment for";
            txtDate.Value = DateTime.Parse(Session["receiptDate"].ToString());
            txtYear.Text = DateTime.Today.Year.ToString();
            txtTerm.Text = StudentBillsPaymentBLL.DefaultTerm();
        }
        txtPayee.DataBind();
        txtLedgerType.DataBind();
        lbl_VoucherNo.Text = Session["VNO"].ToString();
        txtStatus.Text = Session["PostStatus"].ToString();
        lbl_header.Text = Session["header"].ToString();
        if (txtStatus.Text.Contains("Print"))
        {
            //cmdPreview.Visible = false;
        }
        if (gvJournalEntries.VisibleRowCount > 0)
        {
            Session["admn"] = gvJournalEntries.GetRowValues(0, "accountcode");
        }
        pop_messagebox.HeaderText = HomePageManager.SystemName();

    }
    protected void cmdPreview_Click(object sender, EventArgs e)
    {

    }

    protected void cmdPreview_Click1(object sender, EventArgs e)
    {

        if ((txtPayee.Text == "" || txtAmount.Text == "0") && txtStatus.Text == "New" && gvJournalEntries.VisibleRowCount==0)
        {
            img_msg.ImageUrl = setting.InfoImage("Error");
            lbl_msg.ForeColor = setting.InfoColor("Error");
            lbl_msg.Text = "Error! Please select a valid payee and enter a valid amount";
            pop_messagebox.ShowOnPageLoad = true;
        }
        else
        {

            AccountsBLL Acc = new AccountsBLL();
            pop_preview.Width = 800;
            pop_preview.Height = 550;
            string CRParticulars = txtParticulars.Text + " to " + txtPayee.Text;
            string DRParticulars = txtParticulars.Text + " through " + txtBankAccount.Text;
            img_msg.ImageUrl = setting.InfoImage("OK");
            lbl_msg.ForeColor = setting.InfoColor("OK");
            if (txtStatus.Text == "New" && gvJournalEntries.VisibleRowCount==0)
            {
                lbl_msg.Text = Acc.NewVoucherEntry(int.Parse(lbl_VoucherNo.Text),  txtPayee.Value.ToString(),
                    txtLedgerType.Text, DRParticulars, txtBankAccount.Value.ToString(), "Chart Account", CRParticulars, long.Parse(txtAmount.Text.Replace(",", "")), 0, DateTime.Parse(txtDate.Text));
            }
            Session["VNO"] = lbl_VoucherNo.Text;
            Session["yr"] = txtYear.Text;
            Session["trm"] = txtTerm.Text;
            if (gvJournalEntries.VisibleRowCount == 0)
            {
                Session["admn"] = txtPayee.Value;
            }
            else
            {
                Session["admn"] = gvJournalEntries.GetRowValues(0, "accountcode");
            }
            pop_preview.ShowOnPageLoad = true;
        }
    }
    protected void txtLedgerType_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtParticulars.Text = "Being payment for "+txtLedgerType.Text;
    }
    protected void txtPayeeCategory_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void txtYear_NumberChanged(object sender, EventArgs e)
    {
        txtPayee.DataBind();
    }
}