using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_ItemsUnits : System.Web.UI.UserControl
{
    inv_itemdetailsTableAdapter itemDetails = new inv_itemdetailsTableAdapter();
    inv_itemunitdetailsTableAdapter ItemUnits = new inv_itemunitdetailsTableAdapter();
    SettingsFile setting = new SettingsFile();

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAddUnit_Click(object sender, EventArgs e)
    {
        if (txtUnit_ucode.Value != null)
        {
            try
            {
                ItemUnits.inv_itemUnitsEntry(int.Parse(Session["ItemCode"].ToString()), int.Parse(txtUnit_ucode.Value.ToString()), double.Parse(txtUnit_Costprice.Text),
                    double.Parse(txtUnit_SellingPrice.Text), int.Parse(txtUnit_mainQty.Text), int.Parse(txtUnit_alternateQty.Text), int.Parse(txtUnit_conversionQty.Text),
                    txtUnit_barcode1.Text, txtUnit_barcode2.Text, txtUnit_Barcode3.Text);
                ds_unitsList.Select();
                gv_Itemunits.DataBind();
                UnitItemsClear();

                ds_unitcodes.Select();
                txtUnit_ucode.DataBind();
            }
            catch (Exception)
            {
            }
        }
        else
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "Select Unit Code";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    void UnitItemsClear()
    {
        txtUnit_ucode.Text = ""; txtUnit_SellingPrice.Text = ""; txtUnit_mainQty.Text = ""; txtUnit_Costprice.Text = ""; txtUnit_conversionQty.Text = "";
        txtUnit_Barcode3.Text = ""; txtUnit_barcode2.Text = ""; txtUnit_barcode1.Text = ""; txtUnit_alternateQty.Text = "";
    }
    protected void cmdClear_Click(object sender, EventArgs e)
    {
        UnitItemsClear();
    }
    protected void cmdDelete_Click(object sender, EventArgs e)
    {
        try
        {
            int noRows = gv_Itemunits.VisibleRowCount;
            for (int i = 0; i < noRows; i++)
            {
                if (gv_Itemunits.Selection.IsRowSelected(i) == true)
                {

                    string ICODE = gv_Itemunits.GetRowValues(i, "ItemCode").ToString();
                    string UCODE = gv_Itemunits.GetRowValues(i, "UnitCode").ToString();
                    ItemUnits.inv_DeleteunitItems(int.Parse(ICODE), int.Parse(UCODE));
                    ds_unitsList.Select();
                    gv_Itemunits.DataBind();
                    ds_unitcodes.Select();
                    txtUnit_ucode.DataBind();
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
    protected void txtUnit_mainQty_TextChanged(object sender, EventArgs e)
    {
        unitConversion();
    }
    protected void txtUnit_alternateQty_TextChanged(object sender, EventArgs e)
    {
        unitConversion();
    }
    void unitConversion()
    {
        try
        {
            float conv = float.Parse(txtUnit_mainQty.Text) / float.Parse(txtUnit_alternateQty.Text);
            txtUnit_conversionQty.Text = conv.ToString();
            txtUnit_Costprice.Text = (conv * float.Parse(Session["CostP"].ToString())).ToString();
        }
        catch (Exception)
        {
        }
    }
}