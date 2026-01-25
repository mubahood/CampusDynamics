using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Web;
using CoopERPDataTableAdapters;

public partial class UserControls_Accounts_ReceiptPreview : System.Web.UI.UserControl
{
    ControlDefiners cont = new ControlDefiners();
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        fin_GetSingleVoucherTableAdapter Voucher = new fin_GetSingleVoucherTableAdapter();
        ASPxCheckBox cb_Print = cont.DataRowASPXCheckBoxDefiner("cb_PrintReceipt", gvSingleVoucher, 0);
        Session["Report"] = "Receipt";
        if (cb_Print.Checked == true)
        {
            Response.Redirect("~/COOPERP/XtraReports/Default.aspx");
        }
        else
        {
            Voucher.fin_ApproveStudentReceipt(int.Parse(Session["VNO"].ToString()), "Approved", int.Parse(Session["yr"].ToString()),
                int.Parse(Session["trm"].ToString()),Session["admn"].ToString());
            lbl_msg.Text = "Approval Completed";
            pop_messagebox.ShowOnPageLoad = true;
        }
    }
    protected void cb_PrintReceipt_CheckedChanged(object sender, EventArgs e)
    {
        ASPxCheckBox cb_Print = cont.DataRowASPXCheckBoxDefiner("cb_PrintReceipt", gvSingleVoucher, 0);
        ASPxButton cmdApprove = cont.DataRowASPXButtonDefiner("cmdApprove", gvSingleVoucher, 0);
        if (cb_Print.Checked == true)
        {
            cmdApprove.Text = "Approve & Print Receipt";
        }
        else
        {
            cmdApprove.Text = "Approve Receipt Only";
        }
    }
    protected void cmdCancel_Click(object sender, EventArgs e)
    {

    }
}