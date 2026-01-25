using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CoopERPDataTableAdapters;
using DevExpress.XtraPrinting;

public partial class UserControls_Accounts_BudgetManager : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        try
        {
            if (txtCategory.Text != "ALL")
            {
                fin_budgetTableAdapter BUD = new fin_budgetTableAdapter();
                BUD.fin_CreateBudget(int.Parse(txtYear.Value.ToString()), txtCategory.Text);
                lbl_msg.Text = "Budget Updated";
            }
            else
            {
                lbl_msg.Text = "Error! Please Select Category";
            }
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error! "+ex.Message;
        }
        pop_messagebox.ShowOnPageLoad = true;
        gvBudget.DataBind();
    }
    protected void gvBudget_BatchUpdate(object sender, DevExpress.Web.Data.ASPxDataBatchUpdateEventArgs e)
    {
        lbl_msg.Text = "Changes Saved Successfully";
        pop_messagebox.ShowOnPageLoad = true;
    }
    protected void cmdExport_Click(object sender, EventArgs e)
    {
        gve_budget.WriteXlsxToResponse(txtYear.Text+" BUDEGET ", new XlsxExportOptions { ExportMode = XlsxExportMode.SingleFile });

    }
    
}