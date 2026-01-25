using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.XtraPrinting;

public partial class UserControls_schools_lnventoryBudgets : System.Web.UI.UserControl
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
    protected void cmdPostLedger_Click(object sender, EventArgs e)
    {
        Session["TType"] = "Bill";
        lbl_msg_post.Text = "";
        pop_postLedger.ShowOnPageLoad = true;
    }
    protected void cmdPosting_Click(object sender, EventArgs e)
    {
        double tAmount = 0; int sn = 0; string typ = "Bill";
        try
        {
            string postStatus = gvBranchData.GetRowValues(gvBranchData.FocusedRowIndex, "billPosting").ToString();
            if (postStatus == "Not Posted")
            {
                tAmount = double.Parse(gvBranchData.GetRowValues(gvBranchData.FocusedRowIndex, "grandTotal").ToString());
                sn = int.Parse(gvBranchData.GetRowValues(gvBranchData.FocusedRowIndex, "ID").ToString());
                //school_groupTableAdapters.school_class_transactionsTableAdapter GL = new school_groupTableAdapters.school_class_transactionsTableAdapter();
                /*GL.school_CreateLedgerEntry(sn, int.Parse(txtSchool.Value.ToString()), typ, tAmount,
                    DateTime.Today, UserName, int.Parse(txtTerm.Text), int.Parse(txtYear.Text),
                    gvBranchData.GetRowValues(gvBranchData.FocusedRowIndex, "class_name").ToString(), "General");*/
                lbl_msg_post.Text = typ + " Posting Completed";
            }
            else
            {
                lbl_msg_post.Text = " Transaction Already Posted!";
            }
            gvBranchData.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msg_post.Text = String.Format("Error! {0}Amt={1},ID={2}", ex.Message, tAmount, sn);
        }

    }

    protected void cmdExport_Click(object sender, EventArgs e)
    {
        Exporter.WriteXlsxToResponse(string.Format("{0} Budget Term {1}-{2}",txtSchool.Text,txtTerm.Text,txtYear.Text), new XlsxExportOptions { ExportMode = XlsxExportMode.SingleFile });
    }
    protected void txtItemCategory_SelectedIndexChanged(object sender, EventArgs e)
    {
        txtItemName.DataBind();
        //txtItemName.SelectedIndex = 0;
    }

    protected void cmdAddItem_Click(object sender, EventArgs e)
    {
        SchoolInventoryTableAdapters.inv_budgetrequisitionsTableAdapter Budget = new SchoolInventoryTableAdapters.inv_budgetrequisitionsTableAdapter();
        try
        {
            if (txtSingleItem.Checked == true)
            {
                Budget.inv_AddBudgetItems(int.Parse(txtSchool.Value.ToString()), int.Parse(txtTerm.Text), txtYear.Text);
                lbl_msg_post.Text = "Items Added";
            }
            else
            {
                Budget.Insert(uint.Parse(txtSchool.Value.ToString()), uint.Parse(txtTerm.Text), txtYear.Text, uint.Parse(txtItemName.Value.ToString()),
                    0, 0,0);
                lbl_msg_post.Text = "Item Added";
            }
            gvBranchData.DataBind();
        }
        catch (Exception ex)
        {
            lbl_msg_post.Text = "Error! Item Already Added. Select another ["+ex.Message+"]";
        }
    }
    protected void txtSingleItem_CheckedChanged(object sender, EventArgs e)
    {
        if (txtSingleItem.Checked == true)
        {
            txtItemCategory.Enabled = false;
            txtItemName.Enabled = false;
        }
        else
        {
            txtItemCategory.Enabled = true;
            txtItemName.Enabled = true;
        }
    }
    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        pop_details.ContentUrl = "~/COOPERP/Inventory/Reports/Default.aspx";
        Session["report"] = "MaterialsReport";
        Session["term"] = txtTerm.Text;
        Session["year"] = txtYear.Text;
        pop_details.Width = 900;
        pop_details.Height = 600;
        pop_details.ShowOnPageLoad = true;
    }
}