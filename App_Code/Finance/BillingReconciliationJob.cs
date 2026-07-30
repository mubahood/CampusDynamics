using System;
using System.Configuration;
using System.Threading;
using MySql.Data.MySqlClient;

/// <summary>
/// In-process AUTO-RECONCILE engine for registration billing.
///
/// Enforces the institution rule "a student who is enrolled for a semester is
/// automatically REGISTERED and automatically BILLED." Billing is otherwise
/// event-driven (only the portal semester wizard flips REGISTERED + bills), so
/// students who get courses through any other path — admin course registration,
/// a promotion placeholder, or a wizard billing failure that reverted them to
/// UNREGISTERED — silently stay UNREGISTERED / unbilled while their payments
/// float as an unallocated credit. This job closes that gap on a schedule.
///
/// A single <see cref="System.Threading.Timer"/> fires every N hours (default 12)
/// and calls the idempotent stored procedure fin_ReconcileEnrolledBilling for the
/// CURRENT academic year + semester in FIX mode, guarded by a runaway cap: if the
/// number of enrolled-but-unbilled students in one run exceeds the cap, it only
/// flags them (EXCEEDS_CAP) for human review instead of mass-billing.
///
/// Reliability (mirrors SchoolPaySyncJob):
///  - The timer callback is fully wrapped in try/catch — a failing tick can NEVER kill the timer.
///  - In-process single-flight (Interlocked) — an overlapping tick is skipped.
///  - Heartbeat + last-run state in campus_dynamics_accounts.fin_billing_recon_jobstate.
///  - Auto-creates its state table + seed row, so deploy order never matters.
///  - Started from Global.asax Application_Start; only arms the timer (instant, no blocking work).
///  - The reconcile SP itself is fully idempotent (fin_AutoBillOnRegistration short-circuits
///    'Already Billed'), so even a double run never double-bills.
/// </summary>
public static class BillingReconciliationJob
{
    private const string JOB = "BILLING_RECON";

    // ── MASTER SWITCH — auto-reconcile DISABLED by policy (2026-07-31) ──────────
    // This in-process engine called fin_ReconcileEnrolledBilling, which AUTO-REGISTERS
    // enrolled-but-unbilled students (registeredBy 'RECON-ENROLLED'/'AUTO-RECON…'). That
    // auto-registration promoted finalists into phantom "extra years" (e.g. year 5 of a
    // 4-year programme), creating unbillable/UNREGISTERED rows and phantom bills. Policy:
    // students may only be registered via the new-UI screens (NewScreens/NewStudentRegistration.aspx,
    // FeesRegistration.aspx) or student self-service (eportal RegistrationWizard) — never by this
    // automatic job. Set to false to re-enable the engine. (The DB flag `fin_billing_recon_jobstate.enabled`
    // is also set to 0 so any already-running instance stops before a redeploy picks up this flag.)
    private const bool AutoReconcileDisabled = true;

    private static readonly object _startLock = new object();
    private static Timer _timer;
    private static int _ticking;             // 0 = idle, 1 = a tick is in progress
    private static volatile bool _started;
    private static bool _tableReady;

