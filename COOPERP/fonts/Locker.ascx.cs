using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Systems.Settings.SD;

public partial class COOPERP_fonts_Locker : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Licensing.Settings();
        lbl_lock.Text = Licensing.LicenceComment;
        pop_newlicense.ShowOnPageLoad = true;
    }
    protected void cmdActivate_Click(object sender, EventArgs e)
    {

        Licensing LIC = new Licensing();
        string comm = LIC.UpdateLicense(txtLicenseCode.Text);
        lbl_comment.Text = comm;
        if (!comm.Contains("Invalid"))
        {
            cmdActivate.Text = "Login";
        }
        
    }
   
    protected void cmdEnterLicense_Click(object sender, EventArgs e)
    {
        if (cmdActivate.Text == "Login")
        {
            Response.Redirect("~/Default.aspx");
        }
        else
        {
            pop_newlicense.ShowOnPageLoad = true;
        }
    }
}