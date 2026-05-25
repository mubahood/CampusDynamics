using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_BursarRequisitions : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string _bursarName = "";

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        _bursarName = (Session["ScreenName"] ?? Session["username"] ?? "Bursar").ToString();

        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (ajax == "action")
        {
            Response.ContentType = "application/json";
            Response.Clear();
            if (!MarksAntiForgeryService.ValidateRequest())
            {
                Response.Write("{\"ok\":false,\"error\":\"Security validation failed.\"}");
                Response.End();
                return;
            }
            string body;
            using (var sr = new StreamReader(Request.InputStream)) body = sr.ReadToEnd();
            HandleAction(body);
            Response.End();
            return;
        }

        if (!IsPostBack) LoadAll();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  LOAD
    // ═══════════════════════════════════════════════════════════════════
    private void LoadAll()
    {
        LoadPending();
        LoadVcPending();
        LoadProcurement();
        LoadHistory();
    }

    private void LoadPending()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT r.ID,r.req_number,r.title,r.req_type,r.priority,r.total_amount,
                     r.requester_name,r.department,r.supervisor_name,r.supervisor_at,
                     GROUP_CONCAT(ri.item_no,'|',ri.description,'|',ri.unit,'|',ri.qty,'|',ri.unit_price,'|',ri.total_price ORDER BY ri.item_no SEPARATOR '~~') AS items_raw
              FROM sys_requisitions r
              LEFT JOIN sys_requisition_items ri ON ri.requisition_id=r.ID
              WHERE r.status='SUPERVISOR_APPROVED' AND r.is_deleted=0
              GROUP BY r.ID ORDER BY r.supervisor_at ASC");

        litCntAwaiting.Text = dt.Rows.Count.ToString();
        litTabPending.Text  = dt.Rows.Count.ToString();

        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            int     id       = SafeInt(r["ID"]);
            string  reqNo    = SafeStr(r["req_number"]);
            string  title    = SafeStr(r["title"]);
            string  reqType  = SafeStr(r["req_type"]);
            string  priority = SafeStr(r["priority"]);
            decimal amount   = SafeDecimal(r["total_amount"]);
            string  requester= SafeStr(r["requester_name"]);
            string  dept     = SafeStr(r["department"]);
            string  supvName = SafeStr(r["supervisor_name"]);
            string  dateStr  = r["supervisor_at"] == DBNull.Value ? "—" : Convert.ToDateTime(r["supervisor_at"]).ToString("dd MMM yyyy");
            string  itemsRaw = SafeStr(r["items_raw"]);
            string  itemsJson= BuildItemsJson(itemsRaw);

            string jsCall = string.Format("openBursarModal({0},{1},{2},{3},{4},{5},{6},{7})",
                id,
                JS(reqNo), JS(requester), JS(dept), JS(supvName),
                (double)amount,
                JS(priority),
                JS(itemsJson));

            sb.AppendFormat(
                "<tr><td class='bq-col-num'>{0}</td>" +
                "<td class='bq-nowrap'><strong>{1}</strong></td>" +
                "<td>{2}<div class='bq-sub'>{3}</div></td>" +
                "<td>{4}<div class='bq-sub'>{5}</div></td>" +
                "<td>{6}</td>" +
                "<td class='bq-col-amt'>{7}</td>" +
                "<td class='bq-nowrap'>{8}</td>" +
                "<td class='bq-nowrap'>{9}</td>" +
                "<td class='bq-col-action'>" +
                  "<a href='RequisitionDetail.aspx?id={10}' class='bq-btn bq-btn--outline bq-btn--sm'>Detail</a> " +
                  "<button class='bq-btn bq-btn--primary bq-btn--sm' onclick=\"{11}\">Decide</button>" +
                "</td></tr>",
                n,
                HttpUtility.HtmlEncode(reqNo),
                HttpUtility.HtmlEncode(requester), HttpUtility.HtmlEncode(dept),
                HttpUtility.HtmlEncode(title.Length > 45 ? title.Substring(0, 45) + "…" : title), HttpUtility.HtmlEncode(reqType),
                GetPriorityHtml(priority),
                string.Format("{0:N0}", amount),
                HttpUtility.HtmlEncode(supvName),
                HttpUtility.HtmlEncode(dateStr),
                id, jsCall);
        }

        litPendingRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='9' class='bq-empty'>No requisitions awaiting Bursar decision.</td></tr>";
    }

    private void LoadVcPending()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT ID,req_number,title,total_amount,requester_name,bursar_at
              FROM sys_requisitions WHERE status='VC_PENDING' AND is_deleted=0 ORDER BY bursar_at DESC");

        litCntVcPending.Text = dt.Rows.Count.ToString();
        litTabVc.Text        = dt.Rows.Count.ToString();

        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            sb.AppendFormat(
                "<tr><td class='bq-col-num'>{0}</td><td><strong>{1}</strong></td><td>{2}</td><td>{3}</td>" +
                "<td class='bq-col-amt'>{4}</td><td class='bq-nowrap'>{5}</td>" +
                "<td class='bq-col-action'><a href='RequisitionDetail.aspx?id={6}' class='bq-btn bq-btn--outline bq-btn--sm'>View</a></td></tr>",
                n, HttpUtility.HtmlEncode(SafeStr(r["req_number"])),
                HttpUtility.HtmlEncode(SafeStr(r["requester_name"])),
                HttpUtility.HtmlEncode(SafeStr(r["title"])),
                string.Format("{0:N0}", SafeDecimal(r["total_amount"])),
                r["bursar_at"] == DBNull.Value ? "—" : Convert.ToDateTime(r["bursar_at"]).ToString("dd MMM yyyy"),
                SafeInt(r["ID"]));
        }
        litVcRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='7' class='bq-empty'>No requisitions awaiting VC approval.</td></tr>";
    }

    private void LoadProcurement()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT ID,req_number,title,total_amount,requester_name,lpo_number,procurement_status
              FROM sys_requisitions WHERE status IN ('PROCUREMENT','PROCUREMENT_COMPLETE') AND is_deleted=0 ORDER BY bursar_at DESC");

        litCntProcurement.Text = dt.Rows.Count.ToString();
        litTabProcurement.Text = dt.Rows.Count.ToString();

        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            string procStatus = SafeStr(r["procurement_status"]);
            string lpo        = SafeStr(r["lpo_number"]);
            sb.AppendFormat(
                "<tr><td class='bq-col-num'>{0}</td><td><strong>{1}</strong></td><td>{2}</td><td>{3}</td>" +
                "<td class='bq-col-amt'>{4}</td><td>{5}</td><td>{6}</td>" +
                "<td class='bq-col-action'><a href='RequisitionDetail.aspx?id={7}' class='bq-btn bq-btn--outline bq-btn--sm'>View</a></td></tr>",
                n, HttpUtility.HtmlEncode(SafeStr(r["req_number"])),
                HttpUtility.HtmlEncode(SafeStr(r["requester_name"])),
                HttpUtility.HtmlEncode(SafeStr(r["title"])),
                string.Format("{0:N0}", SafeDecimal(r["total_amount"])),
                HttpUtility.HtmlEncode(string.IsNullOrEmpty(lpo) ? "—" : lpo),
                string.IsNullOrEmpty(procStatus) ? "—" : HttpUtility.HtmlEncode(procStatus),
                SafeInt(r["ID"]));
        }
        litProcurementRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='8' class='bq-empty'>No requisitions in procurement.</td></tr>";
    }

    private void LoadHistory()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT ID,req_number,title,total_amount,requester_name,bursar_action,bursar_route,bursar_at
              FROM sys_requisitions
              WHERE bursar_action IN ('APPROVED','RETURNED','ESCALATED','PROCUREMENT') AND is_deleted=0
              ORDER BY bursar_at DESC LIMIT 200");

        litTabHistory.Text = dt.Rows.Count.ToString();

        var sb = new StringBuilder();
        int n = 0;
        int approved = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            string bAction = SafeStr(r["bursar_action"]);
            string bRoute  = SafeStr(r["bursar_route"]);
            if (bAction == "APPROVED") approved++;

            string decBadge = bAction == "APPROVED"
                ? "<span class='bq-badge bq-badge--approved'>Approved</span>"
                : bAction == "RETURNED"
                ? "<span class='bq-badge bq-badge--rejected'>Returned</span>"
                : "<span class='bq-badge bq-badge--pending'>" + HttpUtility.HtmlEncode(bAction) + "</span>";

            string routeBadge = bRoute == "VC" ? "<span class='bq-badge bq-badge--vc'>VC</span>"
                : bRoute == "PROCUREMENT" ? "<span class='bq-badge bq-badge--procurement'>Procurement</span>"
                : "<span class='bq-badge bq-badge--approved'>Finance</span>";

            sb.AppendFormat(
                "<tr><td class='bq-col-num'>{0}</td><td><strong>{1}</strong></td><td>{2}</td><td>{3}</td>" +
                "<td class='bq-col-amt'>{4}</td><td>{5}</td><td>{6}</td>" +
                "<td class='bq-nowrap'>{7}</td>" +
                "<td class='bq-col-action'><a href='RequisitionDetail.aspx?id={8}' class='bq-btn bq-btn--outline bq-btn--sm'>View</a></td></tr>",
                n, HttpUtility.HtmlEncode(SafeStr(r["req_number"])),
                HttpUtility.HtmlEncode(SafeStr(r["requester_name"])),
                HttpUtility.HtmlEncode(SafeStr(r["title"])),
                string.Format("{0:N0}", SafeDecimal(r["total_amount"])),
                decBadge, routeBadge,
                r["bursar_at"] == DBNull.Value ? "—" : Convert.ToDateTime(r["bursar_at"]).ToString("dd MMM yyyy"),
                SafeInt(r["ID"]));
        }
        litHistoryRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='9' class='bq-empty'>No history yet.</td></tr>";
        litCntApproved.Text = approved.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AJAX: BURSAR ACTION
    // ═══════════════════════════════════════════════════════════════════
    private void HandleAction(string body)
    {
        try
        {
            var jss     = new JavaScriptSerializer();
            var payload = jss.Deserialize<Dictionary<string, object>>(body);

            int    reqId   = SafeIntD(payload, "req_id");
            string action  = SafeStrD(payload, "action");
            string route   = SafeStrD(payload, "route");
            string remarks = SafeStrD(payload, "remarks").Trim();

            if (reqId <= 0) { Response.Write("{\"ok\":false,\"error\":\"Invalid requisition.\"}"); return; }

            DataTable dt = ExecuteQuery(
                "SELECT status FROM sys_requisitions WHERE ID=@id AND status='SUPERVISOR_APPROVED' AND is_deleted=0 LIMIT 1",
                new MySqlParameter("@id", reqId));
            if (dt.Rows.Count == 0) { Response.Write("{\"ok\":false,\"error\":\"Requisition not found or already actioned.\"}"); return; }

            string newStatus;
            string bursarAction;

            if (action == "return")
            {
                if (string.IsNullOrEmpty(remarks)) { Response.Write("{\"ok\":false,\"error\":\"Remarks required for returning.\"}"); return; }
                newStatus   = "RETURNED";
                bursarAction= "RETURNED";
                route       = "FINANCE";
            }
            else if (action == "approve")
            {
                bursarAction = "APPROVED";
                switch ((route ?? "").ToUpper())
                {
                    case "VC":          newStatus = "VC_PENDING";   break;
                    case "PROCUREMENT": newStatus = "PROCUREMENT";  break;
                    default:            newStatus = "BURSAR_APPROVED"; route = "FINANCE"; break;
                }
            }
            else { Response.Write("{\"ok\":false,\"error\":\"Invalid action.\"}"); return; }

            ExecuteNonQuery(
                @"UPDATE sys_requisitions SET status=@st,bursar_action=@ba,bursar_remarks=@br,
                    bursar_route=@brt,bursar_processed_by=@bp,bursar_at=NOW(),updated_at=NOW()
                  WHERE ID=@id",
                new MySqlParameter("@st",  newStatus),
                new MySqlParameter("@ba",  bursarAction),
                new MySqlParameter("@br",  remarks),
                new MySqlParameter("@brt", route),
                new MySqlParameter("@bp",  _bursarName),
                new MySqlParameter("@id",  reqId));

            LogAudit(reqId, bursarAction, "SUPERVISOR_APPROVED", newStatus, _bursarName, "BURSAR", remarks);
            Response.Write("{\"ok\":true}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════
    private string BuildItemsJson(string raw)
    {
        if (string.IsNullOrEmpty(raw)) return "[]";
        var sb = new StringBuilder("[");
        bool first = true;
        foreach (string part in raw.Split(new[] { "~~" }, StringSplitOptions.RemoveEmptyEntries))
        {
            string[] cols = part.Split('|');
            if (cols.Length < 6) continue;
            string desc  = (cols[1] ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"");
            string unit  = (cols[2] ?? "pcs").Replace("\"", "\\\"");
            decimal qty  = SafeDecimalStr(cols[3]);
            decimal price= SafeDecimalStr(cols[4]);
            decimal tot  = SafeDecimalStr(cols[5]);
            if (!first) sb.Append(",");
            sb.AppendFormat("{{\"desc\":\"{0}\",\"unit\":\"{1}\",\"qty\":{2},\"price\":{3},\"total\":{4}}}",
                desc, unit, qty, price, tot);
            first = false;
        }
        sb.Append("]");
        return sb.ToString();
    }

    private string GetPriorityHtml(string priority)
    {
        string cls = "bq-priority--medium";
        switch ((priority ?? "").ToUpper())
        {
            case "LOW":    cls = "bq-priority--low";    break;
            case "HIGH":   cls = "bq-priority--high";   break;
            case "URGENT": cls = "bq-priority--urgent"; break;
        }
        return string.Format("<span class='bq-priority {0}'><span class='bq-priority__dot'></span>{1}</span>",
            cls, HttpUtility.HtmlEncode(priority ?? "Medium"));
    }

    private void LogAudit(int reqId, string actionCode, string oldStatus, string newStatus, string actorName, string actorRole, string remarks)
    {
        try
        {
            ExecuteNonQuery(
                "INSERT INTO sys_requisition_audit (requisition_id,action_code,old_status,new_status,actor_name,actor_role,remarks,ip_address,created_at) VALUES (@rid,@ac,@os,@ns,@an,@ar,@rm,@ip,NOW())",
                new MySqlParameter("@rid", reqId), new MySqlParameter("@ac",  actionCode),
                new MySqlParameter("@os",  oldStatus), new MySqlParameter("@ns",  newStatus),
                new MySqlParameter("@an",  actorName), new MySqlParameter("@ar",  actorRole),
                new MySqlParameter("@rm",  remarks), new MySqlParameter("@ip",  Request.UserHostAddress ?? ""));
        }
        catch { }
    }

    private static string JS(string s) { return "'" + (s ?? "").Replace("\\", "\\\\").Replace("'", "\\'").Replace("\n", "\\n").Replace("\r", "") + "'"; }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        var dt = new DataTable();
        using (var conn = new MySqlConnection(ConnStr))
        using (var cmd  = new MySqlCommand(sql, conn))
        {
            if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
            conn.Open();
            using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
        }
        return dt;
    }

    private void ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (var conn = new MySqlConnection(ConnStr))
        using (var cmd  = new MySqlCommand(sql, conn))
        {
            if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private int     SafeInt(object v)          { int x; return v == null || v == DBNull.Value ? 0 : int.TryParse(v.ToString(), out x) ? x : 0; }
    private string  SafeStr(object v)          { return v == null || v == DBNull.Value ? "" : v.ToString().Trim(); }
    private decimal SafeDecimal(object v)      { decimal x; return v == null || v == DBNull.Value ? 0 : decimal.TryParse(v.ToString(), out x) ? x : 0; }
    private decimal SafeDecimalStr(string v)   { decimal x; return decimal.TryParse(v ?? "", out x) ? x : 0; }
    private string  SafeStrD(Dictionary<string,object> d, string k) { object v; return d.TryGetValue(k, out v) && v != null ? v.ToString().Trim() : ""; }
    private int     SafeIntD(Dictionary<string,object> d, string k) { object v; int x; return d.TryGetValue(k, out v) && v != null && int.TryParse(v.ToString(), out x) ? x : 0; }
}
