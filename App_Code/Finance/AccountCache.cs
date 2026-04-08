using System;
using System.Data;
using System.Web;

/// <summary>
/// In-memory cache for frequently-accessed, rarely-changing finance reference data.
/// Uses HttpRuntime.Cache with configurable expiration.
///
/// Eliminates the repeated "SELECT AccountCode, AccountName FROM fin_subaccounts"
/// queries that run on EVERY page load across 6+ controllers (GeneralLedger,
/// JournalEntries, PaymentVouchers, ContraVouchers, etc.).
///
/// Cache policy:
///   - Sub-accounts: 10 minute sliding expiration
///   - Main accounts: 10 minute sliding expiration
///   - Account types: 30 minute sliding expiration  
///   - All caches can be explicitly invalidated via Invalidate*() methods
/// </summary>
public static class AccountCache
{
    private const string CK_SUBACCOUNTS      = "fin_subaccounts_all";
    private const string CK_SUBACCOUNT_COMBO = "fin_subaccounts_combo";
    private const string CK_MAINACCOUNTS     = "fin_mainaccounts_all";
    private const string CK_ACCOUNTTYPES     = "fin_accounttypes_map";

    private static readonly TimeSpan DefaultExpiry = TimeSpan.FromMinutes(10);
    private static readonly TimeSpan LongExpiry    = TimeSpan.FromMinutes(30);

    // ───────────────────────── Sub-Accounts ───────────────────────────────

    /// <summary>
    /// Returns all sub-accounts (AccountCode, AccountName, accounttype).
    /// Cached for 10 minutes. Used by ALL pages that have account dropdowns.
    /// </summary>
    public static DataTable GetSubAccounts()
    {
        return GetCachedDataTable(CK_SUBACCOUNTS,
            "SELECT AccountCode, AccountName, accounttype FROM fin_subaccounts ORDER BY AccountCode",
            DefaultExpiry);
    }

    /// <summary>
    /// Returns sub-accounts formatted for combo boxes: AccountCode, Display.
    /// Display = "AccountCode - AccountName"
    /// </summary>
    public static DataTable GetSubAccountsForCombo()
    {
        return GetCachedDataTable(CK_SUBACCOUNT_COMBO,
            "SELECT AccountCode, CONCAT(AccountCode, ' - ', AccountName) AS Display FROM fin_subaccounts ORDER BY AccountCode",
            DefaultExpiry);
    }

    /// <summary>
    /// Looks up the account type for a given account code.
    /// Uses the cached sub-accounts table to avoid a DB round-trip.
    /// </summary>
    public static string GetAccountType(string accountCode)
    {
        if (string.IsNullOrEmpty(accountCode)) return "";

        DataTable dt = GetSubAccounts();
        foreach (DataRow row in dt.Rows)
        {
            if (string.Equals(row["AccountCode"].ToString(), accountCode, StringComparison.OrdinalIgnoreCase))
            {
                return row["accounttype"] != DBNull.Value ? row["accounttype"].ToString() : "";
            }
        }
        return "";
    }

    /// <summary>
    /// Returns the account name for a given code, or empty string if not found.
    /// </summary>
    public static string GetAccountName(string accountCode)
    {
        if (string.IsNullOrEmpty(accountCode)) return "";

        DataTable dt = GetSubAccounts();
        foreach (DataRow row in dt.Rows)
        {
            if (string.Equals(row["AccountCode"].ToString(), accountCode, StringComparison.OrdinalIgnoreCase))
            {
                return row["AccountName"] != DBNull.Value ? row["AccountName"].ToString() : "";
            }
        }
        return "";
    }

    // ───────────────────────── Main Accounts ──────────────────────────────

    /// <summary>
    /// Returns all main (parent) accounts from fin_mainaccounts.
    /// </summary>
    public static DataTable GetMainAccounts()
    {
        return GetCachedDataTable(CK_MAINACCOUNTS,
            "SELECT AccountCode, AccountName, accounttype, header FROM fin_mainaccounts ORDER BY AccountCode",
            DefaultExpiry);
    }

