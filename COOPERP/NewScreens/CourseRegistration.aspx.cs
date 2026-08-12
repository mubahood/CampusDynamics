using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.XtraPrinting;
using System.Web.Services;
using System.Web.Script.Serialization;

public partial class COOPERP_NewScreens_CourseRegistration : System.Web.UI.Page
{
    private const int QueryPageSize = 50;

    /// <summary>Above this many matching rows the list stops sorting by student name — see BindGrid.</summary>
    private const int NameSortCeiling = 5000;

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }
    
    /// <summary>
    /// Course code typed into the "Course Code" box (normalised). Lets an admin filter
    /// straight to any course without first picking programme / study year / semester.
    /// </summary>
    private string TypedCourseCode
    {
        get
        {
            string v = (txtCourseCode.Text ?? string.Empty).Trim();
            // Tolerate a pasted "CODE - Course Name" suggestion; only the code matters.
            // — is the em dash the suggestion list renders between code and name.
            int dash = v.IndexOf(" — ", StringComparison.Ordinal);
            if (dash < 0) dash = v.IndexOf(" - ", StringComparison.Ordinal);
            if (dash > 0) v = v.Substring(0, dash).Trim();
            return v.ToUpperInvariant();
        }
    }

    /// <summary>
    /// The course every query and batch action works on: the typed code when present,
    /// otherwise the Course dropdown selection.
    /// </summary>
    private string SelectedCourseCode
    {
        get
        {
            string typed = TypedCourseCode;
            return typed.Length > 0 ? typed : (ddlCourse.SelectedValue ?? string.Empty);
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Master page has EnableViewState="false", so dynamic dropdowns must
        // be repopulated on EVERY request and selections restored from POST data.
        LoadAcademicYears();
        LoadProgrammes();
        LoadEntryYears();
        LoadQuickEditDropdowns();
        
        if (!IsPostBack)
        {
            // No pre-set filters. The page opens on everything; the operator narrows it.
            // It used to open pinned to the current academic year, Year 1, Semester 1, which
            // meant the list you were shown was never the list you asked for.
            ddlEntryYear.SelectedValue = "-";

            ApplyFiltersFromQueryString();
            
            // Courses depend on programme/study-year/semester
            LoadCourses();
            ApplyCourseFromQueryString();
            
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
        }
        else
        {
            // Restore posted selections for dynamic dropdowns
            RestoreDropDownFromPost(ddlAcadYear);
            RestoreDropDownFromPost(ddlProgramme);
            RestoreDropDownFromPost(ddlEntryYear);
            
            // Static dropdowns (ddlStudyYear, ddlSemester, ddlIntake, ddlStatus)
            // are restored automatically by ASP.NET from markup + POST data.
            
            // Courses depend on programme/study-year/semester, reload then restore
            LoadCourses();
            RestoreDropDownFromPost(ddlCourse);
            
            UpdateDisplayLabels();
            
            // With ViewState off, SelectedIndexChanged never fires for dynamic
            // dropdowns (ddlAcadYear, ddlProgramme, ddlEntryYear, ddlCourse)
            // because RestoreDropDownFromPost already sets the value before
            // ASP.NET's 2nd ProcessPostData pass can detect a change.
            // Detect filter-dropdown postbacks and refresh the grid here.
            string eventTarget = Request.Form["__EVENTTARGET"] ?? "";
            bool isFilterChange = eventTarget.Contains("ddlAcadYear")
                               || eventTarget.Contains("ddlProgramme")
                               || eventTarget.Contains("ddlStudyYear")
                               || eventTarget.Contains("ddlSemester")
                               || eventTarget.Contains("ddlEntryYear")
                               || eventTarget.Contains("ddlIntake")
                               || eventTarget.Contains("ddlCourse")
                               || eventTarget.Contains("ddlStatus");
            
            if (isFilterChange)
            {
                LoadStats();
                BindGrid();
            }
            // Button clicks (Register, Remove, Retake) handle BindGrid themselves
            // after their work - don't call it here or it would wipe checkbox selections.
        }
    }
    
    /// <summary>
    /// Restores a dropdown's SelectedValue from the form POST data.
    /// Needed because EnableViewState="false" on the master page form means
    /// dynamically-populated dropdown items are lost on postback.
    /// </summary>
    private void RestoreDropDownFromPost(DropDownList ddl)
    {
        string posted = Request.Form[ddl.UniqueID];
        if (!string.IsNullOrEmpty(posted) && ddl.Items.FindByValue(posted) != null)
            ddl.SelectedValue = posted;
    }
    
    // Academic year logic centralised in AcademicYearHelper
    
    private void LoadAcademicYears()
    {
        // "All Academic Years" first, and NOT pre-selected to the current year. The screen
        // opens showing everything; a filter only narrows it once somebody chooses one.
        AcademicYearHelper.PopulateDropDown(ddlAcadYear, true, false);
    }

    /// <summary>Identifies the current filter set, so cached counts belong to one filter set only.</summary>
    private string FilterSignature(string studentTerm)
    {
        return string.Join("~", new string[] {
            Val(ddlAcadYear), Num(ddlSemester).ToString(), Num(ddlStudyYear).ToString(),
            ddlProgramme.SelectedValue ?? "", SelectedCourseCode, ddlStatus.SelectedValue ?? "",
            ddlEntryYear.SelectedValue ?? "", ddlIntake.SelectedValue ?? "", studentTerm ?? ""
        });
    }

    /// <summary>A filter dropdown's value, or "" when it is on its "all" entry.</summary>
    private static string Val(DropDownList ddl)
    {
        string v = (ddl == null ? "" : (ddl.SelectedValue ?? "")).Trim();
        return (v == "-" || v == "0") ? "" : v;
    }

    /// <summary>A numeric filter, or 0 when the dropdown is on "all".</summary>
    private static int Num(DropDownList ddl)
    {
        int n;
        return int.TryParse(Val(ddl), out n) ? n : 0;
    }
    
    private void LoadEntryYears()
    {
        ddlEntryYear.Items.Clear();
        ddlEntryYear.Items.Add(new ListItem("-- All --", "-"));
        int cy = DateTime.Now.Year;
        for (int i = cy + 1; i >= cy - 10; i--)
            ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
    }
    
    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            // Get user's programmes using the stored procedure
            string username = HttpContext.Current.User.Identity.Name;
            
            using (MySqlCommand cmd = new MySqlCommand("myaspnet_GetMyProgrammes", conn))
            {
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@usr", username);
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["progcode"].ToString();
                        string name = reader["progname"].ToString();
                        ddlProgramme.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
            
            // If no programmes found via permissions, load all programmes
            if (ddlProgramme.Items.Count == 1)
            {
                string sqlAll = "SELECT progcode, progname FROM acad_programme ORDER BY progname";
                using (MySqlCommand cmd = new MySqlCommand(sqlAll, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string code = reader["progcode"].ToString();
                            string name = reader["progname"].ToString();
                            ddlProgramme.Items.Add(new ListItem(code + " - " + name, code));
                        }
                    }
                }
            }
        }
    }
    
    private void LoadCourses()
    {
        ddlCourse.Items.Clear();
        ddlCourse.Items.Add(new ListItem("-- Select Course --", ""));
        
        if (string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            return;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            // With study year / semester on "all", the picker offers the programme's whole
            // catalogue rather than nothing at all.
            string sql = @"SELECT DISTINCT pc.course_code, c.courseName as course_name
                          FROM acad_programmecourses pc
                          INNER JOIN acad_course c ON pc.course_code = c.courseID
                          WHERE pc.progcode = @prog
                            AND (@yr = 0 OR pc.study_year = @yr)
                            AND (@sem = 0 OR pc.semester = @sem)
                          ORDER BY c.courseName";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                cmd.Parameters.AddWithValue("@yr", Num(ddlStudyYear));
                cmd.Parameters.AddWithValue("@sem", Num(ddlSemester));
                
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["course_code"].ToString();
                        string name = reader["course_name"].ToString();
                        ddlCourse.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
        }
    }

    private void ApplyFiltersFromQueryString()
    {
        SetDropDownFromQuery(ddlAcadYear, "acad");
        SetDropDownFromQuery(ddlProgramme, "prog");
        SetDropDownFromQuery(ddlStudyYear, "yr");
        SetDropDownFromQuery(ddlSemester, "sem");
        SetDropDownFromQuery(ddlEntryYear, "entyr");
        SetDropDownFromQuery(ddlIntake, "intake");
        SetDropDownFromQuery(ddlStatus, "status");
        txtStudentFilter.Text = (Request.QueryString["student"] ?? string.Empty).Trim();
        txtCourseCode.Text = (Request.QueryString["ccode"] ?? string.Empty).Trim();
    }

    private void ApplyCourseFromQueryString()
    {
        SetDropDownFromQuery(ddlCourse, "course");
    }

    private void SetDropDownFromQuery(DropDownList ddl, string key)
    {
        string value = Request.QueryString[key];
        if (!string.IsNullOrEmpty(value) && ddl.Items.FindByValue(value) != null)
            ddl.SelectedValue = value;
    }
    
    private void UpdateDisplayLabels()
    {
        // The header states what is actually on screen, including when that is everything.
        string ay = Val(ddlAcadYear);
        int yr = Num(ddlStudyYear), sm = Num(ddlSemester);
        litAcadYearDisplay.Text = ay == "" ? "All years" : ay;
        litSemesterDisplay.Text = (yr > 0 ? "Yr " + yr : "All years") + ", " + (sm > 0 ? "Sem " + sm : "all semesters");
        UpdateCourseCodeHint();
    }

    /// <summary>
    /// Names the typed course beside the box so the admin can see they hit the right code —
    /// and warns when the code is not in the catalogue (a legacy code can still hold
    /// registrations, so filtering continues either way).
    /// </summary>
    private void UpdateCourseCodeHint()
    {
        litCourseCodeHint.Text = string.Empty;
        string code = TypedCourseCode;
        if (code.Length == 0) return;

        string name = null;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT courseName FROM acad_course WHERE courseID = @c LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@c", code);
                    object o = cmd.ExecuteScalar();
                    if (o != null) name = (o == DBNull.Value ? code : o.ToString());
                }
            }
        }
        catch { return; }

        if (string.IsNullOrEmpty(name))
            litCourseCodeHint.Text = string.Format(
                "<span class='cr-ccode-hint cr-ccode-hint--warn'>{0} is not in the course catalogue</span>", H(code));
        else
            litCourseCodeHint.Text = string.Format(
                "<span class='cr-ccode-hint cr-ccode-hint--ok' title=\"{0}\">{0}</span>", H(name));
    }
    
    private void LoadStats()
    {
        bool hasProgramme = !string.IsNullOrEmpty(ddlProgramme.SelectedValue);
        string courseCode = SelectedCourseCode;
        bool hasCourse = !string.IsNullOrEmpty(courseCode);

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Count pending students (registered in programme but not course-registered)
            string sqlPending = @"SELECT COUNT(*) FROM acad_registration r
                                 INNER JOIN acad_student s ON r.regno = s.regno
                                 WHERE s.progid = @prog 
                                   AND r.studyyear = @yr
                                   AND r.acad_year = @acad
                                   AND r.regstatus IN ('REGISTERED', 'CLEARED', 'LATE REGISTERED')
                                   AND r.regno NOT IN (
                                       SELECT cr.regno FROM campus_dynamics_portal.acad_course_registration cr
                                       WHERE cr.courseID = @course 
                                         AND cr.acad_year = @acad 
                                         AND cr.semester = @sem
                                   )";
            
            if (hasProgramme && hasCourse)
            {
                using (MySqlCommand cmd = new MySqlCommand(sqlPending, conn))
                {
                    cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    cmd.Parameters.AddWithValue("@yr", Num(ddlStudyYear));
                    cmd.Parameters.AddWithValue("@acad", Val(ddlAcadYear));
                    cmd.Parameters.AddWithValue("@course", courseCode);
                    cmd.Parameters.AddWithValue("@sem", Num(ddlSemester));
                    litPendingCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
                }
            }
            else
            {
                litPendingCount.Text = "0";
            }
            
            // Count registered students (Normal/Regular)
                        string sqlRegistered = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr
                                                                        WHERE cr.acad_year = @acad 
                                                                            AND cr.semester = @sem
                                                                            AND (@prog='' OR cr.prog_id = @prog)
                                                                            AND (@course='' OR cr.courseID = @course)
                                                                            AND (cr.course_status = 'NORMAL' OR cr.course_status = 'REGULAR')";
            
            using (MySqlCommand cmd = new MySqlCommand(sqlRegistered, conn))
            {
                cmd.Parameters.AddWithValue("@course", hasCourse ? courseCode : "");
                cmd.Parameters.AddWithValue("@acad", Val(ddlAcadYear));
                cmd.Parameters.AddWithValue("@sem", Num(ddlSemester));
                cmd.Parameters.AddWithValue("@prog", hasProgramme ? ddlProgramme.SelectedValue : "");
                litRegisteredCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
            
            // Count retake students
                        string sqlRetake = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr
                                                                WHERE cr.acad_year = @acad 
                                                                    AND cr.semester = @sem
                                                                    AND (@prog='' OR cr.prog_id = @prog)
                                                                    AND (@course='' OR cr.courseID = @course)
                                                                    AND cr.course_status = 'RETAKE'";
            
            using (MySqlCommand cmd = new MySqlCommand(sqlRetake, conn))
            {
                cmd.Parameters.AddWithValue("@course", hasCourse ? courseCode : "");
                cmd.Parameters.AddWithValue("@acad", Val(ddlAcadYear));
                cmd.Parameters.AddWithValue("@sem", Num(ddlSemester));
                cmd.Parameters.AddWithValue("@prog", hasProgramme ? ddlProgramme.SelectedValue : "");
                litRetakeCount.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
            }
        }
    }
    
    private void BindGrid()
    {
        int requestedPage = GetRequestedPage();
        int totalRows, totalPages;
        bool isPendingView;
        DataTable dt = QueryRegistrations(true, ref requestedPage, out totalRows, out totalPages, out isPendingView);

        btnRegisterSelected.Visible = isPendingView;
        btnRemoveSelected.Visible = (!isPendingView && !string.IsNullOrEmpty(SelectedCourseCode));

        RenderTable(dt, requestedPage, totalPages, totalRows, isPendingView);

        // Reset any client-side selection after a (re)render so checkboxes and the
        // bulk bar never show stale counts following a batch action.
        ScriptManager.RegisterStartupScript(upCourseReg, upCourseReg.GetType(), "crxResetSel",
            "if(window.clearSel){window.clearSel();}", true);
    }

    /// <summary>
    /// Builds the registration result set for the current filters. When <paramref name="paged"/>
    /// is true the page slice is returned (for the on-screen datatable); otherwise the full set
    /// is returned (for Excel export). Shared by BindGrid and the export handler.
    /// </summary>
    private DataTable QueryRegistrations(bool paged, ref int requestedPage, out int totalRows, out int totalPages, out bool isPendingView)
    {
        bool hasProgramme = !string.IsNullOrEmpty(ddlProgramme.SelectedValue);
        bool hasCourse = !string.IsNullOrEmpty(SelectedCourseCode);
        string studentTerm = (txtStudentFilter.Text ?? string.Empty).Trim();
        // "Pending" answers "who in this programme has NOT taken this course this sitting?",
        // so unlike the register it needs a specific academic year and semester to compare to.
        isPendingView = (ddlStatus.SelectedValue == "Pending" && hasProgramme && hasCourse
                         && Val(ddlAcadYear) != "" && Num(ddlSemester) > 0);

        DataTable dt = new DataTable();
        totalRows = 0;
        totalPages = 1;

        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "";

            if (isPendingView)
            {
                // Show students who are registered in the programme but not in this course
                sql = @"SELECT r.regno,
                              CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) as stud_name,
                              @course AS course_code,
                              @acad AS acad_year,
                              @sem AS semester,
                              r.studyyear AS study_year,
                              COALESCE(s.entryyear, 0) AS entryyear,
                              COALESCE(s.intake, '-') AS intake,
                              COALESCE(r.regstatus, 'REGISTERED') AS reg_status,
                              'PENDING' as course_status
                       FROM acad_registration r
                       INNER JOIN acad_student s ON r.regno = s.regno
                       WHERE s.progid = @prog
                         AND (@yr = 0 OR r.studyyear = @yr)
                         AND r.acad_year = @acad
                         AND r.regstatus IN ('REGISTERED', 'CLEARED', 'LATE REGISTERED')
                         AND r.regno NOT IN (
                             SELECT cr.regno FROM campus_dynamics_portal.acad_course_registration cr
                             WHERE cr.courseID = @course 
                               AND cr.acad_year = @acad 
                               AND cr.semester = @sem
                         )";

                                if (!string.IsNullOrEmpty(studentTerm))
                                {
                                        sql += " AND (r.regno LIKE @studentLike OR CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) LIKE @studentLike)";
                                }
                
                // Apply entry year filter
                if (ddlEntryYear.SelectedValue != "-" && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
                {
                    sql += " AND s.entryyear = @entyr";
                }
                
                // Apply intake filter
                if (ddlIntake.SelectedValue != "-")
                {
                    sql += " AND s.intake = @intake";
                }
                
                                sql += " ORDER BY s.firstname, s.othername";
            }
            else
            {
                                // Default/simple view: show already registered rows (all when no course/programme selected)
                // Every filter is optional. An empty academic year or a zero semester means
                // "all", so the page opens on the whole register and narrows only when asked.
                sql = @"SELECT cr.regno,
                                                            CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) as stud_name,
                                                            cr.courseID AS course_code,
                                                            cr.acad_year AS acad_year,
                                                            cr.semester AS semester,
                                                            COALESCE(s.entryyear, 0) AS entryyear,
                                                            COALESCE(s.intake, '-') AS intake,
                                                            'REGISTERED' AS reg_status,
                                                            cr.course_status
                       FROM campus_dynamics_portal.acad_course_registration cr
                       -- CONVERT on the portal side makes this an eq_ref on acad_student's
                       -- primary key. Comparing utf8mb4 to utf8 directly cannot use the index,
                       -- and cost 1,296ms a page against 107ms with it.
                       INNER JOIN acad_student s ON s.regno = CONVERT(cr.regno USING utf8)
                                             WHERE (@acad = '' OR cr.acad_year = @acad)
                         AND (@sem = 0 OR cr.semester = @sem)
                                                 AND (@prog = '' OR cr.prog_id = @prog)
                                                 AND (@course = '' OR cr.courseID = @course)
                                                 AND (@entyr = 0 OR s.entryyear = @entyr)
                                                 AND (@intake = '-' OR s.intake = @intake)
                                                 AND (@student = '' OR cr.regno LIKE @studentLike OR CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,'')) LIKE @studentLike)";
            }

            // The row count is the same for every page of the same filter set, so paging used to
            // re-count 687,000 rows on every click. Held for a minute against the filter
            // signature: a register does not change materially between two clicks of a pager.
            string countKey = "crx.count|" + FilterSignature(studentTerm);
            object cached = Context.Cache[countKey];
            if (cached != null) totalRows = (int)cached;
            else
            {
                string countSql = "SELECT COUNT(*) FROM (" + sql + ") AS x";
                using (MySqlCommand countCmd = new MySqlCommand(countSql, conn))
                {
                    countCmd.CommandTimeout = 180;
                    AddGridParameters(countCmd, hasProgramme, hasCourse, studentTerm);
                    totalRows = Convert.ToInt32(countCmd.ExecuteScalar());
                }
                Context.Cache.Insert(countKey, totalRows, null, DateTime.UtcNow.AddSeconds(60),
                                     System.Web.Caching.Cache.NoSlidingExpiration);
            }

            totalPages = totalRows > 0 ? (int)Math.Ceiling(totalRows / (double)QueryPageSize) : 1;
            if (requestedPage > totalPages)
                requestedPage = totalPages;

            // Sorting by student name means walking and sorting the whole result set, which is
            // worth it for a list somebody is reading and pointless for 687,000 rows they will
            // never scroll. Narrowed lists sort by name; the wide-open view sorts newest-first
            // off the primary key, which is what an unfiltered register is actually for.
            if (!isPendingView)
                sql += (totalRows <= NameSortCeiling)
                    ? " ORDER BY cr.acad_year DESC, cr.semester DESC, s.firstname, s.othername"
                    : " ORDER BY cr.ID DESC";

            string finalSql = sql;
            if (paged) finalSql += " LIMIT @offset, @pageSize";

            using (MySqlCommand cmd = new MySqlCommand(finalSql, conn))
            {
                AddGridParameters(cmd, hasProgramme, hasCourse, studentTerm);
                if (paged)
                {
                    int offset = (requestedPage - 1) * QueryPageSize;
                    cmd.Parameters.AddWithValue("@offset", offset);
                    cmd.Parameters.AddWithValue("@pageSize", QueryPageSize);
                }

                using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }

            if (!isPendingView)
                AttachStudyYears(conn, dt);
        }

        return dt;
    }

    /// <summary>
    /// A portal course-registration row carries no study year, so take it from the student's
    /// semester registration for the same sitting. One extra query per render: an IN-list for a
    /// page of rows, or the whole sitting in one indexed range for the (unpaged) Excel export.
    /// </summary>
    private void AttachStudyYears(MySqlConnection conn, DataTable dt)
    {
        if (!dt.Columns.Contains("study_year"))
        {
            dt.Columns.Add("study_year", typeof(string));
            if (dt.Columns.Contains("semester"))
                dt.Columns["study_year"].SetOrdinal(dt.Columns["semester"].Ordinal + 1);
        }
        if (dt.Rows.Count == 0) return;

        var wanted = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (DataRow r in dt.Rows)
        {
            string rn = SafeCell(r, "regno").Trim();
            if (rn.Length > 0 && seen.Add(rn)) wanted.Add(rn);
        }
        if (wanted.Count == 0) return;

        // The study year is a property of the ROW's own sitting, not of the page's filter.
        // It used to be looked up for one fixed (acad_year, semester) taken from the
        // dropdowns; once those could be left on "All" that lookup asked for acad_year='' and
        // semester=0, matched nothing, and every Yr/Sem cell lost its year. Each row is now
        // resolved against its own academic year and semester.
        var years = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        var byYearOnly = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        var names2 = new List<string>();
        for (int i = 0; i < wanted.Count; i++) names2.Add("@r" + i);
        string sql = "SELECT regno, acad_year, semester, MIN(studyyear) AS sy FROM acad_registration " +
                     "WHERE IFNULL(studyyear,0) > 0 AND regno IN (" + string.Join(",", names2.ToArray()) + ") " +
                     "GROUP BY regno, acad_year, semester";

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 120;
            for (int i = 0; i < wanted.Count; i++)
                cmd.Parameters.AddWithValue("@r" + i, wanted[i]);

            using (MySqlDataReader rdr = cmd.ExecuteReader())
                while (rdr.Read())
                {
                    string rn = (rdr["regno"] ?? "").ToString().Trim();
                    string ay = (rdr["acad_year"] ?? "").ToString().Trim();
                    string sm = (rdr["semester"] ?? "").ToString().Trim();
                    if (rn.Length == 0 || rdr["sy"] == DBNull.Value) continue;
                    string sy = rdr["sy"].ToString();
                    years[rn + "|" + ay + "|" + sm] = sy;
                    // Same academic year, other semester — a student is in one year of study
                    // for the whole year, so this is a safe second-best.
                    string k2 = rn + "|" + ay;
                    if (!byYearOnly.ContainsKey(k2)) byYearOnly[k2] = sy;
                }
        }

        foreach (DataRow r in dt.Rows)
        {
            string rn = SafeCell(r, "regno").Trim();
            string ay = SafeCell(r, "acad_year").Trim();
            string sm = SafeCell(r, "semester").Trim();
            string sy;
            if (years.TryGetValue(rn + "|" + ay + "|" + sm, out sy) ||
                byYearOnly.TryGetValue(rn + "|" + ay, out sy))
                r["study_year"] = sy;
        }
    }

    private void AddGridParameters(MySqlCommand cmd, bool hasProgramme, bool hasCourse, string studentTerm)
    {
        cmd.Parameters.AddWithValue("@prog", hasProgramme ? ddlProgramme.SelectedValue : "");
        cmd.Parameters.AddWithValue("@yr", Num(ddlStudyYear));       // 0 = all study years
        cmd.Parameters.AddWithValue("@acad", Val(ddlAcadYear));      // "" = all academic years
        cmd.Parameters.AddWithValue("@course", hasCourse ? SelectedCourseCode : "");
        cmd.Parameters.AddWithValue("@sem", Num(ddlSemester));       // 0 = all semesters
        cmd.Parameters.AddWithValue("@student", studentTerm);
        cmd.Parameters.AddWithValue("@studentLike", string.IsNullOrEmpty(studentTerm) ? "%" : ("%" + studentTerm + "%"));

        if (ddlEntryYear.SelectedValue != "-" && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
            cmd.Parameters.AddWithValue("@entyr", int.Parse(ddlEntryYear.SelectedValue));
        else
            cmd.Parameters.AddWithValue("@entyr", 0);

        if (ddlIntake.SelectedValue != "-")
            cmd.Parameters.AddWithValue("@intake", ddlIntake.SelectedValue);
        else
            cmd.Parameters.AddWithValue("@intake", "-");
    }

    private int GetRequestedPage()
    {
        int page;
        if (int.TryParse(Request.QueryString["page"], out page) && page > 0)
            return page;
        return 1;
    }

    // ── New datatable rendering (GET-driven, server-paged) ──
    private void RenderTable(DataTable dt, int page, int totalPages, int totalRows, bool isPendingView)
    {
        int from = totalRows == 0 ? 0 : ((page - 1) * QueryPageSize) + 1;
        int to = (int)Math.Min((long)page * QueryPageSize, totalRows);

        litFrom.Text = from.ToString();
        litTo.Text = to.ToString();
        litTotal.Text = totalRows.ToString("N0");
        litTotal2.Text = totalRows.ToString("N0");
        litPage.Text = page.ToString();
        litPageCount.Text = totalPages.ToString();

        string pager = BuildPagerHtml(page, totalPages);
        litPager.Text = pager;
        litPager2.Text = pager;

        if (dt.Rows.Count == 0)
        {
            // When a year or semester IS set, an empty list is usually the wrong sitting —
            // so say which one was searched. With both on "all" there is nothing to blame.
            string sitting = (Val(ddlAcadYear) == "" && Num(ddlSemester) <= 0)
                ? "" : " for " + H(Val(ddlAcadYear) == "" ? "any year" : Val(ddlAcadYear))
                       + (Num(ddlSemester) > 0 ? ", Semester " + Num(ddlSemester) : "")
                       + " &mdash; check the academic year and semester above";
            string extra = string.IsNullOrEmpty(TypedCourseCode) ? "" : string.Format(
                " Nothing is registered under <b>{0}</b>{1}.", H(TypedCourseCode), sitting);
            litRows.Text = "<tr><td colspan='9' class='crx-empty'>No course-registration records match the current filters." + extra + "</td></tr>";
            return;
        }

        var sb = new StringBuilder();
        foreach (DataRow r in dt.Rows)
        {
            string regno = SafeCell(r, "regno");
            string name = SafeCell(r, "stud_name");
            string course = SafeCell(r, "course_code");
            string acad = SafeCell(r, "acad_year");
            string sem = SafeCell(r, "semester");            // raw — row actions key on it
            string yrSem = FormatYearSem(SafeCell(r, "study_year"), sem);
            string entry = SafeCell(r, "entryyear");
            string courseStatus = SafeCell(r, "course_status");
            // Intake and registration status are still SELECTed and still go into the Excel
            // export — they are just no longer columns on screen, where they cost more width
            // than they earned.

            string regnoA = HttpUtility.HtmlAttributeEncode(regno);
            string courseA = HttpUtility.HtmlAttributeEncode(course);
            string acadA = HttpUtility.HtmlAttributeEncode(acad);
            string semA = HttpUtility.HtmlAttributeEncode(sem);
            string statusA = HttpUtility.HtmlAttributeEncode(courseStatus);

            sb.Append("<tr>");
            sb.AppendFormat("<td class='crx-sel'><input type='checkbox' class='crx-row-sel' data-key=\"{0}\" onclick='onRowSel(this)' /></td>", regnoA);
            sb.AppendFormat("<td><a class='crx-link' title='View course &amp; semester enrolment' onclick=\"openEnrolment('{0}')\"><span class='crx-code'>{1}</span></a></td>", JsEnc(regno), H(regno));
            sb.AppendFormat("<td class='crx-name' title=\"{0}\">{0}</td>", H(name));
            sb.AppendFormat("<td><span class='crx-code'>{0}</span></td>", H(course));
            sb.AppendFormat("<td>{0}</td>", H(acad));
            sb.AppendFormat("<td class='c'>{0}</td>", H(yrSem));
            sb.AppendFormat("<td class='c hide-md'>{0}</td>", H(entry));
            sb.AppendFormat("<td>{0}</td>", GetCourseStatusBadge(courseStatus));

            // One trigger per row. The menu itself is built by the client from these
            // attributes, so fifty rows cost fifty buttons rather than two hundred and fifty.
            sb.Append("<td class='crx-act'>");
            sb.AppendFormat(
                "<button type='button' class='crx-kebab' aria-haspopup='true' aria-expanded='false' title='Actions' " +
                "data-regno=\"{0}\" data-course=\"{1}\" data-acad=\"{2}\" data-sem=\"{3}\" data-status=\"{4}\" " +
                "data-name=\"{5}\" data-pending=\"{6}\" onclick='crxMenu(this,event)'>&#8942;</button>",
                regnoA, courseA, acadA, semA, statusA, HttpUtility.HtmlAttributeEncode(name), isPendingView ? "1" : "0");
            sb.Append("</td></tr>");
        }
        litRows.Text = sb.ToString();
    }

    private string BuildPagerHtml(int page, int totalPages)
    {
        if (totalPages <= 1) return string.Empty;
        var sb = new StringBuilder();
        if (page > 1)
            sb.AppendFormat("<a href='{0}'>&laquo; Prev</a>", BuildPagerUrl(page - 1));

        int start = Math.Max(1, page - 2);
        int end = Math.Min(totalPages, start + 4);
        start = Math.Max(1, end - 4);
        for (int i = start; i <= end; i++)
        {
            if (i == page) sb.AppendFormat("<span class='active'>{0}</span>", i);
            else sb.AppendFormat("<a href='{0}'>{1}</a>", BuildPagerUrl(i), i);
        }

        if (page < totalPages)
            sb.AppendFormat("<a href='{0}'>Next &raquo;</a>", BuildPagerUrl(page + 1));
        return sb.ToString();
    }

    /// <summary>Sitting label for the Yr / Sem column: "Yr1, Sem1" — semester alone when the
    /// student's study year for that sitting could not be resolved.</summary>
    private static string FormatYearSem(string studyYear, string semester)
    {
        string sem = string.IsNullOrEmpty(semester) ? "-" : semester;
        return (string.IsNullOrEmpty(studyYear) || studyYear == "0")
            ? "Sem" + sem
            : "Yr" + studyYear + ", Sem" + sem;
    }

    private static string SafeCell(DataRow r, string col)
    {
        return r.Table.Columns.Contains(col) && r[col] != DBNull.Value ? r[col].ToString() : "";
    }
    private static string H(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
    private static string JsEnc(string s) { return HttpUtility.JavaScriptStringEncode(s ?? ""); }

    /// <summary>Reads the comma-separated reg numbers ticked in the new datatable.</summary>
    private List<string> GetSelectedRegnos()
    {
        var list = new List<string>();
        string raw = hfSelectedKeys.Value ?? string.Empty;
        foreach (string part in raw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
        {
            string v = part.Trim();
            if (v.Length > 0 && !list.Contains(v)) list.Add(v);
        }
        return list;
    }

    private string BuildPagerUrl(int page)
    {
        var query = HttpUtility.ParseQueryString(string.Empty);
        query["page"] = page.ToString();
        // Only filters that are actually set travel in the URL — an "all" filter is the
        // absence of a filter, so paging an unfiltered list keeps it unfiltered.
        if (Val(ddlAcadYear) != "")
            query["acad"] = Val(ddlAcadYear);

        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            query["prog"] = ddlProgramme.SelectedValue;
        if (Val(ddlStudyYear) != "")
            query["yr"] = Val(ddlStudyYear);
        if (Val(ddlSemester) != "")
            query["sem"] = Val(ddlSemester);
        if (!string.IsNullOrEmpty(ddlEntryYear.SelectedValue) && ddlEntryYear.SelectedValue != "-")
            query["entyr"] = ddlEntryYear.SelectedValue;
        if (!string.IsNullOrEmpty(ddlIntake.SelectedValue) && ddlIntake.SelectedValue != "-")
            query["intake"] = ddlIntake.SelectedValue;
        // A typed course code overrides the dropdown — carry only the one in force.
        if (!string.IsNullOrEmpty(TypedCourseCode))
            query["ccode"] = TypedCourseCode;
        else if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
            query["course"] = ddlCourse.SelectedValue;
        if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
            query["status"] = ddlStatus.SelectedValue;
        if (!string.IsNullOrEmpty(txtStudentFilter.Text))
            query["student"] = txtStudentFilter.Text.Trim();

        return Request.Path + "?" + query.ToString();
    }
    
    protected string GetCourseStatusBadge(object status)
    {
        string statusStr = (status != null) ? status.ToString() : "PENDING";
        string cssClass = "cr-status-badge--pending";
        
        switch (statusStr.ToUpper())
        {
            case "REGISTERED":
            case "NORMAL":
            case "REGULAR":
                cssClass = "cr-status-badge--registered";
                statusStr = "REGISTERED";
                break;
            case "RETAKE":
                cssClass = "cr-status-badge--retake";
                break;
            case "PENDING":
            default:
                cssClass = "cr-status-badge--pending";
                break;
        }
        
        return string.Format("<span class=\"cr-status-badge {0}\">{1}</span>", cssClass, statusStr);
    }
    
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStudyYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadCourses();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlEntryYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlIntake_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnRegisterSelected_Click(object sender, EventArgs e)
    {
        string courseCode = SelectedCourseCode;
        if (string.IsNullOrEmpty(courseCode))
        {
            ShowMessage("Please select a course, or type a course code, first.", "error");
            LoadStats();
            BindGrid();
            return;
        }

        // Registering writes a specific sitting, so "all years / all semesters" cannot stand in
        // for one. The filters may be open; the write may not.
        if (Val(ddlAcadYear) == "" || Num(ddlSemester) <= 0)
        {
            ShowMessage("Choose the academic year and semester you are registering these students into.", "error");
            LoadStats();
            BindGrid();
            return;
        }

        // Enforce semester active status — block registration if the semester is closed
        int semNumReg = Num(ddlSemester);
        if (!AcademicYearHelper.IsSemesterActive(semNumReg))
        {
            ShowMessage(string.Format(
                "Semester {0} is not currently open for course registration. " +
                "An administrator must set Semester {0} as active on the Academic Years page before registration can proceed.",
                ddlSemester.SelectedValue), "error");
            LoadStats();
            BindGrid();
            return;
        }

        int count = 0;
        int skipped = 0;
        List<string> errors = new List<string>();
        string username = HttpContext.Current.User.Identity.Name;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();

                List<string> selectedRows = GetSelectedRegnos();

                if (selectedRows.Count == 0)
                {
                    ShowMessage("No students selected. Please tick the checkboxes next to students you want to register.", "error");
                    LoadStats();
                    BindGrid();
                    return;
                }

                foreach (object row in selectedRows)
                {
                    string regno = row.ToString();
                    
                    try
                    {
                        // Check if already registered
                        string checkSql = @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration 
                                           WHERE regno = @regno AND courseID = @course 
                                             AND acad_year = @acad AND semester = @sem";
                        
                        using (MySqlCommand checkCmd = new MySqlCommand(checkSql, conn))
                        {
                            checkCmd.Parameters.AddWithValue("@regno", regno);
                            checkCmd.Parameters.AddWithValue("@course", courseCode);
                            checkCmd.Parameters.AddWithValue("@acad", Val(ddlAcadYear));
                            checkCmd.Parameters.AddWithValue("@sem", Num(ddlSemester));
                            
                            if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                            {
                                skipped++;
                                continue;
                            }
                        }
                        
                        // Use the existing stored procedure for proper registration + logging
                        // Must use ExecuteReader to consume the SELECT result set the proc returns
                        using (MySqlCommand spCmd = new MySqlCommand("acad_CourseRegister", conn))
                        {
                            spCmd.CommandType = CommandType.StoredProcedure;
                            spCmd.Parameters.AddWithValue("@reg", regno);
                            spCmd.Parameters.AddWithValue("@csid", courseCode);
                            spCmd.Parameters.AddWithValue("@acad", Val(ddlAcadYear));
                            spCmd.Parameters.AddWithValue("@sem", Num(ddlSemester));
                            spCmd.Parameters.AddWithValue("@cs_stat", "REGULAR");
                            spCmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                            spCmd.Parameters.AddWithValue("@usr", username);
                            spCmd.Parameters.AddWithValue("@act", "Pending");
                            using (MySqlDataReader rdr = spCmd.ExecuteReader())
                            {
                                // Consume the stored proc result set (the COMMIT runs after SELECT)
                                while (rdr.Read()) { }
                            }
                            count++;
                        }
                    }
                    catch (Exception ex)
                    {
                        errors.Add(regno + ": " + ex.Message);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Database error: " + ex.Message, "error");
            LoadStats();
            BindGrid();
            return;
        }
        
        // Build result message
        string msg = "";
        if (count > 0)
            msg += count + " student(s) registered successfully. ";
        if (skipped > 0)
            msg += skipped + " already registered (skipped). ";
        if (errors.Count > 0)
            msg += "Errors: " + string.Join("; ", errors.ToArray());
        
        if (errors.Count > 0)
            ShowMessage(msg, "error");
        else if (count > 0)
            ShowMessage(msg, "success");
        else
            ShowMessage("No students were registered. " + msg, "info");
        
        hfSelectedKeys.Value = string.Empty;
        LoadStats();
        BindGrid();
    }
    
    protected void btnRemoveSelected_Click(object sender, EventArgs e)
    {
        string courseCode = SelectedCourseCode;
        if (string.IsNullOrEmpty(courseCode))
        {
            ShowMessage("Please select a course, or type a course code, first.", "error");
            LoadStats();
            BindGrid();
            return;
        }
        if (Val(ddlAcadYear) == "" || Num(ddlSemester) <= 0)
        {
            ShowMessage("Choose the academic year and semester the registration should be removed from.", "error");
            LoadStats();
            BindGrid();
            return;
        }

        int count = 0;
        List<string> errors = new List<string>();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<string> selectedRows = GetSelectedRegnos();
                
                if (selectedRows.Count == 0)
                {
                    ShowMessage("No students selected. Please tick the checkboxes next to students you want to remove.", "error");
                    LoadStats();
                    BindGrid();
                    return;
                }
                
                string username = HttpContext.Current.User.Identity.Name;
                
                foreach (object row in selectedRows)
                {
                    string regno = row.ToString();
                    
                    try
                    {
                        // Use stored proc for proper de-registration + logging
                        using (MySqlCommand spCmd = new MySqlCommand("acad_CourseRegister", conn))
                        {
                            spCmd.CommandType = CommandType.StoredProcedure;
                            spCmd.Parameters.AddWithValue("@reg", regno);
                            spCmd.Parameters.AddWithValue("@csid", courseCode);
                            spCmd.Parameters.AddWithValue("@acad", Val(ddlAcadYear));
                            spCmd.Parameters.AddWithValue("@sem", Num(ddlSemester));
                            spCmd.Parameters.AddWithValue("@cs_stat", "NORMAL");
                            spCmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                            spCmd.Parameters.AddWithValue("@usr", username);
                            spCmd.Parameters.AddWithValue("@act", "Registered");
                            using (MySqlDataReader rdr = spCmd.ExecuteReader())
                            {
                                while (rdr.Read()) { }
                            }
                            count++;
                        }
                    }
                    catch (Exception ex)
                    {
                        errors.Add(regno + ": " + ex.Message);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Database error: " + ex.Message, "error");
            LoadStats();
            BindGrid();
            return;
        }
        
        string msg = "";
        if (count > 0)
            msg += count + " registration(s) removed successfully. ";
        if (errors.Count > 0)
            msg += "Errors: " + string.Join("; ", errors.ToArray());
        
        if (errors.Count > 0)
            ShowMessage(msg, "error");
        else if (count > 0)
            ShowMessage(msg, "success");
        else
            ShowMessage("No registrations were removed.", "info");
        
        hfSelectedKeys.Value = string.Empty;
        LoadStats();
        BindGrid();
    }
    
    
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        // The on-screen list is now a server-rendered HTML datatable; bind the hidden
        // DevExpress grid with the FULL (unpaged) result set just for the Excel export.
        int reqPage = 1; int totalRows, totalPages; bool isPendingView;
        DataTable dt = QueryRegistrations(false, ref reqPage, out totalRows, out totalPages, out isPendingView);
        gvCourseReg.DataSource = dt;
        gvCourseReg.DataBind();

        // Name the file for what is in it, including "all" where nothing was narrowed.
        string scopePart = string.IsNullOrEmpty(SelectedCourseCode)
            ? (string.IsNullOrEmpty(ddlProgramme.SelectedValue) ? "AllProgrammes" : ddlProgramme.SelectedValue)
            : SelectedCourseCode;
        string yearPart = Val(ddlAcadYear) == "" ? "AllYears" : Val(ddlAcadYear).Replace("/", "-");
        string semPart = Num(ddlSemester) > 0 ? "Sem" + Num(ddlSemester) : "AllSemesters";
        string fileName = string.Format("CourseRegistration_{0}_{1}_{2}", scopePart, yearPart, semPart);
        gvExporter.WriteXlsxToResponse(fileName, new XlsxExportOptionsEx { ExportType = DevExpress.Export.ExportType.WYSIWYG });
    }

    // ===============================================================
    //  ADMIN ROW ACTIONS (AJAX) — delete & change course status
    // ===============================================================
    private static string ActionConn
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    [WebMethod]
    public static string DeleteRegistration(string regno, string course, string acad, int sem)
    {
        var js = new JavaScriptSerializer();
        try
        {
            if (string.IsNullOrWhiteSpace(regno) || string.IsNullOrWhiteSpace(course) || string.IsNullOrWhiteSpace(acad))
                return js.Serialize(new { success = false, message = "Missing record key." });

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    DELETE FROM campus_dynamics_portal.acad_course_registration
                    WHERE regno = @r AND courseID = @c AND acad_year = @a AND semester = @s", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno.Trim());
                    cmd.Parameters.AddWithValue("@c", course.Trim());
                    cmd.Parameters.AddWithValue("@a", acad.Trim());
                    cmd.Parameters.AddWithValue("@s", sem);
                    int n = cmd.ExecuteNonQuery();
                    if (n <= 0) return js.Serialize(new { success = false, message = "No matching registration was found to delete." });
                }
            }
            return js.Serialize(new { success = true });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    [WebMethod]
    public static string SetCourseStatus(string regno, string course, string acad, int sem, string status)
    {
        var js = new JavaScriptSerializer();
        try
        {
            string st = (status ?? "").Trim().ToUpperInvariant();
            if (st != "REGULAR" && st != "RETAKE" && st != "NORMAL")
                return js.Serialize(new { success = false, message = "Invalid course status." });
            if (string.IsNullOrWhiteSpace(regno) || string.IsNullOrWhiteSpace(course) || string.IsNullOrWhiteSpace(acad))
                return js.Serialize(new { success = false, message = "Missing record key." });

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    UPDATE campus_dynamics_portal.acad_course_registration
                    SET course_status = @st
                    WHERE regno = @r AND courseID = @c AND acad_year = @a AND semester = @s", conn))
                {
                    cmd.Parameters.AddWithValue("@st", st);
                    cmd.Parameters.AddWithValue("@r", regno.Trim());
                    cmd.Parameters.AddWithValue("@c", course.Trim());
                    cmd.Parameters.AddWithValue("@a", acad.Trim());
                    cmd.Parameters.AddWithValue("@s", sem);
                    int n = cmd.ExecuteNonQuery();
                    if (n <= 0) return js.Serialize(new { success = false, message = "No matching registration was found to update." });
                }
            }
            return js.Serialize(new { success = true });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }
    
    // ===============================================================
    //  COURSE-CODE MOVE + SELF-CONTAINED ADD  (stable AJAX WebMethods)
    // ===============================================================

    /// <summary>
    /// Returns the target courses an admin can move a student onto (their programme's catalogue,
    /// annotated with study-year/semester), plus the codes the student already holds for this
    /// (academic year, semester) so the client can prevent a collision. Also used to fill the
    /// searchable course picker in the Add-Record modal.
    /// </summary>
    [WebMethod]
    public static string GetStudentCourseOptions(string regno, string acad, int sem)
    {
        var js = new JavaScriptSerializer();
        try
        {
            if (string.IsNullOrWhiteSpace(regno))
                return js.Serialize(new { success = false, message = "Missing registration number." });
            regno = regno.Trim();

            string prog = null, studentName = null;
            var courses = new List<object>();
            var taken = new List<string>();

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT progid, TRIM(CONCAT(COALESCE(firstname,''),' ',COALESCE(othername,''))) nm FROM acad_student WHERE regno=@r LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                            return js.Serialize(new { success = false, message = "Student not found: " + regno });
                        prog = rdr["progid"] == DBNull.Value ? "" : rdr["progid"].ToString().Trim();
                        studentName = rdr["nm"] == DBNull.Value ? "" : rdr["nm"].ToString();
                    }
                }

                // The programme's catalogue courses (deduped), with their curriculum year/semester + CU.
                using (var cmd = new MySqlCommand(
                    @"SELECT c.courseID code, c.courseName name,
                             MIN(pc.study_year) sy, MIN(pc.semester) sem, IFNULL(c.CreditUnit,0) cu
                        FROM acad_programmecourses pc
                        JOIN acad_course c ON c.courseID = pc.course_code
                       WHERE pc.progcode = @p AND IFNULL(pc.status,'Active') <> 'Inactive'
                       GROUP BY c.courseID, c.courseName, c.CreditUnit
                       ORDER BY sy, sem, name", conn))
                {
                    cmd.Parameters.AddWithValue("@p", prog);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read())
                            courses.Add(new
                            {
                                code = rdr["code"].ToString(),
                                name = rdr["name"] == DBNull.Value ? "" : rdr["name"].ToString(),
                                sy = rdr["sy"] == DBNull.Value ? "" : rdr["sy"].ToString(),
                                sem = rdr["sem"] == DBNull.Value ? "" : rdr["sem"].ToString(),
                                cu = rdr["cu"] == DBNull.Value ? "0" : rdr["cu"].ToString()
                            });
                }

                // Codes the student already has for this sitting (so the UI blocks a duplicate).
                if (!string.IsNullOrWhiteSpace(acad))
                    using (var cmd = new MySqlCommand(
                        @"SELECT courseID FROM campus_dynamics_portal.acad_course_registration
                          WHERE regno=@r AND acad_year=@a AND semester=@s", conn))
                    {
                        cmd.Parameters.AddWithValue("@r", regno);
                        cmd.Parameters.AddWithValue("@a", (acad ?? "").Trim());
                        cmd.Parameters.AddWithValue("@s", sem);
                        using (var rdr = cmd.ExecuteReader())
                            while (rdr.Read()) taken.Add(rdr["courseID"].ToString().Trim());
                    }
            }
            return js.Serialize(new { success = true, prog = prog, student = studentName, courses = courses, taken = taken });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    // ===============================================================
    //  EDIT ONE REGISTRATION
    //  Moving a course to a different sitting is not a single-column update: the
    //  published result is keyed on the same (regno, acad_year, semester) and has
    //  to travel with it, or the transcript keeps reporting the mark under a
    //  semester the student no longer has that course in. The destinations offered
    //  are the sittings the student has actually enrolled for — inventing one is
    //  how a course ends up in a year the student never attended.
    // ===============================================================

    /// <summary>
    /// Everything the edit modal needs: the registration as it stands, and the sittings this
    /// student has ever been enrolled in (semester registrations + any sitting they already
    /// hold courses in), each labelled with its year of study.
    /// </summary>
    [WebMethod]
    public static string GetRegistrationEdit(string regno, string course, string acad, int sem)
    {
        var js = new JavaScriptSerializer();
        try
        {
            regno = (regno ?? "").Trim(); course = (course ?? "").Trim(); acad = (acad ?? "").Trim();
            if (regno == "" || course == "") return js.Serialize(new { success = false, message = "Missing record key." });

            object record = null;
            var sittings = new List<object>();

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();

                // One join, no TRIM. The previous version asked acad_results five separate
                // times and wrapped both sides of every match in TRIM(), which makes the
                // (regno, courseid) index unusable — five full scans of 636,000 rows to open
                // one modal, which is where the two-minute wait came from. TRIM is also what
                // stopped the WHERE using the portal table's own unique index.
                using (var cmd = new MySqlCommand(
                    "SELECT cr.id, cr.regno, cr.courseID, cr.acad_year, cr.semester, IFNULL(cr.course_status,'') cstatus, " +
                    "       IFNULL(cr.mark_stage,'') stage, IFNULL(c.courseName,cr.courseID) cname, " +
                    "       TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) nm, IFNULL(s.progid,'') prog, " +
                    "       cr.provisional_course_work_marks cw, cr.provisional_exam_marks ex, cr.provisional_total_marks tot, " +
                    "       IFNULL(c.CreditUnit,0) cat_cu, " +
                    "       r.score, r.grade, r.gradept gp, r.CreditUnits cu, " +
                    "       CASE WHEN r.ID IS NULL THEN 0 ELSE 1 END has_result " +
                    "FROM campus_dynamics_portal.acad_course_registration cr " +
                    // CONVERT always on the portal side: the portal DB is utf8mb4 and this one
                    // is utf8, and MySQL widens to utf8mb4 — which would convert the *indexed*
                    // campus_dynamics column and scan it instead.
                    "LEFT JOIN acad_course c ON c.courseID = CONVERT(cr.courseID USING utf8) " +
                    "LEFT JOIN acad_student s ON s.regno = CONVERT(cr.regno USING utf8) " +
                    "LEFT JOIN acad_results r ON r.regno = CONVERT(cr.regno USING utf8) " +
                    "                        AND r.courseid = CONVERT(cr.courseID USING utf8) " +
                    "                        AND r.acad = CONVERT(cr.acad_year USING utf8) " +
                    "                        AND r.semester = cr.semester " +
                    "WHERE cr.regno=@r AND cr.courseID=@c AND cr.acad_year=@a AND cr.semester=@s LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    cmd.Parameters.AddWithValue("@c", course);
                    cmd.Parameters.AddWithValue("@a", acad);
                    cmd.Parameters.AddWithValue("@s", sem);
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (!rd.Read()) return js.Serialize(new { success = false, message = "That registration no longer exists." });
                        record = new
                        {
                            id = Convert.ToInt32(rd["id"]),
                            regno = SR2(rd, "regno"),
                            course = SR2(rd, "courseID"),
                            courseName = SR2(rd, "cname"),
                            student = SR2(rd, "nm"),
                            programme = SR2(rd, "prog"),
                            acad = SR2(rd, "acad_year"),
                            sem = SR2(rd, "semester"),
                            status = SR2(rd, "cstatus"),
                            stage = SR2(rd, "stage"),
                            hasResult = SR2(rd, "has_result") != "0",
                            score = SR2(rd, "score"),
                            grade = SR2(rd, "grade"),
                            gp = SR2(rd, "gp"),
                            cu = SR2(rd, "cu") != "" ? SR2(rd, "cu") : SR2(rd, "cat_cu"),
                            cw = SR2(rd, "cw"),
                            exam = SR2(rd, "ex"),
                            total = SR2(rd, "tot")
                        };
                    }
                }

                // Where this course may legitimately be moved to: every sitting the student has
                // a semester registration for, plus any sitting they already hold courses in.
                using (var cmd = new MySqlCommand(
                    // No TRIM here either: both tables index regno, and wrapping it hides that.
                    "SELECT acad_year, semester, MAX(sy) sy, MAX(src) src FROM (" +
                    "  SELECT acad_year, CAST(semester AS UNSIGNED) semester, MIN(studyyear) sy, 'registration' src " +
                    "    FROM acad_registration WHERE regno=@r AND IFNULL(acad_year,'')<>'' GROUP BY acad_year, semester " +
                    "  UNION ALL " +
                    "  SELECT acad_year, CAST(semester AS UNSIGNED) semester, 0 sy, 'courses' src " +
                    "    FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND IFNULL(acad_year,'')<>'' " +
                    "   GROUP BY acad_year, semester" +
                    ") x GROUP BY acad_year, semester ORDER BY acad_year, semester", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rd = cmd.ExecuteReader())
                        while (rd.Read())
                            sittings.Add(new
                            {
                                acad = SR2(rd, "acad_year"),
                                sem = SR2(rd, "semester"),
                                studyYear = SR2(rd, "sy") == "0" ? "" : SR2(rd, "sy"),
                                source = SR2(rd, "src")
                            });
                }
            }
            return js.Serialize(new { success = true, record, sittings });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    /// <summary>
    /// Applies an edit: course status and/or a move to another sitting. The published result
    /// moves with the registration and is re-stamped with the destination's year of study.
    /// Refuses a move that would collide with a course the student already holds there.
    /// </summary>
    [WebMethod]
    public static string SaveRegistrationEdit(string regno, string course, string acad, int sem,
                                              string toAcad, int toSem, string status, string note)
    {
        var js = new JavaScriptSerializer();
        try
        {
            regno = (regno ?? "").Trim(); course = (course ?? "").Trim(); acad = (acad ?? "").Trim();
            toAcad = (toAcad ?? "").Trim();
            status = (status ?? "").Trim().ToUpperInvariant();
            if (regno == "" || course == "" || acad == "") return js.Serialize(new { success = false, message = "Missing record key." });
            if (toAcad == "" || toSem <= 0) return js.Serialize(new { success = false, message = "Choose the academic year and semester to move this course to." });
            if (status != "NORMAL" && status != "REGULAR" && status != "RETAKE")
                return js.Serialize(new { success = false, message = "Course status must be Normal/Regular or Retake." });

            bool moving = !string.Equals(acad, toAcad, StringComparison.OrdinalIgnoreCase) || sem != toSem;
            string actor = "";
            try { actor = HttpContext.Current.User.Identity.Name; } catch { }
            if (string.IsNullOrEmpty(actor)) actor = "admin";

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();

                if (moving)
                {
                    // The destination must be a sitting the student actually has.
                    using (var q = new MySqlCommand(
                        "SELECT (SELECT COUNT(*) FROM acad_registration WHERE regno=@r AND acad_year=@a AND semester=@s) " +
                        "     + (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration WHERE regno=@r AND acad_year=@a AND semester=@s)", conn))
                    {
                        q.Parameters.AddWithValue("@r", regno); q.Parameters.AddWithValue("@a", toAcad); q.Parameters.AddWithValue("@s", toSem);
                        if (Convert.ToInt64(q.ExecuteScalar()) == 0)
                            return js.Serialize(new { success = false, message = "This student has never enrolled for " + toAcad + " Semester " + toSem + ". Register that semester first." });
                    }

                    using (var q = new MySqlCommand(
                        "SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration " +
                        "WHERE regno=@r AND courseID=@c AND acad_year=@a AND semester=@s", conn))
                    {
                        q.Parameters.AddWithValue("@r", regno); q.Parameters.AddWithValue("@c", course);
                        q.Parameters.AddWithValue("@a", toAcad); q.Parameters.AddWithValue("@s", toSem);
                        if (Convert.ToInt64(q.ExecuteScalar()) > 0)
                            return js.Serialize(new { success = false, message = "The student already has " + course + " in " + toAcad + " Semester " + toSem + ". Delete that duplicate first." });
                    }
                }

                int toStudyYear = 0;
                using (var q = new MySqlCommand(
                    "SELECT MIN(studyyear) FROM acad_registration WHERE regno=@r AND acad_year=@a AND IFNULL(studyyear,0)>0", conn))
                {
                    q.Parameters.AddWithValue("@r", regno); q.Parameters.AddWithValue("@a", toAcad);
                    var o = q.ExecuteScalar();
                    if (o != null && o != DBNull.Value) int.TryParse(o.ToString(), out toStudyYear);
                }

                int movedReg = 0, movedRes = 0;
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        using (var up = new MySqlCommand(
                            "UPDATE campus_dynamics_portal.acad_course_registration " +
                            "SET acad_year=@ta, semester=@ts, course_status=@st " +
                            "WHERE regno=@r AND courseID=@c AND acad_year=@a AND semester=@s", conn, tx))
                        {
                            up.Parameters.AddWithValue("@ta", toAcad); up.Parameters.AddWithValue("@ts", toSem);
                            up.Parameters.AddWithValue("@st", status == "REGULAR" ? "NORMAL" : status);
                            up.Parameters.AddWithValue("@r", regno); up.Parameters.AddWithValue("@c", course);
                            up.Parameters.AddWithValue("@a", acad); up.Parameters.AddWithValue("@s", sem);
                            movedReg = up.ExecuteNonQuery();
                        }
                        if (movedReg == 0) { tx.Rollback(); return js.Serialize(new { success = false, message = "That registration no longer exists." }); }

                        if (moving)
                            using (var up = new MySqlCommand(
                                "UPDATE acad_results SET acad=@ta, semester=@ts" +
                                (toStudyYear > 0 ? ", studyyear=@sy" : "") +
                                " WHERE regno=@r AND courseid=@c AND acad=@a AND semester=@s", conn, tx))
                            {
                                up.Parameters.AddWithValue("@ta", toAcad); up.Parameters.AddWithValue("@ts", toSem);
                                if (toStudyYear > 0) up.Parameters.AddWithValue("@sy", toStudyYear);
                                up.Parameters.AddWithValue("@r", regno); up.Parameters.AddWithValue("@c", course);
                                up.Parameters.AddWithValue("@a", acad); up.Parameters.AddWithValue("@s", sem);
                                movedRes = up.ExecuteNonQuery();
                            }

                        using (var log = new MySqlCommand(
                            "INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date) " +
                            "VALUES (@u,'CourseRegistration:EditRegistration',@p,@c,NOW())", conn, tx))
                        {
                            string par = regno + "|" + course;
                            string cmt = moving
                                ? ("Moved " + acad + " S" + sem + " -> " + toAcad + " S" + toSem +
                                   " (result rows " + movedRes + (toStudyYear > 0 ? ", study year " + toStudyYear : "") + ")")
                                : ("Status set to " + status);
                            if (!string.IsNullOrWhiteSpace(note)) cmt += " — " + note.Trim();
                            log.Parameters.AddWithValue("@u", actor.Length > 100 ? actor.Substring(0, 100) : actor);
                            log.Parameters.AddWithValue("@p", par.Length > 300 ? par.Substring(0, 300) : par);
                            log.Parameters.AddWithValue("@c", cmt.Length > 200 ? cmt.Substring(0, 200) : cmt);
                            log.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch { try { tx.Rollback(); } catch { } throw; }
                }

                string msg = moving
                    ? ("Moved to " + toAcad + " Semester " + toSem +
                       (movedRes > 0 ? " with its published result" : "") +
                       (toStudyYear > 0 ? " (Year " + toStudyYear + ")" : "") + ".")
                    : "Course status updated.";
                return js.Serialize(new { success = true, message = msg, movedResult = movedRes });
            }
        }
        catch (MySqlException mex)
        {
            if (mex.Number == 1062) return js.Serialize(new { success = false, message = "That would duplicate a registration the student already has." });
            return js.Serialize(new { success = false, message = mex.Message });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    private static string SR2(MySqlDataReader r, string col)
    { try { object o = r[col]; return o == null || o == DBNull.Value ? "" : o.ToString().Trim(); } catch { return ""; } }

    /// <summary>
    /// Type-ahead for the "Course Code" filter: up to 15 catalogue courses whose code or name
    /// matches what the admin is typing. Code matches are ranked first (a code prefix first of all)
    /// so the exact paper being looked for tops the list.
    /// </summary>
    [WebMethod]
    public static string SearchCourses(string term)
    {
        var js = new JavaScriptSerializer();
        try
        {
            string t = (term ?? "").Trim();
            if (t.Length < 2)
                return js.Serialize(new { success = true, courses = new List<object>() });

            var courses = new List<object>();
            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"SELECT courseID, courseName
                        FROM acad_course
                       WHERE courseID LIKE @like OR courseName LIKE @like
                       ORDER BY CASE WHEN courseID LIKE @prefix THEN 0
                                     WHEN courseID LIKE @like   THEN 1
                                     ELSE 2 END, courseID
                       LIMIT 15", conn))
                {
                    cmd.Parameters.AddWithValue("@like", "%" + t + "%");
                    cmd.Parameters.AddWithValue("@prefix", t + "%");
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read())
                            courses.Add(new { code = SR(rdr, "courseID"), name = SR(rdr, "courseName") });
                }
            }
            return js.Serialize(new { success = true, courses = courses });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    /// <summary>
    /// Read-only course/semester enrolment snapshot for one student, powering the enrolment modal:
    /// the student header, their semester registrations (acad_registration) and every course they
    /// are registered for (portal acad_course_registration) with its mark stage / provisional marks —
    /// grouped by the client into academic-year + semester sittings.
    /// </summary>
    [WebMethod]
    public static string GetStudentEnrolment(string regno)
    {
        var js = new JavaScriptSerializer();
        try
        {
            if (string.IsNullOrWhiteSpace(regno))
                return js.Serialize(new { success = false, message = "Missing registration number." });
            regno = regno.Trim();

            object student = null;
            var regs = new List<object>();
            var courses = new List<object>();

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();

                using (var cmd = new MySqlCommand(
                    @"SELECT s.regno, s.entryno,
                             TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS name,
                             s.progid, p.progname, s.entryyear, s.intake, s.studsesion,
                             IFNULL(cm.campus_name, s.studCampus) AS campus, s.stud_status
                        FROM acad_student s
                        LEFT JOIN acad_programme p ON p.progcode = s.progid
                        LEFT JOIN acad_campuses cm ON cm.campus_code = s.studCampus
                       WHERE s.regno = @r LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                            return js.Serialize(new { success = false, message = "Student not found: " + regno });
                        student = new
                        {
                            regno = SR(rdr, "regno"),
                            entryno = SR(rdr, "entryno"),
                            name = SR(rdr, "name"),
                            prog = SR(rdr, "progid"),
                            progname = SR(rdr, "progname"),
                            entryyear = SR(rdr, "entryyear"),
                            intake = SR(rdr, "intake"),
                            session = SR(rdr, "studsesion"),
                            campus = SR(rdr, "campus"),
                            status = SR(rdr, "stud_status")
                        };
                    }
                }

                using (var cmd = new MySqlCommand(
                    @"SELECT acad_year, studyyear, semester, regstatus
                        FROM acad_registration WHERE regno = @r
                       ORDER BY acad_year DESC, studyyear DESC, semester DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read())
                            regs.Add(new { acad = SR(rdr, "acad_year"), sy = SR(rdr, "studyyear"), sem = SR(rdr, "semester"), status = SR(rdr, "regstatus") });
                }

                using (var cmd = new MySqlCommand(
                    @"SELECT cr.acad_year, cr.semester, cr.courseID, c.courseName,
                             cr.course_status, cr.mark_stage,
                             cr.provisional_course_work_marks AS cw, cr.provisional_exam_marks AS ex,
                             cr.provisional_total_marks AS tot, cr.provisional_marks_status AS mstat,
                             IFNULL(c.CreditUnit,0) AS cu
                        FROM campus_dynamics_portal.acad_course_registration cr
                        LEFT JOIN acad_course c ON c.courseID = cr.courseID
                       WHERE cr.regno = @r
                       ORDER BY cr.acad_year DESC, cr.semester DESC, cr.courseID", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read())
                            courses.Add(new
                            {
                                acad = SR(rdr, "acad_year"),
                                sem = SR(rdr, "semester"),
                                code = SR(rdr, "courseID"),
                                name = SR(rdr, "courseName"),
                                cstatus = SR(rdr, "course_status"),
                                stage = SR(rdr, "mark_stage"),
                                cw = SR(rdr, "cw"),
                                ex = SR(rdr, "ex"),
                                tot = SR(rdr, "tot"),
                                mstat = SR(rdr, "mstat"),
                                cu = SR(rdr, "cu")
                            });
                }
            }
            return js.Serialize(new { success = true, student = student, registrations = regs, courses = courses });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }
    private static string SR(MySqlDataReader r, string col)
    {
        try { object o = r[col]; return o == null || o == DBNull.Value ? "" : o.ToString(); } catch { return ""; }
    }

    /// <summary>
    /// Moves ONE student from a wrongly-selected course code to the correct one for a given sitting,
    /// carrying the marks with it: updates the portal registration (with its provisional CW/Exam),
    /// the published result and the transcript result — so the course now counts under the correct
    /// code in every result summary. Refuses if the student already holds the target course that
    /// sitting (would duplicate). Everything runs in one transaction.
    /// </summary>
    [WebMethod]
    public static string ChangeCourseCode(string regno, string oldCourse, string acad, int sem, string newCourse, string reason)
    {
        var js = new JavaScriptSerializer();
        try
        {
            regno = (regno ?? "").Trim();
            oldCourse = (oldCourse ?? "").Trim();
            newCourse = (newCourse ?? "").Trim();
            acad = (acad ?? "").Trim();
            if (regno == "" || oldCourse == "" || newCourse == "" || acad == "")
                return js.Serialize(new { success = false, message = "Missing record key." });
            if (string.Equals(oldCourse, newCourse, StringComparison.OrdinalIgnoreCase))
                return js.Serialize(new { success = false, message = "The new course is the same as the current one." });

            string actor = "";
            try { actor = HttpContext.Current.User.Identity.Name; } catch { }

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();

                // Target course must exist in the catalogue; grab its programme study-year + CU so the
                // result/transcript rows stay internally consistent after the move.
                string prog = "";
                using (var cmd = new MySqlCommand("SELECT progid FROM acad_student WHERE regno=@r LIMIT 1", conn))
                { cmd.Parameters.AddWithValue("@r", regno); var o = cmd.ExecuteScalar(); prog = o == null || o == DBNull.Value ? "" : o.ToString().Trim(); }

                double? newCu = null;
                using (var cmd = new MySqlCommand("SELECT CreditUnit FROM acad_course WHERE courseID=@c LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@c", newCourse);
                    var o = cmd.ExecuteScalar();
                    if (o == null) return js.Serialize(new { success = false, message = "Target course '" + newCourse + "' does not exist in the course catalogue." });
                    if (o != DBNull.Value) { double d; if (double.TryParse(o.ToString(), out d) && d > 0) newCu = d; }
                }
                int? newSy = null;
                using (var cmd = new MySqlCommand("SELECT MIN(study_year) FROM acad_programmecourses WHERE progcode=@p AND course_code=@c", conn))
                { cmd.Parameters.AddWithValue("@p", prog); cmd.Parameters.AddWithValue("@c", newCourse); var o = cmd.ExecuteScalar(); if (o != null && o != DBNull.Value) { int v; if (int.TryParse(o.ToString(), out v)) newSy = v; } }

                // Collision guard: refuse if the student already holds the target code this sitting.
                using (var cmd = new MySqlCommand(
                    @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration
                      WHERE regno=@r AND courseID=@n AND acad_year=@a AND semester=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@n", newCourse);
                    cmd.Parameters.AddWithValue("@a", acad); cmd.Parameters.AddWithValue("@s", sem);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                        return js.Serialize(new { success = false, message = "This student is already registered for " + newCourse + " in " + acad + " Semester " + sem + ". Delete the duplicate first, or pick a different code." });
                }

                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        int moved;
                        using (var cmd = new MySqlCommand(
                            @"UPDATE campus_dynamics_portal.acad_course_registration
                              SET courseID=@n
                              WHERE regno=@r AND courseID=@o AND acad_year=@a AND semester=@s", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@n", newCourse); cmd.Parameters.AddWithValue("@r", regno);
                            cmd.Parameters.AddWithValue("@o", oldCourse); cmd.Parameters.AddWithValue("@a", acad); cmd.Parameters.AddWithValue("@s", sem);
                            moved = cmd.ExecuteNonQuery();
                        }
                        if (moved <= 0) { tx.Rollback(); return js.Serialize(new { success = false, message = "No matching registration was found to move." }); }

                        // Published result + transcript: move the mark to the new code and keep CU / study-year consistent.
                        foreach (string tbl in new[] { "acad_results", "acad_transcript_results" })
                            using (var cmd = new MySqlCommand(
                                "UPDATE " + tbl + " SET courseid=@n" +
                                (newCu.HasValue ? ", CreditUnits=@cu" : "") +
                                (newSy.HasValue ? ", studyyear=@sy" : "") +
                                " WHERE regno=@r AND courseid=@o AND acad=@a AND semester=@s", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@n", newCourse); cmd.Parameters.AddWithValue("@r", regno);
                                cmd.Parameters.AddWithValue("@o", oldCourse); cmd.Parameters.AddWithValue("@a", acad); cmd.Parameters.AddWithValue("@s", sem);
                                if (newCu.HasValue) cmd.Parameters.AddWithValue("@cu", newCu.Value);
                                if (newSy.HasValue) cmd.Parameters.AddWithValue("@sy", newSy.Value);
                                cmd.ExecuteNonQuery();
                            }

                        using (var cmd = new MySqlCommand(
                            @"INSERT INTO acad_activity_log (user_id, page_function, par, comments, access_date)
                              VALUES (@u, 'CourseRegistration:ChangeCourseCode', @par, @cmt, NOW())", conn, tx))
                        {
                            string par = regno + "|" + acad + "|S" + sem;
                            string cmt = "Moved " + oldCourse + " -> " + newCourse + (string.IsNullOrWhiteSpace(reason) ? "" : " (" + reason.Trim() + ")");
                            cmd.Parameters.AddWithValue("@u", (string.IsNullOrEmpty(actor) ? "system" : actor).Length > 100 ? actor.Substring(0, 100) : (string.IsNullOrEmpty(actor) ? "system" : actor));
                            cmd.Parameters.AddWithValue("@par", par.Length > 300 ? par.Substring(0, 300) : par);
                            cmd.Parameters.AddWithValue("@cmt", cmt.Length > 200 ? cmt.Substring(0, 200) : cmt);
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }
            }
            return js.Serialize(new { success = true, message = "Moved to " + newCourse + "." });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    /// <summary>
    /// Self-contained add of a course registration (no page postback / UpdatePanel), so the
    /// Add-Record popup is stable. Study-year is derived from the target course's curriculum
    /// position; keeps the semester-active + semester-registration guards.
    /// </summary>
    [WebMethod]
    public static string AddCourseRegistration(string regno, string course, string acad, int sem, string type)
    {
        var js = new JavaScriptSerializer();
        try
        {
            regno = (regno ?? "").Trim();
            course = (course ?? "").Trim();
            acad = (acad ?? "").Trim();
            string recordType = (type ?? "REGULAR").Trim().ToUpperInvariant();
            if (recordType != "RETAKE") recordType = "REGULAR";
            if (regno == "" || course == "" || acad == "")
                return js.Serialize(new { success = false, message = "Please provide registration number, course and academic year." });

            if (!AcademicYearHelper.IsSemesterActive(sem))
                return js.Serialize(new { success = false, message = "Semester " + sem + " is not open for registration. An administrator must set it active on the Academic Years page first." });

            string actor = "";
            try { actor = HttpContext.Current.User.Identity.Name; } catch { }

            using (var conn = new MySqlConnection(ActionConn))
            {
                conn.Open();

                string prog;
                using (var cmd = new MySqlCommand("SELECT progid FROM acad_student WHERE regno=@r LIMIT 1", conn))
                { cmd.Parameters.AddWithValue("@r", regno); var o = cmd.ExecuteScalar();
                  if (o == null || o == DBNull.Value) return js.Serialize(new { success = false, message = "Student '" + regno + "' not found." });
                  prog = o.ToString().Trim(); }

                // Study year from the target course's curriculum position (for the REGULAR guard).
                int studyYear = 0;
                using (var cmd = new MySqlCommand("SELECT MIN(study_year) FROM acad_programmecourses WHERE progcode=@p AND course_code=@c", conn))
                { cmd.Parameters.AddWithValue("@p", prog); cmd.Parameters.AddWithValue("@c", course); var o = cmd.ExecuteScalar(); if (o != null && o != DBNull.Value) int.TryParse(o.ToString(), out studyYear); }

                if (recordType == "REGULAR" && studyYear > 0)
                    using (var cmd = new MySqlCommand(
                        @"SELECT COUNT(*) FROM acad_registration
                          WHERE regno=@r AND acad_year=@a AND studyyear=@y
                            AND regstatus IN ('REGISTERED','CLEARED','LATE REGISTERED')", conn))
                    {
                        cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@a", acad); cmd.Parameters.AddWithValue("@y", studyYear);
                        if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                            return js.Serialize(new { success = false, message = "Student is not semester-registered for " + acad + ", Year " + studyYear + ". Register the semester first, or add it as a RETAKE." });
                    }

                using (var cmd = new MySqlCommand(
                    @"SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration
                      WHERE regno=@r AND courseID=@c AND acad_year=@a AND semester=@s", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@c", course);
                    cmd.Parameters.AddWithValue("@a", acad); cmd.Parameters.AddWithValue("@s", sem);
                    if (Convert.ToInt32(cmd.ExecuteScalar()) > 0)
                        return js.Serialize(new { success = false, message = "Student is already registered for " + course + " in " + acad + " Semester " + sem + "." });
                }

                using (var cmd = new MySqlCommand("acad_CourseRegister", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@reg", regno);
                    cmd.Parameters.AddWithValue("@csid", course);
                    cmd.Parameters.AddWithValue("@acad", acad);
                    cmd.Parameters.AddWithValue("@sem", sem);
                    cmd.Parameters.AddWithValue("@cs_stat", recordType);
                    cmd.Parameters.AddWithValue("@prog", prog);
                    cmd.Parameters.AddWithValue("@usr", string.IsNullOrEmpty(actor) ? "system" : actor);
                    cmd.Parameters.AddWithValue("@act", "Pending");
                    using (var rdr = cmd.ExecuteReader()) { while (rdr.Read()) { } }
                }
            }
            return js.Serialize(new { success = true, message = (recordType == "RETAKE" ? "Retake" : "Regular") + " record added for " + regno + "." });
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    private void ShowMessage(string message, string type)
    {
        pnlMessage.Visible = true;
        pnlMessage.CssClass = "cr-message show cr-message--" + type;
        litMessage.Text = message;
    }
    
    // ===============================================================
    //  QUICK EDIT MODAL
    // ===============================================================
    
    private void LoadQuickEditDropdowns()
    {
        // Sessions
        ddlQeSession.Items.Clear();
        
        // Campuses
        ddlQeCampus.Items.Clear();
        
        // Entry Years
        ddlQeEntryYear.Items.Clear();
        ddlQeEntryYear.Items.Add(new ListItem("-- Select Year --", ""));
        int cy = DateTime.Now.Year;
        for (int y = cy + 1; y >= cy - 20; y--)
            ddlQeEntryYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
        
        // Billing (from accounts database)
        ddlQeBilling.Items.Clear();
        ddlQeBilling.Items.Add(new ListItem("-- Select --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Sessions
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT DISTINCT studsesion FROM acad_student WHERE studsesion != '' ORDER BY studsesion", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeSession.Items.Add(new ListItem(
                            rdr["studsesion"].ToString(), rdr["studsesion"].ToString()));
                
                // Campuses
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT campus_code, campus_name FROM acad_campuses WHERE campus_code != '00' ORDER BY campus_name", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeCampus.Items.Add(new ListItem(
                            rdr["campus_name"].ToString(), rdr["campus_code"].ToString()));
                
            }
        }
        catch { }
        
        // Billing systems (separate database)
        try
        {
            using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT ID, bs_name FROM fin_billing_systems ORDER BY bs_name", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        ddlQeBilling.Items.Add(new ListItem(
                            rdr["bs_name"].ToString(), rdr["ID"].ToString()));
            }
        }
        catch { }
    }
    
    protected void btnQeLoad_Click(object sender, EventArgs e)
    {
        string regno = (hfQeRegNo.Value ?? "").Trim();
        if (string.IsNullOrEmpty(regno)) return;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                string sql = @"SELECT regno, entryno, firstname, othername, gender,
                                      dob, national_id, studPhone, email, nationality,
                                      religion, progid, studsesion,
                                      studCampus, entryyear, entrymethod, intake,
                                      billingID, stud_status, new_status, home_dist
                               FROM acad_student
                               WHERE regno = @rn LIMIT 1";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@rn", regno);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                        {
                            QeMsg("Student not found: " + regno, "err");
                            return;
                        }
                        
                        // Populate read-only fields via JS
                        string regNoVal = rdr["regno"].ToString();
                        string entryNoVal = rdr["entryno"] != DBNull.Value ? rdr["entryno"].ToString() : "-";
                        
                        // Personal fields
                        txtQeFirstName.Text = rdr["firstname"] != DBNull.Value ? rdr["firstname"].ToString() : "";
                        txtQeOtherName.Text = rdr["othername"] != DBNull.Value ? rdr["othername"].ToString() : "";
                        
                        string gender = rdr["gender"] != DBNull.Value ? rdr["gender"].ToString() : "MALE";
                        if (ddlQeGender.Items.FindByValue(gender) != null)
                            ddlQeGender.SelectedValue = gender;
                        
                        if (rdr["dob"] != DBNull.Value)
                        {
                            DateTime dob = Convert.ToDateTime(rdr["dob"]);
                            txtQeDOB.Text = dob.ToString("yyyy-MM-dd");
                        }
                        else
                        {
                            txtQeDOB.Text = "";
                        }
                        
                        txtQeNIN.Text = rdr["national_id"] != DBNull.Value ? rdr["national_id"].ToString() : "";
                        txtQePhone.Text = rdr["studPhone"] != DBNull.Value ? rdr["studPhone"].ToString() : "";
                        txtQeEmail.Text = rdr["email"] != DBNull.Value ? rdr["email"].ToString() : "";
                        txtQeNationality.Text = rdr["nationality"] != DBNull.Value ? rdr["nationality"].ToString() : "";
                        txtQeDistrict.Text = rdr["home_dist"] != DBNull.Value ? rdr["home_dist"].ToString() : "";
                        
                        string religion = rdr["religion"] != DBNull.Value ? rdr["religion"].ToString() : "-";
                        if (ddlQeReligion.Items.FindByValue(religion) != null)
                            ddlQeReligion.SelectedValue = religion;
                        
                        // Academic fields
                        string session = rdr["studsesion"] != DBNull.Value ? rdr["studsesion"].ToString() : "";
                        if (ddlQeSession.Items.FindByValue(session) != null)
                            ddlQeSession.SelectedValue = session;
                        
                        // Campus: DB stores int (1,2), dropdown values are zero-padded ("01","02")
                        int campusInt = 0;
                        if (rdr["studCampus"] != DBNull.Value)
                            int.TryParse(rdr["studCampus"].ToString(), out campusInt);
                        if (campusInt > 0)
                        {
                            string campusPad = campusInt.ToString().PadLeft(2, '0');
                            if (ddlQeCampus.Items.FindByValue(campusPad) != null)
                                ddlQeCampus.SelectedValue = campusPad;
                        }
                        
                        int entryYr = 0;
                        if (rdr["entryyear"] != DBNull.Value)
                            int.TryParse(rdr["entryyear"].ToString(), out entryYr);
                        if (entryYr > 0)
                        {
                            string eyStr = entryYr.ToString();
                            if (ddlQeEntryYear.Items.FindByValue(eyStr) == null)
                                ddlQeEntryYear.Items.Insert(0, new ListItem(eyStr, eyStr));
                            ddlQeEntryYear.SelectedValue = eyStr;
                        }
                        
                        string entryMethod = rdr["entrymethod"] != DBNull.Value ? rdr["entrymethod"].ToString() : "DIRECT";
                        if (ddlQeEntryMethod.Items.FindByValue(entryMethod) != null)
                            ddlQeEntryMethod.SelectedValue = entryMethod;
                        
                        string intake = rdr["intake"] != DBNull.Value ? rdr["intake"].ToString() : "AUGUST";
                        if (ddlQeIntakeEdit.Items.FindByValue(intake) != null)
                            ddlQeIntakeEdit.SelectedValue = intake;
                        
                        int billingId = 0;
                        if (rdr["billingID"] != DBNull.Value)
                            int.TryParse(rdr["billingID"].ToString(), out billingId);
                        if (billingId > 0 && ddlQeBilling.Items.FindByValue(billingId.ToString()) != null)
                            ddlQeBilling.SelectedValue = billingId.ToString();
                        
                        // Status
                        string studStatus = rdr["stud_status"] != DBNull.Value ? rdr["stud_status"].ToString() : "ACTIVE";
                        if (ddlQeStatus.Items.FindByValue(studStatus) != null)
                            ddlQeStatus.SelectedValue = studStatus;
                        
                        string newStatus = rdr["new_status"] != DBNull.Value ? rdr["new_status"].ToString() : "ADMITTED";
                        if (ddlQeNewStatus.Items.FindByValue(newStatus) != null)
                            ddlQeNewStatus.SelectedValue = newStatus;
                        
                        // Set JS-side fields and show modal
                        string jsRegNo = regNoVal.Replace("'", "\\'");
                        string jsEntryNo = entryNoVal.Replace("'", "\\'");
                        
                        ScriptManager.RegisterStartupScript(this, GetType(), "qeShow",
                            "document.getElementById('qeRegNo').value='" + jsRegNo + "';" +
                            "document.getElementById('qeEntryNo').value='" + jsEntryNo + "';" +
                            "document.getElementById('qeTitle').innerText='Quick Edit: " + jsRegNo + "';" +
                            "showQuickEditModal();", true);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            QeMsg("Error loading student: " + ex.Message, "err");
        }
    }
    
    protected void btnQeSave_Click(object sender, EventArgs e)
    {
        string regno = (hfQeRegNo.Value ?? "").Trim();
        if (string.IsNullOrEmpty(regno))
        {
            QeMsg("No student selected.", "err");
            return;
        }
        
        try
        {
            // --- Gather & sanitise all form values ---
            string firstName = (txtQeFirstName.Text ?? "").Trim().ToUpper();
            string otherName = (txtQeOtherName.Text ?? "").Trim().ToUpper();
            string gender = ddlQeGender.SelectedValue ?? "MALE";
            string dobStr = (txtQeDOB.Text ?? "").Trim();
            string nin = (txtQeNIN.Text ?? "").Trim().ToUpper();
            string phone = (txtQePhone.Text ?? "").Trim();
            string email = (txtQeEmail.Text ?? "").Trim();
            string nationality = (txtQeNationality.Text ?? "").Trim().ToUpper();
            string district = (txtQeDistrict.Text ?? "").Trim().ToUpper();
            string religion = ddlQeReligion.SelectedValue ?? "-";
            string session = ddlQeSession.SelectedValue ?? "";
            string entryMethod = ddlQeEntryMethod.SelectedValue ?? "DIRECT";
            string intake = ddlQeIntakeEdit.SelectedValue ?? "AUGUST";
            string studStatus = ddlQeStatus.SelectedValue ?? "ACTIVE";
            string newStatus = ddlQeNewStatus.SelectedValue ?? "ADMITTED";
            
            // --- Validation ---
            if (string.IsNullOrEmpty(firstName))
            { QeMsg("First Name is required.", "err"); return; }
            if (string.IsNullOrEmpty(phone))
            { QeMsg("Phone number is required.", "err"); return; }
            if (string.IsNullOrEmpty(session))
            { QeMsg("Please select a Study Session.", "err"); return; }

            // Campus: dropdown value "01" → int 1 for DB
            int campusInt = 1;
            string campusVal = ddlQeCampus.SelectedValue;
            if (!string.IsNullOrEmpty(campusVal))
                int.TryParse(campusVal, out campusInt);
            if (campusInt <= 0) campusInt = 1;
            
            // Entry year
            int entryYear = DateTime.Now.Year;
            string eyVal = ddlQeEntryYear.SelectedValue;
            if (!string.IsNullOrEmpty(eyVal))
                int.TryParse(eyVal, out entryYear);
            
            // Billing
            int billingId = 1;
            string billVal = ddlQeBilling.SelectedValue;
            if (!string.IsNullOrEmpty(billVal))
                int.TryParse(billVal, out billingId);
            if (billingId <= 0) billingId = 1;
            
            // Parse DOB safely
            DateTime dob = new DateTime(1980, 1, 1);
            if (!string.IsNullOrEmpty(dobStr))
            {
                DateTime parsed;
                if (DateTime.TryParse(dobStr, out parsed))
                    dob = parsed;
            }

            // Default empty fields
            if (string.IsNullOrEmpty(nationality)) nationality = "UGANDAN";
            if (string.IsNullOrEmpty(district)) district = "UGANDA";

            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // --- UPDATE acad_student ---
                string sql = @"UPDATE acad_student SET
                    firstname      = @firstName,
                    othername      = @otherName,
                    gender         = @gender,
                    dob            = @dob,
                    national_id    = @nin,
                    studPhone      = @phone,
                    email          = @email,
                    nationality    = @nationality,
                    religion       = @religion,
                    studsesion     = @session,
                    studCampus     = @campus,
                    entryyear      = @entryYear,
                    entrymethod    = @entryMethod,
                    intake         = @intake,
                    billingID      = @billingId,
                    stud_status    = @studStatus,
                    new_status     = @newStatus,
                    home_dist      = @district
                WHERE regno = @regno";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 30;
                    cmd.Parameters.AddWithValue("@firstName",   firstName);
                    cmd.Parameters.AddWithValue("@otherName",   otherName);
                    cmd.Parameters.AddWithValue("@gender",      gender);
                    cmd.Parameters.AddWithValue("@dob",         dob);
                    cmd.Parameters.AddWithValue("@nin",         nin);
                    cmd.Parameters.AddWithValue("@phone",       phone);
                    cmd.Parameters.AddWithValue("@email",       email);
                    cmd.Parameters.AddWithValue("@nationality", nationality);
                    cmd.Parameters.AddWithValue("@religion",    religion);
                    cmd.Parameters.AddWithValue("@session",     session);
                    cmd.Parameters.AddWithValue("@campus",      campusInt);
                    cmd.Parameters.AddWithValue("@entryYear",   entryYear);
                    cmd.Parameters.AddWithValue("@entryMethod", entryMethod);
                    cmd.Parameters.AddWithValue("@intake",      intake);
                    cmd.Parameters.AddWithValue("@billingId",   billingId);
                    cmd.Parameters.AddWithValue("@studStatus",  studStatus);
                    cmd.Parameters.AddWithValue("@newStatus",   newStatus);
                    cmd.Parameters.AddWithValue("@district",    district);
                    cmd.Parameters.AddWithValue("@regno",       regno);
                    int rows = cmd.ExecuteNonQuery();
                    if (rows == 0)
                    {
                        QeMsg("Student record not found. It may have been deleted.", "err");
                        return;
                    }
                }

                // --- Also update acad_applications if record exists ---
                try
                {
                    string entryNo = "";
                    using (MySqlCommand cmd2 = new MySqlCommand(
                        "SELECT entryno FROM acad_student WHERE regno=@r LIMIT 1", conn))
                    {
                        cmd2.Parameters.AddWithValue("@r", regno);
                        object val = cmd2.ExecuteScalar();
                        if (val != null && val != DBNull.Value)
                            entryNo = val.ToString();
                    }

                    if (!string.IsNullOrEmpty(entryNo) && entryNo != "-")
                    {
                        using (MySqlCommand cmd3 = new MySqlCommand(@"
                            UPDATE acad_applications SET
                                stud_name        = @name,
                                stud_sex         = @sex,
                                stud_nationality = @nationality,
                                stud_religion    = @religion,
                                stud_phone       = @phone,
                                stud_email       = @email,
                                stud_birthdate   = @dob,
                                stud_campus      = @campus,
                                stud_intake      = @intake,
                                national_id      = @nin,
                                home_district    = @district,
                                billingID        = @billingId
                            WHERE stud_entry_no = @eno", conn))
                        {
                            cmd3.CommandTimeout = 15;
                            cmd3.Parameters.AddWithValue("@name",        firstName + " " + otherName);
                            cmd3.Parameters.AddWithValue("@sex",         gender);
                            cmd3.Parameters.AddWithValue("@nationality", nationality);
                            cmd3.Parameters.AddWithValue("@religion",    religion);
                            cmd3.Parameters.AddWithValue("@phone",       phone);
                            cmd3.Parameters.AddWithValue("@email",       email);
                            cmd3.Parameters.AddWithValue("@dob",         dob);
                            cmd3.Parameters.AddWithValue("@campus",      campusVal ?? "01");
                            cmd3.Parameters.AddWithValue("@intake",      intake);
                            cmd3.Parameters.AddWithValue("@nin",         nin);
                            cmd3.Parameters.AddWithValue("@district",    district);
                            cmd3.Parameters.AddWithValue("@billingId",   billingId);
                            cmd3.Parameters.AddWithValue("@eno",         entryNo);
                            cmd3.ExecuteNonQuery();
                        }
                    }
                }
                catch { /* application sync failure should not block save */ }
            }
            
            QeMsg("Student updated successfully.", "ok");
            
            // Refresh the grid to show updated data
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            QeMsg("Error saving: " + ex.Message, "err");
        }
    }

    /// <summary>Show a message inside the quick-edit modal.</summary>
    private void QeMsg(string msg, string type)
    {
        string safeMsg = msg.Replace("'", "").Replace("\\", "").Replace("\r", "").Replace("\n", " ");
        ScriptManager.RegisterStartupScript(this, GetType(), "qeMsg",
            "qeShowMsg('" + safeMsg + "','" + type + "');showQuickEditModal();", true);
    }

    protected void btnPrintResults_Click(object sender, EventArgs e)
    {
        string regno = hfQeRegNo.Value;
        if (string.IsNullOrEmpty(regno))
            return;

        Session["regno"] = regno;
        Session["Report"] = "ResultStatement";

        string script = "window.open('../XtraReports/Default.aspx', 'PrintResults', 'width=1050,height=780,scrollbars=yes,resizable=yes');";
        ScriptManager.RegisterStartupScript(this, GetType(), "printResults", script, true);
    }
}
