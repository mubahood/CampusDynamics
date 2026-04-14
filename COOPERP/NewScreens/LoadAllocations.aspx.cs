using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// LoadAllocations.aspx.cs — Code-behind for Teaching Allocations management page.
///
/// AJAX Endpoints (via ?ajax=...):
///   GET  ?ajax=dropdowns                — reference data (programmes, lecturers, rooms, years) + session context
///   GET  ?ajax=list[&amp;prog=&amp;yr=&amp;entry=&amp;sess=] — allocation grid with stats + entry years
///   GET  ?ajax=courses&amp;prog=&amp;yr=&amp;sem=  — cascading courses for modal (filtered by programme/year/semester)
///   POST ?ajax=checkconflict             — room + lecturer collision check (JSON body)
///   POST ?ajax=create                    — create new allocation (JSON body)
///   POST ?ajax=update                    — update allocation   (JSON body)
///   POST ?ajax=delete                    — delete allocation   (JSON body: {id})
///   GET  ?ajax=copypreview&amp;srcYear=&amp;srcSem=&amp;prog=&amp;yr= — preview batch copy count
///   POST ?ajax=copy                      — execute batch copy from previous semester (JSON body)
///   GET  ?ajax=adoptpreview&amp;srcEntry=&amp;dstEntry=&amp;prog=&amp;yr= — preview adopt entry year count
///   POST ?ajax=adopt                     — adopt allocations to different entry year (JSON body)
///   POST ?ajax=bulkdelete                — delete multiple allocations by ID (JSON body: {ids:[...]})
///
/// Tables:
///   acad_teaching_allocation — main allocation records (CRUD target)
///   acad_programme           — programme list (read-only dropdown)
///   acad_programmecourses    — programme-course links (read-only, course filtering)
///   acad_course              — course catalog (read-only)
///   hrm_employee             — lecturer list (read-only, staffCode = empID as string)
///   acad_lecturerooms        — room list (read-only)
///   acad_campuses            — campus list (read-only)
///
/// Design Rules:
///   - C# 4.0 compatible: no ?. operator, no string interpolation ($"")
///   - vacConnectionString only — no hardcoded credentials
///   - Session["SelectedAcademicYear"], Session["SelectedSemester"], Session["SelectedCampus"] from master
///   - staffCode stores empID (integer) as a string — CAST(staffCode AS UNSIGNED) = empID for JOINs
///   - acad_programmecourses uses course_code (not courseID) and study_year (not studyYear)
///   - AllocationHelper.cs for collision detection (Task 9)
///   - Audit trail: created_by/created_at/updated_by/updated_at on every CUD
///
/// Task: LOAD_ALLOCATION_TASKS.md — Task 5
/// Implementation Log: LOAD_ALLOCATION_IMPLEMENTATION_LOG.md
/// Created: 2026-04-10
/// </summary>
public partial class COOPERP_NewScreens_LoadAllocations : System.Web.UI.Page
{
    // ─────────────────────── Connection ──────────────────────────────────

