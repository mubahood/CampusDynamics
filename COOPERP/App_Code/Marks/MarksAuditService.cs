using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksAuditService — Structured audit trail for all mark-changing events.
///
/// Every mutation to marks data is logged here with:
///   - Who performed it (user, IP, role)
///   - What changed (old/new values for CW, Test, Exam)
///   - Why (action type: INSERT, UPDATE, DELETE, APPROVE, IMPORT, UNLOCK, REJECT)
///   - When (server timestamp)
///   - Context (course, programme, student, academic period)
///
/// The service writes to acad_marks_audit with the extended columns from B-05.
/// All methods are static and never throw — they return false on failure.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P4, P5, P69, P70 (audit coverage gaps)
/// Task: D-03
/// </summary>
public static class MarksAuditService
{
    // ─────────────────────── Connection String ──────────────────────────

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    // ─────────────────────── Action Types ───────────────────────────────

    public const string ACTION_INSERT  = "INSERT";
    public const string ACTION_UPDATE  = "UPDATE";
    public const string ACTION_DELETE  = "DELETE";
    public const string ACTION_APPROVE = "APPROVE";
    public const string ACTION_REJECT  = "REJECT";
    public const string ACTION_IMPORT  = "IMPORT";
    public const string ACTION_UNLOCK  = "UNLOCK";
    public const string ACTION_SUBMIT  = "SUBMIT";
    public const string ACTION_REVERT  = "REVERT";

    // ─────────────────────── Core Logging ────────────────────────────────

