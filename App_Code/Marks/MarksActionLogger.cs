using System;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksActionLogger — Structured action logging for the marks module.
///
/// Provides operational visibility into every AJAX handler invocation across
/// all 6 marks pages. Captures:
///   - Action name (load, save, import, submit, approve, reject, etc.)
///   - Page name (MarkEntry, DeanApproval, TeacherDashboard, etc.)
///   - User + IP
///   - Contextual data (course, programme, params) as JSON
///   - Handler execution duration in milliseconds
///   - Outcome (success, error, validation_fail, auth_fail)
///   - Correlation ID (links to MarksErrorHandler entries when errors occur)
///
/// Uses the EnsureTables pattern to auto-create the acad_marks_action_log table.
/// Exposes a StartTimer() / StopAndLog() pair for easy integration into handlers.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P40-P44 (logging/observability), P70 (operations monitoring)
/// Task: G-03
/// </summary>
public static class MarksActionLogger
{
    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    private static volatile bool _tablesChecked;

    // ─────────────────────── Outcome Constants ──────────────────────────

    public const string OUTCOME_SUCCESS      = "success";
    public const string OUTCOME_ERROR        = "error";
    public const string OUTCOME_VALIDATION   = "validation_fail";
    public const string OUTCOME_AUTH_FAIL    = "auth_fail";
    public const string OUTCOME_LOCKED       = "locked";
    public const string OUTCOME_SKIPPED      = "skipped";

    // ─────────────────────── Timer + Log Pattern ────────────────────────

    /// <summary>
    /// Starts a high-resolution timer for measuring handler execution time.
    /// Call StopAndLog() with the returned Stopwatch when the handler completes.
    /// </summary>
    public static Stopwatch StartTimer()
    {
        Stopwatch sw = new Stopwatch();
        sw.Start();
        return sw;
    }

    /// <summary>
    /// Stops the timer and logs the action with duration.
    /// This is the primary integration point — call from each AJAX handler.
    /// </summary>
    /// <param name="timer">The Stopwatch from StartTimer().</param>
    /// <param name="page">Page name (e.g., "MarkEntry", "DeanApproval").</param>
    /// <param name="action">AJAX action name (e.g., "save", "load", "approve").</param>
    /// <param name="outcome">One of the OUTCOME_* constants.</param>
    /// <param name="context">Optional contextual data dict (course, prog, etc.).</param>
    /// <param name="correlationId">Optional correlation ID from MarksErrorHandler.</param>
    public static void StopAndLog(Stopwatch timer, string page, string action,
        string outcome, Dictionary<string, string> context, string correlationId)
    {
        if (timer != null) timer.Stop();
        long durationMs = (timer != null) ? timer.ElapsedMilliseconds : 0;

        LogAction(action, page, context, durationMs, outcome, correlationId);
    }

    /// <summary>
    /// Quick log without timer — for simple actions or when timing is not needed.
    /// </summary>
    public static void QuickLog(string page, string action, string outcome,
        Dictionary<string, string> context)
    {
        LogAction(action, page, context, 0, outcome, null);
    }

    // ─────────────────────── Exempt accounts ─────────────────────────────

    /// <summary>Cached exempt list — this is consulted on every logged action.</summary>
    private static List<string> _exempt;
    private static DateTime _exemptLoaded = DateTime.MinValue;
    private static readonly object _exemptLock = new object();

    /// <summary>
    /// True when the account is configured as exempt from the marks action log.
    /// Cached for two minutes: the check sits on the hot path of every logged action,
    /// and the list changes about once a year. Fails OPEN — if the lookup errors the
    /// action is still logged, because losing a trail silently is worse than an extra row.
    /// </summary>
    private static bool IsExemptFromLogging(string username)
    {
        if (string.IsNullOrEmpty(username)) return false;
        try
        {
            lock (_exemptLock)
            {
                if (_exempt == null || (DateTime.UtcNow - _exemptLoaded).TotalMinutes > 2)
                {
                    List<string> fresh = new List<string>();
                    using (MySqlConnection conn = new MySqlConnection(ConnStr))
                    {
                        conn.Open();
                        using (MySqlCommand cmd = new MySqlCommand(
                            "SELECT username FROM sys_log_exempt WHERE scope IN ('ALL','MARKS')", conn))
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                            while (rdr.Read())
                                fresh.Add(Convert.ToString(rdr[0]).Trim().ToLowerInvariant());
                    }
                    _exempt = fresh;
                    _exemptLoaded = DateTime.UtcNow;
                }
            }
            return _exempt.Contains(username.Trim().ToLowerInvariant());
        }
        catch { return false; }
    }

    // ─────────────────────── Core Logging ────────────────────────────────

