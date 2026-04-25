using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AppraisalDashboard : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─── Query-string helpers ──────────────────────────────────────────
    private int QsSession
    {
        get
        {
            int v;
            return int.TryParse(Request.QueryString["sid"] ?? "0", out v) && v > 0 ? v : 0;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSessionFilter();
            LoadDashboard();
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SESSION FILTER DROPDOWN
    // ═══════════════════════════════════════════════════════════════════
    private void LoadSessionFilter()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT session_id, session_title, status,
                     DATE_FORMAT(period_start,'%d %b %Y') AS ps,
                     DATE_FORMAT(period_end,'%d %b %Y') AS pe
              FROM appraisal_sessions
              ORDER BY FIELD(status,'ACTIVE','DRAFT','CLOSED','ARCHIVED'), created_at DESC");

        StringBuilder sb = new StringBuilder();
        sb.Append("<option value='0'>All Sessions</option>");
        foreach (DataRow r in dt.Rows)
        {
            int sid = Convert.ToInt32(r["session_id"]);
            string label = string.Format("{0} ({1}) — {2} to {3}",
                HttpUtility.HtmlEncode(r["session_title"].ToString()),
                r["status"].ToString(),
                r["ps"].ToString(),
                r["pe"].ToString());
            sb.AppendFormat("<option value='{0}'{1}>{2}</option>",
                sid,
                sid == QsSession ? " selected" : "",
                label);
        }
        litSessionOptions.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  MAIN DASHBOARD LOAD
    // ═══════════════════════════════════════════════════════════════════
    private void LoadDashboard()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                LoadKpis(conn);
                LoadCategoryBreakdown(conn);
                LoadDepartmentBreakdown(conn);
                LoadStatusBreakdown(conn);
                LoadRecentActivity(conn);
                LoadOverdueAlerts(conn);
            }
        }
        catch (Exception ex)
        {
            litAlerts.Text = "<div class='pa-alert pa-alert--error'>Error loading dashboard: " +
                HttpUtility.HtmlEncode(ex.Message) + "</div>";
        }
    }

    // ─── Session filter clause ─────────────────────────────────────────
    private string SessionFilter(string alias)
    {
        if (QsSession > 0)
            return string.Format(" AND {0}.session_id = {1}", alias, QsSession);
        return "";
    }

    private MySqlParameter[] SessionParams()
    {
        if (QsSession > 0)
            return new MySqlParameter[] { new MySqlParameter("@sid", QsSession) };
        return new MySqlParameter[0];
    }

    // ═══════════════════════════════════════════════════════════════════
    //  KPI CARDS
    // ═══════════════════════════════════════════════════════════════════
    private void LoadKpis(MySqlConnection conn)
    {
        string sessionWhere = QsSession > 0 ? " WHERE ar.session_id = " + QsSession : "";

        string sql = string.Format(
            @"SELECT
                COUNT(*)                                                                   AS total,
                SUM(CASE WHEN ar.status = 'COMPLETED' THEN 1 ELSE 0 END)                  AS completed,
                SUM(CASE WHEN ar.status IN ('EMPLOYEE_IN_PROGRESS','EMPLOYEE_SUBMITTED',
                          'SUPERVISOR_IN_PROGRESS','RETURNED') THEN 1 ELSE 0 END)                    AS in_progress,
                SUM(CASE WHEN ar.status = 'PENDING' THEN 1 ELSE 0 END)                    AS pending,
                SUM(CASE WHEN ar.status = 'CANCELLED' THEN 1 ELSE 0 END)                  AS cancelled,
                ROUND(AVG(CASE WHEN ar.status = 'COMPLETED' THEN ar.final_percentage END),1) AS avg_score
              FROM appraisal_records ar
              {0}", sessionWhere);

        DataTable dt = ExecuteQuery(conn, sql);
        DataRow r = dt.Rows[0];

        int total     = SafeInt(r["total"]);
        int completed = SafeInt(r["completed"]);
        int inProg    = SafeInt(r["in_progress"]);
        int pending   = SafeInt(r["pending"]);
        int cancelled = SafeInt(r["cancelled"]);
        string avgScore = (r["avg_score"] != null && r["avg_score"] != DBNull.Value)
            ? Convert.ToDecimal(r["avg_score"]).ToString("F1") + "%" : "—";

        double pct = total > 0 ? Math.Round((double)completed / total * 100, 1) : 0;

        litKpiTotal.Text      = total.ToString("N0");
        litKpiCompleted.Text  = completed.ToString("N0");
        litKpiInProgress.Text = inProg.ToString("N0");
        litKpiPending.Text    = pending.ToString("N0");
        litKpiAvgScore.Text   = avgScore;
        litKpiCompletion.Text = pct.ToString("F1") + "%";

        // Overdue count (sessions past deadline with pending appraisals)
        string overdueWhere = QsSession > 0
            ? " AND ar.session_id = " + QsSession
            : "";
        DataTable dtOver = ExecuteQuery(conn, string.Format(
            @"SELECT COUNT(*) AS cnt
              FROM appraisal_records ar
              INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
              WHERE ar.status NOT IN ('COMPLETED','CANCELLED')
                AND s.deadline < CURDATE()
                {0}", overdueWhere));
        int overdue = SafeInt(dtOver.Rows[0]["cnt"]);
        litKpiOverdue.Text = overdue.ToString("N0");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CATEGORY BREAKDOWN (Academic / Administrative / Support)
    // ═══════════════════════════════════════════════════════════════════
    private void LoadCategoryBreakdown(MySqlConnection conn)
    {
        string sessionWhere = QsSession > 0 ? " AND ar.session_id = " + QsSession : "";

        string sql = string.Format(
            @"SELECT
                ar.staff_category,
                COUNT(*) AS total,
                SUM(CASE WHEN ar.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
                SUM(CASE WHEN ar.status IN ('EMPLOYEE_IN_PROGRESS','EMPLOYEE_SUBMITTED',
                          'SUPERVISOR_IN_PROGRESS') THEN 1 ELSE 0 END) AS in_progress,
                SUM(CASE WHEN ar.status = 'PENDING' THEN 1 ELSE 0 END) AS pending,
                ROUND(AVG(CASE WHEN ar.status = 'COMPLETED' THEN ar.final_percentage END),1) AS avg_score
              FROM appraisal_records ar
              WHERE 1=1 {0}
              GROUP BY ar.staff_category
              ORDER BY FIELD(ar.staff_category,'ACADEMIC','ADMINISTRATIVE','SUPPORT')", sessionWhere);

        DataTable dt = ExecuteQuery(conn, sql);

        StringBuilder sb = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='6' style='text-align:center;color:#999;padding:20px;'>No appraisal data available</td></tr>");
        }
        else
        {
            foreach (DataRow r in dt.Rows)
            {
                int total = SafeInt(r["total"]);
                int comp  = SafeInt(r["completed"]);
                double pct = total > 0 ? Math.Round((double)comp / total * 100, 1) : 0;
                string avg = (r["avg_score"] != null && r["avg_score"] != DBNull.Value)
                    ? Convert.ToDecimal(r["avg_score"]).ToString("F1") + "%" : "—";

                sb.Append("<tr>");
                sb.AppendFormat("<td><strong>{0}</strong></td>", HttpUtility.HtmlEncode(SafeStr(r["staff_category"])));
                sb.AppendFormat("<td class='pa-num'>{0}</td>", total);
                sb.AppendFormat("<td class='pa-num'>{0}</td>", comp);
                sb.AppendFormat("<td class='pa-num'>{0}</td>", SafeInt(r["in_progress"]));
                sb.AppendFormat("<td class='pa-num'>{0}</td>", SafeInt(r["pending"]));
                sb.AppendFormat("<td>{0}</td>", BuildMiniProgress(comp, total));
                sb.AppendFormat("<td class='pa-num'>{0}</td>", avg);
                sb.Append("</tr>");
            }
        }
        litCategoryRows.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DEPARTMENT BREAKDOWN
    // ═══════════════════════════════════════════════════════════════════
    private void LoadDepartmentBreakdown(MySqlConnection conn)
    {
        string sessionWhere = QsSession > 0 ? " AND ar.session_id = " + QsSession : "";

        string sql = string.Format(
            @"SELECT
                IFNULL(e.department, 'Unassigned') AS department,
                COUNT(*) AS total,
                SUM(CASE WHEN ar.status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
                SUM(CASE WHEN ar.status NOT IN ('COMPLETED','CANCELLED') THEN 1 ELSE 0 END) AS outstanding,
                ROUND(AVG(CASE WHEN ar.status = 'COMPLETED' THEN ar.final_percentage END),1) AS avg_score
              FROM appraisal_records ar
              INNER JOIN hrm_employee e ON e.empID = ar.employee_id
              WHERE 1=1 {0}
              GROUP BY IFNULL(e.department, 'Unassigned')
              ORDER BY COUNT(*) DESC
              LIMIT 20", sessionWhere);

        DataTable dt = ExecuteQuery(conn, sql);

        StringBuilder sb = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='5' style='text-align:center;color:#999;padding:20px;'>No data</td></tr>");
        }
        else
        {
            foreach (DataRow r in dt.Rows)
            {
                int total = SafeInt(r["total"]);
                int comp  = SafeInt(r["completed"]);
                string avg = (r["avg_score"] != null && r["avg_score"] != DBNull.Value)
                    ? Convert.ToDecimal(r["avg_score"]).ToString("F1") + "%" : "—";

                sb.Append("<tr>");
                sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(r["department"])));
                sb.AppendFormat("<td class='pa-num'>{0}</td>", total);
                sb.AppendFormat("<td class='pa-num'>{0}</td>", comp);
                sb.AppendFormat("<td>{0}</td>", BuildMiniProgress(comp, total));
                sb.AppendFormat("<td class='pa-num'>{0}</td>", avg);
                sb.Append("</tr>");
            }
        }
        litDeptRows.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  STATUS BREAKDOWN (for chart-like display)
    // ═══════════════════════════════════════════════════════════════════
    private void LoadStatusBreakdown(MySqlConnection conn)
    {
        string sessionWhere = QsSession > 0 ? " AND ar.session_id = " + QsSession : "";

        string sql = string.Format(
            @"SELECT ar.status, COUNT(*) AS cnt
              FROM appraisal_records ar
              WHERE 1=1 {0}
              GROUP BY ar.status
              ORDER BY FIELD(ar.status,'PENDING','EMPLOYEE_IN_PROGRESS','EMPLOYEE_SUBMITTED',
                  'SUPERVISOR_IN_PROGRESS','COMPLETED','CANCELLED')", sessionWhere);

        DataTable dt = ExecuteQuery(conn, sql);

        // Also get total for percentage
        int grandTotal = 0;
        foreach (DataRow r in dt.Rows)
            grandTotal += SafeInt(r["cnt"]);

        StringBuilder sb = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            sb.Append("<div class='pa-status-empty'>No appraisal records found</div>");
        }
        else
        {
            foreach (DataRow r in dt.Rows)
            {
                string status = SafeStr(r["status"]);
                int cnt = SafeInt(r["cnt"]);
                double pct = grandTotal > 0 ? Math.Round((double)cnt / grandTotal * 100, 1) : 0;
                string color = GetStatusColor(status);
                string label = FormatStatusLabel(status);

                sb.Append("<div class='pa-status-row'>");
                sb.AppendFormat("<span class='pa-status-row__label'>{0}</span>", label);
                sb.AppendFormat("<span class='pa-status-row__count'>{0}</span>", cnt);
                sb.AppendFormat("<div class='pa-status-row__bar'><div class='pa-status-row__fill' style='width:{0}%;background:{1};'></div></div>", pct, color);
                sb.AppendFormat("<span class='pa-status-row__pct'>{0}%</span>", pct);
                sb.Append("</div>");
            }
        }
        litStatusBars.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  RECENT ACTIVITY (last 15 status changes)
    // ═══════════════════════════════════════════════════════════════════
    private void LoadRecentActivity(MySqlConnection conn)
    {
        string sessionWhere = QsSession > 0 ? " AND ar.session_id = " + QsSession : "";

        string sql = string.Format(
            @"SELECT ar.record_id, ar.status, ar.updated_at, ar.final_percentage,
                     e.emp_name, e.EMP_CODE,
                     s.session_title
              FROM appraisal_records ar
              INNER JOIN hrm_employee e ON e.empID = ar.employee_id
              INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
              WHERE 1=1 {0}
              ORDER BY ar.updated_at DESC
              LIMIT 15", sessionWhere);

        DataTable dt = ExecuteQuery(conn, sql);

        StringBuilder sb = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan='5' style='text-align:center;color:#999;padding:20px;'>No activity yet</td></tr>");
        }
        else
        {
            foreach (DataRow r in dt.Rows)
            {
                string status = SafeStr(r["status"]);
                sb.Append("<tr>");
                sb.AppendFormat("<td><strong>{0}</strong><br/><span style='font-size:10px;color:#999;'>{1}</span></td>",
                    HttpUtility.HtmlEncode(SafeStr(r["emp_name"])),
                    HttpUtility.HtmlEncode(SafeStr(r["EMP_CODE"])));
                sb.AppendFormat("<td style='font-size:11px;'>{0}</td>",
                    HttpUtility.HtmlEncode(SafeStr(r["session_title"])));
                sb.AppendFormat("<td><span class='pa-rec-badge pa-rec-badge--{0}'>{1}</span></td>",
                    GetRecordBadgeModifier(status), FormatStatusLabel(status));

                string score = (r["final_percentage"] != null && r["final_percentage"] != DBNull.Value)
                    ? Convert.ToDecimal(r["final_percentage"]).ToString("F1") + "%" : "—";
                sb.AppendFormat("<td class='pa-num'>{0}</td>", score);

                string when = FormatTimeAgo(r["updated_at"]);
                sb.AppendFormat("<td style='font-size:11px;color:#888;white-space:nowrap;'>{0}</td>", when);
                sb.Append("</tr>");
            }
        }
        litRecentRows.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  OVERDUE ALERTS
    // ═══════════════════════════════════════════════════════════════════
    private void LoadOverdueAlerts(MySqlConnection conn)
    {
        string sessionWhere = QsSession > 0 ? " AND ar.session_id = " + QsSession : "";

        string sql = string.Format(
            @"SELECT s.session_title, s.deadline,
                     COUNT(*) AS cnt,
                     DATEDIFF(CURDATE(), s.deadline) AS days_overdue
              FROM appraisal_records ar
              INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
              WHERE ar.status NOT IN ('COMPLETED','CANCELLED')
                AND s.deadline < CURDATE()
                {0}
              GROUP BY s.session_id
              ORDER BY s.deadline ASC
              LIMIT 10", sessionWhere);

        DataTable dt = ExecuteQuery(conn, sql);

        StringBuilder sb = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            sb.Append("<div class='pa-no-alerts'>");
            sb.Append("<svg xmlns='http://www.w3.org/2000/svg' width='20' height='20' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='20 6 9 17 4 12'/></svg>");
            sb.Append(" No overdue appraisals — all on track!");
            sb.Append("</div>");
        }
        else
        {
            foreach (DataRow r in dt.Rows)
            {
                int daysOver = SafeInt(r["days_overdue"]);
                string urgency = daysOver > 30 ? "critical" : daysOver > 14 ? "high" : "medium";
                sb.AppendFormat("<div class='pa-alert-item pa-alert-item--{0}'>", urgency);
                sb.AppendFormat("<div class='pa-alert-item__title'>{0}</div>",
                    HttpUtility.HtmlEncode(SafeStr(r["session_title"])));
                sb.AppendFormat("<div class='pa-alert-item__detail'>{0} outstanding &middot; {1} days overdue &middot; Deadline: {2}</div>",
                    SafeInt(r["cnt"]),
                    daysOver,
                    FormatDateDisplay(r["deadline"]));
                sb.Append("</div>");
            }
        }
        litAlerts.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════

    private string BuildMiniProgress(int completed, int total)
    {
        if (total == 0) return "<span style='color:#bbb;font-size:11px;'>—</span>";
        double pct = Math.Round((double)completed / total * 100, 1);
        string color = pct >= 75 ? "#28a745" : pct >= 40 ? "#f59e0b" : pct > 0 ? "#174DA4" : "#dee2e6";
        return string.Format(
            "<div class='pa-mini-prog'>" +
            "<div class='pa-mini-prog__bar' style='width:{0}%;background:{1}'></div>" +
            "</div>" +
            "<span class='pa-mini-prog__text'>{0}%</span>",
            pct, color);
    }

    private string GetStatusColor(string status)
    {
        switch (status.ToUpper())
        {
            case "PENDING":                return "#6c757d";
            case "EMPLOYEE_IN_PROGRESS":   return "#17a2b8";
            case "EMPLOYEE_SUBMITTED":     return "#007bff";
            case "SUPERVISOR_IN_PROGRESS": return "#f59e0b";
            case "COMPLETED":              return "#28a745";
            case "CANCELLED":              return "#dc3545";
            default:                       return "#adb5bd";
        }
    }

    private string FormatStatusLabel(string status)
    {
        switch (status.ToUpper())
        {
            case "PENDING":                return "Pending";
            case "EMPLOYEE_IN_PROGRESS":   return "Employee In Progress";
            case "EMPLOYEE_SUBMITTED":     return "Employee Submitted";
            case "SUPERVISOR_IN_PROGRESS": return "Supervisor In Progress";
            case "COMPLETED":              return "Completed";
            case "CANCELLED":              return "Cancelled";
            default:                       return status;
        }
    }

    private string GetRecordBadgeModifier(string status)
    {
        switch (status.ToUpper())
        {
            case "PENDING":                return "pending";
            case "EMPLOYEE_IN_PROGRESS":   return "emp-prog";
            case "EMPLOYEE_SUBMITTED":     return "emp-done";
            case "SUPERVISOR_IN_PROGRESS": return "sup-prog";
            case "COMPLETED":              return "completed";
            case "CANCELLED":              return "cancelled";
            default:                       return "pending";
        }
    }

    private string FormatTimeAgo(object val)
    {
        if (val == null || val == DBNull.Value) return "—";
        DateTime dt;
        if (!DateTime.TryParse(val.ToString(), out dt)) return val.ToString();
        TimeSpan diff = DateTime.Now - dt;
        if (diff.TotalMinutes < 1) return "Just now";
        if (diff.TotalMinutes < 60) return string.Format("{0}m ago", (int)diff.TotalMinutes);
        if (diff.TotalHours < 24) return string.Format("{0}h ago", (int)diff.TotalHours);
        if (diff.TotalDays < 7) return string.Format("{0}d ago", (int)diff.TotalDays);
        return dt.ToString("dd MMM yyyy");
    }

    private string FormatDateDisplay(object val)
    {
        if (val == null || val == DBNull.Value) return "—";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("dd MMM yyyy");
        return val.ToString();
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int result;
        return int.TryParse(val.ToString(), out result) ? result : 0;
    }

    private string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DATA ACCESS
    // ═══════════════════════════════════════════════════════════════════
    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }
            }
        }
        return dt;
    }

    private DataTable ExecuteQuery(MySqlConnection conn, string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parms != null)
                foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }
        }
        return dt;
    }
}
