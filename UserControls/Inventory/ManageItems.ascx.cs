using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;
public partial class UserControls_Inventory_ManageItems : System.Web.UI.UserControl
{
    SettingsFile setting = new SettingsFile();
    inv_itemdetailsTableAdapter itemDetails = new inv_itemdetailsTableAdapter();
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    void sessionValues()
    {
        Session["ItemCode"] = gv_Items.GetRowValues(gv_Items.FocusedRowIndex, "ItemCode");
        Session["CostP"] = gv_Items.GetRowValues(gv_Items.FocusedRowIndex, "CostPrice");
    }
    protected void cmdUnits_Click(object sender, EventArgs e)
    {
       
    }
    void popButtonHide(bool act)
    {
        cmdContinue.Visible = act;
    }
    protected void cmdAddsupplier_Click(object sender, EventArgs e)
    {
        
    }
    protected void cmdDelete_Click(object sender, EventArgs e)
    {
        popButtonHide(true);
        sessionValues();
        img_pop.ImageUrl = setting.InfoImage("Error");
        lbl_pop.ForeColor = setting.InfoColor("Error");        
        lbl_pop.Text = "You are about to Delete an Item: Unit, Supplier and Inventory Info will be Deleted as Well!";
        pop_mgs.Width = 300;
        pop_mgs.Height = 100;
        pop_mgs.HeaderText = "Campus Dynamics ERP";
        pop_mgs.ShowOnPageLoad = true;

    }
    protected void cmdContinue_Click(object sender, EventArgs e)
    {
        try
        {
            
            itemDetails.inv_DeleteItem_Routine(int.Parse(Session["ItemCode"].ToString()));
            ds_items.Select();
            gv_Items.DataBind();
            popButtonHide(false);

            img_pop.ImageUrl = setting.InfoImage("OK");
            lbl_pop.ForeColor = setting.InfoColor("OK");
            lbl_pop.Text = "Item has been Deleted Successfully!";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "Item Delete Error! " + ex.Message;
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void cmdSuppliers_Click(object sender, ImageClickEventArgs e)
    {
        try
        {

            sessionValues();
            popButtonHide(false);
            if (Session["ItemCode"] != null)
            {
                Session["PopID"] = "2";
                pop_mgs.Width = 1000;
                pop_mgs.Height = 420;
                pop_mgs.HeaderText = "Suppliers of : " + gv_Items.GetRowValues(gv_Items.FocusedRowIndex, "ItemName");
                pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
                pop_mgs.ShowOnPageLoad = true;
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "Item not Identified!";
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
    protected void cmdUnits_Click1(object sender, ImageClickEventArgs e)
    {
        try
        {
            sessionValues();
            popButtonHide(false);
            if (Session["ItemCode"] != null)
            {
                Session["PopID"] = "1";
                pop_mgs.Width = 1000;
                pop_mgs.Height = 500;
                pop_mgs.HeaderText = "Units for : " + gv_Items.GetRowValues(gv_Items.FocusedRowIndex, "ItemName");
                pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
                pop_mgs.ShowOnPageLoad = true;
            }
            else
            {
                img_pop.ImageUrl = setting.InfoImage("Error");
                lbl_pop.ForeColor = setting.InfoColor("Error");
                lbl_pop.Text = "Item not Identified!";
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
    protected void gv_Items_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    protected void cmdNewItem_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/COOPERP/Inventory/Default.aspx?PGid=6");
    }
}