    // ---- config ----
    private static int IntervalHours
    {
        get { int h = ParseInt(ConfigurationManager.AppSettings["Billing.ReconcileHours"], 12); return h < 1 ? 1 : (h > 168 ? 168 : h); }
    }
    private static int Cap
    {
        get { int c = ParseInt(ConfigurationManager.AppSettings["Billing.ReconcileCap"], 300); return c < 1 ? 1 : c; }
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

    public static bool IsEngineAlive { get { return _started && _timer != null; } }

    // ====================================================================
    // LIFECYCLE
    // ====================================================================
    /// <summary>Called once from Application_Start. Idempotent. Does NO blocking work.</summary>
    public static void EnsureStarted()
    {
        lock (_startLock)
        {
            if (_started && _timer != null) return;
            StartNoLock();
        }
    }

    public static void Start() { lock (_startLock) { StartNoLock(); } }

    private static void StartNoLock()
    {
        // Policy: the auto-reconcile engine must never start (see AutoReconcileDisabled).
        if (AutoReconcileDisabled) { _started = false; return; }
        try
        {
            if (_timer != null) { _timer.Dispose(); _timer = null; }
            long period = (long)IntervalHours * 60L * 60L * 1000L;
            long due = 120L * 1000L;                       // 2 min warm-up before the first run
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

    /// <summary>Run one reconcile immediately (UI "Run now"), bypassing the enabled guard.</summary>
    public static string RunOnce(string actor) { return DoRun(true, actor); }

    /// <summary>Enable / pause the auto-reconcile (persisted). The timer stays alive; work is gated on the flag.</summary>
    public static void SetEnabled(bool on, string actor)
    {
        try { EnsureTable(); } catch { }
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "UPDATE fin_billing_recon_jobstate SET enabled=@e, status=@st, last_message=@msg, updated_at=NOW() WHERE job_name=@j", conn))
            {
                cmd.Parameters.AddWithValue("@e", on ? 1 : 0);
                cmd.Parameters.AddWithValue("@st", on ? "IDLE" : "PAUSED");
                cmd.Parameters.AddWithValue("@msg", (string.IsNullOrEmpty(actor) ? "system" : actor) + (on ? " resumed auto-reconcile" : " paused auto-reconcile"));
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
        try { DoRun(false, "auto-reconcile"); }
        catch { /* an exception must NEVER escape the timer thread */ }
    }

    private static string DoRun(bool force, string actor)
    {
        // Policy: auto-reconcile (which auto-registers students) is disabled. This gate covers
        // BOTH the timer path and the "Run now" force path, so no code route can auto-register.
        if (AutoReconcileDisabled)
            return "Auto-reconcile is disabled by policy — register students via the new UI or student self-service only.";

        if (Interlocked.CompareExchange(ref _ticking, 1, 0) != 0)
            return "A reconcile is already running.";

        try
        {
            EnsureTableOnce();

            bool enabled = true;
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "UPDATE fin_billing_recon_jobstate SET last_heartbeat=NOW(), worker_id=@w, interval_hours=@iv, cap=@cap, updated_at=NOW() WHERE job_name=@j", conn))
                {
                    cmd.Parameters.AddWithValue("@w", WorkerId);
                    cmd.Parameters.AddWithValue("@iv", IntervalHours);
                    cmd.Parameters.AddWithValue("@cap", Cap);
                    cmd.Parameters.AddWithValue("@j", JOB);
                    cmd.ExecuteNonQuery();
                }
                using (var cmd = new MySqlCommand("SELECT enabled FROM fin_billing_recon_jobstate WHERE job_name=@j LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@j", JOB);
                    using (var rd = cmd.ExecuteReader())
                        if (rd.Read()) enabled = SafeInt(rd["enabled"], 1) == 1;
                }
                if (!enabled && !force)
                {
                    using (var cmd = new MySqlCommand("UPDATE fin_billing_recon_jobstate SET status='PAUSED', updated_at=NOW() WHERE job_name=@j", conn))
                    { cmd.Parameters.AddWithValue("@j", JOB); cmd.ExecuteNonQuery(); }
                    return "Paused.";
                }
                using (var cmd = new MySqlCommand("UPDATE fin_billing_recon_jobstate SET status='RUNNING', last_run=NOW(), worker_id=@w WHERE job_name=@j", conn))
                { cmd.Parameters.AddWithValue("@w", WorkerId); cmd.Parameters.AddWithValue("@j", JOB); cmd.ExecuteNonQuery(); }
            }

            // resolve the current academic year
            string acadYear = AcademicYearHelper.GetCurrentAcademicYear();
            int semester = AcademicYearHelper.GetCurrentSemester();
            int fixedCount = 0;
            int gapCount = 0;
            string modeMsg = "";

            if (!string.IsNullOrEmpty(acadYear))
            {
                // Sweep ALL THREE semesters, not just the "current" one — students register
                // across S1/S2/S3 and any of them can hold an enrolled-but-unbilled gap. The
                // reconcile SP is idempotent and course-driven, so sweeping an inactive semester
                // is a harmless no-op (no courses => no gap).
                for (int s = 1; s <= 3; s++)
                {
                    using (var conn = new MySqlConnection(ConnStr))
                    {
                        conn.Open();
                        using (var cmd = new MySqlCommand("CALL fin_ReconcileEnrolledBilling(@ay,@s,1,@cap)", conn))
                        {
                            cmd.CommandTimeout = 600;
                            cmd.Parameters.AddWithValue("@ay", acadYear);
                            cmd.Parameters.AddWithValue("@s", s);
                            cmd.Parameters.AddWithValue("@cap", Cap);
                            using (var rd = cmd.ExecuteReader())
                            {
                                if (rd.Read())
                                {
                                    gapCount += SafeInt(rd["enrolled_gap_students"], 0);
                                    fixedCount += SafeInt(rd["fixed"], 0);
                                    string m = rd["mode"] == null || rd["mode"] == DBNull.Value ? "" : rd["mode"].ToString();
                                    if (m.IndexOf("EXCEEDS_CAP", StringComparison.OrdinalIgnoreCase) >= 0) modeMsg = m;
                                }
                            }
                        }
                    }
                }
                if (string.IsNullOrEmpty(modeMsg)) modeMsg = "swept S1-S3";
            }
            else
            {
                modeMsg = "Skipped — no current academic year resolved.";
            }

            string msg = string.IsNullOrEmpty(acadYear)
                ? modeMsg
                : ("[" + acadYear + " S1-S3] gaps " + gapCount + ", fixed " + fixedCount + ". " + modeMsg);

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "UPDATE fin_billing_recon_jobstate SET status='OK', last_finished=NOW(), last_acadyear=@ay, last_semester=@s, " +
                    "last_gaps=@g, last_fixed=@fx, last_message=@msg, last_error=NULL, total_runs=total_runs+1, total_fixed=total_fixed+@fx, updated_at=NOW() " +
                    "WHERE job_name=@j", conn))
                {
                    cmd.Parameters.AddWithValue("@ay", acadYear ?? "");
                    cmd.Parameters.AddWithValue("@s", semester);
                    cmd.Parameters.AddWithValue("@g", gapCount);
                    cmd.Parameters.AddWithValue("@fx", fixedCount);
                    cmd.Parameters.AddWithValue("@msg", Trunc(msg, 500));
                    cmd.Parameters.AddWithValue("@j", JOB);
                    cmd.ExecuteNonQuery();
                }
            }
            return msg;
        }
        catch (Exception ex)
        {
            try
            {
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand("UPDATE fin_billing_recon_jobstate SET status='ERROR', last_finished=NOW(), last_error=@e, updated_at=NOW() WHERE job_name=@j", conn))
                    { cmd.Parameters.AddWithValue("@e", Trunc(ex.Message, 500)); cmd.Parameters.AddWithValue("@j", JOB); cmd.ExecuteNonQuery(); }
                }
            }
            catch { }
            return "Failed: " + ex.Message;
        }
        finally
        {
            Interlocked.Exchange(ref _ticking, 0);
        }
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
                "CREATE TABLE IF NOT EXISTS fin_billing_recon_jobstate (" +
                " job_name VARCHAR(40) NOT NULL PRIMARY KEY," +
                " enabled TINYINT(1) NOT NULL DEFAULT 1," +
                " interval_hours INT NOT NULL DEFAULT 12," +
                " cap INT NOT NULL DEFAULT 300," +
                " status VARCHAR(20) NOT NULL DEFAULT 'IDLE'," +
                " last_heartbeat DATETIME NULL, last_run DATETIME NULL, last_finished DATETIME NULL," +
                " last_acadyear VARCHAR(15) NULL, last_semester INT NOT NULL DEFAULT 0," +
                " last_gaps INT NOT NULL DEFAULT 0, last_fixed INT NOT NULL DEFAULT 0," +
                " last_message VARCHAR(500) NULL, last_error VARCHAR(500) NULL," +
                " total_runs BIGINT NOT NULL DEFAULT 0, total_fixed BIGINT NOT NULL DEFAULT 0," +
                " worker_id VARCHAR(80) NULL, updated_at DATETIME NULL" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8", conn))
            { cmd.ExecuteNonQuery(); }

            using (var cmd = new MySqlCommand(
                "INSERT IGNORE INTO fin_billing_recon_jobstate (job_name,enabled,interval_hours,cap,status) VALUES (@j,1,@iv,@cap,'IDLE')", conn))
            {
                cmd.Parameters.AddWithValue("@j", JOB);
                cmd.Parameters.AddWithValue("@iv", IntervalHours);
                cmd.Parameters.AddWithValue("@cap", Cap);
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
        if (o is bool) return ((bool)o) ? 1 : 0;
        int v; return int.TryParse(o.ToString(), out v) ? v : def;
    }
    private static string Trunc(string s, int n) { s = s ?? ""; return s.Length > n ? s.Substring(0, n) : s; }
}
