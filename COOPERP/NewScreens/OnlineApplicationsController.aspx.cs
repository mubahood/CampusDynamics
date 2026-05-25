using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_OnlineApplicationsController : System.Web.UI.Page
{
    // ── Filter state (set in Page_Load, used by ASPX <%= %> expressions) ────
    protected string FilterQ       { get; private set; }
    protected string FilterStatus  { get; private set; }
    protected string FilterProg    { get; private set; }
    protected string FilterYear    { get; private set; }
    protected string FilterSession { get; private set; }
    protected int    FilterPage    { get; private set; }
    protected int    FilterSize    { get; private set; }

    // ColumnExists cache — avoids repeated information_schema queries per request
    private readonly Dictionary<string, bool> _colCache =
        new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);

    // Always connects to campus_dynamics_portal — portal application data lives there.
    // Connection string names differ between environments, so we scan by actual database
    // name rather than relying on string name conventions.
    private string ConnStr
    {
        get
        {
            // acad_applications is written by the portal into campus_dynamics (the main EMIS DB).
            // In production the portal uses campus_dynamics_portalConnectionString → campus_dynamics,
            // so we scan by actual database name to stay environment-agnostic.

            // Pass 1: find any MySQL connection string that already targets campus_dynamics
            foreach (System.Configuration.ConnectionStringSettings cs in ConfigurationManager.ConnectionStrings)
            {
                if (string.IsNullOrEmpty(cs.ConnectionString)) continue;
                if (cs.ConnectionString.IndexOf("XpoProvider", StringComparison.OrdinalIgnoreCase) >= 0) continue;
                try
                {
                    var b = new MySqlConnectionStringBuilder(cs.ConnectionString);
                    if (string.Equals(b.Database, "campus_dynamics", StringComparison.OrdinalIgnoreCase))
                        return cs.ConnectionString;
                }
                catch { }
            }

            // Pass 2: borrow credentials from any known string and override the database
            string[] candidates = { "campus_dynamics_portalConnectionString", "vacConnectionString",
                                     "schoolMISConnectionString", "LocalMySqlServer" };
            foreach (string name in candidates)
            {
                var cs = ConfigurationManager.ConnectionStrings[name];
                if (cs == null || string.IsNullOrEmpty(cs.ConnectionString)) continue;
                if (cs.ConnectionString.IndexOf("XpoProvider", StringComparison.OrdinalIgnoreCase) >= 0) continue;
                try
                {
                    var b = new MySqlConnectionStringBuilder(cs.ConnectionString);
                    b.Database = "campus_dynamics";
                    return b.ConnectionString;
                }
                catch { }
            }

            return string.Empty;
        }
    }

    // True when user is authenticated via Forms Auth cookie OR has a live session variable
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
            // AJAX branch — detail view and actions only
            Response.Clear();
            Response.ContentType = "application/json";
            Response.TrySkipIisCustomErrors = true; // ensure JSON reaches the client, not IIS HTML error page

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
                    case "detail": HandleDetail(); break;
                    case "review": HandleReview(); break;
                    case "admit":  HandleAdmit();  break;
                    case "reject": HandleReject(); break;
                    case "note":   HandleNote();   break;
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

        // ── Normal server-side page render ───────────────────────────────
        if (!IsAuthenticatedStaff())
        {
            Response.Redirect(ResolveUrl("~/Default.aspx"));
            return;
        }

        FilterQ       = (Request.QueryString["q"]       ?? "").Trim();
        FilterStatus  = (Request.QueryString["status"]  ?? "").Trim().ToUpperInvariant();
        FilterProg    = (Request.QueryString["prog"]    ?? "").Trim();
        FilterYear    = (Request.QueryString["year"]    ?? "").Trim();
        FilterSession = (Request.QueryString["session"] ?? "").Trim().ToUpperInvariant();
        FilterPage    = Math.Max(1, SafeInt(Request.QueryString["page"], 1));
        FilterSize    = Math.Min(500, Math.Max(10, SafeInt(Request.QueryString["size"], 50)));

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
        long total = 0, draft = 0, submitted = 0, review = 0, admitted = 0, rejected = 0;
        try
        {
            using (var conn = Open())
            {
                if (ColumnExists(conn, "acad_applications", "app_status"))
                {
                    bool hasUserId = ColumnExists(conn, "acad_applications", "applicant_user_id");
                    string onlineFilter = hasUserId
                        ? "WHERE applicant_user_id IS NOT NULL"
                        : "WHERE app_status IS NOT NULL"; // fallback: at least has a status (portal rows)
                    string sql = @"
                        SELECT
                            COUNT(*) AS total,
                            SUM(CASE WHEN IFNULL(app_status,'DRAFT')='DRAFT'       THEN 1 ELSE 0 END) AS draft,
                            SUM(CASE WHEN app_status='SUBMITTED'                    THEN 1 ELSE 0 END) AS submitted,
                            SUM(CASE WHEN app_status='UNDER_REVIEW'                 THEN 1 ELSE 0 END) AS review,
                            SUM(CASE WHEN app_status='ADMITTED'                     THEN 1 ELSE 0 END) AS admitted,
                            SUM(CASE WHEN app_status IN('REJECTED','WITHDRAWN')     THEN 1 ELSE 0 END) AS rejected
                        FROM acad_applications
                        " + onlineFilter;
                    using (var cmd = new MySqlCommand(sql, conn))
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            total     = SafeLong(r["total"]);
                            draft     = SafeLong(r["draft"]);
                            submitted = SafeLong(r["submitted"]);
                            review    = SafeLong(r["review"]);
                            admitted  = SafeLong(r["admitted"]);
                            rejected  = SafeLong(r["rejected"]);
                        }
                    }
                }
            }
        }
        catch { /* show zeros on DB error */ }

        var sb = new StringBuilder();
        sb.Append("<div class=\"oa-stats\">");
        sb.AppendFormat("<div class=\"oa-stat oa-stat--total\"><div class=\"oa-stat__label\">Total</div><div class=\"oa-stat__value\">{0:N0}</div></div>", total);
        sb.AppendFormat("<div class=\"oa-stat oa-stat--draft\"><div class=\"oa-stat__label\">Draft</div><div class=\"oa-stat__value\">{0:N0}</div></div>", draft);
        sb.AppendFormat("<div class=\"oa-stat oa-stat--submitted\"><div class=\"oa-stat__label\">Submitted</div><div class=\"oa-stat__value\">{0:N0}</div></div>", submitted);
        sb.AppendFormat("<div class=\"oa-stat oa-stat--review\"><div class=\"oa-stat__label\">Under Review</div><div class=\"oa-stat__value\">{0:N0}</div></div>", review);
        sb.AppendFormat("<div class=\"oa-stat oa-stat--admitted\"><div class=\"oa-stat__label\">Admitted</div><div class=\"oa-stat__value\">{0:N0}</div></div>", admitted);
        sb.AppendFormat("<div class=\"oa-stat oa-stat--rejected\"><div class=\"oa-stat__label\">Rejected / Withdrawn</div><div class=\"oa-stat__value\">{0:N0}</div></div>", rejected);
        sb.Append("</div>");
        litStats.Text = sb.ToString();
    }

    // ════════════════════════════════════════════════════════════════════════
    // SERVER-SIDE RENDER — PROGRAMME DROPDOWN OPTIONS
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
    // SERVER-SIDE RENDER — YEAR DROPDOWN OPTIONS
    // ════════════════════════════════════════════════════════════════════════
    private void LoadYearOptions()
    {
        var sb  = new StringBuilder();
        int now = DateTime.Now.Year;
        for (int y = now; y >= now - 10; y--)
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
        var sbRows  = new StringBuilder();
        long total  = 0;
        int  offset = (FilterPage - 1) * FilterSize;

        // Build WHERE clause from filters
        var where = new List<string>();
        var parms = new Dictionary<string, object>();

        if (!string.IsNullOrEmpty(FilterQ))
        {
            where.Add("(a.stud_name LIKE @q OR a.stud_entry_no LIKE @q OR a.stud_email LIKE @q)");
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
            case "DRAFT":        where.Add("IFNULL(a.app_status,'DRAFT')='DRAFT'"); break;
            case "SUBMITTED":    where.Add("a.app_status='SUBMITTED'");             break;
            case "UNDER_REVIEW": where.Add("a.app_status='UNDER_REVIEW'");          break;
            case "ADMITTED":     where.Add("a.app_status='ADMITTED'");              break;
            case "REJECTED":     where.Add("a.app_status='REJECTED'");              break;
            case "WITHDRAWN":    where.Add("a.app_status='WITHDRAWN'");             break;
        }
        try
        {
            using (var conn = Open())
            {
                bool hasAppStatus   = ColumnExists(conn, "acad_applications", "app_status");
                bool hasSubmittedAt = ColumnExists(conn, "acad_applications", "app_submitted_at");
                bool hasUserId      = ColumnExists(conn, "acad_applications", "applicant_user_id");

                if (!hasAppStatus)
                {
                    sbRows.Append("<tr><td colspan=\"9\" class=\"oa-empty\">The portal application schema is not yet initialised. Applications will appear here once students begin applying online.</td></tr>");
                    litTableRows.Text = sbRows.ToString();
                    litCount.Text     = "0 records";
                    litPager.Text     = "";
                    return;
                }

                // Always restrict to online portal applications only
                if (hasUserId)
                    where.Insert(0, "a.applicant_user_id IS NOT NULL");
                else
                    where.Insert(0, "a.app_status IS NOT NULL");

                string wClause2 = "WHERE " + string.Join(" AND ", where.ToArray());

                string subCol = hasSubmittedAt ? "a.app_submitted_at" : "NULL";

                string countSql = @"
                    SELECT COUNT(*)
                    FROM acad_applications a
                    LEFT JOIN acad_applicant_choices c ON c.stud_entry_no = a.stud_entry_no AND c.Choice = 1
                    LEFT JOIN acad_programme p ON p.progcode = c.prog_id
                    " + wClause2;

                string listSql = @"
                    SELECT
                        a.stud_entry_no AS eno,
                        TRIM(COALESCE(a.stud_name,
                             CONCAT(COALESCE(a.stud_surname,''),' ',COALESCE(a.stud_other_names,'')))) AS name,
                        COALESCE(p.progname, c.prog_id, '') AS programme,
                        COALESCE(c.adm_session, '')         AS session,
                        COALESCE(a.stud_entry_year, '')     AS year,
                        IFNULL(a.app_status,'DRAFT')        AS status,
                        " + subCol + @" AS submitted_at
                    FROM acad_applications a
                    LEFT JOIN acad_applicant_choices c ON c.stud_entry_no = a.stud_entry_no AND c.Choice = 1
                    LEFT JOIN acad_programme p ON p.progcode = c.prog_id
                    " + wClause2 + @"
                    ORDER BY a.stud_entry_no DESC
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
                            string prog     = r["programme"].ToString();
                            string sess     = r["session"].ToString();
                            string yr       = r["year"].ToString();
                            string status   = r["status"].ToString();

                            string submAt = "";
                            object saVal  = r["submitted_at"];
                            DateTime saDate;
                            if (saVal != null && saVal != DBNull.Value &&
                                DateTime.TryParse(saVal.ToString(), out saDate))
                                submAt = saDate.ToString("dd MMM yyyy");

                            sbRows.Append("<tr>");
                            sbRows.AppendFormat("<td style=\"color:#bbb;font-size:10px;text-align:center;\">{0}</td>", rowNum);
                            sbRows.AppendFormat("<td><span class=\"oa-eno\">{0}</span></td>", HE(eno));
                            sbRows.AppendFormat("<td><span class=\"oa-name\">{0}</span></td>", HE(name));
                            sbRows.AppendFormat("<td style=\"max-width:180px;white-space:normal;font-size:11px;\">{0}</td>", HE(prog));
                            sbRows.AppendFormat("<td>{0}</td>", HE(sess));
                            sbRows.AppendFormat("<td>{0}</td>", HE(yr));
                            sbRows.AppendFormat("<td>{0}</td>", StatusBadgeHtml(status));
                            sbRows.AppendFormat("<td style=\"color:#888;font-size:10px;\">{0}</td>",
                                submAt.Length > 0 ? HE(submAt) : "&#8212;");

                            sbRows.Append("<td><div class=\"oa-actions-cell\">");
                            sbRows.AppendFormat(
                                "<button type=\"button\" class=\"oa-btn oa-btn--ghost oa-btn--sm\" onclick=\"openDetail('{0}')\">View</button>",
                                JsStr(eno));
                            if (status == "SUBMITTED")
                                sbRows.AppendFormat(
                                    "<button type=\"button\" class=\"oa-btn oa-btn--amber oa-btn--sm\" onclick=\"moveToReview('{0}','{1}')\">Review</button>",
                                    JsStr(eno), JsStr(name));
                            if (status == "SUBMITTED" || status == "UNDER_REVIEW")
                            {
                                sbRows.AppendFormat(
                                    "<button type=\"button\" class=\"oa-btn oa-btn--amber oa-btn--sm\" onclick=\"admitOne('{0}','{1}')\">Admit</button>",
                                    JsStr(eno), JsStr(name));
                                sbRows.AppendFormat(
                                    "<button type=\"button\" class=\"oa-btn oa-btn--danger oa-btn--sm\" onclick=\"rejectOne('{0}','{1}')\">Reject</button>",
                                    JsStr(eno), JsStr(name));
                            }
                            sbRows.Append("</div></td></tr>");
                            rowNum++;
                        }
                    }

                    if (!hasRows)
                        sbRows.Append("<tr><td colspan=\"9\" class=\"oa-empty\">No applications match the selected filters.</td></tr>");
                }
            }
        }
        catch (Exception ex)
        {
            sbRows.Append("<tr><td colspan=\"9\" class=\"oa-empty\" style=\"color:#c62828;\">Error loading data: " + HE(ex.Message) + "</td></tr>");
        }

        litTableRows.Text = sbRows.ToString();
        litCount.Text = string.Format("{0:N0} record{1}", total, total == 1 ? "" : "s");

        // ── Pager ────────────────────────────────────────────────────────
        int  pages = Math.Max(1, (int)Math.Ceiling((double)total / FilterSize));
        long from  = total > 0 ? (long)offset + 1 : 0;
        long to    = Math.Min(total, (long)offset + FilterSize);

        var sbPager = new StringBuilder();
        sbPager.Append("<div class=\"oa-pager\">");
        if (total > 0)
            sbPager.AppendFormat("<span>Showing {0:N0}&#8211;{1:N0} of {2:N0} record{3}</span>",
                from, to, total, total == 1 ? "" : "s");
        else
            sbPager.Append("<span>0 records</span>");

        sbPager.Append("<div class=\"oa-pager__nav\">");

        if (FilterPage > 1)
            sbPager.AppendFormat("<a href=\"{0}\" class=\"oa-pager__btn\">&larr; Prev</a>",
                HtmlAE(PageUrl(FilterPage - 1)));
        else
            sbPager.Append("<span class=\"oa-pager__btn\" style=\"opacity:.4;cursor:default;\">&larr; Prev</span>");

        sbPager.AppendFormat(
            "<span style=\"padding:4px 10px;font-size:11px;color:#555;\">Page {0} of {1}</span>",
            FilterPage, pages);

        if (FilterPage < pages)
            sbPager.AppendFormat("<a href=\"{0}\" class=\"oa-pager__btn\">Next &rarr;</a>",
                HtmlAE(PageUrl(FilterPage + 1)));
        else
            sbPager.Append("<span class=\"oa-pager__btn\" style=\"opacity:.4;cursor:default;\">Next &rarr;</span>");

        sbPager.Append("</div></div>");
        litPager.Text = sbPager.ToString();
    }

    // Builds a page URL preserving all active filters
    private string PageUrl(int page)
    {
        var parts = new List<string>();
        if (!string.IsNullOrEmpty(FilterQ))       parts.Add("q="       + Uri.EscapeDataString(FilterQ));
        if (!string.IsNullOrEmpty(FilterStatus))  parts.Add("status="  + Uri.EscapeDataString(FilterStatus));
        if (!string.IsNullOrEmpty(FilterProg))    parts.Add("prog="    + Uri.EscapeDataString(FilterProg));
        if (!string.IsNullOrEmpty(FilterYear))    parts.Add("year="    + Uri.EscapeDataString(FilterYear));
        if (!string.IsNullOrEmpty(FilterSession)) parts.Add("session=" + Uri.EscapeDataString(FilterSession));
        if (FilterSize != 50) parts.Add("size=" + FilterSize);
        if (page > 1) parts.Add("page=" + page);
        return "OnlineApplicationsController.aspx" +
               (parts.Count > 0 ? "?" + string.Join("&", parts.ToArray()) : "");
    }

    private static string StatusBadgeHtml(string s)
    {
        string cls, label;
        switch (s)
        {
            case "SUBMITTED":    cls = "oa-badge--submitted";    label = "Submitted";    break;
            case "UNDER_REVIEW": cls = "oa-badge--under_review"; label = "Under Review"; break;
            case "ADMITTED":     cls = "oa-badge--admitted";     label = "Admitted";     break;
            case "REJECTED":     cls = "oa-badge--rejected";     label = "Rejected";     break;
            case "WITHDRAWN":    cls = "oa-badge--withdrawn";    label = "Withdrawn";    break;
            default:             cls = "oa-badge--draft";        label = "Draft";        break;
        }
        return "<span class=\"oa-badge " + cls + "\">" + HE(label) + "</span>";
    }

    // ════════════════════════════════════════════════════════════════════════
    // AJAX — DETAIL
    // ════════════════════════════════════════════════════════════════════════
    private void HandleDetail()
    {
        string eno = (Request.QueryString["eno"] ?? "").Trim();
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");

        using (var conn = Open())
        {
            bool hasSubmittedAt   = ColumnExists(conn, "acad_applications", "app_submitted_at");
            bool hasUpdatedAt     = ColumnExists(conn, "acad_applications", "app_last_updated_at");
            bool hasAppStatus     = ColumnExists(conn, "acad_applications", "app_status");
            bool hasReviewerNotes = ColumnExists(conn, "acad_applications", "app_reviewer_notes");
            bool hasSurname       = ColumnExists(conn, "acad_applications", "stud_surname");
            bool hasNatId         = ColumnExists(conn, "acad_applications", "stud_id_number");
            bool hasEmerg         = ColumnExists(conn, "acad_applications", "emergency_contact_name");

            // Education columns — all optional; portal stores year in stud_pob, agg in stud_district, etc.
            bool hasOlSchool  = ColumnExists(conn, "acad_applications", "olevel_school");
            bool hasOlIndex   = ColumnExists(conn, "acad_applications", "olevel_index");
            bool hasOlYear    = ColumnExists(conn, "acad_applications", "olevel_year");
            bool hasOlYearFb  = !hasOlYear  && ColumnExists(conn, "acad_applications", "stud_pob");
            bool hasOlAgg     = ColumnExists(conn, "acad_applications", "olevel_agg");
            bool hasOlAggFb   = !hasOlAgg   && ColumnExists(conn, "acad_applications", "stud_district");
            bool hasAlSchool  = ColumnExists(conn, "acad_applications", "alevel_school");
            bool hasAlIndex   = ColumnExists(conn, "acad_applications", "alevel_index");
            bool hasAlYear    = ColumnExists(conn, "acad_applications", "alevel_year");
            bool hasAlPts     = ColumnExists(conn, "acad_applications", "alevel_points");
            bool hasAlPtsFb   = !hasAlPts   && ColumnExists(conn, "acad_applications", "stud_ward");
            bool hasOtherInst = ColumnExists(conn, "acad_applications", "other_institution");
            bool hasOtherInstFb = !hasOtherInst && ColumnExists(conn, "acad_applications", "stud_prevcampus");
            bool hasOtherQual = ColumnExists(conn, "acad_applications", "other_qualification");
            bool hasOtherQualFb = !hasOtherQual && ColumnExists(conn, "acad_applications", "stud_lg");
            bool hasOtherYear = ColumnExists(conn, "acad_applications", "other_year");
            bool hasOtherYearFb = !hasOtherYear && ColumnExists(conn, "acad_applications", "stud_village");
            bool hasOtherGrade = ColumnExists(conn, "acad_applications", "other_grade");
            bool hasOtherGradeFb = !hasOtherGrade && ColumnExists(conn, "acad_applications", "stud_county");

            string olSchoolX = hasOlSchool  ? "COALESCE(a.olevel_school,'')" : "''";
            string olIndexX  = hasOlIndex   ? "COALESCE(a.olevel_index,'')"  : "''";
            string olYearX   = hasOlYear    ? "COALESCE(a.olevel_year,'')"   : (hasOlYearFb  ? "COALESCE(a.stud_pob,'')"       : "''");
            string olAggX    = hasOlAgg     ? "COALESCE(a.olevel_agg,'')"    : (hasOlAggFb   ? "COALESCE(a.stud_district,'')"  : "''");
            string alSchoolX = hasAlSchool  ? "COALESCE(a.alevel_school,'')" : "''";
            string alIndexX  = hasAlIndex   ? "COALESCE(a.alevel_index,'')"  : "''";
            string alYearX   = hasAlYear    ? "COALESCE(a.alevel_year,'')"   : "''";
            string alPtsX    = hasAlPts     ? "COALESCE(a.alevel_points,'')" : (hasAlPtsFb   ? "COALESCE(a.stud_ward,'')"      : "''");
            string otInstX   = hasOtherInst ? "COALESCE(a.other_institution,'')" : (hasOtherInstFb  ? "COALESCE(a.stud_prevcampus,'')" : "''");
            string otQualX   = hasOtherQual ? "COALESCE(a.other_qualification,'')" : (hasOtherQualFb ? "COALESCE(a.stud_lg,'')"         : "''");
            string otYearX   = hasOtherYear ? "COALESCE(a.other_year,'')"    : (hasOtherYearFb  ? "COALESCE(a.stud_village,'')"  : "''");
            string otGradeX  = hasOtherGrade ? "COALESCE(a.other_grade,'')"  : (hasOtherGradeFb ? "COALESCE(a.stud_county,'')"   : "''");


            string nameExpr = hasSurname
                ? "TRIM(CONCAT(COALESCE(a.stud_surname,''),' ',COALESCE(a.stud_other_names,'')))"
                : "COALESCE(a.stud_name,'')";

            string sql = @"
                SELECT
                    a.stud_entry_no AS eno,
                    " + nameExpr + @" AS full_name,
                    COALESCE(a.stud_email,'')  AS email,
                    COALESCE(a.stud_phone,'')  AS phone,
                    COALESCE(DATE_FORMAT(a.stud_birthdate,'%d/%m/%Y'),'') AS dob,
                    COALESCE(a.stud_sex,'')         AS gender,
                    COALESCE(a.stud_nationality,'') AS nationality,
                    COALESCE(a.stud_religion,'')    AS religion,
                    COALESCE(a.stud_mar_stat,'')    AS marital,
                    COALESCE(a.physicalDisability,'') AS disability,
                    COALESCE(a.stud_phy_address,'') AS address,
                    " + olSchoolX + @"               AS olevel_school,
                    " + olIndexX  + @"               AS olevel_index,
                    " + olYearX   + @"               AS olevel_year,
                    " + olAggX    + @"               AS olevel_agg,
                    " + alSchoolX + @"               AS alevel_school,
                    " + alIndexX  + @"               AS alevel_index,
                    " + alYearX   + @"               AS alevel_year,
                    " + alPtsX    + @"               AS alevel_points,
                    " + otInstX   + @"               AS other_inst,
                    " + otQualX   + @"               AS other_qual,
                    " + otYearX   + @"               AS other_year,
                    " + otGradeX  + @"               AS other_grade,
                    COALESCE(a.stud_sponsor,'')     AS sponsor,
                    COALESCE(a.stud_campus,'')      AS campus,
                    COALESCE(a.stud_intake,'')      AS intake,
                    COALESCE(a.stud_entry_year,'')  AS entry_year,
                    COALESCE(p.progname, c.prog_id,'') AS programme,
                    COALESCE(c.adm_session,'')      AS session,
                    " + (hasAppStatus     ? "IFNULL(a.app_status,'DRAFT')"         : "'DRAFT'") + @" AS app_status,
                    " + (hasSubmittedAt   ? "a.app_submitted_at"                    : "NULL")    + @" AS submitted_at,
                    " + (hasUpdatedAt     ? "a.app_last_updated_at"                 : "NULL")    + @" AS updated_at,
                    " + (hasReviewerNotes ? "COALESCE(a.app_reviewer_notes,'')"     : "''")      + @" AS reviewer_notes,
                    " + (hasNatId        ? "COALESCE(a.stud_id_number,'')"          : "''")      + @" AS natid,
                    " + (hasEmerg ? "COALESCE(a.emergency_contact_name,'')"  : "''") + @" AS emerg_name,
                    " + (hasEmerg ? "COALESCE(a.emergency_contact_rel,'')"   : "''") + @" AS emerg_rel,
                    " + (hasEmerg ? "COALESCE(a.emergency_contact_phone,'')" : "''") + @" AS emerg_phone
                FROM acad_applications a
                LEFT JOIN acad_applicant_choices c ON c.stud_entry_no = a.stud_entry_no AND c.Choice = 1
                LEFT JOIN acad_programme p ON p.progcode = c.prog_id
                WHERE a.stud_entry_no = @eno
                LIMIT 1";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) throw new Exception("Application not found: " + eno);

                    var sb = new StringBuilder("{\"ok\":true,");
                    sb.Append("\"eno\":"           + JsonStr(r["eno"].ToString())              + ",");
                    sb.Append("\"name\":"          + JsonStr(r["full_name"].ToString().Trim()) + ",");
                    sb.Append("\"email\":"         + JsonStr(r["email"].ToString())            + ",");
                    sb.Append("\"phone\":"         + JsonStr(r["phone"].ToString())            + ",");
                    sb.Append("\"dob\":"           + JsonStr(r["dob"].ToString())              + ",");
                    sb.Append("\"gender\":"        + JsonStr(r["gender"].ToString())           + ",");
                    sb.Append("\"nationality\":"   + JsonStr(r["nationality"].ToString())      + ",");
                    sb.Append("\"natid\":"         + JsonStr(r["natid"].ToString())            + ",");
                    sb.Append("\"religion\":"      + JsonStr(r["religion"].ToString())         + ",");
                    sb.Append("\"marital\":"       + JsonStr(r["marital"].ToString())          + ",");
                    sb.Append("\"disability\":"    + JsonStr(r["disability"].ToString())       + ",");
                    sb.Append("\"address\":"       + JsonStr(r["address"].ToString())          + ",");
                    sb.Append("\"olevel_school\":"  + JsonStr(r["olevel_school"].ToString())   + ",");
                    sb.Append("\"olevel_index\":"   + JsonStr(r["olevel_index"].ToString())    + ",");
                    sb.Append("\"olevel_year\":"    + JsonStr(r["olevel_year"].ToString())     + ",");
                    sb.Append("\"olevel_agg\":"     + JsonStr(r["olevel_agg"].ToString())      + ",");
                    sb.Append("\"alevel_school\":"  + JsonStr(r["alevel_school"].ToString())   + ",");
                    sb.Append("\"alevel_index\":"   + JsonStr(r["alevel_index"].ToString())    + ",");
                    sb.Append("\"alevel_year\":"    + JsonStr(r["alevel_year"].ToString())     + ",");
                    sb.Append("\"alevel_points\":"  + JsonStr(r["alevel_points"].ToString())   + ",");
                    sb.Append("\"other_inst\":"    + JsonStr(r["other_inst"].ToString())       + ",");
                    sb.Append("\"other_qual\":"    + JsonStr(r["other_qual"].ToString())       + ",");
                    sb.Append("\"other_year\":"    + JsonStr(r["other_year"].ToString())       + ",");
                    sb.Append("\"other_grade\":"   + JsonStr(r["other_grade"].ToString())      + ",");
                    sb.Append("\"programme\":"     + JsonStr(r["programme"].ToString())        + ",");
                    sb.Append("\"session\":"       + JsonStr(r["session"].ToString())          + ",");
                    sb.Append("\"campus\":"        + JsonStr(r["campus"].ToString())           + ",");
                    sb.Append("\"intake\":"        + JsonStr(r["intake"].ToString())           + ",");
                    sb.Append("\"sponsor\":"       + JsonStr(r["sponsor"].ToString())          + ",");
                    sb.Append("\"entry_year\":"    + JsonStr(r["entry_year"].ToString())       + ",");
                    sb.Append("\"emerg_name\":"    + JsonStr(r["emerg_name"].ToString())       + ",");
                    sb.Append("\"emerg_rel\":"     + JsonStr(r["emerg_rel"].ToString())        + ",");
                    sb.Append("\"emerg_phone\":"   + JsonStr(r["emerg_phone"].ToString())      + ",");
                    sb.Append("\"status\":"        + JsonStr(r["app_status"].ToString())       + ",");
                    sb.Append("\"reviewer_notes\":" + JsonStr(r["reviewer_notes"].ToString())  + ",");
                    sb.Append("\"submitted_at\":"  + JsonStr(FormatDate(r["submitted_at"]))    + ",");
                    sb.Append("\"updated_at\":"    + JsonStr(FormatDate(r["updated_at"])));
                    sb.Append(",\"docs\":");
                    sb.Append(GetDocsJson(conn, eno));
                    sb.Append("}");
                    Response.Write(sb.ToString());
                }
            }
        }
    }

    private string GetDocsJson(MySqlConnection conn, string eno)
    {
        var sb = new StringBuilder("[");
        try
        {
            if (!TableExists(conn, "apply_documents")) return "[]";
            using (var cmd = new MySqlCommand(
                "SELECT doc_label, original_filename FROM apply_documents WHERE stud_entry_no=@eno ORDER BY id",
                conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                using (var r = cmd.ExecuteReader())
                {
                    bool first = true;
                    while (r.Read())
                    {
                        if (!first) sb.Append(",");
                        first = false;
                        sb.AppendFormat("{{\"label\":{0},\"filename\":{1}}}",
                            JsonStr(r["doc_label"].ToString()),
                            JsonStr(r["original_filename"].ToString()));
                    }
                }
            }
        }
        catch { }
        sb.Append("]");
        return sb.ToString();
    }

    // ════════════════════════════════════════════════════════════════════════
    // AJAX — REVIEW / ADMIT / REJECT / NOTE
    // ════════════════════════════════════════════════════════════════════════
    private void HandleReview()
    {
        var data = ReadPostJson();
        string eno = GetStr(data, "eno");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");
        using (var conn = Open())
        {
            if (!ColumnExists(conn, "acad_applications", "app_status"))
                throw new Exception("app_status column not found.");
            string current = GetAppStatus(conn, eno);
            if (current != "SUBMITTED")
                throw new Exception("Application must be SUBMITTED to move to review. Current: " + current);
            UpdateStatus(conn, eno, "UNDER_REVIEW");
            WriteAuditLog(conn, eno, "UNDER_REVIEW", "Moved to under review by " + GetCurrentUser());
        }
        Response.Write("{\"ok\":true}");
    }

    private void HandleAdmit()
    {
        var data = ReadPostJson();
        string eno = GetStr(data, "eno");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");
        using (var conn = Open())
        {
            if (!ColumnExists(conn, "acad_applications", "app_status"))
                throw new Exception("app_status column not found.");
            string current = GetAppStatus(conn, eno);
            if (current != "SUBMITTED" && current != "UNDER_REVIEW")
                throw new Exception("Application must be SUBMITTED or UNDER_REVIEW to admit. Current: " + current);
            UpdateStatus(conn, eno, "ADMITTED");
            using (var cmd = new MySqlCommand(
                "UPDATE acad_applicant_choices SET adm_status=1 WHERE stud_entry_no=@eno AND Choice=1 AND adm_status=0",
                conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                cmd.ExecuteNonQuery();
            }
            WriteAuditLog(conn, eno, "ADMITTED", "Admitted via Online Applications by " + GetCurrentUser());
        }
        Response.Write("{\"ok\":true}");
    }

    private void HandleReject()
    {
        var data   = ReadPostJson();
        string eno    = GetStr(data, "eno");
        string reason = GetStr(data, "reason");
        if (string.IsNullOrEmpty(eno))    throw new Exception("Entry number required.");
        if (string.IsNullOrEmpty(reason)) throw new Exception("Rejection reason is required.");
        using (var conn = Open())
        {
            if (!ColumnExists(conn, "acad_applications", "app_status"))
                throw new Exception("app_status column not found.");
            string current = GetAppStatus(conn, eno);
            if (current == "ADMITTED" || current == "WITHDRAWN" || current == "REJECTED")
                throw new Exception("Cannot reject application in status: " + current);
            UpdateStatus(conn, eno, "REJECTED");
            SaveReviewerNotes(conn, eno, "[REJECTED] " + reason);
            using (var cmd = new MySqlCommand(
                "UPDATE acad_applicant_choices SET adm_status=2 WHERE stud_entry_no=@eno AND Choice=1 AND adm_status IN(0,1)",
                conn))
            {
                cmd.Parameters.AddWithValue("@eno", eno);
                cmd.ExecuteNonQuery();
            }
            WriteAuditLog(conn, eno, "REJECTED", "Rejected by " + GetCurrentUser() + ". Reason: " + reason);
        }
        Response.Write("{\"ok\":true}");
    }

    private void HandleNote()
    {
        var data  = ReadPostJson();
        string eno   = GetStr(data, "eno");
        string notes = GetStr(data, "notes");
        if (string.IsNullOrEmpty(eno)) throw new Exception("Entry number required.");
        using (var conn = Open())
            SaveReviewerNotes(conn, eno, notes);
        Response.Write("{\"ok\":true}");
    }

    // ════════════════════════════════════════════════════════════════════════
    // DB HELPERS
    // ════════════════════════════════════════════════════════════════════════
    private MySqlConnection Open()
    {
        var conn = new MySqlConnection(ConnStr);
        conn.Open();
        return conn;
    }

    private string GetAppStatus(MySqlConnection conn, string eno)
    {
        using (var cmd = new MySqlCommand(
            "SELECT IFNULL(app_status,'DRAFT') FROM acad_applications WHERE stud_entry_no=@eno LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            object v = cmd.ExecuteScalar();
            if (v == null || v == DBNull.Value) throw new Exception("Application not found: " + eno);
            return v.ToString().Trim().ToUpperInvariant();
        }
    }

    private void UpdateStatus(MySqlConnection conn, string eno, string status)
    {
        bool hasUpdatedAt = ColumnExists(conn, "acad_applications", "app_last_updated_at");
        string sql = hasUpdatedAt
            ? "UPDATE acad_applications SET app_status=@s, app_last_updated_at=@now WHERE stud_entry_no=@eno"
            : "UPDATE acad_applications SET app_status=@s WHERE stud_entry_no=@eno";
        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@s",   status);
            cmd.Parameters.AddWithValue("@eno", eno);
            if (hasUpdatedAt) cmd.Parameters.AddWithValue("@now", DateTime.UtcNow);
            cmd.ExecuteNonQuery();
        }
    }

    private void SaveReviewerNotes(MySqlConnection conn, string eno, string notes)
    {
        if (!ColumnExists(conn, "acad_applications", "app_reviewer_notes")) return;
        bool hasUpdatedAt = ColumnExists(conn, "acad_applications", "app_last_updated_at");
        string sql = "UPDATE acad_applications SET app_reviewer_notes=@n";
        if (hasUpdatedAt) sql += ", app_last_updated_at=@now";
        sql += " WHERE stud_entry_no=@eno";
        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@n",   notes ?? "");
            if (hasUpdatedAt) cmd.Parameters.AddWithValue("@now", DateTime.UtcNow);
            cmd.Parameters.AddWithValue("@eno", eno);
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
                cmd.Parameters.AddWithValue("@detail", detail ?? "");
                cmd.Parameters.AddWithValue("@now",    DateTime.UtcNow);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private string GetCurrentUser()
    {
        if (Session["LoggedInUser"] != null) return Session["LoggedInUser"].ToString();
        if (Session["username"]     != null) return Session["username"].ToString();
        return "system";
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

    private bool TableExists(MySqlConnection conn, string table)
    {
        using (var cmd = new MySqlCommand(@"
            SELECT COUNT(*) FROM information_schema.TABLES
            WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=@t", conn))
        {
            cmd.Parameters.AddWithValue("@t", table);
            object v = cmd.ExecuteScalar();
            return v != null && v != DBNull.Value && Convert.ToInt32(v) > 0;
        }
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

    // ════════════════════════════════════════════════════════════════════════
    // STRING HELPERS (protected so ASPX <%= %> expressions can call them)
    // ════════════════════════════════════════════════════════════════════════
    protected static string HE(string s)
    {
        return HttpUtility.HtmlEncode(s ?? "");
    }

    private static string HtmlAE(string s)
    {
        return HttpUtility.HtmlAttributeEncode(s ?? "");
    }

    // Returns selected="selected" when current matches option (used in ASPX filter selects)
    protected string Sel(string current, string option)
    {
        return string.Equals(current ?? "", option ?? "", StringComparison.OrdinalIgnoreCase)
            ? " selected=\"selected\"" : "";
    }

    private static string JsStr(string s)
    {
        return (s ?? "").Replace("\\", "\\\\").Replace("'", "\\'")
                        .Replace("\r", "").Replace("\n", "");
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

    private static string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        DateTime dt;
        return DateTime.TryParse(val.ToString(), out dt)
            ? dt.ToString("dd MMM yyyy, HH:mm") : "";
    }

    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                        .Replace("\r", "\\r").Replace("\n", "\\n").Replace("\t", "\\t") + "\"";
    }
}
