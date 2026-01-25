using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_financials_api_fees_structure : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtAcademicYear.DataSource = CommonRoutines.ReturnYears();
            txtAcademicYear.DataBind();
            txtAcademicYear.Text = DateTime.Today.Year.ToString();

           
        }
    }
    protected void btn_payschedule_Click(object sender, EventArgs e)
    {
        pop_billitems.ContentUrl = "~/COOPERP/Financials/FeesPaySchedule.aspx";
        pop_billitems.Height = 600;
        pop_billitems.Width = 1000;
        Session["eyr"] = txtAcademicYear.Text;
        pop_billitems.ShowOnPageLoad = true;
    }
    protected void gvClass_DataBound(object sender, EventArgs e)
    {
        if (gvClass.VisibleRowCount == 0)
        {
            btn_payschedule.Enabled = false;
            cmdPrintStructure.Enabled = false;
        }
        else
        {
            btn_payschedule.Enabled = false;
            btn_payschedule.Enabled = false;
            cmdPrintStructure.Enabled = true;
           
        }
    }
    protected void gvClass_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}