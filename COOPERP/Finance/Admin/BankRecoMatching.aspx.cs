using System;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Bank Reconciliation Matching — Finance System Realignment.
/// Provides the bridge between the bank statement import pipeline (BankReconciliationImport.aspx)
/// and the general ledger.  The admin:
///   1. Selects a Passed/Warnings import from fin_reco_bank_statement_import
///   2. Reviews unreconciled fin_ledger entries within the statement date range
///   3. Marks matching entries as bank-reconciled (bank_reconciled = 1, reconciled_by, reconciled_at)
///   4. Views which entries are already matched to this import
///
/// Schema is guarded at every step with TableExists / ColumnExists checks.
/// All reconciliation actions are written to fin_transaction_log.
/// </summary>
public partial class COOPERP_Finance_Admin_BankRecoMatching : System.Web.UI.Page
{
    // ViewState keys
    private const string VS_IMPORT_ID    = "_brm_importid";
    private const string VS_DATE_FROM    = "_brm_datefrom";
    private const string VS_DATE_TO      = "_brm_dateto";
    private const string VS_RECO_COL_OK  = "_brm_recocol";   // bool — bank_reconciled column exists

    // ─── Page Load ───────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblStatus))
        {
            pnlImportSummary.Visible   = false;
            pnlLedgerEntries.Visible   = false;
            pnlReconciledEntries.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindImportDropDown();
        }
    }

    // ─── Populate Import Dropdown ─────────────────────────────────────────────

    private void BindImportDropDown()
    {
        ddlImport.Items.Clear();
        ddlImport.Items.Add(new ListItem("-- Select a validated import --", ""));

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_reco_bank_statement_import"))
                {
                    ShowError("fin_reco_bank_statement_import table is not yet available. Apply Phase 1 schema scripts.");
                    return;
                }

                // Prefer imports that have been validated (Passed or Warnings)
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT
                        import_id,
                        CONCAT(
                            'Import #', import_id,
                            ' | Bank Acc: ', bank_account_id,
                            ' | Date: ', DATE_FORMAT(statement_date, '%Y-%m-%d'),
                            ' | ', validation_status
                        ) AS display_label,
                        statement_date_from,
                        statement_date_to
                    FROM fin_reco_bank_statement_import
                    WHERE validation_status IN ('Passed', 'Warnings', 'Pending')
                    ORDER BY statement_date DESC, import_id DESC
                    LIMIT 100;", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string id    = rdr["import_id"].ToString();
                        string label = rdr["display_label"].ToString();
                        var item     = new ListItem(label, id);

                        // Stash date range in the Value attribute so we don't need ViewState until Load
                        string df = rdr["statement_date_from"] == DBNull.Value ? "" : Convert.ToDateTime(rdr["statement_date_from"]).ToString("yyyy-MM-dd");
                        string dt = rdr["statement_date_to"]   == DBNull.Value ? "" : Convert.ToDateTime(rdr["statement_date_to"]).ToString("yyyy-MM-dd");
                        item.Attributes["data-from"] = df;
                        item.Attributes["data-to"]   = dt;
                        ddlImport.Items.Add(item);
                    }
                }
            }

            if (ddlImport.Items.Count == 1)
            {
                ShowInfo("No validated imports found. Upload and validate a bank statement first using Bank Reconciliation Import Validation.");
            }
        }
        catch (Exception ex)
        {
            ShowError("Error loading import list: " + ex.Message);
        }
    }

    // ─── Load Import ──────────────────────────────────────────────────────────

    protected void btnLoadImport_Click(object sender, EventArgs e)
    {
        string importIdStr = ddlImport.SelectedValue;
        if (string.IsNullOrEmpty(importIdStr))
        {
            ShowError("Please select a bank statement import.");
            return;
        }

        if (!long.TryParse(importIdStr, out long importId))
        {
            ShowError("Invalid import selected.");
            return;
        }

        pnlImportSummary.Visible     = false;
        pnlLedgerEntries.Visible     = false;
        pnlReconciledEntries.Visible = false;
        lblStatus.Text               = string.Empty;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                // ── Fetch import metadata ────────────────────────────────────
                DataRow importRow = null;
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT import_id, bank_account_id, statement_date, validation_status,
                             statement_date_from, statement_date_to,
                             opening_balance, closing_balance, line_count,
                             original_filename, imported_by, imported_at
                      FROM fin_reco_bank_statement_import
                      WHERE import_id = @id;", conn))
                {
                    cmd.Parameters.AddWithValue("@id", importId);
                    DataTable metaDt = new DataTable();
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(metaDt);

                    if (metaDt.Rows.Count == 0)
                    {
                        ShowError("Import not found.");
                        return;
                    }
                    importRow = metaDt.Rows[0];
                }

                // ── Store in ViewState ────────────────────────────────────────
                string dateFrom = importRow["statement_date_from"] == DBNull.Value ? "" : Convert.ToDateTime(importRow["statement_date_from"]).ToString("yyyy-MM-dd");
                string dateTo   = importRow["statement_date_to"]   == DBNull.Value ? "" : Convert.ToDateTime(importRow["statement_date_to"]).ToString("yyyy-MM-dd");

                ViewState[VS_IMPORT_ID]  = importId;
                ViewState[VS_DATE_FROM]  = dateFrom;
                ViewState[VS_DATE_TO]    = dateTo;

                // ── Show import summary ───────────────────────────────────────
                lblImportDetails.Text = string.Format(
                    "<table style='border-collapse:collapse;font-size:13px;'>" +
                    "<tr><td style='padding:3px 12px 3px 0;'><b>Import ID:</b></td><td>{0}</td>" +
                    "    <td style='padding:3px 12px 3px 24px;'><b>Bank Account:</b></td><td>{1}</td></tr>" +
                    "<tr><td><b>Statement Date:</b></td><td>{2}</td>" +
                    "    <td style='padding:3px 12px 3px 24px;'><b>Status:</b></td><td><b style='color:{3};'>{4}</b></td></tr>" +
                    "<tr><td><b>Statement Period:</b></td><td>{5} to {6}</td>" +
                    "    <td style='padding:3px 12px 3px 24px;'><b>Lines:</b></td><td>{7}</td></tr>" +
                    "<tr><td><b>Opening Balance:</b></td><td>{8:N2}</td>" +
                    "    <td style='padding:3px 12px 3px 24px;'><b>Closing Balance:</b></td><td>{9:N2}</td></tr>" +
                    "<tr><td><b>File:</b></td><td>{10}</td>" +
                    "    <td style='padding:3px 12px 3px 24px;'><b>Imported By:</b></td><td>{11} at {12}</td></tr>" +
                    "</table>",
                    importRow["import_id"],
                    importRow["bank_account_id"],
                    importRow["statement_date"] == DBNull.Value ? "—" : Convert.ToDateTime(importRow["statement_date"]).ToString("yyyy-MM-dd"),
                    importRow["validation_status"].ToString() == "Passed" ? "green" : "darkorange",
                    importRow["validation_status"],
                    string.IsNullOrEmpty(dateFrom) ? "—" : dateFrom,
                    string.IsNullOrEmpty(dateTo)   ? "—" : dateTo,
                    importRow["line_count"],
                    importRow["opening_balance"] == DBNull.Value ? 0m : Convert.ToDecimal(importRow["opening_balance"]),
                    importRow["closing_balance"] == DBNull.Value ? 0m : Convert.ToDecimal(importRow["closing_balance"]),
                    Server.HtmlEncode(importRow["original_filename"] == DBNull.Value ? "—" : importRow["original_filename"].ToString()),
                    importRow["imported_by"],
                    importRow["imported_at"] == DBNull.Value ? "—" : Convert.ToDateTime(importRow["imported_at"]).ToString("yyyy-MM-dd HH:mm"));

                pnlImportSummary.Visible = true;

                // ── Check for bank_reconciled column ─────────────────────────
                bool recoColExists = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "bank_reconciled");
                ViewState[VS_RECO_COL_OK] = recoColExists;

                if (!recoColExists)
                {
                    ShowInfo("Note: fin_ledger.bank_reconciled column is not yet present. Apply Phase1_4_Alter_fin_ledger.sql to enable matching.");
                    pnlLedgerEntries.Visible     = true;
                    pnlReconciledEntries.Visible = true;
                    ClearGrids();
                    return;
                }

                // ── Load unreconciled entries ────────────────────────────────
                BindLedgerEntries(conn, dateFrom, dateTo, reconciled: false);

                // ── Load reconciled entries for this import ──────────────────
                BindReconciledEntries(conn, importId, dateFrom, dateTo);
            }

            pnlLedgerEntries.Visible     = true;
            pnlReconciledEntries.Visible = true;
            ShowInfo(string.Format("Import #{0} loaded. Match unreconciled ledger entries below.", importId));
        }
        catch (Exception ex)
        {
            ShowError("Error loading import: " + ex.Message);
        }
    }

    // ─── Mark Reconciled (Row Command) ───────────────────────────────────────

    protected void gvLedgerEntries_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "MarkReconciled") return;

        if (!long.TryParse(e.CommandArgument.ToString(), out long ledgerId))
        {
            ShowError("Invalid ledger entry selected.");
            return;
        }

        object importIdObj = ViewState[VS_IMPORT_ID];
        if (importIdObj == null)
        {
            ShowError("Session state lost. Please reload the import.");
            return;
        }
        long importId = Convert.ToInt64(importIdObj);

        string reconciledBy = Session["username"] != null ? Session["username"].ToString() : User.Identity.Name;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                bool recoColExists = ViewState[VS_RECO_COL_OK] is bool b && b;
                if (!recoColExists)
                    recoColExists = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "bank_reconciled");

                if (!recoColExists)
                {
                    ShowError("bank_reconciled column not available. Apply Phase1_4_Alter_fin_ledger.sql first.");
                    return;
                }

                // Determine column names via schema guard
                string reconByCol  = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "reconciled_by")  ? "reconciled_by"  : null;
                string reconAtCol  = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "reconciled_at")  ? "reconciled_at"  : null;
                string importIdCol = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "bank_import_id") ? "bank_import_id" : null;

                // Build UPDATE dynamically based on which optional columns exist
                string updateSql = "UPDATE fin_ledger SET bank_reconciled = 1";
                if (reconByCol  != null) updateSql += string.Format(", {0} = @reconBy",  reconByCol);
                if (reconAtCol  != null) updateSql += string.Format(", {0} = NOW()",     reconAtCol);
                if (importIdCol != null) updateSql += string.Format(", {0} = @importId", importIdCol);
                updateSql += " WHERE ledger_id = @lid AND (bank_reconciled IS NULL OR bank_reconciled = 0);";

                using (MySqlCommand upd = new MySqlCommand(updateSql, conn))
                {
                    upd.Parameters.AddWithValue("@lid",      ledgerId);
                    if (reconByCol  != null) upd.Parameters.AddWithValue("@reconBy",  reconciledBy);
                    if (importIdCol != null) upd.Parameters.AddWithValue("@importId", importId);
                    int rows = upd.ExecuteNonQuery();

                    if (rows == 0)
                    {
                        ShowInfo("This entry was already reconciled (possibly by another user). Grid refreshed.");
                    }
                    else
                    {
                        // Increment matched lines counter on the import record (if column exists)
                        bool hasMatchedCol = FinanceSystemRealignmentHelper.ColumnExists(
                            conn, "fin_reco_bank_statement_import", "reconciliation_matched_lines");

                        if (hasMatchedCol)
                        {
                            using (MySqlCommand inc = new MySqlCommand(
                                @"UPDATE fin_reco_bank_statement_import
                                  SET reconciliation_matched_lines = COALESCE(reconciliation_matched_lines, 0) + 1
                                  WHERE import_id = @iid;", conn))
                            {
                                inc.Parameters.AddWithValue("@iid", importId);
                                inc.ExecuteNonQuery();
                            }
                        }

                        // Audit log
                        FinanceSystemRealignmentHelper.LogAction(conn,
                            action:    "BankRecoMatched",
                            tableName: "fin_ledger",
                            recordId:  (int)ledgerId,
                            batchId:   0,
                            changedBy: reconciledBy,
                            reasonText: string.Format("Marked reconciled against import #{0}", importId));

                        ShowSuccess(string.Format("Ledger entry #{0} marked as bank-reconciled against Import #{1}.", ledgerId, importId));
                    }
                }

                // Refresh both grids
                string dateFrom = ViewState[VS_DATE_FROM]?.ToString() ?? "";
                string dateTo   = ViewState[VS_DATE_TO]?.ToString()   ?? "";
                BindLedgerEntries(conn, dateFrom, dateTo, reconciled: false);
                BindReconciledEntries(conn, importId, dateFrom, dateTo);
            }
        }
        catch (Exception ex)
        {
            ShowError("Error marking entry reconciled: " + ex.Message);
        }
    }

    // ─── Data Binding Helpers ─────────────────────────────────────────────────

    private void BindLedgerEntries(MySqlConnection conn, string dateFrom, string dateTo, bool reconciled)
    {
        DataTable dt = BuildLedgerSchema();

        string voucherCol  = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "voucherno", "voucher_no", "voucher_number", "ref_no" });
        string accountCol  = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "account_code", "acc_code", "code" });
        string drcrCol     = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "dr_cr", "entry_type", "drcr", "type" });
        string amountCol   = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "amount", "entry_amount", "value" });
        string narrationCol= FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "narration", "description", "remarks", "memo" });
        string dateCol     = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "entry_date", "trans_date", "date", "posting_date" });

        if (amountCol == null)
        {
            gvLedgerEntries.DataSource = dt;
            gvLedgerEntries.DataBind();
            return;
        }

        // Build WHERE clause for date range (only when we have a date column and dates)
        string dateWhere = "";
        if (dateCol != null && !string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(dateTo))
            dateWhere = string.Format(" AND DATE(l.{0}) BETWEEN @dateFrom AND @dateTo", dateCol);

        string recoWhere = " AND (l.bank_reconciled IS NULL OR l.bank_reconciled = 0)";

        string sql = string.Format(
            @"SELECT
                l.ledger_id                                             AS LedgerId,
                {0}                                                     AS VoucherNo,
                {1}                                                     AS AccountCode,
                {2}                                                     AS EntryType,
                l.{3}                                                   AS Amount,
                {4}                                                     AS Narration,
                {5}                                                     AS EntryDate
            FROM fin_ledger l
            WHERE 1=1 {6} {7}
            ORDER BY l.ledger_id DESC
            LIMIT 500;",
            voucherCol   != null ? "l." + voucherCol   : "''",
            accountCol   != null ? "l." + accountCol   : "''",
            drcrCol      != null ? "l." + drcrCol      : "''",
            amountCol,
            narrationCol != null ? "l." + narrationCol : "''",
            dateCol      != null ? string.Format("DATE_FORMAT(l.{0}, '%Y-%m-%d')", dateCol) : "''",
            dateWhere,
            recoWhere);

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (!string.IsNullOrEmpty(dateWhere))
            {
                cmd.Parameters.AddWithValue("@dateFrom", dateFrom);
                cmd.Parameters.AddWithValue("@dateTo",   dateTo);
            }
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                da.Fill(dt);
        }

        gvLedgerEntries.DataSource = dt;
        gvLedgerEntries.DataBind();
    }

    private void BindReconciledEntries(MySqlConnection conn, long importId, string dateFrom, string dateTo)
    {
        DataTable dt = BuildLedgerSchema();
        dt.Columns.Add("ReconciledBy", typeof(string));
        dt.Columns.Add("ReconciledAt", typeof(string));

        string voucherCol   = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "voucherno", "voucher_no", "ref_no" });
        string accountCol   = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "account_code", "acc_code", "code" });
        string drcrCol      = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "dr_cr", "entry_type", "drcr", "type" });
        string amountCol    = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "amount", "entry_amount", "value" });
        string narrationCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "narration", "description", "remarks", "memo" });
        string dateCol      = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "entry_date", "trans_date", "date", "posting_date" });
        string reconByCol   = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "reconciled_by")  ? "reconciled_by"  : null;
        string reconAtCol   = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "reconciled_at")  ? "reconciled_at"  : null;
        string importIdCol  = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_ledger", "bank_import_id") ? "bank_import_id" : null;

        if (amountCol == null)
        {
            gvReconciledEntries.DataSource = dt;
            gvReconciledEntries.DataBind();
            return;
        }

        // Filter by import_id if we have that column, otherwise by date range + reconciled = 1
        string filterWhere;
        if (importIdCol != null)
            filterWhere = " AND l.bank_reconciled = 1 AND l.bank_import_id = @importId";
        else if (dateCol != null && !string.IsNullOrEmpty(dateFrom) && !string.IsNullOrEmpty(dateTo))
            filterWhere = string.Format(" AND l.bank_reconciled = 1 AND DATE(l.{0}) BETWEEN @dateFrom AND @dateTo", dateCol);
        else
            filterWhere = " AND l.bank_reconciled = 1";

        string sql = string.Format(
            @"SELECT
                l.ledger_id                                             AS LedgerId,
                {0}                                                     AS VoucherNo,
                {1}                                                     AS AccountCode,
                {2}                                                     AS EntryType,
                l.{3}                                                   AS Amount,
                {4}                                                     AS Narration,
                {5}                                                     AS EntryDate,
                {6}                                                     AS ReconciledBy,
                {7}                                                     AS ReconciledAt
            FROM fin_ledger l
            WHERE 1=1 {8}
            ORDER BY l.ledger_id DESC
            LIMIT 500;",
            voucherCol  != null ? "l." + voucherCol   : "''",
            accountCol  != null ? "l." + accountCol   : "''",
            drcrCol     != null ? "l." + drcrCol      : "''",
            amountCol,
            narrationCol != null ? "l." + narrationCol : "''",
            dateCol      != null ? string.Format("DATE_FORMAT(l.{0}, '%Y-%m-%d')", dateCol) : "''",
            reconByCol  != null ? "l." + reconByCol  : "''",
            reconAtCol  != null ? string.Format("DATE_FORMAT(l.{0}, '%Y-%m-%d %H:%i')", reconAtCol) : "''",
            filterWhere);

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (importIdCol != null)
                cmd.Parameters.AddWithValue("@importId", importId);
            else if (filterWhere.Contains("@dateFrom"))
            {
                cmd.Parameters.AddWithValue("@dateFrom", dateFrom);
                cmd.Parameters.AddWithValue("@dateTo",   dateTo);
            }
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                da.Fill(dt);
        }

        gvReconciledEntries.DataSource = dt;
        gvReconciledEntries.DataBind();
    }

    private DataTable BuildLedgerSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("LedgerId",    typeof(string));
        dt.Columns.Add("VoucherNo",   typeof(string));
        dt.Columns.Add("AccountCode", typeof(string));
        dt.Columns.Add("EntryType",   typeof(string));
        dt.Columns.Add("Amount",      typeof(decimal));
        dt.Columns.Add("Narration",   typeof(string));
        dt.Columns.Add("EntryDate",   typeof(string));
        return dt;
    }

    private void ClearGrids()
    {
        DataTable emptyLedger = BuildLedgerSchema();
        gvLedgerEntries.DataSource = emptyLedger;
        gvLedgerEntries.DataBind();

        DataTable emptyReco = BuildLedgerSchema();
        emptyReco.Columns.Add("ReconciledBy", typeof(string));
        emptyReco.Columns.Add("ReconciledAt", typeof(string));
        gvReconciledEntries.DataSource = emptyReco;
        gvReconciledEntries.DataBind();
    }

    // ─── Status Helpers ───────────────────────────────────────────────────────

    private void ShowError(string message)
    {
        lblStatus.ForeColor = System.Drawing.Color.DarkRed;
        lblStatus.Text      = message;
    }

    private void ShowInfo(string message)
    {
        lblStatus.ForeColor = System.Drawing.Color.DarkBlue;
        lblStatus.Text      = message;
    }

    private void ShowSuccess(string message)
    {
        lblStatus.ForeColor = System.Drawing.Color.DarkGreen;
        lblStatus.Text      = message;
    }
}
