using System;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

/// <summary>
/// Admin Action Log — a dedicated viewer that traces every admin/manager action across the marks
/// module (reads acad_marks_action_log). Role-gated to management (CanViewAudit). Read-only.
/// AJAX: ?ajax=stats | feed | detail.
/// </summary>
public partial class COOPERP_NewScreens_MarksActionLog : Page
{
    private static string ConnStr { get { return MarksConfiguration.ConnStr; } }

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request["ajax"] ?? "").Trim().ToLowerInvariant();
        if (ajax == "") return; // normal page render

        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        try
        {
            if (!MarksAuthorizationService.CanViewAudit())
            { Response.Write("{\"ok\":false,\"message\":\"Access denied.\"}"); Response.End(); return; }

            switch (ajax)
            {
                case "stats":  WriteStats();  break;
                case "feed":   WriteFeed();   break;
                case "detail": WriteDetail(); break;
                default: Response.Write("{\"ok\":false,\"message\":\"Unknown action\"}"); break;
            }
        }
        catch (Exception ex) { Response.Write("{\"ok\":false,\"message\":" + JS(ex.Message) + "}"); }
        try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
    }

    private void WriteStats()
    {
        int d = ParseInt(Request["days"], 7); if (d <= 0) d = 7;
        var sb = new StringBuilder("{\"ok\":true");
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) total, " +
                " SUM(created_at >= (NOW() - INTERVAL @d DAY)) AS win, " +
                " SUM(DATE(created_at)=CURDATE()) AS today, " +
                " COUNT(DISTINCT username) AS users, " +
                " ROUND(AVG(duration_ms)) AS avgms, " +
                " SUM(outcome IN ('error','auth_fail','validation_fail') AND created_at >= (NOW()-INTERVAL @d DAY)) AS problems " +
                "FROM acad_marks_action_log", conn))
            {
                cmd.Parameters.AddWithValue("@d", d);
                using (var r = cmd.ExecuteReader())
                    if (r.Read())
                    {
                        sb.Append(",\"total\":").Append(L(r["total"]));
                        sb.Append(",\"window\":").Append(L(r["win"]));
                        sb.Append(",\"today\":").Append(L(r["today"]));
                        sb.Append(",\"users\":").Append(L(r["users"]));
                        sb.Append(",\"avgms\":").Append(L(r["avgms"]));
                        sb.Append(",\"problems\":").Append(L(r["problems"]));
                    }
            }
            sb.Append(",\"top_users\":[");
            AppendGroup(conn, sb, "SELECT username k, COUNT(*) n FROM acad_marks_action_log WHERE created_at >= (NOW()-INTERVAL " + d + " DAY) GROUP BY username ORDER BY n DESC LIMIT 6");
            sb.Append("],\"top_pages\":[");
            AppendGroup(conn, sb, "SELECT page k, COUNT(*) n FROM acad_marks_action_log WHERE created_at >= (NOW()-INTERVAL " + d + " DAY) GROUP BY page ORDER BY n DESC LIMIT 8");
            sb.Append("]");
        }
        sb.Append(",\"days\":").Append(d).Append("}");
        Response.Write(sb.ToString());
    }

    private void AppendGroup(MySqlConnection conn, StringBuilder sb, string sql)
    {
        using (var cmd = new MySqlCommand(sql, conn))
        using (var r = cmd.ExecuteReader())
        {
            bool first = true;
            while (r.Read())
            {
                if (!first) sb.Append(","); first = false;
                sb.Append("{\"k\":").Append(JS(r["k"] as string)).Append(",\"n\":").Append(L(r["n"])).Append("}");
            }
        }
    }

    private void WriteFeed()
    {
        int d = ParseInt(Request["days"], 7); if (d <= 0) d = 7;
        int limit = ParseInt(Request["limit"], 100);
        if (limit != 50 && limit != 100 && limit != 200 && limit != 500) limit = 100;
        string page = (Request["page"] ?? "").Trim();
        string user = (Request["user"] ?? "").Trim();
        string action = (Request["action"] ?? "").Trim();
        string outcome = (Request["outcome"] ?? "").Trim().ToLowerInvariant();
        string q = (Request["q"] ?? "").Trim();

        string cond = " WHERE created_at >= (NOW() - INTERVAL @d DAY)";
        if (page != "" && page != "ALL") cond += " AND page=@pg";
        if (user != "") cond += " AND username LIKE @u";
        if (action != "") cond += " AND action=@a";
        if (outcome != "" && outcome != "all") cond += " AND outcome=@o";
        if (q != "") cond += " AND (username LIKE @q OR page LIKE @q OR action LIKE @q OR context_json LIKE @q OR ip_address LIKE @q)";

        var sb = new StringBuilder("{\"ok\":true,\"rows\":[");
        int cnt = 0;
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT id, DATE_FORMAT(created_at,'%d %b %Y %H:%i:%s') ts, username, page, action, outcome, duration_ms, ip_address, context_json, correlation_id " +
                "FROM acad_marks_action_log" + cond + " ORDER BY id DESC LIMIT " + limit, conn))
            {
                cmd.Parameters.AddWithValue("@d", d);
                if (page != "" && page != "ALL") cmd.Parameters.AddWithValue("@pg", page);
                if (user != "") cmd.Parameters.AddWithValue("@u", "%" + user + "%");
                if (action != "") cmd.Parameters.AddWithValue("@a", action);
                if (outcome != "" && outcome != "all") cmd.Parameters.AddWithValue("@o", outcome);
                if (q != "") cmd.Parameters.AddWithValue("@q", "%" + q + "%");
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        if (cnt++ > 0) sb.Append(",");
                        sb.Append("{\"id\":").Append(L(r["id"]));
                        sb.Append(",\"ts\":").Append(JS(r["ts"] as string));
                        sb.Append(",\"user\":").Append(JS(r["username"] as string));
                        sb.Append(",\"page\":").Append(JS(r["page"] as string));
                        sb.Append(",\"action\":").Append(JS(r["action"] as string));
                        sb.Append(",\"outcome\":").Append(JS(r["outcome"] as string));
                        sb.Append(",\"dur\":").Append(L(r["duration_ms"]));
                        sb.Append(",\"ip\":").Append(JS(r["ip_address"] as string));
                        sb.Append(",\"ctx\":").Append(JS(r["context_json"] as string));
                        sb.Append(",\"corr\":").Append(JS(r["correlation_id"] as string)).Append("}");
                    }
                }
            }
            sb.Append("],\"pages\":[");
            using (var cmd = new MySqlCommand("SELECT DISTINCT page FROM acad_marks_action_log WHERE page IS NOT NULL AND page<>'' ORDER BY page LIMIT 80", conn))
            using (var r = cmd.ExecuteReader())
            { bool f = true; while (r.Read()) { if (!f) sb.Append(","); f = false; sb.Append(JS(r["page"] as string)); } }
            sb.Append("],\"actions\":[");
            using (var cmd = new MySqlCommand("SELECT DISTINCT action FROM acad_marks_action_log WHERE action IS NOT NULL AND action<>'' ORDER BY action LIMIT 120", conn))
            using (var r = cmd.ExecuteReader())
            { bool f = true; while (r.Read()) { if (!f) sb.Append(","); f = false; sb.Append(JS(r["action"] as string)); } }
            sb.Append("],\"outcomes\":[");
            using (var cmd = new MySqlCommand("SELECT DISTINCT outcome FROM acad_marks_action_log WHERE outcome IS NOT NULL AND outcome<>'' ORDER BY outcome LIMIT 40", conn))
            using (var r = cmd.ExecuteReader())
            { bool f = true; while (r.Read()) { if (!f) sb.Append(","); f = false; sb.Append(JS(r["outcome"] as string)); } }
            sb.Append("]");
        }
        sb.Append(",\"count\":").Append(cnt).Append("}");
        Response.Write(sb.ToString());
    }

    private void WriteDetail()
    {
        long id = ParseLong(Request["id"], 0);
        var sb = new StringBuilder("{\"ok\":true");
        bool found = false;
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT id, DATE_FORMAT(created_at,'%d %b %Y %H:%i:%s') ts, username, page, action, outcome, duration_ms, ip_address, context_json, correlation_id " +
                "FROM acad_marks_action_log WHERE id=@id LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        found = true;
                        sb.Append(",\"row\":{\"id\":").Append(L(r["id"]));
                        sb.Append(",\"ts\":").Append(JS(r["ts"] as string));
                        sb.Append(",\"user\":").Append(JS(r["username"] as string));
                        sb.Append(",\"page\":").Append(JS(r["page"] as string));
                        sb.Append(",\"action\":").Append(JS(r["action"] as string));
                        sb.Append(",\"outcome\":").Append(JS(r["outcome"] as string));
                        sb.Append(",\"dur\":").Append(L(r["duration_ms"]));
                        sb.Append(",\"ip\":").Append(JS(r["ip_address"] as string));
                        sb.Append(",\"ctx\":").Append(JS(r["context_json"] as string));
                        sb.Append(",\"corr\":").Append(JS(r["correlation_id"] as string)).Append("}");
                    }
                }
            }
        }
        if (!found) { Response.Write("{\"ok\":false,\"message\":\"Not found\"}"); return; }
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    // helpers
    private static string JS(string s) { return HttpUtility.JavaScriptStringEncode(s ?? "", true); }
    private static string L(object o) { return (o == null || o == DBNull.Value) ? "0" : Convert.ToInt64(o).ToString(System.Globalization.CultureInfo.InvariantCulture); }
    private static int ParseInt(string s, int def) { int v; return int.TryParse((s ?? "").Trim(), out v) ? v : def; }
    private static long ParseLong(string s, long def) { long v; return long.TryParse((s ?? "").Trim(), out v) ? v : def; }
}
