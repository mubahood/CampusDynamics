using System;
using System.Collections.Generic;
using System.Configuration;
using MySql.Data.MySqlClient;

/// <summary>
/// Reads the examinations policy switches held in acad_exam_config.
///
/// WHAT THIS IS NOT. It is not another deadline mechanism. acad_deadlines already
/// answers "by when" per campus, year, semester and study system, and
/// MarksDeadlineService already reads it. This answers a different question — "is
/// this permitted at all, here" — which nothing could answer before: the only way
/// to close mark entry was to backdate a deadline, and there was no way to close it
/// for one faculty without closing it for everybody.
///
/// RESOLUTION. Most specific wins, scope before period:
///     PROGRAMME > FACULTY > CAMPUS > GLOBAL
///     exact year+semester > that year, any semester > any period
/// A Registrar sets the rule once, a Dean narrows it where it needs narrowing, and
/// nobody has to remember to put the global one back.
///
/// FAILURE. Every read falls back to the caller's default, and a database that
/// cannot be reached is treated as "no override configured". A policy table that is
/// briefly unavailable must not lock every lecturer out of mark entry, so the
/// defaults passed in by callers are always the permissive, current behaviour.
///
/// This file is duplicated in the portal (CampusDynamics_Portal/App_Code/Exams/)
/// and the two copies must stay byte-identical — the portal is where the lecturer
/// actually types marks, so it has to reach the same answer as the console that
/// sets the switch.
/// </summary>
public static class ExamConfig
{
    // ── keys, named once so a typo is a compile error rather than a silent default ──
    public const string CourseworkEntryEnabled = "coursework.entry.enabled";
    public const string ExamEntryEnabled       = "exam.entry.enabled";
    public const string PracticalEntryEnabled  = "practical.entry.enabled";
    public const string ExcelUploadEnabled     = "marks.excel.upload.enabled";
    public const string EditAfterSubmit        = "marks.edit.after.submit";
    public const string AllowBlankSubmit       = "marks.allow.blank.submit";
    public const string SplitCoursework        = "marks.split.coursework";
    public const string SplitExam              = "marks.split.exam";
    public const string SplitPractical         = "marks.split.practical";
    public const string MarksTotal             = "marks.total";
    public const string MaxScore               = "marks.max.score";
    public const string AllowDecimal           = "marks.allow.decimal";
    public const string ResultsVisible         = "results.students.visible";
    public const string ResultsHideOnBalance   = "results.hide.on.balance";

    /// <summary>
    /// Where a setting is being asked about. Any field may be left empty; an empty
    /// field simply cannot match an override at that level.
    /// </summary>
    public class Scope
    {
        public string Campus = "";
        public string Faculty = "";
        public string Programme = "";
        public string AcadYear = "";
        public int Semester = 0;

        public static Scope Global() { return new Scope(); }
        public Scope ForProgramme(string p) { Programme = (p ?? "").Trim(); return this; }
        public Scope ForFaculty(string f) { Faculty = (f ?? "").Trim(); return this; }
        public Scope ForCampus(string c) { Campus = (c ?? "").Trim(); return this; }
        public Scope ForPeriod(string year, int sem) { AcadYear = (year ?? "").Trim(); Semester = sem; return this; }
    }

    /// <summary>
    /// Builds a full scope from what a lecturer's screen actually has to hand.
    ///
    /// The faculty is looked up from the programme rather than asked for, because no
    /// portal screen carries it in session — and without it a Dean's faculty-wide
    /// override would silently fail to reach the very people it was meant for. The
    /// lookup is cached for the life of the process: programmes do not move faculty
    /// during a request, and this runs on every mark-entry page load.
    /// </summary>
    public static Scope ScopeForProgramme(string programme, string campus, string acadYear, int semester)
    {
        var sc = new Scope();
        sc.Programme = (programme ?? "").Trim();
        sc.Campus = (campus ?? "").Trim();
        sc.AcadYear = (acadYear ?? "").Trim();
        sc.Semester = semester;
        sc.Faculty = FacultyOf(sc.Programme);
        return sc;
    }

    private static readonly Dictionary<string, string> FacultyCache =
        new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

    private static string FacultyOf(string programme)
    {
        if (string.IsNullOrEmpty(programme)) return "";
        lock (FacultyCache)
        {
            string hit;
            if (FacultyCache.TryGetValue(programme, out hit)) return hit;
        }
        string code = "";
        try
        {
            using (var c = new MySqlConnection(ConnStr))
            {
                c.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT IFNULL(faculty_code,'') FROM acad_programme WHERE progcode = @p LIMIT 1", c))
                {
                    cmd.Parameters.AddWithValue("@p", programme);
                    object v = cmd.ExecuteScalar();
                    code = (v == null || v == DBNull.Value) ? "" : v.ToString().Trim();
                }
            }
        }
        catch { code = ""; }
        lock (FacultyCache) { FacultyCache[programme] = code; }
        return code;
    }

    private static string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["ExamConfig.ConnStr"];
            if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;

            // The portal's own vacConnectionString points at campus_dynamics_portal,
            // which is NOT where this table lives. Its second connection is.
            cs = ConfigurationManager.ConnectionStrings["campus_dynamics_portalConnectionString"];
            if (cs != null && cs.ConnectionString.IndexOf("database=campus_dynamics;", StringComparison.OrdinalIgnoreCase) >= 0)
                return cs.ConnectionString;

            cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
            if (cs != null && cs.ConnectionString.IndexOf("database=campus_dynamics;", StringComparison.OrdinalIgnoreCase) >= 0)
                return cs.ConnectionString;

            if (cs != null) return cs.ConnectionString;
            return "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics;charset=utf8";
        }
    }

    // ── reads ──────────────────────────────────────────────────────────────────

    public static bool IsEnabled(string key, Scope scope, bool fallback)
    {
        string v = Resolve(key, scope);
        if (v == null) return fallback;
        v = v.Trim().ToUpperInvariant();
        return v == "1" || v == "TRUE" || v == "YES" || v == "ON";
    }

    public static int GetInt(string key, Scope scope, int fallback)
    {
        string v = Resolve(key, scope);
        int n;
        return (v != null && int.TryParse(v.Trim(), out n)) ? n : fallback;
    }

    public static decimal GetDecimal(string key, Scope scope, decimal fallback)
    {
        string v = Resolve(key, scope);
        decimal d;
        return (v != null && decimal.TryParse(v.Trim(), System.Globalization.NumberStyles.Any,
                System.Globalization.CultureInfo.InvariantCulture, out d)) ? d : fallback;
    }

    public static string GetText(string key, Scope scope, string fallback)
    {
        string v = Resolve(key, scope);
        return v == null ? fallback : v;
    }

    /// <summary>
    /// The winning value for this key in this scope, or null when nothing is
    /// configured. Public so a screen can show an operator WHICH rule is in force.
    /// </summary>
    public static string Resolve(string key, Scope scope)
    {
        string src;
        return Resolve(key, scope, out src);
    }

    /// <summary>As Resolve, and also reports which row won, e.g. "PROGRAMME:BIT (2025/2026 S1)".</summary>
    public static string Resolve(string key, Scope scope, out string source)
    {
        source = "";
        key = (key ?? "").Trim();
        if (key == "") return null;
        if (scope == null) scope = Scope.Global();

        try
        {
            using (var c = new MySqlConnection(ConnStr))
            {
                c.Open();

                // Every row that COULD apply, ordered so the first one is the winner.
                // Ordering in SQL rather than in C# keeps the precedence rule in one
                // place, where it can be read alongside the query that uses it.
                using (var cmd = new MySqlCommand(
                    "SELECT scope_type, scope_value, acad_year, semester, config_value " +
                    "FROM acad_exam_config " +
                    "WHERE config_key = @k AND is_active = 1 " +
                    "  AND ( scope_type = 'GLOBAL' " +
                    "     OR (scope_type = 'CAMPUS'    AND scope_value = @campus    AND @campus    <> '') " +
                    "     OR (scope_type = 'FACULTY'   AND scope_value = @faculty   AND @faculty   <> '') " +
                    "     OR (scope_type = 'PROGRAMME' AND scope_value = @programme AND @programme <> '') ) " +
                    "  AND (acad_year = '' OR acad_year = @year) " +
                    "  AND (semester  = 0  OR semester  = @sem) " +
                    "ORDER BY FIELD(scope_type,'PROGRAMME','FACULTY','CAMPUS','GLOBAL'), " +
                    "         (acad_year <> '') DESC, (semester <> 0) DESC " +
                    "LIMIT 1", c))
                {
                    cmd.Parameters.AddWithValue("@k", key);
                    cmd.Parameters.AddWithValue("@campus", scope.Campus ?? "");
                    cmd.Parameters.AddWithValue("@faculty", scope.Faculty ?? "");
                    cmd.Parameters.AddWithValue("@programme", scope.Programme ?? "");
                    cmd.Parameters.AddWithValue("@year", scope.AcadYear ?? "");
                    cmd.Parameters.AddWithValue("@sem", scope.Semester);

                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return null;
                        string st = r.GetString(0);
                        string sv = r.GetString(1);
                        string yr = r.GetString(2);
                        int sm = r.GetInt32(3);
                        source = st + (sv == "" ? "" : ":" + sv)
                               + (yr == "" && sm == 0 ? "" : " (" + (yr == "" ? "any year" : yr) + (sm == 0 ? "" : " S" + sm) + ")");
                        return r.IsDBNull(4) ? "" : r.GetString(4);
                    }
                }
            }
        }
        catch
        {
            // Unreadable policy must never be stricter than no policy.
            return null;
        }
    }

    /// <summary>
    /// Every setting that applies in this scope, for a screen that wants to show the
    /// effective policy in one go rather than asking key by key.
    /// </summary>
    public static Dictionary<string, string> ResolveAll(Scope scope)
    {
        var outp = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        try
        {
            var keys = new List<string>();
            using (var c = new MySqlConnection(ConnStr))
            {
                c.Open();
                using (var cmd = new MySqlCommand("SELECT DISTINCT config_key FROM acad_exam_config WHERE is_active = 1", c))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) keys.Add(r.GetString(0));
            }
            foreach (string k in keys)
            {
                string v = Resolve(k, scope);
                if (v != null) outp[k] = v;
            }
        }
        catch { }
        return outp;
    }
}
