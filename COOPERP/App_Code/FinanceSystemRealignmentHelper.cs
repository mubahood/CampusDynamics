using System;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Shared static helper for all Finance System Realignment admin interfaces.
/// 
/// Responsibilities:
///   1. EnsureFinanceAdminAccess  — server-side role gating (all realignment pages call this)
///   2. GetFinanceConnectionString — priority-chain connection string resolver
///   3. TableExists               — schema-aware guard before querying new roadmap tables
///   4. GetNextVoucherNumber      — atomic, race-safe voucher numbering via fin_voucher_sequence
///   5. CreateTransactionBatch    — opens a new batch record in fin_transaction_batch
///   6. MarkBatchComplete         — stamps completed_at + updates DR/CR totals
///   7. MarkBatchFailed           — records error message and sets status = Failed
///   8. FormatVoucherNumber       — formats type + number + year into a human-readable ref
/// </summary>
public static class FinanceSystemRealignmentHelper
{
    // ─── Access Control ───────────────────────────────────────────────────────

    private static readonly string[] AllowedRoles = new[]
    {
        "Administrator",
        "FinanceAdmin",
        "Bursar",
        "Accountant",
        "SuperAdmin"
    };

    public static bool EnsureFinanceAdminAccess(Page page, Label messageLabel)
    {
        if (page == null)
            return false;

        var user = HttpContext.Current != null ? HttpContext.Current.User : page.User;
        if (user == null || user.Identity == null || !user.Identity.IsAuthenticated)
        {
            page.Response.Redirect("~/Default.aspx", true);
            return false;
        }

        bool hasAllowedRole = false;
        for (int i = 0; i < AllowedRoles.Length; i++)
        {
            if (user.IsInRole(AllowedRoles[i]))
            {
                hasAllowedRole = true;
                break;
            }
        }

        if (!hasAllowedRole)
        {
            if (messageLabel != null)
            {
                messageLabel.ForeColor = System.Drawing.Color.DarkRed;
                messageLabel.Text = "Access denied. This Finance System Realignment interface is restricted to authorized finance administrators.";
            }

            page.Response.StatusCode = 403;
            return false;
        }

        return true;
    }

    // ─── Connection String ────────────────────────────────────────────────────

    public static string GetFinanceConnectionString()
    {
        var csMain = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        if (csMain != null && !string.IsNullOrWhiteSpace(csMain.ConnectionString))
            return csMain.ConnectionString;

        var csPortal = ConfigurationManager.ConnectionStrings["campus_dynamics_portalConnectionString"];
        if (csPortal != null && !string.IsNullOrWhiteSpace(csPortal.ConnectionString))
            return csPortal.ConnectionString;

        return "server=102.34.160.47;User Id=dbmanager;password=24thdecember1977;database=campus_dynamics_portal;Convert Zero Datetime=True";
    }

    // ─── Schema Guards ────────────────────────────────────────────────────────

