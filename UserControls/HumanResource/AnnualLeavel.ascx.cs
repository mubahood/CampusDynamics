using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_AnnualLeavel : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtYear.DataSource = CommonRoutines.ReturnYears();
            txtYear.DataBind();
            txtYear.Text = DateTime.Today.Year.ToString();

        }
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        pop_details.Width = 300;
        pop_details.Height = 150;
        HRMDataTableAdapters.hrm_annual_leaveTableAdapter LEAVE = new HRMDataTableAdapters.hrm_annual_leaveTableAdapter();
        LEAVE.hrm_CreateAnnualLeaveList(int.Parse(txtYear.Text), int.Parse(txtLeaveDays.Text));
        gvContracts.DataBind();
        lbl_msg.Text = "List Refreshed Successfully!";
        pop_details.HeaderText = "Hotel Dynamics Version 2.0";
        pop_details.ContentUrl = "";
        pop_details.ShowOnPageLoad = true;


    }
    protected void cmdTrack_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.ContentUrl = "~/COOPERP/HumanResource/LeaveTracking.aspx";
        pop_details.Width = 900;
        pop_details.Height = 600;
        Session["lid"] = gvContracts.GetRowValues(gvContracts.FocusedRowIndex, "ID");
        Session["HeaderText"] = "LEAVE RECORDS FOR "+gvContracts.GetRowValues(gvContracts.FocusedRowIndex, "emp_name")+" :: "+txtYear.Text;
        Session["balance"] = gvContracts.GetRowValues(gvContracts.FocusedRowIndex, "balance");
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvContracts_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}