using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// WorkloadAnalysis.aspx.cs — Code-behind for Workload Analysis page.
///
/// AJAX Endpoints (via ?ajax=...):
///   GET  ?ajax=data — returns all workload rows, faculties, programmes, and per-lecturer detail
///
/// Single-endpoint design: the front-end receives ALL data in one request and
/// does filtering/sorting in-memory on the client. This avoids repeated server
/// round-trips for each filter change.
///
/// Tables:
///   acad_teaching_allocation — allocation records (staffCode, courseID, progcode, schedule)
///   hrm_employee             — lecturer names, EMP_CODE, EmpType
///   hrm_emp_contracts        — contract type (FULL TIME / PART TIME), departmentID
///   hrm_departments          — department name
///   acad_course              — course catalog (CreditUnit, courseName)
///   acad_programme           — programme abbreviations
///   acad_faculty             — faculty list for filter dropdown
///
/// Design Rules:
///   - C# 4.0 compatible: no ?. operator, no string interpolation ($"")
///   - vacConnectionString only — no hardcoded credentials
///   - Session["SelectedAcademicYear"], Session["SelectedSemester"], Session["SelectedCampus"]
///   - staffCode stores empID (integer) as a string — CAST(ta.staffCode AS UNSIGNED) = e.empID
///   - COUNT(DISTINCT courseID) to avoid inflating counts from duplicate allocations
///   - "Overloaded" threshold: >6 courses or >18 contact hours
///
/// Task: LOAD_ALLOCATION_TASKS.md — Task 7
/// Implementation Log: LOAD_ALLOCATION_IMPLEMENTATION_LOG.md
/// Created: 2026-04-10
/// </summary>
public partial class COOPERP_NewScreens_WorkloadAnalysis : System.Web.UI.Page
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

    private double SafeDouble(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        double result;
        if (double.TryParse(val.ToString(), out result)) return result;
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
            switch (ajax)
            {
                case "data": HandleData(); break;
                default:
                    RespondJson(new { ok = false, error = "Unknown action: " + ajax });
                    break;
            }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            RespondJson(new { ok = false, error = "Server error: " + ex.Message });
        }
    }

    // ─────────────────────── AJAX: data ─────────────────────────────────

    /// <summary>
    /// Returns the complete workload dataset for the current academic year/semester/campus.
    /// Response structure:
    /// {
    ///   ok: true,
    ///   acadYear: "2025/2026", semester: "1", campusId: "1",
    ///   faculties: [{ code, name }],
    ///   programmes: [{ code, display }],
    ///   rows: [{ staffCode, lecturerName, empCode, department, contractType, faculty,
    ///            courseCount, programmeCount, scheduledHours, totalCredits, programmes_list }],
    ///   details: { "staffCode": [{ courseCode, courseName, progAbbrev, cyear, day, startTime, endTime, creditUnit }] }
    /// }
    /// </summary>
    // Build the timetable filter clause + fresh parameters for one query.
    // Timetable is PERPETUAL (no acad_year): scope is semester + campus only.
    private string FilterClause(string sem, string campus)
    {
        string flt = "";
        if (!string.IsNullOrEmpty(sem) && sem != "0") flt += " AND it.semester=@sem";
        if (!string.IsNullOrEmpty(campus) && campus != "0") flt += " AND (it.campus_id=@campus OR it.campus_id=0)";
        return flt;
    }
    private MySqlParameter[] FilterParams(string sem, string campus)
    {
        List<MySqlParameter> list = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(sem) && sem != "0") list.Add(new MySqlParameter("@sem", sem));
        if (!string.IsNullOrEmpty(campus) && campus != "0") list.Add(new MySqlParameter("@campus", campus));
        return list.ToArray();
    }

    /// <summary>
    /// Workload is derived from ACTIVE timetable items (acad_timetable_item), grouped by
    /// the effective lecturer IFNULL(teacher_id, programme-course lecturer). Load is measured
    /// as weekly contact hours (SUM duration_min) and session count; courses/programmes/credits
    /// are secondary. Scope = semester + campus (perpetual timetable, no academic year).
    /// </summary>
    private void HandleData()
    {
        TimetableService.EnsureSchema();

        string semParam    = Request.QueryString["sem"];
        string campusParam = Request.QueryString["campus"];
        string sem    = semParam != null ? semParam.Trim() : CurrentSemester;
        string campus = campusParam != null ? campusParam.Trim() : CurrentCampusId;

        string flt  = FilterClause(sem, campus);
        // base filtered set of active timetable rows with the effective lecturer resolved
        string baseFrom = " FROM acad_timetable_item it JOIN acad_programmecourses pc ON pc.ID=it.programmecourse_id WHERE it.status='ACTIVE'" + flt;

        // ── 1. Workload summary per effective lecturer ───────────────────
        string summSql =
            "SELECT t.eff AS staffCode, " +
            "  IFNULL(e.emp_name, CONCAT('Staff #', t.eff)) AS lecturerName, IFNULL(e.EMP_CODE,'') AS empCode, IFNULL(e.EmpType,'') AS empType, " +
            "  IFNULL(ct.contract_type,'') AS contractType, IFNULL(d.departmentName,'') AS department, " +
            "  COUNT(*) AS sessionCount, COUNT(DISTINCT t.course_code) AS courseCount, COUNT(DISTINCT t.progcode) AS programmeCount, " +
            "  COALESCE(SUM(t.duration_min),0)/60.0 AS weeklyHours, " +
            "  GROUP_CONCAT(DISTINCT t.progcode) AS programmes_csv, GROUP_CONCAT(DISTINCT p.faculty_code) AS faculties_csv " +
            "FROM (SELECT IFNULL(it.teacher_id, pc.lecturer_id) eff, TRIM(it.course_code) course_code, it.progcode, it.duration_min" + baseFrom + ") t " +
            "LEFT JOIN hrm_employee e ON e.empID=t.eff " +
            "LEFT JOIN hrm_emp_contracts ct ON ct.empID=e.empID AND ct.contractStatus='Active' " +
            "LEFT JOIN hrm_departments d ON d.ID=ct.departmentID " +
            "LEFT JOIN acad_programme p ON p.progcode=t.progcode " +
            "WHERE t.eff>0 GROUP BY t.eff ORDER BY weeklyHours DESC, lecturerName";
        DataTable dtSumm = ExecuteQuery(summSql, FilterParams(sem, campus));

        // ── 2. Detail sessions per lecturer ──────────────────────────────
        string detSql =
            "SELECT t.eff AS staffCode, t.course_code AS courseCode, IFNULL(c.courseName, t.course_code) AS courseName, " +
            "  IFNULL(c.CreditUnit,0) AS creditUnit, IFNULL(p.abbrev, t.progcode) AS progAbbrev, t.study_year AS cyear, " +
            "  t.day_no AS dayNo, t.st AS startTime, t.et AS endTime, t.duration_min AS durationMin, " +
            "  IFNULL(r.RoomName, IFNULL(t.room_label,'')) AS room, t.session_type AS sessionType " +
            "FROM (SELECT IFNULL(it.teacher_id, pc.lecturer_id) eff, TRIM(it.course_code) course_code, it.progcode, it.study_year, it.day_no, " +
            "  TIME_FORMAT(it.start_time,'%H:%i') st, TIME_FORMAT(it.end_time,'%H:%i') et, it.duration_min, it.room_id, it.room_label, it.session_type" + baseFrom + ") t " +
            "LEFT JOIN acad_course c ON TRIM(c.courseID)=t.course_code LEFT JOIN acad_programme p ON p.progcode=t.progcode " +
            "LEFT JOIN acad_lecturerooms r ON r.RoomID=t.room_id WHERE t.eff>0 ORDER BY t.eff, t.day_no, t.st";
        DataTable dtDet = ExecuteQuery(detSql, FilterParams(sem, campus));

        // ── 3. Credit totals per lecturer (distinct courses) ─────────────
        string creditSql =
            "SELECT t.eff AS staffCode, COALESCE(SUM(IFNULL(dc.CreditUnit,0)),0) AS totalCredits " +
            "FROM (SELECT DISTINCT IFNULL(it.teacher_id, pc.lecturer_id) eff, TRIM(it.course_code) course_code" + baseFrom + ") t " +
            "LEFT JOIN acad_course dc ON TRIM(dc.courseID)=t.course_code WHERE t.eff>0 GROUP BY t.eff";
        DataTable dtCredits = ExecuteQuery(creditSql, FilterParams(sem, campus));

        Dictionary<string, int> creditMap = new Dictionary<string, int>();
        foreach (DataRow cr in dtCredits.Rows)
        {
            string sc = SafeStr(cr["staffCode"]);
            if (!string.IsNullOrEmpty(sc)) creditMap[sc] = SafeInt(cr["totalCredits"]);
        }

        // ── 4. Detail dictionary ─────────────────────────────────────────
        string[] DNAMES = { "", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" };
        Dictionary<string, List<object>> detailMap = new Dictionary<string, List<object>>();
        foreach (DataRow dr in dtDet.Rows)
        {
            string sc = SafeStr(dr["staffCode"]);
            if (!detailMap.ContainsKey(sc)) detailMap[sc] = new List<object>();
            int dno = SafeInt(dr["dayNo"]);
            detailMap[sc].Add(new {
                courseCode  = SafeStr(dr["courseCode"]),
                courseName  = SafeStr(dr["courseName"]),
                creditUnit  = SafeInt(dr["creditUnit"]),
                progAbbrev  = SafeStr(dr["progAbbrev"]),
                cyear       = SafeStr(dr["cyear"]),
                day         = (dno >= 1 && dno <= 7) ? DNAMES[dno] : "",
                startTime   = SafeStr(dr["startTime"]),
                endTime     = SafeStr(dr["endTime"]),
                durationMin = SafeInt(dr["durationMin"]),
                room        = SafeStr(dr["room"]),
                sessionType = SafeStr(dr["sessionType"])
            });
        }

        // ── 5. Summary rows ──────────────────────────────────────────────
        var rows = new List<object>();
        foreach (DataRow row in dtSumm.Rows)
        {
            string sc = SafeStr(row["staffCode"]);
            int credits = creditMap.ContainsKey(sc) ? creditMap[sc] : 0;
            string progCsv = SafeStr(row["programmes_csv"]);
            string[] progList = !string.IsNullOrEmpty(progCsv) ? progCsv.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries) : new string[0];
            string facCsv = SafeStr(row["faculties_csv"]);
            string[] facList = !string.IsNullOrEmpty(facCsv) ? facCsv.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries) : new string[0];

            rows.Add(new {
                staffCode       = sc,
                lecturerName    = SafeStr(row["lecturerName"]),
                empCode         = SafeStr(row["empCode"]),
                empType         = SafeStr(row["empType"]),
                contractType    = SafeStr(row["contractType"]),
                department      = SafeStr(row["department"]),
                faculty         = facList.Length > 0 ? facList[0] : "",
                faculties_list  = facList,
                sessionCount    = SafeInt(row["sessionCount"]),
                courseCount     = SafeInt(row["courseCount"]),
                programmeCount  = SafeInt(row["programmeCount"]),
                weeklyHours     = SafeDouble(row["weeklyHours"]),
                totalCredits    = credits,
                programmes_list = progList
            });
        }

        // ── 6. Dropdowns: faculties, in-scope programmes, campuses ───────
        var faculties = new List<object>();
        foreach (DataRow f in ExecuteQuery("SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name").Rows)
            faculties.Add(new { code = SafeStr(f["faculty_code"]), name = SafeStr(f["faculty_name"]) });

        var programmes = new List<object>();
        foreach (DataRow pr in ExecuteQuery(
            "SELECT DISTINCT p.progcode, CONCAT(p.abbrev,' - ',p.progname) AS display " +
            "FROM acad_programme p JOIN acad_timetable_item it ON TRIM(it.progcode)=TRIM(p.progcode) WHERE it.status='ACTIVE'" + flt + " ORDER BY p.abbrev",
            FilterParams(sem, campus)).Rows)
            programmes.Add(new { code = SafeStr(pr["progcode"]), display = SafeStr(pr["display"]) });

        var campuses = new List<object>();
        foreach (DataRow cp in ExecuteQuery("SELECT ID, campus_name FROM acad_campuses ORDER BY ID").Rows)
            campuses.Add(new { id = SafeStr(cp["ID"]), name = SafeStr(cp["campus_name"]) });

        RespondJson(new {
            ok          = true,
            semester    = sem,
            campusId    = campus,
            faculties   = faculties,
            programmes  = programmes,
            campuses    = campuses,
            rows        = rows,
            details     = detailMap
        });
    }
}
