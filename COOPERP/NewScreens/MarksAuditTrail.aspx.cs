using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Marks Audit Trail — shows who inserted, changed, or approved student marks.
/// 
/// Queries the REAL acad_activity_log table (campus_dynamics) which has columns:
///   user_id, page_function, par, comments, access_date, logid
///
/// Marks-related page_function values:
///   'Capture Results'              — OLD system (portal) capture by Dean
///   'Results Capture'              — NEW system (faculty) capture by Dean
///   'Faculty Exam Results Editor'  — Mark edits with old/new values + IP
///   'Results Approval Cancel'      — Approval cancellations
///   'Results Management'           — Various results operations
///   'Results Auto Pass'            — Automatic compensatory pass
/// </summary>
public partial class COOPERP_NewScreens_MarksAuditTrail : System.Web.UI.Page
{
    // Page functions that represent marks-related activity
    private static readonly string[] MarksActions = new string[]
    {
        "Capture Results",
        "Results Capture",
        "Faculty Exam Results Editor",
        "Results Approval Cancel",
        "Results Management",
        "Results Auto Pass",
        // Mark request admin actions (added for full accountability)
        "Mark Request Approve",
        "Mark Request Reject",
        "Mark Request Force Close",
        "Mark Request Reopen",
        "Mark Request Marks Update",
        "Mark Request Batch",
        "Marks Published to Results"
    };

    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // Build the IN clause for marks page_functions
    private string MarksInClause
    {
        get
        {
            return "('Capture Results','Results Capture','Faculty Exam Results Editor'," +
                   "'Results Approval Cancel','Results Management','Results Auto Pass'," +
                   "'Mark Request Approve','Mark Request Reject','Mark Request Force Close'," +
                   "'Mark Request Reopen','Mark Request Marks Update','Mark Request Batch'," +
                   "'Marks Published to Results')";
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            dtFrom.Date = DateTime.Today.AddDays(-30);
            dtTo.Date = DateTime.Today;

            LoadUserDropdown();
            LoadStats();
            LoadTopUsers();
            LoadBreakdown();
            LoadRecentActivity();
        }
        // Always bind so DevExpress grid callbacks (pagination, sorting, filtering) have data
        BindGrid();
    }

    // ────────────────────────────────────────────
    //  DATA LOADING
    // ────────────────────────────────────────────

    #region Load Dropdown

