using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksAuthorizationService — Central authorization engine for the marks module.
/// 
/// Enforces two levels of access control:
///   1. Role-based: Only users in allowed roles can perform mark mutations.
///   2. Assignment-based: Teachers can only modify marks for their assigned courses
///      (via acad_teaching_assignments).
///
/// All methods are static and never throw — they return false on failure. Callers
/// decide how to surface authorization failures (JSON error response, redirect, etc.).
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P1, P65, P66, P67 (authorization gaps)
/// Task: C-01
/// </summary>
public static class MarksAuthorizationService
{
    // ─────────────────────── Connection String ──────────────────────────

    private static string ConnStr
    {
        get { return MarksConfiguration.ConnStr; }
    }

    // ─────────────────────── Role Constants ─────────────────────────────

    /// <summary>Roles allowed to enter/edit marks.</summary>
    public static readonly string[] MarkEntryRoles = new string[] { "faculty_staff", "Dean", "Administrator", "admin", "exam_officer" };

    /// <summary>Roles allowed to approve marks (Dean-level).</summary>
    public static readonly string[] ApprovalRoles = new string[] { "Dean", "Administrator", "admin" };

    /// <summary>Roles allowed to manage teaching assignments.</summary>
    public static readonly string[] AssignmentManagementRoles = new string[] { "Dean", "Administrator", "admin", "registrar" };

    /// <summary>Roles allowed to manage deadlines.</summary>
    public static readonly string[] DeadlineManagementRoles = new string[] { "Dean", "Administrator", "admin", "registrar", "exam_officer" };

    /// <summary>Roles allowed to view the audit centre.</summary>
    public static readonly string[] AuditViewRoles = new string[] { "Dean", "Administrator", "admin", "registrar", "exam_officer" };

    /// <summary>Roles allowed to view the operational alert dashboard (Batch 13).</summary>
    public static readonly string[] AlertDashboardRoles = new string[] { "Dean", "Administrator", "admin", "registrar", "exam_officer" };

    // ─────────────────────── Current User ───────────────────────────────

