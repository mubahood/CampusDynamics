using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Accounts_DocumentCentre : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtMonth.DataSource = SettingsFile.ReturnMonths();
            txtYear.DataSource = SettingsFile.ReturnYears();
            txtMonth.DataBind();
            txtYear.DataBind();
            txtMonth.Text = SettingsFile.DefaultMonth();
            txtYear.Text = DateTime.Today.Year.ToString();
            if (DateTime.Today.Month < 8)
            {
                txtStartDate.Value = "08/01/" + DateTime.Today.AddYears(-1).Year;
            }
            else
            {
                txtStartDate.Value = "08/01/" + DateTime.Today.Year;
            }
            txtEndDate.Text = DateTime.Today.ToShortDateString();
        }

        pop_receipts.Width = 1000;
        pop_receipts.Height = 600;
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["Report"] = txtDocumentType.Value;
        Session["mnth"] = txtMonth.Text;
        Session["year"] = txtYear.Text;
        Session["startDate"] = txtStartDate.Text;
        Session["endDate"] = txtEndDate.Text;
        pop_receipts.ShowOnPageLoad = true;
        //Response.Redirect("~/COOPERP/XtraReports/Default.aspx");
    }
}