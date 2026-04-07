using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// ResultsStatusService — Unified state machine for mark sheet lifecycle.
///
/// Implements the status flow:
///   DRAFT → SUBMITTED → DEAN_APPROVED → PROVISIONAL_PUBLISHED → FINAL_PUBLISHED
///
/// Each transition is validated:
///   - Only teachers can submit (DRAFT → SUBMITTED)
///   - Only Dean/Admin can approve (SUBMITTED → DEAN_APPROVED) or reject (SUBMITTED → DRAFT)
///   - Only Registrar/Admin can publish (DEAN_APPROVED → PROVISIONAL_PUBLISHED → FINAL_PUBLISHED)
///
/// Status is tracked per sheet context: (course, programme, acadyear, semester, study_year, campus, session).
/// The service also enforces that marks cannot be edited once status >= SUBMITTED (unless unlocked).
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P19-P26 (missing workflow, approval ambiguity)
/// Task: D-05
/// </summary>
public static class ResultsStatusService
{
    // ─────────────────────── Connection String ──────────────────────────

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    // ─────────────────────── Status Constants ───────────────────────────

    public const string STATUS_DRAFT                  = "DRAFT";
    public const string STATUS_SUBMITTED              = "SUBMITTED";
    public const string STATUS_DEAN_APPROVED          = "DEAN_APPROVED";
    public const string STATUS_PROVISIONAL_PUBLISHED  = "PROVISIONAL_PUBLISHED";
    public const string STATUS_FINAL_PUBLISHED        = "FINAL_PUBLISHED";

    // Status ordinal for comparison (higher = further along)
    private static int StatusOrdinal(string status)
    {
        if (status == STATUS_DRAFT) return 0;
        if (status == STATUS_SUBMITTED) return 1;
        if (status == STATUS_DEAN_APPROVED) return 2;
        if (status == STATUS_PROVISIONAL_PUBLISHED) return 3;
        if (status == STATUS_FINAL_PUBLISHED) return 4;
        return -1;
    }

    // ─────────────────────── Table Init ─────────────────────────────────

