using System;
using System.Configuration;

/// <summary>
/// MarksConfiguration — Centralized configuration access for the marks module.
///
/// Provides a single point of access for all connection strings and module-level
/// constants used across the marks module service layer. All 13+ services delegate
/// their connection string lookups here, eliminating duplicated property bodies and
/// ensuring consistent connection string key usage throughout.
///
/// Connection string keys (defined in web.config / connectionStrings.local.config):
///   vacConnectionString       →  campus_dynamics      (main marks/academic DB)
///   accountsConnectionString  →  campus_dynamics_accounts (roles + email lookups)
///
/// Returns an empty string if a key is not configured rather than throwing — callers
/// will receive a MySqlException on first use, which propagates through the standard
/// error-handling path (MarksErrorHandler).
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P64, P65 (config aliasing, module configuration standardization)
/// Task: H-05
/// </summary>
public static class MarksConfiguration
{
    // ─────────────────────── Connection Strings ─────────────────────────

    /// <summary>
    /// Connection string for the main campus_dynamics database.
    /// Used by all marks module services for mark data, deadlines, assignments,
    /// audit log, action log, error log, and sync operations.
    /// Config key: "vacConnectionString"
    /// </summary>
    public static string ConnStr
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
                ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
                : "";
        }
    }

    /// <summary>
    /// Connection string for the campus_dynamics_accounts database.
    /// Used by MarksAuthorizationService and MarksNotificationService for
    /// role membership and email address lookups.
    /// Config key: "accountsConnectionString"
    /// </summary>
    public static string AccountsConnStr
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
                ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
                : "";
        }
    }

    // ─────────────────────── Module Constants ───────────────────────────

    /// <summary>
    /// Marks module version string. Included in audit headers, diagnostics,
    /// and health check responses. Increment on each release.
    /// </summary>
    public const string ModuleVersion = "2.0.0";

    /// <summary>
    /// Maximum number of student rows permitted in a single CSV import.
    /// Balances memory/timeout against realistic cohort sizes.
    /// </summary>
    public const int MaxImportRows = 1500;

    /// <summary>
    /// Recommended minimum autosave interval in seconds for mark entry pages.
    /// Pages should not fire autosave more frequently than this value.
    /// </summary>
    public const int AutosaveIntervalSeconds = 60;

    /// <summary>
    /// Maximum number of audit search results returned per page (hard cap).
    /// Prevents runaway queries from overloading the audit centre.
    /// </summary>
    public const int MaxAuditPageSize = 200;

    /// <summary>
    /// Default page size for paginated audit search results.
    /// </summary>
    public const int DefaultAuditPageSize = 50;

    /// <summary>
    /// Number of deadlock retries for BulkSaveMarks and other transactional operations.
    /// </summary>
    public const int MaxDeadlockRetries = 3;

    /// <summary>
    /// MySQL deadlock error number (used in deadlock retry logic).
    /// </summary>
    public const int MysqlDeadlockErrorCode = 1213;
}
