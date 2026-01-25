using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_ItemsEntry : System.Web.UI.UserControl
{

    inv_itemdetailsTableAdapter itemDetails = new inv_itemdetailsTableAdapter();
    inv_itemunitdetailsTableAdapter ItemUnits = new inv_itemunitdetailsTableAdapter();
    SettingsFile setting = new SettingsFile();

    protected void Page_Load(object sender, EventArgs e)
    {
        lbl_itemcount.Text = "Active Items Count: " + itemDetails.inv_GetActiveItems().ToString();        
    }
    protected void txtgroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtLasticode.Text = itemDetails.inv_GetLastItemCode(int.Parse(txtgroup.Value.ToString())).ToString();
    }   
    void ClearFields()
    {
        txtiname.Text = ""; txtshortname.Text = ""; txtunit.Text = ""; txtgroup.Text = ""; lbl_item.Text = "";
        txtqty.Text = ""; txttax.Text = ""; txtcostprice.Text = ""; txtsellingprice.Text = "";
        txtdesc.Text = ""; txtbarcode1.Text = ""; txtbarcode2.Text = ""; txtbarcode3.Text = "";
        txtLasticode.Text = ""; txticode.Text = ""; txticode.NullText = "AUTO GENERATED";
        Session["ItemCode"] = null; txtgroup.Enabled = true;
       
    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        ClearFields();
    }
    protected void cmdSave_Click(object sender, EventArgs e)
    {
        if (txtgroup.Value != null)
        {
            try
            {
                int itemCode = int.Parse(txtLasticode.Text) + 1;
                txticode.Text = "";
                txticode.Text = itemCode.ToString();
                txtgroup.Enabled = false;
                lbl_item.Text = itemCode.ToString();

                itemDetails.inv_itemsDetailsEntry(itemCode, txtiname.Text, txtshortname.Text, int.Parse(txtunit.Value.ToString()), int.Parse(txtgroup.Value.ToString()),
                    int.Parse(txtqty.Text), int.Parse(txttax.Value.ToString()), double.Parse(txtcostprice.Text), double.Parse(txtsellingprice.Text),
                    int.Parse(txtreorderlevel.Text),int.Parse(txtreorderQty.Text), txtdesc.Text, txtbarcode1.Text, txtbarcode2.Text, txtbarcode3.Text);

                Session["ItemCode"] = lbl_item.Text;
                
                img_pop.ImageUrl = setting.InfoImage("OK");
                lbl_pop.ForeColor = setting.InfoColor("OK");
                lbl_pop.Text = "ItemCode:(" + itemCode + ")" + " has been Created!";
                pop_mgs.Width = 300;
                pop_mgs.Height = 100;
                pop_mgs.HeaderText = "Campus Dynamics ERP";
                pop_mgs.ShowOnPageLoad = true;
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
        else
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "Select Item Group";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }


    protected void cmdUnits_Click(object sender, EventArgs e)
    {
        if (Session["ItemCode"] != null)
        {
            Session["CostP"] = txtcostprice.Text;
            Session["PopID"] = "1";
            pop_mgs.Width = 1000;
            pop_mgs.Height = 500;
            pop_mgs.HeaderText = "Item Units for ItemCode: " + lbl_item.Text;
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
    protected void cmdAddsupplier_Click(object sender, EventArgs e)
    {
        if (Session["ItemCode"] != null)
        {
            Session["PopID"] = "2";
            pop_mgs.Width = 1000;
            pop_mgs.Height = 420;
            pop_mgs.HeaderText = "Item Units for ItemCode: " + lbl_item.Text;
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
}