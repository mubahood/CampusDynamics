using System;
using System.Configuration;
using System.Globalization;
using System.Text;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

/// <summary>
/// Student Photo Change Controller (eadmin).
/// Reviews student self-service photo changes recorded by the eportal uploader.
/// Approve  -> photo_status = APPROVED (the new photo stays live).
/// Reject   -> photo_status = REJECTED and acad_student.photofile is BLANKED, so the
///             rejected photo is no longer served anywhere; the student must upload a
///             new one or delete. Supports per-row and batch approve/reject.
/// </summary>
public partial class COOPERP_NewScreens_PhotoChangeController : System.Web.UI.Page
{
    private const int PAGE_SIZE = 20;
    private const string PHOTO_BASE = "/COOPERP/StudentInfo/photos/";

    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string GetCurrentUser()
    {
        if (Session["username"] != null && Session["username"].ToString().Trim() != "")
            return Session["username"].ToString().Trim();
        if (HttpContext.Current.User != null && HttpContext.Current.User.Identity.IsAuthenticated)
            return HttpContext.Current.User.Identity.Name;
        return "admin";
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string action = Request.QueryString["action"] ?? Request.Form["action"];
        if (!string.IsNullOrEmpty(action))
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            try
            {
                if (action == "review") Response.Write(HandleReview());
                else if (action == "batch") Response.Write(HandleBatch());
                else if (action == "admininit") Response.Write(HandleAdminInit());
                else Response.Write("{\"success\":false,\"message\":\"Unknown action.\"}");
            }
            catch (Exception ex)
            {
                Response.Write("{\"success\":false,\"message\":\"" + JsEnc(ex.Message) + "\"}");
            }
            try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
            return;
        }

