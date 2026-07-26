using System;
using System.Collections.Generic;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_MarksDashboard : Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    protected void Page_Load(object sender, EventArgs e) { /* AJAX-powered — no server binding needed */ }

    [WebMethod(EnableSession = true)]
    public static string GetDashboardInit()
    {
        try
        {
            // Resolve this user's data scope (admin = all, dean = faculty, HOD = dept).
            MarksScope scope = MarksScopeResolver.Resolve();
            // Exam stats consider ONLY active (onboarded) students. Rather than a correlated
            // EXISTS (which forces a full scan of the now-684k registration table since the
            // 2007+ classic-marks migration), we INNER JOIN my_aspnet_users (ACTIVE_JOIN) so the
            // ~3.4k active students drive the query via the regno index. ~20x faster.
            string sf = scope.ProgFilter("cr");

            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();

                List<FilterOption> years = new List<FilterOption>();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT DISTINCT cr.acad_year
                    FROM campus_dynamics_portal.acad_course_registration cr
                    INNER JOIN campus_dynamics_portal.my_aspnet_users u ON u.name = cr.regno AND u.user_verification_status = 'ACTIVE STUDENT'
                    INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                    WHERE cr.acad_year IS NOT NULL AND TRIM(cr.acad_year) <> ''" + sf + @"
                    ORDER BY cr.acad_year DESC", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? string.Empty : rdr.GetString(0);
                        if (!string.IsNullOrEmpty(v)) years.Add(new FilterOption { value = v, text = v });
                    }
                }

                List<FilterOption> programmes = new List<FilterOption>();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT DISTINCT p.progcode, COALESCE(p.progname, p.progcode) AS progname
                    FROM acad_programme p
                    INNER JOIN campus_dynamics_portal.acad_course_registration cr ON cr.prog_id = p.progcode
                    INNER JOIN campus_dynamics_portal.my_aspnet_users u ON u.name = cr.regno AND u.user_verification_status = 'ACTIVE STUDENT'
                    INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                    WHERE 1=1" + sf + @"
                    ORDER BY progname", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? string.Empty : rdr.GetString(0);
                        string t = rdr.IsDBNull(1) ? v : rdr.GetString(1);
                        if (!string.IsNullOrEmpty(v)) programmes.Add(new FilterOption { value = v, text = t });
                    }
                }

                return Json.Serialize(new
                {
                    success = true,
                    years = years,
                    programmes = programmes,
                    scope = new { mode = scope.Mode, label = scope.Label, role = scope.RoleNote, isAdmin = scope.IsAdmin, hasAccess = scope.HasAccess }
                });
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load filters: " + ex.Message });
        }
    }

    [WebMethod(EnableSession = true)]
    public static string GetDashboardStats(string year, string semester, string programme)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                DashboardStats stats = BuildStats(conn, year, semester, programme, scope);
                return Json.Serialize(new
                {
                    success = true,
                    stats = stats,
                    scope = new { mode = scope.Mode, label = scope.Label, role = scope.RoleNote, isAdmin = scope.IsAdmin, hasAccess = scope.HasAccess }
                });
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load stats: " + ex.Message });
        }
    }

    // ===================================================================
    //  MARK CHANGES / AUDIT  (who changed what — from acad_marks_audit)
    //  Scope-filtered by the student's programme (join acad_student).
    // ===================================================================
    [WebMethod(EnableSession = true)]
    public static string GetMarkAuditStats(string days)
    {
        try
        {
            int d; if (!int.TryParse(days, out d) || d <= 0) d = 30;
            MarksScope scope = MarksScopeResolver.Resolve();
            string sf = scope.ProgFilter("s", "progid");
            var stats = new Dictionary<string, object>();
            var byAction = new List<object[]>();
            var topEditors = new List<object[]>();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT " +
                    " SUM(CASE WHEN a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY) THEN 1 ELSE 0 END) AS win, " +
                    " SUM(CASE WHEN a.action_type='DELETE' AND a.created_at >= (NOW() - INTERVAL @d DAY) THEN 1 ELSE 0 END) AS dels, " +
                    " COUNT(DISTINCT CASE WHEN a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY) THEN a.performed_by END) AS editors, " +
                    " COUNT(*) AS total_tracked " +
                    "FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno = a.regno " +
                    "WHERE a.target_table='acad_results'" + sf, conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    using (var rdr = cmd.ExecuteReader())
                        if (rdr.Read())
                        {
                            stats["window"] = ToInt(rdr["win"]);
                            stats["deletes"] = ToInt(rdr["dels"]);
                            stats["editors"] = ToInt(rdr["editors"]);
                            stats["total"] = ToInt(rdr["total_tracked"]);
                        }
                }
                using (var cmd = new MySqlCommand(
                    "SELECT a.action_type, COUNT(*) n FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno=a.regno " +
                    "WHERE a.target_table='acad_results' AND a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY)" + sf +
                    " GROUP BY a.action_type ORDER BY n DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read()) byAction.Add(new object[] { ToStr(rdr["action_type"]), ToInt(rdr["n"]) });
                }
                using (var cmd = new MySqlCommand(
                    "SELECT a.performed_by, COUNT(*) n FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno=a.regno " +
                    "WHERE a.target_table='acad_results' AND a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY)" + sf +
                    " GROUP BY a.performed_by ORDER BY n DESC LIMIT 5", conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read()) topEditors.Add(new object[] { ToStr(rdr["performed_by"]), ToInt(rdr["n"]) });
                }
            }
            stats["days"] = d;
            stats["by_action"] = byAction;
            stats["top_editors"] = topEditors;
            return Json.Serialize(new { success = true, stats = stats });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    [WebMethod(EnableSession = true)]
    public static string GetMarkAuditFeed(string days, string action, string q, string regno, string course, string limit)
    {
        try
        {
            int d; if (!int.TryParse(days, out d) || d <= 0) d = 90;
            int lim; if (!int.TryParse(limit, out lim) || (lim != 50 && lim != 100 && lim != 200 && lim != 500)) lim = 100;
            action = (action ?? "").Trim().ToUpperInvariant();
            q = (q ?? "").Trim();
            regno = (regno ?? "").Trim();
            course = (course ?? "").Trim();
            MarksScope scope = MarksScopeResolver.Resolve();
            string sf = scope.ProgFilter("s", "progid");

            string cond = " AND a.created_at >= (NOW() - INTERVAL @d DAY)";
            if (action == "CHANGES") cond += " AND a.action_type IN ('INSERT','UPDATE','DELETE')";
            else if (action != "" && action != "ALL") cond += " AND a.action_type=@act";
            if (regno != "") cond += " AND a.regno=@rg";
            if (course != "") cond += " AND a.course_id=@cs";
            if (q != "") cond += " AND (a.regno LIKE @q OR a.course_id LIKE @q OR a.performed_by LIKE @q OR TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) LIKE @q)";

            var rows = new List<Dictionary<string, object>>();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT a.audit_id, a.action_type, a.performed_by, a.regno, a.course_id, a.acad_year, a.semester, " +
                    " a.old_total, a.new_total, a.old_grade, a.new_grade, a.change_reason, a.source_page, a.ip_address, " +
                    " DATE_FORMAT(a.created_at,'%d %b %Y %H:%i') AS ts, " +
                    " TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student, " +
                    " COALESCE(c.courseName, a.course_id) AS course_name " +
                    "FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno = a.regno " +
                    "LEFT JOIN campus_dynamics.acad_course c ON c.courseID = a.course_id " +
                    "WHERE a.target_table='acad_results'" + sf + cond +
                    " ORDER BY a.created_at DESC, a.audit_id DESC LIMIT " + lim, conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    if (action != "" && action != "ALL" && action != "CHANGES") cmd.Parameters.AddWithValue("@act", action);
                    if (regno != "") cmd.Parameters.AddWithValue("@rg", regno);
                    if (course != "") cmd.Parameters.AddWithValue("@cs", course);
                    if (q != "") cmd.Parameters.AddWithValue("@q", "%" + q + "%");
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var m = new Dictionary<string, object>();
                            m["id"] = ToInt(rdr["audit_id"]);
                            m["action"] = ToStr(rdr["action_type"]);
                            m["actor"] = ToStr(rdr["performed_by"]);
                            m["regno"] = ToStr(rdr["regno"]);
                            m["student"] = ToStr(rdr["student"], "");
                            m["course"] = ToStr(rdr["course_id"]);
                            m["course_name"] = ToStr(rdr["course_name"], "");
                            m["acad"] = ToStr(rdr["acad_year"], "");
                            m["sem"] = ToStr(rdr["semester"], "");
                            m["old_total"] = rdr["old_total"] == DBNull.Value ? null : (object)ToInt(rdr["old_total"]);
                            m["new_total"] = rdr["new_total"] == DBNull.Value ? null : (object)ToInt(rdr["new_total"]);
                            m["old_grade"] = ToStr(rdr["old_grade"], "");
                            m["new_grade"] = ToStr(rdr["new_grade"], "");
                            m["reason"] = ToStr(rdr["change_reason"], "");
                            m["source"] = ToStr(rdr["source_page"], "");
                            m["ip"] = ToStr(rdr["ip_address"], "");
                            m["ts"] = ToStr(rdr["ts"], "");
                            rows.Add(m);
                        }
                    }
                }
            }
            return Json.Serialize(new { success = true, rows = rows });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }


    private static DashboardStats BuildStats(MySqlConnection conn, string year, string semester, string programme, MarksScope scope)
    {
        string courseExpr = GetCourseColumnExpression(conn, "cr");
        string courseCountSql = string.IsNullOrEmpty(courseExpr) ? "0" : "COUNT(DISTINCT " + courseExpr + ")";

        // Server-enforced scope predicate (cannot be widened from the client).
        // Active-student narrowing is done via an INNER JOIN on my_aspnet_users in each FROM
        // (see the ACTIVE-student join below) — index-driven, ~20x faster than a correlated EXISTS
        // now that the registration table holds 684k rows after the classic-marks migration.
        string scopeFilter = scope.ProgFilter("cr");

        // Build WHERE clause — applied to every query in this method
        string where = "WHERE 1=1" + scopeFilter;
        if (!string.IsNullOrEmpty(year))      where += " AND cr.acad_year = @year";
        if (!string.IsNullOrEmpty(semester))  where += " AND CAST(cr.semester AS CHAR) = @semester";
        if (!string.IsNullOrEmpty(programme)) where += " AND cr.prog_id = @programme";

        // ── Main query: ALL stats restricted to active students via INNER JOIN ──
        // Published rows are counted as final regardless of whether CW or Exam marks are NULL.
        string mainSql = @"
            SELECT
                COUNT(DISTINCT cr.regno)                                                                              AS active_students,
                COUNT(*)                                                                                              AS marks_records,
                " + courseCountSql + @"                                                                               AS course_count,
                COUNT(DISTINCT cr.prog_id)                                                                            AS prog_count,
                SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') = 'published'                      THEN 1 ELSE 0 END) AS published_count,
                SUM(CASE WHEN cr.provisional_marks_status = 'approved'                                    THEN 1 ELSE 0 END) AS approved_count,
                SUM(CASE WHEN cr.provisional_marks_status = 'rejected'                                    THEN 1 ELSE 0 END) AS rejected_count,
                SUM(CASE WHEN (cr.provisional_course_work_marks IS NOT NULL OR cr.provisional_exam_marks IS NOT NULL)
                              AND COALESCE(cr.provisional_marks_status,'pending') = 'pending'              THEN 1 ELSE 0 END) AS pending_count,
                SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL
                              AND COALESCE(cr.provisional_marks_status,'') <> 'published'                  THEN 1 ELSE 0 END) AS no_marks_count,
                SUM(CASE WHEN cr.provisional_course_work_marks IS NOT NULL AND cr.provisional_exam_marks IS NOT NULL
                              AND COALESCE(cr.provisional_marks_status,'pending') NOT IN ('published','rejected') THEN 1 ELSE 0 END) AS ready_count,
                SUM(CASE WHEN cr.provisional_course_work_marks IS NULL
                              AND COALESCE(cr.provisional_marks_status,'') <> 'published'                  THEN 1 ELSE 0 END) AS missing_cw,
                SUM(CASE WHEN cr.provisional_exam_marks IS NULL
                              AND COALESCE(cr.provisional_marks_status,'') <> 'published'                  THEN 1 ELSE 0 END) AS missing_exam
            FROM campus_dynamics_portal.acad_course_registration cr
            INNER JOIN campus_dynamics_portal.my_aspnet_users u ON u.name = cr.regno AND u.user_verification_status = 'ACTIVE STUDENT'
            INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
            " + where;

        var stats = new DashboardStats();

        using (MySqlCommand cmd = new MySqlCommand(mainSql, conn))
        {
            if (!string.IsNullOrEmpty(year))      cmd.Parameters.AddWithValue("@year",      year);
            if (!string.IsNullOrEmpty(semester))  cmd.Parameters.AddWithValue("@semester",  semester);
            if (!string.IsNullOrEmpty(programme)) cmd.Parameters.AddWithValue("@programme", programme);

            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read())
                {
                    stats.activeStudents         = ToInt(rdr["active_students"]);
                    stats.marksRecords           = ToInt(rdr["marks_records"]);
                    stats.courseCount            = ToInt(rdr["course_count"]);
                    stats.progCount              = ToInt(rdr["prog_count"]);
                    stats.publishedCount         = ToInt(rdr["published_count"]);
                    stats.approvedCount          = ToInt(rdr["approved_count"]);
                    stats.rejectedCount          = ToInt(rdr["rejected_count"]);
                    stats.pendingCount           = ToInt(rdr["pending_count"]);
                    stats.noMarksCount           = ToInt(rdr["no_marks_count"]);
                    stats.readyCount             = ToInt(rdr["ready_count"]);
                    stats.missingCourseworkCount = ToInt(rdr["missing_cw"]);
                    stats.missingExamCount       = ToInt(rdr["missing_exam"]);
                }
            }
        }

        // ── Top 10 courses with incomplete marks (active students, excluding published) ──
        if (!string.IsNullOrEmpty(courseExpr))
        {
            string topSql = @"
                SELECT " + courseExpr + @" AS course,
                       COALESCE(c.courseName, " + courseExpr + @") AS course_name,
                       COUNT(*) AS missing_count,
                       COUNT(DISTINCT cr.regno) AS students_affected
                FROM campus_dynamics_portal.acad_course_registration cr
                INNER JOIN campus_dynamics_portal.my_aspnet_users u ON u.name = cr.regno AND u.user_verification_status = 'ACTIVE STUDENT'
                INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                LEFT JOIN acad_course c ON c.courseID = " + courseExpr + @"
                WHERE (cr.provisional_course_work_marks IS NULL OR cr.provisional_exam_marks IS NULL)
                  AND COALESCE(cr.provisional_marks_status,'') <> 'published'" + scopeFilter +
                (string.IsNullOrEmpty(year)      ? "" : " AND cr.acad_year = @year") +
                (string.IsNullOrEmpty(semester)  ? "" : " AND CAST(cr.semester AS CHAR) = @semester") +
                (string.IsNullOrEmpty(programme) ? "" : " AND cr.prog_id = @programme") +
                " GROUP BY " + courseExpr + @", c.courseName ORDER BY missing_count DESC LIMIT 25";

            using (MySqlCommand cmd2 = new MySqlCommand(topSql, conn))
            {
                if (!string.IsNullOrEmpty(year))      cmd2.Parameters.AddWithValue("@year",      year);
                if (!string.IsNullOrEmpty(semester))  cmd2.Parameters.AddWithValue("@semester",  semester);
                if (!string.IsNullOrEmpty(programme)) cmd2.Parameters.AddWithValue("@programme", programme);

                stats.topMissingCourses = new List<TopCourse>();
                using (MySqlDataReader rdrTop = cmd2.ExecuteReader())
                {
                    while (rdrTop.Read())
                    {
                        stats.topMissingCourses.Add(new TopCourse
                        {
                            course           = ToStr(rdrTop["course"]),
                            courseName       = ToStr(rdrTop["course_name"]),
                            missingCount     = ToInt(rdrTop["missing_count"]),
                            studentsAffected = ToInt(rdrTop["students_affected"])
                        });
                    }
                }
            }
        }

        // ── Stats by programme (all programmes, same active-student + scope filters) ──
        // Wrap in subquery so ORDER BY sees plain columns, not aggregate expressions (MySQL limitation)
        string progSql = @"
            SELECT * FROM (
                SELECT cr.prog_id,
                       COALESCE(p.progname, cr.prog_id)                                                                       AS prog_name,
                       COUNT(DISTINCT cr.regno)                                                                               AS students,
                       COUNT(*)                                                                                               AS total,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') = 'published' THEN 1 ELSE 0 END)               AS published,
                       SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL
                                     AND COALESCE(cr.provisional_marks_status,'') <> 'published' THEN 1 ELSE 0 END)           AS no_marks,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') <> 'published'
                                     AND (cr.provisional_course_work_marks IS NULL OR cr.provisional_exam_marks IS NULL) THEN 1 ELSE 0 END) AS missing
                FROM campus_dynamics_portal.acad_course_registration cr
                INNER JOIN campus_dynamics_portal.my_aspnet_users u ON u.name = cr.regno AND u.user_verification_status = 'ACTIVE STUDENT'
                INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                LEFT JOIN acad_programme p ON p.progcode = cr.prog_id
                " + where + @"
                GROUP BY cr.prog_id, p.progname
            ) prog_data
            ORDER BY IF(total > 0, published / total, 0) ASC, total DESC";

        using (MySqlCommand cmd3 = new MySqlCommand(progSql, conn))
        {
            if (!string.IsNullOrEmpty(year))      cmd3.Parameters.AddWithValue("@year",      year);
            if (!string.IsNullOrEmpty(semester))  cmd3.Parameters.AddWithValue("@semester",  semester);
            if (!string.IsNullOrEmpty(programme)) cmd3.Parameters.AddWithValue("@programme", programme);

            stats.programmeStats = new List<ProgrammeStat>();
            using (MySqlDataReader rdrProg = cmd3.ExecuteReader())
            {
                while (rdrProg.Read())
                {
                    stats.programmeStats.Add(new ProgrammeStat
                    {
                        progCode  = ToStr(rdrProg["prog_id"]),
                        progName  = ToStr(rdrProg["prog_name"]),
                        students  = ToInt(rdrProg["students"]),
                        total     = ToInt(rdrProg["total"]),
                        published = ToInt(rdrProg["published"]),
                        noMarks   = ToInt(rdrProg["no_marks"]),
                        missing   = ToInt(rdrProg["missing"])
                    });
                }
            }
        }

        // ── Stats by FACULTY (active students, same scope + filters) ──────────
        stats.facultyStats  = BuildGroupStats(conn, where, year, semester, programme, true);
        // ── Stats by DEPARTMENT ───────────────────────────────────────────────
        stats.departmentStats = BuildGroupStats(conn, where, year, semester, programme, false);

        return stats;
    }

    /// <summary>
    /// Marks progress grouped by faculty (byFaculty=true) or department (false),
    /// resolved from acad_programme. Reuses the same active-student + scope WHERE.
    /// </summary>
    private static List<GroupStat> BuildGroupStats(MySqlConnection conn, string where,
        string year, string semester, string programme, bool byFaculty)
    {
        string keyExpr  = byFaculty ? "IFNULL(p.faculty_code,'')" : "CAST(IFNULL(p.department_id,0) AS CHAR)";
        string nameExpr = byFaculty
            ? "COALESCE(NULLIF(f.faculty_name,''), '(Unassigned faculty)')"
            : "COALESCE(NULLIF(d.dept_name,''), '(Unassigned department)')";
        string joinExpr = byFaculty
            ? "LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code"
            : "LEFT JOIN hrm_departments d ON d.ID = p.department_id";

        string sql = @"
            SELECT * FROM (
                SELECT " + keyExpr + @" AS gkey,
                       " + nameExpr + @" AS gname,
                       COUNT(DISTINCT cr.regno)                                                                       AS students,
                       COUNT(*)                                                                                       AS total,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') = 'published' THEN 1 ELSE 0 END)        AS published,
                       SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL
                                     AND COALESCE(cr.provisional_marks_status,'') <> 'published' THEN 1 ELSE 0 END)    AS no_marks,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') <> 'published'
                                     AND (cr.provisional_course_work_marks IS NULL OR cr.provisional_exam_marks IS NULL) THEN 1 ELSE 0 END) AS missing
                FROM campus_dynamics_portal.acad_course_registration cr
                INNER JOIN campus_dynamics_portal.my_aspnet_users u ON u.name = cr.regno AND u.user_verification_status = 'ACTIVE STUDENT'
                INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                LEFT JOIN acad_programme p ON p.progcode = cr.prog_id
                " + joinExpr + @"
                " + where + @"
                GROUP BY gkey, gname
            ) g
            ORDER BY IF(total > 0, published / total, 0) ASC, total DESC";

        var list = new List<GroupStat>();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (!string.IsNullOrEmpty(year))      cmd.Parameters.AddWithValue("@year",      year);
            if (!string.IsNullOrEmpty(semester))  cmd.Parameters.AddWithValue("@semester",  semester);
            if (!string.IsNullOrEmpty(programme)) cmd.Parameters.AddWithValue("@programme", programme);

            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    list.Add(new GroupStat
                    {
                        name      = ToStr(rdr["gname"]),
                        students  = ToInt(rdr["students"]),
                        total     = ToInt(rdr["total"]),
                        published = ToInt(rdr["published"]),
                        noMarks   = ToInt(rdr["no_marks"]),
                        missing   = ToInt(rdr["missing"])
                    });
                }
            }
        }
        return list;
    }

    private static int ToInt(object value)
    {
        return value == null || value == DBNull.Value ? 0 : Convert.ToInt32(value);
    }

    private static string ToStr(object value, string fallback = "-")
    {
        return value == null || value == DBNull.Value ? fallback : value.ToString();
    }

    private static string GetConnStr()
    {
        return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    }

    private static string GetCourseColumnExpression(MySqlConnection conn, string alias)
    {
        string prefix = string.IsNullOrEmpty(alias) ? string.Empty : alias + ".";
        if (ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "courseID"))
            return prefix + "courseID";
        if (ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "course_code"))
            return prefix + "course_code";
        return null;
    }

    private static bool ColumnExists(MySqlConnection conn, string schema, string table, string column)
    {
        const string sql = @"SELECT COUNT(*) FROM information_schema.COLUMNS
                             WHERE TABLE_SCHEMA=@schema AND TABLE_NAME=@table AND COLUMN_NAME=@column";
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@schema", schema);
            cmd.Parameters.AddWithValue("@table", table);
            cmd.Parameters.AddWithValue("@column", column);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    private class FilterOption { public string value { get; set; } public string text { get; set; } }

    private class TopCourse
    {
        public string course           { get; set; }
        public string courseName       { get; set; }
        public int    missingCount     { get; set; }
        public int    studentsAffected { get; set; }
    }

    private class ProgrammeStat
    {
        public string progCode  { get; set; }
        public string progName  { get; set; }
        public int    students  { get; set; }
        public int    total     { get; set; }
        public int    published { get; set; }
        public int    noMarks   { get; set; }
        public int    missing   { get; set; }
    }

    private class GroupStat
    {
        public string name      { get; set; }
        public int    students  { get; set; }
        public int    total     { get; set; }
        public int    published { get; set; }
        public int    noMarks   { get; set; }
        public int    missing   { get; set; }
    }

    private class DashboardStats
    {
        public int activeStudents         { get; set; }
        public int marksRecords           { get; set; }
        public int courseCount            { get; set; }
        public int progCount              { get; set; }
        public int publishedCount         { get; set; }
        public int approvedCount          { get; set; }
        public int rejectedCount          { get; set; }
        public int pendingCount           { get; set; }
        public int noMarksCount           { get; set; }
        public int readyCount             { get; set; }
        public int missingCourseworkCount { get; set; }
        public int missingExamCount       { get; set; }
        public List<TopCourse>     topMissingCourses { get; set; }
        public List<ProgrammeStat> programmeStats    { get; set; }
        public List<GroupStat>     facultyStats      { get; set; }
        public List<GroupStat>     departmentStats   { get; set; }
    }
}
