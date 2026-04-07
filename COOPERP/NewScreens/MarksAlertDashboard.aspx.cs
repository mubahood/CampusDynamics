using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// MarksAlertDashboard — Operational alerting dashboard for marks module (G-05).
///
/// Monitors system health by querying acad_marks_action_log for:
///   - Error rates, auth failures, lock conflicts
///   - Response time metrics
///   - Activity trends (hourly / daily)
///   - Top error sources
///
/// AJAX Endpoints:
///   ?ajax=summary  — Aggregated stats for selected time period
///   ?ajax=logs     — Paginated, filterable action log entries
///
/// Security:
///   - Restricted to Dean, Administrator, admin, registrar, exam_officer
///   - Read-only — no mutations, no CSRF needed
///
/// Design: C# 5 compatible. Task: G-05
/// </summary>
public partial class COOPERP_NewScreens_MarksAlertDashboard : System.Web.UI.Page
{
    // ═════════════════════════════════════════════════════════════════════
    // Page Load
    // ═════════════════════════════════════════════════════════════════════

    protected void Page_Load(object sender, EventArgs e)
    {
        MarksActionLogger.EnsureActionLogTable();

        // Session integrity check (C-05)
        string sessionErr = MarksSessionSecurity.ValidateSessionIntegrity();
        if (sessionErr != null)
        {
            WriteJson("{\"error\":\"" + JsEsc(sessionErr) + "\"}");
            return;
        }

        // Auth gate — centralized via MarksAuthorizationService (Batch 13)
        if (!MarksAuthorizationService.CanViewAlertDashboard())
        {
            WriteJson("{\"error\":\"Access denied. Administrator role required.\"}");
            return;
        }

        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        System.Diagnostics.Stopwatch timer = MarksActionLogger.StartTimer();
        string outcome = MarksActionLogger.OUTCOME_SUCCESS;

        try
        {
            if (ajax == "summary") { HandleSummary(); return; }
            if (ajax == "logs")    { HandleLogs(); return; }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            outcome = MarksActionLogger.OUTCOME_ERROR;
            WriteJson(MarksErrorHandler.HandleException(ex, "MarksAlertDashboard", ajax));
        }
        finally
        {
            MarksActionLogger.StopAndLog(timer, "MarksAlertDashboard", ajax, outcome, null, null);
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Summary (?ajax=summary)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleSummary()
    {
        int days = ToInt(Request.QueryString["days"], 1);
        if (days < 1) days = 1;
        if (days > 90) days = 90;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(MarksConfiguration.ConnStr))
            {
                conn.Open();
                StringBuilder sb = new StringBuilder();
                sb.Append("{");

                // ── Aggregate stats ──────────────────────────────────────
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT
                        COUNT(*) AS total_actions,
                        SUM(CASE WHEN outcome IN ('error','system_error') THEN 1 ELSE 0 END) AS errors,
                        SUM(CASE WHEN outcome = 'auth_fail' THEN 1 ELSE 0 END) AS auth_failures,
                        SUM(CASE WHEN outcome = 'locked' THEN 1 ELSE 0 END) AS lock_conflicts,
                        SUM(CASE WHEN outcome = 'validation_fail' THEN 1 ELSE 0 END) AS validation_fails,
                        ROUND(AVG(duration_ms)) AS avg_duration,
                        MAX(duration_ms) AS max_duration,
                        SUM(CASE WHEN outcome = 'success' THEN 1 ELSE 0 END) AS successes
                      FROM acad_marks_action_log
                      WHERE created_at >= DATE_SUB(NOW(), INTERVAL @days DAY)", conn))
                {
                    cmd.Parameters.AddWithValue("@days", days);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            sb.AppendFormat("\"total_actions\":{0},", SafeInt(rdr, "total_actions"));
                            sb.AppendFormat("\"errors\":{0},", SafeInt(rdr, "errors"));
                            sb.AppendFormat("\"auth_failures\":{0},", SafeInt(rdr, "auth_failures"));
                            sb.AppendFormat("\"lock_conflicts\":{0},", SafeInt(rdr, "lock_conflicts"));
                            sb.AppendFormat("\"validation_fails\":{0},", SafeInt(rdr, "validation_fails"));
                            sb.AppendFormat("\"avg_duration\":{0},", SafeInt(rdr, "avg_duration"));
                            sb.AppendFormat("\"max_duration\":{0},", SafeInt(rdr, "max_duration"));
                            sb.AppendFormat("\"successes\":{0},", SafeInt(rdr, "successes"));
                        }
                    }
                }

                // ── Top error pages ──────────────────────────────────────
                sb.Append("\"top_error_pages\":[");
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT page, COUNT(*) AS cnt
                      FROM acad_marks_action_log
                      WHERE created_at >= DATE_SUB(NOW(), INTERVAL @days DAY)
                        AND outcome IN ('error','system_error')
                      GROUP BY page
                      ORDER BY cnt DESC
                      LIMIT 5", conn))
                {
                    cmd.Parameters.AddWithValue("@days", days);
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.AppendFormat("{{\"page\":\"{0}\",\"count\":{1}}}",
                                JsEsc(rdr["page"].ToString()), Convert.ToInt32(rdr["cnt"]));
                        }
                    }
                }
                sb.Append("],");

                // ── Activity trend ───────────────────────────────────────
                string trendSql;
                string trendFormat;
                if (days <= 1)
                {
                    trendSql = @"SELECT DATE_FORMAT(created_at, '%H:00') AS bucket,
                                        COUNT(*) AS cnt,
                                        SUM(CASE WHEN outcome IN ('error','system_error','auth_fail') THEN 1 ELSE 0 END) AS err_cnt
                                 FROM acad_marks_action_log
                                 WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
                                 GROUP BY bucket ORDER BY bucket";
                    trendFormat = "hourly";
                }
                else
                {
                    trendSql = @"SELECT DATE_FORMAT(created_at, '%Y-%m-%d') AS bucket,
                                        COUNT(*) AS cnt,
                                        SUM(CASE WHEN outcome IN ('error','system_error','auth_fail') THEN 1 ELSE 0 END) AS err_cnt
                                 FROM acad_marks_action_log
                                 WHERE created_at >= DATE_SUB(NOW(), INTERVAL @days DAY)
                                 GROUP BY bucket ORDER BY bucket";
                    trendFormat = "daily";
                }

                sb.AppendFormat("\"trend_type\":\"{0}\",", trendFormat);
                sb.Append("\"trend\":[");
                using (MySqlCommand cmd = new MySqlCommand(trendSql, conn))
                {
                    cmd.Parameters.AddWithValue("@days", days);
                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.AppendFormat("{{\"t\":\"{0}\",\"n\":{1},\"e\":{2}}}",
                                JsEsc(rdr["bucket"].ToString()),
                                Convert.ToInt32(rdr["cnt"]),
                                Convert.ToInt32(rdr["err_cnt"]));
                        }
                    }
                }
                sb.Append("],");

                // ── Active users ─────────────────────────────────────────
                sb.Append("\"active_users\":");
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT COUNT(DISTINCT username) AS cnt
                      FROM acad_marks_action_log
                      WHERE created_at >= DATE_SUB(NOW(), INTERVAL @days DAY)
                        AND username <> ''", conn))
                {
                    cmd.Parameters.AddWithValue("@days", days);
                    sb.Append(Convert.ToInt32(cmd.ExecuteScalar()));
                }

                sb.Append(",\"days\":");
                sb.Append(days);
                sb.Append("}");

                WriteJson(sb.ToString());
            }
        }
        catch (Exception ex)
        {
            WriteJson("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // AJAX: Logs (?ajax=logs)
    // ═════════════════════════════════════════════════════════════════════

    private void HandleLogs()
    {
        int days = ToInt(Request.QueryString["days"], 1);
        if (days < 1) days = 1;
        if (days > 90) days = 90;

        string filterPage    = (Request.QueryString["fpage"] ?? "").Trim();
        string filterAction  = (Request.QueryString["faction"] ?? "").Trim();
        string filterOutcome = (Request.QueryString["foutcome"] ?? "").Trim();
        string filterUser    = (Request.QueryString["fuser"] ?? "").Trim();
        int page = ToInt(Request.QueryString["page"], 1);
        if (page < 1) page = 1;
        int pageSize = MarksConfiguration.DefaultAuditPageSize;
        int offset = (page - 1) * pageSize;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(MarksConfiguration.ConnStr))
            {
                conn.Open();

                // ── Build WHERE clause ───────────────────────────────────
                StringBuilder where = new StringBuilder("WHERE created_at >= DATE_SUB(NOW(), INTERVAL @days DAY)");
                List<MySqlParameter> parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@days", days));

                if (!string.IsNullOrEmpty(filterPage))
                {
                    where.Append(" AND page = @fpage");
                    parms.Add(new MySqlParameter("@fpage", filterPage));
                }
                if (!string.IsNullOrEmpty(filterAction))
                {
                    where.Append(" AND action = @faction");
                    parms.Add(new MySqlParameter("@faction", filterAction));
                }
                if (!string.IsNullOrEmpty(filterOutcome))
                {
                    where.Append(" AND outcome = @foutcome");
                    parms.Add(new MySqlParameter("@foutcome", filterOutcome));
                }
                if (!string.IsNullOrEmpty(filterUser))
                {
                    where.Append(" AND username LIKE @fuser");
                    parms.Add(new MySqlParameter("@fuser", "%" + filterUser + "%"));
                }

                // ── Total count ──────────────────────────────────────────
                int totalRows = 0;
                using (MySqlCommand cntCmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_marks_action_log " + where.ToString(), conn))
                {
                    foreach (MySqlParameter p in parms) cntCmd.Parameters.Add(CloneParam(p));
                    totalRows = Convert.ToInt32(cntCmd.ExecuteScalar());
                }

                // ── Paged rows ───────────────────────────────────────────
                StringBuilder sb = new StringBuilder();
                sb.Append("{\"total\":");
                sb.Append(totalRows);
                sb.Append(",\"page\":");
                sb.Append(page);
                sb.Append(",\"pageSize\":");
                sb.Append(pageSize);
                sb.Append(",\"rows\":[");

                string sql = String.Format(
                    @"SELECT id, action, page, username, ip_address, duration_ms, outcome,
                             correlation_id, created_at
                      FROM acad_marks_action_log {0}
                      ORDER BY created_at DESC
                      LIMIT @limit OFFSET @offset", where.ToString());

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(CloneParam(p));
                    cmd.Parameters.AddWithValue("@limit", pageSize);
                    cmd.Parameters.AddWithValue("@offset", offset);

                    bool first = true;
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            if (!first) sb.Append(",");
                            first = false;
                            sb.Append("{");
                            sb.AppendFormat("\"id\":{0},", Convert.ToInt64(rdr["id"]));
                            sb.AppendFormat("\"action\":\"{0}\",", JsEsc(rdr["action"].ToString()));
                            sb.AppendFormat("\"page\":\"{0}\",", JsEsc(rdr["page"].ToString()));
                            sb.AppendFormat("\"user\":\"{0}\",", JsEsc(rdr["username"].ToString()));
                            sb.AppendFormat("\"ip\":\"{0}\",", JsEsc(rdr["ip_address"].ToString()));
                            sb.AppendFormat("\"ms\":{0},", Convert.ToInt32(rdr["duration_ms"]));
                            sb.AppendFormat("\"outcome\":\"{0}\",", JsEsc(rdr["outcome"].ToString()));
                            sb.AppendFormat("\"corr\":\"{0}\",", JsEsc(rdr["correlation_id"].ToString()));
                            sb.AppendFormat("\"time\":\"{0}\"",
                                Convert.ToDateTime(rdr["created_at"]).ToString("yyyy-MM-dd HH:mm:ss"));
                            sb.Append("}");
                        }
                    }
                }

                // ── Filter dropdown options ──────────────────────────────
                sb.Append("],\"filter_options\":{");

                sb.Append("\"pages\":[");
                AppendDistinctValues(conn, "page", sb);
                sb.Append("],");

                sb.Append("\"actions\":[");
                AppendDistinctValues(conn, "action", sb);
                sb.Append("],");

                sb.Append("\"outcomes\":[");
                AppendDistinctValues(conn, "outcome", sb);
                sb.Append("]");

                sb.Append("}}");
                WriteJson(sb.ToString());
            }
        }
        catch (Exception ex)
        {
            WriteJson("{\"error\":\"" + JsEsc(ex.Message) + "\"}");
        }
    }

    // ═════════════════════════════════════════════════════════════════════
    // Helpers
    // ═════════════════════════════════════════════════════════════════════

    private void AppendDistinctValues(MySqlConnection conn, string column, StringBuilder sb)
    {
        string sql = String.Format(
            "SELECT DISTINCT {0} FROM acad_marks_action_log WHERE {0} <> '' ORDER BY {0}", column);
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            bool first = true;
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    if (!first) sb.Append(",");
                    first = false;
                    sb.AppendFormat("\"{0}\"", JsEsc(rdr[0].ToString()));
                }
            }
        }
    }

    private static int SafeInt(MySqlDataReader rdr, string col)
    {
        object val = rdr[col];
        if (val == null || val == DBNull.Value) return 0;
        return Convert.ToInt32(val);
    }

    private static MySqlParameter CloneParam(MySqlParameter p)
    {
        return new MySqlParameter(p.ParameterName, p.Value);
    }

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
}
