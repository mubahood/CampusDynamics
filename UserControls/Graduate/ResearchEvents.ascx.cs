using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Graduate_ResearchEvents : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void addNewResEvent_Click(object sender, EventArgs e)
    {
        res_eventGV.AddNewRow();
    }
    protected void btnEventDetails_Click(object sender, ImageClickEventArgs e)
    {
        EventsDetails.Width = 700;
        EventsDetails.Height = 400;
        Session["EDId"] = res_eventGV.GetRowValues(res_eventGV.FocusedRowIndex, "Id");
        EventsDetails.ContentUrl = "~/COOPERP/Graduate/EventDetails.aspx";
        EventsDetails.ShowOnPageLoad = true;
    }
}