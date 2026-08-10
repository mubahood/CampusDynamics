using System;
using System.Collections.Generic;
using MySql.Data.MySqlClient;

/// <summary>
/// Per-AppDomain cache for the handful of SCHEMA constants the marks engine needs
/// (which course column exists, what the credit-units column is called, whether the
/// result_comment column has been widened).
///
/// Why this exists: ProcessProvisionalAction resolved all of these from
/// INFORMATION_SCHEMA on EVERY published row — 7 metadata round-trips per mark
/// (2 x ColumnExists for the course column, 1 for acad_course credit units, 1 for
/// acad_results credit units, 1 for result_comment, plus 1 each inside
/// ComputeSemesterGpa and ComputeStudentCgpa). Publishing 5,000 marks therefore fired
/// ~35,000 INFORMATION_SCHEMA queries. On MySQL 5.6 those are genuinely expensive —
/// each one opens table definitions — and they were a large part of why a publish run
/// held its transaction open for tens of minutes.
///
/// These values cannot change while a batch is running: a column does not appear or
/// vanish mid-publish. So they are resolved once and reused for the life of the
/// process. Call Invalidate() if a migration alters the shape of these tables at
/// runtime (nothing in the app currently does).
/// </summary>
public static class MarksSchemaCache
{
    private static readonly object Gate = new object();
    private static readonly Dictionary<string, string> Cache = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    /// <summary>Drop everything — next call re-reads INFORMATION_SCHEMA.</summary>
    public static void Invalidate()
    {
        lock (Gate) { Cache.Clear(); }
    }

    private static bool TryGet(string key, out string value)
    {
        lock (Gate) { return Cache.TryGetValue(key, out value); }
    }

    private static void Put(string key, string value)
    {
        lock (Gate) { Cache[key] = value; }
    }

    /// <summary>
    /// Resolve-once wrapper. The resolver runs at most once per distinct key per
    /// AppDomain; a null result is cached as "" so a genuinely-absent column does not
    /// re-query forever.
    /// </summary>
    private static string Resolve(string key, Func<string> resolver)
    {
        string cached;
        if (TryGet(key, out cached)) return cached.Length == 0 ? null : cached;

        string fresh = null;
        try { fresh = resolver(); }
        catch { fresh = null; }   // caller decides the fallback; never cache-poison on a transient error

        Put(key, fresh ?? "");
        return fresh;
    }

    // ── Column existence ─────────────────────────────────────────────────────
    public static bool ColumnExists(MySqlConnection conn, string schema, string table, string column)
    {
        string key = "exists|" + schema + "|" + table + "|" + column;
        return Resolve(key, delegate
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@s AND TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
            {
                cmd.Parameters.AddWithValue("@s", schema);
                cmd.Parameters.AddWithValue("@t", table);
                cmd.Parameters.AddWithValue("@c", column);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0 ? "1" : null;
            }
        }) != null;
    }

    /// <summary>Actual (case-correct) column name, or null when absent.</summary>
    public static string ActualColumnName(MySqlConnection conn, string schema, string table, string columnCandidate)
    {
        string key = "actual|" + schema + "|" + table + "|" + columnCandidate;
        return Resolve(key, delegate
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@s AND TABLE_NAME=@t AND LOWER(COLUMN_NAME)=@c LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@s", schema);
                cmd.Parameters.AddWithValue("@t", table);
                cmd.Parameters.AddWithValue("@c", (columnCandidate ?? string.Empty).ToLowerInvariant());
                object v = cmd.ExecuteScalar();
                return v == null || v == DBNull.Value ? null : v.ToString();
            }
        });
    }

    /// <summary>
    /// Runs a one-off schema self-heal (an ALTER) at most once per AppDomain.
    ///
    /// This matters for more than speed: the old code called
    /// EnsureResultCommentTextNullable() from inside the per-row publish loop, and an
    /// ALTER TABLE causes an IMPLICIT COMMIT in MySQL. Had that ALTER ever fired
    /// mid-batch it would have silently committed a half-finished publish and made the
    /// surrounding transaction meaningless. Hoisting it here keeps DDL strictly outside
    /// the row loop and outside any transaction.
    /// </summary>
    public static void RunOnce(string key, Action action)
    {
        string done;
        if (TryGet("once|" + key, out done)) return;
        try { action(); }
        catch { /* self-heal is best-effort and must never break a publish */ }
        Put("once|" + key, "1");
    }
}
