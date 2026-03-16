using System;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// F2: Centralized audit logger for the accounting module.
/// Writes structured entries to acc_activity_log including IP address,
/// session ID, affected voucher, financial amount, and before/after values.
/// All methods are static and fail silently — a logging failure must never
/// break a financial transaction.
/// </summary>
public static class AuditLogger
{
    private static string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }

    /// <summary>
    /// Logs an accounting action to acc_activity_log.
    /// </summary>
    /// <param name="action">Action code: RECEIPT_CREATED, JOURNAL_APPROVED, VOUCHER_CREATED, etc.</param>
    /// <param name="details">Human-readable description of what happened.</param>
    /// <param name="voucherNo">Optional voucher/journal number affected.</param>
    /// <param name="amount">Optional financial amount involved.</param>
    /// <param name="beforeValue">Optional serialized value before the change.</param>
    /// <param name="afterValue">Optional serialized value after the change.</param>
    public static void Log(
        string action,
        string details,
        int? voucherNo = null,
        decimal? amount = null,
        string beforeValue = null,
        string afterValue = null)
    {
        try
        {
            string userId = null;
            string ipAddress = null;
            string sessionId = null;

            // Safely read HttpContext — may not be available in all contexts
            if (HttpContext.Current != null)
            {
                if (HttpContext.Current.User != null && HttpContext.Current.User.Identity != null)
                    userId = HttpContext.Current.User.Identity.Name;

                if (HttpContext.Current.Request != null)
                    ipAddress = GetClientIp(HttpContext.Current.Request);

                if (HttpContext.Current.Session != null)
                    sessionId = HttpContext.Current.Session.SessionID;
            }

            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                const string sql = @"
                    INSERT INTO acc_activity_log
                        (user_id, page_function, par, comments, access_date,
                         ip_address, session_id, affected_voucherNo, affected_amount,
                         before_value, after_value)
                    VALUES
                        (@userId, @action, @details, NULL, NOW(),
                         @ipAddress, @sessionId, @voucherNo, @amount,
                         @beforeValue, @afterValue)";

                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@userId",      (object)userId      ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@action",      (object)action      ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@details",     (object)details     ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ipAddress",   (object)ipAddress   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@sessionId",   (object)sessionId   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@voucherNo",   (object)voucherNo   ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@amount",      (object)amount      ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@beforeValue", (object)beforeValue ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@afterValue",  (object)afterValue  ?? DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch
        {
            // Audit logging must never break a transaction — swallow silently
        }
    }

    /// <summary>
    /// Convenience overload for approval events.
    /// </summary>
    public static void LogApproval(string action, int journalNo, string journalType, decimal drTotal, decimal crTotal)
    {
        Log(
            action,
            string.Format("JournalNo={0}, Type={1}", journalNo, journalType),
            journalNo,
            drTotal,
            string.Format("DR={0:N0},CR={1:N0}", drTotal, crTotal),
            "Posted"
        );
    }

    /// <summary>
    /// Convenience overload for creation events.
    /// </summary>
    public static void LogCreation(string action, int journalNo, string accountCode, decimal amount)
    {
        Log(
            action,
            string.Format("JournalNo={0}, Account={1}, Amount={2:N0}", journalNo, accountCode, amount),
            journalNo,
            amount
        );
    }

    private static string GetClientIp(HttpRequest request)
    {
        // Check forwarded headers first (reverse proxy / load balancer)
        string ip = request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (!string.IsNullOrEmpty(ip))
        {
            // X-Forwarded-For can contain a comma-separated list — take the first
            int comma = ip.IndexOf(',');
            return comma > 0 ? ip.Substring(0, comma).Trim() : ip.Trim();
        }
        return request.ServerVariables["REMOTE_ADDR"] ?? request.UserHostAddress;
    }
}
