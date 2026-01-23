using System;
using System.Web.UI;

public partial class COOPERP_NewScreens_SidebarMaster : System.Web.UI.MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Set footer text
        lbl_footer.Text = "© " + DateTime.Now.Year + " Campus Dynamics - Higher Education ERP";
        
        // Set brand link
        linkBrand.HRef = ResolveUrl("~/MyApplications.aspx");
    }
}
