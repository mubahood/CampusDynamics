using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_StudentLedgerCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {

            txtStartDate.Value = "01/01/" + DateTime.Today.AddYears(-1).Year;
            txtEndDate.Date = DateTime.Today;
        }
    }
    protected void cmdLedger_Click(object sender, ImageClickEventArgs e)
    {
        pop_details.Height = 500;
        pop_details.Width = 900;
        pop_details.ContentUrl = "~/COOPERP/Financials/StudentLedger.aspx";
        Session["regno"] = gvStudentList.GetRowValues(gvStudentList.FocusedRowIndex, "regno");
        Session["stud_names"] = gvStudentList.GetRowValues(gvStudentList.FocusedRowIndex, "stud_names");
        Session["sDate"] = txtStartDate.Date;
        Session["eDate"] = txtEndDate.Date;
        pop_details.ShowOnPageLoad = true;
    }
    protected void txtClass_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
    protected void txtYear_NumberChanged(object sender, EventArgs e)
    {
        
    }
    protected void cmdSearch_Click(object sender, EventArgs e)
    {
        gvStudentList.DataBind();
    }
    protected void gvStudentList_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}