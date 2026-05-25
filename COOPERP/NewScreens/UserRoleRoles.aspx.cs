using System;
using System.Configuration;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_UserRoleRoles : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        RoleAccessService.RequireSlug(this, "system.user_roles.roles");

        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjax(ajax);
            return;
        }

        if (!IsPostBack)
            LoadRoleCards();
    }

    // ── AJAX handlers ──────────────────────────────────────────────────────────

    private void HandleAjax(string action)
    {
        Response.ContentType = "application/json";
        Response.Cache.SetNoStore();

        string actor = Session["username"] as string ?? "unknown";
        string ip    = Request.UserHostAddress;

        try
        {
            if (action == "create")
            {
                string name  = (Request.Form["name"]  ?? "").Trim();
                string code  = (Request.Form["code"]  ?? "").Trim().ToLower();
                string color = (Request.Form["color"] ?? "#174DA4").Trim();
                string desc  = (Request.Form["desc"]  ?? "").Trim();

                if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(code))
                {
                    Response.Write("{\"ok\":false,\"error\":\"Name and code are required.\"}");
                    Response.End(); return;
                }

                if (!System.Text.RegularExpressions.Regex.IsMatch(code, @"^[a-z0-9_]+$"))
                {
                    Response.Write("{\"ok\":false,\"error\":\"Role code may only contain lowercase letters, digits and underscores.\"}");
                    Response.End(); return;
                }

                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    using (var chk = new MySqlCommand(
                        "SELECT COUNT(*) FROM sys_roles WHERE role_code=@c", conn))
                    {
                        chk.Parameters.AddWithValue("@c", code);
                        if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        {
                            Response.Write("{\"ok\":false,\"error\":\"A role with that code already exists.\"}");
                            Response.End(); return;
                        }
                    }
                    using (var cmd = new MySqlCommand(
                        @"INSERT INTO sys_roles (role_name, role_code, color_hex, description, is_active)
                          VALUES (@n, @c, @col, @d, 1)", conn))
                    {
                        cmd.Parameters.AddWithValue("@n",   name);
                        cmd.Parameters.AddWithValue("@c",   code);
                        cmd.Parameters.AddWithValue("@col", color);
                        cmd.Parameters.AddWithValue("@d",   string.IsNullOrEmpty(desc) ? (object)DBNull.Value : (object)desc);
                        cmd.ExecuteNonQuery();
                    }
                }

                RoleAccessService.LogAudit("CREATE_ROLE", "role", code,
                    "Created role '" + name + "'", actor, ip);
                Response.Write("{\"ok\":true}");
            }
            else if (action == "update")
            {
                string idRaw = (Request.Form["id"]    ?? "").Trim();
                string name  = (Request.Form["name"]  ?? "").Trim();
                string color = (Request.Form["color"] ?? "#174DA4").Trim();
                string desc  = (Request.Form["desc"]  ?? "").Trim();

                int roleId;
                if (!int.TryParse(idRaw, out roleId) || string.IsNullOrEmpty(name))
                {
                    Response.Write("{\"ok\":false,\"error\":\"Invalid request.\"}");
                    Response.End(); return;
                }

                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand(
                        @"UPDATE sys_roles SET role_name=@n, color_hex=@col, description=@d
                          WHERE id=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@n",   name);
                        cmd.Parameters.AddWithValue("@col", color);
                        cmd.Parameters.AddWithValue("@d",   string.IsNullOrEmpty(desc) ? (object)DBNull.Value : (object)desc);
                        cmd.Parameters.AddWithValue("@id",  roleId);
                        cmd.ExecuteNonQuery();
                    }
                }

                RoleAccessService.LogAudit("UPDATE_ROLE", "role", idRaw,
                    "Updated role '" + name + "'", actor, ip);
                Response.Write("{\"ok\":true}");
            }
            else if (action == "delete")
            {
                string idRaw = (Request.Form["id"] ?? "").Trim();
                int roleId;
                if (!int.TryParse(idRaw, out roleId))
                {
                    Response.Write("{\"ok\":false,\"error\":\"Invalid role ID.\"}");
                    Response.End(); return;
                }

                string roleCode = "";
                string roleName = "";
                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    using (var nm = new MySqlCommand(
                        "SELECT role_name, role_code FROM sys_roles WHERE id=@id", conn))
                    {
                        nm.Parameters.AddWithValue("@id", roleId);
                        using (var dr = nm.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                roleName = dr.GetString(0);
                                roleCode = dr.GetString(1);
                            }
                        }
                    }

                    if (roleCode == "admin")
                    {
                        Response.Write("{\"ok\":false,\"error\":\"The admin role cannot be deleted.\"}");
                        Response.End(); return;
                    }

                    using (var cmd = new MySqlCommand(
                        "UPDATE sys_roles SET is_active=0 WHERE id=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", roleId);
                        cmd.ExecuteNonQuery();
                    }
                    using (var cmd = new MySqlCommand(
                        "UPDATE sys_user_roles SET is_active=0 WHERE role_id=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", roleId);
                        cmd.ExecuteNonQuery();
                    }
                }

                RoleAccessService.LogAudit("DELETE_ROLE", "role", idRaw,
                    "Deleted role '" + roleName + "'", actor, ip);
                Response.Write("{\"ok\":true}");
            }
            else
            {
                Response.Write("{\"ok\":false,\"error\":\"Unknown action.\"}");
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"error\":" + JsonStr(ex.Message) + "}");
        }

        Response.End();
    }

    // ── Page render ────────────────────────────────────────────────────────────

    private void LoadRoleCards()
    {
        var cardsSb = new StringBuilder();
        var statsSb = new StringBuilder();

        int totalRoles     = 0;
        int totalAssigned  = 0;
        int adminRoleCount = 0;

        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();

                const string sql = @"
                    SELECT
                        r.id,
                        r.role_name,
                        r.role_code,
                        r.color_hex,
                        r.description,
                        COUNT(DISTINCT ur.username) AS user_count,
                        COUNT(DISTINCT rp.menu_slug) AS perm_count
                    FROM sys_roles r
                    LEFT JOIN sys_user_roles ur
                        ON ur.role_id = r.id
                        AND ur.is_active = 1
                        AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                    LEFT JOIN sys_role_permissions rp
                        ON rp.role_id = r.id AND rp.can_view = 1
                    WHERE r.is_active = 1
                    GROUP BY r.id, r.role_name, r.role_code, r.color_hex, r.description
                    ORDER BY r.role_name ASC";

                using (var cmd = new MySqlCommand(sql, conn))
                using (var dr  = cmd.ExecuteReader())
                {
                    bool any = false;
                    while (dr.Read())
                    {
                        any = true;
                        int    id        = Convert.ToInt32(dr["id"]);
                        string name      = dr["role_name"].ToString();
                        string code      = dr["role_code"].ToString();
                        string color     = dr["color_hex"].ToString();
                        string desc      = dr["description"] == DBNull.Value ? "" : dr["description"].ToString();
                        int    userCount = Convert.ToInt32(dr["user_count"]);
                        int    permCount = Convert.ToInt32(dr["perm_count"]);

                        if (string.IsNullOrEmpty(color)) color = "#174DA4";
                        bool isAdmin = code == "admin";

                        totalRoles++;
                        totalAssigned += userCount;
                        if (isAdmin) adminRoleCount++;

                        string searchVal = (name + " " + code + " " + desc).ToLower();

                        // ── Card ──────────────────────────────────────────────
                        cardsSb.AppendFormat(
                            "<div class=\"role-card\" data-search=\"{0}\">",
                            HttpUtility.HtmlAttributeEncode(searchVal));

                        // Color bar
                        cardsSb.AppendFormat(
                            "<div class=\"role-card__bar\" style=\"background:{0}\"></div>",
                            HttpUtility.HtmlAttributeEncode(color));

                        // Body
                        cardsSb.Append("<div class=\"role-card__body\">");

                        // Name row
                        cardsSb.Append("<div class=\"role-card__title-row\">");
                        cardsSb.AppendFormat(
                            "<div class=\"role-card__name\">{0}</div>",
                            HttpUtility.HtmlEncode(name));
                        if (isAdmin)
                            cardsSb.Append("<span class=\"role-card__sys\">SYSTEM</span>");
                        cardsSb.Append("</div>");

                        // Code badge
                        cardsSb.AppendFormat(
                            "<span class=\"role-card__code\">{0}</span>",
                            HttpUtility.HtmlEncode(code));

                        // Description
                        if (!string.IsNullOrEmpty(desc))
                            cardsSb.AppendFormat(
                                "<div class=\"role-card__desc\">{0}</div>",
                                HttpUtility.HtmlEncode(desc));
                        else
                            cardsSb.Append("<div class=\"role-card__desc\"></div>");

                        // Stats row
                        string permLabel = isAdmin ? "all" : permCount.ToString();
                        cardsSb.Append("<div class=\"role-card__stats\">");
                        cardsSb.AppendFormat(
                            "<div class=\"role-card__kv\">" +
                            "<span class=\"role-card__kv-num\">{0}</span>" +
                            "<span class=\"role-card__kv-lbl\">user{1}</span></div>",
                            userCount, userCount == 1 ? "" : "s");
                        cardsSb.Append("<div class=\"role-card__kv-sep\"></div>");
                        cardsSb.AppendFormat(
                            "<div class=\"role-card__kv\">" +
                            "<span class=\"role-card__kv-num\">{0}</span>" +
                            "<span class=\"role-card__kv-lbl\">permission{1}</span></div>",
                            permLabel, isAdmin || permCount != 1 ? "s" : "");
                        cardsSb.Append("</div>");

                        cardsSb.Append("</div>"); // .role-card__body

                        // Footer
                        cardsSb.Append("<div class=\"role-card__foot\">");

                        // Edit button
                        cardsSb.AppendFormat(
                            "<button type=\"button\" class=\"urm-btn urm-btn--outline urm-btn--sm\" " +
                            "onclick=\"openEditModal({0},'{1}','{2}','{3}','{4}')\">" +
                            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"11\" height=\"11\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7\"/><path d=\"M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z\"/></svg>" +
                            "Edit</button>",
                            id,
                            JsStr(name),
                            JsStr(code),
                            JsStr(color),
                            JsStr(desc));

                        // Permissions link
                        cardsSb.AppendFormat(
                            "<a href=\"UserRolePermissions.aspx?role_id={0}\" class=\"urm-btn urm-btn--ghost urm-btn--sm\">" +
                            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"11\" height=\"11\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><rect x=\"3\" y=\"11\" width=\"18\" height=\"11\" rx=\"2\" ry=\"2\"/><path d=\"M7 11V7a5 5 0 0 1 10 0v4\"/></svg>" +
                            "Permissions</a>",
                            id);

                        // Delete button (not for admin)
                        if (!isAdmin)
                        {
                            cardsSb.AppendFormat(
                                "<button type=\"button\" class=\"urm-btn urm-btn--danger urm-btn--sm\" " +
                                "style=\"margin-left:auto;\" onclick=\"openDeleteModal({0},'{1}')\">" +
                                "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"11\" height=\"11\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polyline points=\"3 6 5 6 21 6\"/><path d=\"M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6\"/></svg>" +
                                "Delete</button>",
                                id,
                                JsStr(name));
                        }

                        cardsSb.Append("</div>"); // .role-card__foot
                        cardsSb.Append("</div>"); // .role-card
                    }

                    if (!any)
                        cardsSb.Append("<div class=\"empty-state\">No roles found. Click <strong>New Role</strong> to get started.</div>");
                }
            }
        }
        catch (Exception ex)
        {
            cardsSb.Append("<div class=\"empty-state\" style=\"color:#dc2626;\">" +
                           HttpUtility.HtmlEncode("Error loading roles: " + ex.Message) + "</div>");
        }

        litCards.Text = cardsSb.ToString();

        // ── Stat chips ────────────────────────────────────────────────────────
        statsSb.Append("<div class=\"pa-list-stats\">");
        statsSb.AppendFormat(
            "<span class=\"pa-list-stat ps--all\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Active Role{1}</span></span>",
            totalRoles, totalRoles == 1 ? "" : "s");
        statsSb.AppendFormat(
            "<span class=\"pa-list-stat ps--users\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">User Assignment{1}</span></span>",
            totalAssigned, totalAssigned == 1 ? "" : "s");
        if (adminRoleCount > 0)
            statsSb.AppendFormat(
                "<span class=\"pa-list-stat ps--admin\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">System Role{1}</span></span>",
                adminRoleCount, adminRoleCount == 1 ? "" : "s");
        statsSb.Append("</div>");
        litStats.Text = statsSb.ToString();
    }

    // ── Utilities ──────────────────────────────────────────────────────────────

    private static string ConnStr()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
        cs = ConfigurationManager.ConnectionStrings["DefaultConnection"];
        if (cs != null) return cs.ConnectionString;
        throw new InvalidOperationException("No valid connection string.");
    }

    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"")
                       .Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
    }

    private static string JsStr(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("'", "\\'")
                .Replace("\r", "").Replace("\n", "").Replace("\"", "&quot;");
    }
}
