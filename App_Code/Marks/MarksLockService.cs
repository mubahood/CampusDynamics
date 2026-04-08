using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksLockService — Unified lock precedence engine for the marks module.
///
/// Combines multiple independent locking mechanisms into a single
/// authoritative check. Lock precedence (highest to lowest):
///
///   1. Status Lock: Marks in status >= SUBMITTED are non-editable.
///   2. Deadline Lock: Per-type (COURSEWORK, EXAM, SUBMISSION) deadlines.
///   3. Programme Security Level: Per-programme/semester granular lock.
///   4. Global Lock: Legacy acad_results_lock fallback.
///
/// Each lock type can independently lock or unlock the sheet.
/// The engine returns structured results indicating WHICH locks are
/// active and WHY, so the UI can display meaningful messages.
///
/// Unlock requests (from MarksDeadlineService) can override deadline
/// locks for a time-limited window but do NOT override status locks
/// or programme-level locks.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P27, P28, P33 (lock granularity/precedence)
/// Task: F-02
/// </summary>
public static class MarksLockService
{
    // ─────────────────────── Connection String ──────────────────────────

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    // ─────────────────────── Lock Type Constants ────────────────────────

    public const string LOCK_STATUS            = "STATUS";
    public const string LOCK_DEADLINE_CW       = "DEADLINE_COURSEWORK";
    public const string LOCK_DEADLINE_EXAM     = "DEADLINE_EXAM";
    public const string LOCK_DEADLINE_SUBMIT   = "DEADLINE_SUBMISSION";
    public const string LOCK_PROGRAMME         = "PROGRAMME_SECURITY";
    public const string LOCK_GLOBAL            = "GLOBAL_LOCK";

    // ─────────────────────── Component Types ────────────────────────────

    /// <summary>Which mark component the caller wants to edit.</summary>
    public const string COMPONENT_CW   = "COURSEWORK";
    public const string COMPONENT_TEST = "TEST";
    public const string COMPONENT_EXAM = "EXAM";
    public const string COMPONENT_ALL  = "ALL";

    // ═════════════════════════════════════════════════════════════════════
    // PRIMARY API: GetLockState
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns a comprehensive lock state for a sheet context.
    /// Evaluates all lock mechanisms in precedence order and collects
    /// every active lock reason into the result.
    ///
    /// Use this ONCE when loading a mark entry page — it gives you
    /// all the information needed for lock display and enforcement.
    /// </summary>
    public static LockState GetLockState(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession)
    {
        LockState state = new LockState();
        state.Locks = new List<LockReason>();
        state.CourseId = courseId;
        state.ProgId = progId;
        state.AcadYear = acadyear;
        state.Semester = semester;

        try
        {
            // ── 1. Status Lock (highest precedence) ────────────────────
            EvaluateStatusLock(state, courseId, progId, acadyear, semester, studyYear, campusId, studSession);

            // ── 2. Deadline Locks (per component type) ─────────────────
            EvaluateDeadlineLocks(state, campusId, acadyear, semester, studSession);

            // ── 3. Programme Security Level Lock ───────────────────────
            EvaluateProgrammeLock(state, progId, acadyear, semester);

            // ── 4. Global Lock (legacy fallback) ───────────────────────
            EvaluateGlobalLock(state);
        }
        catch (Exception ex)
        {
            // On evaluation error, fail-open but record a warning
            LockReason warning = new LockReason();
            warning.LockType = "ERROR";
            warning.Message = "Lock evaluation error: " + ex.Message;
            warning.IsSoft = true;
            state.Locks.Add(warning);
        }

        // Compute summary flags
        state.IsFullyLocked = false;
        state.IsCwLocked = false;
        state.IsExamLocked = false;
        state.IsSubmitLocked = false;
        state.CanRequestUnlock = false;

        foreach (LockReason lr in state.Locks)
        {
            if (lr.IsSoft) continue; // soft warnings don't prevent editing

            if (lr.LockType == LOCK_STATUS || lr.LockType == LOCK_PROGRAMME || lr.LockType == LOCK_GLOBAL)
            {
                state.IsFullyLocked = true;
                state.IsCwLocked = true;
                state.IsExamLocked = true;
                state.IsSubmitLocked = true;
            }
            else if (lr.LockType == LOCK_DEADLINE_CW)
            {
                state.IsCwLocked = true;
            }
            else if (lr.LockType == LOCK_DEADLINE_EXAM)
            {
                state.IsExamLocked = true;
            }
            else if (lr.LockType == LOCK_DEADLINE_SUBMIT)
            {
                state.IsSubmitLocked = true;
            }
        }

        // Can request unlock only for deadline locks (not status/programme locks)
        if ((state.IsCwLocked || state.IsExamLocked) && !state.IsFullyLocked)
        {
            state.CanRequestUnlock = true;
        }

        return state;
    }

