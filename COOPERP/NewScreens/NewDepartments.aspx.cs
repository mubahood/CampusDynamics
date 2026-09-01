using System;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_NewDepartments : Page
{
    private static string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax)) { HandleAjax(ajax); return; }
        if (!IsPostBack) { LoadRows(); LoadEmployeeOptions(); LoadFacultyOptions(); }
    }

    // ── AJAX CRUD ───────────────────────────────────────────────────────────
    private void HandleAjax(string action)
    {
        Response.ContentType = "application/json";
        Response.Cache.SetNoStore();
        try
        {
            string name = (Request.Form["name"] ?? "").Trim();
            int head = ToInt(Request.Form["head"]);
            int id = ToInt(Request.Form["id"]);
            string faculty = (Request.Form["faculty"] ?? "").Trim();
            object facultyParam = faculty.Length == 0 ? (object)DBNull.Value : (object)faculty;

            if (action == "create")
            {
                if (name.Length == 0) { Write("{\"ok\":false,\"error\":\"Department name is required.\"}"); return; }
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand(
                        "INSERT INTO hrm_departments (dept_name, dept_headID, faculty_code) VALUES (@n,@h,@f)", conn))
                    {
                        cmd.Parameters.AddWithValue("@n", name);
                        cmd.Parameters.AddWithValue("@h", head);
                        cmd.Parameters.AddWithValue("@f", facultyParam);
                        cmd.ExecuteNonQuery();
                    }
                }
                SyncHodRoles();
                Write("{\"ok\":true}");
            }
            else if (action == "update")
            {
                if (id <= 0) { Write("{\"ok\":false,\"error\":\"Invalid department.\"}"); return; }
                if (name.Length == 0) { Write("{\"ok\":false,\"error\":\"Department name is required.\"}"); return; }
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand(
                        "UPDATE hrm_departments SET dept_name=@n, dept_headID=@h, faculty_code=@f WHERE ID=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@n", name);
                        cmd.Parameters.AddWithValue("@h", head);
                        cmd.Parameters.AddWithValue("@f", facultyParam);
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }
                SyncHodRoles();
                Write("{\"ok\":true}");
            }
            else if (action == "delete")
            {
                if (id <= 0) { Write("{\"ok\":false,\"error\":\"Invalid department.\"}"); return; }
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    long used = CountContracts(conn, id);
                    if (used > 0)
                    { Write("{\"ok\":false,\"error\":\"Cannot delete: " + used + " staff contract(s) still reference this department.\"}"); return; }

                    using (var cmd = new MySqlCommand("DELETE FROM hrm_departments WHERE ID=@id", conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        cmd.ExecuteNonQuery();
                    }
                }
                SyncHodRoles();
                Write("{\"ok\":true}");
            }
            else Write("{\"ok\":false,\"error\":\"Unknown action.\"}");
        }
        catch (Exception ex)
        {
            Write("{\"ok\":false,\"error\":" + JsonStr(ex.Message) + "}");
        }
        Response.End();
    }

    private static long CountContracts(MySqlConnection conn, int id)
    {
        // hrm_emp_contracts.departmentID references hrm_departments.ID
        try
        {
            using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM hrm_emp_contracts WHERE departmentID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                object v = cmd.ExecuteScalar();
                return (v == null || v == DBNull.Value) ? 0 : Convert.ToInt64(v);
            }
        }
        catch { return 0; }   // if the column/table differs, don't block deletion
    }

    // ── Render rows ─────────────────────────────────────────────────────────
    private void LoadRows()
    {
        var sb = new StringBuilder();
        int n = 0;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT d.ID, d.dept_name, d.dept_headID, IFNULL(e.emp_name,'') AS head_name, " +
                    "       IFNULL(e.emp_phone,'') AS head_phone, IFNULL(e.phone_contacts,'') AS head_phone2, " +
                    "       IFNULL(e.emp_email,'') AS head_email, " +
                    "       IFNULL(d.faculty_code,'') AS fcode, IFNULL(f.abbrev,'') AS fabbr, IFNULL(f.faculty_name,'') AS fname " +
                    "FROM hrm_departments d " +
                    "LEFT JOIN hrm_employee e ON e.empID = d.dept_headID " +
                    "LEFT JOIN acad_faculty f ON f.faculty_code = d.faculty_code " +
                    "ORDER BY d.dept_name", conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        n++;
                        string id = dr["ID"].ToString();
                        string name = dr["dept_name"].ToString();
                        string headId = dr["dept_headID"].ToString();
                        string headName = dr["head_name"].ToString();
                        string fcode = dr["fcode"].ToString();
                        string fabbr = dr["fabbr"].ToString();
                        string fname = dr["fname"].ToString();
                        bool hasHead = headName.Trim().Length > 0;
                        bool hasFac = fcode.Trim().Length > 0;

                        string phone = CleanPhone(dr["head_phone"].ToString());
                        string phone2 = CleanPhone(dr["head_phone2"].ToString());
                        if (phone2 == phone) phone2 = "";          // the same number twice helps nobody
                        string email = dr["head_email"].ToString().Trim();
                        if (email == "-" || email.IndexOf('@') < 0) email = "";

                        // Searching by phone number is the point of showing it: someone with a
                        // missed call wants to know which department rang.
                        string search = (name + " " + headName + " " + fname + " " + fabbr + " "
                                       + phone + " " + phone2 + " " + email).ToLower();
                        // Markers the summary chips count and filter on. Emitted here rather
                        // than inferred in the browser, because the browser would have to
                        // guess from rendered text what the query already knows.
                        sb.Append("<tr data-search=\"").Append(HE(search)).Append("\"");
                        if (!hasFac) sb.Append(" data-nofaculty=\"1\"");
                        if (!hasHead) sb.Append(" data-nohead=\"1\"");
                        if (hasHead && phone == "" && phone2 == "") sb.Append(" data-nophone=\"1\"");
                        sb.Append(">");
                        sb.Append("<td><span class=\"cd-num\">").Append(HE(id)).Append("</span></td>");
                        sb.Append("<td><strong>").Append(HE(name)).Append("</strong></td>");
                        sb.Append("<td>");
                        if (hasFac)
                            sb.Append("<span class=\"cd-abbr\" title=\"").Append(AE(fname)).Append("\">")
                              .Append(HE(fabbr.Length > 0 ? fabbr : fcode)).Append("</span>");
                        else
                            sb.Append("<span class=\"cd-muted\">—</span>");
                        sb.Append("</td>");
                        sb.Append("<td>");
                        if (hasHead)
                        {
                            sb.Append("<div class=\"cd-head\"><span class=\"cd-head__av\">")
                              .Append(HE(Initials(headName))).Append("</span>");
                            sb.Append("<div class=\"cd-head__body\"><div class=\"cd-head__name\">")
                              .Append(HE(headName)).Append("</div>");

                            // Contacts are links, not text. On a laptop a mailto opens the mail
                            // client; on a phone or a softphone the tel: dials. Copying a number
                            // off the screen by hand is where the digits get transposed.
                            sb.Append("<div class=\"cd-head__contacts\">");
                            if (phone != "")
                                sb.Append("<a class=\"cd-contact\" href=\"tel:").Append(AE(phone)).Append("\" title=\"Call ")
                                  .Append(AE(headName)).Append("\">").Append(PhoneIcon()).Append(HE(phone)).Append("</a>");
                            if (phone2 != "")
                                sb.Append("<a class=\"cd-contact\" href=\"tel:").Append(AE(phone2)).Append("\" title=\"Second number\">")
                                  .Append(PhoneIcon()).Append(HE(phone2)).Append("</a>");
                            if (email != "")
                                sb.Append("<a class=\"cd-contact cd-contact--mail\" href=\"mailto:").Append(AE(email))
                                  .Append("\" title=\"").Append(AE(email)).Append("\">").Append(MailIcon()).Append(HE(email)).Append("</a>");
                            if (phone == "" && phone2 == "" && email == "")
                                sb.Append("<span class=\"cd-contact cd-contact--none\">No contact on file</span>");
                            sb.Append("</div></div></div>");
                        }
                        else
                            sb.Append("<span class=\"cd-muted\">— not set —</span>");
                        sb.Append("</td>");
                        sb.Append("<td><div class=\"cd-rowact\">");
                        sb.Append("<button type=\"button\" class=\"cd-btn cd-btn--ghost cd-btn--sm\" data-act=\"edit\"")
                          .Append(" data-id=\"").Append(AE(id)).Append("\"")
                          .Append(" data-name=\"").Append(AE(name)).Append("\"")
                          .Append(" data-faculty=\"").Append(AE(fcode)).Append("\"")
                          .Append(" data-head=\"").Append(AE(headId)).Append("\">Edit</button>");
                        sb.Append("<button type=\"button\" class=\"cd-btn cd-btn--danger cd-btn--sm\" data-act=\"del\"")
                          .Append(" data-id=\"").Append(AE(id)).Append("\"")
                          .Append(" data-name=\"").Append(AE(name)).Append("\">Delete</button>");
                        sb.Append("</div></td></tr>");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            sb.Append("<tr data-empty=\"1\"><td colspan=\"5\" style=\"color:#dc2626;padding:20px\">")
              .Append(HE("Error: " + ex.Message)).Append("</td></tr>");
        }
        if (n == 0)
            sb.Append("<tr data-empty=\"1\"><td colspan=\"5\" class=\"cd-empty\">No departments yet. Click <strong>New Department</strong> to add one.</td></tr>");
        litRows.Text = sb.ToString();
    }

    // Faculty options for the department modal dropdown.
    private void LoadFacultyOptions()
    {
        var sb = new StringBuilder();
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT faculty_code, faculty_name FROM acad_faculty WHERE faculty_code<>'00' ORDER BY faculty_name", conn))
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                        sb.Append("<option value=\"").Append(HE(dr["faculty_code"].ToString())).Append("\">")
                          .Append(HE(dr["faculty_name"].ToString())).Append("</option>");
            }
        }
        catch { }
        litFacultyOptions.Text = sb.ToString();
    }

    // Keep the HOD role exactly in sync with current department heads:
    //  • every resolvable department head gets the 'hod' role (auto)
    //  • users who are no longer any department's head lose the AUTO hod role
    // Manual 'hod' assignments (assigned_by <> 'hod_auto') are preserved.
    private void SyncHodRoles()
    {
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                int hodId = 0;
                using (var c = new MySqlCommand("SELECT id FROM sys_roles WHERE role_code='hod' AND is_active=1 LIMIT 1", conn))
                {
                    object v = c.ExecuteScalar();
                    if (v != null && v != DBNull.Value) hodId = Convert.ToInt32(v);
                }
                if (hodId <= 0) return;

                // Every department head is assigned the HOD role automatically,
                // regardless of whether the department is linked to a faculty.
                // (The role is "Head of Department" — it applies to any department.)
                var heads   = new System.Collections.Generic.List<string>();
                var headEmp = new System.Collections.Generic.Dictionary<string, int>();
                // Only bind to usernames that are REAL logins (exist in my_aspnet_users).
                // hrm_employee.usernames sometimes holds a staff number (e.g. MRU0068)
                // instead of the actual login (e.g. KMicheal); those would be dead role
                // rows the user could never see, so we skip them.
                using (var c = new MySqlCommand(
                    "SELECT DISTINCT TRIM(e.usernames) u, e.empID emp FROM hrm_departments d " +
                    "JOIN hrm_employee e ON e.empID = d.dept_headID " +
                    "WHERE d.dept_headID > 0 " +
                    "AND IFNULL(TRIM(e.usernames),'') NOT IN ('','-') " +
                    "AND EXISTS (SELECT 1 FROM my_aspnet_users u WHERE u.name = TRIM(e.usernames))", conn))
                using (var dr = c.ExecuteReader())
                    while (dr.Read())
                    {
                        string u = dr["u"].ToString().Trim();
                        if (u.Length == 0) continue;
                        if (!headEmp.ContainsKey(u))
                        {
                            heads.Add(u);
                            int eid = 0; int.TryParse(dr["emp"].ToString(), out eid);
                            headEmp[u] = eid;
                        }
                    }

                // Deactivate AUTO hod for anyone no longer a head.
                if (heads.Count == 0)
                {
                    using (var c = new MySqlCommand(
                        "UPDATE sys_user_roles SET is_active=0 WHERE role_id=@r AND assigned_by='hod_auto'", conn))
                    { c.Parameters.AddWithValue("@r", hodId); c.ExecuteNonQuery(); }
                }
                else
                {
                    var pn = new System.Collections.Generic.List<string>();
                    for (int i = 0; i < heads.Count; i++) pn.Add("@u" + i);
                    using (var c = new MySqlCommand(
                        "UPDATE sys_user_roles SET is_active=0 WHERE role_id=@r AND assigned_by='hod_auto' " +
                        "AND username NOT IN (" + string.Join(",", pn) + ")", conn))
                    {
                        c.Parameters.AddWithValue("@r", hodId);
                        for (int i = 0; i < heads.Count; i++) c.Parameters.AddWithValue("@u" + i, heads[i]);
                        c.ExecuteNonQuery();
                    }
                    // Assign / reactivate hod for each current head.
                    foreach (var u in heads)
                        using (var c = new MySqlCommand(
                            "INSERT INTO sys_user_roles (username, emp_id, role_id, is_active, assigned_by, notes) " +
                            "VALUES (@u,@e,@r,1,'hod_auto','Auto: department head') " +
                            "ON DUPLICATE KEY UPDATE is_active=1, emp_id=VALUES(emp_id)", conn))
                        {
                            c.Parameters.AddWithValue("@u", u);
                            c.Parameters.AddWithValue("@e", headEmp[u] > 0 ? (object)headEmp[u] : DBNull.Value);
                            c.Parameters.AddWithValue("@r", hodId);
                            c.ExecuteNonQuery();
                        }
                }
            }
        }
        catch { /* never fail the save because of role sync */ }
    }

    private void LoadEmployeeOptions()
    {
        // Emit a JS array of { v: empID, t: emp_name } for the searchable head picker.
        var sb = new StringBuilder("[");
        bool first = true;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT empID, emp_name FROM hrm_employee WHERE IFNULL(emp_name,'')<>'' ORDER BY emp_name", conn))
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                    {
                        if (!first) sb.Append(",");
                        first = false;
                        sb.Append("{\"v\":").Append(JsonStr(dr["empID"].ToString()))
                          .Append(",\"t\":").Append(JsonStr(dr["emp_name"].ToString())).Append("}");
                    }
            }
        }
        catch { }
        sb.Append("]");
        litEmpOptions.Text = sb.ToString();
    }

    // ── utils ───────────────────────────────────────────────────────────────
    private void Write(string s) { Response.Write(s); }
    private static int ToInt(string s) { int n; return int.TryParse((s ?? "").Trim(), out n) ? n : 0; }
    private static string HE(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
    private static string AE(string s) { return HttpUtility.HtmlAttributeEncode(s ?? ""); }
    /// <summary>
    /// A phone number, or "" when the field does not hold one.
    ///
    /// hrm_employee.phone_contacts is a free-text column and most of it is not a number
    /// at all — 30 of the 31 department heads have "1" or "0" sitting in it, presumably
    /// a count or a flag from some earlier form. Rendering that as a tel: link would put
    /// a button on the screen that dials nothing. Only something with enough digits to
    /// be a Ugandan number survives.
    /// </summary>
    private static string CleanPhone(string raw)
    {
        string s = (raw ?? "").Trim();
        if (s == "" || s == "-") return "";

        int digits = 0;
        foreach (char c in s) if (char.IsDigit(c)) digits++;
        if (digits < 9) return "";                       // 0700114353 is 10; +256... is 12

        // Keep only what can be dialled, so the tel: href is clean.
        var sb = new StringBuilder(s.Length);
        foreach (char c in s)
            if (char.IsDigit(c) || c == '+' || c == ' ') sb.Append(c);
        return sb.ToString().Trim();
    }

    private static string PhoneIcon()
    {
        return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.13.96.36 1.9.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.9.34 1.85.57 2.81.7A2 2 0 0 1 22 16.92z'/></svg>";
    }

    private static string MailIcon()
    {
        return "<svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z'/><polyline points='22,6 12,13 2,6'/></svg>";
    }

    private static string Initials(string name)
    {
        if (string.IsNullOrEmpty(name)) return "?";
        var p = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        if (p.Length >= 2) return ("" + p[0][0] + p[1][0]).ToUpper();
        return name.Length >= 2 ? name.Substring(0, 2).ToUpper() : name.ToUpper();
    }
    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
    }
}
