using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_TeacherMgt_teachermgt : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvEmployees.DataBind();
        if (!IsPostBack)
        {
            Session["EmpNo"] = gvEmployees.GetRowValues(0, "empID");
            Session["EmpName"] = gvEmployees.GetRowValues(0, "emp_name");
        }
        pop_staffdetails.ContentUrl = "~/COOPERP/Academic Staff Management/StaffDetails.aspx";
        pop_staffdetails.Height = 600;
        pop_staffdetails.Width = 1000;
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvEmployees.AddNewRow();
    }
    protected void gvEmployees_FocusedRowChanged(object sender, EventArgs e)
    {
        Session["EmpNo"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "empID");
        Session["EmpName"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "emp_name");
    }
    protected void cmdAllocations_Click(object sender, ImageClickEventArgs e)
    {
        Session["EmpCode"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "usernames");
        Session["EmpNo"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "empID");
        Session["EmpName"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "emp_name");

        pop_staffdetails.ContentUrl = "~/COOPERP/Academic Staff Management/StaffDetails.aspx";
        pop_staffdetails.ShowOnPageLoad = true;
    }
    protected void cmdProfile_Click(object sender, ImageClickEventArgs e)
    {
        /*pop_staffdetails.Width = 1000;
        pop_staffdetails.Height = 500;
        Session["empID"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "empID");
        pop_staffdetails.ContentUrl = "~/COOPERP/HumanResource/StaffProfile.aspx";
        pop_staffdetails.ShowOnPageLoad = true;*/
        Session["EmpCode"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "usernames");
        Session["EmpNo"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "empID");
        Session["EmpName"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "emp_name");
        Session["Cat"] = "Academics";

        pop_staffdetails.ContentUrl = "~/COOPERP/Academic Staff Management/StaffDetails.aspx";
        pop_staffdetails.ShowOnPageLoad = true;
    }
    protected void gvEmployees_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
       HRMDataTableAdapters.hrm_employeeTableAdapter HRM = new HRMDataTableAdapters.hrm_employeeTableAdapter();
        string nextNum;
        string stn = e.NewValues["Entry_Satation"].ToString();

        try
        {
            nextNum = HRM.NextStaffCode(stn.Substring(0, 3)).ToString().PadLeft(3, '0');
            if (nextNum.Length == 0) nextNum = "001";
        }
        catch (Exception) { nextNum = "001"; }

        e.NewValues["EMP_CODE"] = string.Format("VCN-{2}-{0}",
           nextNum, stn.Substring(0, 3), e.NewValues["Entry_Year"].ToString().Substring(2, 2));

    }
    protected void gvEmployees_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["Entry_Satation"] = "VIENNA COLLEGE";
    }
}