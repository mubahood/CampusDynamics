using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Teacher Dashboard — primary teacher-facing page for marks management.
///
/// Shows:
///   - Assigned courses with completion ratios
///   - Deadline countdowns per course
///   - Status indicators (Draft/Submitted/Approved/Published)
///   - Quick links to mark entry and submit actions
///
/// AJAX Endpoints:
///   ?ajax=init       — teacher name, available years, current period
///   ?ajax=dashboard  — full dashboard data (courses, stats, deadlines)
///   ?ajax=submit     — POST: submit a sheet for Dean approval
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Task: E-01
/// </summary>
public partial class COOPERP_NewScreens_TeacherDashboard : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureTables();

        // Session integrity check (C-05)
        string sessionErr = MarksSessionSecurity.ValidateSessionIntegrity();
        if (sessionErr != null)
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write("{\"error\":\"" + JsEsc(sessionErr) + "\"}");
            Response.End();
            return;
        }

        // Any logged-in user with mark-entry roles can view the dashboard
        if (!MarksAuthorizationService.CanEnterMarks() && !MarksAuthorizationService.CanApproveMarks())
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write("{\"error\":\"Access denied. You do not have marks module access.\"}");
            Response.End();
            return;
        }

        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        System.Diagnostics.Stopwatch _actionTimer = MarksActionLogger.StartTimer();
        string _actionOutcome = MarksActionLogger.OUTCOME_SUCCESS;

        try
        {
            // CSRF validation for write operations
            if (ajax == "submit")
            {
                if (!MarksAntiForgeryService.ValidateRequest())
                {
                    _actionOutcome = MarksActionLogger.OUTCOME_AUTH_FAIL;
                    MarksAntiForgeryService.RejectRequest(Response);
                    return;
                }
            }

            if (ajax == "init")      { HandleInit(); return; }
            if (ajax == "dashboard") { HandleDashboard(); return; }
            if (ajax == "submit")    { HandleSubmit(); return; }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            _actionOutcome = MarksActionLogger.OUTCOME_ERROR;
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write(MarksErrorHandler.HandleException(ex, "TeacherDashboard", ajax));
            Response.End();
        }
        finally
        {
            MarksActionLogger.StopAndLog(_actionTimer, "TeacherDashboard", ajax, _actionOutcome, null, null);
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Init (?ajax=init)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleInit()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        try
        {
            string user = MarksAuthorizationService.GetCurrentUser();
            string teacherName = user;

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Get teacher display name
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT COALESCE(emp_name, '') AS display
                      FROM hrm_employee WHERE usernames = @u LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@u", user);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string name = result.ToString().Trim();
                        if (!string.IsNullOrEmpty(name)) teacherName = name;
                    }
                }

                // Get available academic years
                StringBuilder json = new StringBuilder("{");
                json.AppendFormat("\"teacher_name\":\"{0}\",", JsEsc(teacherName));

                // Current year/semester guess (latest assignment)
                string currentYear = "";
                int currentSem = 1;
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT acadyear, semester FROM acad_teaching_assignments
                      WHERE teacher_username = @u AND is_active = 1
                      ORDER BY acadyear DESC, semester DESC LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@u", user);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            currentYear = rdr["acadyear"].ToString();
                            currentSem = Convert.ToInt32(rdr["semester"]);
                        }
                    }
                }

                // Fallback: get latest year from acad_acadyear
                if (string.IsNullOrEmpty(currentYear))
                {
                    using (MySqlCommand cmd = new MySqlCommand(
                        "SELECT acad_year FROM acad_acadyear ORDER BY acad_year DESC LIMIT 1", conn))
                    {
                        object r = cmd.ExecuteScalar();
                        if (r != null) currentYear = r.ToString();
                    }
                }

                json.AppendFormat("\"current_year\":\"{0}\",", JsEsc(currentYear));
                json.AppendFormat("\"current_sem\":{0},", currentSem);

                json.Append("\"years\":[");
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT DISTINCT acad_year AS val FROM acad_acadyear ORDER BY acad_year DESC LIMIT 10", conn))
                {
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat("{{\"val\":\"{0}\"}}", JsEsc(rdr["val"].ToString()));
                        }
                    }
                }
                json.Append("]");
                json.Append("}");
                Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Dashboard (?ajax=dashboard&year=...&sem=...)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleDashboard()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        string year = (Request.QueryString["year"] ?? "").Trim();
        int sem = 0;
        Int32.TryParse(Request.QueryString["sem"] ?? "1", out sem);
        if (sem <= 0) sem = 1;

        string user = MarksAuthorizationService.GetCurrentUser();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                StringBuilder json = new StringBuilder("{\"courses\":[");

                int totalCourses = 0, marksComplete = 0, pendingEntry = 0, submitted = 0;
                int? nearestDeadline = null;

                // Get teacher's assignments for this period
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT ta.course_id, ta.progid, ta.study_year, ta.campus_id, ta.stud_session,
                             COALESCE(c.CourseName, ta.course_id) AS course_name,
                             COALESCE(p.progname, ta.progid) AS prog_name,
                             COALESCE(cam.campusName, '') AS campus_name
                      FROM acad_teaching_assignments ta
                      LEFT JOIN acad_courses c ON c.CourseCode = ta.course_id
                      LEFT JOIN acad_programme p ON p.progcode = ta.progid
                      LEFT JOIN acad_campus cam ON cam.campusid = ta.campus_id
                      WHERE ta.teacher_username = @user
                        AND ta.acadyear = @year
                        AND ta.semester = @sem
                        AND ta.is_active = 1
                      ORDER BY ta.study_year, ta.course_id", conn))
                {
                    cmd.Parameters.AddWithValue("@user", user);
                    cmd.Parameters.AddWithValue("@year", year);
                    cmd.Parameters.AddWithValue("@sem", sem);

                    // We need to buffer the assignments since we'll do sub-queries per course
                    List<Dictionary<string, object>> assignments = new List<Dictionary<string, object>>();
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            Dictionary<string, object> a = new Dictionary<string, object>();
                            a["course_id"] = rdr["course_id"].ToString();
                            a["progid"] = rdr["progid"].ToString();
                            a["study_year"] = Convert.ToInt32(rdr["study_year"]);
                            a["campus_id"] = Convert.ToInt32(rdr["campus_id"]);
                            a["stud_session"] = rdr["stud_session"].ToString();
                            a["course_name"] = rdr["course_name"].ToString();
                            a["prog_name"] = rdr["prog_name"].ToString();
                            a["campus_name"] = rdr["campus_name"].ToString();
                            assignments.Add(a);
                        }
                    }

                    bool firstCourse = true;
                    foreach (var a in assignments)
                    {
                        if (!firstCourse) json.Append(",");
                        firstCourse = false;
                        totalCourses++;

                        string courseId = a["course_id"].ToString();
                        string progId = a["progid"].ToString();
                        int studyYear = (int)a["study_year"];
                        int campusId = (int)a["campus_id"];
                        string session = a["stud_session"].ToString();

                        // Expected students count
                        int expected = 0;
                        using (MySqlCommand cntCmd = new MySqlCommand(
                            @"SELECT COUNT(*) FROM acad_examsheet
                              WHERE CourseCode = @c AND progid = @p
                                AND acadyear = @y AND semester = @s", conn))
                        {
                            cntCmd.Parameters.AddWithValue("@c", courseId);
                            cntCmd.Parameters.AddWithValue("@p", progId);
                            cntCmd.Parameters.AddWithValue("@y", year);
                            cntCmd.Parameters.AddWithValue("@s", sem);
                            expected = Convert.ToInt32(cntCmd.ExecuteScalar());
                        }

                        // Entered count (where at least one mark is non-null)
                        int entered = 0;
                        using (MySqlCommand entCmd = new MySqlCommand(
                            @"SELECT COUNT(*) FROM acad_examsheet
                              WHERE CourseCode = @c AND progid = @p
                                AND acadyear = @y AND semester = @s
                                AND (coursework IS NOT NULL OR test IS NOT NULL OR exam IS NOT NULL)", conn))
                        {
                            entCmd.Parameters.AddWithValue("@c", courseId);
                            entCmd.Parameters.AddWithValue("@p", progId);
                            entCmd.Parameters.AddWithValue("@y", year);
                            entCmd.Parameters.AddWithValue("@s", sem);
                            entered = Convert.ToInt32(entCmd.ExecuteScalar());
                        }

                        // Get status
                        string status = ResultsStatusService.GetStatus(courseId, progId, year, sem,
                            studyYear, campusId, session);

                        // Get reject reason if any
                        string rejectReason = "";
                        ResultsStatusService.StatusInfo statusInfo = ResultsStatusService.GetStatusInfo(
                            courseId, progId, year, sem, studyYear, campusId, session);
                        if (statusInfo.RejectReason != null) rejectReason = statusInfo.RejectReason;

                        // Update stats
                        if (entered >= expected && expected > 0) marksComplete++;
                        if (status == "DRAFT" && entered < expected) pendingEntry++;
                        if (status == "SUBMITTED") submitted++;

                        // Deadline info
                        int? daysLeft = null;
                        MarksDeadlineService.DeadlineInfo dlInfo = MarksDeadlineService.GetDeadlineInfo(
                            "COURSEWORK", campusId, year, sem, session);
                        if (dlInfo != null)
                        {
                            daysLeft = dlInfo.DaysRemaining;
                            if (nearestDeadline == null || daysLeft < nearestDeadline) nearestDeadline = daysLeft;
                        }

                        // Grade distribution (Batch 11)
                        List<string> gradeDist = new List<string>();
                        using (MySqlCommand gdCmd = new MySqlCommand(
                            @"SELECT grade, COUNT(*) AS cnt
                              FROM acad_examresults_faculty
                              WHERE course_id = @c AND progid = @p AND acad_year = @y
                                AND semester = @s AND study_year = @sy
                                AND campus = @campus AND stud_session = @sess
                                AND grade IS NOT NULL AND grade <> ''
                              GROUP BY grade
                              ORDER BY grade", conn))
                        {
                            gdCmd.Parameters.AddWithValue("@c",      courseId);
                            gdCmd.Parameters.AddWithValue("@p",      progId);
                            gdCmd.Parameters.AddWithValue("@y",      year);
                            gdCmd.Parameters.AddWithValue("@s",      sem);
                            gdCmd.Parameters.AddWithValue("@sy",     studyYear);
                            gdCmd.Parameters.AddWithValue("@campus", campusId);
                            gdCmd.Parameters.AddWithValue("@sess",   session);
                            using (MySqlDataReader gdRdr = gdCmd.ExecuteReader())
                            {
                                while (gdRdr.Read())
                                {
                                    gradeDist.Add(String.Format("{{\"g\":\"{0}\",\"n\":{1}}}",
                                        JsEsc(gdRdr["grade"].ToString()),
                                        Convert.ToInt32(gdRdr["cnt"])));
                                }
                            }
                        }

                        // Build course JSON
                        json.Append("{");
                        json.AppendFormat("\"course_id\":\"{0}\",", JsEsc(courseId));
                        json.AppendFormat("\"course_name\":\"{0}\",", JsEsc(a["course_name"].ToString()));
                        json.AppendFormat("\"prog_id\":\"{0}\",", JsEsc(progId));
                        json.AppendFormat("\"programme\":\"{0}\",", JsEsc(a["prog_name"].ToString()));
                        json.AppendFormat("\"study_year\":{0},", studyYear);
                        json.AppendFormat("\"campus_id\":{0},", campusId);
                        json.AppendFormat("\"campus_name\":\"{0}\",", JsEsc(a["campus_name"].ToString()));
                        json.AppendFormat("\"session\":\"{0}\",", JsEsc(session));
                        json.AppendFormat("\"acadyear\":\"{0}\",", JsEsc(year));
                        json.AppendFormat("\"semester\":{0},", sem);
                        json.AppendFormat("\"expected_students\":{0},", expected);
                        json.AppendFormat("\"entered_count\":{0},", entered);
                        json.AppendFormat("\"status\":\"{0}\",", JsEsc(status));
                        json.AppendFormat("\"reject_reason\":\"{0}\",", JsEsc(rejectReason));
                        json.AppendFormat("\"days_to_deadline\":{0},", daysLeft.HasValue ? daysLeft.Value.ToString() : "null");
                        json.Append("\"grade_distribution\":[");
                        json.Append(string.Join(",", gradeDist.ToArray()));
                        json.Append("]}");

                    }
                }

                json.Append("],\"stats\":{");
                json.AppendFormat("\"total_courses\":{0},", totalCourses);
                json.AppendFormat("\"marks_complete\":{0},", marksComplete);
                json.AppendFormat("\"pending_entry\":{0},", pendingEntry);
                json.AppendFormat("\"submitted\":{0},", submitted);
                json.AppendFormat("\"nearest_deadline\":{0}", nearestDeadline.HasValue ? nearestDeadline.Value.ToString() : "null");
                json.Append("}}");

                Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"courses\":[],\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Submit for Approval (?ajax=submit, POST)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleSubmit()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);

            string courseId = data.ContainsKey("course_id") ? Convert.ToString(data["course_id"]) : "";
            string progId  = data.ContainsKey("prog_id") ? Convert.ToString(data["prog_id"]) : "";
            int studyYear  = data.ContainsKey("study_year") ? Convert.ToInt32(data["study_year"]) : 1;
            int campusId   = data.ContainsKey("campus_id") ? Convert.ToInt32(data["campus_id"]) : 1;
            string session = data.ContainsKey("session") ? Convert.ToString(data["session"]) : "Day";

            string year = (Request.QueryString["year"] ?? "").Trim();
            int sem = 0;
            Int32.TryParse(Request.QueryString["sem"] ?? "1", out sem);

            // If year/sem not in query string, try to get from the POST body
            if (string.IsNullOrEmpty(year) && data.ContainsKey("acadyear"))
                year = Convert.ToString(data["acadyear"]);
            if (sem <= 0 && data.ContainsKey("semester"))
                sem = Convert.ToInt32(data["semester"]);

            // Use the latest year from the teacher's assignments if still empty
            if (string.IsNullOrEmpty(year))
            {
                string user = MarksAuthorizationService.GetCurrentUser();
                using (MySqlConnection conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (MySqlCommand cmd = new MySqlCommand(
                        @"SELECT acadyear, semester FROM acad_teaching_assignments
                          WHERE teacher_username = @u AND course_id = @c AND progid = @p AND is_active = 1
                          ORDER BY acadyear DESC, semester DESC LIMIT 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@u", user);
                        cmd.Parameters.AddWithValue("@c", courseId);
                        cmd.Parameters.AddWithValue("@p", progId);
                        using (MySqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                year = rdr["acadyear"].ToString();
                                sem = Convert.ToInt32(rdr["semester"]);
                            }
                        }
                    }
                }
            }

            if (string.IsNullOrEmpty(courseId)) throw new Exception("Course is required.");
            if (string.IsNullOrEmpty(year)) throw new Exception("Academic year not determined.");

            var result = ResultsStatusService.Submit(courseId, progId, year, sem, studyYear, campusId, session);
            if (result.Success)
            {
                Response.Write(String.Format("{{\"ok\":true,\"status\":\"{0}\"}}", JsEsc(result.NewStatus)));
            }
            else
            {
                Response.Write(String.Format("{{\"ok\":false,\"error\":\"{0}\"}}", JsEsc(result.Error ?? "Submit failed.")));
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // Table Auto-Migration
    // ═════════════════════════════════════════════════════════════════════

    private void EnsureTables()
    {
        try
        {
            // Ensure teaching assignments table
            string ddl1 = @"CREATE TABLE IF NOT EXISTS acad_teaching_assignments (
                id               INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
                teacher_username VARCHAR(50)     NOT NULL,
                course_id        VARCHAR(25)     NOT NULL,
                progid           VARCHAR(25)     NOT NULL,
                acadyear         VARCHAR(25)     NOT NULL,
                semester         TINYINT UNSIGNED NOT NULL,
                study_year       TINYINT UNSIGNED NOT NULL,
                campus_id        INT UNSIGNED    NOT NULL,
                stud_session     VARCHAR(25)     NOT NULL DEFAULT 'Day',
                assigned_by      VARCHAR(50)     NOT NULL,
                assigned_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
                is_active        TINYINT(1)      NOT NULL DEFAULT 1,
                notes            VARCHAR(250)    DEFAULT NULL,
                UNIQUE KEY uq_assignment (teacher_username, course_id, progid, acadyear, semester, study_year, campus_id, stud_session),
                INDEX idx_teacher_year (teacher_username, acadyear, semester),
                INDEX idx_active (is_active)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(ddl1, conn)) { cmd.ExecuteNonQuery(); }
            }

            // Ensure results status table
            ResultsStatusService.EnsureStatusTable();
            MarksActionLogger.EnsureActionLogTable();
        }
        catch
        {
            // Silently ignore
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // Helpers
    // ═════════════════════════════════════════════════════════════════════

    private static string JsEsc(string val)
    {
        if (string.IsNullOrEmpty(val)) return "";
        return val.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "\\n");
    }
}
