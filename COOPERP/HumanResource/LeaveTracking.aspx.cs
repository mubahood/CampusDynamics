using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_HumanResource_LeaveTracking : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        rp_leaverecords.HeaderText = Session["HeaderText"].ToString();
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        try
        {
            HRMDataTableAdapters.hrm_leave_takenTableAdapter LEAVE = new HRMDataTableAdapters.hrm_leave_takenTableAdapter();
            LEAVE.Insert(uint.Parse(Session["lid"].ToString()), DateTime.Today, DateTime.Today, 0);
            gvLeaveRecords.DataBind();
            lbl_msg.Text = "Leave Added";
        }
        catch (Exception) 
        {
            lbl_msg.Text = "Leave Added";
        }
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvLeaveRecords_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        DateTime sDate=DateTime.Parse(e.NewValues["startDate"].ToString());
        DateTime eDate=DateTime.Parse(e.NewValues["endDate"].ToString());
        int noDays = (eDate - sDate).Days;
        int Balance = int.Parse(Session["balance"].ToString());
        if (noDays > Balance)
        {
            throw new Exception("You can not Exceed 30 Days in a year!");
        }
    }
}