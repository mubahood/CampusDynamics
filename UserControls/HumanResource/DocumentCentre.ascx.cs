using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_DocumentCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_details.Width = 900;
        pop_details.Height = 500;
        pop_details.ContentUrl = "~/COOPERP/HumanResource/popups.aspx?pid=7";
        Session["Report"] = txtDoc.Value.ToString();
        pop_details.ShowOnPageLoad = true;
    }
}