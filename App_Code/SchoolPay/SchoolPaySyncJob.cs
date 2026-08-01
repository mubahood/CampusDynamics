using System;
using System.Configuration;
using System.Threading;
using MySql.Data.MySqlClient;

/// <summary>
/// In-process AUTO-SYNC engine for SchoolPay.
///
/// A single <see cref="System.Threading.Timer"/> fires every N minutes (default 5), pulls the
/// last few days of payments from SchoolPay and reconciles anything we are missing — through the
/// same hardened capture engine used everywhere else (fully idempotent, never double-posts).
///
/// All state + heartbeat live in campus_dynamics_accounts.fin_schoolpay_jobstate so the admin
/// controller (Auto-Sync tab) can show health and Restart / Run-now / Pause the job.
///
/// Reliability guarantees ("no room for error"):
///  - The timer callback is fully wrapped in try/catch — a failing tick can NEVER kill the timer.
///  - In-process single-flight (Interlocked) — an overlapping tick is skipped, not queued.
///  - Distributed single-flight (atomic UPDATE "claim" on last_run) — with several IIS worker
///    processes only ONE actually pulls per interval; the rest no-op. (The reconcile is idempotent
///    anyway, so even a double pull is harmless — this just avoids wasted API calls.)
///  - Self-heals a stuck RUNNING: the claim re-opens once last_run is older than the interval.
///  - Auto-creates its own state table + seed row, so deploy order never matters.
///  - Started from Global.asax Application_Start; a Page request always warms the app, so the
///    engine is live whenever an admin is looking at the controller.
/// </summary>
public static class SchoolPaySyncJob
{
    private const string JOB = "AUTO_SYNC";

    private static readonly object _startLock = new object();
    private static Timer _timer;
    private static int _ticking;             // 0 = idle, 1 = a tick is in progress (this worker)
    private static volatile bool _started;
    private static bool _tableReady;

