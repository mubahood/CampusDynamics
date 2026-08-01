using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Configuration;
using MySql.Data.MySqlClient;

/// <summary>
/// AuditCentre — Comprehensive audit trail viewer for all mark-changing events.
///
/// Provides administrative oversight of every mark mutation:
///   - Filterable/paginated audit entry table
///   - Summary statistics by action type
///   - Per-student/course drilldown timeline
///   - CSV export of filtered results
///
/// AJAX Endpoints:
///   ?ajax=dropdowns  — Load distinct users for filter dropdown
///   ?ajax=search     — Search audit entries with filters, pagination + summary stats
///   ?ajax=drilldown  — Per-student/course timeline
///   ?ajax=export     — CSV file download of filtered entries
///
/// Security:
///   - Access restricted to MarksAuthorizationService.AuditViewRoles
///     (Dean, Administrator, admin, registrar, exam_officer)
///   - Read-only — no mutations
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Task: E-10
/// </summary>
public partial class COOPERP_NewScreens_AuditCentre : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Session integrity check (C-05)
        string sessionErr = MarksSessionSecurity.ValidateSessionIntegrity();
        if (sessionErr != null)
        {
            string ajaxChk = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
            if (!string.IsNullOrEmpty(ajaxChk))
            {
                WriteJson("{\"error\":\"" + JsEsc(sessionErr) + "\"}");
            }
            return;
        }

        // Authorization: audit view roles only
        if (!MarksAuthorizationService.CanViewAudit())
        {
            string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
            if (!string.IsNullOrEmpty(ajax))
            {
                WriteJson("{\"error\":\"Access denied. You do not have permission to view the audit centre.\"}");
            }
            return;
        }

        string action = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(action)) return;

        MarksActionLogger.EnsureActionLogTable();
        System.Diagnostics.Stopwatch _actionTimer = MarksActionLogger.StartTimer();
        string _actionOutcome = MarksActionLogger.OUTCOME_SUCCESS;

        try
        {
            if (action == "dropdowns")  { HandleDropdowns(); return; }
            if (action == "search")     { HandleSearch(); return; }
            if (action == "drilldown")  { HandleDrilldown(); return; }
            if (action == "export")     { HandleExport(); return; }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            _actionOutcome = MarksActionLogger.OUTCOME_ERROR;
            WriteJson(MarksErrorHandler.HandleException(ex, "AuditCentre", action));
        }
        finally
        {
            MarksActionLogger.StopAndLog(_actionTimer, "AuditCentre", action, _actionOutcome, null, null);
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // DROPDOWNS — Distinct users from audit table
    // ═════════════════════════════════════════════════════════════════════

    private void HandleDropdowns()
    {
        StringBuilder sb = new StringBuilder();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                sb.Append("{\"users\":[");
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT DISTINCT performed_by
                      FROM acad_marks_audit
                      WHERE performed_by IS NOT NULL AND performed_by <> ''
                      ORDER BY performed_by", conn))
                {
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.Append("\""); sb.Append(JsEsc(rdr["performed_by"].ToString())); sb.Append("\"");
                        }
                    }
                }
                sb.Append("]}");
            }
        }
        catch (Exception ex)
        {
            sb.Clear();
            sb.Append("{\"error\":\"");
            sb.Append(JsEsc("Failed to load dropdowns: " + ex.Message));
            sb.Append("\",\"users\":[]}");
        }

        WriteJson(sb.ToString());
    }

    // ═════════════════════════════════════════════════════════════════════
    // SEARCH — Filtered + paginated audit entries with summary stats
    // ═════════════════════════════════════════════════════════════════════

    private void HandleSearch()
    {
        string dateFrom = (Request.Form["dateFrom"] ?? "").Trim();
        string dateTo   = (Request.Form["dateTo"]   ?? "").Trim();
        string user     = (Request.Form["user"]     ?? "").Trim();
        string course   = (Request.Form["course"]   ?? "").Trim();
        string student  = (Request.Form["student"]  ?? "").Trim();
        string action   = (Request.Form["action"]   ?? "").Trim();
        int page        = ToInt(Request.Form["page"], 1);
        int pageSize    = ToInt(Request.Form["pageSize"], 50);

        if (page < 1) page = 1;
        if (pageSize < 10) pageSize = 10;
        if (pageSize > 200) pageSize = 200;

        // Default date range: last 30 days
        DateTime dtFrom, dtTo;
        if (!DateTime.TryParse(dateFrom, out dtFrom)) dtFrom = DateTime.Now.AddDays(-30);
        if (!DateTime.TryParse(dateTo, out dtTo)) dtTo = DateTime.Now;
        // Ensure dateTo covers the entire day
        dtTo = dtTo.Date.AddDays(1).AddSeconds(-1);

        StringBuilder sb = new StringBuilder();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // ── Build WHERE clause (reused for count, summary, and data) ────
                StringBuilder where = new StringBuilder("WHERE created_at >= @from AND created_at <= @to");
                List<MySqlParameter> parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@from", dtFrom));
                parms.Add(new MySqlParameter("@to", dtTo));

                if (!string.IsNullOrEmpty(user))
                {
                    where.Append(" AND performed_by = @user");
                    parms.Add(new MySqlParameter("@user", user));
                }
                if (!string.IsNullOrEmpty(course))
                {
                    where.Append(" AND course_id LIKE @course");
                    parms.Add(new MySqlParameter("@course", "%" + course + "%"));
                }
                if (!string.IsNullOrEmpty(student))
                {
                    where.Append(" AND regno LIKE @student");
                    parms.Add(new MySqlParameter("@student", "%" + student + "%"));
                }
                if (!string.IsNullOrEmpty(action))
                {
                    where.Append(" AND action_type = @action");
                    parms.Add(new MySqlParameter("@action", action));
                }

                string whereStr = where.ToString();

                // ── Total count ─────────────────────────────────────────────
                int totalCount = 0;
                using (MySqlCommand cntCmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_marks_audit " + whereStr, conn))
                {
                    foreach (MySqlParameter p in parms) cntCmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    object result = cntCmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value) totalCount = Convert.ToInt32(result);
                }

                // ── Summary stats ───────────────────────────────────────────
                int stTotal = 0, stUpdates = 0, stApprovals = 0, stRejections = 0;
                int stImports = 0, stSubmissions = 0;

                using (MySqlCommand sumCmd = new MySqlCommand(
                    @"SELECT COALESCE(action_type, 'UPDATE') AS act, COUNT(*) AS cnt
                      FROM acad_marks_audit " + whereStr + @"
                      GROUP BY COALESCE(action_type, 'UPDATE')", conn))
                {
                    foreach (MySqlParameter p in parms)
                    {
                        sumCmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    }
                    using (MySqlDataReader rdr = sumCmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string act = rdr["act"].ToString().ToUpper();
                            int cnt = Convert.ToInt32(rdr["cnt"]);
                            stTotal += cnt;
                            if (act == "UPDATE" || act == "INSERT" || act == "DELETE") stUpdates += cnt;
                            else if (act == "APPROVE") stApprovals += cnt;
                            else if (act == "REJECT") stRejections += cnt;
                            else if (act == "IMPORT") stImports += cnt;
                            else if (act == "SUBMIT") stSubmissions += cnt;
                        }
                    }
                }

                // ── Paginated data ──────────────────────────────────────────
                int offset = (page - 1) * pageSize;

                string dataSql = @"SELECT regno, course_id, progid, acad_year, semester,
                                          old_cw_mark, new_cw_mark,
                                          old_test_mark, new_test_mark,
                                          old_exam_mark, new_exam_mark,
                                          action_type,
                                          performed_by, ip_address, change_reason,
                                          created_at
                                   FROM acad_marks_audit " + whereStr + @"
                                   ORDER BY created_at DESC
                                   LIMIT @offset, @limit";

                sb.Append("{\"totalCount\":"); sb.Append(totalCount);
                sb.Append(",\"summary\":{");
                sb.Append("\"total\":"); sb.Append(stTotal);
                sb.Append(",\"updates\":"); sb.Append(stUpdates);
                sb.Append(",\"approvals\":"); sb.Append(stApprovals);
                sb.Append(",\"rejections\":"); sb.Append(stRejections);
                sb.Append(",\"imports\":"); sb.Append(stImports);
                sb.Append(",\"submissions\":"); sb.Append(stSubmissions);
                sb.Append("}");
                sb.Append(",\"items\":[");

                using (MySqlCommand dataCmd = new MySqlCommand(dataSql, conn))
                {
                    foreach (MySqlParameter p in parms)
                    {
                        dataCmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    }
                    dataCmd.Parameters.AddWithValue("@offset", offset);
                    dataCmd.Parameters.AddWithValue("@limit", pageSize);

                    bool first = true;
                    using (MySqlDataReader rdr = dataCmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;

                            sb.Append("{");
                            sb.Append("\"studentId\":\""); sb.Append(JsEsc(rdr["regno"].ToString())); sb.Append("\"");
                            sb.Append(",\"courseId\":\""); sb.Append(JsEsc(rdr["course_id"].ToString())); sb.Append("\"");
                            sb.Append(",\"progId\":\""); sb.Append(JsEsc(rdr["progid"].ToString())); sb.Append("\"");
                            sb.Append(",\"acadYear\":\""); sb.Append(JsEsc(rdr["acad_year"].ToString())); sb.Append("\"");
                            sb.Append(",\"semester\":"); sb.Append(ToInt(rdr["semester"].ToString(), 0));

                            AppendNullableDecimal(sb, ",\"oldCwEntered\":", rdr["old_cw_mark"]);
                            AppendNullableDecimal(sb, ",\"newCwEntered\":", rdr["new_cw_mark"]);
                            AppendNullableDecimal(sb, ",\"oldTestEntered\":", rdr["old_test_mark"]);
                            AppendNullableDecimal(sb, ",\"newTestEntered\":", rdr["new_test_mark"]);
                            AppendNullableDecimal(sb, ",\"oldExamEntered\":", rdr["old_exam_mark"]);
                            AppendNullableDecimal(sb, ",\"newExamEntered\":", rdr["new_exam_mark"]);

                            sb.Append(",\"actionType\":\""); sb.Append(JsEsc(rdr["action_type"].ToString())); sb.Append("\"");
                            sb.Append(",\"actionTypeExt\":\""); sb.Append(JsEsc(rdr["action_type"].ToString())); sb.Append("\"");

                            sb.Append(",\"changedBy\":\""); sb.Append(JsEsc(rdr["performed_by"].ToString())); sb.Append("\"");
                            string ip = rdr["ip_address"] != DBNull.Value ? rdr["ip_address"].ToString() : "";
                            sb.Append(",\"ipAddress\":\""); sb.Append(JsEsc(ip)); sb.Append("\"");
                            string reason = rdr["change_reason"] != DBNull.Value ? rdr["change_reason"].ToString() : "";
                            sb.Append(",\"changeReason\":\""); sb.Append(JsEsc(reason)); sb.Append("\"");

                            DateTime dt = Convert.ToDateTime(rdr["created_at"]);
                            sb.Append(",\"changeDate\":\""); sb.Append(JsEsc(dt.ToString("yyyy-MM-dd HH:mm:ss"))); sb.Append("\"");

                            sb.Append("}");
                        }
                    }
                }

                sb.Append("]}");
            }
        }
        catch (Exception ex)
        {
            sb.Clear();
            sb.Append("{\"error\":\"");
            sb.Append(JsEsc("Search failed: " + ex.Message));
            sb.Append("\",\"items\":[],\"totalCount\":0,\"summary\":{\"total\":0,\"updates\":0,\"approvals\":0,\"rejections\":0,\"imports\":0,\"submissions\":0}}");
        }

        WriteJson(sb.ToString());
    }

    // ═════════════════════════════════════════════════════════════════════
    // DRILLDOWN — Per-student/course timeline
    // ═════════════════════════════════════════════════════════════════════

    private void HandleDrilldown()
    {
        string studentId = (Request.Form["student"]  ?? "").Trim();
        string courseId   = (Request.Form["course"]   ?? "").Trim();
        string progId     = (Request.Form["prog"]     ?? "").Trim();
        string acadYear   = (Request.Form["year"]     ?? "").Trim();
        int semester      = ToInt(Request.Form["sem"], 0);

        if (string.IsNullOrEmpty(courseId))
        {
            WriteJson("{\"error\":\"Course ID is required for drilldown.\",\"entries\":[]}");
            return;
        }

        StringBuilder sb = new StringBuilder();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Build the per-student/course timeline filter. course_id is required;
                // the rest narrow the context when supplied.
                StringBuilder where = new StringBuilder("WHERE course_id = @cid");
                List<MySqlParameter> parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@cid", courseId));

                if (!string.IsNullOrEmpty(studentId))
                {
                    where.Append(" AND regno = @sid");
                    parms.Add(new MySqlParameter("@sid", studentId));
                }
                if (!string.IsNullOrEmpty(progId))
                {
                    where.Append(" AND progid = @prog");
                    parms.Add(new MySqlParameter("@prog", progId));
                }
                if (!string.IsNullOrEmpty(acadYear))
                {
                    where.Append(" AND acad_year = @year");
                    parms.Add(new MySqlParameter("@year", acadYear));
                }
                if (semester > 0)
                {
                    where.Append(" AND semester = @sem");
                    parms.Add(new MySqlParameter("@sem", semester));
                }

                string sql = @"SELECT regno, course_id, action_type, performed_by,
                                      old_cw_mark, new_cw_mark,
                                      old_test_mark, new_test_mark,
                                      old_exam_mark, new_exam_mark,
                                      change_reason, created_at
                               FROM acad_marks_audit " + where.ToString() + @"
                               ORDER BY created_at DESC
                               LIMIT 200";

                sb.Append("{\"entries\":[");

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    foreach (MySqlParameter p in parms) cmd.Parameters.AddWithValue(p.ParameterName, p.Value);

                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;

                            string at = rdr["action_type"].ToString();
                            sb.Append("{");
                            sb.Append("\"studentId\":\""); sb.Append(JsEsc(rdr["regno"].ToString())); sb.Append("\"");
                            sb.Append(",\"courseId\":\""); sb.Append(JsEsc(rdr["course_id"].ToString())); sb.Append("\"");
                            sb.Append(",\"actionType\":\""); sb.Append(JsEsc(at)); sb.Append("\"");
                            sb.Append(",\"actionTypeExt\":\""); sb.Append(JsEsc(at)); sb.Append("\"");
                            sb.Append(",\"changedBy\":\""); sb.Append(JsEsc(rdr["performed_by"].ToString())); sb.Append("\"");

                            AppendNullableDecimal(sb, ",\"oldCwEntered\":", rdr["old_cw_mark"]);
                            AppendNullableDecimal(sb, ",\"newCwEntered\":", rdr["new_cw_mark"]);
                            AppendNullableDecimal(sb, ",\"oldTestEntered\":", rdr["old_test_mark"]);
                            AppendNullableDecimal(sb, ",\"newTestEntered\":", rdr["new_test_mark"]);
                            AppendNullableDecimal(sb, ",\"oldExamEntered\":", rdr["old_exam_mark"]);
                            AppendNullableDecimal(sb, ",\"newExamEntered\":", rdr["new_exam_mark"]);

                            string reason = rdr["change_reason"] != DBNull.Value ? rdr["change_reason"].ToString() : "";
                            sb.Append(",\"changeReason\":\""); sb.Append(JsEsc(reason)); sb.Append("\"");
                            DateTime dt = Convert.ToDateTime(rdr["created_at"]);
                            sb.Append(",\"changeDate\":\""); sb.Append(JsEsc(dt.ToString("yyyy-MM-dd HH:mm:ss"))); sb.Append("\"");
                            sb.Append("}");
                        }
                    }
                }

                sb.Append("]}");
            }
        }
        catch (Exception ex)
        {
            sb.Clear();
            sb.Append("{\"error\":\"");
            sb.Append(JsEsc("Drilldown failed: " + ex.Message));
            sb.Append("\",\"entries\":[]}");
        }

        WriteJson(sb.ToString());
    }

    // ═════════════════════════════════════════════════════════════════════
    // EXPORT — CSV download of filtered results
    // ═════════════════════════════════════════════════════════════════════

    private void HandleExport()
    {
        string dateFrom = (Request.QueryString["dateFrom"] ?? "").Trim();
        string dateTo   = (Request.QueryString["dateTo"]   ?? "").Trim();
        string user     = (Request.QueryString["user"]     ?? "").Trim();
        string course   = (Request.QueryString["course"]   ?? "").Trim();
        string student  = (Request.QueryString["student"]  ?? "").Trim();
        string action   = (Request.QueryString["action"]   ?? "").Trim();

        DateTime dtFrom, dtTo;
        if (!DateTime.TryParse(dateFrom, out dtFrom)) dtFrom = DateTime.Now.AddDays(-30);
        if (!DateTime.TryParse(dateTo, out dtTo)) dtTo = DateTime.Now;
        dtTo = dtTo.Date.AddDays(1).AddSeconds(-1);

        StringBuilder csv = new StringBuilder();
        csv.AppendLine("Date/Time,User,IP Address,Action,Action Detail,Course,Student,Old CW,New CW,Old Test,New Test,Old Exam,New Exam,Reason");

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                StringBuilder where = new StringBuilder("WHERE created_at >= @from AND created_at <= @to");
                List<MySqlParameter> parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@from", dtFrom));
                parms.Add(new MySqlParameter("@to", dtTo));

                if (!string.IsNullOrEmpty(user))
                {
                    where.Append(" AND performed_by = @user");
                    parms.Add(new MySqlParameter("@user", user));
                }
                if (!string.IsNullOrEmpty(course))
                {
                    where.Append(" AND course_id LIKE @course");
                    parms.Add(new MySqlParameter("@course", "%" + course + "%"));
                }
                if (!string.IsNullOrEmpty(student))
                {
                    where.Append(" AND regno LIKE @student");
                    parms.Add(new MySqlParameter("@student", "%" + student + "%"));
                }
                if (!string.IsNullOrEmpty(action))
                {
                    where.Append(" AND action_type = @action");
                    parms.Add(new MySqlParameter("@action", action));
                }

                string sql = @"SELECT regno, course_id,
                                      old_cw_mark, new_cw_mark,
                                      old_test_mark, new_test_mark,
                                      old_exam_mark, new_exam_mark,
                                      action_type,
                                      performed_by, ip_address, change_reason,
                                      created_at
                               FROM acad_marks_audit " + where.ToString() + @"
                               ORDER BY created_at DESC
                               LIMIT 10000";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    foreach (MySqlParameter p in parms)
                    {
                        cmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    }

                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            DateTime dt = Convert.ToDateTime(rdr["created_at"]);
                            csv.Append(CsvEsc(dt.ToString("yyyy-MM-dd HH:mm:ss"))); csv.Append(",");
                            csv.Append(CsvEsc(rdr["performed_by"].ToString())); csv.Append(",");
                            csv.Append(CsvEsc(rdr["ip_address"] != DBNull.Value ? rdr["ip_address"].ToString() : "")); csv.Append(",");
                            csv.Append(CsvEsc(rdr["action_type"].ToString())); csv.Append(",");
                            csv.Append(CsvEsc(rdr["action_type"].ToString())); csv.Append(",");
                            csv.Append(CsvEsc(rdr["course_id"].ToString())); csv.Append(",");
                            csv.Append(CsvEsc(rdr["regno"].ToString())); csv.Append(",");
                            csv.Append(DecStr(rdr["old_cw_mark"])); csv.Append(",");
                            csv.Append(DecStr(rdr["new_cw_mark"])); csv.Append(",");
                            csv.Append(DecStr(rdr["old_test_mark"])); csv.Append(",");
                            csv.Append(DecStr(rdr["new_test_mark"])); csv.Append(",");
                            csv.Append(DecStr(rdr["old_exam_mark"])); csv.Append(",");
                            csv.Append(DecStr(rdr["new_exam_mark"])); csv.Append(",");
                            csv.Append(CsvEsc(rdr["change_reason"] != DBNull.Value ? rdr["change_reason"].ToString() : ""));
                            csv.AppendLine();
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            csv.Clear();
            csv.AppendLine("Error exporting audit data: " + ex.Message);
        }

        Response.Clear();
        Response.ContentType = "text/csv";
        string filename = "audit_export_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=" + filename);
        Response.Write(csv.ToString());
        Response.End();
    }

    // ═════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═════════════════════════════════════════════════════════════════════

    private void WriteJson(string json)
    {
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Write(json);
        Response.End();
    }

    private static int ToInt(string s, int def)
    {
        int val;
        return int.TryParse(s, out val) ? val : def;
    }

    private static string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "");
    }

    private static string CsvEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        if (s.IndexOf(',') >= 0 || s.IndexOf('"') >= 0 || s.IndexOf('\n') >= 0)
        {
            return "\"" + s.Replace("\"", "\"\"") + "\"";
        }
        return s;
    }

    private static string DecStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return Convert.ToDecimal(val).ToString("0.##");
    }

    private static void AppendNullableDecimal(StringBuilder sb, string prefix, object val)
    {
        sb.Append(prefix);
        if (val == null || val == DBNull.Value)
        {
            sb.Append("null");
        }
        else
        {
            sb.Append(Convert.ToDecimal(val).ToString("0.##"));
        }
    }
}
