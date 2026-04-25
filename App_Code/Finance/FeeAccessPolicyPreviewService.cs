using System;
using System.Collections.Generic;
using System.Data;

public class FeeAccessPolicyPreviewService
{
    public FeeAccessPreviewResult Run(FeeAccessPolicyConfig policy)
    {
        FeeAccessPreviewResult result = new FeeAccessPreviewResult();

        if (policy == null)
        {
            result.Message = "No saved policy found. Please complete Steps 1 and 2 first.";
            return result;
        }

        if (!policy.IsActive)
        {
            result.Message = "The policy is currently disabled. Enable it in Step 1 to enforce rules.";
            return result;
        }

        int enabledCount = 0;
        if (policy.RuleMinBalanceEnabled) enabledCount++;
        if (policy.RulePaymentWindowEnabled) enabledCount++;
        if (policy.RulePctPaidEnabled) enabledCount++;
        if (policy.RuleRequireRegistration) enabledCount++;
        if (enabledCount == 0 && !policy.RuleBursaryExempt)
        {
            result.Message = "No rules are enabled. All students would be allowed access.";
            return result;
        }

        DataTable dtFin = FinanceDB.ExecuteDataTable(@"
            SELECT fl.accountcode AS regno,
                   COALESCE(SUM(CASE WHEN fl.transactionType='DR' THEN fl.transaction_amount ELSE 0 END),0) AS total_bill,
                   COALESCE(SUM(CASE WHEN fl.transactionType='CR' THEN fl.transaction_amount ELSE 0 END),0) AS total_paid
            FROM fin_ledger fl
            WHERE fl.transaction_amount > 0
            GROUP BY fl.accountcode");

        if (dtFin.Rows.Count == 0)
        {
            result.Message = "No students found with financial data in fin_ledger.";
            return result;
        }

        Dictionary<string, decimal> windowPaid = new Dictionary<string, decimal>(StringComparer.OrdinalIgnoreCase);
        if (policy.RulePaymentWindowEnabled && policy.RulePaymentWindowStart.HasValue && policy.RulePaymentWindowEnd.HasValue)
        {
            DataTable dtWin = FinanceDB.ExecuteDataTable(@"
                SELECT accountcode, SUM(transaction_amount) AS wpaid
                FROM fin_ledger
                WHERE transactionType='CR'
                  AND transaction_amount > 0
                  AND transactionDate >= @s
                  AND transactionDate <= @e
                GROUP BY accountcode",
                FinanceDB.P("@s", policy.RulePaymentWindowStart.Value),
                FinanceDB.P("@e", policy.RulePaymentWindowEnd.Value));

            foreach (DataRow row in dtWin.Rows)
                windowPaid[row["accountcode"].ToString()] = SafeDec(row["wpaid"]);
        }

        HashSet<string> bursaryStudents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (policy.RuleBursaryExempt)
        {
            DataTable dtBur = FinanceDB.ExecuteDataTable(FinanceDB.MainConnStr, @"
                SELECT adm_no, COALESCE(amount_offered,0) AS offered, COALESCE(total_fees,0) AS fees
                FROM scholarshipstudents
                WHERE status = 'Approved' AND amount_offered > 0");

            foreach (DataRow row in dtBur.Rows)
            {
                decimal offered = SafeDec(row["offered"]);
                decimal fees = SafeDec(row["fees"]);
                if (fees > 0 && ((offered / fees) * 100) >= policy.RuleBursaryMinCoverage)
                    bursaryStudents.Add(row["adm_no"].ToString());
            }
        }

        HashSet<string> registered = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (policy.RuleRequireRegistration)
        {
            DataTable dtReg = FinanceDB.ExecuteDataTable(FinanceDB.MainConnStr, @"
                SELECT DISTINCT regno
                FROM acad_registration
                WHERE acad_year = @ay AND semester = @sem AND regstatus = 'Registered'",
                FinanceDB.P("@ay", policy.AcademicYear),
                FinanceDB.P("@sem", policy.Semester));

            foreach (DataRow row in dtReg.Rows)
                registered.Add(row["regno"].ToString());
        }

        result.TotalStudents = dtFin.Rows.Count;

        foreach (DataRow row in dtFin.Rows)
        {
            string regno = row["regno"].ToString();
            decimal bill = SafeDec(row["total_bill"]);
            decimal paid = SafeDec(row["total_paid"]);
            decimal balance = bill - paid;

            if (policy.RuleBursaryExempt && bursaryStudents.Contains(regno))
            {
                result.AllowedStudents++;
                continue;
            }

            List<bool> checks = new List<bool>();
            if (policy.RuleMinBalanceEnabled) checks.Add(balance <= policy.RuleMinBalanceAmount);
            if (policy.RulePaymentWindowEnabled)
            {
                decimal wpaid = 0;
                if (windowPaid.ContainsKey(regno)) wpaid = windowPaid[regno];
                checks.Add(wpaid >= policy.RulePaymentMinAmount);
            }
            if (policy.RulePctPaidEnabled)
            {
                decimal pct = bill > 0 ? ((paid / bill) * 100) : 100;
                checks.Add(pct >= policy.RulePctPaidMinimum);
            }
            if (policy.RuleRequireRegistration) checks.Add(registered.Contains(regno));

            bool pass = true;
            if (checks.Count > 0)
            {
                if ((policy.RuleLogic ?? "ALL").ToUpper() == "ANY")
                    pass = checks.Contains(true);
                else
                    pass = !checks.Contains(false);
            }

            if (pass) result.AllowedStudents++;
            else result.DeniedStudents++;
        }

        result.Success = true;
        return result;
    }

    private static decimal SafeDec(object value)
    {
        if (value == null || value == DBNull.Value) return 0;
        decimal d;
        return decimal.TryParse(value.ToString(), out d) ? d : 0;
    }
}