        litBody.Text = BuildList();
    }

    // ===================================================================
    // REVIEW (approve / reject)
    // ===================================================================
    private string HandleReview()
    {
        int id = SafeInt(Request.Form["id"], 0);
        bool approve = string.Equals(Request.Form["decision"], "approve", StringComparison.OrdinalIgnoreCase);
        string comment = (Request.Form["comment"] ?? "").Trim();
        if (id <= 0) return "{\"success\":false,\"message\":\"Missing record id.\"}";

        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string outcome = ReviewOne(conn, id, approve, comment, GetCurrentUser());
            bool ok = outcome == "OK";
            return "{\"success\":" + (ok ? "true" : "false") + ",\"message\":\"" + JsEnc(ok ? (approve ? "Photo approved." : "Photo rejected and removed from the student.") : outcome) + "\"}";
        }
    }

    private string HandleBatch()
    {
        string idsCsv = Request.Form["ids"] ?? "";
        bool approve = string.Equals(Request.Form["decision"], "approve", StringComparison.OrdinalIgnoreCase);
        string comment = (Request.Form["comment"] ?? "").Trim();

        var ids = new List<int>();
        foreach (string part in idsCsv.Split(','))
        {
            int v; if (int.TryParse(part.Trim(), out v) && v > 0) ids.Add(v);
        }
        if (ids.Count == 0) return "{\"success\":false,\"message\":\"No records selected.\"}";

        int done = 0, skipped = 0;
        string user = GetCurrentUser();
        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            foreach (int id in ids)
            {
                string r = ReviewOne(conn, id, approve, comment, user);
                if (r == "OK") done++; else skipped++;
            }
        }
        string verb = approve ? "approved" : "rejected";
        return "{\"success\":true,\"message\":\"" + done + " " + verb + (skipped > 0 ? ", " + skipped + " skipped (already reviewed)" : "") + ".\"}";
    }

    /// <summary>
    /// Admin-initiated override: create a record for a specific student and set their
    /// photo_status to ANY value (PENDING / APPROVED / REJECTED). REJECTED blanks the
    /// photofile (blocks it), matching the normal reject. Recorded as an admin action.
    /// </summary>
    private string HandleAdminInit()
    {
        string regno = (Request.Form["regno"] ?? "").Trim();
        string status = (Request.Form["status"] ?? "").Trim().ToUpperInvariant();
        string comment = (Request.Form["comment"] ?? "").Trim();

        if (regno == "") return "{\"success\":false,\"message\":\"Please enter a registration number.\"}";
        if (status != "PENDING" && status != "APPROVED" && status != "REJECTED")
            return "{\"success\":false,\"message\":\"Choose a valid status (PENDING, APPROVED or REJECTED).\"}";

        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();

            string curPhoto = null, name = "";
            using (var cmd = new MySqlCommand(
                "SELECT COALESCE(photofile,''), TRIM(CONCAT(COALESCE(firstname,''),' ',COALESCE(othername,''))) FROM acad_student WHERE regno=@r LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                using (var rd = cmd.ExecuteReader())
                {
                    if (!rd.Read()) return "{\"success\":false,\"message\":\"No student found with reg no '" + JsEnc(regno) + "'.\"}";
                    curPhoto = rd.IsDBNull(0) ? "" : rd.GetString(0);
                    name = rd.IsDBNull(1) ? "" : rd.GetString(1);
                }
            }

            string user = GetCurrentUser();
            using (var tx = conn.BeginTransaction())
            {
                try
                {
                    if (status == "REJECTED")
                    {
                        using (var cmd = new MySqlCommand("UPDATE acad_student SET photo_status='REJECTED', photofile='' WHERE regno=@r", conn, tx))
                        { cmd.Parameters.AddWithValue("@r", regno); cmd.ExecuteNonQuery(); }
                    }
                    else
                    {
                        using (var cmd = new MySqlCommand("UPDATE acad_student SET photo_status=@s WHERE regno=@r", conn, tx))
                        { cmd.Parameters.AddWithValue("@s", status); cmd.Parameters.AddWithValue("@r", regno); cmd.ExecuteNonQuery(); }
                    }

                    using (var cmd = new MySqlCommand(
                        "INSERT INTO stud_photo_change (regno, old_photofile, new_photofile, status, source, requested_at, reviewed_by, reviewed_at, review_comment) " +
                        "VALUES (@r, @o, @n, @s, 'eadmin-admin', NOW(), @by, NOW(), @c)", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@r", regno);
                        cmd.Parameters.AddWithValue("@o", curPhoto);
                        cmd.Parameters.AddWithValue("@n", status == "REJECTED" ? "" : curPhoto);
                        cmd.Parameters.AddWithValue("@s", status);
                        cmd.Parameters.AddWithValue("@by", user);
                        cmd.Parameters.AddWithValue("@c", comment == "" ? (object)DBNull.Value : comment);
                        cmd.ExecuteNonQuery();
                    }
                    tx.Commit();
                }
                catch { tx.Rollback(); throw; }
            }

            string who = name == "" ? regno : name + " (" + regno + ")";
            return "{\"success\":true,\"message\":\"Photo status for " + JsEnc(who) + " set to " + status + ".\"}";
        }
    }

    /// <summary>Reviews a single PENDING change. Returns "OK" or a skip reason.</summary>
    private string ReviewOne(MySqlConnection conn, int id, bool approve, string comment, string user)
    {
        string regno = "", newPhoto = "", status = "";
        using (var cmd = new MySqlCommand("SELECT regno, new_photofile, status FROM stud_photo_change WHERE id=@id LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@id", id);
            using (var rd = cmd.ExecuteReader())
            {
                if (!rd.Read()) return "Record not found.";
                regno = rd["regno"].ToString();
                newPhoto = rd["new_photofile"].ToString();
                status = rd["status"].ToString().ToUpperInvariant();
            }
        }
        if (status != "PENDING") return "Already " + status.ToLowerInvariant() + ".";

        using (var tx = conn.BeginTransaction())
        {
            try
            {
                using (var cmd = new MySqlCommand(
                    "UPDATE stud_photo_change SET status=@st, reviewed_by=@by, reviewed_at=NOW(), review_comment=@c WHERE id=@id AND status='PENDING'", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@st", approve ? "APPROVED" : "REJECTED");
                    cmd.Parameters.AddWithValue("@by", user);
                    cmd.Parameters.AddWithValue("@c", comment == "" ? (object)DBNull.Value : comment);
                    cmd.Parameters.AddWithValue("@id", id);
                    if (cmd.ExecuteNonQuery() == 0) { tx.Rollback(); return "Already reviewed."; }
                }

                // Only touch the student if THIS change's photo is still their current photo
                // (guards against a newer upload having superseded this pending one).
                if (approve)
                {
                    using (var cmd = new MySqlCommand(
                        "UPDATE acad_student SET photo_status='APPROVED' WHERE regno=@r AND photofile=@p", conn, tx))
                    { cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@p", newPhoto); cmd.ExecuteNonQuery(); }
                }
                else
                {
                    // Reject: block the photo — blank it so it is not served anywhere.
                    using (var cmd = new MySqlCommand(
                        "UPDATE acad_student SET photo_status='REJECTED', photofile='' WHERE regno=@r AND photofile=@p", conn, tx))
                    { cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@p", newPhoto); cmd.ExecuteNonQuery(); }
                }
                tx.Commit();
                return "OK";
            }
            catch { tx.Rollback(); throw; }
        }
    }

    // ===================================================================
    // LIST
    // ===================================================================
    private string BuildList()
    {
        string status = (Request.QueryString["status"] ?? "PENDING").Trim().ToUpperInvariant();
        if (status != "ALL" && status != "PENDING" && status != "APPROVED" && status != "REJECTED" && status != "DELETED") status = "PENDING";
        string q = (Request.QueryString["q"] ?? "").Trim();
        int page = SafeInt(Request.QueryString["page"], 1); if (page < 1) page = 1;

        var pr = new List<MySqlParameter>();
        var where = new StringBuilder("WHERE 1=1");
        if (status != "ALL") { where.Append(" AND c.status=@st"); pr.Add(new MySqlParameter("@st", status)); }
        if (q != "") { where.Append(" AND (c.regno LIKE @q OR TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) LIKE @q)"); pr.Add(new MySqlParameter("@q", "%" + q + "%")); }

        int total = 0, pendingCount = 0;
        var rows = new List<Dictionary<string, string>>();
        using (var conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM stud_photo_change WHERE status='PENDING'", conn))
                pendingCount = Convert.ToInt32(cmd.ExecuteScalar());

            using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM stud_photo_change c LEFT JOIN acad_student s ON s.regno=c.regno " + where, conn))
            { foreach (var p in pr) cmd.Parameters.Add(Clone(p)); total = Convert.ToInt32(cmd.ExecuteScalar()); }

            int pages = Math.Max(1, (int)Math.Ceiling(total / (double)PAGE_SIZE));
            if (page > pages) page = pages;
            int offset = (page - 1) * PAGE_SIZE;

            string sql = "SELECT c.id, c.regno, TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS name, " +
                         "COALESCE(s.progid,'') AS prog, COALESCE(c.old_photofile,'') AS oldf, c.new_photofile AS newf, c.status, " +
                         "COALESCE(c.source,'') AS source, c.requested_at, COALESCE(c.reviewed_by,'') AS reviewed_by, c.reviewed_at, " +
                         "COALESCE(c.review_comment,'') AS review_comment " +
                         "FROM stud_photo_change c LEFT JOIN acad_student s ON s.regno=c.regno " + where +
                         " ORDER BY (c.status='PENDING') DESC, c.id DESC LIMIT " + offset + "," + PAGE_SIZE;
            using (var cmd = new MySqlCommand(sql, conn))
            {
                foreach (var p in pr) cmd.Parameters.Add(Clone(p));
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        var d = new Dictionary<string, string>();
                        d["id"] = rd["id"].ToString();
                        d["regno"] = Safe(rd, "regno");
                        d["name"] = Safe(rd, "name");
                        d["prog"] = Safe(rd, "prog");
                        d["oldf"] = Safe(rd, "oldf");
                        d["newf"] = Safe(rd, "newf");
                        d["status"] = Safe(rd, "status");
                        d["requested_at"] = rd["requested_at"] == DBNull.Value ? "" : Convert.ToDateTime(rd["requested_at"]).ToString("dd MMM yyyy HH:mm");
                        d["reviewed_by"] = Safe(rd, "reviewed_by");
                        d["reviewed_at"] = rd["reviewed_at"] == DBNull.Value ? "" : Convert.ToDateTime(rd["reviewed_at"]).ToString("dd MMM yyyy HH:mm");
                        d["comment"] = Safe(rd, "review_comment");
                        rows.Add(d);
                    }
                }
            }

            var sb = new StringBuilder();
            // Filter bar
            sb.Append("<div class='pc-bar'>");
            sb.Append("<div class='pc-tabs'>");
            sb.Append(Tab("PENDING", "Pending", status, q, pendingCount));
            sb.Append(Tab("APPROVED", "Approved", status, q, -1));
            sb.Append(Tab("REJECTED", "Rejected", status, q, -1));
            sb.Append(Tab("DELETED", "Deleted", status, q, -1));
            sb.Append(Tab("ALL", "All", status, q, -1));
            sb.Append("</div>");
            sb.Append("<div class='pc-bar__right'>");
            sb.Append("<form method='get' class='pc-search'><input type='hidden' name='status' value='" + HE(status) + "'/>" +
                      "<input type='text' name='q' value='" + HE(q) + "' placeholder='Search reg no or name...' class='pc-search__in'/>" +
                      "<button class='pc-btn pc-btn--sm'>Search</button>" + (q != "" ? "<a class='pc-clear' href='PhotoChangeController.aspx?status=" + HE(status) + "'>clear</a>" : "") + "</form>");
            sb.Append("<button type='button' class='pc-btn pc-btn--nav' onclick='pcOpenInit()'>&#43; Set a student&rsquo;s status</button>");
            sb.Append("</div>");
            sb.Append("</div>");

            // Batch action bar (only meaningful for pending)
            sb.Append("<div class='pc-batch' id='pcBatch'>");
            sb.Append("<label class='pc-selall'><input type='checkbox' id='pcAll' onclick='pcToggleAll(this)'/> Select all on this page</label>");
            sb.Append("<span class='pc-batch__spacer'></span>");
            sb.Append("<span id='pcSelCount' class='pc-selcount'>0 selected</span>");
            sb.Append("<button type='button' class='pc-btn pc-btn--ok' onclick='pcBatch(true)'>Approve selected</button>");
            sb.Append("<button type='button' class='pc-btn pc-btn--danger' onclick='pcBatch(false)'>Reject selected</button>");
            sb.Append("</div>");

            if (rows.Count == 0)
            {
                sb.Append("<div class='pc-empty'>No photo changes match this filter.</div>");
                return sb.ToString();
            }

            sb.Append("<div class='pc-grid'>");
            foreach (var d in rows) sb.Append(Card(d));
            sb.Append("</div>");

            // Pager
            if (pages > 1)
            {
                sb.Append("<div class='pc-pager'>");
                sb.AppendFormat("<span>{0} record{1} &middot; page {2} of {3}</span>", total, total == 1 ? "" : "s", page, pages);
                string baseUrl = "PhotoChangeController.aspx?status=" + HE(status) + (q != "" ? "&q=" + HttpUtility.UrlEncode(q) : "") + "&page=";
                sb.Append("<span class='pc-pager__btns'>");
                sb.Append("<a class='pc-pg " + (page <= 1 ? "off" : "") + "' href='" + baseUrl + (page - 1) + "'>&lsaquo; Prev</a>");
                sb.Append("<a class='pc-pg " + (page >= pages ? "off" : "") + "' href='" + baseUrl + (page + 1) + "'>Next &rsaquo;</a>");
                sb.Append("</span></div>");
            }
            return sb.ToString();
        }
    }

    private string Card(Dictionary<string, string> d)
    {
        string st = d["status"].ToUpperInvariant();
        string badge = "<span class='pc-st pc-st--" + st.ToLowerInvariant() + "'>" + HE(d["status"]) + "</span>";
        string newUrl = d["newf"] != "" ? PHOTO_BASE + Uri.EscapeDataString(d["newf"]) : "";
        string oldUrl = d["oldf"] != "" ? PHOTO_BASE + Uri.EscapeDataString(d["oldf"]) : "";
        bool pending = st == "PENDING";

        var sb = new StringBuilder();
        sb.Append("<div class='pc-card' data-id='" + HE(d["id"]) + "'>");
        // header
        sb.Append("<div class='pc-card__h'>");
        if (pending) sb.Append("<input type='checkbox' class='pc-chk' value='" + HE(d["id"]) + "' onclick='pcCount()'/>");
        sb.Append("<div class='pc-card__id'><b>" + HE(d["name"] == "" ? d["regno"] : d["name"]) + "</b><span>" + HE(d["regno"]) + (d["prog"] != "" ? " &middot; " + HE(d["prog"]) : "") + "</span></div>");
        sb.Append(badge);
        sb.Append("</div>");
        // photos: new (big) + old (small)
        sb.Append("<div class='pc-imgs'>");
        sb.Append("<div class='pc-img pc-img--new'>");
        if (newUrl != "") sb.Append("<img src='" + HE(newUrl) + "' alt='new' loading='lazy'/>"); else sb.Append("<div class='pc-img__none'>none</div>");
        sb.Append("<span class='pc-img__lbl'>New</span></div>");
        sb.Append("<div class='pc-img pc-img--old'>");
        if (oldUrl != "") sb.Append("<img src='" + HE(oldUrl) + "' alt='old' loading='lazy'/>"); else sb.Append("<div class='pc-img__none'>no previous</div>");
        sb.Append("<span class='pc-img__lbl'>Previous</span></div>");
        sb.Append("</div>");
        // meta
        sb.Append("<div class='pc-meta'>Requested " + HE(d["requested_at"]) + "</div>");
        if (d["reviewed_at"] != "") sb.Append("<div class='pc-meta'>" + HE(st == "REJECTED" ? "Rejected" : (st == "APPROVED" ? "Approved" : "Reviewed")) + " by " + HE(d["reviewed_by"]) + " &middot; " + HE(d["reviewed_at"]) + (d["comment"] != "" ? "<br/><i>&ldquo;" + HE(d["comment"]) + "&rdquo;</i>" : "") + "</div>");
        // actions
        if (pending)
        {
            sb.Append("<div class='pc-acts'>");
            sb.Append("<button type='button' class='pc-btn pc-btn--ok' onclick=\"pcReview(" + HE(d["id"]) + ",true)\">Approve</button>");
            sb.Append("<button type='button' class='pc-btn pc-btn--danger' onclick=\"pcReview(" + HE(d["id"]) + ",false)\">Reject</button>");
            sb.Append("</div>");
        }
        sb.Append("</div>");
        return sb.ToString();
    }

    private string Tab(string key, string label, string cur, string q, int count)
    {
        string on = key == cur ? " pc-tab--on" : "";
        string href = "PhotoChangeController.aspx?status=" + key + (q != "" ? "&q=" + HttpUtility.UrlEncode(q) : "");
        string badge = count >= 0 ? " <em>(" + count + ")</em>" : "";
        return "<a class='pc-tab" + on + "' href='" + href + "'>" + HE(label) + badge + "</a>";
    }

    // ---- helpers ----
    private static string Safe(MySqlDataReader rd, string col) { return rd[col] == DBNull.Value ? "" : rd[col].ToString().Trim(); }
    private string HE(string s) { return Server.HtmlEncode(s ?? ""); }
    private static int SafeInt(string s, int def) { int v; return int.TryParse((s ?? "").Trim(), out v) ? v : def; }
    private static MySqlParameter Clone(MySqlParameter p) { return new MySqlParameter(p.ParameterName, p.Value); }
    private static string JsEnc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        var sb = new StringBuilder();
        foreach (char c in s) { if (c == '"' || c == '\\') sb.Append('\\').Append(c); else if (c == '\n' || c == '\r' || c == '\t') sb.Append(' '); else sb.Append(c); }
        return sb.ToString();
    }
}
