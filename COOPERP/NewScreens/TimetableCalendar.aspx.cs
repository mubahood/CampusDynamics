using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_TimetableCalendar : Page
{
    protected void Page_Load(object sender, EventArgs e) { TimetableService.EnsureSchema(); }

    private static int I(DataRow r, string c) { return r.Table.Columns.Contains(c) && r[c] != DBNull.Value ? Convert.ToInt32(r[c]) : 0; }
    private static string S(DataRow r, string c) { return r.Table.Columns.Contains(c) && r[c] != DBNull.Value ? r[c].ToString() : ""; }
    private static MySqlParameter P(string n, object v) { return new MySqlParameter(n, v == null ? DBNull.Value : v); }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object Lookups()
    {
        TimetableService.EnsureSchema();
        List<object> campuses = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT ID, campus_name FROM acad_campuses ORDER BY ID").Rows)
            campuses.Add(new Dictionary<string, object> { { "id", I(r, "ID") }, { "name", S(r, "campus_name") } });
        List<object> progs = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT progcode, progname FROM acad_programme ORDER BY progname").Rows)
            progs.Add(new Dictionary<string, object> { { "code", S(r, "progcode") }, { "name", S(r, "progname") } });
        List<object> rooms = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT RoomID, RoomName FROM acad_lecturerooms WHERE IFNULL(is_active,1)=1 ORDER BY RoomName").Rows)
            rooms.Add(new Dictionary<string, object> { { "id", I(r, "RoomID") }, { "name", S(r, "RoomName") } });
        List<object> teachers = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT empID, emp_name FROM hrm_employee WHERE emp_name<>'' ORDER BY emp_name").Rows)
            teachers.Add(new Dictionary<string, object> { { "id", I(r, "empID") }, { "name", S(r, "emp_name") } });
        // only courses that actually have scheduled sessions (keeps the picker small + relevant)
        List<object> courses = new List<object>();
        foreach (DataRow r in TimetableService.Query(
            "SELECT DISTINCT TRIM(it.course_code) code, TRIM(IFNULL(c.courseName, it.course_code)) name " +
            "FROM acad_timetable_item it LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) " +
            "WHERE it.status='ACTIVE' AND TRIM(it.course_code)<>'' ORDER BY name").Rows)
            courses.Add(new Dictionary<string, object> { { "code", S(r, "code") }, { "name", S(r, "name") } });
        return new { ok = true, campuses = campuses, programmes = progs, rooms = rooms, teachers = teachers, courses = courses };
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object CalendarData(int campusId, string progcode, int studyYear, int semester, int roomId, int teacherId, string courseCode)
    {
        TimetableService.EnsureSchema();
        StringBuilder wh = new StringBuilder();
        List<MySqlParameter> ps = new List<MySqlParameter>();
        if (campusId > 0) { wh.Append(" AND (it.campus_id=@cp OR it.campus_id=0)"); ps.Add(P("@cp", campusId)); }
        if (!string.IsNullOrEmpty(progcode)) { wh.Append(" AND TRIM(it.progcode)=TRIM(@prog)"); ps.Add(P("@prog", progcode)); }
        if (studyYear > 0) { wh.Append(" AND it.study_year=@sy"); ps.Add(P("@sy", studyYear)); }
        if (semester > 0) { wh.Append(" AND it.semester=@sem"); ps.Add(P("@sem", semester)); }
        if (roomId > 0) { wh.Append(" AND it.room_id=@room"); ps.Add(P("@room", roomId)); }
        if (teacherId > 0) { wh.Append(" AND IFNULL(it.teacher_id, pc.lecturer_id)=@t"); ps.Add(P("@t", teacherId)); }
        if (!string.IsNullOrEmpty(courseCode)) { wh.Append(" AND TRIM(it.course_code)=TRIM(@cc)"); ps.Add(P("@cc", courseCode)); }

        DataTable dt = TimetableService.Query(
            "SELECT it.item_id, it.programmecourse_id pc_id, it.day_no, TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et, " +
            "HOUR(it.start_time)*60+MINUTE(it.start_time) sm, HOUR(it.end_time)*60+MINUTE(it.end_time) em, " +
            "TRIM(IFNULL(c.courseName, it.course_code)) course, TRIM(it.course_code) code, IFNULL(it.progcode,'') progcode, IFNULL(p.progname,'') progname, IFNULL(it.study_year,0) study_year, IFNULL(it.semester,0) semester, " +
            "IFNULL(it.teacher_id, pc.lecturer_id) eff_teacher, IFNULL(te.emp_name, IFNULL(le.emp_name,'')) teacher, " +
            "IFNULL(it.room_id,0) room_id, IFNULL(r.RoomName,'') room, IFNULL(b.building_name,'') building, IFNULL(it.room_label,'') room_label, it.campus_id, IFNULL(cp.campus_short_name,'') campus, IFNULL(cp.campus_name,'') campus_full, it.session_type, it.delivery_mode, IFNULL(it.meet_link,'') meet_link " +
            "FROM acad_timetable_item it JOIN acad_programmecourses pc ON pc.ID=it.programmecourse_id " +
            "LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) LEFT JOIN acad_programme p ON p.progcode=it.progcode LEFT JOIN hrm_employee te ON te.empID=it.teacher_id LEFT JOIN hrm_employee le ON le.empID=pc.lecturer_id " +
            "LEFT JOIN acad_lecturerooms r ON r.RoomID=it.room_id LEFT JOIN acad_building b ON b.building_id=it.building_id LEFT JOIN acad_campuses cp ON cp.ID=it.campus_id " +
            "WHERE it.status='ACTIVE'" + wh.ToString() + " ORDER BY it.day_no, it.start_time", ps.ToArray());

        // Mark the rows that are one class shared by several cohorts, so the grid can say so
        // instead of drawing what looks like a double-booking. Same lecturer, same slot, same
        // place is combined teaching — normal delivery, not a clash.
        Dictionary<string, int> shareCount = new Dictionary<string, int>();
        foreach (DataRow r in dt.Rows)
        {
            string k = I(r, "eff_teacher") + "|" + I(r, "day_no") + "|" + I(r, "sm") + "|" + I(r, "em") + "|" +
                       (I(r, "room_id") > 0 ? "R" + I(r, "room_id") : "L" + S(r, "room_label").Trim().ToUpperInvariant()) + "|" +
                       I(r, "campus_id") + "|" + S(r, "delivery_mode").Trim().ToUpperInvariant();
            shareCount[k] = shareCount.ContainsKey(k) ? shareCount[k] + 1 : 1;
        }

        List<object> rows = new List<object>();
        foreach (DataRow r in dt.Rows)
        {
            string k = I(r, "eff_teacher") + "|" + I(r, "day_no") + "|" + I(r, "sm") + "|" + I(r, "em") + "|" +
                       (I(r, "room_id") > 0 ? "R" + I(r, "room_id") : "L" + S(r, "room_label").Trim().ToUpperInvariant()) + "|" +
                       I(r, "campus_id") + "|" + S(r, "delivery_mode").Trim().ToUpperInvariant();
            int shared = I(r, "eff_teacher") > 0 && shareCount.ContainsKey(k) ? shareCount[k] : 1;
            rows.Add(new Dictionary<string, object> {
                { "sessionKey", k }, { "sharedWith", shared }, { "combined", shared > 1 },
                { "id", I(r, "item_id") }, { "pcId", I(r, "pc_id") }, { "dayNo", I(r, "day_no") }, { "start", S(r, "st") }, { "end", S(r, "et") },
                { "sm", I(r, "sm") }, { "em", I(r, "em") }, { "course", S(r, "course") }, { "code", S(r, "code") },
                { "progcode", S(r, "progcode") }, { "progname", S(r, "progname") }, { "studyYear", I(r, "study_year") }, { "semester", I(r, "semester") },
                { "teacherId", I(r, "eff_teacher") }, { "teacher", S(r, "teacher") }, { "roomId", I(r, "room_id") },
                { "room", S(r, "room") }, { "building", S(r, "building") }, { "roomLabel", S(r, "room_label") }, { "campusId", I(r, "campus_id") }, { "campus", S(r, "campus") }, { "campusFull", S(r, "campus_full") },
                { "sessionType", S(r, "session_type") }, { "deliveryMode", S(r, "delivery_mode") }, { "meetLink", S(r, "meet_link") } });
        }
        return new { ok = true, sessions = rows };
    }
}
