using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Deadline Manager — admin page for managing mark entry deadlines and unlock requests.
///
/// AJAX Endpoints (via ?ajax=...):
///   ?ajax=dropdowns            — load campuses and academic years
///   ?ajax=list&amp;campus=...&amp;year=...&amp;sem=...&amp;sess=...  — load deadlines
///   ?ajax=save                 — POST: create or update a deadline
///   ?ajax=toggle               — POST: enable/disable a deadline
///   ?ajax=get&amp;id=...       — get a single deadline for editing
///   ?ajax=unlocks              — get all pending unlock requests
///   ?ajax=review               — POST: approve/reject an unlock request
///
/// Tables Used:
///   acad_deadlines           — main CRUD table for deadlines
///   acad_mark_unlock_requests — unlock request management
///   acad_campus, acad_acadyear — reference dropdowns
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Task: E-08
/// </summary>
public partial class COOPERP_NewScreens_DeadlineManager : System.Web.UI.Page
{
    // ─────────────────────── Connection Strings ──────────────────────────

    private string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─────────────────────── Page Lifecycle ──────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        // Ensure required tables exist
        EnsureDeadlineTables();

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

        // Authorization: only Dean/Admin/Registrar can manage deadlines
        if (!MarksAuthorizationService.CanManageDeadlines())
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write("{\"error\":\"Access denied. Deadline management requires Dean, Administrator, or Registrar role.\"}");
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
            if (ajax == "save" || ajax == "toggle" || ajax == "review")
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
            if (ajax == "save")      { HandleSave(); return; }
            if (ajax == "toggle")    { HandleToggle(); return; }
            if (ajax == "get")       { HandleGet(); return; }
            if (ajax == "unlocks")   { HandleUnlocks(); return; }
            if (ajax == "review")    { HandleReview(); return; }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            _actionOutcome = MarksActionLogger.OUTCOME_ERROR;
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Write(MarksErrorHandler.HandleException(ex, "DeadlineManager", ajax));
            Response.End();
        }
        finally
        {
            MarksActionLogger.StopAndLog(_actionTimer, "DeadlineManager", ajax, _actionOutcome, null, null);
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
    // AJAX: List Deadlines (?ajax=list&campus=...&year=...&sem=...&sess=...)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleList()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        int campusId = 0;
        Int32.TryParse(Request.QueryString["campus"] ?? "", out campusId);
        string year = (Request.QueryString["year"] ?? "").Trim();
        int sem = 0;
        Int32.TryParse(Request.QueryString["sem"] ?? "", out sem);
        string sess = (Request.QueryString["sess"] ?? "Day").Trim();

        if (campusId <= 0 || string.IsNullOrEmpty(year) || sem <= 0)
        {
            Response.Write("{\"deadlines\":[],\"stats\":{\"total\":0,\"active\":0,\"expired\":0}}");
            Response.End();
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                StringBuilder json = new StringBuilder("{\"deadlines\":[");
                int total = 0, active = 0, expired = 0;

                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT id, ActivityName, deadline, deadline_type, is_active,
                             campusid, semester, studsession, acadyear
                      FROM acad_deadlines
                      WHERE campusid = @campus
                        AND acadyear = @year
                        AND semester = @sem
                        AND studsession = @sess
                      ORDER BY deadline_type, deadline", conn))
                {
                    cmd.Parameters.AddWithValue("@campus", campusId);
                    cmd.Parameters.AddWithValue("@year", year);
                    cmd.Parameters.AddWithValue("@sem", sem);
                    cmd.Parameters.AddWithValue("@sess", sess);

                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) json.Append(",");
                            first = false;
                            total++;

                            DateTime dl = Convert.ToDateTime(rdr["deadline"]);
                            bool isActive = Convert.ToInt32(rdr["is_active"]) == 1;
                            bool isExpired = DateTime.Now > dl;
                            int daysLeft = (int)(dl - DateTime.Now).TotalDays;

                            if (isActive) active++;
                            if (isExpired && isActive) expired++;

                            json.Append("{");
                            json.AppendFormat("\"id\":{0},", rdr["id"]);
                            json.AppendFormat("\"activity\":\"{0}\",", JsEsc(rdr["ActivityName"].ToString()));
                            json.AppendFormat("\"type\":\"{0}\",", JsEsc(rdr["deadline_type"].ToString()));
                            json.AppendFormat("\"deadline_display\":\"{0}\",", dl.ToString("dd/MM/yyyy HH:mm"));
                            json.AppendFormat("\"deadline_input\":\"{0}\",", dl.ToString("yyyy-MM-ddTHH:mm"));
                            json.AppendFormat("\"campus_id\":{0},", rdr["campusid"]);
                            json.AppendFormat("\"acadyear\":\"{0}\",", JsEsc(rdr["acadyear"].ToString()));
                            json.AppendFormat("\"semester\":{0},", rdr["semester"]);
                            json.AppendFormat("\"session\":\"{0}\",", JsEsc(rdr["studsession"].ToString()));
                            json.AppendFormat("\"is_active\":{0},", isActive ? "true" : "false");
                            json.AppendFormat("\"is_expired\":{0},", isExpired ? "true" : "false");
                            json.AppendFormat("\"days_remaining\":{0}", daysLeft);
                            json.Append("}");
                        }
                    }
                }

                json.Append("],\"stats\":{");
                json.AppendFormat("\"total\":{0},\"active\":{1},\"expired\":{2}", total, active, expired);
                json.Append("}}");

                Response.Write(json.ToString());
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"deadlines\":[],\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Get Single Deadline (?ajax=get&id=...)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleGet()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        int id = 0;
        Int32.TryParse(Request.QueryString["id"] ?? "", out id);

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT id, ActivityName, deadline, deadline_type, is_active,
                             campusid, semester, studsession, acadyear
                      FROM acad_deadlines WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            DateTime dl = Convert.ToDateTime(rdr["deadline"]);
                            StringBuilder json = new StringBuilder("{");
                            json.AppendFormat("\"id\":{0},", rdr["id"]);
                            json.AppendFormat("\"activity\":\"{0}\",", JsEsc(rdr["ActivityName"].ToString()));
                            json.AppendFormat("\"type\":\"{0}\",", JsEsc(rdr["deadline_type"].ToString()));
                            json.AppendFormat("\"deadline_input\":\"{0}\",", dl.ToString("yyyy-MM-ddTHH:mm"));
                            json.AppendFormat("\"campus_id\":{0},", rdr["campusid"]);
                            json.AppendFormat("\"acadyear\":\"{0}\",", JsEsc(rdr["acadyear"].ToString()));
                            json.AppendFormat("\"semester\":{0},", rdr["semester"]);
                            json.AppendFormat("\"session\":\"{0}\"", JsEsc(rdr["studsession"].ToString()));
                            json.Append("}");
                            Response.Write(json.ToString());
                        }
                        else
                        {
                            Response.Write("{\"error\":\"Deadline not found.\"}");
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Save Deadline (?ajax=save, POST)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleSave()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        // C-02: Per-handler role guard
        if (!MarksAuthorizationService.CanManageDeadlines())
        {
            Response.Write("{\"ok\":false,\"error\":\"Access denied. Deadline management requires appropriate role.\"}");
            Response.End();
            return;
        }

        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);

            string activity = data.ContainsKey("activity") ? Convert.ToString(data["activity"]) : "";
            string type     = data.ContainsKey("type") ? Convert.ToString(data["type"]) : "COURSEWORK";
            string deadline = data.ContainsKey("deadline") ? Convert.ToString(data["deadline"]) : "";
            int campus      = data.ContainsKey("campus") ? Convert.ToInt32(data["campus"]) : 0;
            string acadyear = data.ContainsKey("acadyear") ? Convert.ToString(data["acadyear"]) : "";
            int semester    = data.ContainsKey("semester") ? Convert.ToInt32(data["semester"]) : 0;
            string session  = data.ContainsKey("session") ? Convert.ToString(data["session"]) : "Day";

            // C-04: Input validation
            string valErr = MarksInputValidator.ValidateAcademicYear(acadyear);
            if (valErr != null) throw new Exception(valErr);
            valErr = MarksInputValidator.ValidateSemester(semester);
            if (valErr != null) throw new Exception(valErr);
            activity = MarksInputValidator.Sanitize(activity, 200);

            if (string.IsNullOrEmpty(activity)) throw new Exception("Activity name is required.");
            if (string.IsNullOrEmpty(deadline)) throw new Exception("Deadline date is required.");
            if (campus <= 0) throw new Exception("Campus is required.");
            if (string.IsNullOrEmpty(acadyear)) throw new Exception("Academic year is required.");
            if (semester <= 0) throw new Exception("Semester is required.");

            DateTime dlParsed = DateTime.Parse(deadline);

            // Check for edit (id present and non-null)
            object idObj = data.ContainsKey("id") ? data["id"] : null;
            bool isEdit = (idObj != null && Convert.ToInt32(idObj) > 0);

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                if (isEdit)
                {
                    int editId = Convert.ToInt32(idObj);
                    using (MySqlCommand cmd = new MySqlCommand(
                        @"UPDATE acad_deadlines SET
                            ActivityName = @activity, deadline = @dl, deadline_type = @type
                          WHERE id = @id", conn))
                    {
                        cmd.Parameters.AddWithValue("@activity", activity);
                        cmd.Parameters.AddWithValue("@dl", dlParsed);
                        cmd.Parameters.AddWithValue("@type", type);
                        cmd.Parameters.AddWithValue("@id", editId);
                        cmd.ExecuteNonQuery();
                    }
                    // G-04: Audit deadline update
                    MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                    {
                        AcadYear = acadyear,
                        Semester = semester,
                        ActionType = MarksAuditService.ACTION_UPDATE,
                        ActionTypeExt = "DEADLINE_UPDATE",
                        ChangeReason = String.Format("Deadline updated: {0} ({1}) to {2}", activity, type, dlParsed.ToString("yyyy-MM-dd")),
                        ChangedBy = MarksAuthorizationService.GetCurrentUser(),
                        IpAddress = MarksAuthorizationService.GetClientIP()
                    });
                    Response.Write("{\"ok\":true}");
                }
                else
                {
                    using (MySqlCommand cmd = new MySqlCommand(
                        @"INSERT INTO acad_deadlines (ActivityName, deadline, deadline_type, is_active,
                                                      campusid, acadyear, semester, studsession)
                          VALUES (@activity, @dl, @type, 1, @campus, @year, @sem, @sess)", conn))
                    {
                        cmd.Parameters.AddWithValue("@activity", activity);
                        cmd.Parameters.AddWithValue("@dl", dlParsed);
                        cmd.Parameters.AddWithValue("@type", type);
                        cmd.Parameters.AddWithValue("@campus", campus);
                        cmd.Parameters.AddWithValue("@year", acadyear);
                        cmd.Parameters.AddWithValue("@sem", semester);
                        cmd.Parameters.AddWithValue("@sess", session);
                        cmd.ExecuteNonQuery();
                    }
                    // G-04: Audit deadline creation
                    MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                    {
                        AcadYear = acadyear,
                        Semester = semester,
                        ActionType = MarksAuditService.ACTION_INSERT,
                        ActionTypeExt = "DEADLINE_CREATE",
                        ChangeReason = String.Format("Deadline created: {0} ({1}) due {2}", activity, type, dlParsed.ToString("yyyy-MM-dd")),
                        ChangedBy = MarksAuthorizationService.GetCurrentUser(),
                        IpAddress = MarksAuthorizationService.GetClientIP()
                    });
                    Response.Write("{\"ok\":true}");
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
    // AJAX: Toggle Deadline (?ajax=toggle, POST)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleToggle()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        // C-02: Per-handler role guard
        if (!MarksAuthorizationService.CanManageDeadlines())
        {
            Response.Write("{\"ok\":false,\"error\":\"Access denied. Deadline management requires appropriate role.\"}");
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
            int isActive = data.ContainsKey("is_active") ? Convert.ToInt32(data["is_active"]) : 0;

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "UPDATE acad_deadlines SET is_active = @active WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@active", isActive);
                    cmd.Parameters.AddWithValue("@id", id);
                    bool ok = cmd.ExecuteNonQuery() > 0;
                    if (ok)
                    {
                        // G-04: Audit deadline toggle
                        MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                        {
                            ActionType = MarksAuditService.ACTION_UPDATE,
                            ActionTypeExt = "DEADLINE_TOGGLE",
                            ChangeReason = String.Format("Deadline id={0} toggled to {1}", id, isActive == 1 ? "active" : "inactive"),
                            ChangedBy = MarksAuthorizationService.GetCurrentUser(),
                            IpAddress = MarksAuthorizationService.GetClientIP()
                        });
                    }
                    Response.Write(ok ? "{\"ok\":true}" : "{\"ok\":false,\"error\":\"Deadline not found.\"}");
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
    // AJAX: Get Pending Unlock Requests (?ajax=unlocks)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleUnlocks()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        try
        {
            var requests = MarksDeadlineService.GetPendingUnlockRequests();
            StringBuilder json = new StringBuilder("{\"requests\":[");
            bool first = true;
            foreach (var r in requests)
            {
                if (!first) json.Append(",");
                first = false;
                json.Append("{");
                json.AppendFormat("\"id\":{0},", r.Id);
                json.AppendFormat("\"requested_by\":\"{0}\",", JsEsc(r.RequestedBy));
                json.AppendFormat("\"course_id\":\"{0}\",", JsEsc(r.CourseId));
                json.AppendFormat("\"course_name\":\"{0}\",", JsEsc(r.CourseName));
                json.AppendFormat("\"prog_name\":\"{0}\",", JsEsc(r.ProgName));
                json.AppendFormat("\"acadyear\":\"{0}\",", JsEsc(r.AcadYear));
                json.AppendFormat("\"semester\":{0},", r.Semester);
                json.AppendFormat("\"deadline_type\":\"{0}\",", JsEsc(r.DeadlineType));
                json.AppendFormat("\"reason\":\"{0}\",", JsEsc(r.Reason));
                json.AppendFormat("\"status\":\"{0}\",", JsEsc(r.Status));
                json.AppendFormat("\"created_at\":\"{0}\"", r.CreatedAt.ToString("dd/MM/yyyy HH:mm"));
                json.Append("}");
            }
            json.Append("]}");
            Response.Write(json.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"requests\":[],\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Review Unlock Request (?ajax=review, POST)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleReview()
    {
        Response.Clear();
        Response.ContentType = "application/json";

        // C-02: Per-handler role guard
        if (!MarksAuthorizationService.CanManageDeadlines())
        {
            Response.Write("{\"ok\":false,\"error\":\"Access denied. Unlock review requires appropriate role.\"}");
            Response.End();
            return;
        }

        try
        {
            string body;
            using (var sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            var jss = new JavaScriptSerializer();
            var data = jss.Deserialize<Dictionary<string, object>>(body);

            int id       = data.ContainsKey("id") ? Convert.ToInt32(data["id"]) : 0;
            string decision = data.ContainsKey("decision") ? Convert.ToString(data["decision"]) : "";
            string notes = data.ContainsKey("notes") ? Convert.ToString(data["notes"]) : "";
            int hours    = data.ContainsKey("hours") ? Convert.ToInt32(data["hours"]) : 48;

            if (id <= 0) throw new Exception("Request ID is required.");
            if (decision != "APPROVED" && decision != "REJECTED")
                throw new Exception("Decision must be APPROVED or REJECTED.");

            string reviewer = MarksAuthorizationService.GetCurrentUser();

            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Calculate expiry: now + hours (only meaningful if approved)
                DateTime expiresAt = DateTime.Now.AddHours(hours);

                using (MySqlCommand cmd = new MySqlCommand(
                    @"UPDATE acad_mark_unlock_requests SET
                        status = @status,
                        reviewed_by = @reviewer,
                        reviewed_at = NOW(),
                        review_notes = @notes,
                        expires_at = @expires
                      WHERE id = @id AND status = 'PENDING'", conn))
                {
                    cmd.Parameters.AddWithValue("@status", decision);
                    cmd.Parameters.AddWithValue("@reviewer", reviewer);
                    cmd.Parameters.AddWithValue("@notes", notes);
                    cmd.Parameters.AddWithValue("@expires", decision == "APPROVED" ? (object)expiresAt : DBNull.Value);
                    cmd.Parameters.AddWithValue("@id", id);

                    bool ok = cmd.ExecuteNonQuery() > 0;
                    if (ok)
                    {
                        // G-04: Audit unlock review decision
                        string auditReason = String.Format("Unlock request id={0} {1}{2}",
                            id, decision, string.IsNullOrEmpty(notes) ? "" : ": " + notes);
                        MarksAuditService.LogEntry(new MarksAuditService.AuditEntry
                        {
                            ActionType = decision == "APPROVED" ? MarksAuditService.ACTION_UNLOCK : MarksAuditService.ACTION_REJECT,
                            ActionTypeExt = "UNLOCK_REVIEW",
                            ChangeReason = auditReason,
                            ChangedBy = reviewer,
                            IpAddress = MarksAuthorizationService.GetClientIP()
                        });
                    }
                    Response.Write(ok
                        ? "{\"ok\":true}"
                        : "{\"ok\":false,\"error\":\"Request not found or already reviewed.\"}");
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
    // Table Auto-Migration
    // ═════════════════════════════════════════════════════════════════════

    private void EnsureDeadlineTables()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Ensure deadline_type and is_active columns exist on acad_deadlines
                using (MySqlCommand check = new MySqlCommand(
                    @"SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
                      WHERE TABLE_SCHEMA = DATABASE() 
                        AND TABLE_NAME = 'acad_deadlines' 
                        AND COLUMN_NAME = 'deadline_type'", conn))
                {
                    int exists = Convert.ToInt32(check.ExecuteScalar());
                    if (exists == 0)
                    {
                        using (MySqlCommand alter = new MySqlCommand(
                            @"ALTER TABLE acad_deadlines 
                              ADD COLUMN deadline_type ENUM('COURSEWORK','EXAM','SUBMISSION','OTHER') NOT NULL DEFAULT 'COURSEWORK',
                              ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1", conn))
                        {
                            alter.ExecuteNonQuery();
                        }
                    }
                }

                // Ensure unlock requests table exists
                string ddl = @"CREATE TABLE IF NOT EXISTS acad_mark_unlock_requests (
                    id             INT UNSIGNED    NOT NULL AUTO_INCREMENT PRIMARY KEY,
                    requested_by   VARCHAR(50)     NOT NULL,
                    course_id      VARCHAR(25)     DEFAULT NULL,
                    progid         VARCHAR(25)     DEFAULT NULL,
                    acadyear       VARCHAR(25)     NOT NULL,
                    semester       TINYINT UNSIGNED NOT NULL,
                    deadline_type  ENUM('COURSEWORK','EXAM','SUBMISSION','OTHER') NOT NULL DEFAULT 'COURSEWORK',
                    reason         TEXT            NOT NULL,
                    status         ENUM('PENDING','APPROVED','REJECTED','EXPIRED') NOT NULL DEFAULT 'PENDING',
                    reviewed_by    VARCHAR(50)     DEFAULT NULL,
                    reviewed_at    DATETIME        DEFAULT NULL,
                    review_notes   TEXT            DEFAULT NULL,
                    expires_at     DATETIME        DEFAULT NULL,
                    created_at     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_status (status),
                    INDEX idx_requester (requested_by),
                    INDEX idx_context (acadyear, semester, deadline_type)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

                using (MySqlCommand cmd = new MySqlCommand(ddl, conn)) { cmd.ExecuteNonQuery(); }
            }

            MarksActionLogger.EnsureActionLogTable();
        }
        catch
        {
            // Silently ignore — tables likely already exist
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
