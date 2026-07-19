using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Alumni Data Bank — a contact/address-focused directory of alumni
/// (acad_student.new_status='ALUMNI'), enriched with graduation info
/// (acad_graduands) and richer address (acad_applications, linked by
/// stud_entry_no=regno). Server-rendered paged list + GET filters, AJAX detail,
/// and a streamed CSV export of the whole filtered set.
/// </summary>
public partial class COOPERP_NewScreens_AlumniDataBank : System.Web.UI.Page
{
    // ── filter state (from query string) ──
    protected string FQ, FProg, FFac, FGradYear, FEntryYear, FCampus, FGender, FSession, FHasPhone, FHasEmail;
    protected int FPage = 1, FSize = 50;

    private string ConnStr { get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; } }
    private MySqlConnection Open() { var c = new MySqlConnection(ConnStr); c.Open(); return c; }
    private static string S(object v) { return (v == null || v == DBNull.Value) ? "" : Convert.ToString(v); }
    private static long L(object v) { if (v == null || v == DBNull.Value) return 0; long r; return long.TryParse(Convert.ToString(v), out r) ? r : 0; }
    protected string HE(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
    protected string HtmlAE(string s) { return HttpUtility.HtmlAttributeEncode(s ?? ""); }
    protected string Sel(string a, string b) { return string.Equals(a, b, StringComparison.OrdinalIgnoreCase) ? " selected=\"selected\"" : ""; }
    private string Q(string k) { return (Request.QueryString[k] ?? "").Trim(); }

    protected string litStats = "", litTableRows = "", litPager = "", litCount = "—";
    protected string litProgOptions = "", litFacOptions = "", litGradYearOptions = "", litEntryYearOptions = "", litCampusOptions = "";

    // graduation year from an academic-year string ("2019/2020") or a grad date
    private static string GradYear(string acadyear, object gradDate)
    {
        acadyear = (acadyear ?? "").Trim();
        if (acadyear.Length == 9 && acadyear[4] == '/') return acadyear.Substring(5, 4);
        if (acadyear.Length >= 4) { int y; if (int.TryParse(acadyear.Substring(0, 4), out y)) return acadyear.Substring(0, 4); }
        if (gradDate != null && gradDate != DBNull.Value) { try { return Convert.ToDateTime(gradDate).Year.ToString(); } catch { } }
        return "";
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        FQ = Q("q"); FProg = Q("prog"); FFac = Q("fac"); FGradYear = Q("gradYear");
        FEntryYear = Q("entryYear"); FCampus = Q("campus"); FGender = Q("gender"); FSession = Q("session");
        FHasPhone = Q("hasPhone"); FHasEmail = Q("hasEmail");
        int.TryParse(Q("page"), out FPage); if (FPage < 1) FPage = 1;
        if (!int.TryParse(Q("size"), out FSize) || FSize <= 0) FSize = 50;
        if (FSize > 500) FSize = 500;

        string ajax = Q("ajax");
        try { EnsureIndex(); } catch { }

        if (ajax == "detail") { RespondJson(BuildDetail(Q("regno"))); return; }
        if (Q("export") == "csv") { ExportCsv(); return; }

        LoadOptions();
        LoadStats();
        LoadList();
    }

    private void EnsureIndex()
    {
        using (var conn = Open())
        {
            using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='acad_graduands' AND COLUMN_NAME='regno'", conn))
            {
                object o = cmd.ExecuteScalar();
                if (o != null && Convert.ToInt64(o) == 0)
                    using (var mk = new MySqlCommand("ALTER TABLE acad_graduands ADD INDEX idx_grad_regno (regno)", conn)) mk.ExecuteNonQuery();
            }
        }
    }

    // ── build WHERE + parameters shared by list / stats / export ──
    private string BuildWhere(Dictionary<string, object> parms)
    {
        var w = new List<string>();
        w.Add("s.new_status='ALUMNI'");
        if (FQ != "")
        {
            w.Add("(s.firstname LIKE @q OR s.othername LIKE @q OR CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) LIKE @q OR s.regno LIKE @q OR s.studPhone LIKE @q OR s.email LIKE @q)");
            parms["@q"] = "%" + FQ + "%";
        }
        if (FProg != "") { w.Add("s.progid=@prog"); parms["@prog"] = FProg; }
        if (FFac != "") { w.Add("p.faculty_code=@fac"); parms["@fac"] = FFac; }
        if (FEntryYear != "") { w.Add("s.entryyear=@ey"); parms["@ey"] = FEntryYear; }
        if (FCampus != "") { w.Add("s.studCampus=@campus"); parms["@campus"] = FCampus; }
        if (FGender != "") { w.Add("s.gender=@gender"); parms["@gender"] = FGender; }
        if (FSession != "") { w.Add("s.studsesion=@session"); parms["@session"] = FSession; }
        if (FHasPhone == "1") w.Add("s.studPhone IS NOT NULL AND s.studPhone<>'' AND s.studPhone<>'-'");
        if (FHasEmail == "1") w.Add("s.email IS NOT NULL AND s.email<>'' AND s.email<>'-'");
        if (FGradYear != "")
        {
            w.Add("EXISTS(SELECT 1 FROM acad_graduands g WHERE g.regno=s.regno AND (LEFT(g.acadyear,4)=@gy OR SUBSTRING(g.acadyear,6,4)=@gy OR YEAR(g.grad_date)=@gy))");
            parms["@gy"] = FGradYear;
        }
        return "WHERE " + string.Join(" AND ", w.ToArray());
    }

    private const string BaseFrom = " FROM acad_student s LEFT JOIN acad_programme p ON p.progcode=s.progid LEFT JOIN acad_faculty f ON f.faculty_code=p.faculty_code ";

    private void LoadStats()
    {
        long total = 0, phone = 0, email = 0, progs = 0, grad = 0;
        try
        {
            using (var conn = Open())
            {
                var parms = new Dictionary<string, object>();
                string wc = BuildWhere(parms);
                string sql = "SELECT COUNT(*) total, " +
                    "SUM(s.studPhone IS NOT NULL AND s.studPhone<>'' AND s.studPhone<>'-') phone, " +
                    "SUM(s.email IS NOT NULL AND s.email<>'' AND s.email<>'-') email, " +
                    "COUNT(DISTINCT s.progid) progs, " +
                    "SUM(EXISTS(SELECT 1 FROM acad_graduands g WHERE g.regno=s.regno)) grad " + BaseFrom + wc;
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 60;
                    foreach (var kv in parms) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    using (var r = cmd.ExecuteReader())
                        if (r.Read()) { total = L(r["total"]); phone = L(r["phone"]); email = L(r["email"]); progs = L(r["progs"]); grad = L(r["grad"]); }
                }
            }
        }
        catch { }

        var sb = new StringBuilder();
        sb.Append("<div class=\"adb-stats\">");
        sb.Append(StatCard("total", "Alumni", total, ""));
        sb.Append(StatCard("phone", "With phone", phone, Pct(phone, total)));
        sb.Append(StatCard("email", "With email", email, Pct(email, total)));
        sb.Append(StatCard("grad", "Graduation on record", grad, Pct(grad, total)));
        sb.Append(StatCard("progs", "Programmes", progs, ""));
        sb.Append("</div>");
        litStats = sb.ToString();
        litCount = string.Format("{0:N0} alumni", total);
    }
    private static string Pct(long p, long t) { return (t > 0 && p > 0) ? (p * 100.0 / t).ToString("0.#") + "%" : ""; }
    private string StatCard(string mod, string label, long value, string sub)
    {
        string subHtml = string.IsNullOrEmpty(sub) ? "" : "<div class=\"adb-stat__sub\">" + HE(sub) + "</div>";
        return string.Format("<div class=\"adb-stat adb-stat--{0}\"><div class=\"adb-stat__l\">{1}</div><div class=\"adb-stat__n\">{2:N0}</div>{3}</div>", mod, HE(label), value, subHtml);
    }

    private void LoadList()
    {
        var sb = new StringBuilder();
        long total = 0;
        int offset = (FPage - 1) * FSize;
        try
        {
            using (var conn = Open())
            {
                var parms = new Dictionary<string, object>();
                string wc = BuildWhere(parms);

                using (var cc = new MySqlCommand("SELECT COUNT(*)" + BaseFrom + wc, conn))
                {
                    cc.CommandTimeout = 60;
                    foreach (var kv in parms) cc.Parameters.AddWithValue(kv.Key, kv.Value);
                    object cv = cc.ExecuteScalar(); if (cv != null && cv != DBNull.Value) total = Convert.ToInt64(cv);
                }

                string sql = "SELECT s.regno, IFNULL(s.firstname,'') firstname, IFNULL(s.othername,'') othername, IFNULL(s.gender,'') gender, " +
                    "IFNULL(s.studPhone,'') phone, IFNULL(s.email,'') email, IFNULL(s.home_dist,'') district, IFNULL(s.nationality,'') nationality, " +
                    "IFNULL(s.progid,'') progid, COALESCE(p.progname,s.progid) progname, IFNULL(s.entryyear,0) entryyear, IFNULL(s.studsesion,'') session " +
                    BaseFrom + wc + " ORDER BY IFNULL(s.firstname,'z'), s.othername, s.regno LIMIT @off,@size";

                var regnos = new List<string>();
                var rows = new List<Dictionary<string, string>>();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 60;
                    foreach (var kv in parms) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    cmd.Parameters.AddWithValue("@off", offset);
                    cmd.Parameters.AddWithValue("@size", FSize);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            var d = new Dictionary<string, string>();
                            foreach (string c in new[] { "regno", "firstname", "othername", "gender", "phone", "email", "district", "nationality", "progname", "session" }) d[c] = S(r[c]);
                            d["entryyear"] = S(r["entryyear"]);
                            rows.Add(d); regnos.Add(d["regno"]);
                        }
                }

                // graduation info for this page's regnos
                var gradMap = new Dictionary<string, string[]>(); // regno -> [gradYear, degClass]
                if (regnos.Count > 0)
                {
                    var ins = new List<string>();
                    for (int i = 0; i < regnos.Count; i++) ins.Add("@g" + i);
                    string gsql = "SELECT regno, acadyear, IFNULL(degclass,'') degclass, grad_date FROM acad_graduands WHERE regno IN (" + string.Join(",", ins.ToArray()) + ")";
                    using (var gc = new MySqlCommand(gsql, conn))
                    {
                        for (int i = 0; i < regnos.Count; i++) gc.Parameters.AddWithValue("@g" + i, regnos[i]);
                        using (var r = gc.ExecuteReader())
                            while (r.Read())
                            {
                                string rn = S(r["regno"]);
                                if (!gradMap.ContainsKey(rn)) gradMap[rn] = new[] { GradYear(S(r["acadyear"]), r["grad_date"]), S(r["degclass"]) };
                            }
                    }
                }

                int n = offset;
                foreach (var d in rows)
                {
                    n++;
                    string name = (d["firstname"] + " " + d["othername"]).Trim(); if (name == "") name = "—";
                    string gy = "", dc = "";
                    if (gradMap.ContainsKey(d["regno"])) { gy = gradMap[d["regno"]][0]; dc = gradMap[d["regno"]][1]; }
                    string phone = d["phone"] == "" || d["phone"] == "-" ? "" : d["phone"];
                    string email = d["email"] == "" || d["email"] == "-" ? "" : d["email"];
                    sb.Append("<tr onclick=\"ADB.detail('" + HtmlAE(d["regno"]) + "')\">");
                    sb.Append("<td class=\"adb-rank\">" + n + "</td>");
                    sb.Append("<td class=\"adb-name\">" + HE(name) + "</td>");
                    sb.Append("<td class=\"adb-mono\">" + HE(d["regno"]) + "</td>");
                    sb.Append("<td>" + HE(d["progname"]) + "</td>");
                    sb.Append("<td>" + HE(d["gender"]) + "</td>");
                    sb.Append("<td>" + (phone != "" ? "<a href=\"tel:" + HtmlAE(phone) + "\" onclick=\"event.stopPropagation();\">" + HE(phone) + "</a>" : "<span class=\"adb-mut\">—</span>") + "</td>");
                    sb.Append("<td>" + (email != "" ? "<a href=\"mailto:" + HtmlAE(email) + "\" onclick=\"event.stopPropagation();\">" + HE(email) + "</a>" : "<span class=\"adb-mut\">—</span>") + "</td>");
                    sb.Append("<td>" + (d["district"] != "" ? HE(d["district"]) : "<span class=\"adb-mut\">—</span>") + "</td>");
                    sb.Append("<td class=\"adb-num\">" + (gy != "" ? "<b>" + HE(gy) + "</b>" + (dc != "" ? "<div class=\"adb-sub\">" + HE(dc) + "</div>" : "") : "<span class=\"adb-mut\">—</span>") + "</td>");
                    sb.Append("<td class=\"adb-num\">" + HE(d["entryyear"] != "0" ? d["entryyear"] : "") + "</td>");
                    sb.Append("</tr>");
                }
                if (rows.Count == 0) sb.Append("<tr><td colspan=\"11\" class=\"adb-empty\">No alumni match these filters.</td></tr>");
            }
        }
        catch (Exception ex) { sb.Append("<tr><td colspan=\"11\" class=\"adb-empty\">Error: " + HE(ex.Message) + "</td></tr>"); }

        litTableRows = sb.ToString();
        litPager = BuildPager(total);
    }

    private string BuildPager(long total)
    {
        int pages = (int)Math.Ceiling(total / (double)FSize); if (pages < 1) pages = 1;
        int from = total == 0 ? 0 : (FPage - 1) * FSize + 1;
        long to = Math.Min((long)FPage * FSize, total);
        var sb = new StringBuilder();
        sb.Append("<div class=\"adb-pager\"><div>Showing <b>" + from + "</b>–<b>" + to + "</b> of <b>" + total.ToString("N0") + "</b></div><div class=\"adb-pager__nav\">");
        if (FPage > 1) sb.Append("<a class=\"adb-pg\" href=\"" + PageLink(FPage - 1) + "\">&lsaquo; Prev</a>");
        sb.Append("<span class=\"adb-pg adb-pg--cur\">Page " + FPage + " / " + pages + "</span>");
        if (FPage < pages) sb.Append("<a class=\"adb-pg\" href=\"" + PageLink(FPage + 1) + "\">Next &rsaquo;</a>");
        sb.Append("</div></div>");
        return sb.ToString();
    }
    private string PageLink(int page) { return "AlumniDataBank.aspx?" + FilterQS() + "page=" + page; }
    private string FilterQS()
    {
        var sp = new List<string>();
        Action<string, string> a = (k, v) => { if (!string.IsNullOrEmpty(v)) sp.Add(k + "=" + Uri.EscapeDataString(v)); };
        a("q", FQ); a("prog", FProg); a("fac", FFac); a("gradYear", FGradYear); a("entryYear", FEntryYear);
        a("campus", FCampus); a("gender", FGender); a("session", FSession); a("hasPhone", FHasPhone); a("hasEmail", FHasEmail);
        if (FSize != 50) sp.Add("size=" + FSize);
        return sp.Count > 0 ? string.Join("&", sp.ToArray()) + "&" : "";
    }
    protected string CurrentFilterQS() { return FilterQS(); }

    private void LoadOptions()
    {
        try
        {
            using (var conn = Open())
            {
                var prog = new StringBuilder();
                using (var cmd = new MySqlCommand("SELECT DISTINCT s.progid, COALESCE(p.progname,s.progid) nm FROM acad_student s LEFT JOIN acad_programme p ON p.progcode=s.progid WHERE s.new_status='ALUMNI' AND s.progid<>'' AND s.progid<>'-' ORDER BY nm", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) prog.AppendFormat("<option value=\"{0}\"{1}>{2}</option>", HtmlAE(S(r["progid"])), Sel(FProg, S(r["progid"])), HE(S(r["nm"])));
                litProgOptions = prog.ToString();

                var fac = new StringBuilder();
                using (var cmd = new MySqlCommand("SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) fac.AppendFormat("<option value=\"{0}\"{1}>{2}</option>", HtmlAE(S(r["faculty_code"])), Sel(FFac, S(r["faculty_code"])), HE(S(r["faculty_name"])));
                litFacOptions = fac.ToString();

                var gy = new StringBuilder();
                using (var cmd = new MySqlCommand("SELECT DISTINCT SUBSTRING(acadyear,6,4) gy FROM acad_graduands WHERE acadyear LIKE '____/____' ORDER BY gy DESC", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) { string y = S(r["gy"]); if (y != "") gy.AppendFormat("<option value=\"{0}\"{1}>{0}</option>", HE(y), Sel(FGradYear, y)); }
                litGradYearOptions = gy.ToString();

                var ey = new StringBuilder();
                using (var cmd = new MySqlCommand("SELECT DISTINCT entryyear FROM acad_student WHERE new_status='ALUMNI' AND entryyear IS NOT NULL ORDER BY entryyear DESC", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) { string y = S(r["entryyear"]); if (y != "" && y != "0") ey.AppendFormat("<option value=\"{0}\"{1}>{0}</option>", HE(y), Sel(FEntryYear, y)); }
                litEntryYearOptions = ey.ToString();

                var cp = new StringBuilder();
                using (var cmd = new MySqlCommand("SELECT ID, campus_name FROM acad_campuses WHERE ID<>0 ORDER BY ID", conn))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) cp.AppendFormat("<option value=\"{0}\"{1}>{2}</option>", HE(S(r["ID"])), Sel(FCampus, S(r["ID"])), HE(S(r["campus_name"])));
                litCampusOptions = cp.ToString();
            }
        }
        catch { }
    }

    // ── AJAX detail: full record + address + graduation ──
    private object BuildDetail(string regno)
    {
        if (string.IsNullOrEmpty(regno)) return new { ok = false, error = "No regno." };
        try
        {
            using (var conn = Open())
            {
                var d = new Dictionary<string, object>();
                using (var cmd = new MySqlCommand(
                    "SELECT s.*, COALESCE(p.progname,s.progid) progname, IFNULL(f.faculty_name,'') faculty, IFNULL(cp.campus_name,'') campus_name " +
                    "FROM acad_student s LEFT JOIN acad_programme p ON p.progcode=s.progid LEFT JOIN acad_faculty f ON f.faculty_code=p.faculty_code " +
                    "LEFT JOIN acad_campuses cp ON cp.ID=s.studCampus WHERE s.regno=@r LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var r = cmd.ExecuteReader()) { if (!r.Read()) return new { ok = false, error = "Alumnus not found." }; for (int i = 0; i < r.FieldCount; i++) d[r.GetName(i)] = r.IsDBNull(i) ? null : r.GetValue(i); }
                }
                // address from the admission record (canonical link stud_entry_no=regno)
                var addr = new Dictionary<string, object>();
                using (var cmd = new MySqlCommand("SELECT stud_phy_address, post_box, home_district, stud_district, residence_country, stud_phone, stud_email, kin_contacts, sponsor_contact FROM acad_applications WHERE stud_entry_no=@r LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var r = cmd.ExecuteReader()) if (r.Read()) for (int i = 0; i < r.FieldCount; i++) addr[r.GetName(i)] = r.IsDBNull(i) ? null : r.GetValue(i);
                }
                // graduation
                var grad = new Dictionary<string, object>();
                using (var cmd = new MySqlCommand("SELECT acadyear, degclass, cgpa, grad_date, comp_date, convocation, progcode FROM acad_graduands WHERE regno=@r ORDER BY grad_date DESC LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var r = cmd.ExecuteReader()) if (r.Read()) for (int i = 0; i < r.FieldCount; i++) grad[r.GetName(i)] = r.IsDBNull(i) ? null : r.GetValue(i);
                }

                Func<Dictionary<string, object>, string, string> g = (m, k) => m.ContainsKey(k) ? S(m[k]) : "";
                string gradYear = grad.Count > 0 ? GradYear(g(grad, "acadyear"), grad.ContainsKey("grad_date") ? grad["grad_date"] : null) : "";

                return new
                {
                    ok = true,
                    regno = g(d, "regno"),
                    name = (g(d, "firstname") + " " + g(d, "othername")).Trim(),
                    gender = g(d, "gender"),
                    dob = d.ContainsKey("dob") && d["dob"] != null ? Convert.ToDateTime(d["dob"]).ToString("dd MMM yyyy") : "",
                    nationality = g(d, "nationality"),
                    national_id = g(d, "national_id"),
                    religion = g(d, "religion"),
                    // contact & address
                    phone = g(d, "studPhone"),
                    email = g(d, "email"),
                    district = g(d, "home_dist"),
                    hall = g(d, "StudentHall"),
                    phyAddress = g(addr, "stud_phy_address"),
                    postBox = g(addr, "post_box"),
                    homeDistrict = g(addr, "home_district"),
                    residenceCountry = g(addr, "residence_country"),
                    altPhone = g(addr, "stud_phone"),
                    altEmail = g(addr, "stud_email"),
                    kinContacts = g(addr, "kin_contacts"),
                    // academic
                    programme = g(d, "progname"),
                    faculty = g(d, "faculty"),
                    specialisation = g(d, "specialisation"),
                    entryYear = g(d, "entryyear"),
                    entryMethod = g(d, "entrymethod"),
                    session = g(d, "studsesion"),
                    intake = g(d, "intake"),
                    campus = g(d, "campus_name"),
                    // graduation
                    gradYear = gradYear,
                    gradClass = g(grad, "degclass"),
                    cgpa = g(grad, "cgpa"),
                    gradDate = grad.ContainsKey("grad_date") && grad["grad_date"] != null ? Convert.ToDateTime(grad["grad_date"]).ToString("dd MMM yyyy") : "",
                    convocation = g(grad, "convocation"),
                    acadYear = g(grad, "acadyear")
                };
            }
        }
        catch (Exception ex) { return new { ok = false, error = ex.Message }; }
    }

    private void RespondJson(object obj)
    {
        var ser = new JavaScriptSerializer(); ser.MaxJsonLength = int.MaxValue;
        Response.Clear(); Response.ContentType = "application/json"; Response.Write(ser.Serialize(obj)); Response.End();
    }

    // ── streamed CSV of the whole filtered set ──
    private void ExportCsv()
    {
        Response.Clear();
        Response.ContentType = "text/csv";
        Response.AddHeader("Content-Disposition", "attachment; filename=alumni_data_bank.csv");
        Response.Write("Name,RegNo,Programme,Faculty,Gender,Phone,Email,District,Nationality,EntryYear,Session,GraduationYear,DegreeClass\r\n");
        try
        {
            using (var conn = Open())
            {
                var parms = new Dictionary<string, object>();
                string wc = BuildWhere(parms);
                string sql = "SELECT TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) name, s.regno, COALESCE(p.progname,s.progid) prog, IFNULL(f.faculty_name,'') fac, " +
                    "IFNULL(s.gender,'') gender, IFNULL(s.studPhone,'') phone, IFNULL(s.email,'') email, IFNULL(s.home_dist,'') district, IFNULL(s.nationality,'') nat, " +
                    "IFNULL(s.entryyear,'') ey, IFNULL(s.studsesion,'') sess, " +
                    "(SELECT g.acadyear FROM acad_graduands g WHERE g.regno=s.regno ORDER BY g.grad_date DESC LIMIT 1) gyear, " +
                    "(SELECT g.degclass FROM acad_graduands g WHERE g.regno=s.regno ORDER BY g.grad_date DESC LIMIT 1) gclass " +
                    BaseFrom + wc + " ORDER BY name";
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 180;
                    foreach (var kv in parms) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string gy = GradYear(S(r["gyear"]), null);
                            string[] cells = { S(r["name"]), S(r["regno"]), S(r["prog"]), S(r["fac"]), S(r["gender"]), S(r["phone"]), S(r["email"]), S(r["district"]), S(r["nat"]), S(r["ey"]), S(r["sess"]), gy, S(r["gclass"]) };
                            var sb = new StringBuilder();
                            for (int i = 0; i < cells.Length; i++) { if (i > 0) sb.Append(','); sb.Append(Csv(cells[i])); }
                            Response.Write(sb.ToString()); Response.Write("\r\n");
                        }
                }
            }
        }
        catch (Exception ex) { Response.Write("ERROR," + Csv(ex.Message) + "\r\n"); }
        Response.End();
    }
    private static string Csv(string v) { v = v ?? ""; if (v.IndexOf('"') >= 0 || v.IndexOf(',') >= 0 || v.IndexOf('\n') >= 0) v = "\"" + v.Replace("\"", "\"\"") + "\""; return v; }
}
