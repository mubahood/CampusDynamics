using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Graduate_EventDetails : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void btn_newDay_Click(object sender, EventArgs e)
    {
        eventDayGV.AddNewRow();
    }

    protected void new_stdbyDay_Click(object sender, EventArgs e)
    {
        stdbyDay_GV.AddNewRow();
    }
    protected void stdbyDay_GV_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        //e.NewValues["eid"] = Session["EDId"];
        
    }
}