using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_Employee : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvEmployees.DataBind();
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvEmployees.AddNewRow();
    }
    protected void cmdProfile_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Width = 1000;
        pop_details.Height = 500;
        Session["empID"] = gvEmployees.GetRowValues(gvEmployees.FocusedRowIndex, "empID");
        pop_details.ContentUrl="~/COOPERP/HumanResource/StaffProfile.aspx";
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvEmployees_RowInserting(object sender, DevExpress.Web.Data.ASPxDataInsertingEventArgs e)
    {
        HRMDataTableAdapters.hrm_employeeTableAdapter HRM = new HRMDataTableAdapters.hrm_employeeTableAdapter();
        string nextNum;
        string stn = e.NewValues["Entry_Satation"].ToString();
        
        try
        {
            nextNum = HRM.NextStaffCode().ToString().PadLeft(4, '0');
            if (nextNum.Length == 0) nextNum = "0001";
        }
        catch (Exception) { nextNum = "0001"; }
        
        e.NewValues["EMP_CODE"] = string.Format("MRU{0}",nextNum);
        
    }
    protected void cmdStations_Click(object sender, EventArgs e)
    {
        pop_stations.ShowOnPageLoad = true;
    }
    
    protected void gvEmployees_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
    protected void gvEmployees_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void gvEmployees_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["Entry_Year"] = DateTime.Today.Year;
        e.NewValues["Entry_Satation"] = "MASAKA";
        e.NewValues["EmpType"] = "Academic";
        e.NewValues["referee_1"] = "-";
        e.NewValues["referee_2"] = "-";
        e.NewValues["current_residence"] = "UGANDA";
        e.NewValues["emp_nationality"] = "UGANDAN";
        e.NewValues["EMP_CODE"] = "AUTO";



    }
}