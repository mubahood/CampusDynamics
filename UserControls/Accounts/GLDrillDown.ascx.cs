using DevExpress.Web;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Security;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class UserControls_Accounts_GLDrillDown : System.Web.UI.UserControl
{
    private class AccountSummary
    {
        public string Category = "";
        public string SubCategory = "";
        public string AccountCode = "";
        public string AccountName = "";
        public decimal DRBalance = 0;
        public decimal CRBalance = 0;
    }

    private class OpeningBalanceInfo
    {
        public string Category = "";
        public string SubCategory = "";
        public string AccountCode = "";
        public string AccountName = "";
        public decimal OpeningBalance = 0;

        public decimal OpeningDR
        {
            get { return OpeningBalance > 0 ? OpeningBalance : 0; }
        }

        public decimal OpeningCR
        {
            get { return OpeningBalance < 0 ? Math.Abs(OpeningBalance) : 0; }
        }
    }

    private class DetailAccount
    {
        public string Category = "";
        public string SubCategory = "";
        public string AccountCode = "";
        public string AccountName = "";
        public decimal DRBalance = 0;
        public decimal CRBalance = 0;
        public decimal OpeningBalance = 0;
    }

    private class ConsolidatedBucketInfo
    {
        public string Category = "";
        public string SubCategory = "";
        public string AccountCode = "";
        public string AccountName = "";

        public decimal OpeningDR = 0;
        public decimal OpeningCR = 0;
        public decimal SBCollectionsDR = 0;
        public decimal SBCollectionsCR = 0;
        public decimal CBCollectionsDR = 0;
        public decimal CBCollectionsCR = 0;
        public decimal LoanDR = 0;
        public decimal LoanCR = 0;
        public decimal DfcuDR = 0;
        public decimal DfcuCR = 0;
        public decimal CBOperationsDR = 0;
        public decimal CBOperationsCR = 0;
        public decimal PcMasakaDR = 0;
        public decimal PcMasakaCR = 0;
        public decimal PcKampalaDR = 0;
        public decimal PcKampalaCR = 0;
        public decimal JournalDR = 0;
        public decimal JournalCR = 0;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        pop_msgbox.HeaderText = "Campus Dynamics ERP";

        if (!IsPostBack)
        {
            if (DateTime.Today.Month > 7)
                txtStartDate.Value = new DateTime(DateTime.Today.Year, 8, 1);
            else
                txtStartDate.Value = new DateTime(DateTime.Today.Year - 1, 8, 1);

            txtEndDate.Value = DateTime.Today;
        }
    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        Server.ScriptTimeout = 1800;
        ExportThreeTabTrialBalance(txtStartDate.Date, txtEndDate.Date);
    }

    private void ExportThreeTabTrialBalance(DateTime sDate, DateTime eDate)
    {
        DataTable openingRows = GetOpeningBalancesForExport(sDate);
        DataTable txns = GetAllTransactionDetailsForExport(sDate, eDate);

        Dictionary<string, OpeningBalanceInfo> openingMap = BuildOpeningMap(openingRows);
        Dictionary<string, List<DataRow>> txnMap = BuildTransactionMap(txns);

        List<AccountSummary> summaryAccounts = BuildConsolidatedSummaryAccountList(openingMap, txns);
        List<DetailAccount> detailAccounts = BuildDetailAccountListFromSummaryAccounts(summaryAccounts, openingMap);

        StringBuilder sb = new StringBuilder();

        sb.AppendLine("<?xml version=\"1.0\"?>");
        sb.AppendLine("<?mso-application progid=\"Excel.Sheet\"?>");
        sb.AppendLine("<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"");
        sb.AppendLine(" xmlns:o=\"urn:schemas-microsoft-com:office:office\"");
        sb.AppendLine(" xmlns:x=\"urn:schemas-microsoft-com:office:excel\"");
        sb.AppendLine(" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\">");

        WriteStyles(sb);

        WriteSummarySheet(sb, summaryAccounts, sDate, eDate);
        WriteOpeningBalancesSheet(sb, openingMap, sDate);
        WriteDetailedTrialBalanceSheet(sb, detailAccounts, txnMap, sDate, eDate);

        sb.AppendLine("</Workbook>");

        string fileName =
            "TRIAL_BALANCE_3_TABS_" +
            sDate.ToString("yyyyMMdd") +
            "_to_" +
            eDate.ToString("yyyyMMdd") +
            ".xls";

        HttpResponse response = HttpContext.Current.Response;
        response.Clear();
        response.Buffer = true;
        response.ContentEncoding = Encoding.UTF8;
        response.Charset = "utf-8";
        response.ContentType = "application/vnd.ms-excel";
        response.AddHeader("Content-Disposition", "attachment;filename=" + fileName);
        response.Write(sb.ToString());
        response.Flush();
        response.End();
    }

    private DataTable GetTrialBalance(DateTime sDate, DateTime eDate)
    {
        return ExecuteStoredProcedure(
            "fin_TrialBalance",
            new string[] { "sDate", "eDate" },
            new object[] { sDate.ToString("yyyy-MM-dd"), eDate.ToString("yyyy-MM-dd") }
        );
    }

    private DataTable ExecuteStoredProcedure(string procedureName, string[] parameterNames, object[] parameterValues)
    {
        DataTable dt = new DataTable();

        using (MySqlConnection conn = new MySqlConnection(GetAccountsConnectionString()))
        {
            conn.Open();

            using (MySqlCommand cmd = new MySqlCommand(procedureName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 900;

                for (int i = 0; i < parameterNames.Length; i++)
                    cmd.Parameters.AddWithValue(parameterNames[i], parameterValues[i]);

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        return dt;
    }


    private List<AccountSummary> BuildConsolidatedSummaryAccountList(
        Dictionary<string, OpeningBalanceInfo> openingMap,
        DataTable txns)
    {
        Dictionary<string, ConsolidatedBucketInfo> map = new Dictionary<string, ConsolidatedBucketInfo>();

        foreach (string key in openingMap.Keys)
        {
            OpeningBalanceInfo opening = openingMap[key];
            string accountCode = NormalizeConsolidatedAccountCode(opening.AccountCode);
            ConsolidatedBucketInfo bucket = GetOrCreateConsolidatedBucket(map, accountCode, opening.Category, opening.SubCategory, opening.AccountName);
            bucket.OpeningDR += opening.OpeningDR;
            bucket.OpeningCR += opening.OpeningCR;
        }

        for (int i = 0; i < txns.Rows.Count; i++)
        {
            DataRow row = txns.Rows[i];
            if (ShouldSkipConsolidatedRow(row))
                continue;

            string rawAccountCode = GetValue(row, "accountcode").Trim();

            if (string.IsNullOrEmpty(rawAccountCode))
                continue;

            string accountCode = NormalizeConsolidatedAccountCode(rawAccountCode, GetValue(row, "particulars"), GetValue(row, "acc_name"), GetValue(row, "source_system"), GetValue(row, "RefNo"), GetValue(row, "journal_no"), GetValue(row, "voucherNo"));
            string accountName = GetConsolidatedAccountName(accountCode, GetValue(row, "acc_name"));
            string category = GetConsolidatedCategory(accountCode, GetValue(row, "category"));
            string subCategory = GetConsolidatedSubCategory(accountCode, GetValue(row, "subcategory"));

            ConsolidatedBucketInfo bucket = GetOrCreateConsolidatedBucket(map, accountCode, category, subCategory, accountName);

            string sourceBucket = GetSourceBucket(GetValue(row, "source_system"));
            string transactionType = GetValue(row, "transactionType").Trim().ToUpperInvariant();
            decimal amount = ToDecimal(GetValue(row, "transaction_amount"));

            AddAmountToSourceBucket(bucket, sourceBucket, transactionType, amount);
        }

        List<AccountSummary> accounts = new List<AccountSummary>();

        foreach (ConsolidatedBucketInfo bucket in map.Values)
        {
            decimal drBalance;
            decimal crBalance;
            CalculateConsolidatedBalances(bucket, out drBalance, out crBalance);

            if (drBalance == 0 && crBalance == 0)
                continue;

            AccountSummary account = new AccountSummary();
            account.Category = bucket.Category;
            account.SubCategory = bucket.SubCategory;
            account.AccountCode = bucket.AccountCode;
            account.AccountName = bucket.AccountName;
            account.DRBalance = drBalance;
            account.CRBalance = crBalance;
            accounts.Add(account);
        }

        SortSummaryAccounts(accounts);
        return accounts;
    }

    private ConsolidatedBucketInfo GetOrCreateConsolidatedBucket(
        Dictionary<string, ConsolidatedBucketInfo> map,
        string accountCode,
        string category,
        string subCategory,
        string accountName)
    {
        string key = accountCode.Trim().ToUpperInvariant();

        if (!map.ContainsKey(key))
        {
            ConsolidatedBucketInfo bucket = new ConsolidatedBucketInfo();
            bucket.AccountCode = accountCode;
            map[key] = bucket;
        }

        if (!string.IsNullOrEmpty(category))
            map[key].Category = category;

        if (!string.IsNullOrEmpty(subCategory))
            map[key].SubCategory = subCategory;

        if (!string.IsNullOrEmpty(accountName))
            map[key].AccountName = accountName;

        return map[key];
    }

    private bool ShouldSkipConsolidatedRow(DataRow row)
    {
        string source = GetValue(row, "source_system").Trim().ToUpperInvariant();
        string code = GetValue(row, "accountcode").Trim().ToUpperInvariant();
        string refNo = GetValue(row, "RefNo").Trim().ToUpperInvariant();
        string journalNo = GetValue(row, "journal_no").Trim().ToUpperInvariant();

        if (source == "PC_KAMPALA" && code == "AC2028")
        {
            if (refNo == "PCK-20240731-000385" ||
                refNo == "PCK-20240731-000387" ||
                refNo == "PCK-20240731-000388" ||
                refNo == "PCK-20240731-000389" ||
                journalNo == "PCK-20240731-000385" ||
                journalNo == "PCK-20240731-000387" ||
                journalNo == "PCK-20240731-000388" ||
                journalNo == "PCK-20240731-000389")
            {
                return true;
            }
        }

        return false;
    }

    private string NormalizeConsolidatedAccountCode(string accountCode)
    {
        return NormalizeConsolidatedAccountCode(accountCode, "", "", "", "", "", "");
    }

    private string NormalizeConsolidatedAccountCode(string accountCode, string particulars, string accountName)
    {
        return NormalizeConsolidatedAccountCode(accountCode, particulars, accountName, "", "", "", "");
    }

    private string NormalizeConsolidatedAccountCode(string accountCode, string particulars, string accountName, string sourceSystem, string refNo, string journalNo, string voucherNo)
    {
        string code = (accountCode ?? "").Trim().ToUpperInvariant();
        string p = ((particulars ?? "") + " " + (accountName ?? "")).Trim().ToUpperInvariant();
        string source = (sourceSystem ?? "").Trim().ToUpperInvariant();
        string refText = ((refNo ?? "") + " " + (journalNo ?? "") + " " + (voucherNo ?? "")).Trim().ToUpperInvariant();

        if (source == "CB_COLLECTIONS" && code == "AC2130" && p.Contains("LOANS STANDING ORDER"))
            return "AC1321";

        if (source == "CB_OPERATIONS" && code == "AC2098" && (refText.Contains("CBOP-20250723-000768") || refText.Contains("4450")))
            return "AC2156";

        if (code == "AC1323" || code == "AC1324" || code == "AC1325" || code == "AC1326")
            return "AC6006";

        if (code == "AC9012")
            return "AC8037";

        if (code == "AC2136")
            return "AC2137";

        if (code == "AC2119" && p.Contains("LOCAL SERVICE TAX"))
            return "AC2119_LST";

        return code;
    }

    private string GetDisplayAccountCode(string accountCode)
    {
        string code = (accountCode ?? "").Trim().ToUpperInvariant();

        if (code == "AC2119_LST")
            return "AC2119";

        return accountCode;
    }

    private string GetConsolidatedAccountName(string accountCode, string currentName)
    {
        string code = (accountCode ?? "").Trim().ToUpperInvariant();

        if (code == "AC6006")
            return "STUDENT REVENUE";

        if (code == "AC1321")
            return "CENTENARY BANK UGX 3810300168-Loan account";

        if (code == "AC8037")
            return "SOFTWARE COST";

        if (code == "AC2137")
            return "WATER BILLS";

        if (code == "AC2119_LST")
            return "LOCAL SERVICE TAX";

        if (code == "AC2156")
            return "GRANT EXPENSES";

        return currentName;
    }

    private string GetConsolidatedCategory(string accountCode, string currentCategory)
    {
        string code = (accountCode ?? "").Trim().ToUpperInvariant();

        if (code == "AC6006")
            return "Income";

        if (code == "AC2119_LST")
            return "Expense";

        if (code == "AC2156")
            return "Expense";

        return currentCategory;
    }

    private string GetConsolidatedSubCategory(string accountCode, string currentSubCategory)
    {
        string code = (accountCode ?? "").Trim().ToUpperInvariant();

        if (code == "AC6006")
            return "INCOME";

        if (code == "AC2119_LST")
            return "EMPLOYMENT EXPENSES";

        if (code == "AC2156")
            return "ACADEMIC EXPENSES";

        return currentSubCategory;
    }

    private string GetSourceBucket(string sourceSystem)
    {
        string source = (sourceSystem ?? "").Trim().ToUpperInvariant();

        if (source == "SB_COLLECTIONS") return "SB";
        if (source == "CB_COLLECTIONS") return "CB";
        if (source == "LOAN") return "LOAN";
        if (source == "DFCU") return "DFCU";
        if (source == "CB_OPERATIONS") return "CBOP";
        if (source == "PC_MASAKA" || source == "PC-MASAKA") return "PCMASAKA";
        if (source == "PC_KAMPALA" || source == "PC-KAMPALA") return "PCKAMPALA";
        if (source == "JOURNAL_VOUCHERS") return "JOURNAL";

        return "JOURNAL";
    }

    private void AddAmountToSourceBucket(ConsolidatedBucketInfo bucket, string sourceBucket, string transactionType, decimal amount)
    {
        bool isDebit = transactionType == "DR";
        bool isCredit = transactionType == "CR";

        if (!isDebit && !isCredit)
            return;

        if (sourceBucket == "SB")
        {
            if (isDebit) bucket.SBCollectionsDR += amount; else bucket.SBCollectionsCR += amount;
        }
        else if (sourceBucket == "CB")
        {
            if (isDebit) bucket.CBCollectionsDR += amount; else bucket.CBCollectionsCR += amount;
        }
        else if (sourceBucket == "LOAN")
        {
            if (isDebit) bucket.LoanDR += amount; else bucket.LoanCR += amount;
        }
        else if (sourceBucket == "DFCU")
        {
            if (isDebit) bucket.DfcuDR += amount; else bucket.DfcuCR += amount;
        }
        else if (sourceBucket == "CBOP")
        {
            if (isDebit) bucket.CBOperationsDR += amount; else bucket.CBOperationsCR += amount;
        }
        else if (sourceBucket == "PCMASAKA")
        {
            if (isDebit) bucket.PcMasakaDR += amount; else bucket.PcMasakaCR += amount;
        }
        else if (sourceBucket == "PCKAMPALA")
        {
            if (isDebit) bucket.PcKampalaDR += amount; else bucket.PcKampalaCR += amount;
        }
        else
        {
            if (isDebit) bucket.JournalDR += amount; else bucket.JournalCR += amount;
        }
    }

    private void SetDrCrFromSignedBalance(decimal signedBalance, out decimal drBalance, out decimal crBalance)
    {
        if (signedBalance > 0)
        {
            drBalance = signedBalance;
            crBalance = 0;
        }
        else if (signedBalance < 0)
        {
            drBalance = 0;
            crBalance = Math.Abs(signedBalance);
        }
        else
        {
            drBalance = 0;
            crBalance = 0;
        }
    }

    private void AddSignedAmountToTotals(decimal signedBalance, ref decimal drBalance, ref decimal crBalance)
    {
        if (signedBalance > 0)
            drBalance += signedBalance;
        else if (signedBalance < 0)
            crBalance += Math.Abs(signedBalance);
    }

    private void CalculateConsolidatedBalances(ConsolidatedBucketInfo bucket, out decimal drBalance, out decimal crBalance)
    {
        string code = (bucket.AccountCode ?? "").Trim().ToUpperInvariant();
        string category = (bucket.Category ?? "").Trim().ToUpperInvariant();

        drBalance = 0;
        crBalance = 0;

        decimal openingNet = bucket.OpeningDR - bucket.OpeningCR;
        decimal sbNet = bucket.SBCollectionsDR - bucket.SBCollectionsCR;
        decimal cbNet = bucket.CBCollectionsDR - bucket.CBCollectionsCR;
        decimal loanNet = bucket.LoanDR - bucket.LoanCR;
        decimal dfcuNet = bucket.DfcuDR - bucket.DfcuCR;
        decimal cbopNet = bucket.CBOperationsDR - bucket.CBOperationsCR;
        decimal pcMasakaNet = bucket.PcMasakaDR - bucket.PcMasakaCR;
        decimal pcKampalaNet = bucket.PcKampalaDR - bucket.PcKampalaCR;
        decimal journalNet = bucket.JournalDR - bucket.JournalCR;

        if (code == "AC1102")
        {
            AddSignedAmountToTotals(cbopNet, ref drBalance, ref crBalance);
            return;
        }

        if (code == "AC1103")
        {
            AddSignedAmountToTotals(journalNet, ref drBalance, ref crBalance);
            return;
        }

        if (code == "AC1301")
        {
            SetDrCrFromSignedBalance(openingNet + cbopNet, out drBalance, out crBalance);
            return;
        }

        if (code == "AC1302")
        {
            SetDrCrFromSignedBalance(openingNet + sbNet, out drBalance, out crBalance);
            return;
        }

        if (code == "AC1303")
        {
            SetDrCrFromSignedBalance(openingNet + cbNet, out drBalance, out crBalance);
            return;
        }

        if (code == "AC1304")
        {
            SetDrCrFromSignedBalance(openingNet + cbopNet + pcKampalaNet, out drBalance, out crBalance);
            return;
        }

        if (code == "AC1305")
        {
            SetDrCrFromSignedBalance(openingNet + cbopNet + pcMasakaNet, out drBalance, out crBalance);
            return;
        }

        if (code == "AC1308")
        {
            SetDrCrFromSignedBalance(dfcuNet, out drBalance, out crBalance);
            return;
        }

        if (code == "AC1321")
        {
            SetDrCrFromSignedBalance(-bucket.OpeningCR - bucket.LoanCR + bucket.CBCollectionsDR, out drBalance, out crBalance);
            return;
        }

        if (code == "AC1322")
        {
            drBalance = bucket.OpeningDR;
            crBalance = 0;
            return;
        }

        if (category == "ASSETS" || category == "LIABILITIES" || category == "EQUITY")
        {
            AddSignedAmountToTotals(openingNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(cbopNet, ref drBalance, ref crBalance);

            if (code == "AC9018")
            {
                drBalance += bucket.JournalDR;
                crBalance += bucket.JournalCR;
            }
            else
            {
                AddSignedAmountToTotals(journalNet, ref drBalance, ref crBalance);
            }

            if (code == "AC9023")
                AddSignedAmountToTotals(sbNet, ref drBalance, ref crBalance);

            return;
        }

        if (code == "AC2145")
        {
            AddSignedAmountToTotals(openingNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(sbNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(cbNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(loanNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(dfcuNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(cbopNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(pcMasakaNet, ref drBalance, ref crBalance);
            AddSignedAmountToTotals(pcKampalaNet, ref drBalance, ref crBalance);
            drBalance += bucket.JournalDR;
            crBalance += bucket.JournalCR;
            return;
        }

        AddSignedAmountToTotals(openingNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(sbNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(cbNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(loanNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(dfcuNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(cbopNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(pcMasakaNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(pcKampalaNet, ref drBalance, ref crBalance);
        AddSignedAmountToTotals(journalNet, ref drBalance, ref crBalance);
    }

    private List<AccountSummary> BuildSummaryAccountList(DataTable tb)
    {
        List<AccountSummary> accounts = new List<AccountSummary>();

        for (int i = 0; i < tb.Rows.Count; i++)
        {
            DataRow row = tb.Rows[i];
            string accountCode = GetValue(row, "accountcode").Trim();

            if (string.IsNullOrEmpty(accountCode))
                continue;

            if (accountCode.Equals("TOTALS", StringComparison.OrdinalIgnoreCase))
                continue;

            AccountSummary account = new AccountSummary();
            account.Category = GetValue(row, "category");
            account.SubCategory = GetValue(row, "subcategory");
            account.AccountCode = accountCode;
            account.AccountName = GetValue(row, "accountname");
            account.DRBalance = ToDecimal(GetValue(row, "DRBalance"));
            account.CRBalance = ToDecimal(GetValue(row, "CRBalance"));

            accounts.Add(account);
        }

        SortSummaryAccounts(accounts);
        return accounts;
    }

    private void SortSummaryAccounts(List<AccountSummary> accounts)
    {
        accounts.Sort(delegate(AccountSummary a, AccountSummary b)
        {
            int subCompare = string.Compare(a.SubCategory, b.SubCategory, true);
            if (subCompare != 0)
                return subCompare;

            return string.Compare(a.AccountCode, b.AccountCode, true);
        });
    }

    private DataTable GetOpeningBalancesForExport(DateTime sDate)
    {
        DataTable dt = new DataTable();

        string sql = @"
            SELECT
                x.MAC,
                x.category,
                x.subcategory,
                x.AccountCode AS accountcode,
                x.AccountName AS accountname,
                SUM(x.balance) AS OpeningBalance
            FROM
            (
                SELECT
                    s.MAC,
                    s.category,
                    s.subcategory,
                    s.AccountCode,
                    s.AccountName,
                    CASE
                        WHEN UPPER(TRIM(f.transactionType)) = 'DR'
                            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)
                        WHEN UPPER(TRIM(f.transactionType)) = 'CR'
                            THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)
                        ELSE 0
                    END AS balance
                FROM fin_ledger f
                INNER JOIN
                (
                    SELECT
                        CONVERT(sa.AccountCode USING utf8) AS AccountCode,
                        LEFT(CONVERT(sa.AccountName USING utf8), 191) AS AccountName,
                        CONVERT(sa.accounttype USING utf8) AS accounttype,
                        CONVERT(sa.collectionLedgerType USING utf8) AS collectionLedgerType,
                        CONVERT(fin_GetTrialBalanceGroup(sa.AccountCode) USING utf8) AS MAC,
                        CONVERT(fin_GetAccountCategory(sa.AccountCode) USING utf8) AS category,
                        CONVERT(fin_GetAccountSubCategory(sa.AccountCode) USING utf8) AS subcategory
                    FROM fin_subaccounts sa
                ) s
                    ON s.AccountCode = CONVERT(f.accountcode USING utf8)
                WHERE
                (
                    f.transactionDate < @sDate
                    OR
                    (
                        f.transactionDate >= @sDate
                        AND f.transactionDate < DATE_ADD(@sDate, INTERVAL 1 DAY)
                        AND
                        (
                            UPPER(IFNULL(f.particulars,'')) LIKE '%OPENING BALANCE%'
                            OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OB-%'
                            OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OPENING%'
                            OR UPPER(IFNULL(f.source_system,'')) LIKE '%OPENING%'
                            OR UPPER(IFNULL(f.teller,'')) LIKE '%OPENING%'
                        )
                    )
                )
                AND NOT
                (
                    UPPER(IFNULL(f.source_system,'')) IN
                    (
                        'RSL_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER',
                        'RESTORED_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER_GL_SIDE'
                    )
                    OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'
                    OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'
                )

                UNION ALL

                SELECT
                    s.MAC,
                    s.category,
                    s.subcategory,
                    s.AccountCode,
                    s.AccountName,
                    CASE
                        WHEN UPPER(TRIM(f.transactionType)) = 'DR'
                            THEN COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)
                        WHEN UPPER(TRIM(f.transactionType)) = 'CR'
                            THEN -COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0)
                        ELSE 0
                    END AS balance
                FROM fin_ledger f
                INNER JOIN
                (
                    SELECT
                        CONVERT(sa.AccountCode USING utf8) AS AccountCode,
                        LEFT(CONVERT(sa.AccountName USING utf8), 191) AS AccountName,
                        CONVERT(sa.accounttype USING utf8) AS accounttype,
                        CONVERT(sa.collectionLedgerType USING utf8) AS collectionLedgerType,
                        CONVERT(fin_GetTrialBalanceGroup(sa.AccountCode) USING utf8) AS MAC,
                        CONVERT(fin_GetAccountCategory(sa.AccountCode) USING utf8) AS category,
                        CONVERT(fin_GetAccountSubCategory(sa.AccountCode) USING utf8) AS subcategory
                    FROM fin_subaccounts sa
                ) s
                    ON s.collectionLedgerType = CONVERT(f.account_type USING utf8)
                LEFT JOIN fin_subaccounts directcoa
                    ON CONVERT(directcoa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)
                WHERE
                (
                    f.transactionDate < @sDate
                    OR
                    (
                        f.transactionDate >= @sDate
                        AND f.transactionDate < DATE_ADD(@sDate, INTERVAL 1 DAY)
                        AND
                        (
                            UPPER(IFNULL(f.particulars,'')) LIKE '%OPENING BALANCE%'
                            OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OB-%'
                            OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OPENING%'
                            OR UPPER(IFNULL(f.source_system,'')) LIKE '%OPENING%'
                            OR UPPER(IFNULL(f.teller,'')) LIKE '%OPENING%'
                        )
                    )
                )
                AND NOT
                (
                    UPPER(IFNULL(f.source_system,'')) IN
                    (
                        'RSL_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER',
                        'RESTORED_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER_GL_SIDE'
                    )
                    OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'
                    OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'
                )
                AND directcoa.AccountCode IS NULL
                AND IFNULL(s.collectionLedgerType,'') <> ''
                AND IFNULL(s.accounttype,'') <> 'Basic Account'
            ) x
            GROUP BY
                x.MAC,
                x.category,
                x.subcategory,
                x.AccountCode,
                x.AccountName
            HAVING ROUND(SUM(x.balance), 2) <> 0
            ORDER BY
                x.MAC,
                x.category,
                x.subcategory,
                x.AccountCode";

        using (MySqlConnection conn = new MySqlConnection(GetAccountsConnectionString()))
        {
            conn.Open();

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 900;
                cmd.Parameters.AddWithValue("@sDate", sDate.ToString("yyyy-MM-dd"));

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        return dt;
    }

    private Dictionary<string, OpeningBalanceInfo> BuildOpeningMap(DataTable openingRows)
    {
        Dictionary<string, OpeningBalanceInfo> map = new Dictionary<string, OpeningBalanceInfo>();

        for (int i = 0; i < openingRows.Rows.Count; i++)
        {
            DataRow row = openingRows.Rows[i];
            string accountCode = GetValue(row, "accountcode").Trim();

            if (string.IsNullOrEmpty(accountCode))
                continue;

            string key = accountCode.ToUpperInvariant();

            if (!map.ContainsKey(key))
                map[key] = new OpeningBalanceInfo();

            map[key].Category = GetValue(row, "category");
            map[key].SubCategory = GetValue(row, "subcategory");
            map[key].AccountCode = accountCode;
            map[key].AccountName = GetValue(row, "accountname");
            map[key].OpeningBalance += ToDecimal(GetValue(row, "OpeningBalance"));
        }

        return map;
    }

    private DataTable GetAllTransactionDetailsForExport(DateTime sDate, DateTime eDate)
    {
        DataTable dt = new DataTable();

        string sql = @"
            SELECT
                x.MAC,
                x.category,
                x.subcategory,
                x.accountcode,
                x.acc_name,
                x.transactionDate,
                x.teller,
                x.particulars,
                x.trans_currency,
                x.transactionType,
                x.transaction_amount,
                x.source_system,
                x.RefNo,
                x.journal_no,
                x.voucherNo,
                x.TID
            FROM
            (
                SELECT
                    s.MAC,
                    s.category,
                    s.subcategory,
                    s.AccountCode AS accountcode,
                    s.AccountName AS acc_name,
                    f.transactionDate,
                    f.teller,
                    f.particulars,
                    f.trans_currency,
                    UPPER(TRIM(f.transactionType)) AS transactionType,
                    COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) AS transaction_amount,
                    f.source_system,
                    f.RefNo,
                    f.journal_no,
                    f.voucherNo,
                    f.TID
                FROM fin_ledger f
                INNER JOIN
                (
                    SELECT
                        CONVERT(sa.AccountCode USING utf8) AS AccountCode,
                        LEFT(CONVERT(sa.AccountName USING utf8), 191) AS AccountName,
                        CONVERT(sa.accounttype USING utf8) AS accounttype,
                        CONVERT(sa.collectionLedgerType USING utf8) AS collectionLedgerType,
                        CONVERT(fin_GetTrialBalanceGroup(sa.AccountCode) USING utf8) AS MAC,
                        CONVERT(fin_GetAccountCategory(sa.AccountCode) USING utf8) AS category,
                        CONVERT(fin_GetAccountSubCategory(sa.AccountCode) USING utf8) AS subcategory
                    FROM fin_subaccounts sa
                ) s
                    ON s.AccountCode = CONVERT(f.accountcode USING utf8)
                WHERE
                (
                    (
                        f.transactionDate >= @sDate
                        AND f.transactionDate < DATE_ADD(@eDate, INTERVAL 1 DAY)
                    )
                    OR
                    (
                        UPPER(IFNULL(f.source_system,'')) = 'PC_KAMPALA'
                        AND CAST(f.voucherNo AS CHAR) = DATE_FORMAT(@eDate, '%Y%m%d')
                        AND f.transactionDate >= DATE_ADD(@eDate, INTERVAL 1 DAY)
                        AND CONVERT(f.accountcode USING utf8) <> 'AC1304'
                    )
                )
                AND NOT
                (
                    UPPER(IFNULL(f.source_system,'')) IN
                    (
                        'RSL_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER',
                        'RESTORED_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER_GL_SIDE'
                    )
                    OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'
                    OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'
                )
                  AND NOT
                  (
                      f.transactionDate >= @sDate
                      AND f.transactionDate < DATE_ADD(@sDate, INTERVAL 1 DAY)
                      AND
                      (
                          UPPER(IFNULL(f.particulars,'')) LIKE '%OPENING BALANCE%'
                          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OB-%'
                          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OPENING%'
                          OR UPPER(IFNULL(f.source_system,'')) LIKE '%OPENING%'
                          OR UPPER(IFNULL(f.teller,'')) LIKE '%OPENING%'
                      )
                  )

                UNION ALL

                SELECT
                    s.MAC,
                    s.category,
                    s.subcategory,
                    s.AccountCode AS accountcode,
                    s.AccountName AS acc_name,
                    f.transactionDate,
                    f.teller,
                    f.particulars,
                    f.trans_currency,
                    UPPER(TRIM(f.transactionType)) AS transactionType,
                    COALESCE(NULLIF(f.actual_amount,0), f.transaction_amount,0) AS transaction_amount,
                    f.source_system,
                    f.RefNo,
                    f.journal_no,
                    f.voucherNo,
                    f.TID
                FROM fin_ledger f
                INNER JOIN
                (
                    SELECT
                        CONVERT(sa.AccountCode USING utf8) AS AccountCode,
                        LEFT(CONVERT(sa.AccountName USING utf8), 191) AS AccountName,
                        CONVERT(sa.accounttype USING utf8) AS accounttype,
                        CONVERT(sa.collectionLedgerType USING utf8) AS collectionLedgerType,
                        CONVERT(fin_GetTrialBalanceGroup(sa.AccountCode) USING utf8) AS MAC,
                        CONVERT(fin_GetAccountCategory(sa.AccountCode) USING utf8) AS category,
                        CONVERT(fin_GetAccountSubCategory(sa.AccountCode) USING utf8) AS subcategory
                    FROM fin_subaccounts sa
                ) s
                    ON s.collectionLedgerType = CONVERT(f.account_type USING utf8)
                LEFT JOIN fin_subaccounts directcoa
                    ON CONVERT(directcoa.AccountCode USING utf8) = CONVERT(f.accountcode USING utf8)
                WHERE
                (
                    (
                        f.transactionDate >= @sDate
                        AND f.transactionDate < DATE_ADD(@eDate, INTERVAL 1 DAY)
                    )
                    OR
                    (
                        UPPER(IFNULL(f.source_system,'')) = 'PC_KAMPALA'
                        AND CAST(f.voucherNo AS CHAR) = DATE_FORMAT(@eDate, '%Y%m%d')
                        AND f.transactionDate >= DATE_ADD(@eDate, INTERVAL 1 DAY)
                        AND CONVERT(f.accountcode USING utf8) <> 'AC1304'
                    )
                )
                AND NOT
                (
                    UPPER(IFNULL(f.source_system,'')) IN
                    (
                        'RSL_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER',
                        'RESTORED_GL_SIDE',
                        'RESTORED_STUDENT_LEDGER_GL_SIDE'
                    )
                    OR UPPER(IFNULL(f.RefNo,'')) LIKE 'RSLGL-%'
                    OR UPPER(IFNULL(f.journal_no,'')) LIKE 'RSLGL-%'
                )
                  AND directcoa.AccountCode IS NULL
                  AND IFNULL(s.collectionLedgerType,'') <> ''
                  AND IFNULL(s.accounttype,'') <> 'Basic Account'
                  AND NOT
                  (
                      f.transactionDate >= @sDate
                      AND f.transactionDate < DATE_ADD(@sDate, INTERVAL 1 DAY)
                      AND
                      (
                          UPPER(IFNULL(f.particulars,'')) LIKE '%OPENING BALANCE%'
                          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OB-%'
                          OR UPPER(IFNULL(f.RefNo,'')) LIKE 'OPENING%'
                          OR UPPER(IFNULL(f.source_system,'')) LIKE '%OPENING%'
                          OR UPPER(IFNULL(f.teller,'')) LIKE '%OPENING%'
                      )
                  )

            ) x
            ORDER BY
                x.MAC,
                x.category,
                x.subcategory,
                x.accountcode,
                x.transactionDate,
                x.TID";

        using (MySqlConnection conn = new MySqlConnection(GetAccountsConnectionString()))
        {
            conn.Open();

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 900;
                cmd.Parameters.AddWithValue("@sDate", sDate.ToString("yyyy-MM-dd"));
                cmd.Parameters.AddWithValue("@eDate", eDate.ToString("yyyy-MM-dd"));

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }

        return dt;
    }

    private Dictionary<string, List<DataRow>> BuildTransactionMap(DataTable txns)
    {
        Dictionary<string, List<DataRow>> map = new Dictionary<string, List<DataRow>>();

        for (int i = 0; i < txns.Rows.Count; i++)
        {
            DataRow row = txns.Rows[i];

            if (ShouldSkipConsolidatedRow(row))
                continue;

            string accountCode = NormalizeConsolidatedAccountCode(GetValue(row, "accountcode"), GetValue(row, "particulars"), GetValue(row, "acc_name"), GetValue(row, "source_system"), GetValue(row, "RefNo"), GetValue(row, "journal_no"), GetValue(row, "voucherNo")).Trim().ToUpperInvariant();

            if (string.IsNullOrEmpty(accountCode))
                continue;

            if (!map.ContainsKey(accountCode))
                map[accountCode] = new List<DataRow>();

            map[accountCode].Add(row);
        }

        return map;
    }


    private List<DetailAccount> BuildDetailAccountListFromSummaryAccounts(
        List<AccountSummary> summaryAccounts,
        Dictionary<string, OpeningBalanceInfo> openingMap)
    {
        List<DetailAccount> list = new List<DetailAccount>();

        for (int i = 0; i < summaryAccounts.Count; i++)
        {
            AccountSummary summary = summaryAccounts[i];
            DetailAccount detail = new DetailAccount();
            detail.Category = summary.Category;
            detail.SubCategory = summary.SubCategory;
            detail.AccountCode = summary.AccountCode;
            detail.AccountName = summary.AccountName;
            detail.DRBalance = summary.DRBalance;
            detail.CRBalance = summary.CRBalance;

            string key = NormalizeConsolidatedAccountCode(summary.AccountCode).Trim().ToUpperInvariant();

            if (openingMap.ContainsKey(key))
                detail.OpeningBalance = openingMap[key].OpeningBalance;

            list.Add(detail);
        }

        list.Sort(delegate(DetailAccount a, DetailAccount b)
        {
            int subCompare = string.Compare(a.SubCategory, b.SubCategory, true);
            if (subCompare != 0)
                return subCompare;

            return string.Compare(a.AccountCode, b.AccountCode, true);
        });

        return list;
    }

    private List<DetailAccount> BuildDetailAccountList(
        List<AccountSummary> summaryAccounts,
        Dictionary<string, OpeningBalanceInfo> openingMap,
        Dictionary<string, List<DataRow>> txnMap,
        DataTable txns)
    {
        Dictionary<string, DetailAccount> map = new Dictionary<string, DetailAccount>();

        for (int i = 0; i < summaryAccounts.Count; i++)
        {
            AccountSummary s = summaryAccounts[i];
            string key = s.AccountCode.Trim().ToUpperInvariant();

            if (string.IsNullOrEmpty(key))
                continue;

            if (!map.ContainsKey(key))
                map[key] = new DetailAccount();

            map[key].Category = s.Category;
            map[key].SubCategory = s.SubCategory;
            map[key].AccountCode = s.AccountCode;
            map[key].AccountName = s.AccountName;
            map[key].DRBalance = s.DRBalance;
            map[key].CRBalance = s.CRBalance;
        }

        foreach (string key in openingMap.Keys)
        {
            OpeningBalanceInfo o = openingMap[key];

            if (!map.ContainsKey(key))
                map[key] = new DetailAccount();

            if (string.IsNullOrEmpty(map[key].AccountCode))
                map[key].AccountCode = o.AccountCode;

            if (string.IsNullOrEmpty(map[key].AccountName))
                map[key].AccountName = o.AccountName;

            if (string.IsNullOrEmpty(map[key].Category))
                map[key].Category = o.Category;

            if (string.IsNullOrEmpty(map[key].SubCategory))
                map[key].SubCategory = o.SubCategory;

            map[key].OpeningBalance = o.OpeningBalance;
            map[key].DRBalance += o.OpeningDR;
            map[key].CRBalance += o.OpeningCR;
        }

        for (int i = 0; i < txns.Rows.Count; i++)
        {
            DataRow row = txns.Rows[i];
            string accountCode = GetValue(row, "accountcode").Trim();

            if (string.IsNullOrEmpty(accountCode))
                continue;

            string key = accountCode.ToUpperInvariant();

            if (!map.ContainsKey(key))
                map[key] = new DetailAccount();

            if (string.IsNullOrEmpty(map[key].AccountCode))
                map[key].AccountCode = accountCode;

            if (string.IsNullOrEmpty(map[key].AccountName))
                map[key].AccountName = GetValue(row, "acc_name");

            if (string.IsNullOrEmpty(map[key].Category))
                map[key].Category = GetValue(row, "category");

            if (string.IsNullOrEmpty(map[key].SubCategory))
                map[key].SubCategory = GetValue(row, "subcategory");
        }

        List<DetailAccount> list = new List<DetailAccount>();

        foreach (DetailAccount a in map.Values)
            list.Add(a);

        list.Sort(delegate(DetailAccount a, DetailAccount b)
        {
            int subCompare = string.Compare(a.SubCategory, b.SubCategory, true);
            if (subCompare != 0)
                return subCompare;

            return string.Compare(a.AccountCode, b.AccountCode, true);
        });

        return list;
    }

    private List<AccountSummary> BuildSummaryAccountListFromDetailAccounts(List<DetailAccount> detailAccounts)
    {
        List<AccountSummary> accounts = new List<AccountSummary>();

        for (int i = 0; i < detailAccounts.Count; i++)
        {
            DetailAccount detail = detailAccounts[i];

            if (string.IsNullOrEmpty(detail.AccountCode))
                continue;

            if (detail.DRBalance == 0 && detail.CRBalance == 0)
                continue;

            AccountSummary account = new AccountSummary();
            account.Category = detail.Category;
            account.SubCategory = detail.SubCategory;
            account.AccountCode = detail.AccountCode;
            account.AccountName = detail.AccountName;
            account.DRBalance = detail.DRBalance;
            account.CRBalance = detail.CRBalance;

            accounts.Add(account);
        }

        SortSummaryAccounts(accounts);
        return accounts;
    }

    private void RecalculateClosingBalance(DetailAccount account, Dictionary<string, List<DataRow>> txnMap)
    {
        decimal closingBalance = account.OpeningBalance;
        string key = account.AccountCode.Trim().ToUpperInvariant();

        if (txnMap.ContainsKey(key))
            closingBalance += GetTransactionNetBalance(txnMap[key]);

        if (closingBalance > 0)
        {
            account.DRBalance = closingBalance;
            account.CRBalance = 0;
        }
        else if (closingBalance < 0)
        {
            account.DRBalance = 0;
            account.CRBalance = Math.Abs(closingBalance);
        }
        else
        {
            account.DRBalance = 0;
            account.CRBalance = 0;
        }
    }

    private decimal GetTransactionNetBalance(List<DataRow> rows)
    {
        decimal balance = 0;

        for (int i = 0; i < rows.Count; i++)
            balance += GetSignedTransactionAmount(rows[i]);

        return balance;
    }

    private decimal GetSignedTransactionAmount(DataRow row)
    {
        string transactionType = GetValue(row, "transactionType").Trim().ToUpperInvariant();
        decimal amount = ToDecimal(GetValue(row, "transaction_amount"));

        if (transactionType == "DR")
            return amount;

        if (transactionType == "CR")
            return -amount;

        return 0;
    }

    private void WriteSummarySheet(StringBuilder sb, List<AccountSummary> accounts, DateTime sDate, DateTime eDate)
    {
        sb.AppendLine("<Worksheet ss:Name=\"Summary TB\">");
        sb.AppendLine("<Table>");

        WriteFiveColumns(sb);
        WriteTitleRows(sb, "CONSOLIDATED TRIAL BALANCE SUMMARY", sDate, eDate, 5);

        sb.AppendLine("<Row>");
        WriteCell(sb, "Category", "Header", 0);
        WriteCell(sb, "GL Account", "Header", 0);
        WriteCell(sb, "Account Name", "Header", 0);
        WriteCell(sb, "DR Balance", "HeaderRight", 0);
        WriteCell(sb, "CR Balance", "HeaderRight", 0);
        sb.AppendLine("</Row>");

        decimal totalDr = 0;
        decimal totalCr = 0;

        for (int i = 0; i < accounts.Count; i++)
        {
            AccountSummary account = accounts[i];

            totalDr += account.DRBalance;
            totalCr += account.CRBalance;

            sb.AppendLine("<Row>");
            WriteCell(sb, account.SubCategory, "Normal", 0);
            WriteCell(sb, GetDisplayAccountCode(account.AccountCode), "Normal", 0);
            WriteCell(sb, account.AccountName, "Normal", 0);
            WriteNumberCell(sb, account.DRBalance, "Number");
            WriteNumberCell(sb, account.CRBalance, "Number");
            sb.AppendLine("</Row>");
        }

        sb.AppendLine("<Row>");
        WriteCell(sb, "", "Total", 0);
        WriteCell(sb, "TOTALS", "Total", 0);
        WriteCell(sb, "TOTALS", "Total", 0);
        WriteNumberCell(sb, totalDr, "TotalNumber");
        WriteNumberCell(sb, totalCr, "TotalNumber");
        sb.AppendLine("</Row>");

        sb.AppendLine("</Table>");
        WriteWorksheetOptions(sb, 3);
        sb.AppendLine("</Worksheet>");
    }

    private void WriteOpeningBalancesSheet(StringBuilder sb, Dictionary<string, OpeningBalanceInfo> openingMap, DateTime sDate)
    {
        List<OpeningBalanceInfo> openings = new List<OpeningBalanceInfo>();

        foreach (OpeningBalanceInfo o in openingMap.Values)
            openings.Add(o);

        openings.Sort(delegate(OpeningBalanceInfo a, OpeningBalanceInfo b)
        {
            int subCompare = string.Compare(a.SubCategory, b.SubCategory, true);
            if (subCompare != 0)
                return subCompare;

            return string.Compare(a.AccountCode, b.AccountCode, true);
        });

        sb.AppendLine("<Worksheet ss:Name=\"Opening Balances\">");
        sb.AppendLine("<Table>");

        WriteFiveColumns(sb);
        WriteTitleRows(sb, "OPENING BALANCES AS AT " + sDate.ToString("dd/MM/yyyy"), sDate, sDate, 5);

        sb.AppendLine("<Row>");
        WriteCell(sb, "Category", "Header", 0);
        WriteCell(sb, "GL Account", "Header", 0);
        WriteCell(sb, "Account Name", "Header", 0);
        WriteCell(sb, "Opening DR", "HeaderRight", 0);
        WriteCell(sb, "Opening CR", "HeaderRight", 0);
        sb.AppendLine("</Row>");

        decimal totalDr = 0;
        decimal totalCr = 0;

        for (int i = 0; i < openings.Count; i++)
        {
            OpeningBalanceInfo o = openings[i];

            totalDr += o.OpeningDR;
            totalCr += o.OpeningCR;

            sb.AppendLine("<Row>");
            WriteCell(sb, o.SubCategory, "Normal", 0);
            WriteCell(sb, o.AccountCode, "Normal", 0);
            WriteCell(sb, o.AccountName, "Normal", 0);
            WriteNumberCell(sb, o.OpeningDR, "Number");
            WriteNumberCell(sb, o.OpeningCR, "Number");
            sb.AppendLine("</Row>");
        }

        sb.AppendLine("<Row>");
        WriteCell(sb, "", "Total", 0);
        WriteCell(sb, "TOTALS", "Total", 0);
        WriteCell(sb, "TOTALS", "Total", 0);
        WriteNumberCell(sb, totalDr, "TotalNumber");
        WriteNumberCell(sb, totalCr, "TotalNumber");
        sb.AppendLine("</Row>");

        sb.AppendLine("</Table>");
        WriteWorksheetOptions(sb, 3);
        sb.AppendLine("</Worksheet>");
    }

    private void WriteDetailedTrialBalanceSheet(
        StringBuilder sb,
        List<DetailAccount> accounts,
        Dictionary<string, List<DataRow>> txnMap,
        DateTime sDate,
        DateTime eDate)
    {
        sb.AppendLine("<Worksheet ss:Name=\"Detailed TB\">");
        sb.AppendLine("<Table>");

        WriteEightColumns(sb);
        WriteTitleRows(sb, "DETAILED CONSOLIDATED TRIAL BALANCE", sDate, eDate, 8);

        sb.AppendLine("<Row>");
        WriteCell(sb, "Category", "Header", 0);
        WriteCell(sb, "GL Account", "Header", 0);
        WriteCell(sb, "Account Name", "Header", 0);
        WriteCell(sb, "DR Balance", "HeaderRight", 0);
        WriteCell(sb, "CR Balance", "HeaderRight", 0);
        WriteCell(sb, "", "Header", 0);
        WriteCell(sb, "", "Header", 0);
        WriteCell(sb, "", "Header", 0);
        sb.AppendLine("</Row>");

        decimal totalDr = 0;
        decimal totalCr = 0;

        for (int i = 0; i < accounts.Count; i++)
        {
            DetailAccount account = accounts[i];

            totalDr += account.DRBalance;
            totalCr += account.CRBalance;

            WriteDetailedMasterAccountRow(sb, account);

            if (account.OpeningBalance != 0)
            {
                WriteFirstLevelHeader(sb);
                WriteFirstLevelRow(sb, account.AccountCode, "Opening Balance", account.OpeningBalance);
            }

            string key = account.AccountCode.Trim().ToUpperInvariant();

            if (txnMap.ContainsKey(key) && txnMap[key].Count > 0)
            {
                WriteTransactionHeader(sb);

                for (int t = 0; t < txnMap[key].Count; t++)
                    WriteTransactionRow(sb, txnMap[key][t]);
            }

            WriteSpacerRow(sb);
        }

        sb.AppendLine("<Row>");
        WriteCell(sb, "", "Total", 0);
        WriteCell(sb, "TOTALS", "Total", 0);
        WriteCell(sb, "TOTALS", "Total", 0);
        WriteNumberCell(sb, totalDr, "TotalNumber");
        WriteNumberCell(sb, totalCr, "TotalNumber");
        WriteCell(sb, "", "Total", 0);
        WriteCell(sb, "", "Total", 0);
        WriteCell(sb, "", "Total", 0);
        sb.AppendLine("</Row>");

        sb.AppendLine("</Table>");
        WriteWorksheetOptions(sb, 3);
        sb.AppendLine("</Worksheet>");
    }

    private void WriteDetailedMasterAccountRow(StringBuilder sb, DetailAccount account)
    {
        sb.AppendLine("<Row>");
        WriteCell(sb, account.SubCategory, "Master", 0);
        WriteCell(sb, GetDisplayAccountCode(account.AccountCode), "Master", 0);
        WriteCell(sb, account.AccountName, "Master", 0);
        WriteNumberCell(sb, account.DRBalance, "MasterNumber");
        WriteNumberCell(sb, account.CRBalance, "MasterNumber");
        WriteCell(sb, "", "Master", 0);
        WriteCell(sb, "", "Master", 0);
        WriteCell(sb, "", "Master", 0);
        sb.AppendLine("</Row>");
    }

    private void WriteFirstLevelHeader(StringBuilder sb)
    {
        sb.AppendLine("<Row>");
        WriteCell(sb, "", "DetailHeader", 0);
        WriteCell(sb, "Account Code", "DetailHeader", 0);
        WriteCell(sb, "Description", "DetailHeader", 0);
        WriteCell(sb, "Balance", "DetailHeaderRight", 0);
        WriteCell(sb, "", "DetailHeader", 0);
        WriteCell(sb, "", "DetailHeader", 0);
        WriteCell(sb, "", "DetailHeader", 0);
        WriteCell(sb, "", "DetailHeader", 0);
        sb.AppendLine("</Row>");
    }

    private void WriteFirstLevelRow(StringBuilder sb, string accountCode, string label, decimal balance)
    {
        sb.AppendLine("<Row>");
        WriteCell(sb, "", "Detail", 0);
        WriteCell(sb, GetDisplayAccountCode(accountCode), "Detail", 0);
        WriteCell(sb, label, "Detail", 0);
        WriteBalanceWithDrCr(sb, balance, "DetailNumber");
        WriteCell(sb, "", "Detail", 0);
        WriteCell(sb, "", "Detail", 0);
        WriteCell(sb, "", "Detail", 0);
        WriteCell(sb, "", "Detail", 0);
        sb.AppendLine("</Row>");
    }

    private void WriteTransactionHeader(StringBuilder sb)
    {
        sb.AppendLine("<Row>");
        WriteCell(sb, "", "TxnHeader", 0);
        WriteCell(sb, "", "TxnHeader", 0);
        WriteCell(sb, "Date", "TxnHeader", 0);
        WriteCell(sb, "Entered By", "TxnHeader", 0);
        WriteCell(sb, "Particulars", "TxnHeader", 0);
        WriteCell(sb, "Currency", "TxnHeader", 0);
        WriteCell(sb, "DR/CR", "TxnHeader", 0);
        WriteCell(sb, "Amount", "TxnHeaderRight", 0);
        sb.AppendLine("</Row>");
    }

    private void WriteTransactionRow(StringBuilder sb, DataRow row)
    {
        string date = FormatDate(GetValue(row, "transactionDate"));
        string teller = GetValue(row, "teller");
        string particulars = GetValue(row, "particulars");
        string currency = GetValue(row, "trans_currency");
        string drcr = GetValue(row, "transactionType");
        decimal amount = ToDecimal(GetValue(row, "transaction_amount"));

        sb.AppendLine("<Row>");
        WriteCell(sb, "", "Txn", 0);
        WriteCell(sb, "", "Txn", 0);
        WriteCell(sb, date, "Txn", 0);
        WriteCell(sb, teller, "Txn", 0);
        WriteCell(sb, particulars, "Txn", 0);
        WriteCell(sb, currency, "Txn", 0);
        WriteCell(sb, drcr, "Txn", 0);
        WriteNumberCell(sb, amount, "TxnNumber");
        sb.AppendLine("</Row>");
    }

    private void WriteFiveColumns(StringBuilder sb)
    {
        sb.AppendLine("<Column ss:Width=\"230\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
        sb.AppendLine("<Column ss:Width=\"430\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
    }

    private void WriteEightColumns(StringBuilder sb)
    {
        sb.AppendLine("<Column ss:Width=\"230\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
        sb.AppendLine("<Column ss:Width=\"430\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
        sb.AppendLine("<Column ss:Width=\"130\"/>");
    }

    private string GetAccountsConnectionString()
    {
        string[] names = new string[]
        {
            "campus_dynamics_accountsConnectionString",
            "campus_dynamics_accountsConnectionString1",
            "AccountsConnectionString",
            "accountsConnectionString",
            "vacConnectionString"
        };

        for (int i = 0; i < names.Length; i++)
        {
            ConnectionStringSettings cs = ConfigurationManager.ConnectionStrings[names[i]];

            if (cs != null &&
                cs.ConnectionString != null &&
                cs.ConnectionString.ToLowerInvariant().Contains("campus_dynamics_accounts"))
            {
                return cs.ConnectionString;
            }
        }

        foreach (ConnectionStringSettings cs in ConfigurationManager.ConnectionStrings)
        {
            if (cs != null &&
                cs.ConnectionString != null &&
                cs.ConnectionString.ToLowerInvariant().Contains("campus_dynamics_accounts"))
            {
                return cs.ConnectionString;
            }
        }

        throw new Exception("Could not find campus_dynamics_accounts connection string in web.config.");
    }

    private void WriteSpacerRow(StringBuilder sb)
    {
        sb.AppendLine("<Row></Row>");
    }

    private void WriteTitleRows(StringBuilder sb, string title, DateTime sDate, DateTime eDate, int totalColumns)
    {
        sb.AppendLine("<Row>");
        WriteCell(sb, title, "Title", totalColumns - 1);
        sb.AppendLine("</Row>");

        sb.AppendLine("<Row>");
        WriteCell(sb, "PERIOD: " + sDate.ToString("dd/MM/yyyy") + " TO " + eDate.ToString("dd/MM/yyyy"), "Subtitle", totalColumns - 1);
        sb.AppendLine("</Row>");

        sb.AppendLine("<Row></Row>");
    }

    private void WriteStyles(StringBuilder sb)
    {
        sb.AppendLine("<Styles>");

        sb.AppendLine("<Style ss:ID=\"Title\"><Font ss:Bold=\"1\" ss:Size=\"16\"/><Interior ss:Color=\"#D9EAF7\" ss:Pattern=\"Solid\"/><Alignment ss:Horizontal=\"Center\"/></Style>");
        sb.AppendLine("<Style ss:ID=\"Subtitle\"><Font ss:Bold=\"1\" ss:Size=\"12\"/><Interior ss:Color=\"#D9EAF7\" ss:Pattern=\"Solid\"/><Alignment ss:Horizontal=\"Center\"/></Style>");

        sb.AppendLine("<Style ss:ID=\"Header\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#EAF2F8\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"HeaderRight\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#EAF2F8\" ss:Pattern=\"Solid\"/><Alignment ss:Horizontal=\"Right\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("<Style ss:ID=\"Normal\"><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"Number\"><NumberFormat ss:Format=\"#,##0\"/><Alignment ss:Horizontal=\"Right\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("<Style ss:ID=\"Master\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#FFF2CC\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"MasterNumber\"><Font ss:Bold=\"1\"/><NumberFormat ss:Format=\"#,##0\"/><Alignment ss:Horizontal=\"Right\"/><Interior ss:Color=\"#FFF2CC\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("<Style ss:ID=\"DetailHeader\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#DDEBF7\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"DetailHeaderRight\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#DDEBF7\" ss:Pattern=\"Solid\"/><Alignment ss:Horizontal=\"Right\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("<Style ss:ID=\"Detail\"><Interior ss:Color=\"#FFF2CC\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"DetailNumber\"><Alignment ss:Horizontal=\"Right\"/><Interior ss:Color=\"#FFF2CC\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("<Style ss:ID=\"TxnHeader\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#EAF2F8\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"TxnHeaderRight\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#EAF2F8\" ss:Pattern=\"Solid\"/><Alignment ss:Horizontal=\"Right\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("<Style ss:ID=\"Txn\"><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"TxnNumber\"><NumberFormat ss:Format=\"#,##0\"/><Alignment ss:Horizontal=\"Right\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("<Style ss:ID=\"Total\"><Font ss:Bold=\"1\"/><Interior ss:Color=\"#CFE2F3\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");
        sb.AppendLine("<Style ss:ID=\"TotalNumber\"><Font ss:Bold=\"1\"/><NumberFormat ss:Format=\"#,##0\"/><Alignment ss:Horizontal=\"Right\"/><Interior ss:Color=\"#CFE2F3\" ss:Pattern=\"Solid\"/><Borders><Border ss:Position=\"Bottom\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Left\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Right\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/><Border ss:Position=\"Top\" ss:LineStyle=\"Continuous\" ss:Weight=\"1\"/></Borders></Style>");

        sb.AppendLine("</Styles>");
    }

    private void WriteWorksheetOptions(StringBuilder sb, int frozenColumns)
    {
        sb.AppendLine("<WorksheetOptions xmlns=\"urn:schemas-microsoft-com:office:excel\">");
        sb.AppendLine("<FreezePanes/>");
        sb.AppendLine("<FrozenNoSplit/>");
        sb.AppendLine("<SplitHorizontal>4</SplitHorizontal>");
        sb.AppendLine("<TopRowBottomPane>4</TopRowBottomPane>");

        if (frozenColumns > 0)
        {
            sb.AppendLine("<SplitVertical>" + frozenColumns.ToString(CultureInfo.InvariantCulture) + "</SplitVertical>");
            sb.AppendLine("<LeftColumnRightPane>" + frozenColumns.ToString(CultureInfo.InvariantCulture) + "</LeftColumnRightPane>");
        }

        sb.AppendLine("</WorksheetOptions>");
    }

    private void WriteCell(StringBuilder sb, string value, string styleId, int mergeAcross)
    {
        sb.Append("<Cell");

        if (!string.IsNullOrEmpty(styleId))
            sb.Append(" ss:StyleID=\"" + styleId + "\"");

        if (mergeAcross > 0)
            sb.Append(" ss:MergeAcross=\"" + mergeAcross.ToString(CultureInfo.InvariantCulture) + "\"");

        sb.Append("><Data ss:Type=\"String\">");
        sb.Append(Xml(value));
        sb.AppendLine("</Data></Cell>");
    }

    private decimal WholeShillings(decimal value)
    {
        return Math.Round(value, 0, MidpointRounding.AwayFromZero);
    }

    private void WriteNumberCell(StringBuilder sb, decimal value, string styleId)
    {
        value = WholeShillings(value);

        if (value == 0)
        {
            WriteCell(sb, "", styleId, 0);
            return;
        }

        sb.Append("<Cell");

        if (!string.IsNullOrEmpty(styleId))
            sb.Append(" ss:StyleID=\"" + styleId + "\"");

        sb.Append("><Data ss:Type=\"Number\">");
        sb.Append(value.ToString("0", CultureInfo.InvariantCulture));
        sb.AppendLine("</Data></Cell>");
    }

    private void WriteBalanceWithDrCr(StringBuilder sb, decimal value, string styleId)
    {
        if (value == 0)
        {
            WriteCell(sb, "0", styleId, 0);
            return;
        }

        string suffix = value < 0 ? "CR" : "DR";
        decimal amount = Math.Abs(value);

        WriteCell(sb, amount.ToString("#,##0", CultureInfo.InvariantCulture) + suffix, styleId, 0);
    }

    protected decimal ToDecimal(object value)
    {
        if (value == null || value == DBNull.Value)
            return 0;

        string text = value.ToString()
            .Replace(",", "")
            .Replace("DR", "")
            .Replace("CR", "")
            .Trim();

        decimal result;

        if (decimal.TryParse(text, NumberStyles.Any, CultureInfo.InvariantCulture, out result))
            return result;

        if (decimal.TryParse(text, out result))
            return result;

        return 0;
    }

    private string GetValue(DataRow row, string columnName)
    {
        if (row == null || row.Table == null || !row.Table.Columns.Contains(columnName))
            return "";

        if (row[columnName] == null || row[columnName] == DBNull.Value)
            return "";

        return row[columnName].ToString();
    }

    private string FormatDate(string value)
    {
        DateTime dt;

        if (DateTime.TryParse(value, out dt))
            return dt.ToString("dd/MM/yyyy");

        return value;
    }

    private string Xml(string value)
    {
        if (value == null)
            return "";

        return SecurityElement.Escape(value);
    }

    protected void gvGeneralLedger_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }

    protected void gvDetails_BeforePerformDataSelect(object sender, EventArgs e)
    {
        ASPxGridView grid = sender as ASPxGridView;

        if (grid != null)
            Session["subacc_code"] = grid.GetMasterRowFieldValues("accountcode");
    }

    protected void gvDetails_HtmlDataCellPrepared(object sender, ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Height = 30;
    }

    protected void gvDetails_BeforePerformDataSelect1(object sender, EventArgs e)
    {
        ASPxGridView grid = sender as ASPxGridView;

        if (grid != null)
            Session["acc_code"] = grid.GetMasterRowFieldValues("accountcode");
    }

    protected void cmdExpandAll_Click(object sender, EventArgs e)
    {
        gvGeneralLedger.DataBind();

        for (int i = 0; i < gvGeneralLedger.VisibleRowCount; i++)
        {
            try
            {
                gvGeneralLedger.DetailRows.ExpandRow(i);
            }
            catch
            {
            }
        }
    }

    protected void cmdViewGL_Click(object sender, EventArgs e)
    {
        pop_gl_listing.ContentUrl = "~/COOPERP/accounts/GLAccount.aspx";
        pop_gl_listing.Width = 1000;
        pop_gl_listing.Height = 600;

        Session["s_date"] = txtStartDate.Date.ToString("yyyy-MM-dd");
        Session["e_date"] = txtEndDate.Date.ToString("yyyy-MM-dd");

        pop_gl_listing.ShowOnPageLoad = true;
    }
}
