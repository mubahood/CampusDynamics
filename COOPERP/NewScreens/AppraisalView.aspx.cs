using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AppraisalView : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─── Query-string helpers ──────────────────────────────────────────
    private int QsPage   { get { int v; return int.TryParse(Request.QueryString["page"] ?? "1", out v) && v > 0 ? v : 1; } }
    private string QsSearch { get { return (Request.QueryString["q"] ?? "").Trim(); } }
    private string QsStatus { get { return (Request.QueryString["status"] ?? "").Trim().ToUpper(); } }
    private string QsCategory { get { return (Request.QueryString["cat"] ?? "").Trim().ToUpper(); } }
    private int QsSession { get { int v; return int.TryParse(Request.QueryString["sid"] ?? "0", out v) && v > 0 ? v : 0; } }
    private int QsRecord  { get { int v; return int.TryParse(Request.QueryString["rid"] ?? "0", out v) && v > 0 ? v : 0; } }

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle AJAX
        string ajax = (Request.QueryString["ajax"] ?? "").Trim();
        if (!string.IsNullOrEmpty(ajax))
        {
            Response.ContentType = "application/json";
            Response.Clear();
            HandleAjax(ajax);
            Response.End();
            return;
        }

        if (!IsPostBack)
        {
            if (QsRecord > 0)
            {
                pnlList.Visible = false;
                pnlDetail.Visible = true;
                LoadRecordDetail(QsRecord);
            }
            else
            {
                pnlList.Visible = true;
                pnlDetail.Visible = false;
                LoadSessionFilter();
                BindGrid();
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AJAX HANDLER
    // ═══════════════════════════════════════════════════════════════════
    private void HandleAjax(string action)
    {
        switch (action)
        {
            case "get_record_detail":
                AjaxGetRecordDetail();
                break;
            case "admin_return":
                AjaxAdminReturn();
                break;
            case "admin_cancel":
                AjaxAdminCancel();
                break;
            case "admin_reopen":
                AjaxAdminReopen();
                break;
            default:
                Response.Write("{\"error\":\"Unknown action\"}");
                break;
        }
    }

    private void AjaxGetRecordDetail()
    {
        int rid;
        if (!int.TryParse(Request.QueryString["rid"], out rid))
        { Response.Write("{\"error\":\"Invalid record ID\"}"); return; }

        // Main record + employee + reviewer + session
        DataTable dtRec = ExecuteQuery(
            @"SELECT ar.*,
                     e.emp_name, e.EMP_CODE, e.EmpType, e.department, e.designation,
                     e.date_joined, e.employment_status,
                     IFNULL(rev.emp_name,'Unassigned') AS reviewer_name,
                     IFNULL(rev.designation,'') AS reviewer_designation,
                     s.session_title, s.period_start, s.period_end, s.deadline
              FROM appraisal_records ar
              INNER JOIN hrm_employee e ON e.empID = ar.employee_id
              LEFT JOIN hrm_employee rev ON rev.empID = ar.reviewer_id
              INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
              WHERE ar.record_id = @rid",
            new MySqlParameter("@rid", rid));

        if (dtRec.Rows.Count == 0) { Response.Write("{\"error\":\"Record not found\"}"); return; }
        DataRow rec = dtRec.Rows[0];

        // Section B
        DataTable dtB = ExecuteQuery(
            @"SELECT slot_number, agreed_output, performance_indicators, result_areas,
                     self_rating, supervisor_rating, comments
              FROM appraisal_section_b WHERE record_id = @rid ORDER BY slot_number",
            new MySqlParameter("@rid", rid));

        // Section C
        DataTable dtC = ExecuteQuery(
            @"SELECT competency_code, competency_name, category_name, rating, is_na, comment
              FROM appraisal_section_c WHERE record_id = @rid ORDER BY competency_code",
            new MySqlParameter("@rid", rid));

        // Section D
        DataTable dtD = ExecuteQuery(
            @"SELECT performance_gap, agreed_action, time_frame
              FROM appraisal_section_d WHERE record_id = @rid ORDER BY entry_id",
            new MySqlParameter("@rid", rid));

        // Section E
        DataTable dtE = ExecuteQuery(
            @"SELECT question_number, question_text, response
              FROM appraisal_section_e WHERE record_id = @rid ORDER BY question_number",
            new MySqlParameter("@rid", rid));

        // Build JSON
        StringBuilder sb = new StringBuilder("{");

        // Record info
        sb.AppendFormat("\"record_id\":{0},", SafeInt(rec["record_id"]));
        sb.AppendFormat("\"status\":\"{0}\",", EscapeJson(rec["status"]));
        sb.AppendFormat("\"staff_category\":\"{0}\",", EscapeJson(rec["staff_category"]));
        sb.AppendFormat("\"emp_name\":\"{0}\",", EscapeJson(rec["emp_name"]));
        sb.AppendFormat("\"EMP_CODE\":\"{0}\",", EscapeJson(rec["EMP_CODE"]));
        sb.AppendFormat("\"EmpType\":\"{0}\",", EscapeJson(rec["EmpType"]));
        sb.AppendFormat("\"department\":\"{0}\",", EscapeJson(rec["department"]));
        sb.AppendFormat("\"designation\":\"{0}\",", EscapeJson(rec["designation"]));
        sb.AppendFormat("\"date_joined\":\"{0}\",", FormatDate(rec["date_joined"]));
        sb.AppendFormat("\"employment_status\":\"{0}\",", EscapeJson(rec["employment_status"]));
        sb.AppendFormat("\"reviewer_name\":\"{0}\",", EscapeJson(rec["reviewer_name"]));
        sb.AppendFormat("\"reviewer_designation\":\"{0}\",", EscapeJson(rec["reviewer_designation"]));
        sb.AppendFormat("\"session_title\":\"{0}\",", EscapeJson(rec["session_title"]));
        sb.AppendFormat("\"period_start\":\"{0}\",", FormatDate(rec["period_start"]));
        sb.AppendFormat("\"period_end\":\"{0}\",", FormatDate(rec["period_end"]));
        sb.AppendFormat("\"deadline\":\"{0}\",", FormatDate(rec["deadline"]));
        sb.AppendFormat("\"employee_submitted_at\":\"{0}\",", FormatDateTime(rec["employee_submitted_at"]));
        sb.AppendFormat("\"supervisor_submitted_at\":\"{0}\",", FormatDateTime(rec["supervisor_submitted_at"]));

        // Scores
        sb.AppendFormat("\"section_b_self_total\":\"{0}\",", SafeDecStr(rec["section_b_self_total"]));
        sb.AppendFormat("\"section_b_supervisor_total\":\"{0}\",", SafeDecStr(rec["section_b_supervisor_total"]));
        sb.AppendFormat("\"section_c_total\":\"{0}\",", SafeDecStr(rec["section_c_total"]));
        sb.AppendFormat("\"raw_score\":\"{0}\",", SafeDecStr(rec["raw_score"]));
        sb.AppendFormat("\"max_possible\":\"{0}\",", SafeDecStr(rec["max_possible"]));
        sb.AppendFormat("\"final_percentage\":\"{0}\",", SafeDecStr(rec["final_percentage"]));
        sb.AppendFormat("\"classification\":\"{0}\",", EscapeJson(rec["classification"]));

        // Section B
        sb.Append("\"section_b\":[");
        for (int i = 0; i < dtB.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            DataRow b = dtB.Rows[i];
            sb.Append("{");
            sb.AppendFormat("\"slot\":{0},", SafeInt(b["slot_number"]));
            sb.AppendFormat("\"output\":\"{0}\",", EscapeJson(b["agreed_output"]));
            sb.AppendFormat("\"indicators\":\"{0}\",", EscapeJson(b["performance_indicators"]));
            sb.AppendFormat("\"result_areas\":\"{0}\",", EscapeJson(b["result_areas"]));
            sb.AppendFormat("\"self_rating\":\"{0}\",", SafeDecStr(b["self_rating"]));
            sb.AppendFormat("\"sup_rating\":\"{0}\",", SafeDecStr(b["supervisor_rating"]));
            sb.AppendFormat("\"comments\":\"{0}\"", EscapeJson(b["comments"]));
            sb.Append("}");
        }
        sb.Append("],");

        // Section C
        sb.Append("\"section_c\":[");
        for (int i = 0; i < dtC.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            DataRow c = dtC.Rows[i];
            sb.Append("{");
            sb.AppendFormat("\"code\":\"{0}\",", EscapeJson(c["competency_code"]));
            sb.AppendFormat("\"name\":\"{0}\",", EscapeJson(c["competency_name"]));
            sb.AppendFormat("\"category\":\"{0}\",", EscapeJson(c["category_name"]));
            sb.AppendFormat("\"rating\":\"{0}\",", SafeDecStr(c["rating"]));
            sb.AppendFormat("\"is_na\":{0},", SafeInt(c["is_na"]));
            sb.AppendFormat("\"comment\":\"{0}\"", EscapeJson(c["comment"]));
            sb.Append("}");
        }
        sb.Append("],");

        // Section D
        sb.Append("\"section_d\":[");
        for (int i = 0; i < dtD.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            DataRow d = dtD.Rows[i];
            sb.Append("{");
            sb.AppendFormat("\"gap\":\"{0}\",", EscapeJson(d["performance_gap"]));
            sb.AppendFormat("\"action\":\"{0}\",", EscapeJson(d["agreed_action"]));
            sb.AppendFormat("\"timeframe\":\"{0}\"", EscapeJson(d["time_frame"]));
            sb.Append("}");
        }
        sb.Append("],");

        // Section E
        sb.Append("\"section_e\":[");
        for (int i = 0; i < dtE.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            DataRow qe = dtE.Rows[i];
            sb.Append("{");
            sb.AppendFormat("\"q_num\":{0},", SafeInt(qe["question_number"]));
            sb.AppendFormat("\"q_text\":\"{0}\",", EscapeJson(qe["question_text"]));
            sb.AppendFormat("\"response\":\"{0}\"", EscapeJson(qe["response"]));
            sb.Append("}");
        }
        sb.Append("]}");

        Response.Write(sb.ToString());
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AJAX: ADMIN RETURN TO EMPLOYEE
    // ═══════════════════════════════════════════════════════════════════
    private void AjaxAdminReturn()
    {
        try
        {
            string body;
            using (System.IO.StreamReader sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            System.Web.Script.Serialization.JavaScriptSerializer jss = new System.Web.Script.Serialization.JavaScriptSerializer();
            Dictionary<string, object> data = jss.Deserialize<Dictionary<string, object>>(body);

            int rid = Convert.ToInt32(data["rid"]);
            string comment = data.ContainsKey("comment") ? (data["comment"] ?? "").ToString().Trim() : "";

            if (string.IsNullOrEmpty(comment))
            {
                Response.Write("{\"ok\":false,\"error\":\"Please provide a reason for returning.\"}");
                return;
            }

            // Validate record status
            DataTable dt = ExecuteQuery("SELECT status FROM appraisal_records WHERE record_id = @rid", new MySqlParameter("@rid", rid));
            if (dt.Rows.Count == 0) { Response.Write("{\"ok\":false,\"error\":\"Record not found.\"}"); return; }
            string status = SafeStr(dt.Rows[0]["status"]);
            if (status != "EMPLOYEE_SUBMITTED" && status != "SUPERVISOR_IN_PROGRESS")
            {
                Response.Write("{\"ok\":false,\"error\":\"Cannot return: status is " + status + "\"}");
                return;
            }

            // Ensure column exists
            try { ExecuteNonQuery("ALTER TABLE appraisal_records ADD COLUMN supervisor_return_comment TEXT DEFAULT NULL"); } catch { }

            ExecuteNonQuery(
                "UPDATE appraisal_records SET status = 'RETURNED', supervisor_return_comment = @c WHERE record_id = @rid",
                new MySqlParameter("@c", comment),
                new MySqlParameter("@rid", rid));

            Response.Write("{\"ok\":true,\"message\":\"Appraisal returned to employee for revision.\"}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AJAX: ADMIN CANCEL RECORD
    // ═══════════════════════════════════════════════════════════════════
    private void AjaxAdminCancel()
    {
        try
        {
            string body;
            using (System.IO.StreamReader sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            System.Web.Script.Serialization.JavaScriptSerializer jss = new System.Web.Script.Serialization.JavaScriptSerializer();
            Dictionary<string, object> data = jss.Deserialize<Dictionary<string, object>>(body);

            int rid = Convert.ToInt32(data["rid"]);

            DataTable dt = ExecuteQuery("SELECT status FROM appraisal_records WHERE record_id = @rid", new MySqlParameter("@rid", rid));
            if (dt.Rows.Count == 0) { Response.Write("{\"ok\":false,\"error\":\"Record not found.\"}"); return; }
            string status = SafeStr(dt.Rows[0]["status"]);
            if (status == "CANCELLED") { Response.Write("{\"ok\":false,\"error\":\"Already cancelled.\"}"); return; }

            ExecuteNonQuery(
                "UPDATE appraisal_records SET status = 'CANCELLED' WHERE record_id = @rid",
                new MySqlParameter("@rid", rid));

            Response.Write("{\"ok\":true,\"message\":\"Appraisal record cancelled.\"}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AJAX: ADMIN RE-OPEN COMPLETED RECORD
    // ═══════════════════════════════════════════════════════════════════
    private void AjaxAdminReopen()
    {
        try
        {
            string body;
            using (System.IO.StreamReader sr = new System.IO.StreamReader(Request.InputStream)) { body = sr.ReadToEnd(); }
            System.Web.Script.Serialization.JavaScriptSerializer jss = new System.Web.Script.Serialization.JavaScriptSerializer();
            Dictionary<string, object> data = jss.Deserialize<Dictionary<string, object>>(body);

            int rid = Convert.ToInt32(data["rid"]);

            DataTable dt = ExecuteQuery("SELECT status FROM appraisal_records WHERE record_id = @rid", new MySqlParameter("@rid", rid));
            if (dt.Rows.Count == 0) { Response.Write("{\"ok\":false,\"error\":\"Record not found.\"}"); return; }
            string status = SafeStr(dt.Rows[0]["status"]);
            if (status != "COMPLETED") { Response.Write("{\"ok\":false,\"error\":\"Only completed records can be re-opened.\"}"); return; }

            ExecuteNonQuery(
                "UPDATE appraisal_records SET status = 'SUPERVISOR_IN_PROGRESS', supervisor_submitted_at = NULL WHERE record_id = @rid",
                new MySqlParameter("@rid", rid));

            Response.Write("{\"ok\":true,\"message\":\"Appraisal re-opened for supervisor review.\"}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":\"" + ex.Message.Replace("\"", "'") + "\"}");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SESSION FILTER
    // ═══════════════════════════════════════════════════════════════════
    private void LoadSessionFilter()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT session_id, session_title, status
              FROM appraisal_sessions
              ORDER BY FIELD(status,'ACTIVE','DRAFT','CLOSED','ARCHIVED'), created_at DESC");

        StringBuilder sb = new StringBuilder();
        sb.Append("<option value='0'>All Sessions</option>");
        foreach (DataRow r in dt.Rows)
        {
            int sid = Convert.ToInt32(r["session_id"]);
            sb.AppendFormat("<option value='{0}'{1}>{2} ({3})</option>",
                sid,
                sid == QsSession ? " selected" : "",
                HttpUtility.HtmlEncode(r["session_title"].ToString()),
                r["status"].ToString());
        }
        litSessionOptions.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  GRID (List mode)
    // ═══════════════════════════════════════════════════════════════════
    private void BindGrid()
    {
        StringBuilder where = new StringBuilder("WHERE 1=1");
        List<MySqlParameter> parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(QsSearch))
        {
            where.Append(" AND (e.emp_name LIKE @q OR e.EMP_CODE LIKE @q)");
            parms.Add(new MySqlParameter("@q", "%" + QsSearch + "%"));
        }
        if (!string.IsNullOrEmpty(QsStatus))
        {
            where.Append(" AND ar.status = @st");
            parms.Add(new MySqlParameter("@st", QsStatus));
        }
        if (!string.IsNullOrEmpty(QsCategory))
        {
            where.Append(" AND ar.staff_category = @cat");
            parms.Add(new MySqlParameter("@cat", QsCategory));
        }
        if (QsSession > 0)
        {
            where.Append(" AND ar.session_id = @sid");
            parms.Add(new MySqlParameter("@sid", QsSession));
        }

        // Count
        string countSql = "SELECT COUNT(*) FROM appraisal_records ar INNER JOIN hrm_employee e ON e.empID = ar.employee_id " + where.ToString();
        DataTable dtCount = ExecuteQuery(countSql, parms.ToArray());
        int totalRecords = Convert.ToInt32(dtCount.Rows[0][0]);

        int pageSize = 25;
        int totalPages = (int)Math.Ceiling((double)totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;
        int currentPage = QsPage;
        if (currentPage > totalPages) currentPage = totalPages;
        int offset = (currentPage - 1) * pageSize;

        string dataSql = string.Format(
            @"SELECT ar.record_id, ar.session_id, ar.status, ar.staff_category,
                     ar.final_percentage, ar.classification, ar.updated_at,
                     e.emp_name, e.EMP_CODE, e.department, e.designation,
                     IFNULL(rev.emp_name,'Unassigned') AS reviewer_name,
                     s.session_title
              FROM appraisal_records ar
              INNER JOIN hrm_employee e ON e.empID = ar.employee_id
              LEFT JOIN hrm_employee rev ON rev.empID = ar.reviewer_id
              INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
              {0}
              ORDER BY ar.updated_at DESC
              LIMIT {1} OFFSET {2}",
            where.ToString(), pageSize, offset);

        DataTable dtData = ExecuteQuery(dataSql, CloneParams(parms));

        // Render
        StringBuilder html = new StringBuilder();
        if (dtData.Rows.Count == 0)
        {
            html.Append("<tr><td colspan='9' class='pa-empty-state'>");
            html.Append("<svg xmlns='http://www.w3.org/2000/svg' width='40' height='40' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/></svg>");
            html.Append("<p>No appraisal records found.</p></td></tr>");
        }
        else
        {
            int rowNum = 0;
            foreach (DataRow r in dtData.Rows)
            {
                rowNum++;
                int recId = Convert.ToInt32(r["record_id"]);
                string status = SafeStr(r["status"]);

                html.AppendFormat("<tr onclick=\"window.location='AppraisalView.aspx?rid={0}'\" style='cursor:pointer;' title='Click to view full appraisal'>", recId);
                html.AppendFormat("<td class='pa-col-num'>{0}</td>", offset + rowNum);
                html.AppendFormat("<td><strong>{0}</strong><br/><span style='font-size:10px;color:#999;'>{1}</span></td>",
                    HttpUtility.HtmlEncode(SafeStr(r["emp_name"])),
                    HttpUtility.HtmlEncode(SafeStr(r["EMP_CODE"])));
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeStr(r["department"])));
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeStr(r["staff_category"])));
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeStr(r["session_title"])));
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeStr(r["reviewer_name"])));
                html.AppendFormat("<td><span class='pa-rec-badge pa-rec-badge--{0}'>{1}</span></td>",
                    GetRecordBadgeModifier(status), FormatStatusLabel(status));

                string pct = (r["final_percentage"] != null && r["final_percentage"] != DBNull.Value)
                    ? Convert.ToDecimal(r["final_percentage"]).ToString("F1") + "%" : "—";
                html.AppendFormat("<td class='pa-num' style='font-weight:600;'>{0}</td>", pct);

                string cls = SafeStr(r["classification"]);
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(cls != "" ? cls : "—"));
                html.Append("</tr>");
            }
        }
        litGridBody.Text = html.ToString();

        // Stats
        litTotalCount.Text = totalRecords.ToString("N0");

        // Pager info
        litPagerInfo.Text = string.Format("Showing {0}–{1} of {2}",
            totalRecords == 0 ? 0 : offset + 1,
            Math.Min(offset + pageSize, totalRecords),
            totalRecords);

        BuildPager(currentPage, totalPages);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DETAIL VIEW (server-rendered for when ?rid= is present)
    // ═══════════════════════════════════════════════════════════════════
    private void LoadRecordDetail(int rid)
    {
        // Main record + employee + reviewer + session
        DataTable dtRec = ExecuteQuery(
            @"SELECT ar.*,
                     e.emp_name, e.EMP_CODE, e.EmpType, e.department, e.designation,
                     e.date_joined, e.employment_status,
                     IFNULL(rev.emp_name,'Unassigned') AS reviewer_name,
                     IFNULL(rev.designation,'') AS reviewer_designation,
                     s.session_title, s.period_start, s.period_end, s.deadline
              FROM appraisal_records ar
              INNER JOIN hrm_employee e ON e.empID = ar.employee_id
              LEFT JOIN hrm_employee rev ON rev.empID = ar.reviewer_id
              INNER JOIN appraisal_sessions s ON s.session_id = ar.session_id
              WHERE ar.record_id = @rid",
            new MySqlParameter("@rid", rid));

        if (dtRec.Rows.Count == 0)
        {
            litDetailContent.Text = "<div class='pa-alert--error'>Appraisal record not found.</div>";
            return;
        }

        DataRow rec = dtRec.Rows[0];
        string status = SafeStr(rec["status"]);

        StringBuilder html = new StringBuilder();

        // ── Header bar ──
        html.Append("<div class='pa-detail-header'>");
        html.AppendFormat("<div class='pa-detail-header__left'>");
        html.AppendFormat("<h2 class='pa-detail-header__name'>{0}</h2>", HttpUtility.HtmlEncode(SafeStr(rec["emp_name"])));
        html.AppendFormat("<div class='pa-detail-header__meta'>{0} &middot; {1} &middot; {2}</div>",
            HttpUtility.HtmlEncode(SafeStr(rec["EMP_CODE"])),
            HttpUtility.HtmlEncode(SafeStr(rec["department"])),
            HttpUtility.HtmlEncode(SafeStr(rec["designation"])));
        html.Append("</div>");
        html.AppendFormat("<span class='pa-rec-badge pa-rec-badge--{0}' style='font-size:12px;padding:4px 12px;'>{1}</span>",
            GetRecordBadgeModifier(status), FormatStatusLabel(status));
        html.Append("</div>");

        // ── Section A: Bio Data ──
        html.Append("<div class='pa-detail-section'>");
        html.Append("<div class='pa-detail-section__hdr'>Section A — Bio Data</div>");
        html.Append("<div class='pa-detail-section__body'>");
        html.Append("<div class='pa-info-grid'>");
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Name</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["emp_name"])));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Staff Code</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["EMP_CODE"])));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Department</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["department"])));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Designation</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["designation"])));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Staff Category</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["staff_category"])));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Employment Status</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["employment_status"])));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Date Joined</span><span class='pa-info-val'>{0}</span></div>",
            FormatDateDisplay(rec["date_joined"]));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Reviewer</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["reviewer_name"])));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Appraisal Period</span><span class='pa-info-val'>{0} — {1}</span></div>",
            FormatDateDisplay(rec["period_start"]), FormatDateDisplay(rec["period_end"]));
        html.AppendFormat("<div class='pa-info-item'><span class='pa-info-label'>Session</span><span class='pa-info-val'>{0}</span></div>",
            HttpUtility.HtmlEncode(SafeStr(rec["session_title"])));
        html.Append("</div>");
        html.Append("</div></div>");

        // ── Section B: Performance Outputs ──
        DataTable dtB = ExecuteQuery(
            @"SELECT slot_number, agreed_output, performance_indicators, result_areas,
                     self_rating, supervisor_rating, comments
              FROM appraisal_section_b WHERE record_id = @rid ORDER BY slot_number",
            new MySqlParameter("@rid", rid));

        html.Append("<div class='pa-detail-section'>");
        html.Append("<div class='pa-detail-section__hdr'>Section B — Agreed Outputs / Performance</div>");
        html.Append("<div class='pa-detail-section__body'>");
        if (dtB.Rows.Count == 0)
        {
            html.Append("<p class='pa-detail-empty'>No performance outputs recorded yet.</p>");
        }
        else
        {
            html.Append("<table class='pa-table pa-detail-table'>");
            html.Append("<thead><tr><th>#</th><th>Agreed Output</th><th>Indicators</th><th>Result Areas</th><th>Self</th><th>Supervisor</th><th>Comments</th></tr></thead>");
            html.Append("<tbody>");
            foreach (DataRow b in dtB.Rows)
            {
                html.Append("<tr>");
                html.AppendFormat("<td>{0}</td>", SafeInt(b["slot_number"]));
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(b["agreed_output"])));
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(b["performance_indicators"])));
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(b["result_areas"])));
                html.AppendFormat("<td class='pa-num'>{0}</td>", RatingDisplay(b["self_rating"]));
                html.AppendFormat("<td class='pa-num'>{0}</td>", RatingDisplay(b["supervisor_rating"]));
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeStr(b["comments"])));
                html.Append("</tr>");
            }
            html.Append("</tbody></table>");
        }
        html.Append("</div></div>");

        // ── Section C: Competency Assessment ──
        DataTable dtC = ExecuteQuery(
            @"SELECT competency_code, competency_name, category_name, rating, is_na, comment
              FROM appraisal_section_c WHERE record_id = @rid ORDER BY competency_code",
            new MySqlParameter("@rid", rid));

        html.Append("<div class='pa-detail-section'>");
        html.Append("<div class='pa-detail-section__hdr'>Section C — Competency Assessment</div>");
        html.Append("<div class='pa-detail-section__body'>");
        if (dtC.Rows.Count == 0)
        {
            html.Append("<p class='pa-detail-empty'>No competency ratings recorded yet.</p>");
        }
        else
        {
            string lastCategory = "";
            html.Append("<table class='pa-table pa-detail-table'>");
            html.Append("<thead><tr><th>Code</th><th>Competency</th><th>Rating</th><th>N/A</th><th>Comment</th></tr></thead>");
            html.Append("<tbody>");
            foreach (DataRow c in dtC.Rows)
            {
                string cat = SafeStr(c["category_name"]);
                if (cat != lastCategory)
                {
                    html.AppendFormat("<tr class='pa-cat-row'><td colspan='5'><strong>{0}</strong></td></tr>", HttpUtility.HtmlEncode(cat));
                    lastCategory = cat;
                }
                bool isNA = SafeInt(c["is_na"]) == 1;
                html.Append("<tr>");
                html.AppendFormat("<td style='color:#888;font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeStr(c["competency_code"])));
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(c["competency_name"])));
                html.AppendFormat("<td class='pa-num'>{0}</td>", isNA ? "<span style='color:#999;'>N/A</span>" : RatingDisplay(c["rating"]));
                html.AppendFormat("<td>{0}</td>", isNA ? "Yes" : "—");
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeStr(c["comment"])));
                html.Append("</tr>");
            }
            html.Append("</tbody></table>");
        }
        html.Append("</div></div>");

        // ── Section D: Training & Development Plan ──
        DataTable dtD = ExecuteQuery(
            @"SELECT performance_gap, agreed_action, time_frame
              FROM appraisal_section_d WHERE record_id = @rid ORDER BY entry_id",
            new MySqlParameter("@rid", rid));

        html.Append("<div class='pa-detail-section'>");
        html.Append("<div class='pa-detail-section__hdr'>Section D — Training &amp; Development Plan</div>");
        html.Append("<div class='pa-detail-section__body'>");
        if (dtD.Rows.Count == 0)
        {
            html.Append("<p class='pa-detail-empty'>No training plans recorded yet.</p>");
        }
        else
        {
            html.Append("<table class='pa-table pa-detail-table'>");
            html.Append("<thead><tr><th>#</th><th>Performance Gap</th><th>Agreed Action</th><th>Time Frame</th></tr></thead>");
            html.Append("<tbody>");
            int dIdx = 0;
            foreach (DataRow d in dtD.Rows)
            {
                dIdx++;
                html.Append("<tr>");
                html.AppendFormat("<td>{0}</td>", dIdx);
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(d["performance_gap"])));
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(d["agreed_action"])));
                html.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(SafeStr(d["time_frame"])));
                html.Append("</tr>");
            }
            html.Append("</tbody></table>");
        }
        html.Append("</div></div>");

        // ── Section E: Job Holder Comments ──
        DataTable dtE = ExecuteQuery(
            @"SELECT question_number, question_text, response
              FROM appraisal_section_e WHERE record_id = @rid ORDER BY question_number",
            new MySqlParameter("@rid", rid));

        html.Append("<div class='pa-detail-section'>");
        html.Append("<div class='pa-detail-section__hdr'>Section E — Employee Comments</div>");
        html.Append("<div class='pa-detail-section__body'>");
        if (dtE.Rows.Count == 0)
        {
            html.Append("<p class='pa-detail-empty'>No employee comments recorded yet.</p>");
        }
        else
        {
            foreach (DataRow qe in dtE.Rows)
            {
                html.AppendFormat("<div class='pa-comment-block'>");
                html.AppendFormat("<div class='pa-comment-block__q'>Q{0}. {1}</div>",
                    SafeInt(qe["question_number"]),
                    HttpUtility.HtmlEncode(SafeStr(qe["question_text"])));
                string resp = SafeStr(qe["response"]);
                html.AppendFormat("<div class='pa-comment-block__a'>{0}</div>",
                    resp != "" ? HttpUtility.HtmlEncode(resp) : "<em style='color:#999;'>No response</em>");
                html.Append("</div>");
            }
        }
        html.Append("</div></div>");

        // ── Score Summary ──
        string finalPct = SafeDecStr(rec["final_percentage"]);
        string classification = SafeStr(rec["classification"]);

        html.Append("<div class='pa-detail-section pa-detail-section--score'>");
        html.Append("<div class='pa-detail-section__hdr'>Score Summary</div>");
        html.Append("<div class='pa-detail-section__body'>");
        html.Append("<div class='pa-score-grid'>");
        html.AppendFormat("<div class='pa-score-item'><span class='pa-score-label'>Section B (Self)</span><span class='pa-score-val'>{0}</span></div>",
            SafeDecStr(rec["section_b_self_total"]) != "" ? SafeDecStr(rec["section_b_self_total"]) : "—");
        html.AppendFormat("<div class='pa-score-item'><span class='pa-score-label'>Section B (Supervisor)</span><span class='pa-score-val'>{0}</span></div>",
            SafeDecStr(rec["section_b_supervisor_total"]) != "" ? SafeDecStr(rec["section_b_supervisor_total"]) : "—");
        html.AppendFormat("<div class='pa-score-item'><span class='pa-score-label'>Section C (Competencies)</span><span class='pa-score-val'>{0}</span></div>",
            SafeDecStr(rec["section_c_total"]) != "" ? SafeDecStr(rec["section_c_total"]) : "—");
        html.AppendFormat("<div class='pa-score-item'><span class='pa-score-label'>Raw Score</span><span class='pa-score-val'>{0}</span></div>",
            SafeDecStr(rec["raw_score"]) != "" ? SafeDecStr(rec["raw_score"]) : "—");
        html.AppendFormat("<div class='pa-score-item'><span class='pa-score-label'>Max Possible</span><span class='pa-score-val'>{0}</span></div>",
            SafeDecStr(rec["max_possible"]) != "" ? SafeDecStr(rec["max_possible"]) : "—");
        html.AppendFormat("<div class='pa-score-item pa-score-item--final'><span class='pa-score-label'>Final Percentage</span><span class='pa-score-val'>{0}</span></div>",
            finalPct != "" ? finalPct + "%" : "—");
        html.AppendFormat("<div class='pa-score-item pa-score-item--class'><span class='pa-score-label'>Classification</span><span class='pa-score-val'>{0}</span></div>",
            classification != "" ? HttpUtility.HtmlEncode(classification) : "—");
        html.Append("</div>");

        // Timestamps
        html.Append("<div class='pa-timestamps'>");
        html.AppendFormat("<span>Employee submitted: <strong>{0}</strong></span>",
            FormatDateTimeDisplay(rec["employee_submitted_at"]));
        html.AppendFormat("<span>Supervisor submitted: <strong>{0}</strong></span>",
            FormatDateTimeDisplay(rec["supervisor_submitted_at"]));
        html.Append("</div>");

        html.Append("</div></div>");

        // ── Admin Actions ──
        html.Append("<div class='pa-actions'>");
        if (status == "EMPLOYEE_SUBMITTED" || status == "SUPERVISOR_IN_PROGRESS")
        {
            html.AppendFormat("<button type='button' class='hr-btn hr-btn--warning' onclick='adminReturnToEmployee({0})'>", rid);
            html.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><polyline points='1 4 1 10 7 10'/><path d='M3.51 15a9 9 0 1 0 2.13-9.36L1 10'/></svg>");
            html.Append(" Return to Employee</button>");
        }
        if (status == "COMPLETED")
        {
            html.AppendFormat("<button type='button' class='hr-btn hr-btn--primary' onclick='adminReopen({0})'>", rid);
            html.Append("<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M21 2v6h-6'/><path d='M21 13a9 9 0 1 1-3-7.7L21 8'/></svg>");
            html.Append(" Re-open</button>");
        }
        if (status != "CANCELLED")
        {
            html.AppendFormat("<button type='button' class='hr-btn hr-btn--danger hr-btn--sm' onclick='adminCancel({0})' style='margin-left:auto;'>", rid);
            html.Append("Cancel Record</button>");
        }
        html.Append("</div>");

        litDetailContent.Text = html.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PAGER
    // ═══════════════════════════════════════════════════════════════════
    private void BuildPager(int current, int totalPages)
    {
        if (totalPages <= 1) { litPager.Text = ""; return; }

        StringBuilder sb = new StringBuilder();
        if (current > 1)
            sb.AppendFormat("<a href='{0}' class='pa-pager__btn'>&laquo;</a>", BuildFilterUrl("page=" + (current - 1)));
        else
            sb.Append("<span class='pa-pager__btn pa-pager__btn--disabled'>&laquo;</span>");

        int startPage = Math.Max(1, current - 2);
        int endPage = Math.Min(totalPages, current + 2);
        for (int i = startPage; i <= endPage; i++)
        {
            if (i == current)
                sb.AppendFormat("<span class='pa-pager__btn pa-pager__btn--active'>{0}</span>", i);
            else
                sb.AppendFormat("<a href='{0}' class='pa-pager__btn'>{1}</a>", BuildFilterUrl("page=" + i), i);
        }

        if (current < totalPages)
            sb.AppendFormat("<a href='{0}' class='pa-pager__btn'>&raquo;</a>", BuildFilterUrl("page=" + (current + 1)));
        else
            sb.Append("<span class='pa-pager__btn pa-pager__btn--disabled'>&raquo;</span>");

        litPager.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════
    private string BuildFilterUrl(string extra)
    {
        StringBuilder sb = new StringBuilder("AppraisalView.aspx?");
        if (!string.IsNullOrEmpty(QsSearch)) sb.AppendFormat("q={0}&", HttpUtility.UrlEncode(QsSearch));
        if (!string.IsNullOrEmpty(QsStatus)) sb.AppendFormat("status={0}&", HttpUtility.UrlEncode(QsStatus));
        if (!string.IsNullOrEmpty(QsCategory)) sb.AppendFormat("cat={0}&", HttpUtility.UrlEncode(QsCategory));
        if (QsSession > 0) sb.AppendFormat("sid={0}&", QsSession);
        if (!string.IsNullOrEmpty(extra)) sb.Append(extra);
        return sb.ToString().TrimEnd('&');
    }

    private string RatingDisplay(object val)
    {
        if (val == null || val == DBNull.Value) return "<span style='color:#ccc;'>—</span>";
        int rating;
        if (!int.TryParse(val.ToString(), out rating)) return SafeStr(val);
        string color = rating >= 4 ? "#28a745" : rating >= 3 ? "#f59e0b" : rating >= 2 ? "#fd7e14" : "#dc3545";
        return string.Format("<span style='font-weight:700;color:{0};'>{1}</span>", color, rating);
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
            case "RETURNED":               return "Returned";
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
            case "RETURNED":               return "returned";
            case "CANCELLED":              return "cancelled";
            default:                       return "pending";
        }
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

    private string SafeDecStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        decimal d;
        if (decimal.TryParse(val.ToString(), out d))
            return d.ToString("F1");
        return val.ToString();
    }

    private string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("yyyy-MM-dd");
        return val.ToString();
    }

    private string FormatDateTime(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("yyyy-MM-dd HH:mm:ss");
        return val.ToString();
    }

    private string FormatDateDisplay(object val)
    {
        if (val == null || val == DBNull.Value) return "—";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("dd MMM yyyy");
        return val.ToString();
    }

    private string FormatDateTimeDisplay(object val)
    {
        if (val == null || val == DBNull.Value) return "—";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("dd MMM yyyy HH:mm");
        return val.ToString();
    }

    private string EscapeJson(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        string s = val.ToString();
        StringBuilder sb = new StringBuilder(s.Length + 10);
        foreach (char c in s)
        {
            switch (c)
            {
                case '"':  sb.Append("\\\""); break;
                case '\\': sb.Append("\\\\"); break;
                case '\n': sb.Append("\\n");  break;
                case '\r': sb.Append("\\r");  break;
                case '\t': sb.Append("\\t");  break;
                default:
                    if (c < 0x20) sb.AppendFormat("\\u{0:X4}", (int)c);
                    else sb.Append(c);
                    break;
            }
        }
        return sb.ToString();
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

    private MySqlParameter[] CloneParams(List<MySqlParameter> parms)
    {
        MySqlParameter[] clone = new MySqlParameter[parms.Count];
        for (int i = 0; i < parms.Count; i++)
            clone[i] = new MySqlParameter(parms[i].ParameterName, parms[i].Value);
        return clone;
    }

    private void ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
