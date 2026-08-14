using System;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Structured logger for the Finance module within COOPERP.
/// Writes to acc_activity_log in campus_dynamics_accounts.
///
/// All methods fail silently — a logging failure must NEVER break a
/// financial transaction. Uses FinanceDB for connection management.
///
/// Table schema (acc_activity_log):
///   id INT AUTO_INCREMENT PK
///   user_id VARCHAR
///   page_function VARCHAR          (action code, e.g. "JOURNAL_CREATED")
///   par VARCHAR                    (details / description)
///   comments TEXT                  (extra notes)
///   access_date DATETIME
///   ip_address VARCHAR
///   session_id VARCHAR
///   affected_voucherNo INT NULL
///   affected_amount DECIMAL NULL
///   before_value TEXT NULL
///   after_value TEXT NULL
/// </summary>
public static class FinanceLogger
{
    // ───────────────────────── Action Logging ─────────────────────────────

    /// <summary>
    /// Logs a finance action (journal created, voucher approved, period opened, etc.).
    /// </summary>
    /// <param name="action">Action code: JOURNAL_CREATED, VOUCHER_APPROVED, PERIOD_OPEN, LEDGER_FILTER, etc.</param>
    /// <param name="details">Human-readable description of the event.</param>
    /// <param name="userName">User performing the action (null = auto-detect from HttpContext).</param>
    /// <param name="voucherNo">Optional voucher/journal number affected.</param>
    /// <param name="amount">Optional financial amount involved.</param>
    /// <param name="beforeValue">Optional serialized before-state.</param>
    /// <param name="afterValue">Optional serialized after-state.</param>
    // ─────────────────────── Exempt accounts ─────────────────────────────

    private static System.Collections.Generic.List<string> _exempt;
    private static DateTime _exemptLoaded = DateTime.MinValue;
    private static readonly object _exemptLock = new object();

    /// <summary>
    /// True when the account is configured as exempt from the finance action log.
    /// Cached for two minutes because this sits on the path of every finance log entry.
    /// Fails OPEN — if the lookup errors the action is still logged, since losing a
    /// trail silently is worse than an extra row.
    /// </summary>
    public static bool IsExemptFromLogging(string userName)
    {
        if (string.IsNullOrEmpty(userName)) return false;
        try
        {
            lock (_exemptLock)
            {
                if (_exempt == null || (DateTime.UtcNow - _exemptLoaded).TotalMinutes > 2)
                {
                    var fresh = new System.Collections.Generic.List<string>();
                    // sys_log_exempt lives in the academic DB; the finance connection is to the
                    // accounts DB, so it is named explicitly rather than assumed.
                    System.Data.DataTable dt = FinanceDB.ExecuteDataTable(
                        "SELECT username FROM campus_dynamics.sys_log_exempt WHERE scope IN ('ALL','FINANCE')");
                    if (dt != null)
                        foreach (System.Data.DataRow r in dt.Rows)
                            fresh.Add(Convert.ToString(r[0]).Trim().ToLowerInvariant());
                    _exempt = fresh;
                    _exemptLoaded = DateTime.UtcNow;
                }
            }
            return _exempt.Contains(userName.Trim().ToLowerInvariant());
        }
        catch { return false; }
    }

    public static void LogAction(
        string action,
        string details,
        string userName = null,
        int? voucherNo = null,
        decimal? amount = null,
        string beforeValue = null,
        string afterValue = null)
    {
        try
        {
            string userId = userName;
            string ipAddress = null;
            string sessionId = null;

            if (HttpContext.Current != null)
            {
                if (string.IsNullOrEmpty(userId) &&
                    HttpContext.Current.User != null &&
                    HttpContext.Current.User.Identity != null)
                {
                    userId = HttpContext.Current.User.Identity.Name;
                }

                if (HttpContext.Current.Request != null)
                    ipAddress = GetClientIp();

                if (HttpContext.Current.Session != null)
                    sessionId = HttpContext.Current.Session.SessionID;
            }

            // Protected accounts are not written to the finance log. Checked here, at the one
            // point every finance log entry passes through, so no caller can bypass it and no
            // caller has to remember it. Shares sys_log_exempt with the marks log, so an
            // account is exempted once rather than in two places that can drift apart.
            if (IsExemptFromLogging(userId)) return;

            const string sql = @"INSERT INTO acc_activity_log
                (user_id, page_function, par, comments, access_date,
                 ip_address, session_id, affected_voucherNo, affected_amount,
                 before_value, after_value)
                VALUES
                (@userId, @action, @details, NULL, NOW(),
                 @ip, @sess, @vNo, @amt, @before, @after)";

            FinanceDB.ExecuteNonQuery(sql,
                FinanceDB.P("@userId",  (object)userId      ?? DBNull.Value),
                FinanceDB.P("@action",  (object)action      ?? DBNull.Value),
                FinanceDB.P("@details", (object)details     ?? DBNull.Value),
                FinanceDB.P("@ip",      (object)ipAddress   ?? DBNull.Value),
                FinanceDB.P("@sess",    (object)sessionId   ?? DBNull.Value),
                FinanceDB.P("@vNo",     (object)voucherNo   ?? DBNull.Value),
                FinanceDB.P("@amt",     (object)amount      ?? DBNull.Value),
                FinanceDB.P("@before",  (object)beforeValue ?? DBNull.Value),
                FinanceDB.P("@after",   (object)afterValue  ?? DBNull.Value));
        }
        catch
        {
            // Logging must never break a financial operation — fail silently
        }
    }

