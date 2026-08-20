using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

// =====================================================================
//  TIMETABLE SERVICE — shared logic for the redesigned timetabling module.
//  Timetable items belong to a Programme-Course (acad_programmecourses.ID).
//  Self-healing schema + conflict engine, reused by every admin screen.
//  DB: campus_dynamics (vacConnectionString). See COOPERP/TIMETABLING_REDESIGN_PLAN.md
// =====================================================================
public static class TimetableService
{
    public static string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // =====================================================================
    //  PHYSICAL SESSIONS — the one idea the whole module turns on.
    //
    //  A timetable ITEM is a row: one programme-course placed in one slot.
    //  A SESSION is what actually happens: a lecturer standing in a room for
    //  a period of time. The two are not the same, and conflating them is
    //  what made the workload figures wrong.
    //
    //  One lecturer regularly teaches several programme-courses together in
    //  a single room at a single time — the same course to a degree and a
    //  diploma cohort, or one subject shared by several programmes. In the
    //  live timetable ENG1111D is taught to DCE and DME in one room, and
    //  ICT1104B/ICT1104D likewise. Those are one class, not two.
    //
    //  Two consequences, both previously wrong:
    //
    //   1. HOURS. A lecturer occupies a period of time ONCE. Whether the
    //      slot carries one programme-course or four, and whether the
    //      overlap is deliberate teaching or an accidental double-booking,
    //      they cannot spend the same hour twice. Weekly contact hours are
    //      therefore the UNION of their weekly intervals, not the sum of
    //      item durations. Summing gave a lecturer 6 hours for a 3-hour
    //      combined class.
    //
    //   2. CLASHES. Teaching two cohorts together in one room is normal and
    //      must not be reported as a clash. A genuine lecturer clash is
    //      being in two PLACES at once; a genuine room clash is two
    //      different lecturers in one room.
    // =====================================================================

    /// <summary>A weekly interval on one day, in minutes from midnight.</summary>
    public class Interval
    {
        public int Day;
        public int StartMin;
        public int EndMin;
        public Interval() { }
        public Interval(int day, int startMin, int endMin) { Day = day; StartMin = startMin; EndMin = endMin; }
    }

    /// <summary>
    /// Total minutes occupied by a set of weekly intervals, counting any overlap once.
    /// Intervals are merged per day, so a combined class counts once, a partial overlap
    /// counts only its true span, and a genuine double-booking still costs the lecturer
    /// only the time they are actually standing there.
    /// </summary>
    public static int UnionMinutes(IEnumerable<Interval> intervals)
    {
        if (intervals == null) return 0;
        var byDay = new Dictionary<int, List<Interval>>();
        foreach (Interval iv in intervals)
        {
            if (iv == null || iv.EndMin <= iv.StartMin) continue;
            List<Interval> l;
            if (!byDay.TryGetValue(iv.Day, out l)) { l = new List<Interval>(); byDay[iv.Day] = l; }
            l.Add(iv);
        }

        int total = 0;
        foreach (var kv in byDay)
        {
            List<Interval> day = kv.Value;
            day.Sort(delegate (Interval a, Interval b) { return a.StartMin.CompareTo(b.StartMin); });
            int curStart = day[0].StartMin, curEnd = day[0].EndMin;
            for (int i = 1; i < day.Count; i++)
            {
                if (day[i].StartMin <= curEnd)                       // touches or overlaps — merge
                { if (day[i].EndMin > curEnd) curEnd = day[i].EndMin; }
                else
                { total += curEnd - curStart; curStart = day[i].StartMin; curEnd = day[i].EndMin; }
            }
            total += curEnd - curStart;
        }
        return total;
    }

    public static double UnionHours(IEnumerable<Interval> intervals)
    {
        return Math.Round(UnionMinutes(intervals) / 60.0, 2);
    }

