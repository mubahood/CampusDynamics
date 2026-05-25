using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AdmissionsController : System.Web.UI.Page
{
    // ── Filter state (set in Page_Load, used by ASPX <%= %> expressions) ──
    protected string FilterQ       { get; private set; }
    protected string FilterStatus  { get; private set; }
    protected string FilterProg    { get; private set; }
    protected string FilterYear    { get; private set; }
    protected string FilterSession { get; private set; }
    protected string FilterSource  { get; private set; } // "ONLINE" | "WALKIN" | ""
    protected int    FilterMinDays { get; private set; }
    protected int    FilterPage    { get; private set; }
    protected int    FilterSize    { get; private set; }

    // Per-request column-existence cache
    private readonly Dictionary<string, bool> _colCache =
        new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);

    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ── Admission status mapping ─────────────────────────────────────────────
    // acad_applicant_choices.adm_status:  0=PENDING  1=ADMITTED  2=REJECTED  3=WITHDRAWN
    // REGISTERED = adm_status=1 AND stud_reg_no set

    private bool IsAuthenticatedStaff()
    {
        if (Context.User != null && Context.User.Identity != null && Context.User.Identity.IsAuthenticated)
            return true;
        return (Session["username"] != null && !string.IsNullOrWhiteSpace(Session["username"].ToString()))
            || (Session["usernm"]   != null && !string.IsNullOrWhiteSpace(Session["usernm"].ToString()));
    }

    // ════════════════════════════════════════════════════════════════════════
    // PAGE LOAD
    // ════════════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = Request.QueryString["ajax"] ?? "";
        if (!string.IsNullOrEmpty(ajax))
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.TrySkipIisCustomErrors = true;

            if (!IsAuthenticatedStaff())
            {
                Response.StatusCode = 403;
                Response.Write("{\"ok\":false,\"error\":\"session_expired\"}");
                Response.End();
                return;
            }

            try
            {
                switch (ajax)
                {
                    case "detail":     HandleDetail();     break;
                    case "admit":      HandleAdmit();      break;
                    case "reject":     HandleReject();     break;
                    case "register":   HandleRegister();   break;
                    case "reregister": HandleReRegister(); break;
                    case "note":       HandleNote();       break;
                    default:
                        Response.Write("{\"ok\":false,\"error\":\"Unknown action.\"}");
                        break;
                }
            }
            catch (Exception ex)
            {
                Response.Write("{\"ok\":false,\"error\":" + JsonStr(ex.Message) + "}");
            }
            Response.End();
            return;
        }

        // ── Normal server-side page render ───────────────────────────────────
        if (!IsAuthenticatedStaff())
        {
            Response.Redirect(ResolveUrl("~/Default.aspx"));
            return;
        }

        FilterQ       = (Request.QueryString["q"]             ?? "").Trim();
        FilterStatus  = (Request.QueryString["status"]        ?? "").Trim().ToUpperInvariant();
        FilterProg    = (Request.QueryString["prog"]          ?? "").Trim();
        FilterYear    = (Request.QueryString["year"]          ?? "").Trim();
        FilterSession = (Request.QueryString["session"]       ?? "").Trim().ToUpperInvariant();
        FilterSource  = (Request.QueryString["source"]        ?? "").Trim().ToUpperInvariant();
        FilterMinDays = Math.Max(0, SafeInt(Request.QueryString["minDaysPending"], 0));
        FilterPage    = Math.Max(1, SafeInt(Request.QueryString["page"], 1));
        FilterSize    = Math.Min(500, Math.Max(5, SafeInt(Request.QueryString["size"], 100)));

        LoadStats();
        LoadProgrammeOptions();
        LoadYearOptions();
        LoadList();
    }

    // ════════════════════════════════════════════════════════════════════════
    // SERVER-SIDE RENDER — STATS
    // ════════════════════════════════════════════════════════════════════════
    private void LoadStats()
    {
        long total = 0, draft = 0, submitted = 0, pending = 0, admitted = 0, registered = 0, rejected = 0;
        try
        {
            using (var conn = Open())
            {
                bool hasAppStatus = ColumnExists(conn, "acad_applications", "app_status");

                string draftExpr = hasAppStatus
                    ? "SUM(CASE WHEN IFNULL(a.app_status,'')='DRAFT' THEN 1 ELSE 0 END)"
                    : "0";
                string submittedExpr = hasAppStatus
                    ? "SUM(CASE WHEN IFNULL(a.app_status,'')='SUBMITTED' THEN 1 ELSE 0 END)"
                    : "SUM(CASE WHEN c.adm_status=0 THEN 1 ELSE 0 END)";
                string pendingExpr = hasAppStatus
                    ? "SUM(CASE WHEN (IFNULL(a.app_status,'')='UNDER_REVIEW' OR (IFNULL(a.app_status,'')='' AND c.adm_status=0)) THEN 1 ELSE 0 END)"
                    : "SUM(CASE WHEN c.adm_status=0 THEN 1 ELSE 0 END)";
                string admittedExpr = hasAppStatus
                    ? "SUM(CASE WHEN ((IFNULL(a.app_status,'')='ADMITTED') OR (c.adm_status=1 AND (a.stud_reg_no IS NULL OR a.stud_reg_no='-' OR a.stud_reg_no=''))) THEN 1 ELSE 0 END)"
                    : "SUM(CASE WHEN c.adm_status=1 AND (a.stud_reg_no IS NULL OR a.stud_reg_no='-' OR a.stud_reg_no='') THEN 1 ELSE 0 END)";
                string rejectedExpr = hasAppStatus
                    ? "SUM(CASE WHEN (IFNULL(a.app_status,'') IN('REJECTED','WITHDRAWN') OR c.adm_status IN(2,3)) THEN 1 ELSE 0 END)"
                    : "SUM(CASE WHEN c.adm_status IN(2,3) THEN 1 ELSE 0 END)";

                string sql = @"
                    SELECT COUNT(*) AS total,
                        " + draftExpr + @" AS draft,
                        " + submittedExpr + @" AS submitted,
                        " + pendingExpr + @" AS pending,
                        " + admittedExpr + @" AS admitted,
                        SUM(CASE WHEN c.adm_status=1 AND a.stud_reg_no IS NOT NULL AND a.stud_reg_no<>'-' AND a.stud_reg_no<>'' THEN 1 ELSE 0 END) AS registered,
                        " + rejectedExpr + @" AS rejected
                    FROM acad_applicant_choices c
                    JOIN acad_applications a ON a.stud_entry_no = c.stud_entry_no
                    WHERE c.Choice = 1";

                using (var cmd = new MySqlCommand(sql, conn))
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        total      = SafeLong(r["total"]);
                        draft      = SafeLong(r["draft"]);
                        submitted  = SafeLong(r["submitted"]);
                        pending    = SafeLong(r["pending"]);
                        admitted   = SafeLong(r["admitted"]);
                        registered = SafeLong(r["registered"]);
                        rejected   = SafeLong(r["rejected"]);
                    }
                }
            }
        }
        catch { /* zeros on error */ }

        var sb = new StringBuilder();
        sb.Append("<div class=\"admc-stats\">");
        sb.AppendFormat("<div class=\"admc-stat admc-stat--total\"><div class=\"admc-stat__label\">Total Applicants</div><div class=\"admc-stat__value\">{0:N0}</div></div>", total);
        sb.AppendFormat("<div class=\"admc-stat admc-stat--draft\"><div class=\"admc-stat__label\">In Draft</div><div class=\"admc-stat__value\">{0:N0}</div></div>", draft);
        sb.AppendFormat("<div class=\"admc-stat admc-stat--submitted\"><div class=\"admc-stat__label\">Submitted</div><div class=\"admc-stat__value\">{0:N0}</div></div>", submitted);
        sb.AppendFormat("<div class=\"admc-stat admc-stat--pending\"><div class=\"admc-stat__label\">Pending Admission</div><div class=\"admc-stat__value\">{0:N0}</div></div>", pending);
        sb.AppendFormat("<div class=\"admc-stat admc-stat--admitted\"><div class=\"admc-stat__label\">Admitted</div><div class=\"admc-stat__value\">{0:N0}</div></div>", admitted);
        sb.AppendFormat("<div class=\"admc-stat admc-stat--registered\"><div class=\"admc-stat__label\">Registered</div><div class=\"admc-stat__value\">{0:N0}</div></div>", registered);
        sb.AppendFormat("<div class=\"admc-stat admc-stat--rejected\"><div class=\"admc-stat__label\">Rejected/Withdrawn</div><div class=\"admc-stat__value\">{0:N0}</div></div>", rejected);
        sb.Append("</div>");
        litStats.Text = sb.ToString();
    }

    // ════════════════════════════════════════════════════════════════════════
    // SERVER-SIDE RENDER — PROGRAMME DROPDOWN
    // ════════════════════════════════════════════════════════════════════════
    private void LoadProgrammeOptions()
    {
        var sb = new StringBuilder();
        try
        {
            using (var conn = Open())
            using (var cmd = new MySqlCommand(
                "SELECT progcode, progname FROM acad_programme ORDER BY progname", conn))
            using (var r = cmd.ExecuteReader())
            {
                while (r.Read())
                {
                    string code = r["progcode"].ToString();
                    string name = r["progname"].ToString();
                    string sel  = string.Equals(FilterProg, code, StringComparison.OrdinalIgnoreCase)
                                  ? " selected=\"selected\"" : "";
                    sb.AppendFormat("<option value=\"{0}\"{1}>{2}</option>",
                        HtmlAE(code), sel, HE(name));
                }
            }
        }
        catch { }
        litProgOptions.Text = sb.ToString();
    }

    // ════════════════════════════════════════════════════════════════════════
    // SERVER-SIDE RENDER — YEAR DROPDOWN
    // ════════════════════════════════════════════════════════════════════════
    private void LoadYearOptions()
    {
        var sb  = new StringBuilder();
        int now = DateTime.Now.Year;
        for (int y = now; y >= now - 12; y--)
        {
            string sel = (FilterYear == y.ToString()) ? " selected=\"selected\"" : "";
            sb.AppendFormat("<option value=\"{0}\"{1}>{0}</option>", y, sel);
        }
        litYearOptions.Text = sb.ToString();
    }

    // ════════════════════════════════════════════════════════════════════════
    // SERVER-SIDE RENDER — APPLICATION LIST + PAGER
    // ════════════════════════════════════════════════════════════════════════
    private void LoadList()
    {
        var  sbRows = new StringBuilder();
        long total  = 0;
        int  offset = (FilterPage - 1) * FilterSize;

        var where = new List<string>();
        var parms = new Dictionary<string, object>();
        where.Add("c.Choice = 1");

        if (!string.IsNullOrEmpty(FilterQ))
        {
            where.Add("(a.stud_name LIKE @q OR a.stud_entry_no LIKE @q OR a.stud_reg_no LIKE @q)");
            parms["@q"] = "%" + FilterQ + "%";
        }
        if (!string.IsNullOrEmpty(FilterProg))
        {
            where.Add("c.prog_id = @prog");
            parms["@prog"] = FilterProg;
        }
        if (!string.IsNullOrEmpty(FilterYear))
        {
            where.Add("a.stud_entry_year = @year");
            parms["@year"] = FilterYear;
        }
        if (!string.IsNullOrEmpty(FilterSession))
        {
            where.Add("c.adm_session = @session");
            parms["@session"] = FilterSession;
        }

        switch (FilterStatus)
        {
            case "DRAFT":        where.Add("IFNULL(a.app_status,'') = 'DRAFT'");       break;
            case "SUBMITTED":    where.Add("IFNULL(a.app_status,'') = 'SUBMITTED'");   break;
            case "UNDER_REVIEW": where.Add("IFNULL(a.app_status,'') = 'UNDER_REVIEW'");break;
            case "PENDING":      where.Add("c.adm_status = 0");                         break;
            case "ADMITTED":     where.Add("c.adm_status = 1 AND (a.stud_reg_no IS NULL OR a.stud_reg_no='-' OR a.stud_reg_no='')"); break;
            case "REGISTERED":   where.Add("c.adm_status = 1 AND a.stud_reg_no IS NOT NULL AND a.stud_reg_no<>'-' AND a.stud_reg_no<>''"); break;
            case "REJECTED":     where.Add("c.adm_status = 2");                         break;
            case "WITHDRAWN":    where.Add("c.adm_status = 3");                         break;
        }

        try
        {
            using (var conn = Open())
            {
                bool hasAppLastUpdated  = ColumnExists(conn, "acad_applications", "app_last_updated_at");
                bool hasAppSubmittedAt  = ColumnExists(conn, "acad_applications", "app_submitted_at");
                bool hasUserId          = ColumnExists(conn, "acad_applications", "applicant_user_id");

                string onlineExpr = hasUserId
                    ? "(CASE WHEN a.applicant_user_id IS NOT NULL THEN 1 ELSE 0 END)"
                    : "0";

                // Source filter — only apply if the column exists
                if (hasUserId)
                {
                    if (FilterSource == "ONLINE")
                        where.Add("a.applicant_user_id IS NOT NULL");
                    else if (FilterSource == "WALKIN")
                        where.Add("a.applicant_user_id IS NULL");
                }

                string lastUpdatedExpr = hasAppLastUpdated
                    ? "a.app_last_updated_at"
                    : (hasAppSubmittedAt ? "a.app_submitted_at" : "NOW()");
                string daysPendingExpr = "DATEDIFF(NOW(), " + lastUpdatedExpr + ")";

                if (FilterMinDays > 0)
                {
                    where.Add(daysPendingExpr + " >= @minDays");
                    parms["@minDays"] = FilterMinDays;
                }

                string wClause = "WHERE " + string.Join(" AND ", where.ToArray());

                string countSql = "SELECT COUNT(*) FROM acad_applications a " +
                                  "INNER JOIN acad_applicant_choices c ON c.stud_entry_no = a.stud_entry_no " +
                                  "LEFT JOIN acad_programme p ON p.progcode = c.prog_id " +
                                  wClause;

                string listSql = @"
                    SELECT
                        a.stud_entry_no AS eno,
                        a.stud_name     AS name,
                        a.stud_reg_no   AS regno,
                        COALESCE(p.progname, c.prog_id) AS programme,
                        COALESCE(c.adm_session,'')      AS session,
                        a.stud_entry_year               AS year,
                        " + onlineExpr + @" AS is_online,
                        CASE
                            WHEN c.adm_status=0 THEN 'PENDING'
                            WHEN c.adm_status=2 THEN 'REJECTED'
                            WHEN c.adm_status=3 THEN 'WITHDRAWN'
                            WHEN c.adm_status=1 AND (a.stud_reg_no IS NULL OR a.stud_reg_no='-' OR a.stud_reg_no='') THEN 'ADMITTED'
                            WHEN c.adm_status=1 AND a.stud_reg_no IS NOT NULL AND a.stud_reg_no<>'-' AND a.stud_reg_no<>'' THEN 'REGISTERED'
                            ELSE 'UNKNOWN'
                        END AS status
                    FROM acad_applicant_choices c
                    JOIN acad_applications a ON a.stud_entry_no = c.stud_entry_no
                    LEFT JOIN acad_programme p ON p.progcode = c.prog_id
                    " + wClause + @"
                    ORDER BY is_online DESC, a.stud_entry_no DESC
                    LIMIT @offset, @size";

                using (var countCmd = new MySqlCommand(countSql, conn))
                {
                    foreach (var kv in parms) countCmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    object cv = countCmd.ExecuteScalar();
                    if (cv != null && cv != DBNull.Value) total = Convert.ToInt64(cv);
                }

                using (var cmd = new MySqlCommand(listSql, conn))
                {
                    cmd.CommandTimeout = 30;
                    cmd.Parameters.AddWithValue("@offset", offset);
                    cmd.Parameters.AddWithValue("@size",   FilterSize);
                    foreach (var kv in parms) cmd.Parameters.AddWithValue(kv.Key, kv.Value);

                    bool hasRows = false;
                    int  rowNum  = offset + 1;

                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            hasRows = true;
                            string eno      = r["eno"].ToString();
                            string name     = r["name"].ToString().Trim();
                            string regno    = r["regno"].ToString();
                            string prog     = r["programme"].ToString();
                            string sess     = r["session"].ToString();
                            string yr       = r["year"].ToString();
                            string status   = r["status"].ToString();
                            bool   isOnline = r["is_online"] != DBNull.Value
                                              && Convert.ToInt32(r["is_online"]) == 1;

                            string trAttr = isOnline ? " class=\"admc-row--online\" data-online=\"1\"" : "";
                            sbRows.AppendFormat("<tr{0}>", trAttr);
                            // Checkbox (only for PENDING)
                            sbRows.Append("<td style=\"padding-left:14px;\">");
                            if (status == "PENDING")
                                sbRows.AppendFormat(
                                    "<input type=\"checkbox\" class=\"admc-row-chk\" data-eno=\"{0}\" data-name=\"{1}\" data-status=\"PENDING\" onchange=\"onRowCheck(this)\">",
                                    HtmlAE(eno), HtmlAE(name));
                            sbRows.Append("</td>");

                            sbRows.AppendFormat("<td style=\"color:#bbb;font-size:10px;text-align:center;\">{0}</td>", rowNum);

                            // Entry No cell — show ONLINE chip underneath if submitted via portal
                            sbRows.Append("<td>");
                            sbRows.AppendFormat("<span class=\"admc-eno\">{0}</span>", HE(eno));
                            if (isOnline)
                                sbRows.Append("<br/><span class=\"admc-online-chip\">&#127760; ONLINE</span>");
                            sbRows.Append("</td>");

                            sbRows.AppendFormat("<td><span class=\"admc-name\">{0}</span></td>", HE(name));
                            sbRows.AppendFormat("<td style=\"max-width:180px;white-space:normal;font-size:11px;\">{0}</td>", HE(prog));
                            sbRows.AppendFormat("<td>{0}</td>", HE(sess));
                            sbRows.AppendFormat("<td>{0}</td>", HE(yr));
                            sbRows.AppendFormat("<td style=\"font-family:monospace;font-size:11px;\">{0}</td>",
                                !string.IsNullOrEmpty(regno) && regno != "-"
                                    ? HE(regno) : "<span style=\"color:#ccc;\">&#8212;</span>");
                            sbRows.AppendFormat("<td>{0}</td>", StatusBadgeHtml(status));

                            sbRows.Append("<td><div class=\"admc-actions-cell\">");
                            sbRows.AppendFormat(
                                "<button type=\"button\" class=\"admc-btn admc-btn--ghost admc-btn--sm\" onclick=\"openDetail('{0}')\">View</button>",
                                JsStr(eno));
                            if (status == "PENDING")
                            {
                                sbRows.AppendFormat(
                                    "<button type=\"button\" class=\"admc-btn admc-btn--success admc-btn--sm\" onclick=\"admitOne('{0}','{1}')\">Admit</button>",
                                    JsStr(eno), JsStr(name));
                                sbRows.AppendFormat(
                                    "<button type=\"button\" class=\"admc-btn admc-btn--danger admc-btn--sm\" onclick=\"rejectOne('{0}','{1}')\">Reject</button>",
                                    JsStr(eno), JsStr(name));
                            }
                            if (status == "ADMITTED")
                                sbRows.AppendFormat(
                                    "<button type=\"button\" class=\"admc-btn admc-btn--primary admc-btn--sm\" onclick=\"openDetailTab('{0}','tab-academic')\">Register</button>",
                                    JsStr(eno));
                            if (status == "REGISTERED" && !string.IsNullOrEmpty(regno) && regno != "-")
                            {
                                sbRows.AppendFormat(
                                    "<button type=\"button\" class=\"admc-btn admc-btn--amber admc-btn--sm\" onclick=\"reregisterOne('{0}','{1}')\">Re-register / Fix</button>",
                                    JsStr(eno), JsStr(name));
                                sbRows.AppendFormat(
                                    "<a href=\"StudentProfile.aspx?regno={0}\" class=\"admc-btn admc-btn--ghost admc-btn--sm\" target=\"_blank\">Profile</a>",
                                    Uri.EscapeDataString(regno));
                            }
                            sbRows.Append("</div></td></tr>");
                            rowNum++;
                        }
                    }

                    if (!hasRows)
                        sbRows.Append("<tr><td colspan=\"10\" class=\"admc-empty\">No applicants found for the selected filters.</td></tr>");
                }
            }
        }
        catch (Exception ex)
        {
            sbRows.AppendFormat(
                "<tr><td colspan=\"10\" class=\"admc-empty\" style=\"color:#c62828;\">Error loading data: {0}</td></tr>",
                HE(ex.Message));
        }

        litTableRows.Text = sbRows.ToString();
        litCount.Text = string.Format("{0:N0} record{1}", total, total == 1 ? "" : "s");

        // ── Pager ────────────────────────────────────────────────────────────
        int  pages = Math.Max(1, (int)Math.Ceiling((double)total / FilterSize));
        long from  = total > 0 ? (long)offset + 1 : 0;
        long to    = Math.Min(total, (long)offset + FilterSize);

        var sbPager = new StringBuilder();
        sbPager.Append("<div class=\"admc-pager\">");
        sbPager.AppendFormat("<span>{0}</span>",
            total > 0
                ? string.Format("Showing {0:N0}&#8211;{1:N0} of {2:N0} record{3}", from, to, total, total == 1 ? "" : "s")
                : "0 records");

        sbPager.Append("<div class=\"admc-pager__nav\">");

        if (FilterPage > 1)
            sbPager.AppendFormat("<a href=\"{0}\" class=\"admc-pager__btn\">&#8592; Prev</a>",
                HtmlAE(PageUrl(FilterPage - 1)));
        else
            sbPager.Append("<span class=\"admc-pager__btn\" style=\"opacity:.4;cursor:default;\">&#8592; Prev</span>");

        sbPager.AppendFormat(
            "<span style=\"padding:4px 10px;font-size:11px;color:#555;\">Page {0} of {1}</span>",
            FilterPage, pages);

        if (FilterPage < pages)
            sbPager.AppendFormat("<a href=\"{0}\" class=\"admc-pager__btn\">Next &#8594;</a>",
                HtmlAE(PageUrl(FilterPage + 1)));
        else
            sbPager.Append("<span class=\"admc-pager__btn\" style=\"opacity:.4;cursor:default;\">Next &#8594;</span>");

        sbPager.Append("</div></div>");
        litPager.Text = sbPager.ToString();
    }

    // Builds a page URL preserving all active filters
    private string PageUrl(int page)
    {
        var parts = new List<string>();
        if (!string.IsNullOrEmpty(FilterQ))       parts.Add("q="              + Uri.EscapeDataString(FilterQ));
        if (!string.IsNullOrEmpty(FilterStatus))  parts.Add("status="         + Uri.EscapeDataString(FilterStatus));
        if (!string.IsNullOrEmpty(FilterProg))    parts.Add("prog="           + Uri.EscapeDataString(FilterProg));
        if (!string.IsNullOrEmpty(FilterYear))    parts.Add("year="           + Uri.EscapeDataString(FilterYear));
        if (!string.IsNullOrEmpty(FilterSession)) parts.Add("session="        + Uri.EscapeDataString(FilterSession));
        if (!string.IsNullOrEmpty(FilterSource))  parts.Add("source="         + Uri.EscapeDataString(FilterSource));
        if (FilterMinDays > 0)                    parts.Add("minDaysPending=" + FilterMinDays);
        if (FilterSize != 100)                    parts.Add("size="           + FilterSize);
        if (page > 1)                             parts.Add("page="           + page);
        return "AdmissionsController.aspx" +
               (parts.Count > 0 ? "?" + string.Join("&", parts.ToArray()) : "");
    }

    private static string StatusBadgeHtml(string s)
    {
        string cls, label;
        switch (s)
        {
            case "PENDING":    cls = "admc-badge--pending";    label = "Pending";    break;
            case "ADMITTED":   cls = "admc-badge--admitted";   label = "Admitted";   break;
            case "REGISTERED": cls = "admc-badge--registered"; label = "Registered"; break;
            case "REJECTED":   cls = "admc-badge--rejected";   label = "Rejected";   break;
            case "WITHDRAWN":  cls = "admc-badge--withdrawn";  label = "Withdrawn";  break;
            default:           cls = "";                        label = s;            break;
        }
        return "<span class=\"admc-badge " + cls + "\">" + HE(label) + "</span>";
    }

    // ════════════════════════════════════════════════════════════════════════
    // DETAIL (AJAX — modal popup)
    // ════════════════════════════════════════════════════════════════════════
    private void HandleDetail()
    {
        string eno = (Request.QueryString["eno"] ?? "").Trim();
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");

        using (var conn = Open())
        {
            // Defensive: resolve actual column names — the portal schema reuses legacy columns
            // for education data and some optional columns may not exist in older deployments.
            bool hasNatId      = ColumnExists(conn, "acad_applications", "stud_id_number");
            bool hasNatIdLeg   = !hasNatId  && ColumnExists(conn, "acad_applications", "national_id");
            bool hasTitle      = ColumnExists(conn, "acad_applications", "title");
            bool hasMethod     = ColumnExists(conn, "acad_applications", "stud_entry_method");
            bool hasSponsorC   = ColumnExists(conn, "acad_applications", "sponsor_contact");
            bool hasDistrict   = ColumnExists(conn, "acad_applications", "home_district");
            bool hasPoBox      = ColumnExists(conn, "acad_applications", "post_box");
            bool hasCountry    = ColumnExists(conn, "acad_applications", "residence_country");

            // Education columns — check both the canonical name and the legacy portal alias
            bool hasOlSchool = ColumnExists(conn, "acad_applications", "olevel_school");
            bool hasOlIndex  = ColumnExists(conn, "acad_applications", "olevel_index");
            bool hasOlYr     = ColumnExists(conn, "acad_applications", "olevel_year");
            bool hasOlYrFb   = !hasOlYr && ColumnExists(conn, "acad_applications", "stud_pob");
            bool hasOlAgg    = ColumnExists(conn, "acad_applications", "olevel_agg");
            bool hasOlAggFb  = !hasOlAgg && ColumnExists(conn, "acad_applications", "stud_district");
            bool hasAlSchool = ColumnExists(conn, "acad_applications", "alevel_school");
            bool hasAlIndex  = ColumnExists(conn, "acad_applications", "alevel_index");
            bool hasAlYr     = ColumnExists(conn, "acad_applications", "alevel_year");
            bool hasAlPts    = ColumnExists(conn, "acad_applications", "alevel_points");
            bool hasAlPtsFb  = !hasAlPts && ColumnExists(conn, "acad_applications", "stud_ward");
            bool hasOtInst   = ColumnExists(conn, "acad_applications", "other_institution");
            bool hasOtInstFb = !hasOtInst && ColumnExists(conn, "acad_applications", "stud_prevcampus");
            bool hasOtQual   = ColumnExists(conn, "acad_applications", "other_qualification");
            bool hasOtQualFb = !hasOtQual && ColumnExists(conn, "acad_applications", "stud_lg");
            bool hasOtYr     = ColumnExists(conn, "acad_applications", "other_year");
            bool hasOtYrFb   = !hasOtYr && ColumnExists(conn, "acad_applications", "stud_village");
            bool hasOtGr     = ColumnExists(conn, "acad_applications", "other_grade");
            bool hasOtGrFb   = !hasOtGr && ColumnExists(conn, "acad_applications", "stud_county");

            string natIdX    = hasNatId    ? "a.stud_id_number"    : (hasNatIdLeg ? "a.national_id"         : "NULL");
            string titleX    = hasTitle    ? "a.title"             : "NULL";
            string methX     = hasMethod   ? "a.stud_entry_method" : "NULL";
            string sCX       = hasSponsorC ? "a.sponsor_contact"   : "NULL";
            string distX     = hasDistrict ? "a.home_district"     : "NULL";
            string pbX       = hasPoBox    ? "a.post_box"          : "NULL";
            string cntX      = hasCountry  ? "a.residence_country" : "NULL";
            string olSchoolX = hasOlSchool ? "a.olevel_school"     : "NULL";
            string olIndexX  = hasOlIndex  ? "a.olevel_index"      : "NULL";
            string olYrX     = hasOlYr     ? "a.olevel_year"       : (hasOlYrFb   ? "a.stud_pob"       : "NULL");
            string olAggX    = hasOlAgg    ? "a.olevel_agg"        : (hasOlAggFb  ? "a.stud_district"  : "NULL");
            string alSchoolX = hasAlSchool ? "a.alevel_school"     : "NULL";
            string alIndexX  = hasAlIndex  ? "a.alevel_index"      : "NULL";
            string alYrX     = hasAlYr     ? "a.alevel_year"       : "NULL";
            string alPtsX    = hasAlPts    ? "a.alevel_points"     : (hasAlPtsFb  ? "a.stud_ward"      : "NULL");
            string otInX   = hasOtInst  ? "a.other_institution"   : (hasOtInstFb ? "a.stud_prevcampus" : "NULL");
            string otQuX   = hasOtQual  ? "a.other_qualification" : (hasOtQualFb ? "a.stud_lg"          : "NULL");
            string otYrX   = hasOtYr    ? "a.other_year"          : (hasOtYrFb   ? "a.stud_village"     : "NULL");
            string otGrX   = hasOtGr    ? "a.other_grade"         : (hasOtGrFb   ? "a.stud_county"      : "NULL");

            string sql = @"
                SELECT
                    a.stud_entry_no                                         AS eno,
                    COALESCE(a.stud_reg_no,'')                              AS regno,
                    COALESCE(a.stud_name,'')                                AS name,
                    COALESCE(a.stud_sex,'')                                 AS sex,
                    COALESCE(DATE_FORMAT(a.stud_birthdate,'%d/%m/%Y'),'')   AS dob,
                    COALESCE(a.stud_nationality,'')                         AS nationality,
                    COALESCE(a.stud_religion,'')                            AS religion,
                    COALESCE(a.stud_mar_stat,'')                            AS marital,
                    COALESCE(" + natIdX  + @",'')                           AS national_id,
                    COALESCE(a.physicalDisability,'')                       AS disability,
                    COALESCE(" + titleX  + @",'')                           AS title,
                    COALESCE(a.stud_campus,'')                              AS campus,
                    COALESCE(a.app_reviewer_notes,'')                       AS reviewer_notes,
                    COALESCE(p.progname, c.prog_id,'')                      AS programme,
                    COALESCE(c.adm_session,'')                              AS session,
                    COALESCE(a.stud_entry_year,'')                          AS entry_year,
                    COALESCE(" + methX   + @",'')                           AS entry_method,
                    COALESCE(a.stud_intake,'')                              AS intake,
                    COALESCE(c.sub_comb,'')                                 AS specialisation,
                    COALESCE(a.stud_sponsor,'')                             AS sponsor,
                    COALESCE(" + sCX     + @",'')                           AS sponsor_contact,
                    COALESCE(" + olSchoolX + @",'')                         AS olevel_school,
                    COALESCE(" + olIndexX  + @",'')                         AS olevel_index,
                    COALESCE(" + olYrX     + @",'')                         AS olevel_year,
                    COALESCE(" + olAggX    + @",'')                         AS olevel_agg,
                    COALESCE(" + alSchoolX + @",'')                         AS alevel_school,
                    COALESCE(" + alIndexX  + @",'')                         AS alevel_index,
                    COALESCE(" + alYrX   + @",'')                           AS alevel_year,
                    COALESCE(" + alPtsX  + @",'')                           AS alevel_points,
                    COALESCE(" + otInX   + @",'')                           AS other_inst,
                    COALESCE(" + otQuX   + @",'')                           AS other_qual,
                    COALESCE(" + otYrX   + @",'')                           AS other_year,
                    COALESCE(" + otGrX   + @",'')                           AS other_grade,
                    COALESCE(a.stud_phone,'')                               AS phone,
                    COALESCE(a.stud_email,'')                               AS email,
                    COALESCE(a.stud_phy_address,'')                         AS address,
                    COALESCE(" + distX   + @",'')                           AS district,
                    COALESCE(" + pbX     + @",'')                           AS pobox,
                    COALESCE(" + cntX    + @",'')                           AS country,
                    COALESCE(a.next_kin,'')                                 AS kin_name,
                    COALESCE(a.kin_relationship,'')                         AS kin_relationship,
                    COALESCE(a.kin_contacts,'')                             AS kin_contacts,
                    CASE
                        WHEN c.adm_status=0 THEN 'PENDING'
                        WHEN c.adm_status=2 THEN 'REJECTED'
                        WHEN c.adm_status=3 THEN 'WITHDRAWN'
                        WHEN c.adm_status=1 AND (a.stud_reg_no IS NULL OR a.stud_reg_no='-' OR a.stud_reg_no='') THEN 'ADMITTED'
                        WHEN c.adm_status=1 AND a.stud_reg_no IS NOT NULL AND a.stud_reg_no<>'-' AND a.stud_reg_no<>'' THEN 'REGISTERED'
                        ELSE 'UNKNOWN'
                    END AS status
                FROM acad_applications a
                JOIN acad_applicant_choices c ON c.stud_entry_no = a.stud_entry_no AND c.Choice = 1
                LEFT JOIN acad_programme p ON p.progcode = c.prog_id
                WHERE a.stud_entry_no = @eno
                LIMIT 1";

            // Billing is a cross-DB join — fetch separately so any failure is isolated
            string billing = "";
            try
            {
                using (var bc = new MySqlCommand(
                    @"SELECT COALESCE(f.bs_name,'')
                      FROM acad_applications a
                      JOIN campus_dynamics_accounts.fin_billing_systems f ON f.ID = a.billingID
                      WHERE a.stud_entry_no = @eno LIMIT 1", conn))
                {
                    bc.Parameters.AddWithValue("@eno", eno);
                    object bv = bc.ExecuteScalar();
                    if (bv != null && bv != DBNull.Value) billing = bv.ToString();
                }
            }
            catch { /* billing is best-effort */ }

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) throw new Exception("Applicant not found: " + eno);
                    Response.Write("{\"ok\":true,"  +
                        "\"eno\":"             + JsonStr(r["eno"].ToString())            + "," +
                        "\"regno\":"           + JsonStr(r["regno"].ToString())          + "," +
                        "\"name\":"            + JsonStr(r["name"].ToString())           + "," +
                        "\"sex\":"             + JsonStr(r["sex"].ToString())            + "," +
                        "\"dob\":"             + JsonStr(r["dob"].ToString())            + "," +
                        "\"nationality\":"     + JsonStr(r["nationality"].ToString())    + "," +
                        "\"religion\":"        + JsonStr(r["religion"].ToString())       + "," +
                        "\"marital\":"         + JsonStr(r["marital"].ToString())        + "," +
                        "\"national_id\":"     + JsonStr(r["national_id"].ToString())    + "," +
                        "\"disability\":"      + JsonStr(r["disability"].ToString())     + "," +
                        "\"title\":"           + JsonStr(r["title"].ToString())          + "," +
                        "\"campus\":"          + JsonStr(r["campus"].ToString())         + "," +
                        "\"programme\":"       + JsonStr(r["programme"].ToString())      + "," +
                        "\"session\":"         + JsonStr(r["session"].ToString())        + "," +
                        "\"entry_year\":"      + JsonStr(r["entry_year"].ToString())     + "," +
                        "\"entry_method\":"    + JsonStr(r["entry_method"].ToString())   + "," +
                        "\"intake\":"          + JsonStr(r["intake"].ToString())         + "," +
                        "\"specialisation\":"  + JsonStr(r["specialisation"].ToString()) + "," +
                        "\"sponsor\":"         + JsonStr(r["sponsor"].ToString())        + "," +
                        "\"sponsor_contact\":" + JsonStr(r["sponsor_contact"].ToString())+ "," +
                        "\"billing\":"         + JsonStr(billing)                        + "," +
                        "\"olevel_school\":"   + JsonStr(r["olevel_school"].ToString())  + "," +
                        "\"olevel_index\":"    + JsonStr(r["olevel_index"].ToString())   + "," +
                        "\"olevel_year\":"     + JsonStr(r["olevel_year"].ToString())    + "," +
                        "\"olevel_agg\":"      + JsonStr(r["olevel_agg"].ToString())     + "," +
                        "\"alevel_school\":"   + JsonStr(r["alevel_school"].ToString())  + "," +
                        "\"alevel_index\":"    + JsonStr(r["alevel_index"].ToString())   + "," +
                        "\"alevel_year\":"     + JsonStr(r["alevel_year"].ToString())    + "," +
                        "\"alevel_points\":"   + JsonStr(r["alevel_points"].ToString())  + "," +
                        "\"other_inst\":"      + JsonStr(r["other_inst"].ToString())     + "," +
                        "\"other_qual\":"      + JsonStr(r["other_qual"].ToString())     + "," +
                        "\"other_year\":"      + JsonStr(r["other_year"].ToString())     + "," +
                        "\"other_grade\":"     + JsonStr(r["other_grade"].ToString())    + "," +
                        "\"phone\":"           + JsonStr(r["phone"].ToString())          + "," +
                        "\"email\":"           + JsonStr(r["email"].ToString())          + "," +
                        "\"address\":"         + JsonStr(r["address"].ToString())        + "," +
                        "\"district\":"        + JsonStr(r["district"].ToString())       + "," +
                        "\"pobox\":"           + JsonStr(r["pobox"].ToString())          + "," +
                        "\"country\":"         + JsonStr(r["country"].ToString())        + "," +
                        "\"kin_name\":"        + JsonStr(r["kin_name"].ToString())       + "," +
                        "\"kin_relationship\":" + JsonStr(r["kin_relationship"].ToString())+ "," +
                        "\"kin_contacts\":"    + JsonStr(r["kin_contacts"].ToString())   + "," +
                        "\"reviewer_notes\":"  + JsonStr(r["reviewer_notes"].ToString()) + "," +
                        "\"status\":"          + JsonStr(r["status"].ToString())         +
                        "}");
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    // ADMIT   (adm_status 0 → 1)
    // ════════════════════════════════════════════════════════════════════════
    private void HandleAdmit()
    {
        var data = ReadPostJson();
        string eno = GetStr(data, "eno");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");

        using (var conn = Open())
        {
            int current = GetAdmStatus(conn, eno);
            if (current != 0) throw new Exception("Applicant is not in PENDING status. Current status code: " + current);

            using (var cmd = new MySqlCommand(
                "UPDATE acad_applicant_choices SET adm_status=1 WHERE stud_entry_no=@eno AND Choice=1", conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                cmd.ExecuteNonQuery();
            }

            UpdateApplicationStatus(conn, eno, "ADMITTED");
            ProvisionStudentAccount(conn, eno, eno);
            AddApplicantNotification(conn, eno, "Your application has been admitted. Please check My Application for next steps.", "/apply/my-application.aspx");
            WriteAuditLog(conn, eno, "ADMITTED", "Application admitted by " + GetCurrentUser());

            string admEmail, admName;
            GetApplicantContact(conn, eno, out admEmail, out admName);
            if (!string.IsNullOrWhiteSpace(admEmail) && admEmail.Contains("@"))
                SendDecisionEmail(admEmail, admName, eno, true, string.Empty);
        }
        Response.Write("{\"ok\":true,\"message\":\"Applicant admitted successfully.\"}");
    }

    // ════════════════════════════════════════════════════════════════════════
    // REJECT / WITHDRAW
    // ════════════════════════════════════════════════════════════════════════
    private void HandleReject()
    {
        var data = ReadPostJson();
        string eno    = GetStr(data, "eno");
        string reason = GetStr(data, "reason");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");

        using (var conn = Open())
        {
            int current = GetAdmStatus(conn, eno);
            if (current == 2 || current == 3) throw new Exception("Applicant already rejected or withdrawn.");

            string regno = "";
            using (var cmd = new MySqlCommand(
                "SELECT COALESCE(stud_reg_no,'') FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                object v = cmd.ExecuteScalar();
                if (v != null) regno = v.ToString();
            }
            if (!string.IsNullOrEmpty(regno) && regno != "-")
                throw new Exception("Cannot reject a student who has already been registered (" + regno + "). Use student management tools instead.");

            int newStatus = (current == 0) ? 2 : 3;
            using (var cmd = new MySqlCommand(
                "UPDATE acad_applicant_choices SET adm_status=@s WHERE stud_entry_no=@eno AND Choice=1", conn))
            {
                cmd.Parameters.AddWithValue("@s",   newStatus);
                cmd.Parameters.AddWithValue("@eno", eno);
                cmd.ExecuteNonQuery();
            }

            UpdateApplicationStatus(conn, eno, newStatus == 3 ? "WITHDRAWN" : "REJECTED");

            if (!string.IsNullOrEmpty(reason))
                SaveReviewerNotes(conn, eno, "[REJECTED] " + reason);

            string msg = newStatus == 3
                ? "Your application has been withdrawn by admissions. Please contact admissions office for guidance."
                : "Your application has been rejected. Please review guidance in My Application or contact admissions.";
            AddApplicantNotification(conn, eno, msg, "/apply/my-application.aspx");

            WriteAuditLog(conn, eno, newStatus == 3 ? "WITHDRAWN" : "REJECTED",
                "Status set to " + (newStatus == 3 ? "WITHDRAWN" : "REJECTED") + " by " + GetCurrentUser() +
                (string.IsNullOrWhiteSpace(reason) ? "" : ". Reason: " + reason));

            string rejEmail, rejName;
            GetApplicantContact(conn, eno, out rejEmail, out rejName);
            if (!string.IsNullOrWhiteSpace(rejEmail) && rejEmail.Contains("@"))
                SendDecisionEmail(rejEmail, rejName, eno, false, reason);
        }
        Response.Write("{\"ok\":true,\"message\":\"Applicant rejected/withdrawn.\"}");
    }

    // ════════════════════════════════════════════════════════════════════════
    // REVIEWER NOTES
    // ════════════════════════════════════════════════════════════════════════
    private void HandleNote()
    {
        var data = ReadPostJson();
        string eno   = GetStr(data, "eno");
        string notes = GetStr(data, "notes");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");
        using (var conn = Open())
            SaveReviewerNotes(conn, eno, notes);
        Response.Write("{\"ok\":true,\"message\":\"Reviewer notes saved.\"}");
    }

    // ════════════════════════════════════════════════════════════════════════
    // REGISTER (convert admitted applicant → student)
    // ════════════════════════════════════════════════════════════════════════
    private void HandleRegister()
    {
        var data = ReadPostJson();
        string eno = GetStr(data, "eno");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");

        using (var conn = Open())
        {
            string newRegno = RegisterApplicant(conn, eno);
            WriteAuditLog(conn, eno, "REGISTERED", "Registered as student " + newRegno + " by " + GetCurrentUser());
            Response.Write("{\"ok\":true,\"regno\":" + JsonStr(newRegno) +
                ",\"message\":\"Student registered successfully. Registration No: " + newRegno.Replace("\"", "\\\"") + "\"}");
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    // RE-REGISTER / REPAIR
    // ════════════════════════════════════════════════════════════════════════
    private void HandleReRegister()
    {
        var data = ReadPostJson();
        string eno = GetStr(data, "eno");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");

        using (var conn = Open())
        {
            int admStatus = GetAdmStatus(conn, eno);
            if (admStatus != 1)
                throw new Exception("Applicant must be ADMITTED/REGISTERED before re-registration checks.");

            string regno = GetApplicationRegno(conn, eno);
            if (string.IsNullOrEmpty(regno) || regno == "-")
            {
                string newRegno = RegisterApplicant(conn, eno);
                Response.Write("{\"ok\":true,\"regno\":" + JsonStr(newRegno) +
                    ",\"message\":\"Student was not yet registered. Registration completed. Registration No: " + newRegno.Replace("\"", "\\\"") + "\"}");
                return;
            }

            int fixes = RepairRegisteredApplicant(conn, eno, regno);
            UpdateApplicationStatus(conn, eno, "REGISTERED");
            Response.Write("{\"ok\":true,\"regno\":" + JsonStr(regno) +
                ",\"fixed\":" + fixes +
                ",\"message\":\"Re-registration check complete. " + fixes + " issue(s) repaired.\"}");
        }
    }

    private string RegisterApplicant(MySqlConnection conn, string eno)
    {
        int admStatus = GetAdmStatus(conn, eno);
        if (admStatus != 1) throw new Exception("Applicant must be in ADMITTED status before registration.");

        string existingRegno = GetApplicationRegno(conn, eno);
        if (!string.IsNullOrEmpty(existingRegno) && existingRegno != "-")
            throw new Exception("Applicant already has registration number " + existingRegno + ".");

        string newRegno = "";
        MySqlTransaction tx = conn.BeginTransaction();
        try
        {
            using (var cmd = new MySqlCommand("SELECT acad_RegNoCreator(@eno) AS regno", conn, tx))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                object v = cmd.ExecuteScalar();
                if (v != null) newRegno = v.ToString();
            }
            if (string.IsNullOrEmpty(newRegno) || newRegno == "-")
                throw new Exception("Failed to generate registration number. Please check sequence configuration.");

            using (var cmd = new MySqlCommand(
                "UPDATE acad_applications SET stud_reg_no=@rn WHERE stud_entry_no=@eno AND (stud_reg_no IS NULL OR stud_reg_no='-' OR stud_reg_no='')", conn, tx))
            {
                cmd.Parameters.AddWithValue("@rn",  newRegno);
                cmd.Parameters.AddWithValue("@eno", eno);
                cmd.ExecuteNonQuery();
            }

            string regProg = "", regSess = "", regSpec = "";
            LoadApplicantChoice(conn, tx, eno, out regProg, out regSess, out regSpec);
            if (string.IsNullOrEmpty(regProg))
                throw new Exception("Applicant choice (programme) not found.");

            int entryYear = GetApplicantEntryYear(conn, tx, eno);
            string acadYear = entryYear + "/" + (entryYear + 1);

            InsertStudentFromApplication(conn, tx, eno, regProg, regSess, regSpec);
            FixStudentNames(conn, tx, eno);

            string currentUser = GetCurrentUser();
            using (var cmd = new MySqlCommand(@"
                INSERT IGNORE INTO acad_registration(
                    regno, acad_year, semester, regstatus, studyyear,
                    id_cardStatus, residence_status, reg_CardStatus,
                    examClearance, clearedBy, registeredBy
                ) VALUES(@eno, @acad_year, 1, 'UNREGISTERED', 1, '-', '-', '-', 'UNCLEARED', '-', @usr)", conn, tx))
            {
                cmd.Parameters.AddWithValue("@eno",       eno);
                cmd.Parameters.AddWithValue("@acad_year", acadYear);
                cmd.Parameters.AddWithValue("@usr",       currentUser);
                cmd.ExecuteNonQuery();
            }

            tx.Commit();
            RenameOrProvisionAccount(conn, newRegno, eno);
            return newRegno;
        }
        catch
        {
            try { tx.Rollback(); } catch { }
            throw;
        }
    }

    private void RenameOrProvisionAccount(MySqlConnection conn, string newUsername, string eno)
    {
        try
        {
            int entryAccId = 0;
            using (var cmd = new MySqlCommand("SELECT id FROM my_aspnet_users WHERE name=@name LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@name", eno);
                object v = cmd.ExecuteScalar();
                if (v != null && v != DBNull.Value) entryAccId = Convert.ToInt32(v);
            }
            if (entryAccId > 0)
            {
                bool regExists = false;
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM my_aspnet_users WHERE name=@name", conn))
                {
                    cmd.Parameters.AddWithValue("@name", newUsername);
                    object v = cmd.ExecuteScalar();
                    regExists = v != null && Convert.ToInt32(v) > 0;
                }
                if (!regExists)
                {
                    using (var cmd = new MySqlCommand(
                        "UPDATE my_aspnet_users SET name=@newName WHERE id=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@newName", newUsername);
                        cmd.Parameters.AddWithValue("@id",      entryAccId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            else
            {
                ProvisionStudentAccount(conn, newUsername, eno);
            }
        }
        catch { }
    }

    private int RepairRegisteredApplicant(MySqlConnection conn, string eno, string regno)
    {
        int fixes = 0;
        MySqlTransaction tx = conn.BeginTransaction();
        try
        {
            string regProg = "", regSess = "", regSpec = "";
            LoadApplicantChoice(conn, tx, eno, out regProg, out regSess, out regSpec);
            if (string.IsNullOrEmpty(regProg))
                throw new Exception("Applicant choice (programme) not found.");

            bool hasStudent = false;
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM acad_student WHERE entryno=@eno OR regno=@regno", conn, tx))
            {
                cmd.Parameters.AddWithValue("@eno",   eno);
                cmd.Parameters.AddWithValue("@regno", regno);
                hasStudent = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
            if (!hasStudent)
            {
                int inserted = InsertStudentFromApplication(conn, tx, eno, regProg, regSess, regSpec);
                if (inserted > 0) { fixes++; FixStudentNames(conn, tx, eno); }
            }

            using (var cmd = new MySqlCommand(
                "UPDATE acad_student SET regno=@regno WHERE entryno=@eno AND (regno IS NULL OR regno='' OR regno='-' OR regno<>@regno)", conn, tx))
            {
                cmd.Parameters.AddWithValue("@regno", regno);
                cmd.Parameters.AddWithValue("@eno",   eno);
                if (cmd.ExecuteNonQuery() > 0) fixes++;
            }

            if (FixStudentNames(conn, tx, eno) > 0) fixes++;

            bool hasAnyRegistration = false;
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM acad_registration WHERE regno=@eno OR regno=@regno", conn, tx))
            {
                cmd.Parameters.AddWithValue("@eno",   eno);
                cmd.Parameters.AddWithValue("@regno", regno);
                hasAnyRegistration = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
            if (!hasAnyRegistration)
            {
                int entryYear = GetApplicantEntryYear(conn, tx, eno);
                string acadYear = entryYear + "/" + (entryYear + 1);
                using (var cmd = new MySqlCommand(@"
                    INSERT IGNORE INTO acad_registration(
                        regno, acad_year, semester, regstatus, studyyear,
                        id_cardStatus, residence_status, reg_CardStatus,
                        examClearance, clearedBy, registeredBy
                    ) VALUES(@eno, @acad_year, 1, 'UNREGISTERED', 1, '-', '-', '-', 'UNCLEARED', '-', @usr)", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@eno",       eno);
                    cmd.Parameters.AddWithValue("@acad_year", acadYear);
                    cmd.Parameters.AddWithValue("@usr",       GetCurrentUser());
                    if (cmd.ExecuteNonQuery() > 0) fixes++;
                }
            }
            tx.Commit();
        }
        catch
        {
            try { tx.Rollback(); } catch { }
            throw;
        }

        bool hadPortalAccess = HasPortalMembership(conn, regno);
        ProvisionStudentAccount(conn, regno, eno, false);
        if (!hadPortalAccess && HasPortalMembership(conn, regno)) fixes++;
        return fixes;
    }

    private string GetApplicationRegno(MySqlConnection conn, string eno)
    {
        using (var cmd = new MySqlCommand(
            "SELECT COALESCE(stud_reg_no,'') FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            object v = cmd.ExecuteScalar();
            return v != null ? v.ToString().Trim() : "";
        }
    }

    private void LoadApplicantChoice(MySqlConnection conn, MySqlTransaction tx, string eno, out string regProg, out string regSess, out string regSpec)
    {
        regProg = ""; regSess = ""; regSpec = "";
        using (var cmd = new MySqlCommand(
            "SELECT prog_id, adm_session, sub_comb FROM acad_applicant_choices WHERE stud_entry_no=@eno AND Choice=1 LIMIT 1", conn, tx))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            using (var r = cmd.ExecuteReader())
            {
                if (r.Read())
                {
                    regProg = r["prog_id"]     != DBNull.Value ? r["prog_id"].ToString()     : "";
                    regSess = r["adm_session"] != DBNull.Value ? r["adm_session"].ToString() : "";
                    regSpec = r["sub_comb"]    != DBNull.Value ? r["sub_comb"].ToString()    : "";
                }
            }
        }
    }

    private int GetApplicantEntryYear(MySqlConnection conn, MySqlTransaction tx, string eno)
    {
        int entryYear = DateTime.Now.Year;
        using (var cmd = new MySqlCommand(
            "SELECT COALESCE(stud_entry_year,0) FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn, tx))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            object v = cmd.ExecuteScalar();
            if (v != null) entryYear = SafeInt(v.ToString(), DateTime.Now.Year);
        }
        if (entryYear < 1990) entryYear = DateTime.Now.Year;
        return entryYear;
    }

    private int InsertStudentFromApplication(MySqlConnection conn, MySqlTransaction tx, string eno, string regProg, string regSess, string regSpec)
    {
        using (var cmd = new MySqlCommand(@"
            INSERT IGNORE INTO acad_student(
                entryno, regno, firstname, dob, gender, nationality, religion,
                entrymethod, progid, studPhone, email, entryyear, studsesion,
                home_dist, intake, gradSystemID, othername, duration, specialisation, studcampus, new_status
            )
            SELECT stud_reg_no, stud_entry_no,
                TRIM(IF(LOCATE(' ', stud_name)>0, SUBSTRING(stud_name, LOCATE(' ', stud_name)+1), '')),
                stud_birthdate,
                IF(stud_sex='M','MALE',IF(stud_sex='F','FEMALE',stud_sex)),
                stud_nationality, stud_religion, stud_entry_method,
                @prog, stud_phone, stud_email, stud_entry_year, @sess, home_district,
                stud_intake, 1,
                TRIM(SUBSTRING_INDEX(stud_name,' ',1)),
                Acad_GetApplicantDetails(6, @prog),
                @spec, stud_campus, 'ACTIVE'
            FROM acad_applications WHERE stud_entry_no=@eno", conn, tx))
        {
            cmd.Parameters.AddWithValue("@prog", regProg);
            cmd.Parameters.AddWithValue("@sess", regSess);
            cmd.Parameters.AddWithValue("@spec", regSpec);
            cmd.Parameters.AddWithValue("@eno",  eno);
            return cmd.ExecuteNonQuery();
        }
    }

    private int FixStudentNames(MySqlConnection conn, MySqlTransaction tx, string eno)
    {
        using (var cmd = new MySqlCommand(@"
            UPDATE acad_student s
            JOIN acad_applications a ON a.stud_entry_no = s.entryno
            SET s.firstname = TRIM(IF(LOCATE(' ', a.stud_name)>0, SUBSTRING(a.stud_name, LOCATE(' ', a.stud_name)+1), '')),
                s.othername = TRIM(SUBSTRING_INDEX(a.stud_name,' ',1))
            WHERE s.entryno = @eno AND (s.firstname IS NULL OR s.firstname = '' OR s.firstname = ' ')", conn, tx))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            return cmd.ExecuteNonQuery();
        }
    }

    private bool HasPortalMembership(MySqlConnection conn, string username)
    {
        if (string.IsNullOrEmpty(username)) return false;
        using (var cmd = new MySqlCommand(@"
            SELECT COUNT(*) FROM my_aspnet_users u
            INNER JOIN my_aspnet_membership m ON m.userId = u.id
            WHERE u.name = @name", conn))
        {
            cmd.Parameters.AddWithValue("@name", username);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    // ════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ════════════════════════════════════════════════════════════════════════

    private MySqlConnection Open()
    {
        var conn = new MySqlConnection(ConnStr);
        conn.Open();
        return conn;
    }

    private int GetAdmStatus(MySqlConnection conn, string eno)
    {
        using (var cmd = new MySqlCommand(
            "SELECT adm_status FROM acad_applicant_choices WHERE stud_entry_no=@eno AND Choice=1 LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            object v = cmd.ExecuteScalar();
            if (v == null || v == DBNull.Value) throw new Exception("Applicant not found: " + eno);
            return Convert.ToInt32(v);
        }
    }

    private string GetCurrentUser()
    {
        if (Session["LoggedInUser"] != null) return Session["LoggedInUser"].ToString();
        if (Session["username"]     != null) return Session["username"].ToString();
        var identity = HttpContext.Current.User != null ? HttpContext.Current.User.Identity : null;
        return (identity != null && !string.IsNullOrEmpty(identity.Name)) ? identity.Name : "system";
    }

    private bool ColumnExists(MySqlConnection conn, string table, string column)
    {
        string key = table + "." + column;
        if (_colCache.ContainsKey(key)) return _colCache[key];
        using (var cmd = new MySqlCommand(@"
            SELECT COUNT(*) FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
        {
            cmd.Parameters.AddWithValue("@t", table);
            cmd.Parameters.AddWithValue("@c", column);
            object v = cmd.ExecuteScalar();
            bool result = v != null && v != DBNull.Value && Convert.ToInt32(v) > 0;
            _colCache[key] = result;
            return result;
        }
    }

    private void UpdateApplicationStatus(MySqlConnection conn, string eno, string status)
    {
        try
        {
            if (!ColumnExists(conn, "acad_applications", "app_status")) return;
            bool hasUpdatedAt = ColumnExists(conn, "acad_applications", "app_last_updated_at");
            string sql = hasUpdatedAt
                ? "UPDATE acad_applications SET app_status=@s, app_last_updated_at=@now WHERE stud_entry_no=@eno"
                : "UPDATE acad_applications SET app_status=@s WHERE stud_entry_no=@eno";
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@s",   status ?? "");
                cmd.Parameters.AddWithValue("@eno", eno);
                if (hasUpdatedAt) cmd.Parameters.AddWithValue("@now", DateTime.UtcNow);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private void SaveReviewerNotes(MySqlConnection conn, string eno, string notes)
    {
        try
        {
            bool hasUpdatedAt = ColumnExists(conn, "acad_applications", "app_last_updated_at");
            string sql = "UPDATE acad_applications SET app_reviewer_notes=@n";
            if (hasUpdatedAt) sql += ", app_last_updated_at=@now";
            sql += " WHERE stud_entry_no=@eno";
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@n",   notes ?? string.Empty);
                if (hasUpdatedAt) cmd.Parameters.AddWithValue("@now", DateTime.UtcNow);
                cmd.Parameters.AddWithValue("@eno", eno);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private void AddApplicantNotification(MySqlConnection conn, string eno, string message, string link)
    {
        try
        {
            int userId = ResolveApplicantUserId(conn, eno);
            if (userId <= 0) return;
            EnsureApplyNotificationsTable(conn);
            using (var cmd = new MySqlCommand(@"
                INSERT INTO apply_notifications (user_id, message, is_read, link, created_at)
                VALUES (@uid, @msg, 0, @lnk, @now)", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                cmd.Parameters.AddWithValue("@msg", message ?? "");
                cmd.Parameters.AddWithValue("@lnk", link ?? "");
                cmd.Parameters.AddWithValue("@now", DateTime.UtcNow);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private int ResolveApplicantUserId(MySqlConnection conn, string eno)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "SELECT COALESCE(applicant_user_id,0) FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                object v = cmd.ExecuteScalar();
                int id;
                if (v != null && int.TryParse(v.ToString(), out id) && id > 0) return id;
            }
        }
        catch { }

        string email = "";
        using (var cmd = new MySqlCommand(
            "SELECT COALESCE(stud_email,'') FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            object v = cmd.ExecuteScalar();
            if (v != null) email = v.ToString().Trim();
        }
        if (string.IsNullOrEmpty(email)) return 0;

        using (var cmd = new MySqlCommand(@"
            SELECT id FROM my_aspnet_users
            WHERE LOWER(TRIM(verified_email)) = LOWER(TRIM(@em))
              AND (user_type='APPLICANT' OR user_type IS NULL OR user_type='')
            ORDER BY id DESC LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@em", email);
            object v = cmd.ExecuteScalar();
            int id;
            if (v != null && int.TryParse(v.ToString(), out id) && id > 0) return id;
        }
        return 0;
    }

    private void EnsureApplyNotificationsTable(MySqlConnection conn)
    {
        using (var cmd = new MySqlCommand(@"
            CREATE TABLE IF NOT EXISTS apply_notifications (
                id INT NOT NULL AUTO_INCREMENT,
                user_id INT NOT NULL,
                message TEXT NOT NULL,
                is_read TINYINT(1) NOT NULL DEFAULT 0,
                link VARCHAR(255) NULL,
                created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (id),
                INDEX idx_apply_notifications_user (user_id),
                INDEX idx_apply_notifications_read (is_read)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", conn))
        {
            cmd.ExecuteNonQuery();
        }
    }

    private void WriteAuditLog(MySqlConnection conn, string eno, string action, string detail)
    {
        try
        {
            using (var cmd = new MySqlCommand(@"
                INSERT IGNORE INTO apply_audit_log (stud_entry_no, actor, action, detail, created_at)
                VALUES (@eno, @actor, @action, @detail, @now)", conn))
            {
                cmd.Parameters.AddWithValue("@eno",    eno);
                cmd.Parameters.AddWithValue("@actor",  GetCurrentUser());
                cmd.Parameters.AddWithValue("@action", action);
                cmd.Parameters.AddWithValue("@detail", detail ?? string.Empty);
                cmd.Parameters.AddWithValue("@now",    DateTime.UtcNow);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private static void GetApplicantContact(MySqlConnection conn, string eno, out string email, out string name)
    {
        email = string.Empty; name = string.Empty;
        try
        {
            using (var cmd = new MySqlCommand(
                "SELECT COALESCE(stud_email,''), COALESCE(stud_name,'') FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                using (var rd = cmd.ExecuteReader())
                    if (rd.Read()) { email = rd[0].ToString().Trim(); name = rd[1].ToString().Trim(); }
            }
        }
        catch { }
    }

    private void ProvisionStudentAccount(MySqlConnection conn, string username, string eno, bool resetExistingPassword = false)
    {
        if (string.IsNullOrEmpty(username)) return;
        try
        {
            string email = string.Empty, studName = string.Empty;
            using (var cmd = new MySqlCommand(
                "SELECT COALESCE(stud_email,''), COALESCE(stud_name,'') FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                using (var rd = cmd.ExecuteReader())
                    if (rd.Read()) { email = rd[0].ToString().Trim(); studName = rd[1].ToString().Trim(); }
            }
            if (string.IsNullOrEmpty(email) || !email.Contains("@"))
                email = username.Replace("/", "").Replace(" ", "").ToLower() + "@mru.ac.ug";

            DateTime now   = DateTime.UtcNow;
            int      appId = 1;
            using (var cmd = new MySqlCommand(
                "SELECT MIN(applicationId) FROM my_aspnet_users WHERE applicationId IS NOT NULL", conn))
            {
                object v = cmd.ExecuteScalar();
                if (v != null && v != DBNull.Value) { int a; if (int.TryParse(v.ToString(), out a) && a > 0) appId = a; }
            }

            int userId = 0;
            using (var cmd = new MySqlCommand(
                "SELECT id FROM my_aspnet_users WHERE name=@name LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@name", username);
                object v = cmd.ExecuteScalar();
                if (v != null && v != DBNull.Value) userId = Convert.ToInt32(v);
            }

            if (userId == 0)
            {
                using (var cmd = new MySqlCommand(@"
                    INSERT INTO my_aspnet_users
                        (applicationId, name, isAnonymous, lastActivityDate, user_verification_status, verified_email, user_type)
                    VALUES (@appId, @name, 0, @now, 1, @email, 'STUDENT')", conn))
                {
                    cmd.Parameters.AddWithValue("@appId", appId);
                    cmd.Parameters.AddWithValue("@name",  username);
                    cmd.Parameters.AddWithValue("@now",   now);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.ExecuteNonQuery();
                }
                using (var cmd = new MySqlCommand(
                    "SELECT id FROM my_aspnet_users WHERE name=@name ORDER BY id DESC LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@name", username);
                    object v = cmd.ExecuteScalar();
                    if (v == null || v == DBNull.Value) return;
                    userId = Convert.ToInt32(v);
                }
            }

            bool memExists = false;
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM my_aspnet_membership WHERE userId=@uid", conn))
            {
                cmd.Parameters.AddWithValue("@uid", userId);
                object v = cmd.ExecuteScalar();
                memExists = (v != null && Convert.ToInt32(v) > 0);
            }

            if (!memExists)
            {
                string tempPwd = GenerateTempPassword();
                string salt;
                string hashed = HashPasswordHmac(tempPwd, out salt);
                using (var cmd = new MySqlCommand(@"
                    INSERT INTO my_aspnet_membership
                        (userId, password, passwordFormat, passwordSalt, email, loweredEmail,
                         passwordQuestion, passwordAnswer, isApproved, isLockedOut, comment,
                         creationDate, lastLoginDate, lastPasswordChangedDate, lastLockoutDate,
                         failedPasswordAttemptCount, failedPasswordAttemptWindowStart,
                         failedPasswordAnswerAttemptCount, failedPasswordAnswerAttemptWindowStart)
                    VALUES
                        (@uid, @pwd, 1, @salt, @email, @emailL,
                         '', '', 1, 0, '',
                         @now, @now, @now, @now,
                         0, @now, 0, @now)", conn))
                {
                    cmd.Parameters.AddWithValue("@uid",    userId);
                    cmd.Parameters.AddWithValue("@pwd",    hashed);
                    cmd.Parameters.AddWithValue("@salt",   salt);
                    cmd.Parameters.AddWithValue("@email",  email);
                    cmd.Parameters.AddWithValue("@emailL", email.ToLower());
                    cmd.Parameters.AddWithValue("@now",    now);
                    cmd.ExecuteNonQuery();
                }
                SendWelcomeEmail(email, studName, username, tempPwd);
            }
            else if (resetExistingPassword)
            {
                string tempPwd = GenerateTempPassword();
                string salt;
                string hashed = HashPasswordHmac(tempPwd, out salt);
                using (var cmd = new MySqlCommand(@"
                    UPDATE my_aspnet_membership
                    SET password=@pwd, passwordFormat=1, passwordSalt=@salt, lastPasswordChangedDate=@now
                    WHERE userId=@uid", conn))
                {
                    cmd.Parameters.AddWithValue("@pwd",  hashed);
                    cmd.Parameters.AddWithValue("@salt", salt);
                    cmd.Parameters.AddWithValue("@uid",  userId);
                    cmd.Parameters.AddWithValue("@now",  now);
                    cmd.ExecuteNonQuery();
                }
                SendWelcomeEmail(email, studName, username, tempPwd);
            }
        }
        catch { }
    }

    private static string GenerateTempPassword()
    {
        const string chars = "abcdefghjkmnpqrstuvwxyz23456789";
        byte[] bytes = new byte[8];
        using (var rng = new RNGCryptoServiceProvider()) rng.GetBytes(bytes);
        var sb = new StringBuilder();
        foreach (byte b in bytes) sb.Append(chars[b % chars.Length]);
        return sb.ToString();
    }

    private static string HashPasswordHmac(string password, out string salt)
    {
        byte[] saltBytes = new byte[16];
        using (var rng = new RNGCryptoServiceProvider()) rng.GetBytes(saltBytes);
        salt = Convert.ToBase64String(saltBytes);
        using (var hmac = new HMACSHA256(saltBytes))
        {
            byte[] hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(password));
            return Convert.ToBase64String(hash);
        }
    }

    private static void SendDecisionEmail(string toEmail, string studName, string eno, bool admitted, string reason)
    {
        try
        {
            string host = ConfigurationManager.AppSettings["MAIL_HOST"] ?? string.Empty;
            if (string.IsNullOrWhiteSpace(host)) return;
            string portRaw  = ConfigurationManager.AppSettings["MAIL_PORT"]         ?? "587";
            string mailUser = ConfigurationManager.AppSettings["MAIL_USERNAME"]      ?? string.Empty;
            string mailPwd  = ConfigurationManager.AppSettings["MAIL_PASSWORD"]      ?? string.Empty;
            string fromAddr = ConfigurationManager.AppSettings["MAIL_FROM_ADDRESS"]  ?? mailUser;
            string fromName = ConfigurationManager.AppSettings["MAIL_FROM_NAME"]     ?? "MRU Admissions";
            string portalUrl= ConfigurationManager.AppSettings["PORTAL_BASE_URL"]    ?? "https://eportal.mru.ac.ug";
            string enc      = (ConfigurationManager.AppSettings["MAIL_ENCRYPTION"]   ?? "ssl").Trim().ToLowerInvariant();
            int port = 587; int.TryParse(portRaw, out port);

            string greeting = string.IsNullOrWhiteSpace(studName) ? "Dear Applicant" : "Dear " + studName;
            string subject, body;
            if (admitted)
            {
                subject = "MRU Admissions Decision — Congratulations (Ref: " + eno + ")";
                body = greeting + ",<br><br>We are pleased to inform you that your application to Muteesa Royal University has been <b>ADMITTED</b>.<br><br>" +
                       "Your application reference: <b>" + HttpUtility.HtmlEncode(eno) + "</b><br><br>" +
                       "Please log in to the student portal at <a href='" + portalUrl + "'>" + portalUrl + "</a> to view further instructions.<br><br>" +
                       "Congratulations and welcome to MRU!<br><br>Regards,<br>MRU Admissions Office";
            }
            else
            {
                subject = "MRU Admissions Decision (Ref: " + eno + ")";
                body = greeting + ",<br><br>We regret to inform you that your application (Ref: <b>" + HttpUtility.HtmlEncode(eno) + "</b>) has been <b>unsuccessful</b> at this time.<br><br>";
                if (!string.IsNullOrWhiteSpace(reason))
                    body += "Reason: " + HttpUtility.HtmlEncode(reason) + "<br><br>";
                body += "You may contact our admissions office for further guidance or re-apply in a future intake.<br><br>Regards,<br>MRU Admissions Office";
            }

            using (var msg = new MailMessage())
            {
                msg.From = new MailAddress(fromAddr, fromName);
                msg.To.Add(new MailAddress(toEmail));
                msg.Subject = subject; msg.Body = body; msg.IsBodyHtml = true;
                using (var smtp = new SmtpClient(host, port))
                {
                    smtp.Credentials = new NetworkCredential(mailUser, mailPwd);
                    smtp.EnableSsl = enc == "ssl" || enc == "tls";
                    smtp.Send(msg);
                }
            }
        }
        catch { }
    }

    private static void SendWelcomeEmail(string toEmail, string studName, string username, string tempPassword)
    {
        try
        {
            string host = ConfigurationManager.AppSettings["MAIL_HOST"] ?? string.Empty;
            if (string.IsNullOrWhiteSpace(host)) return;
            string portRaw  = ConfigurationManager.AppSettings["MAIL_PORT"]        ?? "587";
            string mailUser = ConfigurationManager.AppSettings["MAIL_USERNAME"]     ?? string.Empty;
            string mailPwd  = ConfigurationManager.AppSettings["MAIL_PASSWORD"]     ?? string.Empty;
            string fromAddr = ConfigurationManager.AppSettings["MAIL_FROM_ADDRESS"] ?? mailUser;
            string fromName = ConfigurationManager.AppSettings["MAIL_FROM_NAME"]    ?? "MRU Admissions";
            string portalUrl= ConfigurationManager.AppSettings["PORTAL_BASE_URL"]   ?? "https://eportal.mru.ac.ug";
            string enc      = (ConfigurationManager.AppSettings["MAIL_ENCRYPTION"]  ?? "ssl").Trim().ToLowerInvariant();
            int port = 587; int.TryParse(portRaw, out port);

            string greeting = string.IsNullOrWhiteSpace(studName) ? "Dear Student" : "Dear " + studName;
            string body = greeting + ",<br><br>Congratulations! Your application to Muteesa Royal University has been processed.<br><br>" +
                "<b>Username:</b> " + HttpUtility.HtmlEncode(username) + "<br>" +
                "<b>Temporary Password:</b> " + HttpUtility.HtmlEncode(tempPassword) + "<br><br>" +
                "Please login at <a href='" + portalUrl + "'>" + portalUrl + "</a> and change your password immediately.<br><br>" +
                "Regards,<br>MRU Admissions Office";

            using (var msg = new MailMessage())
            {
                msg.From = new MailAddress(fromAddr, fromName);
                msg.To.Add(new MailAddress(toEmail));
                msg.Subject = "MRU Student Portal — Your Login Details";
                msg.Body = body; msg.IsBodyHtml = true;
                using (var smtp = new SmtpClient(host, port))
                {
                    smtp.Credentials = new NetworkCredential(mailUser, mailPwd);
                    smtp.EnableSsl = enc == "ssl" || enc == "tls";
                    smtp.Send(msg);
                }
            }
        }
        catch { }
    }

    private Dictionary<string, object> ReadPostJson()
    {
        string body = "";
        using (var sr = new System.IO.StreamReader(Request.InputStream))
            body = sr.ReadToEnd();
        if (string.IsNullOrWhiteSpace(body)) return new Dictionary<string, object>();
        return new JavaScriptSerializer()
            .Deserialize<Dictionary<string, object>>(body) ?? new Dictionary<string, object>();
    }

    private static string GetStr(Dictionary<string, object> d, string key)
    {
        return d.ContainsKey(key) ? Convert.ToString(d[key] ?? "").Trim() : "";
    }

    private static int SafeInt(object v, int def = 0)
    {
        int n;
        return int.TryParse(Convert.ToString(v ?? ""), out n) ? n : def;
    }

    private static long SafeLong(object v, long def = 0)
    {
        long n;
        return long.TryParse(Convert.ToString(v ?? ""), out n) ? n : def;
    }

    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s
            .Replace("\\", "\\\\").Replace("\"", "\\\"")
            .Replace("\r", "\\r").Replace("\n", "\\n").Replace("\t", "\\t") + "\"";
    }

    // ── ASPX expression helpers (protected so <%= %> can call them) ──────
    protected static string HE(string s)      { return HttpUtility.HtmlEncode(s ?? ""); }
    private   static string HtmlAE(string s)  { return HttpUtility.HtmlAttributeEncode(s ?? ""); }
    private   static string JsStr(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("'", "\\'");
    }
    protected static string Sel(string actual, string check)
    {
        return string.Equals(actual, check, StringComparison.OrdinalIgnoreCase)
               ? " selected=\"selected\"" : "";
    }
}
