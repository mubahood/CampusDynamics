using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_HRPayroll : System.Web.UI.Page
{
    // ─────────────────────────────────────────────────────────────────
    // Section 1: Infrastructure
    // ─────────────────────────────────────────────────────────────────

    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static readonly string[] MONTH_NAMES = {
        "", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
        "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
    };

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (parms != null)
                        foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
        }
        catch { /* return empty DataTable on error */ }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private int ExecuteNonQueryWithConn(MySqlConnection conn, string sql, params MySqlParameter[] parms)
    {
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parms != null)
                foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
            return cmd.ExecuteNonQuery();
        }
    }

    private string GetCurrentUser()
    {
        if (Session["ScreenName"] != null) return Session["ScreenName"].ToString();
        if (Session["username"] != null) return Session["username"].ToString();
        return "";
    }

    private decimal SafeDecimal(object val)
    {
        if (val == null || val == DBNull.Value) return 0m;
        decimal d;
        return decimal.TryParse(val.ToString(), out d) ? d : 0m;
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int i;
        return int.TryParse(val.ToString(), out i) ? i : 0;
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 2: PayrollConfig (PRESERVED EXACTLY from existing code)
    // ─────────────────────────────────────────────────────────────────

    private struct PayrollConfig
    {
        public decimal PayeB1Max,  PayeB1Rate;
        public decimal PayeB2Max,  PayeB2Rate;
        public decimal PayeB3Max,  PayeB3Rate;
        public decimal PayeB4Max,  PayeB4Rate;
        public decimal             PayeB5Rate;
        public decimal NssfEmployeeRate;
        public bool    ChargeKabaka;
        public decimal KabakaRate;
        public bool    ChargeLocalTax;
        public decimal LocalTaxRate;
    }

    private PayrollConfig LoadPayrollConfig()
    {
        var def = new PayrollConfig
        {
            PayeB1Max = 235000m,   PayeB1Rate = 0m,
            PayeB2Max = 335000m,   PayeB2Rate = 10m,
            PayeB3Max = 410000m,   PayeB3Rate = 20m,
            PayeB4Max = 10000000m, PayeB4Rate = 30m,
                                   PayeB5Rate = 40m,
            NssfEmployeeRate = 5m,
            ChargeKabaka   = true,  KabakaRate   = 1m,
            ChargeLocalTax = false, LocalTaxRate = 1m
        };

        try
        {
            DataTable dt = ExecuteQuery(@"
                SELECT paye_b1_max, paye_b1_rate,
                       paye_b2_max, paye_b2_rate,
                       paye_b3_max, paye_b3_rate,
                       paye_b4_max, paye_b4_rate,
                       paye_b5_rate,
                       nssf_employee_rate,
                       should_charge_kabaka, kabaka_rate,
                       should_charge_local_tax, local_tax_rate
                FROM hrm_config WHERE id = 1");

            if (dt.Rows.Count == 0) return def;

            DataRow r = dt.Rows[0];
            def.PayeB1Max  = ToDecimal(r["paye_b1_max"],  def.PayeB1Max);
            def.PayeB1Rate = ToDecimal(r["paye_b1_rate"], def.PayeB1Rate);
            def.PayeB2Max  = ToDecimal(r["paye_b2_max"],  def.PayeB2Max);
            def.PayeB2Rate = ToDecimal(r["paye_b2_rate"], def.PayeB2Rate);
            def.PayeB3Max  = ToDecimal(r["paye_b3_max"],  def.PayeB3Max);
            def.PayeB3Rate = ToDecimal(r["paye_b3_rate"], def.PayeB3Rate);
            def.PayeB4Max  = ToDecimal(r["paye_b4_max"],  def.PayeB4Max);
            def.PayeB4Rate = ToDecimal(r["paye_b4_rate"], def.PayeB4Rate);
            def.PayeB5Rate = ToDecimal(r["paye_b5_rate"], def.PayeB5Rate);
            def.NssfEmployeeRate = ToDecimal(r["nssf_employee_rate"], def.NssfEmployeeRate);
            def.ChargeKabaka     = r["should_charge_kabaka"].ToString().ToUpper() == "YES";
            def.KabakaRate       = ToDecimal(r["kabaka_rate"], def.KabakaRate);
            def.ChargeLocalTax   = r["should_charge_local_tax"].ToString().ToUpper() == "YES";
            def.LocalTaxRate     = ToDecimal(r["local_tax_rate"], def.LocalTaxRate);
        }
        catch
        {
            // hrm_config not yet created — use defaults
        }
        return def;
    }

    private static decimal ToDecimal(object val, decimal fallback)
    {
        if (val == null || val == DBNull.Value) return fallback;
        decimal d;
        return decimal.TryParse(val.ToString(), out d) ? d : fallback;
    }

    private decimal CalculatePAYE(decimal taxableMonthly, PayrollConfig cfg)
    {
        if (taxableMonthly <= 0 || cfg.PayeB1Rate == 100) return 0;

        decimal paye = 0;

        decimal inB1 = Math.Min(taxableMonthly, cfg.PayeB1Max);
        paye += inB1 * cfg.PayeB1Rate / 100;

        if (taxableMonthly > cfg.PayeB1Max)
        {
            decimal inB2 = Math.Min(taxableMonthly, cfg.PayeB2Max) - cfg.PayeB1Max;
            if (inB2 > 0) paye += inB2 * cfg.PayeB2Rate / 100;
        }
        if (taxableMonthly > cfg.PayeB2Max)
        {
            decimal inB3 = Math.Min(taxableMonthly, cfg.PayeB3Max) - cfg.PayeB2Max;
            if (inB3 > 0) paye += inB3 * cfg.PayeB3Rate / 100;
        }
        if (taxableMonthly > cfg.PayeB3Max)
        {
            decimal inB4 = Math.Min(taxableMonthly, cfg.PayeB4Max) - cfg.PayeB3Max;
            if (inB4 > 0) paye += inB4 * cfg.PayeB4Rate / 100;
        }
        if (taxableMonthly > cfg.PayeB4Max)
        {
            decimal inB5 = taxableMonthly - cfg.PayeB4Max;
            paye += inB5 * cfg.PayeB5Rate / 100;
        }

        return Math.Round(paye, 0);
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 3: Page_Load
    // ─────────────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadYearDropdown();
            LoadStats();
            LoadCreateModalDropdowns();
            txtPayrollYear.Text = DateTime.Today.Year.ToString();
            ddlPayrollMonth.SelectedValue = DateTime.Today.Month.ToString();
        }
        BindPayrollGrid();
        LoadStats();
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 4: LoadYearDropdown
    // ─────────────────────────────────────────────────────────────────

    private void LoadYearDropdown()
    {
        int currentYear = DateTime.Today.Year;
        DataTable dt = ExecuteQuery("SELECT DISTINCT payroll_year FROM hrm_payroll ORDER BY payroll_year DESC");

        var years = new List<int>();
        foreach (DataRow r in dt.Rows)
        {
            int y = SafeInt(r["payroll_year"]);
            if (y > 0) years.Add(y);
        }
        if (!years.Contains(currentYear))
            years.Add(currentYear);
        years.Sort((a, b) => b.CompareTo(a));

        ddlPayrollYear.Items.Clear();
        ddlPayrollYear.Items.Add(new ListItem("All Years", ""));
        foreach (int y in years)
            ddlPayrollYear.Items.Add(new ListItem(y.ToString(), y.ToString()));

        // Default to current year
        ListItem cur = ddlPayrollYear.Items.FindByValue(currentYear.ToString());
        if (cur != null) cur.Selected = true;
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 5: LoadStats
    // ─────────────────────────────────────────────────────────────────

    private void LoadStats()
    {
        try
        {
            string yearFilter = ddlPayrollYear.SelectedValue;
            string whereClause = string.IsNullOrEmpty(yearFilter) ? "" : "WHERE p.payroll_year = @yr";

            string sql = @"
                SELECT COUNT(DISTINCT p.ID) AS total,
                       SUM(CASE WHEN p.payroll_status='PROCESSED' THEN 1 ELSE 0 END) AS processed_cnt,
                       COALESCE(SUM(ps.gross_salary),0) AS total_gross,
                       COALESCE(SUM(ps.net_salary),0) AS total_net
                FROM hrm_payroll p
                LEFT JOIN hrm_payslips ps ON ps.payroll_id = p.ID
                " + whereClause;

            DataTable dt;
            if (string.IsNullOrEmpty(yearFilter))
                dt = ExecuteQuery(sql);
            else
                dt = ExecuteQuery(sql, new MySqlParameter("@yr", yearFilter));

            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                litTotalPayrolls.Text = SafeInt(r["total"]).ToString();
                litTotalGross.Text    = SafeDecimal(r["total_gross"]).ToString("N0");
                litTotalNet.Text      = SafeDecimal(r["total_net"]).ToString("N0");
                litProcessed.Text     = SafeInt(r["processed_cnt"]).ToString();
            }
        }
        catch
        {
            litTotalPayrolls.Text = "0";
            litTotalGross.Text    = "0";
            litTotalNet.Text      = "0";
            litProcessed.Text     = "0";
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 6: LoadCreateModalDropdowns
    // ─────────────────────────────────────────────────────────────────

    private void LoadCreateModalDropdowns()
    {
        // Departments
        DataTable dtDepts = ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
        lstTargetDepts.Items.Clear();
        foreach (DataRow r in dtDepts.Rows)
            lstTargetDepts.Items.Add(new ListItem(r["dept_name"].ToString(), r["ID"].ToString()));

        // Active employees with valid contracts
        DataTable dtEmps = ExecuteQuery(@"
            SELECT DISTINCT e.empID, CONCAT(e.emp_name,' [',IFNULL(e.EMP_CODE,''),']') AS display
            FROM hrm_employee e
            JOIN hrm_emp_contracts c ON c.empID = e.empID
            WHERE c.contractStatus = 'VALID' AND c.contractEnd >= CURDATE()
            ORDER BY e.emp_name");
        lstTargetEmps.Items.Clear();
        foreach (DataRow r in dtEmps.Rows)
            lstTargetEmps.Items.Add(new ListItem(r["display"].ToString(), r["empID"].ToString()));
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 7: BindPayrollGrid
    // ─────────────────────────────────────────────────────────────────

    private void BindPayrollGrid()
    {
        var whereParts = new List<string>();
        var parms      = new List<MySqlParameter>();

        string yearVal   = ddlPayrollYear.SelectedValue;
        string statusVal = ddlPayrollStatus.SelectedValue;

        if (!string.IsNullOrEmpty(yearVal))
        {
            whereParts.Add("p.payroll_year = @yr");
            parms.Add(new MySqlParameter("@yr", yearVal));
        }
        if (!string.IsNullOrEmpty(statusVal))
        {
            whereParts.Add("p.payroll_status = @status");
            parms.Add(new MySqlParameter("@status", statusVal));
        }

        string where = whereParts.Count > 0 ? "WHERE " + string.Join(" AND ", whereParts) : "";

        string sql = @"
            SELECT p.ID, p.payroll_title, p.payroll_month, p.payroll_year, p.payroll_date,
                   p.payroll_status, p.target_type, p.total_amount, p.prepared_by,
                   COUNT(DISTINCT ps.ID) AS staff_count
            FROM hrm_payroll p
            LEFT JOIN hrm_payslips ps ON ps.payroll_id = p.ID
            " + where + @"
            GROUP BY p.ID, p.payroll_title, p.payroll_month, p.payroll_year, p.payroll_date,
                     p.payroll_status, p.target_type, p.total_amount, p.prepared_by
            ORDER BY p.payroll_year DESC, p.payroll_month DESC, p.ID DESC";

        DataTable dt = ExecuteQuery(sql, parms.ToArray());

        litFilterCount.Text = dt.Rows.Count.ToString();
        gvPayrolls.DataSource = dt;
        gvPayrolls.DataBind();
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 8: btnCreatePayroll_Click
    // ─────────────────────────────────────────────────────────────────

    protected void btnCreatePayroll_Click(object sender, EventArgs e)
    {
        string title = txtPayrollTitle.Text.Trim();
        if (string.IsNullOrEmpty(title))
        {
            ShowModalError("createPayrollModal", "createResult", "Payroll title is required.");
            return;
        }

        int month = SafeInt(ddlPayrollMonth.SelectedValue);
        int year;
        if (!int.TryParse(txtPayrollYear.Text.Trim(), out year) || year < 2000 || year > 2099)
        {
            ShowModalError("createPayrollModal", "createResult", "Please enter a valid 4-digit year.");
            return;
        }

        string targetType = ddlTargetType.SelectedValue;
        if (string.IsNullOrEmpty(targetType)) targetType = "ALL";

        // Build target_ids
        string targetIds = "";
        if (targetType == "DEPARTMENT")
        {
            var ids = new List<string>();
            foreach (ListItem item in lstTargetDepts.Items)
                if (item.Selected) ids.Add(item.Value);
            targetIds = string.Join(",", ids);
        }
        else if (targetType == "EMPLOYEE")
        {
            var ids = new List<string>();
            foreach (ListItem item in lstTargetEmps.Items)
                if (item.Selected) ids.Add(item.Value);
            targetIds = string.Join(",", ids);
        }

        string inclDed   = ddlIncludeDeductions.SelectedValue;
        string inclAllow = ddlIncludeAllowances.SelectedValue;
        string comments  = txtPayrollComments.Text.Trim();
        string user      = GetCurrentUser();

        try
        {
            ExecuteNonQuery(@"
                INSERT INTO hrm_payroll (payroll_title, payroll_month, payroll_year, payroll_comments,
                    prepared_by, payroll_date, lockStatus, payroll_status, target_type, target_ids,
                    should_include_deductions, should_include_allowances)
                VALUES (@title, @month, @year, @comments, @user, NOW(), 'OPEN', 'PENDING',
                        @targetType, @targetIds, @inclDed, @inclAllow)",
                new MySqlParameter("@title",      title),
                new MySqlParameter("@month",      month),
                new MySqlParameter("@year",       year),
                new MySqlParameter("@comments",   comments),
                new MySqlParameter("@user",       user),
                new MySqlParameter("@targetType", targetType),
                new MySqlParameter("@targetIds",  targetIds),
                new MySqlParameter("@inclDed",    inclDed),
                new MySqlParameter("@inclAllow",  inclAllow));

            txtPayrollTitle.Text    = "";
            txtPayrollComments.Text = "";
            BindPayrollGrid();
            LoadStats();

            ScriptManager.RegisterStartupScript(this, GetType(), "closeCreate",
                "document.getElementById('createPayrollModal').style.display='none';" +
                "showToast('Payroll created successfully.','success');", true);
        }
        catch (Exception ex)
        {
            ShowModalError("createPayrollModal", "createResult",
                "Error creating payroll: " + ex.Message);
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 9: ddlTargetType_Changed
    // ─────────────────────────────────────────────────────────────────

    protected void ddlTargetType_Changed(object sender, EventArgs e)
    {
        string val = ddlTargetType.SelectedValue;
        pnlTargetDept.Visible = (val == "DEPARTMENT");
        pnlTargetEmp.Visible  = (val == "EMPLOYEE");
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 10: btnViewPayroll_Click
    // ─────────────────────────────────────────────────────────────────

    protected void btnViewPayroll_Click(object sender, EventArgs e)
    {
        int payrollID;
        if (!int.TryParse(hdnSelectedPayrollID.Value, out payrollID)) return;

        ShowPayrollDetails(payrollID);
        pnlPayrollDetails.Visible = true;

        ScriptManager.RegisterStartupScript(this, GetType(), "scrollToDetails",
            "setTimeout(function(){ var el=document.getElementById('pnlPayrollDetails'); if(el) el.scrollIntoView({behavior:'smooth',block:'start'}); },150);",
            true);
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 11: ShowPayrollDetails
    // ─────────────────────────────────────────────────────────────────

    private void ShowPayrollDetails(int payrollID)
    {
        try
        {
            // Load payroll header
            DataTable dtHeader = ExecuteQuery(
                "SELECT payroll_title, payroll_status, payroll_month, payroll_year FROM hrm_payroll WHERE ID=@id",
                new MySqlParameter("@id", payrollID));

            if (dtHeader.Rows.Count == 0) return;
            DataRow hdr = dtHeader.Rows[0];

            string status = hdr["payroll_status"].ToString();
            litPayrollTitle.Text      = HttpUtility.HtmlEncode(hdr["payroll_title"].ToString());
            litPayrollStatusBadge.Text = GetStatusBadge(status);

            lnkViewPayslips.NavigateUrl = "~/COOPERP/NewScreens/HRPayslips.aspx?payroll_id=" + payrollID;

            // Payslip summary aggregates
            DataTable dtSum = ExecuteQuery(@"
                SELECT COALESCE(SUM(basic_pay),0)              AS sum_basic,
                       COALESCE(SUM(gross_salary),0)           AS sum_gross,
                       COALESCE(SUM(total_allowances),0)       AS sum_allow,
                       COALESCE(SUM(paye),0)                   AS sum_paye,
                       COALESCE(SUM(nssf),0)                   AS sum_nssf,
                       COALESCE(SUM(kabaka_contribution),0)    AS sum_kabaka,
                       COALESCE(SUM(local_tax),0)              AS sum_localtax,
                       COALESCE(SUM(total_deductions),0)       AS sum_ded,
                       COALESCE(SUM(net_salary),0)             AS sum_net,
                       COUNT(*)                                AS payslip_count
                FROM hrm_payslips
                WHERE payroll_id = @id",
                new MySqlParameter("@id", payrollID));

            bool hasPayslips = false;
            if (dtSum.Rows.Count > 0)
            {
                DataRow s = dtSum.Rows[0];
                hasPayslips = SafeInt(s["payslip_count"]) > 0;

                decimal sumDed     = SafeDecimal(s["sum_ded"]);
                decimal sumPaye    = SafeDecimal(s["sum_paye"]);
                decimal sumNssf    = SafeDecimal(s["sum_nssf"]);
                decimal sumKabaka  = SafeDecimal(s["sum_kabaka"]);
                decimal sumLocal   = SafeDecimal(s["sum_localtax"]);
                decimal otherDed   = sumDed - sumPaye - sumNssf - sumKabaka - sumLocal;
                if (otherDed < 0) otherDed = 0;

                litDetBasic.Text       = SafeDecimal(s["sum_basic"]).ToString("N0");
                litDetGross.Text       = SafeDecimal(s["sum_gross"]).ToString("N0");
                litDetAllowances.Text  = SafeDecimal(s["sum_allow"]).ToString("N0");
                litDetPAYE.Text        = sumPaye.ToString("N0");
                litDetNSSF.Text        = sumNssf.ToString("N0");
                litDetKabaka.Text      = sumKabaka.ToString("N0");
                litDetLocalTax.Text    = sumLocal.ToString("N0");
                litDetOtherDed.Text    = otherDed.ToString("N0");
                litDetNet.Text         = SafeDecimal(s["sum_net"]).ToString("N0");
            }

            // Unapproved payslips
            DataTable dtUnapproved = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id=@id AND status!='APPROVED'",
                new MySqlParameter("@id", payrollID));

            int unapproved = dtUnapproved.Rows.Count > 0 ? SafeInt(dtUnapproved.Rows[0]["cnt"]) : 0;

            litUnapprovedInfo.Text = unapproved > 0
                ? "<span class='text-warning'>\u26a0 " + unapproved + " payslip(s) pending approval</span>"
                : "<span class='text-success'>\u2713 All payslips approved</span>";

            // Button visibility
            if (btnApprovePayroll != null)
                btnApprovePayroll.Visible = (status == "PENDING" && unapproved == 0 && hasPayslips);
            if (btnCancelPayroll != null)
                btnCancelPayroll.Visible = (status == "PENDING");

            BindPayrollDetailsGrid(payrollID);
        }
        catch (Exception ex)
        {
            litAlert.Text = "<div class='alert alert-danger'>Error loading payroll details: " +
                HttpUtility.HtmlEncode(ex.Message) + "</div>";
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 12: BindPayrollDetailsGrid
    // ─────────────────────────────────────────────────────────────────

    private void BindPayrollDetailsGrid(int payrollID)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT ps.ID, ps.empID, e.EMP_CODE, e.emp_name,
                   ps.basic_pay, ps.total_allowances,
                   ps.gross_salary  AS gross_pay,
                   ps.paye, ps.nssf, ps.total_deductions,
                   ps.net_salary    AS net_pay,
                   ps.status
            FROM hrm_payslips ps
            JOIN hrm_employee e ON e.empID = ps.empID
            WHERE ps.payroll_id = @pid
            ORDER BY e.emp_name",
            new MySqlParameter("@pid", payrollID));

        gvPayrollDetails.DataSource = dt;
        gvPayrollDetails.DataBind();
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 13: btnGenPayroll_Click — opens the process confirm modal
    // ─────────────────────────────────────────────────────────────────

    protected void btnGenPayroll_Click(object sender, EventArgs e)
    {
        int payrollID;
        if (!int.TryParse(hdnGeneratePayrollID.Value, out payrollID)) return;

        try
        {
            DataTable dtPayroll = ExecuteQuery(
                @"SELECT payroll_title, payroll_month, payroll_year, payroll_status,
                         target_type, target_ids, should_include_deductions, should_include_allowances
                  FROM hrm_payroll WHERE ID=@id",
                new MySqlParameter("@id", payrollID));

            if (dtPayroll.Rows.Count == 0) return;
            DataRow pr = dtPayroll.Rows[0];

            string status = pr["payroll_status"].ToString();
            if (status != "PENDING")
            {
                ShowAlert("Only PENDING payrolls can be processed.", "danger");
                return;
            }

            int payrollMonth = SafeInt(pr["payroll_month"]);
            int payrollYear  = SafeInt(pr["payroll_year"]);
            string monthName = (payrollMonth >= 1 && payrollMonth <= 12)
                ? MONTH_NAMES[payrollMonth] : payrollMonth.ToString();

            string targetType = pr["target_type"].ToString();
            string targetIds  = pr["target_ids"] == null || pr["target_ids"] == DBNull.Value ? "" : pr["target_ids"].ToString();
            string inclDed    = pr["should_include_deductions"].ToString();
            string inclAllow  = pr["should_include_allowances"].ToString();

            // Count target employees
            List<int> targetEmps = ResolveTargetEmployees(payrollID);
            int empCount = targetEmps.Count;

            // Count existing payslips
            DataTable dtExisting = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id=@id",
                new MySqlParameter("@id", payrollID));
            int existingCount = dtExisting.Rows.Count > 0 ? SafeInt(dtExisting.Rows[0]["cnt"]) : 0;

            // Count approved payslips (will be preserved)
            DataTable dtApproved = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id=@id AND status='APPROVED'",
                new MySqlParameter("@id", payrollID));
            int approvedCount = dtApproved.Rows.Count > 0 ? SafeInt(dtApproved.Rows[0]["cnt"]) : 0;
            int regenerateCount = existingCount - approvedCount;

            // Target label
            string targetLabel;
            if (targetType == "ALL")
                targetLabel = "All Active Staff";
            else if (targetType == "DEPARTMENT")
            {
                int deptCount = string.IsNullOrEmpty(targetIds) ? 0 : targetIds.Split(',').Length;
                targetLabel = deptCount + " Department(s)";
            }
            else
            {
                int empSelCount = string.IsNullOrEmpty(targetIds) ? 0 : targetIds.Split(',').Length;
                targetLabel = empSelCount + " Specific Employee(s)";
            }

            var sb = new StringBuilder();
            sb.Append("<table class='confirm-table' style='width:100%;border-collapse:collapse;font-size:13px;'>");
            sb.Append("<tr><td style='padding:4px 8px;color:#666;width:160px;'>Period:</td>");
            sb.Append("<td style='padding:4px 8px;font-weight:600;'>" + monthName + " " + payrollYear + "</td></tr>");
            sb.Append("<tr><td style='padding:4px 8px;color:#666;'>Target:</td>");
            sb.Append("<td style='padding:4px 8px;'>" + HttpUtility.HtmlEncode(targetLabel) + "</td></tr>");
            sb.Append("<tr><td style='padding:4px 8px;color:#666;'>Staff to process:</td>");
            sb.Append("<td style='padding:4px 8px;font-weight:600;'>" + empCount + " employee(s)</td></tr>");
            sb.Append("<tr><td style='padding:4px 8px;color:#666;'>Include Allowances:</td>");
            sb.Append("<td style='padding:4px 8px;'>" + (inclAllow == "YES" ? "Yes" : "No") + "</td></tr>");
            sb.Append("<tr><td style='padding:4px 8px;color:#666;'>Include Deductions:</td>");
            sb.Append("<td style='padding:4px 8px;'>" + (inclDed == "YES" ? "Yes" : "No") + "</td></tr>");
            if (regenerateCount > 0)
            {
                sb.Append("<tr><td colspan='2' style='padding:8px;background:#fff8e1;color:#856404;border-radius:4px;margin-top:8px;'>");
                sb.Append("\u26a0 " + regenerateCount + " existing payslip(s) will be deleted and regenerated");
                if (approvedCount > 0)
                    sb.Append(" (" + approvedCount + " approved payslip(s) will be preserved)");
                sb.Append(".</td></tr>");
            }
            sb.Append("</table>");

            litProcessConfirmBody.Text = sb.ToString();

            ScriptManager.RegisterStartupScript(this, GetType(), "showProcessModal",
                "document.getElementById('processConfirmModal').style.display='flex';", true);
        }
        catch (Exception ex)
        {
            ShowAlert("Error preparing payroll: " + ex.Message, "danger");
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 14: btnConfirmProcess_Click
    // ─────────────────────────────────────────────────────────────────

    protected void btnConfirmProcess_Click(object sender, EventArgs e)
    {
        int payrollID;
        if (!int.TryParse(hdnGeneratePayrollID.Value, out payrollID)) return;

        try
        {
            PayrollConfig cfg = LoadPayrollConfig();
            GeneratePayslipsForPayroll(payrollID, cfg);

            BindPayrollGrid();
            LoadStats();
            ShowPayrollDetails(payrollID);
            pnlPayrollDetails.Visible = true;

            ScriptManager.RegisterStartupScript(this, GetType(), "closeProcessModal",
                "document.getElementById('processConfirmModal').style.display='none';" +
                "showToast('Payslips generated successfully.','success');", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "processError",
                "document.getElementById('processConfirmModal').style.display='none';" +
                "showToast('Error: " + HttpUtility.JavaScriptStringEncode(ex.Message) + "','danger');", true);
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 15: GeneratePayslipsForPayroll
    // ─────────────────────────────────────────────────────────────────

    private void GeneratePayslipsForPayroll(int payrollID, PayrollConfig cfg)
    {
        // Load payroll record
        DataTable dtPayroll = ExecuteQuery(
            @"SELECT payroll_month, payroll_year, target_type, target_ids,
                     should_include_deductions, should_include_allowances
              FROM hrm_payroll WHERE ID=@id",
            new MySqlParameter("@id", payrollID));

        if (dtPayroll.Rows.Count == 0)
            throw new Exception("Payroll record not found.");

        DataRow pr           = dtPayroll.Rows[0];
        int payrollMonth     = SafeInt(pr["payroll_month"]);
        int payrollYear      = SafeInt(pr["payroll_year"]);
        bool inclDeductions  = pr["should_include_deductions"].ToString().ToUpper() == "YES";
        bool inclAllowances  = pr["should_include_allowances"].ToString().ToUpper() == "YES";

        string payrollMonthName = (payrollMonth >= 1 && payrollMonth <= 12)
            ? MONTH_NAMES[payrollMonth] : "";

        // Delete PENDING/REJECTED payslips — preserve APPROVED
        ExecuteNonQuery(
            "DELETE FROM hrm_payslips WHERE payroll_id=@id AND status IN ('PENDING','REJECTED')",
            new MySqlParameter("@id", payrollID));

        // Delete legacy detail records (will be rebuilt)
        ExecuteNonQuery("DELETE FROM hrm_payroll_details WHERE payrollID=@id",
            new MySqlParameter("@id", payrollID));

        List<int> targetEmps = ResolveTargetEmployees(payrollID);
        decimal totalNet = 0m;

        foreach (int empID in targetEmps)
        {
            // Check for existing APPROVED payslip — preserve it
            DataTable dtApproved = ExecuteQuery(
                "SELECT ID, basic_pay, gross_salary, total_allowances, paye, nssf, " +
                "kabaka_contribution, local_tax, total_deductions, net_salary " +
                "FROM hrm_payslips WHERE payroll_id=@pid AND empID=@eid AND status='APPROVED'",
                new MySqlParameter("@pid", payrollID),
                new MySqlParameter("@eid", empID));

            if (dtApproved.Rows.Count > 0)
            {
                // Use existing approved values for totalNet and write to legacy table
                DataRow ap = dtApproved.Rows[0];
                decimal apNetSalary = SafeDecimal(ap["net_salary"]);
                totalNet += apNetSalary;

                // Write to hrm_payroll_details for backward compat
                try
                {
                    ExecuteNonQuery(@"
                        INSERT INTO hrm_payroll_details
                            (payrollID, empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay)
                        VALUES (@pid, @eid, @basic, @paye, @nssf, @allow, @ded, @gross, @net)",
                        new MySqlParameter("@pid",   payrollID),
                        new MySqlParameter("@eid",   empID),
                        new MySqlParameter("@basic", SafeDecimal(ap["basic_pay"])),
                        new MySqlParameter("@paye",  SafeDecimal(ap["paye"])),
                        new MySqlParameter("@nssf",  SafeDecimal(ap["nssf"])),
                        new MySqlParameter("@allow", SafeDecimal(ap["total_allowances"])),
                        new MySqlParameter("@ded",   SafeDecimal(ap["total_deductions"])),
                        new MySqlParameter("@gross", SafeDecimal(ap["gross_salary"])),
                        new MySqlParameter("@net",   apNetSalary));
                }
                catch { /* non-critical */ }
                continue;
            }

            // Get basic pay from most recent valid contract
            decimal basicPay = 0m;
            DataTable dtContract = ExecuteQuery(@"
                SELECT IFNULL(ps.basicpay, c.fixedamount) AS basic_pay
                FROM hrm_emp_contracts c
                LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
                WHERE c.empID = @eid
                ORDER BY c.ID DESC LIMIT 1",
                new MySqlParameter("@eid", empID));

            if (dtContract.Rows.Count > 0)
                basicPay = SafeDecimal(dtContract.Rows[0]["basic_pay"]);

            if (basicPay <= 0) continue;

            // ── Standard allowances ─────────────────────────────────
            decimal stdAllowances = 0m;
            var allowanceDetails  = new List<string>();

            DataTable dtAllow = ExecuteQuery(@"
                SELECT ad.dedall_name, IFNULL(das.custom_amount, ad.dedall_amount) AS amount, ad.computation_by
                FROM hrm_allowance_deductions ad
                JOIN hrm_ded_allowance_stafflist das ON das.ded_allID = ad.ID
                LEFT JOIN hrm_exemptions ex ON ex.empID = @eid AND ex.ded_allID = ad.ID
                WHERE das.empID = @eid AND ad.ded_allowance = 'ALLOWANCE' AND ex.ID IS NULL",
                new MySqlParameter("@eid", empID));

            foreach (DataRow a in dtAllow.Rows)
            {
                decimal amt   = SafeDecimal(a["amount"]);
                string compBy = a["computation_by"] == null || a["computation_by"] == DBNull.Value ? "" : a["computation_by"].ToString();
                decimal final = compBy.ToUpper() == "PERCENTAGE" ? basicPay * amt / 100 : amt;
                stdAllowances += final;
                allowanceDetails.Add(a["dedall_name"].ToString() + ":" + Math.Round(final, 0).ToString("F0"));
            }

            // ── Ad-hoc allowances ───────────────────────────────────
            decimal adHocAllowanceAmount = 0m;
            if (inclAllowances && !string.IsNullOrEmpty(payrollMonthName))
            {
                try
                {
                    DataTable dtAdAllow = ExecuteQuery(@"
                        SELECT allowance_type, amount FROM hrm_allowance_records
                        WHERE empID=@eid AND to_add_month=@month AND to_add_year=@year AND status='PENDING'",
                        new MySqlParameter("@eid",   empID),
                        new MySqlParameter("@month", payrollMonthName),
                        new MySqlParameter("@year",  payrollYear));

                    foreach (DataRow ar in dtAdAllow.Rows)
                    {
                        decimal amt = SafeDecimal(ar["amount"]);
                        adHocAllowanceAmount += amt;
                        allowanceDetails.Add(ar["allowance_type"].ToString() + ":" + Math.Round(amt, 0).ToString("F0"));
                    }
                }
                catch { /* table may not exist */ }
            }

            decimal totalAllowances = stdAllowances + adHocAllowanceAmount;

            // ── Standard deductions ─────────────────────────────────
            decimal nonStatDeductions = 0m;
            var deductionDetails      = new List<string>();

            DataTable dtDed = ExecuteQuery(@"
                SELECT ad.dedall_name, IFNULL(das.custom_amount, ad.dedall_amount) AS amount, ad.computation_by
                FROM hrm_allowance_deductions ad
                JOIN hrm_ded_allowance_stafflist das ON das.ded_allID = ad.ID
                LEFT JOIN hrm_exemptions ex ON ex.empID = @eid AND ex.ded_allID = ad.ID
                WHERE das.empID = @eid AND ad.ded_allowance = 'DEDUCTION' AND ex.ID IS NULL",
                new MySqlParameter("@eid", empID));

            foreach (DataRow d in dtDed.Rows)
            {
                decimal amt   = SafeDecimal(d["amount"]);
                string compBy = d["computation_by"] == null || d["computation_by"] == DBNull.Value ? "" : d["computation_by"].ToString();
                decimal final = compBy.ToUpper() == "PERCENTAGE" ? basicPay * amt / 100 : amt;
                nonStatDeductions += final;
                deductionDetails.Add(d["dedall_name"].ToString() + ":" + Math.Round(final, 0).ToString("F0"));
            }

            // ── Ad-hoc deductions ───────────────────────────────────
            decimal adHocDeductionAmount = 0m;
            if (inclDeductions && !string.IsNullOrEmpty(payrollMonthName))
            {
                try
                {
                    DataTable dtAdDed = ExecuteQuery(@"
                        SELECT deduction_type, amount FROM hrm_deduction_records
                        WHERE empID=@eid AND to_deduct_month=@month AND to_deduct_year=@year AND status='PENDING'",
                        new MySqlParameter("@eid",   empID),
                        new MySqlParameter("@month", payrollMonthName),
                        new MySqlParameter("@year",  payrollYear));

                    foreach (DataRow dr in dtAdDed.Rows)
                    {
                        decimal amt = SafeDecimal(dr["amount"]);
                        adHocDeductionAmount += amt;
                        deductionDetails.Add(dr["deduction_type"].ToString() + ":" + Math.Round(amt, 0).ToString("F0"));
                    }
                }
                catch { /* table may not exist */ }
            }

            // ── Statutory calculations ──────────────────────────────
            decimal grossPay = basicPay + totalAllowances;
            decimal nssf     = Math.Round(basicPay * cfg.NssfEmployeeRate / 100, 0);
            decimal kabaka   = cfg.ChargeKabaka   ? Math.Round(basicPay * cfg.KabakaRate   / 100, 0) : 0m;
            decimal localTax = cfg.ChargeLocalTax ? Math.Round(basicPay * cfg.LocalTaxRate / 100, 0) : 0m;

            decimal taxableIncome  = grossPay - nssf;
            decimal paye           = CalculatePAYE(taxableIncome, cfg);

            decimal totalDeductions = paye + nssf + kabaka + localTax + nonStatDeductions + adHocDeductionAmount;
            decimal netSalary       = Math.Max(0, grossPay - totalDeductions);

            string allowDetailsStr  = string.Join("|", allowanceDetails);
            string deductDetailsStr = string.Join("|", deductionDetails);

            totalNet += netSalary;

            // Insert hrm_payslips
            ExecuteNonQuery(@"
                INSERT INTO hrm_payslips
                    (payroll_id, empID, payroll_year, payroll_month, payroll_month_name,
                     basic_pay, gross_salary, total_allowances, allowance_amount, allowance_details,
                     total_deductions, deduction_amount, deduction_details,
                     paye, nssf, kabaka_contribution, local_tax, net_salary,
                     status, date_generated)
                VALUES
                    (@pid, @eid, @yr, @mo, @moname,
                     @basic, @gross, @totAllow, @allowAmt, @allowDet,
                     @totDed, @dedAmt, @dedDet,
                     @paye, @nssf, @kabaka, @localtax, @net,
                     'PENDING', NOW())",
                new MySqlParameter("@pid",      payrollID),
                new MySqlParameter("@eid",      empID),
                new MySqlParameter("@yr",       payrollYear),
                new MySqlParameter("@mo",       payrollMonth),
                new MySqlParameter("@moname",   payrollMonthName),
                new MySqlParameter("@basic",    basicPay),
                new MySqlParameter("@gross",    grossPay),
                new MySqlParameter("@totAllow", totalAllowances),
                new MySqlParameter("@allowAmt", adHocAllowanceAmount),
                new MySqlParameter("@allowDet", allowDetailsStr),
                new MySqlParameter("@totDed",   totalDeductions),
                new MySqlParameter("@dedAmt",   adHocDeductionAmount),
                new MySqlParameter("@dedDet",   deductDetailsStr),
                new MySqlParameter("@paye",     paye),
                new MySqlParameter("@nssf",     nssf),
                new MySqlParameter("@kabaka",   kabaka),
                new MySqlParameter("@localtax", localTax),
                new MySqlParameter("@net",      netSalary));

            // Insert hrm_payroll_details for backward compat
            try
            {
                ExecuteNonQuery(@"
                    INSERT INTO hrm_payroll_details
                        (payrollID, empID, basic_pay, paye, nssf, total_allowances, total_deductions, gross_pay, net_pay)
                    VALUES (@pid, @eid, @basic, @paye, @nssf, @allow, @ded, @gross, @net)",
                    new MySqlParameter("@pid",   payrollID),
                    new MySqlParameter("@eid",   empID),
                    new MySqlParameter("@basic", basicPay),
                    new MySqlParameter("@paye",  paye),
                    new MySqlParameter("@nssf",  nssf),
                    new MySqlParameter("@allow", totalAllowances),
                    new MySqlParameter("@ded",   totalDeductions),
                    new MySqlParameter("@gross", grossPay),
                    new MySqlParameter("@net",   netSalary));
            }
            catch { /* non-critical */ }

            // Settle ad-hoc records
            if (!string.IsNullOrEmpty(payrollMonthName))
            {
                if (inclAllowances)
                {
                    try
                    {
                        ExecuteNonQuery(@"
                            UPDATE hrm_allowance_records
                            SET status='SETTLED', payment_date=NOW(), payroll_id=@pid
                            WHERE empID=@eid AND to_add_month=@month AND to_add_year=@year AND status='PENDING'",
                            new MySqlParameter("@pid",   payrollID),
                            new MySqlParameter("@eid",   empID),
                            new MySqlParameter("@month", payrollMonthName),
                            new MySqlParameter("@year",  payrollYear));
                    }
                    catch { }
                }

                if (inclDeductions)
                {
                    try
                    {
                        ExecuteNonQuery(@"
                            UPDATE hrm_deduction_records
                            SET status='SETTLED', payment_date=NOW(), payroll_id=@pid
                            WHERE empID=@eid AND to_deduct_month=@month AND to_deduct_year=@year AND status='PENDING'",
                            new MySqlParameter("@pid",   payrollID),
                            new MySqlParameter("@eid",   empID),
                            new MySqlParameter("@month", payrollMonthName),
                            new MySqlParameter("@year",  payrollYear));
                    }
                    catch { }
                }
            }
        }

        // Update payroll total
        ExecuteNonQuery("UPDATE hrm_payroll SET total_amount=@total WHERE ID=@pid",
            new MySqlParameter("@total", totalNet),
            new MySqlParameter("@pid",   payrollID));
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 16: ResolveTargetEmployees
    // ─────────────────────────────────────────────────────────────────

    private List<int> ResolveTargetEmployees(int payrollID)
    {
        var result = new List<int>();

        DataTable dtPayroll = ExecuteQuery(
            "SELECT target_type, target_ids FROM hrm_payroll WHERE ID=@id",
            new MySqlParameter("@id", payrollID));

        if (dtPayroll.Rows.Count == 0) return result;

        string targetType = dtPayroll.Rows[0]["target_type"].ToString();
        string targetIds  = dtPayroll.Rows[0]["target_ids"] == null || dtPayroll.Rows[0]["target_ids"] == DBNull.Value ? "" : dtPayroll.Rows[0]["target_ids"].ToString();

        DataTable dtEmps;

        if (targetType == "ALL")
        {
            dtEmps = ExecuteQuery(@"
                SELECT DISTINCT e.empID
                FROM hrm_employee e
                JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                    SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
                )
                LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
                WHERE c.contractStatus = 'VALID'
                  AND c.contractEnd >= CURDATE()
                  AND IFNULL(ps.basicpay, c.fixedamount) > 0");
        }
        else if (targetType == "DEPARTMENT" && !string.IsNullOrEmpty(targetIds))
        {
            string[] deptArr = targetIds.Split(',');
            var deptParms    = new List<MySqlParameter>();
            var deptIn       = new List<string>();
            for (int i = 0; i < deptArr.Length; i++)
            {
                string pname = "@d" + i;
                deptIn.Add(pname);
                deptParms.Add(new MySqlParameter(pname, deptArr[i].Trim()));
            }
            deptParms.Add(new MySqlParameter("@dummy", 0)); // ensure array not empty

            dtEmps = ExecuteQuery(@"
                SELECT DISTINCT e.empID
                FROM hrm_employee e
                JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                    SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
                )
                LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
                WHERE c.contractStatus = 'VALID'
                  AND c.contractEnd >= CURDATE()
                  AND IFNULL(ps.basicpay, c.fixedamount) > 0
                  AND c.departmentID IN (" + string.Join(",", deptIn) + ")",
                deptParms.ToArray());
        }
        else if (targetType == "EMPLOYEE" && !string.IsNullOrEmpty(targetIds))
        {
            string[] empArr = targetIds.Split(',');
            var empParms    = new List<MySqlParameter>();
            var empIn       = new List<string>();
            for (int i = 0; i < empArr.Length; i++)
            {
                string pname = "@e" + i;
                empIn.Add(pname);
                empParms.Add(new MySqlParameter(pname, empArr[i].Trim()));
            }

            dtEmps = ExecuteQuery(@"
                SELECT DISTINCT e.empID
                FROM hrm_employee e
                JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                    SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
                )
                LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
                WHERE e.empID IN (" + string.Join(",", empIn) + @")
                  AND c.contractStatus = 'VALID'
                  AND c.contractEnd >= CURDATE()
                  AND IFNULL(ps.basicpay, c.fixedamount) > 0",
                empParms.ToArray());
        }
        else
        {
            return result;
        }

        foreach (DataRow r in dtEmps.Rows)
            result.Add(SafeInt(r["empID"]));

        return result;
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 17: btnDoAction_Click
    // ─────────────────────────────────────────────────────────────────

    protected void btnDoAction_Click(object sender, EventArgs e)
    {
        int id;
        if (!int.TryParse(hdnActionPayrollID.Value, out id)) return;

        string action = hdnActionType.Value.ToUpper();

        switch (action)
        {
            case "APPROVE":
                ApprovePayroll(id);
                break;
            case "CANCEL":
                CancelPayroll(id);
                break;
            case "DELETE":
                DeletePayroll(id);
                break;
            case "REGENERATE":
                try
                {
                    PayrollConfig cfg = LoadPayrollConfig();
                    GeneratePayslipsForPayroll(id, cfg);
                    BindPayrollGrid();
                    LoadStats();
                    ShowPayrollDetails(id);
                    pnlPayrollDetails.Visible = true;
                    ShowAlert("Payslips regenerated successfully.", "success");
                }
                catch (Exception ex)
                {
                    ShowAlert("Regeneration failed: " + ex.Message, "danger");
                }
                break;
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 18: ApprovePayroll
    // ─────────────────────────────────────────────────────────────────

    private void ApprovePayroll(int payrollID)
    {
        try
        {
            DataTable dtStatus = ExecuteQuery(
                "SELECT payroll_status FROM hrm_payroll WHERE ID=@id",
                new MySqlParameter("@id", payrollID));

            if (dtStatus.Rows.Count == 0) { ShowAlert("Payroll not found.", "danger"); return; }

            string status = dtStatus.Rows[0]["payroll_status"].ToString();
            if (status != "PENDING")
            {
                ShowAlert("Only PENDING payrolls can be approved.", "danger");
                return;
            }

            DataTable dtUnapproved = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id=@id AND status!='APPROVED'",
                new MySqlParameter("@id", payrollID));

            int unapprovedCount = dtUnapproved.Rows.Count > 0 ? SafeInt(dtUnapproved.Rows[0]["cnt"]) : 0;
            if (unapprovedCount > 0)
            {
                ShowAlert("Cannot approve: " + unapprovedCount + " payslip(s) not yet approved.", "danger");
                return;
            }

            string user = GetCurrentUser();
            ExecuteNonQuery(@"
                UPDATE hrm_payroll
                SET payroll_status='PROCESSED', lockStatus='LOCKED',
                    date_processed=NOW(), processed_by=@user
                WHERE ID=@id",
                new MySqlParameter("@user", user),
                new MySqlParameter("@id",   payrollID));

            BindPayrollGrid();
            LoadStats();
            ShowPayrollDetails(payrollID);
            ShowAlert("Payroll approved and locked successfully.", "success");
        }
        catch (Exception ex)
        {
            ShowAlert("Error approving payroll: " + ex.Message, "danger");
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 19: CancelPayroll
    // ─────────────────────────────────────────────────────────────────

    private void CancelPayroll(int payrollID)
    {
        try
        {
            DataTable dtStatus = ExecuteQuery(
                "SELECT payroll_status FROM hrm_payroll WHERE ID=@id",
                new MySqlParameter("@id", payrollID));

            if (dtStatus.Rows.Count == 0) { ShowAlert("Payroll not found.", "danger"); return; }

            string status = dtStatus.Rows[0]["payroll_status"].ToString();
            if (status != "PENDING")
            {
                ShowAlert("Only PENDING payrolls can be cancelled.", "danger");
                return;
            }

            ExecuteNonQuery(
                "UPDATE hrm_payroll SET payroll_status='CANCELLED' WHERE ID=@id AND payroll_status='PENDING'",
                new MySqlParameter("@id", payrollID));

            BindPayrollGrid();
            LoadStats();
            pnlPayrollDetails.Visible = false;
            ShowAlert("Payroll cancelled.", "warning");
        }
        catch (Exception ex)
        {
            ShowAlert("Error cancelling payroll: " + ex.Message, "danger");
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 20: DeletePayroll
    // ─────────────────────────────────────────────────────────────────

    private void DeletePayroll(int payrollID)
    {
        try
        {
            DataTable dtStatus = ExecuteQuery(
                "SELECT payroll_status FROM hrm_payroll WHERE ID=@id",
                new MySqlParameter("@id", payrollID));

            if (dtStatus.Rows.Count == 0) { ShowAlert("Payroll not found.", "danger"); return; }

            string status = dtStatus.Rows[0]["payroll_status"].ToString();
            if (status != "PENDING")
            {
                ShowAlert("Only PENDING payrolls can be deleted.", "danger");
                return;
            }

            // Delete non-approved payslips only
            ExecuteNonQuery(
                "DELETE FROM hrm_payslips WHERE payroll_id=@id AND status != 'APPROVED'",
                new MySqlParameter("@id", payrollID));

            // Delete legacy detail records
            ExecuteNonQuery("DELETE FROM hrm_payroll_details WHERE payrollID=@id",
                new MySqlParameter("@id", payrollID));

            // Clean up monthly ded/allowance records
            try
            {
                ExecuteNonQuery("DELETE FROM hrm_monthly_ded_allowance WHERE payrollID=@id",
                    new MySqlParameter("@id", payrollID));
            }
            catch { /* table may not exist */ }

            // Check remaining payslips (approved ones)
            DataTable dtRemaining = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id=@id",
                new MySqlParameter("@id", payrollID));

            int remaining = dtRemaining.Rows.Count > 0 ? SafeInt(dtRemaining.Rows[0]["cnt"]) : 0;

            if (remaining == 0)
            {
                ExecuteNonQuery("DELETE FROM hrm_payroll WHERE ID=@id",
                    new MySqlParameter("@id", payrollID));
                pnlPayrollDetails.Visible = false;
                ShowAlert("Payroll deleted successfully.", "success");
            }
            else
            {
                ShowAlert("Cannot fully delete: " + remaining + " approved payslip(s) still exist. Non-approved records removed.", "warning");
            }

            BindPayrollGrid();
            LoadStats();
        }
        catch (Exception ex)
        {
            ShowAlert("Error deleting payroll: " + ex.Message, "danger");
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 21: gvPayrolls_RowDeleting
    // ─────────────────────────────────────────────────────────────────

    protected void gvPayrolls_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        int payrollID = SafeInt(e.Keys["ID"]);
        DeletePayroll(payrollID);
        e.Cancel = true;
        gvPayrolls.CancelEdit();
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 22: gvPayrollDetails_RowUpdating
    // ─────────────────────────────────────────────────────────────────

    protected void gvPayrollDetails_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        int slipID = SafeInt(e.Keys["ID"]);

        // Guard: look up the payslip to check payroll status
        DataTable dtSlip = ExecuteQuery(
            "SELECT ps.payroll_id, ps.empID, p.payroll_status " +
            "FROM hrm_payslips ps " +
            "JOIN hrm_payroll  p ON p.ID = ps.payroll_id " +
            "WHERE ps.ID = @id",
            new MySqlParameter("@id", slipID));

        if (dtSlip.Rows.Count == 0)
        {
            ShowAlert("Payslip not found.", "danger");
            e.Cancel = true;
            gvPayrollDetails.CancelEdit();
            return;
        }

        string payrollStatus = dtSlip.Rows[0]["payroll_status"].ToString().ToUpper();
        if (payrollStatus == "PROCESSED")
        {
            ShowAlert("This payroll is locked (PROCESSED). Payslips cannot be edited.", "danger");
            e.Cancel = true;
            gvPayrollDetails.CancelEdit();
            return;
        }

        int payrollID = SafeInt(dtSlip.Rows[0]["payroll_id"]);
        int empID     = SafeInt(dtSlip.Rows[0]["empID"]);

        decimal basicPay   = SafeDecimal(e.NewValues["basic_pay"]);
        decimal allowances = SafeDecimal(e.NewValues["total_allowances"]);
        decimal grossPay   = SafeDecimal(e.NewValues["gross_pay"]);
        decimal paye       = SafeDecimal(e.NewValues["paye"]);
        decimal nssf       = SafeDecimal(e.NewValues["nssf"]);
        decimal deductions = SafeDecimal(e.NewValues["total_deductions"]);
        decimal netPay     = SafeDecimal(e.NewValues["net_pay"]);

        // Update hrm_payslips directly (primary table)
        ExecuteNonQuery(@"
            UPDATE hrm_payslips
            SET basic_pay=@basic, total_allowances=@allow, gross_salary=@gross,
                paye=@paye, nssf=@nssf, total_deductions=@ded, net_salary=@net
            WHERE ID=@id AND status != 'APPROVED'",
            new MySqlParameter("@basic", basicPay),
            new MySqlParameter("@allow", allowances),
            new MySqlParameter("@gross", grossPay),
            new MySqlParameter("@paye",  paye),
            new MySqlParameter("@nssf",  nssf),
            new MySqlParameter("@ded",   deductions),
            new MySqlParameter("@net",   netPay),
            new MySqlParameter("@id",    slipID));

        // Sync legacy hrm_payroll_details for backward compatibility
        try
        {
            ExecuteNonQuery(@"
                UPDATE hrm_payroll_details
                SET basic_pay=@basic, total_allowances=@allow, gross_pay=@gross,
                    paye=@paye, nssf=@nssf, total_deductions=@ded, net_pay=@net
                WHERE payrollID=@pid AND empID=@eid",
                new MySqlParameter("@basic", basicPay),
                new MySqlParameter("@allow", allowances),
                new MySqlParameter("@gross", grossPay),
                new MySqlParameter("@paye",  paye),
                new MySqlParameter("@nssf",  nssf),
                new MySqlParameter("@ded",   deductions),
                new MySqlParameter("@net",   netPay),
                new MySqlParameter("@pid",   payrollID),
                new MySqlParameter("@eid",   empID));
        }
        catch { /* non-critical legacy sync */ }

        e.Cancel = true;
        gvPayrollDetails.CancelEdit();
        ShowPayrollDetails(payrollID);
    }

    protected void gvPayrollDetails_HtmlRowCreated(object sender, DevExpress.Web.ASPxGridViewTableRowEventArgs e)
    {
        if (e.RowType != DevExpress.Web.GridViewRowType.Data) return;
        System.Data.DataRowView drv = e.GetRow() as System.Data.DataRowView;
        if (drv == null) return;
        string status = (drv["status"] == DBNull.Value) ? "" : drv["status"].ToString().ToUpper();
        if (status == "APPROVED")
            e.Row.CssClass = "ps-row--approved";
        else if (status == "REJECTED")
            e.Row.CssClass = "ps-row--rejected";
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 23: btnApprovePayroll_Click / btnCancelPayroll_Click
    // ─────────────────────────────────────────────────────────────────

    protected void btnApprovePayroll_Click(object sender, EventArgs e)
    {
        int payrollID;
        if (!int.TryParse(hdnSelectedPayrollID.Value, out payrollID)) return;
        ApprovePayroll(payrollID);
        int pid2 = payrollID;
        ShowPayrollDetails(pid2);
    }

    protected void btnCancelPayroll_Click(object sender, EventArgs e)
    {
        int payrollID;
        if (!int.TryParse(hdnSelectedPayrollID.Value, out payrollID)) return;
        CancelPayroll(payrollID);
        ShowPayrollDetails(payrollID);
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 24: btnCloseDetails_Click
    // ─────────────────────────────────────────────────────────────────

    protected void btnCloseDetails_Click(object sender, EventArgs e)
    {
        pnlPayrollDetails.Visible = false;
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 25: Filter event handlers
    // ─────────────────────────────────────────────────────────────────

    protected void ddlPayrollYear_Changed(object sender, EventArgs e)
    {
        BindPayrollGrid();
        LoadStats();
    }

    protected void ddlPayrollStatus_Changed(object sender, EventArgs e)
    {
        BindPayrollGrid();
        LoadStats();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        BindPayrollGrid();
        LoadStats();
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 26: Template Helpers
    // ─────────────────────────────────────────────────────────────────

    protected string FormatCurrency(object val)
    {
        if (val == null || val == DBNull.Value) return "-";
        decimal d;
        return decimal.TryParse(val.ToString(), out d) ? d.ToString("N0") : "-";
    }

    protected string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "-";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("dd MMM yyyy");
        return "-";
    }

    protected string GetPeriodHtml(object monthObj, object yearObj)
    {
        int mNum = SafeInt(monthObj);
        string mName = (mNum >= 1 && mNum <= 12) ? MONTH_NAMES[mNum] : mNum.ToString();
        string yr = (yearObj != null && yearObj != DBNull.Value) ? yearObj.ToString() : "";
        return "<span class='pr-period'>" + mName + "</span> <span class='pr-period__year'>" + yr + "</span>";
    }

    protected string GetTargetBadge(object targetType)
    {
        if (targetType == null || targetType == DBNull.Value) return "";
        switch (targetType.ToString().ToUpper())
        {
            case "ALL":
                return "<span class='pr-target-badge pr-target-badge--all'>ALL</span>";
            case "DEPARTMENT":
                return "<span class='pr-target-badge pr-target-badge--dept'>DEPARTMENT</span>";
            case "EMPLOYEE":
                return "<span class='pr-target-badge pr-target-badge--emp'>EMPLOYEE</span>";
            default:
                return "<span class='pr-target-badge'>" + HttpUtility.HtmlEncode(targetType.ToString()) + "</span>";
        }
    }

    protected string GetStatusBadge(object status)
    {
        if (status == null || status == DBNull.Value) return "";
        switch (status.ToString().ToUpper())
        {
            case "PENDING":
                return "<span class='ps-badge ps-badge--pending'>PENDING</span>";
            case "PROCESSED":
                return "<span class='ps-badge ps-badge--processed'>PROCESSED</span>";
            case "CANCELLED":
                return "<span class='ps-badge ps-badge--cancelled'>CANCELLED</span>";
            default:
                return "<span class='ps-badge'>" + HttpUtility.HtmlEncode(status.ToString()) + "</span>";
        }
    }

    protected string GetPayrollActionHtml(object idObj, object statusObj)
    {
        if (idObj == null || idObj == DBNull.Value) return "";
        string pid    = idObj.ToString();
        string status = (statusObj != null && statusObj != DBNull.Value) ? statusObj.ToString().ToUpper() : "";

        string icoEye   = "<svg width='13' height='13' fill='none' stroke='currentColor' stroke-width='2' viewBox='0 0 24 24'><ellipse cx='12' cy='12' rx='10' ry='6'/><circle cx='12' cy='12' r='2.5'/></svg>";
        string icoPlay  = "<svg width='13' height='13' fill='currentColor' viewBox='0 0 24 24'><path d='M5 3l14 9-14 9V3z'/></svg>";
        string icoList  = "<svg width='13' height='13' fill='none' stroke='currentColor' stroke-width='2' viewBox='0 0 24 24'><line x1='8' y1='6' x2='21' y2='6'/><line x1='8' y1='12' x2='21' y2='12'/><line x1='8' y1='18' x2='21' y2='18'/><line x1='3' y1='6' x2='3.01' y2='6'/><line x1='3' y1='12' x2='3.01' y2='12'/><line x1='3' y1='18' x2='3.01' y2='18'/></svg>";
        string icoCheck = "<svg width='13' height='13' fill='none' stroke='currentColor' stroke-width='2.5' viewBox='0 0 24 24'><polyline points='20 6 9 17 4 12'/></svg>";
        string icoX     = "<svg width='13' height='13' fill='none' stroke='currentColor' stroke-width='2' viewBox='0 0 24 24'><circle cx='12' cy='12' r='10'/><line x1='15' y1='9' x2='9' y2='15'/><line x1='9' y1='9' x2='15' y2='15'/></svg>";
        string icoTrash = "<svg width='13' height='13' fill='none' stroke='currentColor' stroke-width='2' viewBox='0 0 24 24'><polyline points='3 6 5 6 21 6'/><path d='M19 6l-1 14H6L5 6'/><path d='M10 11v6M14 11v6'/><path d='M9 6V4h6v2'/></svg>";

        var sb = new StringBuilder();
        sb.Append("<div class='cd-action-wrapper'>");
        sb.Append("<button type='button' class='cd-action-btn' onclick='toggleActionPopover(this,event)' title='Actions'>&#8942;</button>");
        sb.Append("<div class='cd-action-popover'>");

        // View Details — always
        sb.Append("<button type='button' onclick='closeAllPopovers();viewPayrollDetails(" + pid + ")'>" + icoEye + " View Details</button>");

        // Generate — PENDING only
        if (status == "PENDING")
            sb.Append("<button type='button' onclick='closeAllPopovers();openProcessModal(" + pid + ")'>" + icoPlay + " Generate Payslips</button>");

        // View Payslips — always
        sb.Append("<a href='HRPayslips.aspx?payroll_id=" + pid + "'>" + icoList + " View Payslips</a>");

        if (status == "PENDING")
        {
            sb.Append("<button type='button' onclick='closeAllPopovers();doAction(" + pid + ",\"CANCEL\")'>" + icoX + " Cancel Payroll</button>");
            sb.Append("<button type='button' class='pop-danger' onclick='closeAllPopovers();doAction(" + pid + ",\"DELETE\")'>" + icoTrash + " Delete</button>");
        }
        else if (status == "PROCESSED")
        {
            sb.Append("<button type='button' disabled style='opacity:.55;cursor:default;'>" + icoCheck + " Locked</button>");
        }

        sb.Append("</div></div>");
        return sb.ToString();
    }

    private void ShowAlert(string message, string type)
    {
        litAlert.Text = "<div class='alert alert-" + HttpUtility.HtmlEncode(type) + " alert-dismissible' role='alert'>" +
            HttpUtility.HtmlEncode(message) +
            "<button type='button' class='btn-close' onclick='this.parentElement.style.display=\"none\"'>&times;</button></div>";

        ScriptManager.RegisterStartupScript(this, GetType(), "toast_" + type,
            "if(typeof showToast==='function') showToast('" +
            HttpUtility.JavaScriptStringEncode(message) + "','" + type + "');", true);
    }

    // ─────────────────────────────────────────────────────────────────
    // Section 27: ShowModalError
    // ─────────────────────────────────────────────────────────────────

    private void ShowModalError(string modalId, string resultId, string message)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "modalErr_" + modalId,
            "document.getElementById('" + resultId + "').innerHTML='<span style=\"color:#dc3545;font-size:12px;\">" +
            HttpUtility.JavaScriptStringEncode(message) + "</span>';" +
            "document.getElementById('" + modalId + "').style.display='flex';", true);
    }
}
