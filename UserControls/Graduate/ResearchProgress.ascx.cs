using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Graduate_ResearchProgress : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void ASPxButton1_Click(object sender, EventArgs e)
    {
        res_progessGV.AddNewRow();
    }
    protected void ASPxButton2_Click(object sender, EventArgs e)
    {
        Session["ReschID"] = res_progessGV.GetRowValues(res_progessGV.FocusedRowIndex, "id");
        Session["mark"] = res_progessGV.GetRowValues(res_progessGV.FocusedRowIndex, "marks");
        Session["regno"] = res_progessGV.GetRowValues(res_progessGV.FocusedRowIndex, "regno");
        ResProgressPopup.Width = 1000;
        ResProgressPopup.Height = 500;
        ResProgressPopup.ContentUrl = "~/COOPERP/Graduate/ReschProgressTracking.aspx";
        ResProgressPopup.ShowOnPageLoad = true;
    }
}