using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;

/// <summary>
/// MarksSessionSecurity — Session integrity and security hardening for the marks module.
///
/// Provides:
///   - Session fingerprinting: binds sessions to User-Agent hash to detect session hijacking.
///   - Integrity validation: checks session variables exist and haven't been tampered with.
///   - Activity tracking: stamps last activity time to detect stale/abandoned sessions.
///   - IP consistency checks: detects significant IP changes mid-session (warning only, not blocking,
///     since NAT/proxy changes are common in campus networks).
///
/// Integration point: called at the top of each marks page's authorization block,
/// before handler dispatch. If validation fails, the user gets a clear "session expired"
/// message prompting re-login.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P51-P53 (session security), P54 (session hijacking prevention)
/// Task: C-05
/// </summary>
public static class MarksSessionSecurity
{
    // Session key names for security metadata
    private const string KEY_UA_HASH     = "_marks_ua_hash";
    private const string KEY_STAMP_TIME  = "_marks_stamp_time";
    private const string KEY_STAMP_IP    = "_marks_stamp_ip";
    private const string KEY_LAST_ACTIVE = "_marks_last_active";

    // Configurable thresholds
    private const int SESSION_IDLE_MINUTES = 120; // Max idle time before requiring re-login

    // ─────────────────────── Stamp (post-login) ─────────────────────────

