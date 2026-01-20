using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using DevExpress.Web;
using Systems.Settings.SD;

public partial class _Default : System.Web.UI.Page
{

    int PageCode;
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            PageCode = int.Parse(Request.QueryString["pid"].ToString());

        }
        catch (Exception)
        {
            PageCode = 0;
        }
        UserControl UC = LoadControls();
        rp_login.Controls.Clear();
        rp_login.Controls.Add(UC);
    }
    public UserControl LoadControls()
    {
        LoginLoader PLoader = new LoginLoader();
        UserControl ctl = Page.LoadControl(PLoader.PageLocator()) as UserControl;
        return ctl;
    }

}