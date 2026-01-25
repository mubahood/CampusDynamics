using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UserControls_Inventory_CurrentStockList : System.Web.UI.UserControl
{
    SettingsFile setting = new SettingsFile();
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void txtoption_SelectedIndexChanged(object sender, EventArgs e)
    {
        try
        {
            if (txtoption.Value.ToString() == "ALL")
            {
                txtItem.Text = "ALL";
                ds_stockList.Select();
                gv_currentStock.DataBind();

                lbl_label.Visible = false;
                txtItem.Visible = false;
                cmdSearch.Visible = false;
            }
            else if (txtoption.Value.ToString() == "SEARCH")
            {
                txtItem.Text = "";
                ds_stockList.Select();
                gv_currentStock.DataBind();
                txtItem.Visible = true;
                lbl_label.Visible = true;
                cmdSearch.Visible = true;
            }
            else
            {
                txtItem.Text = "";
                ds_stockList.Select();
                gv_currentStock.DataBind();
                lbl_label.Visible = false;
                txtItem.Visible = false;
                cmdSearch.Visible = false;
            }
        }
        catch (Exception)
        {
        }
    }
    protected void cmdSearch_Click(object sender, EventArgs e)
    {
        try
        {
            ds_stockList.Select();
            gv_currentStock.DataBind();
            if (gv_currentStock.VisibleRowCount > 0)
            {
                img_pop.ImageUrl = setting.InfoImage("OK");
                lbl_pop.ForeColor = setting.InfoColor("OK");
                lbl_pop.Text = "Search Completed: " + gv_currentStock.VisibleRowCount + " Record(s) Found!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "School Dynamics Version 1.0";
                pop_mgs.ShowOnPageLoad = true;
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "No Record Found!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "School Dynamics Version 1.0";
                pop_mgs.ShowOnPageLoad = true;
            }
        }
        catch (Exception)
        {
        }
    }

    protected void cmdDeduct_Click(object sender, EventArgs e)
    {
        try
        {
            Session["ICD"] = gv_currentStock.GetRowValues(gv_currentStock.FocusedRowIndex, "ItemCode");
            if (Session["ICD"] != null)
            {
                Session["PopID"] = "3";
                Session["INAME"] = gv_currentStock.GetRowValues(gv_currentStock.FocusedRowIndex, "ItemName");
                pop_mgs.Width = 600;
                pop_mgs.Height = 280;
                pop_mgs.HeaderText = "Stock Item Quantity Deduction for ItemCode:: " + Session["ICD"].ToString();
                pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
                pop_mgs.ShowOnPageLoad = true;
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "No Selected Item to Deduct Qty!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "School Dynamics Version 1.0";
                pop_mgs.ShowOnPageLoad = true;
            }

        }
        catch (Exception ex)
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "An error Occured! " + ex.Message;
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.ContentUrl = "";
            pop_mgs.HeaderText = "School Dynamics Version 1.0";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void cmdRefresh_Click(object sender, EventArgs e)
    {
        try
        {
            ds_stockList.Select();
            gv_currentStock.DataBind();

            img_pop.ImageUrl = setting.InfoImage("OK");
            lbl_pop.ForeColor = setting.InfoColor("OK");
            lbl_pop.Text = "Refresh Completed Successfully!";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.ContentUrl = "";
            pop_mgs.HeaderText = "School Dynamics Version 1.0";
            pop_mgs.ShowOnPageLoad = true;
        }
        catch (Exception)
        {
        }
    }
    protected void cmdCheckunit_Click(object sender, EventArgs e)
    {
        try
        {
            Session["ItemC"] = gv_currentStock.GetRowValues(gv_currentStock.FocusedRowIndex, "ItemCode");
            if (Session["ItemC"] != null)
            {
                Session["PopID"] = "6";
                pop_mgs.Width = 1000;
                pop_mgs.Height = 350;
                pop_mgs.HeaderText = "Current Stock List By Units for ItemCode: " + Session["ItemC"].ToString();
                pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
                pop_mgs.ShowOnPageLoad = true;
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "Item not Selected!";
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
            lbl_pop.Text = "An error Occured! " + ex.Message;
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.ContentUrl = "";
            pop_mgs.HeaderText = "School Dynamics Version 1.0";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void gv_currentStock_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
}