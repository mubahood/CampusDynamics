using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_Deductions_Allowances : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_details.Width = 900;
        pop_details.Height = 600;

        gvDedAllowances.Columns["dedall_name"].Caption = txtType.Text;
        gvDedAllowances.DataBind();
    }
    protected void txtType_SelectedIndexChanged(object sender, EventArgs e)
    {
        gvDedAllowances.Columns["dedall_name"].Caption = txtType.Text;
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvDedAllowances.AddNewRow();
    }
    protected void gvDedAllowances_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["ded_allowance"] = txtType.Text.ToUpper();
    }
    protected void cmdStaffList_Click(object sender, ImageClickEventArgs e)
    {
        string type = gvDedAllowances.GetRowValues(gvDedAllowances.FocusedRowIndex, "dedall_type").ToString();
        if (type == "OPTIONAL")
        {
            pop_details.HeaderText = gvDedAllowances.GetRowValues(gvDedAllowances.FocusedRowIndex, "dedall_name").ToString() + " CURRENT STAFF LIST";
            pop_details.ContentUrl = "~/COOPERP/HumanResource/PopUps.aspx?pid=6";
            Session["dedAllID"] = gvDedAllowances.GetRowValues(gvDedAllowances.FocusedRowIndex, "ID");
            Session["default_amount"] = gvDedAllowances.GetRowValues(gvDedAllowances.FocusedRowIndex, "dedall_amount");
            pop_details.ShowOnPageLoad = true;
        }
    }
}