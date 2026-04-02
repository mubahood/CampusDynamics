using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Bank Reconciliation — Match bank statement entries with ledger transactions.
/// 
/// NEW FEATURE (Phase 2):
///  ✓ Bank account + reconciliation statement selectors
///  ✓ Two-panel view: bank statement entries vs ledger entries
///  ✓ Auto-reconciliation via finPerformAutoReconciliation SP
///  ✓ Manual match/unmatch with amount validation
///  ✓ Create new reconciliation statements
///  ✓ Reco summary (adjustments + balances)
///  ✓ KPIs: statement balance, ledger balance, matched/unmatched counts
///  ✓ Uses FinanceDB, FinancePeriod, MoneyHelper, FinanceLogger
/// </summary>
public partial class COOPERP_NewScreens_BankReconciliation : System.Web.UI.Page
{
    private const string PAGE_NAME = "BankReconciliation";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadBankAccounts();
            SetDefaultDates();
        }
    }

    // ── Initialization ──────────────────────────────────────────

    private void LoadBankAccounts()
    {
        ddlBank.Items.Clear();
        ddlBank.Items.Add(new ListItem("-- Select Bank Account --", ""));

        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                @"SELECT sa.accountCode, CONCAT(sa.accountCode,' - ',sa.accountName) AS display
                  FROM fin_subAccounts sa
                  INNER JOIN fin_mainaccounts ma ON sa.MainAccountCode = ma.AccountCode
                  WHERE ma.AccountName LIKE '%Bank%' OR ma.AccountName LIKE '%Cash%'
                  ORDER BY sa.accountName");

            foreach (DataRow row in dt.Rows)
                ddlBank.Items.Add(new ListItem(row["display"].ToString(), row["accountCode"].ToString()));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadBankAccounts", ex);
        }
    }

    private void SetDefaultDates()
    {
        DateTime start, end;
        FinancePeriod.GetDefaultDateRange(out start, out end);
        txtStartDate.Text = start.ToString("yyyy-MM-dd");
        txtEndDate.Text = end.ToString("yyyy-MM-dd");

        var period = FinancePeriod.GetOpenPeriod();
        if (period != null)
        {
            litPeriodBadge.Text = string.Format(
                "<span style='background:rgba(255,255,255,.15);padding:4px 10px;font-size:10px;border-radius:3px;'>{0}</span>",
                period.Name);
        }
    }

    // ── Dropdown events ─────────────────────────────────────────

    protected void ddlBank_Changed(object sender, EventArgs e)
    {
        LoadStatements();
        LoadData();
    }

    protected void ddlStatement_Changed(object sender, EventArgs e)
    {
        LoadData();
    }

    protected void ddlFilter_Changed(object sender, EventArgs e)
    {
        LoadData();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadStatements();
        LoadData();
    }

    private void LoadStatements()
    {
        ddlStatement.Items.Clear();
        ddlStatement.Items.Add(new ListItem("-- Select Statement --", ""));

        string bankCode = ddlBank.SelectedValue;
        if (string.IsNullOrEmpty(bankCode)) return;

        try
        {
            DataTable dt = FinanceDB.ExecuteDataTable(
                @"SELECT ID, CONCAT(title,' [',rec_status,']') AS display
                  FROM fin_reconciliationstatement
                  WHERE bank_code = @bc
                  ORDER BY rec_date DESC",
                FinanceDB.P("@bc", bankCode));

            foreach (DataRow row in dt.Rows)
                ddlStatement.Items.Add(new ListItem(row["display"].ToString(), row["ID"].ToString()));
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadStatements", ex);
        }
    }

    // ── Main data loader ────────────────────────────────────────

    private void LoadData()
    {
        string bankCode = ddlBank.SelectedValue;
        string filter = ddlFilter.SelectedValue;
        int recoId = GetSelectedStatementId();

        if (string.IsNullOrEmpty(bankCode))
        {
            ClearAll();
            return;
        }

        try
        {
            // Bank statement entries (from selected reconciliation statement)
            if (recoId > 0)
            {
                DataTable bankDt = FinanceDB.ExecuteSP("fin_GetBankRecoStatementData",
                    FinanceDB.P("@cat", filter),
                    FinanceDB.P("@RID", recoId));

                rptBankEntries.DataSource = bankDt;
                rptBankEntries.DataBind();

                int matched = 0, unmatched = 0;
                foreach (DataRow row in bankDt.Rows)
                {
                    if (Convert.ToInt32(row["match_TID"]) != 0) matched++;
                    else unmatched++;
                }
                litBankCount.Text = bankDt.Rows.Count + " entries";
                litMatched.Text = matched.ToString();
                litUnmatched.Text = unmatched.ToString();

                // Statement balance
                object stmtBal = FinanceDB.ExecuteScalar<object>(
                    "SELECT statement_balance FROM fin_reconciliationstatement WHERE ID = @id",
                    FinanceDB.P("@id", recoId));
                litStmtBal.Text = stmtBal != null ? MoneyHelper.FormatNumber(MoneyHelper.ToDecimal(stmtBal)) : "--";
            }
            else
            {
                rptBankEntries.DataSource = null;
                rptBankEntries.DataBind();
                litBankCount.Text = "0 entries";
                litMatched.Text = "0";
                litUnmatched.Text = "0";
                litStmtBal.Text = "--";
            }

            // Ledger entries
            DateTime startDate, endDate;
            DateTime.TryParse(txtStartDate.Text, out startDate);
            DateTime.TryParse(txtEndDate.Text, out endDate);
            if (startDate == DateTime.MinValue) startDate = new DateTime(DateTime.Today.Year, 1, 1);
            if (endDate == DateTime.MinValue) endDate = DateTime.Today;

            string ledgerSql = @"SELECT TID, transactionDate, voucherNo, particulars, transactionType,
                                        transaction_amount
                                 FROM fin_ledger
                                 WHERE accountcode = @acc AND account_type = 'Chart Account'
                                   AND transactionDate BETWEEN @s AND @e";

            if (filter == "Pending" && recoId > 0)
                ledgerSql += " AND TID NOT IN (SELECT match_TID FROM fin_reco_bank_entries WHERE RecoID = @rid AND match_TID != 0)";
            else if (filter == "Matched" && recoId > 0)
                ledgerSql += " AND TID IN (SELECT match_TID FROM fin_reco_bank_entries WHERE RecoID = @rid AND match_TID != 0)";

            ledgerSql += " ORDER BY transactionDate, TID";

            DataTable ledgerDt;
            if (recoId > 0 && filter != "ALL")
            {
                ledgerDt = FinanceDB.ExecuteDataTable(ledgerSql,
                    FinanceDB.P("@acc", bankCode),
                    FinanceDB.P("@s", startDate),
                    FinanceDB.P("@e", endDate),
                    FinanceDB.P("@rid", recoId));
            }
            else
            {
                ledgerDt = FinanceDB.ExecuteDataTable(ledgerSql,
                    FinanceDB.P("@acc", bankCode),
                    FinanceDB.P("@s", startDate),
                    FinanceDB.P("@e", endDate));
            }

            rptLedger.DataSource = ledgerDt;
            rptLedger.DataBind();
            litLedgerCount.Text = ledgerDt.Rows.Count + " entries";

            // Ledger balance from DB function
            decimal ledgerBal = FinanceDB.ExecuteScalar<decimal>(
                "SELECT fin_GetPeriodBalance(@s, @e, @acc, 'Opening')",
                FinanceDB.P("@s", startDate),
                FinanceDB.P("@e", endDate),
                FinanceDB.P("@acc", bankCode));
            litLedgerBal.Text = MoneyHelper.FormatNumber(ledgerBal);

            litFooter.Text = string.Format("Bank: <strong>{0}</strong> &bull; {1:dd/MM/yyyy} to {2:dd/MM/yyyy}",
                bankCode, startDate, endDate);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "LoadData", ex);
            ShowMessage("Error loading data: " + ex.Message, false);
        }
    }

    // ── Auto Reconciliation ─────────────────────────────────────

    protected void btnAutoReco_Click(object sender, EventArgs e)
    {
        int recoId = GetSelectedStatementId();
        if (recoId <= 0)
        {
            ShowMessage("Please select a reconciliation statement first.", false);
            return;
        }

        try
        {
            FinanceDB.ExecuteSP("finPerformAutoReconciliation", FinanceDB.P("@rid", recoId));
            FinanceLogger.LogAction(PAGE_NAME, "AutoReconciliation", "RecoID=" + recoId);
            ShowMessage("Auto-reconciliation completed.", true);
            LoadData();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnAutoReco_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    // ── Manual Match ────────────────────────────────────────────

    protected void btnManualMatch_Click(object sender, EventArgs e)
    {
        int bankEntryId, ledgerTid;
        if (!int.TryParse(hdnSelectedBank.Value, out bankEntryId) || bankEntryId <= 0)
        {
            ShowMessage("Select a bank statement entry (left panel) to match.", false);
            return;
        }
        if (!int.TryParse(hdnSelectedLedger.Value, out ledgerTid) || ledgerTid <= 0)
        {
            ShowMessage("Select a ledger entry (right panel) to match.", false);
            return;
        }

        try
        {
            // Get bank entry amount
            decimal bankAmt = FinanceDB.ExecuteScalar<decimal>(
                "SELECT amount FROM fin_reco_bank_entries WHERE ID = @id",
                FinanceDB.P("@id", bankEntryId));

            // Get ledger entry amount
            decimal ledgerAmt = FinanceDB.ExecuteScalar<decimal>(
                "SELECT transaction_amount FROM fin_ledger WHERE TID = @tid",
                FinanceDB.P("@tid", ledgerTid));

            if (bankAmt != ledgerAmt)
            {
                ShowMessage(string.Format("Amount mismatch: Bank={0}, Ledger={1}. Amounts must match.",
                    MoneyHelper.FormatNumber(bankAmt), MoneyHelper.FormatNumber(ledgerAmt)), false);
                return;
            }

            // Perform match: update bank entry's match_TID to point to ledger TID
            FinanceDB.ExecuteNonQuery(
                "UPDATE fin_reco_bank_entries SET match_TID = @tid WHERE ID = @id",
                FinanceDB.P("@tid", ledgerTid),
                FinanceDB.P("@id", bankEntryId));

            FinanceLogger.LogAction(PAGE_NAME, "ManualMatch",
                "BankEntryID=" + bankEntryId + " LedgerTID=" + ledgerTid + " Amount=" + bankAmt);
            ShowMessage("Entries matched successfully.", true);

            hdnSelectedBank.Value = "";
            hdnSelectedLedger.Value = "";
            LoadData();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnManualMatch_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    // ── Unmatch ─────────────────────────────────────────────────

    protected void btnUnmatch_Click(object sender, EventArgs e)
    {
        int bankEntryId;
        if (!int.TryParse(hdnSelectedBank.Value, out bankEntryId) || bankEntryId <= 0)
        {
            ShowMessage("Select a bank statement entry to unmatch.", false);
            return;
        }

        try
        {
            FinanceDB.ExecuteNonQuery(
                "UPDATE fin_reco_bank_entries SET match_TID = 0 WHERE ID = @id",
                FinanceDB.P("@id", bankEntryId));

            FinanceLogger.LogAction(PAGE_NAME, "Unmatch", "BankEntryID=" + bankEntryId);
            ShowMessage("Entry unmatched.", true);

            hdnSelectedBank.Value = "";
            LoadData();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnUnmatch_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    // ── New Statement ───────────────────────────────────────────

    protected void btnNewStatement_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(ddlBank.SelectedValue))
        {
            ShowMessage("Select a bank account first.", false);
            return;
        }
        pnlNewStatement.Visible = true;
        txtStmtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        txtStmtTitle.Text = "RECONCILIATION STATEMENT [" + DateTime.Today.ToString("dd MMMM, yyyy").ToUpper() + "]";
    }

    protected void btnCreateStatement_Click(object sender, EventArgs e)
    {
        string bankCode = ddlBank.SelectedValue;
        if (string.IsNullOrEmpty(bankCode)) return;

        DateTime stmtDate;
        if (!DateTime.TryParse(txtStmtDate.Text, out stmtDate))
            stmtDate = DateTime.Today;

        decimal stmtBalance = MoneyHelper.ParseMoney(txtStmtBalance.Text);
        string title = txtStmtTitle.Text.Trim();
        if (string.IsNullOrEmpty(title))
            title = "RECONCILIATION STATEMENT [" + stmtDate.ToString("dd MMMM, yyyy").ToUpper() + "]";

        try
        {
            // Get last reco balance as the opening balance for new statement
            object lastBal = FinanceDB.ExecuteScalar<object>(
                @"SELECT statement_balance FROM fin_reconciliationstatement
                  WHERE bank_code = @bc ORDER BY rec_date DESC LIMIT 1",
                FinanceDB.P("@bc", bankCode));
            decimal lastRecoBalance = lastBal != null ? MoneyHelper.ToDecimal(lastBal) : 0;

            FinanceDB.ExecuteNonQuery(
                @"INSERT INTO fin_reconciliationstatement
                    (rec_date, last_rec_balance, statement_date, statement_balance, rec_status, bank_code, title)
                  VALUES (@rd, @lb, @sd, @sb, 'Pending', @bc, @t)",
                FinanceDB.P("@rd", stmtDate),
                FinanceDB.P("@lb", lastRecoBalance),
                FinanceDB.P("@sd", stmtDate),
                FinanceDB.P("@sb", stmtBalance),
                FinanceDB.P("@bc", bankCode),
                FinanceDB.P("@t", title));

            FinanceLogger.LogAction(PAGE_NAME, "CreateStatement",
                "Bank=" + bankCode + " Date=" + stmtDate.ToString("yyyy-MM-dd") + " Balance=" + stmtBalance);
            ShowMessage("Reconciliation statement created.", true);

            pnlNewStatement.Visible = false;
            LoadStatements();
            LoadData();
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnCreateStatement_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    protected void btnCancelNew_Click(object sender, EventArgs e)
    {
        pnlNewStatement.Visible = false;
    }

    // ── Reco Summary ────────────────────────────────────────────

    protected void btnViewSummary_Click(object sender, EventArgs e)
    {
        int recoId = GetSelectedStatementId();
        string bankCode = ddlBank.SelectedValue;

        if (recoId <= 0 || string.IsNullOrEmpty(bankCode))
        {
            ShowMessage("Select a bank account and statement to view summary.", false);
            return;
        }

        try
        {
            DataTable dt = FinanceDB.ExecuteSP("fin_GetReconciliationStatement",
                FinanceDB.P("@RID", recoId),
                FinanceDB.P("@bankcode", bankCode));

            rptSummary.DataSource = dt;
            rptSummary.DataBind();
            pnlSummary.Visible = dt.Rows.Count > 0;

            if (dt.Rows.Count == 0)
                ShowMessage("No reconciliation summary data available.", false);
        }
        catch (Exception ex)
        {
            FinanceLogger.LogError(PAGE_NAME, "btnViewSummary_Click", ex);
            ShowMessage("Error: " + ex.Message, false);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────

    private int GetSelectedStatementId()
    {
        int id;
        return int.TryParse(ddlStatement.SelectedValue, out id) ? id : 0;
    }

    private void ClearAll()
    {
        rptBankEntries.DataSource = null;
        rptBankEntries.DataBind();
        rptLedger.DataSource = null;
        rptLedger.DataBind();
        litBankCount.Text = "0 entries";
        litLedgerCount.Text = "0 entries";
        litStmtBal.Text = "--";
        litLedgerBal.Text = "--";
        litMatched.Text = "0";
        litUnmatched.Text = "0";
        litFooter.Text = "";
    }

    protected string FormatAmount(object val)
    {
        return MoneyHelper.FormatNumber(MoneyHelper.ToDecimal(val));
    }

    protected string FormatDR(object transType, object amount)
    {
        if (transType != null && transType.ToString().Trim().ToUpper() == "DR")
            return MoneyHelper.FormatNumber(MoneyHelper.ToDecimal(amount));
        return "";
    }

    protected string FormatCR(object transType, object amount)
    {
        if (transType != null && transType.ToString().Trim().ToUpper() == "CR")
            return MoneyHelper.FormatNumber(MoneyHelper.ToDecimal(amount));
        return "";
    }

    protected string GetMatchBadge(object matchTid)
    {
        int tid = Convert.ToInt32(matchTid);
        if (tid != 0)
            return "<span style='background:#e8f5e9;color:#2e7d32;padding:2px 6px;border-radius:3px;font-size:9px;'>Matched</span>";
        return "<span style='background:#fff3e0;color:#e65100;padding:2px 6px;border-radius:3px;font-size:9px;'>Pending</span>";
    }

    private void ShowMessage(string msg, bool isSuccess)
    {
        pnlMsg.Visible = true;
        pnlMsg.CssClass = isSuccess ? "br-msg br-msg-ok" : "br-msg br-msg-err";
        litMsg.Text = HttpUtility.HtmlEncode(msg);
    }
}