    /// <summary>
    /// Returns true if the specified table exists in the connected database.
    /// Uses information_schema to avoid exceptions when roadmap tables are
    /// not yet deployed.
    /// </summary>
    public static bool TableExists(MySqlConnection connection, string tableName)
    {
        if (connection == null || string.IsNullOrWhiteSpace(tableName))
            return false;

        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = @db AND table_name = @table",
            connection))
        {
            cmd.Parameters.AddWithValue("@db",    connection.Database);
            cmd.Parameters.AddWithValue("@table", tableName);
            object scalar = cmd.ExecuteScalar();
            int count = 0;
            if (scalar != null) int.TryParse(scalar.ToString(), out count);
            return count > 0;
        }
    }

    /// <summary>
    /// Returns true if a specific column exists on a table in the current database.
    /// This is used heavily by realignment pages to support production-safe queries
    /// where legacy schemas may use slightly different column names.
    /// </summary>
    public static bool ColumnExists(MySqlConnection connection, string tableName, string columnName)
    {
        if (connection == null || string.IsNullOrWhiteSpace(tableName) || string.IsNullOrWhiteSpace(columnName))
            return false;

        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = @db AND table_name = @table AND column_name = @column",
            connection))
        {
            cmd.Parameters.AddWithValue("@db", connection.Database);
            cmd.Parameters.AddWithValue("@table", tableName);
            cmd.Parameters.AddWithValue("@column", columnName);
            object scalar = cmd.ExecuteScalar();
            int count = 0;
            if (scalar != null) int.TryParse(scalar.ToString(), out count);
            return count > 0;
        }
    }

    /// <summary>
    /// Returns the first column name from the candidate list that exists on the
    /// target table. Returns empty string if none are found.
    /// </summary>
    public static string GetFirstExistingColumn(MySqlConnection connection, string tableName, params string[] candidateColumns)
    {
        if (candidateColumns == null || candidateColumns.Length == 0)
            return string.Empty;

        for (int i = 0; i < candidateColumns.Length; i++)
        {
            if (ColumnExists(connection, tableName, candidateColumns[i]))
                return candidateColumns[i];
        }

        return string.Empty;
    }

    private static string QuoteIdentifier(string identifier)
    {
        if (string.IsNullOrWhiteSpace(identifier))
            return string.Empty;

        return "`" + identifier.Replace("`", "``") + "`";
    }

    /// <summary>
    /// Prepares a voucher/journal for batch-based posting by optionally tagging
    /// all lines with the supplied batch id and validating that the entry is
    /// balanced before approval/posting continues.
    /// </summary>
    public static bool TryPrepareBatchForVoucher(
        MySqlConnection conn,
        string tableName,
        string voucherColumn,
        int voucherNumber,
        int batchId,
        out int transactionCount,
        out decimal totalDebit,
        out decimal totalCredit,
        out string validationMessage)
    {
        transactionCount = 0;
        totalDebit = 0m;
        totalCredit = 0m;
        validationMessage = string.Empty;

        if (conn == null || voucherNumber <= 0 || string.IsNullOrWhiteSpace(tableName) || string.IsNullOrWhiteSpace(voucherColumn))
        {
            validationMessage = "Invalid voucher reference supplied for batch preparation.";
            return false;
        }

        if (!TableExists(conn, tableName) || !ColumnExists(conn, tableName, voucherColumn))
        {
            // Graceful no-op when roadmap schema is not fully deployed.
            return true;
        }

        string quotedTable = QuoteIdentifier(tableName);
        string quotedVoucherColumn = QuoteIdentifier(voucherColumn);

        using (MySqlCommand countCmd = new MySqlCommand(
            "SELECT COUNT(*) FROM " + quotedTable + " WHERE " + quotedVoucherColumn + " = @voucherNo;",
            conn))
        {
            countCmd.Parameters.AddWithValue("@voucherNo", voucherNumber);
            object countResult = countCmd.ExecuteScalar();
            if (countResult != null)
                int.TryParse(countResult.ToString(), out transactionCount);
        }

        if (transactionCount <= 0)
        {
            validationMessage = "No transaction lines were found for the selected voucher. Add at least two balanced lines before approval.";
            return false;
        }

        if (batchId > 0 && ColumnExists(conn, tableName, "batch_id"))
        {
            using (MySqlCommand tagCmd = new MySqlCommand(
                "UPDATE " + quotedTable + " SET `batch_id` = @batchId WHERE " + quotedVoucherColumn + " = @voucherNo AND (`batch_id` IS NULL OR `batch_id` = 0);",
                conn))
            {
                tagCmd.Parameters.AddWithValue("@batchId", batchId);
                tagCmd.Parameters.AddWithValue("@voucherNo", voucherNumber);
                tagCmd.ExecuteNonQuery();
            }
        }

        string amountColumn = GetFirstExistingColumn(conn, tableName, "transaction_amount", "amount", "Amount");
        string typeColumn = GetFirstExistingColumn(conn, tableName, "transactionType", "transaction_type", "drcr");

        if (string.IsNullOrWhiteSpace(amountColumn) || string.IsNullOrWhiteSpace(typeColumn))
        {
            return true;
        }

        using (MySqlCommand totalsCmd = new MySqlCommand(
            "SELECT " +
            "COALESCE(SUM(CASE WHEN UPPER(" + QuoteIdentifier(typeColumn) + ") = 'DR' THEN " + QuoteIdentifier(amountColumn) + " ELSE 0 END), 0), " +
            "COALESCE(SUM(CASE WHEN UPPER(" + QuoteIdentifier(typeColumn) + ") = 'CR' THEN " + QuoteIdentifier(amountColumn) + " ELSE 0 END), 0) " +
            "FROM " + quotedTable + " WHERE " + quotedVoucherColumn + " = @voucherNo;",
            conn))
        {
            totalsCmd.Parameters.AddWithValue("@voucherNo", voucherNumber);
            using (MySqlDataReader reader = totalsCmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    totalDebit = reader.IsDBNull(0) ? 0m : Convert.ToDecimal(reader.GetValue(0));
                    totalCredit = reader.IsDBNull(1) ? 0m : Convert.ToDecimal(reader.GetValue(1));
                }
            }
        }

        if (transactionCount < 2)
        {
            validationMessage = "At least two transaction lines are required before approval/posting.";
            return false;
        }

        if (decimal.Round(totalDebit, 2) != decimal.Round(totalCredit, 2))
        {
            validationMessage = string.Format(
                "Double-entry validation failed. Debit = {0:N2}, Credit = {1:N2}. Approval has been stopped until the voucher is balanced.",
                totalDebit,
                totalCredit);
            return false;
        }

        return true;
    }

    // ─── Atomic Voucher Number Generation ────────────────────────────────────

    /// <summary>
    /// Atomically retrieves and increments the next voucher number for the
    /// given type using the LAST_INSERT_ID() trick for race-condition safety.
    /// Requires fin_voucher_sequence (Phase 1.1 script) to be deployed.
    /// Returns -1 if the table is not yet available or an error occurs.
    /// </summary>
    public static int GetNextVoucherNumber(MySqlConnection conn, string voucherType)
    {
        if (!TableExists(conn, "fin_voucher_sequence"))
            return -1;

        try
        {
            // Atomic increment
            using (MySqlCommand upd = new MySqlCommand(@"
                UPDATE fin_voucher_sequence
                SET current_number = LAST_INSERT_ID(current_number + 1),
                    updated_at     = NOW()
                WHERE voucher_type = @vtype;", conn))
            {
                upd.Parameters.AddWithValue("@vtype", voucherType);
                int affected = upd.ExecuteNonQuery();

                if (affected == 0)
                {
                    // Row not seeded — insert it gracefully
                    using (MySqlCommand ins = new MySqlCommand(@"
                        INSERT INTO fin_voucher_sequence (voucher_type, current_number)
                        VALUES (@vtype, 1)
                        ON DUPLICATE KEY UPDATE current_number = current_number + 1;", conn))
                    {
                        ins.Parameters.AddWithValue("@vtype", voucherType);
                        ins.ExecuteNonQuery();
                    }
                    return 1;
                }
            }

            // Retrieve the value that LAST_INSERT_ID() captured
            using (MySqlCommand sel = new MySqlCommand("SELECT LAST_INSERT_ID();", conn))
            {
                object result = sel.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : -1;
            }
        }
        catch
        {
            return -1;
        }
    }

    /// <summary>
    /// Formats a voucher number into a human-readable reference string.
    /// Example: FormatVoucherNumber("REC", 1245, "2025") → "REC-2025-001245"
    /// </summary>
    public static string FormatVoucherNumber(string prefix, int number, string fiscalYear = null)
    {
        string yearPart = string.IsNullOrWhiteSpace(fiscalYear)
            ? DateTime.Now.Year.ToString()
            : fiscalYear.Substring(0, Math.Min(4, fiscalYear.Length));

        return string.Format("{0}-{1}-{2}", prefix, yearPart, number.ToString("D6"));
    }

    // ─── Transaction Batch Management ─────────────────────────────────────────

    /// <summary>
    /// Opens a new entry in fin_transaction_batch and returns the new batch_id.
    /// Status is set to 'InProgress' immediately so monitors can detect stale batches.
    /// Returns -1 if the table is not yet deployed or an error occurs.
    /// </summary>
    public static int CreateTransactionBatch(
        MySqlConnection conn,
        string batchType,
        string createdBy,
        string batchReference = null,
        string sourceSystem   = null)
    {
        if (!TableExists(conn, "fin_transaction_batch"))
            return -1;

        try
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                INSERT INTO fin_transaction_batch
                    (batch_type, created_by, started_at, status, batch_reference, source_system)
                VALUES
                    (@btype, @createdby, NOW(), 'InProgress', @bref, @source);", conn))
            {
                cmd.Parameters.AddWithValue("@btype",     batchType);
                cmd.Parameters.AddWithValue("@createdby", createdBy);
                cmd.Parameters.AddWithValue("@bref",      (object)batchReference ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@source",    (object)sourceSystem   ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }

            using (MySqlCommand sel = new MySqlCommand("SELECT LAST_INSERT_ID();", conn))
            {
                object result = sel.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : -1;
            }
        }
        catch
        {
            return -1;
        }
    }

    /// <summary>
    /// Marks a batch as Completed and stamps the completion time.
    /// Optionally updates the aggregate debit/credit totals and transaction count.
    /// </summary>
    public static void MarkBatchComplete(
        MySqlConnection conn,
        int batchId,
        int transactionCount   = 0,
        decimal totalDebit     = 0m,
        decimal totalCredit    = 0m)
    {
        if (batchId <= 0 || !TableExists(conn, "fin_transaction_batch"))
            return;

        using (MySqlCommand cmd = new MySqlCommand(@"
            UPDATE fin_transaction_batch
            SET status            = 'Completed',
                completed_at      = NOW(),
                transaction_count = @txcount,
                total_debit       = @debit,
                total_credit      = @credit
            WHERE batch_id = @bid AND status = 'InProgress';", conn))
        {
            cmd.Parameters.AddWithValue("@txcount", transactionCount);
            cmd.Parameters.AddWithValue("@debit",   totalDebit);
            cmd.Parameters.AddWithValue("@credit",  totalCredit);
            cmd.Parameters.AddWithValue("@bid",     batchId);
            cmd.ExecuteNonQuery();
        }
    }

    /// <summary>
    /// Marks a batch as Failed and records the error message.
    /// Call this inside a catch block before rolling back the outer transaction.
    /// </summary>
    public static void MarkBatchFailed(MySqlConnection conn, int batchId, string errorMessage)
    {
        if (batchId <= 0 || !TableExists(conn, "fin_transaction_batch"))
            return;

        try
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                UPDATE fin_transaction_batch
                SET status        = 'Failed',
                    completed_at  = NOW(),
                    error_message = @err
                WHERE batch_id = @bid;", conn))
            {
                cmd.Parameters.AddWithValue("@err", errorMessage ?? "Unknown error.");
                cmd.Parameters.AddWithValue("@bid", batchId);
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
            // Swallow — we are already in an error path; do not mask the original exception
        }
    }

    // ─── Audit Logging (lightweight — for use where full AuditLogger is unavailable) ─

    /// <summary>
    /// Inserts a single entry into fin_transaction_log.
    /// Silently no-ops if the table does not exist yet.
    /// </summary>
    public static void LogAction(
        MySqlConnection conn,
        string action,
        string tableName,
        int    recordId,
        int    batchId,
        string changedBy,
        string reasonCode   = null,
        string reasonText   = null,
        string ipAddress    = null)
    {
        if (!TableExists(conn, "fin_transaction_log"))
            return;

        try
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                INSERT INTO fin_transaction_log
                    (action, table_name, record_id, batch_id, changed_by,
                     ip_address, reason_code, reason_text)
                VALUES
                    (@action, @tbl, @rid, @bid, @by, @ip, @rcode, @rtext);", conn))
            {
                cmd.Parameters.AddWithValue("@action", action);
                cmd.Parameters.AddWithValue("@tbl",    tableName);
                cmd.Parameters.AddWithValue("@rid",    recordId);
                cmd.Parameters.AddWithValue("@bid",    batchId > 0 ? (object)batchId : DBNull.Value);
                cmd.Parameters.AddWithValue("@by",     changedBy);
                cmd.Parameters.AddWithValue("@ip",     (object)ipAddress  ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@rcode",  (object)reasonCode ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@rtext",  (object)reasonText ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
            // Swallow — audit logging must never block the primary operation
        }
    }
}
