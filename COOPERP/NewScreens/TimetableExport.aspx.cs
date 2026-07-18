using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_TimetableExport : Page
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
        List<object> years = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT DISTINCT acad_year FROM acad_registration WHERE acad_year<>'' ORDER BY acad_year DESC LIMIT 6").Rows) years.Add(S(r, "acad_year"));
        List<object> progs = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT progcode, progname FROM acad_programme ORDER BY progname").Rows)
            progs.Add(new Dictionary<string, object> { { "code", S(r, "progcode") }, { "name", S(r, "progname") } });
        List<object> rooms = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT RoomID, RoomName FROM acad_lecturerooms WHERE IFNULL(is_active,1)=1 ORDER BY RoomName").Rows)
            rooms.Add(new Dictionary<string, object> { { "id", I(r, "RoomID") }, { "name", S(r, "RoomName") } });
        List<object> teachers = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT empID, emp_name FROM hrm_employee WHERE emp_name<>'' ORDER BY emp_name").Rows)
            teachers.Add(new Dictionary<string, object> { { "id", I(r, "empID") }, { "name", S(r, "emp_name") } });
        return new { ok = true, campuses = campuses, years = years, programmes = progs, rooms = rooms, teachers = teachers };
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object ExportData(string acadYear, int campusId, string progcode, int studyYear, int semester, int roomId, int teacherId, int dayNo)
    {
        TimetableService.EnsureSchema();
        StringBuilder wh = new StringBuilder();
        List<MySqlParameter> ps = new List<MySqlParameter>();
        ps.Add(P("@ay", acadYear));
        if (campusId > 0) { wh.Append(" AND (it.campus_id=@cp OR it.campus_id=0)"); ps.Add(P("@cp", campusId)); }
        if (!string.IsNullOrEmpty(progcode)) { wh.Append(" AND TRIM(it.progcode)=TRIM(@prog)"); ps.Add(P("@prog", progcode)); }
        if (studyYear > 0) { wh.Append(" AND it.study_year=@sy"); ps.Add(P("@sy", studyYear)); }
        if (semester > 0) { wh.Append(" AND it.semester=@sem"); ps.Add(P("@sem", semester)); }
        if (roomId > 0) { wh.Append(" AND it.room_id=@room"); ps.Add(P("@room", roomId)); }
        if (teacherId > 0) { wh.Append(" AND IFNULL(it.teacher_id, pc.lecturer_id)=@t"); ps.Add(P("@t", teacherId)); }
        if (dayNo > 0) { wh.Append(" AND it.day_no=@day"); ps.Add(P("@day", dayNo)); }

        DataTable dt = TimetableService.Query(
            "SELECT it.day_no, w.DayName, TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et, " +
            "TRIM(it.course_code) code, TRIM(IFNULL(c.courseName, it.course_code)) course, IFNULL(it.progcode,'') progcode, IFNULL(p.progname,'') progname, " +
            "IFNULL(it.study_year,0) study_year, IFNULL(it.semester,0) semester, IFNULL(te.emp_name, IFNULL(le.emp_name,'')) teacher, " +
            "IFNULL(r.RoomName, IFNULL(it.room_label,'')) room, IFNULL(b.building_name,'') building, IFNULL(cp.campus_name,'') campus, it.session_type, it.delivery_mode " +
            "FROM acad_timetable_item it JOIN acad_programmecourses pc ON pc.ID=it.programmecourse_id " +
            "LEFT JOIN acad_timetable_weekdays w ON w.DayNo=it.day_no LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) LEFT JOIN acad_programme p ON p.progcode=it.progcode " +
            "LEFT JOIN hrm_employee te ON te.empID=it.teacher_id LEFT JOIN hrm_employee le ON le.empID=pc.lecturer_id " +
            "LEFT JOIN acad_lecturerooms r ON r.RoomID=it.room_id LEFT JOIN acad_building b ON b.building_id=it.building_id LEFT JOIN acad_campuses cp ON cp.ID=it.campus_id " +
            "WHERE it.status='ACTIVE' AND it.acad_year=@ay" + wh.ToString() + " ORDER BY it.day_no, it.start_time, p.progname", ps.ToArray());

        List<object> rows = new List<object>();
        foreach (DataRow r in dt.Rows)
            rows.Add(new Dictionary<string, object> {
                { "dayNo", I(r, "day_no") }, { "dayName", S(r, "DayName") }, { "start", S(r, "st") }, { "end", S(r, "et") },
                { "code", S(r, "code") }, { "course", S(r, "course") }, { "progcode", S(r, "progcode") }, { "progname", S(r, "progname") },
                { "studyYear", I(r, "study_year") }, { "semester", I(r, "semester") }, { "teacher", S(r, "teacher") },
                { "room", S(r, "room") }, { "building", S(r, "building") }, { "campus", S(r, "campus") }, { "sessionType", S(r, "session_type") }, { "deliveryMode", S(r, "delivery_mode") } });
        return new { ok = true, rows = rows };
    }
}
