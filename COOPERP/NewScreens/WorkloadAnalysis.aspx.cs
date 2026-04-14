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
    private void HandleData()
    {
        string year    = CurrentAcadYear;
        string sem     = CurrentSemester;
        string campus  = CurrentCampusId;

        // ── 1. Workload summary per lecturer ─────────────────────────────
        string summSql = @"
            SELECT ta.staffCode,
                   IFNULL(e.emp_name, CASE WHEN ta.staffCode = '0' THEN '— Unassigned —' ELSE CONCAT('Staff #', ta.staffCode) END) AS lecturerName,
                   IFNULL(e.EMP_CODE, '') AS empCode,
                   IFNULL(e.EmpType, '') AS empType,
                   IFNULL(ct.contract_type, '') AS contractType,
                   IFNULL(d.departmentName, '') AS department,
                   IFNULL(f.faculty_code, '') AS faculty,
                   COUNT(DISTINCT ta.courseID) AS courseCount,
                   COUNT(DISTINCT ta.progcode) AS programmeCount,
                   COALESCE(SUM(
                       CASE WHEN ta.lectureday != '-' AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL
                            THEN TIMESTAMPDIFF(MINUTE, STR_TO_DATE(ta.StartTime,'%H:%i'), STR_TO_DATE(ta.EndTime,'%H:%i')) / 60.0
                            ELSE 0
                       END
                   ), 0) AS scheduledHours,
                   GROUP_CONCAT(DISTINCT ta.progcode) AS programmes_csv
            FROM acad_teaching_allocation ta
            LEFT JOIN hrm_employee e ON e.empID = CAST(ta.staffCode AS UNSIGNED)
            LEFT JOIN hrm_emp_contracts ct ON ct.empID = e.empID AND ct.contractStatus = 'Active'
            LEFT JOIN hrm_departments d ON d.ID = ct.departmentID
            LEFT JOIN acad_programme p ON p.progcode = (
                SELECT ta2.progcode FROM acad_teaching_allocation ta2
                WHERE ta2.staffCode = ta.staffCode AND ta2.acad_year = @year AND ta2.semester = @sem
                LIMIT 1
            )
            LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
            GROUP BY ta.staffCode
            ORDER BY courseCount DESC, lecturerName";

        DataTable dtSumm = ExecuteQuery(summSql,
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        // ── 2. Detail rows per lecturer (all allocations) ────────────────
        string detSql = @"
            SELECT ta.staffCode, ta.courseID AS courseCode,
                   IFNULL(c.courseName, ta.courseID) AS courseName,
                   IFNULL(c.CreditUnit, 0) AS creditUnit,
                   IFNULL(p.abbrev, ta.progcode) AS progAbbrev,
                   ta.cyear,
                   ta.lectureday AS day, ta.StartTime AS startTime, ta.EndTime AS endTime
            FROM acad_teaching_allocation ta
            LEFT JOIN acad_course c ON c.courseID = ta.courseID
            LEFT JOIN acad_programme p ON p.progcode = ta.progcode
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
            ORDER BY ta.staffCode, ta.progcode, ta.cyear, ta.courseID";

        DataTable dtDet = ExecuteQuery(detSql,
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        // ── 3. Credit totals per lecturer (distinct courses only) ────────
        string creditSql = @"
            SELECT ta.staffCode, COALESCE(SUM(dc.cu), 0) AS totalCredits
            FROM (
                SELECT DISTINCT staffCode, courseID
                FROM acad_teaching_allocation
                WHERE acad_year = @year AND semester = @sem AND campusId = @campus
            ) ta
            LEFT JOIN acad_course dc ON dc.courseID = ta.courseID
            GROUP BY ta.staffCode";

        DataTable dtCredits = ExecuteQuery(creditSql,
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        // Build credit lookup
        Dictionary<string, int> creditMap = new Dictionary<string, int>();
        foreach (DataRow cr in dtCredits.Rows)
        {
            string sc = SafeStr(cr["staffCode"]);
            if (!string.IsNullOrEmpty(sc))
                creditMap[sc] = SafeInt(cr["totalCredits"]);
        }

        // ── 4. Build detail dictionary ───────────────────────────────────
        Dictionary<string, List<object>> detailMap = new Dictionary<string, List<object>>();
        foreach (DataRow dr in dtDet.Rows)
        {
            string sc = SafeStr(dr["staffCode"]);
            if (!detailMap.ContainsKey(sc))
                detailMap[sc] = new List<object>();

            detailMap[sc].Add(new {
                courseCode = SafeStr(dr["courseCode"]),
                courseName = SafeStr(dr["courseName"]),
                creditUnit = SafeInt(dr["creditUnit"]),
                progAbbrev = SafeStr(dr["progAbbrev"]),
                cyear      = SafeStr(dr["cyear"]),
                day        = SafeStr(dr["day"]),
                startTime  = SafeStr(dr["startTime"]),
                endTime    = SafeStr(dr["endTime"])
            });
        }

        // ── 5. Build summary rows ───────────────────────────────────────
        var rows = new List<object>();
        foreach (DataRow row in dtSumm.Rows)
        {
            string sc = SafeStr(row["staffCode"]);
            int credits = 0;
            if (creditMap.ContainsKey(sc)) credits = creditMap[sc];

            string progCsv = SafeStr(row["programmes_csv"]);
            string[] progList = !string.IsNullOrEmpty(progCsv)
                ? progCsv.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                : new string[0];

            rows.Add(new {
                staffCode      = sc,
                lecturerName   = SafeStr(row["lecturerName"]),
                empCode        = SafeStr(row["empCode"]),
                empType        = SafeStr(row["empType"]),
                contractType   = SafeStr(row["contractType"]),
                department     = SafeStr(row["department"]),
                faculty        = SafeStr(row["faculty"]),
                courseCount     = SafeInt(row["courseCount"]),
                programmeCount = SafeInt(row["programmeCount"]),
                scheduledHours = SafeDouble(row["scheduledHours"]),
                totalCredits   = credits,
                programmes_list = progList
            });
        }

        // ── 6. Faculties & Programmes for dropdowns ─────────────────────
        DataTable dtFac = ExecuteQuery(
            "SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name");

        var faculties = new List<object>();
        foreach (DataRow f in dtFac.Rows)
        {
            faculties.Add(new {
                code = SafeStr(f["faculty_code"]),
                name = SafeStr(f["faculty_name"])
            });
        }

        DataTable dtProg = ExecuteQuery(@"
            SELECT DISTINCT p.progcode, CONCAT(p.abbrev, ' - ', p.progname) AS display
            FROM acad_programme p
            INNER JOIN acad_teaching_allocation ta ON ta.progcode = p.progcode
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
            ORDER BY p.abbrev",
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        var programmes = new List<object>();
        foreach (DataRow pr in dtProg.Rows)
        {
            programmes.Add(new {
                code    = SafeStr(pr["progcode"]),
                display = SafeStr(pr["display"])
            });
        }

        // ── 7. Respond ──────────────────────────────────────────────────
        RespondJson(new {
            ok          = true,
            acadYear    = year,
            semester    = sem,
            campusId    = campus,
            faculties   = faculties,
            programmes  = programmes,
            rows        = rows,
            details     = detailMap
        });
    }
}
