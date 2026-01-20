using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Admissions_ApplicantDetails : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lblheader.Text = headercreator();
    }
    public string headercreator()
    {
        return string.Format("DETAILS FOR {0}[{1}]", Session["stud_name"], Session["stud_entry_no"]);
    }
}