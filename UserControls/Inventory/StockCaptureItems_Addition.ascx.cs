using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_StockCaptureItems_Addition : System.Web.UI.UserControl
{
    inv_GetStockCaptureSheetitemsTableAdapter CaptureSheet = new inv_GetStockCaptureSheetitemsTableAdapter();
    inv_GetItemPrimaryUnitTableAdapter units = new inv_GetItemPrimaryUnitTableAdapter();
    SettingsFile setting = new SettingsFile();
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["sheetstatus"].ToString() == "Adjusted")
        {
            cmdAdd.Enabled = false;
            cmdDelete.Enabled = false; 
        }
        DataBinder();
    }    
    void DataBinder()
    {
        ds_sheetitems.Select();
        gv_sheetitems.DataBind();
    }
    void ClearFields()
    {
        txtItemName.Text = ""; txtlocation.Text = ""; txtQty.Text = ""; txtUnit.Text = "";
    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        try
        {
            CaptureSheet.inv_stockcaptureEntries(int.Parse(txtItemName.Value.ToString()), int.Parse(txtUnit.Value.ToString()), int.Parse(txtQty.Text),
            int.Parse(txtlocation.Value.ToString()), int.Parse(Session["CapSheetNo"].ToString()));

            DataBinder();
            ClearFields();
        }
        catch (Exception)
        {
        }
    }
    protected void cmdClear_Click(object sender, EventArgs e)
    {
        ClearFields();
    }
    protected void txtItemName_SelectedIndexChanged(object sender, EventArgs e)
    {
        ds_Units.Select();
        txtUnit.DataBind();
        txtUnit.SelectedIndex = 0;
    }   
    protected void cmdDelete_Click(object sender, EventArgs e)
    {
        try
        {
            int noRows = gv_sheetitems.VisibleRowCount;
            for (int i = 0; i < noRows; i++)
            {
                if (gv_sheetitems.Selection.IsRowSelected(i) == true)
                {

                    string snumber = gv_sheetitems.GetRowValues(i, "SNO").ToString();
                    CaptureSheet.inv_DeleteSheetItem(int.Parse(snumber));
                    ds_sheetitems.Select();
                    gv_sheetitems.DataBind();

                   
                    img_pop.ImageUrl = setting.InfoImage("OK");
                    lbl_pop.ForeColor = setting.InfoColor("OK");
                    lbl_pop.Text = "Item SNo: " + snumber + " has been Deleted!";
                    pop_mgs.Width = 300;
                    pop_mgs.Height = 100;
                    pop_mgs.HeaderText = "Campus Dynamics ERP";
                    pop_mgs.ShowOnPageLoad = true;
                }
                else
                {
                }
            }
        }
        catch (Exception ex)
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "An Error Occured! " + ex.Message;
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void gv_sheetitems_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
}