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
        string AppName = Request.QueryString["AppName"];
        imgHomeImage.ImageUrl = HomePageMan.HomeImage(AppName);
        lbl_functionalities.Text = HomePageMan.HomeText(AppName);
        lbl_header.Text = HomePageMan.HeaderText(AppName);
        panel_header.HeaderText = HomePageMan.Panel_Header(AppName);
        panel_header.HeaderImage.Url = HomePageMan.homePanelImage(AppName);

    }
}