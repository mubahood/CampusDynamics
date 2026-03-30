using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_BursaryDashboard : System.Web.UI.Page
{
    private string AcctConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }
    private string MainConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // Colour palette — must match JS COLORS array exactly
    private static readonly string[] Palette =
    {
        "#174DA4", "#00897b", "#6d28d9", "#d97706",
        "#dc3545", "#16a34a", "#0891b2", "#9333ea"
    };

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadYearDropdown();

        // Restore/select year (ViewState disabled on master)
        string postedYear = Request.Form[ddlYear.UniqueID];
        string selectedYear = "";

        if (!string.IsNullOrEmpty(postedYear))
        {
            ListItem li = ddlYear.Items.FindByValue(postedYear);
            if (li != null) { ddlYear.ClearSelection(); li.Selected = true; }
            selectedYear = ddlYear.SelectedValue;
        }
        else
        {
            selectedYear = ddlYear.SelectedValue; // first item = current year
        }

        LoadDashboard(selectedYear);
    }

    protected void ddlYear_Changed(object sender, EventArgs e)
    {
        // PostBack handled by ViewState-free restore above; this event fires on AutoPostBack
        LoadDashboard(ddlYear.SelectedValue);
    }

    // ====================================================================
    // Load Year Dropdown
    // ====================================================================
    private void LoadYearDropdown()
    {
        ddlYear.Items.Clear();
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            // Combine years from registrations and scholarship records
            string sql = @"SELECT DISTINCT acad_year AS yr FROM (
                               SELECT DISTINCT scholarhipYear AS acad_year FROM scholarshipstudents WHERE scholarhipYear <> ''
                           ) x ORDER BY yr DESC";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    string yr = rdr["yr"].ToString();
                    ddlYear.Items.Add(new ListItem(yr, yr));
                }
            }
        }

        // Ensure at least a fallback
        if (ddlYear.Items.Count == 0)
            ddlYear.Items.Add(new ListItem("2025/2026", "2025/2026"));

        // Default to most recent registration year if available
        string currentRegYear = GetCurrentAcademicYear();
        if (!string.IsNullOrEmpty(currentRegYear))
        {
            ListItem li = ddlYear.Items.FindByValue(currentRegYear);
            if (li != null) { ddlYear.ClearSelection(); li.Selected = true; }
        }
    }

    private string GetCurrentAcademicYear()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT acad_year FROM acad_registration WHERE regstatus='REGISTERED' ORDER BY acad_year DESC LIMIT 1", conn))
                {
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) return r.ToString();
                }
            }
        }
        catch { }
        return "";
    }

    // ====================================================================
    // Main Dashboard Load
    // ====================================================================
    private void LoadDashboard(string year)
    {
        if (string.IsNullOrEmpty(year)) year = ddlYear.Items.Count > 0 ? ddlYear.Items[0].Value : "2025/2026";

        litHeaderSub.Text = "Academic Year " + Server.HtmlEncode(year) + " — Performance Overview";
        litSchemeBreakdownYear.Text = year;
        litAmountChartYear.Text = year;
        litStudyYearChartYear.Text = year;
        litSchemeTableYear.Text = year;
        litRecentYear.Text = year;

        LoadKpis(year);
        LoadSchemeTable(year);
        LoadYearSummaryTable();
        LoadRecentBeneficiaries(year);
        EmitChartData(year);
    }

    // ====================================================================
    // KPI Cards
    // ====================================================================
    private void LoadKpis(string year)
    {
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // Total beneficiaries for selected year
            long total = 0;
            double totalAmt = 0;

            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT 
                    COUNT(*) AS total,
                    IFNULL(SUM(amount_offered),0) AS total_amount
                  FROM scholarshipstudents WHERE scholarhipYear = @yr", conn))
            {
                cmd.Parameters.AddWithValue("@yr", year);
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        total    = rdr["total"]        != DBNull.Value ? Convert.ToInt64(rdr["total"])          : 0;
                        totalAmt = rdr["total_amount"] != DBNull.Value ? Convert.ToDouble(rdr["total_amount"]) : 0;
                    }
                }
            }

            // Active schemes total
            long activeSchemes = 0;
            using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM scholarships WHERE status='Active'", conn))
                activeSchemes = Convert.ToInt64(cmd.ExecuteScalar());

            // Schemes actually used this year
            long schemesUsed = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(DISTINCT scholarshipID) FROM scholarshipstudents WHERE scholarhipYear=@yr", conn))
            {
                cmd.Parameters.AddWithValue("@yr", year);
                schemesUsed = Convert.ToInt64(cmd.ExecuteScalar());
            }

            // Fee transactions linked for this year
            long txLinked = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT COUNT(*) FROM scholarshipstudents ss
                  JOIN fin_studentfeestracking ft ON ft.TID = ss.transaction_ref AND ft.trans_type='Payment'
                  WHERE ss.scholarhipYear=@yr", conn))
            {
                cmd.Parameters.AddWithValue("@yr", year);
                txLinked = Convert.ToInt64(cmd.ExecuteScalar());
            }

            // Set KPI literals
            litKpiTotal.Text = total.ToString("N0");
            litKpiTotalSub.Text = year;
            litKpiAmount.Text = totalAmt.ToString("N0");
            litKpiSchemes.Text = activeSchemes.ToString();
            litKpiSchemesUsed.Text = schemesUsed + " used in " + year;
            double avg = total > 0 ? totalAmt / total : 0;
            litKpiApproved.Text = avg.ToString("N0");
            litKpiApprovedPct.Text = "avg per beneficiary";
            litKpiPending.Text = txLinked.ToString("N0");
            litKpiPendingSub.Text = txLinked + " of " + total + " linked";
        }
    }

    // ====================================================================
    // Scheme Breakdown Table
    // ====================================================================
    private void LoadSchemeTable(string year)
    {
        var sb = new StringBuilder();

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // Get total for this year (for % calc)
            long grandTotal = 0;
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM scholarshipstudents WHERE scholarhipYear=@yr", conn))
            {
                cmd.Parameters.AddWithValue("@yr", year);
                grandTotal = Convert.ToInt64(cmd.ExecuteScalar());
            }

            // All schemes (active), left-joined with this year's data
            string sql = @"SELECT s.scholarshipID, s.scholarshipName, s.bursary_amount, s.status AS scheme_status,
                                  IFNULL(d.cnt,0) AS cnt,
                                  IFNULL(d.total_awarded,0) AS total_awarded
                           FROM scholarships s
                           LEFT JOIN (
                               SELECT scholarshipID,
                                      COUNT(*) AS cnt,
                                      IFNULL(SUM(amount_offered),0) AS total_awarded
                               FROM scholarshipstudents WHERE scholarhipYear=@yr
                               GROUP BY scholarshipID
                           ) d ON d.scholarshipID = s.scholarshipID
                           ORDER BY d.cnt DESC, s.scholarshipName";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@yr", year);
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    int idx = 0;
                    long totalBens = 0;
                    double totalAwarded = 0;
                    var rows = new List<Tuple<long, string, double, string, double>>();

                    while (rdr.Read())
                    {
                        long cnt = Convert.ToInt64(rdr["cnt"]);
                        double awarded = Convert.ToDouble(rdr["total_awarded"]);
                        totalBens   += cnt;
                        totalAwarded += awarded;
                        rows.Add(Tuple.Create(
                            cnt,
                            rdr["scholarshipName"].ToString(),
                            Convert.ToDouble(rdr["bursary_amount"] != DBNull.Value ? rdr["bursary_amount"] : 0),
                            rdr["scheme_status"].ToString(),
                            awarded));
                    }

                    foreach (var row in rows)
                    {
                        long   cnt     = row.Item1;
                        string name    = row.Item2;
                        double burAmt  = row.Item3;
                        string status  = row.Item4;
                        double awarded = row.Item5;

                        double sharePct = grandTotal > 0 && cnt > 0 ? Math.Round((double)cnt / grandTotal * 100, 1) : 0;
                        string color    = Palette[idx % Palette.Length];
                        string badgeCls = status == "Active" ? "bd-badge--active" : "bd-badge--pending";

                        sb.AppendFormat(
                            "<tr>" +
                            "<td><span class='bd-dot' style='background:{0};'></span></td>" +
                            "<td style='font-weight:600;color:#05275C;'>{1}</td>" +
                            "<td class='r' style='font-variant-numeric:tabular-nums;'>UGX {2}</td>" +
                            "<td class='c'><strong>{3}</strong></td>" +
                            "<td class='r' style='font-variant-numeric:tabular-nums;font-weight:700;color:#00695c;'>{4}</td>" +
                            "<td class='c'>{5}%</td>" +
                            "<td><div class='bd-progress'><div class='bd-progress__fill' style='width:{5}%;background:{0};'></div></div></td>" +
                            "<td class='c'><span class='bd-badge {6}'>{7}</span></td>" +
                            "</tr>",
                            HtmlEnc(color),
                            HtmlEnc(name),
                            burAmt.ToString("N0"),
                            cnt,
                            awarded.ToString("N0"),
                            sharePct,
                            badgeCls,
                            HtmlEnc(status));
                        idx++;
                    }

                    if (rows.Count == 0)
                    {
                        sb.Append("<tr><td colspan='8' class='bd-table__empty'>No data for " + HtmlEnc(year) + "</td></tr>");
                    }
                    else
                    {
                        // Totals row
                        double grandPct = grandTotal > 0 ? 100.0 : 0;
                        sb.AppendFormat(
                            "<tr class='bd-tr--total'>" +
                            "<td></td><td>TOTAL</td><td></td>" +
                            "<td class='c'>{0}</td>" +
                            "<td class='r'>UGX {1}</td>" +
                            "<td class='c'>100%</td><td></td><td></td></tr>",
                            totalBens,
                            totalAwarded.ToString("N0"));
                    }

                    litSchemeTableMeta.Text = grandTotal + " total beneficiar" + (grandTotal != 1 ? "ies" : "y");
                }
            }
        }

        litSchemeRows.Text = sb.ToString();
    }

    // ====================================================================
    // Year Summary Table
    // ====================================================================
    private void LoadYearSummaryTable()
    {
        var sb = new StringBuilder();
        string currentYear = ddlYear.SelectedValue;

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"SELECT ss.scholarhipYear,
                                  COUNT(*) AS total,
                                  IFNULL(SUM(ss.amount_offered),0) AS total_amount
                           FROM scholarshipstudents ss
                           GROUP BY ss.scholarhipYear
                           ORDER BY ss.scholarhipYear DESC";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    string yr    = rdr["scholarhipYear"].ToString();
                    long   total = Convert.ToInt64(rdr["total"]);
                    double amt   = Convert.ToDouble(rdr["total_amount"]);
                    double avg   = total > 0 ? amt / total : 0;
                    bool   isCur = yr == currentYear;

                    sb.AppendFormat(
                        "<tr>" +
                        "<td><span class='bd-year-badge{0}'>{1}</span></td>" +
                        "<td class='c'><strong>{2}</strong></td>" +
                        "<td class='r' style='font-variant-numeric:tabular-nums;'>UGX {3}</td>" +
                        "<td class='r' style='font-variant-numeric:tabular-nums;color:#888;'>UGX {4}</td>" +
                        "</tr>",
                        isCur ? " bd-year-badge--current" : "",
                        HtmlEnc(yr),
                        total,
                        amt.ToString("N0"),
                        avg.ToString("N0"));
                }
            }
        }

        if (sb.Length == 0)
            sb.Append("<tr><td colspan='5' class='bd-table__empty'>No historical data available.</td></tr>");

        litYearRows.Text = sb.ToString();
    }

    // ====================================================================
    // Recent Beneficiaries
    // ====================================================================
    private void LoadRecentBeneficiaries(string year)
    {
        var sb = new StringBuilder();

        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"SELECT ss.adm_no, ss.amount_offered, sc.scholarshipName,
                                  IFNULL(CONCAT(st.firstname,' ',st.othername),'—') AS student_name
                           FROM scholarshipstudents ss
                           LEFT JOIN scholarships sc ON sc.scholarshipID = ss.scholarshipID
                           LEFT JOIN campus_dynamics.acad_student st ON st.regno = ss.adm_no
                           WHERE ss.scholarhipYear = @yr
                           ORDER BY ss.date_added DESC, ss.stid DESC
                           LIMIT 10";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@yr", year);
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        double amt = Convert.ToDouble(rdr["amount_offered"]);

                        sb.AppendFormat(
                            "<tr>" +
                            "<td style='font-weight:700;color:#05275C;font-size:11px;'>{0}</td>" +
                            "<td>{1}</td>" +
                            "<td style='color:#6d28d9;font-size:10px;'>{2}</td>" +
                            "<td class='r' style='font-variant-numeric:tabular-nums;'>UGX {3}</td>" +
                            "</tr>",
                            HtmlEnc(rdr["adm_no"].ToString()),
                            HtmlEnc(rdr["student_name"].ToString()),
                            HtmlEnc(rdr["scholarshipName"].ToString()),
                            amt.ToString("N0"));
                    }
                }
            }
        }

        if (sb.Length == 0)
            sb.Append("<tr><td colspan='5' class='bd-table__empty'>No beneficiaries for " + HtmlEnc(year) + ".</td></tr>");

        litRecentRows.Text = sb.ToString();
    }

    // ====================================================================
    // Emit Chart Data as JS variables
    // ====================================================================
    private void EmitChartData(string selectedYear)
    {
        using (MySqlConnection conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // --- Trend data: all years ---
            var trendYears   = new List<string>();
            var trendCounts  = new List<long>();
            var trendAmounts = new List<string>(); // millions, 1dp

            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT scholarhipYear,
                         COUNT(*) AS cnt,
                         IFNULL(SUM(amount_offered),0) AS amt
                  FROM scholarshipstudents
                  GROUP BY scholarhipYear ORDER BY scholarhipYear ASC", conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    trendYears.Add(rdr["scholarhipYear"].ToString());
                    trendCounts.Add(Convert.ToInt64(rdr["cnt"]));
                    double amtM = Convert.ToDouble(rdr["amt"]) / 1000000.0;
                    trendAmounts.Add(amtM.ToString("F2"));
                }
            }

            // --- Scheme data for selected year ---
            var schemeLabels  = new List<string>();
            var schemeCounts  = new List<long>();
            var schemeAmounts = new List<double>();

            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT sc.scholarshipName, COUNT(*) AS cnt,
                         IFNULL(SUM(ss.amount_offered),0) AS amt
                  FROM scholarshipstudents ss
                  JOIN scholarships sc ON sc.scholarshipID = ss.scholarshipID
                  WHERE ss.scholarhipYear = @yr
                  GROUP BY ss.scholarshipID ORDER BY cnt DESC", conn))
            {
                cmd.Parameters.AddWithValue("@yr", selectedYear);
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        schemeLabels.Add(rdr["scholarshipName"].ToString());
                        schemeCounts.Add(Convert.ToInt64(rdr["cnt"]));
                        schemeAmounts.Add(Convert.ToDouble(rdr["amt"]));
                    }
                }
            }

            // --- Study-year distribution for selected year ---
            var syLabels = new List<string>();
            var syCounts = new List<long>();

            using (MySqlCommand cmd = new MySqlCommand(
                @"SELECT GREATEST(1, CAST(SUBSTRING(scholarhipYear,1,4) AS SIGNED) - CAST(SUBSTRING(adm_no,4,4) AS SIGNED) + 1) AS study_yr,
                         COUNT(*) AS cnt
                  FROM scholarshipstudents
                  WHERE scholarhipYear = @yr
                  GROUP BY study_yr ORDER BY study_yr ASC", conn))
            {
                cmd.Parameters.AddWithValue("@yr", selectedYear);
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        syLabels.Add("Year " + rdr["study_yr"]);
                        syCounts.Add(Convert.ToInt64(rdr["cnt"]));
                    }
                }
            }

            // --- Build JSON ---
            string trendJs = string.Format(
                "var _trendData = {{years:[{0}],counts:[{1}],amounts:[{2}]}};",
                string.Join(",", trendYears.ConvertAll(s => "\"" + JsEsc(s) + "\"")),
                string.Join(",", trendCounts),
                string.Join(",", trendAmounts));

            string schemeJs = string.Format(
                "var _schemeData = {{labels:[{0}],counts:[{1}],amounts:[{2}]}};",
                string.Join(",", schemeLabels.ConvertAll(s => "\"" + JsEsc(s) + "\"")),
                string.Join(",", schemeCounts),
                string.Join(",", schemeAmounts.ConvertAll(a => a.ToString("F0"))));

            string syJs = string.Format(
                "var _studyYearData = {{labels:[{0}],counts:[{1}]}};",
                string.Join(",", syLabels.ConvertAll(s => "\"" + JsEsc(s) + "\"")),
                string.Join(",", syCounts));

            ScriptManager.RegisterStartupScript(this, GetType(), "chartData",
                trendJs + "\n" + schemeJs + "\n" + syJs, true);
        }
    }

    // ====================================================================
    // Helpers
    // ====================================================================
    private static string JsEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "");
    }

    private string HtmlEnc(string s)
    {
        return Server.HtmlEncode(s ?? "");
    }
}
