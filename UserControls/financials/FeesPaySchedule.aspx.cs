using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_financials_FeesPaySchedule : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        try
        {
            StudentAccountingDataTableAdapters.fin_fees_pay_scheduleTableAdapter SCHED = new StudentAccountingDataTableAdapters.fin_fees_pay_scheduleTableAdapter();
            SCHED.fin_AddFeesScheduleItems(int.Parse(txtItem.Value.ToString()), int.Parse(txtYear.Text), int.Parse(txtSemester.Text), txtStyle.Text, Session["prog"].ToString(),
                Session["sess"].ToString(), int.Parse(Session["eyr"].ToString()));
            lbl_msg.Text = "Item Added Successfully";
            gvFeesSchedule.DataBind();

        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error! ["+ex.Message+"]";
        }
        pop_messagebox.ShowOnPageLoad = true;

    }
    protected void gvFeesSchedule_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdPrintSchedule_Click(object sender, EventArgs e)
    {

    }
}