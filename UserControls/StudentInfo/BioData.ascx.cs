using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_StudentInfo_BioData : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
    protected void gvStudentBiodata_DataBound(object sender, EventArgs e)
    {
        Session["myProgname"] = gvStudentBiodata.GetRowValues(0, "progname");
    }
}