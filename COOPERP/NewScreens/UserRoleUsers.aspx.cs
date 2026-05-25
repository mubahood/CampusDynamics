using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_UserRoleUsers : System.Web.UI.Page
{
    // ── Inner models ──────────────────────────────────────────────────────────

    private class UserRow
    {
        public string Username    { get; set; }
        public string DisplayName { get; set; }
        public string Email       { get; set; }
        public string EmpCode     { get; set; }
        public string Department  { get; set; }
        public string Designation { get; set; }
        public string EmpType     { get; set; }
        public bool   IsStaff     { get; set; }
        public string LastLogin   { get; set; }  // formatted string, "" = never
        public bool   IsApproved  { get; set; }
        public bool   IsLocked    { get; set; }
    }

    private class RoleEntry
    {
        public int    Id      { get; set; }
        public string Name    { get; set; }
        public string Color   { get; set; }
        public string Expires { get; set; }
    }

    // ── Page lifecycle ────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        RoleAccessService.RequireSlug(this, "system.user_roles.users");

        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjax(ajax);
            return;
        }

        if (!IsPostBack)
        {
            LoadRoleOptions();
            LoadUserRows();
        }
    }

    // ── AJAX handlers ─────────────────────────────────────────────────────────

    private void HandleAjax(string action)
    {
        Response.ContentType = "application/json";
        Response.Cache.SetNoStore();

        string actor = Session["username"] as string ?? "unknown";
        string ip    = Request.UserHostAddress;

        try
        {
            if (action == "assign")
            {
                string username  = (Request.Form["username"] ?? "").Trim();
                string roleIdRaw = (Request.Form["role_id"]  ?? "").Trim();
                string expiry    = (Request.Form["expiry"]   ?? "").Trim();
                string notes     = (Request.Form["notes"]    ?? "").Trim();

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(roleIdRaw))
                { Response.Write("{\"ok\":false,\"error\":\"Missing required fields.\"}"); Response.End(); return; }

                int roleId;
                if (!int.TryParse(roleIdRaw, out roleId))
                { Response.Write("{\"ok\":false,\"error\":\"Invalid role.\"}"); Response.End(); return; }

                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    const string upsert = @"
                        INSERT INTO sys_user_roles (username,role_id,expires_at,notes,assigned_by,is_active)
                        VALUES (@u,@rid,@exp,@notes,@by,1)
                        ON DUPLICATE KEY UPDATE
                            is_active=1,expires_at=@exp,notes=@notes,
                            assigned_by=@by,assigned_at=NOW()";
                    using (var cmd = new MySqlCommand(upsert, conn))
                    {
                        cmd.Parameters.AddWithValue("@u",     username);
                        cmd.Parameters.AddWithValue("@rid",   roleId);
                        cmd.Parameters.AddWithValue("@exp",   string.IsNullOrEmpty(expiry) ? (object)DBNull.Value : (object)expiry);
                        cmd.Parameters.AddWithValue("@notes", string.IsNullOrEmpty(notes)  ? (object)DBNull.Value : (object)notes);
                        cmd.Parameters.AddWithValue("@by",    actor);
                        cmd.ExecuteNonQuery();
                    }
                    string roleName = "";
                    using (var cmd = new MySqlCommand("SELECT role_name FROM sys_roles WHERE id=@id LIMIT 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", roleId);
                        var r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) roleName = r.ToString();
                    }
                    RoleAccessService.LogAudit("ASSIGN_ROLE", "user", username,
                        "Assigned role '" + roleName + "'" + (string.IsNullOrEmpty(notes) ? "" : ": " + notes),
                        actor, ip);
                }
                Response.Write("{\"ok\":true}");
            }
            else if (action == "revoke")
            {
                string username  = (Request.Form["username"] ?? "").Trim();
                string roleIdRaw = (Request.Form["role_id"]  ?? "").Trim();

                if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(roleIdRaw))
                { Response.Write("{\"ok\":false,\"error\":\"Missing required fields.\"}"); Response.End(); return; }

                int roleId;
                if (!int.TryParse(roleIdRaw, out roleId))
                { Response.Write("{\"ok\":false,\"error\":\"Invalid role.\"}"); Response.End(); return; }

                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    string roleName = "";
                    using (var cmd = new MySqlCommand("SELECT role_name FROM sys_roles WHERE id=@id LIMIT 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", roleId);
                        var r = cmd.ExecuteScalar();
                        if (r != null && r != DBNull.Value) roleName = r.ToString();
                    }
                    using (var cmd = new MySqlCommand(
                        "UPDATE sys_user_roles SET is_active=0 WHERE username=@u AND role_id=@rid", conn))
                    {
                        cmd.Parameters.AddWithValue("@u",   username);
                        cmd.Parameters.AddWithValue("@rid", roleId);
                        cmd.ExecuteNonQuery();
                    }
                    RoleAccessService.LogAudit("REVOKE_ROLE", "user", username,
                        "Revoked role '" + roleName + "'", actor, ip);
                }
                Response.Write("{\"ok\":true}");
            }
            else if (action == "batch_assign")
            {
                string usernamesRaw = (Request.Form["usernames"] ?? "").Trim();
                string roleIdRaw    = (Request.Form["role_id"]   ?? "").Trim();
                string expiry       = (Request.Form["expiry"]    ?? "").Trim();
                string notes        = (Request.Form["notes"]     ?? "").Trim();

                if (string.IsNullOrEmpty(usernamesRaw) || string.IsNullOrEmpty(roleIdRaw))
                { Response.Write("{\"ok\":false,\"error\":\"Missing required fields.\"}"); Response.End(); return; }

                int roleId;
                if (!int.TryParse(roleIdRaw, out roleId))
                { Response.Write("{\"ok\":false,\"error\":\"Invalid role.\"}"); Response.End(); return; }

                var usernames = usernamesRaw
                    .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(u => u.Trim())
                    .Where(u => !string.IsNullOrEmpty(u))
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .ToList();

                if (usernames.Count == 0)
                { Response.Write("{\"ok\":false,\"error\":\"No users specified.\"}"); Response.End(); return; }

                string roleName = "";
                int count = 0;
                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand("SELECT role_name FROM sys_roles WHERE id=@id AND is_active=1 LIMIT 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", roleId);
                        var r = cmd.ExecuteScalar();
                        if (r == null || r == DBNull.Value)
                        { Response.Write("{\"ok\":false,\"error\":\"Role not found.\"}"); Response.End(); return; }
                        roleName = r.ToString();
                    }

                    const string upsert = @"
                        INSERT INTO sys_user_roles (username,role_id,expires_at,notes,assigned_by,is_active)
                        VALUES (@u,@rid,@exp,@notes,@by,1)
                        ON DUPLICATE KEY UPDATE
                            is_active=1,expires_at=@exp,notes=@notes,
                            assigned_by=@by,assigned_at=NOW()";

                    foreach (var uname in usernames)
                    {
                        using (var cmd = new MySqlCommand(upsert, conn))
                        {
                            cmd.Parameters.AddWithValue("@u",     uname);
                            cmd.Parameters.AddWithValue("@rid",   roleId);
                            cmd.Parameters.AddWithValue("@exp",   string.IsNullOrEmpty(expiry) ? (object)DBNull.Value : (object)expiry);
                            cmd.Parameters.AddWithValue("@notes", string.IsNullOrEmpty(notes)  ? (object)DBNull.Value : (object)notes);
                            cmd.Parameters.AddWithValue("@by",    actor);
                            cmd.ExecuteNonQuery();
                        }
                        count++;
                    }
                }

                RoleAccessService.LogAudit("BATCH_ASSIGN_ROLE", "role", roleId.ToString(),
                    "Batch assigned role '" + roleName + "' to " + count + " user(s): " +
                    string.Join(", ", usernames.Take(10)) + (usernames.Count > 10 ? "..." : ""),
                    actor, ip);

                Response.Write("{\"ok\":true,\"count\":" + count + "}");
            }
            else if (action == "batch_revoke_all")
            {
                string usernamesRaw = (Request.Form["usernames"] ?? "").Trim();

                if (string.IsNullOrEmpty(usernamesRaw))
                { Response.Write("{\"ok\":false,\"error\":\"No users specified.\"}"); Response.End(); return; }

                var usernames = usernamesRaw
                    .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                    .Select(u => u.Trim())
                    .Where(u => !string.IsNullOrEmpty(u))
                    .Distinct(StringComparer.OrdinalIgnoreCase)
                    .ToList();

                if (usernames.Count == 0)
                { Response.Write("{\"ok\":false,\"error\":\"No users specified.\"}"); Response.End(); return; }

                int count = 0;
                using (var conn = new MySqlConnection(ConnStr()))
                {
                    conn.Open();
                    foreach (var uname in usernames)
                    {
                        using (var cmd = new MySqlCommand(
                            "UPDATE sys_user_roles SET is_active=0 WHERE username=@u", conn))
                        {
                            cmd.Parameters.AddWithValue("@u", uname);
                            int affected = cmd.ExecuteNonQuery();
                            if (affected > 0) count++;
                        }
                    }
                }

                RoleAccessService.LogAudit("BATCH_REVOKE_ALL_ROLES", "user", "batch",
                    "Batch revoked all roles from " + count + " user(s): " +
                    string.Join(", ", usernames.Take(10)) + (usernames.Count > 10 ? "..." : ""),
                    actor, ip);

                Response.Write("{\"ok\":true,\"count\":" + count + "}");
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

    // ── Page render helpers ───────────────────────────────────────────────────

    private void LoadRoleOptions()
    {
        var sb = new StringBuilder();
        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT id, role_name FROM sys_roles WHERE is_active=1 ORDER BY role_name", conn))
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                        sb.AppendFormat("<option value=\"{0}\">{1}</option>",
                            dr["id"], HttpUtility.HtmlEncode(dr["role_name"].ToString()));
            }
        }
        catch { }
        litRoleOptions.Text = sb.ToString();
    }

    private void LoadUserRows()
    {
        var rows   = new StringBuilder();
        var stats  = new StringBuilder();

        int cntTotal   = 0;
        int cntStaff   = 0;
        int cntRoles   = 0;
        int cntNoRole  = 0;
        int cntLocked  = 0;

        try
        {
            using (var conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();

                // ── Load users with membership and employee details ──────────
                const string sql = @"
                    SELECT
                        u.name                                              AS UserName,
                        COALESCE(e.emp_name,   '')                         AS display_name,
                        COALESCE(m.Email,      '')                         AS email,
                        COALESCE(e.EMP_CODE,   '')                         AS emp_code,
                        COALESCE(d.dept_name,  '')                         AS dept_name,
                        COALESCE(j.jobname,    '')                         AS designation,
                        COALESCE(e.EmpType,    '')                         AS emp_type,
                        CASE WHEN e.empID IS NOT NULL THEN 1 ELSE 0 END   AS is_staff,
                        m.LastLoginDate,
                        COALESCE(m.IsApproved,  1)                         AS is_approved,
                        COALESCE(m.IsLockedOut, 0)                         AS is_locked
                    FROM my_aspnet_users u
                    LEFT JOIN hrm_employee e
                        ON UPPER(TRIM(e.usernames)) = UPPER(TRIM(u.name))
                    LEFT JOIN hrm_emp_contracts c
                        ON c.empID = e.empID
                        AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
                    LEFT JOIN hrm_departments d ON d.ID = c.departmentID
                    LEFT JOIN hrm_jobs j        ON j.ID = c.jobID
                    LEFT JOIN my_aspnet_membership m ON m.userId = u.id
                    WHERE u.isAnonymous = 0
                    ORDER BY
                        (CASE WHEN e.empID IS NOT NULL THEN 0 ELSE 1 END),
                        COALESCE(e.emp_name, u.name)";

                var users = new List<UserRow>();
                using (var cmd = new MySqlCommand(sql, conn))
                using (var dr  = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string lastLogin = "";
                        if (dr["LastLoginDate"] != DBNull.Value)
                        {
                            var dt = Convert.ToDateTime(dr["LastLoginDate"]);
                            if (dt.Year > 2000)
                                lastLogin = dt.ToString("dd MMM yyyy");
                        }

                        users.Add(new UserRow
                        {
                            Username    = dr["UserName"].ToString(),
                            DisplayName = dr["display_name"].ToString(),
                            Email       = dr["email"].ToString(),
                            EmpCode     = dr["emp_code"].ToString(),
                            Department  = dr["dept_name"].ToString(),
                            Designation = dr["designation"].ToString(),
                            EmpType     = dr["emp_type"].ToString(),
                            IsStaff     = Convert.ToInt32(dr["is_staff"]) == 1,
                            LastLogin   = lastLogin,
                            IsApproved  = Convert.ToInt32(dr["is_approved"])  != 0,
                            IsLocked    = Convert.ToInt32(dr["is_locked"])    != 0
                        });
                    }
                }

                // ── Load active role assignments ─────────────────────────────
                const string rolesSql = @"
                    SELECT ur.username, r.id, r.role_name, r.color_hex, ur.expires_at
                    FROM sys_user_roles ur
                    JOIN sys_roles r ON ur.role_id = r.id
                    WHERE ur.is_active = 1
                      AND r.is_active  = 1
                      AND (ur.expires_at IS NULL OR ur.expires_at > NOW())
                    ORDER BY ur.username, r.role_name";

                var roleMap = new Dictionary<string, List<RoleEntry>>(StringComparer.OrdinalIgnoreCase);
                using (var cmd = new MySqlCommand(rolesSql, conn))
                using (var dr  = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        string uname = dr["username"].ToString();
                        if (!roleMap.ContainsKey(uname))
                            roleMap[uname] = new List<RoleEntry>();
                        string exp = dr["expires_at"] == DBNull.Value
                            ? ""
                            : Convert.ToDateTime(dr["expires_at"]).ToString("yyyy-MM-dd");
                        roleMap[uname].Add(new RoleEntry
                        {
                            Id      = Convert.ToInt32(dr["id"]),
                            Name    = dr["role_name"].ToString(),
                            Color   = dr["color_hex"].ToString(),
                            Expires = exp
                        });
                    }
                }

                // ── SVG icon strings ─────────────────────────────────────────
                const string icoChevron =
                    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"11\" height=\"11\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polyline points=\"6 9 12 15 18 9\"/></svg>";
                const string icoPlus =
                    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"13\" height=\"13\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><line x1=\"12\" y1=\"5\" x2=\"12\" y2=\"19\"/><line x1=\"5\" y1=\"12\" x2=\"19\" y2=\"12\"/></svg>";
                const string icoX =
                    "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"13\" height=\"13\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><line x1=\"18\" y1=\"6\" x2=\"6\" y2=\"18\"/><line x1=\"6\" y1=\"6\" x2=\"18\" y2=\"18\"/></svg>";

                // ── Build rows ───────────────────────────────────────────────
                int rowNum = 0;

                foreach (var user in users)
                {
                    string uEnc  = HttpUtility.HtmlEncode(user.Username);
                    string uAttr = HttpUtility.HtmlAttributeEncode(user.Username);

                    List<RoleEntry> roles;
                    bool hasRoles = roleMap.TryGetValue(user.Username, out roles) && roles.Count > 0;

                    // Detect user type for filter
                    string userType = GetUserType(user.IsStaff, user.Username);

                    // Detect account status for filter
                    string statusKey;
                    if (user.IsLocked)            statusKey = "locked";
                    else if (!user.IsApproved)    statusKey = "inactive";
                    else                          statusKey = "active";

                    // Build search string
                    string searchVal = (user.Username + " " + user.DisplayName + " " +
                                        user.Email + " " + user.Department + " " +
                                        user.EmpCode + " " + user.Designation).ToLower();

                    // Count stats
                    cntTotal++;
                    if (user.IsStaff)  cntStaff++;
                    if (hasRoles)      cntRoles++;
                    else               cntNoRole++;
                    if (user.IsLocked) cntLocked++;

                    rowNum++;

                    rows.Append("<tr class=\"pa-row\"");
                    rows.AppendFormat(" data-search=\"{0}\"",  HttpUtility.HtmlEncode(searchVal));
                    rows.AppendFormat(" data-type=\"{0}\"",    userType);
                    rows.AppendFormat(" data-hasrole=\"{0}\"", hasRoles ? "1" : "0");
                    rows.AppendFormat(" data-status=\"{0}\"",  statusKey);
                    rows.Append(">");

                    // ── Checkbox ───────────────────────────────────────────
                    rows.AppendFormat(
                        "<td class=\"pa-col-chk\"><input type=\"checkbox\" class=\"pa-row-chk\" value=\"{0}\" onclick=\"onRowCheck(this,event)\" /></td>",
                        uAttr);

                    // ── # ──────────────────────────────────────────────────
                    rows.AppendFormat("<td class=\"pa-col-num\">{0}</td>", rowNum);

                    // ── Account (avatar + username + email) ────────────────
                    string initials   = GetInitials(user.DisplayName, user.Username);
                    string avatarColor= GetAvatarColor(user.Username);
                    string emailEnc   = HttpUtility.HtmlEncode(user.Email);

                    rows.Append("<td>");
                    rows.Append("<div class=\"uru-user\">");
                    rows.AppendFormat(
                        "<div class=\"uru-avatar\" style=\"background:{0}\">{1}</div>",
                        avatarColor, initials);
                    rows.Append("<div>");
                    rows.AppendFormat("<div class=\"uru-user__name\">{0}</div>", uEnc);
                    if (!string.IsNullOrEmpty(user.Email))
                        rows.AppendFormat("<div class=\"uru-user__email\">{0}</div>", emailEnc);
                    rows.Append("</div></div></td>");

                    // ── Full Name / Employee ───────────────────────────────
                    rows.Append("<td>");
                    string nameToShow = (!string.IsNullOrEmpty(user.DisplayName) && user.DisplayName != user.Username)
                        ? HttpUtility.HtmlEncode(user.DisplayName)
                        : "<span style=\"color:#bbb;font-style:italic;\">No name</span>";
                    rows.AppendFormat("<div class=\"uru-emp__name\">{0}</div>", nameToShow);
                    if (!string.IsNullOrEmpty(user.EmpCode))
                        rows.AppendFormat("<div class=\"uru-emp__code\">{0}</div>",
                            HttpUtility.HtmlEncode(user.EmpCode));
                    if (!string.IsNullOrEmpty(user.Designation))
                        rows.AppendFormat("<div class=\"uru-emp__desg\">{0}</div>",
                            HttpUtility.HtmlEncode(user.Designation));
                    rows.Append("</td>");

                    // ── Department / Type ──────────────────────────────────
                    rows.Append("<td>");
                    if (!string.IsNullOrEmpty(user.Department))
                    {
                        rows.AppendFormat("<div style=\"font-size:12px;color:#333;\">{0}</div>",
                            HttpUtility.HtmlEncode(user.Department));
                    }
                    // Type badge
                    string typeLabel, typeCls;
                    switch (userType)
                    {
                        case "staff":
                            typeLabel = !string.IsNullOrEmpty(user.EmpType)
                                ? user.EmpType : "Staff";
                            typeCls   = "uru-type--staff";   break;
                        case "student":
                            typeLabel = "Student"; typeCls = "uru-type--student"; break;
                        default:
                            typeLabel = "System";  typeCls = "uru-type--system";  break;
                    }
                    rows.AppendFormat("<span class=\"uru-type {0}\" style=\"margin-top:{1}px\">{2}</span>",
                        typeCls,
                        string.IsNullOrEmpty(user.Department) ? 0 : 4,
                        HttpUtility.HtmlEncode(typeLabel));
                    rows.Append("</td>");

                    // ── Assigned Roles ─────────────────────────────────────
                    rows.Append("<td>");
                    if (hasRoles)
                    {
                        foreach (var role in roles)
                        {
                            string color = string.IsNullOrEmpty(role.Color) ? "#64748b" : role.Color;
                            rows.AppendFormat(
                                "<span class=\"role-badge\" style=\"background:{0}\">{1}</span>",
                                HttpUtility.HtmlEncode(color),
                                HttpUtility.HtmlEncode(role.Name));
                        }
                        // Show expiry if any
                        var exps = new List<string>();
                        foreach (var role in roles)
                            if (!string.IsNullOrEmpty(role.Expires)) exps.Add(role.Expires);
                        if (exps.Count > 0)
                            rows.AppendFormat(
                                "<div style=\"font-size:10px;color:#888;margin-top:3px;\">Expires: {0}</div>",
                                HttpUtility.HtmlEncode(string.Join(", ", exps)));
                    }
                    else
                    {
                        rows.Append("<span class=\"no-role\">No role assigned</span>");
                    }
                    rows.Append("</td>");

                    // ── Last Active ────────────────────────────────────────
                    rows.Append("<td style=\"font-size:11px;color:#555;\">");
                    rows.Append(string.IsNullOrEmpty(user.LastLogin)
                        ? "<span style=\"color:#bbb\">Never</span>"
                        : HttpUtility.HtmlEncode(user.LastLogin));
                    rows.Append("</td>");

                    // ── Status ─────────────────────────────────────────────
                    rows.Append("<td>");
                    string statusLabel, statusCls;
                    if (user.IsLocked)         { statusLabel = "Locked";   statusCls = "uru-status--locked";   }
                    else if (!user.IsApproved) { statusLabel = "Inactive"; statusCls = "uru-status--inactive"; }
                    else                       { statusLabel = "Active";   statusCls = "uru-status--active";   }
                    rows.AppendFormat("<span class=\"uru-status {0}\">{1}</span>", statusCls, statusLabel);
                    rows.Append("</td>");

                    // ── Actions dropdown ───────────────────────────────────
                    rows.Append("<td class=\"pa-col-act\">");
                    rows.Append("<div class=\"pa-act-menu\">");
                    rows.AppendFormat(
                        "<button type=\"button\" class=\"pa-act-btn\" onclick=\"toggleActMenu(this)\">Actions {0}</button>",
                        icoChevron);
                    rows.Append("<div class=\"pa-act-drop\">");
                    rows.AppendFormat(
                        "<button type=\"button\" class=\"pa-act-item\" data-action=\"assign\" data-uname=\"{0}\">{1} Assign Role</button>",
                        uAttr, icoPlus);
                    if (hasRoles)
                    {
                        rows.Append("<div class=\"pa-act-sep\"></div>");
                        foreach (var role in roles)
                        {
                            rows.AppendFormat(
                                "<button type=\"button\" class=\"pa-act-item pa-act-item--danger\" data-action=\"revoke\" data-uname=\"{0}\" data-rid=\"{1}\" data-rname=\"{2}\">{3} Revoke {4}</button>",
                                uAttr,
                                role.Id,
                                HttpUtility.HtmlAttributeEncode(role.Name),
                                icoX,
                                HttpUtility.HtmlEncode(role.Name));
                        }
                    }
                    rows.Append("</div></div></td>");
                    rows.Append("</tr>");
                }
            }
        }
        catch (Exception ex)
        {
            rows.AppendFormat(
                "<tr><td colspan=\"9\" style=\"color:#dc2626;padding:20px\">{0}</td></tr>",
                HttpUtility.HtmlEncode("Error: " + ex.Message));
        }

        litRows.Text = rows.ToString();

        // ── Stat chips ────────────────────────────────────────────────────────
        stats.Append("<div class=\"pa-list-stats\">");
        stats.AppendFormat(
            "<span class=\"pa-list-stat ps--all\" onclick=\"filterByChip('','')\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Total</span></span>",
            cntTotal);
        stats.AppendFormat(
            "<span class=\"pa-list-stat ps--staff\" onclick=\"filterByChip('staff','')\" title=\"Has an employee record\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Staff</span></span>",
            cntStaff);
        stats.AppendFormat(
            "<span class=\"pa-list-stat ps--roles\" onclick=\"filterByChip('','1')\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">With Role</span></span>",
            cntRoles);
        stats.AppendFormat(
            "<span class=\"pa-list-stat ps--norole\" onclick=\"filterByChip('','0')\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">No Role</span></span>",
            cntNoRole);
        if (cntLocked > 0)
            stats.AppendFormat(
                "<span class=\"pa-list-stat ps--locked\" onclick=\"filterByChip('','')\" title=\"Click, then filter by Locked status\"><b>{0}</b>&nbsp;<span class=\"pa-list-stat__lbl\">Locked</span></span>",
                cntLocked);
        stats.Append("</div>");
        litStats.Text = stats.ToString();
    }

    // ── Helper methods ────────────────────────────────────────────────────────

    private static readonly string[] AvatarColors = {
        "#174DA4","#2e7d32","#6a1b9a","#00838f",
        "#c62828","#4527a0","#00695c","#ad1457",
        "#e65100","#37474f"
    };

    private static string GetAvatarColor(string username)
    {
        if (string.IsNullOrEmpty(username)) return AvatarColors[0];
        int hash = 0;
        foreach (char c in username) hash = (hash * 31 + (int)c) & 0x7fffffff;
        return AvatarColors[hash % AvatarColors.Length];
    }

    private static string GetInitials(string displayName, string username)
    {
        string name = (!string.IsNullOrEmpty(displayName) && displayName != username)
            ? displayName : username;
        var parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length >= 2)
            return ("" + parts[0][0] + parts[1][0]).ToUpper();
        return name.Length >= 2 ? name.Substring(0, 2).ToUpper()
             : name.Length == 1 ? name[0].ToString().ToUpper()
             : "?";
    }

    private static string GetUserType(bool isStaff, string username)
    {
        if (isStaff) return "staff";
        if (!string.IsNullOrEmpty(username) && username.IndexOf('/') >= 0) return "student";
        return "system";
    }

    // ── Utilities ─────────────────────────────────────────────────────────────

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
