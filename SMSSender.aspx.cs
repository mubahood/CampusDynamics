using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Net;

public partial class SMSSender : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            try
            {
                txtPhones.Text = Session["receipients"].ToString();
                //txtMessage.Text = Session["message"].ToString();
            }
            catch (Exception ex) 
            {
                Session["receipients"] = "-";
                txtPhones.Text = "-";
                txtMessage.Text = ex.Message;
            }
        }
         if (HttpContext.Current.User.IsInRole("Administrator"))
        {
	   txtPhones.ReadOnly = false;
        }
else{
        txtPhones.ReadOnly = true;
}
    }
   
    protected void cmdClear_Click(object sender, EventArgs e)
    {
        txtMessage.Text = "";
    }
    protected void cmdSend_Click(object sender, EventArgs e)
    {
        SMSSendingBLL sms = new SMSSendingBLL();
        lbl_comment.Text = sms.SMSSending(txtSender.Text, txtMessage.Text, txtPhones.Text);

    }
}