using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Security_RolesInApps : System.Web.UI.UserControl
{
    SecurityTableAdapters.my_aspnet_roles_in_appsTableAdapter roleApps = new SecurityTableAdapters.my_aspnet_roles_in_appsTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        roleApps.Insert(uint.Parse(txtApplications.Value.ToString()), txtRoles.Value.ToString());
        gvRoles.DataBind();
    }
    protected void cmdRemove_Click(object sender, EventArgs e)
    {
        roleApps.Delete(uint.Parse(txtApplications.Value.ToString()), txtRoles.Value.ToString());
        gvRoles.DataBind();
    }
}