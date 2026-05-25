using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_FinanceRequisitions : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string _financeName = "";

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        _financeName = (Session["ScreenName"] ?? Session["username"] ?? "Finance").ToString();

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
        // Statuses that mean "Finance can process"
        string readySql = "status IN ('BURSAR_APPROVED','VC_APPROVED','PROCUREMENT_COMPLETE')";

        // Awaiting payment
        DataTable dtAwaiting = ExecuteQuery(
            @"SELECT r.ID,r.req_number,r.title,r.total_amount,r.requester_name,r.department,
                     r.bursar_route,r.bursar_at,r.vc_at,r.procurement_at,
                     GROUP_CONCAT(ri.item_no,'|',ri.description,'|',ri.unit,'|',ri.qty,'|',ri.unit_price,'|',ri.total_price ORDER BY ri.item_no SEPARATOR '~~') AS items_raw
              FROM sys_requisitions r
              LEFT JOIN sys_requisition_items ri ON ri.requisition_id=r.ID
              WHERE " + readySql + @" AND r.is_deleted=0
              GROUP BY r.ID ORDER BY r.updated_at ASC");

        // Pending payment
        DataTable dtPending = ExecuteQuery(
            @"SELECT ID,req_number,title,total_amount,requester_name,finance_at,finance_remarks
              FROM sys_requisitions WHERE status='PENDING_PAYMENT' AND is_deleted=0 ORDER BY finance_at DESC");

        // Unposted (paid but not yet posted to ledger)
        DataTable dtUnposted = ExecuteQuery(
            @"SELECT r.ID,r.req_number,r.title,r.total_amount,r.requester_name,r.payment_method,r.payment_ref
              FROM sys_requisitions r
              WHERE r.status='PAID_OUT' AND r.ledger_posted=0 AND r.is_deleted=0 ORDER BY r.finance_at ASC");

        // History
        DataTable dtHistory = ExecuteQuery(
            @"SELECT ID,req_number,title,total_amount,requester_name,payment_method,payment_ref,ledger_ref,ledger_posted,finance_at
              FROM sys_requisitions WHERE status='PAID_OUT' AND is_deleted=0 ORDER BY finance_at DESC LIMIT 200");

        litCntAwaiting.Text  = dtAwaiting.Rows.Count.ToString();
        litCntPending.Text   = dtPending.Rows.Count.ToString();
        litCntPaid.Text      = dtHistory.Rows.Count.ToString();
        litCntUnposted.Text  = dtUnposted.Rows.Count.ToString();
        litTabAwaiting.Text  = dtAwaiting.Rows.Count.ToString();
        litTabPending.Text   = dtPending.Rows.Count.ToString();
        litTabUnposted.Text  = dtUnposted.Rows.Count.ToString();
        litTabHistory.Text   = dtHistory.Rows.Count.ToString();

        RenderAwaiting(dtAwaiting);
        RenderPending(dtPending);
        RenderUnposted(dtUnposted);
        RenderHistory(dtHistory);
    }

    private void RenderAwaiting(DataTable dt)
    {
        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            int     id       = SafeInt(r["ID"]);
            string  reqNo    = SafeStr(r["req_number"]);
            string  title    = SafeStr(r["title"]);
            decimal amount   = SafeDecimal(r["total_amount"]);
            string  requester= SafeStr(r["requester_name"]);
            string  dept     = SafeStr(r["department"]);
            string  route    = SafeStr(r["bursar_route"]);
            string  approvedVia = route == "VC" ? "Vice Chancellor" : route == "PROCUREMENT" ? "Bursar + Procurement" : "Bursar";

            // Pick latest approval date
            DateTime approvedAt = DateTime.MinValue;
            foreach (string col in new[] { "vc_at", "procurement_at", "bursar_at" })
            {
                if (r[col] != DBNull.Value) { approvedAt = Convert.ToDateTime(r[col]); break; }
            }
            string dateStr = approvedAt == DateTime.MinValue ? "—" : approvedAt.ToString("dd MMM yyyy");
            string itemsJson = BuildItemsJson(SafeStr(r["items_raw"]));

            string jsCall = string.Format("openPayModal({0},{1},{2},{3},{4},{5},{6})",
                id, JS(reqNo), JS(requester), JS(dept), (double)amount, JS(approvedVia), JS(itemsJson));

            sb.AppendFormat(
                "<tr><td class='fq-col-num'>{0}</td><td class='fq-nowrap'><strong>{1}</strong></td>" +
                "<td>{2}<div class='fq-sub'>{3}</div></td>" +
                "<td>{4}</td><td class='fq-col-amt'>{5}</td>" +
                "<td>{6}</td><td class='fq-nowrap'>{7}</td>" +
                "<td class='fq-col-action'>" +
                  "<a href='RequisitionDetail.aspx?id={8}' class='fq-btn fq-btn--outline fq-btn--sm'>Detail</a> " +
                  "<button class='fq-btn fq-btn--success fq-btn--sm' onclick=\"{9}\">Pay</button>" +
                "</td></tr>",
                n, HttpUtility.HtmlEncode(reqNo),
                HttpUtility.HtmlEncode(requester), HttpUtility.HtmlEncode(dept),
                HttpUtility.HtmlEncode(title.Length > 45 ? title.Substring(0, 45) + "…" : title),
                string.Format("{0:N0}", amount),
                HttpUtility.HtmlEncode(approvedVia),
                HttpUtility.HtmlEncode(dateStr),
                id, jsCall);
        }
        litAwaitingRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='8' class='fq-empty'>No requisitions awaiting payment.</td></tr>";
    }

    private void RenderPending(DataTable dt)
    {
        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            int     id      = SafeInt(r["ID"]);
            string  reqNo   = SafeStr(r["req_number"]);
            string  title   = SafeStr(r["title"]);
            decimal amount  = SafeDecimal(r["total_amount"]);
            string  requester = SafeStr(r["requester_name"]);
            string  dateStr = r["finance_at"] == DBNull.Value ? "—" : Convert.ToDateTime(r["finance_at"]).ToString("dd MMM yyyy");
            string  remarks = SafeStr(r["finance_remarks"]);

            // Fetch items for pay button
            DataTable dtItems = ExecuteQuery(
                "SELECT item_no,description,unit,qty,unit_price,total_price FROM sys_requisition_items WHERE requisition_id=@id ORDER BY item_no",
                new MySqlParameter("@id", id));
            string itemsJson = BuildItemsJsonFromDt(dtItems);

            string jsCall = string.Format("openPayModal({0},{1},{2},'—',{3},'Pending Payment (re-process)',{4})",
                id, JS(reqNo), JS(requester), (double)amount, JS(itemsJson));

            sb.AppendFormat(
                "<tr><td class='fq-col-num'>{0}</td><td><strong>{1}</strong></td><td>{2}</td><td>{3}</td>" +
                "<td class='fq-col-amt'>{4}</td><td class='fq-nowrap'>{5}</td>" +
                "<td style='font-size:10px;color:#888;max-width:150px;'>{6}</td>" +
                "<td class='fq-col-action'>" +
                  "<a href='RequisitionDetail.aspx?id={7}' class='fq-btn fq-btn--outline fq-btn--sm'>View</a> " +
                  "<button class='fq-btn fq-btn--success fq-btn--sm' onclick=\"{8}\">Process</button>" +
                "</td></tr>",
                n, HttpUtility.HtmlEncode(reqNo),
                HttpUtility.HtmlEncode(requester),
                HttpUtility.HtmlEncode(title.Length > 40 ? title.Substring(0, 40) + "…" : title),
                string.Format("{0:N0}", amount),
                HttpUtility.HtmlEncode(dateStr),
                HttpUtility.HtmlEncode(remarks.Length > 60 ? remarks.Substring(0, 60) + "…" : remarks),
                id, jsCall);
        }
        litPendingRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='8' class='fq-empty'>No requisitions with pending payment.</td></tr>";
    }

    private void RenderUnposted(DataTable dt)
    {
        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            int    id     = SafeInt(r["ID"]);
            string reqNo  = SafeStr(r["req_number"]);
            decimal amount= SafeDecimal(r["total_amount"]);
            string method = SafeStr(r["payment_method"]);
            string payRef = SafeStr(r["payment_ref"]);
            sb.AppendFormat(
                "<tr><td class='fq-col-num'>{0}</td><td><strong>{1}</strong></td><td>{2}</td><td>{3}</td>" +
                "<td class='fq-col-amt'>{4}</td><td>{5}</td><td>{6}</td>" +
                "<td class='fq-col-action'><button class='fq-btn fq-btn--success fq-btn--sm' onclick='postLedger({7})'>Post GL</button></td></tr>",
                n, HttpUtility.HtmlEncode(reqNo),
                HttpUtility.HtmlEncode(SafeStr(r["requester_name"])),
                HttpUtility.HtmlEncode(SafeStr(r["title"])),
                string.Format("{0:N0}", amount),
                HttpUtility.HtmlEncode(method), HttpUtility.HtmlEncode(payRef),
                id);
        }
        litUnpostedRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='8' class='fq-empty'>All paid requisitions are posted to ledger.</td></tr>";
    }

    private void RenderHistory(DataTable dt)
    {
        var sb = new StringBuilder();
        int n = 0;
        foreach (DataRow r in dt.Rows)
        {
            n++;
            string posted = SafeInt(r["ledger_posted"]) == 1
                ? "<span class='fq-badge fq-badge--posted'>Posted</span>"
                : "<span class='fq-badge fq-badge--unposted'>Unposted</span>";
            string lref = SafeStr(r["ledger_ref"]);
            sb.AppendFormat(
                "<tr><td class='fq-col-num'>{0}</td><td><strong>{1}</strong></td><td>{2}</td><td>{3}</td>" +
                "<td class='fq-col-amt'>{4}</td><td>{5}</td><td>{6}</td><td>{7}</td>" +
                "<td class='fq-nowrap'>{8}</td>" +
                "<td class='fq-col-action'><a href='RequisitionDetail.aspx?id={9}' class='fq-btn fq-btn--outline fq-btn--sm'>View</a></td></tr>",
                n, HttpUtility.HtmlEncode(SafeStr(r["req_number"])),
                HttpUtility.HtmlEncode(SafeStr(r["requester_name"])),
                HttpUtility.HtmlEncode(SafeStr(r["title"])),
                string.Format("{0:N0}", SafeDecimal(r["total_amount"])),
                HttpUtility.HtmlEncode(SafeStr(r["payment_method"])),
                HttpUtility.HtmlEncode(SafeStr(r["payment_ref"])),
                posted,
                r["finance_at"] == DBNull.Value ? "—" : Convert.ToDateTime(r["finance_at"]).ToString("dd MMM yyyy"),
                SafeInt(r["ID"]));
        }
        litHistoryRows.Text = sb.Length > 0 ? sb.ToString() : "<tr><td colspan='10' class='fq-empty'>No paid requisitions yet.</td></tr>";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AJAX: FINANCE ACTION
    // ═══════════════════════════════════════════════════════════════════
    private void HandleAction(string body)
    {
        try
        {
            var jss     = new JavaScriptSerializer();
            var payload = jss.Deserialize<Dictionary<string, object>>(body);

            int    reqId  = SafeIntD(payload, "req_id");
            string action = SafeStrD(payload, "action");

            if (reqId <= 0) { Response.Write("{\"ok\":false,\"error\":\"Invalid requisition.\"}"); return; }

            if (action == "post_ledger")
            {
                string lref = SafeStrD(payload, "ledger_ref");
                if (string.IsNullOrEmpty(lref)) lref = "GL-" + DateTime.Now.ToString("yyyyMMddHHmm") + "-" + reqId;
                ExecuteNonQuery(
                    "UPDATE sys_requisitions SET ledger_posted=1,ledger_ref=@lr,ledger_posted_at=NOW(),updated_at=NOW() WHERE ID=@id AND status='PAID_OUT'",
                    new MySqlParameter("@lr", lref), new MySqlParameter("@id", reqId));
                LogAudit(reqId, "LEDGER_POSTED", "PAID_OUT", "PAID_OUT", _financeName, "FINANCE", "Posted to General Ledger. Ref: " + lref);
                Response.Write("{\"ok\":true}");
                return;
            }

            // Verify the requisition is in a processable state
            DataTable dt = ExecuteQuery(
                "SELECT status FROM sys_requisitions WHERE ID=@id AND status IN ('BURSAR_APPROVED','VC_APPROVED','PROCUREMENT_COMPLETE','PENDING_PAYMENT') AND is_deleted=0 LIMIT 1",
                new MySqlParameter("@id", reqId));
            if (dt.Rows.Count == 0) { Response.Write("{\"ok\":false,\"error\":\"Requisition not found or not ready for finance processing.\"}"); return; }

            string oldStatus = SafeStr(dt.Rows[0]["status"]);
            string method    = SafeStrD(payload, "method");
            string payRef    = SafeStrD(payload, "ref");
            string payDate   = SafeStrD(payload, "date");
            string ledgerRef = SafeStrD(payload, "ledger_ref");
            string remarks   = SafeStrD(payload, "remarks");

            if (string.IsNullOrEmpty(method)) method = "CASH";
            DateTime payDateDt;
            if (!DateTime.TryParse(payDate, out payDateDt)) payDateDt = DateTime.Now.Date;

            string newStatus;
            string finAction;

            if (action == "paid")
            {
                newStatus = "PAID_OUT";
                finAction = "PAID";
                if (string.IsNullOrEmpty(ledgerRef)) ledgerRef = "GL-" + DateTime.Now.ToString("yyyyMMdd") + "-" + reqId;

                ExecuteNonQuery(
                    @"UPDATE sys_requisitions SET status=@st,finance_action=@fa,finance_remarks=@fr,
                        finance_processed_by=@fp,finance_at=NOW(),payment_method=@pm,payment_ref=@pr,
                        payment_date=@pd,ledger_ref=@lr,ledger_posted=1,ledger_posted_at=NOW(),updated_at=NOW()
                      WHERE ID=@id",
                    new MySqlParameter("@st",  newStatus),
                    new MySqlParameter("@fa",  finAction),
                    new MySqlParameter("@fr",  remarks),
                    new MySqlParameter("@fp",  _financeName),
                    new MySqlParameter("@pm",  method),
                    new MySqlParameter("@pr",  payRef),
                    new MySqlParameter("@pd",  payDateDt.ToString("yyyy-MM-dd")),
                    new MySqlParameter("@lr",  ledgerRef),
                    new MySqlParameter("@id",  reqId));

                LogAudit(reqId, "PAID_OUT", oldStatus, "PAID_OUT", _financeName, "FINANCE",
                    string.Format("Paid via {0}. Ref: {1}. GL: {2}. {3}", method, payRef, ledgerRef, remarks));
            }
            else if (action == "pending")
            {
                newStatus = "PENDING_PAYMENT";
                finAction = "PENDING_PAYMENT";

                ExecuteNonQuery(
                    @"UPDATE sys_requisitions SET status=@st,finance_action=@fa,finance_remarks=@fr,
                        finance_processed_by=@fp,finance_at=NOW(),payment_method=@pm,payment_ref=@pr,updated_at=NOW()
                      WHERE ID=@id",
                    new MySqlParameter("@st", newStatus),
                    new MySqlParameter("@fa", finAction),
                    new MySqlParameter("@fr", remarks),
                    new MySqlParameter("@fp", _financeName),
                    new MySqlParameter("@pm", method),
                    new MySqlParameter("@pr", payRef),
                    new MySqlParameter("@id", reqId));

                LogAudit(reqId, "PENDING_PAYMENT", oldStatus, "PENDING_PAYMENT", _financeName, "FINANCE",
                    "Marked as pending payment. " + remarks);
            }
            else { Response.Write("{\"ok\":false,\"error\":\"Invalid action.\"}"); return; }

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
            sb.AppendFormat("{{\"desc\":\"{0}\",\"unit\":\"{1}\",\"qty\":{2},\"price\":{3},\"total\":{4}}}", desc, unit, qty, price, tot);
            first = false;
        }
        sb.Append("]");
        return sb.ToString();
    }

    private string BuildItemsJsonFromDt(DataTable dt)
    {
        var sb = new StringBuilder("[");
        bool first = true;
        foreach (DataRow r in dt.Rows)
        {
            string desc  = (SafeStr(r["description"])).Replace("\\", "\\\\").Replace("\"", "\\\"");
            string unit  = (SafeStr(r["unit"])).Replace("\"", "\\\"");
            decimal qty  = SafeDecimal(r["qty"]);
            decimal price= SafeDecimal(r["unit_price"]);
            decimal tot  = SafeDecimal(r["total_price"]);
            if (!first) sb.Append(",");
            sb.AppendFormat("{{\"desc\":\"{0}\",\"unit\":\"{1}\",\"qty\":{2},\"price\":{3},\"total\":{4}}}", desc, unit, qty, price, tot);
            first = false;
        }
        sb.Append("]");
        return sb.ToString();
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