    // ───────────────────────── Cache Invalidation ─────────────────────────

    /// <summary>
    /// Clears the sub-accounts cache. Call after adding/editing/deleting accounts
    /// from the Chart of Accounts page.
    /// </summary>
    public static void InvalidateSubAccounts()
    {
        HttpRuntime.Cache.Remove(CK_SUBACCOUNTS);
        HttpRuntime.Cache.Remove(CK_SUBACCOUNT_COMBO);
    }

    /// <summary>
    /// Clears the main accounts cache.
    /// </summary>
    public static void InvalidateMainAccounts()
    {
        HttpRuntime.Cache.Remove(CK_MAINACCOUNTS);
    }

    /// <summary>
    /// Clears ALL finance-related caches.
    /// </summary>
    public static void InvalidateAll()
    {
        InvalidateSubAccounts();
        InvalidateMainAccounts();
        HttpRuntime.Cache.Remove(CK_ACCOUNTTYPES);
    }

    // ───────────────────────── Dropdown Binding ───────────────────────────

    /// <summary>
    /// Binds a DropDownList with sub-accounts (Code - Name) and an optional "All" first item.
    /// Eliminates duplicated LoadAccountsDropDown() code across controllers.
    /// 
    /// Usage:
    ///   AccountCache.BindAccountDropDown(ddlAccount, includeAll: true, allText: "All Accounts");
    /// </summary>
    public static void BindAccountDropDown(
        System.Web.UI.WebControls.DropDownList ddl,
        bool includeAll = false,
        string allText = "All Accounts",
        string allValue = "")
    {
        DataTable dt = GetSubAccountsForCombo();
        ddl.DataSource = dt;
        ddl.DataTextField = "Display";
        ddl.DataValueField = "AccountCode";
        ddl.DataBind();

        if (includeAll)
        {
            ddl.Items.Insert(0, new System.Web.UI.WebControls.ListItem(allText, allValue));
        }
    }

    /// <summary>
    /// Binds a DropDownList with sub-accounts using "-- Select Account --" as first item.
    /// Used by PaymentVouchers and similar pages.
    /// </summary>
    public static void BindAccountDropDownWithSelect(
        System.Web.UI.WebControls.DropDownList ddl,
        string selectText = "-- Select Account --")
    {
        DataTable dt = GetSubAccounts();

        ddl.Items.Clear();
        ddl.Items.Add(new System.Web.UI.WebControls.ListItem(selectText, ""));

        foreach (DataRow row in dt.Rows)
        {
            string code = row["AccountCode"].ToString();
            string name = row["AccountName"].ToString();
            string display = code + " - " + name;
            ddl.Items.Add(new System.Web.UI.WebControls.ListItem(display, code));
        }
    }

    /// <summary>
    /// Binds a DevExpress ASPxComboBox with sub-accounts.
    /// Used by JournalEntries and ContraVouchers.
    /// </summary>
    public static void BindComboBox(DevExpress.Web.ASPxComboBox combo)
    {
        DataTable dt = GetSubAccounts();
        combo.DataSource = dt;
        combo.DataBind();
    }

    // ───────────────────────── Private Helpers ────────────────────────────

    private static DataTable GetCachedDataTable(string cacheKey, string sql, TimeSpan expiry)
    {
        DataTable dt = HttpRuntime.Cache[cacheKey] as DataTable;
        if (dt != null)
            return dt;

        dt = FinanceDB.ExecuteDataTable(sql);

        HttpRuntime.Cache.Insert(
            cacheKey,
            dt,
            null, // no file dependency
            System.Web.Caching.Cache.NoAbsoluteExpiration,
            expiry, // sliding expiration
            System.Web.Caching.CacheItemPriority.Normal,
            null);

        return dt;
    }
}
