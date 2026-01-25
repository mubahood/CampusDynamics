using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Systems.Settings.SD;

public partial class UserControls_Accounts_PaymentVoucher : System.Web.UI.UserControl
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
        }
        txtPayee.DataBind();
        txtLedgerType.DataBind();
        lbl_VoucherNo.Text  = Session["VNO"].ToString();
        txtStatus.Text = Session["PostStatus"].ToString();
        lbl_header.Text = Session["header"].ToString();
        pop_messagebox.HeaderText = HomePageManager.SystemName();

    }
    protected void cmdPreview_Click(object sender, EventArgs e)
    {
        
    }
    
    protected void cmdPreview_Click1(object sender, EventArgs e)
    {
        
        if ((txtPayee.Text == "" || txtAmount.Text == "0") && txtStatus.Text=="New")
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
            if (txtStatus.Text == "New")
            {
                lbl_msg.Text = Acc.NewVoucherEntry(int.Parse(lbl_VoucherNo.Text), txtBankAccount.Value.ToString(), "Chart Account", CRParticulars, txtPayee.Value.ToString(), 
                    txtLedgerType.Text,DRParticulars, long.Parse(txtAmount.Text.Replace(",", "")), 0, DateTime.Parse(txtDate.Text));
            }
            Session["VNO"] = lbl_VoucherNo.Text;
            pop_preview.ShowOnPageLoad = true;
        }
        
    }

    
}