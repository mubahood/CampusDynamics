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
        "Results Auto Pass"
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
                   "'Results Approval Cancel','Results Management','Results Auto Pass')";
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
            BindGrid();
        }
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

                // Total marks actions
                litTotal.Text = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause)
                    .ToString("N0");

                // Today
                litToday.Text = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND DATE(access_date) = CURDATE()")
                    .ToString("N0");

                // This week
                litWeek.Text = ScalarInt(conn,
                    "SELECT COUNT(*) FROM acad_activity_log WHERE page_function IN " + MarksInClause +
                    " AND access_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)")
                    .ToString("N0");

                // Unique users
                litUniqueUsers.Text = ScalarInt(conn,
                    "SELECT COUNT(DISTINCT user_id) FROM acad_activity_log WHERE page_function IN " + MarksInClause)
                    .ToString("N0");

                // Most active user (last 30 days)
                string sqlTop = "SELECT user_id FROM acad_activity_log " +
                    "WHERE page_function IN " + MarksInClause +
                    " AND access_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)" +
                    " GROUP BY user_id ORDER BY COUNT(*) DESC LIMIT 1";
                using (var cmd = new MySqlCommand(sqlTop, conn))
                {
                    object val = cmd.ExecuteScalar();
                    litTopUser.Text = (val != null && val != DBNull.Value)
                        ? HttpUtility.HtmlEncode(val.ToString())
                        : "—";
                }
            }
        }
        catch { }
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
            { "Results Auto Pass",            new[] { "Auto Pass",           "#2e7d32" } }
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

                        // Build short summary
                        string summary = BuildShortSummary(pf, par);
                        string timeAgo = FormatTimeAgo(dt2);

                        dt.Rows.Add(
                            HttpUtility.HtmlEncode(user),
                            HttpUtility.HtmlEncode(summary),
                            timeAgo);
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
                conditions.Add("page_function IN " + MarksInClause);

                if (dtFrom.Date != DateTime.MinValue)
                    conditions.Add("access_date >= @dtFrom");
                if (dtTo.Date != DateTime.MinValue)
                    conditions.Add("access_date <= @dtTo");
                if (!string.IsNullOrEmpty(ddlAction.SelectedValue))
                    conditions.Add("page_function = @action");
                if (!string.IsNullOrEmpty(ddlUser.SelectedValue))
                    conditions.Add("user_id = @user");
                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    conditions.Add("par LIKE @search");

                string where = "WHERE " + string.Join(" AND ", conditions.ToArray());

                // Extract IP from par if present (format: "... IP Address: x.x.x.x")
                string sql = @"SELECT logid, user_id, page_function, par, comments, access_date,
                    CASE
                        WHEN par LIKE '%IP Address:%' THEN TRIM(SUBSTRING_INDEX(par, 'IP Address:', -1))
                        ELSE ''
                    END AS ip_address
                    FROM acad_activity_log " + where + @"
                    ORDER BY access_date DESC
                    LIMIT 3000";

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
        dt.Columns.Add("comments", typeof(string));
        dt.Columns.Add("access_date", typeof(DateTime));
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

        return "<span class='mat-badge mat-badge--mgmt'>" + HttpUtility.HtmlEncode(pf) + "</span>";
    }

    /// <summary>Severity dot: edits/cancels = critical, captures = normal.</summary>
    protected string GetSeverityDot(object pageFunction)
    {
        string pf = (pageFunction ?? "").ToString().Trim();

        if (pf == "Faculty Exam Results Editor" || pf == "Results Approval Cancel")
            return "<span class='mat-sev mat-sev--critical'><span class='mat-sev__dot'></span>Critical</span>";
        if (pf == "Results Auto Pass")
            return "<span class='mat-sev mat-sev--high'><span class='mat-sev__dot'></span>High</span>";

        return "<span class='mat-sev mat-sev--normal'><span class='mat-sev__dot'></span>Normal</span>";
    }

    /// <summary>Rank badge CSS class for top-users repeater.</summary>
    protected string GetRankClass(int index)
    {
        if (index == 0) return "mat-top-rank mat-top-rank--1";
        if (index == 1) return "mat-top-rank mat-top-rank--2";
        if (index == 2) return "mat-top-rank mat-top-rank--3";
        return "mat-top-rank mat-top-rank--other";
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
        // Extract key info from the `par` column
        // Format A: "Course: BIT1101 Reg No: MRU2024... Mark: 75"
        // Format B: "Student: MRU... Course: BCE2103 ... Old Exam Mark: 0 New Exam Mark: 55"
        // Format C: "Marks for MRU..., Acad 2025/2026, Course: BEF2101, Score: 75, Sem: 1"

        if (string.IsNullOrEmpty(par)) return pageFunction;

        // Truncate for sidebar display
        if (par.Length > 80) par = par.Substring(0, 80) + "...";

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
        pnlMsg.CssClass = isError ? "mat-msg mat-msg--error" : "mat-msg mat-msg--info";
        pnlMsg.Attributes["style"] = "margin:14px 20px 0;";
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
