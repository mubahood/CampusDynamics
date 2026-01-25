using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_ItemSuppliers : System.Web.UI.UserControl
{
    inv_supplierwithitemsTableAdapter supplierD = new inv_supplierwithitemsTableAdapter();

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        try
        {
            supplierD.inv_supplierwithItemsEntries(int.Parse(txtsupplier.Value.ToString()), int.Parse(Session["ItemCode"].ToString()),
                int.Parse(txtUnits.Value.ToString()), double.Parse(txtCostPrice.Text));
            ds_SupplierList.Select();
            gv_supplier.DataBind();
        }
        catch (Exception ex)
        {
        }
    }
}