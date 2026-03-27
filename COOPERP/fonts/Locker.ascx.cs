using System;
using System.Web.UI;
using Systems.Settings.SD;

public partial class COOPERP_fonts_Locker : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Licensing.Settings();
        // lbl_lock is hidden - just kept to avoid breaking any external reference
    }

    protected void cmdActivate_Click(object sender, EventArgs e)
    {
        string code = txtLicenseCode.Text.Trim();
        if (string.IsNullOrEmpty(code))
        {
            lbl_comment.Text = "Please enter your activation code.";
            lbl_comment.CssClass = "lk-feedback--err";
            return;
        }

        Licensing lic = new Licensing();
        string result = lic.UpdateLicense(code);

        if (result.Contains("Error") || result.Contains("Invalid"))
        {
            lbl_comment.Text = "Invalid or unrecognised activation code. Please check and try again, or contact Newline Technologies.";
            lbl_comment.CssClass = "lk-feedback--err";
        }
        else
        {
            lbl_comment.Text = result + " - Redirecting to login...";
            lbl_comment.CssClass = "lk-feedback--ok";

            // Redirect after 2 seconds so the user sees the success message
            ScriptManager.RegisterStartupScript(this, GetType(), "redir",
                "setTimeout(function(){ window.location.replace('/Default.aspx'); }, 2000);", true);
        }
    }
}
