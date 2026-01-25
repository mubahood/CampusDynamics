using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HRMDataTableAdapters;

public partial class UserControls_HumanResource_DedAllowanceList : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvStaffList.DataBind();
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        try
        {
            hrm_ded_allowance_stafflistTableAdapter LIST = new hrm_ded_allowance_stafflistTableAdapter();
            if (txtAllStaff.Checked == true)
            {
                LIST.AddAllStaffOnDedAllowance(int.Parse(Session["dedAllID"].ToString()));
            }
            else
            {
                LIST.Insert(uint.Parse(Session["dedAllID"].ToString()), 0, double.Parse(Session["default_amount"].ToString()));
            }
            gvStaffList.DataBind();
            lbl_msg.ForeColor = System.Drawing.Color.Blue;
            lbl_msg.Text = "Blank Staff Added. Edit and save Updates.";
        }
        catch (Exception) 
        {
            lbl_msg.ForeColor = System.Drawing.Color.Red;
            lbl_msg.Text = "Error! Edit Blank Staff First";
        }
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvStaffList_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["ded_allID"] = Session["dedAllID"];
    }
}