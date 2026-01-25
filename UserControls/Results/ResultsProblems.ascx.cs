using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Results_ResultsProblems : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        lbl_header.Text = string.Format("RESULTS PROBLEMS FOR {0} [{1}]", Session["stud_name"], Session["reg"]);
    }

    protected void gvResultsInfo_DataBound(object sender, EventArgs e)
    {
        lbl_header.Text = string.Format("RESULTS PROBLEMS FOR {0} [{1}]", Session["stud_name"], Session["reg"]);
    }
}