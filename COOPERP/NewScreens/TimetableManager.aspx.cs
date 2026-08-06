using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_TimetableManager : Page
{
    protected void Page_Load(object sender, EventArgs e) { TimetableService.EnsureSchema(); }

    private static int I(DataRow r, string c) { return r.Table.Columns.Contains(c) && r[c] != DBNull.Value ? Convert.ToInt32(r[c]) : 0; }
    private static string S(DataRow r, string c) { return r.Table.Columns.Contains(c) && r[c] != DBNull.Value ? r[c].ToString() : ""; }
    private static MySqlParameter P(string n, object v) { return new MySqlParameter(n, v == null ? DBNull.Value : v); }
    private static string Actor()
    {
        try { HttpContext c = HttpContext.Current; if (c != null && c.Session != null && c.Session["username"] != null) return c.Session["username"].ToString(); } catch { }
        try { HttpContext c = HttpContext.Current; if (c != null && c.User != null && c.User.Identity != null && !string.IsNullOrEmpty(c.User.Identity.Name)) return c.User.Identity.Name; } catch { }
        return "admin";
    }

    // WebMethods bypass the master-page login gate, so each guards the session itself.
    private static bool Authed()
    { try { HttpContext c = HttpContext.Current; return c != null && c.Session != null && c.Session["username"] != null; } catch { return false; } }
    private static object Denied() { return new { ok = false, message = "Your session has expired. Please sign in again." }; }

    // ── lookups (no academic year — timetable is perpetual) ──
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object Lookups()
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        List<object> campuses = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT ID, campus_name FROM acad_campuses ORDER BY ID").Rows)
            campuses.Add(new Dictionary<string, object> { { "id", I(r, "ID") }, { "name", S(r, "campus_name") } });
        List<object> teachers = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT empID, emp_name FROM hrm_employee WHERE emp_name IS NOT NULL AND TRIM(emp_name)<>'' ORDER BY emp_name").Rows)
            teachers.Add(new Dictionary<string, object> { { "id", I(r, "empID") }, { "name", S(r, "emp_name") } });
        List<object> progs = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT progcode, progname FROM acad_programme ORDER BY progname").Rows)
            progs.Add(new Dictionary<string, object> { { "code", S(r, "progcode") }, { "name", S(r, "progname") } });
        List<object> rooms = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT r.RoomID, r.RoomName, IFNULL(r.Capacity,0) cap, IFNULL(r.campusId,0) campusId, IFNULL(r.building_id,0) bid, IFNULL(b.building_name,'') bn FROM acad_lecturerooms r LEFT JOIN acad_building b ON b.building_id=r.building_id WHERE IFNULL(r.is_active,1)=1 ORDER BY r.RoomName").Rows)
            rooms.Add(new Dictionary<string, object> { { "id", I(r, "RoomID") }, { "name", S(r, "RoomName") }, { "capacity", I(r, "cap") }, { "campusId", I(r, "campusId") }, { "buildingId", I(r, "bid") }, { "building", S(r, "bn") } });
        return new { ok = true, campuses = campuses, teachers = teachers, programmes = progs, rooms = rooms };
    }

    // ── rooms for a campus, annotated with availability for a day/time slot ──
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object RoomsForSlot(int campusId, int dayNo, string start, int durationMin, int excludeItemId)
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        string st = TimetableService.NormTime(start);
        string et = TimetableService.EndTime(start, durationMin);
        bool checkSlot = dayNo >= 1 && dayNo <= 7 && durationMin > 0;
        List<MySqlParameter> ps = new List<MySqlParameter>();
        string busySub = checkSlot
            ? "(SELECT TRIM(IFNULL(c.courseName, it.course_code)) FROM acad_timetable_item it LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(it.course_code) WHERE it.room_id=r.RoomID AND it.status='ACTIVE' AND it.day_no=@day AND it.item_id<>@ex AND it.start_time < @et AND @st < it.end_time LIMIT 1)"
            : "NULL";
        if (checkSlot) { ps.Add(P("@day", dayNo)); ps.Add(P("@ex", excludeItemId)); ps.Add(P("@st", st)); ps.Add(P("@et", et)); }
        string where = "WHERE IFNULL(r.is_active,1)=1";
        if (campusId > 0) { where += " AND (r.campusId=@cp OR r.campusId=0)"; ps.Add(P("@cp", campusId)); }
        DataTable dt = TimetableService.Query(
            "SELECT r.RoomID, r.RoomName, IFNULL(r.Capacity,0) cap, IFNULL(r.building_id,0) bid, IFNULL(b.building_name,'') bn, " + busySub + " busywith " +
            "FROM acad_lecturerooms r LEFT JOIN acad_building b ON b.building_id=r.building_id " + where + " ORDER BY r.RoomName", ps.ToArray());
        List<object> rooms = new List<object>();
        foreach (DataRow r in dt.Rows)
        {
            string bw = S(r, "busywith");
            rooms.Add(new Dictionary<string, object> { { "id", I(r, "RoomID") }, { "name", S(r, "RoomName") }, { "capacity", I(r, "cap") }, { "buildingId", I(r, "bid") }, { "building", S(r, "bn") }, { "busy", bw != "" ? 1 : 0 }, { "busyWith", bw } });
        }
        return new { ok = true, rooms = rooms };
    }

    // ── list programme-courses (+ session count) ──
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object ListPCs(string q, string progcode, int studyYear, int semester, int onlyUnscheduled, int page)
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        const int PS = 20;
        if (page < 1) page = 1;
        StringBuilder wh = new StringBuilder();
        List<MySqlParameter> ps = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(progcode)) { wh.Append(" AND pc.progcode=@prog"); ps.Add(P("@prog", progcode)); }
        if (studyYear > 0) { wh.Append(" AND pc.study_year=@sy"); ps.Add(P("@sy", studyYear)); }
        if (semester > 0) { wh.Append(" AND pc.semester=@sem"); ps.Add(P("@sem", semester)); }
        if (!string.IsNullOrEmpty(q)) { wh.Append(" AND (pc.course_code LIKE @q OR IFNULL(c.courseName,'') LIKE @q OR IFNULL(p.progname,'') LIKE @q OR IFNULL(e.emp_name,'') LIKE @q OR pc.progcode LIKE @q)"); ps.Add(P("@q", "%" + q + "%")); }
        string cnt = " AND (SELECT COUNT(*) FROM acad_timetable_item it WHERE it.programmecourse_id=pc.ID AND it.status='ACTIVE')";
        if (onlyUnscheduled == 1) wh.Append(cnt + "=0");

        string joins = "FROM acad_programmecourses pc LEFT JOIN acad_programme p ON pc.progcode=p.progcode LEFT JOIN acad_course c ON pc.course_code=c.courseID LEFT JOIN hrm_employee e ON e.empID=pc.lecturer_id WHERE 1=1" + wh.ToString();

        object tot = TimetableService.Scalar("SELECT COUNT(*) " + joins, ps.ToArray());
        int total = tot == null || tot == DBNull.Value ? 0 : Convert.ToInt32(tot);
        int pages = (int)Math.Ceiling(total / (double)PS); if (pages < 1) pages = 1; if (page > pages) page = pages;
        int off = (page - 1) * PS;

        DataTable dt = TimetableService.Query(
            "SELECT pc.ID, pc.progcode, IFNULL(p.progname,'') progname, TRIM(pc.course_code) course_code, IFNULL(c.courseName,'') courseName, " +
            "IFNULL(pc.study_year,1) study_year, IFNULL(pc.semester,1) semester, IFNULL(pc.course_type,'CORE') course_type, " +
            "IFNULL(pc.lecturer_id,0) lecturer_id, IFNULL(e.emp_name,'') lecturer_name, " +
            "(SELECT COUNT(*) FROM acad_timetable_item it WHERE it.programmecourse_id=pc.ID AND it.status='ACTIVE') sessions " +
            joins + " ORDER BY p.progname, pc.study_year, pc.semester, c.courseName LIMIT " + PS + " OFFSET " + off, ps.ToArray());
        List<object> rows = new List<object>();
        foreach (DataRow r in dt.Rows)
            rows.Add(new Dictionary<string, object> {
                { "id", I(r, "ID") }, { "courseCode", S(r, "course_code") }, { "courseName", S(r, "courseName") },
                { "progcode", S(r, "progcode") }, { "progname", S(r, "progname") }, { "studyYear", I(r, "study_year") },
                { "semester", I(r, "semester") }, { "courseType", S(r, "course_type") }, { "lecturerId", I(r, "lecturer_id") },
                { "lecturerName", S(r, "lecturer_name") }, { "sessions", I(r, "sessions") } });
        return new { ok = true, rows = rows, total = total, page = page, pages = pages };
    }

    // ── items for one programme-course ──
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object GetItems(int pcId)
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        Dictionary<string, object> pc = LoadPc(pcId);
        if (pc == null) return new { ok = false, message = "Programme-course not found." };
        List<object> items = new List<object>();
        DataTable dt = TimetableService.Query(
            "SELECT it.item_id, it.day_no, w.DayName, TIME_FORMAT(it.start_time,'%H:%i') st, it.duration_min, TIME_FORMAT(it.end_time,'%H:%i') et, " +
            "IFNULL(it.teacher_id,0) teacher_id, IFNULL(e.emp_name,'') teacher_name, it.campus_id, IFNULL(cp.campus_name,'') campus_name, " +
            "IFNULL(it.building_id,0) building_id, IFNULL(b.building_name,'') building_name, IFNULL(it.room_id,0) room_id, IFNULL(r.RoomName,'') room_name, " +
            "IFNULL(it.room_label,'') room_label, it.session_type, it.delivery_mode, IFNULL(it.meet_link,'') meet_link, IFNULL(it.description,'') description, IFNULL(it.status,'ACTIVE') status " +
            "FROM acad_timetable_item it LEFT JOIN acad_timetable_weekdays w ON w.DayNo=it.day_no LEFT JOIN hrm_employee e ON e.empID=it.teacher_id " +
            "LEFT JOIN acad_campuses cp ON cp.ID=it.campus_id LEFT JOIN acad_building b ON b.building_id=it.building_id LEFT JOIN acad_lecturerooms r ON r.RoomID=it.room_id " +
            "WHERE it.programmecourse_id=@pc ORDER BY FIELD(it.status,'ACTIVE','DRAFT','ARCHIVED'), it.day_no, it.start_time",
            P("@pc", pcId));
        foreach (DataRow r in dt.Rows)
            items.Add(new Dictionary<string, object> {
                { "id", I(r, "item_id") }, { "dayNo", I(r, "day_no") }, { "dayName", S(r, "DayName") }, { "start", S(r, "st") }, { "durationMin", I(r, "duration_min") }, { "end", S(r, "et") },
                { "teacherId", I(r, "teacher_id") }, { "teacherName", S(r, "teacher_name") }, { "campusId", I(r, "campus_id") }, { "campusName", S(r, "campus_name") },
                { "buildingId", I(r, "building_id") }, { "buildingName", S(r, "building_name") }, { "roomId", I(r, "room_id") }, { "roomName", S(r, "room_name") },
                { "roomLabel", S(r, "room_label") }, { "sessionType", S(r, "session_type") }, { "deliveryMode", S(r, "delivery_mode") }, { "meetLink", S(r, "meet_link") }, { "description", S(r, "description") }, { "status", S(r, "status") } });
        return new { ok = true, items = items, pc = pc };
    }

    private static Dictionary<string, object> LoadPc(int pcId)
    {
        DataTable dt = TimetableService.Query(
            "SELECT pc.ID, pc.progcode, IFNULL(p.progname,'') progname, TRIM(pc.course_code) course_code, IFNULL(c.courseName,'') courseName, " +
            "IFNULL(pc.study_year,1) study_year, IFNULL(pc.semester,1) semester, IFNULL(pc.lecturer_id,0) lecturer_id, IFNULL(e.emp_name,'') lecturer_name " +
            "FROM acad_programmecourses pc LEFT JOIN acad_programme p ON pc.progcode=p.progcode LEFT JOIN acad_course c ON pc.course_code=c.courseID LEFT JOIN hrm_employee e ON e.empID=pc.lecturer_id WHERE pc.ID=@id",
            P("@id", pcId));
        if (dt.Rows.Count == 0) return null;
        DataRow r = dt.Rows[0];
        return new Dictionary<string, object> {
            { "id", I(r, "ID") }, { "progcode", S(r, "progcode") }, { "progname", S(r, "progname") }, { "courseCode", S(r, "course_code") }, { "courseName", S(r, "courseName") },
            { "studyYear", I(r, "study_year") }, { "semester", I(r, "semester") }, { "lecturerId", I(r, "lecturer_id") }, { "lecturerName", S(r, "lecturer_name") } };
    }

    // ── live conflict preview ──
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object PreviewConflicts(int itemId, int pcId, int dayNo, string start, int durationMin, int roomId, int teacherId, int campusId)
    {
        if (!Authed()) return Denied();
        Dictionary<string, object> pc = LoadPc(pcId);
        if (pc == null) return new { ok = false, message = "Programme-course not found." };
        int effTeacher = teacherId > 0 ? teacherId : Convert.ToInt32(pc["lecturerId"]);
        List<TimetableService.Conflict> cs = TimetableService.CheckConflicts(itemId, dayNo, start, durationMin, roomId, effTeacher,
            Convert.ToString(pc["progcode"]), Convert.ToInt32(pc["studyYear"]), Convert.ToInt32(pc["semester"]), campusId);
        List<object> outc = new List<object>();
        foreach (TimetableService.Conflict c in cs) outc.Add(new Dictionary<string, object> { { "kind", c.Kind }, { "message", c.Message } });
        return new { ok = true, conflicts = outc };
    }

    // ── save an item ──
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object SaveItem(int itemId, int pcId, int dayNo, string start, int durationMin,
        int teacherId, int campusId, int buildingId, int roomId, string roomLabel, string sessionType, string deliveryMode, string meetLink, string description, string status, int allowConflicts, int setCourseLecturer)
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        try
        {
            Dictionary<string, object> pc = LoadPc(pcId);
            if (pc == null) return new { ok = false, message = "Programme-course not found." };
            if (dayNo < 1 || dayNo > 7) return new { ok = false, message = "Pick a valid weekday." };
            if (durationMin <= 0) durationMin = 60;
            string st = TimetableService.NormTime(start);
            string et = TimetableService.EndTime(start, durationMin);
            if (string.Compare(et, st) <= 0) return new { ok = false, message = "End time must be after start time." };

            string stat = (status ?? "ACTIVE").Trim().ToUpperInvariant(); if (stat != "DRAFT" && stat != "ARCHIVED") stat = "ACTIVE";
            int effTeacher = teacherId > 0 ? teacherId : Convert.ToInt32(pc["lecturerId"]);
            if (stat == "ACTIVE" && allowConflicts != 1)
            {
                List<TimetableService.Conflict> cs = TimetableService.CheckConflicts(itemId, dayNo, start, durationMin, roomId, effTeacher,
                    Convert.ToString(pc["progcode"]), Convert.ToInt32(pc["studyYear"]), Convert.ToInt32(pc["semester"]), campusId);
                if (cs.Count > 0)
                {
                    List<object> outc = new List<object>();
                    foreach (TimetableService.Conflict c in cs) outc.Add(new Dictionary<string, object> { { "kind", c.Kind }, { "message", c.Message } });
                    return new { ok = false, needsOverride = true, conflicts = outc };
                }
            }

            object bId = buildingId > 0 ? (object)buildingId : null;
            object rId = roomId > 0 ? (object)roomId : null;
            object tId = teacherId > 0 ? (object)teacherId : null;
            string prog = Convert.ToString(pc["progcode"]);
            string ccode = Convert.ToString(pc["courseCode"]);
            int sy = Convert.ToInt32(pc["studyYear"]);
            int sem = Convert.ToInt32(pc["semester"]);
            string who = Actor();

            if (itemId > 0)
            {
                TimetableService.Exec(
                    "UPDATE acad_timetable_item SET progcode=@prog, course_code=@cc, study_year=@sy, semester=@sem, day_no=@day, start_time=@st, duration_min=@dur, end_time=@et, " +
                    "teacher_id=@t, campus_id=@cp, building_id=@b, room_id=@r, room_label=@rl, session_type=@stype, delivery_mode=@dmode, meet_link=@ml, description=@desc, status=@status, updated_by=@who, updated_at=NOW() " +
                    "WHERE item_id=@id AND programmecourse_id=@pc",
                    P("@prog", prog), P("@cc", ccode), P("@sy", sy), P("@sem", sem), P("@day", dayNo), P("@st", st), P("@dur", durationMin), P("@et", et),
                    P("@t", tId), P("@cp", campusId), P("@b", bId), P("@r", rId), P("@rl", roomLabel), P("@stype", (sessionType ?? "LECTURE").ToUpperInvariant()), P("@dmode", (deliveryMode ?? "PHYSICAL").ToUpperInvariant()),
                    P("@ml", meetLink), P("@desc", description), P("@status", stat), P("@who", who), P("@id", itemId), P("@pc", pcId));
            }
            else
            {
                TimetableService.Exec(
                    "INSERT INTO acad_timetable_item (programmecourse_id, acad_year, progcode, course_code, study_year, semester, day_no, start_time, duration_min, end_time, " +
                    "teacher_id, campus_id, building_id, room_id, room_label, session_type, delivery_mode, meet_link, description, status, created_by, created_at) " +
                    "VALUES (@pc,'',@prog,@cc,@sy,@sem,@day,@st,@dur,@et,@t,@cp,@b,@r,@rl,@stype,@dmode,@ml,@desc,@status,@who,NOW())",
                    P("@pc", pcId), P("@prog", prog), P("@cc", ccode), P("@sy", sy), P("@sem", sem), P("@day", dayNo), P("@st", st), P("@dur", durationMin), P("@et", et),
                    P("@t", tId), P("@cp", campusId), P("@b", bId), P("@r", rId), P("@rl", roomLabel), P("@stype", (sessionType ?? "LECTURE").ToUpperInvariant()), P("@dmode", (deliveryMode ?? "PHYSICAL").ToUpperInvariant()),
                    P("@ml", meetLink), P("@desc", description), P("@status", stat), P("@who", who));
                object nid = TimetableService.Scalar("SELECT LAST_INSERT_ID()");
                itemId = nid == null || nid == DBNull.Value ? 0 : Convert.ToInt32(nid);
            }

            // Optionally promote the chosen lecturer to be the course's default lecturer.
            // Only acts on an explicit request, with a real teacher, and only when it
            // actually differs from (or fills) the current course lecturer.
            bool courseLecturerSet = false;
            string setLecturerName = "";
            int curCourseLecturer = Convert.ToInt32(pc["lecturerId"]);
            if (setCourseLecturer == 1 && teacherId > 0 && teacherId != curCourseLecturer)
            {
                int changed = TimetableService.Exec(
                    "UPDATE acad_programmecourses SET lecturer_id=@t WHERE ID=@pc",
                    P("@t", teacherId), P("@pc", pcId));
                if (changed > 0)
                {
                    courseLecturerSet = true;
                    object nm = TimetableService.Scalar("SELECT IFNULL(emp_name,'') FROM hrm_employee WHERE empID=@t", P("@t", teacherId));
                    setLecturerName = nm == null || nm == DBNull.Value ? "" : Convert.ToString(nm);
                }
            }
            return new { ok = true, id = itemId, courseLecturerSet = courseLecturerSet, lecturerName = setLecturerName };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object DeleteItem(int itemId)
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        try { TimetableService.Exec("DELETE FROM acad_timetable_item WHERE item_id=@id", P("@id", itemId)); return new { ok = true }; }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    // Duplicate a session as a DRAFT so it can be tweaked before going live.
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object DuplicateItem(int itemId)
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        try
        {
            int n = TimetableService.Exec(
                "INSERT INTO acad_timetable_item (programmecourse_id, acad_year, progcode, course_code, study_year, semester, day_no, start_time, duration_min, end_time, teacher_id, campus_id, building_id, room_id, room_label, session_type, delivery_mode, meet_link, description, status, created_by, created_at) " +
                "SELECT programmecourse_id, acad_year, progcode, course_code, study_year, semester, day_no, start_time, duration_min, end_time, teacher_id, campus_id, building_id, room_id, room_label, session_type, delivery_mode, meet_link, description, 'DRAFT', @who, NOW() " +
                "FROM acad_timetable_item WHERE item_id=@id",
                P("@who", Actor()), P("@id", itemId));
            return new { ok = n > 0 };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    // ── Legacy import (acad_timetable -> acad_timetable_item), deduped across years ──
    // Perpetual timetable: collapse legacy rows to one per (programme-course, day, start).
    private const string ImportJoins =
        "FROM acad_timetable t " +
        "JOIN acad_programmecourses pc ON pc.ID=(SELECT MIN(pc2.ID) FROM acad_programmecourses pc2 WHERE TRIM(pc2.progcode)=TRIM(t.programme_code) AND TRIM(pc2.course_code)=TRIM(t.course_code) AND pc2.study_year=t.study_year AND pc2.semester=t.semester) " +
        "JOIN acad_timetable_weekdays w ON UPPER(TRIM(w.DayName))=UPPER(TRIM(t.day_of_week)) " +
        "LEFT JOIN acad_lecturerooms rr ON t.room REGEXP '^[0-9]+$' AND rr.RoomID=CAST(t.room AS UNSIGNED) ";

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object ImportPreview()
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        try
        {
            object distinct = TimetableService.Scalar("SELECT COUNT(*) FROM (SELECT pc.ID pid, w.DayNo dno, CAST(t.start_time AS TIME) st " + ImportJoins + "WHERE CAST(t.end_time AS TIME) > CAST(t.start_time AS TIME) GROUP BY pc.ID, w.DayNo, CAST(t.start_time AS TIME)) x");
            object already = TimetableService.Scalar("SELECT COUNT(*) FROM (SELECT pc.ID pid, w.DayNo dno, CAST(t.start_time AS TIME) st " + ImportJoins + "WHERE CAST(t.end_time AS TIME) > CAST(t.start_time AS TIME) AND EXISTS (SELECT 1 FROM acad_timetable_item it WHERE it.programmecourse_id=pc.ID AND it.day_no=w.DayNo AND it.start_time=CAST(t.start_time AS TIME)) GROUP BY pc.ID, w.DayNo, CAST(t.start_time AS TIME)) x");
            object unmatched = TimetableService.Scalar("SELECT COUNT(*) FROM acad_timetable t WHERE NOT EXISTS (SELECT 1 FROM acad_programmecourses pc WHERE TRIM(pc.progcode)=TRIM(t.programme_code) AND TRIM(pc.course_code)=TRIM(t.course_code) AND pc.study_year=t.study_year AND pc.semester=t.semester)");
            return new { ok = true, distinct = Convert.ToInt32(distinct), already = Convert.ToInt32(already), unmatched = Convert.ToInt32(unmatched) };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object ImportRun()
    {
        if (!Authed()) return Denied();
        TimetableService.EnsureSchema();
        try
        {
            int n = TimetableService.Exec(
                "INSERT INTO acad_timetable_item (programmecourse_id, acad_year, progcode, course_code, study_year, semester, day_no, start_time, duration_min, end_time, teacher_id, campus_id, room_id, room_label, session_type, delivery_mode, status, created_by, created_at) " +
                "SELECT pc.ID, '', pc.progcode, TRIM(pc.course_code), pc.study_year, pc.semester, w.DayNo, CAST(t.start_time AS TIME), " +
                "GREATEST(30, TIME_TO_SEC(TIMEDIFF(MAX(CAST(t.end_time AS TIME)), CAST(t.start_time AS TIME)))/60), MAX(CAST(t.end_time AS TIME)), " +
                "NULLIF(MAX(t.lecturer_id),0), IFNULL(MAX(t.campusId),0), MAX(rr.RoomID), IFNULL(MAX(t.building),''), 'LECTURE', 'PHYSICAL', 'ACTIVE', 'legacy_import', NOW() " +
                ImportJoins +
                "WHERE CAST(t.end_time AS TIME) > CAST(t.start_time AS TIME) " +
                "AND NOT EXISTS (SELECT 1 FROM acad_timetable_item it WHERE it.programmecourse_id=pc.ID AND it.day_no=w.DayNo AND it.start_time=CAST(t.start_time AS TIME)) " +
                "GROUP BY pc.ID, w.DayNo, CAST(t.start_time AS TIME)");
            return new { ok = true, imported = n };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }
}
