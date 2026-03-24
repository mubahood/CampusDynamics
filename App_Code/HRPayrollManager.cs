using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// Business-logic manager for payroll lifecycle: create, process, approve, cancel, delete.
/// Used by HRPayroll.aspx and any future controllers / API endpoints.
/// </summary>
public static class HRPayrollManager
{
    // ─────────────────────────────────────────────────────────────────
    // Infrastructure
    // ─────────────────────────────────────────────────────────────────

    private static string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static readonly string[] MONTH_NAMES = {
        "", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
        "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
    };

    private static DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        var dt = new DataTable();
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                using (var da = new MySqlDataAdapter(cmd)) da.Fill(dt);
            }
        }
        return dt;
    }

    private static int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private static decimal SafeDecimal(object val)
    {
        if (val == null || val == DBNull.Value) return 0m;
        decimal d;
        return decimal.TryParse(val.ToString(), out d) ? d : 0m;
    }

    private static int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int i;
        return int.TryParse(val.ToString(), out i) ? i : 0;
    }

    // ─────────────────────────────────────────────────────────────────
    // PayrollConfig — tax rates from hrm_config
    // ─────────────────────────────────────────────────────────────────

    public struct PayrollConfig
    {
        public decimal PayeB1Max, PayeB1Rate;
        public decimal PayeB2Max, PayeB2Rate;
        public decimal PayeB3Max, PayeB3Rate;
        public decimal PayeB4Max, PayeB4Rate;
        public decimal PayeB5Rate;
        public decimal NssfEmployeeRate;
        public bool    ChargeKabaka;
        public decimal KabakaRate;
        public bool    ChargeLocalTax;
        public decimal LocalTaxRate;
    }

    public static PayrollConfig LoadPayrollConfig()
    {
        var def = new PayrollConfig
        {
            PayeB1Max = 235000m,   PayeB1Rate = 0m,
            PayeB2Max = 335000m,   PayeB2Rate = 10m,
            PayeB3Max = 410000m,   PayeB3Rate = 20m,
            PayeB4Max = 10000000m, PayeB4Rate = 30m,
                                   PayeB5Rate = 40m,
            NssfEmployeeRate = 5m,
            ChargeKabaka = true,   KabakaRate   = 1m,
            ChargeLocalTax = false, LocalTaxRate = 1m
        };
        try
        {
            DataTable dt = ExecuteQuery(@"
                SELECT paye_b1_max, paye_b1_rate, paye_b2_max, paye_b2_rate,
                       paye_b3_max, paye_b3_rate, paye_b4_max, paye_b4_rate, paye_b5_rate,
                       nssf_employee_rate, should_charge_kabaka, kabaka_rate,
                       should_charge_local_tax, local_tax_rate
                FROM hrm_config WHERE id = 1");
            if (dt.Rows.Count > 0)
            {
                DataRow r = dt.Rows[0];
                def.PayeB1Max  = Cvt(r["paye_b1_max"],  def.PayeB1Max);
                def.PayeB1Rate = Cvt(r["paye_b1_rate"], def.PayeB1Rate);
                def.PayeB2Max  = Cvt(r["paye_b2_max"],  def.PayeB2Max);
                def.PayeB2Rate = Cvt(r["paye_b2_rate"], def.PayeB2Rate);
                def.PayeB3Max  = Cvt(r["paye_b3_max"],  def.PayeB3Max);
                def.PayeB3Rate = Cvt(r["paye_b3_rate"], def.PayeB3Rate);
                def.PayeB4Max  = Cvt(r["paye_b4_max"],  def.PayeB4Max);
                def.PayeB4Rate = Cvt(r["paye_b4_rate"], def.PayeB4Rate);
                def.PayeB5Rate = Cvt(r["paye_b5_rate"], def.PayeB5Rate);
                def.NssfEmployeeRate = Cvt(r["nssf_employee_rate"], def.NssfEmployeeRate);
                def.ChargeKabaka   = r["should_charge_kabaka"].ToString().ToUpper() == "YES";
                def.KabakaRate     = Cvt(r["kabaka_rate"],   def.KabakaRate);
                def.ChargeLocalTax = r["should_charge_local_tax"].ToString().ToUpper() == "YES";
                def.LocalTaxRate   = Cvt(r["local_tax_rate"], def.LocalTaxRate);
            }
        }
        catch { /* use Uganda defaults */ }
        return def;
    }

    private static decimal Cvt(object val, decimal fallback)
    {
        if (val == null || val == DBNull.Value) return fallback;
        decimal d;
        return decimal.TryParse(val.ToString(), out d) ? d : fallback;
    }

    public static decimal CalculatePAYE(decimal taxableMonthly, PayrollConfig cfg)
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
            paye += (taxableMonthly - cfg.PayeB4Max) * cfg.PayeB5Rate / 100;
        return Math.Round(paye, 0);
    }

    // ─────────────────────────────────────────────────────────────────
    // Query helpers
    // ─────────────────────────────────────────────────────────────────

    public static DataTable GetPayrolls(string year = null, string status = null)
    {
        var where = new List<string>();
        var parms = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(year))   { where.Add("p.payroll_year = @yr");     parms.Add(new MySqlParameter("@yr",     year));   }
        if (!string.IsNullOrEmpty(status)) { where.Add("p.payroll_status = @st");   parms.Add(new MySqlParameter("@st",     status)); }
        string w = where.Count > 0 ? "WHERE " + string.Join(" AND ", where) : "";

        return ExecuteQuery(@"
            SELECT p.ID, p.payroll_title, p.payroll_month, p.payroll_year, p.payroll_date,
                   p.payroll_status, p.target_type, p.total_amount, p.prepared_by,
                   COUNT(DISTINCT ps.ID) AS staff_count
            FROM hrm_payroll p
            LEFT JOIN hrm_payslips ps ON ps.payroll_id = p.ID
            " + w + @"
            GROUP BY p.ID, p.payroll_title, p.payroll_month, p.payroll_year, p.payroll_date,
                     p.payroll_status, p.target_type, p.total_amount, p.prepared_by
            ORDER BY p.payroll_year DESC, p.payroll_month DESC, p.ID DESC",
            parms.ToArray());
    }

    public static DataTable GetPayroll(int id)
    {
        return ExecuteQuery("SELECT * FROM hrm_payroll WHERE ID = @id",
            new MySqlParameter("@id", id));
    }

    public static DataTable GetPayrollStats(string year = null)
    {
        string w    = string.IsNullOrEmpty(year) ? "" : "WHERE p.payroll_year = @yr";
        var    parm = string.IsNullOrEmpty(year) ? new MySqlParameter[0]
                      : new[] { new MySqlParameter("@yr", year) };
        return ExecuteQuery(@"
            SELECT COUNT(DISTINCT p.ID)                                                    AS total,
                   SUM(CASE WHEN p.payroll_status='PROCESSED' THEN 1 ELSE 0 END)          AS processed_cnt,
                   COALESCE(SUM(ps.gross_salary), 0)                                       AS total_gross,
                   COALESCE(SUM(ps.net_salary),   0)                                       AS total_net
            FROM hrm_payroll p
            LEFT JOIN hrm_payslips ps ON ps.payroll_id = p.ID
            " + w, parm);
    }

    public static DataTable GetPayrollSummary(int payrollID)
    {
        return ExecuteQuery(@"
            SELECT COALESCE(SUM(basic_pay),0)           AS sum_basic,
                   COALESCE(SUM(gross_salary),0)        AS sum_gross,
                   COALESCE(SUM(total_allowances),0)    AS sum_allow,
                   COALESCE(SUM(paye),0)                AS sum_paye,
                   COALESCE(SUM(nssf),0)                AS sum_nssf,
                   COALESCE(SUM(kabaka_contribution),0) AS sum_kabaka,
                   COALESCE(SUM(local_tax),0)           AS sum_localtax,
                   COALESCE(SUM(total_deductions),0)    AS sum_ded,
                   COALESCE(SUM(net_salary),0)          AS sum_net,
                   COUNT(*)                             AS payslip_count,
                   SUM(CASE WHEN status='APPROVED'  THEN 1 ELSE 0 END) AS approved_count,
                   SUM(CASE WHEN status!='APPROVED' THEN 1 ELSE 0 END) AS unapproved_count
            FROM hrm_payslips WHERE payroll_id = @id",
            new MySqlParameter("@id", payrollID));
    }

    public static DataTable GetPayrollPayslips(int payrollID)
    {
        return ExecuteQuery(@"
            SELECT ps.ID, ps.empID, e.EMP_CODE, e.emp_name,
                   ps.basic_pay, ps.total_allowances,
                   ps.gross_salary  AS gross_pay,
                   ps.paye, ps.nssf, ps.kabaka_contribution, ps.local_tax,
                   ps.total_deductions, ps.net_salary AS net_pay,
                   ps.status, ps.date_generated, ps.approved_by
            FROM hrm_payslips ps
            JOIN hrm_employee e ON e.empID = ps.empID
            WHERE ps.payroll_id = @pid
            ORDER BY e.emp_name",
            new MySqlParameter("@pid", payrollID));
    }

    public static DataTable GetPayrollYears()
    {
        return ExecuteQuery("SELECT DISTINCT payroll_year FROM hrm_payroll ORDER BY payroll_year DESC");
    }

    public static DataTable GetDepartments()
    {
        return ExecuteQuery("SELECT ID, dept_name FROM hrm_departments ORDER BY dept_name");
    }

    public static DataTable GetActiveEmployeesWithContracts()
    {
        return ExecuteQuery(@"
            SELECT DISTINCT e.empID,
                   CONCAT(e.emp_name,' [',IFNULL(e.EMP_CODE,''),']') AS display
            FROM hrm_employee e
            JOIN hrm_emp_contracts c ON c.empID = e.empID
            WHERE c.contractStatus = 'VALID' AND c.contractEnd >= CURDATE()
            ORDER BY e.emp_name");
    }

    // ─────────────────────────────────────────────────────────────────
    // Create
    // ─────────────────────────────────────────────────────────────────

    public static int CreatePayroll(string title, int month, int year,
        string targetType, string targetIds,
        string inclDeductions, string inclAllowances,
        string comments, string preparedBy)
    {
        ExecuteNonQuery(@"
            INSERT INTO hrm_payroll
                (payroll_title, payroll_month, payroll_year, payroll_comments,
                 prepared_by, payroll_date, lockStatus, payroll_status,
                 target_type, target_ids, should_include_deductions, should_include_allowances)
            VALUES
                (@title, @month, @year, @comments, @user, NOW(), 'OPEN', 'PENDING',
                 @ttype, @tids, @inclDed, @inclAllow)",
            new MySqlParameter("@title",    title),
            new MySqlParameter("@month",    month),
            new MySqlParameter("@year",     year),
            new MySqlParameter("@comments", comments),
            new MySqlParameter("@user",     preparedBy),
            new MySqlParameter("@ttype",    targetType),
            new MySqlParameter("@tids",     targetIds),
            new MySqlParameter("@inclDed",  inclDeductions),
            new MySqlParameter("@inclAllow",inclAllowances));

        DataTable dtId = ExecuteQuery("SELECT LAST_INSERT_ID() AS id");
        return dtId.Rows.Count > 0 ? SafeInt(dtId.Rows[0]["id"]) : 0;
    }

    // ─────────────────────────────────────────────────────────────────
    // Target employee resolution
    // ─────────────────────────────────────────────────────────────────

    public static List<int> ResolveTargetEmployees(int payrollID)
    {
        var result = new List<int>();
        DataTable dtPr = ExecuteQuery(
            "SELECT target_type, target_ids FROM hrm_payroll WHERE ID = @id",
            new MySqlParameter("@id", payrollID));
        if (dtPr.Rows.Count == 0) return result;

        string targetType = dtPr.Rows[0]["target_type"].ToString();
        string targetIds  = dtPr.Rows[0]["target_ids"] == null || dtPr.Rows[0]["target_ids"] == DBNull.Value
                            ? "" : dtPr.Rows[0]["target_ids"].ToString();

        const string validContractBase = @"
            JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.ID = (
                SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID
            )
            LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
            WHERE c.contractStatus = 'VALID'
              AND c.contractEnd >= CURDATE()
              AND IFNULL(ps.basicpay, c.fixedamount) > 0";

        DataTable dtEmps;

        if (targetType == "ALL")
        {
            dtEmps = ExecuteQuery(
                "SELECT DISTINCT e.empID FROM hrm_employee e" + validContractBase);
        }
        else if (targetType == "DEPARTMENT" && !string.IsNullOrEmpty(targetIds))
        {
            string[] arr   = targetIds.Split(',');
            var parms      = new List<MySqlParameter>();
            var placeholders = new List<string>();
            for (int i = 0; i < arr.Length; i++)
            {
                placeholders.Add("@d" + i);
                parms.Add(new MySqlParameter("@d" + i, arr[i].Trim()));
            }
            dtEmps = ExecuteQuery(
                "SELECT DISTINCT e.empID FROM hrm_employee e" + validContractBase +
                " AND c.departmentID IN (" + string.Join(",", placeholders) + ")",
                parms.ToArray());
        }
        else if (targetType == "EMPLOYEE" && !string.IsNullOrEmpty(targetIds))
        {
            string[] arr   = targetIds.Split(',');
            var parms      = new List<MySqlParameter>();
            var placeholders = new List<string>();
            for (int i = 0; i < arr.Length; i++)
            {
                placeholders.Add("@e" + i);
                parms.Add(new MySqlParameter("@e" + i, arr[i].Trim()));
            }
            dtEmps = ExecuteQuery(
                "SELECT DISTINCT e.empID FROM hrm_employee e" + validContractBase +
                " AND e.empID IN (" + string.Join(",", placeholders) + ")",
                parms.ToArray());
        }
        else
        {
            return result;
        }

        foreach (DataRow r in dtEmps.Rows)
            result.Add(SafeInt(r["empID"]));
        return result;
    }

    public static int CountTargetEmployees(int payrollID)
    {
        return ResolveTargetEmployees(payrollID).Count;
    }

    // ─────────────────────────────────────────────────────────────────
    // Core payslip generation engine
    // ─────────────────────────────────────────────────────────────────

    public static void GeneratePayslipsForPayroll(int payrollID, PayrollConfig cfg)
    {
        DataTable dtPr = ExecuteQuery(
            @"SELECT payroll_month, payroll_year, target_type, target_ids,
                     should_include_deductions, should_include_allowances
              FROM hrm_payroll WHERE ID = @id",
            new MySqlParameter("@id", payrollID));

        if (dtPr.Rows.Count == 0) throw new Exception("Payroll record not found.");

        DataRow pr           = dtPr.Rows[0];
        int     payrollMonth = SafeInt(pr["payroll_month"]);
        int     payrollYear  = SafeInt(pr["payroll_year"]);
        bool    inclDed      = pr["should_include_deductions"].ToString().ToUpper() == "YES";
        bool    inclAllow    = pr["should_include_allowances"].ToString().ToUpper() == "YES";
        string  monthName    = (payrollMonth >= 1 && payrollMonth <= 12) ? MONTH_NAMES[payrollMonth] : "";

        // Remove PENDING/REJECTED payslips only — preserve APPROVED
        ExecuteNonQuery(
            "DELETE FROM hrm_payslips WHERE payroll_id = @id AND status IN ('PENDING','REJECTED')",
            new MySqlParameter("@id", payrollID));

        // Rebuild legacy detail table
        try { ExecuteNonQuery("DELETE FROM hrm_payroll_details WHERE payrollID = @id",
                  new MySqlParameter("@id", payrollID)); }
        catch { /* table may not exist */ }

        List<int> targetEmps = ResolveTargetEmployees(payrollID);
        decimal   totalNet   = 0m;

        foreach (int empID in targetEmps)
        {
            // Preserve already-approved payslips
            DataTable dtApproved = ExecuteQuery(
                @"SELECT basic_pay, gross_salary, total_allowances,
                         paye, nssf, kabaka_contribution, local_tax, total_deductions, net_salary
                  FROM hrm_payslips
                  WHERE payroll_id = @pid AND empID = @eid AND status = 'APPROVED'",
                new MySqlParameter("@pid", payrollID),
                new MySqlParameter("@eid", empID));

            if (dtApproved.Rows.Count > 0)
            {
                totalNet += SafeDecimal(dtApproved.Rows[0]["net_salary"]);
                WriteLegacyDetail(payrollID, empID, dtApproved.Rows[0]);
                continue;
            }

            // Basic pay from most recent valid contract
            decimal basicPay = 0m;
            DataTable dtCon = ExecuteQuery(
                @"SELECT IFNULL(ps.basicpay, c.fixedamount) AS basic_pay
                  FROM hrm_emp_contracts c
                  LEFT JOIN hrm_payscales ps ON ps.ID = c.payscale
                  WHERE c.empID = @eid ORDER BY c.ID DESC LIMIT 1",
                new MySqlParameter("@eid", empID));
            if (dtCon.Rows.Count > 0) basicPay = SafeDecimal(dtCon.Rows[0]["basic_pay"]);
            if (basicPay <= 0) continue;

            // Standard allowances (from configured allowance assignments)
            decimal stdAllow      = 0m;
            var     allowDetails  = new List<string>();
            try
            {
                DataTable dt = ExecuteQuery(
                    @"SELECT ad.dedall_name,
                             IFNULL(das.custom_amount, ad.dedall_amount) AS amount,
                             ad.computation_by
                      FROM hrm_allowance_deductions ad
                      JOIN hrm_ded_allowance_stafflist das ON das.ded_allID = ad.ID
                      LEFT JOIN hrm_exemptions ex ON ex.empID = @eid AND ex.ded_allID = ad.ID
                      WHERE das.empID = @eid AND ad.ded_allowance = 'ALLOWANCE' AND ex.ID IS NULL",
                    new MySqlParameter("@eid", empID));
                foreach (DataRow a in dt.Rows)
                {
                    decimal amt    = SafeDecimal(a["amount"]);
                    string  compBy = a["computation_by"] == null || a["computation_by"] == DBNull.Value
                                     ? "" : a["computation_by"].ToString();
                    decimal final  = compBy.ToUpper() == "PERCENTAGE" ? basicPay * amt / 100 : amt;
                    stdAllow += final;
                    allowDetails.Add(a["dedall_name"] + ":" + Math.Round(final, 0).ToString("F0"));
                }
            }
            catch { /* table may not exist */ }

            // Ad-hoc allowances for this pay period
            decimal adHocAllow = 0m;
            if (inclAllow && !string.IsNullOrEmpty(monthName))
            {
                try
                {
                    DataTable dt = ExecuteQuery(
                        @"SELECT allowance_type, amount FROM hrm_allowance_records
                          WHERE empID = @eid AND to_add_month = @month
                            AND to_add_year = @year AND status = 'PENDING'",
                        new MySqlParameter("@eid",   empID),
                        new MySqlParameter("@month", monthName),
                        new MySqlParameter("@year",  payrollYear));
                    foreach (DataRow ar in dt.Rows)
                    {
                        decimal amt = SafeDecimal(ar["amount"]);
                        adHocAllow += amt;
                        allowDetails.Add(ar["allowance_type"] + ":" + Math.Round(amt, 0).ToString("F0"));
                    }
                }
                catch { }
            }

            // Standard non-statutory deductions
            decimal stdDed     = 0m;
            var     dedDetails = new List<string>();
            try
            {
                DataTable dt = ExecuteQuery(
                    @"SELECT ad.dedall_name,
                             IFNULL(das.custom_amount, ad.dedall_amount) AS amount,
                             ad.computation_by
                      FROM hrm_allowance_deductions ad
                      JOIN hrm_ded_allowance_stafflist das ON das.ded_allID = ad.ID
                      LEFT JOIN hrm_exemptions ex ON ex.empID = @eid AND ex.ded_allID = ad.ID
                      WHERE das.empID = @eid AND ad.ded_allowance = 'DEDUCTION' AND ex.ID IS NULL",
                    new MySqlParameter("@eid", empID));
                foreach (DataRow d in dt.Rows)
                {
                    decimal amt    = SafeDecimal(d["amount"]);
                    string  compBy = d["computation_by"] == null || d["computation_by"] == DBNull.Value
                                     ? "" : d["computation_by"].ToString();
                    decimal final  = compBy.ToUpper() == "PERCENTAGE" ? basicPay * amt / 100 : amt;
                    stdDed += final;
                    dedDetails.Add(d["dedall_name"] + ":" + Math.Round(final, 0).ToString("F0"));
                }
            }
            catch { }

            // Ad-hoc deductions for this pay period
            decimal adHocDed = 0m;
            if (inclDed && !string.IsNullOrEmpty(monthName))
            {
                try
                {
                    DataTable dt = ExecuteQuery(
                        @"SELECT deduction_type, amount FROM hrm_deduction_records
                          WHERE empID = @eid AND to_deduct_month = @month
                            AND to_deduct_year = @year AND status = 'PENDING'",
                        new MySqlParameter("@eid",   empID),
                        new MySqlParameter("@month", monthName),
                        new MySqlParameter("@year",  payrollYear));
                    foreach (DataRow dr in dt.Rows)
                    {
                        decimal amt = SafeDecimal(dr["amount"]);
                        adHocDed += amt;
                        dedDetails.Add(dr["deduction_type"] + ":" + Math.Round(amt, 0).ToString("F0"));
                    }
                }
                catch { }
            }

            // Statutory calculations
            decimal totalAllow  = stdAllow + adHocAllow;
            decimal grossPay    = basicPay + totalAllow;
            decimal nssf        = Math.Round(basicPay * cfg.NssfEmployeeRate / 100, 0);
            decimal kabaka      = cfg.ChargeKabaka   ? Math.Round(basicPay * cfg.KabakaRate   / 100, 0) : 0m;
            decimal localTax    = cfg.ChargeLocalTax ? Math.Round(basicPay * cfg.LocalTaxRate  / 100, 0) : 0m;
            decimal paye        = CalculatePAYE(grossPay - nssf, cfg);
            decimal totalDed    = paye + nssf + kabaka + localTax + stdDed + adHocDed;
            decimal netSalary   = Math.Max(0, grossPay - totalDed);

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
                    (@pid,@eid,@yr,@mo,@moname,
                     @basic,@gross,@totAllow,@allowAmt,@allowDet,
                     @totDed,@dedAmt,@dedDet,
                     @paye,@nssf,@kabaka,@lt,@net,
                     'PENDING',NOW())",
                new MySqlParameter("@pid",      payrollID),
                new MySqlParameter("@eid",      empID),
                new MySqlParameter("@yr",       payrollYear),
                new MySqlParameter("@mo",       payrollMonth),
                new MySqlParameter("@moname",   monthName),
                new MySqlParameter("@basic",    basicPay),
                new MySqlParameter("@gross",    grossPay),
                new MySqlParameter("@totAllow", totalAllow),
                new MySqlParameter("@allowAmt", adHocAllow),
                new MySqlParameter("@allowDet", string.Join("|", allowDetails)),
                new MySqlParameter("@totDed",   totalDed),
                new MySqlParameter("@dedAmt",   adHocDed),
                new MySqlParameter("@dedDet",   string.Join("|", dedDetails)),
                new MySqlParameter("@paye",     paye),
                new MySqlParameter("@nssf",     nssf),
                new MySqlParameter("@kabaka",   kabaka),
                new MySqlParameter("@lt",       localTax),
                new MySqlParameter("@net",      netSalary));

            // Write to legacy hrm_payroll_details for backward compatibility
            WriteLegacyDetailValues(payrollID, empID, basicPay, totalAllow, grossPay,
                                    paye, nssf, totalDed, netSalary);

            // Settle ad-hoc records
            SettleAdHocRecords(payrollID, empID, monthName, payrollYear, inclAllow, inclDed);
        }

        ExecuteNonQuery("UPDATE hrm_payroll SET total_amount = @total WHERE ID = @pid",
            new MySqlParameter("@total", totalNet),
            new MySqlParameter("@pid",   payrollID));
    }

    private static void WriteLegacyDetail(int payrollID, int empID, DataRow ap)
    {
        WriteLegacyDetailValues(payrollID, empID,
            SafeDecimal(ap["basic_pay"]),
            SafeDecimal(ap["total_allowances"]),
            SafeDecimal(ap["gross_salary"]),
            SafeDecimal(ap["paye"]),
            SafeDecimal(ap["nssf"]),
            SafeDecimal(ap["total_deductions"]),
            SafeDecimal(ap["net_salary"]));
    }

    private static void WriteLegacyDetailValues(int payrollID, int empID,
        decimal basic, decimal allow, decimal gross,
        decimal paye,  decimal nssf,  decimal ded, decimal net)
    {
        try
        {
            ExecuteNonQuery(@"
                INSERT INTO hrm_payroll_details
                    (payrollID, empID, basic_pay, paye, nssf, total_allowances,
                     total_deductions, gross_pay, net_pay)
                VALUES (@pid,@eid,@basic,@paye,@nssf,@allow,@ded,@gross,@net)",
                new MySqlParameter("@pid",   payrollID),
                new MySqlParameter("@eid",   empID),
                new MySqlParameter("@basic", basic),
                new MySqlParameter("@paye",  paye),
                new MySqlParameter("@nssf",  nssf),
                new MySqlParameter("@allow", allow),
                new MySqlParameter("@ded",   ded),
                new MySqlParameter("@gross", gross),
                new MySqlParameter("@net",   net));
        }
        catch { /* non-critical */ }
    }

    private static void SettleAdHocRecords(int payrollID, int empID,
        string monthName, int year, bool inclAllow, bool inclDed)
    {
        if (string.IsNullOrEmpty(monthName)) return;
        if (inclAllow)
        {
            try
            {
                ExecuteNonQuery(@"
                    UPDATE hrm_allowance_records
                    SET status = 'SETTLED', payment_date = NOW(), payroll_id = @pid
                    WHERE empID = @eid AND to_add_month = @month
                      AND to_add_year = @year AND status = 'PENDING'",
                    new MySqlParameter("@pid",   payrollID),
                    new MySqlParameter("@eid",   empID),
                    new MySqlParameter("@month", monthName),
                    new MySqlParameter("@year",  year));
            }
            catch { }
        }
        if (inclDed)
        {
            try
            {
                ExecuteNonQuery(@"
                    UPDATE hrm_deduction_records
                    SET status = 'SETTLED', payment_date = NOW(), payroll_id = @pid
                    WHERE empID = @eid AND to_deduct_month = @month
                      AND to_deduct_year = @year AND status = 'PENDING'",
                    new MySqlParameter("@pid",   payrollID),
                    new MySqlParameter("@eid",   empID),
                    new MySqlParameter("@month", monthName),
                    new MySqlParameter("@year",  year));
            }
            catch { }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Lifecycle: Approve / Cancel / Delete
    // ─────────────────────────────────────────────────────────────────

    /// <returns>null on success; error message on failure.</returns>
    public static string ApprovePayroll(int payrollID, string approvedBy)
    {
        try
        {
            DataTable dtS = ExecuteQuery("SELECT payroll_status FROM hrm_payroll WHERE ID = @id",
                new MySqlParameter("@id", payrollID));
            if (dtS.Rows.Count == 0) return "Payroll not found.";
            if (dtS.Rows[0]["payroll_status"].ToString() != "PENDING")
                return "Only PENDING payrolls can be approved.";

            DataTable dtU = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id = @id AND status != 'APPROVED'",
                new MySqlParameter("@id", payrollID));
            int unapproved = dtU.Rows.Count > 0 ? SafeInt(dtU.Rows[0]["cnt"]) : 0;
            if (unapproved > 0)
                return unapproved + " payslip(s) not yet approved. Review all payslips first.";

            DataTable dtC = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id = @id",
                new MySqlParameter("@id", payrollID));
            if (SafeInt(dtC.Rows[0]["cnt"]) == 0)
                return "No payslips generated. Process the payroll first.";

            ExecuteNonQuery(@"
                UPDATE hrm_payroll
                SET payroll_status = 'PROCESSED', lockStatus = 'LOCKED',
                    date_processed = NOW(), processed_by = @user
                WHERE ID = @id",
                new MySqlParameter("@user", approvedBy),
                new MySqlParameter("@id",   payrollID));
            return null;
        }
        catch (Exception ex) { return "Error: " + ex.Message; }
    }

    /// <returns>null on success; error message on failure.</returns>
    public static string CancelPayroll(int payrollID)
    {
        try
        {
            DataTable dtS = ExecuteQuery("SELECT payroll_status FROM hrm_payroll WHERE ID = @id",
                new MySqlParameter("@id", payrollID));
            if (dtS.Rows.Count == 0) return "Payroll not found.";
            if (dtS.Rows[0]["payroll_status"].ToString() != "PENDING")
                return "Only PENDING payrolls can be cancelled.";

            ExecuteNonQuery(
                "UPDATE hrm_payroll SET payroll_status = 'CANCELLED' WHERE ID = @id AND payroll_status = 'PENDING'",
                new MySqlParameter("@id", payrollID));
            return null;
        }
        catch (Exception ex) { return "Error: " + ex.Message; }
    }

    /// <returns>null on success; error/info message on failure or partial delete.</returns>
    public static string DeletePayroll(int payrollID)
    {
        try
        {
            DataTable dtS = ExecuteQuery("SELECT payroll_status FROM hrm_payroll WHERE ID = @id",
                new MySqlParameter("@id", payrollID));
            if (dtS.Rows.Count == 0) return "Payroll not found.";
            if (dtS.Rows[0]["payroll_status"].ToString() != "PENDING")
                return "Only PENDING payrolls can be deleted.";

            ExecuteNonQuery(
                "DELETE FROM hrm_payslips WHERE payroll_id = @id AND status != 'APPROVED'",
                new MySqlParameter("@id", payrollID));
            try { ExecuteNonQuery("DELETE FROM hrm_payroll_details WHERE payrollID = @id",
                      new MySqlParameter("@id", payrollID)); } catch { }

            DataTable dtR = ExecuteQuery(
                "SELECT COUNT(*) AS cnt FROM hrm_payslips WHERE payroll_id = @id",
                new MySqlParameter("@id", payrollID));
            int remaining = dtR.Rows.Count > 0 ? SafeInt(dtR.Rows[0]["cnt"]) : 0;

            if (remaining == 0)
            {
                ExecuteNonQuery("DELETE FROM hrm_payroll WHERE ID = @id",
                    new MySqlParameter("@id", payrollID));
                return null;
            }
            return remaining + " approved payslip(s) remain — payroll header preserved.";
        }
        catch (Exception ex) { return "Error: " + ex.Message; }
    }

    // ─────────────────────────────────────────────────────────────────
    // Manual payslip adjustment (called from details grid row update)
    // ─────────────────────────────────────────────────────────────────

    /// <summary>
    /// Manually override computed values for a single non-approved payslip.
    /// Gross and net are recalculated from the supplied figures to keep them consistent.
    /// </summary>
    public static void AdjustPayslip(int payslipID,
        decimal basicPay, decimal totalAllowances,
        decimal paye, decimal nssf, decimal kabaka, decimal localTax,
        decimal totalDeductions, decimal netSalary)
    {
        decimal gross = basicPay + totalAllowances;
        ExecuteNonQuery(@"
            UPDATE hrm_payslips
            SET basic_pay = @basic, total_allowances = @allow, gross_salary = @gross,
                paye = @paye, nssf = @nssf, kabaka_contribution = @kabaka, local_tax = @lt,
                total_deductions = @ded, net_salary = @net
            WHERE ID = @id AND status != 'APPROVED'",
            new MySqlParameter("@basic", basicPay),
            new MySqlParameter("@allow", totalAllowances),
            new MySqlParameter("@gross", gross),
            new MySqlParameter("@paye",  paye),
            new MySqlParameter("@nssf",  nssf),
            new MySqlParameter("@kabaka",kabaka),
            new MySqlParameter("@lt",    localTax),
            new MySqlParameter("@ded",   totalDeductions),
            new MySqlParameter("@net",   netSalary),
            new MySqlParameter("@id",    payslipID));
    }
}