    // ═════════════════════════════════════════════════════════════════════
    // CONVENIENCE: Quick Check Methods
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Quick check: is marking fully locked for this context?
    /// Shorthand for GetLockState().IsFullyLocked.
    /// </summary>
    public static bool IsLocked(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession)
    {
        LockState state = GetLockState(courseId, progId, acadyear, semester, studyYear, campusId, studSession);
        return state.IsFullyLocked;
    }

    /// <summary>
    /// Quick check: can marks be edited for a specific component?
    /// Returns true if the component is NOT locked.
    /// </summary>
    public static bool CanEditComponent(
        string component,
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession)
    {
        LockState state = GetLockState(courseId, progId, acadyear, semester, studyYear, campusId, studSession);

        if (state.IsFullyLocked) return false;
        if (component == COMPONENT_CW) return !state.IsCwLocked;
        if (component == COMPONENT_EXAM || component == COMPONENT_TEST) return !state.IsExamLocked;
        return true;
    }

    /// <summary>
    /// Quick check: can the teacher submit this sheet for review?
    /// Requires DRAFT status and submission deadline not passed.
    /// </summary>
    public static bool CanSubmit(
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession)
    {
        LockState state = GetLockState(courseId, progId, acadyear, semester, studyYear, campusId, studSession);

        // Must not be fully locked, must not be past submission deadline
        // And status must be DRAFT (status lock means it's already submitted+)
        bool hasStatusLock = false;
        foreach (LockReason lr in state.Locks)
        {
            if (lr.LockType == LOCK_STATUS && !lr.IsSoft) hasStatusLock = true;
        }
        return !hasStatusLock && !state.IsSubmitLocked;
    }

    // ═════════════════════════════════════════════════════════════════════
    // LOCK EVALUATORS (private)
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Evaluates the results status lock.
    /// Marks are non-editable once status >= SUBMITTED (unless there's
    /// an active unlock request — but status locks aredefinitive).
    /// </summary>
    private static void EvaluateStatusLock(LockState state,
        string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession)
    {
        string status = ResultsStatusService.GetStatus(courseId, progId, acadyear, semester, studyYear, campusId, studSession);
        state.CurrentStatus = status;

        if (status != ResultsStatusService.STATUS_DRAFT)
        {
            LockReason lr = new LockReason();
            lr.LockType = LOCK_STATUS;
            lr.IsSoft = false;

            if (status == ResultsStatusService.STATUS_SUBMITTED)
            {
                lr.Message = "Marks have been submitted for Dean review and cannot be edited.";
            }
            else if (status == ResultsStatusService.STATUS_DEAN_APPROVED)
            {
                lr.Message = "Results have been approved by the Dean and are locked.";
            }
            else if (status == ResultsStatusService.STATUS_PROVISIONAL_PUBLISHED)
            {
                lr.Message = "Results have been provisionally published and are locked.";
            }
            else if (status == ResultsStatusService.STATUS_FINAL_PUBLISHED)
            {
                lr.Message = "Results have been finally published and are permanently locked.";
            }
            else
            {
                lr.Message = String.Format("Sheet is in '{0}' status and cannot be edited.", status);
            }
            state.Locks.Add(lr);
        }
    }

