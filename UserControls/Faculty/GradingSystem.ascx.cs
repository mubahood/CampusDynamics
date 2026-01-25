using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Faculty_GradingSystem : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {

    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {
        Session["HeaderText"] = string.Format("GRADING & AWARD DETAILS OF {0}",gvCourseInfo.GetRowValues(gvCourseInfo.FocusedRowIndex, "gs_name"));
        Session["gsid"] = gvCourseInfo.GetRowValues(gvCourseInfo.FocusedRowIndex,"ID");
        pop_messagebox.ContentUrl = "~/COOPERP/Faculty/GradingSysDetails.aspx";
        pop_messagebox.Width = 800;
        pop_messagebox.Height = 500;
        pop_messagebox.ShowOnPageLoad = true;
    }
}