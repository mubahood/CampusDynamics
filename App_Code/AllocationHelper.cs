using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// AllocationHelper — shared static methods for Load Allocation module.
///
/// Provides:
///   - Room collision detection (is a room double-booked on a given day/time?)
///   - Lecturer collision detection (is a lecturer double-booked on a given day/time?)
///   - Semester-wide collision summary (for dashboard alerts)
///   - Time parsing / overlap utilities
///
/// Design Rules:
///   - C# 4.0 compatible: no ?. operator, no string interpolation ($"")
///   - Always use vacConnectionString — no hardcoded credentials
///   - staffCode stores empID as string: CAST(staffCode AS UNSIGNED) = empID
///   - Times stored as varchar "HH:MM" (or "HH:MM:SS") — use STR_TO_DATE
///   - lectureday = '-' means unscheduled; filter these out
///
/// Tasks: See LOAD_ALLOCATION_TASKS.md — Task 9
/// Created: 2026-04-11
/// </summary>
public static class AllocationHelper
{
    // ─────────────────────── Connection ──────────────────────────────────

    private static string ConnStr
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        }
    }

    // ─────────────────────── Public Data Types ────────────────────────────

    /// <summary>
    /// A single detected scheduling conflict.
    /// </summary>
    public class ConflictInfo
    {
        /// <summary>Allocation ID of the conflicting record.</summary>
        public int AllocationId { get; set; }
        /// <summary>Human-readable description of the conflict.</summary>
        public string Message { get; set; }
        /// <summary>"room" or "lecturer"</summary>
        public string ConflictType { get; set; }
        /// <summary>Course code involved.</summary>
        public string CourseCode { get; set; }
        /// <summary>Lecturer name (if known).</summary>
        public string LecturerName { get; set; }
        /// <summary>Start time of the conflicting slot.</summary>
        public string StartTime { get; set; }
        /// <summary>End time of the conflicting slot.</summary>
        public string EndTime { get; set; }
    }

    /// <summary>
    /// Summary of all collisions for a given semester — used by the dashboard.
    /// </summary>
    public class CollisionSummary
    {
        public int RoomCollisionCount { get; set; }
        public int LecturerCollisionCount { get; set; }
        public List<ConflictInfo> RoomConflicts { get; set; }
        public List<ConflictInfo> LecturerConflicts { get; set; }

        public CollisionSummary()
        {
            RoomConflicts = new List<ConflictInfo>();
            LecturerConflicts = new List<ConflictInfo>();
        }
    }

    // ─────────────────────── Room Collision ──────────────────────────────

    /// <summary>
    /// Checks whether the given room is already booked on the given day and time window.
    /// Returns a list of ConflictInfo describing each overlap found.
    /// Returns an empty list when there are no conflicts.
    ///
    /// Overlap condition: existingStart &lt; @endTime AND existingEnd &gt; @startTime
    /// </summary>
    /// <param name="roomNo">Room ID / number as stored in acad_teaching_allocation.roomNo</param>
    /// <param name="day">Day of week exactly as stored in lectureday (e.g. "MONDAY")</param>
    /// <param name="startTime">Start time string "HH:MM"</param>
    /// <param name="endTime">End time string "HH:MM"</param>
    /// <param name="acadYear">Academic year string (e.g. "2025/2026")</param>
    /// <param name="semester">Semester number as string ("1" or "2")</param>
    /// <param name="campusId">Campus ID as string</param>
    /// <param name="excludeId">ID of the allocation being edited (0 for new records)</param>
    public static List<ConflictInfo> CheckRoomCollision(
        string roomNo, string day, string startTime, string endTime,
        string acadYear, string semester, string campusId, int excludeId)
    {
        List<ConflictInfo> conflicts = new List<ConflictInfo>();
        if (string.IsNullOrEmpty(roomNo) || string.IsNullOrEmpty(day)
            || day == "-" || string.IsNullOrEmpty(startTime) || string.IsNullOrEmpty(endTime))
        {
            return conflicts;
        }

        string sql = @"
            SELECT ta.ID,
                   ta.courseID,
                   IFNULL(c.courseName, ta.courseID) AS courseName,
                   IFNULL(e.emp_name, CONCAT('Staff #', ta.staffCode)) AS lecturerName,
                   ta.StartTime, ta.EndTime,
                   ta.progcode
            FROM   acad_teaching_allocation ta
            LEFT JOIN acad_course c   ON c.courseID = ta.courseID
            LEFT JOIN hrm_employee e  ON e.empID = CAST(ta.staffCode AS UNSIGNED)
            WHERE  ta.roomNo    = @room
              AND  ta.lectureday = @day
              AND  ta.acad_year  = @year
              AND  ta.semester   = @sem
              AND  ta.campusId   = @campus
              AND  ta.lectureday != '-'
              AND  ta.StartTime IS NOT NULL
              AND  ta.EndTime   IS NOT NULL
              AND  STR_TO_DATE(ta.StartTime, '%H:%i') < STR_TO_DATE(@end,   '%H:%i')
              AND  STR_TO_DATE(ta.EndTime,   '%H:%i') > STR_TO_DATE(@start, '%H:%i')
              AND  ta.ID != @excl";

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@room",   roomNo);
                    cmd.Parameters.AddWithValue("@day",    day);
                    cmd.Parameters.AddWithValue("@year",   acadYear);
                    cmd.Parameters.AddWithValue("@sem",    semester);
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@start",  startTime);
                    cmd.Parameters.AddWithValue("@end",    endTime);
                    cmd.Parameters.AddWithValue("@excl",   excludeId);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string cName   = rdr["courseName"].ToString();
                            string lName   = rdr["lecturerName"].ToString();
                            string sTime   = rdr["StartTime"].ToString();
                            string eTime   = rdr["EndTime"].ToString();
                            string prog    = rdr["progcode"].ToString();

                            conflicts.Add(new ConflictInfo
                            {
                                AllocationId  = Convert.ToInt32(rdr["ID"]),
                                ConflictType  = "room",
                                CourseCode    = rdr["courseID"].ToString(),
                                LecturerName  = lName,
                                StartTime     = sTime,
                                EndTime       = eTime,
                                Message       = string.Format(
                                    "Room conflict: {0} is booked {1} {2}\u2013{3} for {4} ({5})",
                                    "this room", day, sTime, eTime, cName, prog)
                            });
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            conflicts.Add(new ConflictInfo
            {
                ConflictType = "room",
                Message      = "Error checking room conflicts: " + ex.Message
            });
        }

        return conflicts;
    }

    // ─────────────────────── Lecturer Collision ───────────────────────────

    /// <summary>
    /// Checks whether the given lecturer is already teaching at the given day and time window.
    /// A lecturer cannot be in two places at once — this check is NOT campus-scoped.
    /// Returns a list of ConflictInfo describing each overlap found.
    /// </summary>
    /// <param name="staffCode">staffCode as stored in acad_teaching_allocation (= empID as string)</param>
    /// <param name="day">Day of week exactly as stored (e.g. "MONDAY")</param>
    /// <param name="startTime">Start time string "HH:MM"</param>
    /// <param name="endTime">End time string "HH:MM"</param>
    /// <param name="acadYear">Academic year string</param>
    /// <param name="semester">Semester number as string</param>
    /// <param name="excludeId">ID of the allocation being edited (0 for new records)</param>
    public static List<ConflictInfo> CheckLecturerCollision(
        string staffCode, string day, string startTime, string endTime,
        string acadYear, string semester, int excludeId)
    {
        List<ConflictInfo> conflicts = new List<ConflictInfo>();
        if (string.IsNullOrEmpty(staffCode) || staffCode == "0"
            || string.IsNullOrEmpty(day) || day == "-"
            || string.IsNullOrEmpty(startTime) || string.IsNullOrEmpty(endTime))
        {
            return conflicts;
        }

        string sql = @"
            SELECT ta.ID,
                   ta.courseID,
                   IFNULL(c.courseName, ta.courseID) AS courseName,
                   IFNULL(lr.RoomName, ta.roomNo)    AS roomName,
                   ta.StartTime, ta.EndTime,
                   ta.progcode
            FROM   acad_teaching_allocation ta
            LEFT JOIN acad_course c        ON c.courseID = ta.courseID
            LEFT JOIN acad_lecturerooms lr ON lr.RoomID  = CAST(ta.roomNo AS UNSIGNED)
            WHERE  ta.staffCode  = @staff
              AND  ta.lectureday = @day
              AND  ta.acad_year  = @year
              AND  ta.semester   = @sem
              AND  ta.lectureday != '-'
              AND  ta.StartTime IS NOT NULL
              AND  ta.EndTime   IS NOT NULL
              AND  STR_TO_DATE(ta.StartTime, '%H:%i') < STR_TO_DATE(@end,   '%H:%i')
              AND  STR_TO_DATE(ta.EndTime,   '%H:%i') > STR_TO_DATE(@start, '%H:%i')
              AND  ta.ID != @excl";

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@staff",  staffCode);
                    cmd.Parameters.AddWithValue("@day",    day);
                    cmd.Parameters.AddWithValue("@year",   acadYear);
                    cmd.Parameters.AddWithValue("@sem",    semester);
                    cmd.Parameters.AddWithValue("@start",  startTime);
                    cmd.Parameters.AddWithValue("@end",    endTime);
                    cmd.Parameters.AddWithValue("@excl",   excludeId);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string cName  = rdr["courseName"].ToString();
                            string rName  = rdr["roomName"].ToString();
                            string sTime  = rdr["StartTime"].ToString();
                            string eTime  = rdr["EndTime"].ToString();
                            string prog   = rdr["progcode"].ToString();

                            conflicts.Add(new ConflictInfo
                            {
                                AllocationId  = Convert.ToInt32(rdr["ID"]),
                                ConflictType  = "lecturer",
                                CourseCode    = rdr["courseID"].ToString(),
                                LecturerName  = "",
                                StartTime     = sTime,
                                EndTime       = eTime,
                                Message       = string.Format(
                                    "Lecturer conflict: already teaching {0} ({1}) on {2} {3}\u2013{4} in {5}",
                                    cName, prog, day, sTime, eTime, rName)
                            });
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            conflicts.Add(new ConflictInfo
            {
                ConflictType = "lecturer",
                Message      = "Error checking lecturer conflicts: " + ex.Message
            });
        }

        return conflicts;
    }

    // ─────────────────────── Semester-Wide Summary ────────────────────────

    /// <summary>
    /// Scans all scheduled allocations for a semester and returns a summary of
    /// all detected room and lecturer conflicts.  Used by the dashboard alert panel.
    ///
    /// Performance note: uses a self-join; the idx_room and idx_staff indexes
    /// make this fast on the 15K-row table.
    /// </summary>
    public static CollisionSummary GetCollisionSummary(
        string acadYear, string semester, string campusId)
    {
        CollisionSummary summary = new CollisionSummary();

        // ── Room collisions (same room, same day, overlapping time) ──────
        string roomSql = @"
            SELECT a.ID AS id_a, b.ID AS id_b,
                   a.courseID AS course_a, b.courseID AS course_b,
                   IFNULL(c1.courseName, a.courseID) AS name_a,
                   IFNULL(c2.courseName, b.courseID) AS name_b,
                   a.lectureday, a.StartTime, a.EndTime,
                   IFNULL(lr.RoomName, a.roomNo) AS roomName
            FROM   acad_teaching_allocation a
            JOIN   acad_teaching_allocation b
                   ON  a.roomNo     = b.roomNo
                   AND a.lectureday = b.lectureday
                   AND a.acad_year  = b.acad_year
                   AND a.semester   = b.semester
                   AND a.campusId   = b.campusId
                   AND a.ID < b.ID
                   AND STR_TO_DATE(a.StartTime,'%H:%i') < STR_TO_DATE(b.EndTime,  '%H:%i')
                   AND STR_TO_DATE(a.EndTime,  '%H:%i') > STR_TO_DATE(b.StartTime,'%H:%i')
            LEFT JOIN acad_course c1       ON c1.courseID = a.courseID
            LEFT JOIN acad_course c2       ON c2.courseID = b.courseID
            LEFT JOIN acad_lecturerooms lr ON lr.RoomID   = CAST(a.roomNo AS UNSIGNED)
            WHERE  a.acad_year  = @year
              AND  a.semester   = @sem
              AND  a.campusId   = @campus
              AND  a.lectureday != '-'
              AND  a.StartTime IS NOT NULL AND a.EndTime IS NOT NULL
              AND  b.StartTime IS NOT NULL AND b.EndTime IS NOT NULL
            ORDER BY a.lectureday, a.StartTime
            LIMIT 50";

        // ── Lecturer collisions (same staff, same day, overlapping time) ─
        string lecturerSql = @"
            SELECT a.ID AS id_a, b.ID AS id_b,
                   a.staffCode,
                   IFNULL(e.emp_name, CONCAT('Staff #', a.staffCode)) AS lecturerName,
                   a.courseID AS course_a, b.courseID AS course_b,
                   IFNULL(c1.courseName, a.courseID) AS name_a,
                   IFNULL(c2.courseName, b.courseID) AS name_b,
                   a.lectureday, a.StartTime, a.EndTime
            FROM   acad_teaching_allocation a
            JOIN   acad_teaching_allocation b
                   ON  a.staffCode  = b.staffCode
                   AND a.lectureday = b.lectureday
                   AND a.acad_year  = b.acad_year
                   AND a.semester   = b.semester
                   AND a.ID < b.ID
                   AND STR_TO_DATE(a.StartTime,'%H:%i') < STR_TO_DATE(b.EndTime,  '%H:%i')
                   AND STR_TO_DATE(a.EndTime,  '%H:%i') > STR_TO_DATE(b.StartTime,'%H:%i')
            LEFT JOIN acad_course c1   ON c1.courseID = a.courseID
            LEFT JOIN acad_course c2   ON c2.courseID = b.courseID
            LEFT JOIN hrm_employee e   ON e.empID     = CAST(a.staffCode AS UNSIGNED)
            WHERE  a.acad_year  = @year
              AND  a.semester   = @sem
              AND  a.staffCode != '0'
              AND  a.lectureday != '-'
              AND  a.StartTime IS NOT NULL AND a.EndTime IS NOT NULL
              AND  b.StartTime IS NOT NULL AND b.EndTime IS NOT NULL
            ORDER BY a.staffCode, a.lectureday, a.StartTime
            LIMIT 50";

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Room conflicts
                using (MySqlCommand cmd = new MySqlCommand(roomSql, conn))
                {
                    cmd.Parameters.AddWithValue("@year",   acadYear);
                    cmd.Parameters.AddWithValue("@sem",    semester);
                    cmd.Parameters.AddWithValue("@campus", campusId);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            summary.RoomConflicts.Add(new ConflictInfo
                            {
                                AllocationId  = Convert.ToInt32(rdr["id_a"]),
                                ConflictType  = "room",
                                CourseCode    = rdr["course_a"].ToString(),
                                StartTime     = rdr["StartTime"].ToString(),
                                EndTime       = rdr["EndTime"].ToString(),
                                Message       = string.Format(
                                    "Room '{0}' double-booked on {1} {2}\u2013{3}: {4} and {5}",
                                    rdr["roomName"], rdr["lectureday"],
                                    rdr["StartTime"], rdr["EndTime"],
                                    rdr["name_a"], rdr["name_b"])
                            });
                        }
                    }
                }

                // Lecturer conflicts
                using (MySqlCommand cmd = new MySqlCommand(lecturerSql, conn))
                {
                    cmd.Parameters.AddWithValue("@year",  acadYear);
                    cmd.Parameters.AddWithValue("@sem",   semester);

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            summary.LecturerConflicts.Add(new ConflictInfo
                            {
                                AllocationId  = Convert.ToInt32(rdr["id_a"]),
                                ConflictType  = "lecturer",
                                CourseCode    = rdr["course_a"].ToString(),
                                LecturerName  = rdr["lecturerName"].ToString(),
                                StartTime     = rdr["StartTime"].ToString(),
                                EndTime       = rdr["EndTime"].ToString(),
                                Message       = string.Format(
                                    "{0} has overlapping classes on {1} {2}\u2013{3}: {4} and {5}",
                                    rdr["lecturerName"], rdr["lectureday"],
                                    rdr["StartTime"], rdr["EndTime"],
                                    rdr["name_a"], rdr["name_b"])
                            });
                        }
                    }
                }
            }
        }
        catch { /* Dashboard: silently degrade on error */ }

        summary.RoomCollisionCount     = summary.RoomConflicts.Count;
        summary.LecturerCollisionCount = summary.LecturerConflicts.Count;

        return summary;
    }

    // ─────────────────────── Usage Check ─────────────────────────────────

    /// <summary>
    /// Returns the number of allocations that reference the given room.
    /// Used by LectureRooms page to block deletion of in-use rooms.
    /// </summary>
    public static int GetRoomUsageCount(string roomId, string acadYear, string semester)
    {
        if (string.IsNullOrEmpty(roomId)) return 0;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"
                    SELECT COUNT(*) FROM acad_teaching_allocation
                    WHERE  roomNo    = @room
                      AND  acad_year = @year
                      AND  semester  = @sem";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@room", roomId);
                    cmd.Parameters.AddWithValue("@year", acadYear);
                    cmd.Parameters.AddWithValue("@sem",  semester);
                    object res = cmd.ExecuteScalar();
                    return (res == null || res == DBNull.Value) ? 0 : Convert.ToInt32(res);
                }
            }
        }
        catch { return -1; }
    }

    /// <summary>
    /// Returns the total number of allocations that reference the given room across ALL years.
    /// Used for the "this room is used in N allocations across all time" warning.
    /// </summary>
    public static int GetRoomTotalUsageCount(string roomId)
    {
        if (string.IsNullOrEmpty(roomId)) return 0;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_teaching_allocation WHERE roomNo = @room", conn))
                {
                    cmd.Parameters.AddWithValue("@room", roomId);
                    object res = cmd.ExecuteScalar();
                    return (res == null || res == DBNull.Value) ? 0 : Convert.ToInt32(res);
                }
            }
        }
        catch { return -1; }
    }

    // ─────────────────────── Current User ────────────────────────────────

    /// <summary>
    /// Gets the current authenticated user's display name for audit trail.
    /// Falls back to "system" if session is unavailable.
    /// </summary>
    public static string GetCurrentUser()
    {
        try
        {
            System.Web.HttpContext ctx = System.Web.HttpContext.Current;
            if (ctx == null || ctx.Session == null) return "system";
            object u = ctx.Session["UserName"];
            if (u != null && !string.IsNullOrEmpty(u.ToString())) return u.ToString();
            u = ctx.Session["username"];
            if (u != null && !string.IsNullOrEmpty(u.ToString())) return u.ToString();
            u = ctx.Session["LoggedInUser"];
            if (u != null && !string.IsNullOrEmpty(u.ToString())) return u.ToString();
        }
        catch { }
        return "system";
    }

    // ─────────────────────── Time Utilities ──────────────────────────────

    /// <summary>
    /// Checks whether two time ranges overlap.
    /// All times as "HH:MM" or "HH:MM:SS" strings.
    /// Returns true if they overlap.
    /// </summary>
    public static bool TimesOverlap(string start1, string end1, string start2, string end2)
    {
        try
        {
            TimeSpan s1 = ParseTime(start1);
            TimeSpan e1 = ParseTime(end1);
            TimeSpan s2 = ParseTime(start2);
            TimeSpan e2 = ParseTime(end2);
            return s1 < e2 && e1 > s2;
        }
        catch { return false; }
    }

    /// <summary>
    /// Parses "HH:MM" or "HH:MM:SS" to a TimeSpan.
    /// </summary>
    public static TimeSpan ParseTime(string t)
    {
        if (string.IsNullOrEmpty(t)) return TimeSpan.Zero;
        // Normalise "HH:MM:SS" → "HH:MM"
        string[] parts = t.Trim().Split(':');
        int hours   = parts.Length > 0 ? int.Parse(parts[0]) : 0;
        int minutes = parts.Length > 1 ? int.Parse(parts[1]) : 0;
        return new TimeSpan(hours, minutes, 0);
    }

    /// <summary>
    /// Returns the duration in minutes between two time strings.
    /// </summary>
    public static int DurationMinutes(string start, string end)
    {
        try
        {
            TimeSpan s = ParseTime(start);
            TimeSpan e = ParseTime(end);
            return (int)(e - s).TotalMinutes;
        }
        catch { return 0; }
    }
}
