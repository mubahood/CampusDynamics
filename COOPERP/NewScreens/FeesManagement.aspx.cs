using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_FeesManagement : System.Web.UI.Page
{
    // ===================================================================
    // CONNECTION STRINGS
    // ===================================================================

    private string AcctConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["accountsConnectionString"];
            return cs != null ? cs.ConnectionString
                : "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    private string MainConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ===================================================================
    // HELPERS
    // ===================================================================

    private void TrySelect(DropDownList ddl, string value)
    {
        var item = ddl.Items.FindByValue(value);
        if (item != null) item.Selected = true;
    }

    private string FormatCurrency(double amount)
    {
        return string.Format("UGX {0:N0}", amount);
    }

    private void AddSemParam(MySqlCommand cmd, string semFilter)
    {
        if (!string.IsNullOrEmpty(semFilter))
            cmd.Parameters.AddWithValue("@sem", int.Parse(semFilter));
    }

    private string BuildTrendHtml(double current, double previous, string prevYear, bool invertColor)
    {
        if (previous <= 0) return "";
        double change = ((current - previous) / previous) * 100;
        bool isUp = change > 0.5;
        bool isDown = change < -0.5;
        string cssClass, arrow;
        if (isUp)
        {
            cssClass = invertColor ? "fd-trend--down" : "fd-trend--up";
            arrow = "<polyline points='18 15 12 9 6 15'/>";
        }
        else if (isDown)
        {
            cssClass = invertColor ? "fd-trend--up" : "fd-trend--down";
            arrow = "<polyline points='6 9 12 15 18 9'/>";
        }
        else
        {
            cssClass = "fd-trend--flat";
            arrow = "<line x1='5' y1='12' x2='19' y2='12'/>";
        }
        string sign = change > 0 ? "+" : "";
        return string.Format(
            "<div class='fd-kpi__trend {0}'>" +
            "<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5'>{1}</svg>" +
            "{2}{3:F1}% vs {4}</div>",
            cssClass, arrow, sign, change, Server.HtmlEncode(prevYear));
    }

    // Enrolled-only base SQL fragment (reused across queries)
    // Joins fin_studentfeestracking → acad_registration → acad_student
    // Filters: acadyear match, registered statuses, ACTIVE students
    private const string ENROLLED_JOIN = @"
        INNER JOIN campus_dynamics.acad_registration r
            ON r.regno = ft.regno AND r.acad_year = ft.acadyear AND r.semester = ft.semester
        INNER JOIN campus_dynamics.acad_student s
            ON s.regno = ft.regno AND s.new_status = 'ACTIVE'";

    private const string ENROLLED_WHERE = @"
        AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')";

    // Excludes bursaries (item 75), bill waivers, and balance-fix adjustments — leaving only real cash
    private const string CASH_PAY_COND = @"
        AND ft.item_code != 75
        AND ft.detail NOT LIKE 'Bill Waiver%'
        AND ft.detail NOT LIKE 'Balance Fix%'";

    // ===================================================================
    // PAGE LIFECYCLE
    // ===================================================================

    protected void Page_Load(object sender, EventArgs e)
    {
        LoadAcademicYears();

        string postedYear = Request.Form[ddlAcadYear.UniqueID];
        if (!string.IsNullOrEmpty(postedYear))
            TrySelect(ddlAcadYear, postedYear);
        else if (!IsPostBack)
            SetDefaultYear();

        // Semester filter postback preservation
        string postedSem = Request.Form[ddlSemester.UniqueID];
        if (!string.IsNullOrEmpty(postedSem))
            TrySelect(ddlSemester, postedSem);

        LoadDashboard();
    }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Page_Load already calls LoadDashboard unconditionally
    }

    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Page_Load already calls LoadDashboard unconditionally
    }

    // ===================================================================
    // DATA LOADING — Dropdown
    // ===================================================================

    private void LoadAcademicYears()
    {
        using (var conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT DISTINCT acad_year FROM acad_registration ORDER BY acad_year DESC", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                ddlAcadYear.Items.Clear();
                while (rdr.Read())
                {
                    string y = rdr["acad_year"].ToString();
                    ddlAcadYear.Items.Add(new ListItem(y, y));
                }
            }
        }
    }

    private void SetDefaultYear()
    {
        string ay = AcademicYearHelper.GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(ay) != null)
            ddlAcadYear.SelectedValue = ay;
        else if (ddlAcadYear.Items.Count > 0)
            ddlAcadYear.SelectedIndex = 0;
    }

    // ===================================================================
    // MAIN DASHBOARD ORCHESTRATOR
    // ===================================================================

    private void LoadDashboard()
    {
        string yearFilter = ddlAcadYear.SelectedValue;

        // Fallback: ensure we always have a year
        if (string.IsNullOrEmpty(yearFilter))
        {
            if (ddlAcadYear.Items.Count > 0)
            {
                ddlAcadYear.SelectedIndex = 0;
                yearFilter = ddlAcadYear.SelectedValue;
            }
            if (string.IsNullOrEmpty(yearFilter)) return;
        }

        string semFilter = ddlSemester.SelectedValue;
        string semLabel = string.IsNullOrEmpty(semFilter) ? "" : " &middot; Sem " + semFilter;
        litAcadContext.Text = string.Format(
            "<span class='fs-badge fs-badge--primary'>{0}{1}</span>",
            Server.HtmlEncode(yearFilter), semLabel);

        // Each section loads independently — one failure must not cascade to others
        try { LoadHeroStats(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadHeroStats error: " + ex.Message); }

        try { LoadFeeTypeBreakdown(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadFeeTypeBreakdown error: " + ex.Message); }

        try { LoadSemesterData(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadSemesterData error: " + ex.Message); }

        try { LoadMonthlyPayments(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadMonthlyPayments error: " + ex.Message); }

        try { LoadDailyPayments(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadDailyPayments error: " + ex.Message); }

        try { LoadProgrammeRevenue(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadProgrammeRevenue error: " + ex.Message); }

        try { LoadTopDebtors(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadTopDebtors error: " + ex.Message); }

        try { LoadAnomalyStats(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadAnomalyStats error: " + ex.Message); }

        try { LoadLatestPayments(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadLatestPayments error: " + ex.Message); }

        try { LoadLatestBillings(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadLatestBillings error: " + ex.Message); }

        try { LoadPaymentChannels(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadPaymentChannels error: " + ex.Message); }

        LoadPaidButUnregistered();
    }

    // ===================================================================
    // 1. HERO KPI STATS + YEAR-OVER-YEAR
    // ===================================================================

    private void LoadHeroStats(string yearFilter, string semFilter)
    {
        string semSqlR = string.IsNullOrEmpty(semFilter) ? "" : " AND r.semester = @sem";
        string semSqlFT = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";

        // (a) Enrolled student count — current year
        long enrolledCount = 0;
        using (var conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"
                SELECT COUNT(DISTINCT r.regno)
                FROM acad_registration r
                INNER JOIN acad_student s ON s.regno = r.regno AND s.new_status = 'ACTIVE'
                WHERE r.acad_year = @ay
                  AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')" + semSqlR, conn))
            {
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                object val = cmd.ExecuteScalar();
                enrolledCount = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }
        }
        litStatEnrolled.Text = enrolledCount.ToString("N0");

        // (b) Financial totals — current year, enrolled only (cash vs non-cash split)
        double billed = 0, cashReceived = 0, bursaries = 0, waivers = 0, totalCredits = 0, balance = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END),0) AS total_billed,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment'
                                      AND ft.item_code != 75
                                      AND ft.detail NOT LIKE 'Bill Waiver%'
                                      AND ft.detail NOT LIKE 'Balance Fix%'
                                      THEN ft.amount ELSE 0 END),0) AS cash_received,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment' AND ft.item_code = 75
                                      THEN ft.amount ELSE 0 END),0) AS bursaries,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment'
                                      AND (ft.detail LIKE 'Bill Waiver%' OR ft.detail LIKE 'Balance Fix%')
                                      THEN ft.amount ELSE 0 END),0) AS waivers_adj,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END),0) AS total_all_credits,
                    SUM(CASE WHEN ft.trans_type='Bill' THEN 1 ELSE 0 END) AS bill_count,
                    SUM(CASE WHEN ft.trans_type='Payment'
                             AND ft.item_code != 75
                             AND ft.detail NOT LIKE 'Bill Waiver%'
                             AND ft.detail NOT LIKE 'Balance Fix%'
                             THEN 1 ELSE 0 END) AS cash_count
                FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
                WHERE ft.acadyear = @ay" + ENROLLED_WHERE + semSqlFT;

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        billed        = Convert.ToDouble(rdr["total_billed"]);
                        cashReceived  = Convert.ToDouble(rdr["cash_received"]);
                        bursaries     = Convert.ToDouble(rdr["bursaries"]);
                        waivers       = Convert.ToDouble(rdr["waivers_adj"]);
                        totalCredits  = Convert.ToDouble(rdr["total_all_credits"]);
                        long billCnt  = Convert.ToInt64(rdr["bill_count"]);
                        long cashCnt  = Convert.ToInt64(rdr["cash_count"]);

                        balance = billed - totalCredits;
                        if (balance < 0) balance = 0;
                        double cashRate = billed > 0 ? (cashReceived / billed) * 100 : 0;

                        litStatBilled.Text    = FormatCurrency(billed);
                        litStatPaid.Text      = FormatCurrency(cashReceived);
                        litStatBalance.Text   = FormatCurrency(balance);
                        litStatBillCount.Text = string.Format("{0:N0} invoices", billCnt);
                        litStatPayCount.Text  = string.Format("{0:N0} cash payments", cashCnt);
                        litStatCollRate.Text  = string.Format("{0:F1}% cash collection", cashRate);

                        hfDonutPaid.Value = cashReceived.ToString("F0");
                        hfDonutBal.Value  = balance.ToString("F0");

                        litCashBreakdown.Text = BuildCreditBreakdownHtml(cashReceived, bursaries, waivers, totalCredits, billed, cashRate);
                    }
                }
            }
        }

        // (c) Year-over-Year comparison
        try { LoadYoYTrends(yearFilter, semFilter, enrolledCount, billed, cashReceived, balance); }
        catch { /* YoY is non-critical */ }
    }

    private void LoadYoYTrends(string yearFilter, string semFilter,
        long currEnrolled, double currBilled, double currPaid, double currBalance)
    {
        string semSqlR = string.IsNullOrEmpty(semFilter) ? "" : " AND r.semester = @sem";
        string semSqlFT = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";

        // Determine previous academic year
        string prevYear = null;
        using (var conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT MAX(acad_year) FROM acad_registration WHERE acad_year < @ay", conn))
            {
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                object v = cmd.ExecuteScalar();
                if (v != null && v != DBNull.Value)
                    prevYear = v.ToString();
            }
        }
        if (string.IsNullOrEmpty(prevYear)) return;

        // Previous year enrolled count
        long prevEnrolled = 0;
        using (var conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(@"
                SELECT COUNT(DISTINCT r.regno)
                FROM acad_registration r
                INNER JOIN acad_student s ON s.regno = r.regno AND s.new_status = 'ACTIVE'
                WHERE r.acad_year = @ay
                  AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')" + semSqlR, conn))
            {
                cmd.Parameters.AddWithValue("@ay", prevYear);
                AddSemParam(cmd, semFilter);
                object v = cmd.ExecuteScalar();
                prevEnrolled = v != null && v != DBNull.Value ? Convert.ToInt64(v) : 0;
            }
        }

        // Previous year financials — cash only for accurate comparison
        double prevBilled = 0, prevPaid = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END),0) AS total_billed,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment'
                                      AND ft.item_code != 75
                                      AND ft.detail NOT LIKE 'Bill Waiver%'
                                      AND ft.detail NOT LIKE 'Balance Fix%'
                                      THEN ft.amount ELSE 0 END),0) AS total_paid
                FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
                WHERE ft.acadyear = @ay" + ENROLLED_WHERE + semSqlFT;

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", prevYear);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        prevBilled = rdr["total_billed"] != DBNull.Value ? Convert.ToDouble(rdr["total_billed"]) : 0;
                        prevPaid = rdr["total_paid"] != DBNull.Value ? Convert.ToDouble(rdr["total_paid"]) : 0;
                    }
                }
            }
        }

        double prevBalance = prevBilled - prevPaid;
        if (prevBalance < 0) prevBalance = 0;

        // Set trend indicators
        litTrendEnrolled.Text = BuildTrendHtml(currEnrolled, prevEnrolled, prevYear, false);
        litTrendBilled.Text   = BuildTrendHtml(currBilled, prevBilled, prevYear, false);
        litTrendPaid.Text     = BuildTrendHtml(currPaid, prevPaid, prevYear, false);
        litTrendBalance.Text  = BuildTrendHtml(currBalance, prevBalance, prevYear, true);
    }

    // ===================================================================
    // 2. FEE TYPE BREAKDOWN (horizontal bars)
    // ===================================================================

    private void LoadFeeTypeBreakdown(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' AND ft.item_code=1  THEN ft.amount ELSE 0 END),0) AS tuition,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' AND ft.item_code=52 THEN ft.amount ELSE 0 END),0) AS functional,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' AND ft.item_code NOT IN (1,52) THEN ft.amount ELSE 0 END),0) AS other_fees,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END),0) AS total_bill
                FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
                WHERE ft.acadyear = @ay" + ENROLLED_WHERE + semSql;

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        double tuition    = Convert.ToDouble(rdr["tuition"]);
                        double functional = Convert.ToDouble(rdr["functional"]);
                        double other      = Convert.ToDouble(rdr["other_fees"]);
                        double total      = Convert.ToDouble(rdr["total_bill"]);

                        double pctT = total > 0 ? (tuition / total * 100)    : 0;
                        double pctF = total > 0 ? (functional / total * 100) : 0;
                        double pctO = total > 0 ? (other / total * 100)      : 0;

                        var sb = new StringBuilder();

                        // Tuition bar
                        sb.AppendFormat(
                            "<div class='fd-hbar-row'>" +
                            "<div class='fd-hbar-label'>Tuition</div>" +
                            "<div class='fd-hbar-track'><div class='fd-hbar-fill fd-hbar-fill--navy' style='width:{0:F0}%'>" +
                            "<span class='fd-hbar-pct'>{0:F0}%</span></div></div>" +
                            "<div class='fd-hbar-value'>{1}</div></div>",
                            pctT, FormatCurrency(tuition));

                        // Functional bar
                        sb.AppendFormat(
                            "<div class='fd-hbar-row'>" +
                            "<div class='fd-hbar-label'>Functional</div>" +
                            "<div class='fd-hbar-track'><div class='fd-hbar-fill fd-hbar-fill--blue' style='width:{0:F0}%'>" +
                            "<span class='fd-hbar-pct'>{0:F0}%</span></div></div>" +
                            "<div class='fd-hbar-value'>{1}</div></div>",
                            pctF, FormatCurrency(functional));

                        // Other fees bar
                        sb.AppendFormat(
                            "<div class='fd-hbar-row'>" +
                            "<div class='fd-hbar-label'>Other Fees</div>" +
                            "<div class='fd-hbar-track'><div class='fd-hbar-fill fd-hbar-fill--amber' style='width:{0:F0}%'>" +
                            "<span class='fd-hbar-pct'>{0:F0}%</span></div></div>" +
                            "<div class='fd-hbar-value'>{1}</div></div>",
                            pctO, FormatCurrency(other));

                        litFeeTypeBars.Text = sb.ToString();
                    }
                }
            }
        }
    }

    // ===================================================================
    // 3. SEMESTER DATA (cards + chart data)
    // ===================================================================

    private void LoadSemesterData(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        var cards = new StringBuilder();
        var semLabels = new List<string>();
        var semBilled = new List<string>();
        var semPaid   = new List<string>();
        var semBalance = new List<string>();
        var semRate   = new List<string>();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT ft.semester,
                    SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END) AS billed,
                    SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END) AS paid,
                    COUNT(DISTINCT CASE WHEN ft.trans_type='Bill' THEN ft.regno END) AS students
                FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
                WHERE ft.acadyear = @ay" + ENROLLED_WHERE + semSql + @"
                GROUP BY ft.semester ORDER BY ft.semester";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        int sem    = Convert.ToInt32(rdr["semester"]);
                        double b   = Convert.ToDouble(rdr["billed"]);
                        double p   = Convert.ToDouble(rdr["paid"]);
                        long st    = Convert.ToInt64(rdr["students"]);
                        double bal = b - p;
                        if (bal < 0) bal = 0;
                        double pct = b > 0 ? (p / b) * 100 : 0;

                        string pctClass   = pct >= 80 ? "green" : (pct >= 50 ? "amber" : "red");
                        string badgeClass = pct >= 70 ? "ok" : (pct >= 40 ? "warn" : "red");

                        cards.AppendFormat(@"
                        <div class='fd-sem-card'>
                            <div class='fd-sem-card__head'>
                                <div class='fd-sem-card__title'>Semester {0}</div>
                                <span class='fd-sem-card__badge fd-sem-card__badge--{1}'>{2:F0}% collected</span>
                            </div>
                            <div class='fd-row'><span class='fd-row__label'>Enrolled &amp; Billed</span><span class='fd-row__val'>{3:N0}</span></div>
                            <div class='fd-row'><span class='fd-row__label'>Total Billed</span><span class='fd-row__val'>{4}</span></div>
                            <div class='fd-row'><span class='fd-row__label'>Total Paid</span><span class='fd-row__val fd-row__val--green'>{5}</span></div>
                            <div class='fd-row'><span class='fd-row__label'>Outstanding</span><span class='fd-row__val fd-row__val--{6}'>{7}</span></div>
                            <div class='fd-progress'><div class='fd-progress__fill fd-progress__fill--{8}' style='width:{9:F0}%'></div></div>
                            <div class='fd-progress-label'>{10:F1}% collected</div>
                        </div>",
                            sem, badgeClass, pct, st,
                            FormatCurrency(b), FormatCurrency(p),
                            bal > 0 ? "amber" : "green", FormatCurrency(bal),
                            pctClass, Math.Min(pct, 100), pct);

                        semLabels.Add(sem.ToString());
                        semBilled.Add(b.ToString("F0"));
                        semPaid.Add(p.ToString("F0"));
                        semBalance.Add(bal.ToString("F0"));
                        semRate.Add(pct.ToString("F1"));
                    }
                }
            }
        }

        litSemesterCards.Text = cards.Length > 0 ? cards.ToString()
            : "<div style='grid-column:1/-1;text-align:center;padding:20px;color:#aaa;font-size:12px;'>No semester data for selected year</div>";
    }

    // ===================================================================
    // 4. MONTHLY PAYMENTS (chart data)
    // ===================================================================

    private void LoadMonthlyPayments(string yearFilter, string semFilter)
    {
        string semSql   = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        string semSqlNc = string.IsNullOrEmpty(semFilter) ? "" : " AND fnc.semester = @sem";
        string semSql2  = string.IsNullOrEmpty(semFilter) ? "" : " AND ft2.semester = @sem";
        var labels       = new List<string>();
        var cashValues   = new List<string>();
        var nonCashValues= new List<string>();
        var billValues   = new List<string>();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT DATE_FORMAT(m.month_start, '%b-%y') AS month_label,
                       m.month_start,
                       (SELECT COALESCE(SUM(ft.amount),0)
                        FROM fin_studentfeestracking ft
                        INNER JOIN campus_dynamics.acad_student s ON s.regno = ft.regno AND s.new_status = 'ACTIVE'
                        INNER JOIN campus_dynamics.acad_registration r ON r.regno = ft.regno AND r.acad_year = ft.acadyear
                            AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                        WHERE ft.trans_type = 'Payment'
                          AND ft.item_code != 75
                          AND ft.detail NOT LIKE 'Bill Waiver%'
                          AND ft.detail NOT LIKE 'Balance Fix%'
                          AND DATE_FORMAT(ft.trans_date, '%Y-%m') = DATE_FORMAT(m.month_start, '%Y-%m')
                          AND ft.trans_date IS NOT NULL" + semSql + @"
                       ) AS cash_received,
                       (SELECT COALESCE(SUM(fnc.amount),0)
                        FROM fin_studentfeestracking fnc
                        INNER JOIN campus_dynamics.acad_student snc ON snc.regno = fnc.regno AND snc.new_status = 'ACTIVE'
                        INNER JOIN campus_dynamics.acad_registration rnc ON rnc.regno = fnc.regno AND rnc.acad_year = fnc.acadyear
                            AND rnc.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                        WHERE fnc.trans_type = 'Payment'
                          AND (fnc.item_code = 75 OR fnc.detail LIKE 'Bill Waiver%' OR fnc.detail LIKE 'Balance Fix%')
                          AND DATE_FORMAT(fnc.trans_date, '%Y-%m') = DATE_FORMAT(m.month_start, '%Y-%m')
                          AND fnc.trans_date IS NOT NULL" + semSqlNc + @"
                       ) AS non_cash,
                       (SELECT COALESCE(SUM(ft2.amount),0)
                        FROM fin_studentfeestracking ft2
                        INNER JOIN campus_dynamics.acad_student s2 ON s2.regno = ft2.regno AND s2.new_status = 'ACTIVE'
                        INNER JOIN campus_dynamics.acad_registration r2 ON r2.regno = ft2.regno AND r2.acad_year = ft2.acadyear
                            AND r2.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                        WHERE ft2.trans_type = 'Bill'
                          AND DATE_FORMAT(ft2.trans_date, '%Y-%m') = DATE_FORMAT(m.month_start, '%Y-%m')
                          AND ft2.trans_date IS NOT NULL" + semSql2 + @"
                       ) AS total_billed
                FROM (
                    SELECT DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL n MONTH), '%Y-%m-01') AS month_start
                    FROM (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3
                          UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7
                          UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11) nums
                ) m
                ORDER BY m.month_start";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 120;
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        labels.Add(rdr["month_label"].ToString());
                        cashValues.Add(Convert.ToDouble(rdr["cash_received"]).ToString("F0"));
                        nonCashValues.Add(Convert.ToDouble(rdr["non_cash"]).ToString("F0"));
                        billValues.Add(Convert.ToDouble(rdr["total_billed"]).ToString("F0"));
                    }
                }
            }
        }

        hfMonthLabels.Value     = string.Join(",", labels.ToArray());
        hfMonthValues.Value     = string.Join(",", cashValues.ToArray());
        hfMonthBillValues.Value = string.Join(",", billValues.ToArray());
        hfMonthNonCash.Value    = string.Join(",", nonCashValues.ToArray());
    }

    // ===================================================================
    // 5. DAILY PAYMENTS (Past 15 Days — line chart data)
    // ===================================================================

    private void LoadDailyPayments(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        var labels = new List<string>();
        var values = new List<string>();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            // Daily payment totals for past 30 days (enrolled students only)
            string sql = @"
                SELECT DATE_FORMAT(d.date, '%d %b (%a)') AS day_label,
                       d.date,
                       (SELECT COALESCE(SUM(ft.amount),0)
                        FROM fin_studentfeestracking ft
                        INNER JOIN campus_dynamics.acad_student s ON s.regno = ft.regno AND s.new_status = 'ACTIVE'
                        INNER JOIN campus_dynamics.acad_registration r ON r.regno = ft.regno AND r.acad_year = ft.acadyear
                            AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                        WHERE ft.trans_type = 'Payment'
                          AND ft.item_code != 75
                          AND ft.detail NOT LIKE 'Bill Waiver%'
                          AND ft.detail NOT LIKE 'Balance Fix%'
                          AND DATE(ft.trans_date) = d.date
                          AND ft.trans_date IS NOT NULL" + semSql + @"
                       ) AS daily_paid
                FROM (
                    SELECT DATE_SUB(CURDATE(), INTERVAL n DAY) AS date
                    FROM (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 
                          UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7
                          UNION SELECT 8 UNION SELECT 9 UNION SELECT 10 UNION SELECT 11
                          UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
                          UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19
                          UNION SELECT 20 UNION SELECT 21 UNION SELECT 22 UNION SELECT 23
                          UNION SELECT 24 UNION SELECT 25 UNION SELECT 26 UNION SELECT 27
                          UNION SELECT 28 UNION SELECT 29) nums
                    ORDER BY n
                ) d
                ORDER BY d.date ASC";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        labels.Add(rdr["day_label"].ToString());
                        values.Add(Convert.ToDouble(rdr["daily_paid"]).ToString("F0"));
                    }
                }
            }
        }

        hfDailyLabels.Value = string.Join(",", labels.ToArray());
        hfDailyValues.Value = string.Join(",", values.ToArray());
    }

    // ===================================================================
    // 6. PROGRAMME REVENUE (top 10)
    // ===================================================================

    private void LoadProgrammeRevenue(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        var progData = new List<object[]>();
        double maxBilled = 0;

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT s.progid,
                    COALESCE(p.progname, s.progid) AS programme_name,
                    SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END) AS billed,
                    SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END) AS paid,
                    COUNT(DISTINCT ft.regno) AS student_count
                FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
                LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = s.progid
                WHERE ft.acadyear = @ay" + ENROLLED_WHERE + semSql + @"
                GROUP BY s.progid, programme_name
                ORDER BY billed DESC
                LIMIT 10";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        double b = Convert.ToDouble(rdr["billed"]);
                        double p = Convert.ToDouble(rdr["paid"]);
                        if (b > maxBilled) maxBilled = b;
                        progData.Add(new object[] {
                            rdr["progid"].ToString(),
                            rdr["programme_name"].ToString(),
                            b, p,
                            Convert.ToInt64(rdr["student_count"])
                        });
                    }
                }
            }
        }

        var rows = new StringBuilder();
        int count = 0;

        foreach (var prog in progData)
        {
            count++;
            string code = (string)prog[0];
            string name = (string)prog[1];
            double b    = (double)prog[2];
            double p    = (double)prog[3];
            long st     = (long)prog[4];
            double pct  = b > 0 ? (p / b) * 100 : 0;
            double barW = maxBilled > 0 ? (b / maxBilled * 100) : 0;
            string pctColor = pct >= 80 ? "#155724" : (pct >= 50 ? "#b45309" : "#dc3545");

            rows.AppendFormat(
                "<tr><td><div style='font-weight:600;font-size:12px;'>{0}</div>" +
                "<div style='font-size:10px;color:#174DA4;font-family:Consolas,monospace;font-weight:600;'>{1}</div></td>" +
                "<td style='text-align:right;'>{2:N0}</td>" +
                "<td style='text-align:right;font-weight:600;'>{3}</td>" +
                "<td style='text-align:right;color:#155724;font-weight:600;'>{4}</td>" +
                "<td><div class='fd-prog-bar'><div class='fd-prog-bar__fill' style='width:{5:F0}%'></div></div></td>" +
                "<td style='text-align:right;color:{6};font-weight:700;'>{7:F1}%</td></tr>",
                Server.HtmlEncode(name), Server.HtmlEncode(code),
                st, FormatCurrency(b), FormatCurrency(p),
                barW, pctColor, pct);
        }

        if (count == 0)
            rows.Append("<tr><td colspan='6' style='text-align:center;color:#aaa;padding:30px;font-size:12px;'>No programme data for selected year</td></tr>");

        litProgRows.Text  = rows.ToString();
        litProgCount.Text = string.Format("{0} programme{1}", count, count == 1 ? "" : "s");
    }

    // ===================================================================
    // 6. TOP DEBTORS (enrolled students only)
    // ===================================================================

    private void LoadTopDebtors(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        string sql = @"
            SELECT ft.regno,
                TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                COALESCE(s.progid,'') AS progid,
                SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END) AS billed,
                SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END) AS paid
            FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
            WHERE ft.acadyear = @ay" + ENROLLED_WHERE + semSql + @"
            GROUP BY ft.regno
            HAVING SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END)
                 > SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END)
            ORDER BY (SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END)
                    - SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END)) DESC
            LIMIT 15";

        var rows = new StringBuilder();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    int cnt = 0;
                    while (rdr.Read())
                    {
                        cnt++;
                        double b = Convert.ToDouble(rdr["billed"]);
                        double p = Convert.ToDouble(rdr["paid"]);
                        rows.AppendFormat(
                            "<tr><td style='font-weight:600;'>{0}</td><td>{1}</td>" +
                            "<td><span class='fs-code'>{2}</span></td>" +
                            "<td style='text-align:right;font-weight:600;'>{3}</td>" +
                            "<td style='text-align:right;color:#155724;'>{4}</td>" +
                            "<td style='text-align:right;color:#dc3545;font-weight:700;'>{5}</td></tr>",
                            Server.HtmlEncode(rdr["regno"].ToString()),
                            Server.HtmlEncode(rdr["student_name"].ToString()),
                            Server.HtmlEncode(rdr["progid"].ToString()),
                            FormatCurrency(b), FormatCurrency(p), FormatCurrency(b - p));
                    }
                    if (cnt == 0)
                        rows.Append("<tr><td colspan='6' style='text-align:center;color:#aaa;padding:30px;font-size:12px;'>No outstanding balances</td></tr>");
                }
            }
        }

        litDebtorRows.Text = rows.ToString();
    }

    // ===================================================================
    // 7. DATA INTEGRITY — Anomaly Stats
    // ===================================================================

    private void LoadAnomalyStats(string yearFilter, string semFilter)
    {
        string semSqlR = string.IsNullOrEmpty(semFilter) ? "" : " AND r.semester = @sem";
        string semSqlFT = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        string semSqlBare = string.IsNullOrEmpty(semFilter) ? "" : " AND semester = @sem";
        long regNotBilled = 0, billsNoGL = 0, duplicateBills = 0;

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // (a) Registered but NOT billed
            string sql1 = @"
                SELECT COUNT(DISTINCT r.regno)
                FROM campus_dynamics.acad_registration r
                INNER JOIN campus_dynamics.acad_student s ON s.regno = r.regno AND s.new_status = 'ACTIVE'
                WHERE r.acad_year = @ay
                  AND r.regstatus IN ('REGISTERED','LATE REGISTERED')" + semSqlR + @"
                  AND NOT EXISTS(
                      SELECT 1 FROM fin_studentfeestracking ft
                      WHERE ft.regno = r.regno AND ft.acadyear = r.acad_year
                        AND ft.semester = r.semester AND ft.trans_type = 'Bill'
                  )";
            using (var cmd = new MySqlCommand(sql1, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                object val = cmd.ExecuteScalar();
                regNotBilled = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }

            // (b) Bills without GL entries
            string sql2 = @"
                SELECT COUNT(*) FROM fin_studentfeestracking ft
                WHERE ft.trans_type = 'Bill' AND ft.acadyear = @ay" + semSqlFT + @"
                  AND NOT EXISTS(
                      SELECT 1 FROM fin_ledger l
                      WHERE l.folio = CONCAT('BillNo:', ft.TID)
                  )";
            using (var cmd2 = new MySqlCommand(sql2, conn))
            {
                cmd2.CommandTimeout = 60;
                cmd2.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd2, semFilter);
                object val = cmd2.ExecuteScalar();
                billsNoGL = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }

            // (c) Duplicate bill groups
            string sql3 = @"
                SELECT COUNT(*) FROM (
                    SELECT regno, acadyear, semester, item_code
                    FROM fin_studentfeestracking
                    WHERE trans_type = 'Bill' AND acadyear = @ay" + semSqlBare + @"
                    GROUP BY regno, acadyear, semester, item_code
                    HAVING COUNT(*) > 1
                ) dups";
            using (var cmd3 = new MySqlCommand(sql3, conn))
            {
                cmd3.CommandTimeout = 60;
                cmd3.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd3, semFilter);
                object val = cmd3.ExecuteScalar();
                duplicateBills = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }
        }

        // Build anomaly cards HTML
        var cards = new StringBuilder();

        // Card 1: Registered but unbilled
        string c1Class = regNotBilled == 0 ? "ok" : (regNotBilled > 20 ? "danger" : "warn");
        string c1Icon = regNotBilled == 0
            ? "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#2e7d32' stroke-width='2'><polyline points='20 6 9 17 4 12'></polyline></svg>"
            : "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#e65100' stroke-width='2'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'></path><circle cx='9' cy='7' r='4'></circle><line x1='23' y1='11' x2='17' y2='11'></line></svg>";
        cards.AppendFormat(@"
            <div class='fd-anomaly fd-anomaly--{0}'>
                <div class='fd-anomaly__icon'>{1}</div>
                <div class='fd-anomaly__label'>Registered, Not Billed</div>
                <div class='fd-anomaly__val'>{2:N0}</div>
                <div class='fd-anomaly__hint'>{3}</div>
            </div>",
            c1Class, c1Icon, regNotBilled,
            regNotBilled == 0
                ? "All registered students have been billed"
                : string.Format("{0:N0} student(s) are registered but have no bill records", regNotBilled));

        // Card 2: Bills without GL
        string c2Class = billsNoGL == 0 ? "ok" : "warn";
        string c2Icon = billsNoGL == 0
            ? "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#2e7d32' stroke-width='2'><polyline points='20 6 9 17 4 12'></polyline></svg>"
            : "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#e65100' stroke-width='2'><circle cx='12' cy='12' r='10'></circle><line x1='12' y1='8' x2='12' y2='12'></line><line x1='12' y1='16' x2='12.01' y2='16'></line></svg>";
        cards.AppendFormat(@"
            <div class='fd-anomaly fd-anomaly--{0}'>
                <div class='fd-anomaly__icon'>{1}</div>
                <div class='fd-anomaly__label'>Bills Without GL Entries</div>
                <div class='fd-anomaly__val'>{2:N0}</div>
                <div class='fd-anomaly__hint'>{3}</div>
            </div>",
            c2Class, c2Icon, billsNoGL,
            billsNoGL == 0
                ? "All bills have corresponding ledger entries"
                : string.Format("{0:N0} bill(s) are missing general ledger entries", billsNoGL));

        // Card 3: Duplicate bills
        string c3Class = duplicateBills == 0 ? "ok" : "danger";
        string c3Icon = duplicateBills == 0
            ? "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#2e7d32' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'></path><polyline points='22 4 12 14.01 9 11.01'></polyline></svg>"
            : "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#dc3545' stroke-width='2'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'></path><line x1='12' y1='9' x2='12' y2='13'></line><line x1='12' y1='17' x2='12.01' y2='17'></line></svg>";
        cards.AppendFormat(@"
            <div class='fd-anomaly fd-anomaly--{0}'>
                <div class='fd-anomaly__icon'>{1}</div>
                <div class='fd-anomaly__label'>Duplicate Bill Groups</div>
                <div class='fd-anomaly__val'>{2:N0}</div>
                <div class='fd-anomaly__hint'>{3}</div>
            </div>",
            c3Class, c3Icon, duplicateBills,
            duplicateBills == 0
                ? "No duplicate billing detected \u2014 system is clean"
                : string.Format("{0:N0} student/item combination(s) have multiple bills", duplicateBills));

        litAnomalyCards.Text = cards.ToString();
    }

    // ===================================================================
    // CREDIT BREAKDOWN HTML BUILDER
    // ===================================================================

    private string BuildCreditBreakdownHtml(double cash, double bursary, double waiver, double total, double billed, double cashRate)
    {
        double bursaryRate = billed > 0 ? (bursary / billed * 100) : 0;
        double waiverRate  = billed > 0 ? (waiver  / billed * 100) : 0;
        double totalRate   = billed > 0 ? (total   / billed * 100) : 0;

        return string.Format(
            "<div class='fd-credits-row'>" +
              "<div class='fd-credit-card fd-credit-card--cash'>" +
                "<div class='fd-credit-card__icon'>" +
                  "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='#15803d' stroke-width='2'><rect x='1' y='4' width='22' height='16' rx='2'/><line x1='1' y1='10' x2='23' y2='10'/></svg>" +
                "</div>" +
                "<div class='fd-credit-card__label'>Cash Received</div>" +
                "<div class='fd-credit-card__value'>{0}</div>" +
                "<div class='fd-credit-card__sub'>Mobile Money &amp; Bank Deposits &mdash; {1:F1}% of billed</div>" +
              "</div>" +
              "<div class='fd-credit-card fd-credit-card--bursary'>" +
                "<div class='fd-credit-card__icon'>" +
                  "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='#1d4ed8' stroke-width='2'><path d='M22 12h-4l-3 9L9 3l-3 9H2'/></svg>" +
                "</div>" +
                "<div class='fd-credit-card__label'>Bursaries &amp; Scholarships</div>" +
                "<div class='fd-credit-card__value'>{2}</div>" +
                "<div class='fd-credit-card__sub'>Non-cash govt &amp; institutional grants &mdash; {3:F1}% of billed</div>" +
              "</div>" +
              "<div class='fd-credit-card fd-credit-card--waiver'>" +
                "<div class='fd-credit-card__icon'>" +
                  "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='#b45309' stroke-width='2'><polyline points='20 6 9 17 4 12'/><path d='M4 2v20l2-1 2 1 2-1 2 1 2-1 2 1 2-1 2 1V2'/></svg>" +
                "</div>" +
                "<div class='fd-credit-card__label'>Waivers &amp; Adjustments</div>" +
                "<div class='fd-credit-card__value'>{4}</div>" +
                "<div class='fd-credit-card__sub'>Bill corrections &amp; reconciliation fixes &mdash; {5:F1}% of billed</div>" +
              "</div>" +
              "<div class='fd-credit-card fd-credit-card--net'>" +
                "<div class='fd-credit-card__icon'>" +
                  "<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='#05275C' stroke-width='2'><line x1='12' y1='1' x2='12' y2='23'/><path d='M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6'/></svg>" +
                "</div>" +
                "<div class='fd-credit-card__label'>Total Credits Applied</div>" +
                "<div class='fd-credit-card__value'>{6}</div>" +
                "<div class='fd-credit-card__sub'>Cash + Bursaries + Waivers &mdash; {7:F1}% coverage</div>" +
              "</div>" +
            "</div>",
            FormatCurrency(cash),    cashRate,
            FormatCurrency(bursary), bursaryRate,
            FormatCurrency(waiver),  waiverRate,
            FormatCurrency(total),   totalRate);
    }

    // ===================================================================
    // PAYMENT CHANNELS (cash only — Mobile Money, Direct Bank, Other)
    // ===================================================================

    private void LoadPaymentChannels(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        var labels = new List<string>();
        var values = new List<string>();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT
                  CASE
                    WHEN ft.detail REGEXP 'MTN|Airtel|Mobile.Money|MoMo' THEN 'Mobile Money'
                    WHEN ft.detail REGEXP 'Stanbic|Centenary|DFCU|Equity|Absa|PostBank|Crane|Orient|Tropical|KCB|[Bb]ank' THEN 'Direct Bank'
                    ELSE 'Other Cash'
                  END AS channel,
                  COALESCE(SUM(ft.amount), 0) AS total
                FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
                WHERE ft.trans_type = 'Payment'
                  AND ft.item_code != 75
                  AND ft.detail NOT LIKE 'Bill Waiver%'
                  AND ft.detail NOT LIKE 'Balance Fix%'
                  AND ft.acadyear = @ay" + ENROLLED_WHERE + semSql + @"
                GROUP BY channel
                ORDER BY total DESC";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        labels.Add(rdr["channel"].ToString());
                        values.Add(Convert.ToDouble(rdr["total"]).ToString("F0"));
                    }
                }
            }
        }

        hfChannelLabels.Value = string.Join(",", labels.ToArray());
        hfChannelValues.Value = string.Join(",", values.ToArray());
    }

    // ===================================================================
    // 8. PAID BUT UNREGISTERED (last 30 days)
    // ===================================================================

    private void LoadPaidButUnregistered()
    {
        string currentYear = AcademicYearHelper.GetCurrentAcademicYear();
        if (string.IsNullOrEmpty(currentYear))
        {
            pnlPaidUnregistered.Visible = false;
            return;
        }

        try
        {
            string sql = @"
                SELECT ft.regno,
                    TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                    COALESCE(s.progid,'') AS progid,
                    SUM(ft.amount) AS total_paid_30d,
                    MAX(ft.trans_date) AS last_payment,
                    COALESCE(r.regstatus, 'NO RECORD') AS reg_status
                FROM fin_studentfeestracking ft
                LEFT JOIN campus_dynamics.acad_student s ON s.regno = ft.regno
                LEFT JOIN campus_dynamics.acad_registration r
                    ON r.regno = ft.regno AND r.acad_year = @ay
                    AND r.semester = (SELECT MAX(r2.semester)
                        FROM campus_dynamics.acad_registration r2
                        WHERE r2.regno = ft.regno AND r2.acad_year = @ay)
                WHERE ft.trans_type = 'Payment'
                  AND ft.acadyear = @ay
                  AND ft.trans_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                  AND (r.regstatus IS NULL
                       OR r.regstatus NOT IN ('REGISTERED','LATE REGISTERED','CLEARED'))
                GROUP BY ft.regno
                ORDER BY total_paid_30d DESC
                LIMIT 50";

            var rows = new StringBuilder();
            int count = 0;

            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ay", currentYear);
                    cmd.CommandTimeout = 60;
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            count++;
                            double paid = Convert.ToDouble(rdr["total_paid_30d"]);
                            string status = rdr["reg_status"].ToString();
                            string badgeClass = status == "NO RECORD" ? "fs-badge--red" : "fs-badge--amber";
                            string lastPay = "";
                            if (rdr["last_payment"] != DBNull.Value)
                            {
                                DateTime dt = Convert.ToDateTime(rdr["last_payment"]);
                                lastPay = dt.ToString("dd MMM yyyy");
                            }

                            rows.AppendFormat(
                                "<tr><td style='font-weight:600;'>{0}</td><td>{1}</td>" +
                                "<td><span class='fs-code'>{2}</span></td>" +
                                "<td style='text-align:right;font-weight:600;color:#155724;'>{3}</td>" +
                                "<td><span class='fs-badge {4}'>{5}</span></td>" +
                                "<td style='font-size:10px;color:#888;'>{6}</td></tr>",
                                Server.HtmlEncode(rdr["regno"].ToString()),
                                Server.HtmlEncode(rdr["student_name"].ToString()),
                                Server.HtmlEncode(rdr["progid"].ToString()),
                                FormatCurrency(paid),
                                badgeClass,
                                Server.HtmlEncode(status),
                                lastPay);
                        }
                    }
                }
            }

            if (count > 0)
            {
                pnlPaidUnregistered.Visible = true;
                litPaidUnregCount.Text = string.Format("{0} student{1}", count, count == 1 ? "" : "s");
                litPaidUnregRows.Text = rows.ToString();
            }
            else
            {
                pnlPaidUnregistered.Visible = false;
            }
        }
        catch
        {
            pnlPaidUnregistered.Visible = false;
        }
    }

    // ===================================================================
    // 9. LATEST 20 PAYMENTS
    // ===================================================================

    private void LoadLatestPayments(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        string sql = @"
            SELECT ft.TID, ft.regno,
                TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                ft.amount, ft.trans_date, ft.detail,
                COALESCE(b.ItemName, ft.item_code) AS item_name
            FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
            LEFT JOIN academicbillingitems b ON b.ItemCode = ft.item_code
            WHERE ft.trans_type = 'Payment'
              AND ft.acadyear = @ay" + ENROLLED_WHERE + semSql + @"
            ORDER BY ft.TID DESC
            LIMIT 20";

        var rows = new StringBuilder();
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    int cnt = 0;
                    while (rdr.Read())
                    {
                        cnt++;
                        double amt = Convert.ToDouble(rdr["amount"]);
                        string dt = "";
                        if (rdr["trans_date"] != DBNull.Value)
                            dt = Convert.ToDateTime(rdr["trans_date"]).ToString("dd MMM yyyy");

                        rows.AppendFormat(
                            "<tr><td style='font-weight:600;'>{0}</td><td>{1}</td>" +
                            "<td>{2}</td>" +
                            "<td style='text-align:right;font-weight:600;color:#155724;'>{3}</td>" +
                            "<td style='font-size:10px;color:#888;'>{4}</td></tr>",
                            Server.HtmlEncode(rdr["regno"].ToString()),
                            Server.HtmlEncode(rdr["student_name"].ToString()),
                            Server.HtmlEncode(rdr["item_name"].ToString()),
                            FormatCurrency(amt), dt);
                    }
                    if (cnt == 0)
                        rows.Append("<tr><td colspan='5' style='text-align:center;color:#aaa;padding:30px;font-size:12px;'>No payments found</td></tr>");
                }
            }
        }
        litLatestPayRows.Text = rows.ToString();
    }

    // ===================================================================
    // 10. LATEST 20 BILLINGS
    // ===================================================================

    private void LoadLatestBillings(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        string sql = @"
            SELECT ft.TID, ft.regno,
                TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                ft.amount, ft.trans_date, ft.detail,
                COALESCE(b.ItemName, ft.item_code) AS item_name
            FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
            LEFT JOIN academicbillingitems b ON b.ItemCode = ft.item_code
            WHERE ft.trans_type = 'Bill'
              AND ft.acadyear = @ay" + ENROLLED_WHERE + semSql + @"
            ORDER BY ft.TID DESC
            LIMIT 20";

        var rows = new StringBuilder();
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    int cnt = 0;
                    while (rdr.Read())
                    {
                        cnt++;
                        double amt = Convert.ToDouble(rdr["amount"]);
                        string dt = "";
                        if (rdr["trans_date"] != DBNull.Value)
                            dt = Convert.ToDateTime(rdr["trans_date"]).ToString("dd MMM yyyy");

                        rows.AppendFormat(
                            "<tr><td style='font-weight:600;'>{0}</td><td>{1}</td>" +
                            "<td>{2}</td>" +
                            "<td style='text-align:right;font-weight:600;color:#174DA4;'>{3}</td>" +
                            "<td style='font-size:10px;color:#888;'>{4}</td></tr>",
                            Server.HtmlEncode(rdr["regno"].ToString()),
                            Server.HtmlEncode(rdr["student_name"].ToString()),
                            Server.HtmlEncode(rdr["item_name"].ToString()),
                            FormatCurrency(amt), dt);
                    }
                    if (cnt == 0)
                        rows.Append("<tr><td colspan='5' style='text-align:center;color:#aaa;padding:30px;font-size:12px;'>No billings found</td></tr>");
                }
            }
        }
        litLatestBillRows.Text = rows.ToString();
    }
}