    /// <summary>
    /// True when two overlapping items are one class taught to several cohorts rather than
    /// a clash. The test is physical: same place, same delivery. A lecturer in one room can
    /// address any number of programmes at once; a lecturer in two rooms cannot.
    /// Room "0"/blank means unallocated — two unallocated items for the same lecturer at the
    /// same time are treated as one combined class, because that is overwhelmingly what they
    /// are in this timetable, and the room clash check will still catch a real double-booking
    /// once rooms are assigned.
    /// </summary>
    public static bool IsCombinedTeaching(int roomA, int roomB, string roomLabelA, string roomLabelB,
                                          int campusA, int campusB, string modeA, string modeB)
    {
        if (campusA > 0 && campusB > 0 && campusA != campusB) return false;   // cannot be on two campuses
        if (!string.Equals((modeA ?? "").Trim(), (modeB ?? "").Trim(), StringComparison.OrdinalIgnoreCase)) return false;

        if (roomA > 0 && roomB > 0) return roomA == roomB;
        if (roomA > 0 || roomB > 0) return false;                             // one placed, one not

        string la = (roomLabelA ?? "").Trim(), lb = (roomLabelB ?? "").Trim();
        if (la.Length > 0 && lb.Length > 0) return string.Equals(la, lb, StringComparison.OrdinalIgnoreCase);
        return true;                                                          // both unallocated
    }

