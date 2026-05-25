using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.SessionState;

public class NewScreens_TicketAction : IHttpHandler, IRequiresSessionState
{
    public bool IsReusable { get { return false; } }

    public void ProcessRequest(HttpContext ctx)
    {
        ctx.Response.ContentType = "application/json; charset=utf-8";
        ctx.Response.Cache.SetNoStore();

        if (ctx.Session == null || ctx.Session["username"] == null)
        {
            ctx.Response.Write("{\"ok\":false,\"msg\":\"Unauthorized\"}");
            return;
        }

        string action    = (ctx.Request["action"] ?? "").Trim().ToLower();
        string adminName = ctx.Session["username"].ToString();

        try
        {
            SupportTicketDB.EnsureSchema();
            switch (action)
            {
                case "detail":      HandleDetail(ctx);               break;
                case "set_status":  HandleSetStatus(ctx, adminName);  break;
                case "set_priority":HandleSetPriority(ctx);           break;
                case "assign":      HandleAssign(ctx);                break;
                case "reply":       HandleReply(ctx, adminName);      break;
                case "stats":       HandleStats(ctx);                 break;
                default:
                    ctx.Response.Write("{\"ok\":false,\"msg\":\"Unknown action\"}");
                    break;
            }
        }
        catch (Exception ex)
        {
            ctx.Response.Write("{\"ok\":false,\"msg\":" + JsonStr(ex.Message) + "}");
        }
    }

    // ── detail ────────────────────────────────────────────────────────────────

