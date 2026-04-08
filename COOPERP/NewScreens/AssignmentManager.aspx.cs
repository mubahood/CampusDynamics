using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Assignment Manager — admin page for managing teacher–course assignments.
/// 
/// AJAX Endpoints (via ?ajax=...):
///   ?ajax=dropdowns          — load programmes, years, teachers, courses, campuses
///   ?ajax=list&amp;prog=...&amp;year=...&amp;sem=...  — load assignments for a filter
///   ?ajax=create             — POST: create a new assignment (JSON body)
///   ?ajax=deactivate         — POST: deactivate an assignment
///   ?ajax=reactivate         — POST: reactivate an assignment
///   ?ajax=backfill           — run legacy backfill from acad_examsettings
///
/// Tables Used:
///   acad_teaching_assignments — main CRUD table
///   acad_programme, acad_courses, hrm_employee, acad_campus — reference dropdowns
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Task: E-09
/// </summary>
public partial class COOPERP_NewScreens_AssignmentManager : System.Web.UI.Page
{
    // ─────────────────────── Connection Strings ──────────────────────────

    private string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─────────────────────── Page Lifecycle ──────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        // Ensure assignment tables exist
        EnsureAssignmentTables();

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

        // Authorization: only Dean/Admin/Registrar can manage assignments
        if (!MarksAuthorizationService.CanManageAssignments())
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write("{\"error\":\"Access denied. Assignment management requires Dean, Administrator, or Registrar role.\"}");
            Response.End();
            return;
        }

        // Handle AJAX requests
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        System.Diagnostics.Stopwatch _actionTimer = MarksActionLogger.StartTimer();
        string _actionOutcome = MarksActionLogger.OUTCOME_SUCCESS;

        try
        {
            // CSRF validation for write operations
            if (ajax == "create" || ajax == "deactivate" || ajax == "reactivate" || ajax == "backfill")
            {
                if (!MarksAntiForgeryService.ValidateRequest())
                {
                    _actionOutcome = MarksActionLogger.OUTCOME_AUTH_FAIL;
                    MarksAntiForgeryService.RejectRequest(Response);
                    return;
                }
            }

            if (ajax == "dropdowns") { HandleDropdowns(); return; }
            if (ajax == "list")      { HandleList(); return; }
            if (ajax == "create")    { HandleCreate(); return; }
            if (ajax == "deactivate") { HandleDeactivate(); return; }
            if (ajax == "reactivate") { HandleReactivate(); return; }
            if (ajax == "backfill")  { HandleBackfill(); return; }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            _actionOutcome = MarksActionLogger.OUTCOME_ERROR;
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write(MarksErrorHandler.HandleException(ex, "AssignmentManager", ajax));
            Response.End();
        }
        finally
        {
            MarksActionLogger.StopAndLog(_actionTimer, "AssignmentManager", ajax, _actionOutcome, null, null);
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Dropdowns (?ajax=dropdowns)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleDropdowns()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        try
        {
            StringBuilder json = new StringBuilder("{");

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Programmes
                json.Append("\"programmes\":[");
                using (MySqlCommand cmd = new MySqlCommand("SELECT progcode, progname FROM acad_programme ORDER BY progname", conn))
                {
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat("{{\"progcode\":\"{0}\",\"progname\":\"{1}\"}}",
                                JsEsc(rdr["progcode"].ToString()), JsEsc(rdr["progname"].ToString()));
                        }
                    }
                }
                json.Append("],");

                // Academic Years
                json.Append("\"years\":[");
                using (MySqlCommand cmd = new MySqlCommand("SELECT DISTINCT acad_year AS val FROM acad_acadyear ORDER BY acad_year DESC LIMIT 10", conn))
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
                json.Append("],");

                // Teachers (from hrm_employee)
                json.Append("\"teachers\":[");
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT DISTINCT e.usernames AS username,
                             CONCAT(COALESCE(e.emp_name,''), ' (', e.usernames, ')') AS display
                      FROM hrm_employee e
                      WHERE e.usernames IS NOT NULL AND e.usernames != ''
                      ORDER BY e.emp_name LIMIT 500", conn))
                {
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat("{{\"username\":\"{0}\",\"display\":\"{1}\"}}",
                                JsEsc(rdr["username"].ToString()), JsEsc(rdr["display"].ToString()));
                        }
                    }
                }
                json.Append("],");

                // Courses
                json.Append("\"courses\":[");
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT DISTINCT CourseCode AS code, CONCAT(CourseCode, ' - ', CourseName) AS display
                      FROM acad_courses ORDER BY CourseCode LIMIT 1000", conn))
                {
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat("{{\"code\":\"{0}\",\"display\":\"{1}\"}}",
                                JsEsc(rdr["code"].ToString()), JsEsc(rdr["display"].ToString()));
                        }
                    }
                }
                json.Append("],");

                // Campuses
                json.Append("\"campuses\":[");
                using (MySqlCommand cmd = new MySqlCommand("SELECT campusid AS id, campusName AS name FROM acad_campus ORDER BY campusName", conn))
                {
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            json.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}",
                                rdr["id"].ToString(), JsEsc(rdr["name"].ToString()));
                        }
                    }
                }
                json.Append("]");
            }

            json.Append("}");
            Response.Write(json.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: List Assignments (?ajax=list&prog=...&year=...&sem=...)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleList()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        string prog = (Request.QueryString["prog"] ?? "").Trim();
        string year = (Request.QueryString["year"] ?? "").Trim();
        string sem  = (Request.QueryString["sem"] ?? "").Trim();

        if (string.IsNullOrEmpty(prog) || string.IsNullOrEmpty(year) || string.IsNullOrEmpty(sem))
        {
            Response.Write("{\"assignments\":[],\"stats\":{\"total\":0,\"active\":0,\"inactive\":0,\"courses\":0}}");
            Response.End();
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                StringBuilder json = new StringBuilder("{\"assignments\":[");
                int total = 0, active = 0, inactive = 0;
                HashSet<string> courses = new HashSet<string>();

                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT ta.id, ta.teacher_username, ta.course_id, ta.progid,
                             ta.study_year, ta.campus_id, ta.stud_session,
                             ta.assigned_by, DATE_FORMAT(ta.assigned_at, '%d/%m/%Y') AS assigned_at,
                             ta.is_active, COALESCE(ta.notes, '') AS notes,
                             COALESCE(c.CourseName, ta.course_id) AS course_name,
                             COALESCE(p.progname, ta.progid) AS prog_name,
                             COALESCE(e.emp_name, ta.teacher_username) AS teacher_name,
                             COALESCE(cam.campusName, '') AS campus_name
                      FROM acad_teaching_assignments ta
                      LEFT JOIN acad_courses c ON c.CourseCode = ta.course_id
                      LEFT JOIN acad_programme p ON p.progcode = ta.progid
                      LEFT JOIN hrm_employee e ON e.usernames = ta.teacher_username
                      LEFT JOIN acad_campus cam ON cam.campusid = ta.campus_id
                      WHERE ta.progid = @prog AND ta.acadyear = @year AND ta.semester = @sem
                      ORDER BY ta.study_year, ta.course_id, ta.teacher_username", conn))
                {
                    cmd.Parameters.AddWithValue("@prog", prog);
                    cmd.Parameters.AddWithValue("@year", year);
                    cmd.Parameters.AddWithValue("@sem", Convert.ToInt32(sem));

                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            total++;
                            bool isActive = Convert.ToInt32(rdr["is_active"]) == 1;
                            if (isActive) active++; else inactive++;
                            courses.Add(rdr["course_id"].ToString());

                            json.Append("{");
                            json.AppendFormat("\"id\":{0},", rdr["id"]);
                            json.AppendFormat("\"teacher_username\":\"{0}\",", JsEsc(rdr["teacher_username"].ToString()));
                            json.AppendFormat("\"teacher_name\":\"{0}\",", JsEsc(rdr["teacher_name"].ToString()));
                            json.AppendFormat("\"course_id\":\"{0}\",", JsEsc(rdr["course_id"].ToString()));
                            json.AppendFormat("\"course_name\":\"{0}\",", JsEsc(rdr["course_name"].ToString()));
                            json.AppendFormat("\"prog_name\":\"{0}\",", JsEsc(rdr["prog_name"].ToString()));
                            json.AppendFormat("\"study_year\":{0},", rdr["study_year"]);
                            json.AppendFormat("\"campus_name\":\"{0}\",", JsEsc(rdr["campus_name"].ToString()));
                            json.AppendFormat("\"stud_session\":\"{0}\",", JsEsc(rdr["stud_session"].ToString()));
                            json.AppendFormat("\"assigned_by\":\"{0}\",", JsEsc(rdr["assigned_by"].ToString()));
                            json.AppendFormat("\"assigned_at\":\"{0}\",", JsEsc(rdr["assigned_at"].ToString()));
                            json.AppendFormat("\"is_active\":{0},", isActive ? "true" : "false");
                            json.AppendFormat("\"notes\":\"{0}\"", JsEsc(rdr["notes"].ToString()));
                            json.Append("}");
                        }
                    }
                }

                json.Append("],\"stats\":{");
                json.AppendFormat("\"total\":{0},\"active\":{1},\"inactive\":{2},\"courses\":{3}",
                    total, active, inactive, courses.Count);
                json.Append("}}");

                Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"assignments\":[],\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Create Assignment (?ajax=create, POST)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleCreate()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        // C-02: Per-handler role guard
        if (!MarksAuthorizationService.CanManageAssignments())
        {
            Response.Write("{\"ok\":false,\"error\":\"Access denied. Assignment management requires appropriate role.\"}");
            Response.End();
            return;
        }

        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);

            string teacher = data.ContainsKey("teacher") ? Convert.ToString(data["teacher"]) : "";
            string course  = data.ContainsKey("course") ? Convert.ToString(data["course"]) : "";
            string prog    = data.ContainsKey("prog") ? Convert.ToString(data["prog"]) : "";
            string acadyear = data.ContainsKey("acadyear") ? Convert.ToString(data["acadyear"]) : "";
            int semester   = data.ContainsKey("semester") ? Convert.ToInt32(data["semester"]) : 0;
            int studyYear  = data.ContainsKey("study_year") ? Convert.ToInt32(data["study_year"]) : 1;
            int campus     = data.ContainsKey("campus") ? Convert.ToInt32(data["campus"]) : 1;
            string session = data.ContainsKey("session") ? Convert.ToString(data["session"]) : "Day";
            string notes   = data.ContainsKey("notes") ? Convert.ToString(data["notes"]) : "";

            // C-04: Input validation
            string valErr = MarksInputValidator.ValidateCourseCode(course);
            if (valErr != null) throw new Exception(valErr);
            valErr = MarksInputValidator.ValidateProgrammeCode(prog);
            if (valErr != null) throw new Exception(valErr);
            valErr = MarksInputValidator.ValidateAcademicYear(acadyear);
            if (valErr != null) throw new Exception(valErr);
            valErr = MarksInputValidator.ValidateSemester(semester);
            if (valErr != null) throw new Exception(valErr);
            valErr = MarksInputValidator.ValidateUsername(teacher);
            if (valErr != null) throw new Exception(valErr);
            notes = MarksInputValidator.Sanitize(notes, 250);

            if (string.IsNullOrEmpty(teacher)) throw new Exception("Teacher is required.");
            if (string.IsNullOrEmpty(course)) throw new Exception("Course is required.");
            if (string.IsNullOrEmpty(prog)) throw new Exception("Programme is required.");
            if (string.IsNullOrEmpty(acadyear)) throw new Exception("Academic year is required.");
            if (semester <= 0) throw new Exception("Semester is required.");

            int newId = MarksAssignmentService.CreateAssignment(teacher, course, prog, acadyear,
                semester, studyYear, campus, session, notes);

            if (newId > 0)
            {
                // G-04: Audit assignment creation
                MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                {
                    CourseId = course,
                    ProgId = prog,
                    AcadYear = acadyear,
                    Semester = semester,
                    ActionType = MarksAuditService.ACTION_INSERT,
                    ActionTypeExt = "ASSIGNMENT_CREATE",
                    ChangeReason = String.Format("Assignment created: {0} -> {1}/{2} Sem {3}", teacher, course, prog, semester),
                    ChangedBy = MarksAuthorizationService.GetCurrentUser(),
                    IpAddress = MarksAuthorizationService.GetClientIP()
                });
                Response.Write(String.Format("{{\"ok\":true,\"id\":{0}}}", newId));
            }
            else
            {
                Response.Write("{\"ok\":false,\"error\":\"Failed to create assignment.\"}");
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Deactivate/Reactivate (?ajax=deactivate/reactivate, POST)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleDeactivate()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        // C-02: Per-handler role guard
        if (!MarksAuthorizationService.CanManageAssignments())
        {
            Response.Write("{\"ok\":false,\"error\":\"Access denied. Assignment management requires appropriate role.\"}");
            Response.End();
            return;
        }

        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);
            int id = data.ContainsKey("id") ? Convert.ToInt32(data["id"]) : 0;

            bool ok = MarksAssignmentService.DeactivateAssignment(id);
            if (ok)
            {
                // G-04: Audit assignment deactivation
                MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                {
                    ActionType = MarksAuditService.ACTION_DELETE,
                    ActionTypeExt = "ASSIGNMENT_DEACTIVATE",
                    ChangeReason = String.Format("Assignment id={0} deactivated", id),
                    ChangedBy = MarksAuthorizationService.GetCurrentUser(),
                    IpAddress = MarksAuthorizationService.GetClientIP()
                });
            }
            Response.Write(ok ? "{\"ok\":true}" : "{\"ok\":false,\"error\":\"Assignment not found.\"}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    private void HandleReactivate()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        // C-02: Per-handler role guard
        if (!MarksAuthorizationService.CanManageAssignments())
        {
            Response.Write("{\"ok\":false,\"error\":\"Access denied. Assignment management requires appropriate role.\"}");
            Response.End();
            return;
        }

        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);
            int id = data.ContainsKey("id") ? Convert.ToInt32(data["id"]) : 0;

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "UPDATE acad_teaching_assignments SET is_active = 1 WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    if (ok)
                    {
                        // G-04: Audit assignment reactivation
                        MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                        {
                            ActionType = MarksAuditService.ACTION_UPDATE,
                            ActionTypeExt = "ASSIGNMENT_REACTIVATE",
                            ChangeReason = String.Format("Assignment id={0} reactivated", id),
                            ChangedBy = MarksAuthorizationService.GetCurrentUser(),
                            IpAddress = MarksAuthorizationService.GetClientIP()
                        });
                    }
                    Response.Write(ok ? "{\"ok\":true}" : "{\"ok\":false,\"error\":\"Assignment not found.\"}");
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Backfill (?ajax=backfill)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleBackfill()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        // C-02: Per-handler role guard
        if (!MarksAuthorizationService.CanManageAssignments())
        {
            Response.Write("{\"ok\":false,\"error\":\"Access denied. Assignment management requires appropriate role.\"}");
            Response.End();
            return;
        }

        try
        {
            int count = MarksAssignmentService.BackfillFromExamSettings();
            if (count >= 0)
            {
                // G-04: Audit backfill operation
                if (count > 0)
                {
                    MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                    {
                        ActionType = MarksAuditService.ACTION_INSERT,
                        ActionTypeExt = "ASSIGNMENT_BACKFILL",
                        ChangeReason = String.Format("Backfilled {0} assignment(s) from exam settings", count),
                        ChangedBy = MarksAuthorizationService.GetCurrentUser(),
                        IpAddress = MarksAuthorizationService.GetClientIP()
                    });
                }
                Response.Write(String.Format("{{\"ok\":true,\"count\":{0}}}", count));
            }
            else
            {
                Response.Write("{\"ok\":false,\"error\":\"Backfill failed — check database connection.\"}");
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

    private void EnsureAssignmentTables()
    {
        try
        {
            string ddl = @"CREATE TABLE IF NOT EXISTS acad_teaching_assignments (
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
                INDEX idx_course_year (course_id, acadyear, semester),
                INDEX idx_programme (progid, acadyear, semester),
                INDEX idx_active (is_active)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(ddl, conn)) { cmd.ExecuteNonQuery(); }
            }

            MarksActionLogger.EnsureActionLogTable();
        }
        catch
        {
            // Silently ignore — table likely already exists
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
