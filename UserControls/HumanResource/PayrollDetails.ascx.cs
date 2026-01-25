using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_PayrollDetails : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtSchool.SelectedIndex = 0;
        }
        gvPayrollList.DataBind();

    }
    protected void cmdRefreshPayroll_Click(object sender, EventArgs e)
    {
        gvPayrollList.DataBind();
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_details.Width=900;
        pop_details.Height=500;
        pop_details.ContentUrl="~/COOPERP/HumanResource/Reports/xtraReportCentre.aspx";
        Session["Report"] = "Payroll";
        Session["branch"] = txtSchool.Value;
        pop_details.ShowOnPageLoad = true;
    }
    protected void txtSchool_DataBound(object sender, EventArgs e)
    {
        gvPayrollList.DataBind();
    }
    protected void gvPayrollList_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
    protected void cmdSpecialPrint_Click(object sender, EventArgs e)
    {
        pop_details.Width = 900;
        pop_details.Height = 500;
        pop_details.ContentUrl = "~/COOPERP/HumanResource/Reports/xtraReportCentre.aspx";
        Session["Report"] = "SpecialPayroll";
        Session["branch"] = txtSchool.Value;
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdRefreshSpecialPayroll_Click(object sender, EventArgs e)
    {
        HRMDataTableAdapters.hrm_special_paymentsTableAdapter SPEC = new HRMDataTableAdapters.hrm_special_paymentsTableAdapter();
        SPEC.hrm_CreateSpecialPayList(int.Parse(Session["pid"].ToString()));
        gvSpecialPayrollList.DataBind();
    }
    protected void gvSpecialPayrollList_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        string type = e.OldValues["pay_type"].ToString();
        double hrs = double.Parse(e.NewValues["hours"].ToString());
        double payrate = double.Parse(e.NewValues["pay_rate"].ToString());
        double deductions = double.Parse(e.NewValues["deductions"].ToString());
        e.NewValues["gross_pay"] = hrs * payrate;
        e.NewValues["net_pay"] = hrs * payrate - deductions;
    }
    protected void cmdDeleteBlanks_Click(object sender, EventArgs e)
    {
        HRMDataTableAdapters.hrm_special_paymentsTableAdapter SPEC = new HRMDataTableAdapters.hrm_special_paymentsTableAdapter();
        SPEC.DeleteBlanks(int.Parse(Session["pid"].ToString()));
        gvSpecialPayrollList.DataBind();
    }
}