    private void LoadUserDropdown()
    {
        ddlUser.Items.Clear();
        ddlUser.Items.Add(new ListItem("All Users", ""));

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = "SELECT DISTINCT user_id FROM acad_activity_log " +
                             "WHERE page_function IN " + MarksInClause +
                             " ORDER BY user_id";
                using (var cmd = new MySqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string u = rdr["user_id"].ToString().Trim();
                        if (!string.IsNullOrEmpty(u))
                            ddlUser.Items.Add(new ListItem(u, u));
                    }
                }
            }
        }
        catch { }
    }

    #endregion

    #region Stats (KPI)

    private void LoadStats()
    {
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // ── Row 1: Total Actions ──
                int total = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause);
                litTotal.Text = total.ToString("N0");
                litHeroTotal.Text = total.ToString("N0");
                try { litHeroWindow.Text = Math.Max(0, (int)(dtTo.Date - dtFrom.Date).TotalDays).ToString("N0"); } catch { }

                // ── Row 2: Today + yesterday comparison ──
                int today = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND DATE(access_date) = CURDATE()");
                int yesterday = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND DATE(access_date) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)");
                litToday.Text = today.ToString("N0");
                litTodayTrend.Text = BuildTrend(today, yesterday, "yesterday");

                // ── Row 3: This Week + last week comparison ──
                int thisWeek = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND access_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
                int lastWeek = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND access_date >= DATE_SUB(CURDATE(), INTERVAL 14 DAY)" +
                    " AND access_date < DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
                litWeek.Text = thisWeek.ToString("N0");
                litWeekTrend.Text = BuildTrend(thisWeek, lastWeek, "prev week");

                // ── Row 4: This Month ──
                int thisMonth = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND access_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')");
                litMonth.Text = thisMonth.ToString("N0");

                // ── Row 5: Critical Actions (edits, cancels, force-closes, rejections) ──
                int critical = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " +
                    "('Faculty Exam Results Editor','Results Approval Cancel'," +
                    "'Mark Request Reject','Mark Request Force Close','Mark Request Marks Update'," +
                    "'Marks Published to Results')");
                int criticalToday = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " +
                    "('Faculty Exam Results Editor','Results Approval Cancel'," +
                    "'Mark Request Reject','Mark Request Force Close','Mark Request Marks Update'," +
                    "'Marks Published to Results')" +
                    " AND DATE(access_date) = CURDATE()");
                litCritical.Text = critical.ToString("N0");
                litCriticalToday.Text = criticalToday > 0
                    ? criticalToday.ToString("N0") + " today"
                    : "0 today";

                // ── Row 6: Unique Users ──
                int uniqueUsers = ScalarInt(conn,
                    "SELECT COUNT(DISTINCT user_id) FROM acad_activity_log WHERE page_function IN " + MarksInClause);
                int activeToday = ScalarInt(conn,
                    "SELECT COUNT(DISTINCT user_id) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND DATE(access_date) = CURDATE()");
                litUniqueUsers.Text = uniqueUsers.ToString("N0");
                litActiveToday.Text = activeToday.ToString("N0") + " active today";

                // ── Row 7: Most Active User (last 30 days) + their count ──
                string sqlTop = "SELECT user_id, COUNT(*) AS cnt FROM acad_activity_log " +
                    "WHERE page_function IN " + MarksInClause +
                    " AND access_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)" +
                    " GROUP BY user_id ORDER BY cnt DESC LIMIT 1";
                using (var cmd = new MySqlCommand(sqlTop, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        litTopUser.Text = HttpUtility.HtmlEncode(rdr["user_id"].ToString());
                        litTopUserCount.Text = Convert.ToInt32(rdr["cnt"]).ToString("N0") + " actions";
                    }
                    else
                    {
                        litTopUser.Text = "&mdash;";
                        litTopUserCount.Text = "no data";
                    }
                }

                // ── Avg per day (last 30 days) ──
                int last30 = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND access_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)");
                double avg = last30 / 30.0;
                litAvgDay.Text = avg.ToString("N1");
            }
        }
        catch { }
    }

    /// <summary>Build an HTML trend indicator (up/down arrow + percentage).</summary>
    private string BuildTrend(int current, int previous, string label)
    {
        if (previous == 0 && current == 0) return "<span class='mat-trend mat-trend--flat'>&mdash; vs " + label + "</span>";
        if (previous == 0) return "<span class='mat-trend mat-trend--up'>&#9650; new vs " + label + "</span>";
        double pct = ((double)(current - previous) / previous) * 100;
        if (Math.Abs(pct) < 1) return "<span class='mat-trend mat-trend--flat'>&mdash; vs " + label + "</span>";
        if (pct > 0)
            return string.Format("<span class='mat-trend mat-trend--up'>&#9650; {0}% vs {1}</span>", (int)Math.Round(pct), label);
        return string.Format("<span class='mat-trend mat-trend--down'>&#9660; {0}% vs {1}</span>", (int)Math.Round(Math.Abs(pct)), label);
    }

    #endregion

    #region Top Users (sidebar)

    private void LoadTopUsers()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("user_id", typeof(string));
        dt.Columns.Add("cnt", typeof(int));
        dt.Columns.Add("pct", typeof(int));

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT user_id, COUNT(*) AS cnt
                    FROM acad_activity_log
                    WHERE page_function IN " + MarksInClause + @"
                      AND access_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                    GROUP BY user_id ORDER BY cnt DESC LIMIT 10";

                using (var cmd = new MySqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    int maxCnt = 0;
                    while (rdr.Read())
                    {
                        int c = Convert.ToInt32(rdr["cnt"]);
                        if (c > maxCnt) maxCnt = c;
                        dt.Rows.Add(rdr["user_id"].ToString(), c, 0);
                    }
                    // Compute percentage bars relative to max
                    foreach (DataRow row in dt.Rows)
                    {
                        row["pct"] = maxCnt > 0 ? (int)Math.Round(Convert.ToDouble(row["cnt"]) / maxCnt * 100) : 0;
                    }
                }
            }
        }
        catch { }

        rptTopUsers.DataSource = dt;
        rptTopUsers.DataBind();
    }

    #endregion

    #region Action Breakdown (sidebar)

    private void LoadBreakdown()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("label", typeof(string));
        dt.Columns.Add("cnt", typeof(string));
        dt.Columns.Add("color", typeof(string));

        // Map: page_function → friendly label + color
        var mapping = new Dictionary<string, string[]>
        {
            { "Capture Results",              new[] { "Old System Capture",  "#1565c0" } },
            { "Results Capture",              new[] { "Faculty Capture",     "#0d47a1" } },
            { "Faculty Exam Results Editor",  new[] { "Marks Edit",          "#e65100" } },
            { "Results Approval Cancel",      new[] { "Approval Cancel",     "#b71c1c" } },
            { "Results Management",           new[] { "Results Mgmt",        "#6a1b9a" } },
            { "Results Auto Pass",            new[] { "Auto Pass",           "#2e7d32" } },
            { "Mark Request Approve",         new[] { "Req Approve",         "#1b5e20" } },
            { "Mark Request Reject",          new[] { "Req Reject",          "#b71c1c" } },
            { "Mark Request Force Close",     new[] { "Force Close",         "#7f0000" } },
            { "Mark Request Reopen",          new[] { "Req Reopen",          "#e65100" } },
            { "Mark Request Marks Update",    new[] { "Marks Update",        "#e65100" } },
            { "Mark Request Batch",           new[] { "Batch Action",        "#4a148c" } },
            { "Marks Published to Results",   new[] { "Marks Published",     "#004d40" } }
        };

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT page_function, COUNT(*) AS cnt
                    FROM acad_activity_log
                    WHERE page_function IN " + MarksInClause + @"
                    GROUP BY page_function ORDER BY cnt DESC";

                using (var cmd = new MySqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string pf = rdr["page_function"].ToString().Trim();
                        string[] info;
                        if (mapping.TryGetValue(pf, out info))
                            dt.Rows.Add(info[0], Convert.ToInt32(rdr["cnt"]).ToString("N0"), info[1]);
                        else
                            dt.Rows.Add(pf, Convert.ToInt32(rdr["cnt"]).ToString("N0"), "#78909c");
                    }
                }
            }
        }
        catch { }

        rptBreakdown.DataSource = dt;
        rptBreakdown.DataBind();
    }

    #endregion

    #region Recent Activity (sidebar)

    private void LoadRecentActivity()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("user_id", typeof(string));
        dt.Columns.Add("summary", typeof(string));
        dt.Columns.Add("time_ago", typeof(string));
        dt.Columns.Add("badge_text", typeof(string));
        dt.Columns.Add("badge_bg", typeof(string));
        dt.Columns.Add("badge_fg", typeof(string));

        // Map page_function → short badge
        var badgeMap = new Dictionary<string, string[]>
        {
            { "Capture Results",              new[] { "Capture",   "#e3f2fd", "#0d47a1" } },
            { "Results Capture",              new[] { "Capture",   "#e3f2fd", "#0d47a1" } },
            { "Faculty Exam Results Editor",  new[] { "Edit",      "#fff8e1", "#e65100" } },
            { "Results Approval Cancel",      new[] { "Cancel",    "#fef5f5", "#991b1b" } },
            { "Results Management",           new[] { "Mgmt",      "#f3e5f5", "#4a148c" } },
            { "Results Auto Pass",            new[] { "Auto",      "#e6f4ea", "#155724" } },
            { "Mark Request Approve",         new[] { "Approved",  "#e8f5e9", "#1b5e20" } },
            { "Mark Request Reject",          new[] { "Rejected",  "#fef5f5", "#991b1b" } },
            { "Mark Request Force Close",     new[] { "Forced",    "#fef5f5", "#7f0000" } },
            { "Mark Request Reopen",          new[] { "Reopen",    "#fff3e0", "#bf360c" } },
            { "Mark Request Marks Update",    new[] { "Mk Update", "#fff3e0", "#bf360c" } },
            { "Mark Request Batch",           new[] { "Batch",     "#f3e5f5", "#4a148c" } },
            { "Marks Published to Results",   new[] { "Published", "#e0f2f1", "#004d40" } }
        };

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"SELECT user_id, page_function, par, access_date
                    FROM acad_activity_log
                    WHERE page_function IN " + MarksInClause + @"
                    ORDER BY access_date DESC LIMIT 5";

                using (var cmd = new MySqlCommand(sql, conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string user = rdr["user_id"].ToString();
                        string pf = rdr["page_function"].ToString();
                        string par = rdr["par"] != DBNull.Value ? rdr["par"].ToString() : "";
                        DateTime dt2 = Convert.ToDateTime(rdr["access_date"]);

                        string summary = BuildShortSummary(pf, par);
                        string timeAgo = FormatTimeAgo(dt2);

                        string[] badge;
                        if (!badgeMap.TryGetValue(pf, out badge))
                            badge = new[] { "Other", "#f5f5f5", "#555" };

                        dt.Rows.Add(
                            HttpUtility.HtmlEncode(user),
                            HttpUtility.HtmlEncode(summary),
                            timeAgo,
                            badge[0], badge[1], badge[2]);
                    }
                }
            }
        }
        catch { }

        rptRecent.DataSource = dt;
        rptRecent.DataBind();
    }

    #endregion

    #region Grid Binding

    private void BindGrid()
    {
        DataTable dt = CreateEmptyTable();

        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                var conditions = new List<string>();
                conditions.Add("a.page_function IN " + MarksInClause);

                if (dtFrom.Date != DateTime.MinValue)
                    conditions.Add("a.access_date >= @dtFrom");
                if (dtTo.Date != DateTime.MinValue)
                    conditions.Add("a.access_date <= @dtTo");
                if (!string.IsNullOrEmpty(ddlAction.SelectedValue))
                    conditions.Add("a.page_function = @action");
                if (!string.IsNullOrEmpty(ddlUser.SelectedValue))
                    conditions.Add("a.user_id = @user");
                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    conditions.Add("(a.par LIKE @search OR s.firstname LIKE @search OR s.othername LIKE @search OR e.emp_name LIKE @search OR e.EMP_CODE LIKE @search OR e_fb.emp_name LIKE @search OR e_fb.EMP_CODE LIKE @search OR e_nm.emp_name LIKE @search OR e_nm.EMP_CODE LIKE @search)");

                string where = "WHERE " + string.Join(" AND ", conditions.ToArray());

                // Extract student reg number from par, join acad_student for name
                string regExpr = @"CASE
                        WHEN a.par LIKE 'Marks for %' THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(a.par, 'Marks for ', -1), ',', 1))
                        WHEN a.par LIKE '%Student: %' THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(a.par, 'Student: ', -1), ' ', 1))
                        ELSE '' END";

                // Extract IP address from par field
                string ipExpr = @"CASE
                        WHEN a.par LIKE '%IP Address: %' THEN TRIM(SUBSTRING_INDEX(a.par, 'IP Address: ', -1))
                        ELSE '' END";

                string sql = @"SELECT a.logid, a.user_id, a.page_function, a.par, a.access_date,
                    a.comments,
                    " + regExpr + @" AS student_regno,
                    CONCAT(IFNULL(s.firstname,''), ' ', IFNULL(s.othername,'')) AS student_name,
                    IFNULL(e.EMP_CODE, IFNULL(e_fb.EMP_CODE, e_nm.EMP_CODE)) AS teacher_code,
                    IFNULL(IFNULL(e.emp_name, IFNULL(e_fb.emp_name, e_nm.emp_name)), a.user_id) AS teacher_name,
                    IFNULL(e.emp_email, IFNULL(e_fb.emp_email, e_nm.emp_email)) AS teacher_email,
                    IFNULL(d.dept_name, IFNULL(d_fb.dept_name, IFNULL(d_nm.dept_name, ''))) AS teacher_dept,
                    IFNULL(e.EmpType, IFNULL(e_fb.EmpType, IFNULL(e_nm.EmpType, ''))) AS teacher_type,
                    " + ipExpr + @" AS ip_address
                    FROM acad_activity_log a
                    LEFT JOIN acad_student s ON s.regno = " + regExpr + @"
                    LEFT JOIN hrm_employee e ON e.usernames = a.user_id
                    LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                        SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
                    )
                    LEFT JOIN hrm_departments d ON d.ID = c.departmentID
                    LEFT JOIN my_aspnet_users mu ON e.empID IS NULL AND mu.name = a.user_id
                    LEFT JOIN my_aspnet_membership mm ON mu.id IS NOT NULL AND mm.userId = mu.id
                    LEFT JOIN hrm_employee e_fb ON e.empID IS NULL AND mm.Email IS NOT NULL AND mm.Email != '' AND e_fb.emp_email = mm.Email
                    LEFT JOIN hrm_emp_contracts c_fb ON e_fb.empID IS NOT NULL AND c_fb.empID = e_fb.empID AND c_fb.ID = (
                        SELECT MAX(c3.ID) FROM hrm_emp_contracts c3 WHERE c3.empID = e_fb.empID
                    )
                    LEFT JOIN hrm_departments d_fb ON c_fb.departmentID IS NOT NULL AND d_fb.ID = c_fb.departmentID
                    LEFT JOIN hrm_employee e_nm ON e.empID IS NULL AND e_fb.empID IS NULL
                        AND CHAR_LENGTH(a.user_id) >= 4
                        AND LOWER(e_nm.emp_name) LIKE CONCAT('%', LOWER(a.user_id), '%')
                        AND 1 = (SELECT COUNT(*) FROM hrm_employee enm2 WHERE LOWER(enm2.emp_name) LIKE CONCAT('%', LOWER(a.user_id), '%'))
                    LEFT JOIN hrm_emp_contracts c_nm ON e_nm.empID IS NOT NULL AND c_nm.empID = e_nm.empID AND c_nm.ID = (
                        SELECT MAX(c4.ID) FROM hrm_emp_contracts c4 WHERE c4.empID = e_nm.empID
                    )
                    LEFT JOIN hrm_departments d_nm ON c_nm.departmentID IS NOT NULL AND d_nm.ID = c_nm.departmentID
                    " + where + @"
                    ORDER BY a.access_date DESC
                    LIMIT 5000";

                using (var cmd = new MySqlCommand(sql, conn))
                {
                    if (dtFrom.Date != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@dtFrom", dtFrom.Date);
                    if (dtTo.Date != DateTime.MinValue)
                        cmd.Parameters.AddWithValue("@dtTo", dtTo.Date.AddDays(1));
                    if (!string.IsNullOrEmpty(ddlAction.SelectedValue))
                        cmd.Parameters.AddWithValue("@action", ddlAction.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlUser.SelectedValue))
                        cmd.Parameters.AddWithValue("@user", ddlUser.SelectedValue);
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        cmd.Parameters.AddWithValue("@search", "%" + txtSearch.Text.Trim() + "%");

                    using (var adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMsg("Error loading log: " + ex.Message, true);
        }

        litRowCount.Text = dt.Rows.Count.ToString("N0");
        gvLog.DataSource = dt;
        gvLog.DataBind();
    }

    private DataTable CreateEmptyTable()
    {
        var dt = new DataTable();
        dt.Columns.Add("logid", typeof(int));
        dt.Columns.Add("user_id", typeof(string));
        dt.Columns.Add("page_function", typeof(string));
        dt.Columns.Add("par", typeof(string));
        dt.Columns.Add("access_date", typeof(DateTime));
        dt.Columns.Add("comments", typeof(string));
        dt.Columns.Add("student_regno", typeof(string));
        dt.Columns.Add("student_name", typeof(string));
        dt.Columns.Add("teacher_code", typeof(string));
        dt.Columns.Add("teacher_name", typeof(string));
        dt.Columns.Add("teacher_email", typeof(string));
        dt.Columns.Add("teacher_dept", typeof(string));
        dt.Columns.Add("teacher_type", typeof(string));
        dt.Columns.Add("ip_address", typeof(string));
        return dt;
    }

    #endregion

    // ────────────────────────────────────────────
    //  HELPERS
    // ────────────────────────────────────────────

    #region Template Helpers

    /// <summary>Badge for action type column.</summary>
    protected string GetActionBadge(object pageFunction)
    {
        string pf = (pageFunction ?? "").ToString().Trim();

        if (pf == "Capture Results")
            return "<span class='mat-badge mat-badge--capture'>OLD CAPTURE</span>";
        if (pf == "Results Capture")
            return "<span class='mat-badge mat-badge--capture'>FACULTY CAPTURE</span>";
        if (pf == "Faculty Exam Results Editor")
            return "<span class='mat-badge mat-badge--edit'>MARKS EDIT</span>";
        if (pf == "Results Approval Cancel")
            return "<span class='mat-badge mat-badge--cancel'>CANCEL</span>";
        if (pf == "Results Auto Pass")
            return "<span class='mat-badge mat-badge--autopass'>AUTO PASS</span>";
        if (pf == "Results Management")
            return "<span class='mat-badge mat-badge--mgmt'>MANAGEMENT</span>";
        // Mark request admin actions
        if (pf == "Marks Published to Results")
            return "<span class='mat-badge mat-badge--published'>PUBLISHED</span>";
        if (pf == "Mark Request Approve")
            return "<span class='mat-badge mat-badge--approve'>APPROVED</span>";
        if (pf == "Mark Request Reject")
            return "<span class='mat-badge mat-badge--cancel'>REJECTED</span>";
        if (pf == "Mark Request Force Close")
            return "<span class='mat-badge mat-badge--cancel'>FORCED CLOSE</span>";
        if (pf == "Mark Request Reopen")
            return "<span class='mat-badge mat-badge--edit'>REOPENED</span>";
        if (pf == "Mark Request Marks Update")
            return "<span class='mat-badge mat-badge--edit'>MK UPDATE</span>";
        if (pf == "Mark Request Batch")
            return "<span class='mat-badge mat-badge--mgmt'>BATCH</span>";

        return "<span class='mat-badge mat-badge--mgmt'>" + HttpUtility.HtmlEncode(pf) + "</span>";
    }

    /// <summary>Severity dot: edits/cancels = critical, captures = normal.</summary>
    protected string GetSeverityDot(object pageFunction)
    {
        string pf = (pageFunction ?? "").ToString().Trim();

        if (pf == "Faculty Exam Results Editor" || pf == "Results Approval Cancel" ||
            pf == "Mark Request Force Close" || pf == "Mark Request Reject")
            return "<span class='mat-sev mat-sev--critical'><span class='mat-sev__dot'></span>Critical</span>";

        if (pf == "Results Auto Pass" || pf == "Marks Published to Results" ||
            pf == "Mark Request Approve" || pf == "Mark Request Marks Update")
            return "<span class='mat-sev mat-sev--high'><span class='mat-sev__dot'></span>High</span>";

        if (pf == "Mark Request Batch" || pf == "Mark Request Reopen")
            return "<span class='mat-sev mat-sev--high'><span class='mat-sev__dot'></span>Medium</span>";

        return "<span class='mat-sev mat-sev--normal'><span class='mat-sev__dot'></span>Normal</span>";
    }

    /// <summary>Format the student column: reg number + name.</summary>
    protected string FormatStudent(object regnoObj, object nameObj)
    {
        string regno = (regnoObj ?? "").ToString().Trim();
        string name = (nameObj ?? "").ToString().Trim();
        if (string.IsNullOrEmpty(regno)) return "<span style='color:#999;font-size:10px'>&mdash;</span>";
        string html = "<span style='font-weight:600;color:#1a237e;font-size:11px'>" + HttpUtility.HtmlEncode(regno) + "</span>";
        if (!string.IsNullOrEmpty(name) && name != " ")
            html += "<br/><span style='color:#666;font-size:10px'>" + HttpUtility.HtmlEncode(name.Trim()) + "</span>";
        return html;
    }
    /// <summary>Format the teacher/user column: name, code, department, type.</summary>
    protected string FormatTeacher(object userIdObj, object codeObj, object nameObj, object deptObj, object typeObj, object emailObj)
    {
        string userId = (userIdObj ?? "").ToString().Trim();
        string code = (codeObj ?? "").ToString().Trim();
        string name = (nameObj ?? "").ToString().Trim();
        string dept = (deptObj ?? "").ToString().Trim();
        string empType = (typeObj ?? "").ToString().Trim();
        string email = (emailObj ?? "").ToString().Trim();

        // If no employee record found, just show the user_id
        if (string.IsNullOrEmpty(code) && string.IsNullOrEmpty(name))
        {
            return "<span class='mat-user'>" + HttpUtility.HtmlEncode(userId) + "</span>";
        }

        string html = "<div style='line-height:1.3'>";
        html += "<div style='font-weight:700;color:#1a237e;font-size:11px'>" + HttpUtility.HtmlEncode(name) + "</div>";
        if (!string.IsNullOrEmpty(code))
            html += "<div style='font-size:10px;color:#555'><span style='font-weight:600;color:#174DA4'>" + HttpUtility.HtmlEncode(code) + "</span>";
        if (!string.IsNullOrEmpty(empType))
            html += " &bull; " + HttpUtility.HtmlEncode(empType);
        html += "</div>";
        if (!string.IsNullOrEmpty(dept))
            html += "<div style='font-size:9px;color:#888'>" + HttpUtility.HtmlEncode(dept) + "</div>";
        html += "</div>";
        return html;
    }

    /// <summary>Format the IP address column with icon.</summary>
    protected string FormatIP(object ipObj)
    {
        string ip = (ipObj ?? "").ToString().Trim();
        if (string.IsNullOrEmpty(ip))
            return "<span style='color:#ccc;font-size:10px'>&mdash;</span>";
        // Clean up: IP may trail with other text after a space
        if (ip.Contains(" ")) ip = ip.Substring(0, ip.IndexOf(' '));
        return "<span style='font-family:monospace;font-size:10px;color:#555;background:#f5f5f5;padding:1px 5px;border:1px solid #e0e0e0'>" + HttpUtility.HtmlEncode(ip) + "</span>";
    }
    /// <summary>Shorten verbose par details to a compact summary.</summary>
    protected string ShortenDetails(object parObj, object pfObj)
    {
        string par = (parObj ?? "").ToString().Trim();
        string pf = (pfObj ?? "").ToString().Trim();
        if (string.IsNullOrEmpty(par)) return "";

        try
        {
            // "Marks for MRU2024002034, Acad 2024/2025, Course: FAD1206D, Score: 57, Sem: 2, Serial No: 298538"
            if (par.StartsWith("Marks for "))
            {
                string course = ExtractBetween(par, "Course: ", ",") ?? ExtractAfter(par, "Course: ");
                string score = ExtractBetween(par, "Score: ", ",") ?? ExtractAfter(par, "Score: ");
                string acad = ExtractBetween(par, "Acad ", ",");
                string sem = ExtractBetween(par, "Sem: ", ",") ?? ExtractAfter(par, "Sem: ");
                var parts = new List<string>();
                if (!string.IsNullOrEmpty(course)) parts.Add(course.Trim());
                if (!string.IsNullOrEmpty(score)) parts.Add("Score: " + score.Trim());
                if (!string.IsNullOrEmpty(acad) && !string.IsNullOrEmpty(sem))
                    parts.Add(acad.Trim() + " S" + sem.Trim());
                return parts.Count > 0 ? HttpUtility.HtmlEncode(string.Join(" | ", parts.ToArray())) : HttpUtility.HtmlEncode(Truncate(par, 80));
            }

            // "Student: MRU... Course: BEF2101 Academic Year: 2025/2026 Semester: 1 Old CourseWork Mark: 0 New CourseWork: 35 ..."
            if (par.Contains("Student:") && par.Contains("Course:"))
            {
                string course = ExtractBetween(par, "Course: ", " ") ?? "";
                string acad = ExtractBetween(par, "Academic Year: ", " ") ?? "";
                string sem = ExtractBetween(par, "Semester: ", " ") ?? ExtractBetween(par, "Semester: ", "\n") ?? "";

                var changes = new List<string>();
                // CW
                string oldCW = ExtractBetween(par, "Old CourseWork Mark: ", " ");
                string newCW = ExtractBetween(par, "New CourseWork: ", " ") ?? ExtractBetween(par, "New CourseWork: ", "\n");
                if (oldCW != null && newCW != null && oldCW != newCW) changes.Add("CW:" + oldCW.Trim() + "->" + newCW.Trim());
                // Exam
                string oldExam = ExtractBetween(par, "Old Exam Mark: ", " ");
                string newExam = ExtractBetween(par, "New Exam Mark: ", " ") ?? ExtractBetween(par, "New Exam Mark: ", "\n");
                if (newExam != null && newExam.Contains(" ")) newExam = newExam.Substring(0, newExam.IndexOf(' '));
                if (oldExam != null && newExam != null && oldExam != newExam) changes.Add("Exam:" + oldExam.Trim() + "->" + newExam.Trim());
                // Score / Grade (new mark-request entries)
                string oldSc = ExtractBetween(par, "Old Score: ", " ");
                string newSc = ExtractBetween(par, "New Score: ", " ");
                if (oldSc != null && newSc != null && oldSc != newSc && oldSc != "-" && newSc != "-")
                    changes.Add("Score:" + oldSc.Trim() + "->" + newSc.Trim());
                string oldGr = ExtractBetween(par, "Old Grade: ", " ");
                string newGr = ExtractBetween(par, "New Grade: ", " ");
                if (oldGr != null && newGr != null && oldGr != newGr && oldGr != "-" && newGr != "-")
                    changes.Add("Grade:" + oldGr.Trim() + "->" + newGr.Trim());
                // Action
                string act = ExtractBetween(par, "Action: ", " ");

                var parts = new List<string>();
                if (!string.IsNullOrEmpty(course) && course != "-") parts.Add(course.Trim());
                if (changes.Count > 0) parts.Add(string.Join(", ", changes.ToArray()));
                else if (!string.IsNullOrEmpty(act) && act != "-") parts.Add(act.Trim());
                else parts.Add("no mark change");
                if (!string.IsNullOrEmpty(acad) && !string.IsNullOrEmpty(sem))
                    parts.Add(acad.Trim() + " S" + sem.Trim());
                return HttpUtility.HtmlEncode(string.Join(" | ", parts.ToArray()));
            }
        }
        catch { }

        return HttpUtility.HtmlEncode(Truncate(par, 80));
    }

    private string ExtractBetween(string src, string start, string end)
    {
        int i = src.IndexOf(start);
        if (i < 0) return null;
        i += start.Length;
        int j = src.IndexOf(end, i);
        if (j < 0) return null;
        return src.Substring(i, j - i);
    }

    private string ExtractAfter(string src, string start)
    {
        int i = src.IndexOf(start);
        if (i < 0) return null;
        return src.Substring(i + start.Length).Trim();
    }

    private string Truncate(string s, int max)
    {
        return s.Length <= max ? s : s.Substring(0, max) + "...";
    }

    /// <summary>Rank badge CSS class for top-users repeater.</summary>
    protected string GetRankClass(int index)
    {
        if (index == 0) return "mat-rank mat-rank--1";
        if (index == 1) return "mat-rank mat-rank--2";
        if (index == 2) return "mat-rank mat-rank--3";
        return "mat-rank mat-rank--other";
    }

    #endregion

    #region Utility

    private int ScalarInt(MySqlConnection conn, string sql)
    {
        using (var cmd = new MySqlCommand(sql, conn))
        {
            object val = cmd.ExecuteScalar();
            return (val != null && val != DBNull.Value) ? Convert.ToInt32(val) : 0;
        }
    }

    private string BuildShortSummary(string pageFunction, string par)
    {
        if (string.IsNullOrEmpty(par)) return pageFunction;

        try
        {
            // "Marks for MRU..., ..., Course: FAD1206D, Score: 57, ..."
            if (par.StartsWith("Marks for "))
            {
                string course = ExtractBetween(par, "Course: ", ",") ?? ExtractAfter(par, "Course: ");
                string score = ExtractBetween(par, "Score: ", ",") ?? ExtractAfter(par, "Score: ");
                var parts = new List<string>();
                if (!string.IsNullOrEmpty(course)) parts.Add(course.Trim());
                if (!string.IsNullOrEmpty(score)) parts.Add("Score: " + score.Trim());
                if (parts.Count > 0) return string.Join(" | ", parts.ToArray());
            }

            // "Student: MRU... Course: BEF2101 ... Old Exam Mark: 0 New Exam Mark: 55"
            if (par.Contains("Student:") && par.Contains("Course:"))
            {
                string course = ExtractBetween(par, "Course: ", " ") ?? "";
                var changes = new List<string>();
                string oldCW = ExtractBetween(par, "Old CourseWork Mark: ", " ");
                string newCW = ExtractBetween(par, "New CourseWork: ", " ") ?? ExtractAfter(par, "New CourseWork: ");
                if (oldCW != null && newCW != null && oldCW != newCW) changes.Add("CW:" + oldCW + "&rarr;" + newCW);
                string oldExam = ExtractBetween(par, "Old Exam Mark: ", " ");
                string newExam = ExtractAfter(par, "New Exam Mark: ");
                if (newExam != null && newExam.Contains(" ")) newExam = newExam.Substring(0, newExam.IndexOf(' '));
                if (oldExam != null && newExam != null && oldExam != newExam) changes.Add("Exam:" + oldExam + "&rarr;" + newExam);
                var p = new List<string>();
                if (!string.IsNullOrEmpty(course)) p.Add(course.Trim());
                if (changes.Count > 0) p.Add(string.Join(", ", changes.ToArray()));
                if (p.Count > 0) return string.Join(" | ", p.ToArray());
            }
        }
        catch { }

        if (par.Length > 60) par = par.Substring(0, 60) + "...";
        return par;
    }

    private string FormatTimeAgo(DateTime dt)
    {
        TimeSpan span = DateTime.Now - dt;
        if (span.TotalMinutes < 1) return "just now";
        if (span.TotalMinutes < 60) return (int)span.TotalMinutes + "m ago";
        if (span.TotalHours < 24) return (int)span.TotalHours + "h ago";
        if (span.TotalDays < 7) return (int)span.TotalDays + "d ago";
        return dt.ToString("dd-MMM");
    }

    private void ShowMsg(string text, bool isError)
    {
        pnlMsg.CssClass = isError ? "mat-alert mat-alert--error" : "mat-alert mat-alert--info";
        litMsg.Text = HttpUtility.HtmlEncode(text);
        pnlMsg.Visible = true;
    }

    #endregion

    // ────────────────────────────────────────────
    //  EVENT HANDLERS
    // ────────────────────────────────────────────

    protected void btnFilter_Click(object sender, EventArgs e)
    {
        LoadStats();
        LoadTopUsers();
        LoadBreakdown();
        LoadRecentActivity();
        BindGrid();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        dtFrom.Date = DateTime.Today.AddDays(-30);
        dtTo.Date = DateTime.Today;
        ddlAction.SelectedIndex = 0;
        ddlUser.SelectedIndex = 0;
        txtSearch.Text = "";
        pnlMsg.Visible = false;

        LoadStats();
        LoadTopUsers();
        LoadBreakdown();
        LoadRecentActivity();
        BindGrid();
    }

    protected void btnExportCsv_Click(object sender, EventArgs e)
    {
        try
        {
            string fileName = string.Format("MarksAuditTrail_{0}", DateTime.Now.ToString("yyyyMMdd_HHmm"));
            gvExporter.WriteXlsToResponse(fileName);
        }
        catch (Exception ex)
        {
            ShowMsg("Export error: " + ex.Message, true);
        }
    }
}