    private string ConnStr
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        }
    }

    // ─────────────────────── Helpers ─────────────────────────────────────

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private object ExecuteScalar(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteScalar();
            }
        }
    }

    private string RespondJson(object obj)
    {
        JavaScriptSerializer ser = new JavaScriptSerializer();
        ser.MaxJsonLength = int.MaxValue;
        string json = ser.Serialize(obj);
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Write(json);
        Response.End();
        return null;                // never reached; calms the compiler
    }

    private string GetSession(string key)
    {
        if (Session[key] == null) return "";
        return Session[key].ToString();
    }

    private string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int result;
        if (int.TryParse(val.ToString(), out result)) return result;
        return 0;
    }

    // ─────────────────────── Lifecycle ───────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        try
        {
            // Parse composite ajax key (e.g. "list&prog=BICT&yr=2") — only first token is the action
            string action = ajax;
            int ampIdx = ajax.IndexOf('&');
            if (ampIdx > 0) action = ajax.Substring(0, ampIdx);

            switch (action)
            {
                case "dropdowns":    HandleDropdowns();    break;
                case "list":         HandleList();         break;
                case "courses":      HandleCourses();      break;
                case "checkconflict":HandleCheckConflict();break;
                case "create":       HandleCreate();       break;
                case "update":       HandleUpdate();       break;
                case "delete":       HandleDelete();       break;
                case "copypreview":  HandleCopyPreview();  break;
                case "copy":         HandleCopy();         break;
                case "adoptpreview": HandleAdoptPreview(); break;
                case "adopt":        HandleAdopt();        break;
                case "bulkdelete":   HandleBulkDelete();   break;
                default:
                    RespondJson(new { ok = false, error = "Unknown action: " + action });
                    break;
            }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            RespondJson(new { ok = false, error = "Server error: " + ex.Message });
        }
    }

    // ─────────────────────── Session Context ─────────────────────────────

    /// <summary>Current academic year from master page (e.g. "2025/2026").</summary>
    private string CurrentAcadYear
    {
        get
        {
            string v = GetSession("SelectedAcademicYear");
            if (string.IsNullOrEmpty(v)) v = AcademicYearHelper.GetCurrentAcademicYear();
            return v;
        }
    }

    /// <summary>Current semester from master page (e.g. "1" or "2").</summary>
    private string CurrentSemester
    {
        get
        {
            string v = GetSession("SelectedSemester");
            if (string.IsNullOrEmpty(v)) v = "1";
            return v;
        }
    }

    /// <summary>Current campus ID from master page (e.g. "1").</summary>
    private string CurrentCampusId
    {
        get
        {
            string v = GetSession("SelectedCampus");
            if (string.IsNullOrEmpty(v)) v = "0";
            return v;
        }
    }

    /// <summary>Current campus name for display.</summary>
    private string CurrentCampusName
    {
        get
        {
            string id = CurrentCampusId;
            if (id == "0") return "All Campuses";
            DataTable dt = ExecuteQuery(
                "SELECT campus_name FROM acad_campuses WHERE ID = @id",
                new MySqlParameter("@id", id));
            if (dt.Rows.Count > 0) return SafeStr(dt.Rows[0]["campus_name"]);
            return "Campus " + id;
        }
    }

    // ─────────────────────── AJAX: dropdowns ─────────────────────────────

    /// <summary>
    /// Returns all reference data needed to populate filters, modal dropdowns, and context band.
    /// Called once on page load by loadDropdowns() in JS.
    /// </summary>
    private void HandleDropdowns()
    {
        string acadYear  = CurrentAcadYear;
        string semester  = CurrentSemester;
        string campusId  = CurrentCampusId;
        string campusName = CurrentCampusName;

        // ── Programmes ──────────────────────────────────────────────────
        DataTable dtProg = ExecuteQuery(
            "SELECT progcode, CONCAT(abbrev, ' - ', progname) AS display FROM acad_programme ORDER BY abbrev, progname");
        List<object> programmes = new List<object>();
        foreach (DataRow r in dtProg.Rows)
        {
            programmes.Add(new { code = SafeStr(r["progcode"]), display = SafeStr(r["display"]) });
        }

        // ── Lecturers (all employees — filter to academic/part-time in UI) ──
        DataTable dtLec = ExecuteQuery(@"
            SELECT e.empID, CONCAT(e.emp_name, ' (', IFNULL(e.EMP_CODE,''), ')') AS display
            FROM   hrm_employee e
            ORDER BY e.emp_name");
        List<object> lecturers = new List<object>();
        foreach (DataRow r in dtLec.Rows)
        {
            lecturers.Add(new {
                id      = SafeStr(r["empID"]),
                display = SafeStr(r["display"])
            });
        }

        // ── Rooms (filtered by campus if campus != 0 / ALL) ─────────────
        string roomSql = @"
            SELECT lr.RoomID, CONCAT(lr.RoomName, ' (Cap: ', lr.Capacity, ')') AS display
            FROM   acad_lecturerooms lr";
        List<MySqlParameter> roomParms = new List<MySqlParameter>();
        if (campusId != "0" && !string.IsNullOrEmpty(campusId))
        {
            roomSql += " WHERE lr.campusId = @campus";
            roomParms.Add(new MySqlParameter("@campus", campusId));
        }
        roomSql += " ORDER BY lr.RoomName";
        DataTable dtRooms = ExecuteQuery(roomSql, roomParms.ToArray());
        List<object> rooms = new List<object>();
        foreach (DataRow r in dtRooms.Rows)
        {
            rooms.Add(new {
                id      = SafeStr(r["RoomID"]),
                display = SafeStr(r["display"])
            });
        }

        // ── Entry Years (distinct from current acad_year allocations) ────
        DataTable dtEntry = ExecuteQuery(@"
            SELECT DISTINCT EntryYear AS val
            FROM   acad_teaching_allocation
            WHERE  acad_year = @year AND EntryYear IS NOT NULL AND EntryYear != ''
            ORDER BY EntryYear DESC",
            new MySqlParameter("@year", acadYear));
        List<object> entryYears = new List<object>();
        foreach (DataRow r in dtEntry.Rows)
        {
            string v = SafeStr(r["val"]);
            if (!string.IsNullOrEmpty(v) && v != "0")
                entryYears.Add(new { val = v });
        }

        // ── All Academic Years (for batch copy source picker) ────────────
        DataTable dtYears = ExecuteQuery(@"
            SELECT DISTINCT acad_year AS val
            FROM   acad_teaching_allocation
            ORDER BY acad_year DESC");
        List<object> allYears = new List<object>();
        foreach (DataRow r in dtYears.Rows)
        {
            allYears.Add(new { val = SafeStr(r["val"]) });
        }

        RespondJson(new {
            acadYear   = acadYear,
            semester   = semester,
            campusId   = campusId,
            campusName = campusName,
            programmes = programmes,
            lecturers  = lecturers,
            rooms      = rooms,
            entryYears = entryYears,
            allYears   = allYears
        });
    }

    // ─────────────────────── AJAX: list ──────────────────────────────────

    /// <summary>
    /// Returns the allocation grid data for the current academic year/semester/campus,
    /// optionally filtered by programme, study year, entry year, and session.
    /// Also returns summary stats and distinct entry years for the filter dropdown.
    /// </summary>
    private void HandleList()
    {
        string acadYear = CurrentAcadYear;
        string semester = CurrentSemester;
        string campusId = CurrentCampusId;

        // Read optional filters from query string
        string prog  = (Request.QueryString["prog"]  ?? "").Trim();
        string yr    = (Request.QueryString["yr"]    ?? "").Trim();
        string entry = (Request.QueryString["entry"] ?? "").Trim();
        string sess  = (Request.QueryString["sess"]  ?? "").Trim();

        // Build dynamic WHERE
        string where = "ta.acad_year = @year AND ta.semester = @sem";
        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@year", acadYear));
        parms.Add(new MySqlParameter("@sem",  semester));

        if (campusId != "0" && !string.IsNullOrEmpty(campusId))
        {
            where += " AND ta.campusId = @campus";
            parms.Add(new MySqlParameter("@campus", campusId));
        }
        if (!string.IsNullOrEmpty(prog))
        {
            where += " AND ta.progcode = @prog";
            parms.Add(new MySqlParameter("@prog", prog));
        }
        if (!string.IsNullOrEmpty(yr))
        {
            where += " AND ta.cyear = @cyear";
            parms.Add(new MySqlParameter("@cyear", yr));
        }
        if (!string.IsNullOrEmpty(entry))
        {
            where += " AND ta.EntryYear = @entry";
            parms.Add(new MySqlParameter("@entry", entry));
        }
        if (!string.IsNullOrEmpty(sess))
        {
            where += " AND ta.stud_session = @sess";
            parms.Add(new MySqlParameter("@sess", sess));
        }

        // Main query — heavy lifting
        string sql = string.Format(@"
            SELECT ta.ID, ta.staffCode,
                   IFNULL(e.emp_name, '') AS lecturerName,
                   IFNULL(e.EMP_CODE, '') AS empCode,
                   ta.courseID AS courseCode,
                   IFNULL(c.courseName, ta.courseID) AS courseName,
                   IFNULL(c.CreditUnit, 0) AS creditUnit,
                   ta.progcode, ta.cyear,
                   IFNULL(ta.lectureday, '-') AS lectureday,
                   ta.StartTime AS startTime,
                   ta.EndTime AS endTime,
                   IFNULL(ta.roomNo, '') AS roomNo,
                   IFNULL(lr.RoomName, '') AS roomName,
                   IFNULL(ta.stud_session, 'DAY') AS session,
                   IFNULL(ta.EntryYear, '') AS entryYear,
                   IFNULL(ta.intake, '') AS intake,
                   IFNULL(ta.stream, '-') AS stream
            FROM   acad_teaching_allocation ta
            LEFT JOIN hrm_employee e      ON e.empID   = CAST(ta.staffCode AS UNSIGNED)
            LEFT JOIN acad_course c       ON c.courseID = ta.courseID
            LEFT JOIN acad_lecturerooms lr ON lr.RoomID = CAST(ta.roomNo AS UNSIGNED)
            WHERE  {0}
            ORDER BY ta.lectureday, ta.StartTime, c.courseName
            LIMIT 2000", where);

        DataTable dt = ExecuteQuery(sql, parms.ToArray());

        List<object> rows = new List<object>();
        int totalCount  = 0;
        int schedCount  = 0;
        int unschedCount = 0;
        HashSet<string> lecturerSet = new HashSet<string>();
        HashSet<string> entryYearSet = new HashSet<string>();

        foreach (DataRow r in dt.Rows)
        {
            totalCount++;
            string day = SafeStr(r["lectureday"]);
            if (day != "-" && !string.IsNullOrEmpty(day)) schedCount++;
            else unschedCount++;

            string sc = SafeStr(r["staffCode"]);
            if (sc != "0" && !string.IsNullOrEmpty(sc)) lecturerSet.Add(sc);

            string ey = SafeStr(r["entryYear"]);
            if (!string.IsNullOrEmpty(ey) && ey != "0") entryYearSet.Add(ey);

            rows.Add(new {
                id           = SafeInt(r["ID"]),
                staffCode    = sc,
                lecturerName = SafeStr(r["lecturerName"]),
                empCode      = SafeStr(r["empCode"]),
                courseCode   = SafeStr(r["courseCode"]),
                courseName   = SafeStr(r["courseName"]),
                creditUnit   = SafeInt(r["creditUnit"]),
                progcode     = SafeStr(r["progcode"]),
                cyear        = SafeStr(r["cyear"]),
                lectureday   = day,
                startTime    = SafeStr(r["startTime"]),
                endTime      = SafeStr(r["endTime"]),
                roomNo       = SafeStr(r["roomNo"]),
                roomName     = SafeStr(r["roomName"]),
                session      = SafeStr(r["session"]),
                entryYear    = ey,
                intake       = SafeStr(r["intake"]),
                stream       = SafeStr(r["stream"])
            });
        }

        // Build entry years list for filter dropdown
        List<object> entryYears = new List<object>();
        List<string> eyList = new List<string>(entryYearSet);
        eyList.Sort();
        eyList.Reverse();
        foreach (string ey in eyList)
        {
            entryYears.Add(new { val = ey });
        }

        RespondJson(new {
            rows       = rows,
            stats      = new {
                total       = totalCount,
                scheduled   = schedCount,
                unscheduled = unschedCount,
                lecturers   = lecturerSet.Count
            },
            entryYears = entryYears
        });
    }

    // ─────────────────────── AJAX: courses ───────────────────────────────

    /// <summary>
    /// Returns courses for the modal dropdown, filtered by programme + study year + semester
    /// from acad_programmecourses. This ensures the user only sees courses assigned
    /// to the programme for the specific year/semester (unlike classic which shows all).
    /// </summary>
    private void HandleCourses()
    {
        string prog = (Request.QueryString["prog"] ?? "").Trim();
        string yr   = (Request.QueryString["yr"]   ?? "").Trim();
        string sem  = (Request.QueryString["sem"]  ?? "").Trim();

        if (string.IsNullOrEmpty(prog))
        {
            RespondJson(new { courses = new List<object>() });
            return;
        }

        // Build query with optional year/semester filters
        string sql = @"
            SELECT DISTINCT pc.course_code,
                   CONCAT(c.courseID, ' - ', IFNULL(c.courseName, pc.course_code),
                          ' (', IFNULL(c.CreditUnit, 0), ' CU)') AS display
            FROM   acad_programmecourses pc
            LEFT JOIN acad_course c ON c.courseID = pc.course_code
            WHERE  pc.progcode = @prog";
        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@prog", prog));

        if (!string.IsNullOrEmpty(yr))
        {
            sql += " AND pc.study_year = @yr";
            parms.Add(new MySqlParameter("@yr", yr));
        }
        if (!string.IsNullOrEmpty(sem))
        {
            sql += " AND pc.semester = @sem";
            parms.Add(new MySqlParameter("@sem", sem));
        }
        sql += " ORDER BY c.courseName, pc.course_code";

        DataTable dt = ExecuteQuery(sql, parms.ToArray());

        List<object> courses = new List<object>();
        foreach (DataRow r in dt.Rows)
        {
            courses.Add(new {
                code    = SafeStr(r["course_code"]),
                display = SafeStr(r["display"])
            });
        }

        RespondJson(new { courses = courses });
    }

    // ─────────────────────── AJAX: checkconflict ─────────────────────────

    /// <summary>
    /// Checks for room and lecturer scheduling conflicts using AllocationHelper.
    /// Returns a list of human-readable conflict messages (may be empty).
    /// Soft check — the UI shows warnings but allows saving.
    /// </summary>
    private void HandleCheckConflict()
    {
        AllocPayload p = ReadPayload();
        if (p == null) return;

        string acadYear = CurrentAcadYear;
        string semester = CurrentSemester;
        string campusId = CurrentCampusId;

        List<string> messages = new List<string>();

        // Room collision
        if (!string.IsNullOrEmpty(p.roomNo) && !string.IsNullOrEmpty(p.lectureday) && p.lectureday != "-")
        {
            List<AllocationHelper.ConflictInfo> roomConf = AllocationHelper.CheckRoomCollision(
                p.roomNo, p.lectureday, p.startTime, p.endTime,
                acadYear, semester, campusId, p.id);
            foreach (AllocationHelper.ConflictInfo ci in roomConf)
                messages.Add(ci.Message);
        }

        // Lecturer collision
        if (!string.IsNullOrEmpty(p.staffCode) && p.staffCode != "0"
            && !string.IsNullOrEmpty(p.lectureday) && p.lectureday != "-")
        {
            List<AllocationHelper.ConflictInfo> lecConf = AllocationHelper.CheckLecturerCollision(
                p.staffCode, p.lectureday, p.startTime, p.endTime,
                acadYear, semester, p.id);
            foreach (AllocationHelper.ConflictInfo ci in lecConf)
                messages.Add(ci.Message);
        }

        RespondJson(new { conflicts = messages });
    }

    // ─────────────────────── AJAX: create ────────────────────────────────

    /// <summary>
    /// Creates a new teaching allocation record.
    /// Validates required fields, checks for exact duplicates, then INSERTs.
    /// Populates audit trail (created_by, created_at).
    /// </summary>
    private void HandleCreate()
    {
        AllocPayload p = ReadPayload();
        if (p == null) return;

        string valErr = ValidatePayload(p);
        if (valErr != null)
        {
            RespondJson(new { ok = false, error = valErr });
            return;
        }

        string acadYear = CurrentAcadYear;
        string semester = CurrentSemester;
        string campusId = CurrentCampusId;
        string user     = AllocationHelper.GetCurrentUser();

        // Duplicate check (same lecturer + course + prog + year + semester + entry + session + day)
        DataTable dup = ExecuteQuery(@"
            SELECT COUNT(*) AS cnt FROM acad_teaching_allocation
            WHERE  staffCode    = @staff
              AND  courseID     = @course
              AND  progcode    = @prog
              AND  acad_year   = @year
              AND  semester    = @sem
              AND  cyear       = @cyear
              AND  EntryYear   = @entry
              AND  stud_session = @sess
              AND  lectureday  = @day",
            new MySqlParameter("@staff",  p.staffCode),
            new MySqlParameter("@course", p.courseCode),
            new MySqlParameter("@prog",   p.progcode),
            new MySqlParameter("@year",   acadYear),
            new MySqlParameter("@sem",    semester),
            new MySqlParameter("@cyear",  p.cyear),
            new MySqlParameter("@entry",  p.entryYear > 0 ? p.entryYear.ToString() : ""),
            new MySqlParameter("@sess",   p.session),
            new MySqlParameter("@day",    p.lectureday));

        if (Convert.ToInt32(dup.Rows[0]["cnt"]) > 0)
        {
            RespondJson(new { ok = false, error = "A matching allocation already exists (same lecturer, course, programme, year, semester, entry year, session, and day)." });
            return;
        }

        // INSERT
        int rows = ExecuteNonQuery(@"
            INSERT INTO acad_teaching_allocation
                (staffCode, courseID, acad_year, semester, progcode, cyear,
                 stud_session, intake, stream, campusId,
                 lectureday, StartTime, EndTime, roomNo, EntryYear,
                 created_by, created_at)
            VALUES
                (@staff, @course, @year, @sem, @prog, @cyear,
                 @sess, @intake, @stream, @campus,
                 @day, @start, @end, @room, @entry,
                 @user, NOW())",
            new MySqlParameter("@staff",   p.staffCode),
            new MySqlParameter("@course",  p.courseCode),
            new MySqlParameter("@year",    acadYear),
            new MySqlParameter("@sem",     semester),
            new MySqlParameter("@prog",    p.progcode),
            new MySqlParameter("@cyear",   p.cyear),
            new MySqlParameter("@sess",    p.session),
            new MySqlParameter("@intake",  string.IsNullOrEmpty(p.intake) ? "" : p.intake),
            new MySqlParameter("@stream",  string.IsNullOrEmpty(p.stream) ? "-" : p.stream),
            new MySqlParameter("@campus",  campusId),
            new MySqlParameter("@day",     p.lectureday),
            new MySqlParameter("@start",   (p.lectureday != "-" && !string.IsNullOrEmpty(p.startTime)) ? (object)p.startTime : DBNull.Value),
            new MySqlParameter("@end",     (p.lectureday != "-" && !string.IsNullOrEmpty(p.endTime))   ? (object)p.endTime   : DBNull.Value),
            new MySqlParameter("@room",    !string.IsNullOrEmpty(p.roomNo) ? p.roomNo : "8"),
            new MySqlParameter("@entry",   p.entryYear > 0 ? p.entryYear.ToString() : ""),
            new MySqlParameter("@user",    user));

        if (rows > 0)
            RespondJson(new { ok = true });
        else
            RespondJson(new { ok = false, error = "Insert failed — no rows affected." });
    }

    // ─────────────────────── AJAX: update ────────────────────────────────

    /// <summary>
    /// Updates an existing teaching allocation record.
    /// Validates, then UPDATEs with audit trail (updated_by, updated_at).
    /// </summary>
    private void HandleUpdate()
    {
        AllocPayload p = ReadPayload();
        if (p == null) return;

        if (p.id <= 0)
        {
            RespondJson(new { ok = false, error = "Invalid allocation ID." });
            return;
        }

        string valErr = ValidatePayload(p);
        if (valErr != null)
        {
            RespondJson(new { ok = false, error = valErr });
            return;
        }

        string user = AllocationHelper.GetCurrentUser();

        int rows = ExecuteNonQuery(@"
            UPDATE acad_teaching_allocation SET
                staffCode    = @staff,
                courseID     = @course,
                progcode     = @prog,
                cyear        = @cyear,
                stud_session = @sess,
                intake       = @intake,
                stream       = @stream,
                lectureday   = @day,
                StartTime    = @start,
                EndTime      = @end,
                roomNo       = @room,
                EntryYear    = @entry,
                updated_by   = @user,
                updated_at   = NOW()
            WHERE ID = @id",
            new MySqlParameter("@staff",   p.staffCode),
            new MySqlParameter("@course",  p.courseCode),
            new MySqlParameter("@prog",    p.progcode),
            new MySqlParameter("@cyear",   p.cyear),
            new MySqlParameter("@sess",    p.session),
            new MySqlParameter("@intake",  string.IsNullOrEmpty(p.intake) ? "" : p.intake),
            new MySqlParameter("@stream",  string.IsNullOrEmpty(p.stream) ? "-" : p.stream),
            new MySqlParameter("@day",     p.lectureday),
            new MySqlParameter("@start",   (p.lectureday != "-" && !string.IsNullOrEmpty(p.startTime)) ? (object)p.startTime : DBNull.Value),
            new MySqlParameter("@end",     (p.lectureday != "-" && !string.IsNullOrEmpty(p.endTime))   ? (object)p.endTime   : DBNull.Value),
            new MySqlParameter("@room",    !string.IsNullOrEmpty(p.roomNo) ? p.roomNo : "8"),
            new MySqlParameter("@entry",   p.entryYear > 0 ? p.entryYear.ToString() : ""),
            new MySqlParameter("@user",    user),
            new MySqlParameter("@id",      p.id));

        if (rows > 0)
            RespondJson(new { ok = true });
        else
            RespondJson(new { ok = false, error = "Update failed — allocation not found or no changes." });
    }

    // ─────────────────────── AJAX: delete ────────────────────────────────

    /// <summary>
    /// Deletes a teaching allocation by ID.
    /// </summary>
    private void HandleDelete()
    {
        AllocPayload p = ReadPayload();
        if (p == null) return;
        if (p.id <= 0)
        {
            RespondJson(new { ok = false, error = "Invalid allocation ID." });
            return;
        }

        // Verify it exists
        DataTable check = ExecuteQuery(
            "SELECT ID FROM acad_teaching_allocation WHERE ID = @id",
            new MySqlParameter("@id", p.id));
        if (check.Rows.Count == 0)
        {
            RespondJson(new { ok = false, error = "Allocation not found." });
            return;
        }

        int rows = ExecuteNonQuery(
            "DELETE FROM acad_teaching_allocation WHERE ID = @id",
            new MySqlParameter("@id", p.id));

        if (rows > 0)
            RespondJson(new { ok = true });
        else
            RespondJson(new { ok = false, error = "Delete failed." });
    }

    // ─────────────────────── AJAX: copypreview ───────────────────────────

    /// <summary>
    /// Counts how many allocations would be copied from a source semester,
    /// and how many already exist in the current semester (duplicates to skip).
    /// </summary>
    private void HandleCopyPreview()
    {
        string srcYear = (Request.QueryString["srcYear"] ?? "").Trim();
        string srcSem  = (Request.QueryString["srcSem"]  ?? "").Trim();
        string prog    = (Request.QueryString["prog"]    ?? "").Trim();
        string yr      = (Request.QueryString["yr"]      ?? "").Trim();

        if (string.IsNullOrEmpty(srcYear))
        {
            RespondJson(new { count = 0, existing = 0 });
            return;
        }
        if (string.IsNullOrEmpty(srcSem)) srcSem = "1";

        string dstYear  = CurrentAcadYear;
        string dstSem   = CurrentSemester;
        string campusId = CurrentCampusId;

        // Count source allocations
        string srcWhere = "acad_year = @srcYear AND semester = @srcSem";
        List<MySqlParameter> srcParms = new List<MySqlParameter>();
        srcParms.Add(new MySqlParameter("@srcYear", srcYear));
        srcParms.Add(new MySqlParameter("@srcSem",  srcSem));
        if (!string.IsNullOrEmpty(prog))
        {
            srcWhere += " AND progcode = @prog";
            srcParms.Add(new MySqlParameter("@prog", prog));
        }
        if (!string.IsNullOrEmpty(yr))
        {
            srcWhere += " AND cyear = @cyear";
            srcParms.Add(new MySqlParameter("@cyear", yr));
        }
        if (campusId != "0" && !string.IsNullOrEmpty(campusId))
        {
            srcWhere += " AND campusId = @campus";
            srcParms.Add(new MySqlParameter("@campus", campusId));
        }

        string countSql = string.Format("SELECT COUNT(*) FROM acad_teaching_allocation WHERE {0}", srcWhere);
        object srcObj = ExecuteScalar(countSql, srcParms.ToArray());
        int total = (srcObj == null || srcObj == DBNull.Value) ? 0 : Convert.ToInt32(srcObj);

        // Count how many already exist in destination
        // A "duplicate" = same staffCode + courseID + progcode + cyear + stud_session + lectureday
        string existSql = string.Format(@"
            SELECT COUNT(*) FROM acad_teaching_allocation src
            WHERE  {0}
              AND  EXISTS (
                  SELECT 1 FROM acad_teaching_allocation dst
                  WHERE dst.acad_year    = @dstYear
                    AND dst.semester     = @dstSem
                    AND dst.staffCode    = src.staffCode
                    AND dst.courseID     = src.courseID
                    AND dst.progcode    = src.progcode
                    AND dst.cyear       = src.cyear
                    AND dst.stud_session = src.stud_session
              )", srcWhere);

        List<MySqlParameter> existParms = new List<MySqlParameter>(srcParms.Count + 2);
        foreach (MySqlParameter sp in srcParms)
        {
            existParms.Add(new MySqlParameter(sp.ParameterName, sp.Value));
        }
        existParms.Add(new MySqlParameter("@dstYear", dstYear));
        existParms.Add(new MySqlParameter("@dstSem",  dstSem));

        object existObj = ExecuteScalar(existSql, existParms.ToArray());
        int existing = (existObj == null || existObj == DBNull.Value) ? 0 : Convert.ToInt32(existObj);

        RespondJson(new { count = total, existing = existing });
    }

    // ─────────────────────── AJAX: copy ──────────────────────────────────

    /// <summary>
    /// Batch copies allocations from a source academic year/semester into the current one.
    /// Skips duplicates (same staffCode + courseID + progcode + cyear + stud_session).
    /// All copied records get new audit trail entries.
    /// </summary>
    private void HandleCopy()
    {
        AllocPayload p = ReadPayload();
        if (p == null) return;

        string srcYear = p.srcYear;
        string srcSem  = p.srcSem;

        if (string.IsNullOrEmpty(srcYear))
        {
            RespondJson(new { ok = false, error = "Source academic year is required." });
            return;
        }
        if (string.IsNullOrEmpty(srcSem)) srcSem = "1";

        string dstYear  = CurrentAcadYear;
        string dstSem   = CurrentSemester;
        string campusId = CurrentCampusId;
        string user     = AllocationHelper.GetCurrentUser();

        // Build source WHERE
        string srcWhere = "src.acad_year = @srcYear AND src.semester = @srcSem";
        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@srcYear", srcYear));
        parms.Add(new MySqlParameter("@srcSem",  srcSem));
        parms.Add(new MySqlParameter("@dstYear", dstYear));
        parms.Add(new MySqlParameter("@dstSem",  dstSem));
        parms.Add(new MySqlParameter("@user",    user));

        if (!string.IsNullOrEmpty(p.progcode))
        {
            srcWhere += " AND src.progcode = @prog";
            parms.Add(new MySqlParameter("@prog", p.progcode));
        }
        if (p.cyear > 0)
        {
            srcWhere += " AND src.cyear = @cyear";
            parms.Add(new MySqlParameter("@cyear", p.cyear));
        }
        if (campusId != "0" && !string.IsNullOrEmpty(campusId))
        {
            srcWhere += " AND src.campusId = @campus";
            parms.Add(new MySqlParameter("@campus", campusId));
        }

        // INSERT...SELECT with NOT EXISTS to skip duplicates
        string sql = string.Format(@"
            INSERT INTO acad_teaching_allocation
                (staffCode, courseID, acad_year, semester, progcode, cyear,
                 stud_session, intake, stream, campusId,
                 lectureday, StartTime, EndTime, roomNo, EntryYear,
                 created_by, created_at)
            SELECT
                src.staffCode, src.courseID, @dstYear, @dstSem, src.progcode, src.cyear,
                src.stud_session, src.intake, src.stream, src.campusId,
                src.lectureday, src.StartTime, src.EndTime, src.roomNo, src.EntryYear,
                @user, NOW()
            FROM acad_teaching_allocation src
            WHERE {0}
              AND NOT EXISTS (
                  SELECT 1 FROM acad_teaching_allocation dst
                  WHERE dst.acad_year    = @dstYear
                    AND dst.semester     = @dstSem
                    AND dst.staffCode    = src.staffCode
                    AND dst.courseID     = src.courseID
                    AND dst.progcode    = src.progcode
                    AND dst.cyear       = src.cyear
                    AND dst.stud_session = src.stud_session
              )", srcWhere);

        int copied = ExecuteNonQuery(sql, parms.ToArray());
        RespondJson(new { ok = true, copied = copied });
    }

    // ─────────────────────── AJAX: adoptpreview ──────────────────────────

    /// <summary>
    /// Counts how many allocations from a source entry year can be adopted
    /// to the target entry year within the current academic year/semester.
    /// </summary>
    private void HandleAdoptPreview()
    {
        string srcEntry = (Request.QueryString["srcEntry"] ?? "").Trim();
        string dstEntry = (Request.QueryString["dstEntry"] ?? "").Trim();
        string prog     = (Request.QueryString["prog"]     ?? "").Trim();
        string yr       = (Request.QueryString["yr"]       ?? "").Trim();

        if (string.IsNullOrEmpty(srcEntry) || string.IsNullOrEmpty(dstEntry))
        {
            RespondJson(new { count = 0, existing = 0 });
            return;
        }

        string acadYear = CurrentAcadYear;
        string sem      = CurrentSemester;
        string campus   = CurrentCampusId;

        // Build source WHERE
        string srcWhere = "acad_year = @year AND semester = @sem AND EntryYear = @srcEntry";
        List<MySqlParameter> srcParms = new List<MySqlParameter>();
        srcParms.Add(new MySqlParameter("@year",     acadYear));
        srcParms.Add(new MySqlParameter("@sem",      sem));
        srcParms.Add(new MySqlParameter("@srcEntry", srcEntry));
        srcParms.Add(new MySqlParameter("@dstEntry", dstEntry));
        if (!string.IsNullOrEmpty(prog))
        {
            srcWhere += " AND progcode = @prog";
            srcParms.Add(new MySqlParameter("@prog", prog));
        }
        if (!string.IsNullOrEmpty(yr))
        {
            srcWhere += " AND cyear = @cyear";
            srcParms.Add(new MySqlParameter("@cyear", yr));
        }
        if (campus != "0" && !string.IsNullOrEmpty(campus))
        {
            srcWhere += " AND campusId = @campus";
            srcParms.Add(new MySqlParameter("@campus", campus));
        }

        string countSql = string.Format("SELECT COUNT(*) FROM acad_teaching_allocation WHERE {0}", srcWhere);
        object srcObj = ExecuteScalar(countSql, srcParms.ToArray());
        int total = (srcObj == null || srcObj == DBNull.Value) ? 0 : Convert.ToInt32(srcObj);

        // Count existing duplicates in destination entry year
        string existSql = string.Format(@"
            SELECT COUNT(*) FROM acad_teaching_allocation src
            WHERE  {0}
              AND  EXISTS (
                  SELECT 1 FROM acad_teaching_allocation dst
                  WHERE dst.acad_year    = src.acad_year
                    AND dst.semester     = src.semester
                    AND dst.staffCode    = src.staffCode
                    AND dst.courseID     = src.courseID
                    AND dst.progcode    = src.progcode
                    AND dst.cyear       = src.cyear
                    AND dst.stud_session = src.stud_session
                    AND dst.EntryYear    = @dstEntry
              )", srcWhere);

        object existObj = ExecuteScalar(existSql, srcParms.ToArray());
        int existing = (existObj == null || existObj == DBNull.Value) ? 0 : Convert.ToInt32(existObj);

        RespondJson(new { count = total, existing = existing });
    }

    // ─────────────────────── AJAX: adopt ─────────────────────────────────

    /// <summary>
    /// Adopts (copies) allocations from one entry year to another within the
    /// current academic year/semester. Skips duplicates.
    /// </summary>
    private void HandleAdopt()
    {
        AllocPayload p = ReadPayload();
        if (p == null) return;

        int srcEntry = p.srcEntry;
        int dstEntry = p.dstEntry;

        if (srcEntry <= 0 || dstEntry <= 0)
        {
            RespondJson(new { ok = false, error = "Both source and target entry years are required." });
            return;
        }
        if (srcEntry == dstEntry)
        {
            RespondJson(new { ok = false, error = "Source and target entry years must be different." });
            return;
        }

        string acadYear = CurrentAcadYear;
        string sem      = CurrentSemester;
        string campus   = CurrentCampusId;
        string user     = AllocationHelper.GetCurrentUser();

        // Build WHERE for source records
        string srcWhere = "src.acad_year = @year AND src.semester = @sem AND src.EntryYear = @srcEntry";
        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@year",     acadYear));
        parms.Add(new MySqlParameter("@sem",      sem));
        parms.Add(new MySqlParameter("@srcEntry", srcEntry));
        parms.Add(new MySqlParameter("@dstEntry", dstEntry));
        parms.Add(new MySqlParameter("@user",     user));

        if (!string.IsNullOrEmpty(p.progcode))
        {
            srcWhere += " AND src.progcode = @prog";
            parms.Add(new MySqlParameter("@prog", p.progcode));
        }
        if (p.cyear > 0)
        {
            srcWhere += " AND src.cyear = @cyear";
            parms.Add(new MySqlParameter("@cyear", p.cyear));
        }
        if (campus != "0" && !string.IsNullOrEmpty(campus))
        {
            srcWhere += " AND src.campusId = @campus";
            parms.Add(new MySqlParameter("@campus", campus));
        }

        // INSERT...SELECT with different EntryYear, skip duplicates
        string sql = string.Format(@"
            INSERT INTO acad_teaching_allocation
                (staffCode, courseID, acad_year, semester, progcode, cyear,
                 stud_session, intake, stream, campusId,
                 lectureday, StartTime, EndTime, roomNo, EntryYear,
                 created_by, created_at)
            SELECT
                src.staffCode, src.courseID, src.acad_year, src.semester, src.progcode, src.cyear,
                src.stud_session, src.intake, src.stream, src.campusId,
                src.lectureday, src.StartTime, src.EndTime, src.roomNo, @dstEntry,
                @user, NOW()
            FROM acad_teaching_allocation src
            WHERE {0}
              AND NOT EXISTS (
                  SELECT 1 FROM acad_teaching_allocation dst
                  WHERE dst.acad_year    = src.acad_year
                    AND dst.semester     = src.semester
                    AND dst.staffCode    = src.staffCode
                    AND dst.courseID     = src.courseID
                    AND dst.progcode    = src.progcode
                    AND dst.cyear       = src.cyear
                    AND dst.stud_session = src.stud_session
                    AND dst.EntryYear    = @dstEntry
              )", srcWhere);

        int adopted = ExecuteNonQuery(sql, parms.ToArray());
        RespondJson(new { ok = true, adopted = adopted });
    }

    // ─────────────────────── AJAX: bulkdelete ────────────────────────────

    /// <summary>
    /// Deletes multiple allocations by ID. Receives a JSON body with { ids: [1,2,3] }.
    /// </summary>
    private void HandleBulkDelete()
    {
        // Read JSON body manually since AllocPayload doesn't have ids array
        int len = Request.ContentLength;
        if (len <= 0)
        {
            RespondJson(new { ok = false, error = "No data received." });
            return;
        }

        byte[] buf = new byte[len];
        Request.InputStream.Read(buf, 0, len);
        string body = System.Text.Encoding.UTF8.GetString(buf);

        JavaScriptSerializer ser = new JavaScriptSerializer();
        Dictionary<string, object> data = ser.Deserialize<Dictionary<string, object>>(body);

        if (data == null || !data.ContainsKey("ids"))
        {
            RespondJson(new { ok = false, error = "No IDs provided." });
            return;
        }

        System.Collections.ArrayList idList = data["ids"] as System.Collections.ArrayList;
        if (idList == null || idList.Count == 0)
        {
            RespondJson(new { ok = false, error = "No IDs provided." });
            return;
        }

        // Safety limit: max 500 deletions at once
        if (idList.Count > 500)
        {
            RespondJson(new { ok = false, error = "Cannot delete more than 500 allocations at once." });
            return;
        }

        // Build parameterized IN clause
        List<string> placeholders = new List<string>();
        List<MySqlParameter> parms = new List<MySqlParameter>();
        for (int i = 0; i < idList.Count; i++)
        {
            string pName = "@id" + i;
            placeholders.Add(pName);
            int idVal = 0;
            int.TryParse(idList[i].ToString(), out idVal);
            parms.Add(new MySqlParameter(pName, idVal));
        }

        string sql = string.Format(
            "DELETE FROM acad_teaching_allocation WHERE ID IN ({0})",
            string.Join(",", placeholders.ToArray()));

        int deleted = ExecuteNonQuery(sql, parms.ToArray());
        RespondJson(new { ok = true, deleted = deleted });
    }

    // ─────────────────────── Payload ─────────────────────────────────────

    /// <summary>
    /// Shared payload for create/update/delete/checkconflict/copy/adopt.
    /// Not all fields are used by every action.
    /// </summary>
    private class AllocPayload
    {
        // Common
        public int    id         { get; set; }
        public string staffCode  { get; set; }
        public string courseCode { get; set; }
        public string progcode   { get; set; }
        public int    cyear      { get; set; }
        public string session    { get; set; }
        public int    entryYear  { get; set; }
        public string intake     { get; set; }
        public string stream     { get; set; }
        public string lectureday { get; set; }
        public string startTime  { get; set; }
        public string endTime    { get; set; }
        public string roomNo     { get; set; }

        // Conflict check additional
        public string day        { get; set; }

        // Batch copy
        public string srcYear    { get; set; }
        public string srcSem     { get; set; }
        public string prog       { get; set; }
        public string studyYear  { get; set; }

        // Adopt entry year
        public int    srcEntry   { get; set; }
        public int    dstEntry   { get; set; }
    }

    private AllocPayload ReadPayload()
    {
        try
        {
            int len = Request.ContentLength;
            if (len <= 0) return new AllocPayload();

            byte[] buf = new byte[len];
            Request.InputStream.Read(buf, 0, len);
            string body = System.Text.Encoding.UTF8.GetString(buf);

            JavaScriptSerializer ser = new JavaScriptSerializer();
            AllocPayload p = ser.Deserialize<AllocPayload>(body);
            if (p == null) p = new AllocPayload();

            // Normalise: checkconflict sends "day" instead of "lectureday"
            if (!string.IsNullOrEmpty(p.day) && string.IsNullOrEmpty(p.lectureday))
                p.lectureday = p.day;

            // Normalise empty strings
            if (p.lectureday == null) p.lectureday = "-";
            if (p.staffCode == null)  p.staffCode = "";
            if (p.courseCode == null) p.courseCode = "";
            if (p.progcode == null)   p.progcode = "";
            if (p.session == null)    p.session = "DAY";
            if (p.startTime == null)  p.startTime = "";
            if (p.endTime == null)    p.endTime = "";
            if (p.roomNo == null)     p.roomNo = "";
            if (p.intake == null)     p.intake = "";
            if (p.stream == null)     p.stream = "-";

            // Batch copy: copy prog/studyYear from alternate field names
            if (string.IsNullOrEmpty(p.progcode) && !string.IsNullOrEmpty(p.prog))
                p.progcode = p.prog;
            if (p.cyear <= 0 && !string.IsNullOrEmpty(p.studyYear))
            {
                int cy = 0;
                int.TryParse(p.studyYear, out cy);
                p.cyear = cy;
            }

            return p;
        }
        catch (Exception ex)
        {
            RespondJson(new { ok = false, error = "Invalid request body: " + ex.Message });
            return null;
        }
    }

    private string ValidatePayload(AllocPayload p)
    {
        if (string.IsNullOrEmpty(p.staffCode))
            return "Lecturer (staffCode) is required.";
        if (string.IsNullOrEmpty(p.courseCode))
            return "Course is required.";
        if (string.IsNullOrEmpty(p.progcode))
            return "Programme is required.";
        if (p.cyear < 1 || p.cyear > 7)
            return "Study year must be between 1 and 7.";

        // If a day is selected, both start and end times are required
        if (p.lectureday != "-" && !string.IsNullOrEmpty(p.lectureday))
        {
            if (string.IsNullOrEmpty(p.startTime) || string.IsNullOrEmpty(p.endTime))
                return "When a day is selected, both start and end times are required.";

            // Validate time order
            TimeSpan start = AllocationHelper.ParseTime(p.startTime);
            TimeSpan end   = AllocationHelper.ParseTime(p.endTime);
            if (end <= start)
                return "End time must be after start time.";
        }

        return null;    // valid
    }
}
