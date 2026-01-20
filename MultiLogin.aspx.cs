using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MultiLogin : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lbl_lock.Text = "SECURITY WARNING!!!\n\n\n Another Login Session Was Detected. \nLogin Again to Proceed";
        pop_newlicense.ShowOnPageLoad = true;
        
    }
}