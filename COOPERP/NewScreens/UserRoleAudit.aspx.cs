using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_UserRoleAudit : System.Web.UI.Page
{
    private const int PageSize = 50;

    protected void Page_Load(object sender, EventArgs e)
    {
        RoleAccessService.RequireSlug(this, "system.user_roles.audit");

        if (Request.QueryString["export"] == "csv")
        {
            ExportCsv();
            return;
        }

        if (!IsPostBack)
            LoadAuditLog();
    }

    // ── CSV export ─────────────────────────────────────────────────────────────

    private void ExportCsv()
    {
        string actionType = (Request.QueryString["action_type"] ?? "").Trim();
        string target     = (Request.QueryString["target"]      ?? "").Trim();
        string actor      = (Request.QueryString["actor"]       ?? "").Trim();
        string from       = (Request.QueryString["from"]        ?? "").Trim();
        string to         = (Request.QueryString["to"]          ?? "").Trim();

        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition",
            "attachment; filename=role_audit_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".csv");

        var sb = new StringBuilder();
        sb.AppendLine("Timestamp,Action,Target Type,Target,Detail,Actor,IP Address");

        string where;
        var parms = BuildWhere(actionType, target, actor, from, to, out where);

        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                string sql = "SELECT created_at, action_type, target_type, target_id, detail, actor, ip_address " +
                             "FROM sys_role_audit" + where + " ORDER BY created_at DESC";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    foreach (var p in parms) cmd.Parameters.AddWithValue(p.Key, p.Value);
                    using (var dr = cmd.ExecuteReader())
                    {
                        while (dr.Read())
                        {
                            sb.AppendFormat("\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\"\n",
                                CsvEsc(dr["created_at"].ToString()),
                                CsvEsc(dr["action_type"].ToString()),
                                CsvEsc(dr["target_type"].ToString()),
                                CsvEsc(dr["target_id"].ToString()),
                                CsvEsc(dr["detail"] == DBNull.Value ? "" : dr["detail"].ToString()),
                                CsvEsc(dr["actor"].ToString()),
                                CsvEsc(dr["ip_address"] == DBNull.Value ? "" : dr["ip_address"].ToString()));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            sb.AppendLine("Error: " + CsvEsc(ex.Message));
        }

        Response.Write(sb.ToString());
        Response.End();
    }

    // ── Page load ──────────────────────────────────────────────────────────────

    private void LoadAuditLog()
    {
        string actionType = (Request.QueryString["action_type"] ?? "").Trim();
        string target     = (Request.QueryString["target"]      ?? "").Trim();
        string actor      = (Request.QueryString["actor"]       ?? "").Trim();
        string from       = (Request.QueryString["from"]        ?? "").Trim();
        string to         = (Request.QueryString["to"]          ?? "").Trim();
        int    page       = 1;
        int.TryParse(Request.QueryString["page"] ?? "1", out page);
        if (page < 1) page = 1;

        litActionOpts.Text = BuildActionOptions(actionType);
        litTargetVal.Text  = HttpUtility.HtmlEncode(target);
        litActorVal.Text   = HttpUtility.HtmlEncode(actor);
        litFromVal.Text    = HttpUtility.HtmlEncode(from);
        litToVal.Text      = HttpUtility.HtmlEncode(to);

        var exportSb = new StringBuilder();
        if (!string.IsNullOrEmpty(actionType)) exportSb.Append("&amp;action_type=" + HttpUtility.UrlEncode(actionType));
        if (!string.IsNullOrEmpty(target))     exportSb.Append("&amp;target="      + HttpUtility.UrlEncode(target));
        if (!string.IsNullOrEmpty(actor))      exportSb.Append("&amp;actor="       + HttpUtility.UrlEncode(actor));
        if (!string.IsNullOrEmpty(from))       exportSb.Append("&amp;from="        + HttpUtility.UrlEncode(from));
        if (!string.IsNullOrEmpty(to))         exportSb.Append("&amp;to="          + HttpUtility.UrlEncode(to));
        litExportParams.Text = exportSb.ToString();

        string where;
        var parms = BuildWhere(actionType, target, actor, from, to, out where);

        var rowsSb  = new StringBuilder();
        var pagerSb = new StringBuilder();

        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();

                // ── Stats (always all-time, ignores filter) ──────────────────
                LoadStats(conn);

                // ── Filtered count ───────────────────────────────────────────
                int total = 0;
                using (var cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM sys_role_audit" + where, conn))
                {
                    foreach (var p in parms) cmd.Parameters.AddWithValue(p.Key, p.Value);
                    total = Convert.ToInt32(cmd.ExecuteScalar());
                }

                int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)PageSize));
                if (page > totalPages) page = totalPages;
                int offset = (page - 1) * PageSize;

                // ── Data rows ────────────────────────────────────────────────
                string dataSql = "SELECT created_at, action_type, target_type, target_id, detail, actor, ip_address " +
                                 "FROM sys_role_audit" + where +
                                 " ORDER BY created_at DESC LIMIT @lim OFFSET @off";

                using (var cmd = new MySqlCommand(dataSql, conn))
                {
                    foreach (var p in parms) cmd.Parameters.AddWithValue(p.Key, p.Value);
                    cmd.Parameters.AddWithValue("@lim", PageSize);
                    cmd.Parameters.AddWithValue("@off", offset);

                    using (var dr = cmd.ExecuteReader())
                    {
                        bool any = false;
                        while (dr.Read())
                        {
                            any = true;
                            string at     = dr["action_type"].ToString();
                            string tt     = dr["target_type"].ToString();
                            string tid    = dr["target_id"].ToString();
                            string detail = dr["detail"] == DBNull.Value ? "" : dr["detail"].ToString();
                            string actorV = dr["actor"].ToString();
                            string ipV    = dr["ip_address"] == DBNull.Value ? "" : dr["ip_address"].ToString();
                            DateTime ts   = Convert.ToDateTime(dr["created_at"]);

                            string tsFormatted = ts.ToString("dd MMM yyyy HH:mm");
                            string tsRel       = RelativeTime(ts);

                            bool longDetail = detail.Length > 100;
                            string detailHtml;
                            if (longDetail)
                            {
                                detailHtml =
                                    "<div class=\"detail-text is-truncated\">" + HttpUtility.HtmlEncode(detail) + "</div>" +
                                    "<button type=\"button\" class=\"detail-expand\" onclick=\"toggleDetail(this)\">Show more &#9660;</button>";
                            }
                            else
                            {
                                detailHtml = "<div class=\"detail-text\">" + HttpUtility.HtmlEncode(detail) + "</div>";
                            }

                            rowsSb.AppendFormat(
                                "<tr>" +
                                "<td class=\"ts-cell\">{0}<span class=\"ts-rel\">{1}</span></td>" +
                                "<td>{2}</td>" +
                                "<td>{3}</td>" +
                                "<td style=\"font-size:11px;word-break:break-all;\">{4}</td>" +
                                "<td class=\"detail-cell\">{5}</td>" +
                                "<td class=\"actor-cell\">{6}</td>" +
                                "<td class=\"ip-cell\">{7}</td>" +
                                "</tr>",
                                HttpUtility.HtmlEncode(tsFormatted),
                                HttpUtility.HtmlEncode(tsRel),
                                ActionBadge(at),
                                HttpUtility.HtmlEncode(tt),
                                HttpUtility.HtmlEncode(tid),
                                detailHtml,
                                HttpUtility.HtmlEncode(actorV),
                                string.IsNullOrEmpty(ipV) ? "<span style=\"color:#cbd5e1\">—</span>" : HttpUtility.HtmlEncode(ipV));
                        }

                        if (!any)
                            rowsSb.Append("<tr><td colspan=\"7\" style=\"text-align:center;padding:40px;color:#94a3b8;\">No audit records match the current filter.</td></tr>");
                    }
                }

                // ── Pager ────────────────────────────────────────────────────
                string baseUrl = BuildPageUrl(actionType, target, actor, from, to);
                pagerSb.AppendFormat(
                    "<span class=\"urm-pager__info\">Page {0} of {1} &mdash; {2} record{3}</span>",
                    page, totalPages, total, total == 1 ? "" : "s");

                if (totalPages > 1)
                {
                    if (page > 1)
                        pagerSb.AppendFormat("<a href=\"{0}&amp;page={1}\">&laquo;</a>", baseUrl, page - 1);

                    for (int i = 1; i <= totalPages; i++)
                    {
                        if (totalPages > 12 && i > 3 && i < totalPages - 2 && Math.Abs(i - page) > 2)
                        {
                            if (i == 4 || i == totalPages - 3) pagerSb.Append("<span style=\"padding:0 4px;\">…</span>");
                            continue;
                        }
                        pagerSb.AppendFormat(
                            "<a href=\"{0}&amp;page={1}\"{2}>{1}</a>",
                            baseUrl, i, i == page ? " class=\"active\"" : "");
                    }

                    if (page < totalPages)
                        pagerSb.AppendFormat("<a href=\"{0}&amp;page={1}\">&raquo;</a>", baseUrl, page + 1);
                }
            }
        }
        catch (Exception ex)
        {
            rowsSb.Append("<tr><td colspan=\"7\" style=\"color:#dc2626;padding:20px\">" +
                          HttpUtility.HtmlEncode("Error: " + ex.Message) + "</td></tr>");
        }

        litRows.Text  = rowsSb.ToString();
        litPager.Text = pagerSb.ToString();
    }

    // ── Stats ──────────────────────────────────────────────────────────────────

    private void LoadStats(MySqlConnection conn)
    {
        try
        {
            const string sql = @"
                SELECT
                    COUNT(*) AS total,
                    SUM(CASE WHEN DATE(created_at) = CURDATE() THEN 1 ELSE 0 END) AS today,
                    SUM(CASE WHEN action_type IN ('ASSIGN_ROLE','BATCH_ASSIGN_ROLE') THEN 1 ELSE 0 END) AS assigns,
                    SUM(CASE WHEN action_type IN ('REVOKE_ROLE','BATCH_REVOKE_ALL_ROLES') THEN 1 ELSE 0 END) AS revokes,
                    SUM(CASE WHEN action_type = 'UPDATE_PERMISSIONS' THEN 1 ELSE 0 END) AS perms
                FROM sys_role_audit";

            int total = 0, today = 0, assigns = 0, revokes = 0, perms = 0;
            using (var cmd = new MySqlCommand(sql, conn))
            using (var dr = cmd.ExecuteReader())
            {
                if (dr.Read())
                {
                    total   = Convert.ToInt32(dr["total"]);
                    today   = Convert.ToInt32(dr["today"]);
                    assigns = Convert.ToInt32(dr["assigns"]);
                    revokes = Convert.ToInt32(dr["revokes"]);
                    perms   = Convert.ToInt32(dr["perms"]);
                }
            }

            var sb = new StringBuilder();
            sb.Append("<div class=\"pa-list-stats\">");
            sb.AppendFormat(
                "<span class=\"pa-list-stat ps--all\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Total Events</span></span>",
                total);
            sb.AppendFormat(
                "<span class=\"pa-list-stat ps--today\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Today</span></span>",
                today);
            sb.AppendFormat(
                "<span class=\"pa-list-stat ps--assign\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Assignments</span></span>",
                assigns);
            sb.AppendFormat(
                "<span class=\"pa-list-stat ps--revoke\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Revocations</span></span>",
                revokes);
            sb.AppendFormat(
                "<span class=\"pa-list-stat ps--perm\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Permission Changes</span></span>",
                perms);
            sb.Append("</div>");
            litStats.Text = sb.ToString();
        }
        catch { litStats.Text = ""; }
    }

    // ── Query builder ──────────────────────────────────────────────────────────

    private Dictionary<string, object> BuildWhere(
        string actionType, string target, string actor, string from, string to,
        out string where)
    {
        var clauses = new List<string>();
        var parms   = new Dictionary<string, object>();

        if (!string.IsNullOrEmpty(actionType))
        {
            clauses.Add("action_type = @at");
            parms["@at"] = actionType;
        }
        if (!string.IsNullOrEmpty(target))
        {
            clauses.Add("(target_id LIKE @tgt OR target_type LIKE @tgt)");
            parms["@tgt"] = "%" + target + "%";
        }
        if (!string.IsNullOrEmpty(actor))
        {
            clauses.Add("actor LIKE @act");
            parms["@act"] = "%" + actor + "%";
        }
        if (!string.IsNullOrEmpty(from))
        {
            clauses.Add("created_at >= @frm");
            parms["@frm"] = from + " 00:00:00";
        }
        if (!string.IsNullOrEmpty(to))
        {
            clauses.Add("created_at <= @toD");
            parms["@toD"] = to + " 23:59:59";
        }

        where = clauses.Count > 0 ? " WHERE " + string.Join(" AND ", clauses) : "";
        return parms;
    }

    // ── Render helpers ─────────────────────────────────────────────────────────

    private static string BuildActionOptions(string selected)
    {
        var actions = new[]
        {
            "ASSIGN_ROLE",
            "REVOKE_ROLE",
            "BATCH_ASSIGN_ROLE",
            "BATCH_REVOKE_ALL_ROLES",
            "CREATE_ROLE",
            "UPDATE_ROLE",
            "DELETE_ROLE",
            "CLONE_ROLE",
            "UPDATE_PERMISSIONS",
            "ACCESS_DENIED",
            "ACCESS_DENIED_REPORT"
        };
        var labels = new Dictionary<string, string>
        {
            {"ASSIGN_ROLE",            "Assign Role"},
            {"REVOKE_ROLE",            "Revoke Role"},
            {"BATCH_ASSIGN_ROLE",      "Batch Assign Role"},
            {"BATCH_REVOKE_ALL_ROLES", "Batch Revoke All Roles"},
            {"CREATE_ROLE",            "Create Role"},
            {"UPDATE_ROLE",            "Update Role"},
            {"DELETE_ROLE",            "Delete Role"},
            {"CLONE_ROLE",             "Clone Role"},
            {"UPDATE_PERMISSIONS",     "Update Permissions"},
            {"ACCESS_DENIED",          "Access Denied"},
            {"ACCESS_DENIED_REPORT",   "Access Denied (report-only)"}
        };
        var sb = new StringBuilder();
        foreach (var a in actions)
        {
            string label;
            if (!labels.TryGetValue(a, out label)) label = a.Replace("_", " ");
            sb.AppendFormat("<option value=\"{0}\"{1}>{2}</option>",
                a, a == selected ? " selected" : "", label);
        }
        return sb.ToString();
    }

    private static string ActionBadge(string at)
    {
        string cls;
        switch (at)
        {
            case "ASSIGN_ROLE":            cls = "at-assign"; break;
            case "REVOKE_ROLE":            cls = "at-revoke"; break;
            case "BATCH_ASSIGN_ROLE":      cls = "at-batch";  break;
            case "BATCH_REVOKE_ALL_ROLES": cls = "at-revoke"; break;
            case "CREATE_ROLE":            cls = "at-create"; break;
            case "UPDATE_ROLE":            cls = "at-update"; break;
            case "DELETE_ROLE":            cls = "at-delete"; break;
            case "CLONE_ROLE":             cls = "at-create"; break;
            case "UPDATE_PERMISSIONS":     cls = "at-perms";  break;
            case "ACCESS_DENIED":          cls = "at-delete"; break;
            case "ACCESS_DENIED_REPORT":   cls = "at-update"; break;
            default:                       cls = "at-other";  break;
        }

        string label;
        switch (at)
        {
            case "ASSIGN_ROLE":            label = "Assign Role";     break;
            case "REVOKE_ROLE":            label = "Revoke Role";     break;
            case "BATCH_ASSIGN_ROLE":      label = "Batch Assign";    break;
            case "BATCH_REVOKE_ALL_ROLES": label = "Batch Revoke";    break;
            case "CREATE_ROLE":            label = "Create Role";     break;
            case "UPDATE_ROLE":            label = "Update Role";     break;
            case "DELETE_ROLE":            label = "Delete Role";     break;
            case "CLONE_ROLE":             label = "Clone Role";      break;
            case "UPDATE_PERMISSIONS":     label = "Permissions";     break;
            case "ACCESS_DENIED":          label = "Access Denied";   break;
            case "ACCESS_DENIED_REPORT":   label = "Denied (report)"; break;
            default:                       label = at.Replace("_"," "); break;
        }

        return string.Format("<span class=\"at-badge {0}\">{1}</span>",
            cls, HttpUtility.HtmlEncode(label));
    }

    private static string RelativeTime(DateTime dt)
    {
        var diff = DateTime.Now - dt;
        if (diff.TotalMinutes < 2)   return "just now";
        if (diff.TotalMinutes < 60)  return (int)diff.TotalMinutes + " min ago";
        if (diff.TotalHours < 24)    return (int)diff.TotalHours + " hr ago";
        if (diff.TotalDays < 7)      return (int)diff.TotalDays + " day" + ((int)diff.TotalDays == 1 ? "" : "s") + " ago";
        if (diff.TotalDays < 30)     return (int)(diff.TotalDays / 7) + " week" + ((int)(diff.TotalDays / 7) == 1 ? "" : "s") + " ago";
        if (diff.TotalDays < 365)    return (int)(diff.TotalDays / 30) + " mo ago";
        return (int)(diff.TotalDays / 365) + " yr ago";
    }

    private static string BuildPageUrl(string actionType, string target, string actor, string from, string to)
    {
        var sb = new StringBuilder("UserRoleAudit.aspx?x=1");
        if (!string.IsNullOrEmpty(actionType)) sb.Append("&amp;action_type=" + HttpUtility.UrlEncode(actionType));
        if (!string.IsNullOrEmpty(target))     sb.Append("&amp;target="      + HttpUtility.UrlEncode(target));
        if (!string.IsNullOrEmpty(actor))      sb.Append("&amp;actor="       + HttpUtility.UrlEncode(actor));
        if (!string.IsNullOrEmpty(from))       sb.Append("&amp;from="        + HttpUtility.UrlEncode(from));
        if (!string.IsNullOrEmpty(to))         sb.Append("&amp;to="          + HttpUtility.UrlEncode(to));
        return sb.ToString();
    }

    private static string CsvEsc(string s) { return (s ?? "").Replace("\"", "\"\""); }

    private static string ConnStr()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
        cs = ConfigurationManager.ConnectionStrings["DefaultConnection"];
        if (cs != null) return cs.ConnectionString;
        throw new InvalidOperationException("No valid connection string.");
    }
}