    /// <summary>
    /// Evaluates deadline-based locks per component type.
    /// CW and Exam have independent deadlines. Submission has its own.
    /// Each deadline type is checked independently against the unified
    /// MarksDeadlineService.
    /// </summary>
    private static void EvaluateDeadlineLocks(LockState state,
        int campusId, string acadyear, int semester, string studSession)
    {
        // ── CW Deadline ───────────────────────────────────────────────
        if (MarksDeadlineService.IsLocked("COURSEWORK", campusId, acadyear, semester, studSession))
        {
            MarksDeadlineService.DeadlineInfo cwInfo = MarksDeadlineService.GetDeadlineInfo(
                "COURSEWORK", campusId, acadyear, semester, studSession);

            LockReason lr = new LockReason();
            lr.LockType = LOCK_DEADLINE_CW;
            lr.IsSoft = false;
            if (cwInfo != null)
            {
                lr.Message = String.Format("Coursework marks deadline passed on {0:dd MMM yyyy}.",
                    cwInfo.DeadlineDate);
                lr.DeadlineDate = cwInfo.DeadlineDate;
            }
            else
            {
                lr.Message = "Coursework marks deadline has passed.";
            }
            state.Locks.Add(lr);
        }
        else
        {
            // Not locked — check if deadline is approaching (soft warning)
            MarksDeadlineService.DeadlineInfo cwInfo = MarksDeadlineService.GetDeadlineInfo(
                "COURSEWORK", campusId, acadyear, semester, studSession);
            if (cwInfo != null && !cwInfo.IsExpired && cwInfo.DaysRemaining <= 7)
            {
                LockReason lr = new LockReason();
                lr.LockType = LOCK_DEADLINE_CW;
                lr.IsSoft = true;
                lr.Message = String.Format("Coursework marks due in {0} day{1} ({2:dd MMM yyyy}).",
                    cwInfo.DaysRemaining, cwInfo.DaysRemaining == 1 ? "" : "s", cwInfo.DeadlineDate);
                lr.DeadlineDate = cwInfo.DeadlineDate;
                lr.DaysRemaining = cwInfo.DaysRemaining;
                state.Locks.Add(lr);
            }
        }

        // ── Exam Deadline ─────────────────────────────────────────────
        if (MarksDeadlineService.IsLocked("EXAM", campusId, acadyear, semester, studSession))
        {
            MarksDeadlineService.DeadlineInfo examInfo = MarksDeadlineService.GetDeadlineInfo(
                "EXAM", campusId, acadyear, semester, studSession);

            LockReason lr = new LockReason();
            lr.LockType = LOCK_DEADLINE_EXAM;
            lr.IsSoft = false;
            if (examInfo != null)
            {
                lr.Message = String.Format("Exam marks deadline passed on {0:dd MMM yyyy}.",
                    examInfo.DeadlineDate);
                lr.DeadlineDate = examInfo.DeadlineDate;
            }
            else
            {
                lr.Message = "Exam marks deadline has passed.";
            }
            state.Locks.Add(lr);
        }
        else
        {
            MarksDeadlineService.DeadlineInfo examInfo = MarksDeadlineService.GetDeadlineInfo(
                "EXAM", campusId, acadyear, semester, studSession);
            if (examInfo != null && !examInfo.IsExpired && examInfo.DaysRemaining <= 7)
            {
                LockReason lr = new LockReason();
                lr.LockType = LOCK_DEADLINE_EXAM;
                lr.IsSoft = true;
                lr.Message = String.Format("Exam marks due in {0} day{1} ({2:dd MMM yyyy}).",
                    examInfo.DaysRemaining, examInfo.DaysRemaining == 1 ? "" : "s", examInfo.DeadlineDate);
                lr.DeadlineDate = examInfo.DeadlineDate;
                lr.DaysRemaining = examInfo.DaysRemaining;
                state.Locks.Add(lr);
            }
        }

        // ── Submission Deadline ───────────────────────────────────────
        if (MarksDeadlineService.IsLocked("SUBMISSION", campusId, acadyear, semester, studSession))
        {
            MarksDeadlineService.DeadlineInfo subInfo = MarksDeadlineService.GetDeadlineInfo(
                "SUBMISSION", campusId, acadyear, semester, studSession);

            LockReason lr = new LockReason();
            lr.LockType = LOCK_DEADLINE_SUBMIT;
            lr.IsSoft = false;
            if (subInfo != null)
            {
                lr.Message = String.Format("Sheet submission deadline passed on {0:dd MMM yyyy}.",
                    subInfo.DeadlineDate);
                lr.DeadlineDate = subInfo.DeadlineDate;
            }
            else
            {
                lr.Message = "Sheet submission deadline has passed.";
            }
            state.Locks.Add(lr);
        }
        else
        {
            MarksDeadlineService.DeadlineInfo subInfo = MarksDeadlineService.GetDeadlineInfo(
                "SUBMISSION", campusId, acadyear, semester, studSession);
            if (subInfo != null && !subInfo.IsExpired && subInfo.DaysRemaining <= 7)
            {
                LockReason lr = new LockReason();
                lr.LockType = LOCK_DEADLINE_SUBMIT;
                lr.IsSoft = true;
                lr.Message = String.Format("Submit deadline in {0} day{1} ({2:dd MMM yyyy}).",
                    subInfo.DaysRemaining, subInfo.DaysRemaining == 1 ? "" : "s", subInfo.DeadlineDate);
                lr.DeadlineDate = subInfo.DeadlineDate;
                lr.DaysRemaining = subInfo.DaysRemaining;
                state.Locks.Add(lr);
            }
        }
    }

