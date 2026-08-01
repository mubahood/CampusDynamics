using System;
using System.Collections.Generic;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Shared logic for admission letter generation used by both the admin letter
/// page and the config page.  The portal has its own copy of this logic
/// (inline in admission-letter.aspx.cs) because it is a separate project.
/// </summary>
public static class AdmissionLetterHelper
{
    // ── Config loader ────────────────────────────────────────────────────
    public static Dictionary<string, string> LoadConfig(MySqlConnection conn)
    {
        var cfg = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        try
        {
            using (var cmd = new MySqlCommand(
                "SELECT cfg_key, cfg_value FROM admission_letter_config", conn))
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                    cfg[r["cfg_key"].ToString()] = r["cfg_value"] != null ? r["cfg_value"].ToString() : "";
        }
        catch { /* table not yet created — return empty config, defaults kick in */ }
        return cfg;
    }

    public static string GetCfg(Dictionary<string, string> cfg, string key, string def)
    {
        string v;
        return cfg.TryGetValue(key, out v) && !string.IsNullOrEmpty(v) ? v : def;
    }
    public static string GetCfg(Dictionary<string, string> cfg, string key)
    {
        return GetCfg(cfg, key, "");
    }

    // ── Variable substitution ────────────────────────────────────────────
    /// <summary>
    /// Replaces {{var}} placeholders in a template string.
    /// Variable values are HTML-encoded before insertion.
    /// The template itself is treated as trusted HTML (not re-encoded).
    /// </summary>
    public static string Sub(string template, Dictionary<string, string> vars)
    {
        if (string.IsNullOrEmpty(template)) return "";
        foreach (var kv in vars)
            template = template.Replace("{{" + kv.Key + "}}", HttpUtility.HtmlEncode(kv.Value ?? ""));
        return template;
    }

    // ── Student data ─────────────────────────────────────────────────────
    public class StudentLetterData
    {
        public string StudentName    = "";
        public string EntryNo        = "";
        public string RegNo          = "";
        public string Title          = "";
        public string ProgrammeName  = "";
        public string ProgrammeCode  = "";
        public string FacultyName    = "";
        public string DepartmentName = "";
        public string CampusName     = "";
        public string StudySession   = "";
        public string EntryYear      = "";
        public bool   Found          = false;
    }

    public static StudentLetterData LoadStudentData(MySqlConnection conn, string eno)
    {
        var d = new StudentLetterData();
        if (string.IsNullOrEmpty(eno)) return d;

        // Try to detect whether acad_programme has a dept_name column
        bool hasDept = false;
        try
        {
            using (var chk = new MySqlCommand(
                "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='acad_programme' AND COLUMN_NAME='dept_name'", conn))
                hasDept = Convert.ToInt32(chk.ExecuteScalar()) > 0;
        }
        catch { }

        string deptExpr = hasDept ? "COALESCE(p.dept_name,'')" : "''";

        string sql = @"
            SELECT
                a.stud_name,
                a.stud_entry_no,
                COALESCE(a.stud_reg_no,'')       AS reg_no,
                COALESCE(a.title,'')             AS title,
                COALESCE(c.prog_id,'')           AS prog_code,
                COALESCE(p.progname,'')          AS prog_name,
                " + deptExpr + @"               AS dept_name,
                COALESCE(f.faculty_name,'')      AS faculty_name,
                COALESCE(cam.campus_name,'')     AS campus_name,
                COALESCE(c.adm_session,'DAY')    AS study_session,
                COALESCE(a.stud_entry_year,YEAR(NOW())) AS entry_year
            FROM acad_applications a
            INNER JOIN acad_applicant_choices c ON c.stud_entry_no = a.stud_entry_no AND c.Choice = 1
            LEFT  JOIN acad_programme p   ON p.progcode     = c.prog_id
            LEFT  JOIN acad_faculty   f   ON f.faculty_code = p.faculty_code
            LEFT  JOIN acad_campuses  cam ON cam.campus_code = a.stud_campus
            WHERE a.stud_entry_no = @eno
            LIMIT 1";

        using (var cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@eno", eno);
            using (var r = cmd.ExecuteReader())
            {
                if (!r.Read()) return d;
                d.Found          = true;
                d.StudentName    = r["stud_name"].ToString().Trim();
                d.EntryNo        = r["stud_entry_no"].ToString().Trim();
                d.RegNo          = r["reg_no"].ToString().Trim();
                d.Title          = r["title"].ToString().Trim();
                d.ProgrammeCode  = r["prog_code"].ToString().Trim().ToUpper();
                d.ProgrammeName  = r["prog_name"].ToString().Trim().ToUpper();
                d.DepartmentName = r["dept_name"].ToString().Trim();
                d.FacultyName    = r["faculty_name"].ToString().Trim();
                d.CampusName     = r["campus_name"].ToString().Trim();
                d.StudySession   = FormatSession(r["study_session"].ToString().Trim());
                d.EntryYear      = r["entry_year"].ToString().Trim();
            }
        }
        return d;
    }

