using System;
using System.Configuration;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Centralized audit logger for all marks/results changes.
/// Writes structured before→after snapshots to acad_marks_audit.
/// 
/// Table: acad_marks_audit (campus_dynamics)
/// Created: 2026-04-02
/// 
/// Usage:
///   // Before an UPDATE or DELETE, take a snapshot:
///   var snap = MarksAuditLogger.SnapshotFaculty(conn, id);
///   // ... do the UPDATE/DELETE ...
///   // Then log:
///   MarksAuditLogger.LogChange("UPDATE", "acad_examresults_faculty", id,
///       snap, newCw, newTest, newExam, newTotal, newGrade, newApprovedBy,
///       "ALL", null, null, "ExamResultsInfo.aspx");
/// 
///   // For INSERT (no old values):
///   MarksAuditLogger.LogInsert("acad_examresults_faculty", id,
///       regno, courseId, acadYear, sem, progid,
///       cwMark, testMark, examMark, total, grade, approvedBy,
///       "ExamResultsInfo.aspx");
/// </summary>
public static class MarksAuditLogger
{
    private static string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    /// <summary>
    /// Generate a batch ID for grouping multiple operations from one user action.
    /// </summary>
    public static string NewBatchId()
    {
        return Guid.NewGuid().ToString();
    }

    /// <summary>
    /// Get the current user name safely.
    /// </summary>
    private static string CurrentUser
    {
        get
        {
            try
            {
                if (HttpContext.Current != null && HttpContext.Current.User != null &&
                    HttpContext.Current.User.Identity != null)
                    return HttpContext.Current.User.Identity.Name ?? "UNKNOWN";
            }
            catch { }
            return "UNKNOWN";
        }
    }

    /// <summary>
    /// Get the client IP address safely.
    /// </summary>
    private static string ClientIP
    {
        get
        {
            try
            {
                if (HttpContext.Current == null) return null;
                string ip = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
                if (string.IsNullOrEmpty(ip))
                    ip = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
                else
                    ip = ip.Split(',')[0].Trim();
                if (ip == "::1") ip = "127.0.0.1";
                return ip;
            }
            catch { return null; }
        }
    }

    // ─────────────────────────────────────────────────
    //  SNAPSHOT HELPERS — read current row before change
    // ─────────────────────────────────────────────────

