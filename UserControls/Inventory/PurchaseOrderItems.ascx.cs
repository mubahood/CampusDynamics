using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_PurchaseOrderItems : System.Web.UI.UserControl
{
    inv_GetPurchaseOrderItemsTableAdapter poData = new inv_GetPurchaseOrderItemsTableAdapter();
    SettingsFile setting = new SettingsFile();
    int VATStat;
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        try
        {
            poData.inv_poItemsEntries(0, int.Parse(Session["PON"].ToString()), int.Parse(txtItemName.Value.ToString()), double.Parse(txtQty.Text),
                int.Parse(txtUnit.Value.ToString()), VATStat, "INSERT");
            DataBinder();
            ClearFields();
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
    void ClearFields()
    {
        txtItemName.Text = ""; txtQty.Text = ""; txtUnit.Text = ""; txtTaxStatus.Checked = false;
    }
    void DataBinder()
    {
        ds_poItems.Select();
        gv_poItems.DataBind();
    }
    protected void cmdClear_Click(object sender, EventArgs e)
    {
        ClearFields();
    }
    protected void cmdDelete_Click(object sender, EventArgs e)
    {
        try
        {
            Session["SN"] = gv_poItems.GetRowValues(gv_poItems.FocusedRowIndex, "S_no");
            Session["ICD"] = gv_poItems.GetRowValues(gv_poItems.FocusedRowIndex, "ItemCode");
            poData.inv_poItemsEntries(int.Parse(Session["SN"].ToString()), int.Parse(Session["PON"].ToString()), int.Parse(Session["ICD"].ToString()),
                0, 0, 0, "DELETE");
            DataBinder();
            ClearFields();
            img_pop.ImageUrl = setting.InfoImage("OK");
            lbl_pop.ForeColor = setting.InfoColor("OK");
            lbl_pop.Text = "Item SNo: " + Session["SN"].ToString() + " has been Deleted!";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
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
    protected void txtItemName_SelectedIndexChanged(object sender, EventArgs e)
    {
        ds_Units.Select();
        txtUnit.DataBind();
        txtUnit.SelectedIndex = 0;
    }
    protected void txtTaxStatus_CheckedChanged(object sender, EventArgs e)
    {

        if (txtTaxStatus.Checked == true)
        {
            VATStat = 1;
        }
        else
        {
            VATStat = 0;
        }

    }
}