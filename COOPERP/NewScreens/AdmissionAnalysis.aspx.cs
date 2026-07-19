using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Admission Analysis — read-only aggregate analytics over admissions
/// (acad_applicant_choices primary choice ∩ acad_applications). Groups the
/// applicant pipeline (pending / admitted / registered / rejected / withdrawn)
/// by programme, faculty, entry year, session and source, honouring GET filters.
/// Server-rendered payload (window.__AA_INIT) — no AJAX on load.
/// </summary>
public partial class COOPERP_NewScreens_AdmissionAnalysis : System.Web.UI.Page
{
    public string InitJson = "{\"ok\":false,\"error\":\"not loaded\"}";

    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; } }
    private MySqlConnection Open() { var c = new MySqlConnection(ConnStr); c.Open(); return c; }
    private static long L(object v) { if (v == null || v == DBNull.Value) return 0; long r; return long.TryParse(Convert.ToString(v), out r) ? r : 0; }
    private static string S(object v) { return (v == null || v == DBNull.Value) ? "" : Convert.ToString(v); }
    private static MySqlParameter P(string n, object v) { return new MySqlParameter(n, v ?? DBNull.Value); }

    private static bool ColumnExists(MySqlConnection conn, string table, string col)
    {
        using (var cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
        {
            cmd.Parameters.AddWithValue("@t", table);
            cmd.Parameters.AddWithValue("@c", col);
            object o = cmd.ExecuteScalar();
            return o != null && Convert.ToInt64(o) > 0;
        }
    }

    // status-conditional counters (MySQL treats a boolean predicate as 1/0)
    private const string StatCols =
        "COUNT(*) total, " +
        "SUM(c.adm_status=0) pending, " +
        "SUM(c.adm_status=1 AND (a.stud_reg_no IS NULL OR a.stud_reg_no='' OR a.stud_reg_no='-')) admitted, " +
        "SUM(c.adm_status=1 AND a.stud_reg_no IS NOT NULL AND a.stud_reg_no<>'' AND a.stud_reg_no<>'-') registered, " +
        "SUM(c.adm_status=2) rejected, SUM(c.adm_status=3) withdrawn ";
    private const string BaseJoin =
        " FROM acad_applicant_choices c " +
        "JOIN acad_applications a ON a.stud_entry_no=c.stud_entry_no " +
        "LEFT JOIN acad_programme p ON p.progcode=c.prog_id " +
        "LEFT JOIN acad_faculty f ON f.faculty_code=p.faculty_code ";

    protected void Page_Load(object sender, EventArgs e)
    {
        string year    = (Request.QueryString["year"] ?? "").Trim();
        string session = (Request.QueryString["session"] ?? "").Trim();
        string source  = (Request.QueryString["source"] ?? "").Trim();
        string fac     = (Request.QueryString["fac"] ?? "").Trim();
        string prog    = (Request.QueryString["prog"] ?? "").Trim();

        var ser = new JavaScriptSerializer(); ser.MaxJsonLength = int.MaxValue;
        try { InitJson = ser.Serialize(BuildData(year, session, source, fac, prog)); }
        catch (Exception ex) { InitJson = ser.Serialize(new { ok = false, error = "Server error: " + ex.Message }); }
    }

    private List<Dictionary<string, object>> Query(MySqlConnection conn, string sql, List<MySqlParameter> ps)
    {
        var rows = new List<Dictionary<string, object>>();
        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 60;
            if (ps != null) foreach (var p in ps) cmd.Parameters.Add(new MySqlParameter(p.ParameterName, p.Value));
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                {
                    var d = new Dictionary<string, object>();
                    for (int i = 0; i < r.FieldCount; i++) d[r.GetName(i)] = r.IsDBNull(i) ? null : r.GetValue(i);
                    rows.Add(d);
                }
        }
        return rows;
    }

    private static object Stat(Dictionary<string, object> d)
    {
        long total = L(d["total"]), pending = L(d["pending"]), admitted = L(d["admitted"]),
             registered = L(d["registered"]), rejected = L(d["rejected"]), withdrawn = L(d["withdrawn"]);
        return new { total, pending, admitted, registered, rejected, withdrawn };
    }

    private object BuildData(string year, string session, string source, string fac, string prog)
    {
        using (var conn = Open())
        {
            bool hasUserId = ColumnExists(conn, "acad_applications", "applicant_user_id");

            var where = new List<string> { "c.Choice=1" };
            var ps = new List<MySqlParameter>();
            if (year != "") { where.Add("a.stud_entry_year=@year"); ps.Add(P("@year", year)); }
            if (session != "") { where.Add("c.adm_session=@sess"); ps.Add(P("@sess", session)); }
            if (fac != "") { where.Add("p.faculty_code=@fac"); ps.Add(P("@fac", fac)); }
            if (prog != "") { where.Add("c.prog_id=@prog"); ps.Add(P("@prog", prog)); }
            if (hasUserId && source == "ONLINE") where.Add("a.applicant_user_id IS NOT NULL");
            else if (hasUserId && source == "WALKIN") where.Add("a.applicant_user_id IS NULL");
            string wc = " WHERE " + string.Join(" AND ", where.ToArray());

            // ── KPIs (single row) ──
            var kpiRows = Query(conn, "SELECT " + StatCols + BaseJoin + wc, ps);
            object kpis = kpiRows.Count > 0 ? Stat(kpiRows[0]) : new { total = 0, pending = 0, admitted = 0, registered = 0, rejected = 0, withdrawn = 0 };

            // ── By programme (the core: programme totals) ──
            var byProg = new List<object>();
            foreach (var d in Query(conn, "SELECT c.prog_id code, COALESCE(p.progname,c.prog_id) name, COALESCE(p.faculty_code,'') facCode, COALESCE(f.faculty_name,'') facName, " + StatCols + BaseJoin + wc + " GROUP BY c.prog_id ORDER BY total DESC", ps))
                byProg.Add(new { code = S(d["code"]), name = S(d["name"]), facCode = S(d["facCode"]), facName = S(d["facName"]), stat = Stat(d) });

            // ── By faculty ──
            var byFaculty = new List<object>();
            foreach (var d in Query(conn, "SELECT COALESCE(p.faculty_code,'') code, COALESCE(f.faculty_name,'(Unassigned)') name, " + StatCols + BaseJoin + wc + " GROUP BY p.faculty_code ORDER BY total DESC", ps))
                byFaculty.Add(new { code = S(d["code"]), name = S(d["name"]), stat = Stat(d) });

            // ── By entry year ──
            var byYear = new List<object>();
            foreach (var d in Query(conn, "SELECT COALESCE(a.stud_entry_year,0) yr, " + StatCols + BaseJoin + wc + " GROUP BY a.stud_entry_year ORDER BY yr DESC", ps))
                byYear.Add(new { name = S(d["yr"]), stat = Stat(d) });

            // ── By session ──
            var bySession = new List<object>();
            foreach (var d in Query(conn, "SELECT COALESCE(NULLIF(c.adm_session,''),'(None)') sess, " + StatCols + BaseJoin + wc + " GROUP BY c.adm_session ORDER BY total DESC", ps))
                bySession.Add(new { name = S(d["sess"]), stat = Stat(d) });

            // ── By source (online vs walk-in) ──
            var bySource = new List<object>();
            if (hasUserId)
                foreach (var d in Query(conn, "SELECT CASE WHEN a.applicant_user_id IS NOT NULL THEN 'Online Portal' ELSE 'Walk-in / Manual' END src, " + StatCols + BaseJoin + wc + " GROUP BY (a.applicant_user_id IS NOT NULL) ORDER BY total DESC", ps))
                    bySource.Add(new { name = S(d["src"]), stat = Stat(d) });

            // ── Filter option lists ──
            var faculties = new List<object>();
            foreach (var d in Query(conn, "SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name", null))
                faculties.Add(new { code = S(d["faculty_code"]), name = S(d["faculty_name"]) });
            var programmes = new List<object>();
            foreach (var d in Query(conn, "SELECT progcode, progname FROM acad_programme ORDER BY progname", null))
                programmes.Add(new { code = S(d["progcode"]), name = S(d["progname"]) });
            var years = new List<object>();
            foreach (var d in Query(conn, "SELECT DISTINCT stud_entry_year yr FROM acad_applications WHERE stud_entry_year IS NOT NULL AND stud_entry_year<>'' ORDER BY yr DESC", null))
                years.Add(S(d["yr"]));
            var sessions = new List<object>();
            foreach (var d in Query(conn, "SELECT DISTINCT adm_session s FROM acad_applicant_choices WHERE adm_session IS NOT NULL AND adm_session<>'' ORDER BY s", null))
                sessions.Add(S(d["s"]));

            return new {
                ok = true,
                filters = new { year, session, source, fac, prog, hasSource = hasUserId },
                kpis = kpis,
                byProg = byProg,
                byFaculty = byFaculty,
                byYear = byYear,
                bySession = bySession,
                bySource = bySource,
                lists = new { faculties, programmes, years, sessions }
            };
        }
    }
}
