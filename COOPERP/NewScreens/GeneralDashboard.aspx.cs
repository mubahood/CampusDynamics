using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

// =====================================================================
//  GENERAL DASHBOARD  — institution-wide, dynamically-filterable overview.
//  Shown to ALL eadmin users. Phase 1: Students / Onboarding /
//  Registrations / Fees + the Applied->Admitted->Registered funnel.
//
//  Every metric is backed by a query verified against the live DB.
//  Data lives in TWO databases (both on the same MySQL server):
//    - academic/student/onboarding -> campus_dynamics   (vacConnectionString)
//    - finance/payments            -> campus_dynamics_accounts (accountsConnectionString)
//  Fees queries run on the accounts connection and cross-reference
//  campus_dynamics.* by fully-qualified names when a student-scope
//  filter is active. PERF: regno/progcode/faculty_code joins use plain '='
//  (NOT TRIM) — MySQL '=' ignores trailing CHAR padding, so plain '=' is
//  index-backed AND equivalent; TRIM() defeats the index and made the board
//  take ~8s. Only leftover TRIM()s are cheap IFNULL empty-checks.
// =====================================================================
public partial class COOPERP_NewScreens_GeneralDashboard : Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    protected void Page_Load(object sender, EventArgs e) { /* AJAX-powered — no server binding */ }

    private static string AcadConn() { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    private static string AcctConn() { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }

    // GL entries that are not real fee movements — excluded from collections.
    private const string GL_NOISE = "'OPENING_BALANCE','JOURNAL_VOUCHERS','CB_OPERATIONS','REVERSAL'";

    // ------------------------------------------------------------------
    //  Filter model
    // ------------------------------------------------------------------
    private class Filters
    {
        public string dateFrom;   public string dateTo;
        public string acadYear;   public string semester;
        public string faculty;    public string programme;
        public string intake;     public string session;
        public string gender;     public string status;
        public string campus;
    }

    private static string S(Dictionary<string, object> d, string k)
    {
        object v;
        if (d != null && d.TryGetValue(k, out v) && v != null) return Convert.ToString(v).Trim();
        return "";
    }

    private static Filters ParseFilters(string filtersJson)
    {
        Filters f = new Filters();
        f.dateFrom = ""; f.dateTo = ""; f.acadYear = ""; f.semester = ""; f.faculty = "";
        f.programme = ""; f.intake = ""; f.session = ""; f.gender = ""; f.status = ""; f.campus = "";
        if (string.IsNullOrEmpty(filtersJson)) return f;
        try
        {
            Dictionary<string, object> d = Json.Deserialize<Dictionary<string, object>>(filtersJson);
            f.dateFrom = S(d, "dateFrom"); f.dateTo = S(d, "dateTo");
            f.acadYear = S(d, "acadYear"); f.semester = S(d, "semester");
            f.faculty = S(d, "faculty"); f.programme = S(d, "programme");
            f.intake = S(d, "intake"); f.session = S(d, "session");
            f.gender = S(d, "gender"); f.status = S(d, "status"); f.campus = S(d, "campus");
        }
        catch { }
        return f;
    }

    private static bool HasStudentScope(Filters f)
    {
        return f.faculty != "" || f.programme != "" || f.intake != "" || f.session != ""
            || f.gender != "" || f.status != "" || f.campus != "";
    }

    // Student-attribute predicate against fixed aliases s (acad_student) + p (acad_programme).
    private static string StudentScope(Filters f, Dictionary<string, object> p)
    {
        StringBuilder sb = new StringBuilder();
        if (f.faculty != "") { sb.Append(" AND p.faculty_code=@faculty"); p["@faculty"] = f.faculty; }
        if (f.programme != "") { sb.Append(" AND s.progid=@programme"); p["@programme"] = f.programme; }
        if (f.intake != "") { sb.Append(" AND s.intake=@intake"); p["@intake"] = f.intake; }
        if (f.session != "") { sb.Append(" AND s.studsesion=@session"); p["@session"] = f.session; }
        if (f.gender != "") { sb.Append(" AND s.gender=@gender"); p["@gender"] = f.gender; }
        if (f.status != "") { sb.Append(" AND s.new_status=@status"); p["@status"] = f.status; }
        if (f.campus != "") { sb.Append(" AND s.studCampus=@campus"); p["@campus"] = f.campus; }
        return sb.ToString();
    }

    private static void AddParams(MySqlCommand cmd, Dictionary<string, object> p)
    {
        if (p == null) return;
        foreach (KeyValuePair<string, object> kv in p)
            if (!cmd.Parameters.Contains(kv.Key)) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
    }

    // Resolve the effective date window (defaults to the last 12 months).
    private static void DateWindow(Filters f, out string start, out string endExclusive)
    {
        DateTime dEnd, dStart;
        if (!DateTime.TryParse(f.dateTo, out dEnd)) dEnd = DateTime.Today;
        if (!DateTime.TryParse(f.dateFrom, out dStart)) dStart = dEnd.AddMonths(-12);
        if (dStart > dEnd) { DateTime t = dStart; dStart = dEnd; dEnd = t; }
        start = dStart.ToString("yyyy-MM-dd");
        endExclusive = dEnd.AddDays(1).ToString("yyyy-MM-dd");
    }

    // ------------------------------------------------------------------
    //  Small read helpers
    // ------------------------------------------------------------------
    private static long L(MySqlDataReader r, int i) { return r.IsDBNull(i) ? 0L : Convert.ToInt64(r.GetValue(i)); }
    private static double D(MySqlDataReader r, int i) { return r.IsDBNull(i) ? 0.0 : Convert.ToDouble(r.GetValue(i)); }
    private static string Str(MySqlDataReader r, int i) { return r.IsDBNull(i) ? "" : Convert.ToString(r.GetValue(i)); }

    // ==================================================================
    //  1) FILTER OPTIONS  (real values from the live DB)
    // ==================================================================
    [WebMethod(EnableSession = true)]
    public static string GetFilterOptions()
    {
        try
        {
            List<object> years = new List<object>();
            List<object> faculties = new List<object>();
            List<object> programmes = new List<object>();
            List<object> intakes = new List<object>();
            List<object> campuses = new List<object>();
            string currentYear = "";

            using (MySqlConnection conn = new MySqlConnection(AcadConn()))
            {
                conn.Open();

                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT DISTINCT acad_year FROM acad_registration " +
                    "WHERE acad_year IS NOT NULL AND TRIM(acad_year)<>'' ORDER BY acad_year DESC", conn))
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) { string v = Str(r, 0); if (v != "") years.Add(new { value = v, text = v }); }

                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT TRIM(faculty_code) fc, faculty_name FROM acad_faculty " +
                    "WHERE TRIM(faculty_code)<>'00' ORDER BY faculty_name", conn))
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) { string v = Str(r, 0); if (v != "") faculties.Add(new { value = v, text = Str(r, 1) }); }

                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT TRIM(progcode) pc, COALESCE(progname,progcode) pn FROM acad_programme " +
                    "WHERE TRIM(progcode)<>'' ORDER BY pn", conn))
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) { string v = Str(r, 0); if (v != "") programmes.Add(new { value = v, text = Str(r, 1) }); }

                // Only the clean, real intake months (data has numeric junk).
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT intake, COUNT(*) n FROM acad_student " +
                    "WHERE intake IN ('AUGUST','JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER') " +
                    "GROUP BY intake HAVING n>0 ORDER BY n DESC", conn))
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) { string v = Str(r, 0); if (v != "") intakes.Add(new { value = v, text = v }); }

                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT ID, campus_name FROM acad_campuses WHERE ID<>0 ORDER BY campus_name", conn))
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) campuses.Add(new { value = Str(r, 0), text = Str(r, 1) });

                // Default academic year = the busiest term (operationally "current").
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT acad_year FROM acad_registration WHERE TRIM(IFNULL(acad_year,''))<>'' " +
                    "GROUP BY acad_year ORDER BY COUNT(*) DESC LIMIT 1", conn))
                {
                    object o = cmd.ExecuteScalar();
                    if (o != null && o != DBNull.Value) currentYear = Convert.ToString(o);
                }
            }

            object sessions = new object[] {
                new { value = "DAY", text = "Day" },
                new { value = "INSERVICE", text = "In-Service" },
                new { value = "WEEKEND", text = "Weekend" },
                new { value = "EVENING", text = "Evening" }
            };
            object genders = new object[] { new { value = "MALE", text = "Male" }, new { value = "FEMALE", text = "Female" } };
            object statuses = new object[] {
                new { value = "ACTIVE", text = "Active" },
                new { value = "ADMITTED", text = "Admitted" },
                new { value = "ALUMNI", text = "Alumni" }
            };

            return Json.Serialize(new
            {
                success = true,
                currentYear = currentYear,
                years = years,
                faculties = faculties,
                programmes = programmes,
                intakes = intakes,
                sessions = sessions,
                genders = genders,
                statuses = statuses,
                campuses = campuses
            });
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load filters: " + ex.Message });
        }
    }

    // ==================================================================
    //  2) AGGREGATE DASHBOARD  (one round-trip drives the whole board)
    // ==================================================================
    [WebMethod(EnableSession = true)]
    public static string GetDashboard(string filtersJson)
    {
        try
        {
            Filters f = ParseFilters(filtersJson);

            object students, registrations, onboarding, funnel, fees;

            using (MySqlConnection conn = new MySqlConnection(AcadConn()))
            {
                conn.Open();
                students = BuildStudents(conn, f);
                registrations = BuildRegistrations(conn, f);
                onboarding = BuildOnboarding(conn, f);
                funnel = BuildFunnel(conn, f);
            }
            using (MySqlConnection acct = new MySqlConnection(AcctConn()))
            {
                acct.Open();
                fees = BuildFees(acct, f);
            }

            return Json.Serialize(new
            {
                success = true,
                generatedAt = DateTime.Now.ToString("ddd, dd MMM yyyy HH:mm"),
                students = students,
                registrations = registrations,
                onboarding = onboarding,
                funnel = funnel,
                fees = fees
            });
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load dashboard: " + ex.Message });
        }
    }

    // ------------------------------------------------------------------
    //  SECTION A — Student Body (snapshot; ignores date range)
    // ------------------------------------------------------------------
    private static object BuildStudents(MySqlConnection conn, Filters f)
    {
        try
        {
            Dictionary<string, object> p = new Dictionary<string, object>();
            string scope = StudentScope(f, p);
            string from = " FROM acad_student s LEFT JOIN acad_programme p ON p.progcode=s.progid WHERE 1=1" + scope;

            long total = 0, active = 0, admitted = 0, alumni = 0, male = 0, female = 0, progs = 0, facs = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) t, " +
                " SUM(s.new_status='ACTIVE') a, SUM(s.new_status='ADMITTED') ad, SUM(s.new_status='ALUMNI') al, " +
                " SUM(s.gender='MALE') m, SUM(s.gender='FEMALE') fm, " +
                " COUNT(DISTINCT s.progid) pc, COUNT(DISTINCT p.faculty_code) fc" + from, conn))
            {
                AddParams(cmd, p);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    if (r.Read())
                    {
                        total = L(r, 0); active = L(r, 1); admitted = L(r, 2); alumni = L(r, 3);
                        male = L(r, 4); female = L(r, 5); progs = L(r, 6); facs = L(r, 7);
                    }
            }

            List<object> byFaculty = GroupQuery(conn, p,
                "SELECT COALESCE(f.faculty_name,'Unmapped') nm, COUNT(*) n " +
                "FROM acad_student s LEFT JOIN acad_programme p ON p.progcode=s.progid " +
                "LEFT JOIN acad_faculty f ON f.faculty_code=p.faculty_code WHERE 1=1" + scope +
                " GROUP BY nm ORDER BY n DESC");

            List<object> byGender = GroupQuery(conn, p,
                "SELECT s.gender nm, COUNT(*) n FROM acad_student s " +
                "LEFT JOIN acad_programme p ON p.progcode=s.progid WHERE s.gender IN ('MALE','FEMALE')" + scope +
                " GROUP BY s.gender");

            List<object> bySession = GroupQuery(conn, p,
                "SELECT UPPER(TRIM(s.studsesion)) nm, COUNT(*) n FROM acad_student s " +
                "LEFT JOIN acad_programme p ON p.progcode=s.progid WHERE TRIM(IFNULL(s.studsesion,''))<>''" + scope +
                " GROUP BY nm ORDER BY n DESC LIMIT 6");

            int yr = DateTime.Now.Year;
            List<object> byEntryYear = GroupQuery(conn, p,
                "SELECT CAST(s.entryyear AS CHAR) nm, COUNT(*) n FROM acad_student s " +
                "LEFT JOIN acad_programme p ON p.progcode=s.progid " +
                "WHERE s.entryyear BETWEEN " + (yr - 7) + " AND " + (yr + 1) + scope +
                " GROUP BY s.entryyear ORDER BY s.entryyear");

            List<object> topProgrammes = GroupQuery(conn, p,
                "SELECT COALESCE(p.progname, s.progid) nm, COUNT(*) n FROM acad_student s " +
                "LEFT JOIN acad_programme p ON p.progcode=s.progid WHERE TRIM(IFNULL(s.progid,''))<>''" + scope +
                " GROUP BY nm ORDER BY n DESC LIMIT 10");

            return new
            {
                total = total, active = active, admitted = admitted, alumni = alumni,
                male = male, female = female, programmes = progs, faculties = facs,
                byFaculty = byFaculty, byGender = byGender, bySession = bySession,
                byEntryYear = byEntryYear, topProgrammes = topProgrammes
            };
        }
        catch (Exception ex) { return new { error = ex.Message }; }
    }

    // ------------------------------------------------------------------
    //  SECTION C — Registrations (acad_year + semester + student scope)
    // ------------------------------------------------------------------
    private static object BuildRegistrations(MySqlConnection conn, Filters f)
    {
        try
        {
            // Base scope (student attributes) shared by every registration query.
            Dictionary<string, object> pBase = new Dictionary<string, object>();
            string sScope = StudentScope(f, pBase);
            string join = " FROM acad_registration r " +
                          "JOIN acad_student s ON s.regno=r.regno " +
                          "LEFT JOIN acad_programme p ON p.progcode=s.progid ";

            // Term predicate (year + semester) — used by the KPI + status + faculty widgets.
            Dictionary<string, object> pTerm = new Dictionary<string, object>(pBase);
            string term = sScope;
            if (f.acadYear != "") { term += " AND r.acad_year=@acadYear"; pTerm["@acadYear"] = f.acadYear; }
            if (f.semester != "") { term += " AND CAST(r.semester AS CHAR)=@semester"; pTerm["@semester"] = f.semester; }

            long total = 0, registered = 0, unregistered = 0, cleared = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) t, " +
                " SUM(r.regstatus IN ('REGISTERED','LATE REGISTERED')) reg, " +
                " SUM(r.regstatus='UNREGISTERED') unreg, " +
                " SUM(r.regstatus='CLEARED') clr" + join + "WHERE 1=1" + term, conn))
            {
                AddParams(cmd, pTerm);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    if (r.Read()) { total = L(r, 0); registered = L(r, 1); unregistered = L(r, 2); cleared = L(r, 3); }
            }

            List<object> byStatus = GroupQuery(conn, pTerm,
                "SELECT r.regstatus nm, COUNT(*) n" + join + "WHERE TRIM(IFNULL(r.regstatus,''))<>''" + term +
                " GROUP BY r.regstatus ORDER BY n DESC");

            // Registered vs Unregistered by faculty for the selected term (stacked bar source).
            List<object> byFaculty = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COALESCE(fa.abbrev,'—') nm, " +
                " SUM(r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')) reg, " +
                " SUM(r.regstatus='UNREGISTERED') unreg" + join +
                "LEFT JOIN acad_faculty fa ON fa.faculty_code=p.faculty_code WHERE 1=1" + term +
                " GROUP BY nm ORDER BY COUNT(*) DESC LIMIT 8", conn))
            {
                AddParams(cmd, pTerm);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) byFaculty.Add(new { name = Str(r, 0), registered = L(r, 1), unregistered = L(r, 2) });
            }

            // Trend across acad_year x semester — ignores the acad_year/semester filter so the
            // multi-year trend stays visible; still respects student-attribute scope.
            List<object> byYearSem = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT r.acad_year ay, CAST(r.semester AS CHAR) sem, COUNT(*) n" + join +
                "WHERE TRIM(IFNULL(r.acad_year,''))<>''" + sScope +
                " GROUP BY r.acad_year, r.semester " +
                " ORDER BY r.acad_year DESC, r.semester LIMIT 30", conn))
            {
                AddParams(cmd, pBase);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) byYearSem.Add(new { year = Str(r, 0), semester = Str(r, 1), count = L(r, 2) });
            }

            return new
            {
                total = total, registered = registered, unregistered = unregistered, cleared = cleared,
                byStatus = byStatus, byFaculty = byFaculty, byYearSem = byYearSem
            };
        }
        catch (Exception ex) { return new { error = ex.Message }; }
    }

    // ------------------------------------------------------------------
    //  SECTION B — Onboarding / Applications
    // ------------------------------------------------------------------
    private static object BuildOnboarding(MySqlConnection conn, Filters f)
    {
        try
        {
            Dictionary<string, object> p = new Dictionary<string, object>();
            string w = " WHERE 1=1";
            if (f.intake != "") { w += " AND a.stud_intake=@intake"; p["@intake"] = f.intake; }

            long total = 0, admitted = 0, draft = 0, submitted = 0, registered = 0, rejected = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) t, SUM(a.app_status='ADMITTED') adm, SUM(a.app_status='DRAFT') dr, " +
                " SUM(a.app_status='SUBMITTED') sb, SUM(a.app_status='REGISTERED') rg, SUM(a.app_status='REJECTED') rj " +
                "FROM acad_applications a" + w, conn))
            {
                AddParams(cmd, p);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    if (r.Read()) { total = L(r, 0); admitted = L(r, 1); draft = L(r, 2); submitted = L(r, 3); registered = L(r, 4); rejected = L(r, 5); }
            }

            List<object> byStatus = GroupQuery(conn, p,
                "SELECT a.app_status nm, COUNT(*) n FROM acad_applications a" + w +
                " AND TRIM(IFNULL(a.app_status,''))<>'' GROUP BY a.app_status ORDER BY n DESC");

            // Online applications over time — timestamps only exist for the 2026+ cohort.
            string start, endEx; DateWindow(f, out start, out endEx);
            List<object> overTime = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT DATE_FORMAT(a.app_created_at,'%Y-%m-%d') d, COUNT(*) n FROM acad_applications a " +
                "WHERE a.app_created_at IS NOT NULL AND a.app_created_at>=@start AND a.app_created_at<@endEx " +
                (f.intake != "" ? "AND a.stud_intake=@intake " : "") +
                "GROUP BY d ORDER BY d", conn))
            {
                cmd.Parameters.AddWithValue("@start", start);
                cmd.Parameters.AddWithValue("@endEx", endEx);
                if (f.intake != "") cmd.Parameters.AddWithValue("@intake", f.intake);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) overTime.Add(new { label = Str(r, 0), count = L(r, 1) });
            }

            // First-choice programme demand.
            List<object> demand = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COALESCE(pr.progname, c.prog_id) nm, COUNT(*) n " +
                "FROM acad_applicant_choices c " +
                "LEFT JOIN acad_programme pr ON pr.progcode=c.prog_id " +
                "WHERE c.choice=1 AND TRIM(IFNULL(c.prog_id,''))<>'' GROUP BY nm ORDER BY n DESC LIMIT 10", conn))
            using (MySqlDataReader r = cmd.ExecuteReader())
                while (r.Read()) demand.Add(new { name = Str(r, 0), count = L(r, 1) });

            long admittedChoices = 0, totalChoices = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT SUM(adm_status=1) adm, COUNT(*) t FROM acad_applicant_choices", conn))
            using (MySqlDataReader r = cmd.ExecuteReader())
                if (r.Read()) { admittedChoices = L(r, 0); totalChoices = L(r, 1); }

            double admissionRate = totalChoices > 0 ? (admittedChoices * 100.0 / totalChoices) : 0;

            return new
            {
                total = total, admitted = admitted, draft = draft, submitted = submitted,
                registered = registered, rejected = rejected, admissionRate = admissionRate,
                byStatus = byStatus, overTime = overTime, demand = demand
            };
        }
        catch (Exception ex) { return new { error = ex.Message }; }
    }

    // ------------------------------------------------------------------
    //  Applied -> Admitted -> Active -> Registered -> Cleared funnel
    //  (institution snapshot; mixes lifetime onboarding with current-term
    //   registration — labelled as such in the UI).
    // ------------------------------------------------------------------
    private static object BuildFunnel(MySqlConnection conn, Filters f)
    {
        try
        {
            Dictionary<string, object> p = new Dictionary<string, object>();
            string sScope = StudentScope(f, p);

            long applied = 0, admitted = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) t, SUM(app_status IN ('ADMITTED','REGISTERED')) adm FROM acad_applications a" +
                (f.intake != "" ? " WHERE a.stud_intake=@intake" : ""), conn))
            {
                if (f.intake != "") cmd.Parameters.AddWithValue("@intake", f.intake);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    if (r.Read()) { applied = L(r, 0); admitted = L(r, 1); }
            }

            long activeAccounts = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM acad_student s LEFT JOIN acad_programme p ON p.progcode=s.progid " +
                "WHERE s.new_status='ACTIVE'" + sScope, conn))
            {
                AddParams(cmd, p);
                object o = cmd.ExecuteScalar(); activeAccounts = o == null || o == DBNull.Value ? 0 : Convert.ToInt64(o);
            }

            // Registered / cleared distinct students in the selected (or current) academic year.
            Dictionary<string, object> pr = new Dictionary<string, object>(p);
            string yearPred;
            if (f.acadYear != "") { yearPred = " AND r.acad_year=@ay"; pr["@ay"] = f.acadYear; }
            else yearPred = " AND r.acad_year=(SELECT acad_year FROM acad_registration " +
                            "WHERE TRIM(IFNULL(acad_year,''))<>'' GROUP BY acad_year ORDER BY COUNT(*) DESC LIMIT 1)";

            long registered = 0, cleared = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(DISTINCT CASE WHEN r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED') THEN r.regno END) reg, " +
                " COUNT(DISTINCT CASE WHEN r.regstatus='CLEARED' THEN r.regno END) clr " +
                "FROM acad_registration r JOIN acad_student s ON s.regno=r.regno " +
                "LEFT JOIN acad_programme p ON p.progcode=s.progid WHERE 1=1" + sScope + yearPred, conn))
            {
                AddParams(cmd, pr);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    if (r.Read()) { registered = L(r, 0); cleared = L(r, 1); }
            }

            return new
            {
                applied = applied, admitted = admitted, active = activeAccounts,
                registered = registered, cleared = cleared
            };
        }
        catch (Exception ex) { return new { error = ex.Message }; }
    }

    // ------------------------------------------------------------------
    //  SECTION D — Fees & Collections (accounts DB; fin_ledger single-source)
    // ------------------------------------------------------------------
    private static object BuildFees(MySqlConnection acct, Filters f)
    {
        try
        {
            string start, endEx; DateWindow(f, out start, out endEx);
            bool scoped = HasStudentScope(f);

            Dictionary<string, object> sp = new Dictionary<string, object>();
            string sScope = scoped ? StudentScope(f, sp) : "";
            string ledgerJoin = scoped
                ? " JOIN campus_dynamics.acad_student s ON s.regno=l.accountcode " +
                  "LEFT JOIN campus_dynamics.acad_programme p ON p.progcode=s.progid "
                : " ";
            string baseWhere = "WHERE l.account_type='Student' AND l.transactionDate>=@start AND l.transactionDate<@endEx " +
                               "AND (l.source_system IS NULL OR l.source_system NOT IN (" + GL_NOISE + "))" + sScope;

            long collected = 0, billed = 0, numPayments = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT " +
                " SUM(CASE WHEN l.transactionType='CR' THEN l.transaction_amount ELSE 0 END) coll, " +
                " SUM(CASE WHEN l.transactionType='CR' THEN 1 ELSE 0 END) np, " +
                " SUM(CASE WHEN l.transactionType='DR' THEN l.transaction_amount ELSE 0 END) bill " +
                "FROM fin_ledger l" + ledgerJoin + baseWhere, acct))
            {
                cmd.Parameters.AddWithValue("@start", start);
                cmd.Parameters.AddWithValue("@endEx", endEx);
                AddParams(cmd, sp);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    if (r.Read()) { collected = L(r, 0); numPayments = L(r, 1); billed = L(r, 2); }
            }

            double avgPayment = numPayments > 0 ? (collected * 1.0 / numPayments) : 0;
            double collectionRate = billed > 0 ? (collected * 100.0 / billed) : 0;

            // Trend — daily when the window is short, monthly otherwise.
            DateTime ds = DateTime.Parse(start), de = DateTime.Parse(endEx);
            bool daily = (de - ds).TotalDays <= 100;
            string fmt = daily ? "%Y-%m-%d" : "%Y-%m";
            List<object> trend = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT DATE_FORMAT(l.transactionDate,'" + fmt + "') ym, " +
                " SUM(CASE WHEN l.transactionType='CR' THEN l.transaction_amount ELSE 0 END) coll, " +
                " SUM(CASE WHEN l.transactionType='DR' THEN l.transaction_amount ELSE 0 END) bill, " +
                " SUM(CASE WHEN l.transactionType='CR' THEN 1 ELSE 0 END) np " +
                "FROM fin_ledger l" + ledgerJoin + baseWhere + " GROUP BY ym ORDER BY ym", acct))
            {
                cmd.Parameters.AddWithValue("@start", start);
                cmd.Parameters.AddWithValue("@endEx", endEx);
                AddParams(cmd, sp);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) trend.Add(new { label = Str(r, 0), collected = L(r, 1), billed = L(r, 2), payments = L(r, 3) });
            }

            // Collections by GL source_system.
            List<object> bySource = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT IFNULL(NULLIF(TRIM(l.source_system),''),'Manual/Other') nm, " +
                " SUM(l.transaction_amount) amt, COUNT(*) n " +
                "FROM fin_ledger l" + ledgerJoin + baseWhere + " AND l.transactionType='CR' " +
                "GROUP BY nm ORDER BY amt DESC LIMIT 8", acct))
            {
                cmd.Parameters.AddWithValue("@start", start);
                cmd.Parameters.AddWithValue("@endEx", endEx);
                AddParams(cmd, sp);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) bySource.Add(new { name = Str(r, 0), amount = L(r, 1), count = L(r, 2) });
            }

            // SchoolPay (mobile money) channel view — a subset lens, not the total.
            Dictionary<string, object> sp2 = new Dictionary<string, object>();
            string spScope = scoped ? StudentScope(f, sp2) : "";
            string spJoin = scoped
                ? " JOIN campus_dynamics.acad_student s ON s.regno=sd.regno " +
                  "LEFT JOIN campus_dynamics.acad_programme p ON p.progcode=s.progid "
                : " ";
            List<object> byChannel = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT sd.channelPaid nm, SUM(sd.amount_paid) amt, COUNT(*) n " +
                "FROM fin_schoolpaydata sd" + spJoin +
                "WHERE sd.datePaid>=@start AND sd.datePaid<@endEx AND TRIM(IFNULL(sd.channelPaid,''))<>''" + spScope +
                " GROUP BY sd.channelPaid ORDER BY amt DESC LIMIT 8", acct))
            {
                cmd.Parameters.AddWithValue("@start", start);
                cmd.Parameters.AddWithValue("@endEx", endEx);
                AddParams(cmd, sp2);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) byChannel.Add(new { name = Str(r, 0), amount = D(r, 1), count = L(r, 2) });
            }

            // Top collecting faculties (always joins to resolve names).
            Dictionary<string, object> sp3 = new Dictionary<string, object>();
            string s3 = StudentScope(f, sp3);
            List<object> topFaculties = new List<object>();
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COALESCE(fa.faculty_name,'Unmapped') nm, SUM(l.transaction_amount) amt " +
                "FROM fin_ledger l " +
                "JOIN campus_dynamics.acad_student s ON s.regno=l.accountcode " +
                "LEFT JOIN campus_dynamics.acad_programme p ON p.progcode=s.progid " +
                "LEFT JOIN campus_dynamics.acad_faculty fa ON fa.faculty_code=p.faculty_code " +
                "WHERE l.account_type='Student' AND l.transactionType='CR' " +
                "AND l.transactionDate>=@start AND l.transactionDate<@endEx " +
                "AND (l.source_system IS NULL OR l.source_system NOT IN (" + GL_NOISE + "))" + s3 +
                " GROUP BY nm ORDER BY amt DESC LIMIT 8", acct))
            {
                cmd.Parameters.AddWithValue("@start", start);
                cmd.Parameters.AddWithValue("@endEx", endEx);
                AddParams(cmd, sp3);
                using (MySqlDataReader r = cmd.ExecuteReader())
                    while (r.Read()) topFaculties.Add(new { name = Str(r, 0), amount = L(r, 1) });
            }

            return new
            {
                collected = collected, billed = billed, numPayments = numPayments,
                avgPayment = avgPayment, collectionRate = collectionRate,
                windowStart = start, windowEnd = de.AddDays(-1).ToString("yyyy-MM-dd"), granularity = (daily ? "day" : "month"),
                trend = trend, bySource = bySource, byChannel = byChannel, topFaculties = topFaculties
            };
        }
        catch (Exception ex) { return new { error = ex.Message }; }
    }

    // Generic "name,count" grouping used by several student widgets.
    private static List<object> GroupQuery(MySqlConnection conn, Dictionary<string, object> p, string sql)
    {
        List<object> rows = new List<object>();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            AddParams(cmd, p);
            using (MySqlDataReader r = cmd.ExecuteReader())
                while (r.Read()) rows.Add(new { name = Str(r, 0), count = L(r, 1) });
        }
        return rows;
    }
}