    /// <summary>
    /// Stamps the current session with security fingerprint metadata.
    /// Should be called once after successful authentication (or on first marks page access).
    /// Records User-Agent hash, IP address, and timestamp.
    /// </summary>
    public static void StampSession()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Session == null) return;

        string userAgent = ctx.Request.UserAgent ?? "";
        ctx.Session[KEY_UA_HASH] = ComputeHash(userAgent);
        ctx.Session[KEY_STAMP_IP] = GetClientIP(ctx);
        ctx.Session[KEY_STAMP_TIME] = DateTime.Now;
        ctx.Session[KEY_LAST_ACTIVE] = DateTime.Now;
    }

    /// <summary>
    /// Updates the last activity timestamp. Call during each valid request.
    /// </summary>
    public static void TouchSession()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Session == null) return;
        ctx.Session[KEY_LAST_ACTIVE] = DateTime.Now;
    }

    // ─────────────────────── Validation ──────────────────────────────────

    /// <summary>
    /// Validates session integrity. Returns null if valid, or an error message if not.
    ///
    /// Checks (in order):
    ///   1. Session has a user identity (ScreenName or username).
    ///   2. Session was stamped (has fingerprint metadata).
    ///      If not stamped, auto-stamps (first access since feature deployment).
    ///   3. User-Agent hash matches (detects session hijacking).
    ///   4. Session is not idle beyond threshold.
    ///
    /// IP changes are logged but not blocked (campus NAT/proxy can cause legitimate shifts).
    /// </summary>
    /// <returns>null if valid; error message string if session is compromised or expired.</returns>
    public static string ValidateSessionIntegrity()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Session == null)
        {
            return "Session not available. Please log in again.";
        }

        // Check 1: Session has a user identity
        string screenName = ctx.Session["ScreenName"] != null ? ctx.Session["ScreenName"].ToString() : "";
        string username = ctx.Session["username"] != null ? ctx.Session["username"].ToString() : "";

        if (string.IsNullOrEmpty(screenName) && string.IsNullOrEmpty(username))
        {
            // Session variables are gone (e.g. app-pool recycle) but the user may still hold
            // a valid persistent Forms-Authentication ticket.  If so, restore the session from
            // the identity rather than forcing a redundant re-login.
            if (ctx.User != null && ctx.User.Identity != null
                && ctx.User.Identity.IsAuthenticated
                && !string.IsNullOrEmpty(ctx.User.Identity.Name))
            {
                ctx.Session["username"] = ctx.User.Identity.Name;
                username = ctx.User.Identity.Name;
                StampSession();   // fresh fingerprint for this restored session
                return null;
            }
            return "Session expired. Please log in again.";
        }

        // Check 2: Session fingerprint exists
        if (ctx.Session[KEY_UA_HASH] == null)
        {
            // First access since feature deployment — auto-stamp without blocking
            StampSession();
            return null;
        }

        // Check 3: User-Agent consistency
        string currentUAHash = ComputeHash(ctx.Request.UserAgent ?? "");
        string storedUAHash = ctx.Session[KEY_UA_HASH].ToString();

        if (currentUAHash != storedUAHash)
        {
            // User-Agent changed mid-session — potential session hijacking
            LogSecurityEvent("UA_MISMATCH", screenName + "|" + username,
                GetClientIP(ctx), "User-Agent fingerprint changed mid-session");
            return "Session security check failed. Please log in again.";
        }

        // Check 4: Idle timeout
        if (ctx.Session[KEY_LAST_ACTIVE] != null)
        {
            DateTime lastActive = (DateTime)ctx.Session[KEY_LAST_ACTIVE];
            double idleMinutes = (DateTime.Now - lastActive).TotalMinutes;

            if (idleMinutes > SESSION_IDLE_MINUTES)
            {
                LogSecurityEvent("IDLE_TIMEOUT", screenName + "|" + username,
                    GetClientIP(ctx),
                    String.Format("Session idle for {0:F0} minutes (threshold: {1})",
                        idleMinutes, SESSION_IDLE_MINUTES));
                return "Your session has timed out due to inactivity. Please log in again.";
            }
        }

        // Check 5: IP change detection (warning only — not blocking)
        if (ctx.Session[KEY_STAMP_IP] != null)
        {
            string storedIP = ctx.Session[KEY_STAMP_IP].ToString();
            string currentIP = GetClientIP(ctx);

            if (storedIP != currentIP)
            {
                LogSecurityEvent("IP_CHANGE", screenName + "|" + username,
                    currentIP,
                    String.Format("IP changed from {0} to {1}", storedIP, currentIP));
                // Update stored IP to prevent repeated warnings for the same change
                ctx.Session[KEY_STAMP_IP] = currentIP;
            }
        }

        // All checks passed — refresh activity timestamp
        TouchSession();
        return null;
    }

    // ─────────────────────── Security Event Logging ─────────────────────

    /// <summary>
    /// Logs a security-related session event via the action logger.
    /// These events are valuable for detecting attack patterns.
    /// </summary>
    private static void LogSecurityEvent(string eventType, string user, string ip, string detail)
    {
        try
        {
            System.Collections.Generic.Dictionary<string, string> ctx =
                new System.Collections.Generic.Dictionary<string, string>();
            ctx["event"] = eventType;
            ctx["user"] = user;
            ctx["ip"] = ip;
            ctx["detail"] = detail;

            MarksActionLogger.LogAction("SESSION_SECURITY", "SessionSecurity",
                ctx, 0, eventType, null);
        }
        catch
        {
            // Never break the flow for logging failures
        }
    }

    // ─────────────────────── Helpers ─────────────────────────────────────

    /// <summary>
    /// Computes a SHA-256 hash of the input string, returning the first 16 hex chars.
    /// Used for User-Agent fingerprinting — fast, no collision concern for this use.
    /// </summary>
    private static string ComputeHash(string input)
    {
        if (string.IsNullOrEmpty(input)) return "EMPTY";

        using (SHA256 sha = SHA256.Create())
        {
            byte[] hashBytes = sha.ComputeHash(Encoding.UTF8.GetBytes(input));
            StringBuilder sb = new StringBuilder(16);
            for (int i = 0; i < 8; i++)
            {
                sb.Append(hashBytes[i].ToString("x2"));
            }
            return sb.ToString();
        }
    }

    /// <summary>
    /// Gets the client's IP address from the current request.
    /// Checks X-Forwarded-For for proxy/load-balancer scenarios.
    /// </summary>
    private static string GetClientIP(HttpContext ctx)
    {
        if (ctx == null || ctx.Request == null) return "unknown";

        string forwarded = ctx.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (!string.IsNullOrEmpty(forwarded))
        {
            // Take the first IP in the chain (original client)
            string[] ips = forwarded.Split(',');
            if (ips.Length > 0)
            {
                string first = ips[0].Trim();
                if (!string.IsNullOrEmpty(first)) return first;
            }
        }

        return ctx.Request.ServerVariables["REMOTE_ADDR"] ?? "unknown";
    }
}
