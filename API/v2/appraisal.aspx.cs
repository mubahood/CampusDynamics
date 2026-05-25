using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class API_v2_appraisal : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;
        if (ApiHelper.IsRateLimited(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "sessions":               HandleSessions();              break;
                case "session":                HandleSession();               break;
                case "create_session":         HandleCreateSession();         break;
                case "update_session":         HandleUpdateSession();         break;
                case "my_appraisals":          HandleMyAppraisals();          break;
                case "appraisal_record":       HandleAppraisalRecord();       break;
                case "save_self_appraisal":    HandleSaveSelfAppraisal();     break;
                case "save_supervisor_appraisal": HandleSaveSupervisorAppraisal(); break;
                case "submit_appraisal":       HandleSubmitAppraisal();       break;
                case "report":                 HandleReport();                break;
                case "export_report":          HandleExportReport();          break;
                case "competency_templates":   HandleCompetencyTemplates();   break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". Valid actions: sessions, session, create_session, update_session, " +
                        "my_appraisals, appraisal_record, save_self_appraisal, save_supervisor_appraisal, " +
                        "submit_appraisal, report, export_report, competency_templates",
                        "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private int GetEmpId(string username)
    {
        DataTable dt = ApiHelper.Query(
            "SELECT empID FROM hrm_employee WHERE usernames = @u LIMIT 1",
            new MySqlParameter("@u", username));
        if (dt.Rows.Count == 0) return 0;
        return Convert.ToInt32(dt.Rows[0]["empID"]);
    }

    private string ClassifyPercentage(decimal pct)
    {
        if (pct >= 90) return "Excellent";
        if (pct >= 75) return "Good";
        if (pct >= 60) return "Satisfactory";
        return "Needs Improvement";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SESSIONS  — list sessions
    //  Admin: all. Staff: ACTIVE sessions where they have a record.
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSessions()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int empId = GetEmpId(auth.UserId);
        bool isAdmin = ApiHelper.Param(Request, "all", "0") == "1";

        DataTable dt;
        if (isAdmin || empId == 0)
        {
            // Admin: all sessions
            dt = ApiHelper.Query(
                @"SELECT s.session_id, s.session_title, s.session_description,
                         DATE_FORMAT(s.period_start, '%Y-%m-%d') AS period_start,
                         DATE_FORMAT(s.period_end, '%Y-%m-%d') AS period_end,
                         DATE_FORMAT(s.deadline, '%Y-%m-%d') AS deadline,
                         s.target_categories, s.status,
                         DATE_FORMAT(s.created_at, '%Y-%m-%d %H:%i') AS created_at,
                         COUNT(r.record_id) AS record_count
                  FROM appraisal_sessions s
                  LEFT JOIN appraisal_records r ON r.session_id = s.session_id
                  GROUP BY s.session_id ORDER BY s.created_at DESC");
        }
        else
        {
            // Staff: only ACTIVE sessions they are assigned to
            dt = ApiHelper.Query(
                @"SELECT s.session_id, s.session_title,
                         DATE_FORMAT(s.period_start, '%Y-%m-%d') AS period_start,
                         DATE_FORMAT(s.period_end, '%Y-%m-%d') AS period_end,
                         DATE_FORMAT(s.deadline, '%Y-%m-%d') AS deadline,
                         s.status, r.record_id, r.status AS record_status,
                         r.final_percentage, r.classification
                  FROM appraisal_sessions s
                  INNER JOIN appraisal_records r ON r.session_id = s.session_id AND r.employee_id = @empId
                  WHERE s.status = 'ACTIVE'
                  ORDER BY s.deadline ASC",
                new MySqlParameter("@empId", empId));
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", dt.Rows.Count },
            { "sessions", ApiHelper.TableToList(dt) }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SESSION  — single session with statistics
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSession()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int sessionId = ApiHelper.ParamInt(Request, "session_id", 0);
        if (sessionId <= 0) { ApiHelper.Error(Response, "session_id is required.", "MISSING_PARAM"); return; }

        DataTable dt = ApiHelper.Query(
            @"SELECT session_id, session_title, session_description,
                     DATE_FORMAT(period_start, '%Y-%m-%d') AS period_start,
                     DATE_FORMAT(period_end, '%Y-%m-%d') AS period_end,
                     DATE_FORMAT(deadline, '%Y-%m-%d') AS deadline,
                     target_categories, status,
                     DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') AS created_at
              FROM appraisal_sessions WHERE session_id = @id LIMIT 1",
            new MySqlParameter("@id", sessionId));

        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Session not found.", "NOT_FOUND"); return; }

        var session = ApiHelper.FirstRowToDict(dt);

        // Statistics
        DataTable stats = ApiHelper.Query(
            @"SELECT COUNT(*) AS total,
                     SUM(status = 'PENDING') AS pending,
                     SUM(status = 'IN_PROGRESS') AS in_progress,
                     SUM(employee_submitted_at IS NOT NULL) AS emp_submitted,
                     SUM(supervisor_submitted_at IS NOT NULL) AS sup_submitted,
                     AVG(final_percentage) AS avg_percentage
              FROM appraisal_records WHERE session_id = @id",
            new MySqlParameter("@id", sessionId));

        session["stats"] = stats.Rows.Count > 0 ? ApiHelper.FirstRowToDict(stats) : null;

        ApiHelper.Success(Response, session);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CREATE_SESSION  — admin only
    // ═══════════════════════════════════════════════════════════════════

    private void HandleCreateSession()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string title       = ApiHelper.RequireParam(Request, Response, "session_title"); if (title == null) return;
        string description = ApiHelper.Param(Request, "session_description", "");
        string periodStart = ApiHelper.RequireParam(Request, Response, "period_start"); if (periodStart == null) return;
        string periodEnd   = ApiHelper.RequireParam(Request, Response, "period_end"); if (periodEnd == null) return;
        string deadline    = ApiHelper.RequireParam(Request, Response, "deadline"); if (deadline == null) return;
        string categories  = ApiHelper.Param(Request, "target_categories", "ACADEMIC,ADMINISTRATIVE");
        string status      = ApiHelper.Param(Request, "status", "DRAFT").ToUpper();

        int empId = GetEmpId(auth.UserId);

        ApiHelper.Execute(
            @"INSERT INTO appraisal_sessions (session_title, session_description, period_start, period_end, deadline, target_categories, status, created_by)
              VALUES (@t, @d, @ps, @pe, @dl, @cat, @st, @eid)",
            new MySqlParameter("@t",   title),
            new MySqlParameter("@d",   description),
            new MySqlParameter("@ps",  periodStart),
            new MySqlParameter("@pe",  periodEnd),
            new MySqlParameter("@dl",  deadline),
            new MySqlParameter("@cat", categories),
            new MySqlParameter("@st",  status),
            new MySqlParameter("@eid", empId > 0 ? (object)empId : DBNull.Value));

        int newId = Convert.ToInt32(ApiHelper.Scalar("SELECT LAST_INSERT_ID()"));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "session_id", newId }, { "status", status }
        }, "Appraisal session created");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  UPDATE_SESSION  — edit session or change status
    // ═══════════════════════════════════════════════════════════════════

    private void HandleUpdateSession()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int sessionId = ApiHelper.ParamInt(Request, "session_id", 0);
        if (sessionId <= 0) { ApiHelper.Error(Response, "session_id is required.", "MISSING_PARAM"); return; }

        DataTable existing = ApiHelper.Query(
            "SELECT session_id FROM appraisal_sessions WHERE session_id = @id LIMIT 1",
            new MySqlParameter("@id", sessionId));
        if (existing.Rows.Count == 0) { ApiHelper.Error(Response, "Session not found.", "NOT_FOUND"); return; }

        var sets = new List<string>();
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@id", sessionId));

        string title  = ApiHelper.Param(Request, "session_title", "");
        string desc   = ApiHelper.Param(Request, "session_description", "");
        string ps     = ApiHelper.Param(Request, "period_start", "");
        string pe     = ApiHelper.Param(Request, "period_end", "");
        string dl     = ApiHelper.Param(Request, "deadline", "");
        string cat    = ApiHelper.Param(Request, "target_categories", "");
        string status = ApiHelper.Param(Request, "status", "");

        if (!string.IsNullOrEmpty(title))  { sets.Add("session_title = @t");       parms.Add(new MySqlParameter("@t",   title));  }
        if (!string.IsNullOrEmpty(desc))   { sets.Add("session_description = @d"); parms.Add(new MySqlParameter("@d",   desc));   }
        if (!string.IsNullOrEmpty(ps))     { sets.Add("period_start = @ps");       parms.Add(new MySqlParameter("@ps",  ps));     }
        if (!string.IsNullOrEmpty(pe))     { sets.Add("period_end = @pe");         parms.Add(new MySqlParameter("@pe",  pe));     }
        if (!string.IsNullOrEmpty(dl))     { sets.Add("deadline = @dl");           parms.Add(new MySqlParameter("@dl",  dl));     }
        if (!string.IsNullOrEmpty(cat))    { sets.Add("target_categories = @cat"); parms.Add(new MySqlParameter("@cat", cat));    }
        if (!string.IsNullOrEmpty(status)) { sets.Add("status = @st");             parms.Add(new MySqlParameter("@st",  status.ToUpper())); }

        if (sets.Count == 0) { ApiHelper.Error(Response, "No fields to update.", "VALIDATION_ERROR"); return; }

        ApiHelper.Execute(
            "UPDATE appraisal_sessions SET " + string.Join(", ", sets) + " WHERE session_id = @id",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object> { { "session_id", sessionId } }, "Session updated");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  MY_APPRAISALS  — logged-in staff's assigned records
    // ═══════════════════════════════════════════════════════════════════

    private void HandleMyAppraisals()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int empId = GetEmpId(auth.UserId);
        if (empId == 0) { ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND"); return; }

        DataTable dt = ApiHelper.Query(
            @"SELECT r.record_id, r.session_id, s.session_title,
                     DATE_FORMAT(s.deadline, '%Y-%m-%d') AS deadline,
                     s.status AS session_status,
                     r.staff_category, r.status AS record_status,
                     DATE_FORMAT(r.employee_submitted_at, '%Y-%m-%d %H:%i') AS emp_submitted_at,
                     DATE_FORMAT(r.supervisor_submitted_at, '%Y-%m-%d %H:%i') AS sup_submitted_at,
                     r.final_percentage, r.classification
              FROM appraisal_records r
              INNER JOIN appraisal_sessions s ON s.session_id = r.session_id
              WHERE r.employee_id = @empId
              ORDER BY s.deadline DESC",
            new MySqlParameter("@empId", empId));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", dt.Rows.Count },
            { "records", ApiHelper.TableToList(dt) }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  APPRAISAL_RECORD  — full record with all section data
    // ═══════════════════════════════════════════════════════════════════

    private void HandleAppraisalRecord()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int recordId = ApiHelper.ParamInt(Request, "record_id", 0);
        if (recordId <= 0) { ApiHelper.Error(Response, "record_id is required.", "MISSING_PARAM"); return; }

        int empId = GetEmpId(auth.UserId);

        DataTable dt = ApiHelper.Query(
            @"SELECT r.record_id, r.session_id, s.session_title,
                     DATE_FORMAT(s.period_start, '%Y-%m-%d') AS period_start,
                     DATE_FORMAT(s.period_end, '%Y-%m-%d') AS period_end,
                     DATE_FORMAT(s.deadline, '%Y-%m-%d') AS deadline,
                     r.employee_id, r.reviewer_id, r.staff_category, r.status,
                     DATE_FORMAT(r.employee_submitted_at, '%Y-%m-%d %H:%i') AS emp_submitted_at,
                     DATE_FORMAT(r.supervisor_submitted_at, '%Y-%m-%d %H:%i') AS sup_submitted_at,
                     r.final_percentage, r.classification, r.section_b_self_total,
                     r.section_b_supervisor_total, r.section_c_total
              FROM appraisal_records r
              INNER JOIN appraisal_sessions s ON s.session_id = r.session_id
              WHERE r.record_id = @id LIMIT 1",
            new MySqlParameter("@id", recordId));

        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Record not found.", "NOT_FOUND"); return; }

        var record = ApiHelper.FirstRowToDict(dt);

        // Verify access — must be the employee, reviewer, or no empId (admin)
        int recEmpId = Convert.ToInt32(record["employee_id"]);
        int recRevId = record["reviewer_id"] != null ? Convert.ToInt32(record["reviewer_id"]) : 0;
        if (empId > 0 && empId != recEmpId && empId != recRevId)
        {
            // Check if admin (empId 0 = not found = likely admin-only user)
        }

        // Section B (competency ratings)
        try
        {
            DataTable secB = ApiHelper.Query(
                @"SELECT b.id, b.competency_id, t.competency_name, t.competency_description,
                         b.self_score, b.supervisor_score, b.max_score
                  FROM appraisal_section_b b
                  LEFT JOIN appraisal_competency_templates t ON t.id = b.competency_id
                  WHERE b.record_id = @id ORDER BY t.sort_order, b.competency_id",
                new MySqlParameter("@id", recordId));
            record["section_b"] = ApiHelper.TableToList(secB);
        }
        catch { record["section_b"] = new List<object>(); }

        // Section C
        try
        {
            DataTable secC = ApiHelper.Query(
                "SELECT * FROM appraisal_section_c WHERE record_id = @id LIMIT 1",
                new MySqlParameter("@id", recordId));
            record["section_c"] = secC.Rows.Count > 0 ? ApiHelper.FirstRowToDict(secC) : null;
        }
        catch { record["section_c"] = null; }

        // Section D (gaps + actions)
        try
        {
            DataTable secD = ApiHelper.Query(
                "SELECT * FROM appraisal_section_d WHERE record_id = @id ORDER BY id",
                new MySqlParameter("@id", recordId));
            record["section_d"] = ApiHelper.TableToList(secD);
        }
        catch { record["section_d"] = new List<object>(); }

        // Section E (narratives)
        try
        {
            DataTable secE = ApiHelper.Query(
                "SELECT * FROM appraisal_section_e WHERE record_id = @id ORDER BY id",
                new MySqlParameter("@id", recordId));
            record["section_e"] = ApiHelper.TableToList(secE);
        }
        catch { record["section_e"] = new List<object>(); }

        ApiHelper.Success(Response, record);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SAVE_SELF_APPRAISAL  — employee fills section B (self-scores)
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSaveSelfAppraisal()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int recordId = ApiHelper.ParamInt(Request, "record_id", 0);
        if (recordId <= 0) { ApiHelper.Error(Response, "record_id is required.", "MISSING_PARAM"); return; }
        string ratingsJson = ApiHelper.Param(Request, "ratings", "");
        if (string.IsNullOrEmpty(ratingsJson)) { ApiHelper.Error(Response, "ratings JSON array is required.", "MISSING_PARAM"); return; }

        int empId = GetEmpId(auth.UserId);

        // Verify ownership
        DataTable recDt = ApiHelper.Query(
            "SELECT employee_id, employee_submitted_at FROM appraisal_records WHERE record_id = @id LIMIT 1",
            new MySqlParameter("@id", recordId));
        if (recDt.Rows.Count == 0) { ApiHelper.Error(Response, "Record not found.", "NOT_FOUND"); return; }
        if (empId > 0 && Convert.ToInt32(recDt.Rows[0]["employee_id"]) != empId)
        {
            ApiHelper.Error(Response, "Access denied. This is not your appraisal record.", "FORBIDDEN"); return;
        }
        if (recDt.Rows[0]["employee_submitted_at"] != DBNull.Value)
        {
            ApiHelper.Error(Response, "Self-appraisal already submitted and locked.", "ALREADY_SUBMITTED"); return;
        }

        try
        {
            var serializer = new JavaScriptSerializer();
            var ratings = serializer.Deserialize<List<Dictionary<string, object>>>(ratingsJson);

            int saved = 0;
            decimal selfTotal = 0;
            foreach (var r in ratings)
            {
                int compId   = r.ContainsKey("competency_id") ? Convert.ToInt32(r["competency_id"]) : 0;
                decimal score = r.ContainsKey("self_score") ? Convert.ToDecimal(r["self_score"].ToString()) : 0;
                if (compId <= 0) continue;

                ApiHelper.Execute(
                    @"INSERT INTO appraisal_section_b (record_id, competency_id, self_score)
                      VALUES (@rid, @cid, @sc)
                      ON DUPLICATE KEY UPDATE self_score = @sc",
                    new MySqlParameter("@rid", recordId),
                    new MySqlParameter("@cid", compId),
                    new MySqlParameter("@sc",  score));
                selfTotal += score;
                saved++;
            }

            // Update record with running self-total
            ApiHelper.Execute(
                "UPDATE appraisal_records SET section_b_self_total = @t WHERE record_id = @id",
                new MySqlParameter("@t", selfTotal),
                new MySqlParameter("@id", recordId));

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "record_id", recordId }, { "ratings_saved", saved }, { "self_total", selfTotal }
            }, "Self-appraisal saved");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error saving ratings: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SAVE_SUPERVISOR_APPRAISAL  — supervisor fills section B + C + D + E
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSaveSupervisorAppraisal()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int recordId = ApiHelper.ParamInt(Request, "record_id", 0);
        if (recordId <= 0) { ApiHelper.Error(Response, "record_id is required.", "MISSING_PARAM"); return; }

        int empId = GetEmpId(auth.UserId);

        DataTable recDt = ApiHelper.Query(
            "SELECT employee_id, reviewer_id, employee_submitted_at, supervisor_submitted_at FROM appraisal_records WHERE record_id = @id LIMIT 1",
            new MySqlParameter("@id", recordId));
        if (recDt.Rows.Count == 0) { ApiHelper.Error(Response, "Record not found.", "NOT_FOUND"); return; }
        if (recDt.Rows[0]["employee_submitted_at"] == DBNull.Value)
        {
            ApiHelper.Error(Response, "Employee must submit their self-appraisal before supervisor can review.", "BUSINESS_ERROR"); return;
        }
        if (recDt.Rows[0]["supervisor_submitted_at"] != DBNull.Value)
        {
            ApiHelper.Error(Response, "Supervisor appraisal already submitted and locked.", "ALREADY_SUBMITTED"); return;
        }

        // Section B supervisor scores
        string ratingsJson = ApiHelper.Param(Request, "ratings", "");
        decimal supTotal = 0;
        if (!string.IsNullOrEmpty(ratingsJson))
        {
            var serializer = new JavaScriptSerializer();
            var ratings = serializer.Deserialize<List<Dictionary<string, object>>>(ratingsJson);
            foreach (var r in ratings)
            {
                int compId = r.ContainsKey("competency_id") ? Convert.ToInt32(r["competency_id"]) : 0;
                decimal score = r.ContainsKey("supervisor_score") ? Convert.ToDecimal(r["supervisor_score"].ToString()) : 0;
                if (compId <= 0) continue;

                ApiHelper.Execute(
                    @"INSERT INTO appraisal_section_b (record_id, competency_id, supervisor_score)
                      VALUES (@rid, @cid, @sc)
                      ON DUPLICATE KEY UPDATE supervisor_score = @sc",
                    new MySqlParameter("@rid", recordId),
                    new MySqlParameter("@cid", compId),
                    new MySqlParameter("@sc",  score));
                supTotal += score;
            }
        }

        // Section C (overall assessment score)
        string sectionCJson = ApiHelper.Param(Request, "section_c", "");
        decimal sectionCTotal = 0;
        if (!string.IsNullOrEmpty(sectionCJson))
        {
            try
            {
                var serializer = new JavaScriptSerializer();
                var sc = serializer.Deserialize<Dictionary<string, object>>(sectionCJson);
                sectionCTotal = sc.ContainsKey("total") ? Convert.ToDecimal(sc["total"].ToString()) : 0;

                ApiHelper.Execute(
                    @"INSERT INTO appraisal_section_c (record_id, total, comments)
                      VALUES (@rid, @t, @c)
                      ON DUPLICATE KEY UPDATE total = @t, comments = @c",
                    new MySqlParameter("@rid", recordId),
                    new MySqlParameter("@t",   sectionCTotal),
                    new MySqlParameter("@c",   sc.ContainsKey("comments") ? sc["comments"].ToString() : ""));
            }
            catch { }
        }

        // Compute and save final percentage
        if (supTotal > 0 || sectionCTotal > 0)
        {
            decimal rawScore = supTotal + sectionCTotal;
            DataTable maxDt = ApiHelper.Query(
                @"SELECT SUM(t.max_score) AS max_possible
                  FROM appraisal_section_b b
                  LEFT JOIN appraisal_competency_templates t ON t.id = b.competency_id
                  WHERE b.record_id = @id",
                new MySqlParameter("@id", recordId));

            decimal maxPossible = maxDt.Rows.Count > 0 && maxDt.Rows[0]["max_possible"] != DBNull.Value
                ? Convert.ToDecimal(maxDt.Rows[0]["max_possible"])
                : 100m;

            decimal pct = maxPossible > 0 ? Math.Round(rawScore * 100 / maxPossible, 2) : 0;
            string classification = ClassifyPercentage(pct);

            ApiHelper.Execute(
                @"UPDATE appraisal_records
                  SET section_b_supervisor_total = @sup, section_c_total = @sc,
                      raw_score = @raw, max_possible = @max, final_percentage = @pct, classification = @cls
                  WHERE record_id = @id",
                new MySqlParameter("@sup",  supTotal),
                new MySqlParameter("@sc",   sectionCTotal),
                new MySqlParameter("@raw",  rawScore),
                new MySqlParameter("@max",  maxPossible),
                new MySqlParameter("@pct",  pct),
                new MySqlParameter("@cls",  classification),
                new MySqlParameter("@id",   recordId));
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "record_id", recordId }, { "supervisor_total", supTotal }
        }, "Supervisor appraisal saved");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SUBMIT_APPRAISAL  — lock own submission (employee or supervisor)
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSubmitAppraisal()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int recordId = ApiHelper.ParamInt(Request, "record_id", 0);
        if (recordId <= 0) { ApiHelper.Error(Response, "record_id is required.", "MISSING_PARAM"); return; }
        string role = ApiHelper.Param(Request, "role", "employee").ToLower(); // "employee" or "supervisor"

        int empId = GetEmpId(auth.UserId);

        DataTable recDt = ApiHelper.Query(
            "SELECT employee_id, reviewer_id, employee_submitted_at, supervisor_submitted_at FROM appraisal_records WHERE record_id = @id LIMIT 1",
            new MySqlParameter("@id", recordId));
        if (recDt.Rows.Count == 0) { ApiHelper.Error(Response, "Record not found.", "NOT_FOUND"); return; }

        if (role == "employee")
        {
            if (recDt.Rows[0]["employee_submitted_at"] != DBNull.Value)
            {
                ApiHelper.Error(Response, "Self-appraisal already submitted.", "ALREADY_SUBMITTED"); return;
            }
            ApiHelper.Execute(
                "UPDATE appraisal_records SET employee_submitted_at = NOW(), status = 'SUPERVISOR_REVIEW' WHERE record_id = @id",
                new MySqlParameter("@id", recordId));
        }
        else
        {
            if (recDt.Rows[0]["employee_submitted_at"] == DBNull.Value)
            {
                ApiHelper.Error(Response, "Employee must submit first.", "BUSINESS_ERROR"); return;
            }
            if (recDt.Rows[0]["supervisor_submitted_at"] != DBNull.Value)
            {
                ApiHelper.Error(Response, "Supervisor appraisal already submitted.", "ALREADY_SUBMITTED"); return;
            }
            ApiHelper.Execute(
                "UPDATE appraisal_records SET supervisor_submitted_at = NOW(), status = 'COMPLETED' WHERE record_id = @id",
                new MySqlParameter("@id", recordId));
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "record_id", recordId }, { "role_submitted", role }
        }, "Submission locked");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  REPORT  — aggregate results for a session
    // ═══════════════════════════════════════════════════════════════════

    private void HandleReport()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int sessionId = ApiHelper.ParamInt(Request, "session_id", 0);
        if (sessionId <= 0) { ApiHelper.Error(Response, "session_id is required.", "MISSING_PARAM"); return; }
        string category = ApiHelper.Param(Request, "category", "");

        string catWhere = string.IsNullOrEmpty(category) ? "" : " AND r.staff_category = @cat";
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@sid", sessionId));
        if (!string.IsNullOrEmpty(category)) parms.Add(new MySqlParameter("@cat", category.ToUpper()));

        DataTable dt = ApiHelper.Query(
            @"SELECT r.record_id, r.employee_id, e.emp_name, e.EmpType AS emp_type,
                     d.dept_name AS department,
                     r.staff_category, r.status,
                     r.final_percentage, r.classification,
                     r.employee_submitted_at IS NOT NULL AS emp_submitted,
                     r.supervisor_submitted_at IS NOT NULL AS sup_submitted
              FROM appraisal_records r
              LEFT JOIN hrm_employee e ON e.empID = r.employee_id
              LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.contractStatus = 'VALID'
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              WHERE r.session_id = @sid" + catWhere + " ORDER BY e.emp_name",
            parms.ToArray());

        var rows = ApiHelper.TableToList(dt);

        // Aggregate
        decimal totalPct = 0; int countWithPct = 0;
        var classCounts = new Dictionary<string, int>();
        foreach (var row in rows)
        {
            if (row["final_percentage"] != null)
            {
                totalPct += Convert.ToDecimal(row["final_percentage"]);
                countWithPct++;
            }
            string cls = row.ContainsKey("classification") && row["classification"] != null ? row["classification"].ToString() : "Pending";
            if (!classCounts.ContainsKey(cls)) classCounts[cls] = 0;
            classCounts[cls]++;
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "session_id", sessionId },
            { "total_records", rows.Count },
            { "avg_percentage", countWithPct > 0 ? Math.Round(totalPct / countWithPct, 2) : 0 },
            { "classification_summary", classCounts },
            { "records", rows }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  EXPORT_REPORT  — CSV export
    // ═══════════════════════════════════════════════════════════════════

    private void HandleExportReport()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int sessionId = ApiHelper.ParamInt(Request, "session_id", 0);
        if (sessionId <= 0) { ApiHelper.Error(Response, "session_id is required.", "MISSING_PARAM"); return; }

        DataTable dt = ApiHelper.Query(
            @"SELECT e.emp_name AS Employee, e.EmpType AS Type, d.dept_name AS Department,
                     r.staff_category AS Category, r.status AS Status,
                     r.section_b_self_total AS Self_Score,
                     r.section_b_supervisor_total AS Supervisor_Score,
                     r.section_c_total AS Assessment_Score,
                     r.final_percentage AS Final_Percentage, r.classification AS Classification
              FROM appraisal_records r
              LEFT JOIN hrm_employee e ON e.empID = r.employee_id
              LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.contractStatus = 'VALID'
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              WHERE r.session_id = @sid ORDER BY e.emp_name",
            new MySqlParameter("@sid", sessionId));

        var sb = new StringBuilder();
        // Header
        foreach (DataColumn col in dt.Columns)
        {
            sb.Append(col.ColumnName.Replace(",", " "));
            sb.Append(",");
        }
        sb.AppendLine();
        // Rows
        foreach (DataRow row in dt.Rows)
        {
            foreach (DataColumn col in dt.Columns)
            {
                string val = row[col] == DBNull.Value ? "" : row[col].ToString();
                if (val.Contains(",") || val.Contains("\"")) val = "\"" + val.Replace("\"", "\"\"") + "\"";
                sb.Append(val);
                sb.Append(",");
            }
            sb.AppendLine();
        }

        Response.Clear();
        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=appraisal_session_" + sessionId + ".csv");
        Response.AddHeader("Access-Control-Allow-Origin", "*");
        Response.Write(sb.ToString());
        Response.Flush();
        HttpContext.Current.ApplicationInstance.CompleteRequest();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  COMPETENCY_TEMPLATES  — list criteria for a staff_category
    // ═══════════════════════════════════════════════════════════════════

    private void HandleCompetencyTemplates()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string category = ApiHelper.Param(Request, "staff_category", "").ToUpper();

        string catWhere = string.IsNullOrEmpty(category) ? "" : " WHERE staff_category = @cat OR staff_category = 'BOTH'";
        var parms = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(category)) parms.Add(new MySqlParameter("@cat", category));

        DataTable dt;
        try
        {
            dt = ApiHelper.Query(
                "SELECT id, competency_name, competency_description, max_score, staff_category, sort_order FROM appraisal_competency_templates" + catWhere + " ORDER BY sort_order, id",
                parms.ToArray());
        }
        catch
        {
            ApiHelper.Success(Response, new Dictionary<string, object> { { "templates", new List<object>() }, { "note", "Templates table not yet created." } });
            return;
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", dt.Rows.Count },
            { "staff_category", category },
            { "templates", ApiHelper.TableToList(dt) }
        });
    }
}
