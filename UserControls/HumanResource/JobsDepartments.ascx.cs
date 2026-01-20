using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_JobsDepartments : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvJobs.DataBind();
        gvDepartments.DataBind();
        gvBanks.DataBind();
        gvScales.DataBind();
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvJobs.AddNewRow();
    }
    protected void cmdAddNewDept_Click(object sender, EventArgs e)
    {
        gvDepartments.AddNewRow();
    }
    protected void cmdAddNewBank_Click(object sender, EventArgs e)
    {
        gvBanks.AddNewRow();
    }
    protected void cmdAddNewScale_Click(object sender, EventArgs e)
    {
        gvScales.AddNewRow();
    }
}