using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Systems.Settings.SD;

public partial class UserControls_Accounts_CashBook : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        pop_msgbox.HeaderText ="Campus Dynamics ERP";
        if (!IsPostBack)
        {
            if (DateTime.Today.Month > 7)
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }
            else
            {
                String DateString = string.Format("08-01-{0}", DateTime.Today.Year - 1); ;
                txtStartDate.Value = DateTime.Parse(DateString);
            }
          
            txtEndDate.Value = DateTime.Today;
        }
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 600;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/xtraReports/xtraReportCentre.aspx";
        Session["accno"] = txtPayee.Value == null ? string.Empty : txtPayee.Value.ToString();
        Session["startDate"] = txtStartDate.Text;
        Session["endDate"] = txtEndDate.Text;
        Session["Report"] = "Legder";
        Session["typ"] = "Chart Account";
        Session["disp_curr"] = "UGX";
        pop_msgbox.ShowOnPageLoad = true;
        gvLedger.DataBind();
    }
    protected void imgDetails_Click(object sender, ImageClickEventArgs e)
    {
        pop_msgbox.Width = 1000;
        pop_msgbox.Height = 400;
        pop_msgbox.ContentUrl = "~/COOPERP/accounts/TransactionDetails.aspx";
        Session["Vno"] = gvLedger.GetRowValues(gvLedger.FocusedRowIndex,"voucherno");
        pop_msgbox.ShowOnPageLoad = true;
    }
}
