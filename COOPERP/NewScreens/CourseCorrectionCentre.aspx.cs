using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

// =====================================================================
//  COURSE RECORDS CORRECTION CENTRE — page methods.
//
//  Follows the Results Export Centre pattern: every interaction is a
//  [WebMethod] returning a JSON string, called from a small XMLHttpRequest
//  helper. The wizard's configuration is round-tripped as one object so
//  preview and apply are driven by identical input.
//
//  Scope is resolved server-side on every call. Nothing the browser sends
//  can widen it.
// =====================================================================
public partial class COOPERP_NewScreens_CourseCorrectionCentre : System.Web.UI.Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
    private const string PAGE = "CourseCorrectionCentre";

    protected void Page_Load(object sender, EventArgs e)
    {
        MarksScope scope = MarksScopeResolver.Resolve();
        litScope.Text = scope.HasAccess
            ? HttpUtility.HtmlEncode(scope.RoleNote + " — " + scope.Label)
            : "No access";
        hdnIsAdmin.Value = scope.IsAdmin ? "1" : "0";
    }

    private static string CurrentUser()
    {
        var ctx = HttpContext.Current;
        if (ctx != null && ctx.Session != null)
        {
            string u = ctx.Session["username"] as string;
            if (!string.IsNullOrEmpty(u)) return u;
        }
        if (ctx != null && ctx.User != null && ctx.User.Identity != null) return ctx.User.Identity.Name;
        return "unknown";
    }

    private static string Ip()
    {
        try
        {
            var rq = HttpContext.Current.Request;
            string f = rq.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(f)) return f.Split(',')[0].Trim();
            return rq.ServerVariables["REMOTE_ADDR"] ?? rq.UserHostAddress;
        }
        catch { return null; }
    }

    private static CorrectionConfig Parse(string json)
    {
        try
        {
            var c = Json.Deserialize<CorrectionConfig>(json);
            return c ?? new CorrectionConfig();
        }
        catch { return new CorrectionConfig(); }
    }

    private static string Fail(string msg) { return Json.Serialize(new { success = false, message = msg }); }

    // ─────────────────────────────────────────────────────────────────
    //  Filter options
    // ─────────────────────────────────────────────────────────────────
    [WebMethod(EnableSession = true)]
    public static string GetOptions()
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            if (!scope.HasAccess)
                return Json.Serialize(new { success = true, hasAccess = false, scopeLabel = scope.Label, roleNote = scope.RoleNote });

            var years = new List<object>();
            var programmes = new List<object>();
            var faculties = new List<object>();
            var stages = new List<object>();
            var specialisations = new List<object>();
            string pf = scope.ProgFilter("p", "progcode");

            using (var c = new MySqlConnection(CourseCorrectionService.ConnStr()))
            {
                c.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT DISTINCT acad_year FROM campus_dynamics_portal.acad_course_registration " +
                    "WHERE acad_year REGEXP '^[0-9]{4}/[0-9]{4}$' ORDER BY acad_year DESC", c))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) years.Add(new { value = r.GetString(0), text = r.GetString(0) });

                using (var cmd = new MySqlCommand(
                    "SELECT TRIM(p.progcode), COALESCE(p.progname,p.progcode), TRIM(IFNULL(p.faculty_code,'')) " +
                    "FROM acad_programme p WHERE TRIM(p.progcode) NOT IN ('','-')" + pf + " ORDER BY 2", c))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) programmes.Add(new { value = r.GetString(0), text = r.GetString(1), faculty = r.GetString(2) });

                if (scope.IsAdmin)
                    using (var cmd = new MySqlCommand(
                        "SELECT TRIM(faculty_code), faculty_name FROM acad_faculty WHERE TRIM(faculty_code)<>'00' ORDER BY faculty_name", c))
                    using (var r = cmd.ExecuteReader())
                        while (r.Read()) faculties.Add(new { value = r.GetString(0), text = r.GetString(1) });

                // Specialisations are programme-scoped (acad_specialisation.prog_id), so each one
                // carries its programme and the browser cascades locally. The placeholder rows
                // ('-') and those with no students are dropped — they only clutter the list.
                using (var cmd = new MySqlCommand(
                    "SELECT sp.spec_id, TRIM(sp.prog_id), sp.spec, IFNULL(sp.abbrev,''), sp.is_active, " +
                    "       (SELECT COUNT(*) FROM acad_student st WHERE st.specialisation = sp.spec_id) students " +
                    "FROM acad_specialisation sp " +
                    "WHERE TRIM(sp.spec) NOT IN ('','-') AND TRIM(sp.prog_id) NOT IN ('','-') " +
                    "ORDER BY sp.prog_id, sp.spec", c))
                {
                    cmd.CommandTimeout = 120;
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            specialisations.Add(new
                            {
                                value = Convert.ToString(r[0]),
                                text = r.GetString(2),
                                abbrev = r.GetString(3),
                                programme = r.GetString(1),
                                active = string.Equals(r.GetString(4), "Active", StringComparison.OrdinalIgnoreCase),
                                students = Convert.ToInt32(r[5])
                            });
                }
            }

            foreach (var s in new[] { "NOT_ENTERED", "ENTERED", "CAPTURED", "APPROVED", "PUBLISHED", "RETURNED" })
                stages.Add(new { value = s, text = s.Replace('_', ' ') });

            return Json.Serialize(new
            {
                success = true,
                hasAccess = true,
                isAdmin = scope.IsAdmin,
                scopeLabel = scope.Label,
                roleNote = scope.RoleNote,
                years,
                programmes,
                faculties,
                stages,
                specialisations
            });
        }
        catch (Exception ex) { return Fail(ex.Message); }
    }

    /// <summary>Course-code lookup for the two code pickers. Returns the code, its name,
    /// credit units and how many registrations currently carry it — so the operator can see
    /// at a glance which of two similar codes is the real one.</summary>
    [WebMethod(EnableSession = true)]
    public static string SearchCourses(string term)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            if (!scope.HasAccess) return Fail("No access.");
            term = (term ?? "").Trim();
            if (term.Length < 2) return Json.Serialize(new { success = true, items = new List<object>() });

            var items = new List<object>();
            using (var c = new MySqlConnection(CourseCorrectionService.ConnStr()))
            {
                c.Open();
                // The code columns use utf8_general_ci, so mgt1201b and MGT1201B are the same
                // course and the catalogue — a primary key — can only ever hold one of them.
                // The registration table has no such guard and has drifted: MGT1201B alone is
                // written three ways across 3,266 rows. The count is therefore the true
                // case-insensitive total, and any stray casings are listed beside it so the
                // operator can see the drift instead of it silently disappearing into the total.
                using (var cmd = new MySqlCommand(
                    "SELECT c.courseID, IFNULL(c.courseName,''), IFNULL(c.CreditUnit,0), IFNULL(c.course_state,'ACTIVE'), " +
                    "  (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr WHERE cr.courseID=c.courseID) regs, " +
                    "  (SELECT GROUP_CONCAT(DISTINCT BINARY cr2.courseID ORDER BY cr2.courseID SEPARATOR '|') " +
                    "     FROM campus_dynamics_portal.acad_course_registration cr2 " +
                    "    WHERE cr2.courseID=c.courseID AND BINARY cr2.courseID <> BINARY c.courseID) othercase " +
                    "FROM acad_course c WHERE c.courseID LIKE @t OR c.courseName LIKE @t " +
                    "ORDER BY (c.courseID=@exact) DESC, regs DESC, c.courseID LIMIT 40", c))
                {
                    cmd.Parameters.AddWithValue("@t", "%" + term + "%");
                    cmd.Parameters.AddWithValue("@exact", term);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string other = r.IsDBNull(5) ? "" : r.GetString(5);
                            items.Add(new
                            {
                                code = r.GetString(0),
                                name = r.GetString(1),
                                cu = r.IsDBNull(2) ? 0 : r.GetDouble(2),
                                state = r.GetString(3),
                                regs = r.IsDBNull(4) ? 0 : Convert.ToInt32(r[4]),
                                otherCasings = other == "" ? new string[0] : other.Split('|')
                            });
                        }
                }
            }
            return Json.Serialize(new { success = true, items });
        }
        catch (Exception ex) { return Fail(ex.Message); }
    }

    /// <summary>Codes that look like duplicates of one another — the shortlist this module exists
    /// to clean up. Same letters and digits once spaces, punctuation and case are removed.</summary>
    [WebMethod(EnableSession = true)]
    public static string FindSimilarCodes()
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            if (!scope.HasAccess) return Fail("No access.");

            var groups = new List<object>();
            using (var c = new MySqlConnection(CourseCorrectionService.ConnStr()))
            {
                c.Open();
                // Normalise by stripping spaces, dots and hyphens; group codes that collapse
                // to the same string but are stored differently.
                using (var cmd = new MySqlCommand(
                    "SELECT norm, GROUP_CONCAT(courseID ORDER BY regs DESC SEPARATOR '|') codes, " +
                    "       GROUP_CONCAT(regs ORDER BY regs DESC SEPARATOR '|') counts, COUNT(*) n " +
                    "FROM ( SELECT c.courseID, UPPER(REPLACE(REPLACE(REPLACE(c.courseID,' ',''),'.',''),'-','')) norm, " +
                    "         (SELECT COUNT(*) FROM campus_dynamics_portal.acad_course_registration cr WHERE cr.courseID=c.courseID) regs " +
                    "       FROM acad_course c ) t " +
                    "GROUP BY norm HAVING n > 1 ORDER BY n DESC, norm LIMIT 200", c))
                {
                    cmd.CommandTimeout = 300;
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            groups.Add(new
                            {
                                norm = r.GetString(0),
                                codes = r.GetString(1).Split('|'),
                                counts = r.GetString(2).Split('|'),
                                n = Convert.ToInt32(r[3])
                            });
                }
            }
            return Json.Serialize(new { success = true, groups });
        }
        catch (Exception ex) { return Fail(ex.Message); }
    }

    // ─────────────────────────────────────────────────────────────────
    //  Preview / Apply
    // ─────────────────────────────────────────────────────────────────
    [WebMethod(EnableSession = true)]
    public static string Preview(string configJson)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            var cfg = Parse(configJson);
            var res = CourseCorrectionService.Preview(cfg, scope);
            return Json.Serialize(res);
        }
        catch (Exception ex) { return Fail(ex.Message); }
    }

    [WebMethod(EnableSession = true)]
    public static string ApplyCorrection(string configJson, string checksum)
    {
        var sw = MarksActionLogger.StartTimer();
        string outcome = MarksActionLogger.OUTCOME_SUCCESS, detail = "";
        var cfg = Parse(configJson);
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            var res = CourseCorrectionService.Apply(cfg, scope, CurrentUser(), Ip(), checksum);
            if (!res.success) { outcome = MarksActionLogger.OUTCOME_VALIDATION; detail = res.message; }
            else detail = res.batchRef + ": " + res.rowsApplied + " registrations, " + res.satelliteRows + " related records";
            return Json.Serialize(res);
        }
        catch (Exception ex)
        {
            outcome = MarksActionLogger.OUTCOME_VALIDATION; detail = ex.Message;
            return Fail(ex.Message);
        }
        finally
        {
            try
            {
                var ctx = new Dictionary<string, string> {
                    { "source", cfg.sourceCode }, { "target", cfg.targetCode },
                    { "sourceTerm", cfg.sourceYear + " S" + cfg.sourceSemester },
                    { "targetTerm", cfg.targetYear + " S" + cfg.targetSemester },
                    { "programme", cfg.programme }, { "reason", cfg.reason },
                    { "result", detail }, { "actor", CurrentUser() }
                };
                MarksActionLogger.StopAndLog(sw, PAGE, cfg.operation, outcome, ctx, null);
            }
            catch { }
        }
    }
}