    // ---- config ----
    private static int IntervalMinutes
    {
        get { int m = ParseInt(ConfigurationManager.AppSettings["SchoolPay.AutoSyncMinutes"], 5); return m < 1 ? 5 : m; }
    }
    private static int WindowDays
    {
        get { int d = ParseInt(ConfigurationManager.AppSettings["SchoolPay.AutoSyncWindowDays"], 2); return d < 1 ? 1 : (d > 31 ? 31 : d); }
    }
    private static string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }
    private static string WorkerId
    {
        get
        {
            try { return Environment.MachineName + "/pid" + System.Diagnostics.Process.GetCurrentProcess().Id + "/ad" + AppDomain.CurrentDomain.Id; }
            catch { return "worker"; }
        }
    }

    /// <summary>Is the timer alive in THIS worker process?</summary>
    public static bool IsEngineAlive { get { return _started && _timer != null; } }

    // ====================================================================
    // LIFECYCLE
    // ====================================================================
    /// <summary>Called once from Application_Start. Idempotent.</summary>
    public static void EnsureStarted()
    {
        lock (_startLock)
        {
            if (_started && _timer != null) return;
            // IMPORTANT: do NO blocking work here. Application_Start runs under a global lock, so a
            // slow DB/network call would stall EVERY incoming request ("whole system loads forever").
            // We only arm the timer (instant); the state table + first pull happen 30s later on the
            // first tick, off the request path.
            StartNoLock();
        }
    }

    public static void Start() { lock (_startLock) { StartNoLock(); } }

    private static void StartNoLock()
    {
        try
        {
            if (_timer != null) { _timer.Dispose(); _timer = null; }
            long period = (long)IntervalMinutes * 60L * 1000L;
            long due = 30L * 1000L;                       // 30s warm-up before the first ping
            _timer = new Timer(TimerCallback, null, due, period);
            _started = true;
        }
        catch { _started = false; }
    }

    public static void Stop()
    {
        lock (_startLock)
        {
            if (_timer != null) { _timer.Dispose(); _timer = null; }
            _started = false;
        }
    }

    public static void Restart() { Stop(); Start(); }

    /// <summary>Run one sync immediately (UI "Run now"), bypassing the interval / enabled guard.</summary>
    public static SchoolPayPullService.PullResult RunOnce(string actor) { return DoSync(true, actor); }

    /// <summary>Enable / pause the auto-sync (persisted). Work is gated on this flag; the timer stays alive.</summary>
    public static void SetEnabled(bool on, string actor)
    {
        try { EnsureTable(); } catch { }
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "UPDATE fin_schoolpay_jobstate SET enabled=@e, status=@st, last_message=@msg, updated_at=NOW() WHERE job_name=@j", conn))
            {
                cmd.Parameters.AddWithValue("@e", on ? 1 : 0);
                cmd.Parameters.AddWithValue("@st", on ? "IDLE" : "PAUSED");
                cmd.Parameters.AddWithValue("@msg", (string.IsNullOrEmpty(actor) ? "system" : actor) + (on ? " resumed auto-sync" : " paused auto-sync"));
                cmd.Parameters.AddWithValue("@j", JOB);
                cmd.ExecuteNonQuery();
            }
        }
        if (on && !IsEngineAlive) Start();
    }

    // ====================================================================
    // THE TICK
    // ====================================================================
    private static void TimerCallback(object state)
    {
        try { DoSync(false, "auto-sync"); }
        catch { /* an exception must NEVER escape the timer thread */ }
    }

    private static SchoolPayPullService.PullResult DoSync(bool force, string actor)
    {
        // in-process single-flight: if a tick is already running here, skip
        if (Interlocked.CompareExchange(ref _ticking, 1, 0) != 0)
            return new SchoolPayPullService.PullResult { Ok = true, ReturnMessage = "A sync is already running." };

        try
        {
            EnsureTableOnce();

            bool enabled = false;
            int windowDays = WindowDays;

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // heartbeat — proves the timer/worker is alive even when paused
                using (var cmd = new MySqlCommand(
                    "UPDATE fin_schoolpay_jobstate SET last_heartbeat=NOW(), worker_id=@w, interval_minutes=@iv, window_days=@wd, updated_at=NOW() WHERE job_name=@j", conn))
                {
                    cmd.Parameters.AddWithValue("@w", WorkerId);
                    cmd.Parameters.AddWithValue("@iv", IntervalMinutes);
                    cmd.Parameters.AddWithValue("@wd", WindowDays);
                    cmd.Parameters.AddWithValue("@j", JOB);
                    cmd.ExecuteNonQuery();
                }

                using (var cmd = new MySqlCommand("SELECT enabled, window_days FROM fin_schoolpay_jobstate WHERE job_name=@j LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@j", JOB);
                    using (var rd = cmd.ExecuteReader())
                        if (rd.Read()) { enabled = SafeInt(rd["enabled"], 0) == 1; windowDays = SafeInt(rd["window_days"], WindowDays); }
                }

                if (!enabled && !force)
                {
                    using (var cmd = new MySqlCommand("UPDATE fin_schoolpay_jobstate SET status='PAUSED', updated_at=NOW() WHERE job_name=@j", conn))
                    { cmd.Parameters.AddWithValue("@j", JOB); cmd.ExecuteNonQuery(); }
                    return new SchoolPayPullService.PullResult { Ok = true, ReturnMessage = "Paused." };
                }

                if (!force)
                {
                    // distributed claim: only the worker that flips last_run within this window proceeds
                    int guardSec = (IntervalMinutes * 60) - 45;      // interval minus 45s slack
                    if (guardSec < 15) guardSec = 15;
                    int claimed;
                    using (var cmd = new MySqlCommand(
                        "UPDATE fin_schoolpay_jobstate SET status='RUNNING', last_run=NOW(), worker_id=@w " +
                        "WHERE job_name=@j AND enabled=1 AND (last_run IS NULL OR last_run < DATE_SUB(NOW(), INTERVAL @g SECOND))", conn))
                    {
                        cmd.Parameters.AddWithValue("@w", WorkerId);
                        cmd.Parameters.AddWithValue("@j", JOB);
                        cmd.Parameters.AddWithValue("@g", guardSec);
                        claimed = cmd.ExecuteNonQuery();
                    }
                    if (claimed == 0)
                        return new SchoolPayPullService.PullResult { Ok = true, ReturnMessage = "Skipped (another worker handled this interval)." };
                }
                else
                {
                    using (var cmd = new MySqlCommand("UPDATE fin_schoolpay_jobstate SET status='RUNNING', last_run=NOW(), worker_id=@w WHERE job_name=@j", conn))
                    { cmd.Parameters.AddWithValue("@w", WorkerId); cmd.Parameters.AddWithValue("@j", JOB); cmd.ExecuteNonQuery(); }
                }
            }

            // the actual work — rolling window, idempotent reconcile
            DateTime to = DateTime.Now.Date;
            DateTime from = to.AddDays(-(windowDays - 1));
            SchoolPayPullService.PullResult res = SchoolPayPullService.SyncRange(from, to, force ? "AUTO_NOW" : "AUTO", actor);

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "UPDATE fin_schoolpay_jobstate SET status=@st, last_finished=NOW(), last_run_id=@rid, " +
                    "last_message=@msg, last_error=@err, last_fetched=@f, last_new=@n, last_captured=@c, " +
                    "last_existed=@ex, last_failed=@fl, total_runs=total_runs+1, total_captured=total_captured+@c, updated_at=NOW() " +
                    "WHERE job_name=@j", conn))
                {
                    cmd.Parameters.AddWithValue("@st", res.Ok ? "OK" : "ERROR");
                    cmd.Parameters.AddWithValue("@rid", res.RunId ?? "");
                    cmd.Parameters.AddWithValue("@msg", Trunc(res.Ok ? BuildMsg(res) : ("Failed: " + (res.Error ?? "error")), 500));
                    cmd.Parameters.AddWithValue("@err", res.Ok ? (object)DBNull.Value : Trunc(res.Error, 500));
                    cmd.Parameters.AddWithValue("@f", res.Fetched);
                    cmd.Parameters.AddWithValue("@n", res.NewCount);
                    cmd.Parameters.AddWithValue("@c", res.Captured);
                    cmd.Parameters.AddWithValue("@ex", res.Existed);
                    cmd.Parameters.AddWithValue("@fl", res.Failed);
                    cmd.Parameters.AddWithValue("@j", JOB);
                    cmd.ExecuteNonQuery();
                }
            }
            return res;
        }
        catch (Exception ex)
        {
            try
            {
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand("UPDATE fin_schoolpay_jobstate SET status='ERROR', last_finished=NOW(), last_error=@e, updated_at=NOW() WHERE job_name=@j", conn))
                    { cmd.Parameters.AddWithValue("@e", Trunc(ex.Message, 500)); cmd.Parameters.AddWithValue("@j", JOB); cmd.ExecuteNonQuery(); }
                }
            }
            catch { }
            return new SchoolPayPullService.PullResult { Ok = false, Error = ex.Message };
        }
        finally
        {
            Interlocked.Exchange(ref _ticking, 0);
        }
    }

    private static string BuildMsg(SchoolPayPullService.PullResult r)
    {
        return "Fetched " + r.Fetched + ", posted " + r.Captured + ", already had " + r.Existed +
               (r.Failed > 0 ? (", review " + r.Failed) : "") + ".";
    }

    // ====================================================================
    // STATE TABLE
    // ====================================================================
    private static void EnsureTableOnce() { if (!_tableReady) EnsureTable(); }

    private static void EnsureTable()
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "CREATE TABLE IF NOT EXISTS fin_schoolpay_jobstate (" +
                " job_name VARCHAR(40) NOT NULL PRIMARY KEY," +
                " enabled TINYINT(1) NOT NULL DEFAULT 1," +
                " interval_minutes INT NOT NULL DEFAULT 5," +
                " window_days INT NOT NULL DEFAULT 2," +
                " status VARCHAR(20) NOT NULL DEFAULT 'IDLE'," +
                " last_heartbeat DATETIME NULL, last_run DATETIME NULL, last_finished DATETIME NULL," +
                " last_run_id VARCHAR(40) NULL, last_message VARCHAR(500) NULL, last_error VARCHAR(500) NULL," +
                " last_fetched INT NOT NULL DEFAULT 0, last_new INT NOT NULL DEFAULT 0, last_captured INT NOT NULL DEFAULT 0," +
                " last_existed INT NOT NULL DEFAULT 0, last_failed INT NOT NULL DEFAULT 0," +
                " total_runs BIGINT NOT NULL DEFAULT 0, total_captured BIGINT NOT NULL DEFAULT 0," +
                " worker_id VARCHAR(80) NULL, updated_at DATETIME NULL" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8", conn))
            { cmd.ExecuteNonQuery(); }

            using (var cmd = new MySqlCommand(
                "INSERT IGNORE INTO fin_schoolpay_jobstate (job_name,enabled,interval_minutes,window_days,status) VALUES (@j,1,@iv,@wd,'IDLE')", conn))
            {
                cmd.Parameters.AddWithValue("@j", JOB);
                cmd.Parameters.AddWithValue("@iv", IntervalMinutes);
                cmd.Parameters.AddWithValue("@wd", WindowDays);
                cmd.ExecuteNonQuery();
            }
        }
        _tableReady = true;
    }

    // ---- small helpers ----
    private static int ParseInt(string s, int def) { int v; return int.TryParse((s ?? "").Trim(), out v) ? v : def; }
    private static int SafeInt(object o, int def)
    {
        if (o == null || o == DBNull.Value) return def;
        if (o is bool) return ((bool)o) ? 1 : 0;   // MySQL returns TINYINT(1) as Boolean by default
        int v; return int.TryParse(o.ToString(), out v) ? v : def;
    }
    private static string Trunc(string s, int n) { s = s ?? ""; return s.Length > n ? s.Substring(0, n) : s; }
}
