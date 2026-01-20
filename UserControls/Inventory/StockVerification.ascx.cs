using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_StockVerification : System.Web.UI.UserControl
{
    SettingsFile setting = new SettingsFile();
    inv_GetStockCaptureSheetitemsTableAdapter verifying = new inv_GetStockCaptureSheetitemsTableAdapter();

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdPreview_Click(object sender, EventArgs e)
    {
        try
        {
            Session["Sht_No"] = gv_sheets.GetRowValues(gv_sheets.FocusedRowIndex, "SheetNo");
            if (Session["Sht_No"] != null)
            {
                Session["PopID"] = "4";
                pop_mgs.Width = 1000;
                pop_mgs.Height = 500;
                pop_mgs.HeaderText = "Items on Stock Capturing Sheet No: " + Session["Sht_No"].ToString();
                pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
                pop_mgs.ShowOnPageLoad = true;
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "Sheet Number not Identified!";
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
    protected void cmdVerify_Click(object sender, EventArgs e)
    {
        try
        {
            if (gv_sheets.VisibleRowCount > 0)
            {
                if (Session["username"] != null)
                {
                    Session["Sht_No"] = gv_sheets.GetRowValues(gv_sheets.FocusedRowIndex, "SheetNo");
                    verifying.inv_SubmitStockcaptureSheet(int.Parse(Session["Sht_No"].ToString()), "Verified", Session["username"].ToString(), "Confirmed");
                    img_pop.ImageUrl = setting.InfoImage("OK");
                    lbl_pop.ForeColor = setting.InfoColor("OK");
                    lbl_pop.Text = "Sheet Number: " + Session["Sht_No"].ToString() + " has been Verified!";
                    pop_mgs.Width = 300;
                    pop_mgs.Height = 100;
                    pop_mgs.HeaderText = "Campus Dynamics ERP";
                    pop_mgs.ShowOnPageLoad = true;
                    ds_sheets.Select();
                    gv_sheets.DataBind();
                }
                else
                {
                    Response.Redirect("~/Default.aspx");
                }
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "Sheet Number not Identified!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "School Dynamics Version 1.0";
                pop_mgs.ContentUrl = "";
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
            pop_mgs.ContentUrl = "";
            pop_mgs.HeaderText = "School Dynamics Version 1.0";
            pop_mgs.ShowOnPageLoad = true;
        }
    }


    protected void cmdRollback_Click(object sender, EventArgs e)
    {
        try
        {
            if (gv_sheets.VisibleRowCount > 0)
            {
                if (Session["username"] != null)
                {
                    Session["Sht_No"] = gv_sheets.GetRowValues(gv_sheets.FocusedRowIndex, "SheetNo");
                    verifying.inv_SubmitStockcaptureSheet(int.Parse(Session["Sht_No"].ToString()), "ROLLEDBACK", Session["username"].ToString(), "ROLLEDBACK");
                    img_pop.ImageUrl = setting.InfoImage("OK");
                    lbl_pop.ForeColor = setting.InfoColor("OK");
                    lbl_pop.Text = "Sheet Number: " + Session["Sht_No"].ToString() + " has been ROLLEDBACK!";
                    pop_mgs.Width = 300;
                    pop_mgs.Height = 100;
                    pop_mgs.ContentUrl = "";
                    pop_mgs.HeaderText = "School Dynamics Version 1.0";
                    pop_mgs.ShowOnPageLoad = true;
                    ds_sheets.Select();
                    gv_sheets.DataBind();
                }
                else
                {
                    Response.Redirect("~/Default.aspx");
                }
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "Sheet Number not Identified!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.ContentUrl = "";
                pop_mgs.HeaderText = "School Dynamics Version 1.0";
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
            pop_mgs.ContentUrl = "";
            pop_mgs.HeaderText = "School Dynamics Version 1.0";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
}