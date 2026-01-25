using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Systems.Settings.SD;

public partial class COOPERP_accounts_AccountingCenter : System.Web.UI.Page
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
        rp_accounting.Controls.Clear();
        rp_accounting.Controls.Add(UC);
    }
    public UserControl LoadControls()
    {
        AccountingPageLoader PLoader = new AccountingPageLoader();
        UserControl ctl = Page.LoadControl(PLoader.PageLocator(PageCode)) as UserControl;
        return ctl;
    }
}