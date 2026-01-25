using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_StockAdjustment : System.Web.UI.UserControl
{
    SettingsFile setting = new SettingsFile();
    inv_GetStockItemsToAdjustTableAdapter StockAjust = new inv_GetStockItemsToAdjustTableAdapter();

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdGenerate_Click(object sender, EventArgs e)
    {
        try
        {
            ds_sheetNo.Select();
            txtsheetNo.DataBind();

            if (txtsheetNo.Items.Count > 0)
            {
                img_pop.ImageUrl = setting.InfoImage("OK");
                lbl_pop.ForeColor = setting.InfoColor("OK");
                lbl_pop.Text = "Stock Genetation Completed!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "Campus Dynamics ERP";
                pop_mgs.ShowOnPageLoad = true;
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "No verified Stock Found!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "Campus Dynamics ERP";
                pop_mgs.ShowOnPageLoad = true;
            }
        }
        catch (Exception)
        {
        }
    }
    protected void cmdAdjust_Click(object sender, EventArgs e)
    {
        try
        {
            if (txtsheetNo.Value != null)
            {

                StockAjust.inv_StockAdjustment(int.Parse(txtsheetNo.Value.ToString()), Session["username"].ToString());
                img_pop.ImageUrl = setting.InfoImage("OK");
                lbl_pop.ForeColor = setting.InfoColor("OK");
                lbl_pop.Text = "Stock Adjustment Completed!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "Campus Dynamics ERP";
                pop_mgs.ShowOnPageLoad = true;

                txtsheetNo.Text = "";
                ds_sheetNo.Select();
                txtsheetNo.DataBind();
                ds_items.Select();
                gv_stock.DataBind();
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "No verified Stock Sheet Selected!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "Campus Dynamics ERP";
                pop_mgs.ShowOnPageLoad = true;
            }

        }
        catch (Exception ex)
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "An Error Occured: " + ex.Message;
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
}