using System;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_NewFaculties : Page
{
    private static string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax)) { HandleAjax(ajax); return; }
        if (!IsPostBack) { LoadRows(); LoadDeanOptions(); }
    }

    // Emit a JS array of staff names for the searchable Dean picker (free-text allowed).
    private void LoadDeanOptions()
    {
        var sb = new StringBuilder("[");
        bool first = true;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT DISTINCT emp_name FROM hrm_employee WHERE IFNULL(emp_name,'')<>'' ORDER BY emp_name", conn))
                using (var dr = cmd.ExecuteReader())
                    while (dr.Read())
                    {
                        string nm = dr["emp_name"].ToString();
                        if (!first) sb.Append(",");
                        first = false;
                        sb.Append("{\"v\":").Append(JsonStr(nm)).Append(",\"t\":").Append(JsonStr(nm)).Append("}");
                    }
            }
        }
        catch { }
        sb.Append("]");
        litDeanOptions.Text = sb.ToString();
    }

    // ── AJAX CRUD ───────────────────────────────────────────────────────────
    private void HandleAjax(string action)
    {
        Response.ContentType = "application/json";
        Response.Cache.SetNoStore();
        try
        {
            string code = (Request.Form["code"] ?? "").Trim();
            string name = (Request.Form["name"] ?? "").Trim();
            string abbrev = (Request.Form["abbrev"] ?? "").Trim();
            string dean = (Request.Form["dean"] ?? "").Trim();
            string contacts = (Request.Form["contacts"] ?? "").Trim();

            if (action == "create")
            {
                if (code.Length == 0 || name.Length == 0)
                { Write("{\"ok\":false,\"error\":\"Code and name are required.\"}"); return; }

                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    if (Exists(conn, code))
                    { Write("{\"ok\":false,\"error\":\"A faculty with that code already exists.\"}"); return; }

                    using (var cmd = new MySqlCommand(
                        "INSERT INTO acad_faculty (faculty_code, faculty_name, abbrev, faculty_dean, faculty_contacts) " +
                        "VALUES (@c,@n,@a,@d,@k)", conn))
                    {
                        cmd.Parameters.AddWithValue("@c", code);
                        cmd.Parameters.AddWithValue("@n", name);
                        cmd.Parameters.AddWithValue("@a", abbrev);
                        cmd.Parameters.AddWithValue("@d", dean);
                        cmd.Parameters.AddWithValue("@k", contacts);
                        cmd.ExecuteNonQuery();
                    }
                }
                Write("{\"ok\":true}");
            }
            else if (action == "update")
            {
                if (code.Length == 0 || name.Length == 0)
                { Write("{\"ok\":false,\"error\":\"Code and name are required.\"}"); return; }

                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand(
                        "UPDATE acad_faculty SET faculty_name=@n, abbrev=@a, faculty_dean=@d, faculty_contacts=@k " +
                        "WHERE faculty_code=@c", conn))
                    {
                        cmd.Parameters.AddWithValue("@n", name);
                        cmd.Parameters.AddWithValue("@a", abbrev);
                        cmd.Parameters.AddWithValue("@d", dean);
                        cmd.Parameters.AddWithValue("@k", contacts);
                        cmd.Parameters.AddWithValue("@c", code);
                        cmd.ExecuteNonQuery();
                    }
                }
                Write("{\"ok\":true}");
            }
            else if (action == "delete")
            {
                if (code.Length == 0) { Write("{\"ok\":false,\"error\":\"Missing faculty code.\"}"); return; }
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    long progs = Count(conn, "SELECT COUNT(*) FROM acad_programme WHERE faculty_code=@c", code);
                    if (progs > 0)
                    { Write("{\"ok\":false,\"error\":\"Cannot delete: " + progs + " programme(s) still belong to this faculty. Reassign or remove them first.\"}"); return; }

                    using (var cmd = new MySqlCommand("DELETE FROM acad_faculty WHERE faculty_code=@c", conn))
                    {
                        cmd.Parameters.AddWithValue("@c", code);
                        cmd.ExecuteNonQuery();
                    }
                }
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

    private static bool Exists(MySqlConnection conn, string code)
    {
        using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_faculty WHERE faculty_code=@c", conn))
        {
            cmd.Parameters.AddWithValue("@c", code);
            return Convert.ToInt64(cmd.ExecuteScalar()) > 0;
        }
    }
    private static long Count(MySqlConnection conn, string sql, string code)
    {
        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@c", code);
            object v = cmd.ExecuteScalar();
            return (v == null || v == DBNull.Value) ? 0 : Convert.ToInt64(v);
        }
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
                    "SELECT faculty_code, faculty_name, abbrev, faculty_dean, faculty_contacts " +
                    "FROM acad_faculty WHERE faculty_code <> '00' ORDER BY faculty_name", conn))
                using (var dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        n++;
                        string code = dr["faculty_code"].ToString();
                        string name = dr["faculty_name"].ToString();
                        string abbr = dr["abbrev"].ToString();
                        string dean = dr["faculty_dean"].ToString();
                        string cont = dr["faculty_contacts"].ToString();
                        if (dean == "-") dean = "";
                        if (cont == "-") cont = "";
                        if (abbr == "-") abbr = "";

                        string search = (code + " " + name + " " + abbr + " " + dean).ToLower();
                        sb.Append("<tr data-search=\"").Append(HE(search)).Append("\">");
                        sb.Append("<td><span class=\"cd-code\">").Append(HE(code)).Append("</span></td>");
                        sb.Append("<td><strong>").Append(HE(name)).Append("</strong></td>");
                        sb.Append("<td>").Append(abbr.Length > 0 ? "<span class=\"cd-abbr\">" + HE(abbr) + "</span>" : "<span class=\"cd-muted\">—</span>").Append("</td>");
                        sb.Append("<td>").Append(dean.Length > 0 ? HE(dean) : "<span class=\"cd-muted\">—</span>").Append("</td>");
                        sb.Append("<td>").Append(cont.Length > 0 ? HE(cont) : "<span class=\"cd-muted\">—</span>").Append("</td>");
                        sb.Append("<td><div class=\"cd-rowact\">");
                        sb.Append("<button type=\"button\" class=\"cd-btn cd-btn--ghost cd-btn--sm\" data-act=\"edit\"")
                          .Append(" data-code=\"").Append(AE(code)).Append("\"")
                          .Append(" data-name=\"").Append(AE(name)).Append("\"")
                          .Append(" data-abbrev=\"").Append(AE(abbr)).Append("\"")
                          .Append(" data-dean=\"").Append(AE(dean)).Append("\"")
                          .Append(" data-contacts=\"").Append(AE(cont)).Append("\">Edit</button>");
                        sb.Append("<button type=\"button\" class=\"cd-btn cd-btn--danger cd-btn--sm\" data-act=\"del\"")
                          .Append(" data-code=\"").Append(AE(code)).Append("\"")
                          .Append(" data-name=\"").Append(AE(name)).Append("\">Delete</button>");
                        sb.Append("</div></td></tr>");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            sb.Append("<tr data-empty=\"1\"><td colspan=\"6\" style=\"color:#dc2626;padding:20px\">")
              .Append(HE("Error: " + ex.Message)).Append("</td></tr>");
        }
        if (n == 0)
            sb.Append("<tr data-empty=\"1\"><td colspan=\"6\" class=\"cd-empty\">No faculties yet. Click <strong>New Faculty</strong> to add one.</td></tr>");
        litRows.Text = sb.ToString();
    }

    // ── utils ───────────────────────────────────────────────────────────────
    private void Write(string s) { Response.Write(s); }
    private static string HE(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
    private static string AE(string s) { return HttpUtility.HtmlAttributeEncode(s ?? ""); }
    private static string JsonStr(string s)
    {
        if (s == null) return "null";
        return "\"" + s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "\\r").Replace("\n", "\\n") + "\"";
    }
}
