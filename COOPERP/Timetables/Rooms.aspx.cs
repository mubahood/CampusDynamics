using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Timetables_Rooms : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        if (int.Parse(txtCampus.Value.ToString()) != 0)
            gvRooms.AddNewRow();
        else
        {
            lbl_msg.Text = "Please Select a Campus";
            pop_msgBox.ShowOnPageLoad = true;
        }
    }
    protected void gvRooms_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["campusId"] = txtCampus.Value;
    }
}