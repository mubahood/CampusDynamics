using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Faculty_Faculty_Info : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvFacultyInfo.AddNewRow();
    }
}