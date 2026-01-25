using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_StockDeduction : System.Web.UI.UserControl
{
    inv_GetStockItemsToAdjustTableAdapter Deductstock = new inv_GetStockItemsToAdjustTableAdapter();
    SettingsFile setting = new SettingsFile();
    protected void Page_Load(object sender, EventArgs e)
    {
        lblItemName.Text = Session["INAME"].ToString();
        //txtDeductionUnit.SelectedIndex = 0;
        cmdRollback.Enabled = false;
    }
    void LockControls()
    {
        cmdSubmit.Enabled = false;
        txtreason.Enabled = false;
        txtDeductionUnit.Enabled = false;
        txtDeductionQty.Enabled = false;
    }
    protected void cmdSubmit_Click(object sender, EventArgs e)
    {
        try
        {
            string Actions = "Deduct";
            Deductstock.inv_stockDeductionEntries(Actions, int.Parse(Session["ICD"].ToString()), int.Parse(txtDeductionUnit.Value.ToString()),
                long.Parse(txtDeductionQty.Text), txtreason.Text, Session["username"].ToString());
            LockControls();
            cmdRollback.Enabled = true;
            img_pop.ImageUrl = setting.InfoImage("OK");
            lbl_pop.ForeColor = setting.InfoColor("OK");
            lbl_pop.Text = "Qty Deduction Completed!";
            pop_mgs.Width = 200;
            pop_mgs.Height = 80;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "An error occured" + ex.Message;
            pop_mgs.Width = 200;
            pop_mgs.Height = 80;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void cmdRollback_Click(object sender, EventArgs e)
    {
        try
        {
            string Actions = "RollBack";
            Deductstock.inv_stockDeductionEntries(Actions, int.Parse(Session["ICD"].ToString()), int.Parse(txtDeductionUnit.Value.ToString()),
                long.Parse(txtDeductionQty.Text), txtreason.Text, Session["username"].ToString());
            LockControls();

            img_pop.ImageUrl = setting.InfoImage("OK");
            lbl_pop.ForeColor = setting.InfoColor("OK");
            lbl_pop.Text = "Qty Deduction RolledBack!";
            pop_mgs.Width = 200;
            pop_mgs.Height = 80;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "An error occured" + ex.Message;
            pop_mgs.Width = 200;
            pop_mgs.Height = 80;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
}