    /// <summary>
    /// Snapshot a row from acad_examresults_faculty before UPDATE/DELETE.
    /// Returns null if row not found.
    /// </summary>
    public static DataRow SnapshotFaculty(MySqlConnection conn, int id)
    {
        try
        {
            string sql = @"SELECT ID, regno, course_id, acadyear, semester, progid,
                cw_mark_entered, cw_mark, test_mark_entered, test_mark,
                exam_mark_entered, ex_mark, total_mark, grade, gradept, approved_by
                FROM acad_examresults_faculty WHERE ID = @id";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var adapter = new MySqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt.Rows.Count > 0 ? dt.Rows[0] : null;
                }
            }
        }
        catch { return null; }
    }

    /// <summary>
    /// Snapshot a row from acad_results before UPDATE/DELETE.
    /// Returns null if row not found.
    /// </summary>
    public static DataRow SnapshotResults(MySqlConnection conn, int id)
    {
        try
        {
            string sql = @"SELECT ID, regno, courseid, acad, semester, studyyear, progid,
                score, grade, gradept, gpa, CreditUnits, result_comment
                FROM acad_results WHERE ID = @id";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var adapter = new MySqlDataAdapter(cmd))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt.Rows.Count > 0 ? dt.Rows[0] : null;
                }
            }
        }
        catch { return null; }
    }

    // ─────────────────────────────────────────────────
    //  CORE LOGGING METHOD
    // ─────────────────────────────────────────────────

    /// <summary>
    /// Write a single audit record to acad_marks_audit.
    /// All parameters except actionType, targetTable, targetId, regno, courseId, sourcePage are optional.
    /// This method NEVER throws — logging must not break the main operation.
    /// </summary>
    public static void Log(
        string actionType,
        string targetTable,
        int targetId,
        string regno,
        string courseId,
        string acadYear,
        int? semester,
        string progid,
        string fieldChanged,
        string oldValue,
        string newValue,
        int? oldCw, int? newCw,
        int? oldTest, int? newTest,
        int? oldExam, int? newExam,
        int? oldTotal, int? newTotal,
        string oldGrade, string newGrade,
        string oldApprovedBy, string newApprovedBy,
        string changeReason,
        string sourcePage,
        string batchId = null,
        string overrideUser = null)
    {
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"INSERT INTO acad_marks_audit
                    (action_type, performed_by, ip_address, target_table, target_id,
                     regno, course_id, acad_year, semester, progid,
                     field_changed, old_value, new_value,
                     old_cw_mark, new_cw_mark, old_test_mark, new_test_mark,
                     old_exam_mark, new_exam_mark, old_total, new_total,
                     old_grade, new_grade, old_approved_by, new_approved_by,
                     change_reason, source_page, batch_id)
                    VALUES
                    (@action, @user, @ip, @table, @tid,
                     @reg, @course, @acad, @sem, @prog,
                     @field, @oldv, @newv,
                     @ocw, @ncw, @otest, @ntest,
                     @oexam, @nexam, @ototal, @ntotal,
                     @ograde, @ngrade, @oapproved, @napproved,
                     @reason, @source, @batch)";

                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@action", Truncate(actionType, 15));
                    cmd.Parameters.AddWithValue("@user", Truncate(overrideUser ?? CurrentUser, 50));
                    cmd.Parameters.AddWithValue("@ip", (object)Truncate(ClientIP, 45) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@table", Truncate(targetTable, 30));
                    cmd.Parameters.AddWithValue("@tid", targetId);
                    cmd.Parameters.AddWithValue("@reg", Truncate(regno ?? "", 50));
                    cmd.Parameters.AddWithValue("@course", Truncate(courseId ?? "", 25));
                    cmd.Parameters.AddWithValue("@acad", (object)Truncate(acadYear, 25) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@sem", semester.HasValue ? (object)semester.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@prog", (object)Truncate(progid, 25) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@field", (object)Truncate(fieldChanged, 50) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@oldv", (object)Truncate(oldValue, 200) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@newv", (object)Truncate(newValue, 200) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ocw", oldCw.HasValue ? (object)oldCw.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ncw", newCw.HasValue ? (object)newCw.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@otest", oldTest.HasValue ? (object)oldTest.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ntest", newTest.HasValue ? (object)newTest.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@oexam", oldExam.HasValue ? (object)oldExam.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@nexam", newExam.HasValue ? (object)newExam.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ototal", oldTotal.HasValue ? (object)oldTotal.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ntotal", newTotal.HasValue ? (object)newTotal.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ograde", (object)Truncate(oldGrade, 5) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ngrade", (object)Truncate(newGrade, 5) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@oapproved", (object)Truncate(oldApprovedBy, 25) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@napproved", (object)Truncate(newApprovedBy, 25) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@reason", (object)Truncate(changeReason, 200) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@source", Truncate(sourcePage, 100));
                    cmd.Parameters.AddWithValue("@batch", (object)batchId ?? DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch
        {
            // NEVER let audit logging break the main operation
        }
    }

    // ─────────────────────────────────────────────────
    //  HIGH-LEVEL CONVENIENCE METHODS
    // ─────────────────────────────────────────────────

    /// <summary>
    /// Log a mark UPDATE on acad_examresults_faculty using a pre-taken snapshot.
    /// </summary>
    public static void LogFacultyUpdate(DataRow oldSnap,
        int newCwEntered, int newTestEntered, int newExamEntered,
        int newCwMark, int newTestMark, int newExamMark,
        int newTotal, string newGrade, string sourcePage,
        string changeReason = null, string batchId = null)
    {
        if (oldSnap == null) return;

        int id = Convert.ToInt32(oldSnap["ID"]);
        string regno = oldSnap["regno"].ToString();
        string courseId = oldSnap["course_id"].ToString();
        string acadYear = oldSnap["acadyear"].ToString();
        int sem = Convert.ToInt32(oldSnap["semester"]);
        string progid = oldSnap["progid"].ToString();

        int oldCw = ToInt(oldSnap["cw_mark_entered"]);
        int oldTest = ToInt(oldSnap["test_mark_entered"]);
        int oldExam = ToInt(oldSnap["exam_mark_entered"]);
        int oldCwMark = ToInt(oldSnap["cw_mark"]);
        int oldTestMark = ToInt(oldSnap["test_mark"]);
        int oldExamMark = ToInt(oldSnap["ex_mark"]);
        int oldTotal = ToInt(oldSnap["total_mark"]);
        string oldGrade = oldSnap["grade"].ToString();

        // Build summary: "CW:30→35, Exam:40→55, Total:70→90, Grade:B→A"
        var changes = new System.Collections.Generic.List<string>();
        if (oldCw != newCwEntered) changes.Add("CW:" + oldCw + "→" + newCwEntered);
        if (oldTest != newTestEntered) changes.Add("Test:" + oldTest + "→" + newTestEntered);
        if (oldExam != newExamEntered) changes.Add("Exam:" + oldExam + "→" + newExamEntered);
        if (oldTotal != newTotal) changes.Add("Total:" + oldTotal + "→" + newTotal);
        if (oldGrade != newGrade) changes.Add("Grade:" + oldGrade + "→" + newGrade);
        string summary = changes.Count > 0 ? string.Join(", ", changes.ToArray()) : "No change";

        Log("UPDATE", "acad_examresults_faculty", id,
            regno, courseId, acadYear, sem, progid,
            "ALL", summary, null,
            oldCwMark, newCwMark, oldTestMark, newTestMark,
            oldExamMark, newExamMark, oldTotal, newTotal,
            oldGrade, newGrade,
            oldSnap["approved_by"].ToString(), oldSnap["approved_by"].ToString(),
            changeReason, sourcePage, batchId);
    }

    /// <summary>
    /// Log a DELETE on acad_examresults_faculty using a pre-taken snapshot.
    /// The snapshot captures everything that was destroyed.
    /// </summary>
    public static void LogFacultyDelete(DataRow oldSnap, string sourcePage,
        string changeReason = null, string batchId = null)
    {
        if (oldSnap == null) return;

        int id = Convert.ToInt32(oldSnap["ID"]);
        string regno = oldSnap["regno"].ToString();
        string courseId = oldSnap["course_id"].ToString();
        string acadYear = oldSnap["acadyear"].ToString();
        int sem = Convert.ToInt32(oldSnap["semester"]);
        string progid = oldSnap["progid"].ToString();

        int oldCw = ToInt(oldSnap["cw_mark_entered"]);
        int oldTest = ToInt(oldSnap["test_mark_entered"]);
        int oldExam = ToInt(oldSnap["exam_mark_entered"]);
        int oldTotal = ToInt(oldSnap["total_mark"]);
        string oldGrade = oldSnap["grade"].ToString();
        string oldApproved = oldSnap["approved_by"].ToString();

        string summary = string.Format("CW:{0} Test:{1} Exam:{2} Total:{3} Grade:{4}",
            oldCw, oldTest, oldExam, oldTotal, oldGrade);

        Log("DELETE", "acad_examresults_faculty", id,
            regno, courseId, acadYear, sem, progid,
            "ALL", summary, null,
            oldCw, null, oldTest, null, oldExam, null, oldTotal, null,
            oldGrade, null, oldApproved, null,
            changeReason, sourcePage, batchId);
    }

    /// <summary>
    /// Log an APPROVE or UNAPPROVE on acad_examresults_faculty.
    /// </summary>
    public static void LogFacultyApproval(string actionType, int targetId,
        string regno, string courseId, string acadYear, int? semester, string progid,
        string oldApprovedBy, string newApprovedBy,
        string sourcePage, string batchId = null)
    {
        string summary = string.Format("{0} → {1}", oldApprovedBy ?? "-", newApprovedBy ?? "-");

        Log(actionType, "acad_examresults_faculty", targetId,
            regno, courseId, acadYear, semester, progid,
            "approved_by", oldApprovedBy, newApprovedBy,
            null, null, null, null, null, null, null, null, null, null,
            oldApprovedBy, newApprovedBy,
            null, sourcePage, batchId);
    }

    /// <summary>
    /// Log a HOLD or RELEASE (bulk approval change).
    /// Uses snapshot to capture current state.
    /// </summary>
    public static void LogFacultyBulkApproval(MySqlConnection conn, string actionType,
        string courseId, string progid, string acadYear, int semester,
        string newApprovedBy, int affectedCount,
        string sourcePage, string batchId = null)
    {
        // For bulk operations, log a single summary record with target_id=0
        string summary = string.Format("{0} {1} results: {2}, {3}, {4}/{5} S{6}",
            actionType, affectedCount, courseId, progid, acadYear, "", semester);

        Log(actionType, "acad_examresults_faculty", 0,
            "", courseId, acadYear, semester, progid,
            "approved_by", null, newApprovedBy,
            null, null, null, null, null, null, null, null, null, null,
            null, newApprovedBy,
            summary, sourcePage, batchId);
    }

    /// <summary>
    /// Log a DELETE on acad_results using a pre-taken snapshot.
    /// </summary>
    public static void LogResultsDelete(DataRow oldSnap, string sourcePage,
        string changeReason = null, string batchId = null)
    {
        if (oldSnap == null) return;

        int id = Convert.ToInt32(oldSnap["ID"]);
        string regno = oldSnap["regno"].ToString();
        string courseId = oldSnap["courseid"].ToString();
        string acadYear = oldSnap["acad"].ToString();
        int sem = Convert.ToInt32(oldSnap["semester"]);
        string progid = oldSnap["progid"].ToString();
        int oldScore = ToInt(oldSnap["score"]);
        string oldGrade = oldSnap["grade"].ToString();

        string summary = string.Format("Score:{0} Grade:{1}", oldScore, oldGrade);

        Log("DELETE", "acad_results", id,
            regno, courseId, acadYear, sem, progid,
            "ALL", summary, null,
            null, null, null, null, null, null, oldScore, null,
            oldGrade, null, null, null,
            changeReason, sourcePage, batchId);
    }

    /// <summary>
    /// Log an UPDATE on acad_results using a pre-taken snapshot.
    /// </summary>
    public static void LogResultsUpdate(DataRow oldSnap,
        int newScore, string newGrade, string sourcePage,
        string changeReason = null, string batchId = null)
    {
        if (oldSnap == null) return;

        int id = Convert.ToInt32(oldSnap["ID"]);
        string regno = oldSnap["regno"].ToString();
        string courseId = oldSnap["courseid"].ToString();
        string acadYear = oldSnap["acad"].ToString();
        int sem = Convert.ToInt32(oldSnap["semester"]);
        string progid = oldSnap["progid"].ToString();
        int oldScore = ToInt(oldSnap["score"]);
        string oldGrade = oldSnap["grade"].ToString();

        string summary = string.Format("Score:{0}→{1}, Grade:{2}→{3}",
            oldScore, newScore, oldGrade, newGrade);

        Log("UPDATE", "acad_results", id,
            regno, courseId, acadYear, sem, progid,
            "ALL", summary, null,
            null, null, null, null, null, null, oldScore, newScore,
            oldGrade, newGrade, null, null,
            changeReason, sourcePage, batchId);
    }

    // ─────────────────────────────────────────────────
    //  PRIVATE UTILITIES
    // ─────────────────────────────────────────────────

    private static int ToInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int result;
        return int.TryParse(val.ToString(), out result) ? result : 0;
    }

    private static string Truncate(string s, int max)
    {
        if (s == null) return null;
        return s.Length <= max ? s : s.Substring(0, max);
    }
}
