using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_RequisitionDetail : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        int reqId = SafeInt(Request.QueryString["id"]);
        if (reqId <= 0) { Response.Redirect("RequisitionsController.aspx"); return; }
        if (!IsPostBack) LoadDetail(reqId);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  LOAD
    // ═══════════════════════════════════════════════════════════════════
    private void LoadDetail(int reqId)
    {
        DataTable dt = ExecuteQuery(
            @"SELECT r.* FROM sys_requisitions r WHERE r.ID=@id AND r.is_deleted=0 LIMIT 1",
            new MySqlParameter("@id", reqId));

        if (dt.Rows.Count == 0) { Response.Redirect("RequisitionsController.aspx"); return; }
        DataRow r = dt.Rows[0];

        string status   = SafeStr(r["status"]);
        string reqNumber= SafeStr(r["req_number"]);
        string title    = SafeStr(r["title"]);
        string desc     = SafeStr(r["description"]);
        string reqType  = SafeStr(r["req_type"]);
        string priority = SafeStr(r["priority"]);
        decimal total   = SafeDecimal(r["total_amount"]);

        litReqNumber.Text    = HttpUtility.HtmlEncode(reqNumber);
        litTitle.Text        = HttpUtility.HtmlEncode(title);
        litStatusBadge.Text  = GetStatusBadge(status);
        litPriorityHtml.Text = GetPriorityHtml(priority);
        litReqType.Text      = HttpUtility.HtmlEncode(reqType);
        litSubmittedAt.Text  = r["submitted_at"] == DBNull.Value ? "Not yet" : Convert.ToDateTime(r["submitted_at"]).ToString("dd MMM yyyy HH:mm");
        litDescription.Text  = HttpUtility.HtmlEncode(desc).Replace("\n", "<br/>");
        litProgressBar.Text  = BuildProgressBar(status);

        // Requester meta
        litRequesterMeta.Text = BuildMetaGrid(new[] {
            new[]{"Requester",     SafeStr(r["requester_name"])},
            new[]{"Department",    SafeStr(r["department"])},
            new[]{"Section",       SafeStr(r["section"])},
            new[]{"Email",         SafeStr(r["requester_email"])},
            new[]{"Financial Year",SafeStr(r["financial_year"])},
            new[]{"Period",        SafeStr(r["period_label"])}
        });

        // Items
        DataTable dtItems = ExecuteQuery(
            "SELECT item_no,description,unit,qty,unit_price,total_price FROM sys_requisition_items WHERE requisition_id=@id ORDER BY item_no",
            new MySqlParameter("@id", reqId));

        litItemCount.Text = dtItems.Rows.Count.ToString();
        litGrandTotal.Text = string.Format("{0:N0}", total);

        var sbItems = new StringBuilder();
        foreach (DataRow ir in dtItems.Rows)
        {
            sbItems.AppendFormat(
                "<tr><td class='rd-col-no'>{0}</td><td>{1}</td><td class='rd-col-unit'>{2}</td>" +
                "<td class='rd-col-qty'>{3}</td><td class='rd-col-price'>{4}</td><td class='rd-col-total'>{5}</td></tr>",
                SafeInt(ir["item_no"]),
                HttpUtility.HtmlEncode(SafeStr(ir["description"])),
                HttpUtility.HtmlEncode(SafeStr(ir["unit"])),
                string.Format("{0:N2}", SafeDecimal(ir["qty"])),
                string.Format("{0:N0}", SafeDecimal(ir["unit_price"])),
                string.Format("{0:N0}", SafeDecimal(ir["total_price"])));
        }
        if (sbItems.Length == 0) sbItems.Append("<tr><td colspan='6' style='text-align:center;color:#999;padding:20px;'>No items.</td></tr>");
        litItemRows.Text = sbItems.ToString();

        // Approval chain
        litApprovalChain.Text = BuildApprovalChain(r, status);

        // Finance section
        if (status == "PAID_OUT" || status == "PENDING_PAYMENT")
            litFinanceSection.Text = BuildFinanceSection(r);

        // Audit timeline
        DataTable dtAudit = ExecuteQuery(
            "SELECT action_code,old_status,new_status,actor_name,actor_role,remarks,created_at FROM sys_requisition_audit WHERE requisition_id=@id ORDER BY created_at ASC",
            new MySqlParameter("@id", reqId));
        litTimeline.Text = BuildTimeline(dtAudit);

        // Back link
        string referer = Request.QueryString["from"] ?? "";
        if (referer == "bursar") litBackLink.Text = "<a href='BursarRequisitions.aspx' class='rd-back'>← Back to Bursar Queue</a>";
        else if (referer == "finance") litBackLink.Text = "<a href='FinanceRequisitions.aspx' class='rd-back'>← Back to Finance Queue</a>";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  BUILD PROGRESS BAR
    // ═══════════════════════════════════════════════════════════════════
    private string BuildProgressBar(string status)
    {
        var stages = new[] {
            new { label = "1. Submitted",  codes = new[] { "DRAFT","SUBMITTED" } },
            new { label = "2. Supervisor", codes = new[] { "SUPERVISOR_APPROVED","SUPERVISOR_REJECTED" } },
            new { label = "3. Bursar",     codes = new[] { "BURSAR_REVIEW","BURSAR_APPROVED","VC_PENDING","VC_APPROVED","VC_REJECTED","PROCUREMENT","PROCUREMENT_COMPLETE","RETURNED" } },
            new { label = "4. Finance",    codes = new[] { "FINANCE_REVIEW","PENDING_PAYMENT" } },
            new { label = "5. Closed",     codes = new[] { "PAID_OUT","CANCELLED" } }
        };

        int currentIdx = 0;
        for (int i = 0; i < stages.Length; i++)
        {
            foreach (string c in stages[i].codes)
                if (c == status) { currentIdx = i; goto found; }
        }
        found:

        var sb = new StringBuilder();
        for (int i = 0; i < stages.Length; i++)
        {
            string cls, dot;
            if (i < currentIdx) { cls = "done"; dot = "✓"; }
            else if (i == currentIdx)
            {
                bool isRej = status.Contains("REJECTED") || status == "RETURNED" || status == "CANCELLED";
                cls = isRej ? "rejected" : "current";
                dot = isRej ? "✗" : (i + 1).ToString();
            }
            else { cls = ""; dot = (i + 1).ToString(); }
            sb.AppendFormat("<div class='rd-stage {0}'><div class='rd-dot'>{1}</div><div class='rd-stage__label'>{2}</div></div>",
                cls, dot, HttpUtility.HtmlEncode(stages[i].label));
        }
        return sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  BUILD APPROVAL CHAIN
    // ═══════════════════════════════════════════════════════════════════
    private string BuildApprovalChain(DataRow r, string status)
    {
        var sb = new StringBuilder();

        // Stage 1: Supervisor
        string supvAction  = SafeStr(r["supervisor_action"]);
        string supvName    = SafeStr(r["supervisor_name"]);
        string supvRemarks = SafeStr(r["supervisor_remarks"]);
        string supvAt      = r["supervisor_at"] == DBNull.Value ? "" : Convert.ToDateTime(r["supervisor_at"]).ToString("dd MMM yyyy HH:mm");
        string supvCls = supvAction == "APPROVED" ? "rd-approval--done" : supvAction == "REJECTED" || supvAction == "RETURNED" ? "rd-approval--rejected" : "";
        string supvBadge = supvAction == "APPROVED" ? "<span class='rd-badge rd-badge--green'>Approved</span>"
            : supvAction == "REJECTED" ? "<span class='rd-badge rd-badge--red'>Rejected</span>"
            : supvAction == "RETURNED" ? "<span class='rd-badge rd-badge--returned'>Returned</span>"
            : "<span class='rd-badge rd-badge--amber'>Pending</span>";
        sb.AppendFormat(
            "<div class='rd-approval {0}'>" +
            "<div class='rd-approval__head'><span class='rd-approval__stage'>Stage 2 — Supervisor Review</span>{1}<span style='font-size:10px;color:#888;'>{2}</span></div>" +
            "<div class='rd-approval__body'>Supervisor: <strong>{3}</strong>{4}</div></div>",
            supvCls, supvBadge, HttpUtility.HtmlEncode(supvAt),
            HttpUtility.HtmlEncode(string.IsNullOrEmpty(supvName) ? "Not assigned" : supvName),
            string.IsNullOrEmpty(supvRemarks) ? "" : "<br/><em style='color:#888;font-size:11px;'>\"" + HttpUtility.HtmlEncode(supvRemarks) + "\"</em>");

        // Stage 2: Bursar
        string bAction  = SafeStr(r["bursar_action"]);
        string bName    = SafeStr(r["bursar_processed_by"]);
        string bRemarks = SafeStr(r["bursar_remarks"]);
        string bRoute   = SafeStr(r["bursar_route"]);
        string bAt      = r["bursar_at"] == DBNull.Value ? "" : Convert.ToDateTime(r["bursar_at"]).ToString("dd MMM yyyy HH:mm");
        string bCls = bAction == "APPROVED" ? "rd-approval--done" : bAction == "RETURNED" ? "rd-approval--rejected" : "";
        string bBadge = bAction == "APPROVED"
            ? (bRoute == "VC" ? "<span class='rd-badge rd-badge--vc'>Escalated to VC</span>"
               : bRoute == "PROCUREMENT" ? "<span class='rd-badge rd-badge--procurement'>Sent to Procurement</span>"
               : "<span class='rd-badge rd-badge--green'>Approved → Finance</span>")
            : bAction == "RETURNED" ? "<span class='rd-badge rd-badge--returned'>Returned</span>"
            : "<span class='rd-badge rd-badge--amber'>Pending</span>";
        sb.AppendFormat(
            "<div class='rd-approval {0}'>" +
            "<div class='rd-approval__head'><span class='rd-approval__stage'>Stage 3 — Bursar Decision</span>{1}<span style='font-size:10px;color:#888;'>{2}</span></div>" +
            "<div class='rd-approval__body'>Processed by: <strong>{3}</strong>{4}</div></div>",
            bCls, bBadge, HttpUtility.HtmlEncode(bAt),
            HttpUtility.HtmlEncode(string.IsNullOrEmpty(bName) ? "Pending" : bName),
            string.IsNullOrEmpty(bRemarks) ? "" : "<br/><em style='color:#888;font-size:11px;'>\"" + HttpUtility.HtmlEncode(bRemarks) + "\"</em>");

        // VC stage (conditional)
        string vcAction  = SafeStr(r["vc_action"]);
        string vcName    = SafeStr(r["vc_processed_by"]);
        string vcRemarks = SafeStr(r["vc_remarks"]);
        string vcAt      = r["vc_at"] == DBNull.Value ? "" : Convert.ToDateTime(r["vc_at"]).ToString("dd MMM yyyy HH:mm");
        if (bRoute == "VC" || !string.IsNullOrEmpty(vcName) || status == "VC_PENDING" || status == "VC_APPROVED" || status == "VC_REJECTED")
        {
            string vcBadge = vcAction == "APPROVED" ? "<span class='rd-badge rd-badge--green'>VC Approved</span>"
                : vcAction == "REJECTED" ? "<span class='rd-badge rd-badge--red'>VC Rejected</span>"
                : "<span class='rd-badge rd-badge--vc'>Awaiting VC</span>";
            string vcCls = vcAction == "APPROVED" ? "rd-approval--done" : vcAction == "REJECTED" ? "rd-approval--rejected" : "rd-approval--current";
            sb.AppendFormat(
                "<div class='rd-approval {0}'>" +
                "<div class='rd-approval__head'><span class='rd-approval__stage'>Stage 3b — Vice Chancellor Approval</span>{1}<span style='font-size:10px;color:#888;'>{2}</span></div>" +
                "<div class='rd-approval__body'>VC decision by: <strong>{3}</strong>{4}</div></div>",
                vcCls, vcBadge, HttpUtility.HtmlEncode(vcAt),
                HttpUtility.HtmlEncode(string.IsNullOrEmpty(vcName) ? "Pending" : vcName),
                string.IsNullOrEmpty(vcRemarks) ? "" : "<br/><em style='color:#888;font-size:11px;'>\"" + HttpUtility.HtmlEncode(vcRemarks) + "\"</em>");
        }

        // Procurement stage (conditional)
        string procStatus  = SafeStr(r["procurement_status"]);
        string procName    = SafeStr(r["procurement_processed_by"]);
        string lpo         = SafeStr(r["lpo_number"]);
        string procAt      = r["procurement_at"] == DBNull.Value ? "" : Convert.ToDateTime(r["procurement_at"]).ToString("dd MMM yyyy HH:mm");
        if (bRoute == "PROCUREMENT" || !string.IsNullOrEmpty(procName))
        {
            string procBadge = string.IsNullOrEmpty(procStatus) ? "<span class='rd-badge rd-badge--procurement'>In Procurement</span>"
                : procStatus == "COMPLETE" ? "<span class='rd-badge rd-badge--green'>Procurement Complete</span>"
                : "<span class='rd-badge rd-badge--amber'>" + HttpUtility.HtmlEncode(procStatus) + "</span>";
            sb.AppendFormat(
                "<div class='rd-approval {0}'>" +
                "<div class='rd-approval__head'><span class='rd-approval__stage'>Stage 3c — Procurement</span>{1}<span style='font-size:10px;color:#888;'>{2}</span></div>" +
                "<div class='rd-approval__body'>Handler: <strong>{3}</strong> &nbsp;|&nbsp; LPO: <strong>{4}</strong></div></div>",
                string.IsNullOrEmpty(procName) ? "rd-approval--current" : "rd-approval--done",
                procBadge, HttpUtility.HtmlEncode(procAt),
                HttpUtility.HtmlEncode(string.IsNullOrEmpty(procName) ? "Pending" : procName),
                HttpUtility.HtmlEncode(string.IsNullOrEmpty(lpo) ? "—" : lpo));
        }

        // Finance stage
        string fAction  = SafeStr(r["finance_action"]);
        string fName    = SafeStr(r["finance_processed_by"]);
        string fRemarks = SafeStr(r["finance_remarks"]);
        string fAt      = r["finance_at"] == DBNull.Value ? "" : Convert.ToDateTime(r["finance_at"]).ToString("dd MMM yyyy HH:mm");
        string fCls = fAction == "PAID" ? "rd-approval--done" : "";
        string fBadge = fAction == "PAID" ? "<span class='rd-badge rd-badge--paid'>Paid Out</span>"
            : fAction == "PENDING_PAYMENT" ? "<span class='rd-badge rd-badge--pending-pay'>Pending Payment</span>"
            : "<span class='rd-badge rd-badge--amber'>Awaiting Finance</span>";
        sb.AppendFormat(
            "<div class='rd-approval {0}'>" +
            "<div class='rd-approval__head'><span class='rd-approval__stage'>Stage 4 — Finance Processing</span>{1}<span style='font-size:10px;color:#888;'>{2}</span></div>" +
            "<div class='rd-approval__body'>Finance officer: <strong>{3}</strong>{4}</div></div>",
            fCls, fBadge, HttpUtility.HtmlEncode(fAt),
            HttpUtility.HtmlEncode(string.IsNullOrEmpty(fName) ? "Pending" : fName),
            string.IsNullOrEmpty(fRemarks) ? "" : "<br/><em style='color:#888;font-size:11px;'>\"" + HttpUtility.HtmlEncode(fRemarks) + "\"</em>");

        return sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  FINANCE SECTION
    // ═══════════════════════════════════════════════════════════════════
    private string BuildFinanceSection(DataRow r)
    {
        string method   = SafeStr(r["payment_method"]);
        string payRef   = SafeStr(r["payment_ref"]);
        string ledgerRef= SafeStr(r["ledger_ref"]);
        string payDate  = r["payment_date"] == DBNull.Value ? "—" : Convert.ToDateTime(r["payment_date"]).ToString("dd MMM yyyy");
        string posted   = SafeInt(r["ledger_posted"]) == 1 ? "<span class='rd-badge rd-badge--green'>Posted</span>" : "<span class='rd-badge rd-badge--amber'>Not Posted</span>";

        return string.Format(
            "<div class='rd-section'>" +
            "<div class='rd-section__head'><div class='rd-section__title'>💰 Payment Details</div></div>" +
            "<div class='rd-section__body'>" +
            "<div style='display:grid;grid-template-columns:repeat(3,1fr);gap:8px;'>" +
            "<div style='background:#e8f5e9;border:1px solid #a5d6a7;padding:10px 12px;'><div style='font-size:9px;color:#388e3c;text-transform:uppercase;letter-spacing:.4px;'>Method</div><div style='font-size:13px;font-weight:700;color:#1b5e20;'>{0}</div></div>" +
            "<div style='background:#e8f5e9;border:1px solid #a5d6a7;padding:10px 12px;'><div style='font-size:9px;color:#388e3c;text-transform:uppercase;letter-spacing:.4px;'>Reference</div><div style='font-size:13px;font-weight:700;color:#1b5e20;'>{1}</div></div>" +
            "<div style='background:#e8f5e9;border:1px solid #a5d6a7;padding:10px 12px;'><div style='font-size:9px;color:#388e3c;text-transform:uppercase;letter-spacing:.4px;'>Payment Date</div><div style='font-size:13px;font-weight:700;color:#1b5e20;'>{2}</div></div>" +
            "<div style='background:#e8f5e9;border:1px solid #a5d6a7;padding:10px 12px;'><div style='font-size:9px;color:#388e3c;text-transform:uppercase;letter-spacing:.4px;'>GL Reference</div><div style='font-size:13px;font-weight:700;color:#1b5e20;'>{3}</div></div>" +
            "<div style='background:#e8f5e9;border:1px solid #a5d6a7;padding:10px 12px;'><div style='font-size:9px;color:#388e3c;text-transform:uppercase;letter-spacing:.4px;'>Ledger Status</div><div style='font-size:13px;font-weight:700;'>{4}</div></div>" +
            "</div></div></div>",
            HttpUtility.HtmlEncode(string.IsNullOrEmpty(method) ? "—" : method),
            HttpUtility.HtmlEncode(string.IsNullOrEmpty(payRef) ? "—" : payRef),
            HttpUtility.HtmlEncode(payDate),
            HttpUtility.HtmlEncode(string.IsNullOrEmpty(ledgerRef) ? "—" : ledgerRef),
            posted);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  BUILD TIMELINE
    // ═══════════════════════════════════════════════════════════════════
    private string BuildTimeline(DataTable dt)
    {
        if (dt.Rows.Count == 0)
            return "<li style='color:#999;font-size:12px;padding-left:18px;margin-left:14px;border-left:2px solid #e0e5ed;'>No activity recorded yet.</li>";

        var sb = new StringBuilder();
        foreach (DataRow r in dt.Rows)
        {
            string actionCode = SafeStr(r["action_code"]);
            string actorName  = SafeStr(r["actor_name"]);
            string actorRole  = SafeStr(r["actor_role"]);
            string remarks    = SafeStr(r["remarks"]);
            string timeStr    = r["created_at"] == DBNull.Value ? "—" : Convert.ToDateTime(r["created_at"]).ToString("dd MMM yyyy, HH:mm");

            bool isRej = actionCode.Contains("REJECTED") || actionCode == "RETURNED";
            string liCls = isRej ? "is-rejected" : "";

            sb.AppendFormat(
                "<li class='{0}'>" +
                "<div class='rd-tl-time'>{1}</div>" +
                "<div><div class='rd-tl-actor'>{2} <span style='font-size:10px;color:#999;font-weight:400;'>({3})</span></div>" +
                "<div class='rd-tl-action'>{4}</div>" +
                "{5}</div></li>",
                liCls,
                HttpUtility.HtmlEncode(timeStr),
                HttpUtility.HtmlEncode(actorName),
                HttpUtility.HtmlEncode(actorRole),
                HttpUtility.HtmlEncode(FriendlyAction(actionCode)),
                string.IsNullOrEmpty(remarks) ? "" :
                    "<div class='rd-tl-remarks'>\"" + HttpUtility.HtmlEncode(remarks.Length > 200 ? remarks.Substring(0, 200) + "…" : remarks) + "\"</div>");
        }
        return sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════
    private string FriendlyAction(string code)
    {
        switch (code)
        {
            case "CREATED":              return "Requisition created";
            case "SUBMITTED":            return "Submitted for supervisor approval";
            case "UPDATED":              return "Requisition revised and saved";
            case "APPROVED":             return "Approved by supervisor";
            case "REJECTED":             return "Rejected by supervisor";
            case "RETURNED":             return "Returned for revision";
            case "BURSAR_REVIEWED":      return "Reviewed by Bursar";
            case "PAID_OUT":             return "Payment confirmed — marked as Paid Out";
            case "PENDING_PAYMENT":      return "Marked as Pending Payment";
            case "LEDGER_POSTED":        return "Accounting entry posted to General Ledger";
            default:                     return code.Replace("_", " ");
        }
    }

    private string BuildMetaGrid(string[][] items)
    {
        var sb = new StringBuilder();
        foreach (var item in items)
        {
            string label = item[0];
            string val   = item.Length > 1 ? item[1] : "—";
            sb.AppendFormat(
                "<div class='rd-meta-item'><div class='rd-meta-item__label'>{0}</div><div class='rd-meta-item__val'>{1}</div></div>",
                HttpUtility.HtmlEncode(label),
                HttpUtility.HtmlEncode(string.IsNullOrEmpty(val) ? "—" : val));
        }
        return sb.ToString();
    }

    private string GetStatusBadge(string status)
    {
        switch (status)
        {
            case "DRAFT":                return "<span class='rd-badge rd-badge--draft'>Draft</span>";
            case "SUBMITTED":            return "<span class='rd-badge rd-badge--submitted'>Awaiting Supervisor</span>";
            case "SUPERVISOR_APPROVED":  return "<span class='rd-badge rd-badge--amber'>Bursar Queue</span>";
            case "SUPERVISOR_REJECTED":  return "<span class='rd-badge rd-badge--red'>Supervisor Rejected</span>";
            case "BURSAR_REVIEW":        return "<span class='rd-badge rd-badge--amber'>Bursar Review</span>";
            case "BURSAR_APPROVED":      return "<span class='rd-badge rd-badge--green'>Bursar Approved</span>";
            case "VC_PENDING":           return "<span class='rd-badge rd-badge--vc'>VC Pending</span>";
            case "VC_APPROVED":          return "<span class='rd-badge rd-badge--green'>VC Approved</span>";
            case "VC_REJECTED":          return "<span class='rd-badge rd-badge--red'>VC Rejected</span>";
            case "PROCUREMENT":          return "<span class='rd-badge rd-badge--procurement'>Procurement</span>";
            case "PROCUREMENT_COMPLETE": return "<span class='rd-badge rd-badge--green'>Procurement Done</span>";
            case "FINANCE_REVIEW":       return "<span class='rd-badge rd-badge--amber'>Finance Review</span>";
            case "PAID_OUT":             return "<span class='rd-badge rd-badge--paid'>Paid Out</span>";
            case "PENDING_PAYMENT":      return "<span class='rd-badge rd-badge--pending-pay'>Pending Payment</span>";
            case "RETURNED":             return "<span class='rd-badge rd-badge--returned'>Returned</span>";
            case "CANCELLED":            return "<span class='rd-badge rd-badge--cancelled'>Cancelled</span>";
            default:                     return "<span class='rd-badge rd-badge--draft'>" + HttpUtility.HtmlEncode(status) + "</span>";
        }
    }

    private string GetPriorityHtml(string priority)
    {
        string cls = "rd-pri--medium";
        switch ((priority ?? "").ToUpper())
        {
            case "LOW":    cls = "rd-pri--low";    break;
            case "HIGH":   cls = "rd-pri--high";   break;
            case "URGENT": cls = "rd-pri--urgent"; break;
        }
        return string.Format("<span class='rd-pri-dot {0}'></span>{1}", cls, HttpUtility.HtmlEncode(priority ?? "Medium"));
    }

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

    private int     SafeInt(object v)     { int x; return v == null || v == DBNull.Value ? 0 : int.TryParse(v.ToString(), out x) ? x : 0; }
    private string  SafeStr(object v)     { return v == null || v == DBNull.Value ? "" : v.ToString().Trim(); }
    private decimal SafeDecimal(object v) { decimal x; return v == null || v == DBNull.Value ? 0 : decimal.TryParse(v.ToString(), out x) ? x : 0; }
}
