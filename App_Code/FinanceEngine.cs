using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// FinanceEngine — THE single source of truth for all student financial computations.
///
/// Every finance endpoint must use these methods. Defining balance, clearance, and
/// waiver logic here in one place eliminates the divergence bugs that arise when the
/// same UNION ALL query is copy-pasted into multiple handlers.
///
/// Design contract:
///   • GetDualLedger()        → raw ordered ledger entries (full history)
///   • SummariseLedger()      → totals from an already-fetched ledger (no extra DB hit)
///   • ComputePeriodBalance() → period-filtered totals direct from DB (for bulk ops)
///   • GetWaiverTotal()       → sum of active waiver amounts
///   • HasFinancialLock()     → studLock flag from acad_student
///   • GetClearanceStatus()   → "cleared" / "partial" / "not_cleared" / "no_bill"
/// </summary>
public static class FinanceEngine
{
    public const string CURRENCY = "UGX";

    // ═══════════════════════════════════════════════════════════════════
    //  CANONICAL DUAL-SOURCE LEDGER SQL
    //  This is the ONLY authoritative definition of the dual-ledger query.
    //  All handlers call GetDualLedger() or ComputePeriodBalance() — never
    //  copy this SQL inline.
    // ═══════════════════════════════════════════════════════════════════

    private static readonly string DUAL_LEDGER_SQL =
        "SELECT " +
        "  DATE(fl.transactionDate)                                            AS trans_date, " +
        "  CASE WHEN fl.transactionType='DR' THEN fl.transaction_amount ELSE 0 END AS debit, " +
        "  CASE WHEN fl.transactionType='CR' THEN fl.transaction_amount ELSE 0 END AS credit, " +
        "  COALESCE(fl.particulars, '')                                        AS detail, " +
        "  ''                                                                  AS acad_year, " +
        "  ''                                                                  AS semester, " +
        "  'GL' AS entry_source " +
        "FROM fin_ledger fl " +
        "WHERE fl.accountcode = @reg AND fl.transaction_amount > 0 " +
        "UNION ALL " +
        "SELECT " +
        "  DATE(t.trans_date)                                                  AS trans_date, " +
        "  CASE WHEN t.trans_type='Bill'    THEN t.amount ELSE 0 END           AS debit, " +
        "  CASE WHEN t.trans_type='Payment' THEN t.amount ELSE 0 END           AS credit, " +
        "  COALESCE(t.detail, '')                                              AS detail, " +
        "  COALESCE(t.acadyear, '')                                            AS acad_year, " +
        "  COALESCE(t.semester, '')                                            AS semester, " +
        "  'tracking' AS entry_source " +
        "FROM fin_studentfeestracking t " +
        "WHERE t.regno = @reg AND t.post_status = 'Posted' " +
        "  AND NOT EXISTS ( " +
        "    SELECT 1 FROM fin_ledger fl2 " +
        "    WHERE fl2.accountcode = t.regno " +
        "      AND ( " +
        "        fl2.voucherNo = CAST(t.TID AS CHAR) " +
        "        OR fl2.folio  = CONCAT('BillNo:', CAST(t.TID AS CHAR)) " +
        "        OR ( " +
        "          fl2.transaction_amount = t.amount " +
        "          AND DATE(fl2.transactionDate) = DATE(t.trans_date) " +
        "          AND fl2.transactionType = CASE WHEN t.trans_type='Payment' THEN 'CR' ELSE 'DR' END " +
        "          AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = '') " +
        "        ) " +
        "      ) " +
        "  ) " +
        "ORDER BY trans_date ASC, entry_source ASC, detail ASC";

