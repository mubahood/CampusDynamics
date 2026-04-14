using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// TimetableView.aspx.cs — Code-behind for Timetable View page.
///
/// AJAX Endpoints (via ?ajax=...):
///   GET  ?ajax=dropdowns                   — programmes, lecturers, rooms for filter dropdowns
///   GET  ?ajax=timetable&amp;mode=programme&amp;prog=&amp;yr=...  — timetable data for selected filters
///   GET  ?ajax=timetable&amp;mode=lecturer&amp;staff=...         — timetable data for a lecturer
///   GET  ?ajax=timetable&amp;mode=room&amp;room=...              — timetable data for a room
///
/// View Modes:
///   - programme: show all allocations for a programme/study_year (optionally filtered by entry year, session)
///   - lecturer:  show all allocations for a specific lecturer across all programmes
///   - room:      show all allocations for a specific room across all programmes
///
/// The front-end renders the visual weekly grid client-side.
/// The server returns scheduled and unscheduled arrays plus stats.
///
/// Tables:
///   acad_teaching_allocation — allocation records
///   acad_course              — course names, credit units
///   acad_programme           — programme abbreviations
///   hrm_employee             — lecturer names, EMP_CODE
///   acad_lecturerooms        — room names
///
/// Design Rules:
///   - C# 4.0 compatible: no ?. operator, no string interpolation ($"")
///   - vacConnectionString only
///   - Session from SidebarMaster for acad year, semester, campus
///   - staffCode = empID (integer as string)
///   - lectureday = '-' means unscheduled
///
/// Task: LOAD_ALLOCATION_TASKS.md — Task 6
/// Implementation Log: LOAD_ALLOCATION_IMPLEMENTATION_LOG.md
/// Created: 2026-04-10
/// </summary>
public partial class COOPERP_NewScreens_TimetableView : System.Web.UI.Page
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

    private string RespondJson(object obj)
    {
        JavaScriptSerializer ser = new JavaScriptSerializer();
        ser.MaxJsonLength = int.MaxValue;
        string json = ser.Serialize(obj);
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Write(json);
        Response.End();
        return null;
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

    // ─────────────────────── Session Context ─────────────────────────────

    private string CurrentAcadYear
    {
        get
        {
            string v = GetSession("SelectedAcademicYear");
            if (string.IsNullOrEmpty(v)) v = AcademicYearHelper.GetCurrentAcademicYear();
            return v;
        }
    }

    private string CurrentSemester
    {
        get
        {
            string v = GetSession("SelectedSemester");
            if (string.IsNullOrEmpty(v)) v = "1";
            return v;
        }
    }

    private string CurrentCampusId
    {
        get
        {
            string v = GetSession("SelectedCampus");
            if (string.IsNullOrEmpty(v)) v = "1";
            return v;
        }
    }

    // ─────────────────────── Lifecycle ───────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        try
        {
            // Parse action from ajax param
            string action = ajax;
            int ampIdx = ajax.IndexOf('&');
            if (ampIdx > 0) action = ajax.Substring(0, ampIdx);

            switch (action)
            {
                case "dropdowns":  HandleDropdowns();  break;
                case "timetable":  HandleTimetable();  break;
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

    // ─────────────────────── AJAX: dropdowns ────────────────────────────

    /// <summary>
    /// Returns programmes, lecturers, and rooms for the filter dropdowns.
    /// Only programmes and lecturers that have allocations in the current semester are returned.
    /// </summary>
    private void HandleDropdowns()
    {
        string year   = CurrentAcadYear;
        string sem    = CurrentSemester;
        string campus = CurrentCampusId;

        // Programmes with allocations
        DataTable dtProg = ExecuteQuery(@"
            SELECT DISTINCT p.progcode AS code,
                   CONCAT(IFNULL(p.abbrev, p.progcode), ' - ', p.progname) AS display
            FROM acad_programme p
            INNER JOIN acad_teaching_allocation ta ON ta.progcode = p.progcode
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
            ORDER BY p.abbrev",
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        var programmes = new List<object>();
        foreach (DataRow r in dtProg.Rows)
            programmes.Add(new { code = SafeStr(r["code"]), display = SafeStr(r["display"]) });

        // Lecturers with allocations
        DataTable dtLec = ExecuteQuery(@"
            SELECT DISTINCT ta.staffCode AS id,
                   CONCAT(IFNULL(e.emp_name, CONCAT('Staff #', ta.staffCode)), ' (', IFNULL(e.EMP_CODE,''), ')') AS display
            FROM acad_teaching_allocation ta
            LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
              AND ta.staffCode != '0'
            ORDER BY e.emp_name",
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        var lecturers = new List<object>();
        foreach (DataRow r in dtLec.Rows)
            lecturers.Add(new { id = SafeStr(r["id"]), display = SafeStr(r["display"]) });

        // Rooms
        DataTable dtRooms = ExecuteQuery(@"
            SELECT lr.RoomID AS id,
                   CONCAT(lr.RoomName, ' (Cap: ', IFNULL(lr.Capacity,0), ')') AS display
            FROM acad_lecturerooms lr
            WHERE lr.campusId = @campus
            ORDER BY lr.RoomName",
            new MySqlParameter("@campus", campus));

        var rooms = new List<object>();
        foreach (DataRow r in dtRooms.Rows)
            rooms.Add(new { id = SafeStr(r["id"]), display = SafeStr(r["display"]) });

        RespondJson(new {
            ok         = true,
            acadYear   = year,
            semester   = sem,
            campusId   = campus,
            programmes = programmes,
            lecturers  = lecturers,
            rooms      = rooms
        });
    }

    // ─────────────────────── AJAX: timetable ────────────────────────────

    /// <summary>
    /// Returns timetable data for the selected view mode.
    /// Response:
    /// {
    ///   ok, title, totalAllocations, scheduledCount, unscheduledCount, roomCount,
    ///   scheduled: [{ courseCode, courseName, lecturerName, roomName, day, startTime, endTime, progAbbrev, cyear }],
    ///   unscheduled: [{ courseCode, courseName, lecturerName, progAbbrev, cyear, session }]
    /// }
    /// </summary>
    private void HandleTimetable()
    {
        string year   = CurrentAcadYear;
        string sem    = CurrentSemester;
        string campus = CurrentCampusId;
        string mode   = (Request.QueryString["mode"] ?? "programme").Trim().ToLower();

        // Build WHERE clause based on mode
        string where = " ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus ";
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@year",   year));
        parms.Add(new MySqlParameter("@sem",    sem));
        parms.Add(new MySqlParameter("@campus", campus));

        string title = "";

        if (mode == "programme")
        {
            string prog = (Request.QueryString["prog"] ?? "").Trim();
            if (string.IsNullOrEmpty(prog))
            {
                RespondJson(new { ok = false, error = "Programme is required." });
                return;
            }
            where += " AND ta.progcode = @prog ";
            parms.Add(new MySqlParameter("@prog", prog));
            title = prog;

            string yr = (Request.QueryString["yr"] ?? "").Trim();
            if (!string.IsNullOrEmpty(yr))
            {
                where += " AND ta.cyear = @cyear ";
                parms.Add(new MySqlParameter("@cyear", yr));
                title += " Year " + yr;
            }

            string entry = (Request.QueryString["entry"] ?? "").Trim();
            if (!string.IsNullOrEmpty(entry))
            {
                where += " AND ta.EntryYear = @entry ";
                parms.Add(new MySqlParameter("@entry", entry));
            }

            string sess = (Request.QueryString["sess"] ?? "").Trim();
            if (!string.IsNullOrEmpty(sess))
            {
                where += " AND ta.stud_session = @sess ";
                parms.Add(new MySqlParameter("@sess", sess));
                title += " (" + sess + ")";
            }
        }
        else if (mode == "lecturer")
        {
            string staff = (Request.QueryString["staff"] ?? "").Trim();
            if (string.IsNullOrEmpty(staff))
            {
                RespondJson(new { ok = false, error = "Lecturer is required." });
                return;
            }
            where += " AND ta.staffCode = @staff ";
            parms.Add(new MySqlParameter("@staff", staff));

            // Get lecturer name for title
            DataTable dtName = ExecuteQuery(
                "SELECT emp_name FROM hrm_employee WHERE empID = @id",
                new MySqlParameter("@id", staff));
            title = dtName.Rows.Count > 0 ? SafeStr(dtName.Rows[0]["emp_name"]) : "Staff #" + staff;
        }
        else if (mode == "room")
        {
            string room = (Request.QueryString["room"] ?? "").Trim();
            if (string.IsNullOrEmpty(room))
            {
                RespondJson(new { ok = false, error = "Room is required." });
                return;
            }
            where += " AND ta.roomNo = @room ";
            parms.Add(new MySqlParameter("@room", room));

            // Get room name for title
            DataTable dtRoom = ExecuteQuery(
                "SELECT RoomName FROM acad_lecturerooms WHERE RoomID = @id",
                new MySqlParameter("@id", room));
            title = dtRoom.Rows.Count > 0 ? SafeStr(dtRoom.Rows[0]["RoomName"]) : "Room #" + room;
        }
        else
        {
            RespondJson(new { ok = false, error = "Invalid view mode." });
            return;
        }

        // Query all allocations
        string sql = @"
            SELECT ta.ID, ta.courseID AS courseCode,
                   IFNULL(c.courseName, ta.courseID) AS courseName,
                   ta.staffCode,
                   IFNULL(e.emp_name, CASE WHEN ta.staffCode = '0' THEN 'Unassigned' ELSE CONCAT('Staff #', ta.staffCode) END) AS lecturerName,
                   ta.lectureday AS day,
                   ta.StartTime AS startTime,
                   ta.EndTime   AS endTime,
                   ta.roomNo,
                   IFNULL(lr.RoomName, '') AS roomName,
                   IFNULL(p.abbrev, ta.progcode) AS progAbbrev,
                   ta.cyear,
                   IFNULL(ta.stud_session, '') AS session
            FROM acad_teaching_allocation ta
            LEFT JOIN acad_course c ON c.courseID = ta.courseID
            LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
            LEFT JOIN acad_lecturerooms lr ON lr.RoomID = CAST(ta.roomNo AS UNSIGNED)
            LEFT JOIN acad_programme p ON p.progcode = ta.progcode
            WHERE " + where + @"
            ORDER BY FIELD(ta.lectureday, 'MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY'), ta.StartTime";

        DataTable dt = ExecuteQuery(sql, parms.ToArray());

        // Separate scheduled vs unscheduled
        var scheduled   = new List<object>();
        var unscheduled = new List<object>();
        var roomSet     = new Dictionary<string, bool>();

        foreach (DataRow row in dt.Rows)
        {
            string day       = SafeStr(row["day"]);
            string startTime = SafeStr(row["startTime"]);
            string endTime   = SafeStr(row["endTime"]);
            string roomName  = SafeStr(row["roomName"]);

            bool isScheduled = !string.IsNullOrEmpty(day) && day != "-"
                && !string.IsNullOrEmpty(startTime) && !string.IsNullOrEmpty(endTime);

            if (isScheduled)
            {
                scheduled.Add(new {
                    courseCode   = SafeStr(row["courseCode"]),
                    courseName   = SafeStr(row["courseName"]),
                    lecturerName = SafeStr(row["lecturerName"]),
                    roomName     = roomName,
                    day          = day,
                    startTime    = startTime,
                    endTime      = endTime,
                    progAbbrev   = SafeStr(row["progAbbrev"]),
                    cyear        = SafeStr(row["cyear"])
                });

                if (!string.IsNullOrEmpty(roomName) && !roomSet.ContainsKey(roomName))
                    roomSet[roomName] = true;
            }
            else
            {
                unscheduled.Add(new {
                    courseCode   = SafeStr(row["courseCode"]),
                    courseName   = SafeStr(row["courseName"]),
                    lecturerName = SafeStr(row["lecturerName"]),
                    progAbbrev   = SafeStr(row["progAbbrev"]),
                    cyear        = SafeStr(row["cyear"]),
                    session      = SafeStr(row["session"])
                });
            }
        }

        RespondJson(new {
            ok               = true,
            title            = title,
            totalAllocations = dt.Rows.Count,
            scheduledCount   = scheduled.Count,
            unscheduledCount = unscheduled.Count,
            roomCount        = roomSet.Count,
            scheduled        = scheduled,
            unscheduled      = unscheduled
        });
    }
}
