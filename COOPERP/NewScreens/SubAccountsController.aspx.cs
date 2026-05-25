using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_SubAccountsController : System.Web.UI.Page
{
    private const string PAGE_NAME = "SubAccountsController";

    private string QueryFinancialYear { get { return (Request.QueryString["fy"] ?? string.Empty).Trim(); } }
    private string QueryMainFilter { get { return (Request.QueryString["main"] ?? string.Empty).Trim(); } }
    private string QueryLedgerFilter { get { return (Request.QueryString["ledger"] ?? string.Empty).Trim(); } }
    private string QuerySearch { get { return (Request.QueryString["q"] ?? string.Empty).Trim(); } }
    private int QueryPageSize { get { return NormalizePageSize(ParseInt(Request.QueryString["ps"], 50)); } }
    private int QueryPage { get { return Math.Max(1, ParseInt(Request.QueryString["pg"], 1)); } }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadFinancialYearDropdown();
        LoadMainAccountDropdowns();
        LoadLedgerTypesDropdown();
        LoadFilterLedgerDropdown();

        if (!IsPostBack)
        {
            BindFilterControlsFromQuery();
            LoadStats();
            BindSubAccountsPaged();
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

    private void BindSubAccountsPaged()
    {
        try
        {
            string mainFilter = QueryMainFilter;
            string ledgerFilter = QueryLedgerFilter;
            string search = QuerySearch;
            int pageSize = QueryPageSize;
            int page = QueryPage;
            DateTime fyStart;
            DateTime fyEndInclusive;
            string fyLabel;
            GetEffectiveFinancialYear(out fyStart, out fyEndInclusive, out fyLabel);
            DateTime fyEndExclusive = fyEndInclusive.Date.AddDays(1);

            List<MySqlParameter> sqlParams = new List<MySqlParameter>();
            List<string> where = new List<string>();

            if (!string.IsNullOrEmpty(mainFilter))
            {
                where.Add("MainAccountCode = @main");
                sqlParams.Add(FinanceDB.P("@main", mainFilter));
            }

            if (!string.IsNullOrEmpty(ledgerFilter))
            {
                where.Add("collectionLedgerType = @ledger");
                sqlParams.Add(FinanceDB.P("@ledger", ledgerFilter));
            }

            if (!string.IsNullOrEmpty(search))
            {
                where.Add("(AccountCode LIKE @q OR AccountName LIKE @q OR MainAccountCode LIKE @q OR Details LIKE @q OR accounttype LIKE @q)");
                sqlParams.Add(FinanceDB.P("@q", "%" + search + "%"));
            }

            string whereSql = where.Count > 0 ? (" WHERE " + string.Join(" AND ", where.ToArray())) : string.Empty;

            string countSql = "SELECT COUNT(*) AS total FROM fin_subaccounts" + whereSql;
            DataTable dtCount = FinanceDB.ExecuteDataTable(countSql, sqlParams.ToArray());
            int totalRows = 0;
            if (dtCount.Rows.Count > 0)
            {
                totalRows = Convert.ToInt32(dtCount.Rows[0]["total"]);
            }

            int pageCount = totalRows <= 0 ? 1 : (int)Math.Ceiling(totalRows / (double)pageSize);
            if (page > pageCount)
            {
                page = pageCount;
            }

            int offset = (page - 1) * pageSize;

            List<MySqlParameter> dataParams = new List<MySqlParameter>(sqlParams);
            dataParams.Add(FinanceDB.P("@fyStart", fyStart));
            dataParams.Add(FinanceDB.P("@fyEndEx", fyEndExclusive));
            dataParams.Add(FinanceDB.P("@offset", offset));
            dataParams.Add(FinanceDB.P("@ps", pageSize));

            string dataSql =
                "SELECT sa.AccountCode, sa.AccountName, sa.MainAccountCode, sa.Details, sa.accounttype, sa.collectionLedgerType, " +
                "COALESCE((SELECT SUM(CASE WHEN fl.transactionType = 'DR' THEN fl.transaction_amount ELSE 0 END) FROM fin_ledger fl WHERE fl.accountcode = sa.AccountCode AND fl.transactionDate >= @fyStart AND fl.transactionDate < @fyEndEx), 0) AS TotalDebit, " +
                "COALESCE((SELECT SUM(CASE WHEN fl.transactionType = 'CR' THEN fl.transaction_amount ELSE 0 END) FROM fin_ledger fl WHERE fl.accountcode = sa.AccountCode AND fl.transactionDate >= @fyStart AND fl.transactionDate < @fyEndEx), 0) AS TotalCredit, " +
                "COALESCE((SELECT SUM(CASE WHEN fl.transactionType = 'DR' THEN fl.transaction_amount ELSE 0 END) FROM fin_ledger fl WHERE fl.accountcode = sa.AccountCode AND fl.transactionDate >= @fyStart AND fl.transactionDate < @fyEndEx), 0) - " +
                "COALESCE((SELECT SUM(CASE WHEN fl.transactionType = 'CR' THEN fl.transaction_amount ELSE 0 END) FROM fin_ledger fl WHERE fl.accountcode = sa.AccountCode AND fl.transactionDate >= @fyStart AND fl.transactionDate < @fyEndEx), 0) AS Balance " +
                "FROM fin_subaccounts sa" + whereSql +
                " ORDER BY sa.AccountCode LIMIT @offset, @ps";

            DataTable dt = FinanceDB.ExecuteDataTable(dataSql, dataParams.ToArray());
            rptSubAccounts.DataSource = dt;
            rptSubAccounts.DataBind();
            phNoSub.Visible = (dt.Rows.Count == 0);

            int from = totalRows == 0 ? 0 : offset + 1;
            int to = Math.Min(offset + pageSize, totalRows);

            litFrom.Text = from.ToString("N0");
            litTo.Text = to.ToString("N0");
            litTotal.Text = totalRows.ToString("N0");
            litPage.Text = page.ToString("N0");
            litPageCount.Text = pageCount.ToString("N0");
            litSubFooter.Text = string.Format("<strong>{0}</strong> sub accounts", totalRows.ToString("N0"));
            litPagerTop.Text = BuildPager(page, pageCount);
            litPagerBottom.Text = BuildPager(page, pageCount);

            if (!string.IsNullOrEmpty(mainFilter))
            {
                litSubBadge.Text = string.Format("<span class='pm-chip'>Filtered: {0}</span> <span class='pm-chip'>FY: {1}</span>", HttpUtility.HtmlEncode(mainFilter), HttpUtility.HtmlEncode(fyLabel));
            }
            else
            {
                litSubBadge.Text = string.Format("<span class='pm-chip'>Showing all</span> <span class='pm-chip'>FY: {0}</span>", HttpUtility.HtmlEncode(fyLabel));
            }
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "BindSubAccountsPaged", ex);
            ShowMessage("Error loading sub accounts: " + ex.Message, false);
        }
    }

    private void BindFilterControlsFromQuery()
    {
        if (!string.IsNullOrEmpty(QueryFinancialYear) && ddlFinancialYear.Items.FindByValue(QueryFinancialYear) != null)
        {
            ddlFinancialYear.SelectedValue = QueryFinancialYear;
        }

        if (!string.IsNullOrEmpty(QueryMainFilter) && ddlFilterMainAcc.Items.FindByValue(QueryMainFilter) != null)
        {
            ddlFilterMainAcc.SelectedValue = QueryMainFilter;
        }

        if (!string.IsNullOrEmpty(QueryLedgerFilter) && ddlFilterLedger.Items.FindByValue(QueryLedgerFilter) != null)
        {
            ddlFilterLedger.SelectedValue = QueryLedgerFilter;
        }

        txtSearch.Text = QuerySearch;

        string pageSizeText = QueryPageSize.ToString();
        if (ddlPageSize.Items.FindByValue(pageSizeText) != null)
        {
            ddlPageSize.SelectedValue = pageSizeText;
        }
        else
        {
            ddlPageSize.SelectedValue = "50";
        }
    }

    private void LoadFinancialYearDropdown()
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            "SELECT id, finacial_Year, status FROM fin_financial_years ORDER BY start_date DESC");

        ddlFinancialYear.Items.Clear();
        ddlFinancialYear.Items.Add(new ListItem("Active Financial Year", ""));

        foreach (DataRow row in dt.Rows)
        {
            string id = row["id"].ToString();
            string label = row["finacial_Year"].ToString();
            string status = row["status"].ToString();
            if (!string.IsNullOrEmpty(status))
            {
                label += " (" + status + ")";
            }
            ddlFinancialYear.Items.Add(new ListItem(label, id));
        }
    }

    private void LoadMainAccountDropdowns()
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            "SELECT AccountCode, AccountName FROM fin_mainaccounts ORDER BY AccountCode");

        ddlMainAccountForSub.Items.Clear();
        ddlMainAccountForSub.Items.Add(new ListItem("-- Select Main Account --", ""));

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

    private void LoadFilterLedgerDropdown()
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            "SELECT LedgerTypeName FROM fin_ledgertypes ORDER BY LedgerTypeName");

        ddlFilterLedger.Items.Clear();
        ddlFilterLedger.Items.Add(new ListItem("All Ledger Types", ""));

        foreach (DataRow row in dt.Rows)
        {
            string name = row["LedgerTypeName"].ToString();
            ddlFilterLedger.Items.Add(new ListItem(name, name));
        }
    }

    protected void btnAddSubAccount_Click(object sender, EventArgs e)
    {
        bool isEdit = !string.IsNullOrEmpty(hdnEditSubCode.Value);
        string mainAcc = ddlMainAccountForSub.SelectedValue;
        string name = txtSubAccName.Text.Trim();
        string details = txtSubAccDetails.Text.Trim();
        string accType = txtSubAccType.Text.Trim();
        string ledgerType = ddlLedgerTypeForSub.SelectedValue;

        if (string.IsNullOrEmpty(mainAcc) || string.IsNullOrEmpty(name))
        {
            ShowMessage("Please select a Main Account and enter Account Name.", false);
            BindFilterControlsFromQuery();
            LoadStats();
            BindSubAccountsPaged();
            return;
        }

        try
        {
            string targetCode = hdnEditSubCode.Value;
            if (!isEdit)
            {
                targetCode = FinanceDB.ExecuteScalar<string>(
                    "SELECT fin_NextAccountCode(@mainAcc) AS AccountCode FROM DUAL",
                    FinanceDB.P("@mainAcc", mainAcc));

                if (string.IsNullOrEmpty(targetCode))
                {
                    ShowMessage("Error generating account code.", false);
                    BindFilterControlsFromQuery();
                    LoadStats();
                    BindSubAccountsPaged();
                    return;
                }
            }

            FinanceDB.ExecuteNonQuerySP("AccountEditor",
                FinanceDB.P("@usr", HttpContext.Current.User.Identity.Name),
                FinanceDB.P("@AccCode", targetCode),
                FinanceDB.P("@MainAccountCode", mainAcc),
                FinanceDB.P("@AccountName", name),
                FinanceDB.P("@Details", details),
                FinanceDB.P("@accountType", accType),
                FinanceDB.P("@collectionLedgerType", ledgerType));

            FinanceLogger.LogAction(PAGE_NAME, isEdit ? "EditSubAccount" : "AddSubAccount",
                "Code=" + targetCode + " Main=" + mainAcc + " Name=" + name);
            AccountCache.InvalidateSubAccounts();

            ShowMessage(isEdit
                ? "Sub account '" + targetCode + " - " + name + "' updated successfully."
                : "Sub account '" + targetCode + " - " + name + "' created successfully.", true);
            ResetEditState();

            string targetUrl = BuildPageUrl(1, mainAcc, QueryLedgerFilter, QuerySearch, QueryPageSize);
            Response.Redirect(targetUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnAddSubAccount_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
            BindFilterControlsFromQuery();
            LoadStats();
            BindSubAccountsPaged();
        }
    }

    protected void rptSubAccounts_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "EditSub")
        {
            string code = e.CommandArgument.ToString();
            try
            {
                DataTable dt = FinanceDB.ExecuteDataTable(
                    "SELECT AccountCode, MainAccountCode, AccountName, Details, accounttype, collectionLedgerType FROM fin_subaccounts WHERE AccountCode = @code LIMIT 1",
                    FinanceDB.P("@code", code));

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Sub account not found for edit.", false);
                    return;
                }

                DataRow row = dt.Rows[0];
                hdnEditSubCode.Value = row["AccountCode"].ToString();
                if (ddlMainAccountForSub.Items.FindByValue(row["MainAccountCode"].ToString()) != null)
                {
                    ddlMainAccountForSub.SelectedValue = row["MainAccountCode"].ToString();
                }
                txtSubAccName.Text = row["AccountName"].ToString();
                txtSubAccDetails.Text = row["Details"].ToString();
                txtSubAccType.Text = row["accounttype"].ToString();
                if (ddlLedgerTypeForSub.Items.FindByValue(row["collectionLedgerType"].ToString()) != null)
                {
                    ddlLedgerTypeForSub.SelectedValue = row["collectionLedgerType"].ToString();
                }

                btnAddSubAccount.Text = "Update Sub Account";
                btnCancelEdit.Visible = true;
                ShowMessage("Editing sub account '" + HttpUtility.HtmlEncode(code) + "'.", true);
            }
            catch (Exception ex)
            {
                FinanceLogger.LogError(PAGE_NAME, "EditSubAccount", ex);
                ShowMessage("Cannot edit: " + ex.Message, false);
                LoadStats();
                BindFilterControlsFromQuery();
                BindSubAccountsPaged();
            }
        }
    }

    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        ResetEditState();
        ShowMessage("Edit cancelled.", true);
        LoadStats();
        BindFilterControlsFromQuery();
        BindSubAccountsPaged();
    }

    private void ResetEditState()
    {
        hdnEditSubCode.Value = string.Empty;
        txtSubAccName.Text = string.Empty;
        txtSubAccDetails.Text = string.Empty;
        txtSubAccType.Text = string.Empty;
        btnAddSubAccount.Text = "Add Sub Account";
        btnCancelEdit.Visible = false;
        if (ddlMainAccountForSub.Items.Count > 0)
        {
            ddlMainAccountForSub.SelectedIndex = 0;
        }
        if (ddlLedgerTypeForSub.Items.Count > 0)
        {
            ddlLedgerTypeForSub.SelectedIndex = 0;
        }
    }

    private string BuildPager(int currentPage, int pageCount)
    {
        if (pageCount <= 1)
        {
            return string.Empty;
        }

        StringBuilder sb = new StringBuilder();
        int start = Math.Max(1, currentPage - 3);
        int end = Math.Min(pageCount, currentPage + 3);

        if (currentPage > 1)
        {
            sb.Append("<a href='").Append(HttpUtility.HtmlAttributeEncode(BuildPageUrl(currentPage - 1, QueryMainFilter, QueryLedgerFilter, QuerySearch, QueryPageSize))).Append("'>&laquo; Prev</a>");
        }

        for (int i = start; i <= end; i++)
        {
            if (i == currentPage)
            {
                sb.Append("<span class='active'>").Append(i).Append("</span>");
            }
            else
            {
                sb.Append("<a href='").Append(HttpUtility.HtmlAttributeEncode(BuildPageUrl(i, QueryMainFilter, QueryLedgerFilter, QuerySearch, QueryPageSize))).Append("'>").Append(i).Append("</a>");
            }
        }

        if (currentPage < pageCount)
        {
            sb.Append("<a href='").Append(HttpUtility.HtmlAttributeEncode(BuildPageUrl(currentPage + 1, QueryMainFilter, QueryLedgerFilter, QuerySearch, QueryPageSize))).Append("'>Next &raquo;</a>");
        }

        return sb.ToString();
    }

    private string BuildPageUrl(int page, string main, string ledger, string q, int pageSize)
    {
        List<string> parts = new List<string>();
        parts.Add("pg=" + page);

        if (!string.IsNullOrEmpty(QueryFinancialYear))
        {
            parts.Add("fy=" + HttpUtility.UrlEncode(QueryFinancialYear));
        }

        if (!string.IsNullOrEmpty(main))
        {
            parts.Add("main=" + HttpUtility.UrlEncode(main));
        }

        if (!string.IsNullOrEmpty(ledger))
        {
            parts.Add("ledger=" + HttpUtility.UrlEncode(ledger));
        }

        if (!string.IsNullOrEmpty(q))
        {
            parts.Add("q=" + HttpUtility.UrlEncode(q));
        }

        parts.Add("ps=" + pageSize);

        return "SubAccountsController.aspx?" + string.Join("&", parts.ToArray());
    }

    private static int ParseInt(string value, int fallback)
    {
        int result;
        return int.TryParse(value, out result) ? result : fallback;
    }

    private static int NormalizePageSize(int value)
    {
        if (value <= 25) return 25;
        if (value <= 50) return 50;
        if (value <= 100) return 100;
        return 200;
    }

    private void GetEffectiveFinancialYear(out DateTime startDate, out DateTime endDate, out string label)
    {
        string fyId = QueryFinancialYear;
        if (!string.IsNullOrEmpty(fyId))
        {
            try
            {
                DataTable dt = FinanceDB.ExecuteDataTable(
                    "SELECT finacial_Year, start_date, end_date FROM fin_financial_years WHERE id = @id LIMIT 1",
                    FinanceDB.P("@id", fyId));

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    startDate = row["start_date"] != DBNull.Value ? Convert.ToDateTime(row["start_date"]) : new DateTime(DateTime.Today.Year, 1, 1);
                    endDate = row["end_date"] != DBNull.Value ? Convert.ToDateTime(row["end_date"]) : new DateTime(DateTime.Today.Year, 12, 31);
                    label = row["finacial_Year"] != DBNull.Value ? Convert.ToString(row["finacial_Year"]) : DateTime.Today.Year.ToString();
                    return;
                }
            }
            catch (Exception ex)
            {
                FinanceLogger.LogError(PAGE_NAME, "GetEffectiveFinancialYear.Selected", ex);
            }
        }

        GetActiveFinancialYear(out startDate, out endDate, out label);
    }

    protected string RenderMoneyCell(object value, string kind)
    {
        decimal amount = 0m;
        if (value != null && value != DBNull.Value)
        {
            decimal.TryParse(Convert.ToString(value), out amount);
        }

        string color = "#05275C";
        string weight = "700";

        switch ((kind ?? string.Empty).ToLower())
        {
            case "debit":
                color = "#b42318";
                weight = "700";
                break;
            case "credit":
                color = "#15803d";
                weight = "700";
                break;
            case "balance":
                color = amount == 0m ? "#6b7280" : "#b42318";
                weight = "800";
                break;
        }

        return string.Format(
            "<span class='pm-money' style='color:{0};font-weight:{1};display:block;text-align:right;font-variant-numeric:tabular-nums;'>{2}</span>",
            color,
            weight,
            amount.ToString("N2"));
    }

    private void GetActiveFinancialYear(out DateTime startDate, out DateTime endDate, out string label)
    {
        startDate = new DateTime(DateTime.Today.Year, 1, 1);
        endDate = new DateTime(DateTime.Today.Year, 12, 31);
        label = DateTime.Today.Year.ToString();

        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                "SELECT finacial_Year, start_date, end_date FROM fin_financial_years WHERE status = 'Open' ORDER BY end_date DESC LIMIT 1");

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                if (row["start_date"] != DBNull.Value)
                {
                    startDate = Convert.ToDateTime(row["start_date"]);
                }
                if (row["end_date"] != DBNull.Value)
                {
                    endDate = Convert.ToDateTime(row["end_date"]);
                }
                if (row["finacial_Year"] != DBNull.Value)
                {
                    label = Convert.ToString(row["finacial_Year"]);
                }
            }
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "GetActiveFinancialYear", ex);
        }
    }

    private void ShowMessage(string msg, bool success)
    {
        string cssClass = success ? "pm-alert pm-alert--ok" : "pm-alert pm-alert--err";
        lblMessage.Text = "<div class='" + cssClass + "'>" + HttpUtility.HtmlEncode(msg) + "</div>";
        lblMessage.Visible = true;
    }
}
