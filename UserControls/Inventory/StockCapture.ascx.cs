using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_StockCapture : System.Web.UI.UserControl
{
    inv_GetStockCaptureSheetitemsTableAdapter CaptureSheet = new inv_GetStockCaptureSheetitemsTableAdapter();
    inv_GetItemPrimaryUnitTableAdapter units = new inv_GetItemPrimaryUnitTableAdapter();
    SettingsFile setting = new SettingsFile();
    inv_GetStockItemsToAdjustTableAdapter StockAjust = new inv_GetStockItemsToAdjustTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {
        txtSheetDate.Date = DateTime.Now;
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        try
        {
            NewSheet();
            pop_mgs.ShowOnPageLoad = false;
        }
        catch (Exception)
        {
        }
    }
    void NewSheet()
    {
        CaptureSheet.inv_GetStockCaptureSheets(Session["username"].ToString());
        DataBinder();
    }
    void DataBinder()
    {
        ds_sheets.Select();
        gv_capturesheets.DataBind();
    }
    protected void cmdSubmit_Click(object sender, EventArgs e)
    {
        string sheetno = gv_capturesheets.GetRowValues(gv_capturesheets.FocusedRowIndex, "SheetNo").ToString(),
            status = gv_capturesheets.GetRowValues(gv_capturesheets.FocusedRowIndex, "SheetStatus").ToString();
        pop_mgs.ContentUrl = "";
        try
        {
            if (sheetno != null && status != "Adjusted")
            {

                StockAjust.inv_StockAdjustment(int.Parse(sheetno), Session["username"].ToString());
                img_pop.ImageUrl = setting.InfoImage("OK");
                lbl_pop.ForeColor = setting.InfoColor("OK");
                lbl_pop.Text = "Stock Adjustment Completed!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "Campus Dynamics ERP";
                pop_mgs.ShowOnPageLoad = true;
                gv_capturesheets.DataBind();
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
    protected void cmdAddItems_Click(object sender, EventArgs e)
    {
        Session["CapSheetNo"] = gv_capturesheets.GetRowValues(gv_capturesheets.FocusedRowIndex, "SheetNo");
        string stat = CaptureSheet.inv_GetStockSheetStatus(int.Parse(Session["CapSheetNo"].ToString())).ToString();
        Session["sheetstatus"] = stat;
        if (Session["CapSheetNo"] != null)
        {
            try
            {
                
                    Session["PopID"] = "5";
                    pop_mgs.Width = 1000;
                    pop_mgs.Height = 500;
                    pop_mgs.HeaderText = "..... Adding Items on Stock Capturing Sheet Number: " + Session["CapSheetNo"].ToString();
                    pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
                    pop_mgs.ShowOnPageLoad = true;
               
            }
            catch (Exception ex)
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "An error Occured!" + ex.Message;
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "School Dynamics Version 1.0";
                pop_mgs.ShowOnPageLoad = true;
            }
        }
        else
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "No Sheet Selected!";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "School Dynamics Version 1.0";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void imgDetails_Click(object sender, ImageClickEventArgs e)
    {
        Session["CapSheetNo"] = gv_capturesheets.GetRowValues(gv_capturesheets.FocusedRowIndex, "SheetNo");

        string stat = CaptureSheet.inv_GetStockSheetStatus(int.Parse(Session["CapSheetNo"].ToString())).ToString();
        Session["sheetstatus"] = stat;
        if (Session["CapSheetNo"] != null)
        {
            try
            {
                
                    Session["PopID"] = "5";
                    pop_mgs.Width = 1000;
                    pop_mgs.Height = 500;
                    pop_mgs.HeaderText = "..... Adding Items on Stock Capturing Sheet Number: " + Session["CapSheetNo"].ToString();
                    pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
                    pop_mgs.ShowOnPageLoad = true;
               
            }
            catch (Exception ex)
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "An error Occured!" + ex.Message;
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "School Dynamics Version 1.0";
                pop_mgs.ShowOnPageLoad = true;
            }
        }
        else
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "No Sheet Selected!";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics Version 1.0";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void gv_capturesheets_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
}