    private void HandleDetail(HttpContext ctx)
    {
        int id;
        if (!int.TryParse(ctx.Request["id"], out id) || id <= 0)
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Invalid id\"}"); return; }

        var ticket = SupportTicketDB.GetTicket(id);
        if (ticket == null)
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Not found\"}"); return; }

        string status   = ticket["status"].ToString();
        string issue    = ticket["issue_type"].ToString();
        string priority = ticket["priority"].ToString();
        string subject  = ticket["subject"].ToString();
        string assigned = ticket["assigned_to"] != DBNull.Value ? ticket["assigned_to"].ToString() : "";
        string submitter = ticket["submitter_name"].ToString()
                         + " [" + ticket["submitter_regno"].ToString() + "] — "
                         + ticket["submitter_type"].ToString();
        string created  = SupportTicketDB.FormatDateTime(Convert.ToDateTime(ticket["created_at"]));
        string updated  = SupportTicketDB.FormatDateTime(Convert.ToDateTime(ticket["updated_at"]));
        string tktRef   = SupportTicketDB.FormatRef(id);

        string badges = BuildBadgesHtml(status, issue, priority);
        string thread = BuildThreadHtml(ctx, id);

        var sb = new StringBuilder();
        sb.Append("{\"ok\":true");
        sb.Append(",\"ref\":")      .Append(JsonStr(tktRef));
        sb.Append(",\"subject\":").Append(JsonStr(subject));
        sb.Append(",\"status\":") .Append(JsonStr(status));
        sb.Append(",\"priority\":").Append(JsonStr(priority));
        sb.Append(",\"assigned\":").Append(JsonStr(assigned));
        sb.Append(",\"submitter\":").Append(JsonStr(submitter));
        sb.Append(",\"created\":") .Append(JsonStr(created));
        sb.Append(",\"updated\":") .Append(JsonStr(updated));
        sb.Append(",\"badges\":").Append(JsonStr(badges));
        sb.Append(",\"thread\":").Append(JsonStr(thread));
        sb.Append("}");
        ctx.Response.Write(sb.ToString());
    }

    // ── set_status ────────────────────────────────────────────────────────────

    private void HandleSetStatus(HttpContext ctx, string adminName)
    {
        int id; string value;
        if (!ParseIdValue(ctx, out id, out value))
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Invalid params\"}"); return; }

        value = value.ToUpper();
        string[] valid = { "OPEN", "IN_PROGRESS", "AWAITING_REPLY", "RESOLVED", "CLOSED" };
        if (!InArray(value, valid))
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Invalid status\"}"); return; }

        SupportTicketDB.UpdateStatus(id, value, adminName, adminName);
        ctx.Response.Write("{\"ok\":true" + StatsJson() + "}");
    }

    // ── set_priority ──────────────────────────────────────────────────────────

    private void HandleSetPriority(HttpContext ctx)
    {
        int id; string value;
        if (!ParseIdValue(ctx, out id, out value))
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Invalid params\"}"); return; }

        value = value.ToUpper();
        string[] valid = { "LOW", "NORMAL", "HIGH", "URGENT" };
        if (!InArray(value, valid))
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Invalid priority\"}"); return; }

        SupportTicketDB.UpdatePriority(id, value);
        ctx.Response.Write("{\"ok\":true}");
    }

    // ── assign ────────────────────────────────────────────────────────────────

    private void HandleAssign(HttpContext ctx)
    {
        int id; string value;
        if (!ParseIdValue(ctx, out id, out value))
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Invalid params\"}"); return; }

        SupportTicketDB.AssignTicket(id, value);
        ctx.Response.Write("{\"ok\":true}");
    }

    // ── reply ─────────────────────────────────────────────────────────────────

    private void HandleReply(HttpContext ctx, string adminName)
    {
        int id;
        if (!int.TryParse(ctx.Request["id"], out id) || id <= 0)
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Invalid id\"}"); return; }

        string text = (ctx.Request["text"] ?? "").Trim();
        if (text.Length < 2)
        { ctx.Response.Write("{\"ok\":false,\"msg\":\"Reply too short\"}"); return; }

        bool isInternal = ctx.Request["internal"] == "1";

        int msgId = SupportTicketDB.AddMessage(id, adminName, adminName, "ADMIN", text, isInternal);

        if (ctx.Request.Files != null && ctx.Request.Files.Count > 0)
        {
            string uploadFolder = GetUploadFolder(ctx);
            for (int i = 0; i < ctx.Request.Files.Count; i++)
            {
                var file = ctx.Request.Files[i];
                if (file == null || file.ContentLength == 0) continue;
                string origName = Path.GetFileName(file.FileName);
                string ext = Path.GetExtension(origName);
                if (!SupportTicketDB.IsAllowedExtension(ext)) continue;
                if (!SupportTicketDB.IsWithinSizeLimit(file.ContentLength)) continue;
                string storedName = Guid.NewGuid().ToString("N") + ext.ToLower();
                try
                {
                    file.SaveAs(Path.Combine(uploadFolder, storedName));
                    SupportTicketDB.AddAttachment(id, msgId, origName, storedName,
                        file.ContentLength, file.ContentType, adminName);
                }
                catch { }
            }
        }

        string thread = BuildThreadHtml(ctx, id);
        ctx.Response.Write("{\"ok\":true,\"thread\":" + JsonStr(thread) + StatsJson() + "}");
    }

    // ── stats ─────────────────────────────────────────────────────────────────

    private void HandleStats(HttpContext ctx)
    {
        ctx.Response.Write("{\"ok\":true" + StatsJson() + "}");
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private string StatsJson()
    {
        try
        {
            var s = SupportTicketDB.GetAdminStats();
            if (s == null) return "";
            return string.Format(
                ",\"stats\":{{\"total\":{0},\"open\":{1},\"prog\":{2},\"wait\":{3},\"resolved\":{4},\"closed\":{5},\"urgent\":{6}}}",
                S(s["total"]), S(s["cnt_open"]), S(s["cnt_progress"]),
                S(s["cnt_awaiting"]), S(s["cnt_resolved"]), S(s["cnt_closed"]), S(s["cnt_urgent"]));
        }
        catch { return ""; }
    }

    private string BuildBadgesHtml(string status, string issue, string priority)
    {
        var sb = new StringBuilder();
        sb.AppendFormat("<span class='tc-badge' style='background:{0};color:{1}'>{2}</span>",
            SupportTicketDB.GetStatusBg(status),
            SupportTicketDB.GetStatusColor(status),
            SupportTicketDB.GetStatusLabel(status));
        sb.AppendFormat("<span class='tc-badge' style='background:rgba(0,0,0,.06);color:#555'>{0}</span>",
            HttpUtility.HtmlEncode(issue));
        if (priority == "HIGH" || priority == "URGENT")
            sb.AppendFormat("<span class='tc-badge' style='background:rgba(220,53,69,.10);color:{0}'>{1}</span>",
                SupportTicketDB.GetPriorityColor(priority),
                HttpUtility.HtmlEncode(priority));
        return sb.ToString();
    }

    private string BuildThreadHtml(HttpContext ctx, int ticketId)
    {
        var messages    = SupportTicketDB.GetMessages(ticketId, true);
        var attachments = SupportTicketDB.GetTicketAttachments(ticketId);

        var attMap = new Dictionary<int, List<DataRow>>();
        foreach (DataRow att in attachments.Rows)
        {
            if (att["message_id"] == DBNull.Value) continue;
            int mid = Convert.ToInt32(att["message_id"]);
            if (!attMap.ContainsKey(mid)) attMap[mid] = new List<DataRow>();
            attMap[mid].Add(att);
        }

        string portalBase = (System.Configuration.ConfigurationManager.AppSettings["PortalBaseUrl"] ?? "").TrimEnd('/');

        var sb = new StringBuilder();
        foreach (DataRow msg in messages.Rows)
        {
            string role   = msg["sender_role"].ToString();
            string text   = msg["message"].ToString();
            int    msgId  = Convert.ToInt32(msg["message_id"]);
            string sender = msg["sender_name"].ToString();
            bool   intern = Convert.ToInt32(msg["is_internal"]) == 1;
            var    ts     = Convert.ToDateTime(msg["created_at"]);

            if (role == "SYSTEM" && text.StartsWith("STATUS_CHANGE:"))
            {
                string ns = text.Substring("STATUS_CHANGE:".Length);
                sb.Append("<div class='tc-event'>Status &rarr; <strong>")
                  .Append(SupportTicketDB.GetStatusLabel(ns))
                  .Append("</strong> &bull; ")
                  .Append(SupportTicketDB.FormatTimeAgo(ts))
                  .Append("</div>");
                continue;
            }

            bool isSub = (role == "SUBMITTER");
            string msgCls = isSub ? "tc-msg--sub"
                          : intern ? "tc-msg--admin tc-msg--internal"
                          : "tc-msg--admin";

            sb.Append("<div class='tc-msg ").Append(msgCls).Append("'>");
            sb.Append("<div class='tc-bubble'>").Append(HttpUtility.HtmlEncode(text));

            if (attMap.ContainsKey(msgId))
            {
                foreach (DataRow att in attMap[msgId])
                {
                    string orig   = att["original_name"].ToString();
                    string stored = att["stored_name"].ToString();
                    string ext    = Path.GetExtension(stored).ToLower();
                    string url    = string.IsNullOrEmpty(portalBase)
                        ? "/COOPERP/Support/Uploads/" + stored
                        : portalBase + "/COOPERP/Support/Uploads/" + stored;

                    if (SupportTicketDB.IsImageExtension(ext))
                        sb.AppendFormat(
                            "<div><img src='{0}' alt='{1}' class='tc-att-img' onclick=\"openLightbox('{0}')\"/></div>",
                            HttpUtility.HtmlAttributeEncode(url),
                            HttpUtility.HtmlAttributeEncode(orig));
                    else
                        sb.AppendFormat(
                            "<div><a href='{0}' class='tc-att-link' target='_blank'>" +
                            "<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'>" +
                            "<path d='M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48'/></svg>" +
                            " {1}</a></div>",
                            HttpUtility.HtmlAttributeEncode(url),
                            HttpUtility.HtmlEncode(orig));
                }
            }

            sb.Append("</div>"); // bubble
            sb.Append("<div class='tc-msg__meta'>");
            if (intern) sb.Append("<em>[Internal]</em> ");
            sb.Append(HttpUtility.HtmlEncode(sender))
              .Append(" &bull; ")
              .Append(SupportTicketDB.FormatDateTime(ts))
              .Append("</div></div>");
        }
        return sb.ToString();
    }

    private bool ParseIdValue(HttpContext ctx, out int id, out string value)
    {
        value = (ctx.Request["value"] ?? "").Trim();
        return int.TryParse(ctx.Request["id"], out id) && id > 0;
    }

    private static bool InArray(string val, string[] arr)
    {
        foreach (var s in arr) if (s == val) return true;
        return false;
    }

    private static string GetUploadFolder(HttpContext ctx)
    {
        string adminRoot  = ctx.Server.MapPath("~/");
        string sharedRoot = Path.Combine(adminRoot, @"..\..\CampusDynamics_Portal\COOPERP\Support\Uploads\");
        string folder     = Path.GetFullPath(sharedRoot);
        if (!Directory.Exists(folder))
        {
            string local = Path.Combine(adminRoot, @"COOPERP\Support\Uploads\");
            Directory.CreateDirectory(local);
            return local;
        }
        return folder;
    }

    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s
            .Replace("\\", "\\\\")
            .Replace("\"", "\\\"")
            .Replace("\r", "\\r")
            .Replace("\n", "\\n")
            .Replace("\t", "\\t") + "\"";
    }

    private static string S(object val)
    {
        if (val == null || val == DBNull.Value) return "0";
        return val.ToString();
    }
}
