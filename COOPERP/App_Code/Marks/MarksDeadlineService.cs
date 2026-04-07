using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksDeadlineService — Centralized deadline checking and management for the marks module.
/// 
/// Provides:
///   - Deadline lock checking per type (COURSEWORK, EXAM, SUBMISSION).
///   - Countdown calculation for UI banners.
///   - Unlock window validation (checks for approved unlock requests).
///   - Active deadline listing for the Deadline Manager UI.
///
/// Consolidates locking logic that was previously split across acad_results_lock
/// (global) and acad_deadlines (per-campus). The new approach uses acad_deadlines
/// exclusively, with the added deadline_type and is_active columns (B-04).
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P27, P28, P29, P33 (deadline/lock gaps)
/// Task: D-02
/// </summary>
public static class MarksDeadlineService
{
    // ─────────────────────── Connection String ──────────────────────────

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    // ─────────────────────── Lock Checking ──────────────────────────────

    /// <summary>
    /// Checks whether a specific deadline type is locked for the given context.
    /// Returns true if the deadline has passed AND is active AND no valid unlock exists.
    /// 
    /// Falls back to the legacy acad_results_lock check if no acad_deadlines row found,
    /// ensuring backward compatibility during the migration period.
    /// </summary>
    public static bool IsLocked(string deadlineType, int campusId, string acadyear, int semester, string studSession)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // First, check acad_deadlines for a typed deadline
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT deadline 
                      FROM acad_deadlines
                      WHERE deadline_type = @dtype
                        AND campusid = @campus
                        AND acadyear = @year
                        AND semester = @sem
                        AND studsession = @sess
                        AND is_active = 1
                      ORDER BY deadline DESC
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@dtype", deadlineType);
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    cmd.Parameters.AddWithValue("@sess", studSession);

                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        DateTime deadline = Convert.ToDateTime(result);
                        if (DateTime.Now > deadline)
                        {
                            // Deadline has passed — check for active unlock
                            return !HasActiveUnlock(conn, deadlineType, acadyear, semester);
                        }
                        return false; // deadline not yet reached
                    }
                }

                // Fallback: legacy global lock check (acad_results_lock)
                using (MySqlCommand cmd2 = new MySqlCommand(
                    @"SELECT COUNT(*) FROM acad_results_lock 
                      WHERE lock_type = 'RESULTS_DEADLINE' 
                        AND is_active = 1 
                        AND CURDATE() > deadline_date", conn))
                {
                    return Convert.ToInt32(cmd2.ExecuteScalar()) > 0;
                }
            }
        }
        catch
        {
            return false; // fail-open: don't block entry on error
        }
    }

    /// <summary>
    /// Simplified lock check when campus/session context is not available.
    /// Checks the global lock only.
    /// </summary>
    public static bool IsGloballyLocked()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT COUNT(*) FROM acad_results_lock 
                      WHERE lock_type = 'RESULTS_DEADLINE' 
                        AND is_active = 1 
                        AND CURDATE() > deadline_date", conn))
                {
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }
        catch
        {
            return false;
        }
    }

    // ─────────────────────── Unlock Window Check ────────────────────────

    /// <summary>
    /// Checks if the current user has an active (approved, not expired) unlock request
    /// for the given deadline type and period.
    /// </summary>
    private static bool HasActiveUnlock(MySqlConnection conn, string deadlineType, string acadyear, int semester)
    {
        string user = MarksAuthorizationService.GetCurrentUser();
        if (user == "Unknown") return false;

        try
        {
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT COUNT(*) FROM acad_mark_unlock_requests
                  WHERE requested_by = @user
                    AND deadline_type = @dtype
                    AND acadyear = @year
                    AND semester = @sem
                    AND status = 'APPROVED'
                    AND expires_at > NOW()", conn))
            {
                cmd.Parameters.AddWithValue("@user", user);
                cmd.Parameters.AddWithValue("@dtype", deadlineType);
                cmd.Parameters.AddWithValue("@year", acadyear);
                cmd.Parameters.AddWithValue("@sem", semester);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
        catch
        {
            return false;
        }
    }

    // ─────────────────────── Countdown Info ─────────────────────────────

    /// <summary>
    /// Returns deadline information for UI display — the deadline date and days remaining.
    /// Returns null if no deadline is configured for this context.
    /// </summary>
    public static DeadlineInfo GetDeadlineInfo(string deadlineType, int campusId, string acadyear, int semester, string studSession)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT deadline, ActivityName
                      FROM acad_deadlines
                      WHERE deadline_type = @dtype
                        AND campusid = @campus
                        AND acadyear = @year
                        AND semester = @sem
                        AND studsession = @sess
                        AND is_active = 1
                      ORDER BY deadline DESC
                      LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@dtype", deadlineType);
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    cmd.Parameters.AddWithValue("@sess", studSession);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            DeadlineInfo info = new DeadlineInfo();
                            info.DeadlineDate = Convert.ToDateTime(rdr["deadline"]);
                            info.ActivityName = rdr["ActivityName"].ToString();
                            info.DeadlineType = deadlineType;
                            info.DaysRemaining = (int)(info.DeadlineDate - DateTime.Now).TotalDays;
                            info.IsExpired = DateTime.Now > info.DeadlineDate;
                            return info;
                        }
                    }
                }
            }
        }
        catch
        {
            // Return null on error
        }
        return null;
    }

    /// <summary>
    /// Returns all active deadlines for a given context, useful for the Deadline Manager.
    /// </summary>
    public static List<DeadlineInfo> GetAllDeadlines(int campusId, string acadyear, int semester, string studSession)
    {
        List<DeadlineInfo> list = new List<DeadlineInfo>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT deadline, ActivityName, deadline_type, is_active,
                             campusid, semester, studsession, acadyear
                      FROM acad_deadlines
                      WHERE campusid = @campus
                        AND acadyear = @year
                        AND semester = @sem
                        AND studsession = @sess
                      ORDER BY deadline_type, deadline", conn))
                {
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    cmd.Parameters.AddWithValue("@sess", studSession);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            DeadlineInfo info = new DeadlineInfo();
                            info.DeadlineDate = Convert.ToDateTime(rdr["deadline"]);
                            info.ActivityName = rdr["ActivityName"].ToString();
                            info.DeadlineType = rdr["deadline_type"].ToString();
                            info.IsActive = Convert.ToInt32(rdr["is_active"]) == 1;
                            info.DaysRemaining = (int)(info.DeadlineDate - DateTime.Now).TotalDays;
                            info.IsExpired = DateTime.Now > info.DeadlineDate;
                            info.CampusId = Convert.ToInt32(rdr["campusid"]);
                            info.Semester = Convert.ToInt32(rdr["semester"]);
                            info.StudSession = rdr["studsession"].ToString();
                            info.AcadYear = rdr["acadyear"].ToString();
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

    // ─────────────────────── Unlock Request Management ──────────────────

    /// <summary>
    /// Gets all pending unlock requests (for Dean/Registrar review).
    /// </summary>
    public static List<UnlockRequest> GetPendingUnlockRequests()
    {
        List<UnlockRequest> list = new List<UnlockRequest>();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT ur.*, 
                             COALESCE(c.CourseName, ur.course_id) AS course_name,
                             COALESCE(p.progname, ur.progid) AS prog_name
                      FROM acad_mark_unlock_requests ur
                      LEFT JOIN acad_courses c ON c.CourseCode = ur.course_id
                      LEFT JOIN acad_programme p ON p.progcode = ur.progid
                      WHERE ur.status = 'PENDING'
                      ORDER BY ur.created_at ASC", conn))
                {
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            UnlockRequest req = new UnlockRequest();
                            req.Id = Convert.ToInt32(rdr["id"]);
                            req.RequestedBy = rdr["requested_by"].ToString();
                            req.CourseId = rdr["course_id"] != DBNull.Value ? rdr["course_id"].ToString() : "";
                            req.ProgId = rdr["progid"] != DBNull.Value ? rdr["progid"].ToString() : "";
                            req.AcadYear = rdr["acadyear"].ToString();
                            req.Semester = Convert.ToInt32(rdr["semester"]);
                            req.DeadlineType = rdr["deadline_type"].ToString();
                            req.Reason = rdr["reason"].ToString();
                            req.Status = rdr["status"].ToString();
                            req.CreatedAt = Convert.ToDateTime(rdr["created_at"]);
                            req.CourseName = rdr["course_name"].ToString();
                            req.ProgName = rdr["prog_name"].ToString();
                            list.Add(req);
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

    // ─────────────────────── DTOs ───────────────────────────────────────

    public class DeadlineInfo
    {
        public DateTime DeadlineDate { get; set; }
        public string ActivityName { get; set; }
        public string DeadlineType { get; set; }
        public int DaysRemaining { get; set; }
        public bool IsExpired { get; set; }
        public bool IsActive { get; set; }
        public int CampusId { get; set; }
        public int Semester { get; set; }
        public string StudSession { get; set; }
        public string AcadYear { get; set; }
    }

    public class UnlockRequest
    {
        public int Id { get; set; }
        public string RequestedBy { get; set; }
        public string CourseId { get; set; }
        public string ProgId { get; set; }
        public string AcadYear { get; set; }
        public int Semester { get; set; }
        public string DeadlineType { get; set; }
        public string Reason { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public string ReviewedBy { get; set; }
        public DateTime ReviewedAt { get; set; }
        public string ReviewNotes { get; set; }
        public DateTime ExpiresAt { get; set; }
        public string CourseName { get; set; }
        public string ProgName { get; set; }
    }
}
