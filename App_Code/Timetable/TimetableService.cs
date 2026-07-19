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
        int roomId, int effectiveTeacherId, string progcode, int studyYear, int semester, int campusId)
    {
        List<Conflict> list = new List<Conflict>();
        try
        {
            string start = NormTime(startHHmm);
            string end = EndTime(startHHmm, durationMin);
            string overlap = " AND it.status='ACTIVE' AND it.day_no=@day AND it.item_id<>@id AND it.start_time < @end AND @start < it.end_time ";

            // Room clash
            if (roomId > 0)
            {
                DataTable dt = Query(
                    "SELECT TRIM(IFNULL(c.courseName, it.course_code)) cn, TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et, IFNULL(r.RoomName,'') rn " +
                    "FROM acad_timetable_item it LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) LEFT JOIN acad_lecturerooms r ON r.RoomID=it.room_id " +
                    "WHERE it.room_id=@room " + overlap,
                    P("@room", roomId), P("@day", dayNo), P("@id", itemId), P("@start", start), P("@end", end));
                foreach (DataRow r in dt.Rows)
                    list.Add(new Conflict { Kind = "ROOM", Message = "Room busy: " + Val(r, "rn") + " already has " + Val(r, "cn") + " at " + Val(r, "st") + "-" + Val(r, "et") + "." });
            }

            // Lecturer clash (effective teacher = item.teacher_id or pc.lecturer_id)
            if (effectiveTeacherId > 0)
            {
                DataTable dt = Query(
                    "SELECT TRIM(IFNULL(c.courseName, it.course_code)) cn, TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et " +
                    "FROM acad_timetable_item it JOIN acad_programmecourses pc ON pc.ID=it.programmecourse_id LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) " +
                    "WHERE IFNULL(it.teacher_id, pc.lecturer_id)=@t " + overlap,
                    P("@t", effectiveTeacherId), P("@day", dayNo), P("@id", itemId), P("@start", start), P("@end", end));
                foreach (DataRow r in dt.Rows)
                    list.Add(new Conflict { Kind = "LECTURER", Message = "Lecturer already teaching " + Val(r, "cn") + " at " + Val(r, "st") + "-" + Val(r, "et") + "." });
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
