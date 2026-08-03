using System;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Collections.Generic;

public partial class COOPERP_NewScreens_NewDashboard : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    // Faculty code(s) the current user is Dean of (populated by LoadMyFaculty).
    private readonly System.Collections.Generic.List<string> _facultyCodes = new System.Collections.Generic.List<string>();
    // Department id(s) the current user is Head of (populated by LoadMyDepartment).
    private readonly System.Collections.Generic.List<int> _deptIds = new System.Collections.Generic.List<int>();

    private string AcctConn
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) ? cs.ConnectionString : ConnectionString;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;

        string username = Session["username"] as string;

        // Ensure the user's access set is loaded AND fresh — reload when null (never
        // loaded) or empty (loaded as "no access") so newly granted roles take effect
        // without a re-login.
        object slugObj0 = Session[RoleAccessService.SESSION_SLUGS];
        if (!string.IsNullOrEmpty(username))
        {
            if (slugObj0 == null || string.IsNullOrEmpty(slugObj0 as string))
                RoleAccessService.LoadUserAccess(username);
            else
                RoleAccessService.MaybeRefresh(username);   // refresh stale sessions so new grants show
        }

        string slugs = Session[RoleAccessService.SESSION_SLUGS] as string ?? "";
        bool isAdmin = slugs.Contains(RoleAccessService.ADMIN_WILDCARD);
        var parts = slugs.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        Func<string, bool> Has = prefix =>
            isAdmin || parts.Any(s => s.Trim().StartsWith(prefix, StringComparison.OrdinalIgnoreCase));

        bool secAcademics = Has("academics");
        bool secFees      = Has("fees");
        bool secAccounts  = Has("accounts");
        bool secHr        = Has("hr");
        bool secReq       = Has("requisitions");
        bool any = secAcademics || secFees || secAccounts || secHr || secReq;

        pnlAcademics.Visible = secAcademics;
        pnlFees.Visible      = secFees;
        pnlAccounts.Visible  = secAccounts;
        pnlHr.Visible        = secHr;
        pnlReq.Visible       = secReq;
        pnlNoAccess.Visible  = !any;

        LoadWelcome(username);
        try { LoadMyFaculty(username); } catch { pnlMyFaculty.Visible = false; }
        try { LoadMyDepartment(username); } catch { pnlMyDept.Visible = false; }

        // A Dean gets a FACULTY-scoped overview; a Head of Department gets a
        // DEPARTMENT-scoped overview — both INSTEAD of the university-wide academic
        // widgets (which stay for registrars/admins). Dynamic + reusable widget.
        if (_facultyCodes.Count > 0)
        {
            pnlAcademics.Visible = false;
            try { LoadScopedOverview(FacultyScopeSql(), "Faculty Overview",
                "Live statistics for the programmes, staff and students in your faculty",
                "Programmes in your faculty", "faculty"); }
            catch { pnlFacultyOverview.Visible = false; }
        }
        else if (_deptIds.Count > 0)
        {
            pnlAcademics.Visible = false;
            try { LoadScopedOverview(DeptScopeSql(), "Department Overview",
                "Live statistics for the programmes, staff and students in your department",
                "Programmes in your department", "department"); }
            catch { pnlFacultyOverview.Visible = false; }
        }

        // Load data only for the sections this user can see (relevance + perf).
        // Each loader is fully isolated so one failure can never blank the page.
        if (pnlAcademics.Visible) { try { LoadAcademicStats(); } catch { } }
        if (secFees)      { try { LoadFeesStats(); }     catch { } }
        if (secAccounts)  { try { LoadAccountsStats(); } catch { } }
        if (secHr)        { try { LoadHrStats(); }       catch { } }
        if (secReq)       { try { LoadReqStats(); }      catch { } }
    }

    // ── Welcome header ──────────────────────────────────────────────────────
    private void LoadWelcome(string username)
    {
        int h = DateTime.Now.Hour;
        string greet = h < 12 ? "Good morning" : (h < 17 ? "Good afternoon" : "Good evening");
        string name = Session["ScreenName"] as string;
        if (string.IsNullOrEmpty(name)) name = string.IsNullOrEmpty(username) ? "there" : username;
        string first = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries).FirstOrDefault() ?? name;

        litGreeting.Text   = HttpUtility.HtmlEncode(greet + ", " + first);
        litWelcomeSub.Text = DateTime.Now.ToString("dddd, dd MMMM yyyy");

        var chips = new StringBuilder();
        try
        {
            using (var conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    SELECT r.role_name, COALESCE(NULLIF(r.color_hex,''),'#64748b') AS color
                    FROM sys_user_roles ur
                    JOIN sys_roles r ON ur.role_id = r.id AND r.is_active = 1
                    WHERE ur.username = @u AND ur.is_active = 1
                      AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                    ORDER BY r.id", conn))
                {
                    cmd.Parameters.AddWithValue("@u", username ?? "");
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                            chips.AppendFormat(
                                "<span class=\"dash-rolechip\" style=\"background:{0}\"><span class=\"dash-rolechip__dot\"></span>{1}</span>",
                                HttpUtility.HtmlAttributeEncode(dr["color"].ToString()),
                                HttpUtility.HtmlEncode(dr["role_name"].ToString()));
                }
            }
        }
        catch { }
        if (chips.Length == 0)
            chips.Append("<span class=\"dash-rolechip dash-rolechip--none\">No role assigned</span>");
        litRoleChips.Text = chips.ToString();
    }

    // ── "Your Faculty" card for deans (matched via acad_faculty.faculty_dean) ──
    private static readonly System.Collections.Generic.HashSet<string> TITLES =
        new System.Collections.Generic.HashSet<string> { "DR","PROF","ASSOC","MR","MRS","MS","ENG","HON","REV","SIR","MADAM","PROFESSOR","DOCTOR","AG","DEAN" };

    private static System.Collections.Generic.HashSet<string> NameTokens(string s)
    {
        var set = new System.Collections.Generic.HashSet<string>();
        if (string.IsNullOrEmpty(s)) return set;
        foreach (var t in s.ToUpperInvariant().Split(new[] { ' ', '.', ',', '-', '/', '\t' }, StringSplitOptions.RemoveEmptyEntries))
        {
            string tok = t.Trim();
            if (tok.Length < 2 || TITLES.Contains(tok)) continue;
            set.Add(tok);
        }
        return set;
    }

    private void LoadMyFaculty(string username)
    {
        pnlMyFaculty.Visible = false;
        if (string.IsNullOrEmpty(username)) return;

        // Resolve the best name we have for this user.
        string myName = Session["ScreenName"] as string;
        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            if (string.IsNullOrEmpty(myName))
            {
                using (var cmd = new MySqlCommand(
                    "SELECT emp_name FROM hrm_employee WHERE UPPER(TRIM(usernames))=UPPER(TRIM(@u)) LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@u", username);
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) myName = r.ToString();
                }
            }
            if (string.IsNullOrEmpty(myName)) myName = username;

            var myTokens = NameTokens(myName);
            if (myTokens.Count < 2) return;   // not enough to match reliably → show nothing (no false positives)

            var cards = new StringBuilder();
            int matched = 0;
            using (var cmd = new MySqlCommand(
                "SELECT faculty_code, faculty_name, abbrev, faculty_dean FROM acad_faculty WHERE faculty_code<>'00'", conn))
            using (var dr = cmd.ExecuteReader())
            {
                var rows = new System.Collections.Generic.List<string[]>();
                while (dr.Read())
                    rows.Add(new[] { dr["faculty_code"].ToString(), dr["faculty_name"].ToString(),
                                     dr["abbrev"].ToString(), dr["faculty_dean"].ToString() });
                dr.Close();

                foreach (var row in rows)
                {
                    var deanTokens = NameTokens(row[3]);
                    int common = 0;
                    foreach (var tk in myTokens) if (deanTokens.Contains(tk)) common++;
                    if (common < 2) continue;   // need at least two shared name parts

                    matched++;
                    string code = row[0], name = row[1], abbr = row[2];
                    if (!_facultyCodes.Contains(code)) _facultyCodes.Add(code);
                    string codeEsc = code.Replace("'", "''");
                    double progs = Agg(ConnectionString, "SELECT COUNT(*) FROM acad_programme WHERE faculty_code='" + codeEsc + "'");
                    double studs = Agg(ConnectionString, "SELECT COUNT(*) FROM acad_student s JOIN acad_programme p ON p.progcode=s.progid WHERE p.faculty_code='" + codeEsc + "'");

                    cards.Append("<div class=\"myfac-card\">");
                    cards.Append("<div class=\"myfac-card__top\">");
                    if (!string.IsNullOrEmpty(abbr) && abbr != "-")
                        cards.Append("<span class=\"myfac-card__abbr\">").Append(HE(abbr)).Append("</span>");
                    cards.Append("<span class=\"myfac-card__role\">You are the Dean</span></div>");
                    cards.Append("<div class=\"myfac-card__name\">").Append(HE(name)).Append("</div>");
                    cards.Append("<div class=\"myfac-card__stats\">");
                    cards.Append("<div><b>").Append(N(progs)).Append("</b><span>Programmes</span></div>");
                    cards.Append("<div><b>").Append(N(studs)).Append("</b><span>Students</span></div>");
                    cards.Append("</div>");
                    cards.Append("<a class=\"myfac-card__link\" href=\"NewFacultyProgrammes.aspx\">View programmes &rarr;</a>");
                    cards.Append("</div>");
                }
            }

            if (matched > 0)
            {
                litMyFaculty.Text = cards.ToString();
                pnlMyFaculty.Visible = true;
            }
        }
    }

    /* ═══════════════════════════════════════════════════════════════════════
       REUSABLE DASHBOARD WIDGETS  (scope-parameterised → role-agnostic)
       ───────────────────────────────────────────────────────────────────────
       Each widget below takes a `scope` = a SQL predicate on acad_programme `p`
       (e.g. "p.faculty_code IN ('01')" for a Dean, or "1=1" for a Registrar/
       Admin university-wide view). Pass a different scope to reuse for any role:

         WIDGET                     SOURCE                         CURRENT USERS
         ----------------------     ---------------------------    ------------------
         Programmes count           acad_programme                 Dean (faculty)
         Students / Active count    acad_student⋈acad_programme    Dean (faculty)
         Lecturers count            acad_teaching_allocation       Dean (faculty)
         Results pass-rate          acad_results⋈acad_programme    Dean (faculty)
         Gender split (doughnut)    acad_student⋈acad_programme    Dean (faculty)
         Students-per-programme(bar)acad_programme⋈acad_student    Dean (faculty)
         Enrolment trend (bar)      acad_registration⋈student⋈prog Dean (faculty)
         Programmes table           acad_programme⋈acad_student    Dean (faculty)

       To extend to e.g. Registrar (university-wide) or HoD (department),
       call LoadFacultyOverview-style logic with scope="1=1" or a dept filter.
       ═══════════════════════════════════════════════════════════════════════ */
    // ── "Your Department" card(s) for HODs (heads via hrm_departments.dept_headID) ──
    private void LoadMyDepartment(string username)
    {
        pnlMyDept.Visible = false;
        if (string.IsNullOrEmpty(username)) return;

        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();

            int empId = 0;
            using (var cmd = new MySqlCommand(
                "SELECT empID FROM hrm_employee WHERE UPPER(TRIM(usernames))=UPPER(TRIM(@u)) LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@u", username);
                object r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) empId = Convert.ToInt32(r);
            }
            if (empId <= 0) return;

            var rows = new System.Collections.Generic.List<string[]>();
            using (var cmd = new MySqlCommand(
                "SELECT d.ID, IFNULL(d.dept_name,'') dn, IFNULL(d.faculty_code,'') fc, IFNULL(f.faculty_name,'') fn " +
                "FROM hrm_departments d LEFT JOIN acad_faculty f ON f.faculty_code=d.faculty_code " +
                "WHERE d.dept_headID=@e ORDER BY d.dept_name", conn))
            {
                cmd.Parameters.AddWithValue("@e", empId);
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                        rows.Add(new[] { dr["ID"].ToString(), dr["dn"].ToString(), dr["fc"].ToString(), dr["fn"].ToString() });
            }

            var cards = new StringBuilder();
            foreach (var row in rows)
            {
                int id = 0; int.TryParse(row[0], out id);
                if (id <= 0) continue;
                if (!_deptIds.Contains(id)) _deptIds.Add(id);

                double progs = Agg(ConnectionString, "SELECT COUNT(*) FROM acad_programme WHERE department_id=" + id);
                double studs = Agg(ConnectionString, "SELECT COUNT(*) FROM acad_student s JOIN acad_programme p ON p.progcode=s.progid WHERE p.department_id=" + id);

                cards.Append("<div class=\"myfac-card myfac-card--dept\">");
                cards.Append("<div class=\"myfac-card__top\">");
                if (!string.IsNullOrEmpty(row[3]))
                    cards.Append("<span class=\"myfac-card__abbr\">").Append(HE(row[3])).Append("</span>");
                cards.Append("<span class=\"myfac-card__role\">You are the Head</span></div>");
                cards.Append("<div class=\"myfac-card__name\">").Append(HE(row[1])).Append("</div>");
                cards.Append("<div class=\"myfac-card__stats\">");
                cards.Append("<div><b>").Append(N(progs)).Append("</b><span>Programmes</span></div>");
                cards.Append("<div><b>").Append(N(studs)).Append("</b><span>Students</span></div>");
                cards.Append("</div>");
                cards.Append("<a class=\"myfac-card__link\" href=\"NewFacultyProgrammes.aspx\">View programmes &rarr;</a>");
                cards.Append("</div>");
            }

            if (_deptIds.Count > 0)
            {
                litMyDept.Text = cards.ToString();
                pnlMyDept.Visible = true;
            }
        }
    }

    private string DeptScopeSql()
    {
        if (_deptIds.Count == 0) return "";
        var sb = new StringBuilder();
        for (int i = 0; i < _deptIds.Count; i++) { if (i > 0) sb.Append(","); sb.Append(_deptIds[i]); }
        return "p.department_id IN (" + sb + ")";
    }

    private string FacultyScopeSql()
    {
        if (_facultyCodes.Count == 0) return "";
        var inb = new StringBuilder();
        for (int i = 0; i < _facultyCodes.Count; i++)
        {
            if (i > 0) inb.Append(",");
            inb.Append("'").Append(_facultyCodes[i].Replace("'", "''")).Append("'");
        }
        return "p.faculty_code IN (" + inb + ")";
    }

    // Scope-parameterised overview, reused by Dean (faculty scope) and HOD (department
    // scope). `scope` is a SQL predicate on acad_programme `p`; labels set the headings.
    private void LoadScopedOverview(string scope, string title, string hint, string tableTitle, string emptyNoun)
    {
        if (string.IsNullOrEmpty(scope)) { pnlFacultyOverview.Visible = false; return; }
        litFoTitle.Text      = HE(title);
        litFoHint.Text       = HE(hint);
        litFoTableTitle.Text = HE(tableTitle);
        string cs = ConnectionString;
        string cy = "";
        try { cy = AcademicYearHelper.GetCurrentAcademicYear(); } catch { }

        // KPIs
        lblFoProgrammes.Text = N(Agg(cs, "SELECT COUNT(*) FROM acad_programme p WHERE " + scope));
        lblFoStudents.Text   = N(Agg(cs, "SELECT COUNT(*) FROM acad_student s JOIN acad_programme p ON p.progcode=s.progid WHERE " + scope));
        lblFoLecturers.Text  = N(Agg(cs, "SELECT COUNT(DISTINCT ta.staffCode) FROM acad_teaching_allocation ta JOIN acad_programme p ON p.progcode=ta.progcode WHERE " + scope));

        // Registered students. NOTE: acad_student.stud_status is uniformly 'ACTIVE'
        // (not maintained), so "active" via status is meaningless (it equals the
        // total). Instead show the students actually registered in the most recent
        // *substantial* registration cohort — i.e. the academic year with the most
        // registrations in scope. This avoids a just-opened year (e.g. June, when the
        // new year has only a handful of early registrations) understating the figure.
        string regYear = ScalarStr(cs,
            "SELECT r.acad_year FROM acad_registration r " +
            "JOIN acad_student s ON s.regno=r.regno " +
            "JOIN acad_programme p ON p.progcode=s.progid WHERE " + scope +
            " AND r.acad_year REGEXP '^[0-9]{4}/[0-9]{4}$' " +
            "GROUP BY r.acad_year ORDER BY COUNT(DISTINCT r.regno) DESC LIMIT 1");
        double registered = string.IsNullOrEmpty(regYear) ? double.NaN : Agg(cs, RegisteredCountSql(scope, regYear));
        lblFoActive.Text    = N(registered);
        lblFoActiveSub.Text = string.IsNullOrEmpty(regYear) ? "current year" : ("in " + regYear);

        // Results pass rate. The calendar "current" academic year may have almost no
        // results yet (e.g. a year that just opened), which yields a misleading 100%
        // from a 3-result sample. Use the latest academic year that holds a
        // meaningful body of results within this scope.
        string resYear = ScalarStr(cs,
            "SELECT r.acad FROM acad_results r JOIN acad_programme p ON p.progcode=r.progid WHERE " + scope +
            " AND r.acad REGEXP '^[0-9]{4}/[0-9]{4}$' " +
            "GROUP BY r.acad HAVING COUNT(*) >= 20 ORDER BY CAST(LEFT(r.acad,4) AS UNSIGNED) DESC LIMIT 1");
        if (string.IsNullOrEmpty(resYear)) resYear = cy;

        // graded = results that carry a grade; pass = grade present and not failing.
        string gradedPred = " AND TRIM(IFNULL(r.grade,'')) <> '' ";
        double total = Agg(cs, "SELECT COUNT(*) FROM acad_results r JOIN acad_programme p ON p.progcode=r.progid WHERE " + scope + " AND r.acad=" + SqlQ(resYear) + gradedPred);
        double pass  = Agg(cs, "SELECT COUNT(*) FROM acad_results r JOIN acad_programme p ON p.progcode=r.progid WHERE " + scope + " AND r.acad=" + SqlQ(resYear) + gradedPred + " AND UPPER(TRIM(r.grade)) NOT IN ('F','E','0.0')");
        if (double.IsNaN(total) || total <= 0 || double.IsNaN(pass))
        {
            lblFoPassRate.Text = "—";
            lblFoPassSub.Text  = "No results recorded for " + (string.IsNullOrEmpty(resYear) ? "this year" : resYear);
        }
        else
        {
            lblFoPassRate.Text = Math.Round(pass / total * 100).ToString("0") + "%";
            lblFoPassSub.Text  = ((long)pass).ToString("N0") + " of " + ((long)total).ToString("N0") + " passed &middot; " + resYear;
        }

        // Chart data
        hfFoGender.Value     = JsonPairs(cs, "SELECT IFNULL(NULLIF(TRIM(s.gender),''),'Unknown') k, COUNT(*) v FROM acad_student s JOIN acad_programme p ON p.progcode=s.progid WHERE " + scope + " GROUP BY k", false);
        hfFoProgrammes.Value = JsonPairs(cs, "SELECT COALESCE(NULLIF(p.abbrev,''),p.progcode) k, COUNT(s.regno) v FROM acad_programme p LEFT JOIN acad_student s ON s.progid=p.progcode WHERE " + scope + " GROUP BY p.progcode, k ORDER BY v DESC LIMIT 8", false);
        hfFoEnroll.Value     = JsonPairs(cs, "SELECT r.acad_year k, COUNT(*) v FROM acad_registration r JOIN acad_student s ON s.regno=r.regno JOIN acad_programme p ON p.progcode=s.progid WHERE " + scope + " GROUP BY r.acad_year ORDER BY r.acad_year DESC LIMIT 6", true);

        // Programmes table
        var tb = new StringBuilder();
        int n = 0;
        try
        {
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT p.progcode, IFNULL(p.progname,'') pn, IFNULL(p.levelCode,'') lvl, " +
                    " COALESCE(NULLIF(p.is_fully_set,''),'No') cfg, COUNT(s.regno) studs " +
                    "FROM acad_programme p LEFT JOIN acad_student s ON s.progid=p.progcode WHERE " + scope + " " +
                    "GROUP BY p.progcode, pn, lvl, cfg ORDER BY studs DESC", conn))
                {
                    cmd.CommandTimeout = 20;
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                        {
                            n++;
                            bool set = string.Equals(dr["cfg"].ToString(), "Yes", StringComparison.OrdinalIgnoreCase);
                            tb.Append("<tr>")
                              .Append("<td><span class=\"fo-code\">").Append(HE(dr["progcode"].ToString())).Append("</span></td>")
                              .Append("<td>").Append(HE(dr["pn"].ToString())).Append("</td>")
                              .Append("<td style=\"text-align:right\"><strong>").Append(N(Convert.ToDouble(dr["studs"]))).Append("</strong></td>")
                              .Append("<td>").Append(set
                                    ? "<span class=\"fo-badge fo-badge--ok\">Configured</span>"
                                    : "<span class=\"fo-badge fo-badge--warn\">Pending setup</span>").Append("</td>")
                              .Append("</tr>");
                        }
                }
            }
        }
        catch (Exception ex)
        {
            tb.Append("<tr><td colspan=\"4\" style=\"color:#dc2626;padding:12px\">").Append(HE("Error: " + ex.Message)).Append("</td></tr>");
        }
        if (n == 0) tb.Append("<tr><td colspan=\"4\" class=\"fo-empty\">No programmes found for this " + HE(emptyNoun) + ".</td></tr>");
        litFoProgrammes.Text = tb.ToString();

        pnlFacultyOverview.Visible = true;
    }

    private static string SqlQ(string s) { return "'" + (s ?? "").Replace("'", "''") + "'"; }

    // Returns a JSON array [{"k":label,"v":number},…] for a 2-column query; [] on error.
    private string JsonPairs(string cs, string sql, bool reverse)
    {
        var items = new System.Collections.Generic.List<string>();
        try
        {
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 20;
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read())
                        {
                            string k = dr[0] == DBNull.Value ? "" : dr[0].ToString();
                            long v = dr[1] == DBNull.Value ? 0 : Convert.ToInt64(dr[1]);
                            items.Add("{\"k\":" + JsStr(k) + ",\"v\":" + v + "}");
                        }
                }
            }
        }
        catch { return "[]"; }
        if (reverse) items.Reverse();
        return "[" + string.Join(",", items) + "]";
    }

    // Distinct students with a registration in the given academic year, within scope.
    private string RegisteredCountSql(string scope, string year)
    {
        return "SELECT COUNT(DISTINCT r.regno) FROM acad_registration r " +
               "JOIN acad_student s ON s.regno=r.regno " +
               "JOIN acad_programme p ON p.progcode=s.progid WHERE " + scope +
               " AND r.acad_year=" + SqlQ(year);
    }

    // Safe scalar-string fetch ("" on error/empty).
    private string ScalarStr(string cs, string sql)
    {
        try
        {
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 20;
                    var v = cmd.ExecuteScalar();
                    return (v == null || v == DBNull.Value) ? "" : v.ToString();
                }
            }
        }
        catch { return ""; }
    }

    // ── Safe aggregate + formatters (one failed widget never breaks the page) ─
    // Dashboard summaries are institution-wide counts that change slowly; caching them
    // for a few minutes turns ~35 sequential DB round-trips (each a new connection) into a
    // single instant lookup on all but the first load within the window. Only successful
    // values are cached — an error (NaN) is never cached, so it retries next request.
    private const int DashCacheSeconds = 300;
    private static object CacheGet(string key) { return System.Web.HttpRuntime.Cache[key]; }
    private static void CachePut(string key, object val)
    {
        System.Web.HttpRuntime.Cache.Insert(key, val, null,
            DateTime.UtcNow.AddSeconds(DashCacheSeconds),
            System.Web.Caching.Cache.NoSlidingExpiration);
    }

    // Cached multi-column scalar row — lets several counts/sums from ONE table be fetched
    // in a single scan (one connection, one round-trip) instead of N separate Agg() calls.
    private double[] AggMulti(string cs, string sql, int cols)
    {
        string key = "nd_aggm:" + (cs ?? "").GetHashCode() + ":" + sql;
        object hit = CacheGet(key);
        if (hit is double[]) return (double[])hit;
        var res = new double[cols];
        try
        {
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 20;
                    using (var r = cmd.ExecuteReader())
                        if (r.Read())
                            for (int i = 0; i < cols; i++)
                                res[i] = r.IsDBNull(i) ? 0 : Convert.ToDouble(r.GetValue(i));
                }
            }
            CachePut(key, res);
            return res;
        }
        catch { for (int i = 0; i < cols; i++) res[i] = double.NaN; return res; }
    }

    private double Agg(string cs, string sql)
    {
        string key = "nd_agg:" + (cs ?? "").GetHashCode() + ":" + sql;
        object hit = CacheGet(key);
        if (hit is double) return (double)hit;
        try
        {
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 20;
                    var v = cmd.ExecuteScalar();
                    double d = (v == null || v == DBNull.Value) ? 0 : Convert.ToDouble(v);
                    CachePut(key, d);
                    return d;
                }
            }
        }
        catch { return double.NaN; }
    }
    private static string HE(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
    // JSON string literal (with surrounding double quotes), safely escaped.
    private static string JsStr(string s) { return HttpUtility.JavaScriptStringEncode(s ?? "", true); }
    private static string N(double d) { return double.IsNaN(d) ? "—" : ((long)Math.Round(d)).ToString("N0"); }
    private static string M(double d) { return double.IsNaN(d) ? "—" : "UGX " + ((long)Math.Round(d)).ToString("N0"); }

    // ── Fees & Bursary (campus_dynamics_accounts.fin_studentfeestracking) ────
    private void LoadFeesStats()
    {
        string cs = AcctConn;
        lblFeesMonthName.Text = DateTime.Now.ToString("MMMM yyyy");
        // One scan of the current year's rows yields all three figures (was 3 separate scans/connections).
        double[] f = AggMulti(cs,
            "SELECT " +
            "COALESCE(SUM(CASE WHEN trans_type='Payment' AND MONTH(trans_date)=MONTH(CURDATE()) THEN amount END),0), " +
            "COALESCE(SUM(CASE WHEN trans_type='Payment' THEN amount END),0), " +
            "COALESCE(SUM(CASE WHEN trans_type='Bill'    THEN amount END),0) " +
            "FROM fin_studentfeestracking WHERE YEAR(trans_date)=YEAR(CURDATE())", 3);
        double month = f[0], yc = f[1], yb = f[2];
        lblFeesMonth.Text         = M(month);
        lblFeesYearCollected.Text = M(yc);
        lblFeesYearBilled.Text    = M(yb);
        lblFeesOutstanding.Text   = (double.IsNaN(yb) || double.IsNaN(yc)) ? "—" : M(yb - yc);
    }

    // ── Finance & Accounts ───────────────────────────────────────────────────
    private void LoadAccountsStats()
    {
        string cs = AcctConn;
        // Both fin_ledger figures from a single scan (was 2 separate scans/connections).
        double[] a = AggMulti(cs,
            "SELECT COUNT(CASE WHEN YEAR(transactionDate)=YEAR(CURDATE()) AND MONTH(transactionDate)=MONTH(CURDATE()) THEN 1 END), " +
            "COUNT(DISTINCT accountcode) FROM fin_ledger", 2);
        lblAcctTxMonth.Text  = N(a[0]);
        lblAcctAccounts.Text = N(a[1]);
        lblAcctPendingFin.Text = N(Agg(ConnectionString,
            "SELECT COUNT(*) FROM sys_requisitions WHERE is_deleted=0 AND finance_action='PENDING' AND status NOT IN ('DRAFT','COMPLETED','REJECTED','CANCELLED')"));
    }

    // ── Requisitions (campus_dynamics.sys_requisitions) ──────────────────────
    private void LoadReqStats()
    {
        string cs = ConnectionString;
        const string activeWhere = "is_deleted=0 AND status NOT IN ('DRAFT','COMPLETED','REJECTED','CANCELLED','PAID','CLOSED')";
        lblReqPending.Text = N(Agg(cs, "SELECT COUNT(*) FROM sys_requisitions WHERE " + activeWhere));
        lblReqValue.Text   = M(Agg(cs, "SELECT COALESCE(SUM(total_amount),0) FROM sys_requisitions WHERE " + activeWhere));
        lblReqTotal.Text   = N(Agg(cs, "SELECT COUNT(*) FROM sys_requisitions WHERE is_deleted=0"));
    }

    // ── Human Resource (campus_dynamics.hrm_*) ───────────────────────────────
    private void LoadHrStats()
    {
        string cs = ConnectionString;
        lblHrEmployees.Text    = N(Agg(cs, "SELECT COUNT(*) FROM hrm_employee"));
        lblHrContracts.Text    = N(Agg(cs, "SELECT COUNT(*) FROM hrm_emp_contracts"));
        lblHrPendingLeave.Text = N(Agg(cs, "SELECT COUNT(*) FROM hrm_leave_applications WHERE status IN ('SUBMITTED','HOD_APPROVED','HR_APPROVED')"));
    }

    // Academic year logic centralised in AcademicYearHelper

    // Snapshot of the whole Academic section — cached so repeat loads run ZERO queries.
    private class AcademicSnapshot
    {
        public string currentYear;
        public long totalStudents, maleStudents, femaleStudents;
        public long currentEnrollments, totalReg, apps, results;
        public long faculties, programmes, specs, courses;
        public long progCourses, coreCourses, electiveCourses, defaultSpecs;
        public long progsConfigured, specsConfigured, progsWithCourses;
        public DataTable enrollments;
        public string enrollmentJson;
    }

    private static string N0(long v) { return String.Format("{0:N0}", v); }

    private void LoadAcademicStats()
    {
        var snap = CacheGet("nd_academic") as AcademicSnapshot;
        if (snap == null)
        {
            snap = ComputeAcademicStats();
            if (snap != null) CachePut("nd_academic", snap);
        }
        if (snap != null) ApplyAcademic(snap);
    }

    // Consolidated: ~20 separate counts collapsed into ~10 single-scan queries.
    private AcademicSnapshot ComputeAcademicStats()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                var s = new AcademicSnapshot();
                s.currentYear = AcademicYearHelper.GetCurrentAcademicYear();

                // Students: total + male + female in one scan
                using (var cmd = new MySqlCommand("SELECT COUNT(*), COALESCE(SUM(gender='Male'),0), COALESCE(SUM(gender='Female'),0) FROM acad_student", conn))
                using (var r = cmd.ExecuteReader())
                    if (r.Read()) { s.totalStudents = Convert.ToInt64(r.GetValue(0)); s.maleStudents = Convert.ToInt64(r.GetValue(1)); s.femaleStudents = Convert.ToInt64(r.GetValue(2)); }

                // Registrations: total + current-year in one scan
                using (var cmd = new MySqlCommand("SELECT COUNT(*), COALESCE(SUM(acad_year=@year),0) FROM acad_registration", conn))
                {
                    cmd.Parameters.AddWithValue("@year", s.currentYear);
                    using (var r = cmd.ExecuteReader())
                        if (r.Read()) { s.totalReg = Convert.ToInt64(r.GetValue(0)); s.currentEnrollments = Convert.ToInt64(r.GetValue(1)); }
                }

                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_applications", conn))
                    s.apps = Convert.ToInt64(cmd.ExecuteScalar());
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_results", conn))
                    s.results = Convert.ToInt64(cmd.ExecuteScalar());
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_faculty", conn))
                    s.faculties = Convert.ToInt64(cmd.ExecuteScalar());
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course", conn))
                    s.courses = Convert.ToInt64(cmd.ExecuteScalar());

                // Programmes: total + configured in one scan
                using (var cmd = new MySqlCommand("SELECT COUNT(*), COALESCE(SUM(is_fully_set='Yes'),0) FROM acad_programme", conn))
                using (var r = cmd.ExecuteReader())
                    if (r.Read()) { s.programmes = Convert.ToInt64(r.GetValue(0)); s.progsConfigured = Convert.ToInt64(r.GetValue(1)); }

                // Specialisations: total + configured + default in one scan
                using (var cmd = new MySqlCommand("SELECT COUNT(*), COALESCE(SUM(is_fully_set='Yes'),0), COALESCE(SUM(spec='Default'),0) FROM acad_specialisation", conn))
                using (var r = cmd.ExecuteReader())
                    if (r.Read()) { s.specs = Convert.ToInt64(r.GetValue(0)); s.specsConfigured = Convert.ToInt64(r.GetValue(1)); s.defaultSpecs = Convert.ToInt64(r.GetValue(2)); }

                // Programme-courses: total + core + elective + programmes-with-courses in one scan
                using (var cmd = new MySqlCommand("SELECT COUNT(*), COALESCE(SUM(course_type='CORE' OR course_type IS NULL),0), COALESCE(SUM(course_type='ELECTIVE'),0), COUNT(DISTINCT progcode) FROM acad_programmecourses", conn))
                using (var r = cmd.ExecuteReader())
                    if (r.Read()) { s.progCourses = Convert.ToInt64(r.GetValue(0)); s.coreCourses = Convert.ToInt64(r.GetValue(1)); s.electiveCourses = Convert.ToInt64(r.GetValue(2)); s.progsWithCourses = Convert.ToInt64(r.GetValue(3)); }

                // Enrollment by year (table + chart)
                s.enrollments = new DataTable();
                using (var cmd = new MySqlCommand("SELECT acad_year, COUNT(*) as count FROM acad_registration GROUP BY acad_year ORDER BY acad_year DESC LIMIT 5", conn))
                using (var adapter = new MySqlDataAdapter(cmd))
                    adapter.Fill(s.enrollments);

                var chartData = new List<object>();
                for (int i = s.enrollments.Rows.Count - 1; i >= 0; i--)
                {
                    DataRow row = s.enrollments.Rows[i];
                    chartData.Add(new { year = row["acad_year"].ToString(), count = Convert.ToInt32(row["count"]) });
                }
                s.enrollmentJson = new JavaScriptSerializer().Serialize(chartData);
                return s;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Dashboard Error: " + ex.Message);
            return null;
        }
    }

    private void ApplyAcademic(AcademicSnapshot s)
    {
        lblCurrentYear.Text = s.currentYear;

        lblTotalStudents.Text  = N0(s.totalStudents);
        lblMaleStudents.Text   = N0(s.maleStudents);   hfMaleCount.Value   = s.maleStudents.ToString();
        lblFemaleStudents.Text = N0(s.femaleStudents); hfFemaleCount.Value = s.femaleStudents.ToString();
        if (s.femaleStudents > 0)
            lblGenderRatio.Text = Math.Round((double)s.maleStudents / s.femaleStudents, 2).ToString("0.00") + ":1";

        lblCurrentEnrollments.Text = N0(s.currentEnrollments);
        lblTotalRegistrations.Text = N0(s.totalReg);
        lblApplications.Text       = N0(s.apps);
        lblExamResults.Text        = N0(s.results);

        lblFaculties.Text            = s.faculties.ToString();
        lblProgrammes.Text           = s.programmes.ToString();
        lblSpecialisations.Text      = s.specs.ToString();
        lblCourses.Text              = s.courses.ToString();
        lblTotalProgrammeCourses.Text = s.progCourses.ToString();
        lblCoreCourses.Text          = s.coreCourses.ToString();
        lblElectiveCourses.Text      = s.electiveCourses.ToString();
        lblDefaultSpecs.Text         = s.defaultSpecs.ToString();

        int progPercent = s.programmes > 0 ? (int)(s.progsConfigured * 100 / s.programmes) : 0;
        lblProgConfigured.Text = progPercent.ToString();
        progBar.Style["width"] = progPercent + "%";
        lblUnConfiguredProgs.Text = (s.programmes - s.progsConfigured).ToString();

        int specPercent = s.specs > 0 ? (int)(s.specsConfigured * 100 / s.specs) : 0;
        lblSpecConfigured.Text = specPercent.ToString();
        specBar.Style["width"] = specPercent + "%";
        lblUnConfiguredSpecs.Text = (s.specs - s.specsConfigured).ToString();

        int coursesPercent = s.programmes > 0 ? (int)(s.progsWithCourses * 100 / s.programmes) : 0;
        lblProgWithCourses.Text = coursesPercent.ToString();
        coursesBar.Style["width"] = coursesPercent + "%";

        rptEnrollmentsByYear.DataSource = s.enrollments;
        rptEnrollmentsByYear.DataBind();
        hfEnrollmentData.Value = s.enrollmentJson;
    }
}