    // ---- low-level helpers -------------------------------------------
    public static DataTable Query(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) da.Fill(dt);
            }
        }
        return dt;
    }

    public static int Exec(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    // INSERT and return the new auto-increment id from the SAME connection/session.
    // A separate Scalar("SELECT LAST_INSERT_ID()") runs on a DIFFERENT pooled connection
    // and returns 0 (fresh session) or a stale id from a prior insert — a real bug.
    public static long ExecInsertId(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                cmd.ExecuteNonQuery();
                return cmd.LastInsertedId;
            }
        }
    }

    // Run several statements inside ONE transaction on one connection (atomic multi-write).
    public static void ExecTx(Action<MySqlConnection, MySqlTransaction> body)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlTransaction tx = conn.BeginTransaction())
            {
                try { body(conn, tx); tx.Commit(); }
                catch { try { tx.Rollback(); } catch { } throw; }
            }
        }
    }

    // Validate a start time is parseable and within the day; and that start+duration does not
    // run past midnight. Returns "" when valid, else a student-friendly reason.
    public static string ValidateSlot(string startHHmm, int durationMin)
    {
        TimeSpan t;
        if (!TimeSpan.TryParse((startHHmm ?? "").Trim(), out t) || t.TotalHours >= 24 || t < TimeSpan.Zero)
            return "Enter a valid start time (HH:MM).";
        if (durationMin <= 0) durationMin = 60;
        if (t.Add(TimeSpan.FromMinutes(durationMin)).TotalHours > 24)
            return "This session runs past midnight — shorten it or start it earlier.";
        return "";
    }

    public static object Scalar(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteScalar();
            }
        }
    }

    public static MySqlParameter P(string name, object value)
    {
        return new MySqlParameter(name, value == null ? DBNull.Value : value);
    }

    // ---- schema self-heal --------------------------------------------
    private static bool _ensured = false;
    public static void EnsureSchema()
    {
        if (_ensured) return;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                ExecOn(conn, "CREATE TABLE IF NOT EXISTS acad_building (" +
                    " building_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, building_name VARCHAR(120) NOT NULL," +
                    " building_code VARCHAR(20) NULL, campus_id INT NOT NULL DEFAULT 0, floors INT NULL," +
                    " notes VARCHAR(300) NULL, is_active TINYINT NOT NULL DEFAULT 1," +
                    " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NULL," +
                    " KEY ix_bldg_campus (campus_id)) ENGINE=InnoDB DEFAULT CHARSET=utf8");

                ExecOn(conn, "CREATE TABLE IF NOT EXISTS acad_timetable_item (" +
                    " item_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, programmecourse_id INT UNSIGNED NOT NULL," +
                    " acad_year CHAR(15) NOT NULL, progcode CHAR(15) NULL, course_code CHAR(25) NULL, study_year INT NULL, semester INT NULL," +
                    " day_no INT NOT NULL, start_time TIME NOT NULL, duration_min INT NOT NULL DEFAULT 60, end_time TIME NOT NULL," +
                    " teacher_id INT NULL, campus_id INT NOT NULL DEFAULT 0, building_id INT NULL, room_id INT NULL, room_label VARCHAR(80) NULL," +
                    " session_type VARCHAR(15) NOT NULL DEFAULT 'LECTURE', delivery_mode VARCHAR(10) NOT NULL DEFAULT 'PHYSICAL'," +
                    " meet_link VARCHAR(400) NULL, description VARCHAR(400) NULL, status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'," +
                    " created_by VARCHAR(100) NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_by VARCHAR(100) NULL, updated_at DATETIME NULL," +
                    " KEY ix_tti_pc (programmecourse_id), KEY ix_tti_year (acad_year, semester)," +
                    " KEY ix_tti_teacher (teacher_id, acad_year, day_no), KEY ix_tti_room (room_id, acad_year, day_no)," +
                    " KEY ix_tti_cohort (progcode, study_year, semester, acad_year, day_no)) ENGINE=InnoDB DEFAULT CHARSET=utf8");

                // Extend the existing rooms table (never drop its 47 rows).
                AddColumn(conn, "acad_lecturerooms", "building_id", "INT NULL");
                AddColumn(conn, "acad_lecturerooms", "room_type", "VARCHAR(20) NULL");
                AddColumn(conn, "acad_lecturerooms", "is_active", "TINYINT NOT NULL DEFAULT 1");
                AddColumn(conn, "acad_lecturerooms", "notes", "VARCHAR(300) NULL");
            }
            _ensured = true;
        }
        catch { /* never break a page on self-heal */ }
    }

    private static void ExecOn(MySqlConnection conn, string sql)
    {
        using (MySqlCommand c = new MySqlCommand(sql, conn)) c.ExecuteNonQuery();
    }
    private static void AddColumn(MySqlConnection conn, string table, string col, string ddl)
    {
        using (MySqlCommand chk = new MySqlCommand("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
        {
            chk.Parameters.AddWithValue("@t", table); chk.Parameters.AddWithValue("@c", col);
            if (Convert.ToInt64(chk.ExecuteScalar()) > 0) return;
        }
        ExecOn(conn, "ALTER TABLE " + table + " ADD COLUMN " + col + " " + ddl);
    }

    // ---- time helpers -------------------------------------------------
    // "HH:mm" (or "HH:mm:ss") + minutes -> "HH:mm:ss"
    public static string EndTime(string startHHmm, int durationMin)
    {
        TimeSpan t;
        if (!TimeSpan.TryParse((startHHmm ?? "").Trim(), out t)) t = TimeSpan.Zero;
        if (durationMin <= 0) durationMin = 60;
        TimeSpan e = t.Add(TimeSpan.FromMinutes(durationMin));
        if (e.TotalHours >= 24) e = TimeSpan.FromHours(23) + TimeSpan.FromMinutes(59);
        return string.Format("{0:D2}:{1:D2}:00", e.Hours, e.Minutes);
    }
    public static string NormTime(string hhmm)
    {
        TimeSpan t;
        if (!TimeSpan.TryParse((hhmm ?? "").Trim(), out t)) return "00:00:00";
        return string.Format("{0:D2}:{1:D2}:00", t.Hours, t.Minutes);
    }

    // ---- conflict engine ---------------------------------------------
    public class Conflict
    {
        public string Kind;    // ROOM | LECTURER | COHORT | CAPACITY | CAMPUS
        public string Message;
    }

    // Detect clashes for a candidate item (itemId=0 for a new one). Times are "HH:mm".
    // Timetables are perpetual (not per academic year): a weekly day+time slot clashes
    // regardless of year, so there is no acad_year in the overlap.
    public static List<Conflict> CheckConflicts(int itemId, int dayNo, string startHHmm, int durationMin,
        int roomId, int effectiveTeacherId, string progcode, int studyYear, int semester, int campusId,
        string deliveryMode = "PHYSICAL")
    {
        List<Conflict> list = new List<Conflict>();
        try
        {
            string start = NormTime(startHHmm);
            string end = EndTime(startHHmm, durationMin);
            string overlap = " AND it.status='ACTIVE' AND it.day_no=@day AND it.item_id<>@id AND it.start_time < @end AND @start < it.end_time ";

            // Room clash — a room is only "busy" if someone ELSE has it. The same lecturer
            // holding two programme-courses in one room at one time is a combined class, which
            // is normal teaching and must not be reported.
            if (roomId > 0)
            {
                DataTable dt = Query(
                    "SELECT TRIM(IFNULL(c.courseName, it.course_code)) cn, TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et, IFNULL(r.RoomName,'') rn, " +
                    "       IFNULL(IFNULL(it.teacher_id, pc.lecturer_id),0) other_teacher " +
                    "FROM acad_timetable_item it JOIN acad_programmecourses pc ON pc.ID=it.programmecourse_id " +
                    "LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) LEFT JOIN acad_lecturerooms r ON r.RoomID=it.room_id " +
                    "WHERE it.room_id=@room " + overlap,
                    P("@room", roomId), P("@day", dayNo), P("@id", itemId), P("@start", start), P("@end", end));
                foreach (DataRow r in dt.Rows)
                {
                    int otherTeacher = 0;
                    int.TryParse(Val(r, "other_teacher"), out otherTeacher);
                    if (effectiveTeacherId > 0 && otherTeacher == effectiveTeacherId) continue;   // same lecturer, one class
                    list.Add(new Conflict { Kind = "ROOM", Message = "Room busy: " + Val(r, "rn") + " already has " + Val(r, "cn") + " at " + Val(r, "st") + "-" + Val(r, "et") + "." });
                }
            }

            // Lecturer clash — being in two PLACES at once. Teaching several cohorts together
            // in one room is not a clash; it is how a shared course is delivered.
            if (effectiveTeacherId > 0)
            {
                DataTable dt = Query(
                    "SELECT TRIM(IFNULL(c.courseName, it.course_code)) cn, TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et, " +
                    "       IFNULL(it.room_id,0) rid, IFNULL(it.room_label,'') rlab, IFNULL(it.campus_id,0) cid, IFNULL(it.delivery_mode,'') dmode " +
                    "FROM acad_timetable_item it JOIN acad_programmecourses pc ON pc.ID=it.programmecourse_id LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) " +
                    "WHERE IFNULL(it.teacher_id, pc.lecturer_id)=@t " + overlap,
                    P("@t", effectiveTeacherId), P("@day", dayNo), P("@id", itemId), P("@start", start), P("@end", end));
                foreach (DataRow r in dt.Rows)
                {
                    int otherRoom = 0, otherCampus = 0;
                    int.TryParse(Val(r, "rid"), out otherRoom);
                    int.TryParse(Val(r, "cid"), out otherCampus);
                    if (IsCombinedTeaching(roomId, otherRoom, "", Val(r, "rlab"), campusId, otherCampus, deliveryMode, Val(r, "dmode")))
                        continue;   // one class, several cohorts
                    list.Add(new Conflict { Kind = "LECTURER", Message = "Lecturer is already in another room teaching " + Val(r, "cn") + " at " + Val(r, "st") + "-" + Val(r, "et") + "." });
                }
            }

            // Cohort clash (same programme + study year + semester -> students double-booked)
            if (!string.IsNullOrEmpty(progcode) && studyYear > 0 && semester > 0)
            {
                DataTable dt = Query(
                    "SELECT TRIM(IFNULL(c.courseName, it.course_code)) cn, TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et " +
                    "FROM acad_timetable_item it LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) " +
                    "WHERE TRIM(it.progcode)=TRIM(@prog) AND it.study_year=@sy AND it.semester=@sem " + overlap,
                    P("@prog", progcode), P("@sy", studyYear), P("@sem", semester), P("@day", dayNo), P("@id", itemId), P("@start", start), P("@end", end));
                foreach (DataRow r in dt.Rows)
                    list.Add(new Conflict { Kind = "COHORT", Message = "Cohort clash: this class already has " + Val(r, "cn") + " at " + Val(r, "st") + "-" + Val(r, "et") + "." });
            }

            // Campus/room mismatch (soft)
            if (roomId > 0 && campusId > 0)
            {
                object rc = Scalar("SELECT campusId FROM acad_lecturerooms WHERE RoomID=@r", P("@r", roomId));
                int roomCampus = rc == null || rc == DBNull.Value ? 0 : Convert.ToInt32(rc);
                if (roomCampus > 0 && roomCampus != campusId)
                    list.Add(new Conflict { Kind = "CAMPUS", Message = "The chosen room is on a different campus than the session's campus." });
            }
        }
        catch (Exception ex) { list.Add(new Conflict { Kind = "ERROR", Message = ex.Message }); }
        return list;
    }

    private static string Val(DataRow r, string col)
    {
        return r.Table.Columns.Contains(col) && r[col] != DBNull.Value ? r[col].ToString() : "";
    }
}
