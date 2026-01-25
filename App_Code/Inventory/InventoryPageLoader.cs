using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for InventoryPageLoader
/// </summary>
public class InventoryPageLoader
{
    string UserControlPath;
    public string PageLocator(int PageCode)
    {
        if (PageCode == 0)
        {
            UserControlPath = "../../UserControls/Inventory/Homescreen.ascx";
        }
        else if (PageCode == 1)
        {
            UserControlPath = "../../UserControls/Inventory/Units.ascx";
        }
        else if (PageCode == 2)
        {
            UserControlPath = "../../UserControls/Inventory/Groups.ascx";
        }
        else if (PageCode == 3)
        {
            UserControlPath = "../../UserControls/Inventory/StoresLocation.ascx";
        }
        else if (PageCode == 4)
        {
            UserControlPath = "../../UserControls/Inventory/SupplierInfo.ascx";
        }
        else if (PageCode == 5)
        {
            UserControlPath = "../../UserControls/Inventory/TaxInfo.ascx";
        }
        else if (PageCode == 6)
        {
            UserControlPath = "../../UserControls/Inventory/ItemsEntry.ascx";
        }
        else if (PageCode == 7)
        {
            UserControlPath = "../../UserControls/Inventory/StockCapture.ascx";
        }
        else if (PageCode == 8)
        {
            UserControlPath = "../../UserControls/Inventory/StockVerification.ascx";
        }
        else if (PageCode == 9)
        {
            UserControlPath = "../../UserControls/Inventory/StockAdjustment.ascx";
        }
        else if (PageCode == 10)
        {
            UserControlPath = "../../UserControls/Inventory/CurrentStockList.ascx";
        }
        else if (PageCode == 11)
        {
            UserControlPath = "../../UserControls/Inventory/StockWarning.ascx";
        }
        else if (PageCode == 12)
        {
            UserControlPath = "../../UserControls/Inventory/ManageItems.ascx";
        }
        else if (PageCode == 13)
        {
            UserControlPath = "../../UserControls/Inventory/StockDeductionLog.ascx";
        }
        else if (PageCode == 14)
        {
            UserControlPath = "../../UserControls/Inventory/PurchaseOrders.ascx";
        }
        else
        {
            UserControlPath = "../../UserControls/Inventory/DocumentCentre.ascx";
        }

        return UserControlPath;
    }
}