using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;

public class FeeAccessPolicyRepository
{
    public void EnsureSchema()
    {
        string ddl = @"CREATE TABLE IF NOT EXISTS fin_fee_access_policy (
            policy_id                    INT NOT NULL AUTO_INCREMENT,
            policy_title                 VARCHAR(200) NOT NULL DEFAULT 'Fee Access Policy',
            academic_year                VARCHAR(20) NULL,
            semester                     INT NULL,
            is_active                    VARCHAR(3) NOT NULL DEFAULT 'no',
            created_by                   VARCHAR(100) NULL,
            created_at                   DATETIME NULL,
            updated_by                   VARCHAR(100) NULL,
            updated_at                   DATETIME NULL,
            rule_min_balance_enabled     VARCHAR(3) NOT NULL DEFAULT 'no',
            rule_min_balance_amount      DECIMAL(15,2) NOT NULL DEFAULT 0,
            rule_payment_window_enabled  VARCHAR(3) NOT NULL DEFAULT 'no',
            rule_payment_min_amount      DECIMAL(15,2) NOT NULL DEFAULT 0,
            rule_payment_window_start    DATE NULL,
            rule_payment_window_end      DATE NULL,
            rule_pct_paid_enabled        VARCHAR(3) NOT NULL DEFAULT 'no',
            rule_pct_paid_minimum        DECIMAL(5,2) NOT NULL DEFAULT 0,
            rule_bursary_exempt          VARCHAR(3) NOT NULL DEFAULT 'no',
            rule_bursary_min_coverage    DECIMAL(5,2) NOT NULL DEFAULT 0,
            rule_require_registration    VARCHAR(3) NOT NULL DEFAULT 'no',
            rule_logic                   VARCHAR(10) NOT NULL DEFAULT 'ALL',
            policy_notes                 TEXT NULL,
            PRIMARY KEY (policy_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;";

        FinanceDB.ExecuteNonQuery(ddl);
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN academic_year VARCHAR(20) NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN semester INT NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN created_by VARCHAR(100) NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN created_at DATETIME NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN updated_by VARCHAR(100) NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN updated_at DATETIME NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_min_balance_enabled VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_min_balance_amount DECIMAL(15,2) NOT NULL DEFAULT 0");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_payment_window_enabled VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_payment_min_amount DECIMAL(15,2) NOT NULL DEFAULT 0");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_payment_window_start DATE NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_payment_window_end DATE NULL");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_pct_paid_enabled VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_pct_paid_minimum DECIMAL(5,2) NOT NULL DEFAULT 0");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_bursary_exempt VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_bursary_min_coverage DECIMAL(5,2) NOT NULL DEFAULT 0");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_require_registration VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN rule_logic VARCHAR(10) NOT NULL DEFAULT 'ALL'");
        TryAlter("ALTER TABLE fin_fee_access_policy ADD COLUMN policy_notes TEXT NULL");

        // Migrate boolean columns from TINYINT to VARCHAR(3) 'yes'/'no'
        TryAlter("ALTER TABLE fin_fee_access_policy MODIFY COLUMN is_active VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy MODIFY COLUMN rule_min_balance_enabled VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy MODIFY COLUMN rule_payment_window_enabled VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy MODIFY COLUMN rule_pct_paid_enabled VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy MODIFY COLUMN rule_bursary_exempt VARCHAR(3) NOT NULL DEFAULT 'no'");
        TryAlter("ALTER TABLE fin_fee_access_policy MODIFY COLUMN rule_require_registration VARCHAR(3) NOT NULL DEFAULT 'no'");
        // Convert old 1/0 values to yes/no
        TryAlter("UPDATE fin_fee_access_policy SET is_active = 'yes' WHERE is_active = '1'");
        TryAlter("UPDATE fin_fee_access_policy SET is_active = 'no' WHERE is_active NOT IN ('yes','no')");
        TryAlter("UPDATE fin_fee_access_policy SET rule_min_balance_enabled = CASE WHEN rule_min_balance_enabled='1' THEN 'yes' ELSE 'no' END WHERE rule_min_balance_enabled NOT IN ('yes','no')");
        TryAlter("UPDATE fin_fee_access_policy SET rule_payment_window_enabled = CASE WHEN rule_payment_window_enabled='1' THEN 'yes' ELSE 'no' END WHERE rule_payment_window_enabled NOT IN ('yes','no')");
        TryAlter("UPDATE fin_fee_access_policy SET rule_pct_paid_enabled = CASE WHEN rule_pct_paid_enabled='1' THEN 'yes' ELSE 'no' END WHERE rule_pct_paid_enabled NOT IN ('yes','no')");
        TryAlter("UPDATE fin_fee_access_policy SET rule_bursary_exempt = CASE WHEN rule_bursary_exempt='1' THEN 'yes' ELSE 'no' END WHERE rule_bursary_exempt NOT IN ('yes','no')");
        TryAlter("UPDATE fin_fee_access_policy SET rule_require_registration = CASE WHEN rule_require_registration='1' THEN 'yes' ELSE 'no' END WHERE rule_require_registration NOT IN ('yes','no')");
    }

    public FeeAccessPolicyConfig LoadSingleton(string fallbackUser)
    {
        EnsureSchema();
        int id = GetOrCreateCanonicalPolicyId(fallbackUser);
        return LoadById(id);
    }

    public FeeAccessPolicyConfig SaveGeneral(FeeAccessPolicyConfig input, string user)
    {
        EnsureSchema();
        int id = GetOrCreateCanonicalPolicyId(user);

        string sql = @"INSERT INTO fin_fee_access_policy
            (policy_id, policy_title, academic_year, semester, is_active, created_by, created_at, updated_by, updated_at, rule_logic, policy_notes)
            VALUES (@id, @title, @ay, @sem, @active, @user, NOW(), @user, NOW(), @logic, @notes)
            ON DUPLICATE KEY UPDATE
                policy_title = @title,
                academic_year = @ay,
                semester = @sem,
                is_active = @active,
                rule_logic = @logic,
                policy_notes = @notes,
                updated_by = @user,
                updated_at = NOW(),
                created_by = COALESCE(created_by, @user),
                created_at = COALESCE(created_at, NOW())";

        FinanceDB.ExecuteNonQuery(sql,
            FinanceDB.P("@id", id),
            FinanceDB.P("@title", input.PolicyTitle),
            FinanceDB.P("@ay", input.AcademicYear),
            FinanceDB.P("@sem", input.Semester),
            FinanceDB.P("@active", input.IsActive ? "yes" : "no"),
            FinanceDB.P("@user", user),
            FinanceDB.P("@logic", string.IsNullOrEmpty(input.RuleLogic) ? "ALL" : input.RuleLogic),
            FinanceDB.P("@notes", input.PolicyNotes));

        // Explicit UPDATE for is_active to guarantee persistence.
        FinanceDB.ExecuteNonQuery(
            "UPDATE fin_fee_access_policy SET is_active = @v WHERE policy_id = @pid",
            FinanceDB.P("@v", input.IsActive ? "yes" : "no"),
            FinanceDB.P("@pid", id));

        EnforceSingleton(id);
        return LoadById(id);
    }

    public FeeAccessPolicyConfig SaveRules(FeeAccessPolicyConfig input, string user)
    {
        EnsureSchema();
        int id = GetOrCreateCanonicalPolicyId(user);

        string sql = @"UPDATE fin_fee_access_policy SET
            rule_min_balance_enabled = @balOn,
            rule_min_balance_amount = @balAmt,
            rule_payment_window_enabled = @winOn,
            rule_payment_min_amount = @winAmt,
            rule_payment_window_start = @winStart,
            rule_payment_window_end = @winEnd,
            rule_pct_paid_enabled = @pctOn,
            rule_pct_paid_minimum = @pctMin,
            rule_bursary_exempt = @burOn,
            rule_bursary_min_coverage = @burMin,
            rule_require_registration = @regOn,
            updated_by = @user,
            updated_at = NOW()
            WHERE policy_id = @id";

        FinanceDB.ExecuteNonQuery(sql,
            FinanceDB.P("@id", id),
            FinanceDB.P("@balOn", input.RuleMinBalanceEnabled ? "yes" : "no"),
            FinanceDB.P("@balAmt", input.RuleMinBalanceAmount),
            FinanceDB.P("@winOn", input.RulePaymentWindowEnabled ? "yes" : "no"),
            FinanceDB.P("@winAmt", input.RulePaymentMinAmount),
            FinanceDB.P("@winStart", input.RulePaymentWindowStart.HasValue ? (object)input.RulePaymentWindowStart.Value : DBNull.Value),
            FinanceDB.P("@winEnd", input.RulePaymentWindowEnd.HasValue ? (object)input.RulePaymentWindowEnd.Value : DBNull.Value),
            FinanceDB.P("@pctOn", input.RulePctPaidEnabled ? "yes" : "no"),
            FinanceDB.P("@pctMin", input.RulePctPaidMinimum),
            FinanceDB.P("@burOn", input.RuleBursaryExempt ? "yes" : "no"),
            FinanceDB.P("@burMin", input.RuleBursaryMinCoverage),
            FinanceDB.P("@regOn", input.RuleRequireRegistration ? "yes" : "no"),
            FinanceDB.P("@user", user));

        EnforceSingleton(id);
        return LoadById(id);
    }

    private FeeAccessPolicyConfig LoadById(int id)
    {
        DataTable dt = FinanceDB.ExecuteDataTable(
            "SELECT * FROM fin_fee_access_policy WHERE policy_id = @id LIMIT 1",
            FinanceDB.P("@id", id));

        if (dt.Rows.Count == 0)
            return new FeeAccessPolicyConfig();

        return MapRow(dt.Rows[0]);
    }

    private int GetOrCreateCanonicalPolicyId(string user)
    {
        DataTable dt = FinanceDB.ExecuteDataTable(@"
            SELECT policy_id
            FROM fin_fee_access_policy
            ORDER BY
                CASE WHEN is_active = 'yes' THEN 0 ELSE 1 END,
                CASE WHEN updated_at IS NULL THEN 1 ELSE 0 END,
                updated_at DESC,
                CASE WHEN created_at IS NULL THEN 1 ELSE 0 END,
                created_at DESC,
                policy_id DESC
            LIMIT 1");

        if (dt.Rows.Count > 0)
            return SafeInt(dt.Rows[0]["policy_id"]);

        FinanceDB.ExecuteNonQuery(@"
            INSERT INTO fin_fee_access_policy
            (policy_title, academic_year, semester, is_active, created_by, created_at, updated_by, updated_at, rule_logic, policy_notes)
            VALUES ('Fee Access Policy', @ay, @sem, 'no', @user, NOW(), @user, NOW(), 'ALL', '')",
            FinanceDB.P("@ay", FeeAccessPolicyRuntime.CurrentAcadYear()),
            FinanceDB.P("@sem", FeeAccessPolicyRuntime.CurrentSemester()),
            FinanceDB.P("@user", user));

        return FinanceDB.ExecuteScalar<int>("SELECT COALESCE(MAX(policy_id), 0) FROM fin_fee_access_policy");
    }

    private void EnforceSingleton(int keepId)
    {
        FinanceDB.ExecuteNonQuery(
            "UPDATE fin_fee_access_policy SET is_active = 'no' WHERE policy_id <> @id",
            FinanceDB.P("@id", keepId));

        FinanceDB.ExecuteNonQuery(
            "DELETE FROM fin_fee_access_policy WHERE policy_id <> @id",
            FinanceDB.P("@id", keepId));
    }

    private static void TryAlter(string sql)
    {
        try { FinanceDB.ExecuteNonQuery(sql); }
        catch { }
    }

    private static FeeAccessPolicyConfig MapRow(DataRow r)
    {
        FeeAccessPolicyConfig item = new FeeAccessPolicyConfig();
        item.PolicyId = SafeInt(r["policy_id"]);
        item.PolicyTitle = SafeStr(r["policy_title"]);
        item.AcademicYear = SafeStr(r["academic_year"]);
        item.Semester = SafeInt(r["semester"]);
        item.IsActive = SafeStr(r["is_active"]).Equals("yes", StringComparison.OrdinalIgnoreCase);
        item.RuleLogic = SafeStr(r["rule_logic"]);
        item.PolicyNotes = SafeStr(r["policy_notes"]);
        item.RuleMinBalanceEnabled = SafeStr(r["rule_min_balance_enabled"]).Equals("yes", StringComparison.OrdinalIgnoreCase);
        item.RuleMinBalanceAmount = SafeDec(r["rule_min_balance_amount"]);
        item.RulePaymentWindowEnabled = SafeStr(r["rule_payment_window_enabled"]).Equals("yes", StringComparison.OrdinalIgnoreCase);
        item.RulePaymentMinAmount = SafeDec(r["rule_payment_min_amount"]);
        item.RulePaymentWindowStart = SafeDate(r["rule_payment_window_start"]);
        item.RulePaymentWindowEnd = SafeDate(r["rule_payment_window_end"]);
        item.RulePctPaidEnabled = SafeStr(r["rule_pct_paid_enabled"]).Equals("yes", StringComparison.OrdinalIgnoreCase);
        item.RulePctPaidMinimum = SafeDec(r["rule_pct_paid_minimum"]);
        item.RuleBursaryExempt = SafeStr(r["rule_bursary_exempt"]).Equals("yes", StringComparison.OrdinalIgnoreCase);
        item.RuleBursaryMinCoverage = SafeDec(r["rule_bursary_min_coverage"]);
        item.RuleRequireRegistration = SafeStr(r["rule_require_registration"]).Equals("yes", StringComparison.OrdinalIgnoreCase);
        item.CreatedBy = SafeStr(r["created_by"]);
        item.CreatedAt = SafeDateTime(r["created_at"]);
        item.UpdatedBy = SafeStr(r["updated_by"]);
        item.UpdatedAt = SafeDateTime(r["updated_at"]);
        return item;
    }

    private static int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int n;
        return int.TryParse(val.ToString(), out n) ? n : 0;
    }

    private static decimal SafeDec(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        decimal n;
        return decimal.TryParse(val.ToString(), out n) ? n : 0;
    }

    private static string SafeStr(object val)
    {
        return val == null || val == DBNull.Value ? "" : val.ToString();
    }

    private static DateTime? SafeDate(object val)
    {
        if (val == null || val == DBNull.Value) return null;
        DateTime d;
        return DateTime.TryParse(val.ToString(), out d) ? d.Date : (DateTime?)null;
    }

    private static DateTime? SafeDateTime(object val)
    {
        if (val == null || val == DBNull.Value) return null;
        DateTime d;
        return DateTime.TryParse(val.ToString(), out d) ? d : (DateTime?)null;
    }
}

public static class FeeAccessPolicyRuntime
{
    public static string CurrentAcadYear()
    {
        int y = DateTime.Now.Year;
        int m = DateTime.Now.Month;
        int start = (m >= 8) ? y : y - 1;
        return start + "/" + (start + 1);
    }

    public static int CurrentSemester()
    {
        int m = DateTime.Now.Month;
        return (m >= 8 || m <= 1) ? 1 : 2;
    }
}
