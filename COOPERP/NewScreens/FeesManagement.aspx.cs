using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_FeesManagement : System.Web.UI.Page
{
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

    // ═══════════════════════════════════════════════════════════════════
    // PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAcademicYears();
            LoadBillingSystems();
            SetDefaultYear();
            LoadDashboard();
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    // DATA LOADING
    // ═══════════════════════════════════════════════════════════════════

    private void LoadAcademicYears()
    {
        using (var conn = new MySqlConnection(MainConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("SELECT DISTINCT acad_year FROM acad_registration ORDER BY acad_year DESC", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                ddlAcadYear.Items.Clear();
                ddlAcadYear.Items.Add(new System.Web.UI.WebControls.ListItem("All Years", ""));
                while (rdr.Read())
                {
                    string y = rdr["acad_year"].ToString();
                    ddlAcadYear.Items.Add(new System.Web.UI.WebControls.ListItem(y, y));
                }
            }
        }
    }

    private void LoadBillingSystems()
    {
        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("SELECT ID, bs_name FROM fin_billing_systems ORDER BY ID", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    ddlBillingSystem.Items.Add(new System.Web.UI.WebControls.ListItem(
                        rdr["bs_name"].ToString(), rdr["ID"].ToString()));
                }
            }
        }
    }

    private void SetDefaultYear()
    {
        string ay = AcademicYearHelper.GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(ay) != null)
            ddlAcadYear.SelectedValue = ay;
    }

    // Academic year logic centralised in AcademicYearHelper

    // ═══════════════════════════════════════════════════════════════════
    // MAIN DASHBOARD LOADER
    // ═══════════════════════════════════════════════════════════════════

    private void LoadDashboard()
    {
        string yearFilter = ddlAcadYear.SelectedValue;

        // Context label
        litAcadContext.Text = string.Format(
            "<span style='font-size:11px;font-weight:600;color:#174DA4;background:rgba(23,77,164,.06);padding:4px 12px;border-radius:10px;'>{0}</span>",
            string.IsNullOrEmpty(yearFilter) ? "All Years" : yearFilter);

        using (var conn = new MySqlConnection(AcctConnStr))
        {
            conn.Open();

            // ── Hero Stats ──────────────────────────────────────
            string heroSql = @"
                SELECT
                    SUM(CASE WHEN trans_type='Bill' THEN amount ELSE 0 END) AS total_billed,
                    SUM(CASE WHEN trans_type='Payment' THEN amount ELSE 0 END) AS total_paid,
                    SUM(CASE WHEN trans_type='Bill' THEN 1 ELSE 0 END) AS bill_count,
                    SUM(CASE WHEN trans_type='Payment' THEN 1 ELSE 0 END) AS pay_count,
                    COUNT(DISTINCT CASE WHEN trans_type='Bill' THEN regno END) AS students_billed
                FROM fin_studentfeestracking
                WHERE 1=1";
            if (!string.IsNullOrEmpty(yearFilter))
                heroSql += " AND acadyear=@ay";

            using (var cmd = new MySqlCommand(heroSql, conn))
            {
                if (!string.IsNullOrEmpty(yearFilter))
                    cmd.Parameters.AddWithValue("@ay", yearFilter);

                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        double billed = rdr["total_billed"] != DBNull.Value ? Convert.ToDouble(rdr["total_billed"]) : 0;
                        double paid = rdr["total_paid"] != DBNull.Value ? Convert.ToDouble(rdr["total_paid"]) : 0;
                        long billCnt = rdr["bill_count"] != DBNull.Value ? Convert.ToInt64(rdr["bill_count"]) : 0;
                        long payCnt = rdr["pay_count"] != DBNull.Value ? Convert.ToInt64(rdr["pay_count"]) : 0;
                        long studBilled = rdr["students_billed"] != DBNull.Value ? Convert.ToInt64(rdr["students_billed"]) : 0;
                        double balance = billed - paid;
                        double rate = billed > 0 ? (paid / billed) * 100 : 0;

                        litTotalBilled.Text = FormatCurrency(billed);
                        litTotalPaid.Text = FormatCurrency(paid);
                        litBalance.Text = FormatCurrency(balance);
                        litBillCount.Text = string.Format("{0:N0} invoices", billCnt);
                        litPayCount.Text = string.Format("{0:N0} payments", payCnt);
                        litStudentsBilled.Text = string.Format("{0:N0}", studBilled);
                        litCollectionRate.Text = string.Format("{0:F1}% collection rate", rate);
                    }
                }
            }

            // Students not billed count
            if (!string.IsNullOrEmpty(yearFilter))
            {
                string unbilledSql = @"
                    SELECT COUNT(*) FROM campus_dynamics.acad_registration r
                    WHERE r.acad_year=@ay
                    AND NOT EXISTS(
                        SELECT 1 FROM fin_studentfeestracking ft
                        WHERE ft.regno=r.regno AND ft.acadyear=r.acad_year AND ft.semester=r.semester AND ft.trans_type='Bill'
                    )";
                using (var cmd2 = new MySqlCommand(unbilledSql, conn))
                {
                    cmd2.Parameters.AddWithValue("@ay", yearFilter);
                    object val = cmd2.ExecuteScalar();
                    long unbilled = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
                    litStudentsUnbilled.Text = string.Format("{0:N0} not billed", unbilled);
                }
            }

            // ── Semester Breakdown ──────────────────────────────
            string semSql = @"
                SELECT semester,
                    SUM(CASE WHEN trans_type='Bill' THEN amount ELSE 0 END) AS billed,
                    SUM(CASE WHEN trans_type='Payment' THEN amount ELSE 0 END) AS paid,
                    COUNT(DISTINCT CASE WHEN trans_type='Bill' THEN regno END) AS students
                FROM fin_studentfeestracking
                WHERE 1=1";
            if (!string.IsNullOrEmpty(yearFilter))
                semSql += " AND acadyear=@ay";
            semSql += " GROUP BY semester ORDER BY semester";

            var semCards = new StringBuilder();
            using (var cmd3 = new MySqlCommand(semSql, conn))
            {
                if (!string.IsNullOrEmpty(yearFilter))
                    cmd3.Parameters.AddWithValue("@ay", yearFilter);

                using (var rdr3 = cmd3.ExecuteReader())
                {
                    while (rdr3.Read())
                    {
                        int sem = Convert.ToInt32(rdr3["semester"]);
                        double b = Convert.ToDouble(rdr3["billed"]);
                        double p = Convert.ToDouble(rdr3["paid"]);
                        long st = Convert.ToInt64(rdr3["students"]);
                        double bal = b - p;
                        double pct = b > 0 ? (p / b) * 100 : 0;
                        string pctClass = pct >= 80 ? "green" : (pct >= 50 ? "amber" : "red");
                        string badgeClass = pct >= 70 ? "ok" : "warn";

                        semCards.AppendFormat(@"
                        <div class='fm-semester-card'>
                            <div class='fm-semester-card__head'>
                                <div class='fm-semester-card__title'>Semester {0}</div>
                                <span class='fm-semester-card__badge fm-semester-card__badge--{1}'>{2:F0}% collected</span>
                            </div>
                            <div class='fm-row'><span class='fm-row__label'>Students Billed</span><span class='fm-row__val'>{3:N0}</span></div>
                            <div class='fm-row'><span class='fm-row__label'>Total Billed</span><span class='fm-row__val'>{4}</span></div>
                            <div class='fm-row'><span class='fm-row__label'>Total Paid</span><span class='fm-row__val fm-row__val--green'>{5}</span></div>
                            <div class='fm-row'><span class='fm-row__label'>Outstanding</span><span class='fm-row__val fm-row__val--{6}'>{7}</span></div>
                            <div class='fm-progress'><div class='fm-progress__fill fm-progress__fill--{8}' style='width:{9:F0}%'></div></div>
                            <div class='fm-progress-label'>{10:F1}% collected</div>
                        </div>",
                            sem, badgeClass, pct, st,
                            FormatCurrency(b), FormatCurrency(p),
                            bal > 0 ? "amber" : "green", FormatCurrency(bal),
                            pctClass, pct, pct);
                    }
                }
            }
            litSemesterCards.Text = semCards.ToString();

            // ── Billing Items Revenue ───────────────────────────
            string itemSql = @"
                SELECT bi.ItemCode, bi.ItemName, bi.AccountCode,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END),0) AS billed,
                    COALESCE(SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END),0) AS paid
                FROM academicbillingitems bi
                LEFT JOIN fin_studentfeestracking ft ON ft.item_code=bi.ItemCode";
            if (!string.IsNullOrEmpty(yearFilter))
                itemSql += " AND ft.acadyear=@ay";
            itemSql += " GROUP BY bi.ItemCode, bi.ItemName, bi.AccountCode ORDER BY billed DESC";

            var itemRows = new StringBuilder();
            int itemCount = 0;
            using (var cmd4 = new MySqlCommand(itemSql, conn))
            {
                if (!string.IsNullOrEmpty(yearFilter))
                    cmd4.Parameters.AddWithValue("@ay", yearFilter);

                using (var rdr4 = cmd4.ExecuteReader())
                {
                    while (rdr4.Read())
                    {
                        itemCount++;
                        double b = Convert.ToDouble(rdr4["billed"]);
                        double p = Convert.ToDouble(rdr4["paid"]);
                        itemRows.AppendFormat(
                            "<tr><td>{0}</td><td><span class='fm-code'>{1}</span></td><td style='text-align:right;font-weight:600;'>{2}</td><td style='text-align:right;color:#2e7d32;font-weight:600;'>{3}</td></tr>",
                            Server.HtmlEncode(rdr4["ItemName"].ToString()),
                            Server.HtmlEncode(rdr4["AccountCode"].ToString()),
                            FormatCurrency(b), FormatCurrency(p));
                    }
                }
            }
            litItemRows.Text = itemRows.ToString();
            litItemCount.Text = string.Format("{0} items", itemCount);

            // ── Year Trend ──────────────────────────────────────
            string yrSql = @"
                SELECT acadyear,
                    SUM(CASE WHEN trans_type='Bill' THEN amount ELSE 0 END) AS billed,
                    SUM(CASE WHEN trans_type='Payment' THEN amount ELSE 0 END) AS paid
                FROM fin_studentfeestracking
                GROUP BY acadyear ORDER BY acadyear DESC LIMIT 8";

            var yrRows = new StringBuilder();
            using (var cmd5 = new MySqlCommand(yrSql, conn))
            using (var rdr5 = cmd5.ExecuteReader())
            {
                while (rdr5.Read())
                {
                    double b = Convert.ToDouble(rdr5["billed"]);
                    double p = Convert.ToDouble(rdr5["paid"]);
                    double pct = b > 0 ? (p / b) * 100 : 0;
                    string pctColor = pct >= 80 ? "#2e7d32" : (pct >= 50 ? "#e65100" : "#dc3545");
                    yrRows.AppendFormat(
                        "<tr><td style='font-weight:600;'>{0}</td><td style='text-align:right;font-weight:600;'>{1}</td><td style='text-align:right;color:#2e7d32;font-weight:600;'>{2}</td><td style='text-align:right;color:{3};font-weight:700;'>{4:F1}%</td></tr>",
                        Server.HtmlEncode(rdr5["acadyear"].ToString()),
                        FormatCurrency(b), FormatCurrency(p), pctColor, pct);
                }
            }
            litYearRows.Text = yrRows.ToString();

            // ── Top Debtors ─────────────────────────────────────
            string debtorSql = @"
                SELECT ft.regno,
                    TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                    COALESCE(s.progid,'') AS progid,
                    SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END) AS billed,
                    SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END) AS paid
                FROM fin_studentfeestracking ft
                LEFT JOIN campus_dynamics.acad_student s ON s.regno=ft.regno
                WHERE 1=1";
            if (!string.IsNullOrEmpty(yearFilter))
                debtorSql += " AND ft.acadyear=@ay";
            debtorSql += @" GROUP BY ft.regno
                HAVING SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END) > SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END)
                ORDER BY (SUM(CASE WHEN ft.trans_type='Bill' THEN ft.amount ELSE 0 END) - SUM(CASE WHEN ft.trans_type='Payment' THEN ft.amount ELSE 0 END)) DESC LIMIT 15";

            var debtorRows = new StringBuilder();
            using (var cmd6 = new MySqlCommand(debtorSql, conn))
            {
                if (!string.IsNullOrEmpty(yearFilter))
                    cmd6.Parameters.AddWithValue("@ay", yearFilter);

                using (var rdr6 = cmd6.ExecuteReader())
                {
                    while (rdr6.Read())
                    {
                        double b = Convert.ToDouble(rdr6["billed"]);
                        double p = Convert.ToDouble(rdr6["paid"]);
                        debtorRows.AppendFormat(
                            "<tr><td style='font-weight:600;'>{0}</td><td>{1}</td><td><span class='fm-code'>{2}</span></td><td style='text-align:right;font-weight:600;'>{3}</td><td style='text-align:right;color:#2e7d32;'>{4}</td><td style='text-align:right;color:#dc3545;font-weight:700;'>{5}</td></tr>",
                            Server.HtmlEncode(rdr6["regno"].ToString()),
                            Server.HtmlEncode(rdr6["student_name"].ToString()),
                            Server.HtmlEncode(rdr6["progid"].ToString()),
                            FormatCurrency(b), FormatCurrency(p), FormatCurrency(b - p));
                    }
                }
            }
            litDebtorRows.Text = debtorRows.ToString();

            // ── Anomaly Stats ───────────────────────────────────
            LoadAnomalyStats(conn, yearFilter);
        }

        // ── Paid but Unregistered (always uses current year) ────
        LoadPaidButUnregistered();
    }

    private void LoadAnomalyStats(MySqlConnection conn, string yearFilter)
    {
        long regNotBilled = 0, billsNoGL = 0, duplicateBills = 0;

        // 1. Registered but NOT billed (only when year selected)
        if (!string.IsNullOrEmpty(yearFilter))
        {
            string sql1 = @"
                SELECT COUNT(DISTINCT r.regno) 
                FROM campus_dynamics.acad_registration r
                WHERE r.acad_year = @ay
                  AND r.regstatus IN ('REGISTERED','LATE REGISTERED')
                  AND NOT EXISTS(
                      SELECT 1 FROM fin_studentfeestracking ft
                      WHERE ft.regno = r.regno AND ft.acadyear = r.acad_year 
                        AND ft.semester = r.semester AND ft.trans_type = 'Bill'
                  )";
            using (var cmd = new MySqlCommand(sql1, conn))
            {
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                object val = cmd.ExecuteScalar();
                regNotBilled = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }
        }

        // 2. Bills without GL entries (only when year selected)
        if (!string.IsNullOrEmpty(yearFilter))
        {
            string sql2 = @"
                SELECT COUNT(*) FROM fin_studentfeestracking ft
                WHERE ft.trans_type = 'Bill' AND ft.acadyear = @ay
                  AND NOT EXISTS(
                      SELECT 1 FROM fin_ledger l
                      WHERE l.folio = CONCAT('BillNo:', ft.TID)
                  )";
            using (var cmd = new MySqlCommand(sql2, conn))
            {
                cmd.Parameters.AddWithValue("@ay", yearFilter);
                object val = cmd.ExecuteScalar();
                billsNoGL = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }
        }

        // 3. Duplicate bills check (ongoing monitoring)
        {
            string sql3 = @"
                SELECT COUNT(*) FROM (
                    SELECT regno, acadyear, semester, item_code
                    FROM fin_studentfeestracking
                    WHERE trans_type = 'Bill'";
            if (!string.IsNullOrEmpty(yearFilter))
                sql3 += " AND acadyear = @ay";
            sql3 += @"
                    GROUP BY regno, acadyear, semester, item_code
                    HAVING COUNT(*) > 1
                ) dups";
            using (var cmd = new MySqlCommand(sql3, conn))
            {
                if (!string.IsNullOrEmpty(yearFilter))
                    cmd.Parameters.AddWithValue("@ay", yearFilter);
                object val = cmd.ExecuteScalar();
                duplicateBills = val != null && val != DBNull.Value ? Convert.ToInt64(val) : 0;
            }
        }

        // Build anomaly cards
        var cards = new StringBuilder();

        // Card 1: Registered but unbilled
        string c1Class = regNotBilled == 0 ? "ok" : (regNotBilled > 20 ? "danger" : "warn");
        string c1Icon = regNotBilled == 0
            ? "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#2e7d32' stroke-width='2'><polyline points='20 6 9 17 4 12'></polyline></svg>"
            : "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#e65100' stroke-width='2'><path d='M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2'></path><circle cx='9' cy='7' r='4'></circle><line x1='23' y1='11' x2='17' y2='11'></line></svg>";
        cards.AppendFormat(@"
            <div class='fm-anomaly fm-anomaly--{0}'>
                <div class='fm-anomaly__icon'>{1}</div>
                <div class='fm-anomaly__label'>Registered, Not Billed</div>
                <div class='fm-anomaly__val'>{2:N0}</div>
                <div class='fm-anomaly__hint'>{3}</div>
            </div>",
            c1Class, c1Icon, regNotBilled,
            regNotBilled == 0 ? "All registered students have been billed"
                : string.Format("{0:N0} student(s) are registered but have no bill records", regNotBilled));

        // Card 2: Bills without GL entries
        string c2Class = billsNoGL == 0 ? "ok" : "warn";
        string c2Icon = billsNoGL == 0
            ? "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#2e7d32' stroke-width='2'><polyline points='20 6 9 17 4 12'></polyline></svg>"
            : "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#e65100' stroke-width='2'><circle cx='12' cy='12' r='10'></circle><line x1='12' y1='8' x2='12' y2='12'></line><line x1='12' y1='16' x2='12.01' y2='16'></line></svg>";
        cards.AppendFormat(@"
            <div class='fm-anomaly fm-anomaly--{0}'>
                <div class='fm-anomaly__icon'>{1}</div>
                <div class='fm-anomaly__label'>Bills Without GL Entries</div>
                <div class='fm-anomaly__val'>{2:N0}</div>
                <div class='fm-anomaly__hint'>{3}</div>
            </div>",
            c2Class, c2Icon, billsNoGL,
            billsNoGL == 0 ? "All bills have corresponding ledger entries"
                : string.Format("{0:N0} bill(s) are missing general ledger entries", billsNoGL));

        // Card 3: Duplicate bills
        string c3Class = duplicateBills == 0 ? "ok" : "danger";
        string c3Icon = duplicateBills == 0
            ? "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#2e7d32' stroke-width='2'><path d='M22 11.08V12a10 10 0 1 1-5.93-9.14'></path><polyline points='22 4 12 14.01 9 11.01'></polyline></svg>"
            : "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='#dc3545' stroke-width='2'><path d='M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z'></path><line x1='12' y1='9' x2='12' y2='13'></line><line x1='12' y1='17' x2='12.01' y2='17'></line></svg>";
        cards.AppendFormat(@"
            <div class='fm-anomaly fm-anomaly--{0}'>
                <div class='fm-anomaly__icon'>{1}</div>
                <div class='fm-anomaly__label'>Duplicate Bill Groups</div>
                <div class='fm-anomaly__val'>{2:N0}</div>
                <div class='fm-anomaly__hint'>{3}</div>
            </div>",
            c3Class, c3Icon, duplicateBills,
            duplicateBills == 0 ? "No duplicate billing detected — system is clean"
                : string.Format("{0:N0} student/item combination(s) have multiple bills", duplicateBills));

        litAnomalyCards.Text = cards.ToString();
    }

    private void LoadPaidButUnregistered()
    {
        // Current academic year for the paid-but-unregistered list
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
                    AND r.semester = (SELECT MAX(r2.semester) FROM campus_dynamics.acad_registration r2 WHERE r2.regno=ft.regno AND r2.acad_year=@ay)
                WHERE ft.trans_type = 'Payment'
                  AND ft.acadyear = @ay
                  AND ft.trans_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                  AND (r.regstatus IS NULL OR r.regstatus NOT IN ('REGISTERED','LATE REGISTERED','CLEARED'))
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
                            string badgeClass = status == "NO RECORD" ? "unreg" : "other";
                            string lastPay = "";
                            if (rdr["last_payment"] != DBNull.Value)
                            {
                                DateTime dt = Convert.ToDateTime(rdr["last_payment"]);
                                lastPay = dt.ToString("dd MMM yyyy");
                            }

                            rows.AppendFormat(
                                "<tr><td style='font-weight:600;'>{0}</td><td>{1}</td><td><span class='fm-code'>{2}</span></td><td style='text-align:right;font-weight:600;color:#2e7d32;'>{3}</td><td><span class='fm-paid-unreg-badge fm-paid-unreg-badge--{4}'>{5}</span></td><td style='font-size:10px;color:#888;'>{6}</td></tr>",
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

    // ═══════════════════════════════════════════════════════════════════
    // EVENT HANDLERS
    // ═══════════════════════════════════════════════════════════════════

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadDashboard();
    }

    protected void ddlBillingSystem_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadDashboard();
    }

    // ═══════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════

    private string FormatCurrency(double amount)
    {
        if (amount >= 1000000000)
            return string.Format("UGX {0:F1}B", amount / 1000000000);
        if (amount >= 1000000)
            return string.Format("UGX {0:F1}M", amount / 1000000);
        if (amount >= 1000)
            return string.Format("UGX {0:N0}", amount);
        return string.Format("UGX {0:N0}", amount);
    }
}
