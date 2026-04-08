using System;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksErrorHandler — Centralised error taxonomy, correlation IDs, and 
/// structured error logging for the Marks module.
///
/// Every unhandled exception in marks AJAX handlers gets:
///   1. A unique short correlation ID (for user reporting)
///   2. Consistent JSON error envelope
///   3. Persisted to acad_marks_error_log for post-mortem
///
/// Error categories:
///   VALIDATION     — bad input or constraint violation
///   AUTHORIZATION  — role or assignment check failed
///   BUSINESS_RULE  — workflow state violation (e.g. locked, already submitted)
///   SYSTEM_ERROR   — unexpected exception (DB timeout, null ref, etc.)
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Tasks: G-01, G-02
/// </summary>
public static class MarksErrorHandler
{
    // ─────────────────────── Error Categories ───────────────────────────

    public const string VALIDATION = "VALIDATION";
    public const string AUTHORIZATION = "AUTHORIZATION";
    public const string BUSINESS_RULE = "BUSINESS_RULE";
    public const string SYSTEM_ERROR = "SYSTEM_ERROR";

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    private static bool _tablesChecked;

    // ─────────────────────── Correlation IDs ────────────────────────────

    /// <summary>
    /// Generates a short 8-character hex correlation ID for end-user reference.
    /// </summary>
    public static string NewCorrelationId()
    {
        return Guid.NewGuid().ToString("N").Substring(0, 8).ToUpperInvariant();
    }

    // ─────────────────────── Error Formatting ───────────────────────────

    /// <summary>
    /// Creates a JSON error response with category and correlation ID.
    /// </summary>
    public static string SafeError(string message, string category, string correlationId)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("{\"error\":");
        sb.Append(JsEsc(message));
        sb.Append(",\"errorCode\":");
        sb.Append(JsEsc(category));
        if (!string.IsNullOrEmpty(correlationId))
        {
            sb.Append(",\"ref\":");
            sb.Append(JsEsc(correlationId));
        }
        sb.Append("}");
        return sb.ToString();
    }

    /// <summary>
    /// Convenience: creates a VALIDATION error (no correlation ID needed).
    /// </summary>
    public static string ValidationError(string message)
    {
        return SafeError(message, VALIDATION, null);
    }

    /// <summary>
    /// Convenience: creates an AUTHORIZATION error.
    /// </summary>
    public static string AuthorizationError(string message)
    {
        return SafeError(message, AUTHORIZATION, null);
    }

    /// <summary>
    /// Convenience: creates a BUSINESS_RULE error.
    /// </summary>
    public static string BusinessRuleError(string message)
    {
        return SafeError(message, BUSINESS_RULE, null);
    }

    // ─────────────────────── Exception Handling ─────────────────────────

    /// <summary>
    /// Handles an unexpected exception: logs it, generates a correlation ID,
    /// and returns a safe JSON error message for the client.
    /// </summary>
    public static string HandleException(Exception ex, string page, string action, string username)
    {
        string corrId = NewCorrelationId();
        LogError(corrId, ex, page, action, username);
        return SafeError(
            "An unexpected error occurred. Reference: " + corrId,
            SYSTEM_ERROR,
            corrId);
    }

    /// <summary>
    /// Overload: auto-detects username from session.
    /// </summary>
    public static string HandleException(Exception ex, string page, string action)
    {
        string username = "";
        try
        {
            if (HttpContext.Current != null && HttpContext.Current.Session != null)
            {
                object u = HttpContext.Current.Session["ScreenName"];
                if (u == null) u = HttpContext.Current.Session["username"];
                if (u != null) username = u.ToString();
            }
        }
        catch { }
        return HandleException(ex, page, action, username);
    }

    // ─────────────────────── Error Logging ──────────────────────────────

    /// <summary>
    /// Persists error details to acad_marks_error_log for post-mortem analysis.
    /// Fire-and-forget — never throws.
    /// </summary>
    public static void LogError(string correlationId, Exception ex,
        string page, string action, string username)
    {
        try
        {
            EnsureTables();

            string exType = ex != null ? ex.GetType().FullName : "Unknown";
            string exMsg = ex != null ? ex.Message : "";
            string stackTrace = ex != null ? (ex.StackTrace ?? "") : "";
            string innerMsg = "";
            if (ex != null && ex.InnerException != null)
            {
                innerMsg = ex.InnerException.Message;
            }

            // Truncate stack trace if too long
            if (stackTrace.Length > 4000)
            {
                stackTrace = stackTrace.Substring(0, 4000);
            }

            string ip = "";
            try
            {
                if (HttpContext.Current != null)
                {
                    ip = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
                    if (string.IsNullOrEmpty(ip))
                    {
                        ip = HttpContext.Current.Request.UserHostAddress;
                    }
                }
            }
            catch { }

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"INSERT INTO acad_marks_error_log 
                    (correlation_id, page, action, username, ip_address,
                     exception_type, exception_message, inner_message, stack_trace, 
                     created_at)
                    VALUES 
                    (@corrId, @page, @action, @user, @ip,
                     @exType, @exMsg, @innerMsg, @stack, NOW())";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@corrId", correlationId);
                    cmd.Parameters.AddWithValue("@page", page ?? "");
                    cmd.Parameters.AddWithValue("@action", action ?? "");
                    cmd.Parameters.AddWithValue("@user", username ?? "");
                    cmd.Parameters.AddWithValue("@ip", ip ?? "");
                    cmd.Parameters.AddWithValue("@exType", exType);
                    cmd.Parameters.AddWithValue("@exMsg", exMsg.Length > 1000 ? exMsg.Substring(0, 1000) : exMsg);
                    cmd.Parameters.AddWithValue("@innerMsg", innerMsg.Length > 1000 ? innerMsg.Substring(0, 1000) : innerMsg);
                    cmd.Parameters.AddWithValue("@stack", stackTrace);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch
        {
            // Absolute last resort — error logging itself failed.
            // Swallow to prevent cascading failures.
        }
    }

    // ─────────────────────── Table Creation ──────────────────────────────

    private static void EnsureTables()
    {
        if (_tablesChecked) return;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"
                    CREATE TABLE IF NOT EXISTS acad_marks_error_log (
                        id            BIGINT AUTO_INCREMENT PRIMARY KEY,
                        correlation_id VARCHAR(10) NOT NULL,
                        page          VARCHAR(100) NOT NULL DEFAULT '',
                        action        VARCHAR(50) NOT NULL DEFAULT '',
                        username      VARCHAR(100) NOT NULL DEFAULT '',
                        ip_address    VARCHAR(50) NOT NULL DEFAULT '',
                        exception_type VARCHAR(200) NOT NULL DEFAULT '',
                        exception_message VARCHAR(1000) NOT NULL DEFAULT '',
                        inner_message VARCHAR(1000) NOT NULL DEFAULT '',
                        stack_trace   TEXT,
                        created_at    DATETIME NOT NULL,
                        INDEX idx_error_corr (correlation_id),
                        INDEX idx_error_page_date (page, created_at),
                        INDEX idx_error_user (username, created_at)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            _tablesChecked = true;
        }
        catch { }
    }

    // ─────────────────────── JSON Helper ────────────────────────────────

    /// <summary>
    /// Escapes a string for safe embedding in JSON.
    /// </summary>
    private static string JsEsc(string val)
    {
        if (val == null) return "null";
        return "\"" + val
            .Replace("\\", "\\\\")
            .Replace("\"", "\\\"")
            .Replace("\r", "\\r")
            .Replace("\n", "\\n")
            .Replace("\t", "\\t") + "\"";
    }
}