    // ───────────────────────── Error Logging ──────────────────────────────

    /// <summary>
    /// Logs an error encountered during a finance operation.
    /// Records the exception type, message, and page context.
    /// </summary>
    public static void LogError(string pageName, string operation, Exception ex, string userName = null)
    {
        string details = string.Format("[{0}] {1} — {2}: {3}",
            pageName, operation, ex.GetType().Name, ex.Message);

        LogAction("ERROR", details, userName,
            afterValue: ex.StackTrace != null
                ? ex.StackTrace.Substring(0, Math.Min(ex.StackTrace.Length, 2000))
                : null);
    }

    /// <summary>
    /// Logs a warning (non-fatal issue that should be investigated).
    /// </summary>
    public static void LogWarning(string pageName, string message, string userName = null)
    {
        LogAction("WARNING",
            string.Format("[{0}] {1}", pageName, message),
            userName);
    }

    // ───────────────────────── Convenience Methods ────────────────────────

    /// <summary>Logs a journal creation event.</summary>
    public static void LogJournalCreated(int journalNo, string journalType, string userName)
    {
        LogAction("JOURNAL_CREATED",
            string.Format("Journal #{0} ({1}) created", journalNo, journalType),
            userName, journalNo);
    }

    /// <summary>Logs a journal approval event.</summary>
    public static void LogJournalApproved(int journalNo, string journalType, decimal drTotal, decimal crTotal, string userName)
    {
        LogAction("JOURNAL_APPROVED",
            string.Format("Journal #{0} ({1}) approved. DR={2:N0} CR={3:N0}", journalNo, journalType, drTotal, crTotal),
            userName, journalNo, drTotal,
            string.Format("DR={0:N0},CR={1:N0}", drTotal, crTotal));
    }

    /// <summary>Logs a voucher creation event.</summary>
    public static void LogVoucherCreated(int voucherNo, string voucherType, decimal amount, string userName)
    {
        LogAction("VOUCHER_CREATED",
            string.Format("Voucher #{0} ({1}) created for {2:N0}", voucherNo, voucherType, amount),
            userName, voucherNo, amount);
    }

    /// <summary>Logs a voucher approval event.</summary>
    public static void LogVoucherApproved(int voucherNo, string userName)
    {
        LogAction("VOUCHER_APPROVED",
            string.Format("Voucher #{0} approved", voucherNo),
            userName, voucherNo);
    }

    /// <summary>Logs a report generation event (Trial Balance, Balance Sheet, etc.).</summary>
    public static void LogReportGenerated(string reportName, DateTime startDate, DateTime endDate, string userName = null)
    {
        LogAction("REPORT_GENERATED",
            string.Format("{0} generated for {1:yyyy-MM-dd} to {2:yyyy-MM-dd}", reportName, startDate, endDate),
            userName);
    }

    /// <summary>
    /// Logs a report generation event with a free-form details string
    /// (used by reports that include totals/period info in the message).
    /// </summary>
    public static void LogReportGenerated(string reportName, string details, string userName = null)
    {
        LogAction("REPORT_GENERATED",
            string.IsNullOrEmpty(details) ? reportName : string.Format("{0} — {1}", reportName, details),
            userName);
    }

    // ───────────────────────── Private Helpers ────────────────────────────

    private static string GetClientIp()
    {
        try
        {
            var request = HttpContext.Current.Request;
            string forwarded = request.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(forwarded))
            {
                // Take the first IP if multiple proxies
                string[] ips = forwarded.Split(',');
                return ips[0].Trim();
            }
            return request.ServerVariables["REMOTE_ADDR"] ?? request.UserHostAddress;
        }
        catch
        {
            return null;
        }
    }
}