    // ═══════════════════════════════════════════════════════════════════
    //  LEDGER RETRIEVAL
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns the full chronological dual-source ledger for a student.
    /// Combines fin_ledger (GL) and fin_studentfeestracking with deduplication.
    /// Only Posted entries are included. Ordered by date ascending.
    /// </summary>
    public static DataTable GetDualLedger(string regno)
    {
        return ApiHelper.QueryAccounts(DUAL_LEDGER_SQL,
            new MySqlParameter("@reg", regno));
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SUMMARISE AN ALREADY-FETCHED LEDGER
    //  Use when the caller already has the full ledger DataTable and wants
    //  totals without an extra round-trip to the DB.
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Computes FinancialSummary from a ledger DataTable returned by GetDualLedger().
    /// Pass acadYear / semester to annotate the result — does not filter rows.
    /// </summary>
    public static FinancialSummary SummariseLedger(DataTable dt,
        string acadYear = "", string semester = "")
    {
        decimal totalCharges = 0, totalPayments = 0;
        string  lastPayDate  = "";

        foreach (DataRow row in dt.Rows)
        {
            decimal d = 0, c = 0;
            if (row["debit"]  != DBNull.Value) decimal.TryParse(row["debit"].ToString(),  out d);
            if (row["credit"] != DBNull.Value) decimal.TryParse(row["credit"].ToString(), out c);
            totalCharges  += d;
            totalPayments += c;
            if (c > 0 && row["trans_date"] != DBNull.Value)
                lastPayDate = Convert.ToDateTime(row["trans_date"]).ToString("yyyy-MM-dd");
        }

        return BuildSummary(totalCharges, totalPayments, lastPayDate, acadYear, semester);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PERIOD-FILTERED AGGREGATE BALANCE
    //  Runs a single aggregation SQL against the DB — more efficient than
    //  fetching the full ledger when only totals are needed (e.g. bulk ops).
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Computes the student's balance for a specific period (or all-time if both empty).
    /// Uses the same UNION ALL deduplication as GetDualLedger — results are always consistent.
    /// </summary>
    public static FinancialSummary ComputePeriodBalance(string regno,
        string acadYear = "", string semester = "")
    {
        bool filterYear = !string.IsNullOrEmpty(acadYear);
        bool filterSem  = !string.IsNullOrEmpty(semester);

        string sql;
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@reg", regno));

        if (filterYear)
        {
            // fin_ledger has no acadYear/semester columns — period queries use
            // fin_studentfeestracking only (which is the primary billing record store).
            // No cross-source deduplication needed when not mixing sources.
            parms.Add(new MySqlParameter("@ay", acadYear));
            if (filterSem) parms.Add(new MySqlParameter("@sem", semester));

            sql =
                "SELECT COALESCE(SUM(CASE WHEN trans_type='Bill'    THEN amount ELSE 0 END), 0) AS total_charges, " +
                "       COALESCE(SUM(CASE WHEN trans_type='Payment' THEN amount ELSE 0 END), 0) AS total_payments, " +
                "       MAX(CASE WHEN trans_type='Payment' THEN trans_date ELSE NULL END)        AS last_payment_date " +
                "FROM fin_studentfeestracking " +
                "WHERE regno = @reg AND post_status = 'Posted' " +
                " AND COALESCE(acadyear,'') = @ay " +
                (filterSem ? " AND COALESCE(semester,'') = @sem " : "");
        }
        else
        {
            // All-time: full dual-source query with deduplication
            sql =
                "SELECT COALESCE(SUM(dr), 0) AS total_charges, " +
                "       COALESCE(SUM(cr), 0) AS total_payments, " +
                "       MAX(pay_date)        AS last_payment_date " +
                "FROM ( " +
                "  SELECT CASE WHEN transactionType='DR' THEN transaction_amount ELSE 0 END AS dr, " +
                "         CASE WHEN transactionType='CR' THEN transaction_amount ELSE 0 END AS cr, " +
                "         CASE WHEN transactionType='CR' THEN transactionDate    ELSE NULL END AS pay_date " +
                "  FROM fin_ledger " +
                "  WHERE accountcode = @reg AND transaction_amount > 0 " +
                "  UNION ALL " +
                "  SELECT CASE WHEN trans_type='Bill'    THEN amount ELSE 0 END AS dr, " +
                "         CASE WHEN trans_type='Payment' THEN amount ELSE 0 END AS cr, " +
                "         CASE WHEN trans_type='Payment' THEN trans_date ELSE NULL END AS pay_date " +
                "  FROM fin_studentfeestracking t " +
                "  WHERE regno = @reg AND post_status = 'Posted' " +
                "    AND NOT EXISTS ( " +
                "      SELECT 1 FROM fin_ledger fl2 " +
                "      WHERE fl2.accountcode = t.regno " +
                "        AND (fl2.voucherNo = CAST(t.TID AS CHAR) " +
                "          OR fl2.folio = CONCAT('BillNo:', CAST(t.TID AS CHAR)) " +
                "          OR (fl2.transaction_amount = t.amount " +
                "              AND DATE(fl2.transactionDate) = DATE(t.trans_date) " +
                "              AND fl2.transactionType = CASE WHEN t.trans_type='Payment' THEN 'CR' ELSE 'DR' END " +
                "              AND (fl2.particulars = t.detail OR t.detail IS NULL OR t.detail = ''))) " +
                "    ) " +
                ") AS combined";
        }

        DataTable dt = ApiHelper.QueryAccounts(sql, parms.ToArray());

        decimal totalCharges = 0, totalPayments = 0;
        string  lastPayDate  = "";
        if (dt.Rows.Count > 0)
        {
            decimal.TryParse(dt.Rows[0]["total_charges"].ToString(),  out totalCharges);
            decimal.TryParse(dt.Rows[0]["total_payments"].ToString(), out totalPayments);
            if (dt.Rows[0]["last_payment_date"] != DBNull.Value)
                lastPayDate = Convert.ToDateTime(dt.Rows[0]["last_payment_date"]).ToString("yyyy-MM-dd");
        }

        return BuildSummary(totalCharges, totalPayments, lastPayDate, acadYear, semester);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  WAIVERS
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>Total active waiver amount for a student (all time).</summary>
    public static decimal GetWaiverTotal(string regno)
    {
        try
        {
            DataTable dt = ApiHelper.QueryAccounts(
                "SELECT COALESCE(SUM(wi.waived_amount), 0) AS total " +
                "FROM fin_bill_waiver_items wi " +
                "INNER JOIN fin_bill_waivers w ON w.waiver_id = wi.waiver_id " +
                "WHERE w.regno = @reg AND w.status = 'Active'",
                new MySqlParameter("@reg", regno));
            if (dt.Rows.Count > 0)
            {
                decimal v;
                if (decimal.TryParse(dt.Rows[0]["total"].ToString(), out v)) return v;
            }
        }
        catch { /* table may not exist on all deployments */ }
        return 0;
    }

    /// <summary>
    /// Sum of waived amounts for active waivers that have NOT yet been posted as ledger credits.
    /// Use this for effective_balance — posted waiver credits are already in the ledger totals.
    /// </summary>
    public static decimal GetUnpostedWaiverTotal(string regno)
    {
        try
        {
            DataTable dt = ApiHelper.QueryAccounts(
                "SELECT COALESCE(SUM(wi.waived_amount), 0) AS total " +
                "FROM fin_bill_waiver_items wi " +
                "INNER JOIN fin_bill_waivers w ON w.waiver_id = wi.waiver_id " +
                "WHERE w.regno = @reg AND w.status = 'Active' " +
                "  AND w.credit_tid IS NULL AND w.credit_gl_tid IS NULL",
                new MySqlParameter("@reg", regno));
            if (dt.Rows.Count > 0)
            {
                decimal v;
                if (decimal.TryParse(dt.Rows[0]["total"].ToString(), out v)) return v;
            }
        }
        catch { }
        return 0;
    }

    /// <summary>Count of active waivers for a student.</summary>
    public static int GetWaiverCount(string regno)
    {
        try
        {
            object o = ApiHelper.QueryAccounts(
                "SELECT COUNT(*) FROM fin_bill_waivers WHERE regno = @reg AND status = 'Active'",
                new MySqlParameter("@reg", regno)).Rows.Count > 0
                ? ApiHelper.QueryAccounts("SELECT COUNT(*) AS c FROM fin_bill_waivers WHERE regno = @reg AND status = 'Active'",
                    new MySqlParameter("@reg", regno)).Rows[0]["c"]
                : 0;
            int n; int.TryParse(o.ToString(), out n); return n;
        }
        catch { return 0; }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  FINANCIAL LOCK
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>True if the student's account has a financial hold (studLock).</summary>
    public static bool HasFinancialLock(string regno)
    {
        try
        {
            DataTable dt = ApiHelper.Query(
                "SELECT studLock FROM acad_student WHERE regno = @reg LIMIT 1",
                new MySqlParameter("@reg", regno));
            if (dt.Rows.Count > 0)
            {
                string lv = Convert.ToString(dt.Rows[0]["studLock"]).ToLower();
                return lv == "1" || lv == "true" || lv == "yes" || lv == "locked";
            }
        }
        catch { }
        return false;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CLEARANCE STATUS (static helper — no DB hit)
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Derive clearance status from totals.
    /// Returns: "cleared" | "partial" | "not_cleared" | "no_bill"
    /// </summary>
    public static string GetClearanceStatus(decimal totalFees, decimal amountPaid)
    {
        decimal balance = totalFees - amountPaid;
        if (totalFees == 0 && amountPaid == 0) return "no_bill";
        if (balance <= 0)                      return "cleared";
        if (amountPaid > 0)                    return "partial";
        return "not_cleared";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  INTERNAL BUILDER
    // ═══════════════════════════════════════════════════════════════════

    private static FinancialSummary BuildSummary(decimal totalCharges, decimal totalPayments,
        string lastPayDate, string acadYear, string semester)
    {
        decimal balance = totalCharges - totalPayments;
        decimal pctPaid = totalCharges > 0
            ? Math.Round(totalPayments / totalCharges * 100, 1)
            : (totalPayments > 0 ? 100m : 0m);

        return new FinancialSummary
        {
            TotalCharges    = totalCharges,
            TotalPayments   = totalPayments,
            Balance         = balance,
            AmountOwing     = balance > 0 ? balance : 0,
            CreditBalance   = balance < 0 ? Math.Abs(balance) : 0,
            LastPaymentDate = lastPayDate,
            ClearanceStatus = GetClearanceStatus(totalCharges, totalPayments),
            PercentagePaid  = pctPaid,
            Currency        = CURRENCY,
            AcadYear        = acadYear,
            Semester        = semester
        };
    }

    // ═══════════════════════════════════════════════════════════════════
    //  IN-PROCESS ACCESS POLICY EVALUATION
    //  Called directly by doc_verification.aspx — no HTTP loopback.
    //  Returns the same data structure as the finance API access_status
    //  endpoint so callers can use identical parsing logic.
    // ═══════════════════════════════════════════════════════════════════

    public static Dictionary<string, object> EvaluateAccessPolicy(string regno)
    {
        DataTable dtPolicy;
        try { dtPolicy = ApiHelper.QueryAccounts("SELECT * FROM fin_fee_access_policy WHERE is_active = 'yes' ORDER BY updated_at DESC, policy_id DESC LIMIT 1"); }
        catch { dtPolicy = new DataTable(); }

        if (dtPolicy.Rows.Count == 0)
        {
            return new Dictionary<string, object>
            {
                { "access_allowed", true  }, { "has_policy", false }, { "verdict", "granted" },
                { "verdict_reason", "No active fee access policy. All students are granted full access." },
                { "policy",   null },
                { "finance",  new Dictionary<string, object> { { "total_bill", 0m }, { "total_paid", 0m }, { "balance", 0m }, { "amount_owing", 0m }, { "credit_balance", 0m }, { "percentage_paid", 0m }, { "currency", CURRENCY } } },
                { "criteria", new List<Dictionary<string, object>>() },
                { "guidance", "No active fee access restrictions." }
            };
        }

        DataRow pol          = dtPolicy.Rows[0];
        string  acadYear     = FeSafeStr(pol, "academic_year");
        int     semester     = FeSafeInt(pol, "semester");
        string  logic        = FeSafeStr(pol, "rule_logic").ToUpper() == "ANY" ? "ANY" : "ALL";
        string  policyTitle  = FeSafeStr(pol, "policy_title");

        bool    balEnabled    = FeSafeStr(pol, "rule_min_balance_enabled")   == "yes";
        decimal balMax        = FeSafeDec(pol, "rule_min_balance_amount");
        bool    winEnabled    = FeSafeStr(pol, "rule_payment_window_enabled") == "yes";
        decimal winMinAmt     = FeSafeDec(pol, "rule_payment_min_amount");
        DateTime? winStart    = FeSafeDate(pol, "rule_payment_window_start");
        DateTime? winEnd      = FeSafeDate(pol, "rule_payment_window_end");
        bool    pctEnabled    = FeSafeStr(pol, "rule_pct_paid_enabled")      == "yes";
        decimal pctMin        = FeSafeDec(pol, "rule_pct_paid_minimum");
        bool    bursaryExempt = FeSafeStr(pol, "rule_bursary_exempt")        == "yes";
        decimal bursaryMinCov = FeSafeDec(pol, "rule_bursary_min_coverage");
        bool    regRequired   = FeSafeStr(pol, "rule_require_registration")  == "yes";

        var policyConfig = new Dictionary<string, object>
        {
            { "title", policyTitle }, { "academic_year", acadYear },
            { "semester", semester }, { "combination_logic", logic }
        };

        FinancialSummary finSummary = ComputePeriodBalance(regno);
        decimal totalBill  = finSummary.TotalCharges;
        decimal totalPaid  = finSummary.TotalPayments;
        decimal balance2   = finSummary.Balance;
        decimal pctPaidAll = finSummary.PercentagePaid;

        var financeData = new Dictionary<string, object>
        {
            { "total_bill",      totalBill              },
            { "total_paid",      totalPaid              },
            { "balance",         -balance2              },
            { "amount_owing",    finSummary.AmountOwing  },
            { "credit_balance",  finSummary.CreditBalance},
            { "percentage_paid", pctPaidAll             },
            { "currency",        CURRENCY               }
        };

        var  criteria           = new List<Dictionary<string, object>>();
        bool bursaryShortCircuit = false;
        string bursarySchemeName = "";

        if (bursaryExempt)
        {
            DataTable dtBur = ApiHelper.QueryAccounts(
                "SELECT ss.amount_offered, s.scholarshipName FROM scholarshipstudents ss " +
                "JOIN scholarships s ON s.scholarshipID = ss.scholarshipID " +
                "WHERE ss.adm_no = @reg AND ss.scholarhipYear = @ay AND ss.scholarhipTerm = @sem AND ss.status = 'Approved' LIMIT 1",
                new MySqlParameter("@reg", regno),
                new MySqlParameter("@ay",  acadYear),
                new MySqlParameter("@sem", semester));

            if (dtBur.Rows.Count > 0)
            {
                decimal bursaryOffered = Convert.ToDecimal(dtBur.Rows[0]["amount_offered"]);
                bursarySchemeName = dtBur.Rows[0]["scholarshipName"] != null ? dtBur.Rows[0]["scholarshipName"].ToString() : "Scholarship";
                decimal bursaryCoverage = totalBill > 0 ? Math.Round(bursaryOffered / totalBill * 100, 1) : 100;
                bool bursaryPass = bursaryCoverage >= bursaryMinCov;
                if (bursaryPass) bursaryShortCircuit = true;
                criteria.Add(new Dictionary<string, object> {
                    { "rule", "Bursary Exemption" }, { "passed", bursaryPass }, { "enabled", true },
                    { "detail", bursaryPass ? string.Format("Bursary ({0}) with {1:F0}% coverage — exempt.", bursarySchemeName, bursaryCoverage) : string.Format("Bursary coverage {0:F0}% below required {1:F0}%.", bursaryCoverage, bursaryMinCov) },
                    { "threshold", string.Format("Min {0:F0}%", bursaryMinCov) }, { "actual_value", string.Format("{0:F0}%", bursaryCoverage) }
                });
            }
            else
            {
                criteria.Add(new Dictionary<string, object> {
                    { "rule", "Bursary Exemption" }, { "passed", false }, { "enabled", true },
                    { "detail", string.Format("No approved bursary for {0} Sem {1}.", acadYear, semester) },
                    { "threshold", string.Format("Min {0:F0}%", bursaryMinCov) }, { "actual_value", "No bursary" }
                });
            }
        }

        if (!bursaryShortCircuit)
        {
            if (balEnabled)
            {
                bool pass = balance2 <= balMax;
                criteria.Add(new Dictionary<string, object> {
                    { "rule", "Balance Threshold" }, { "passed", pass }, { "enabled", true },
                    { "detail", pass ? string.Format("Balance {0:N0} within allowed {1:N0}.", balance2, balMax) : string.Format("Balance {0:N0} exceeds allowed {1:N0}.", balance2, balMax) },
                    { "threshold", string.Format("Max UGX {0:N0}", balMax) }, { "actual_value", string.Format("UGX {0:N0}", balance2) }
                });
            }
            if (winEnabled && winStart.HasValue && winEnd.HasValue)
            {
                DataTable dtWin = ApiHelper.QueryAccounts(
                    "SELECT COALESCE(SUM(fl.transaction_amount), 0) AS window_payments FROM fin_ledger fl " +
                    "WHERE fl.accountcode = @reg AND fl.transactionType = 'CR' AND fl.transaction_amount > 0 " +
                    "  AND fl.transactionDate >= @ws AND fl.transactionDate <= @we",
                    new MySqlParameter("@reg", regno),
                    new MySqlParameter("@ws",  winStart.Value),
                    new MySqlParameter("@we",  winEnd.Value));
                decimal wp = dtWin.Rows.Count > 0 ? Convert.ToDecimal(dtWin.Rows[0]["window_payments"]) : 0;
                bool pass = wp >= winMinAmt;
                criteria.Add(new Dictionary<string, object> {
                    { "rule", "Payment Window" }, { "passed", pass }, { "enabled", true },
                    { "detail", pass ? string.Format("Paid {0:N0} in window (required {1:N0}).", wp, winMinAmt) : string.Format("Only paid {0:N0} in window (required {1:N0}).", wp, winMinAmt) },
                    { "threshold", string.Format("Min UGX {0:N0} between {1:yyyy-MM-dd} and {2:yyyy-MM-dd}", winMinAmt, winStart.Value, winEnd.Value) },
                    { "actual_value", string.Format("UGX {0:N0}", wp) }
                });
            }
            if (pctEnabled)
            {
                decimal pct = totalBill > 0 ? Math.Round(totalPaid / totalBill * 100, 1) : 100;
                bool pass = pct >= pctMin;
                criteria.Add(new Dictionary<string, object> {
                    { "rule", "Percentage Paid" }, { "passed", pass }, { "enabled", true },
                    { "detail", pass ? string.Format("{0:F1}% paid (required {1:F0}%).", pct, pctMin) : string.Format("Only {0:F1}% paid (required {1:F0}%).", pct, pctMin) },
                    { "threshold", string.Format("Min {0:F0}%", pctMin) }, { "actual_value", string.Format("{0:F1}%", pct) }
                });
            }
            if (regRequired)
            {
                DataTable dtReg = ApiHelper.Query(
                    "SELECT regno FROM acad_registration WHERE regno = @reg AND acad_year = @ay AND semester = @sem AND regstatus = 'Registered' LIMIT 1",
                    new MySqlParameter("@reg", regno),
                    new MySqlParameter("@ay",  acadYear),
                    new MySqlParameter("@sem", semester));
                bool pass = dtReg.Rows.Count > 0;
                criteria.Add(new Dictionary<string, object> {
                    { "rule", "Registration" }, { "passed", pass }, { "enabled", true },
                    { "detail", pass ? string.Format("Registered for {0} Sem {1}.", acadYear, semester) : string.Format("NOT registered for {0} Sem {1}.", acadYear, semester) },
                    { "threshold", string.Format("Registered for {0} Sem {1}", acadYear, semester) },
                    { "actual_value", pass ? "Registered" : "Not registered" }
                });
            }
        }

        bool allowed;
        if      (bursaryShortCircuit) allowed = true;
        else if (criteria.Count == 0) allowed = true;
        else if (logic == "ANY") { allowed = false; foreach (var cr in criteria) { if ((bool)cr["passed"]) { allowed = true; break; } } }
        else                     { allowed = true;  foreach (var cr in criteria) { if (!(bool)cr["passed"]) { allowed = false; break; } } }

        int rulesPassed = 0, rulesFailed = 0;
        foreach (var cr in criteria) { if ((bool)cr["passed"]) rulesPassed++; else rulesFailed++; }

        var tips = new List<string>();
        if (!allowed)
        {
            foreach (var cr in criteria)
            {
                if ((bool)cr["passed"]) continue;
                string rule = cr["rule"].ToString();
                if      (rule == "Balance Threshold") tips.Add(string.Format("Pay at least UGX {0:N0} to reduce balance to the allowed maximum.", Math.Max(0, balance2 - balMax)));
                else if (rule == "Payment Window" && winEnd.HasValue) tips.Add(string.Format("Make a payment of at least UGX {0:N0} before {1:yyyy-MM-dd}.", winMinAmt, winEnd.Value));
                else if (rule == "Percentage Paid") { decimal need = pctMin / 100 * totalBill - totalPaid; if (need > 0) tips.Add(string.Format("Pay an additional UGX {0:N0} to reach {1:F0}%.", need, pctMin)); }
                else if (rule == "Registration") tips.Add(string.Format("Complete registration for {0} Semester {1}.", acadYear, semester));
            }
        }

        string verdictReason;
        if      (bursaryShortCircuit) verdictReason = string.Format("Exempt via bursary ({0}).", bursarySchemeName);
        else if (criteria.Count == 0) verdictReason = "No rules enabled — all students pass by default.";
        else if (allowed && logic == "ANY") verdictReason = string.Format("{0}/{1} rule(s) passed. ANY logic.", rulesPassed, criteria.Count);
        else if (allowed)             verdictReason = string.Format("All {0} rule(s) passed.", criteria.Count);
        else if (logic == "ANY")      verdictReason = string.Format("0/{0} rules passed. ANY logic.", criteria.Count);
        else                          verdictReason = string.Format("{0}/{1} rule(s) failed. ALL logic.", rulesFailed, criteria.Count);

        return new Dictionary<string, object>
        {
            { "access_allowed",  allowed       },
            { "has_policy",      true          },
            { "verdict",         allowed ? "granted" : "denied" },
            { "verdict_reason",  verdictReason },
            { "policy",          policyConfig  },
            { "finance",         financeData   },
            { "criteria",        criteria      },
            { "guidance",        string.Join(" ", tips.ToArray()) }
        };
    }

    private static string   FeSafeStr(DataRow row, string col) { if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return ""; return row[col].ToString(); }
    private static int      FeSafeInt(DataRow row, string col) { if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return 0; int v; return int.TryParse(row[col].ToString(), out v) ? v : 0; }
    private static decimal  FeSafeDec(DataRow row, string col) { if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return 0; decimal v; return decimal.TryParse(row[col].ToString(), out v) ? v : 0; }
    private static DateTime? FeSafeDate(DataRow row, string col) { if (!row.Table.Columns.Contains(col) || row[col] == null || row[col] == DBNull.Value) return null; DateTime v; return DateTime.TryParse(row[col].ToString(), out v) ? v : (DateTime?)null; }
}

// ═══════════════════════════════════════════════════════════════════════
//  DATA TRANSFER OBJECT — FinancialSummary
// ═══════════════════════════════════════════════════════════════════════

/// <summary>
/// Structured result of a balance computation. Immutable by convention.
/// All finance endpoints that return balance data must use ToDictionary() to
/// ensure the JSON field names are consistent.
/// </summary>
public class FinancialSummary
{
    public decimal TotalCharges    { get; set; }
    public decimal TotalPayments   { get; set; }

    /// <summary>Positive = student owes money. Negative = student has a credit.</summary>
    public decimal Balance         { get; set; }

    /// <summary>Absolute amount owed (0 when student is clear or in credit).</summary>
    public decimal AmountOwing     { get; set; }

    /// <summary>Absolute credit balance (0 when student owes or is at zero).</summary>
    public decimal CreditBalance   { get; set; }

    public string  LastPaymentDate { get; set; }

    /// <summary>"cleared" | "partial" | "not_cleared" | "no_bill"</summary>
    public string  ClearanceStatus { get; set; }

    public decimal PercentagePaid  { get; set; }
    public string  Currency        { get; set; }
    public string  AcadYear        { get; set; }
    public string  Semester        { get; set; }

    /// <summary>
    /// Serialise to a dictionary for JSON output.
    /// All callers use this — field names are defined once here.
    /// </summary>
    public Dictionary<string, object> ToDictionary()
    {
        return new Dictionary<string, object>
        {
            { "total_charges",     TotalCharges    },
            { "total_payments",    TotalPayments   },
            { "balance",           Balance         },
            { "amount_owing",      AmountOwing     },
            { "credit_balance",    CreditBalance   },
            { "clearance_status",  ClearanceStatus },
            { "percentage_paid",   PercentagePaid  },
            { "last_payment_date", LastPaymentDate },
            { "currency",          Currency        }
        };
    }
}
