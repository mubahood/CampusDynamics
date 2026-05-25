using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_NewScreens_MainAccountsController : System.Web.UI.Page
{
    private const string PAGE_NAME = "MainAccountsController";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ResetMainForm();
            LoadMainAccounts();
            LoadStats();
        }
    }

    private void LoadStats()
    {
        try
        {
            var row = FinanceDB.ExecuteAggregateRow(
                @"SELECT (SELECT COUNT(*) FROM fin_mainaccounts) AS main_cnt,
                         (SELECT COUNT(*) FROM fin_subaccounts) AS sub_cnt,
                         (SELECT COUNT(DISTINCT GeneralCategory) FROM fin_mainaccounts) AS cat_cnt,
                         (SELECT COUNT(*) FROM fin_ledgertypes) AS lt_cnt");

            litMainCount.Text = Convert.ToInt32(row.ContainsKey("main_cnt") ? row["main_cnt"] : 0).ToString("N0");
            litSubCount.Text = Convert.ToInt32(row.ContainsKey("sub_cnt") ? row["sub_cnt"] : 0).ToString("N0");
            litCatCount.Text = Convert.ToInt32(row.ContainsKey("cat_cnt") ? row["cat_cnt"] : 0).ToString("N0");
            litLedgerTypes.Text = Convert.ToInt32(row.ContainsKey("lt_cnt") ? row["lt_cnt"] : 0).ToString("N0");
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadStats", ex);
        }
    }

    private void LoadMainAccounts()
    {
        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                "SELECT AccountCode, AccountName, GeneralCategory, SubCategory FROM fin_mainaccounts ORDER BY AccountCode");
            rptMainAccounts.DataSource = dt;
            rptMainAccounts.DataBind();
            phNoMain.Visible = (dt.Rows.Count == 0);
            litMainFooter.Text = string.Format("<strong>{0}</strong> main accounts", dt.Rows.Count);
            litMainBadge.Text = string.Format("<span class='pm-chip'>{0} accounts</span>", dt.Rows.Count);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadMainAccounts", ex);
        }
    }

    protected void btnSaveMainAccount_Click(object sender, EventArgs e)
    {
        string mode = (hdnMainMode.Value ?? "add").Trim().ToLower();
        bool isEdit = mode == "edit";

        string code = (txtMainAccCode.Text ?? string.Empty).Trim();
        string originalCode = (hdnMainOriginalCode.Value ?? string.Empty).Trim();
        string name = (txtMainAccName.Text ?? string.Empty).Trim();
        string category = (ddlGeneralCategory.SelectedValue ?? string.Empty).Trim();
        string subCat = (txtSubCategory.Text ?? string.Empty).Trim();

        if (isEdit && !string.IsNullOrEmpty(originalCode))
        {
            code = originalCode;
        }

        if (string.IsNullOrEmpty(code) || string.IsNullOrEmpty(name) || string.IsNullOrEmpty(category))
        {
            ShowMessage("Please fill in Account Code, Name, and Category.", false);
            OpenMainModal(isEdit);
            return;
        }

        try
        {
            FinanceDB.ExecuteNonQuerySP("MainAccountEditor",
                FinanceDB.P("@usr", HttpContext.Current.User.Identity.Name),
                FinanceDB.P("@AccCode", code),
                FinanceDB.P("@AccountName", name),
                FinanceDB.P("@GeneralCategory", category),
                FinanceDB.P("@SubCategory", subCat));

            FinanceLogger.LogAction(PAGE_NAME,
                isEdit ? "EditMainAccount" : "AddMainAccount",
                "Code=" + code + " Name=" + name + " Category=" + category);
            AccountCache.InvalidateAll();

            ShowMessage(isEdit
                ? "Main account '" + code + "' updated successfully."
                : "Main account '" + code + "' added successfully.", true);

            ResetMainForm();
            LoadMainAccounts();
            LoadStats();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnSaveMainAccount_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
            OpenMainModal(isEdit);
        }
    }

    protected void rptMainAccounts_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        string code = (e.CommandArgument ?? string.Empty).ToString();

        if (e.CommandName == "ViewSubs")
        {
            Response.Redirect("~/COOPERP/NewScreens/SubAccountsController.aspx?main=" + HttpUtility.UrlEncode(code), false);
            Context.ApplicationInstance.CompleteRequest();
        }
        else if (e.CommandName == "EditMain")
        {
            LoadMainForEdit(code);
        }
        else if (e.CommandName == "DeleteMain")
        {
            try
            {
                FinanceDB.ExecuteNonQuerySP("DeleteMainAccount",
                    FinanceDB.P("@usr", HttpContext.Current.User.Identity.Name),
                    FinanceDB.P("@AccCode", code));

                FinanceLogger.LogAction(PAGE_NAME, "DeleteMainAccount", "Code=" + code);
                AccountCache.InvalidateAll();

                ShowMessage("Main account deleted.", true);
                ResetMainForm();
                LoadMainAccounts();
                LoadStats();
            }
            catch (Exception ex)
            {
                FinanceLogger.LogError(PAGE_NAME, "DeleteMainAccount", ex);
                ShowMessage("Cannot delete: " + ex.Message, false);
            }
        }
    }

    private void LoadMainForEdit(string code)
    {
        if (string.IsNullOrWhiteSpace(code))
        {
            ShowMessage("Unable to open edit form: invalid account code.", false);
            return;
        }

        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                "SELECT AccountCode, AccountName, GeneralCategory, SubCategory FROM fin_mainaccounts WHERE AccountCode = @code LIMIT 1",
                FinanceDB.P("@code", code));

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Account not found for edit.", false);
                return;
            }

            DataRow row = dt.Rows[0];
            txtMainAccCode.Text = row["AccountCode"].ToString();
            txtMainAccName.Text = row["AccountName"].ToString();
            string category = row["GeneralCategory"].ToString();
            if (ddlGeneralCategory.Items.FindByValue(category) != null)
            {
                ddlGeneralCategory.SelectedValue = category;
            }
            else
            {
                ddlGeneralCategory.SelectedIndex = 0;
            }
            txtSubCategory.Text = row["SubCategory"].ToString();

            hdnMainMode.Value = "edit";
            hdnMainOriginalCode.Value = row["AccountCode"].ToString();
            txtMainAccCode.ReadOnly = true;

            OpenMainModal(true);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadMainForEdit", ex);
            ShowMessage("Error loading account for edit: " + ex.Message, false);
        }
    }

    private void ResetMainForm()
    {
        hdnMainMode.Value = "add";
        hdnMainOriginalCode.Value = "";
        txtMainAccCode.Text = "";
        txtMainAccName.Text = "";
        txtSubCategory.Text = "";
        ddlGeneralCategory.SelectedIndex = 0;
        txtMainAccCode.ReadOnly = false;
    }

    private void OpenMainModal(bool editMode)
    {
        string mode = editMode ? "edit" : "add";
        ScriptManager.RegisterStartupScript(this, GetType(), "OpenMainModal", "openMainModal('" + mode + "');", true);
    }

    private void ShowMessage(string msg, bool success)
    {
        string cssClass = success ? "pm-alert pm-alert--ok" : "pm-alert pm-alert--err";
        lblMessage.Text = "<div class='" + cssClass + "'>" + HttpUtility.HtmlEncode(msg) + "</div>";
        lblMessage.Visible = true;
    }
}
