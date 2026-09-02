using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Examinations configuration — the switches that govern what lecturers may do.
///
/// Deadlines are NOT here. acad_deadlines already answers "by when", per campus,
/// year, semester and study system, and MarksDeadlineService already reads it.
/// This screen answers the question nothing could answer before: "is this permitted
/// at all, here". Previously the only way to stop coursework entry was to backdate a
/// deadline for the whole university.
///
/// Every switch can be set globally and then overridden for a campus, a faculty or a
/// single programme, optionally for one academic year and semester. The most specific
/// rule wins. The screen shows which rule is actually in force for a chosen scope, so
/// an administrator can answer "why can this lecturer not enter marks" without
/// reading the table.
/// </summary>
public partial class COOPERP_NewScreens_ExamConfiguration : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string Actor()
    {
        try
        {
            if (Session != null && Session["username"] != null && Session["username"].ToString().Trim() != "")
                return Session["username"].ToString().Trim();
        }
        catch { }
        try { if (User != null && User.Identity != null && User.Identity.IsAuthenticated) return User.Identity.Name; }
        catch { }
        return "admin";
    }

    /// <summary>
    /// True when the request carries a signed-in staff session. Same gate as the other
    /// consoles: these switches can stop every lecturer in the university entering
    /// marks, so the endpoints are not left open.
    /// </summary>
    private bool Authed()
    {
        try
        {
            if (User != null && User.Identity != null && User.Identity.IsAuthenticated
                && !string.IsNullOrEmpty(User.Identity.Name)) return true;
        }
        catch { }
        try
        {
            if (Session != null)
            {
                object u = Session["username"];
                if (u != null && !string.IsNullOrEmpty(u.ToString().Trim())) return true;
            }
        }
        catch { }
        return false;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string action = Request.QueryString["action"] ?? Request.Form["action"];
        if (!string.IsNullOrEmpty(action))
        {
            Response.Clear();
            Response.ContentType = "application/json";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);

            // 200 with success:false, never 401 — FormsAuthenticationModule turns a 401
            // into a redirect to the login page and the caller gets HTML where it
            // expected JSON.
            if (!Authed())
            {
                Response.Write("{\"success\":false,\"message\":\"Your session has expired. Please sign in again, then retry.\"}");
                try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
                return;
            }

            try
            {
                if (action == "List") Response.Write(HandleList());
                else if (action == "Save") Response.Write(HandleSave());
                else if (action == "Delete") Response.Write(HandleDelete());
                else if (action == "Effective") Response.Write(HandleEffective());
                else Response.Write("{\"success\":false,\"message\":\"Unknown action.\"}");
            }
            catch (Exception ex)
            {
                Response.Write(new JavaScriptSerializer().Serialize(new { success = false, message = ex.Message }));
            }
            try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
            return;
        }
    }

    // ── the catalogue ───────────────────────────────────────────────────────────
    //
    // Held here rather than in the database so a setting cannot exist without a
    // human explanation of what it does. The database stores VALUES; this describes
    // what the values mean.
    private class Setting
    {
        public string Key, Group, Title, Help, Type;
        public Setting(string k, string g, string t, string h, string ty)
        { Key = k; Group = g; Title = t; Help = h; Type = ty; }
    }

    private static readonly List<Setting> Catalogue = new List<Setting>
    {
        // The schedule comes first because it is what an administrator normally wants,
        // and because leaving it blank is a valid, common answer.
        new Setting(ExamConfig.CourseworkOpens, "When mark entry runs",
            "Coursework entry opens",
            "Lecturers cannot type coursework marks before this. Leave empty for no start limit.", "DATETIME"),
        new Setting(ExamConfig.CourseworkCloses, "When mark entry runs",
            "Coursework entry closes",
            "Lecturers cannot type coursework marks after this. Leave empty for no end limit.", "DATETIME"),
        new Setting(ExamConfig.ExamOpens, "When mark entry runs",
            "Final exam entry opens",
            "Leave empty for no start limit.", "DATETIME"),
        new Setting(ExamConfig.ExamCloses, "When mark entry runs",
            "Final exam entry closes",
            "Leave empty for no end limit.", "DATETIME"),

        new Setting(ExamConfig.CourseworkEntryEnabled, "What lecturers may do",
            "Coursework mark entry",
            "When off, lecturers cannot open or type coursework marks. This is separate from the deadline — use it to close entry without pretending a date has passed.", "BOOL"),
        new Setting(ExamConfig.ExamEntryEnabled, "What lecturers may do",
            "Final exam mark entry",
            "When off, lecturers cannot open or type final exam marks.", "BOOL"),
        new Setting(ExamConfig.PracticalEntryEnabled, "What lecturers may do",
            "Practical mark entry",
            "For programmes that assess a practical component separately.", "BOOL"),
        new Setting(ExamConfig.ExcelUploadEnabled, "What lecturers may do",
            "Upload marks from Excel",
            "When off, marks must be typed in. Useful when a spreadsheet template has changed and old copies are still circulating.", "BOOL"),
        new Setting(ExamConfig.EditAfterSubmit, "What lecturers may do",
            "Edit a marksheet after submitting it",
            "Normally off: once a sheet is submitted it belongs to the approval chain. Turn on briefly when a department is correcting a batch.", "BOOL"),
        new Setting(ExamConfig.AllowBlankSubmit, "What lecturers may do",
            "Allow submission with marks missing",
            "Normally off, so an absent student is recorded deliberately rather than by leaving a box empty.", "BOOL"),

        new Setting(ExamConfig.SplitCoursework, "How a mark is made up",
            "Coursework percentage", "Default share of the final mark for new marksheets.", "INT"),
        new Setting(ExamConfig.SplitExam, "How a mark is made up",
            "Final exam percentage", "Default share of the final mark for new marksheets.", "INT"),
        new Setting(ExamConfig.SplitPractical, "How a mark is made up",
            "Practical percentage", "Left at zero for programmes with no practical component.", "INT"),
        new Setting(ExamConfig.MarksTotal, "How a mark is made up",
            "Total the shares must add to", "The three percentages above are checked against this.", "INT"),
        new Setting(ExamConfig.MaxScore, "How a mark is made up",
            "Highest mark allowed for one component", "A guard against a slipped decimal point.", "INT"),
        new Setting(ExamConfig.AllowDecimal, "How a mark is made up",
            "Allow decimal marks", "When off, only whole numbers may be entered.", "BOOL"),

        new Setting(ExamConfig.ResultsVisible, "What students may see",
            "Students can view published results",
            "Turn off to hold results back from the portal while a board of examiners is sitting.", "BOOL"),
        new Setting(ExamConfig.ResultsHideOnBalance, "What students may see",
            "Hide results from students who owe fees",
            "A policy decision, not a technical one. Off by default.", "BOOL"),
    };

    private string HandleList()
    {
        var js = new JavaScriptSerializer();
        var rows = new List<object>();

        var overrides = new Dictionary<string, List<object>>();
        using (var c = new MySqlConnection(ConnStr))
        {
            c.Open();
            using (var cmd = new MySqlCommand(
                "SELECT id, config_key, scope_type, scope_value, acad_year, semester, config_value, " +
                "       IFNULL(notes,''), IFNULL(updated_by,''), IFNULL(DATE_FORMAT(updated_at,'%e %b %Y'),'') " +
                "FROM acad_exam_config WHERE is_active = 1 " +
                "ORDER BY config_key, FIELD(scope_type,'GLOBAL','CAMPUS','FACULTY','PROGRAMME'), scope_value", c))
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                {
                    string key = r.GetString(1);
                    if (!overrides.ContainsKey(key)) overrides[key] = new List<object>();
                    overrides[key].Add(new
                    {
                        id = r.GetInt32(0),
                        scopeType = r.GetString(2),
                        scopeValue = r.GetString(3),
                        acadYear = r.GetString(4),
                        semester = r.GetInt32(5),
                        value = r.GetString(6),
                        notes = r.GetString(7),
                        updatedBy = r.GetString(8),
                        updatedAt = r.GetString(9)
                    });
                }
        }

        foreach (Setting s in Catalogue)
            rows.Add(new
            {
                key = s.Key,
                group = s.Group,
                title = s.Title,
                help = s.Help,
                type = s.Type,
                rules = overrides.ContainsKey(s.Key) ? overrides[s.Key] : new List<object>()
            });

        return js.Serialize(new { success = true, settings = rows, scopes = LoadScopes() });
    }

    /// <summary>Campuses, faculties and programmes an override can be attached to.</summary>
    private object LoadScopes()
    {
        var campuses = new List<object>();
        var faculties = new List<object>();
        var programmes = new List<object>();
        try
        {
            using (var c = new MySqlConnection(ConnStr))
            {
                c.Open();
                using (var cmd = new MySqlCommand("SELECT ID, campus_name FROM acad_campuses WHERE ID > 0 ORDER BY ID", c))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) campuses.Add(new { v = r.GetValue(0).ToString(), t = r.GetValue(1).ToString() });

                using (var cmd = new MySqlCommand(
                    "SELECT faculty_code, faculty_name FROM acad_faculty WHERE faculty_code <> '00' ORDER BY faculty_name", c))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) faculties.Add(new { v = r.GetString(0), t = r.GetString(1) });

                using (var cmd = new MySqlCommand("SELECT progcode, progname FROM acad_programme ORDER BY progname", c))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) programmes.Add(new { v = r.GetString(0), t = r.GetString(1) });
            }
        }
        catch { }
        return new { campuses = campuses, faculties = faculties, programmes = programmes };
    }

    private string HandleSave()
    {
        var js = new JavaScriptSerializer();
        Func<string, string> F = k => (Request.Form[k] ?? "").Trim();

        string key = F("key");
        string scopeType = F("scopeType").ToUpperInvariant();
        string scopeValue = F("scopeValue");
        string acadYear = F("acadYear");
        string value = F("value");
        string notes = F("notes");
        int semester; if (!int.TryParse(F("semester"), out semester)) semester = 0;

        Setting def = Catalogue.Find(x => x.Key == key);
        if (def == null) return js.Serialize(new { success = false, message = "Unknown setting." });
        if (scopeType != "GLOBAL" && scopeType != "CAMPUS" && scopeType != "FACULTY" && scopeType != "PROGRAMME")
            return js.Serialize(new { success = false, message = "Choose a valid scope." });
        if (scopeType == "GLOBAL") scopeValue = "";
        else if (scopeValue == "")
            return js.Serialize(new { success = false, message = "Choose which " + scopeType.ToLowerInvariant() + " this applies to." });

        // Validate against the declared type rather than trusting the form: a "1.5" in a
        // BOOL, or letters in a percentage, would resolve to the fallback for ever after
        // and look like the setting simply did not work.
        if (def.Type == "BOOL")
        {
            string v = value.ToUpperInvariant();
            if (v == "TRUE" || v == "YES" || v == "ON" || v == "1") value = "1";
            else if (v == "FALSE" || v == "NO" || v == "OFF" || v == "0") value = "0";
            else return js.Serialize(new { success = false, message = "This setting is on or off." });
        }
        else if (def.Type == "DATETIME")
        {
            // Empty is legitimate and means "no limit", so it is accepted as-is.
            if (value != "")
            {
                DateTime dt;
                if (!DateTime.TryParseExact(value, ExamConfig.DateTimeFormat,
                        System.Globalization.CultureInfo.InvariantCulture,
                        System.Globalization.DateTimeStyles.None, out dt))
                {
                    // The browser's datetime-local control sends yyyy-MM-ddTHH:mm.
                    if (!DateTime.TryParseExact(value, "yyyy-MM-ddTHH:mm",
                            System.Globalization.CultureInfo.InvariantCulture,
                            System.Globalization.DateTimeStyles.None, out dt))
                        return js.Serialize(new { success = false, message = "Enter the date and time as yyyy-MM-dd HH:mm." });
                }
                // Stored in one format only, so nothing downstream has to guess.
                value = dt.ToString(ExamConfig.DateTimeFormat, System.Globalization.CultureInfo.InvariantCulture);

                string other = OppositeWindowKey(key);
                if (other != null)
                {
                    // A window that closes before it opens can never be open, and would
                    // read on screen as though it were configured correctly. Refused here
                    // rather than tolerated later.
                    DateTime? o = ReadRaw(other, scopeType, scopeValue, acadYear, semester);
                    bool thisIsOpening = key.EndsWith(".opens", StringComparison.OrdinalIgnoreCase);
                    DateTime opens = thisIsOpening ? dt : (o ?? DateTime.MinValue);
                    DateTime closes = thisIsOpening ? (o ?? DateTime.MaxValue) : dt;
                    if (o.HasValue && closes <= opens)
                        return js.Serialize(new { success = false, message =
                            "That would close entry before it opens (" +
                            opens.ToString("d MMM yyyy, h:mm tt") + " to " + closes.ToString("d MMM yyyy, h:mm tt") +
                            "). Check the other date first." });
                }
            }
        }
        else if (def.Type == "INT")
        {
            int n;
            if (!int.TryParse(value, out n)) return js.Serialize(new { success = false, message = "This setting needs a whole number." });
            if (n < 0 || n > 1000) return js.Serialize(new { success = false, message = "That number is outside the sensible range." });
            value = n.ToString();
        }

        using (var c = new MySqlConnection(ConnStr))
        {
            c.Open();
            string before = null;
            using (var cmd = new MySqlCommand(
                "SELECT config_value FROM acad_exam_config WHERE config_key=@k AND scope_type=@st AND scope_value=@sv " +
                "AND acad_year=@y AND semester=@s LIMIT 1", c))
            {
                cmd.Parameters.AddWithValue("@k", key); cmd.Parameters.AddWithValue("@st", scopeType);
                cmd.Parameters.AddWithValue("@sv", scopeValue); cmd.Parameters.AddWithValue("@y", acadYear);
                cmd.Parameters.AddWithValue("@s", semester);
                object o = cmd.ExecuteScalar();
                if (o != null && o != DBNull.Value) before = o.ToString();
            }

            using (var cmd = new MySqlCommand(
                "INSERT INTO acad_exam_config (config_key,scope_type,scope_value,acad_year,semester,value_type,config_value,notes,updated_by,updated_at,is_active) " +
                "VALUES (@k,@st,@sv,@y,@s,@vt,@v,@n,@by,NOW(),1) " +
                "ON DUPLICATE KEY UPDATE config_value=VALUES(config_value), notes=VALUES(notes), " +
                "  value_type=VALUES(value_type), updated_by=VALUES(updated_by), updated_at=NOW(), is_active=1", c))
            {
                cmd.Parameters.AddWithValue("@k", key); cmd.Parameters.AddWithValue("@st", scopeType);
                cmd.Parameters.AddWithValue("@sv", scopeValue); cmd.Parameters.AddWithValue("@y", acadYear);
                cmd.Parameters.AddWithValue("@s", semester); cmd.Parameters.AddWithValue("@vt", def.Type);
                cmd.Parameters.AddWithValue("@v", value); cmd.Parameters.AddWithValue("@n", notes);
                cmd.Parameters.AddWithValue("@by", Actor());
                cmd.ExecuteNonQuery();
            }

            Log(c, key, scopeType, scopeValue, acadYear, semester, before, value, before == null ? "CREATE" : "SET");
        }

        return js.Serialize(new { success = true, message = "Saved." });
    }

    /// <summary>The other half of a window pair, or null when the key is not one.</summary>
    private static string OppositeWindowKey(string key)
    {
        if (key == ExamConfig.CourseworkOpens) return ExamConfig.CourseworkCloses;
        if (key == ExamConfig.CourseworkCloses) return ExamConfig.CourseworkOpens;
        if (key == ExamConfig.ExamOpens) return ExamConfig.ExamCloses;
        if (key == ExamConfig.ExamCloses) return ExamConfig.ExamOpens;
        return null;
    }

    /// <summary>
    /// The value stored at EXACTLY this scope — not resolved. The pair check must
    /// compare like with like: a global closing date has no business vetoing a
    /// programme-level opening date, because at the programme level the pair is the
    /// programme's own two rows.
    /// </summary>
    private DateTime? ReadRaw(string key, string scopeType, string scopeValue, string acadYear, int semester)
    {
        try
        {
            using (var c = new MySqlConnection(ConnStr))
            {
                c.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT config_value FROM acad_exam_config WHERE config_key=@k AND scope_type=@st " +
                    "AND scope_value=@sv AND acad_year=@y AND semester=@s AND is_active=1 LIMIT 1", c))
                {
                    cmd.Parameters.AddWithValue("@k", key); cmd.Parameters.AddWithValue("@st", scopeType);
                    cmd.Parameters.AddWithValue("@sv", scopeValue); cmd.Parameters.AddWithValue("@y", acadYear);
                    cmd.Parameters.AddWithValue("@s", semester);
                    object o = cmd.ExecuteScalar();
                    if (o == null || o == DBNull.Value) return null;
                    string v = o.ToString().Trim();
                    if (v == "") return null;
                    DateTime d;
                    if (DateTime.TryParseExact(v, ExamConfig.DateTimeFormat,
                            System.Globalization.CultureInfo.InvariantCulture,
                            System.Globalization.DateTimeStyles.None, out d)) return d;
                    return null;
                }
            }
        }
        catch { return null; }
    }

    private string HandleDelete()
    {
        var js = new JavaScriptSerializer();
        int id; if (!int.TryParse((Request.Form["id"] ?? "").Trim(), out id) || id <= 0)
            return js.Serialize(new { success = false, message = "Missing rule id." });

        using (var c = new MySqlConnection(ConnStr))
        {
            c.Open();
            string key = "", st = "", sv = "", yr = "", val = ""; int sem = 0;
            using (var cmd = new MySqlCommand(
                "SELECT config_key, scope_type, scope_value, acad_year, semester, config_value FROM acad_exam_config WHERE id=@i", c))
            {
                cmd.Parameters.AddWithValue("@i", id);
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return js.Serialize(new { success = false, message = "That rule no longer exists." });
                    key = r.GetString(0); st = r.GetString(1); sv = r.GetString(2);
                    yr = r.GetString(3); sem = r.GetInt32(4); val = r.GetString(5);
                }
            }

            // The GLOBAL row is the floor every other rule falls back to. Removing it
            // would leave the code silently using its compiled-in default, which is not
            // something anybody would find by looking at this screen.
            if (st == "GLOBAL")
                return js.Serialize(new { success = false, message = "The university-wide value cannot be removed — change it instead. Only overrides can be removed." });

            using (var cmd = new MySqlCommand("DELETE FROM acad_exam_config WHERE id=@i", c))
            { cmd.Parameters.AddWithValue("@i", id); cmd.ExecuteNonQuery(); }

            Log(c, key, st, sv, yr, sem, val, null, "DELETE");
        }
        return js.Serialize(new { success = true, message = "Override removed. The wider rule now applies." });
    }

    /// <summary>
    /// action=Effective — what is actually in force for one programme/campus/period,
    /// and which rule decided it. This is the answer to "why can this lecturer not
    /// enter marks", which is otherwise a table-reading exercise.
    /// </summary>
    private string HandleEffective()
    {
        var js = new JavaScriptSerializer();
        Func<string, string> F = k => (Request.Form[k] ?? Request.QueryString[k] ?? "").Trim();
        int sem; if (!int.TryParse(F("semester"), out sem)) sem = 0;

        var scope = ExamConfig.ScopeForProgramme(F("programme"), F("campus"), F("acadYear"), sem);
        var rows = new List<object>();
        foreach (Setting s in Catalogue)
        {
            string src;
            string v = ExamConfig.Resolve(s.Key, scope, out src);
            rows.Add(new { key = s.Key, title = s.Title, group = s.Group, type = s.Type, value = v ?? "", source = src });
        }
        return js.Serialize(new { success = true, faculty = scope.Faculty, settings = rows });
    }

    private void Log(MySqlConnection c, string key, string st, string sv, string yr, int sem,
                     string before, string after, string action)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "INSERT INTO acad_exam_config_log (config_key,scope_type,scope_value,acad_year,semester,old_value,new_value,action,actor) " +
                "VALUES (@k,@st,@sv,@y,@s,@o,@n,@a,@by)", c))
            {
                cmd.Parameters.AddWithValue("@k", key); cmd.Parameters.AddWithValue("@st", st);
                cmd.Parameters.AddWithValue("@sv", sv); cmd.Parameters.AddWithValue("@y", yr);
                cmd.Parameters.AddWithValue("@s", sem);
                cmd.Parameters.AddWithValue("@o", (object)before ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@n", (object)after ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@a", action); cmd.Parameters.AddWithValue("@by", Actor());
                cmd.ExecuteNonQuery();
            }
        }
        catch { /* the change is already made; never fail on the audit write */ }
    }
}
