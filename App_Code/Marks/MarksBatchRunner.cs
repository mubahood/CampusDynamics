using System;
using System.Threading;
using MySql.Data.MySqlClient;

/// <summary>
/// Deadlock-avoidance primitives for the staged-marks batch operations.
///
/// Publishing used to run as ONE transaction covering every matched mark. With ~15
/// statements per mark that meant a five-thousand-mark publish held tens of thousands of
/// row locks for tens of minutes. Anything else touching acad_results or
/// acad_course_registration queued behind it, and two overlapping publishes could grab the
/// same rows in opposite orders and deadlock outright — losing the entire run, because a
/// deadlock rolls back everything.
///
/// The strategy here has four parts:
///
///   1. DETERMINISTIC ORDER — every batch walks rows in ascending primary-key order.
///      Two concurrent runs therefore always take locks in the same sequence, which makes
///      a lock-ordering deadlock between them impossible by construction.
///
///   2. SHORT TRANSACTIONS — work is committed in small chunks, so locks are released
///      continuously instead of at the end. Readers and other writers are never blocked
///      for more than one chunk.
///
///   3. FAIL FAST, THEN RETRY — the session drops innodb_lock_wait_timeout to a few
///      seconds so a blocked chunk gives up quickly, and RunChunkWithRetry replays just
///      that chunk with exponential backoff. A deadlock becomes a brief retry rather than
///      a lost run.
///
///   4. ONE WRITER AT A TIME — a MySQL advisory lock serialises publish batches
///      cluster-wide. Batch publishing is an administrative act, so serialising it costs
///      nothing and removes publish-vs-publish contention completely.
/// </summary>
public static class MarksBatchRunner
{
    /// <summary>Rows per transaction. Small enough to hold few locks, large enough to amortise round-trips.</summary>
    public const int ChunkSize = 200;

    /// <summary>How many times a single chunk is replayed after a deadlock / lock-wait timeout.</summary>
    public const int MaxChunkAttempts = 5;

    // MySQL error codes we treat as "transient, worth replaying".
    private const int ER_LOCK_DEADLOCK = 1213;
    private const int ER_LOCK_WAIT_TIMEOUT = 1205;

    public static bool IsTransientLockError(Exception ex)
    {
        MySqlException my = ex as MySqlException;
        while (my == null && ex != null) { ex = ex.InnerException; my = ex as MySqlException; }
        if (my == null) return false;
        return my.Number == ER_LOCK_DEADLOCK || my.Number == ER_LOCK_WAIT_TIMEOUT;
    }

    /// <summary>
    /// Make this connection a well-behaved batch citizen: give up on a contended row after
    /// a few seconds (so we can retry deliberately) rather than hanging on the 50s default.
    /// </summary>
    public static void PrepareSession(MySqlConnection conn)
    {
        try
        {
            using (MySqlCommand cmd = new MySqlCommand("SET SESSION innodb_lock_wait_timeout=10", conn))
                cmd.ExecuteNonQuery();
        }
        catch { /* not fatal — the default timeout merely makes retries slower */ }
    }

    /// <summary>
    /// Run one chunk inside its own transaction, replaying it on deadlock / lock-wait
    /// timeout with exponential backoff (120ms, 240ms, 480ms...) plus jitter so two
    /// contending runs do not resynchronise onto the same retry beat.
    ///
    /// The body must be idempotent across a rolled-back attempt — which holds here because
    /// a rollback restores every row the attempt touched, so the replay starts from the
    /// same state.
    /// </summary>
    public static void RunChunkWithRetry(MySqlConnection conn, Action<MySqlTransaction> body)
    {
        Exception last = null;
        for (int attempt = 1; attempt <= MaxChunkAttempts; attempt++)
        {
            MySqlTransaction tx = null;
            try
            {
                tx = conn.BeginTransaction();
                body(tx);
                tx.Commit();
                return;
            }
            catch (Exception ex)
            {
                last = ex;
                if (tx != null) { try { tx.Rollback(); } catch { } }

                if (!IsTransientLockError(ex) || attempt == MaxChunkAttempts) throw;

                int backoffMs = 120 * (1 << (attempt - 1));
                backoffMs += new Random(Environment.TickCount + attempt * 7919).Next(0, 90);
                Thread.Sleep(backoffMs);
            }
            finally
            {
                if (tx != null) { try { tx.Dispose(); } catch { } }
            }
        }
        if (last != null) throw last;
    }

    // ── Cluster-wide advisory mutex ──────────────────────────────────────────
    // MySQL named locks are held per CONNECTION, so the same connection must both take and
    // release the lock. On 5.6 a connection can hold only one named lock at a time, which
    // is all we need.

    /// <summary>
    /// Try to take the named batch lock. Returns false when another run already holds it,
    /// letting the caller report "a publish is already running" instead of piling a second
    /// writer onto the same rows.
    /// </summary>
    public static bool TryAcquire(MySqlConnection conn, string lockName, int waitSeconds)
    {
        using (MySqlCommand cmd = new MySqlCommand("SELECT GET_LOCK(@n, @w)", conn))
        {
            cmd.Parameters.AddWithValue("@n", lockName);
            cmd.Parameters.AddWithValue("@w", waitSeconds);
            object v = cmd.ExecuteScalar();
            return v != null && v != DBNull.Value && Convert.ToInt32(v) == 1;
        }
    }

    public static void Release(MySqlConnection conn, string lockName)
    {
        try
        {
            using (MySqlCommand cmd = new MySqlCommand("SELECT RELEASE_LOCK(@n)", conn))
            {
                cmd.Parameters.AddWithValue("@n", lockName);
                cmd.ExecuteScalar();
            }
        }
        catch { /* connection is closing anyway; MySQL frees the lock on disconnect */ }
    }
}
