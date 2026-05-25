using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using MySql.Data.MySqlClient;

public static class RoleAccessService
{
    public const string SESSION_SLUGS     = "access_slugs";
    public const string SESSION_ROLE      = "user_role_code";
    public const string SESSION_ROLE_NAME = "user_role_name";
    public const string ADMIN_WILDCARD    = "*";

    // Loads the user's role and accessible slugs into Session after login.
    public static void LoadUserAccess(string username)
    {
        var session = HttpContext.Current.Session;
        if (session == null) return;

        var slugs = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        string roleCode = "";
        string roleName = "";

        try
        {
            string cs = ResolveConnectionString();
            using (var conn = new MySqlConnection(cs))
            {
                conn.Open();

                const string roleSql = @"
                    SELECT r.role_code, r.role_name
                    FROM sys_user_roles ur
                    JOIN sys_roles r ON ur.role_id = r.id
                    WHERE ur.username = @u
                      AND ur.is_active = 1
                      AND r.is_active  = 1
                      AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                    ORDER BY r.id ASC
                    LIMIT 1";

                using (var cmd = new MySqlCommand(roleSql, conn))
                {
                    cmd.Parameters.AddWithValue("@u", username);
                    using (var dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            roleCode = dr.GetString(0);
                            roleName = dr.GetString(1);
                        }
                    }
                }

                if (string.IsNullOrEmpty(roleCode)) return;

                if (roleCode == "admin")
                {
                    slugs.Add(ADMIN_WILDCARD);
                }
                else
                {
                    const string slugSql = @"
                        SELECT DISTINCT rp.menu_slug
                        FROM sys_role_permissions rp
                        JOIN sys_user_roles ur ON rp.role_id = ur.role_id
                        WHERE ur.username = @u
                          AND ur.is_active = 1
                          AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                          AND rp.can_view  = 1";

                    using (var cmd = new MySqlCommand(slugSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@u", username);
                        using (var dr = cmd.ExecuteReader())
                            while (dr.Read()) slugs.Add(dr.GetString(0));
                    }
                }
            }
        }
        catch { }

        session[SESSION_SLUGS]     = string.Join(",", slugs);
        session[SESSION_ROLE]      = roleCode;
        session[SESSION_ROLE_NAME] = roleName;
        session["usertype"]        = roleCode;
    }

    public static bool CanAccess(string slug)
    {
        var session = HttpContext.Current.Session;
        if (session == null) return false;
        string raw = session[SESSION_SLUGS] as string ?? "";
        if (string.IsNullOrEmpty(raw)) return false;
        if (raw.Contains(ADMIN_WILDCARD)) return true;
        var parts = raw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        return parts.Any(p => string.Equals(p.Trim(), slug, StringComparison.OrdinalIgnoreCase));
    }

    public static bool IsAdmin()
    {
        var session = HttpContext.Current.Session;
        if (session == null) return false;
        string raw = session[SESSION_SLUGS] as string ?? "";
        return raw.Contains(ADMIN_WILDCARD);
    }

    public static string GetRoleCode()
    {
        var session = HttpContext.Current.Session;
        if (session == null) return "";
        return (session[SESSION_ROLE] as string ?? "").ToLower();
    }

    public static string GetRoleName()
    {
        var session = HttpContext.Current.Session;
        if (session == null) return "";
        return session[SESSION_ROLE_NAME] as string ?? "";
    }

    // Redirects to login if not authenticated, or AccessDenied if slug is missing.
    public static void RequireSlug(System.Web.UI.Page page, string slug)
    {
        var session = page.Session;
        if (session == null || session["username"] == null ||
            string.IsNullOrEmpty(session["username"].ToString()))
        {
            page.Response.Redirect("~/Default.aspx", true);
            return;
        }

        // If access slugs are missing (session lost, app pool recycled, or login
        // path didn't call LoadUserAccess), reload them now from the database.
        if (string.IsNullOrEmpty(session[SESSION_SLUGS] as string))
        {
            LoadUserAccess(session["username"].ToString());
        }

        if (!CanAccess(slug))
        {
            page.Response.Redirect(
                "~/COOPERP/NewScreens/AccessDenied.aspx?slug=" + HttpUtility.UrlEncode(slug),
                true);
        }
    }

    public static string GetSectionDefaultsJson()
    {
        string roleCode = GetRoleCode();
        if (string.IsNullOrEmpty(roleCode)) return "{}";

        var defaults = new Dictionary<string, string[]>(StringComparer.OrdinalIgnoreCase)
        {
            { "admin",            new[] { "system" } },
            { "dean",             new[] { "academics", "comms" } },
            { "registrar",        new[] { "academics", "comms" } },
            { "faculty_staff",    new[] { "academics" } },
            { "exam_officer",     new[] { "academics" } },
            { "admissions",       new[] { "academics" } },
            { "student_services", new[] { "academics", "comms" } },
            { "fees_officer",     new[] { "fees" } },
            { "bursar",           new[] { "fees", "requisitions" } },
            { "finance_officer",  new[] { "accounts", "requisitions" } },
            { "accountant",       new[] { "accounts" } },
            { "hr_manager",       new[] { "hr" } },
            { "procurement",      new[] { "requisitions" } },
            { "vc",               new[] { "requisitions" } }
        };

        string[] openSections;
        if (!defaults.TryGetValue(roleCode, out openSections))
            openSections = new string[0];

        var parts = openSections.Select(s => "\"" + s + "\":true");
        return "{" + string.Join(",", parts) + "}";
    }

    public static HashSet<string> GetRoleSlugs(int roleId)
    {
        var result = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        try
        {
            using (var conn = new MySqlConnection(ResolveConnectionString()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT menu_slug FROM sys_role_permissions WHERE role_id=@id AND can_view=1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", roleId);
                    using (var dr = cmd.ExecuteReader())
                        while (dr.Read()) result.Add(dr.GetString(0));
                }
            }
        }
        catch { }
        return result;
    }

    public static void LogAudit(string actionType, string targetType, string targetId,
                                string detail, string actor, string ip)
    {
        try
        {
            using (var conn = new MySqlConnection(ResolveConnectionString()))
            {
                conn.Open();
                const string sql = @"
                    INSERT INTO sys_role_audit
                        (action_type, target_type, target_id, detail, actor, ip_address)
                    VALUES (@at, @tt, @tid, @d, @a, @ip)";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@at",  actionType);
                    cmd.Parameters.AddWithValue("@tt",  targetType);
                    cmd.Parameters.AddWithValue("@tid", targetId);
                    cmd.Parameters.AddWithValue("@d",   detail   ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@a",   actor);
                    cmd.Parameters.AddWithValue("@ip",  ip       ?? (object)DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }
        catch { }
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
