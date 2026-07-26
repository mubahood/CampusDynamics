using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_MarksDashboard : Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    protected void Page_Load(object sender, EventArgs e) { /* AJAX-powered — no server binding needed */ }

    [WebMethod(EnableSession = true)]
    public static string GetDashboardInit()
    {
        try
        {
            // Resolve this user's data scope (admin = all, dean = faculty, HOD = dept).
            MarksScope scope = MarksScopeResolver.Resolve();
            // Exam stats consider ONLY active (onboarded) students — see ActiveStudentFilter.
            string sf = scope.ProgFilter("cr") + ActiveStudentFilter.Clause("cr.regno");

            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();

                List<FilterOption> years = new List<FilterOption>();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT DISTINCT cr.acad_year
                    FROM campus_dynamics_portal.acad_course_registration cr
                    INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                    WHERE cr.acad_year IS NOT NULL AND TRIM(cr.acad_year) <> ''" + sf + @"
                    ORDER BY cr.acad_year DESC", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? string.Empty : rdr.GetString(0);
                        if (!string.IsNullOrEmpty(v)) years.Add(new FilterOption { value = v, text = v });
                    }
                }

                List<FilterOption> programmes = new List<FilterOption>();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT DISTINCT p.progcode, COALESCE(p.progname, p.progcode) AS progname
                    FROM acad_programme p
                    INNER JOIN campus_dynamics_portal.acad_course_registration cr ON cr.prog_id = p.progcode
                    INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                    WHERE 1=1" + sf + @"
                    ORDER BY progname", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? string.Empty : rdr.GetString(0);
                        string t = rdr.IsDBNull(1) ? v : rdr.GetString(1);
                        if (!string.IsNullOrEmpty(v)) programmes.Add(new FilterOption { value = v, text = t });
                    }
                }

                return Json.Serialize(new
                {
                    success = true,
                    years = years,
                    programmes = programmes,
                    scope = new { mode = scope.Mode, label = scope.Label, role = scope.RoleNote, isAdmin = scope.IsAdmin, hasAccess = scope.HasAccess }
                });
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load filters: " + ex.Message });
        }
    }

    [WebMethod(EnableSession = true)]
    public static string GetDashboardStats(string year, string semester, string programme)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                DashboardStats stats = BuildStats(conn, year, semester, programme, scope);
                return Json.Serialize(new
                {
                    success = true,
                    stats = stats,
                    scope = new { mode = scope.Mode, label = scope.Label, role = scope.RoleNote, isAdmin = scope.IsAdmin, hasAccess = scope.HasAccess }
                });
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load stats: " + ex.Message });
        }
    }

    // ===================================================================
    //  MARK CHANGES / AUDIT  (who changed what — from acad_marks_audit)
    //  Scope-filtered by the student's programme (join acad_student).
    // ===================================================================
    [WebMethod(EnableSession = true)]
    public static string GetMarkAuditStats(string days)
    {
        try
        {
            int d; if (!int.TryParse(days, out d) || d <= 0) d = 30;
            MarksScope scope = MarksScopeResolver.Resolve();
            string sf = scope.ProgFilter("s", "progid");
            var stats = new Dictionary<string, object>();
            var byAction = new List<object[]>();
            var topEditors = new List<object[]>();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT " +
                    " SUM(CASE WHEN a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY) THEN 1 ELSE 0 END) AS win, " +
                    " SUM(CASE WHEN a.action_type='DELETE' AND a.created_at >= (NOW() - INTERVAL @d DAY) THEN 1 ELSE 0 END) AS dels, " +
                    " COUNT(DISTINCT CASE WHEN a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY) THEN a.performed_by END) AS editors, " +
                    " COUNT(*) AS total_tracked " +
                    "FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno = a.regno " +
                    "WHERE a.target_table='acad_results'" + sf, conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    using (var rdr = cmd.ExecuteReader())
                        if (rdr.Read())
                        {
                            stats["window"] = ToInt(rdr["win"]);
                            stats["deletes"] = ToInt(rdr["dels"]);
                            stats["editors"] = ToInt(rdr["editors"]);
                            stats["total"] = ToInt(rdr["total_tracked"]);
                        }
                }
                using (var cmd = new MySqlCommand(
                    "SELECT a.action_type, COUNT(*) n FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno=a.regno " +
                    "WHERE a.target_table='acad_results' AND a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY)" + sf +
                    " GROUP BY a.action_type ORDER BY n DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read()) byAction.Add(new object[] { ToStr(rdr["action_type"]), ToInt(rdr["n"]) });
                }
                using (var cmd = new MySqlCommand(
                    "SELECT a.performed_by, COUNT(*) n FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno=a.regno " +
                    "WHERE a.target_table='acad_results' AND a.action_type<>'MIGRATE' AND a.created_at >= (NOW() - INTERVAL @d DAY)" + sf +
                    " GROUP BY a.performed_by ORDER BY n DESC LIMIT 5", conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    using (var rdr = cmd.ExecuteReader())
                        while (rdr.Read()) topEditors.Add(new object[] { ToStr(rdr["performed_by"]), ToInt(rdr["n"]) });
                }
            }
            stats["days"] = d;
            stats["by_action"] = byAction;
            stats["top_editors"] = topEditors;
            return Json.Serialize(new { success = true, stats = stats });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    [WebMethod(EnableSession = true)]
    public static string GetMarkAuditFeed(string days, string action, string q, string regno, string course, string limit)
    {
        try
        {
            int d; if (!int.TryParse(days, out d) || d <= 0) d = 90;
            int lim; if (!int.TryParse(limit, out lim) || (lim != 50 && lim != 100 && lim != 200 && lim != 500)) lim = 100;
            action = (action ?? "").Trim().ToUpperInvariant();
            q = (q ?? "").Trim();
            regno = (regno ?? "").Trim();
            course = (course ?? "").Trim();
            MarksScope scope = MarksScopeResolver.Resolve();
            string sf = scope.ProgFilter("s", "progid");

            string cond = " AND a.created_at >= (NOW() - INTERVAL @d DAY)";
            if (action == "CHANGES") cond += " AND a.action_type IN ('INSERT','UPDATE','DELETE')";
            else if (action != "" && action != "ALL") cond += " AND a.action_type=@act";
            if (regno != "") cond += " AND a.regno=@rg";
            if (course != "") cond += " AND a.course_id=@cs";
            if (q != "") cond += " AND (a.regno LIKE @q OR a.course_id LIKE @q OR a.performed_by LIKE @q OR TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) LIKE @q)";

            var rows = new List<Dictionary<string, object>>();
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT a.audit_id, a.action_type, a.performed_by, a.regno, a.course_id, a.acad_year, a.semester, " +
                    " a.old_total, a.new_total, a.old_grade, a.new_grade, a.change_reason, a.source_page, a.ip_address, " +
                    " DATE_FORMAT(a.created_at,'%d %b %Y %H:%i') AS ts, " +
                    " TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student, " +
                    " COALESCE(c.courseName, a.course_id) AS course_name " +
                    "FROM campus_dynamics.acad_marks_audit a " +
                    "LEFT JOIN campus_dynamics.acad_student s ON s.regno = a.regno " +
                    "LEFT JOIN campus_dynamics.acad_course c ON c.courseID = a.course_id " +
                    "WHERE a.target_table='acad_results'" + sf + cond +
                    " ORDER BY a.created_at DESC, a.audit_id DESC LIMIT " + lim, conn))
                {
                    cmd.Parameters.AddWithValue("@d", d);
                    if (action != "" && action != "ALL" && action != "CHANGES") cmd.Parameters.AddWithValue("@act", action);
                    if (regno != "") cmd.Parameters.AddWithValue("@rg", regno);
                    if (course != "") cmd.Parameters.AddWithValue("@cs", course);
                    if (q != "") cmd.Parameters.AddWithValue("@q", "%" + q + "%");
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            var m = new Dictionary<string, object>();
                            m["id"] = ToInt(rdr["audit_id"]);
                            m["action"] = ToStr(rdr["action_type"]);
                            m["actor"] = ToStr(rdr["performed_by"]);
                            m["regno"] = ToStr(rdr["regno"]);
                            m["student"] = ToStr(rdr["student"], "");
                            m["course"] = ToStr(rdr["course_id"]);
                            m["course_name"] = ToStr(rdr["course_name"], "");
                            m["acad"] = ToStr(rdr["acad_year"], "");
                            m["sem"] = ToStr(rdr["semester"], "");
                            m["old_total"] = rdr["old_total"] == DBNull.Value ? null : (object)ToInt(rdr["old_total"]);
                            m["new_total"] = rdr["new_total"] == DBNull.Value ? null : (object)ToInt(rdr["new_total"]);
                            m["old_grade"] = ToStr(rdr["old_grade"], "");
                            m["new_grade"] = ToStr(rdr["new_grade"], "");
                            m["reason"] = ToStr(rdr["change_reason"], "");
                            m["source"] = ToStr(rdr["source_page"], "");
                            m["ip"] = ToStr(rdr["ip_address"], "");
                            m["ts"] = ToStr(rdr["ts"], "");
                            rows.Add(m);
                        }
                    }
                }
            }
            return Json.Serialize(new { success = true, rows = rows });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ===================================================================
    //  AI INSIGHTS — executive analysis of the provisional-marks pipeline.
    //  Rule-based highlights / risks / recommendations always; an executive
    //  narrative from Claude when configured (web.config Anthropic.ApiKey),
    //  otherwise a locally-generated summary. Scope-aware; loads async.
    // ===================================================================
    [WebMethod(EnableSession = true)]
    public static string GetAiInsights(string year, string semester, string programme)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            DashboardStats st;
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                st = BuildStats(conn, year, semester, programme, scope);
            }

            int total = st.marksRecords, published = st.publishedCount, pending = st.pendingCount;
            int ready = st.readyCount, noMarks = st.noMarksCount, rejected = st.rejectedCount;
            int missing = st.missingCourseworkCount + st.missingExamCount;
            double pubPct = total > 0 ? (published * 100.0 / total) : 0;

            var highlights = new List<string>();
            var risks = new List<string>();
            var recs = new List<string>();

            highlights.Add(string.Format("{0:0.0}% published ({1:n0} of {2:n0} records)", pubPct, published, total));
            if (ready > 0) highlights.Add(string.Format("{0:n0} record(s) reviewed & ready to publish now", ready));
            highlights.Add(string.Format("{0:n0} active students across {1:n0} programmes", st.activeStudents, st.progCount));

            if (total > 0 && pubPct < 60) risks.Add(string.Format("Low completion — only {0:0.0}% of marks are published", pubPct));
            if (noMarks > 0) risks.Add(string.Format("{0:n0} registration(s) have NO marks entered yet", noMarks));
            if (pending > 0) risks.Add(string.Format("{0:n0} record(s) awaiting review/approval (backlog)", pending));
            if (rejected > 0) risks.Add(string.Format("{0:n0} record(s) rejected and need re-work", rejected));

            string laggard = null;
            if (st.facultyStats != null)
                foreach (GroupStat g in st.facultyStats)
                {
                    if (g.total <= 0) continue;
                    if (laggard == null) laggard = g.name;   // list is ordered ASC by completion
                    double gp = g.published * 100.0 / g.total;
                    if (gp < 50 && risks.Count < 6) risks.Add(string.Format("{0}: {1:0}% published ({2:n0}/{3:n0})", g.name, gp, g.published, g.total));
                }

            if (ready > 0) recs.Add(string.Format("Publish the {0:n0} ready record(s) to update transcripts & GPA", ready));
            if (pending > 0) recs.Add(string.Format("Clear the review backlog of {0:n0} pending record(s)", pending));
            if (noMarks > 0) recs.Add(string.Format("Chase lecturers for {0:n0} un-entered mark(s)", noMarks));
            if (st.topMissingCourses != null && st.topMissingCourses.Count > 0)
                recs.Add(string.Format("Prioritise '{0}' — {1:n0} student(s) with incomplete marks", st.topMissingCourses[0].course, st.topMissingCourses[0].missingCount));
            if (laggard != null) recs.Add(string.Format("Follow up {0} (lowest completion)", laggard));
            if (recs.Count == 0) recs.Add("Pipeline is healthy — keep publishing reviewed marks promptly.");

            string scopeLabel = scope.IsAdmin ? "the whole university" : (string.IsNullOrEmpty(scope.Label) ? "your scope" : scope.Label);
            string prompt =
                "Provisional-marks pipeline snapshot (scope: " + scopeLabel + "):\n"
                + "- Total registrations: " + total + "\n"
                + "- Published: " + published + " (" + pubPct.ToString("0.0") + "%)\n"
                + "- Reviewed & ready to publish: " + ready + "\n"
                + "- Pending review/approval: " + pending + "\n"
                + "- Rejected: " + rejected + "\n"
                + "- No marks entered: " + noMarks + "\n"
                + "- Incomplete (missing CW or Exam): " + missing + "\n"
                + "- Active students: " + st.activeStudents + "; programmes: " + st.progCount + "\n"
                + BuildLaggards(st.facultyStats);

            string sys = "You are the academic registrar's analytics assistant at Muteesa I Royal University (MRU). "
                + "Given a provisional-marks pipeline snapshot, write a crisp 3-5 sentence executive insight for senior "
                + "management: overall completion health, the biggest bottleneck/risk, and the single highest-impact next "
                + "action. Use the actual numbers and percentages. Plain prose only — no markdown, no headings, no lists.";

            string aiText = CallClaude(sys, prompt);
            bool byAi = !string.IsNullOrEmpty(aiText);
            string narrative = byAi ? aiText.Trim()
                : GenNarrative(pubPct, published, total, ready, pending, noMarks, laggard);
            string poweredBy = byAi ? ("Claude · " + CurrentModel()) : "MRU analytics engine";

            return Json.Serialize(new
            {
                success = true,
                powered_by = poweredBy,
                narrative = narrative,
                highlights = highlights,
                risks = risks,
                recommendations = recs
            });
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = ex.Message });
        }
    }

    private static string BuildLaggards(List<GroupStat> g)
    {
        if (g == null || g.Count == 0) return "";
        StringBuilder sb = new StringBuilder("Lowest-completion faculties:\n");
        int n = 0;
        foreach (GroupStat x in g)
        {
            if (x.total <= 0) continue;
            sb.Append("- ").Append(x.name).Append(": ")
              .Append((x.published * 100.0 / x.total).ToString("0")).Append("% (")
              .Append(x.published).Append("/").Append(x.total).Append(")\n");
            if (++n >= 4) break;
        }
        return sb.ToString();
    }

    private static string GenNarrative(double pubPct, int published, int total, int ready, int pending, int noMarks, string laggard)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append(total == 0
            ? "No marks records fall within the selected scope yet."
            : string.Format("Completion stands at {0:0.0}% — {1:n0} of {2:n0} registrations have published results.", pubPct, published, total));
        if (ready > 0) sb.Append(string.Format(" {0:n0} reviewed record(s) are ready to publish immediately.", ready));
        if (noMarks > 0 || pending > 0)
        {
            sb.Append(" ");
            if (noMarks > 0) sb.Append(string.Format("{0:n0} registration(s) still have no marks entered", noMarks));
            if (pending > 0) sb.Append(string.Format("{0} {1:n0} await review", noMarks > 0 ? " and" : "", pending));
            sb.Append(".");
        }
        if (!string.IsNullOrEmpty(laggard)) sb.Append(string.Format(" {0} has the lowest completion and needs the most attention.", laggard));
        if (ready > 0) sb.Append(" Highest-impact next step: publish the ready records to update transcripts and GPA.");
        else if (pending > 0) sb.Append(" Highest-impact next step: clear the review backlog.");
        else if (noMarks > 0) sb.Append(" Highest-impact next step: chase the outstanding mark entries.");
        return sb.ToString();
    }

    private static string CurrentModel()
    {
        string m = (WebConfigurationManager.AppSettings["Anthropic.Model"] ?? "").Trim();
        return string.IsNullOrEmpty(m) ? "claude-sonnet-4-6" : m;
    }

    // Calls the Anthropic Messages API for a short narrative. Returns null on any
    // failure or when no key is configured (caller falls back to a local narrative).
    private static string CallClaude(string systemPrompt, string userContent)
    {
        string key = (WebConfigurationManager.AppSettings["Anthropic.ApiKey"] ?? "").Trim();
        if (string.IsNullOrEmpty(key)) return null;
        string baseUrl = (WebConfigurationManager.AppSettings["Anthropic.ApiBase"] ?? "https://api.anthropic.com").Trim().TrimEnd('/');
        try
        {
            JavaScriptSerializer jss = new JavaScriptSerializer();
            Dictionary<string, object> msg = new Dictionary<string, object>();
            msg["role"] = "user"; msg["content"] = userContent;
            Dictionary<string, object> body = new Dictionary<string, object>();
            body["model"] = CurrentModel();
            body["max_tokens"] = 500;
            body["system"] = systemPrompt;
            body["messages"] = new object[] { msg };
            byte[] data = Encoding.UTF8.GetBytes(jss.Serialize(body));

            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(baseUrl + "/v1/messages");
            req.Method = "POST";
            req.ContentType = "application/json";
            req.Timeout = 45000;
            req.ReadWriteTimeout = 45000;
            req.Headers["x-api-key"] = key;
            req.Headers["anthropic-version"] = "2023-06-01";
            req.ContentLength = data.Length;
            using (Stream s = req.GetRequestStream()) s.Write(data, 0, data.Length);

            string json;
            using (HttpWebResponse resp = (HttpWebResponse)req.GetResponse())
            using (StreamReader rd = new StreamReader(resp.GetResponseStream()))
                json = rd.ReadToEnd();

            Dictionary<string, object> parsed = jss.Deserialize<Dictionary<string, object>>(json);
            object contentObj;
            if (parsed != null && parsed.TryGetValue("content", out contentObj))
            {
                object[] blocks = contentObj as object[];
                if (blocks != null && blocks.Length > 0)
                {
                    Dictionary<string, object> block = blocks[0] as Dictionary<string, object>;
                    if (block != null && block.ContainsKey("text"))
                    {
                        string t = Convert.ToString(block["text"]);
                        if (!string.IsNullOrEmpty(t)) return t;
                    }
                }
            }
            return null;
        }
        catch { return null; }
    }

    private static DashboardStats BuildStats(MySqlConnection conn, string year, string semester, string programme, MarksScope scope)
    {
        string courseExpr = GetCourseColumnExpression(conn, "cr");
        string courseCountSql = string.IsNullOrEmpty(courseExpr) ? "0" : "COUNT(DISTINCT " + courseExpr + ")";

        // Server-enforced scope predicate (cannot be widened from the client).
        // Exam stats consider ONLY active (onboarded) students — see ActiveStudentFilter.
        // (narrows the existing stud_status='ACTIVE' join, which still counted alumni.)
        string scopeFilter = scope.ProgFilter("cr") + ActiveStudentFilter.Clause("cr.regno");

        // Build WHERE clause — applied to every query in this method
        string where = "WHERE 1=1" + scopeFilter;
        if (!string.IsNullOrEmpty(year))      where += " AND cr.acad_year = @year";
        if (!string.IsNullOrEmpty(semester))  where += " AND CAST(cr.semester AS CHAR) = @semester";
        if (!string.IsNullOrEmpty(programme)) where += " AND cr.prog_id = @programme";

        // ── Main query: ALL stats restricted to active students via INNER JOIN ──
        // Published rows are counted as final regardless of whether CW or Exam marks are NULL.
        string mainSql = @"
            SELECT
                COUNT(DISTINCT cr.regno)                                                                              AS active_students,
                COUNT(*)                                                                                              AS marks_records,
                " + courseCountSql + @"                                                                               AS course_count,
                COUNT(DISTINCT cr.prog_id)                                                                            AS prog_count,
                SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') = 'published'                      THEN 1 ELSE 0 END) AS published_count,
                SUM(CASE WHEN cr.provisional_marks_status = 'approved'                                    THEN 1 ELSE 0 END) AS approved_count,
                SUM(CASE WHEN cr.provisional_marks_status = 'rejected'                                    THEN 1 ELSE 0 END) AS rejected_count,
                SUM(CASE WHEN (cr.provisional_course_work_marks IS NOT NULL OR cr.provisional_exam_marks IS NOT NULL)
                              AND COALESCE(cr.provisional_marks_status,'pending') = 'pending'              THEN 1 ELSE 0 END) AS pending_count,
                SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL
                              AND COALESCE(cr.provisional_marks_status,'') <> 'published'                  THEN 1 ELSE 0 END) AS no_marks_count,
                SUM(CASE WHEN cr.provisional_course_work_marks IS NOT NULL AND cr.provisional_exam_marks IS NOT NULL
                              AND COALESCE(cr.provisional_marks_status,'pending') NOT IN ('published','rejected') THEN 1 ELSE 0 END) AS ready_count,
                SUM(CASE WHEN cr.provisional_course_work_marks IS NULL
                              AND COALESCE(cr.provisional_marks_status,'') <> 'published'                  THEN 1 ELSE 0 END) AS missing_cw,
                SUM(CASE WHEN cr.provisional_exam_marks IS NULL
                              AND COALESCE(cr.provisional_marks_status,'') <> 'published'                  THEN 1 ELSE 0 END) AS missing_exam
            FROM campus_dynamics_portal.acad_course_registration cr
            INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
            " + where;

        var stats = new DashboardStats();

        using (MySqlCommand cmd = new MySqlCommand(mainSql, conn))
        {
            if (!string.IsNullOrEmpty(year))      cmd.Parameters.AddWithValue("@year",      year);
            if (!string.IsNullOrEmpty(semester))  cmd.Parameters.AddWithValue("@semester",  semester);
            if (!string.IsNullOrEmpty(programme)) cmd.Parameters.AddWithValue("@programme", programme);

            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                if (rdr.Read())
                {
                    stats.activeStudents         = ToInt(rdr["active_students"]);
                    stats.marksRecords           = ToInt(rdr["marks_records"]);
                    stats.courseCount            = ToInt(rdr["course_count"]);
                    stats.progCount              = ToInt(rdr["prog_count"]);
                    stats.publishedCount         = ToInt(rdr["published_count"]);
                    stats.approvedCount          = ToInt(rdr["approved_count"]);
                    stats.rejectedCount          = ToInt(rdr["rejected_count"]);
                    stats.pendingCount           = ToInt(rdr["pending_count"]);
                    stats.noMarksCount           = ToInt(rdr["no_marks_count"]);
                    stats.readyCount             = ToInt(rdr["ready_count"]);
                    stats.missingCourseworkCount = ToInt(rdr["missing_cw"]);
                    stats.missingExamCount       = ToInt(rdr["missing_exam"]);
                }
            }
        }

        // ── Top 10 courses with incomplete marks (active students, excluding published) ──
        if (!string.IsNullOrEmpty(courseExpr))
        {
            string topSql = @"
                SELECT " + courseExpr + @" AS course,
                       COALESCE(c.courseName, " + courseExpr + @") AS course_name,
                       COUNT(*) AS missing_count,
                       COUNT(DISTINCT cr.regno) AS students_affected
                FROM campus_dynamics_portal.acad_course_registration cr
                INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                LEFT JOIN acad_course c ON c.courseID = " + courseExpr + @"
                WHERE (cr.provisional_course_work_marks IS NULL OR cr.provisional_exam_marks IS NULL)
                  AND COALESCE(cr.provisional_marks_status,'') <> 'published'" + scopeFilter +
                (string.IsNullOrEmpty(year)      ? "" : " AND cr.acad_year = @year") +
                (string.IsNullOrEmpty(semester)  ? "" : " AND CAST(cr.semester AS CHAR) = @semester") +
                (string.IsNullOrEmpty(programme) ? "" : " AND cr.prog_id = @programme") +
                " GROUP BY " + courseExpr + @", c.courseName ORDER BY missing_count DESC LIMIT 25";

            using (MySqlCommand cmd2 = new MySqlCommand(topSql, conn))
            {
                if (!string.IsNullOrEmpty(year))      cmd2.Parameters.AddWithValue("@year",      year);
                if (!string.IsNullOrEmpty(semester))  cmd2.Parameters.AddWithValue("@semester",  semester);
                if (!string.IsNullOrEmpty(programme)) cmd2.Parameters.AddWithValue("@programme", programme);

                stats.topMissingCourses = new List<TopCourse>();
                using (MySqlDataReader rdrTop = cmd2.ExecuteReader())
                {
                    while (rdrTop.Read())
                    {
                        stats.topMissingCourses.Add(new TopCourse
                        {
                            course           = ToStr(rdrTop["course"]),
                            courseName       = ToStr(rdrTop["course_name"]),
                            missingCount     = ToInt(rdrTop["missing_count"]),
                            studentsAffected = ToInt(rdrTop["students_affected"])
                        });
                    }
                }
            }
        }

        // ── Stats by programme (all programmes, same active-student + scope filters) ──
        // Wrap in subquery so ORDER BY sees plain columns, not aggregate expressions (MySQL limitation)
        string progSql = @"
            SELECT * FROM (
                SELECT cr.prog_id,
                       COALESCE(p.progname, cr.prog_id)                                                                       AS prog_name,
                       COUNT(DISTINCT cr.regno)                                                                               AS students,
                       COUNT(*)                                                                                               AS total,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') = 'published' THEN 1 ELSE 0 END)               AS published,
                       SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL
                                     AND COALESCE(cr.provisional_marks_status,'') <> 'published' THEN 1 ELSE 0 END)           AS no_marks,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') <> 'published'
                                     AND (cr.provisional_course_work_marks IS NULL OR cr.provisional_exam_marks IS NULL) THEN 1 ELSE 0 END) AS missing
                FROM campus_dynamics_portal.acad_course_registration cr
                INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                LEFT JOIN acad_programme p ON p.progcode = cr.prog_id
                " + where + @"
                GROUP BY cr.prog_id, p.progname
            ) prog_data
            ORDER BY IF(total > 0, published / total, 0) ASC, total DESC";

        using (MySqlCommand cmd3 = new MySqlCommand(progSql, conn))
        {
            if (!string.IsNullOrEmpty(year))      cmd3.Parameters.AddWithValue("@year",      year);
            if (!string.IsNullOrEmpty(semester))  cmd3.Parameters.AddWithValue("@semester",  semester);
            if (!string.IsNullOrEmpty(programme)) cmd3.Parameters.AddWithValue("@programme", programme);

            stats.programmeStats = new List<ProgrammeStat>();
            using (MySqlDataReader rdrProg = cmd3.ExecuteReader())
            {
                while (rdrProg.Read())
                {
                    stats.programmeStats.Add(new ProgrammeStat
                    {
                        progCode  = ToStr(rdrProg["prog_id"]),
                        progName  = ToStr(rdrProg["prog_name"]),
                        students  = ToInt(rdrProg["students"]),
                        total     = ToInt(rdrProg["total"]),
                        published = ToInt(rdrProg["published"]),
                        noMarks   = ToInt(rdrProg["no_marks"]),
                        missing   = ToInt(rdrProg["missing"])
                    });
                }
            }
        }

        // ── Stats by FACULTY (active students, same scope + filters) ──────────
        stats.facultyStats  = BuildGroupStats(conn, where, year, semester, programme, true);
        // ── Stats by DEPARTMENT ───────────────────────────────────────────────
        stats.departmentStats = BuildGroupStats(conn, where, year, semester, programme, false);

        return stats;
    }

    /// <summary>
    /// Marks progress grouped by faculty (byFaculty=true) or department (false),
    /// resolved from acad_programme. Reuses the same active-student + scope WHERE.
    /// </summary>
    private static List<GroupStat> BuildGroupStats(MySqlConnection conn, string where,
        string year, string semester, string programme, bool byFaculty)
    {
        string keyExpr  = byFaculty ? "IFNULL(p.faculty_code,'')" : "CAST(IFNULL(p.department_id,0) AS CHAR)";
        string nameExpr = byFaculty
            ? "COALESCE(NULLIF(f.faculty_name,''), '(Unassigned faculty)')"
            : "COALESCE(NULLIF(d.dept_name,''), '(Unassigned department)')";
        string joinExpr = byFaculty
            ? "LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code"
            : "LEFT JOIN hrm_departments d ON d.ID = p.department_id";

        string sql = @"
            SELECT * FROM (
                SELECT " + keyExpr + @" AS gkey,
                       " + nameExpr + @" AS gname,
                       COUNT(DISTINCT cr.regno)                                                                       AS students,
                       COUNT(*)                                                                                       AS total,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') = 'published' THEN 1 ELSE 0 END)        AS published,
                       SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL
                                     AND COALESCE(cr.provisional_marks_status,'') <> 'published' THEN 1 ELSE 0 END)    AS no_marks,
                       SUM(CASE WHEN COALESCE(cr.provisional_marks_status,'') <> 'published'
                                     AND (cr.provisional_course_work_marks IS NULL OR cr.provisional_exam_marks IS NULL) THEN 1 ELSE 0 END) AS missing
                FROM campus_dynamics_portal.acad_course_registration cr
                INNER JOIN campus_dynamics.acad_student s ON s.regno = cr.regno AND s.stud_status = 'ACTIVE'
                LEFT JOIN acad_programme p ON p.progcode = cr.prog_id
                " + joinExpr + @"
                " + where + @"
                GROUP BY gkey, gname
            ) g
            ORDER BY IF(total > 0, published / total, 0) ASC, total DESC";

        var list = new List<GroupStat>();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (!string.IsNullOrEmpty(year))      cmd.Parameters.AddWithValue("@year",      year);
            if (!string.IsNullOrEmpty(semester))  cmd.Parameters.AddWithValue("@semester",  semester);
            if (!string.IsNullOrEmpty(programme)) cmd.Parameters.AddWithValue("@programme", programme);

            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    list.Add(new GroupStat
                    {
                        name      = ToStr(rdr["gname"]),
                        students  = ToInt(rdr["students"]),
                        total     = ToInt(rdr["total"]),
                        published = ToInt(rdr["published"]),
                        noMarks   = ToInt(rdr["no_marks"]),
                        missing   = ToInt(rdr["missing"])
                    });
                }
            }
        }
        return list;
    }

    private static int ToInt(object value)
    {
        return value == null || value == DBNull.Value ? 0 : Convert.ToInt32(value);
    }

    private static string ToStr(object value, string fallback = "-")
    {
        return value == null || value == DBNull.Value ? fallback : value.ToString();
    }

    private static string GetConnStr()
    {
        return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    }

    private static string GetCourseColumnExpression(MySqlConnection conn, string alias)
    {
        string prefix = string.IsNullOrEmpty(alias) ? string.Empty : alias + ".";
        if (ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "courseID"))
            return prefix + "courseID";
        if (ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "course_code"))
            return prefix + "course_code";
        return null;
    }

    private static bool ColumnExists(MySqlConnection conn, string schema, string table, string column)
    {
        const string sql = @"SELECT COUNT(*) FROM information_schema.COLUMNS
                             WHERE TABLE_SCHEMA=@schema AND TABLE_NAME=@table AND COLUMN_NAME=@column";
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@schema", schema);
            cmd.Parameters.AddWithValue("@table", table);
            cmd.Parameters.AddWithValue("@column", column);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    private class FilterOption { public string value { get; set; } public string text { get; set; } }

    private class TopCourse
    {
        public string course           { get; set; }
        public string courseName       { get; set; }
        public int    missingCount     { get; set; }
        public int    studentsAffected { get; set; }
    }

    private class ProgrammeStat
    {
        public string progCode  { get; set; }
        public string progName  { get; set; }
        public int    students  { get; set; }
        public int    total     { get; set; }
        public int    published { get; set; }
        public int    noMarks   { get; set; }
        public int    missing   { get; set; }
    }

    private class GroupStat
    {
        public string name      { get; set; }
        public int    students  { get; set; }
        public int    total     { get; set; }
        public int    published { get; set; }
        public int    noMarks   { get; set; }
        public int    missing   { get; set; }
    }

    private class DashboardStats
    {
        public int activeStudents         { get; set; }
        public int marksRecords           { get; set; }
        public int courseCount            { get; set; }
        public int progCount              { get; set; }
        public int publishedCount         { get; set; }
        public int approvedCount          { get; set; }
        public int rejectedCount          { get; set; }
        public int pendingCount           { get; set; }
        public int noMarksCount           { get; set; }
        public int readyCount             { get; set; }
        public int missingCourseworkCount { get; set; }
        public int missingExamCount       { get; set; }
        public List<TopCourse>     topMissingCourses { get; set; }
        public List<ProgrammeStat> programmeStats    { get; set; }
        public List<GroupStat>     facultyStats      { get; set; }
        public List<GroupStat>     departmentStats   { get; set; }
    }
}
