using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// RBAC enforcement base page (Phase 2 of the Access-Control plan).
///
/// A NewScreens page can opt in to automatic slug enforcement by inheriting
/// this class instead of <see cref="System.Web.UI.Page"/>. The page's slug is
/// derived from its file name via <c>sys_menu_items.url</c>; access is then
/// checked through <see cref="RoleAccessService"/>.
///
/// Behaviour is controlled by the <c>RbacEnforcement</c> app setting:
///   • "off"     (default)  — no checking at all (deploy-safe).
///   • "report"             — log would-be denials to sys_role_audit, never block.
///   • "enforce"            — redirect non-permitted users to AccessDenied.aspx.
///
/// Fail-safe everywhere: admins (wildcard "*") always pass; unmapped pages are
/// never blocked; any error fails OPEN (the page renders). This guarantees the
/// base page can never lock the system out on its own.
/// </summary>
public class AdminSecurePage : System.Web.UI.Page
{
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        try { EnforceAccess(); }
        catch { /* never let enforcement break a page — fail open */ }
    }

    private void EnforceAccess()
    {
        string mode = (ConfigurationManager.AppSettings["RbacEnforcement"] ?? "off").Trim().ToLower();
        if (mode != "report" && mode != "enforce") return;   // "off" or anything else → no-op

        if (Session == null || Session["username"] == null ||
            string.IsNullOrEmpty(Session["username"].ToString()))
        {
            // Not logged in — only redirect in enforce mode; report mode stays silent.
            if (mode == "enforce") Response.Redirect("~/Default.aspx", true);
            return;
        }

        string file = System.IO.Path.GetFileName(Request.Url.AbsolutePath);
        if (string.IsNullOrEmpty(file)) return;

        string slug = ResolvePageSlug(file);
        if (string.IsNullOrEmpty(slug)) return;              // page not in registry → not guarded

        // Make sure the user's access set is loaded (self-heal after a recycle)
        // and refreshed if stale (D2).
        if (string.IsNullOrEmpty(Session[RoleAccessService.SESSION_SLUGS] as string))
            RoleAccessService.LoadUserAccess(Session["username"].ToString());
        else
            RoleAccessService.MaybeRefresh(Session["username"].ToString());

        if (RoleAccessService.CanAccess(slug)) return;       // admins pass via wildcard

        string actor = Session["username"].ToString();
        string ip    = Request.UserHostAddress;

        if (mode == "report")
        {
            // Log once per slug per session to avoid flooding the audit table.
            var reported = Session["rbac_reported"] as HashSet<string>;
            if (reported == null) { reported = new HashSet<string>(StringComparer.OrdinalIgnoreCase); Session["rbac_reported"] = reported; }
            if (reported.Add(slug))
            {
                RoleAccessService.LogAudit("ACCESS_DENIED_REPORT", "page", slug,
                    "Report-only: " + actor + " would be denied " + file, actor, ip);
            }
            return;                                          // report-only never blocks
        }

        // enforce
        RoleAccessService.LogAudit("ACCESS_DENIED", "page", slug,
            "Denied " + actor + " → " + file, actor, ip);
        Response.Redirect(
            "~/COOPERP/NewScreens/AccessDenied.aspx?slug=" + HttpUtility.UrlEncode(slug), true);
    }

    // ── filename → slug, cached for 10 minutes to avoid a query per request ─────
    private static string ResolvePageSlug(string file)
    {
        var map = GetSlugMap();
        string key = file.ToLowerInvariant();
        string slug;
        return map.TryGetValue(key, out slug) ? slug : null;
    }

    private static Dictionary<string, string> GetSlugMap()
    {
        const string cacheKey = "rbac_url_slug_map";
        var cache = HttpRuntime.Cache;
        var map = cache[cacheKey] as Dictionary<string, string>;
        if (map != null) return map;

        map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        try
        {
            using (var conn = new MySqlConnection(ResolveConnectionString()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT url, menu_slug FROM sys_menu_items WHERE is_active=1 AND IFNULL(url,'')<>''", conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string url  = dr["url"].ToString();
                        string slug = dr["menu_slug"].ToString();
                        string f = url.Split('?')[0].TrimEnd('/');
                        int slash = f.LastIndexOf('/');
                        if (slash >= 0) f = f.Substring(slash + 1);
                        f = f.ToLowerInvariant();
                        if (!string.IsNullOrEmpty(f) && !map.ContainsKey(f)) map[f] = slug;
                    }
                }
            }
        }
        catch { /* leave map empty → everything fails open */ }

        cache.Insert(cacheKey, map, null, DateTime.UtcNow.AddMinutes(10),
                     System.Web.Caching.Cache.NoSlidingExpiration);
        return map;
    }

    private static string ResolveConnectionString()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
        cs = ConfigurationManager.ConnectionStrings["DefaultConnection"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
        throw new InvalidOperationException("No valid connection string found.");
    }
}
