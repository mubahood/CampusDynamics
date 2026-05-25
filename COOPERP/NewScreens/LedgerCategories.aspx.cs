using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_NewScreens_LedgerCategories : System.Web.UI.Page
{
    private const string PAGE_NAME = "LedgerCategories";

    protected string GetCategoryPillCss(object categoryValue)
    {
        string category = Convert.ToString(categoryValue ?? string.Empty).Trim().ToLowerInvariant();
        switch (category)
        {
            case "asset":
                return "pm-pill--asset";
            case "liability":
                return "pm-pill--liability";
            case "income":
                return "pm-pill--income";
            case "expense":
                return "pm-pill--expense";
            case "equity":
                return "pm-pill--equity";
            default:
                return "pm-pill--neutral";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            hdnModalOpen.Value = string.Empty;
            LoadCategories();
        }
        else
        {
            if (hdnModalOpen.Value == "1")
            {
                OpenModal();
            }
        }
    }

    private void LoadCategories()
    {
        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                "SELECT LedgerTypeID, LedgerTypeName, LedgerTypeCategory FROM fin_ledgertypes ORDER BY LedgerTypeCategory, LedgerTypeName");

            rptCategories.DataSource = dt;
            rptCategories.DataBind();
            phEmpty.Visible = dt.Rows.Count == 0;

            // Stats
            int total = dt.Rows.Count;
            int asset = 0, liability = 0, income = 0, expense = 0, equity = 0;
            foreach (DataRow row in dt.Rows)
            {
                string cat = row["LedgerTypeCategory"].ToString();
                if (cat == "Asset") asset++;
                else if (cat == "Liability") liability++;
                else if (cat == "Income") income++;
                else if (cat == "Expense") expense++;
                else if (cat == "Equity") equity++;
            }
            litTotal.Text = total.ToString();
            litAsset.Text = asset.ToString();
            litLiability.Text = liability.ToString();
            litIncome.Text = income.ToString();
            litExpense.Text = expense.ToString();
            litEquity.Text = equity.ToString();

            litBadge.Text = string.Format("<span class='pm-chip'>{0} categories</span>", total);
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
        string editId = hdnEditId.Value.Trim();

        if (string.IsNullOrEmpty(name))
        {
            ShowMessage("Please enter a category name.", false);
            OpenModal();
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
                FinanceLogger.LogAction(PAGE_NAME, "UpdateCategory", "ID=" + editId + " Name=" + name);
                ShowMessage("Category '" + name + "' updated successfully.", true);
            }
            else
            {
                FinanceDB.ExecuteNonQuerySP("fin_LedgerCategoryEditor",
                    FinanceDB.P("@ltName", name),
                    FinanceDB.P("@ltCategory", category));
                FinanceLogger.LogAction(PAGE_NAME, "AddCategory", "Name=" + name + " Category=" + category);
                ShowMessage("Category '" + name + "' added successfully.", true);
            }

            ResetForm();
            LoadCategories();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnSave_Click", ex);
            ShowMessage("Error saving category: " + ex.Message, false);
            OpenModal();
        }
    }

    protected void rptCategories_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "Edit")
        {
            string[] parts = e.CommandArgument.ToString().Split('|');
            if (parts.Length >= 3)
            {
                hdnEditId.Value = parts[0];
                hdnModalOpen.Value = "1";
                txtCategoryName.Text = parts[1];
                try { ddlGeneralCategory.SelectedValue = parts[2]; } catch { }
                btnSave.Text = "Update Category";
                LoadCategories();
                OpenModal();
            }
        }
        else if (e.CommandName == "Delete")
        {
            string id = e.CommandArgument.ToString();
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
                FinanceLogger.LogError(PAGE_NAME, "DeleteCategory", ex);
                ShowMessage("Error deleting category: " + ex.Message, false);
            }
        }
    }

    private void ResetForm()
    {
        txtCategoryName.Text = "";
        ddlGeneralCategory.SelectedIndex = 0;
        hdnEditId.Value = "";
        hdnModalOpen.Value = "";
        btnSave.Text = "Save Category";
    }

    private void OpenModal()
    {
        hdnModalOpen.Value = "1";
        ScriptManager.RegisterStartupScript(this, GetType(), "openModal",
            "if(window.openLcModal){window.openLcModal('edit');}", true);
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        divMsg.Attributes["class"] = isSuccess ? "pm-alert pm-alert--ok" : "pm-alert pm-alert--err";
        litMsg.Text = msg;
    }
}