    /// <summary>
    /// Gets the current authenticated username from Session or Identity.
    /// Returns "Unknown" if not determinable.
    /// </summary>
    public static string GetCurrentUser()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null) return "Unknown";

        if (ctx.Session != null && ctx.Session["ScreenName"] != null)
            return ctx.Session["ScreenName"].ToString();
        if (ctx.Session != null && ctx.Session["username"] != null)
            return ctx.Session["username"].ToString();
        if (ctx.User != null && ctx.User.Identity != null && ctx.User.Identity.IsAuthenticated)
            return ctx.User.Identity.Name;
        return "Unknown";
    }

    /// <summary>
    /// Gets the client IP address, preferring X-Forwarded-For first hop.
    /// Sanitizes proxy-spoofed values by accepting only valid IPv4/IPv6.
    /// </summary>
    public static string GetClientIP()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null) return "0.0.0.0";

        string xff = ctx.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];
        if (!string.IsNullOrEmpty(xff))
        {
            // Take only the first address (client's real IP)
            string firstHop = xff.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)[0].Trim();
            System.Net.IPAddress parsed;
            if (System.Net.IPAddress.TryParse(firstHop, out parsed))
            {
                return parsed.ToString();
            }
        }

        string remote = ctx.Request.ServerVariables["REMOTE_ADDR"];
        return string.IsNullOrEmpty(remote) ? "0.0.0.0" : remote;
    }

    // ─────────────────────── Role Checks ────────────────────────────────

    /// <summary>
    /// Returns true if the current user is in at least one of the given roles.
    /// </summary>
    public static bool IsInAnyRole(string[] roles)
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.User == null) return false;

        for (int i = 0; i < roles.Length; i++)
        {
            if (ctx.User.IsInRole(roles[i])) return true;
        }
        return false;
    }

    /// <summary>Returns true if the current user can enter/edit marks.</summary>
    public static bool CanEnterMarks()
    {
        return IsInAnyRole(MarkEntryRoles);
    }

    /// <summary>Returns true if the current user can approve marks (Dean-level).</summary>
    public static bool CanApproveMarks()
    {
        return IsInAnyRole(ApprovalRoles);
    }

    /// <summary>Returns true if the current user can manage teaching assignments.</summary>
    public static bool CanManageAssignments()
    {
        return IsInAnyRole(AssignmentManagementRoles);
    }

    /// <summary>Returns true if the current user can manage deadlines.</summary>
    public static bool CanManageDeadlines()
    {
        return IsInAnyRole(DeadlineManagementRoles);
    }

    /// <summary>Returns true if the current user can view the audit centre.</summary>
    public static bool CanViewAudit()
    {
        return IsInAnyRole(AuditViewRoles);
    }

    /// <summary>Returns true if the current user can view the operational alert dashboard (Batch 13).</summary>
    public static bool CanViewAlertDashboard()
    {
        return IsInAnyRole(AlertDashboardRoles);
    }

    // ─────────────────────── Assignment Checks ──────────────────────────

    /// <summary>
    /// Checks whether the given teacher has an active assignment for the specified
    /// course/programme/year/semester combination. This is the core enforcement
    /// method for P1 (teacher-course assignment enforcement).
    /// 
    /// Dean and Administrator roles bypass assignment checks (they can access all).
    /// </summary>
    public static bool IsAssignedToCourse(string teacherUsername, string courseId, string progid,
        string acadyear, int semester)
    {
        // Dean/Admin bypass — they can access all courses
        if (CanApproveMarks()) return true;

        if (string.IsNullOrEmpty(teacherUsername) || string.IsNullOrEmpty(courseId))
            return false;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT COUNT(*) FROM acad_teaching_assignments
                      WHERE teacher_username = @teacher
                        AND course_id = @course
                        AND progid = @prog
                        AND acadyear = @year
                        AND semester = @sem
                        AND is_active = 1", conn))
                {
                    cmd.Parameters.AddWithValue("@teacher", teacherUsername);
                    cmd.Parameters.AddWithValue("@course", courseId);
                    cmd.Parameters.AddWithValue("@prog", progid);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Returns all active course assignment IDs for a teacher in a given academic period.
    /// Used by the Teacher Dashboard to show "My Courses This Semester".
    /// </summary>
    public static List<TeachingAssignment> GetAssignmentsForTeacher(string teacherUsername, string acadyear, int semester)
    {
        List<TeachingAssignment> list = new List<TeachingAssignment>();

        if (string.IsNullOrEmpty(teacherUsername)) return list;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT ta.id, ta.course_id, ta.progid, ta.study_year, ta.campus_id, ta.stud_session,
                             COALESCE(pc.CourseName, c.CourseName, ta.course_id) AS course_name,
                             COALESCE(p.progname, ta.progid) AS prog_name
                      FROM acad_teaching_assignments ta
                      LEFT JOIN acad_programmecourses pc ON pc.course_code = ta.course_id AND pc.progcode = ta.progid
                      LEFT JOIN acad_courses c ON c.CourseCode = ta.course_id
                      LEFT JOIN acad_programme p ON p.progcode = ta.progid
                      WHERE ta.teacher_username = @teacher
                        AND ta.acadyear = @year
                        AND ta.semester = @sem
                        AND ta.is_active = 1
                      ORDER BY ta.study_year, ta.course_id", conn))
                {
                    cmd.Parameters.AddWithValue("@teacher", teacherUsername);
                    cmd.Parameters.AddWithValue("@year", acadyear);
                    cmd.Parameters.AddWithValue("@sem", semester);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            TeachingAssignment a = new TeachingAssignment();
                            a.Id = Convert.ToInt32(rdr["id"]);
                            a.CourseId = rdr["course_id"].ToString();
                            a.ProgId = rdr["progid"].ToString();
                            a.StudyYear = Convert.ToInt32(rdr["study_year"]);
                            a.CampusId = Convert.ToInt32(rdr["campus_id"]);
                            a.StudSession = rdr["stud_session"].ToString();
                            a.CourseName = rdr["course_name"].ToString();
                            a.ProgName = rdr["prog_name"].ToString();
                            list.Add(a);
                        }
                    }
                }
            }
        }
        catch
        {
            // Return empty list on error — caller handles empty state
        }

        return list;
    }

    /// <summary>
    /// Validates that a mark-entry operation is authorized. Returns null on success,
    /// or an error message string on failure. This is the single gate method used
    /// before any mark mutation.
    /// </summary>
    public static string ValidateMarkEntryAuthorization(string courseId, string progid,
        string acadyear, int semester)
    {
        string user = GetCurrentUser();
        if (user == "Unknown") return "Not authenticated.";

        if (!CanEnterMarks())
            return "Your role does not allow mark entry.";

        if (!IsAssignedToCourse(user, courseId, progid, acadyear, semester))
            return String.Format("You are not assigned to course {0} in programme {1} for {2} semester {3}.",
                courseId, progid, acadyear, semester);

        return null; // authorized
    }

    // ─────────────────────── DTO ────────────────────────────────────────

    /// <summary>Simple DTO for teaching assignment data.</summary>
    public class TeachingAssignment
    {
        public int Id { get; set; }
        public string CourseId { get; set; }
        public string ProgId { get; set; }
        public int StudyYear { get; set; }
        public int CampusId { get; set; }
        public string StudSession { get; set; }
        public string CourseName { get; set; }
        public string ProgName { get; set; }
    }
}