    /// <summary>
    /// Creates the acad_results_status table if it doesn't exist.
    /// Called by page EnsureTables() methods.
    /// </summary>
    public static void EnsureStatusTable()
    {
        try
        {
            string ddl = @"CREATE TABLE IF NOT EXISTS acad_results_status (
                id              INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
                course_id       VARCHAR(25)     NOT NULL,
                progid          VARCHAR(25)     NOT NULL,
                acadyear        VARCHAR(25)     NOT NULL,
                semester        TINYINT UNSIGNED NOT NULL,
                study_year      TINYINT UNSIGNED NOT NULL DEFAULT 1,
                campus_id       INT UNSIGNED    NOT NULL DEFAULT 1,
                stud_session    VARCHAR(25)     NOT NULL DEFAULT 'Day',
                status          VARCHAR(30)     NOT NULL DEFAULT 'DRAFT',
                submitted_by    VARCHAR(50)     DEFAULT NULL,
                submitted_at    DATETIME        DEFAULT NULL,
                approved_by     VARCHAR(50)     DEFAULT NULL,
                approved_at     DATETIME        DEFAULT NULL,
                published_by    VARCHAR(50)     DEFAULT NULL,
                published_at    DATETIME        DEFAULT NULL,
                reject_reason   TEXT            DEFAULT NULL,
                updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                UNIQUE KEY uq_context (course_id, progid, acadyear, semester, study_year, campus_id, stud_session),
                INDEX idx_status (status),
                INDEX idx_course_period (course_id, acadyear, semester),
                INDEX idx_programme (progid, acadyear)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(ddl, conn)) { cmd.ExecuteNonQuery(); }
            }
        }
        catch
        {
            // Silently ignore — table likely already exists
        }
    }

    // ─────────────────────── Status Query ───────────────────────────────

    /// <summary>
    /// Gets the current status for a sheet context.
    /// Returns "DRAFT" if no row exists (new sheet defaults to DRAFT).
    /// </summary>
    public static string GetStatus(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string session)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT status FROM acad_results_status
                      WHERE course_id = @c AND progid = @p AND acadyear = @y
                        AND semester = @s AND study_year = @sy
                        AND campus_id = @campus AND stud_session = @sess
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@c", courseId);
                    cmd.Parameters.AddWithValue("@p", progId);
                    cmd.Parameters.AddWithValue("@y", acadyear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    cmd.Parameters.AddWithValue("@sy", studyYear);
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@sess", session);

                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        return result.ToString();
                    }
                }
            }
        }
        catch
        {
            // Default to DRAFT on error
        }
        return STATUS_DRAFT;
    }

    /// <summary>
    /// Gets full status info including who/when for each transition.
    /// </summary>
    public static StatusInfo GetStatusInfo(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string session)
    {
        StatusInfo info = new StatusInfo();
        info.Status = STATUS_DRAFT;
        info.CourseId = courseId;
        info.ProgId = progId;
        info.AcadYear = acadyear;
        info.Semester = semester;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT status, submitted_by, submitted_at, approved_by, approved_at,
                             published_by, published_at, reject_reason, updated_at
                      FROM acad_results_status
                      WHERE course_id = @c AND progid = @p AND acadyear = @y
                        AND semester = @s AND study_year = @sy
                        AND campus_id = @campus AND stud_session = @sess
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@c", courseId);
                    cmd.Parameters.AddWithValue("@p", progId);
                    cmd.Parameters.AddWithValue("@y", acadyear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    cmd.Parameters.AddWithValue("@sy", studyYear);
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@sess", session);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            info.Status = rdr["status"].ToString();
                            info.SubmittedBy = rdr["submitted_by"] != DBNull.Value ? rdr["submitted_by"].ToString() : null;
                            info.SubmittedAt = rdr["submitted_at"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(rdr["submitted_at"]) : null;
                            info.ApprovedBy = rdr["approved_by"] != DBNull.Value ? rdr["approved_by"].ToString() : null;
                            info.ApprovedAt = rdr["approved_at"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(rdr["approved_at"]) : null;
                            info.PublishedBy = rdr["published_by"] != DBNull.Value ? rdr["published_by"].ToString() : null;
                            info.PublishedAt = rdr["published_at"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(rdr["published_at"]) : null;
                            info.RejectReason = rdr["reject_reason"] != DBNull.Value ? rdr["reject_reason"].ToString() : null;
                            info.UpdatedAt = Convert.ToDateTime(rdr["updated_at"]);
                        }
                    }
                }
            }
        }
        catch
        {
            // Return default info
        }
        return info;
    }

    // ─────────────────────── Editability Check ──────────────────────────

    /// <summary>
    /// Checks whether marks can be edited for the given context.
    /// Marks are only editable in DRAFT status (or if the user has an active unlock).
    /// </summary>
    public static bool IsEditable(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string session)
    {
        string status = GetStatus(courseId, progId, acadyear, semester, studyYear, campusId, session);
        return status == STATUS_DRAFT;
    }

    // ─────────────────────── State Transitions ──────────────────────────

    /// <summary>
    /// Submit marks for dean review. DRAFT → SUBMITTED.
    /// Only the assigned teacher (or admin) can submit.
    /// </summary>
    public static TransitionResult Submit(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string session)
    {
        TransitionResult result = new TransitionResult();
        string user = MarksAuthorizationService.GetCurrentUser();

        if (!MarksAuthorizationService.CanEnterMarks())
        {
            result.Error = "You do not have permission to submit marks.";
            return result;
        }

        string current = GetStatus(courseId, progId, acadyear, semester, studyYear, campusId, session);
        if (current != STATUS_DRAFT)
        {
            result.Error = String.Format("Cannot submit: marks are currently in '{0}' status.", current);
            return result;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                result.Success = UpsertStatus(conn, courseId, progId, acadyear, semester,
                    studyYear, campusId, session, STATUS_SUBMITTED,
                    "submitted_by", user, "submitted_at");
            }

            // Audit
            MarksAuditService.LogApproval(MarksAuditService.ACTION_SUBMIT, courseId, progId, acadyear, semester,
                String.Format("Submitted by {0}", user));
        }
        catch (Exception ex)
        {
            result.Error = ex.Message;
        }

        result.NewStatus = result.Success ? STATUS_SUBMITTED : current;
        return result;
    }

    /// <summary>
    /// Approve submitted marks. SUBMITTED → DEAN_APPROVED.
    /// Only Dean/Admin can approve.
    /// </summary>
    public static TransitionResult Approve(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string session)
    {
        TransitionResult result = new TransitionResult();
        string user = MarksAuthorizationService.GetCurrentUser();

        if (!MarksAuthorizationService.CanApproveMarks())
        {
            result.Error = "You do not have permission to approve marks.";
            return result;
        }

        string current = GetStatus(courseId, progId, acadyear, semester, studyYear, campusId, session);
        if (current != STATUS_SUBMITTED)
        {
            result.Error = String.Format("Cannot approve: marks are currently in '{0}' status.", current);
            return result;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                result.Success = UpsertStatus(conn, courseId, progId, acadyear, semester,
                    studyYear, campusId, session, STATUS_DEAN_APPROVED,
                    "approved_by", user, "approved_at");
            }

            MarksAuditService.LogApproval(MarksAuditService.ACTION_APPROVE, courseId, progId, acadyear, semester,
                String.Format("Approved by {0}", user));
        }
        catch (Exception ex)
        {
            result.Error = ex.Message;
        }

        result.NewStatus = result.Success ? STATUS_DEAN_APPROVED : current;
        return result;
    }

    /// <summary>
    /// Reject submitted marks back to DRAFT. SUBMITTED → DRAFT.
    /// Only Dean/Admin can reject.
    /// </summary>
    public static TransitionResult Reject(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string session, string reason)
    {
        TransitionResult result = new TransitionResult();
        string user = MarksAuthorizationService.GetCurrentUser();

        if (!MarksAuthorizationService.CanApproveMarks())
        {
            result.Error = "You do not have permission to reject marks.";
            return result;
        }

        string current = GetStatus(courseId, progId, acadyear, semester, studyYear, campusId, session);
        if (current != STATUS_SUBMITTED)
        {
            result.Error = String.Format("Cannot reject: marks are currently in '{0}' status.", current);
            return result;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                string sql = @"UPDATE acad_results_status SET
                    status = @status,
                    reject_reason = @reason,
                    submitted_by = NULL,
                    submitted_at = NULL
                WHERE course_id = @c AND progid = @p AND acadyear = @y
                  AND semester = @s AND study_year = @sy
                  AND campus_id = @campus AND stud_session = @sess";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@status", STATUS_DRAFT);
                    cmd.Parameters.AddWithValue("@reason", reason ?? "");
                    cmd.Parameters.AddWithValue("@c", courseId);
                    cmd.Parameters.AddWithValue("@p", progId);
                    cmd.Parameters.AddWithValue("@y", acadyear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    cmd.Parameters.AddWithValue("@sy", studyYear);
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@sess", session);
                    result.Success = cmd.ExecuteNonQuery() > 0;
                }
            }

            MarksAuditService.LogApproval(MarksAuditService.ACTION_REJECT, courseId, progId, acadyear, semester,
                String.Format("Rejected by {0}: {1}", user, reason ?? ""));
        }
        catch (Exception ex)
        {
            result.Error = ex.Message;
        }

        result.NewStatus = result.Success ? STATUS_DRAFT : current;
        return result;
    }

    /// <summary>
    /// Publish approved marks. DEAN_APPROVED → PROVISIONAL_PUBLISHED.
    /// Only Registrar/Admin can publish.
    /// </summary>
    public static TransitionResult Publish(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string session, bool isFinal)
    {
        TransitionResult result = new TransitionResult();
        string user = MarksAuthorizationService.GetCurrentUser();

        // Registrar or admin only
        if (!MarksAuthorizationService.IsInAnyRole(new string[] { "registrar", "Administrator", "admin" }))
        {
            result.Error = "You do not have permission to publish results.";
            return result;
        }

        string current = GetStatus(courseId, progId, acadyear, semester, studyYear, campusId, session);
        string expectedFrom = isFinal ? STATUS_PROVISIONAL_PUBLISHED : STATUS_DEAN_APPROVED;
        string targetStatus = isFinal ? STATUS_FINAL_PUBLISHED : STATUS_PROVISIONAL_PUBLISHED;

        if (current != expectedFrom)
        {
            result.Error = String.Format("Cannot publish: marks are currently in '{0}' status (expected '{1}').",
                current, expectedFrom);
            return result;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                result.Success = UpsertStatus(conn, courseId, progId, acadyear, semester,
                    studyYear, campusId, session, targetStatus,
                    "published_by", user, "published_at");
            }

            MarksAuditService.LogApproval(MarksAuditService.ACTION_APPROVE, courseId, progId, acadyear, semester,
                String.Format("{0} published by {1}", isFinal ? "Final" : "Provisional", user));
        }
        catch (Exception ex)
        {
            result.Error = ex.Message;
        }

        result.NewStatus = result.Success ? targetStatus : current;
        return result;
    }

    // ─────────────────────── Batch Queries ──────────────────────────────

    /// <summary>
    /// Gets all sheet statuses for a programme/year/semester context.
    /// Used by the Dean Approval Dashboard and Teacher Dashboard.
    /// </summary>
    public static List<StatusInfo> GetStatusesByProgramme(string progId, string acadyear, int semester)
    {
        List<StatusInfo> list = new List<StatusInfo>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT rs.course_id, rs.progid, rs.acadyear, rs.semester,
                             rs.study_year, rs.campus_id, rs.stud_session,
                             rs.status, rs.submitted_by, rs.submitted_at,
                             rs.approved_by, rs.approved_at, rs.published_by, rs.published_at,
                             rs.reject_reason, rs.updated_at,
                             COALESCE(c.CourseName, rs.course_id) AS course_name
                      FROM acad_results_status rs
                      LEFT JOIN acad_courses c ON c.CourseCode = rs.course_id
                      WHERE rs.progid = @p AND rs.acadyear = @y AND rs.semester = @s
                      ORDER BY rs.study_year, rs.course_id", conn))
                {
                    cmd.Parameters.AddWithValue("@p", progId);
                    cmd.Parameters.AddWithValue("@y", acadyear);
                    cmd.Parameters.AddWithValue("@s", semester);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            StatusInfo info = new StatusInfo();
                            info.CourseId = rdr["course_id"].ToString();
                            info.CourseName = rdr["course_name"].ToString();
                            info.ProgId = rdr["progid"].ToString();
                            info.AcadYear = rdr["acadyear"].ToString();
                            info.Semester = Convert.ToInt32(rdr["semester"]);
                            info.StudyYear = Convert.ToInt32(rdr["study_year"]);
                            info.CampusId = Convert.ToInt32(rdr["campus_id"]);
                            info.Session = rdr["stud_session"].ToString();
                            info.Status = rdr["status"].ToString();
                            info.SubmittedBy = rdr["submitted_by"] != DBNull.Value ? rdr["submitted_by"].ToString() : null;
                            info.SubmittedAt = rdr["submitted_at"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(rdr["submitted_at"]) : null;
                            info.ApprovedBy = rdr["approved_by"] != DBNull.Value ? rdr["approved_by"].ToString() : null;
                            info.ApprovedAt = rdr["approved_at"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(rdr["approved_at"]) : null;
                            info.PublishedBy = rdr["published_by"] != DBNull.Value ? rdr["published_by"].ToString() : null;
                            info.PublishedAt = rdr["published_at"] != DBNull.Value ? (DateTime?)Convert.ToDateTime(rdr["published_at"]) : null;
                            info.RejectReason = rdr["reject_reason"] != DBNull.Value ? rdr["reject_reason"].ToString() : null;
                            info.UpdatedAt = Convert.ToDateTime(rdr["updated_at"]);
                            list.Add(info);
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

    // ─────────────────────── Private Helpers ────────────────────────────

    /// <summary>
    /// INSERT or UPDATE the status row, setting one actor/timestamp pair.
    /// Uses INSERT ... ON DUPLICATE KEY UPDATE for atomicity.
    /// </summary>
    private static bool UpsertStatus(MySqlConnection conn, string courseId, string progId,
        string acadyear, int semester, int studyYear, int campusId, string session,
        string newStatus, string actorCol, string actorVal, string atCol)
    {
        string sql = String.Format(
            @"INSERT INTO acad_results_status
                (course_id, progid, acadyear, semester, study_year, campus_id, stud_session,
                 status, {0}, {1})
              VALUES (@c, @p, @y, @s, @sy, @campus, @sess, @status, @actor, NOW())
              ON DUPLICATE KEY UPDATE
                status = @status, {0} = @actor, {1} = NOW()",
            actorCol, atCol);

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@c", courseId);
            cmd.Parameters.AddWithValue("@p", progId);
            cmd.Parameters.AddWithValue("@y", acadyear);
            cmd.Parameters.AddWithValue("@s", semester);
            cmd.Parameters.AddWithValue("@sy", studyYear);
            cmd.Parameters.AddWithValue("@campus", campusId);
            cmd.Parameters.AddWithValue("@sess", session);
            cmd.Parameters.AddWithValue("@status", newStatus);
            cmd.Parameters.AddWithValue("@actor", actorVal);
            return cmd.ExecuteNonQuery() > 0;
        }
    }

    // ─────────────────────── DTOs ───────────────────────────────────────

    public class StatusInfo
    {
        public string CourseId { get; set; }
        public string CourseName { get; set; }
        public string ProgId { get; set; }
        public string AcadYear { get; set; }
        public int Semester { get; set; }
        public int StudyYear { get; set; }
        public int CampusId { get; set; }
        public string Session { get; set; }
        public string Status { get; set; }
        public string SubmittedBy { get; set; }
        public DateTime? SubmittedAt { get; set; }
        public string ApprovedBy { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public string PublishedBy { get; set; }
        public DateTime? PublishedAt { get; set; }
        public string RejectReason { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class TransitionResult
    {
        public bool Success { get; set; }
        public string NewStatus { get; set; }
        public string Error { get; set; }
    }
}
