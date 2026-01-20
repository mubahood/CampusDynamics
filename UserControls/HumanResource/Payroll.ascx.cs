using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_Payroll : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvPayroll.DataBind();
    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvPayroll.AddNewRow();
    }
    protected void cmdPayrollDetails_Click(object sender, EventArgs e)
    {
        pop_details.HeaderText = "Payroll Details";
        Session["pid"] = gvPayroll.GetRowValues(gvPayroll.FocusedRowIndex, "ID");
        pop_details.ContentUrl = "~/COOPERP/HumanResource/PopUps.aspx?pid=4";
        pop_details.Width = 1000;
        pop_details.Height = 600;
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvPayroll_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
}