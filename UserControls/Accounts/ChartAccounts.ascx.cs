using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Web;
using System.Data;


public partial class UserControls_Accounts_ChartAccounts : System.Web.UI.UserControl
{
    ControlDefiners conts = new ControlDefiners();

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected void cmdAdd_Click(object sender, EventArgs e)
    {
        gvMainAccounts.AddNewRow();
    }
    protected void txtData_SelectedIndexChanged(object sender, EventArgs e)
    {
        //Initialise Values for Subcategory Combo: Assets: Fixed & Current; Liabilities: Fixed & Current
        ASPxComboBox txtCategory = conts.ASPXComboDefiner("GeneralCategory", "txtData", gvMainAccounts);
        ASPxComboBox txtSubCategory = conts.ASPXComboDefiner("SubCategory", "txtData", gvMainAccounts);
        txtSubCategory.Items.Clear();
        if (txtCategory.Text == "Assets")
        {
            txtSubCategory.Items.Add("Current Assets", "Current Assets");
            txtSubCategory.Items.Add("Fixed Assets", "Fixed Assets");
        }

        else if (txtCategory.Text == "Liabilities")
        {
            txtSubCategory.Items.Add("Current Liabilities", "Current Liabilities");
            txtSubCategory.Items.Add("Fixed Liabilities", "Fixed Liabilities");
        }
        else if (txtCategory.Text == "Income")
        {
            txtSubCategory.Items.Add("Income", "Income");
        }
        else if (txtCategory.Text == "Expense")
        {
            txtSubCategory.Items.Add("Expense", "Expense");
        }
        else
        {
            txtSubCategory.Items.Add("-", "-");
        }

        txtSubCategory.Focus();
    }
    protected void gvAccounts_BeforePerformDataSelect(object sender, EventArgs e)
    {
        Session["CategoryCode"] = (sender as ASPxGridView).GetMasterRowKeyValue();
    }

    protected void gvHouseHold_CustomErrorText(object sender, DevExpress.Web.ASPxGridViewCustomErrorTextEventArgs e)
    {
        e.ErrorText = e.Exception.InnerException.Message;
    }
    protected void gvAccounts_InitNewRow(object sender, DevExpress.Web.Data.ASPxDataInitNewRowEventArgs e)
    {
        CoopERPDataTableAdapters.fin_subaccountsTableAdapter ACC = new CoopERPDataTableAdapters.fin_subaccountsTableAdapter();
        e.NewValues["MainAccountCode"] = Session["CategoryCode"];
        e.NewValues["AccountCode"] = ACC.NextAccountCode(Session["CategoryCode"].ToString());
        e.NewValues["accounttype"] = "Basic Account";
        e.NewValues["collectionLedgerType"] = "Chart Account";
    }
    protected void cmdCategories_Click(object sender, EventArgs e)
    {
        pop_categories.Width = 600;
        pop_categories.Height = 600;
        pop_categories.ShowOnPageLoad = true;
    }
    protected void cmdAddAccount_Click(object sender, EventArgs e)
    {
        ControlDefiners GV = new ControlDefiners();
       
    }
    protected void gvMainAccounts_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 35;
    }
    private ASPxGridView GetFirstDetailGrid()
    {
        for (int i = 0; i < gvMainAccounts.VisibleRowCount; i++)
        {
            if (gvMainAccounts.IsRowExpanded(i))
            {
                Control ctrl = gvMainAccounts.FindDetailRowTemplateControl(i, "gvAccounts");
                if (ctrl != null)
                    return ctrl as ASPxGridView;
            }
        }
        return null;
    }



    protected void cmdExport_Click(object sender, EventArgs e)
    {
        // 1. Create flattened DataTable for export
        DataTable dtExport = new DataTable();
        dtExport.Columns.Add("CategoryCode");
        dtExport.Columns.Add("CategoryName");   // Only for main category
        dtExport.Columns.Add("Classification"); // GeneralCategory
        dtExport.Columns.Add("AccountCode");    // Subaccount code
        dtExport.Columns.Add("AccountName");    // Subaccount name
        dtExport.Columns.Add("AccountType");
        dtExport.Columns.Add("LedgerCategory");
        dtExport.Columns.Add("BaseCurrency");
        dtExport.Columns.Add("Details");

        // 2. TableAdapters
        CoopERPDataTableAdapters.fin_mainaccountsTableAdapter mainAdapter =
            new CoopERPDataTableAdapters.fin_mainaccountsTableAdapter();
        CoopERPDataTableAdapters.fin_subaccountsTableAdapter accAdapter =
            new CoopERPDataTableAdapters.fin_subaccountsTableAdapter();

        // 3. Get all main categories
        DataTable categories = mainAdapter.GetData();

        foreach (DataRow cat in categories.Rows)
        {
            string catCode = cat["AccountCode"].ToString();
            string catName = cat["AccountName"].ToString();
            string generalCategory = cat["GeneralCategory"].ToString();

            // 4. Add main category row (no subaccount info yet)
            dtExport.Rows.Add(
                catCode,
                catName,
                generalCategory,
                "", // AccountCode empty for main category
                "", // AccountName empty for main category
                "", // AccountType empty
                "", // LedgerCategory empty
                "", // BaseCurrency empty
                ""  // Details empty
            );

            // 5. Get subaccounts for this category
            DataTable accounts = accAdapter.GetAccountsbyCategory(catCode);
            foreach (DataRow acc in accounts.Rows)
            {
                dtExport.Rows.Add(
                    "", // CategoryCode empty for subaccounts
                    "", // CategoryName empty for subaccounts
                    "", // Classification empty for subaccounts
                    acc["AccountCode"].ToString(),
                    acc["AccountName"].ToString(),
                    acc["accounttype"].ToString(),
                    acc["collectionLedgerType"].ToString(),
                    acc["base_currency"].ToString(),
                    acc["Details"].ToString()
                );
            }
        }

        // 6. Bind and export
        gvExportTemp.DataSource = dtExport;
        gvExportTemp.DataBind();
        gveExportTemp.WriteXlsToResponse("Chart_of_Accounts_Full");
    }
}