    public static ProgFees GetProgrammeFees(
        MySqlConnection conn, string progCode, Dictionary<string, string> cfg)
    {
        int defTuition    = SafeInt(GetCfg(cfg, "default_tuition_fees",    "780000"));
        int defFunctional = SafeInt(GetCfg(cfg, "default_functional_fees", "867000"));

        if (!string.IsNullOrEmpty(progCode))
        {
            try
            {
                using (var cmd = new MySqlCommand(
                    "SELECT tuition_fees, functional_fees FROM admission_letter_prog_fees WHERE prog_code=@c LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@c", progCode.ToUpper());
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                            return new ProgFees(
                                Convert.ToInt32(r["tuition_fees"]),
                                Convert.ToInt32(r["functional_fees"]));
                    }
                }
            }
            catch { }
        }
        return new ProgFees(defTuition, defFunctional);
    }

    public class ProgFees
    {
        public int Tuition    { get; private set; }
        public int Functional { get; private set; }
        public ProgFees(int t, int f) { Tuition = t; Functional = f; }
    }

    // ── Letter HTML builder ──────────────────────────────────────────────
    public static string BuildLetterHtml(
        StudentLetterData student,
        int tuition, int functional,
        Dictionary<string, string> cfg,
        bool isProvisional)
    {
        // Build substitution variables
        bool noRegNo = isProvisional && (string.IsNullOrEmpty(student.RegNo) || student.RegNo == "-");
        string acadYear   = GetCfg(cfg, "acad_year", DateTime.Now.Year + "/" + (DateTime.Now.Year + 1));
        string univName   = GetCfg(cfg, "university_name", "Muteesa I Royal University");
        string regName    = GetCfg(cfg, "registrar_name",  "ACADEMIC REGISTRAR");
        string regTitle   = GetCfg(cfg, "registrar_title", "ACADEMIC REGISTRAR");
        int total = tuition + functional;

        var vars = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            {"student_name",           student.StudentName},
            {"student_no",             student.EntryNo},
            {"reg_no",                 noRegNo ? "…………………………." : student.RegNo},
            {"date",                   DateTime.Now.ToString("dd/MM/yyyy")},
            {"acad_year",              acadYear},
            {"programme_name",         student.ProgrammeName},
            {"programme_abbrev",       student.ProgrammeCode},
            {"faculty_name",           student.FacultyName},
            {"dept_name",              student.DepartmentName},
            {"campus_name",            student.CampusName},
            {"study_session",          student.StudySession},
            {"sponsor_type",           GetCfg(cfg, "sponsor_type", "Privately-Sponsored")},
            {"reg_deadline_date",      GetCfg(cfg, "reg_deadline_date", "")},
            {"reg_deadline_weeks",     GetCfg(cfg, "reg_deadline_weeks", "3")},
            {"tuition_fees",           FmtNum(tuition)},
            {"functional_fees",        FmtNum(functional)},
            {"total_fees",             "Ush " + FmtNum(total)},
            {"programme_fees_label",   student.ProgrammeCode + " Programme"},
            {"registrar_name",         regName},
            {"registrar_title",        regTitle},
            {"university_name",        univName},
            {"admissions_email",       GetCfg(cfg, "admissions_email", "admissions@mru.ac.ug")},
            {"nche_fee_amount",        GetCfg(cfg, "nche_fee_amount",   "20,000")},
            {"kabaka_fund_amount",     GetCfg(cfg, "kabaka_fund_amount","24,000")},
        };

        string he = ""; // shortcut used below

        var sb = new System.Text.StringBuilder();

        // ── University header ──────────────────────────────────────
        string logoPath = GetCfg(cfg, "logo_path", "");
        string tagline  = GetCfg(cfg, "univ_tagline", "");
        sb.Append("<div class='al-header'>");
        if (!string.IsNullOrEmpty(logoPath))
            sb.AppendFormat("<img src='{0}' class='al-logo' alt='{1}' />",
                HttpUtility.HtmlAttributeEncode(logoPath),
                HttpUtility.HtmlAttributeEncode(univName));
        sb.AppendFormat("<div class='al-univ-name'>{0}</div>", HttpUtility.HtmlEncode(univName.ToUpper()));
        if (!string.IsNullOrEmpty(tagline))
            sb.AppendFormat("<div class='al-univ-tagline'>{0}</div>", HttpUtility.HtmlEncode(tagline));
        sb.Append("</div><hr class='al-divider'/>");

        // ── Letter title ──────────────────────────────────────────
        string title = isProvisional
            ? GetCfg(cfg, "provisional_title", "PROVISIONAL ADMISSION LETTER")
            : GetCfg(cfg, "official_title",    "ADMISSION LETTER");
        sb.AppendFormat("<div class='al-letter-title'>{0}</div>", HttpUtility.HtmlEncode(title));

        // ── Student info block ────────────────────────────────────
        sb.Append("<div class='al-student-info'>");
        sb.AppendFormat("<div class='al-student-row'><span class='al-slabel'>NAME:</span><span class='al-sval'>{0}</span></div>",
            HttpUtility.HtmlEncode(student.StudentName));
        sb.AppendFormat("<div class='al-student-row'><span class='al-slabel'>STUDENT NO.:</span><span class='al-sval'>{0}</span></div>",
            HttpUtility.HtmlEncode(student.EntryNo));
        sb.AppendFormat("<div class='al-student-row'><span class='al-slabel'>REG. NO:</span><span class='al-sval'>{0}</span></div>",
            noRegNo ? "…………………………." : HttpUtility.HtmlEncode(student.RegNo));
        sb.Append("</div>");

        // ── Date ──────────────────────────────────────────────────
        sb.AppendFormat("<div class='al-date-row'>DATE:&nbsp;&nbsp;{0}</div>", DateTime.Now.ToString("dd/MM/yyyy"));

        // ── Salutation ────────────────────────────────────────────
        sb.Append("<p><strong>Dear Sir/Madam</strong></p>");

        // ── Intro paragraph ───────────────────────────────────────
        string intro = Sub(GetCfg(cfg, "intro_paragraph",
            "I write to offer you a place at this University, for the Academic Year {{acad_year}} for a program of study leading to the following award:"), vars);
        sb.AppendFormat("<p>{0}</p>", intro);

        // ── Programme block ───────────────────────────────────────
        sb.Append("<div class='al-prog-block'>");
        sb.AppendFormat("<div class='al-prog-name'>{0} ({1})</div>",
            HttpUtility.HtmlEncode(student.ProgrammeName),
            HttpUtility.HtmlEncode(student.ProgrammeCode));
        if (!string.IsNullOrEmpty(student.FacultyName))
            sb.AppendFormat("<div class='al-prog-detail'><strong>Faculty:</strong> {0}</div>",
                HttpUtility.HtmlEncode(student.FacultyName));
        if (!string.IsNullOrEmpty(student.DepartmentName))
            sb.AppendFormat("<div class='al-prog-detail'><strong>Department:</strong> {0}</div>",
                HttpUtility.HtmlEncode(student.DepartmentName));
        if (!string.IsNullOrEmpty(student.CampusName))
            sb.AppendFormat("<div class='al-prog-detail'><strong>Campus:</strong> {0}</div>",
                HttpUtility.HtmlEncode(student.CampusName));
        sb.AppendFormat("<div class='al-prog-detail'><strong>Study Arrangement:</strong> {0}</div>",
            HttpUtility.HtmlEncode(student.StudySession));
        sb.Append("</div>");

        // ── Body paragraph (raw HTML — supports section headings) ────
        string body = Sub(GetCfg(cfg, "body_paragraph", ""), vars);
        if (!string.IsNullOrEmpty(body)) sb.Append(body);

        // ── Requirements list ─────────────────────────────────────
        sb.Append(Sub(GetCfg(cfg, "requirements_html", ""), vars));

        // ── Disclaimer ────────────────────────────────────────────
        sb.Append(Sub(GetCfg(cfg, "disclaimer_html", ""), vars));

        // ── Fees section ──────────────────────────────────────────
        sb.Append("<div class='al-section-head'>FEES PAYMENT</div>");
        string feesIntro = GetCfg(cfg, "fees_section_intro", "");
        if (!string.IsNullOrEmpty(feesIntro)) sb.AppendFormat("<p>{0}</p>", feesIntro);

        sb.AppendFormat("<p class='al-fees-label'>FEES STRUCTURE ({0})</p>",
            HttpUtility.HtmlEncode(student.ProgrammeCode + " Programme"));
        sb.Append("<table class='al-fees-table'>");
        sb.Append("<thead><tr><th>Tuition Fees</th><th>Functional Fees</th><th>Total</th></tr></thead>");
        sb.Append("<tbody><tr>");
        sb.AppendFormat("<td>{0}</td><td>{1}</td><td class='al-total-cell'>{2}</td>",
            FmtNum(tuition), FmtNum(functional), "Ush " + FmtNum(total));
        sb.Append("</tr></tbody></table>");

        // ── Payment instructions ──────────────────────────────────
        sb.AppendFormat("<div class='al-section-head'>MODE OF PAYMENT AT {0}</div>",
            HttpUtility.HtmlEncode(univName.ToUpper()));
        sb.Append(Sub(GetCfg(cfg, "payment_instructions_html", ""), vars));
        sb.Append(Sub(GetCfg(cfg, "additional_charges_html", ""), vars));

        // ── Sections ──────────────────────────────────────────────
        string[][] sections = {
            new[]{ "ORIENTATION PROGRAMME", "orientation_html" },
            new[]{ "CHANGE OF PROGRAMME",   "change_prog_html" },
            new[]{ "REGISTRATION",          "registration_html" },
        };
        foreach (string[] sec in sections)
        {
            string heading = sec[0], key = sec[1];
            string content = Sub(GetCfg(cfg, key, ""), vars);
            if (!string.IsNullOrEmpty(content))
            {
                sb.AppendFormat("<div class='al-section-head'>{0}</div>",
                    HttpUtility.HtmlEncode(heading));
                sb.Append(content);
            }
        }

        // ── Closing ───────────────────────────────────────────────
        sb.Append(Sub(GetCfg(cfg, "closing_html", ""), vars));

        // ── Signature ─────────────────────────────────────────────
        string sigPath = GetCfg(cfg, "registrar_sig_path", "");
        sb.Append("<div class='al-sig'>");
        sb.Append("<p>Yours faithfully,</p>");
        if (!string.IsNullOrWhiteSpace(sigPath))
            sb.AppendFormat(
                "<img src='{0}' class='al-sig-img' alt='Signature' />",
                HttpUtility.HtmlAttributeEncode(sigPath));
        sb.AppendFormat("<p class='al-sig-name'>{0}</p>", HttpUtility.HtmlEncode(regName));
        sb.AppendFormat("<p class='al-sig-title'>{0}.</p>", HttpUtility.HtmlEncode(regTitle));
        sb.Append("</div>");

        return sb.ToString();
    }

    // ── Utility ──────────────────────────────────────────────────────────
    public static string FormatSession(string raw)
    {
        if (string.IsNullOrEmpty(raw)) return "Day";
        switch (raw.ToUpper())
        {
            case "DAY":      return "Day";
            case "EVENING":  return "Evening";
            case "WEEKEND":  return "Weekend";
            case "DISTANCE": return "Distance Learning";
            default: return raw;
        }
    }

    public static string FmtNum(int n)
    {
        return string.Format("{0:N0}", n);
    }

    private static int SafeInt(string s)
    {
        int n; int.TryParse((s ?? "").Trim(), out n); return n;
    }

    // ── DB setup (called once from any admin page on first use) ──────────
    public static void EnsureTablesExist(MySqlConnection conn)
    {
        using (var cmd = new MySqlCommand(@"
            CREATE TABLE IF NOT EXISTS admission_letter_config (
                id         INT NOT NULL AUTO_INCREMENT,
                cfg_key    VARCHAR(80) NOT NULL,
                cfg_value  MEDIUMTEXT,
                updated_at DATETIME,
                updated_by VARCHAR(80),
                PRIMARY KEY (id),
                UNIQUE KEY uq_cfg_key (cfg_key)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", conn))
            cmd.ExecuteNonQuery();

        using (var cmd = new MySqlCommand(@"
            CREATE TABLE IF NOT EXISTS admission_letter_prog_fees (
                id              INT NOT NULL AUTO_INCREMENT,
                prog_code       VARCHAR(20) NOT NULL,
                tuition_fees    INT NOT NULL DEFAULT 0,
                functional_fees INT NOT NULL DEFAULT 0,
                updated_at      DATETIME,
                PRIMARY KEY (id),
                UNIQUE KEY uq_prog_code (prog_code)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", conn))
            cmd.ExecuteNonQuery();

        SeedDefaults(conn);
    }

    public static void SeedDefaults(MySqlConnection conn)
    {
        // Uses upsert that only overwrites rows still owned by 'system' — admin-saved
        // values (updated_by != 'system') are never touched.
        const string sql = @"
            INSERT INTO admission_letter_config (cfg_key, cfg_value, updated_at, updated_by)
            VALUES (@k, @v, NOW(), 'system')
            ON DUPLICATE KEY UPDATE
                cfg_value  = IF(updated_by = 'system', VALUES(cfg_value), cfg_value),
                updated_at = IF(updated_by = 'system', NOW(), updated_at)";

        var defaults = new System.Collections.Generic.Dictionary<string, string>
        {
            // ── Titles & Signatory ───────────────────────────────────────────
            {"provisional_title",        "PROVISIONAL ADMISSION LETTER"},
            {"official_title",           "ORIGINAL ADMISSION LETTER"},
            {"registrar_name",           "Musisi Fred Kamoga (PhD)"},
            {"registrar_title",          "ACADEMIC REGISTRAR"},
            {"registrar_sig_path",       "/COOPERP/NewScreens/images/ar_signature.png"},

            // ── University ───────────────────────────────────────────────────
            {"university_name",          "Muteesa I Royal University"},
            {"admissions_email",         "admissions@mru.ac.ug"},
            {"logo_path",                ""},
            {"univ_tagline",             "Kampala, Uganda | www.mru.ac.ug | admissions@mru.ac.ug"},

            // ── Dates & Deadlines ────────────────────────────────────────────
            {"acad_year",                System.DateTime.Now.Year + "/" + (System.DateTime.Now.Year + 1)},
            {"reg_deadline_date",        "03rd August, " + System.DateTime.Now.Year},
            {"reg_deadline_weeks",       "6"},

            // ── Fees defaults ────────────────────────────────────────────────
            {"sponsor_type",             "Privately-Sponsored"},
            {"default_tuition_fees",     "780000"},
            {"default_functional_fees",  "867000"},
            {"nche_fee_amount",          "20,000"},
            {"kabaka_fund_amount",       "24,000"},

            // ── Intro paragraph ──────────────────────────────────────────────
            {"intro_paragraph",
                "On behalf of the Admissions Board, I am pleased to confirm your admission to {{university_name}} "
              + "for the Academic Year {{acad_year}} starting on {{reg_deadline_date}}. "
              + "You have been admitted to pursue the:"},

            // ── Body: REGISTRATION + DURATION sections (rendered as raw HTML) ─
            {"body_paragraph",
                "<div class=\"al-section-head\">REGISTRATION</div>"
              + "<p>You should ensure that you register your course units every semester within six (6) weeks "
              + "from the official start date of the semester.</p>"
              + "<div class=\"al-section-head\">DURATION OF THE PROGRAMME</div>"
              + "<p>The {{programme_name}} programme shall have a minimum duration of three (3) academic years "
              + "and a maximum duration of five (5) academic years, within which the student is expected to "
              + "complete all the prescribed academic requirements. Failure to do so will require the student "
              + "to reapply and start the programme afresh.</p>"},

            // ── Pre-fees HTML (leave blank; can be used for a documents list on provisional letters) ──
            {"requirements_html",        ""},
            {"disclaimer_html",          ""},

            // ── Fees section ─────────────────────────────────────────────────
            {"fees_section_intro",
                "Fees must be paid in full at the start of the semester or in two installments "
              + "(50% tuition + 100% other charges) within the first three weeks. "
              + "All fees must be cleared by the end of week eight; otherwise, the student will not be "
              + "allowed to sit for examinations. All dues must also be fully paid before graduation."},

            {"payment_instructions_html",
                "<p>Fees should be paid via mobile money (school pay platform) using the following options:</p>"
              + "<p><strong>Airtel:</strong><br/>"
              + "Dial <strong>*185#</strong> &#x2192; 6 (School Fees) &#x2192; 2 (School Pay) &#x2192; 1 (Pay Fees) "
              + "&#x2192; Enter Student No. (MRU202600&hellip;) &#x2192; Confirm that the student number provided is in your names "
              + "&#x2192; Enter Amount &#x2192; PIN</p>"
              + "<p><strong>MTN:</strong><br/>"
              + "Dial <strong>*165#</strong> &#x2192; 4 (Payments) &#x2192; 3 (School Fees) &#x2192; 1 (School Pay) "
              + "&#x2192; 1 (Pay Fees) &#x2192; Enter Student No. (MRU202600&hellip;) "
              + "&#x2192; Confirm that the student number provided is in your names &#x2192; Enter Amount &#x2192; PIN</p>"
              + "<p>The University Council reserves the right to revise fees at any time without prior notice.</p>"},

            {"additional_charges_html",
                "<p><strong>Additional Charges:</strong></p>"
              + "<ul>"
              + "<li>NCHE Fee of USh {{nche_fee_amount}} shall be paid directly to the National Council for Higher Education (NCHE) Account once per year.</li>"
              + "<li>Kabaka Education Fund of USh {{kabaka_fund_amount}} shall be paid directly to the Gwanika Iyabuganda Kabaka Education Fund Account each semester.</li>"
              + "</ul>"
              + "<p><strong>NB:</strong> For a program to be offered, it must have a minimum of 10 students as per the University Admissions Policy.</p>"},

            // ── Optional sections (leave blank — configure per need) ─────────
            {"orientation_html",         ""},
            {"change_prog_html",         ""},
            {"registration_html",        ""},

            // ── Closing + Important Notes ────────────────────────────────────
            {"closing_html",
                "<p>We congratulate you on securing admission to {{university_name}} and warmly welcome you "
              + "to the institution. We wish you success in your academic journey and future endeavors.</p>"
              + "<div class=\"al-section-head\">IMPORTANT THINGS TO NOTE</div>"
              + "<ol>"
              + "<li><strong>Bursary Renewal.</strong> Students on bursary are required to renew their bursaries "
              + "and submit the renewal letters to the Bursar's Office within six (6) weeks from the official semester start date.</li>"
              + "<li><strong>Dead Semester/Year Application.</strong> Any student who is unable to complete a semester "
              + "due to reasons such as financial constraints, illness, or loss of a guardian must formally apply "
              + "for a dead semester or year before discontinuing their studies.</li>"
              + "<li>Always collect and keep all marked scripts from your coursework, tests, practicals, and reports. "
              + "Store these documents safely until you have completed your studies and received your transcript and "
              + "certificate. In addition, ensure that all receipts and proofs of payment are securely kept until "
              + "you graduate and obtain your transcript and certificate.</li>"
              + "</ol>"},
        };

        foreach (var kv in defaults)
        {
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@k", kv.Key);
                cmd.Parameters.AddWithValue("@v", kv.Value);
                cmd.ExecuteNonQuery();
            }
        }
    }
}
