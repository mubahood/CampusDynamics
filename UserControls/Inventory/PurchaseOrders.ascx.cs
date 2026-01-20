using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Web;
using System.IO;
using InventoryDataTableAdapters;

public partial class UserControls_Inventory_PurchaseOrders : System.Web.UI.UserControl
{
    ControlDefiners cont = new ControlDefiners();
    inv_GetPurchaseOrdersByDateTableAdapter newOrder = new inv_GetPurchaseOrdersByDateTableAdapter();
    SettingsFile setting = new SettingsFile();

    protected void Page_Load(object sender, EventArgs e)
    {
        txtRunDate.Date = DateTime.Now;

    }
    protected void cmdNew_Click(object sender, EventArgs e)
    {
        gv_purchaseorders.AddNewRow();
    }
    protected void cmdSave_Click(object sender, EventArgs e)
    {
        SavePurchaseOrderData();
    }
    protected void cmdCancel_Click(object sender, EventArgs e)
    {
        gv_purchaseorders.CancelEdit();
    }

    public void SavePurchaseOrderData()
    {
        try
        {
            ASPxTextBox txtPON = cont.EditASPXTextBoxDefiner("txtPON", gv_purchaseorders);
            ASPxDateEdit txtDateCreated = cont.EditASPXDateEditDefiner("txtDateCreated", gv_purchaseorders);
            ASPxTextBox txtRequstedBy = cont.EditASPXTextBoxDefiner("txtRequstedBy", gv_purchaseorders);
            ASPxTextBox txtRequisitionNo = cont.EditASPXTextBoxDefiner("txtRequisitionNo", gv_purchaseorders);
            ASPxDateEdit txtRequisitionDate = cont.EditASPXDateEditDefiner("txtRequisitionDate", gv_purchaseorders);
            ASPxComboBox txtSupplierID = cont.EditASPXComboBoxDefiner("txtSupplierID", gv_purchaseorders);            
            ASPxTextBox txtTermsOfDelivery = cont.EditASPXTextBoxDefiner("txtTermsOfDelivery", gv_purchaseorders);
            ASPxDateEdit txtDateOfDelivery = cont.EditASPXDateEditDefiner("txtDateOfDelivery", gv_purchaseorders);
            ASPxTextBox txtTermsOfPayment = cont.EditASPXTextBoxDefiner("txtTermsOfPayment", gv_purchaseorders);
            ASPxTextBox txtMethodOfPayment = cont.EditASPXTextBoxDefiner("txtMethodOfPayment", gv_purchaseorders);

            if (txtPON.Text.ToString() == "")
            {
                newOrder.inv_poEntries(null, txtDateCreated.Date, txtRequstedBy.Text, int.Parse(txtRequisitionNo.Text), txtRequisitionDate.Date,
                    int.Parse(txtSupplierID.Value.ToString()), Session["username"].ToString(), txtTermsOfDelivery.Text, txtDateOfDelivery.Date, txtTermsOfPayment.Text, txtMethodOfPayment.Text);
            }
            else
            {
                newOrder.inv_poEntries(int.Parse(txtPON.Text), txtDateCreated.Date, txtRequstedBy.Text, int.Parse(txtRequisitionNo.Text), txtRequisitionDate.Date,
                    int.Parse(txtSupplierID.Value.ToString()), Session["username"].ToString(), txtTermsOfDelivery.Text, txtDateOfDelivery.Date, txtTermsOfPayment.Text, txtMethodOfPayment.Text);
            }
            gv_purchaseorders.CancelEdit();
            ds_purchaseOrders.Select();
            gv_purchaseorders.DataBind();

            img_pop.ImageUrl = setting.InfoImage("OK");
            lbl_pop.ForeColor = setting.InfoColor("OK");
            lbl_pop.Text = "Data Update Completed Successfuly!";
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
    protected void cmdAddItems_Click(object sender, EventArgs e)
    {
        
    }
    protected void cmdItems_Click(object sender, ImageClickEventArgs e)
    {
        Session["PON"] = gv_purchaseorders.GetRowValues(gv_purchaseorders.FocusedRowIndex, "Po_No");
        if (Session["PON"] != null)
        {

            Session["PopID"] = "7";
            pop_mgs.Width = 1000;
            pop_mgs.Height = 500;
            pop_mgs.HeaderText = "...Adding Items on Purchase order Number: " + Session["PON"].ToString();
            pop_mgs.ContentUrl = "~/COOPERP/Inventory/PopWindows.aspx";
            pop_mgs.ShowOnPageLoad = true;
        }
        else
        {
            img_pop.ImageUrl = setting.InfoImage("Error");
            lbl_pop.ForeColor = setting.InfoColor("Error");
            lbl_pop.Text = "Purchase Order Number not Identified!";
            pop_mgs.Width = 300;
            pop_mgs.Height = 100;
            pop_mgs.HeaderText = "Campus Dynamics ERP";
            pop_mgs.ShowOnPageLoad = true;
        }
    }
    protected void gv_purchaseorders_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        e.NewValues["DateCreated"] = txtRunDate.Value;
    }
}