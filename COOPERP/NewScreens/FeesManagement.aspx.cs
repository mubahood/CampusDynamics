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
        // Dynamic Recent-Transactions endpoints (GET JSON) — served before any page/postback work.
        string act = (Request["act"] ?? "").Trim().ToLowerInvariant();
        if (act != "") { HandleRecentAjax(act); return; }

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
        // Cache the year list for 15 min — it changes at most once per academic cycle
        const string cacheKey = "FeesManagement_AcadYears";
        var years = System.Web.HttpRuntime.Cache[cacheKey] as List<string>;
        if (years == null)
        {
            years = new List<string>();
            using (var conn = new MySqlConnection(MainConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    "SELECT DISTINCT acad_year FROM acad_registration ORDER BY acad_year DESC", conn))
                using (var rdr = cmd.ExecuteReader())
                    while (rdr.Read())
                        years.Add(rdr["acad_year"].ToString());
            }
            System.Web.HttpRuntime.Cache.Insert(cacheKey, years, null,
                System.Web.Caching.Cache.NoAbsoluteExpiration,
                TimeSpan.FromMinutes(15),
                System.Web.Caching.CacheItemPriority.Normal, null);
        }

        ddlAcadYear.Items.Clear();
        foreach (string y in years)
            ddlAcadYear.Items.Add(new ListItem(y, y));
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

        // Serve from 3-minute in-process cache — avoids re-running ~16 cross-database queries
        if (TryApplySnapshot(yearFilter, semFilter)) return;

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

        try { LoadBursaryStats(yearFilter, semFilter); }
        catch (Exception ex) { System.Diagnostics.Debug.WriteLine("LoadBursaryStats error: " + ex.Message); }

        LoadPaidButUnregistered();

        SaveSnapshot(yearFilter, semFilter);
    }

    // ===================================================================
    // RECENT TRANSACTIONS — dynamic, accurate, clickable  (AJAX: ?act=recenttx|txdetail)
    //   Accuracy: LEFT joins (nothing dropped like the old enrolled-only tables),
    //   true chronological order (trans_date DESC), all-years by default.
    // ===================================================================
    private const string RTX_NAME_EXPR =
        "TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,'')))";

    private void HandleRecentAjax(string act)
    {
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        try
        {
            if (act == "recenttx") WriteRecentTx();
            else if (act == "txdetail") WriteTxDetail();
            else Response.Write("{\"ok\":false,\"message\":\"Unknown action\"}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"message\":" + JsEnc(ex.Message) + "}");
        }
        try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
    }

    private void WriteRecentTx()
    {
        string type  = (Request["type"] ?? "all").Trim().ToLowerInvariant();
        string q     = (Request["q"] ?? "").Trim();
        string scope = (Request["scope"] ?? "all").Trim().ToLowerInvariant();
        string year  = (Request["year"] ?? "").Trim();
        int limit; if (!int.TryParse(Request["limit"], out limit)) limit = 50;
        if (limit != 25 && limit != 50 && limit != 100 && limit != 200) limit = 50;

        string typeCond = type == "payment" ? " AND ft.trans_type='Payment'"
                        : type == "bill"    ? " AND ft.trans_type='Bill'" : "";
        string yearCond = (scope == "year" && year != "") ? " AND ft.acadyear=@ay" : "";
        string searchCond = q == "" ? "" :
            " AND (ft.regno LIKE @q OR " + RTX_NAME_EXPR + " LIKE @q OR ft.detail LIKE @q)";

        string sql =
            "SELECT ft.TID, ft.regno, ft.trans_type, ft.amount, ft.trans_date, ft.detail, ft.semester, ft.acadyear, ft.post_status, " +
            RTX_NAME_EXPR + " AS student_name, s.progid, COALESCE(p.progname, s.progid, '') AS programme, " +
            "COALESCE(b.ItemName, CAST(ft.item_code AS CHAR)) AS item_name " +
            "FROM fin_studentfeestracking ft " +
            "LEFT JOIN campus_dynamics.acad_student s ON s.regno = ft.regno " +
            "LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = s.progid " +
            "LEFT JOIN academicbillingitems b ON b.ItemCode = ft.item_code " +
            "WHERE 1=1" + typeCond + yearCond + searchCond + " " +
            "ORDER BY ft.trans_date DESC, ft.TID DESC LIMIT " + limit;

        var sb = new StringBuilder("{\"ok\":true,\"rows\":[");
        int cnt = 0;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                if (yearCond != "") cmd.Parameters.AddWithValue("@ay", year);
                if (searchCond != "") cmd.Parameters.AddWithValue("@q", "%" + q + "%");
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        if (cnt++ > 0) sb.Append(",");
                        double amt = rdr["amount"] == DBNull.Value ? 0 : Convert.ToDouble(rdr["amount"]);
                        string dt = rdr["trans_date"] == DBNull.Value ? ""
                                  : Convert.ToDateTime(rdr["trans_date"]).ToString("dd MMM yyyy · HH:mm");
                        sb.Append("{\"tid\":").Append(rdr["TID"].ToString());
                        sb.Append(",\"regno\":").Append(JsEnc(rdr["regno"].ToString()));
                        sb.Append(",\"name\":").Append(JsEnc(rdr["student_name"].ToString()));
                        sb.Append(",\"prog\":").Append(JsEnc(rdr["programme"].ToString()));
                        sb.Append(",\"item\":").Append(JsEnc(rdr["item_name"].ToString()));
                        sb.Append(",\"detail\":").Append(JsEnc(rdr["detail"].ToString()));
                        sb.Append(",\"amount\":").Append(amt.ToString(System.Globalization.CultureInfo.InvariantCulture));
                        sb.Append(",\"type\":").Append(JsEnc(rdr["trans_type"].ToString().Trim()));
                        sb.Append(",\"date\":").Append(JsEnc(dt));
                        sb.Append(",\"status\":").Append(JsEnc(rdr["post_status"].ToString().Trim()));
                        sb.Append(",\"sem\":").Append(JsEnc(rdr["semester"].ToString()));
                        sb.Append(",\"year\":").Append(JsEnc(rdr["acadyear"].ToString().Trim()));
                        sb.Append("}");
                    }
                }
            }
        }
        sb.Append("],\"count\":").Append(cnt).Append("}");
        Response.Write(sb.ToString());
    }

    private void WriteTxDetail()
    {
        long tid;
        if (!long.TryParse((Request["tid"] ?? "").Trim(), out tid))
        { Response.Write("{\"ok\":false,\"message\":\"Bad id\"}"); return; }

        var sb = new StringBuilder("{\"ok\":true");
        string regno = "";
        bool found = false;
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT ft.TID, ft.regno, ft.trans_type, ft.amount, ft.trans_date, ft.detail, ft.semester, ft.acadyear, ft.post_status, " +
                "COALESCE(b.ItemName, CAST(ft.item_code AS CHAR)) AS item_name " +
                "FROM fin_studentfeestracking ft LEFT JOIN academicbillingitems b ON b.ItemCode = ft.item_code WHERE ft.TID=@t LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@t", tid);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        found = true;
                        regno = rdr["regno"].ToString();
                        double amt = rdr["amount"] == DBNull.Value ? 0 : Convert.ToDouble(rdr["amount"]);
                        string dt = rdr["trans_date"] == DBNull.Value ? ""
                                  : Convert.ToDateTime(rdr["trans_date"]).ToString("dd MMM yyyy HH:mm:ss");
                        sb.Append(",\"txn\":{\"tid\":").Append(rdr["TID"].ToString());
                        sb.Append(",\"regno\":").Append(JsEnc(regno));
                        sb.Append(",\"type\":").Append(JsEnc(rdr["trans_type"].ToString().Trim()));
                        sb.Append(",\"amount\":").Append(amt.ToString(System.Globalization.CultureInfo.InvariantCulture));
                        sb.Append(",\"date\":").Append(JsEnc(dt));
                        sb.Append(",\"detail\":").Append(JsEnc(rdr["detail"].ToString()));
                        sb.Append(",\"item\":").Append(JsEnc(rdr["item_name"].ToString()));
                        sb.Append(",\"sem\":").Append(JsEnc(rdr["semester"].ToString()));
                        sb.Append(",\"year\":").Append(JsEnc(rdr["acadyear"].ToString().Trim()));
                        sb.Append(",\"status\":").Append(JsEnc(rdr["post_status"].ToString().Trim()));
                        sb.Append("}");
                    }
                }
            }

            if (found && regno != "")
            {
                using (var cmd = new MySqlCommand(
                    "SELECT " + RTX_NAME_EXPR + " AS nm, COALESCE(p.progname, s.progid, '') AS programme, " +
                    "s.new_status, s.gender, s.studPhone, s.email, s.entryyear " +
                    "FROM campus_dynamics.acad_student s LEFT JOIN campus_dynamics.acad_programme p ON p.progcode = s.progid " +
                    "WHERE s.regno=@r LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            sb.Append(",\"student\":{\"name\":").Append(JsEnc(rdr["nm"].ToString()));
                            sb.Append(",\"programme\":").Append(JsEnc(rdr["programme"].ToString()));
                            sb.Append(",\"status\":").Append(JsEnc(rdr["new_status"].ToString()));
                            sb.Append(",\"gender\":").Append(JsEnc(rdr["gender"] == DBNull.Value ? "" : rdr["gender"].ToString()));
                            sb.Append(",\"phone\":").Append(JsEnc(rdr["studPhone"] == DBNull.Value ? "" : rdr["studPhone"].ToString()));
                            sb.Append(",\"email\":").Append(JsEnc(rdr["email"] == DBNull.Value ? "" : rdr["email"].ToString()));
                            sb.Append(",\"entryyear\":").Append(JsEnc(rdr["entryyear"] == DBNull.Value ? "" : rdr["entryyear"].ToString()));
                            sb.Append("}");
                        }
                    }
                }

                using (var cmd = new MySqlCommand(
                    "SELECT total_billed, total_paid, total_balance FROM fin_student_balance_cache WHERE regno=@r LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            sb.Append(",\"balance\":{\"billed\":").Append(Convert.ToDouble(rdr["total_billed"]).ToString(System.Globalization.CultureInfo.InvariantCulture));
                            sb.Append(",\"paid\":").Append(Convert.ToDouble(rdr["total_paid"]).ToString(System.Globalization.CultureInfo.InvariantCulture));
                            sb.Append(",\"balance\":").Append(Convert.ToDouble(rdr["total_balance"]).ToString(System.Globalization.CultureInfo.InvariantCulture));
                            sb.Append("}");
                        }
                    }
                }
            }
        }

        if (!found) { Response.Write("{\"ok\":false,\"message\":\"Transaction not found\"}"); return; }

        string prof = ResolveUrl("~/COOPERP/NewScreens/StudentProfile.aspx?regno=" + Server.UrlEncode(regno));
        string led  = ResolveUrl("~/COOPERP/NewScreens/StudentLedgers.aspx?q=" + Server.UrlEncode(regno));
        sb.Append(",\"links\":{\"profile\":").Append(JsEnc(prof)).Append(",\"ledger\":").Append(JsEnc(led)).Append("}");
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    private static string JsEnc(string s) { return System.Web.HttpUtility.JavaScriptStringEncode(s ?? "", true); }

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
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";

        // Pre-build ordered 12-month slot dictionaries (oldest → newest)
        var keyOrder = new List<string>(12);
        var labelMap = new Dictionary<string, string>(12);
        var dataMap  = new Dictionary<string, double[]>(12); // [cash, nonCash, billed]

        for (int i = 11; i >= 0; i--)
        {
            DateTime m = DateTime.Today.AddMonths(-i);
            string key = m.ToString("yyyy-MM");
            if (!dataMap.ContainsKey(key))
            {
                keyOrder.Add(key);
                labelMap[key] = m.ToString("MMM-yy");   // e.g. "May-26"
                dataMap[key]  = new double[3];
            }
        }

        // One single GROUP BY replaces 36 correlated-subquery executions
        string cutoff = DateTime.Today.AddMonths(-11).ToString("yyyy-MM-01");
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT DATE_FORMAT(ft.trans_date, '%Y-%m') AS month_key,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment'
                                     AND ft.item_code != 75
                                     AND ft.detail NOT LIKE 'Bill Waiver%'
                                     AND ft.detail NOT LIKE 'Balance Fix%'
                                     THEN ft.amount ELSE 0 END),0) AS cash_received,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment'
                                     AND (ft.item_code = 75
                                       OR ft.detail LIKE 'Bill Waiver%'
                                       OR ft.detail LIKE 'Balance Fix%')
                                     THEN ft.amount ELSE 0 END),0) AS non_cash,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END),0) AS total_billed
                FROM fin_studentfeestracking ft
                INNER JOIN campus_dynamics.acad_student s
                    ON s.regno = ft.regno AND s.new_status = 'ACTIVE'
                INNER JOIN campus_dynamics.acad_registration r
                    ON r.regno = ft.regno AND r.acad_year = ft.acadyear
                    AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                WHERE ft.trans_date >= @cutoff
                  AND ft.trans_date IS NOT NULL" + semSql + @"
                GROUP BY DATE_FORMAT(ft.trans_date, '%Y-%m')";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@cutoff", cutoff);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string key = rdr["month_key"].ToString();
                        if (dataMap.ContainsKey(key))
                        {
                            dataMap[key][0] = Convert.ToDouble(rdr["cash_received"]);
                            dataMap[key][1] = Convert.ToDouble(rdr["non_cash"]);
                            dataMap[key][2] = Convert.ToDouble(rdr["total_billed"]);
                        }
                    }
                }
            }
        }

        var labels    = new List<string>(12);
        var cashVals  = new List<string>(12);
        var ncVals    = new List<string>(12);
        var billVals  = new List<string>(12);

        foreach (string key in keyOrder)
        {
            double[] d = dataMap[key];
            labels.Add(labelMap[key]);
            cashVals.Add(d[0].ToString("F0"));
            ncVals.Add(d[1].ToString("F0"));
            billVals.Add(d[2].ToString("F0"));
        }

        hfMonthLabels.Value     = string.Join(",", labels.ToArray());
        hfMonthValues.Value     = string.Join(",", cashVals.ToArray());
        hfMonthBillValues.Value = string.Join(",", billVals.ToArray());
        hfMonthNonCash.Value    = string.Join(",", ncVals.ToArray());
    }

    // ===================================================================
    // 5. DAILY PAYMENTS (Past 30 Days — line chart data)
    // ===================================================================

    private void LoadDailyPayments(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";

        // Pre-build ordered 30-day slot dictionaries (oldest → newest)
        var keyOrder = new List<string>(30);
        var labelMap = new Dictionary<string, string>(30);
        var dataMap  = new Dictionary<string, double>(30);

        for (int i = 29; i >= 0; i--)
        {
            DateTime d = DateTime.Today.AddDays(-i);
            string key = d.ToString("yyyy-MM-dd");
            keyOrder.Add(key);
            labelMap[key] = d.ToString("dd MMM (ddd)");  // e.g. "29 May (Thu)"
            dataMap[key]  = 0;
        }

        // One single GROUP BY replaces 30 correlated-subquery executions
        string cutoff = DateTime.Today.AddDays(-29).ToString("yyyy-MM-dd");
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT DATE_FORMAT(ft.trans_date, '%Y-%m-%d') AS pay_date,
                       COALESCE(SUM(ft.amount), 0) AS daily_paid
                FROM fin_studentfeestracking ft
                INNER JOIN campus_dynamics.acad_student s
                    ON s.regno = ft.regno AND s.new_status = 'ACTIVE'
                INNER JOIN campus_dynamics.acad_registration r
                    ON r.regno = ft.regno AND r.acad_year = ft.acadyear
                    AND r.regstatus IN ('REGISTERED','LATE REGISTERED','CLEARED')
                WHERE ft.trans_type = 'Payment'
                  AND ft.item_code != 75
                  AND ft.detail NOT LIKE 'Bill Waiver%'
                  AND ft.detail NOT LIKE 'Balance Fix%'
                  AND ft.trans_date >= @cutoff
                  AND ft.trans_date IS NOT NULL" + semSql + @"
                GROUP BY DATE_FORMAT(ft.trans_date, '%Y-%m-%d')";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@cutoff", cutoff);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string key = rdr["pay_date"].ToString();
                        if (dataMap.ContainsKey(key))
                            dataMap[key] = Convert.ToDouble(rdr["daily_paid"]);
                    }
                }
            }
        }

        var labels = new List<string>(30);
        var values = new List<string>(30);

        foreach (string key in keyOrder)
        {
            labels.Add(labelMap[key]);
            values.Add(dataMap[key].ToString("F0"));
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
        // Canonical top debtors: rank active students by the materialised dual-source balance
        // (fin_student_balance_cache) so each student's billed/paid/owing matches StudentLedgers
        // and the portal exactly. (Previously summed fin_studentfeestracking for one year only,
        // which contradicted the canonical figure shown elsewhere.) total_balance = paid - billed,
        // so owing = total_balance < 0, most-owing first = ORDER BY total_balance ASC.
        string sql = @"
            SELECT c.regno,
                TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                COALESCE(s.progid,'') AS progid,
                c.total_billed AS billed,
                c.total_paid   AS paid
            FROM fin_student_balance_cache c
            INNER JOIN campus_dynamics.acad_student s
                ON s.regno = c.regno AND UPPER(COALESCE(s.new_status,'')) = 'ACTIVE'
            WHERE c.total_balance < 0
            ORDER BY c.total_balance ASC
            LIMIT 15";

        var rows = new StringBuilder();

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
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

            // (a) Registered but NOT billed — LEFT JOIN IS NULL is faster than NOT EXISTS
            string sql1 = @"
                SELECT COUNT(DISTINCT r.regno)
                FROM campus_dynamics.acad_registration r
                INNER JOIN campus_dynamics.acad_student s ON s.regno = r.regno AND s.new_status = 'ACTIVE'
                LEFT JOIN fin_studentfeestracking ft
                    ON ft.regno = r.regno AND ft.acadyear = r.acad_year
                    AND ft.semester = r.semester AND ft.trans_type = 'Bill'
                WHERE r.acad_year = @ay
                  AND r.regstatus IN ('REGISTERED','LATE REGISTERED')" + semSqlR + @"
                  AND ft.TID IS NULL";
            using (var cmd = new MySqlCommand(sql1, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                object val = cmd.ExecuteScalar();
                regNotBilled = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }

            // (b) Bills without GL entries — LEFT JOIN IS NULL is faster than NOT EXISTS
            string sql2 = @"
                SELECT COUNT(*)
                FROM fin_studentfeestracking ft
                LEFT JOIN fin_ledger l ON l.folio = CONCAT('BillNo:', ft.TID)
                WHERE ft.trans_type = 'Bill' AND ft.acadyear = @ay" + semSqlFT + @"
                  AND l.folio IS NULL";
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
                LEFT JOIN (
                    SELECT regno, MAX(semester) AS max_sem
                    FROM campus_dynamics.acad_registration
                    WHERE acad_year = @ay
                    GROUP BY regno
                ) rm ON rm.regno = ft.regno
                LEFT JOIN campus_dynamics.acad_registration r
                    ON r.regno = ft.regno AND r.acad_year = @ay AND r.semester = rm.max_sem
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

    // ===================================================================
    // BURSARY SCHEMES & BENEFICIARIES
    // ===================================================================

    private void LoadBursaryStats(string yearFilter, string semFilter)
    {
        string semSql = string.IsNullOrEmpty(semFilter) ? "" : " AND ft.semester = @sem";
        string yearPfx = yearFilter.Length >= 4 ? yearFilter.Substring(0, 4) : yearFilter;

        // Part 1: Financial bursary credits (item_code = 75) for enrolled students
        long   creditedStudents = 0;
        double totalCredited    = 0;
        long   creditTxns       = 0;

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            string sql = @"
                SELECT COUNT(DISTINCT ft.regno) AS credited_students,
                       COALESCE(SUM(ft.amount),0) AS total_credited,
                       COUNT(*) AS txn_count
                FROM fin_studentfeestracking ft" + ENROLLED_JOIN + @"
                WHERE ft.trans_type='Payment' AND ft.item_code=75
                  AND ft.acadyear=@ay" + ENROLLED_WHERE + semSql;
            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 60;
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                AddSemParam(cmd, semFilter);
                using (var rdr = cmd.ExecuteReader())
                    if (rdr.Read())
                    {
                        creditedStudents = rdr["credited_students"] == DBNull.Value ? 0 : Convert.ToInt64(rdr["credited_students"]);
                        totalCredited    = rdr["total_credited"]    == DBNull.Value ? 0 : Convert.ToDouble(rdr["total_credited"]);
                        creditTxns       = rdr["txn_count"]         == DBNull.Value ? 0 : Convert.ToInt64(rdr["txn_count"]);
                    }
            }
        }

        // Part 2: Scheme master + beneficiary summary + per-scheme breakdown
        int    schemeCount              = 0;
        long   registeredBeneficiaries  = 0;
        double totalOffered             = 0;
        var    schemeRows               = new StringBuilder();

        try
        {
            using (var conn = new MySqlConnection(AcctConnStr))
            {
                conn.Open();

                // Auto-detect which database holds the scholarship tables
                long inAcct = Convert.ToInt64(new MySqlCommand(
                    "SELECT COUNT(*) FROM information_schema.TABLES " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='scholarships'", conn).ExecuteScalar());
                string pfx = inAcct > 0 ? "" : "campus_dynamics.";

                // Total scheme count
                schemeCount = Convert.ToInt32(
                    new MySqlCommand("SELECT COUNT(*) FROM " + pfx + "scholarships", conn).ExecuteScalar());

                // Approved beneficiaries + offered amount for this academic year
                string sumSql = @"
                    SELECT COUNT(DISTINCT ss.adm_no) AS total_reg,
                           COALESCE(SUM(ss.amount_offered),0) AS total_offered
                    FROM " + pfx + @"scholarshipstudents ss
                    WHERE (ss.scholarhipYear=@ay OR ss.scholarhipYear LIKE CONCAT(@ypfx,'%'))
                      AND LOWER(ss.status)='approved'";
                using (var cmd = new MySqlCommand(sumSql, conn))
                {
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.AddWithValue("@ay",   yearFilter);
                    cmd.Parameters.AddWithValue("@ypfx", yearPfx);
                    using (var rdr = cmd.ExecuteReader())
                        if (rdr.Read())
                        {
                            registeredBeneficiaries = rdr["total_reg"]    == DBNull.Value ? 0 : Convert.ToInt64(rdr["total_reg"]);
                            totalOffered            = rdr["total_offered"] == DBNull.Value ? 0 : Convert.ToDouble(rdr["total_offered"]);
                        }
                }

                // Per-scheme breakdown; ft_agg pre-aggregates so there's no correlated subquery
                string brkSql = @"
                    SELECT sc.scholarshipName,
                           COUNT(DISTINCT ss.adm_no)          AS beneficiaries,
                           COALESCE(SUM(ss.amount_offered),0)  AS offered,
                           COALESCE(SUM(ft_agg.credited),0)    AS credited
                    FROM " + pfx + @"scholarships sc
                    LEFT JOIN " + pfx + @"scholarshipstudents ss
                           ON ss.scholarshipID=sc.scholarshipID
                          AND (ss.scholarhipYear=@ay OR ss.scholarhipYear LIKE CONCAT(@ypfx,'%'))
                          AND LOWER(ss.status)='approved'
                    LEFT JOIN (
                        SELECT regno, SUM(amount) AS credited
                        FROM fin_studentfeestracking
                        WHERE trans_type='Payment' AND item_code=75 AND acadyear=@ay
                        GROUP BY regno
                    ) ft_agg ON ft_agg.regno=ss.adm_no
                    GROUP BY sc.scholarshipID, sc.scholarshipName
                    HAVING COUNT(DISTINCT ss.adm_no)>0
                    ORDER BY offered DESC
                    LIMIT 20";
                using (var cmd = new MySqlCommand(brkSql, conn))
                {
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.AddWithValue("@ay",   yearFilter);
                    cmd.Parameters.AddWithValue("@ypfx", yearPfx);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string name    = rdr["scholarshipName"].ToString();
                            long   bens    = Convert.ToInt64(rdr["beneficiaries"]);
                            double offered = Convert.ToDouble(rdr["offered"]);
                            double credited= Convert.ToDouble(rdr["credited"]);
                            double pct     = offered > 0 ? (credited / offered * 100) : 0;
                            string pctCol  = pct >= 90 ? "#15803d" : pct >= 60 ? "#b45309" : "#dc3545";
                            string barW    = Math.Min(pct, 100).ToString("F0");

                            schemeRows.AppendFormat(
                                "<tr>" +
                                "<td style='font-weight:600;'>{0}</td>" +
                                "<td style='text-align:center;font-variant-numeric:tabular-nums;'>{1:N0}</td>" +
                                "<td style='text-align:right;'>{2}</td>" +
                                "<td style='text-align:right;color:#155724;font-weight:600;'>{3}</td>" +
                                "<td><div class='fd-prog-bar'><div class='fd-prog-bar__fill' style='width:{4}%;background:{5};'></div></div></td>" +
                                "<td style='text-align:right;color:{5};font-weight:700;white-space:nowrap;'>{6:F1}%</td>" +
                                "</tr>",
                                Server.HtmlEncode(name), bens,
                                FormatCurrency(offered), FormatCurrency(credited),
                                barW, pctCol, pct);
                        }
                    }
                }
            }
        }
        catch { /* scholarship tables unavailable — financial stats still display */ }

        // Build HTML
        var sb = new StringBuilder();
        double coveragePct = totalOffered > 0 ? (totalCredited / totalOffered * 100) : 0;
        double disbGap     = totalOffered > totalCredited ? totalOffered - totalCredited : 0;
        string covColor    = coveragePct >= 90 ? "#15803d" : coveragePct >= 60 ? "#b45309" : "#dc3545";

        // KPI mini-cards
        sb.Append("<div class='fs-card' style='margin-bottom:14px;'><div style='padding:14px 16px;'>");
        sb.Append("<div class='fd-bursary-kpis'>");

        sb.AppendFormat(
            "<div class='fd-bursary-kpi fd-bursary-kpi--credited'>" +
            "<div class='fd-bursary-kpi__icon' style='background:rgba(29,78,216,.08);'>" +
              "<svg xmlns='http://www.w3.org/2000/svg' width='15' height='15' viewBox='0 0 24 24' fill='none' stroke='#1d4ed8' stroke-width='2'><path d='M22 12h-4l-3 9L9 3l-3 9H2'/></svg>" +
            "</div>" +
            "<div class='fd-bursary-kpi__label'>Bursary Credited</div>" +
            "<div class='fd-bursary-kpi__val' style='color:#1d4ed8;'>{0}</div>" +
            "<div class='fd-bursary-kpi__sub'>{1:N0} transactions &middot; {2:N0} students</div></div>",
            FormatCurrency(totalCredited), creditTxns, creditedStudents);

        sb.AppendFormat(
            "<div class='fd-bursary-kpi fd-bursary-kpi--coverage'>" +
            "<div class='fd-bursary-kpi__icon' style='background:rgba(21,128,61,.08);'>" +
              "<svg xmlns='http://www.w3.org/2000/svg' width='15' height='15' viewBox='0 0 24 24' fill='none' stroke='{0}' stroke-width='2'><polyline points='23 6 13.5 15.5 8.5 10.5 1 18'/><polyline points='17 6 23 6 23 12'/></svg>" +
            "</div>" +
            "<div class='fd-bursary-kpi__label'>Disbursement Coverage</div>" +
            "<div class='fd-bursary-kpi__val' style='color:{0};'>{1:F1}%</div>" +
            "<div class='fd-bursary-kpi__sub'>of {2} offered &mdash; gap {3}</div></div>",
            covColor, coveragePct, FormatCurrency(totalOffered), FormatCurrency(disbGap));

        sb.AppendFormat(
            "<div class='fd-bursary-kpi fd-bursary-kpi--schemes'>" +
            "<div class='fd-bursary-kpi__icon' style='background:rgba(124,58,237,.08);'>" +
              "<svg xmlns='http://www.w3.org/2000/svg' width='15' height='15' viewBox='0 0 24 24' fill='none' stroke='#7c3aed' stroke-width='2'><rect x='3' y='3' width='18' height='18' rx='2'/><line x1='3' y1='9' x2='21' y2='9'/><line x1='9' y1='21' x2='9' y2='3'/></svg>" +
            "</div>" +
            "<div class='fd-bursary-kpi__label'>Bursary Schemes</div>" +
            "<div class='fd-bursary-kpi__val' style='color:#7c3aed;'>{0:N0}</div>" +
            "<div class='fd-bursary-kpi__sub'>registered scholarship &amp; bursary programmes</div></div>",
            schemeCount);

        sb.AppendFormat(
            "<div class='fd-bursary-kpi fd-bursary-kpi--beneficiaries'>" +
            "<div class='fd-bursary-kpi__icon' style='background:rgba(8,145,178,.08);'>" +
              "<svg xmlns='http://www.w3.org/2000/svg' width='15' height='15' viewBox='0 0 24 24' fill='none' stroke='#0891b2' stroke-width='2'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'/><circle cx='9' cy='7' r='4'/><path d='M23 21v-2a4 4 0 0 0-3-3.87'/><path d='M16 3.13a4 4 0 0 1 0 7.75'/></svg>" +
            "</div>" +
            "<div class='fd-bursary-kpi__label'>Registered Beneficiaries</div>" +
            "<div class='fd-bursary-kpi__val' style='color:#0891b2;'>{0:N0}</div>" +
            "<div class='fd-bursary-kpi__sub'>approved for {1}</div></div>",
            registeredBeneficiaries, yearFilter);

        sb.Append("</div></div></div>");

        // Per-scheme breakdown table
        if (schemeRows.Length > 0)
        {
            sb.Append("<div class='fs-card'>");
            sb.Append(
                "<div class='fs-card__header'>" +
                "<div class='fs-card__title'>" +
                "<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='#1d4ed8' stroke-width='2'><path d='M22 12h-4l-3 9L9 3l-3 9H2'/></svg>" +
                " Scheme-by-Scheme Breakdown</div>" +
                "<div class='fs-card__meta'>Offered vs credited &mdash; approved beneficiaries only</div></div>");
            sb.Append(
                "<div style='overflow-x:auto;'><table class='fs-table'><thead><tr>" +
                "<th>Scheme / Programme</th>" +
                "<th style='text-align:center;'>Beneficiaries</th>" +
                "<th style='text-align:right;'>Total Offered</th>" +
                "<th style='text-align:right;'>Credited to Accounts</th>" +
                "<th style='width:90px;'>Disbursed</th>" +
                "<th style='text-align:right;'>%</th>" +
                "</tr></thead><tbody>");
            sb.Append(schemeRows);
            sb.Append("</tbody></table></div></div>");
        }

        litBursarySection.Text = sb.ToString();
    }

    // ===================================================================
    // SNAPSHOT CACHE — 3-minute in-process cache that eliminates all
    // re-queries when the same year+semester is viewed repeatedly.
    // First load is still slow (all queries run); every subsequent hit
    // within the TTL window is served entirely from memory (~0 ms).
    // ===================================================================

    private sealed class DashboardSnapshot
    {
        public string StatEnrolled, StatBilled, StatPaid, StatBalance;
        public string StatBillCount, StatPayCount, StatCollRate;
        public string DonutPaid, DonutBal, CashBreakdown;
        public string TrendEnrolled, TrendBilled, TrendPaid, TrendBalance;
        public string FeeTypeBars, SemesterCards;
        public string MonthLabels, MonthValues, MonthBillValues, MonthNonCash;
        public string DailyLabels, DailyValues;
        public string ProgRows, ProgCount, DebtorRows, AnomalyCards;
        public string LatestPayRows, LatestBillRows;
        public string ChannelLabels, ChannelValues;
        public bool   ShowPaidUnreg;
        public string PaidUnregCount, PaidUnregRows;
        public string BursarySection;
    }

    private bool TryApplySnapshot(string year, string sem)
    {
        var snap = System.Web.HttpRuntime.Cache["FeesDash_" + year + "_" + sem] as DashboardSnapshot;
        if (snap == null) return false;

        litStatEnrolled.Text  = snap.StatEnrolled;
        litStatBilled.Text    = snap.StatBilled;
        litStatPaid.Text      = snap.StatPaid;
        litStatBalance.Text   = snap.StatBalance;
        litStatBillCount.Text = snap.StatBillCount;
        litStatPayCount.Text  = snap.StatPayCount;
        litStatCollRate.Text  = snap.StatCollRate;
        hfDonutPaid.Value     = snap.DonutPaid;
        hfDonutBal.Value      = snap.DonutBal;
        litCashBreakdown.Text = snap.CashBreakdown;
        litTrendEnrolled.Text = snap.TrendEnrolled;
        litTrendBilled.Text   = snap.TrendBilled;
        litTrendPaid.Text     = snap.TrendPaid;
        litTrendBalance.Text  = snap.TrendBalance;
        litFeeTypeBars.Text   = snap.FeeTypeBars;
        litSemesterCards.Text = snap.SemesterCards;
        hfMonthLabels.Value     = snap.MonthLabels;
        hfMonthValues.Value     = snap.MonthValues;
        hfMonthBillValues.Value = snap.MonthBillValues;
        hfMonthNonCash.Value    = snap.MonthNonCash;
        hfDailyLabels.Value   = snap.DailyLabels;
        hfDailyValues.Value   = snap.DailyValues;
        litProgRows.Text      = snap.ProgRows;
        litProgCount.Text     = snap.ProgCount;
        litDebtorRows.Text    = snap.DebtorRows;
        litAnomalyCards.Text  = snap.AnomalyCards;
        litLatestPayRows.Text  = snap.LatestPayRows;
        litLatestBillRows.Text = snap.LatestBillRows;
        hfChannelLabels.Value  = snap.ChannelLabels;
        hfChannelValues.Value  = snap.ChannelValues;
        litBursarySection.Text = snap.BursarySection;
        pnlPaidUnregistered.Visible = snap.ShowPaidUnreg;
        if (snap.ShowPaidUnreg)
        {
            litPaidUnregCount.Text = snap.PaidUnregCount;
            litPaidUnregRows.Text  = snap.PaidUnregRows;
        }
        return true;
    }

    private void SaveSnapshot(string year, string sem)
    {
        var snap = new DashboardSnapshot
        {
            StatEnrolled  = litStatEnrolled.Text,
            StatBilled    = litStatBilled.Text,
            StatPaid      = litStatPaid.Text,
            StatBalance   = litStatBalance.Text,
            StatBillCount = litStatBillCount.Text,
            StatPayCount  = litStatPayCount.Text,
            StatCollRate  = litStatCollRate.Text,
            DonutPaid     = hfDonutPaid.Value,
            DonutBal      = hfDonutBal.Value,
            CashBreakdown = litCashBreakdown.Text,
            TrendEnrolled = litTrendEnrolled.Text,
            TrendBilled   = litTrendBilled.Text,
            TrendPaid     = litTrendPaid.Text,
            TrendBalance  = litTrendBalance.Text,
            FeeTypeBars   = litFeeTypeBars.Text,
            SemesterCards = litSemesterCards.Text,
            MonthLabels     = hfMonthLabels.Value,
            MonthValues     = hfMonthValues.Value,
            MonthBillValues = hfMonthBillValues.Value,
            MonthNonCash    = hfMonthNonCash.Value,
            DailyLabels   = hfDailyLabels.Value,
            DailyValues   = hfDailyValues.Value,
            ProgRows      = litProgRows.Text,
            ProgCount     = litProgCount.Text,
            DebtorRows    = litDebtorRows.Text,
            AnomalyCards  = litAnomalyCards.Text,
            LatestPayRows  = litLatestPayRows.Text,
            LatestBillRows = litLatestBillRows.Text,
            ChannelLabels  = hfChannelLabels.Value,
            ChannelValues  = hfChannelValues.Value,
            BursarySection = litBursarySection.Text,
            ShowPaidUnreg  = pnlPaidUnregistered.Visible,
            PaidUnregCount = pnlPaidUnregistered.Visible ? litPaidUnregCount.Text : "",
            PaidUnregRows  = pnlPaidUnregistered.Visible ? litPaidUnregRows.Text  : ""
        };

        System.Web.HttpRuntime.Cache.Insert(
            "FeesDash_" + year + "_" + sem, snap, null,
            System.Web.Caching.Cache.NoAbsoluteExpiration,
            TimeSpan.FromMinutes(3),
            System.Web.Caching.CacheItemPriority.Normal, null);
    }
}
