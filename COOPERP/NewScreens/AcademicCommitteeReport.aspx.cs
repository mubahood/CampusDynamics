using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AcademicCommitteeReport : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static readonly string[] LEVEL_LABELS = {
        "Elementary", "Certificate", "Diploma", "Bachelors Degree",
        "Post Graduate Diploma", "Masters Degree", "Doctorate"
    };

    // ── helpers ──────────────────────────────────────────────────────────────

    private DataTable ExecuteQuery(MySqlConnection conn, string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parms != null)
                foreach (var p in parms) cmd.Parameters.Add(p);
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                da.Fill(dt);
        }
        return dt;
    }

    private object ExecuteScalar(MySqlConnection conn, string sql, params MySqlParameter[] parms)
    {
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parms != null)
                foreach (var p in parms) cmd.Parameters.Add(p);
            return cmd.ExecuteScalar();
        }
    }

    private static string H(string s)
    {
        return string.IsNullOrEmpty(s) ? "" : HttpUtility.HtmlEncode(s);
    }

    private static string LevelLabel(int code)
    {
        return (code >= 0 && code < LEVEL_LABELS.Length) ? LEVEL_LABELS[code] : "Other";
    }

    // ── page ─────────────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            BuildReport();
    }

    private void BuildReport()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                List<string> years = GetRecentYears(conn, 3);
                string currentYear = years.Count > 0 ? years[0] : "";

                // Header literals
                litReportDate.Text = DateTime.Now.ToString("dddd, d MMMM yyyy");
                litYearsRef.Text   = string.Join(", ", years.ToArray());
                litFooterDate.Text = DateTime.Now.ToString("d MMMM yyyy 'at' HH:mm");
                litCurrentYear.Text = "Academic year " + H(currentYear);

                // Excel export link — same page, export flag
                lnkExcel.NavigateUrl = Request.RawUrl +
                    (Request.RawUrl.Contains("?") ? "&" : "?") + "export=xls";

                BuildSummaryCards(conn, currentYear);
                BuildEnrolmentPanels(conn, years);
                BuildProgrammesTable(conn);
            }
        }
        catch (Exception ex)
        {
            litEnrolmentPanels.Text =
                "<div style=\"color:red;padding:12px;\">Error loading report: " + H(ex.Message) + "</div>";
        }
    }

    // ── recent academic years ────────────────────────────────────────────────

    private List<string> GetRecentYears(MySqlConnection conn, int count)
    {
        List<string> years = new List<string>();
        try
        {
            DataTable dt = ExecuteQuery(conn,
                "SELECT DISTINCT acad_year FROM acad_registration " +
                "ORDER BY acad_year DESC LIMIT @n",
                new MySqlParameter("@n", count));
            foreach (DataRow row in dt.Rows)
                years.Add(row[0].ToString());
        }
        catch { }
        return years;
    }

    // ── summary cards ────────────────────────────────────────────────────────

    private void BuildSummaryCards(MySqlConnection conn, string currentYear)
    {
        // Active students (current year)
        int totalActive = 0, totalMale = 0, totalFemale = 0;
        try
        {
            string sqlActive = @"
                SELECT
                    COUNT(DISTINCT s.regno)                                                        AS total,
                    SUM(CASE WHEN UPPER(TRIM(s.gender)) IN ('M','MALE')   THEN 1 ELSE 0 END)     AS male,
                    SUM(CASE WHEN UPPER(TRIM(s.gender)) IN ('F','FEMALE') THEN 1 ELSE 0 END)     AS female
                FROM acad_student s
                INNER JOIN (
                    SELECT DISTINCT regno FROM acad_registration
                    WHERE acad_year = @yr
                      AND regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                ) r ON r.regno = s.regno
                WHERE s.new_status = 'ACTIVE'";
            DataTable dt = ExecuteQuery(conn, sqlActive, new MySqlParameter("@yr", currentYear));
            if (dt.Rows.Count > 0)
            {
                totalActive = Convert.ToInt32(dt.Rows[0]["total"]);
                totalMale   = Convert.ToInt32(dt.Rows[0]["male"]);
                totalFemale = Convert.ToInt32(dt.Rows[0]["female"]);
            }
        }
        catch { }

        litTotalActive.Text  = totalActive.ToString("N0");
        litGenderSplit.Text  = string.Format(
            "<span class=\"acr-num--male\">{0:N0} M</span> &nbsp;·&nbsp; <span class=\"acr-num--female\">{1:N0} F</span>",
            totalMale, totalFemale);

        // Programmes
        int progCount = 0;
        try
        {
            object val = ExecuteScalar(conn, "SELECT COUNT(*) FROM acad_programme");
            if (val != null && val != DBNull.Value) progCount = Convert.ToInt32(val);
        }
        catch { }
        litTotalProgrammes.Text = progCount.ToString("N0");

        // Level breakdown
        try
        {
            DataTable dtLevels = ExecuteQuery(conn,
                "SELECT COALESCE(levelCode,0) AS lc, COUNT(*) AS cnt " +
                "FROM acad_programme GROUP BY levelCode ORDER BY levelCode");
            var parts = new List<string>();
            foreach (DataRow r in dtLevels.Rows)
                parts.Add(string.Format("{0} {1}", r["cnt"], LevelLabel(Convert.ToInt32(r["lc"]))));
            litLevelSplit.Text = string.Join(" &nbsp;·&nbsp; ", parts.ToArray());
        }
        catch { litLevelSplit.Text = ""; }

        // Faculties
        int facCount = 0;
        try
        {
            object val = ExecuteScalar(conn, "SELECT COUNT(*) FROM acad_faculty");
            if (val != null && val != DBNull.Value) facCount = Convert.ToInt32(val);
        }
        catch { }
        litTotalFaculties.Text = facCount.ToString("N0");

        // Alumni
        int alumniCount = 0;
        try
        {
            object val = ExecuteScalar(conn,
                "SELECT COUNT(DISTINCT regno) FROM acad_student WHERE new_status = 'ALUMNI'");
            if (val != null && val != DBNull.Value) alumniCount = Convert.ToInt32(val);
        }
        catch { }
        litAlumni.Text = alumniCount.ToString("N0");

        // Ever admitted (active + alumni + inactive)
        int admittedCount = 0;
        try
        {
            object val = ExecuteScalar(conn,
                "SELECT COUNT(*) FROM acad_student WHERE new_status NOT IN ('WITHDRAWN','EXPELLED','REJECTED')");
            if (val != null && val != DBNull.Value) admittedCount = Convert.ToInt32(val);
        }
        catch { }
        litAdmitted.Text = string.Format("{0:N0} total admitted", admittedCount);
    }

    // ── section 1.1 ──────────────────────────────────────────────────────────

    private void BuildEnrolmentPanels(MySqlConnection conn, List<string> years)
    {
        // cross-year: faculty → year → [male, female]
        var crossYear   = new Dictionary<string, Dictionary<string, int[]>>();
        var facOrder    = new List<string>();

        StringBuilder sbPanels = new StringBuilder();

        for (int i = 0; i < years.Count; i++)
        {
            string year    = years[i];
            string panelId = "panel_" + year.Replace("/", "_");

            DataTable dt = new DataTable();
            try
            {
                string sqlEnrol = @"
                    SELECT
                        COALESCE(f.faculty_name, 'Unassigned')  AS faculty,
                        COALESCE(p.progname, s.progid)          AS programme,
                        COALESCE(p.levelCode, 0)                AS levelCode,
                        SUM(CASE WHEN UPPER(TRIM(s.gender)) IN ('M','MALE')   THEN 1 ELSE 0 END) AS male_count,
                        SUM(CASE WHEN UPPER(TRIM(s.gender)) IN ('F','FEMALE') THEN 1 ELSE 0 END) AS female_count,
                        COUNT(DISTINCT s.regno)                 AS total_count
                    FROM acad_student s
                    INNER JOIN (
                        SELECT DISTINCT regno FROM acad_registration
                        WHERE acad_year = @yr
                          AND regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                    ) r ON r.regno = s.regno
                    LEFT JOIN acad_programme p ON p.progcode = s.progid
                    LEFT JOIN acad_faculty   f ON f.faculty_code = p.faculty_code
                    WHERE s.new_status = 'ACTIVE'
                    GROUP BY f.faculty_name, p.progname, s.progid, p.levelCode
                    ORDER BY faculty, programme";

                dt = ExecuteQuery(conn, sqlEnrol, new MySqlParameter("@yr", year));
            }
            catch { }

            // Group rows by faculty
            var groups = new Dictionary<string, List<DataRow>>();
            var groupOrder = new List<string>();
            foreach (DataRow row in dt.Rows)
            {
                string fac = row["faculty"].ToString();
                if (!groups.ContainsKey(fac)) { groups[fac] = new List<DataRow>(); groupOrder.Add(fac); }
                groups[fac].Add(row);
            }

            // Accumulate cross-year data
            foreach (string fac in groupOrder)
            {
                if (!facOrder.Contains(fac)) facOrder.Add(fac);
                if (!crossYear.ContainsKey(fac)) crossYear[fac] = new Dictionary<string, int[]>();
                int cm = 0, cf = 0;
                foreach (DataRow r in groups[fac])
                { cm += Convert.ToInt32(r["male_count"]); cf += Convert.ToInt32(r["female_count"]); }
                crossYear[fac][year] = new int[] { cm, cf };
            }

            // Year totals
            int yM = 0, yF = 0;
            foreach (DataRow row in dt.Rows)
            { yM += Convert.ToInt32(row["male_count"]); yF += Convert.ToInt32(row["female_count"]); }
            int yTotal = yM + yF;

            sbPanels.AppendFormat(
                "<div class=\"acr-year-panel\" id=\"{0}\" data-year=\"{1}\">",
                panelId, H(year));

            sbPanels.AppendFormat(
                "<p style=\"font-size:11px;color:var(--muted);margin:0 0 10px;\">" +
                "Academic Year <strong style=\"color:var(--navy);\">{0}</strong>" +
                " &mdash; <strong>{1:N0}</strong> active students " +
                "(<span class=\"acr-num--male\">{2:N0} M</span> &nbsp;·&nbsp; " +
                "<span class=\"acr-num--female\">{3:N0} F</span>)" +
                "</p>",
                H(year), yTotal, yM, yF);

            sbPanels.Append(
                "<table class=\"acr-table acr-table--compact\"><thead><tr>" +
                "<th>Faculty / School</th>" +
                "<th>Programme</th>" +
                "<th>Level</th>" +
                "<th class=\"right\">Male</th>" +
                "<th class=\"right\">Female</th>" +
                "<th class=\"right\">Total</th>" +
                "<th class=\"right\">% F</th>" +
                "</tr></thead><tbody>");

            foreach (string fac in groupOrder)
            {
                List<DataRow> rows = groups[fac];
                int fM = 0, fF = 0;
                foreach (DataRow r in rows)
                { fM += Convert.ToInt32(r["male_count"]); fF += Convert.ToInt32(r["female_count"]); }
                int fTotal = fM + fF;

                sbPanels.AppendFormat(
                    "<tr class=\"acr-table--faculty\">" +
                    "<td colspan=\"7\">{0}" +
                    " &nbsp;<span style=\"font-weight:normal;font-size:10px;\">— {1:N0} students</span>" +
                    "</td></tr>",
                    H(fac), fTotal);

                foreach (DataRow r in rows)
                {
                    int rm  = Convert.ToInt32(r["male_count"]);
                    int rf  = Convert.ToInt32(r["female_count"]);
                    int rt  = rm + rf;
                    int lvl = Convert.ToInt32(r["levelCode"]);
                    double pctF = rt > 0 ? (double)rf / rt * 100 : 0;

                    sbPanels.AppendFormat(
                        "<tr>" +
                        "<td></td>" +
                        "<td>{0}</td>" +
                        "<td><span class=\"acr-level acr-level--{1}\">{2}</span></td>" +
                        "<td class=\"right acr-num--male\">{3:N0}</td>" +
                        "<td class=\"right acr-num--female\">{4:N0}</td>" +
                        "<td class=\"right acr-num\">{5:N0}</td>" +
                        "<td class=\"right\" style=\"color:var(--muted);\">{6:F1}%</td>" +
                        "</tr>",
                        H(r["programme"].ToString()),
                        lvl, H(LevelLabel(lvl)),
                        rm, rf, rt, pctF);
                }

                // Faculty subtotal
                double facPctF = fTotal > 0 ? (double)fF / fTotal * 100 : 0;
                sbPanels.AppendFormat(
                    "<tr class=\"acr-table--subtotal\">" +
                    "<td colspan=\"3\" style=\"font-style:italic;\">{0} Subtotal</td>" +
                    "<td class=\"right\">{1:N0}</td><td class=\"right\">{2:N0}</td>" +
                    "<td class=\"right\">{3:N0}</td><td class=\"right\">{4:F1}%</td>" +
                    "</tr>",
                    H(fac), fM, fF, fTotal, facPctF);
            }

            double yPctF = yTotal > 0 ? (double)yF / yTotal * 100 : 0;
            sbPanels.AppendFormat(
                "<tr class=\"acr-table--grandtotal\">" +
                "<td colspan=\"3\">GRAND TOTAL &mdash; {0}</td>" +
                "<td class=\"right\">{1:N0}</td><td class=\"right\">{2:N0}</td>" +
                "<td class=\"right\">{3:N0}</td><td class=\"right\">{4:F1}%</td>" +
                "</tr>",
                H(year), yM, yF, yTotal, yPctF);

            sbPanels.Append("</tbody></table></div>\n");
        }

        litEnrolmentPanels.Text = sbPanels.ToString();
        BuildCrossYearSummary(crossYear, facOrder, years);
    }

    // ── cross-year summary ───────────────────────────────────────────────────

    private void BuildCrossYearSummary(
        Dictionary<string, Dictionary<string, int[]>> crossYear,
        List<string> facOrder,
        List<string> years)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("<table class=\"acr-table\"><thead><tr>");
        sb.Append("<th style=\"width:30%;\">Faculty / School</th>");
        foreach (string y in years)
            sb.AppendFormat("<th class=\"right\">{0}</th>", H(y));
        sb.Append("<th class=\"right\">3-Yr Trend</th></tr></thead><tbody>");

        // Column sub-headers
        sb.Append("<tr style=\"background:#f0f4ff;font-size:9px;color:var(--muted);\">");
        sb.Append("<td></td>");
        foreach (string y in years)
            sb.Append("<td class=\"right\">M &nbsp;/&nbsp; F &nbsp;/&nbsp; Total</td>");
        sb.Append("<td></td></tr>");

        var yearTotals = new Dictionary<string, int[]>();
        foreach (string y in years) yearTotals[y] = new int[] { 0, 0 };

        foreach (string fac in facOrder)
        {
            sb.AppendFormat("<tr><td><strong>{0}</strong></td>", H(fac));

            int firstTotal = 0, lastTotal = 0;
            for (int i = 0; i < years.Count; i++)
            {
                string y = years[i];
                int m = 0, f = 0;
                if (crossYear.ContainsKey(fac) && crossYear[fac].ContainsKey(y))
                { m = crossYear[fac][y][0]; f = crossYear[fac][y][1]; }
                int tot = m + f;
                yearTotals[y][0] += m;
                yearTotals[y][1] += f;

                sb.AppendFormat(
                    "<td class=\"right\">" +
                    "<span class=\"acr-num--male\">{0}</span> / " +
                    "<span class=\"acr-num--female\">{1}</span> / " +
                    "<strong>{2}</strong></td>",
                    m, f, tot);

                if (i == 0) firstTotal = tot;
                if (i == years.Count - 1) lastTotal = tot;
            }
            sb.AppendFormat("<td class=\"right\">{0}</td></tr>", TrendBadge(lastTotal, firstTotal));
        }

        // Grand total row
        sb.Append("<tr class=\"acr-table--grandtotal\"><td>GRAND TOTAL</td>");
        int gtFirst = 0, gtLast = 0;
        for (int i = 0; i < years.Count; i++)
        {
            string y = years[i];
            int m = yearTotals[y][0], f = yearTotals[y][1], tot = m + f;
            sb.AppendFormat("<td class=\"right\">{0} / {1} / {2}</td>", m, f, tot);
            if (i == 0) gtFirst = tot;
            if (i == years.Count - 1) gtLast = tot;
        }
        sb.AppendFormat("<td class=\"right\">{0}</td></tr>", TrendBadge(gtLast, gtFirst));
        sb.Append("</tbody></table>");

        litCrossYearSummary.Text = sb.ToString();
    }

    private static string TrendBadge(int older, int newer)
    {
        if (older == 0) return "<span class=\"acr-na\">—</span>";
        double pct = (double)(newer - older) / older * 100;
        if (pct > 5)
            return string.Format("<span style=\"color:var(--green);font-weight:700;\">&#9650; {0:F1}%</span>", pct);
        if (pct < -5)
            return string.Format("<span style=\"color:var(--red);font-weight:700;\">&#9660; {0:F1}%</span>", Math.Abs(pct));
        return string.Format("<span style=\"color:var(--muted);\">&#8594; {0:F1}%</span>", pct);
    }

    // ── section 1.2 ──────────────────────────────────────────────────────────

    private void BuildProgrammesTable(MySqlConnection conn)
    {
        DataTable dt = new DataTable();
        try
        {
            string sql = @"
                SELECT
                    p.progcode,
                    p.progname,
                    COALESCE(f.faculty_name, 'Unassigned')   AS faculty_name,
                    COALESCE(p.levelCode, 0)                  AS levelCode,
                    CASE COALESCE(p.levelCode, 0)
                        WHEN 0 THEN 'Elementary'
                        WHEN 1 THEN 'Certificate'
                        WHEN 2 THEN 'Diploma'
                        WHEN 3 THEN 'Bachelors Degree'
                        WHEN 4 THEN 'Post Graduate Diploma'
                        WHEN 5 THEN 'Masters Degree'
                        WHEN 6 THEN 'Doctorate'
                        ELSE 'Other'
                    END                                       AS award_level,
                    COALESCE(p.couselength, 0)                AS duration,
                    COALESCE(p.study_system, '')              AS study_system,
                    (SELECT COUNT(DISTINCT s.regno)
                       FROM acad_student s
                      WHERE s.progid = p.progcode
                        AND s.new_status = 'ACTIVE')          AS enrolled_count
                FROM acad_programme p
                LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code
                ORDER BY levelCode, faculty_name, p.progname";
            dt = ExecuteQuery(conn, sql);
        }
        catch { }

        StringBuilder sb = new StringBuilder();
        sb.Append(
            "<table class=\"acr-table\"><thead><tr>" +
            "<th>#</th>" +
            "<th>Programme Name</th>" +
            "<th>Code</th>" +
            "<th>Faculty / School</th>" +
            "<th>Award</th>" +
            "<th class=\"right\">Dur.</th>" +
            "<th>Mode</th>" +
            "<th class=\"right\">Enrolled</th>" +
            "<th>Status</th>" +
            "<th>Review Date</th>" +
            "<th>NCHE Submission</th>" +
            "<th>Accreditation Date</th>" +
            "<th>Next Review</th>" +
            "<th>Council Approval</th>" +
            "</tr></thead><tbody>\n");

        string currentLevel = null;
        int sn = 0, levelCount = 0, levelEnrolled = 0;
        const string NA = "<span class=\"acr-na\">N/A</span>";

        foreach (DataRow row in dt.Rows)
        {
            int    lvl      = Convert.ToInt32(row["levelCode"]);
            string thisLvl  = row["award_level"].ToString();

            if (currentLevel != thisLvl)
            {
                // Close previous level group
                if (currentLevel != null)
                {
                    sb.AppendFormat(
                        "<tr class=\"acr-table--subtotal\">" +
                        "<td colspan=\"7\"><em>{0} &mdash; {1} programme(s)</em></td>" +
                        "<td class=\"right\">{2:N0}</td>" +
                        "<td colspan=\"6\"></td></tr>\n",
                        H(currentLevel), levelCount, levelEnrolled);
                }
                currentLevel  = thisLvl;
                levelCount    = 0;
                levelEnrolled = 0;

                // Level group header
                int prevLvl = lvl > 0 ? lvl : 0;
                sb.AppendFormat(
                    "<tr class=\"acr-table--faculty\">" +
                    "<td colspan=\"14\">" +
                    "<span class=\"acr-level acr-level--{0}\">{1}</span>" +
                    " &nbsp; PROGRAMMES" +
                    "</td></tr>\n",
                    lvl, H(thisLvl));
            }

            sn++;
            levelCount++;
            int enrolled = Convert.ToInt32(row["enrolled_count"]);
            levelEnrolled += enrolled;

            string mode   = row["study_system"].ToString().Trim();
            string dur    = Convert.ToInt32(row["duration"]) > 0
                            ? row["duration"].ToString() + " yr" : "&mdash;";
            string status = enrolled > 0
                            ? "<span class=\"acr-status--active\">ACTIVE</span>"
                            : "<span class=\"acr-status--inactive\">INACTIVE</span>";

            sb.AppendFormat(
                "<tr>" +
                "<td style=\"color:var(--muted);font-size:10px;\">{0}</td>" +
                "<td><strong>{1}</strong></td>" +
                "<td style=\"font-family:monospace;color:var(--muted);font-size:10px;\">{2}</td>" +
                "<td>{3}</td>" +
                "<td><span class=\"acr-level acr-level--{4}\">{5}</span></td>" +
                "<td class=\"right\">{6}</td>" +
                "<td>{7}</td>" +
                "<td class=\"right acr-num\">{8:N0}</td>" +
                "<td>{9}</td>" +
                "<td>{10}</td>" +
                "<td>{10}</td>" +
                "<td>{10}</td>" +
                "<td>{10}</td>" +
                "<td>{10}</td>" +
                "</tr>\n",
                sn,
                H(row["progname"].ToString()),
                H(row["progcode"].ToString()),
                H(row["faculty_name"].ToString()),
                lvl, H(thisLvl),
                dur,
                string.IsNullOrEmpty(mode) ? "&mdash;" : H(mode),
                enrolled,
                status,
                NA);
        }

        // Final level subtotal
        if (currentLevel != null)
        {
            sb.AppendFormat(
                "<tr class=\"acr-table--subtotal\">" +
                "<td colspan=\"7\"><em>{0} &mdash; {1} programme(s)</em></td>" +
                "<td class=\"right\">{2:N0}</td>" +
                "<td colspan=\"6\"></td></tr>\n",
                H(currentLevel), levelCount, levelEnrolled);
        }

        // Grand total
        sb.AppendFormat(
            "<tr class=\"acr-table--grandtotal\">" +
            "<td colspan=\"4\">TOTAL: {0} PROGRAMMES REGISTERED</td>" +
            "<td colspan=\"10\"></td></tr>\n",
            sn);

        sb.Append("</tbody></table>");
        litProgrammesTable.Text = sb.ToString();
    }
}
