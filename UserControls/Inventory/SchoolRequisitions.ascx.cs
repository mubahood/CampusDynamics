using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraPrinting;
using SchoolInventoryTableAdapters;

public partial class UserControls_Inventory_SchoolRequisitions : System.Web.UI.UserControl
{
    string UserName = HttpContext.Current.User.Identity.Name;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtYear.DataSource = CommonRoutines.ReturnAcademicYrs();
            txtYear.DataBind();
            txtYear.Text = DateTime.Now.Year + "/" + (DateTime.Now.Year+1);
        }
    }
    
   

    protected void cmdExport_Click(object sender, EventArgs e)
    {
        Exporter.WriteXlsxToResponse(string.Format("{0} Requisitions Term {1}-{2}", txtSchool.Text, txtTerm.Text, txtYear.Text), new XlsxExportOptions { ExportMode = XlsxExportMode.SingleFile });
    }


    protected void cmdPostLedger_Click(object sender, EventArgs e)
    {
        SchoolInventoryTableAdapters.inv_schoolrequisitionTableAdapter REQ = new SchoolInventoryTableAdapters.inv_schoolrequisitionTableAdapter();
        try
        {
            REQ.Insert(uint.Parse(txtSchool.Value.ToString()), DateTime.Today, "-", "-", "-", 0, uint.Parse(txtTerm.Text), txtYear.Text,"Pending");
            lbl_msg.Text = "Requisition Added";
        }
        catch (Exception ex)
        {
            lbl_msg.Text = "Error. Only 1 Requisition Per Day";
        }
        pop_details.ContentUrl = "";
        pop_details.Width = 300;
        pop_details.Height = 120;
        gvBranchData.DataBind();
        pop_details.ShowOnPageLoad = true;

    }
    protected void cmdDetails_Click(object sender, ImageClickEventArgs e)
    {
        gvBranchData.DataBind();
        pop_details.Width = 1000;
        pop_details.Height = 500;
        Session["rid"] = gvBranchData.GetRowValues(gvBranchData.FocusedRowIndex, "ID");
        Session["stat"] = gvBranchData.GetRowValues(gvBranchData.FocusedRowIndex, "req_status");
        pop_details.ContentUrl = "~/COOPERP/Inventory/RequisitionDetails.aspx";
        pop_details.ShowOnPageLoad = true;
    }

    protected void cmdApprove_Click(object sender, EventArgs e)
    {
        pop_details.Width = 300;
        pop_details.Height = 120;
        inv_schoolrequisitionTableAdapter REQ = new inv_schoolrequisitionTableAdapter();
        int noRows = gvBranchData.VisibleRowCount;
        lbl_msg.Text = "No Item Selected";
        for (int i = 0; i < noRows; i++)
        {
            if (gvBranchData.Selection.IsRowSelected(i))
            {
                try
                {
                    lbl_msg.Text = REQ.inv_ApproveRequisition(int.Parse(gvBranchData.GetRowValues(i, "ID").ToString()), gvBranchData.GetRowValues(i, "req_status").ToString(),
                        HttpContext.Current.User.Identity.Name).ToString();
                }
                catch (Exception ex)
                {
                    lbl_msg.Text = "Error! " + ex.Message;
                }
            }
        }
        gvBranchData.DataBind();
        pop_details.ContentUrl = "";
        pop_details.ShowOnPageLoad = true;
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Session["rid"] = gvBranchData.GetRowValues(gvBranchData.FocusedRowIndex, "ID");
        pop_details.Width = 900;
        pop_details.Height = 600;
        pop_details.ContentUrl = "~/COOPERP/XtraReports/Default.aspx";
        Session["Report"] = "Requisition";
        gvBranchData.DataBind();
        pop_details.ShowOnPageLoad = true;
    }
    protected void gvBranchData_HtmlRowPrepared(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        e.Row.Height = 35;
    }
}