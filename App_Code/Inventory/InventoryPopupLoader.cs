using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for InventoryPopupLoader
/// </summary>
public class InventoryPopupLoader
{
    string UserControlPath;
    public string PageLocator(int PageCode)
    {
        if (PageCode == 0)
        {
            UserControlPath = "../../UserControls/Inventory/HomeScreen.ascx";
        }
        else if (PageCode == 1)
        {
            UserControlPath = "../../UserControls/Inventory/ItemsUnits.ascx";
        }
        else if (PageCode == 2)
        {
            UserControlPath = "../../UserControls/Inventory/ItemSuppliers.ascx";
        }
        else if (PageCode == 3)
        {
            UserControlPath = "../../UserControls/Inventory/StockDeduction.ascx";
        }
        else if (PageCode == 4)
        {
            UserControlPath = "../../UserControls/Inventory/ItemsOnStockSheet.ascx";
        }
        else if (PageCode == 5)
        {
            UserControlPath = "../../UserControls/Inventory/StockCaptureItems_Addition.ascx";
        }
        else if (PageCode == 6)
        {
            UserControlPath = "../../UserControls/Inventory/StockViewByUnit.ascx";
        }
        else if (PageCode == 7)
        {
            UserControlPath = "../../UserControls/Inventory/PurchaseOrderItems.ascx";
        }
        else
        {
            UserControlPath = "../../UserControls/Inventory/HomeScreen.ascx";
        }

        return UserControlPath;
    }
}