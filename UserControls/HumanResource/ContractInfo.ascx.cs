using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_HumanResource_ContractInfo : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        gvContracts.DataBind();
        pop_sms.Width = 500;
        pop_sms.Height = 400;

    }
    protected void cmdAddNew_Click(object sender, EventArgs e)
    {
        gvContracts.AddNewRow();
    }
    protected void cmdJobsDepts_Click(object sender, EventArgs e)
    {
        pop_details.HeaderText = "Jobs & Departments";
        pop_details.ContentUrl = "~/COOPERP/HumanResource/PopUps.aspx?pid=2";
        pop_details.Width = 700;
        pop_details.Height = 500;
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdClearList_Click(object sender, EventArgs e)
    {

        Session["receipients"] = "-";
        Session["noReceipients"] = 0;
        panel_sms.HeaderStyle.ForeColor = System.Drawing.Color.Red;
        panel_sms.HeaderText = "List Cleared";

    }
    protected void cmdUpdateList_Click(object sender, EventArgs e)
    {
        if (Session["noReceipients"] == null) { Session["noReceipients"] = 0; }
        HRMDataTableAdapters.hrm_employeeTableAdapter emp = new HRMDataTableAdapters.hrm_employeeTableAdapter();
        int noRows = gvContracts.VisibleRowCount, counter = 0, intCurrReceipients = int.Parse(Session["noReceipients"].ToString());
        string comm = "Error! None Selected";
        for (int i = 0; i < noRows; i++)
        {
            if (gvContracts.Selection.IsRowSelected(i))
            {
                counter++;
                if (Session["receipients"] == "-")
                {
                    Session["receipients"] = string.Format("{0}", emp.GetPhone(int.Parse(gvContracts.GetRowValues(i, "empID").ToString())));
                }
                else
                {
                    Session["receipients"] = string.Format("{0},{1}", Session["receipients"], emp.GetPhone(int.Parse(gvContracts.GetRowValues(i, "empID").ToString())));
                }

                intCurrReceipients++;
                Session["noReceipients"] = intCurrReceipients;

                comm = string.Format("{0} New Added. Total={1}", counter, intCurrReceipients); 
            }
        }

        panel_sms.HeaderStyle.ForeColor = System.Drawing.Color.Red;
        panel_sms.HeaderText = comm;
        //lbl_smsComments.Text = comm;
    }

    protected void cmdPrintID_Click(object sender, EventArgs e)
    {
        pop_details.Width = 900;
        pop_details.Height = 500;
        pop_details.ContentUrl = "~/COOPERP/HumanResource/popups.aspx?pid=7";
        Session["Report"] = "STAFFID";
        Session["ID"] = gvContracts.GetRowValues(gvContracts.FocusedRowIndex, "ID");
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvContracts_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
}