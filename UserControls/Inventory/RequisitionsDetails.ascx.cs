using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraPrinting;

public partial class UserControls_Inventory_InventoryRequisitions : System.Web.UI.UserControl
{
    string UserName = HttpContext.Current.User.Identity.Name;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["stat"].ToString() == "Approved")
        {
            cmdPostLedger.Visible = false;
            cmdAddItem.Visible = false;
            gvBranchData.Columns["comm"].Visible = false;
            gvBranchData.Enabled = false;
        }
    }
    protected void cmdPostLedger_Click(object sender, EventArgs e)
    {
        Session["TType"] = "Bill";
        lbl_msg_post.Text = "";
        pop_postLedger.ShowOnPageLoad = true;
    }
   
    protected void txtItemCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtItemName.DataBind();
        //txtItemName.SelectedIndex = 0;
    }

    protected void cmdAddItem_Click(object sender, EventArgs e)
    {
        SchoolInventoryTableAdapters.inv_schoolreqdetailsTableAdapter Requisition = new SchoolInventoryTableAdapters.inv_schoolreqdetailsTableAdapter();
        try
        {
            Requisition.inv_AddNewRequisitionDetail(int.Parse(Session["rid"].ToString()), int.Parse(txtItemName.Value.ToString()),int.Parse(txtUnit.Value.ToString()),
                int.Parse(txtlocation.Value.ToString()));
            lbl_msg_post.Text = "Item Added to Store" + txtlocation.Value.ToString();
            gvBranchData.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msg_post.Text = "Error! Item Already Added OR not Budgeted For ["+ex.Message+"]";
        }
    }

    protected void gvBranchData_RowUpdated(object sender, DevExpress.Web.Data.ASPxDataUpdatedEventArgs e)
    {
        UpdateValues();
    }

    void UpdateValues()
    {
        int noRows = gvBranchData.VisibleRowCount;
        SchoolInventoryTableAdapters.inv_schoolreqdetailsTableAdapter Requisition = new SchoolInventoryTableAdapters.inv_schoolreqdetailsTableAdapter();
        for (int i = 0; i < noRows; i++)
        {
            try
            {
                Requisition.inv_UpdateRequisitionDetail(int.Parse(Session["rid"].ToString()), int.Parse(gvBranchData.GetRowValues(i,"itemCode").ToString()));
            }
            catch (Exception ex)
            {
                lbl_msg_post.Text = "Error! Item Already Added. Select another";
            }
        }
        gvBranchData.DataBind();
    }
    protected void gvBranchData_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        double req=double.Parse(e.NewValues["req_qty"].ToString()),actual=double.Parse(e.NewValues["actual_qty"].ToString()) ;
         try
        {
            if (actual > req)
            {
                Exception ex = new Exception();
                e.Cancel = true;
                throw ex;

            }
        }
         catch (Exception)
         {
             lbl_msg.Text = "Error! Actual Quantity Should be less or same with Requested!";
             lbl_msg.ForeColor = System.Drawing.Color.Red;
             gvBranchData.CancelEdit();
             pop_details.ShowOnPageLoad = true;
         }
       
    }

    protected void gvBranchData_BatchUpdate(object sender, DevExpress.Web.Data.ASPxDataBatchUpdateEventArgs e)
    {
        lbl_msg.Text = "Updates Saved Successfully";
        lbl_msg.ForeColor = System.Drawing.Color.Blue;
        pop_details.ShowOnPageLoad = true;
    }
    protected void txtItemName_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtUnit.DataBind();
    }
    protected void gvBranchData_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
}