using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AccessControlCenter : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Gated by the same slug as the Users screen (admins pass via the '*' wildcard).
        RoleAccessService.RequireSlug(this, "system.user_roles.users");

        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            Response.ContentType = "application/json";
            Response.Cache.SetNoStore();
            try
            {
                if (ajax == "preview")       Preview();
                else if (ajax == "diagnose") Diagnose();
                else Response.Write("{\"ok\":false,\"error\":\"Unknown action.\"}");
            }
            catch (Exception ex)
            {
                Response.Write("{\"ok\":false,\"error\":" + JsStr(ex.Message) + "}");
            }
            Response.End();
            return;
        }

        if (!IsPostBack) { LoadOverview(); BuildPickers(); }
    }

    private void LoadOverview()
    {
        long usersNoRole = 0, totalUsers = 0, activeRoles = 0, menuItems = 0,
             perms = 0, expiring = 0, ungranted = 0, orphans = 0;
        var chips = new StringBuilder();
        var ungrantedList = new StringBuilder();
        var orphanList = new StringBuilder();

        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();

                usersNoRole = Scalar(conn, @"
                    SELECT COUNT(*) FROM my_aspnet_users u
                     WHERE u.isAnonymous = 0
                       AND NOT EXISTS (SELECT 1 FROM sys_user_roles ur
                                        WHERE ur.username = u.name AND ur.is_active = 1
                                          AND (ur.expires_at IS NULL OR ur.expires_at > NOW()))");
                totalUsers  = Scalar(conn, "SELECT COUNT(*) FROM my_aspnet_users WHERE isAnonymous = 0");
                activeRoles = Scalar(conn, "SELECT COUNT(*) FROM sys_roles WHERE is_active = 1");
                menuItems   = Scalar(conn, "SELECT COUNT(*) FROM sys_menu_items WHERE is_active = 1");
                perms       = Scalar(conn, "SELECT COUNT(*) FROM sys_role_permissions");
                expiring    = Scalar(conn, @"
                    SELECT COUNT(*) FROM sys_user_roles
                     WHERE is_active = 1 AND expires_at IS NOT NULL
                       AND expires_at BETWEEN NOW() AND NOW() + INTERVAL 7 DAY");
                ungranted   = Scalar(conn, @"
                    SELECT COUNT(*) FROM sys_menu_items mi
                     WHERE mi.is_active = 1 AND mi.item_type IN ('subitem','standalone')
                       AND IFNULL(mi.url,'') <> ''
                       AND NOT EXISTS (SELECT 1 FROM sys_role_permissions rp
                                        WHERE rp.menu_slug = mi.menu_slug AND rp.can_view = 1)");

                // Roles at a glance — active distinct user count per role
                using (var cmd = new MySqlCommand(@"
                    SELECT r.role_code, r.role_name, COALESCE(r.color_hex,'#64748b') AS color_hex,
                           (SELECT COUNT(DISTINCT ur.username) FROM sys_user_roles ur
                             WHERE ur.role_id = r.id AND ur.is_active = 1
                               AND (ur.expires_at IS NULL OR ur.expires_at > NOW())) AS users
                    FROM sys_roles r WHERE r.is_active = 1
                    ORDER BY users DESC, r.id", conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        chips.AppendFormat(
                            "<a class='acc-chip' href='UserRoleUsers.aspx?role={0}' title='{1} — {3} user(s)'>" +
                            "<span class='acc-chip__dot' style='background:{2}'></span>{1}<b>{3}</b></a>",
                            HE(dr["role_code"].ToString()), HE(dr["role_name"].ToString()),
                            HE(dr["color_hex"].ToString()), dr["users"]);
                }

                // Ungranted page slugs — actionable detail (cap 60)
                using (var cmd = new MySqlCommand(@"
                    SELECT mi.menu_slug, mi.label, mi.section
                    FROM sys_menu_items mi
                    WHERE mi.is_active = 1 AND mi.item_type IN ('subitem','standalone')
                      AND IFNULL(mi.url,'') <> ''
                      AND NOT EXISTS (SELECT 1 FROM sys_role_permissions rp
                                       WHERE rp.menu_slug = mi.menu_slug AND rp.can_view = 1)
                    ORDER BY mi.section, mi.sort_order LIMIT 60", conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                        ungrantedList.AppendFormat(
                            "<li><span class='acc-slug'>{0}</span>{1} <span class='acc-sec'>{2}</span></li>",
                            HE(dr["menu_slug"].ToString()), HE(dr["label"].ToString()), HE(dr["section"].ToString()));
                }

                // D1 drift: permission grants pointing at a slug that no longer
                // exists as an active menu item (orphaned grants).
                using (var cmd = new MySqlCommand(@"
                    SELECT rp.menu_slug, COUNT(DISTINCT rp.role_id) AS roles
                    FROM sys_role_permissions rp
                    WHERE NOT EXISTS (SELECT 1 FROM sys_menu_items mi
                                       WHERE mi.menu_slug = rp.menu_slug AND mi.is_active = 1)
                    GROUP BY rp.menu_slug ORDER BY rp.menu_slug LIMIT 60", conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        orphans++;
                        orphanList.AppendFormat(
                            "<li><span class='acc-slug'>{0}</span><span class='acc-sec'>granted to {1} role(s) — no live menu item</span></li>",
                            HE(dr["menu_slug"].ToString()), dr["roles"]);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            litError.Text = "<div class='acc-err'>&#9888; Could not load overview: " + HE(ex.Message) + "</div>";
        }

        // KPI cards
        var k = new StringBuilder();
        k.Append(Kpi(usersNoRole, "Users without a role", usersNoRole > 0 ? "warn" : "ok", "UserRoleUsers.aspx?filter=norole"));
        k.Append(Kpi(activeRoles, "Active roles", "info", "UserRoleRoles.aspx"));
        k.Append(Kpi(menuItems,   "Menu items (slugs)", "info", "UserRolePermissions.aspx"));
        k.Append(Kpi(perms,       "Permission grants", "info", "UserRolePermissions.aspx"));
        k.Append(Kpi(ungranted,   "Ungranted page slugs", ungranted > 0 ? "warn" : "ok", "#ungranted"));
        k.Append(Kpi(expiring,    "Roles expiring (7d)", expiring > 0 ? "warn" : "ok", "UserRoleUsers.aspx?filter=expiring"));
        litKpis.Text = k.ToString();

        // Needs attention
        var a = new StringBuilder();
        if (usersNoRole > 0)
            a.Append(Att(string.Format("<b>{0:N0}</b> of {1:N0} login users have <b>no active role</b> — they will get no menu or page access once enforcement is switched on.", usersNoRole, totalUsers),
                         "Assign roles", "UserRoleUsers.aspx?filter=norole"));
        if (ungranted > 0)
            a.Append(Att(string.Format("<b>{0:N0}</b> page slug(s) are granted to <b>no role</b> — currently reachable only by admins.", ungranted),
                         "Review below", "#ungranted"));
        if (expiring > 0)
            a.Append(Att(string.Format("<b>{0:N0}</b> role assignment(s) expire within 7 days.", expiring),
                         "Review", "UserRoleUsers.aspx?filter=expiring"));
        if (orphans > 0)
            a.Append(Att(string.Format("<b>{0:N0}</b> permission grant(s) point at a slug with <b>no live menu item</b> (drift) — clean up in the Permissions tab.", orphans),
                         "See below", "#drift"));
        if (a.Length == 0)
            a.Append("<div class='acc-att acc-att--ok'><span class='acc-att__txt'>All clear &mdash; every user has a role and every page is granted to at least one role.</span></div>");
        litAttention.Text = a.ToString();

        litRoleChips.Text = chips.Length > 0 ? chips.ToString() : "<span class='acc-muted'>No active roles.</span>";
        litUngranted.Text = ungrantedList.Length > 0
            ? "<ul class='acc-ul'>" + ungrantedList + "</ul>"
            : "<p class='acc-muted'>None &mdash; every page slug is granted to at least one role.</p>";

        litDrift.Text = orphanList.Length > 0
            ? "<ul class='acc-ul'>" + orphanList + "</ul>"
            : "<p class='acc-muted'>No drift &mdash; every permission grant maps to a live menu item.</p>";
    }

    // ── A7: populate the role / slug pickers used by the diagnostics ───────────
    private void BuildPickers()
    {
        var roles = new StringBuilder();
        var slugs = new StringBuilder();
        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT id, role_name FROM sys_roles WHERE is_active=1 ORDER BY role_name", conn))
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                        roles.AppendFormat("<option value='{0}'>{1}</option>",
                            dr["id"], HE(dr["role_name"].ToString()));

                using (var cmd = new MySqlCommand(@"
                    SELECT menu_slug, label FROM sys_menu_items
                    WHERE is_active=1 AND item_type IN ('subitem','standalone') AND IFNULL(url,'')<>''
                    ORDER BY section, sort_order, label", conn))
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                        slugs.AppendFormat("<option value='{0}'>{1} ({0})</option>",
                            HE(dr["menu_slug"].ToString()), HE(dr["label"].ToString()));
            }
        }
        catch { }
        litRoleSelect.Text = roles.ToString();
        litSlugSelect.Text = slugs.ToString();
    }

    // ── A7: Preview-as-role — the menu/screens a role would see ────────────────
    private void Preview()
    {
        int roleId;
        if (!int.TryParse((Request["role_id"] ?? "").Trim(), out roleId))
        { Response.Write("{\"ok\":false,\"error\":\"Pick a role.\"}"); return; }

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();
            string roleCode = "", roleName = "";
            using (var cmd = new MySqlCommand("SELECT role_code, role_name FROM sys_roles WHERE id=@id AND is_active=1", conn))
            {
                cmd.Parameters.AddWithValue("@id", roleId);
                using (var dr = cmd.ExecuteReader())
                {
                    if (!dr.Read()) { Response.Write("{\"ok\":false,\"error\":\"Role not found.\"}"); return; }
                    roleCode = dr.GetString(0); roleName = dr.GetString(1);
                }
            }

            var sb = new StringBuilder();
            sb.Append("{\"ok\":true,\"role\":").Append(JsStr(roleName));
            sb.Append(",\"is_admin\":").Append(roleCode == "admin" ? "true" : "false");

            if (roleCode == "admin")
            {
                sb.Append(",\"total\":0,\"sections\":[]}");
                Response.Write(sb.ToString());
                return;
            }

            var sections = new List<string>();
            var secItems = new Dictionary<string, List<string>>();
            int total = 0;
            using (var cmd = new MySqlCommand(@"
                SELECT mi.section, mi.menu_slug, mi.label
                FROM sys_role_permissions rp
                JOIN sys_menu_items mi ON mi.menu_slug = rp.menu_slug AND mi.is_active = 1
                WHERE rp.role_id = @id AND rp.can_view = 1
                  AND mi.item_type IN ('subitem','standalone')
                ORDER BY mi.section, mi.sort_order, mi.label", conn))
            {
                cmd.Parameters.AddWithValue("@id", roleId);
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                    {
                        string sec = dr["section"] == DBNull.Value || string.IsNullOrEmpty(dr["section"].ToString())
                            ? "(other)" : dr["section"].ToString();
                        if (!secItems.ContainsKey(sec)) { secItems[sec] = new List<string>(); sections.Add(sec); }
                        secItems[sec].Add("{\"label\":" + JsStr(dr["label"].ToString()) +
                                          ",\"slug\":" + JsStr(dr["menu_slug"].ToString()) + "}");
                        total++;
                    }
            }

            sb.Append(",\"total\":").Append(total).Append(",\"sections\":[");
            for (int s = 0; s < sections.Count; s++)
            {
                if (s > 0) sb.Append(",");
                sb.Append("{\"name\":").Append(JsStr(sections[s])).Append(",\"items\":[")
                  .Append(string.Join(",", secItems[sections[s]])).Append("]}");
            }
            sb.Append("]}");
            Response.Write(sb.ToString());
        }
    }

    // ── A7: "Why can't user X see page Y?" diagnostic ──────────────────────────
    private void Diagnose()
    {
        string username = (Request["username"] ?? "").Trim();
        string slug     = (Request["slug"] ?? "").Trim();
        if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(slug))
        { Response.Write("{\"ok\":false,\"error\":\"Enter a username and pick a page.\"}"); return; }

        using (var conn = new MySqlConnection(ConnStr()))
        {
            conn.Open();

            // Does the page/slug exist?
            string pageLabel = null;
            using (var cmd = new MySqlCommand("SELECT label FROM sys_menu_items WHERE menu_slug=@s AND is_active=1 LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@s", slug);
                var r = cmd.ExecuteScalar();
                if (r != null && r != DBNull.Value) pageLabel = r.ToString();
            }
            if (pageLabel == null)
            {
                WriteVerdict("unknown", "No active menu item has the slug <code>" + HE(slug) + "</code>.", null);
                return;
            }

            // Does the user exist?
            long uExists = Scalar2(conn, "SELECT COUNT(*) FROM my_aspnet_users WHERE name=@u AND isAnonymous=0",
                                    "@u", username);
            if (uExists == 0)
            {
                WriteVerdict("unknown", "No login user named <code>" + HE(username) + "</code> was found.", pageLabel);
                return;
            }

            // Active roles?
            int activeRoles = 0; bool isAdmin = false;
            using (var cmd = new MySqlCommand(@"
                SELECT r.role_code FROM sys_user_roles ur
                JOIN sys_roles r ON ur.role_id=r.id AND r.is_active=1
                WHERE ur.username=@u AND ur.is_active=1 AND (ur.expires_at IS NULL OR ur.expires_at>NOW())", conn))
            {
                cmd.Parameters.AddWithValue("@u", username);
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read()) { activeRoles++; if (dr.GetString(0) == "admin") isAdmin = true; }
            }

            if (isAdmin)
            {
                WriteVerdict("allow", "User is an <b>administrator</b> (wildcard access) — they can open every screen.", pageLabel);
                return;
            }
            if (activeRoles == 0)
            {
                // any expired/inactive roles for context?
                long expired = Scalar2(conn, @"SELECT COUNT(*) FROM sys_user_roles
                    WHERE username=@u AND (is_active=0 OR (expires_at IS NOT NULL AND expires_at<=NOW()))",
                    "@u", username);
                string extra = expired > 0 ? " They have " + expired + " inactive/expired role assignment(s)." : "";
                WriteVerdict("deny", "User has <b>no active role</b>, so they are granted no screens." + extra, pageLabel);
                return;
            }

            // Which of their active roles grant this slug?
            var grantingRoles = new List<string>();
            using (var cmd = new MySqlCommand(@"
                SELECT DISTINCT r.role_name FROM sys_user_roles ur
                JOIN sys_roles r ON ur.role_id=r.id AND r.is_active=1
                JOIN sys_role_permissions rp ON rp.role_id=ur.role_id AND rp.can_view=1
                WHERE ur.username=@u AND ur.is_active=1 AND (ur.expires_at IS NULL OR ur.expires_at>NOW())
                  AND rp.menu_slug=@s", conn))
            {
                cmd.Parameters.AddWithValue("@u", username);
                cmd.Parameters.AddWithValue("@s", slug);
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read()) grantingRoles.Add(dr.GetString(0));
            }

            if (grantingRoles.Count > 0)
                WriteVerdict("allow", "User <b>can</b> open this page — granted via role(s): <b>" +
                    HE(string.Join(", ", grantingRoles)) + "</b>.", pageLabel);
            else
                WriteVerdict("deny", "None of the user's " + activeRoles +
                    " active role(s) grant this page. Grant the slug to one of their roles (Permissions tab) or assign a role that includes it.", pageLabel);
        }
    }

    private void WriteVerdict(string verdict, string message, string pageLabel)
    {
        var sb = new StringBuilder();
        sb.Append("{\"ok\":true,\"verdict\":").Append(JsStr(verdict));
        sb.Append(",\"message\":").Append(JsStr(message));
        sb.Append(",\"page\":").Append(JsStr(pageLabel ?? "")).Append("}");
        Response.Write(sb.ToString());
    }

    private static long Scalar2(MySqlConnection conn, string sql, string pName, object pVal)
    {
        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue(pName, pVal);
            object v = cmd.ExecuteScalar();
            return (v == null || v == DBNull.Value) ? 0 : Convert.ToInt64(v);
        }
    }

    private static string JsStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                       .Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
    }

    // ── helpers ──────────────────────────────────────────────────────────────
    private static string Kpi(long val, string label, string tone, string href)
    {
        return string.Format(
            "<a class='acc-kpi acc-kpi--{0}' href='{1}'><div class='acc-kpi__val'>{2:N0}</div><div class='acc-kpi__lbl'>{3}</div></a>",
            tone, href, val, HE(label));
    }

    private static string Att(string html, string btnText, string href)
    {
        return string.Format(
            "<div class='acc-att'><span class='acc-att__txt'>{0}</span><a class='urm-btn urm-btn--primary' href='{1}'>{2}</a></div>",
            html, href, HE(btnText));
    }

    private static long Scalar(MySqlConnection conn, string sql)
    {
        using (var cmd = new MySqlCommand(sql, conn))
        {
            object v = cmd.ExecuteScalar();
            return (v == null || v == DBNull.Value) ? 0 : Convert.ToInt64(v);
        }
    }

    private static string HE(string s) { return HttpUtility.HtmlEncode(s ?? ""); }

    private static string ConnStr()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
        cs = ConfigurationManager.ConnectionStrings["DefaultConnection"];
        if (cs != null) return cs.ConnectionString;
        throw new InvalidOperationException("No valid connection string.");
    }
}