    /// <summary>
    /// Evaluates the programme-level security lock.
    /// acad_results_securitylevel.securitylevel = 2 means locked.
    /// </summary>
    private static void EvaluateProgrammeLock(LockState state,
        string progId, string acadyear, int semester)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT securitylevel FROM acad_results_securitylevel
                      WHERE progid = @prog AND acadyear = @year AND semester = @sem
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@prog", progId);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);

                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        int level = Convert.ToInt32(result);
                        if (level >= 2)
                        {
                            LockReason lr = new LockReason();
                            lr.LockType = LOCK_PROGRAMME;
                            lr.IsSoft = false;
                            lr.Message = String.Format(
                                "Programme {0} has been locked at security level {1} for {2} semester {3}.",
                                progId, level, acadyear, semester);
                            state.Locks.Add(lr);
                        }
                    }
                }
            }
        }
        catch
        {
            // Fail-open: don't block on security-level check error
        }
    }

    /// <summary>
    /// Evaluates the legacy global lock from acad_results_lock.
    /// </summary>
    private static void EvaluateGlobalLock(LockState state)
    {
        if (MarksDeadlineService.IsGloballyLocked())
        {
            LockReason lr = new LockReason();
            lr.LockType = LOCK_GLOBAL;
            lr.IsSoft = false;
            lr.Message = "Results are globally locked by the system administrator.";
            state.Locks.Add(lr);
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // JSON HELPER (for AJAX responses)
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Serializes LockState to JSON for embedding in AJAX responses.
    /// Uses StringBuilder for C# 5 compatibility.
    /// </summary>
    public static string ToJson(LockState state)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("{");
        sb.Append("\"isFullyLocked\":");
        sb.Append(state.IsFullyLocked ? "true" : "false");
        sb.Append(",\"isCwLocked\":");
        sb.Append(state.IsCwLocked ? "true" : "false");
        sb.Append(",\"isExamLocked\":");
        sb.Append(state.IsExamLocked ? "true" : "false");
        sb.Append(",\"isSubmitLocked\":");
        sb.Append(state.IsSubmitLocked ? "true" : "false");
        sb.Append(",\"canRequestUnlock\":");
        sb.Append(state.CanRequestUnlock ? "true" : "false");
        sb.Append(",\"currentStatus\":\"");
        sb.Append(JsEsc(state.CurrentStatus ?? "DRAFT"));
        sb.Append("\",\"locks\":[");

        for (int i = 0; i < state.Locks.Count; i++)
        {
            if (i > 0) sb.Append(",");
            LockReason lr = state.Locks[i];
            sb.Append("{\"type\":\"");
            sb.Append(JsEsc(lr.LockType));
            sb.Append("\",\"message\":\"");
            sb.Append(JsEsc(lr.Message));
            sb.Append("\",\"isSoft\":");
            sb.Append(lr.IsSoft ? "true" : "false");
            if (lr.DeadlineDate != DateTime.MinValue)
            {
                sb.Append(",\"deadline\":\"");
                sb.Append(lr.DeadlineDate.ToString("yyyy-MM-dd"));
                sb.Append("\"");
            }
            if (lr.DaysRemaining > 0)
            {
                sb.Append(",\"daysRemaining\":");
                sb.Append(lr.DaysRemaining);
            }
            sb.Append("}");
        }

        sb.Append("]}");
        return sb.ToString();
    }

    private static string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }

    // ═════════════════════════════════════════════════════════════════════
    // DTOs
    // ═════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Comprehensive lock state result. Contains all active locks,
    /// convenience boolean flags, and the current sheet status.
    /// </summary>
    public class LockState
    {
        public string CourseId { get; set; }
        public string ProgId { get; set; }
        public string AcadYear { get; set; }
        public int Semester { get; set; }

        /// <summary>Current sheet status (DRAFT, SUBMITTED, etc.).</summary>
        public string CurrentStatus { get; set; }

        /// <summary>True if ALL mark editing is blocked (status/programme/global lock).</summary>
        public bool IsFullyLocked { get; set; }

        /// <summary>True if CW component editing is blocked (deadline or full lock).</summary>
        public bool IsCwLocked { get; set; }

        /// <summary>True if Exam/Test component editing is blocked.</summary>
        public bool IsExamLocked { get; set; }

        /// <summary>True if sheet submission is blocked (deadline or status).</summary>
        public bool IsSubmitLocked { get; set; }

        /// <summary>True if the user can request an unlock (deadline-locked but not status-locked).</summary>
        public bool CanRequestUnlock { get; set; }

        /// <summary>List of all active lock reasons with details.</summary>
        public List<LockReason> Locks { get; set; }
    }

    /// <summary>
    /// Individual lock reason with type, message, and optional deadline info.
    /// </summary>
    public class LockReason
    {
        /// <summary>Lock type constant (LOCK_STATUS, LOCK_DEADLINE_CW, etc.).</summary>
        public string LockType { get; set; }

        /// <summary>Human-readable lock message for the UI.</summary>
        public string Message { get; set; }

        /// <summary>True for warnings (approaching deadline) that don't prevent editing.</summary>
        public bool IsSoft { get; set; }

        /// <summary>The deadline date, if this lock is deadline-related.</summary>
        public DateTime DeadlineDate { get; set; }

        /// <summary>Days remaining until deadline (0 or negative if expired).</summary>
        public int DaysRemaining { get; set; }
    }
}
