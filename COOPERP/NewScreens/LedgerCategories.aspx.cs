using System;
using System.Data;
using System.Web.UI;
using DevExpress.Web;

/// <summary>
/// Ledger Categories — CRUD for ledger types.
/// 
/// REFACTORED (Phase 2):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ No error handling → try/catch + FinanceLogger.LogError
///  ✓ No audit trail → FinanceLogger.LogAction on save/delete
/// </summary>
public partial class COOPERP_NewScreens_LedgerCategories : System.Web.UI.Page
{
    private const string PAGE_NAME = "LedgerCategories";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCategories();
        }
    }

    private void LoadCategories()
    {
        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                "SELECT LedgerTypeID, LedgerTypeName, LedgerTypeCategory FROM fin_ledgertypes ORDER BY LedgerTypeCategory, LedgerTypeName");
            gridCategories.DataSource = dt;
            gridCategories.DataBind();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadCategories", ex);
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        string name = txtCategoryName.Text.Trim();
        string category = ddlGeneralCategory.SelectedValue;
        string editId = hdnEditId.Value;

        if (string.IsNullOrEmpty(name))
        {
            ShowMessage("Please enter a category name.", false);
            return;
        }

        try
        {
            if (!string.IsNullOrEmpty(editId))
            {
                FinanceDB.ExecuteNonQuerySP("fin_LedgerCategoryEditor",
                    FinanceDB.P("@ltName", name),
                    FinanceDB.P("@ltCategory", category),
                    FinanceDB.P("@ltID", int.Parse(editId)));
            }
            else
            {
                FinanceDB.ExecuteNonQuerySP("fin_LedgerCategoryEditor",
                    FinanceDB.P("@ltName", name),
                    FinanceDB.P("@ltCategory", category));
            }

            string action = string.IsNullOrEmpty(editId) ? "added" : "updated";
            FinanceLogger.LogAction(PAGE_NAME, action == "added" ? "AddCategory" : "UpdateCategory",
                "Name=" + name + " Category=" + category);

            ShowMessage("Category '" + name + "' " + action + " successfully.", true);
            txtCategoryName.Text = "";
            hdnEditId.Value = "";
            btnSave.Text = "+ Add Category";
            LoadCategories();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnSave_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnEdit_Click(object sender, EventArgs e)
    {
        ASPxButton btn = sender as ASPxButton;
        if (btn == null) return;

        string[] parts = btn.CommandArgument.Split('|');
        if (parts.Length >= 3)
        {
            hdnEditId.Value = parts[0];
            txtCategoryName.Text = parts[1];
            try { ddlGeneralCategory.SelectedValue = parts[2]; } catch { }
            btnSave.Text = "Update Category";
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        ASPxButton btn = sender as ASPxButton;
        if (btn == null) return;
        string id = btn.CommandArgument;

        try
        {
            FinanceDB.ExecuteNonQuerySP("fin_DeleteLedgerCategory",
                FinanceDB.P("@ltID", int.Parse(id)));

            FinanceLogger.LogAction(PAGE_NAME, "DeleteCategory", "ID=" + id);
            ShowMessage("Category deleted successfully.", true);
            LoadCategories();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnDelete_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        pnlMsg.CssClass = isSuccess ? "lc-msg lc-msg-ok" : "lc-msg lc-msg-err";
        litMsg.Text = msg;
    }
}
