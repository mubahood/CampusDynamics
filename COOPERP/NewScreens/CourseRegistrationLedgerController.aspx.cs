using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_CourseRegistrationLedgerController : System.Web.UI.Page
{
    private string _sortField = "latest";
    private string _sortDir = "desc";

    private static List<string> _cachedAcadYears;
    private static List<string[]> _cachedProgrammes;
    private static List<string[]> _cachedCourses;
    private static DateTime _lookupCacheExpiry = DateTime.MinValue;
    private static readonly object _lookupCacheLock = new object();

    private string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadLookups();
        ApplyQueryToControls();
        BindGrid();
        LoadStats();
    }

    private void LoadStats()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                EnsureRegistrationAuditColumns(conn);

                bool hasEditAuditTrail = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_audit_trail");

                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT
                        (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr2
                         INNER JOIN acad_results ar ON ar.regno = cr2.regno AND ar.courseid = cr2.courseID
                            AND ar.acad = cr2.acad_year AND ar.semester = cr2.semester
                         WHERE (ar.score IS NOT NULL AND ar.score <> '') OR (ar.grade IS NOT NULL AND ar.grade <> '')) AS with_marks,
                        (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration WHERE UPPER(COALESCE(course_status,'')) = 'RETAKE') AS retake_count", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litWithMarks.Text     = Convert.ToInt64(rdr["with_marks"]).ToString("N0");
                        litRetakeCount.Text   = Convert.ToInt64(rdr["retake_count"]).ToString("N0");
                    }
                }

                if (hasEditAuditTrail)
                {
                    using (MySqlCommand cmd2 = new MySqlCommand(
                        @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration
                          WHERE edit_audit_trail IS NOT NULL AND edit_audit_trail <> ''", conn))
                    {
                        litChangedCount.Text = Convert.ToInt64(cmd2.ExecuteScalar()).ToString("N0");
                    }
                }
                else
                {
                    litChangedCount.Text = "0";
                }
            }
        }
        catch { }
    }

    private void LoadLookups()
    {
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new ListItem("All", ""));

        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("All", ""));

        ddlCourse.Items.Clear();
        ddlCourse.Items.Add(new ListItem("All", ""));

        EnsureLookupCache();

        if (_cachedAcadYears != null)
        {
            foreach (string y in _cachedAcadYears)
                ddlAcadYear.Items.Add(new ListItem(y, y));
        }

        if (_cachedProgrammes != null)
        {
            foreach (string[] p in _cachedProgrammes)
                ddlProgramme.Items.Add(new ListItem(p[1], p[0]));
        }

        if (_cachedCourses != null)
        {
            foreach (string[] c in _cachedCourses)
                ddlCourse.Items.Add(new ListItem(c[0] + " - " + c[1], c[0]));
        }
    }

    private void EnsureLookupCache()
    {
        bool refreshNeeded;
        lock (_lookupCacheLock)
        {
            refreshNeeded = _cachedAcadYears == null || DateTime.UtcNow > _lookupCacheExpiry;
        }

        if (!refreshNeeded)
            return;

        List<string> acadYears = new List<string>();
        List<string[]> programmes = new List<string[]>();
        List<string[]> courses = new List<string[]>();

        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            EnsureRegistrationAuditColumns(conn);

            bool hasMarksEditFlag = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "marks_edit_flag");
            bool hasEditReason = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_reason");
            bool hasEditAuditTrail = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_audit_trail");

            string marksEditFlagSelect = hasMarksEditFlag ? "COALESCE(cr.marks_edit_flag, '-') AS marks_edit_flag," : "'-' AS marks_edit_flag,";
            string editReasonSelect = hasEditReason ? "COALESCE(cr.edit_reason, '-') AS edit_reason," : "'-' AS edit_reason,";
            string editAuditTrailSelect = hasEditAuditTrail ? "COALESCE(cr.edit_audit_trail, '-') AS edit_audit_trail," : "'-' AS edit_audit_trail,";

            using (MySqlCommand cmd = new MySqlCommand(@"SELECT DISTINCT acad_year FROM campus_dynamics_portal.acad_course_registration WHERE acad_year IS NOT NULL AND acad_year <> '' ORDER BY acad_year DESC", conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                    acadYears.Add(rdr["acad_year"].ToString());
            }

            using (MySqlCommand cmd = new MySqlCommand(@"SELECT progcode, progname FROM acad_programme ORDER BY progname", conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                    programmes.Add(new string[] { rdr["progcode"].ToString(), rdr["progname"].ToString() });
            }

            using (MySqlCommand cmd = new MySqlCommand(@"SELECT courseID, courseName FROM acad_course ORDER BY courseName", conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                    courses.Add(new string[] { rdr["courseID"].ToString(), rdr["courseName"].ToString() });
            }
        }

        lock (_lookupCacheLock)
        {
            _cachedAcadYears = acadYears;
            _cachedProgrammes = programmes;
            _cachedCourses = courses;
            _lookupCacheExpiry = DateTime.UtcNow.AddMinutes(10);
        }
    }

    private void ApplyQueryToControls()
    {
        TrySelect(ddlAcadYear, Request.QueryString["acad"]);
        TrySelect(ddlSemester, Request.QueryString["sem"]);
        TrySelect(ddlProgramme, Request.QueryString["prog"]);
        TrySelect(ddlCourse, Request.QueryString["course"]);
        TrySelect(ddlStatus, Request.QueryString["status"]);
        TrySelect(ddlChanged, Request.QueryString["changed"]);
        TrySelect(ddlPageSize, Request.QueryString["size"]);
        txtStudent.Text = (Request.QueryString["student"] ?? string.Empty).Trim();
    }

    private void TrySelect(DropDownList ddl, string value)
    {
        if (string.IsNullOrEmpty(value)) return;
        ListItem li = ddl.Items.FindByValue(value);
        if (li != null)
            ddl.SelectedValue = value;
    }

    private void BindGrid()
    {
        string acad = GetQueryValue("acad");
        string sem = GetQueryValue("sem");
        string prog = GetQueryValue("prog");
        string course = GetQueryValue("course");
        string status = GetQueryValue("status");
        string changed = GetQueryValue("changed");
        string student = GetQueryValue("student");

        _sortField = NormalizeSortField(GetQueryValue("sort"));
        _sortDir = NormalizeSortDir(GetQueryValue("dir"));

        int page = ParseInt(Request.QueryString["page"], 1, 1, 1000000);
        int pageSize = ParseInt(Request.QueryString["size"], ParseInt(ddlPageSize.SelectedValue, 50, 1, 200), 1, 200);
        int offset = (page - 1) * pageSize;

        string where = BuildWhereClause(acad, sem, prog, course, status, student);

        int totalRows = 0;
        DataTable dt = new DataTable();

        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();

            EnsureRegistrationAuditColumns(conn);

            bool hasMarksEditFlag = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "marks_edit_flag");
            bool hasEditReason = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_reason");
            bool hasEditAuditTrail = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_audit_trail");
            bool hasChangeDate = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "change_date");

            string marksEditFlagSelect = hasMarksEditFlag ? "COALESCE(cr.marks_edit_flag, '-') AS marks_edit_flag," : "'-' AS marks_edit_flag,";
            string editReasonSelect = hasEditReason ? "COALESCE(cr.edit_reason, '-') AS edit_reason," : "'-' AS edit_reason,";
            string editAuditTrailSelect = hasEditAuditTrail ? "COALESCE(cr.edit_audit_trail, '-') AS edit_audit_trail," : "'-' AS edit_audit_trail,";
            string changeDateSelect = hasChangeDate ? "COALESCE(DATE_FORMAT(cr.change_date, '%Y-%m-%d %H:%i'), '-') AS change_date," : "'-' AS change_date,";
            string schemaWhere = where;

            if (!string.IsNullOrEmpty(changed))
            {
                if (hasEditAuditTrail)
                {
                    if (string.Equals(changed, "yes", StringComparison.OrdinalIgnoreCase))
                        schemaWhere += " AND COALESCE(NULLIF(cr.edit_audit_trail,''), '') <> ''";
                    else if (string.Equals(changed, "no", StringComparison.OrdinalIgnoreCase))
                        schemaWhere += " AND COALESCE(NULLIF(cr.edit_audit_trail,''), '') = ''";
                }
                else if (string.Equals(changed, "yes", StringComparison.OrdinalIgnoreCase))
                {
                    schemaWhere += " AND 1=0";
                }
            }

            string effectiveSortField = (!hasChangeDate && _sortField == "change_date") ? "latest" : _sortField;

            string fromSqlBase = @"
                FROM campus_dynamics_portal.acad_course_registration cr
                LEFT JOIN acad_student s ON s.regno = cr.regno
                LEFT JOIN acad_programme p ON p.progcode = cr.prog_id
                LEFT JOIN acad_course c ON c.courseID = cr.courseID";

            using (MySqlCommand countCmd = new MySqlCommand("SELECT COUNT(*) " + fromSqlBase + schemaWhere, conn))
            {
                AddWhereParameters(countCmd, acad, sem, prog, course, status, student);
                totalRows = Convert.ToInt32(countCmd.ExecuteScalar());
            }

            int totalPages = totalRows > 0 ? (int)Math.Ceiling(totalRows / (double)pageSize) : 1;
            if (page > totalPages)
            {
                page = totalPages;
                offset = (page - 1) * pageSize;
            }

            bool heavyResultsSort = effectiveSortField == "marks" || effectiveSortField == "grade";
            string dataSql;

            if (heavyResultsSort)
            {
                string fromSqlWithResults = fromSqlBase + @"
                    LEFT JOIN (
                        SELECT regno, courseid, acad, semester,
                               MAX(score) AS score,
                               MAX(grade) AS grade,
                               MAX(result_comment) AS result_comment
                        FROM acad_results
                        GROUP BY regno, courseid, acad, semester
                    ) rs ON rs.regno = cr.regno
                        AND rs.courseid = cr.courseID
                        AND rs.acad = cr.acad_year
                        AND rs.semester = cr.semester";

                dataSql = @"
                    SELECT cr.id AS ID,
                           cr.regno,
                           TRIM(CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,''))) AS student_name,
                           COALESCE(cr.prog_id, COALESCE(s.progid,'')) AS prog_id,
                           COALESCE(p.progname, '-') AS programme_name,
                           cr.courseID,
                           COALESCE(c.courseName, cr.courseID) AS course_name,
                           cr.acad_year,
                           cr.semester,
                           COALESCE(cr.course_status, '-') AS course_status,
                           COALESCE(rs.score, '-') AS score,
                           COALESCE(rs.grade, '-') AS grade,
                                                     " + marksEditFlagSelect + @"
                                                     " + editReasonSelect + @"
                                                     " + editAuditTrailSelect + @"
                                               " + changeDateSelect + @"
                           COALESCE(rs.result_comment, '-') AS result_comment
                      " + fromSqlWithResults + schemaWhere + @"
                      ORDER BY " + BuildOrderBy(effectiveSortField, _sortDir) + @"
                    LIMIT @offset, @pageSize";
            }
            else
            {
                dataSql = @"
                    SELECT pr.ID,
                           pr.regno,
                           pr.student_name,
                           pr.prog_id,
                           pr.programme_name,
                           pr.courseID,
                           pr.course_name,
                           pr.acad_year,
                           pr.semester,
                           pr.course_status,
                           COALESCE(ar.score, '-') AS score,
                           COALESCE(ar.grade, '-') AS grade,
                              pr.marks_edit_flag,
                              pr.edit_reason,
                              pr.edit_audit_trail,
                                        pr.change_date,
                           COALESCE(ar.result_comment, '-') AS result_comment
                    FROM (
                        SELECT cr.id AS ID,
                               cr.regno,
                               TRIM(CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,''))) AS student_name,
                               COALESCE(cr.prog_id, COALESCE(s.progid,'')) AS prog_id,
                               COALESCE(p.progname, '-') AS programme_name,
                               cr.courseID,
                               COALESCE(c.courseName, cr.courseID) AS course_name,
                               cr.acad_year,
                               cr.semester,
                               " + marksEditFlagSelect + @"
                               " + editReasonSelect + @"
                               " + editAuditTrailSelect + @"
                               " + changeDateSelect + @"
                               COALESCE(cr.course_status, '-') AS course_status
                           " + fromSqlBase + schemaWhere + @"
                           ORDER BY " + BuildOrderByBase(effectiveSortField, _sortDir) + @"
                        LIMIT @offset, @pageSize
                    ) pr
                    LEFT JOIN acad_results ar ON ar.ID = (
                        SELECT MAX(r2.ID)
                        FROM acad_results r2
                        WHERE r2.regno = pr.regno
                          AND r2.courseid = pr.courseID
                          AND r2.acad = pr.acad_year
                          AND r2.semester = pr.semester
                    )";
            }

            using (MySqlCommand dataCmd = new MySqlCommand(dataSql, conn))
            {
                AddWhereParameters(dataCmd, acad, sem, prog, course, status, student);
                dataCmd.Parameters.AddWithValue("@offset", offset);
                dataCmd.Parameters.AddWithValue("@pageSize", pageSize);

                using (MySqlDataAdapter da = new MySqlDataAdapter(dataCmd))
                    da.Fill(dt);
            }

            if (!dt.Columns.Contains("row_no"))
                dt.Columns.Add("row_no", typeof(int));

            int row = offset + 1;
            foreach (DataRow dr in dt.Rows)
                dr["row_no"] = row++;

            rptRows.DataSource = dt;
            rptRows.DataBind();
            phEmpty.Visible = dt.Rows.Count == 0;

            litTotal.Text        = totalRows.ToString("N0");
            litTotalDisplay.Text = totalRows.ToString("N0");
            litTotalDisplayTop.Text = totalRows.ToString("N0");
            litPeriodHint.Text = BuildPeriodHint(acad, sem);
            int rangeFrom = totalRows == 0 ? 0 : offset + 1;
            int rangeTo   = Math.Min(offset + pageSize, totalRows);
            litPageRangeInfo.Text = rangeFrom + " - " + rangeTo;
            litPageInfo.Text = "Page " + page + " of " + totalPages;
            litPager.Text = BuildPager(page, totalPages, acad, sem, prog, course, status, changed, student, pageSize, _sortField, _sortDir);
        }
    }

    private string BuildPeriodHint(string acad, string sem)
    {
        string year = string.IsNullOrEmpty(acad) ? "All Years" : acad;
        string semester = string.IsNullOrEmpty(sem) ? "All Semesters" : ("Sem " + sem);
        return year + " / " + semester;
    }

    private string NormalizeSortField(string sortField)
    {
        switch ((sortField ?? string.Empty).Trim().ToLower())
        {
            case "latest":
            case "regno":
            case "student":
            case "programme":
            case "course":
            case "course_name":
            case "acad_year":
            case "semester":
            case "status":
            case "marks":
            case "grade":
            case "change_date":
                return sortField.Trim().ToLower();
            default:
                return "latest";
        }
    }

    private string NormalizeSortDir(string dir)
    {
        string cleaned = (dir ?? string.Empty).Trim().ToLower();
        return cleaned == "asc" ? "asc" : "desc";
    }

    private string BuildOrderBy(string sortField, string sortDir)
    {
        string dir = sortDir == "asc" ? "ASC" : "DESC";

        switch (sortField)
        {
            case "regno":
                return "cr.regno " + dir + ", cr.courseID ASC";
            case "student":
                return "student_name " + dir + ", cr.regno ASC";
            case "programme":
                return "programme_name " + dir + ", cr.regno ASC";
            case "course":
                return "cr.courseID " + dir + ", cr.regno ASC";
            case "course_name":
                return "course_name " + dir + ", cr.courseID ASC";
            case "acad_year":
                return "cr.acad_year " + dir + ", cr.semester " + dir + ", cr.regno DESC";
            case "semester":
                return "cr.semester " + dir + ", cr.acad_year DESC, cr.regno DESC";
            case "status":
                return "cr.course_status " + dir + ", cr.acad_year DESC, cr.semester DESC";
            case "marks":
                return "CAST(COALESCE(NULLIF(rs.score,''), '0') AS DECIMAL(10,2)) " + dir + ", cr.acad_year DESC, cr.semester DESC";
            case "grade":
                return "rs.grade " + dir + ", cr.acad_year DESC, cr.semester DESC";
            case "change_date":
                return "cr.change_date " + dir + ", cr.acad_year DESC, cr.semester DESC";
            case "latest":
            default:
                return "cr.acad_year " + dir + ", cr.semester " + dir + ", cr.regno DESC, cr.courseID ASC";
        }
    }

    private string BuildOrderByBase(string sortField, string sortDir)
    {
        string dir = sortDir == "asc" ? "ASC" : "DESC";

        switch (sortField)
        {
            case "regno":
                return "cr.regno " + dir + ", cr.courseID ASC";
            case "student":
                return "student_name " + dir + ", cr.regno ASC";
            case "programme":
                return "programme_name " + dir + ", cr.regno ASC";
            case "course":
                return "cr.courseID " + dir + ", cr.regno ASC";
            case "course_name":
                return "course_name " + dir + ", cr.courseID ASC";
            case "acad_year":
                return "cr.acad_year " + dir + ", cr.semester " + dir + ", cr.regno DESC";
            case "semester":
                return "cr.semester " + dir + ", cr.acad_year DESC, cr.regno DESC";
            case "status":
                return "cr.course_status " + dir + ", cr.acad_year DESC, cr.semester DESC";
            case "change_date":
                return "cr.change_date " + dir + ", cr.acad_year DESC, cr.semester DESC";
            case "latest":
            default:
                return "cr.acad_year " + dir + ", cr.semester " + dir + ", cr.regno DESC, cr.courseID ASC";
        }
    }

    private string BuildWhereClause(string acad, string sem, string prog, string course, string status, string student)
    {
        StringBuilder where = new StringBuilder(" WHERE 1=1");

        if (!string.IsNullOrEmpty(acad))
            where.Append(" AND cr.acad_year = @acad");

        if (!string.IsNullOrEmpty(sem))
            where.Append(" AND cr.semester = @sem");

        if (!string.IsNullOrEmpty(prog))
            where.Append(" AND COALESCE(cr.prog_id, COALESCE(s.progid,'')) = @prog");

        if (!string.IsNullOrEmpty(course))
            where.Append(" AND cr.courseID = @course");

        if (!string.IsNullOrEmpty(status))
            where.Append(" AND UPPER(COALESCE(cr.course_status,'')) = @status");

        if (!string.IsNullOrEmpty(student))
            where.Append(" AND (cr.regno LIKE @student OR CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) LIKE @student)");

        return where.ToString();
    }

    private void AddWhereParameters(MySqlCommand cmd, string acad, string sem, string prog, string course, string status, string student)
    {
        if (!string.IsNullOrEmpty(acad))
            cmd.Parameters.AddWithValue("@acad", acad);

        if (!string.IsNullOrEmpty(sem))
            cmd.Parameters.AddWithValue("@sem", ParseInt(sem, 1, 1, 3));

        if (!string.IsNullOrEmpty(prog))
            cmd.Parameters.AddWithValue("@prog", prog);

        if (!string.IsNullOrEmpty(course))
            cmd.Parameters.AddWithValue("@course", course);

        if (!string.IsNullOrEmpty(status))
            cmd.Parameters.AddWithValue("@status", status.Trim().ToUpper());

        if (!string.IsNullOrEmpty(student))
            cmd.Parameters.AddWithValue("@student", "%" + student + "%");
    }

    private string GetQueryValue(string key)
    {
        return (Request.QueryString[key] ?? string.Empty).Trim();
    }

    private int ParseInt(string value, int fallback, int min, int max)
    {
        int parsed;
        if (!int.TryParse(value, out parsed)) return fallback;
        if (parsed < min) return min;
        if (parsed > max) return max;
        return parsed;
    }

    private static int ParseIntSafe(string value, int fallback)
    {
        int parsed;
        if (!int.TryParse(value, out parsed)) return fallback;
        return parsed;
    }

    private string BuildPager(int page, int totalPages, string acad, string sem, string prog, string course, string status, string changed, string student, int pageSize, string sortField, string sortDir)
    {
        if (totalPages <= 1) return string.Empty;

        StringBuilder sb = new StringBuilder();

        if (page > 1)
            sb.Append("<a href='" + BuildUrl(page - 1, acad, sem, prog, course, status, changed, student, pageSize, sortField, sortDir) + "'>&laquo; Prev</a>");

        int start = Math.Max(1, page - 2);
        int end = Math.Min(totalPages, start + 4);
        start = Math.Max(1, end - 4);

        for (int i = start; i <= end; i++)
        {
            if (i == page)
                sb.Append("<span class='active'>" + i + "</span>");
            else
                sb.Append("<a href='" + BuildUrl(i, acad, sem, prog, course, status, changed, student, pageSize, sortField, sortDir) + "'>" + i + "</a>");
        }

        if (page < totalPages)
            sb.Append("<a href='" + BuildUrl(page + 1, acad, sem, prog, course, status, changed, student, pageSize, sortField, sortDir) + "'>Next &raquo;</a>");

        return sb.ToString();
    }

    private string BuildUrl(int page, string acad, string sem, string prog, string course, string status, string changed, string student, int pageSize, string sortField, string sortDir)
    {
        var q = HttpUtility.ParseQueryString(string.Empty);
        q["page"] = page.ToString();
        q["size"] = pageSize.ToString();
        q["sort"] = sortField;
        q["dir"] = sortDir;

        if (!string.IsNullOrEmpty(acad)) q["acad"] = acad;
        if (!string.IsNullOrEmpty(sem)) q["sem"] = sem;
        if (!string.IsNullOrEmpty(prog)) q["prog"] = prog;
        if (!string.IsNullOrEmpty(course)) q["course"] = course;
        if (!string.IsNullOrEmpty(status)) q["status"] = status;
        if (!string.IsNullOrEmpty(changed)) q["changed"] = changed;
        if (!string.IsNullOrEmpty(student)) q["student"] = student;

        return Request.Path + "?" + q.ToString();
    }

    protected string BuildSortHeader(string field, string label)
    {
        string activeField = _sortField;
        string activeDir = _sortDir;

        bool isActive = string.Equals(activeField, field, StringComparison.OrdinalIgnoreCase);
        string nextDir = "asc";
        string icon = "↕";

        if (isActive)
        {
            if (activeDir == "asc")
            {
                nextDir = "desc";
                icon = "↑";
            }
            else
            {
                nextDir = "asc";
                icon = "↓";
            }
        }

        var q = HttpUtility.ParseQueryString(Request.QueryString.ToString());
        q["page"] = "1";
        q["sort"] = field;
        q["dir"] = nextDir;

        string url = Request.Path + "?" + q.ToString();
        return "<a class='rl-th-link' href='" + url + "'>" + label + " <span class='rl-th-icon'>" + icon + "</span></a>";
    }

    protected string GetStatusBadge(object statusObj)
    {
        string status = statusObj == null ? "-" : statusObj.ToString().ToUpper();

        if (status == "REGULAR" || status == "NORMAL")
            return "<span class='rl-pill rl-pill--regular'>" + status + "</span>";
        if (status == "RETAKE")
            return "<span class='rl-pill rl-pill--retake'>RETAKE</span>";
        return "<span class='rl-pill rl-pill--pending'>" + status + "</span>";
    }

    /// <summary>
    /// WebMethod to fetch complete course registration record details for a specific registration.
    /// Called via AJAX from the modal popup when user clicks on a registration number.
    /// 
    /// PARAMETERS:
    ///   - regno: Student registration number (e.g., "REG001234")
    ///   - acad_year: Academic year (e.g., "2023/2024")
    ///   - semester: Semester number (1, 2, or 3)
    ///   - course_id: Course ID/code (e.g., "CS101")
    /// 
    /// RETURNS: JSON object with structure:
    /// {
    ///   "d": {
    ///     "success": true/false,
    ///     "message": "error message if failed",
    ///     "data": {
    ///       "regno": "...",
    ///       "student_name": "...",
    ///       "programme_name": "...",
    ///       "courseID": "...",
    ///       "course_name": "...",
    ///       "acad_year": "...",
    ///       "semester": "...",
    ///       "course_status": "...",
    ///       "score": "...",
    ///       "grade": "...",
    ///       "result_comment": "..."
    ///     }
    ///   }
    /// }
    /// 
    /// DATA SOURCES:
    ///   1. acad_course_registration: Core registration record
    ///   2. acad_student: Student demographic info
    ///   3. acad_programme: Programme/degree info
    ///   4. acad_course: Course metadata
    ///   5. acad_results: Assessment results (marks, grades, comments)
    /// 
    /// SECURITY: Properly parameterized SQL to prevent injection.
    /// PERFORMANCE: Single query with efficient LEFT JOINs, suitable for real-time modal display.
    /// </summary>
    [WebMethod]
    public static string GetRecordDetailJson(string regno, string acad_year, string semester, string course_id)
    {
        try
        {
            // Input validation
            if (string.IsNullOrWhiteSpace(regno) || string.IsNullOrWhiteSpace(acad_year) || 
                string.IsNullOrWhiteSpace(semester) || string.IsNullOrWhiteSpace(course_id))
            {
                return CreateJsonResponse(false, "Invalid parameters provided.", null);
            }

            string connStr = WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                EnsureRegistrationAuditColumns(conn);

                bool hasEditReason = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_reason");
                bool hasEditAuditTrail = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_audit_trail");
                bool hasChangeDate = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "change_date");
                string editReasonSelect = hasEditReason ? "COALESCE(cr.edit_reason, '-') AS edit_reason," : "'-' AS edit_reason,";
                string editAuditTrailSelect = hasEditAuditTrail ? "COALESCE(cr.edit_audit_trail, '-') AS edit_audit_trail," : "'-' AS edit_audit_trail,";
                string changeDateSelect = hasChangeDate ? "COALESCE(DATE_FORMAT(cr.change_date, '%Y-%m-%d %H:%i'), '-') AS change_date," : "'-' AS change_date,";

                // MAIN QUERY: Fetch complete record details with all related information
                string sql = @"
                    SELECT 
                           cr.regno,
                           TRIM(CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,''))) AS student_name,
                           COALESCE(cr.prog_id, COALESCE(s.progid,'')) AS prog_id,
                           COALESCE(p.progname, '-') AS programme_name,
                           cr.courseID,
                           COALESCE(c.courseName, cr.courseID) AS course_name,
                           cr.acad_year,
                           cr.semester,
                           COALESCE(cr.course_status, '-') AS course_status,
                           COALESCE(rs.score, '-') AS score,
                           COALESCE(rs.grade, '-') AS grade,
                          " + editReasonSelect + @"
                          " + editAuditTrailSelect + @"
                          " + changeDateSelect + @"
                           COALESCE(rs.result_comment, '-') AS result_comment
                      FROM campus_dynamics_portal.acad_course_registration cr
                      LEFT JOIN acad_student s ON s.regno = cr.regno
                      LEFT JOIN acad_programme p ON p.progcode = COALESCE(cr.prog_id, COALESCE(s.progid,''))
                      LEFT JOIN acad_course c ON c.courseID = cr.courseID
                      LEFT JOIN acad_results rs ON rs.regno = cr.regno
                                                   AND rs.courseid = cr.courseID
                                                   AND rs.acad = cr.acad_year
                                                   AND rs.semester = cr.semester
                     WHERE cr.regno = @regno
                       AND cr.acad_year = @acad_year
                       AND cr.semester = @semester
                       AND cr.courseID = @course_id
                     LIMIT 1";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno.Trim());
                    cmd.Parameters.AddWithValue("@acad_year", acad_year.Trim());
                    cmd.Parameters.AddWithValue("@semester", semester.Trim());
                    cmd.Parameters.AddWithValue("@course_id", course_id.Trim());

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            // Build dictionary of record details
                            var recordData = new Dictionary<string, object>
                            {
                                { "regno", GetDBString(rdr, "regno") },
                                { "student_name", GetDBString(rdr, "student_name") },
                                { "prog_id", GetDBString(rdr, "prog_id") },
                                { "programme_name", GetDBString(rdr, "programme_name") },
                                { "courseID", GetDBString(rdr, "courseID") },
                                { "course_name", GetDBString(rdr, "course_name") },
                                { "acad_year", GetDBString(rdr, "acad_year") },
                                { "semester", GetDBString(rdr, "semester") },
                                { "course_status", GetDBString(rdr, "course_status") },
                                { "score", GetDBString(rdr, "score") },
                                { "grade", GetDBString(rdr, "grade") },
                                { "edit_reason", GetDBString(rdr, "edit_reason") },
                                { "edit_audit_trail", GetDBString(rdr, "edit_audit_trail") },
                                { "change_date", GetDBString(rdr, "change_date") },
                                { "result_comment", GetDBString(rdr, "result_comment") }
                            };

                            return CreateJsonResponse(true, null, recordData);
                        }
                        else
                        {
                            return CreateJsonResponse(false, "Record not found. Please check the registration details.", null);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return CreateJsonResponse(false, "Error retrieving record details: " + ex.Message, null);
        }
    }

    /// <summary>
    /// Helper method to safely retrieve string values from DataReader,
    /// returning empty string if value is DBNull.
    /// </summary>
    private static string GetDBString(MySqlDataReader rdr, string columnName)
    {
        int ordinal = rdr.GetOrdinal(columnName);
        if (rdr.IsDBNull(ordinal))
            return string.Empty;
        return rdr.GetString(ordinal) ?? string.Empty;
    }

    /// <summary>
    /// Helper method to create JSON response for AJAX calls.
    /// Formats response with success flag, optional error message, and data payload.
    /// 
    /// STRUCTURE:
    /// {
    ///   "success": boolean,
    ///   "message": "error message or null",
    ///   "data": object or null
    /// }
    /// </summary>
    private static string CreateJsonResponse(bool success, string message, Dictionary<string, object> data)
    {
        // Use JavaScriptSerializer for proper JSON serialization of complex types
        var response = new Dictionary<string, object>
        {
            { "success", success },
            { "message", message }
        };
        
        if (data != null)
        {
            response["data"] = data;
        }
        else
        {
            response["data"] = null;
        }
        
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        return serializer.Serialize(response);
    }

    private static bool ColumnExists(MySqlConnection conn, string schemaName, string tableName, string columnName)
    {
        string sql = @"SELECT COUNT(*)
                       FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE TABLE_SCHEMA = @schema
                         AND TABLE_NAME = @table
                         AND COLUMN_NAME = @column";

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@schema", schemaName);
            cmd.Parameters.AddWithValue("@table", tableName);
            cmd.Parameters.AddWithValue("@column", columnName);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    private static void EnsureRegistrationAuditColumns(MySqlConnection conn)
    {
        try { EnsureNullableColumn(conn, "campus_dynamics_portal", "acad_course_registration", "marks_edit_flag", "VARCHAR(10) NULL"); } catch { }
        try { EnsureNullableColumn(conn, "campus_dynamics_portal", "acad_course_registration", "edit_reason", "TEXT NULL"); } catch { }
        try { EnsureNullableColumn(conn, "campus_dynamics_portal", "acad_course_registration", "edit_audit_trail", "LONGTEXT NULL"); } catch { }
        try { EnsureNullableColumn(conn, "campus_dynamics_portal", "acad_course_registration", "change_date", "DATETIME NULL"); } catch { }
    }

    private static void EnsureNullableColumn(MySqlConnection conn, string schemaName, string tableName, string columnName, string columnSqlType)
    {
        if (ColumnExists(conn, schemaName, tableName, columnName))
            return;

        string alterSql = "ALTER TABLE " + schemaName + "." + tableName + " ADD COLUMN " + columnName + " " + columnSqlType;
        using (MySqlCommand alterCmd = new MySqlCommand(alterSql, conn))
        {
            alterCmd.ExecuteNonQuery();
        }
    }

    /// <summary>
    /// WebMethod: Validates if a student exists and returns basic info
    /// Called from form validation before creating registration
    /// 
    /// SECURITY: Parameterized SQL prevents injection
    /// RESPONSE: JSON with student name and programme
    /// </summary>
    [WebMethod]
    public static string ValidateStudentExists(string regno)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(regno))
                return CreateJsonResponse(false, "Registration number is required.", null);

            string connStr = WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();

                string sql = @"SELECT s.firstname, s.othername, s.progid, p.progname
                              FROM acad_student s
                              LEFT JOIN acad_programme p ON p.progcode = s.progid
                              WHERE s.regno = @regno
                              LIMIT 1";

                string firstName = null, otherName = null, progName = null;
                bool studentFound = false;

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno.Trim());

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            firstName = GetDBString(rdr, "firstname");
                            otherName = GetDBString(rdr, "othername");
                            progName = GetDBString(rdr, "progname");
                            studentFound = true;
                        }
                    }
                }

                if (!studentFound)
                    return CreateJsonResponse(false, "Student not found.", null);

                // DataReader is now closed; safe to execute another query on the connection
                string studentName = (firstName + " " + otherName).Trim();
                List<Dictionary<string, object>> registrations = GetStudentRegistrationOptions(conn, regno.Trim());

                var data = new Dictionary<string, object>
                {
                    { "student_name", studentName },
                    { "programme_name", progName },
                    { "registrations", registrations }
                };

                return CreateJsonResponse(true, null, data);
            }
        }
        catch (Exception ex)
        {
            return CreateJsonResponse(false, "Error validating student: " + ex.Message, null);
        }
    }

    private static List<Dictionary<string, object>> GetStudentRegistrationOptions(MySqlConnection conn, string regno)
    {
        List<Dictionary<string, object>> items = new List<Dictionary<string, object>>();
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT ID, acad_year, semester, studyyear, IFNULL(regstatus, '') AS regstatus
            FROM acad_registration
            WHERE TRIM(regno) = @regno
            ORDER BY acad_year DESC, semester DESC, ID DESC", conn))
        {
            cmd.Parameters.AddWithValue("@regno", regno);
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    int sem = rdr["semester"] != DBNull.Value ? Convert.ToInt32(rdr["semester"]) : 0;
                    int studyYear = rdr["studyyear"] != DBNull.Value ? Convert.ToInt32(rdr["studyyear"]) : 0;
                    string acadYear = GetDBString(rdr, "acad_year");
                    string regStatus = GetDBString(rdr, "regstatus");
                    items.Add(new Dictionary<string, object>
                    {
                        { "id", rdr["ID"] != DBNull.Value ? Convert.ToInt32(rdr["ID"]) : 0 },
                        { "acad_year", acadYear },
                        { "semester", sem },
                        { "study_year", studyYear },
                        { "reg_status", regStatus },
                        { "label", acadYear + " - Sem " + sem.ToString() + (studyYear > 0 ? " - Year " + studyYear.ToString() : "") + (!string.IsNullOrEmpty(regStatus) ? " - " + regStatus : "") }
                    });
                }
            }
        }
        return items;
    }

    /// <summary>
    /// WebMethod: Creates a new course registration record
    /// PARAMETERS:
    ///   - regno: Student registration number
    ///   - courseID: Course ID
    ///   - acad_year: Academic year
    ///   - semester: Semester (1, 2, or 3)
    ///
    /// VALIDATIONS:
    ///   1. Student must exist
    ///   2. Course must exist
    ///   3. Duplicate check (same student + course + acad_year + semester)
    ///   4. All parameters must be non-empty
    ///
    /// RETURNS: JSON with new record details and auto-filled fields
    /// </summary>
    [WebMethod]
    public static string CreateCourseRegistration(string regno, string courseID, string registrationId)
    {
        try
        {
            // STEP 1: Input Validation
            if (string.IsNullOrWhiteSpace(regno) || string.IsNullOrWhiteSpace(courseID))
            {
                return CreateJsonResponse(false, "Student and course are required.", null);
            }

            int regId;
            if (!int.TryParse(registrationId, out regId) || regId <= 0)
            {
                return CreateJsonResponse(false, "Select a valid semester registration record.", null);
            }

            string connStr = WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();

                // STEP 2: Verify student exists
                string checkStudentSql = "SELECT COUNT(*) FROM acad_student WHERE regno = @regno";
                using (MySqlCommand checkCmd = new MySqlCommand(checkStudentSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regno.Trim());
                    int studentCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (studentCount == 0)
                        return CreateJsonResponse(false, "Student not found.", null);
                }

                // STEP 3: Verify course exists
                string checkCourseSql = "SELECT COUNT(*) FROM acad_course WHERE courseID = @courseID";
                using (MySqlCommand checkCmd = new MySqlCommand(checkCourseSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@courseID", courseID.Trim());
                    int courseCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (courseCount == 0)
                        return CreateJsonResponse(false, "Course not found.", null);
                }

                int sem = 0;
                string selectedAcadYear = "";
                string progId = "";
                string studentName = "";
                string courseName = "";
                string programmeName = "";

                string regSql = @"SELECT r.regno, r.acad_year, r.semester, s.progid, s.firstname, s.othername,
                                         c.courseName, p.progname
                                  FROM acad_registration r
                                  LEFT JOIN acad_student s ON s.regno = r.regno
                                  LEFT JOIN acad_course c ON c.courseID = @courseID
                                  LEFT JOIN acad_programme p ON p.progcode = s.progid
                                  WHERE r.ID = @id
                                  LIMIT 1";
                using (MySqlCommand regCmd = new MySqlCommand(regSql, conn))
                {
                    regCmd.Parameters.AddWithValue("@id", regId);
                    regCmd.Parameters.AddWithValue("@courseID", courseID.Trim());
                    using (MySqlDataReader rdr = regCmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                            return CreateJsonResponse(false, "Selected semester registration record was not found.", null);

                        string selectedRegno = GetDBString(rdr, "regno").Trim();
                        if (!string.Equals(selectedRegno, regno.Trim(), StringComparison.OrdinalIgnoreCase))
                            return CreateJsonResponse(false, "Selected semester registration does not belong to the chosen student.", null);

                        selectedAcadYear = GetDBString(rdr, "acad_year");
                        sem = rdr["semester"] != DBNull.Value ? Convert.ToInt32(rdr["semester"]) : 0;
                        progId = GetDBString(rdr, "progid");
                        studentName = (GetDBString(rdr, "firstname") + " " + GetDBString(rdr, "othername")).Trim();
                        courseName = GetDBString(rdr, "courseName");
                        programmeName = GetDBString(rdr, "progname");
                    }
                }

                if (string.IsNullOrWhiteSpace(selectedAcadYear) || sem < 1 || sem > 3)
                    return CreateJsonResponse(false, "Selected semester registration record is incomplete.", null);

                // STEP 4: Check for duplicate registration
                string checkDupSql = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration 
                                      WHERE regno = @regno AND courseID = @courseID 
                                      AND acad_year = @acad_year AND semester = @semester";
                using (MySqlCommand checkCmd = new MySqlCommand(checkDupSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regno.Trim());
                    checkCmd.Parameters.AddWithValue("@courseID", courseID.Trim());
                    checkCmd.Parameters.AddWithValue("@acad_year", selectedAcadYear);
                    checkCmd.Parameters.AddWithValue("@semester", sem);

                    int dupCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (dupCount > 0)
                        return CreateJsonResponse(false, "This student is already registered for this course in the specified period.", null);
                }

                // STEP 5: Insert new record (schema-aware for installations with optional required columns)
                bool hasCreatedDate = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "created_date");
                bool hasStudSession = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "stud_session");
                string insertSql;
                if (hasCreatedDate && hasStudSession)
                {
                    insertSql = @"INSERT INTO campus_dynamics_portal.acad_course_registration 
                                  (regno, courseID, prog_id, acad_year, semester, course_status, stud_session, created_date)
                                  VALUES (@regno, @courseID, @progId, @acad_year, @semester, 'REGULAR', @stud_session, NOW())";
                }
                else if (hasCreatedDate)
                {
                    insertSql = @"INSERT INTO campus_dynamics_portal.acad_course_registration 
                                  (regno, courseID, prog_id, acad_year, semester, course_status, created_date)
                                  VALUES (@regno, @courseID, @progId, @acad_year, @semester, 'REGULAR', NOW())";
                }
                else if (hasStudSession)
                {
                    insertSql = @"INSERT INTO campus_dynamics_portal.acad_course_registration 
                                  (regno, courseID, prog_id, acad_year, semester, course_status, stud_session)
                                  VALUES (@regno, @courseID, @progId, @acad_year, @semester, 'REGULAR', @stud_session)";
                }
                else
                {
                    insertSql = @"INSERT INTO campus_dynamics_portal.acad_course_registration 
                                  (regno, courseID, prog_id, acad_year, semester, course_status)
                                  VALUES (@regno, @courseID, @progId, @acad_year, @semester, 'REGULAR')";
                }

                long newRecordId = 0;
                using (MySqlCommand insertCmd = new MySqlCommand(insertSql, conn))
                {
                    insertCmd.Parameters.AddWithValue("@regno", regno.Trim());
                    insertCmd.Parameters.AddWithValue("@courseID", courseID.Trim());
                    insertCmd.Parameters.AddWithValue("@progId", progId);
                    insertCmd.Parameters.AddWithValue("@acad_year", selectedAcadYear);
                    insertCmd.Parameters.AddWithValue("@semester", sem);
                    if (hasStudSession)
                        insertCmd.Parameters.AddWithValue("@stud_session", "Day");

                    insertCmd.ExecuteNonQuery();
                    newRecordId = insertCmd.LastInsertedId;
                }

                // STEP 6: Build response with auto-filled data
                var resultData = new Dictionary<string, object>
                {
                    { "registration_id", newRecordId },
                    { "regno", regno },
                    { "student_name", studentName },
                    { "courseID", courseID },
                    { "course_name", courseName },
                    { "programme_name", programmeName },
                    { "acad_year", selectedAcadYear },
                    { "semester", sem.ToString() },
                    { "course_status", "REGULAR" }
                };

                return CreateJsonResponse(true, null, resultData);
            }
        }
        catch (Exception ex)
        {
            return CreateJsonResponse(false, "Error creating registration: " + ex.Message, null);
        }
    }

    /// <summary>
    /// WebMethod: Deletes a course registration record
    /// VALIDATION: Cannot delete if record has marks or grades
    /// SECURITY: Checks record ID and verifies no assessment data before deletion
    /// </summary>
    [WebMethod]
    public static string DeleteCourseRegistration(string id)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(id))
                return CreateJsonResponse(false, "Invalid record ID.", null);

            int recordId;
            if (!int.TryParse(id, out recordId))
                return CreateJsonResponse(false, "Invalid record ID format.", null);

            string connStr = WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();

                // Get registration details
                string getRegSql = @"SELECT cr.regno, cr.courseID, cr.acad_year, cr.semester
                                   FROM campus_dynamics_portal.acad_course_registration cr
                                   WHERE cr.id = @id";

                string regNo = "", courseID = "", acadYear = "";
                int semester = 0;

                using (MySqlCommand getCmd = new MySqlCommand(getRegSql, conn))
                {
                    getCmd.Parameters.AddWithValue("@id", recordId);

                    using (MySqlDataReader rdr = getCmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                            return CreateJsonResponse(false, "Record not found.", null);

                        regNo = GetDBString(rdr, "regno");
                        courseID = GetDBString(rdr, "courseID");
                        acadYear = GetDBString(rdr, "acad_year");
                        semester = Convert.ToInt32(rdr["semester"]);
                    }
                }

                // Check if record has marks or grades
                string checkResultsSql = @"SELECT COUNT(*) FROM acad_results 
                                         WHERE regno = @regno AND courseid = @courseID 
                                         AND acad = @acad_year AND semester = @semester
                                         AND (score IS NOT NULL AND score <> '' OR grade IS NOT NULL AND grade <> '')";

                using (MySqlCommand checkCmd = new MySqlCommand(checkResultsSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regNo);
                    checkCmd.Parameters.AddWithValue("@courseID", courseID);
                    checkCmd.Parameters.AddWithValue("@acad_year", acadYear);
                    checkCmd.Parameters.AddWithValue("@semester", semester);

                    int resultCount = Convert.ToInt32(checkCmd.ExecuteScalar());
                    if (resultCount > 0)
                        return CreateJsonResponse(false, "Cannot delete this record - it has assessment results associated with it.", null);
                }

                // Delete the registration
                string deleteSql = "DELETE FROM campus_dynamics_portal.acad_course_registration WHERE id = @id";
                using (MySqlCommand deleteCmd = new MySqlCommand(deleteSql, conn))
                {
                    deleteCmd.Parameters.AddWithValue("@id", recordId);
                    deleteCmd.ExecuteNonQuery();
                }

                return CreateJsonResponse(true, null, null);
            }
        }
        catch (Exception ex)
        {
            return CreateJsonResponse(false, "Error deleting record: " + ex.Message, null);
        }
    }

    /// <summary>
    /// WebMethod: Updates editable registration fields and appends immutable audit trail.
    /// Editable fields: courseID, acad_year, semester, course_status.
    /// Audit fields (nullable): marks_edit_flag, edit_reason, edit_audit_trail.
    /// </summary>
    [WebMethod]
    public static string EditCourseRegistration(string id, string courseID, string acad_year, string semester, string course_status, string edit_reason)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(id) || string.IsNullOrWhiteSpace(courseID) ||
                string.IsNullOrWhiteSpace(acad_year) || string.IsNullOrWhiteSpace(semester) ||
                string.IsNullOrWhiteSpace(course_status) || string.IsNullOrWhiteSpace(edit_reason))
            {
                return CreateJsonResponse(false, "All edit fields are required.", null);
            }

            string[] allowedStatuses = { "REGULAR", "RETAKE", "PENDING", "NORMAL" };
            string normalizedStatus = course_status.Trim().ToUpper();
            if (System.Array.IndexOf(allowedStatuses, normalizedStatus) < 0)
                return CreateJsonResponse(false, "Invalid status value.", null);

            int recordId;
            if (!int.TryParse(id, out recordId))
                return CreateJsonResponse(false, "Invalid record ID format.", null);

            int sem;
            if (!int.TryParse(semester, out sem) || sem < 1 || sem > 3)
                return CreateJsonResponse(false, "Invalid semester value.", null);

            string connStr = WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                EnsureRegistrationAuditColumns(conn);

                string oldRegNo = "";
                string oldCourseID = "";
                string oldAcadYear = "";
                string oldSemester = "";
                string oldStatus = "";
                string oldAuditTrail = "";

                bool hasMarksEditFlag = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "marks_edit_flag");
                bool hasEditReason = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_reason");
                bool hasEditAuditTrail = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "edit_audit_trail");
                bool hasModifiedDate = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "modified_date");
                bool hasChangeDate = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "change_date");

                string getSql = @"SELECT regno, courseID, acad_year, semester, course_status" +
                                (hasEditAuditTrail ? ", edit_audit_trail" : "") +
                                @" FROM campus_dynamics_portal.acad_course_registration WHERE id = @id LIMIT 1";

                using (MySqlCommand getCmd = new MySqlCommand(getSql, conn))
                {
                    getCmd.Parameters.AddWithValue("@id", recordId);
                    using (MySqlDataReader rdr = getCmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                            return CreateJsonResponse(false, "Record not found.", null);

                        oldRegNo = GetDBString(rdr, "regno");
                        oldCourseID = GetDBString(rdr, "courseID");
                        oldAcadYear = GetDBString(rdr, "acad_year");
                        oldSemester = GetDBString(rdr, "semester");
                        oldStatus = GetDBString(rdr, "course_status");
                        oldAuditTrail = hasEditAuditTrail ? GetDBString(rdr, "edit_audit_trail") : "";
                    }
                }

                string checkCourseSql = "SELECT COUNT(*) FROM acad_course WHERE courseID = @courseID";
                using (MySqlCommand checkCourseCmd = new MySqlCommand(checkCourseSql, conn))
                {
                    checkCourseCmd.Parameters.AddWithValue("@courseID", courseID.Trim());
                    if (Convert.ToInt32(checkCourseCmd.ExecuteScalar()) == 0)
                        return CreateJsonResponse(false, "Selected course does not exist.", null);
                }

                string checkDupSql = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration
                                      WHERE regno = @regno AND courseID = @courseID AND acad_year = @acad_year AND semester = @semester
                                        AND id <> @id";
                using (MySqlCommand dupCmd = new MySqlCommand(checkDupSql, conn))
                {
                    dupCmd.Parameters.AddWithValue("@regno", oldRegNo);
                    dupCmd.Parameters.AddWithValue("@courseID", courseID.Trim());
                    dupCmd.Parameters.AddWithValue("@acad_year", acad_year.Trim());
                    dupCmd.Parameters.AddWithValue("@semester", sem);
                    dupCmd.Parameters.AddWithValue("@id", recordId);
                    if (Convert.ToInt32(dupCmd.ExecuteScalar()) > 0)
                        return CreateJsonResponse(false, "Another registration already exists for this student/course/year/semester.", null);
                }

                string marksEditedFlag = "NO";
                string checkMarksSql = @"SELECT COUNT(*) FROM acad_results
                                         WHERE regno = @regno AND courseid = @courseID AND acad = @acad_year AND semester = @semester
                                           AND ((score IS NOT NULL AND score <> '') OR (grade IS NOT NULL AND grade <> ''))";
                using (MySqlCommand marksCmd = new MySqlCommand(checkMarksSql, conn))
                {
                    marksCmd.Parameters.AddWithValue("@regno", oldRegNo);
                    marksCmd.Parameters.AddWithValue("@courseID", oldCourseID);
                    marksCmd.Parameters.AddWithValue("@acad_year", oldAcadYear);
                    marksCmd.Parameters.AddWithValue("@semester", ParseIntSafe(oldSemester, sem));
                    marksEditedFlag = Convert.ToInt32(marksCmd.ExecuteScalar()) > 0 ? "YES" : "NO";
                }

                string editedBy = "SYSTEM";
                if (HttpContext.Current != null && HttpContext.Current.User != null && HttpContext.Current.User.Identity != null && HttpContext.Current.User.Identity.IsAuthenticated)
                    editedBy = string.IsNullOrWhiteSpace(HttpContext.Current.User.Identity.Name) ? "SYSTEM" : HttpContext.Current.User.Identity.Name;

                string newCourseID = courseID.Trim();
                string newAcadYear = acad_year.Trim();
                string newSemester = sem.ToString();
                string changeLine = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss")
                    + " | by " + editedBy
                    + " | reason: " + edit_reason.Trim()
                    + "\nFROM: Course=" + oldCourseID + ", Year=" + oldAcadYear + ", Semester=" + oldSemester + ", Status=" + oldStatus
                    + "\nTO: Course=" + newCourseID + ", Year=" + newAcadYear + ", Semester=" + newSemester + ", Status=" + normalizedStatus;

                string appendedAuditTrail = string.IsNullOrWhiteSpace(oldAuditTrail)
                    ? changeLine
                    : oldAuditTrail + "\n---\n" + changeLine;

                StringBuilder setClause = new StringBuilder();
                setClause.Append("courseID = @courseID, acad_year = @acad_year, semester = @semester, course_status = @status");
                if (hasMarksEditFlag) setClause.Append(", marks_edit_flag = @marks_edit_flag");
                if (hasEditReason) setClause.Append(", edit_reason = @edit_reason");
                if (hasEditAuditTrail) setClause.Append(", edit_audit_trail = @edit_audit_trail");
                if (hasChangeDate) setClause.Append(", change_date = NOW()");
                if (hasModifiedDate) setClause.Append(", modified_date = NOW()");

                string updateSql = "UPDATE campus_dynamics_portal.acad_course_registration SET " + setClause + " WHERE id = @id";
                using (MySqlCommand updateCmd = new MySqlCommand(updateSql, conn))
                {
                    updateCmd.Parameters.AddWithValue("@courseID", newCourseID);
                    updateCmd.Parameters.AddWithValue("@acad_year", newAcadYear);
                    updateCmd.Parameters.AddWithValue("@semester", sem);
                    updateCmd.Parameters.AddWithValue("@status", normalizedStatus);
                    updateCmd.Parameters.AddWithValue("@id", recordId);

                    if (hasMarksEditFlag) updateCmd.Parameters.AddWithValue("@marks_edit_flag", marksEditedFlag);
                    if (hasEditReason) updateCmd.Parameters.AddWithValue("@edit_reason", edit_reason.Trim());
                    if (hasEditAuditTrail) updateCmd.Parameters.AddWithValue("@edit_audit_trail", appendedAuditTrail);

                    updateCmd.ExecuteNonQuery();
                }

                return CreateJsonResponse(true, null, null);
            }
        }
        catch (Exception ex)
        {
            return CreateJsonResponse(false, "Error updating record: " + ex.Message, null);
        }
    }
}
