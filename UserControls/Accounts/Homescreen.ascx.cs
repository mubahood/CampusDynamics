using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using PageLoader;

public partial class UserControls_FrontOffice_Homescreen : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        imgHomeImage.ImageUrl = HomePageMan.HomeImage("Accounts");
        lbl_functionalities.Text = HomePageMan.HomeText("Accounts");

    }
}