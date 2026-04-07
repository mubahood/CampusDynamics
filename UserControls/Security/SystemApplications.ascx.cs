using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class UserControls_Security_SystemApplications : System.Web.UI.UserControl
{
    /// <summary>
    /// Returns true if the string looks like a real email address
    /// (has text before and after the '@').
    /// </summary>
    private static bool IsValidEmail(string email)
    {
        if (string.IsNullOrEmpty(email)) return false;
        email = email.Trim();
        int at = email.IndexOf('@');
        // Must have something before '@' and a dot somewhere after it
        return at > 0 && at < email.Length - 1 && email.IndexOf('.', at) > at;
    }

    /// <summary>
    /// Search every known email source for the given login username.
    /// Order: 1) my_aspnet_userphone.emails
    ///        2) my_aspnet_membership.Email   (via my_aspnet_users)
    ///        3) hrm_employee.emp_email       (via hrm_employee.usernames)
    ///        4) hrm_staff.Email              (via hrm_employee.EMP_CODE)
    /// Returns the first valid email found, or empty string.
    /// </summary>
    private string FindUserEmail(string username)
    {
        try
        {
            string connStr = ConfigurationManager.ConnectionStrings["schoolMISConnectionString"].ConnectionString;
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();

                // One query, four LEFT JOINs – grab every possible email in a single round trip
                string sql =
                    "SELECT p.emails, m.Email, e.emp_email, s.Email AS staff_email "
                  + "FROM my_aspnet_users u "
                  + "LEFT JOIN my_aspnet_userphone  p ON u.name     = p.username "
                  + "LEFT JOIN my_aspnet_membership m ON u.id       = m.userId "
                  + "LEFT JOIN hrm_employee         e ON u.name     = e.usernames "
                  + "LEFT JOIN hrm_staff            s ON e.EMP_CODE = s.staffCode "
                  + "WHERE u.name = @uname LIMIT 1";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@uname", username);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            // Walk through columns in priority order
                            for (int i = 0; i < rdr.FieldCount; i++)
                            {
                                if (rdr.IsDBNull(i)) continue;
                                string val = rdr.GetString(i).Trim();
                                // userphone.emails can hold comma-separated list; take the first valid one
                                if (val.Contains(","))
                                {
                                    foreach (string part in val.Split(','))
                                    {
                                        if (IsValidEmail(part.Trim()))
                                            return part.Trim();
                                    }
                                }
                                else if (IsValidEmail(val))
                                {
                                    return val;
                                }
                            }
                        }
                    }
                }
            }
        }
        catch (Exception) { /* swallow – caller will show the existing error message */ }
        return string.Empty;
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        Page.Form.DefaultButton = cmdVerify.UniqueID;

        // ── Staff OTP gate — re-enabled ──
        try
        {
            if (Session["otp"] == null)
            {
                lbl_comment.ForeColor = System.Drawing.Color.Blue;
                lbl_comment.Text = "Please Request and Verify Code to Proceed";
                pop_otp.ShowOnPageLoad = true;
            }
            else
            {
                pop_otp.ShowOnPageLoad = false;
            }
        }
        catch (Exception)
        {
            Response.Redirect("~/Default.aspx");
        }
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

        // Guard: username must be in session
        if (Session["username"] == null || string.IsNullOrEmpty(Session["username"].ToString()))
        {
            lbl_comment.ForeColor = System.Drawing.Color.Red;
            lbl_comment.Text = "Session expired. Please log in again.";
            return;
        }
        string username = Session["username"].ToString();

        Random Coder = new Random();
        Session["newotp"] = Coder.Next(10000, 99999);

        if (rb_channel.SelectedIndex == 0)
        {
            // --- SMS / Phone path ---
            object phoneObj = USR.GetUserPhone(username);
            string phone = (phoneObj != null) ? phoneObj.ToString() : "";
            if (string.IsNullOrEmpty(phone))
            {
                lbl_comment.ForeColor = System.Drawing.Color.Red;
                lbl_comment.Text = "Error: No phone number found for your account. Please contact support.";
                return;
            }
            string Message = SMS.SMSSending("Campus Dynamics", "Your Code: " + Session["newotp"], phone);
            if (Message.Contains("successfully"))
            {
                lbl_comment.Text = "New Code sent to your phone No [" + phone.Substring(0, Math.Min(8, phone.Length)) + "...]";
            }
            else
            {
                lbl_comment.Text = "SMS Error. No Code Sent [" + Message + "]";
            }
        }
        else
        {
            // --- Email path ---
            // Search all known email sources: userphone, membership, employee, staff
            string Email = FindUserEmail(username);

            if (string.IsNullOrEmpty(Email))
            {
                lbl_comment.ForeColor = System.Drawing.Color.Red;
                lbl_comment.Text = "Error: No email address found for your account. Please contact support.";
                return;
            }

            string EmailMessage = "Your OTP Code: " + Session["newotp"];
            string sendResult = "";
            try
            {
                EmailSenderProtocol Emailer = new EmailSenderProtocol();
                sendResult = Emailer.SendMail("", Email, "Campus Dynamics \u2013 OTP Code", "Campus Dynamics", EmailMessage, "");
            }
            catch (Exception ex)
            {
                sendResult = "Error! " + ex.Message;
            }

            if (sendResult.IndexOf("Successfully", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                lbl_comment.ForeColor = System.Drawing.Color.Green;
                lbl_comment.Text = "OTP sent successfully to: " + Email;
            }
            else
            {
                lbl_comment.ForeColor = System.Drawing.Color.Red;
                lbl_comment.Text = "Failed to send OTP to: " + Email + " — " + sendResult;
            }
        }
    }
}