using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_UserRolePermissions : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        RoleAccessService.RequireSlug(this, "system.user_roles.permissions");

        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjax(ajax);
            return;
        }

        if (!IsPostBack)
            LoadRoleDropdown();
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
            if (action == "matrix")
            {
                string roleIdRaw = (Request.QueryString["role_id"] ?? "").Trim();
                int roleId;
                if (!int.TryParse(roleIdRaw, out roleId))
                {
                    Response.Write("{\"ok\":false,\"error\":\"Invalid role.\"}"); Response.End(); return;
                }

                string roleCode = "";
                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand("SELECT role_code FROM sys_roles WHERE id=@id AND is_active=1 LIMIT 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", roleId);
                        var r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value) { Response.Write("{\"ok\":false,\"error\":\"Role not found.\"}"); Response.End(); return; }
                        roleCode = r.ToString();
                    }
                }

                bool isAdmin = roleCode == "admin";

                // Load all menu items ordered by sort_order
                var items = LoadMenuItems();

                // Load current grants for this role
                var granted = RoleAccessService.GetRoleSlugs(roleId);

                // Count leaf items
                int total        = items.Count(i => i.Type == "leaf");
                int grantedCount = isAdmin ? total : items.Count(i => i.Type == "leaf" && granted.Contains(i.Slug));

                // Build JSON
                var sb = new StringBuilder();
                sb.Append("{\"ok\":true,\"is_admin\":");
                sb.Append(isAdmin ? "true" : "false");
                sb.Append(",\"total\":"); sb.Append(total);
                sb.Append(",\"granted_count\":"); sb.Append(grantedCount);
                sb.Append(",\"granted\":[");
                sb.Append(string.Join(",", granted.Select(s => JsonStr(s))));
                sb.Append("],\"items\":[");
                bool first = true;
                foreach (var item in items)
                {
                    if (!first) sb.Append(",");
                    first = false;
                    sb.Append("{\"type\":"); sb.Append(JsonStr(item.Type));
                    sb.Append(",\"label\":"); sb.Append(JsonStr(item.Label));
                    if (item.Type == "leaf") { sb.Append(",\"slug\":"); sb.Append(JsonStr(item.Slug)); }
                    sb.Append("}");
                }
                sb.Append("]}");
                Response.Write(sb.ToString());
            }
            else if (action == "save")
            {
                string roleIdRaw = (Request.Form["role_id"] ?? "").Trim();
                string slugsRaw  = (Request.Form["slugs"]  ?? "").Trim();

                int roleId;
                if (!int.TryParse(roleIdRaw, out roleId))
                {
                    Response.Write("{\"ok\":false,\"error\":\"Invalid role.\"}"); Response.End(); return;
                }

                // Prevent editing admin role permissions (wildcard)
                string roleCode = "";
                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand("SELECT role_code FROM sys_roles WHERE id=@id LIMIT 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", roleId);
                        var r = cmd.ExecuteScalar();
                        roleCode = r != null && r != DBNull.Value ? r.ToString() : "";
                    }
                }

                if (roleCode == "admin")
                {
                    Response.Write("{\"ok\":false,\"error\":\"Admin role permissions cannot be modified.\"}");
                    Response.End(); return;
                }

                var newSlugs = new HashSet<string>(
                    slugsRaw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                            .Select(s => s.Trim())
                            .Where(s => !string.IsNullOrEmpty(s)),
                    StringComparer.OrdinalIgnoreCase);

                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    using (var tx = conn.BeginTransaction())
                    {
                        // Remove all existing permissions for this role
                        using (var cmd = new MySqlCommand(
                            "DELETE FROM sys_role_permissions WHERE role_id=@rid", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@rid", roleId);
                            cmd.ExecuteNonQuery();
                        }

                        // Insert new permissions
                        if (newSlugs.Count > 0)
                        {
                            const string ins = @"
                                INSERT INTO sys_role_permissions (role_id, menu_slug, can_view)
                                VALUES (@rid, @slug, 1)";
                            foreach (var slug in newSlugs)
                            {
                                using (var cmd = new MySqlCommand(ins, conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@rid",  roleId);
                                    cmd.Parameters.AddWithValue("@slug", slug);
                                    cmd.ExecuteNonQuery();
                                }
                            }
                        }

                        tx.Commit();
                    }
                }

                RoleAccessService.LogAudit("UPDATE_PERMISSIONS", "role", roleIdRaw,
                    "Set " + newSlugs.Count + " permissions for role_code=" + roleCode, actor, ip);
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

    private void LoadRoleDropdown()
    {
        var sb = new StringBuilder();
        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                const string sql = @"
                    SELECT r.id, r.role_name, r.role_code, r.color_hex,
                           COUNT(DISTINCT ur.username) AS user_count
                    FROM sys_roles r
                    LEFT JOIN sys_user_roles ur
                        ON ur.role_id = r.id AND ur.is_active=1
                        AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                    WHERE r.is_active=1
                    GROUP BY r.id, r.role_name, r.role_code, r.color_hex
                    ORDER BY r.role_name";
                using (var cmd = new MySqlCommand(sql, conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string color = dr["color_hex"] == DBNull.Value ? "#174DA4" : dr["color_hex"].ToString();
                        if (string.IsNullOrEmpty(color)) color = "#174DA4";
                        sb.AppendFormat(
                            "<option value=\"{0}\" data-name=\"{1}\" data-code=\"{2}\" data-color=\"{3}\" data-users=\"{4}\">{1}</option>",
                            dr["id"],
                            HttpUtility.HtmlAttributeEncode(dr["role_name"].ToString()),
                            HttpUtility.HtmlAttributeEncode(dr["role_code"].ToString()),
                            HttpUtility.HtmlAttributeEncode(color),
                            dr["user_count"]);
                    }
                }
            }
        }
        catch { }
        litRoleOptions.Text = sb.ToString();
    }

    // ── Menu item loader ───────────────────────────────────────────────────────

    private class MenuItem
    {
        public string Type  { get; set; } // section | group | leaf
        public string Label { get; set; }
        public string Slug  { get; set; }
    }

    private List<MenuItem> LoadMenuItems()
    {
        var list = new List<MenuItem>();
        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                const string sql = @"
                    SELECT item_type, label, menu_slug
                    FROM sys_menu_items
                    WHERE is_active = 1
                    ORDER BY sort_order ASC";
                using (var cmd = new MySqlCommand(sql, conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        // Map DB enum values to the JS render types
                        string dbType = dr["item_type"].ToString();
                        string renderType;
                        switch (dbType)
                        {
                            case "heading":    renderType = "section"; break;
                            case "parent":     renderType = "group";   break;
                            default:           renderType = "leaf";    break; // subitem / standalone
                        }
                        list.Add(new MenuItem
                        {
                            Type  = renderType,
                            Label = dr["label"].ToString(),
                            Slug  = dr["menu_slug"] == DBNull.Value ? "" : dr["menu_slug"].ToString()
                        });
                    }
                }
            }
        }
        catch { }
        return list;
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
}
