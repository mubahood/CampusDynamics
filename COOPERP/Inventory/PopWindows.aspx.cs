using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Inventory_PopWindows : System.Web.UI.Page
{
    int PageCode = 0;
    int CurrentStage;
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            PageCode = int.Parse(Session["PopID"].ToString());

        }
        catch (Exception)
        {
            PageCode = 0;
        }
        UserControl UC = LoadControls();
        rp_controls.Controls.Clear();
        rp_controls.Controls.Add(UC);
    }
    public UserControl LoadControls()
    {
        InventoryPopupLoader PLoader = new InventoryPopupLoader();
        UserControl ctl = Page.LoadControl(PLoader.PageLocator(PageCode)) as UserControl;
        return ctl;
    } 
    
}