    /// <summary>
    /// Writes an action log entry to acad_marks_action_log.
    /// Silently swallows exceptions to avoid impacting business logic.
    /// </summary>
    public static void LogAction(string action, string page,
        Dictionary<string, string> context, long durationMs, string outcome,
        string correlationId)
    {
        try
        {
            EnsureTables();

            string username = "";
            string ipAddress = "";
            try
            {
                username = MarksAuthorizationService.GetCurrentUser();
                ipAddress = MarksAuthorizationService.GetClientIP();
            }
            catch { }

            // Protected accounts are not written to the marks log. Checked here, at the one
            // point every logged action passes through, so no caller can bypass it and no
            // caller has to remember it. Driven from sys_log_exempt rather than a
            // hardcoded name, so the list is visible in the database and changing it is an
            // INSERT rather than a deployment.
            if (IsExemptFromLogging(username)) return;

            string contextJson = "";
            if (context != null && context.Count > 0)
            {
                try
                {
                    JavaScriptSerializer jss = new JavaScriptSerializer();
                    contextJson = jss.Serialize(context);
                }
                catch
                {
                    // Fall back to manual JSON
                    List<string> parts = new List<string>();
                    foreach (KeyValuePair<string, string> kvp in context)
                    {
                        parts.Add(String.Format("\"{0}\":\"{1}\"",
                            SafeJson(kvp.Key), SafeJson(kvp.Value)));
                    }
                    contextJson = "{" + string.Join(",", parts.ToArray()) + "}";
                }
            }

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"INSERT INTO acad_marks_action_log 
                    (action, page, username, ip_address, context_json, duration_ms, outcome, correlation_id, created_at)
                    VALUES (@action, @page, @user, @ip, @ctx, @dur, @outcome, @corr, @dt)";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@action", action ?? "");
                    cmd.Parameters.AddWithValue("@page", page ?? "");
                    cmd.Parameters.AddWithValue("@user", username ?? "");
                    cmd.Parameters.AddWithValue("@ip", ipAddress ?? "");
                    cmd.Parameters.AddWithValue("@ctx", contextJson ?? "");
                    cmd.Parameters.AddWithValue("@dur", durationMs);
                    cmd.Parameters.AddWithValue("@outcome", outcome ?? "");
                    cmd.Parameters.AddWithValue("@corr", correlationId ?? "");
                    cmd.Parameters.AddWithValue("@dt", DateTime.Now);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch
        {
            // Silently swallow — action logging must never break business flow
        }
    }

    // ─────────────────────── Context Builder ─────────────────────────────

    /// <summary>
    /// Convenience method to build a context dictionary from common mark parameters.
    /// Call from page handlers to capture course/programme/year context.
    /// </summary>
    public static Dictionary<string, string> BuildContext(string courseId, string progId,
        string acadyear, int semester)
    {
        Dictionary<string, string> ctx = new Dictionary<string, string>();
        if (!string.IsNullOrEmpty(courseId)) ctx["course"] = courseId;
        if (!string.IsNullOrEmpty(progId)) ctx["prog"] = progId;
        if (!string.IsNullOrEmpty(acadyear)) ctx["year"] = acadyear;
        ctx["sem"] = semester.ToString();
        return ctx;
    }

    /// <summary>
    /// Extended context builder with additional parameters.
    /// </summary>
    public static Dictionary<string, string> BuildContext(string courseId, string progId,
        string acadyear, int semester, string extra)
    {
        Dictionary<string, string> ctx = BuildContext(courseId, progId, acadyear, semester);
        if (!string.IsNullOrEmpty(extra)) ctx["detail"] = extra;
        return ctx;
    }

    // ─────────────────────── Table Creation ──────────────────────────────

    /// <summary>
    /// Auto-creates acad_marks_action_log if it does not exist.
    /// Called once per application lifecycle (volatile flag).
    /// Should also be called from page EnsureTables() methods.
    /// </summary>
    public static void EnsureActionLogTable()
    {
        if (_tablesChecked) return;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"
                    CREATE TABLE IF NOT EXISTS acad_marks_action_log (
                        id              BIGINT AUTO_INCREMENT PRIMARY KEY,
                        action          VARCHAR(50) NOT NULL DEFAULT '',
                        page            VARCHAR(100) NOT NULL DEFAULT '',
                        username        VARCHAR(100) NOT NULL DEFAULT '',
                        ip_address      VARCHAR(50) NOT NULL DEFAULT '',
                        context_json    TEXT,
                        duration_ms     INT NOT NULL DEFAULT 0,
                        outcome         VARCHAR(30) NOT NULL DEFAULT '',
                        correlation_id  VARCHAR(10) NOT NULL DEFAULT '',
                        created_at      DATETIME NOT NULL,
                        INDEX idx_action_page (page, action, created_at),
                        INDEX idx_action_user (username, created_at),
                        INDEX idx_action_outcome (outcome, created_at),
                        INDEX idx_action_corr (correlation_id)
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

    private static void EnsureTables()
    {
        EnsureActionLogTable();
    }

    // ─────────────────────── Helpers ─────────────────────────────────────

    private static string SafeJson(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }
}