    /// <summary>
    /// Logs a single mark change to the audit trail.
    /// This is the primary method — all other Log* methods delegate to this.
    /// </summary>
    /// <param name="entry">A fully populated AuditEntry.</param>
    /// <returns>true if the audit row was successfully inserted.</returns>
    public static bool LogEntry(AuditEntry entry)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                return LogEntry(conn, null, entry);
            }
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Logs an audit entry within an existing connection/transaction context.
    /// Use this when you're already inside a BulkSave transaction so the audit
    /// writes are atomic with the data writes.
    /// </summary>
    public static bool LogEntry(MySqlConnection conn, MySqlTransaction tx, AuditEntry entry)
    {
        try
        {
            string sql = @"INSERT INTO acad_marks_audit
                (student_id, course_id, progid, acadyear, semester,
                 old_coursework, new_coursework, old_test, new_test, old_exam, new_exam,
                 old_cw_entered, new_cw_entered, old_test_entered, new_test_entered,
                 old_exam_entered, new_exam_entered,
                 action_type, action_type_ext, changed_by, ip_address, change_reason,
                 change_date)
                VALUES
                (@sid, @cid, @prog, @year, @sem,
                 @oldCw, @newCw, @oldTest, @newTest, @oldExam, @newExam,
                 @oldCwE, @newCwE, @oldTestE, @newTestE,
                 @oldExamE, @newExamE,
                 @action, @actionExt, @user, @ip, @reason,
                 NOW())";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (tx != null) cmd.Transaction = tx;

                cmd.Parameters.AddWithValue("@sid", entry.StudentId ?? "");
                cmd.Parameters.AddWithValue("@cid", entry.CourseId ?? "");
                cmd.Parameters.AddWithValue("@prog", entry.ProgId ?? "");
                cmd.Parameters.AddWithValue("@year", entry.AcadYear ?? "");
                cmd.Parameters.AddWithValue("@sem", entry.Semester);

                cmd.Parameters.AddWithValue("@oldCw", (object)entry.OldCoursework ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@newCw", (object)entry.NewCoursework ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@oldTest", (object)entry.OldTest ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@newTest", (object)entry.NewTest ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@oldExam", (object)entry.OldExam ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@newExam", (object)entry.NewExam ?? DBNull.Value);

                cmd.Parameters.AddWithValue("@oldCwE", (object)entry.OldCwEntered ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@newCwE", (object)entry.NewCwEntered ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@oldTestE", (object)entry.OldTestEntered ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@newTestE", (object)entry.NewTestEntered ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@oldExamE", (object)entry.OldExamEntered ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@newExamE", (object)entry.NewExamEntered ?? DBNull.Value);

                cmd.Parameters.AddWithValue("@action", entry.ActionType ?? ACTION_UPDATE);
                cmd.Parameters.AddWithValue("@actionExt", entry.ActionTypeExt ?? entry.ActionType ?? ACTION_UPDATE);
                cmd.Parameters.AddWithValue("@user", entry.ChangedBy ?? "SYSTEM");
                cmd.Parameters.AddWithValue("@ip", entry.IpAddress ?? "");
                cmd.Parameters.AddWithValue("@reason", entry.ChangeReason ?? "");

                return cmd.ExecuteNonQuery() > 0;
            }
        }
        catch
        {
            return false;
        }
    }

    // ─────────────────────── Convenience Methods ────────────────────────

    /// <summary>
    /// Log a mark update (the most common audit event).
    /// Captures old and new values for all three mark components.
    /// </summary>
    public static bool LogMarkUpdate(string studentId, string courseId, string progId,
        string acadyear, int semester,
        decimal? oldCw, decimal? newCw, decimal? oldTest, decimal? newTest,
        decimal? oldExam, decimal? newExam,
        decimal? oldCwEntered, decimal? newCwEntered,
        decimal? oldTestEntered, decimal? newTestEntered,
        decimal? oldExamEntered, decimal? newExamEntered)
    {
        AuditEntry entry = new AuditEntry();
        entry.StudentId = studentId;
        entry.CourseId = courseId;
        entry.ProgId = progId;
        entry.AcadYear = acadyear;
        entry.Semester = semester;
        entry.ActionType = ACTION_UPDATE;
        entry.ActionTypeExt = ACTION_UPDATE;
        entry.OldCoursework = oldCw;
        entry.NewCoursework = newCw;
        entry.OldTest = oldTest;
        entry.NewTest = newTest;
        entry.OldExam = oldExam;
        entry.NewExam = newExam;
        entry.OldCwEntered = oldCwEntered;
        entry.NewCwEntered = newCwEntered;
        entry.OldTestEntered = oldTestEntered;
        entry.NewTestEntered = newTestEntered;
        entry.OldExamEntered = oldExamEntered;
        entry.NewExamEntered = newExamEntered;
        entry.ChangedBy = MarksAuthorizationService.GetCurrentUser();
        entry.IpAddress = MarksAuthorizationService.GetClientIP();
        return LogEntry(entry);
    }

    /// <summary>
    /// Log a mark update within a transaction (for BulkSave).
    /// </summary>
    public static bool LogMarkUpdate(MySqlConnection conn, MySqlTransaction tx,
        string studentId, string courseId, string progId,
        string acadyear, int semester,
        decimal? oldCw, decimal? newCw, decimal? oldTest, decimal? newTest,
        decimal? oldExam, decimal? newExam,
        decimal? oldCwEntered, decimal? newCwEntered,
        decimal? oldTestEntered, decimal? newTestEntered,
        decimal? oldExamEntered, decimal? newExamEntered)
    {
        AuditEntry entry = new AuditEntry();
        entry.StudentId = studentId;
        entry.CourseId = courseId;
        entry.ProgId = progId;
        entry.AcadYear = acadyear;
        entry.Semester = semester;
        entry.ActionType = ACTION_UPDATE;
        entry.ActionTypeExt = ACTION_UPDATE;
        entry.OldCoursework = oldCw;
        entry.NewCoursework = newCw;
        entry.OldTest = oldTest;
        entry.NewTest = newTest;
        entry.OldExam = oldExam;
        entry.NewExam = newExam;
        entry.OldCwEntered = oldCwEntered;
        entry.NewCwEntered = newCwEntered;
        entry.OldTestEntered = oldTestEntered;
        entry.NewTestEntered = newTestEntered;
        entry.OldExamEntered = oldExamEntered;
        entry.NewExamEntered = newExamEntered;
        entry.ChangedBy = MarksAuthorizationService.GetCurrentUser();
        entry.IpAddress = MarksAuthorizationService.GetClientIP();
        return LogEntry(conn, tx, entry);
    }

    /// <summary>
    /// Log a bulk import event. Records the action on a per-student basis.
    /// </summary>
    public static bool LogImport(string studentId, string courseId, string progId,
        string acadyear, int semester,
        decimal? newCw, decimal? newTest, decimal? newExam,
        decimal? newCwEntered, decimal? newTestEntered, decimal? newExamEntered)
    {
        AuditEntry entry = new AuditEntry();
        entry.StudentId = studentId;
        entry.CourseId = courseId;
        entry.ProgId = progId;
        entry.AcadYear = acadyear;
        entry.Semester = semester;
        entry.ActionType = ACTION_IMPORT;
        entry.ActionTypeExt = ACTION_IMPORT;
        entry.NewCoursework = newCw;
        entry.NewTest = newTest;
        entry.NewExam = newExam;
        entry.NewCwEntered = newCwEntered;
        entry.NewTestEntered = newTestEntered;
        entry.NewExamEntered = newExamEntered;
        entry.ChangedBy = MarksAuthorizationService.GetCurrentUser();
        entry.IpAddress = MarksAuthorizationService.GetClientIP();
        return LogEntry(entry);
    }

    /// <summary>
    /// Log an approval/rejection event. Applies at the sheet level (one per course context).
    /// </summary>
    public static bool LogApproval(string actionType, string courseId, string progId,
        string acadyear, int semester, string reason)
    {
        AuditEntry entry = new AuditEntry();
        entry.CourseId = courseId;
        entry.ProgId = progId;
        entry.AcadYear = acadyear;
        entry.Semester = semester;
        entry.ActionType = actionType;
        entry.ActionTypeExt = actionType;
        entry.ChangeReason = reason;
        entry.ChangedBy = MarksAuthorizationService.GetCurrentUser();
        entry.IpAddress = MarksAuthorizationService.GetClientIP();
        return LogEntry(entry);
    }

    /// <summary>
    /// Log an unlock event (when a deadline is overridden for a user).
    /// </summary>
    public static bool LogUnlock(string courseId, string progId, string acadyear, int semester,
        string unlockedFor, string reason)
    {
        AuditEntry entry = new AuditEntry();
        entry.CourseId = courseId;
        entry.ProgId = progId;
        entry.AcadYear = acadyear;
        entry.Semester = semester;
        entry.ActionType = ACTION_UNLOCK;
        entry.ActionTypeExt = ACTION_UNLOCK;
        entry.ChangeReason = String.Format("Unlocked for {0}: {1}", unlockedFor, reason);
        entry.ChangedBy = MarksAuthorizationService.GetCurrentUser();
        entry.IpAddress = MarksAuthorizationService.GetClientIP();
        return LogEntry(entry);
    }

    // ─────────────────────── Query / Retrieval ──────────────────────────

    /// <summary>
    /// Retrieves audit trail for a specific student/course context.
    /// Returns most recent entries first.
    /// </summary>
    public static List<AuditEntry> GetAuditTrail(string studentId, string courseId,
        string progId, string acadyear, int semester, int limit)
    {
        List<AuditEntry> list = new List<AuditEntry>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT student_id, course_id, progid, acadyear, semester,
                                      old_coursework, new_coursework, old_test, new_test, old_exam, new_exam,
                                      old_cw_entered, new_cw_entered, old_test_entered, new_test_entered,
                                      old_exam_entered, new_exam_entered,
                                      action_type, action_type_ext, changed_by, ip_address, change_reason,
                                      change_date
                               FROM acad_marks_audit
                               WHERE (@sid = '' OR student_id = @sid)
                                 AND course_id = @cid
                                 AND progid = @prog
                                 AND acadyear = @year
                                 AND semester = @sem
                               ORDER BY change_date DESC
                               LIMIT @lim";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId ?? "");
                    cmd.Parameters.AddWithValue("@cid", courseId);
                    cmd.Parameters.AddWithValue("@prog", progId);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    cmd.Parameters.AddWithValue("@lim", limit > 0 ? limit : 100);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            AuditEntry e = new AuditEntry();
                            e.StudentId = rdr["student_id"].ToString();
                            e.CourseId = rdr["course_id"].ToString();
                            e.ProgId = rdr["progid"].ToString();
                            e.AcadYear = rdr["acadyear"].ToString();
                            e.Semester = Convert.ToInt32(rdr["semester"]);
                            e.OldCoursework = rdr["old_coursework"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_coursework"]) : null;
                            e.NewCoursework = rdr["new_coursework"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_coursework"]) : null;
                            e.OldTest = rdr["old_test"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_test"]) : null;
                            e.NewTest = rdr["new_test"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_test"]) : null;
                            e.OldExam = rdr["old_exam"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_exam"]) : null;
                            e.NewExam = rdr["new_exam"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_exam"]) : null;
                            e.OldCwEntered = rdr["old_cw_entered"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_cw_entered"]) : null;
                            e.NewCwEntered = rdr["new_cw_entered"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_cw_entered"]) : null;
                            e.OldTestEntered = rdr["old_test_entered"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_test_entered"]) : null;
                            e.NewTestEntered = rdr["new_test_entered"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_test_entered"]) : null;
                            e.OldExamEntered = rdr["old_exam_entered"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_exam_entered"]) : null;
                            e.NewExamEntered = rdr["new_exam_entered"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_exam_entered"]) : null;
                            e.ActionType = rdr["action_type"].ToString();
                            e.ActionTypeExt = rdr["action_type_ext"] != DBNull.Value ? rdr["action_type_ext"].ToString() : e.ActionType;
                            e.ChangedBy = rdr["changed_by"].ToString();
                            e.IpAddress = rdr["ip_address"] != DBNull.Value ? rdr["ip_address"].ToString() : "";
                            e.ChangeReason = rdr["change_reason"] != DBNull.Value ? rdr["change_reason"].ToString() : "";
                            e.ChangeDate = Convert.ToDateTime(rdr["change_date"]);
                            list.Add(e);
                        }
                    }
                }
            }
        }
        catch
        {
            // Return empty list on error
        }
        return list;
    }

    /// <summary>
    /// Retrieves recent audit entries across all courses (for Audit Centre dashboard).
    /// Supports optional filtering by action type and date range.
    /// </summary>
    public static List<AuditEntry> GetRecentActivity(string actionTypeFilter, DateTime? fromDate,
        DateTime? toDate, int limit)
    {
        List<AuditEntry> list = new List<AuditEntry>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                string sql = @"SELECT student_id, course_id, progid, acadyear, semester,
                                      old_coursework, new_coursework, old_test, new_test, old_exam, new_exam,
                                      action_type, action_type_ext, changed_by, ip_address, change_reason,
                                      change_date
                               FROM acad_marks_audit
                               WHERE 1=1";

                if (!string.IsNullOrEmpty(actionTypeFilter))
                    sql += " AND action_type_ext = @atype";
                if (fromDate.HasValue)
                    sql += " AND change_date >= @from";
                if (toDate.HasValue)
                    sql += " AND change_date <= @to";

                sql += " ORDER BY change_date DESC LIMIT @lim";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(actionTypeFilter))
                        cmd.Parameters.AddWithValue("@atype", actionTypeFilter);
                    if (fromDate.HasValue)
                        cmd.Parameters.AddWithValue("@from", fromDate.Value);
                    if (toDate.HasValue)
                        cmd.Parameters.AddWithValue("@to", toDate.Value);
                    cmd.Parameters.AddWithValue("@lim", limit > 0 ? limit : 200);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            AuditEntry e = new AuditEntry();
                            e.StudentId = rdr["student_id"].ToString();
                            e.CourseId = rdr["course_id"].ToString();
                            e.ProgId = rdr["progid"].ToString();
                            e.AcadYear = rdr["acadyear"].ToString();
                            e.Semester = Convert.ToInt32(rdr["semester"]);
                            e.OldCoursework = rdr["old_coursework"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_coursework"]) : null;
                            e.NewCoursework = rdr["new_coursework"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_coursework"]) : null;
                            e.OldTest = rdr["old_test"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_test"]) : null;
                            e.NewTest = rdr["new_test"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_test"]) : null;
                            e.OldExam = rdr["old_exam"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["old_exam"]) : null;
                            e.NewExam = rdr["new_exam"] != DBNull.Value ? (decimal?)Convert.ToDecimal(rdr["new_exam"]) : null;
                            e.ActionType = rdr["action_type"].ToString();
                            e.ActionTypeExt = rdr["action_type_ext"] != DBNull.Value ? rdr["action_type_ext"].ToString() : e.ActionType;
                            e.ChangedBy = rdr["changed_by"].ToString();
                            e.IpAddress = rdr["ip_address"] != DBNull.Value ? rdr["ip_address"].ToString() : "";
                            e.ChangeReason = rdr["change_reason"] != DBNull.Value ? rdr["change_reason"].ToString() : "";
                            e.ChangeDate = Convert.ToDateTime(rdr["change_date"]);
                            list.Add(e);
                        }
                    }
                }
            }
        }
        catch
        {
            // Return empty list on error
        }
        return list;
    }

    /// <summary>
    /// Returns summary statistics for the Audit Centre dashboard.
    /// Counts by action type for a given period.
    /// </summary>
    public static AuditSummary GetSummary(DateTime fromDate, DateTime toDate)
    {
        AuditSummary summary = new AuditSummary();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT COALESCE(action_type_ext, action_type) AS act, COUNT(*) AS cnt
                      FROM acad_marks_audit
                      WHERE change_date >= @from AND change_date <= @to
                      GROUP BY COALESCE(action_type_ext, action_type)", conn))
                {
                    cmd.Parameters.AddWithValue("@from", fromDate);
                    cmd.Parameters.AddWithValue("@to", toDate);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string act = rdr["act"].ToString().ToUpper();
                            int cnt = Convert.ToInt32(rdr["cnt"]);
                            summary.TotalEntries += cnt;
                            if (act == ACTION_INSERT) summary.Inserts = cnt;
                            else if (act == ACTION_UPDATE) summary.Updates = cnt;
                            else if (act == ACTION_DELETE) summary.Deletes = cnt;
                            else if (act == ACTION_APPROVE) summary.Approvals = cnt;
                            else if (act == ACTION_REJECT) summary.Rejections = cnt;
                            else if (act == ACTION_IMPORT) summary.Imports = cnt;
                            else if (act == ACTION_UNLOCK) summary.Unlocks = cnt;
                            else if (act == ACTION_SUBMIT) summary.Submissions = cnt;
                        }
                    }
                }
            }
        }
        catch
        {
            // Return zeroed summary on error
        }
        return summary;
    }

    // ─────────────────────── DTOs ───────────────────────────────────────

    public class AuditEntry
    {
        public string StudentId { get; set; }
        public string CourseId { get; set; }
        public string ProgId { get; set; }
        public string AcadYear { get; set; }
        public int Semester { get; set; }
        public decimal? OldCoursework { get; set; }
        public decimal? NewCoursework { get; set; }
        public decimal? OldTest { get; set; }
        public decimal? NewTest { get; set; }
        public decimal? OldExam { get; set; }
        public decimal? NewExam { get; set; }
        public decimal? OldCwEntered { get; set; }
        public decimal? NewCwEntered { get; set; }
        public decimal? OldTestEntered { get; set; }
        public decimal? NewTestEntered { get; set; }
        public decimal? OldExamEntered { get; set; }
        public decimal? NewExamEntered { get; set; }
        public string ActionType { get; set; }
        public string ActionTypeExt { get; set; }
        public string ChangedBy { get; set; }
        public string IpAddress { get; set; }
        public string ChangeReason { get; set; }
        public DateTime ChangeDate { get; set; }
    }

    public class AuditSummary
    {
        public int TotalEntries { get; set; }
        public int Inserts { get; set; }
        public int Updates { get; set; }
        public int Deletes { get; set; }
        public int Approvals { get; set; }
        public int Rejections { get; set; }
        public int Imports { get; set; }
        public int Unlocks { get; set; }
        public int Submissions { get; set; }
    }
}
