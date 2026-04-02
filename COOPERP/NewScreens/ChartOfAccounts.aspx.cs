using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Chart of Accounts — Main + Sub account CRUD with stats.
/// 
/// REFACTORED (Phase 2):
///  ✓ Hardcoded connection string → FinanceDB
///  ✓ 4 separate LoadMainAccount* methods with duplicated queries → shared helper
///  ✓ No error handling on loads → try/catch + FinanceLogger
///  ✓ No audit trail → FinanceLogger.LogAction on add/delete
///  ✓ AccountCache invalidation on mutations
/// </summary>
public partial class COOPERP_NewScreens_ChartOfAccounts : System.Web.UI.Page
{
    private const string PAGE_NAME = "ChartOfAccounts";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadMainAccounts();
            LoadSubAccounts(null);
            LoadMainAccountDropdowns();
            LoadLedgerTypesDropdown();
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
            litMainBadge.Text = string.Format("<span class='ft-card__meta'>{0} accounts</span>", dt.Rows.Count);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadMainAccounts", ex);
        }
    }

    private void LoadSubAccounts(string mainAccountCode)
    {
        try
        {
            DataTable dt;
            if (mainAccountCode != null)
            {
                dt = FinanceDB.ExecuteDataTable(
                    "SELECT AccountCode, AccountName, MainAccountCode, Details, accounttype, collectionLedgerType FROM fin_subaccounts WHERE MainAccountCode = @mac ORDER BY AccountCode",
                    FinanceDB.P("@mac", mainAccountCode));
            }
            else
            {
                dt = FinanceDB.ExecuteDataTable(
                    "SELECT AccountCode, AccountName, MainAccountCode, Details, accounttype, collectionLedgerType FROM fin_subaccounts ORDER BY AccountCode");
            }

            rptSubAccounts.DataSource = dt;
            rptSubAccounts.DataBind();
            phNoSub.Visible = (dt.Rows.Count == 0);
            litSubFooter.Text = string.Format("<strong>{0}</strong> sub accounts", dt.Rows.Count);

            litSubBadge.Text = mainAccountCode != null
                ? string.Format("<span class='ft-card__meta'>Filtered: {0}</span>", HttpUtility.HtmlEncode(mainAccountCode))
                : "<span class='ft-card__meta'>Showing all</span>";
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadSubAccounts", ex);
        }
    }

    /// <summary>Populates both main-account dropdowns from a single query.</summary>
    private void LoadMainAccountDropdowns()
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            "SELECT AccountCode, AccountName FROM fin_mainaccounts ORDER BY AccountCode");

        // Dropdown for sub-account creation
        ddlMainAccountForSub.Items.Clear();
        ddlMainAccountForSub.Items.Add(new ListItem("-- Select Main Account --", ""));

        // Filter dropdown
        ddlFilterMainAcc.Items.Clear();
        ddlFilterMainAcc.Items.Add(new ListItem("All Main Accounts", ""));

        foreach (DataRow row in dt.Rows)
        {
            string code = row["AccountCode"].ToString();
            string name = row["AccountName"].ToString();
            string display = code + " - " + name;
            ddlMainAccountForSub.Items.Add(new ListItem(display, code));
            ddlFilterMainAcc.Items.Add(new ListItem(display, code));
        }
    }

    private void LoadLedgerTypesDropdown()
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            "SELECT LedgerTypeName FROM fin_ledgertypes ORDER BY LedgerTypeName");
        ddlLedgerTypeForSub.Items.Clear();
        ddlLedgerTypeForSub.Items.Add(new ListItem("-- Select --", ""));
        foreach (DataRow row in dt.Rows)
        {
            string name = row["LedgerTypeName"].ToString();
            ddlLedgerTypeForSub.Items.Add(new ListItem(name, name));
        }
    }

    protected void ddlFilterMainAcc_Changed(object sender, EventArgs e)
    {
        string val = ddlFilterMainAcc.SelectedValue;
        LoadSubAccounts(string.IsNullOrEmpty(val) ? null : val);
    }

    protected void btnAddMainAccount_Click(object sender, EventArgs e)
    {
        string code = txtMainAccCode.Text.Trim();
        string name = txtMainAccName.Text.Trim();
        string category = ddlGeneralCategory.SelectedValue;
        string subCat = txtSubCategory.Text.Trim();

        if (string.IsNullOrEmpty(code) || string.IsNullOrEmpty(name) || string.IsNullOrEmpty(category))
        {
            ShowMessage("Please fill in Account Code, Name, and Category.", false);
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

            FinanceLogger.LogAction(PAGE_NAME, "AddMainAccount",
                "Code=" + code + " Name=" + name + " Category=" + category);
            AccountCache.InvalidateAll();

            ShowMessage("Main account '" + code + "' added successfully.", true);
            txtMainAccCode.Text = "";
            txtMainAccName.Text = "";
            txtSubCategory.Text = "";
            LoadMainAccounts();
            LoadMainAccountDropdowns();
            LoadStats();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnAddMainAccount_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnAddSubAccount_Click(object sender, EventArgs e)
    {
        string mainAcc = ddlMainAccountForSub.SelectedValue;
        string name = txtSubAccName.Text.Trim();
        string details = txtSubAccDetails.Text.Trim();
        string accType = txtSubAccType.Text.Trim();
        string ledgerType = ddlLedgerTypeForSub.SelectedValue;

        if (string.IsNullOrEmpty(mainAcc) || string.IsNullOrEmpty(name))
        {
            ShowMessage("Please select a Main Account and enter Account Name.", false);
            return;
        }

        try
        {
            // Generate next account code
            string newCode = FinanceDB.ExecuteScalar<string>(
                "SELECT fin_NextAccountCode(@mainAcc) AS AccountCode FROM DUAL",
                FinanceDB.P("@mainAcc", mainAcc));

            if (string.IsNullOrEmpty(newCode))
            {
                ShowMessage("Error generating account code.", false);
                return;
            }

            FinanceDB.ExecuteNonQuerySP("AccountEditor",
                FinanceDB.P("@usr", HttpContext.Current.User.Identity.Name),
                FinanceDB.P("@AccCode", newCode),
                FinanceDB.P("@MainAccountCode", mainAcc),
                FinanceDB.P("@AccountName", name),
                FinanceDB.P("@Details", details),
                FinanceDB.P("@accountType", accType),
                FinanceDB.P("@collectionLedgerType", ledgerType));

            FinanceLogger.LogAction(PAGE_NAME, "AddSubAccount",
                "Code=" + newCode + " Main=" + mainAcc + " Name=" + name);
            AccountCache.InvalidateSubAccounts();

            ShowMessage("Sub account '" + newCode + " - " + name + "' created successfully.", true);
            txtSubAccName.Text = "";
            txtSubAccDetails.Text = "";
            txtSubAccType.Text = "";
            LoadSubAccounts(mainAcc);
            LoadStats();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnAddSubAccount_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void rptMainAccounts_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        string code = e.CommandArgument.ToString();
        if (e.CommandName == "ViewSubs")
        {
            ddlFilterMainAcc.SelectedValue = code;
            LoadSubAccounts(code);
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
                LoadMainAccounts();
                LoadMainAccountDropdowns();
                LoadStats();
            }
            catch (Exception ex)
            {
                FinanceLogger.LogError(PAGE_NAME, "DeleteMainAccount", ex);
                ShowMessage("Cannot delete: " + ex.Message, false);
            }
        }
    }

    protected void rptSubAccounts_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "DeleteSub")
        {
            string code = e.CommandArgument.ToString();
            try
            {
                FinanceDB.ExecuteNonQuerySP("DeleteAccount",
                    FinanceDB.P("@usr", HttpContext.Current.User.Identity.Name),
                    FinanceDB.P("@AccCode", code));

                FinanceLogger.LogAction(PAGE_NAME, "DeleteSubAccount", "Code=" + code);
                AccountCache.InvalidateSubAccounts();

                ShowMessage("Sub account deleted.", true);
                string filter = ddlFilterMainAcc.SelectedValue;
                LoadSubAccounts(string.IsNullOrEmpty(filter) ? null : filter);
                LoadStats();
            }
            catch (Exception ex)
            {
                FinanceLogger.LogError(PAGE_NAME, "DeleteSubAccount", ex);
                ShowMessage("Cannot delete: " + ex.Message, false);
            }
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        string cssClass = success ? "ft-toast ft-toast--success" : "ft-toast ft-toast--error";
        lblMessage.Text = "<div class='" + cssClass + "'>" + HttpUtility.HtmlEncode(msg) + "</div>";
        lblMessage.Visible = true;
    }
}
