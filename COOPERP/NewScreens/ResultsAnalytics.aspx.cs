using System;
using System.Collections.Generic;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_ResultsAnalytics : Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    protected void Page_Load(object sender, EventArgs e) { /* AJAX-powered */ }

    private static string GetConnStr()
    {
        return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    }

    // ── Approved/released results only ──
    private const string APPROVED = " AND er.approved_by NOT IN ('-','HELD') ";

    [WebMethod(EnableSession = true)]
    public static string GetInit()
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            string sf = scope.ProgFilter("er", "progid");

            List<FilterOption> years = new List<FilterOption>();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT er.acadyear, COUNT(*) c FROM acad_examresults_faculty er " +
                    "JOIN acad_programme p ON p.progcode = er.progid " +
                    "WHERE er.acadyear REGEXP '^[0-9]{4}/[0-9]{4}$'" + APPROVED + sf +
                    " GROUP BY er.acadyear ORDER BY er.acadyear DESC LIMIT 12", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? "" : rdr.GetString(0);
                        if (!string.IsNullOrEmpty(v)) years.Add(new FilterOption(v, v));
                    }
            }

            return Json.Serialize(new
            {
                success = true,
                years = years,
                scope = new { mode = scope.Mode, label = scope.Label, role = scope.RoleNote, isAdmin = scope.IsAdmin, hasAccess = scope.HasAccess }
            });
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Init failed: " + ex.Message });
        }
    }

    [WebMethod(EnableSession = true)]
    public static string GetAnalytics(string year, string semester)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                string where = "WHERE 1=1" + APPROVED + scope.ProgFilter("er", "progid");
                if (!string.IsNullOrEmpty(year))     where += " AND er.acadyear = @year";
                if (!string.IsNullOrEmpty(semester)) where += " AND er.semester = @sem";

                object result = new
                {
                    kpis         = Kpis(conn, where, year, semester),
                    grades       = Grades(conn, where, year, semester),
                    byFaculty    = Groups(conn, where, year, semester, "fac"),
                    byDepartment = Groups(conn, where, year, semester, "dept"),
                    byProgramme  = Groups(conn, where, year, semester, "prog"),
                    trend        = Trend(conn, scope),
                    problematic  = Problematic(conn, where, year, semester),
                    topStudents  = TopStudents(conn, where, year, semester)
                };

                return Json.Serialize(new
                {
                    success = true,
                    data = result,
                    scope = new { mode = scope.Mode, label = scope.Label, role = scope.RoleNote, isAdmin = scope.IsAdmin, hasAccess = scope.HasAccess }
                });
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Analytics failed: " + ex.Message });
        }
    }

    private static void AddP(MySqlCommand cmd, string year, string sem)
    {
        if (!string.IsNullOrEmpty(year)) cmd.Parameters.AddWithValue("@year", year);
        if (!string.IsNullOrEmpty(sem))  cmd.Parameters.AddWithValue("@sem", sem);
    }

    private static object Kpis(MySqlConnection conn, string where, string year, string sem)
    {
        string sql = "SELECT COUNT(DISTINCT er.regno) students, COUNT(DISTINCT er.course_id) courses, " +
                     "COUNT(*) results, SUM(er.total_mark>=50) passes, " +
                     "ROUND(AVG(er.total_mark),1) avg_mark, SUM(UPPER(TRIM(er.grade))='A') distinctions " +
                     "FROM acad_examresults_faculty er JOIN acad_programme p ON p.progcode=er.progid " + where;
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            AddP(cmd, year, sem);
            using (MySqlDataReader r = cmd.ExecuteReader())
            {
                if (r.Read())
                {
                    int results = ToInt(r["results"]);
                    int passes = ToInt(r["passes"]);
                    int distinct = ToInt(r["distinctions"]);
                    double passRate = results > 0 ? Math.Round((double)passes * 100 / results, 1) : 0;
                    double distPct  = results > 0 ? Math.Round((double)distinct * 100 / results, 1) : 0;
                    return new
                    {
                        students = ToInt(r["students"]),
                        courses = ToInt(r["courses"]),
                        results = results,
                        passes = passes,
                        passRate = passRate,
                        failRate = results > 0 ? Math.Round(100 - passRate, 1) : 0,
                        avgMark = r["avg_mark"] == DBNull.Value ? 0 : Convert.ToDouble(r["avg_mark"]),
                        distinctions = distinct,
                        distinctionPct = distPct
                    };
                }
            }
        }
        return new { students = 0, courses = 0, results = 0, passes = 0, passRate = 0, failRate = 0, avgMark = 0, distinctions = 0, distinctionPct = 0 };
    }

    private static List<object> Grades(MySqlConnection conn, string where, string year, string sem)
    {
        var list = new List<object>();
        string sql = "SELECT UPPER(TRIM(er.grade)) g, COUNT(*) c " +
                     "FROM acad_examresults_faculty er JOIN acad_programme p ON p.progcode=er.progid " +
                     where + " AND TRIM(IFNULL(er.grade,''))<>'' GROUP BY g";
        // Fixed display order for the standard grade ladder.
        string[] order = { "A", "B+", "B", "C+", "C", "D+", "D", "F" };
        var counts = new Dictionary<string, int>();
        int total = 0;
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            AddP(cmd, year, sem);
            using (MySqlDataReader r = cmd.ExecuteReader())
                while (r.Read())
                {
                    string g = r["g"].ToString();
                    int c = ToInt(r["c"]);
                    if (!counts.ContainsKey(g)) counts[g] = 0;
                    counts[g] += c; total += c;
                }
        }
        for (int i = 0; i < order.Length; i++)
        {
            int c = counts.ContainsKey(order[i]) ? counts[order[i]] : 0;
            list.Add(new { grade = order[i], count = c, pct = total > 0 ? Math.Round((double)c * 100 / total, 1) : 0 });
        }
        return list;
    }

    // group: "fac" | "dept" | "prog"
    private static List<object> Groups(MySqlConnection conn, string where, string year, string sem, string group)
    {
        string keyName, join;
        if (group == "fac")
        {
            keyName = "COALESCE(NULLIF(f.faculty_name,''),'(Unassigned)')";
            join = "LEFT JOIN acad_faculty f ON f.faculty_code=p.faculty_code";
        }
        else if (group == "dept")
        {
            keyName = "COALESCE(NULLIF(d.dept_name,''),'(Unassigned)')";
            join = "LEFT JOIN hrm_departments d ON d.ID=p.department_id";
        }
        else
        {
            keyName = "COALESCE(NULLIF(p.progname,''),p.progcode)";
            join = "";
        }

        string sql = "SELECT * FROM (" +
            "SELECT " + keyName + " gname, COUNT(DISTINCT er.regno) students, COUNT(*) results, " +
            "SUM(er.total_mark>=50) passes, ROUND(AVG(er.total_mark),1) avg_mark " +
            "FROM acad_examresults_faculty er JOIN acad_programme p ON p.progcode=er.progid " + join + " " +
            where + " GROUP BY gname) g ORDER BY results DESC LIMIT 40";

        var list = new List<object>();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            AddP(cmd, year, sem);
            using (MySqlDataReader r = cmd.ExecuteReader())
                while (r.Read())
                {
                    int results = ToInt(r["results"]); int passes = ToInt(r["passes"]);
                    list.Add(new
                    {
                        name = ToStr(r["gname"]),
                        students = ToInt(r["students"]),
                        results = results,
                        passRate = results > 0 ? Math.Round((double)passes * 100 / results, 1) : 0,
                        avgMark = r["avg_mark"] == DBNull.Value ? 0 : Convert.ToDouble(r["avg_mark"])
                    });
                }
        }
        return list;
    }

    private static List<object> Trend(MySqlConnection conn, MarksScope scope)
    {
        var list = new List<object>();
        string sql = "SELECT * FROM (" +
            "SELECT er.acadyear y, COUNT(*) results, SUM(er.total_mark>=50) passes " +
            "FROM acad_examresults_faculty er JOIN acad_programme p ON p.progcode=er.progid " +
            "WHERE er.acadyear REGEXP '^[0-9]{4}/[0-9]{4}$'" + APPROVED + scope.ProgFilter("er", "progid") +
            " GROUP BY er.acadyear ORDER BY CAST(LEFT(er.acadyear,4) AS UNSIGNED) DESC LIMIT 6) t " +
            "ORDER BY CAST(LEFT(y,4) AS UNSIGNED) ASC";
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        using (MySqlDataReader r = cmd.ExecuteReader())
            while (r.Read())
            {
                int results = ToInt(r["results"]); int passes = ToInt(r["passes"]);
                list.Add(new { label = ToStr(r["y"]), results = results,
                    passRate = results > 0 ? Math.Round((double)passes * 100 / results, 1) : 0 });
            }
        return list;
    }

    private static List<object> Problematic(MySqlConnection conn, string where, string year, string sem)
    {
        var list = new List<object>();
        string sql = "SELECT * FROM (" +
            "SELECT er.course_id code, COALESCE(NULLIF(c.courseName,''),er.course_id) cname, " +
            "COUNT(*) results, SUM(er.total_mark<50) fails, " +
            "ROUND(SUM(er.total_mark<50)*100/COUNT(*),1) fail_rate " +
            "FROM acad_examresults_faculty er JOIN acad_programme p ON p.progcode=er.progid " +
            "LEFT JOIN acad_course c ON c.courseID=er.course_id " + where +
            " GROUP BY er.course_id, cname HAVING results>=5 AND fail_rate>20) x " +
            "ORDER BY fail_rate DESC, results DESC LIMIT 12";
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            AddP(cmd, year, sem);
            using (MySqlDataReader r = cmd.ExecuteReader())
                while (r.Read())
                    list.Add(new { code = ToStr(r["code"]), name = ToStr(r["cname"]),
                        results = ToInt(r["results"]), fails = ToInt(r["fails"]),
                        failRate = r["fail_rate"] == DBNull.Value ? 0 : Convert.ToDouble(r["fail_rate"]) });
        }
        return list;
    }

    private static List<object> TopStudents(MySqlConnection conn, string where, string year, string sem)
    {
        var list = new List<object>();
        string sql = "SELECT er.regno, MAX(TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')))) nm, MAX(COALESCE(NULLIF(p.progname,''),p.progcode)) prog, " +
            "ROUND(AVG(er.total_mark),1) avg_mark, COUNT(*) results " +
            "FROM acad_examresults_faculty er JOIN acad_programme p ON p.progcode=er.progid " +
            "LEFT JOIN acad_student s ON s.regno=er.regno " + where +
            " GROUP BY er.regno HAVING results>=3 ORDER BY avg_mark DESC LIMIT 10";
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            AddP(cmd, year, sem);
            using (MySqlDataReader r = cmd.ExecuteReader())
                while (r.Read())
                    list.Add(new { regno = ToStr(r["regno"]), name = ToStr(r["nm"]), prog = ToStr(r["prog"]),
                        avgMark = r["avg_mark"] == DBNull.Value ? 0 : Convert.ToDouble(r["avg_mark"]),
                        results = ToInt(r["results"]) });
        }
        return list;
    }

    private static int ToInt(object v) { return v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v); }
    private static string ToStr(object v) { return v == null || v == DBNull.Value ? "" : v.ToString(); }

    private class FilterOption
    {
        public string value { get; set; }
        public string text { get; set; }
        public FilterOption(string v, string t) { value = v; text = t; }
    }
}
