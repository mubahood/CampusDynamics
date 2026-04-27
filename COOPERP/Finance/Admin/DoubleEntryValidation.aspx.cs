using System;
using System.Data;
using MySql.Data.MySqlClient;

public partial class COOPERP_Finance_Admin_DoubleEntryValidation : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblValidationInfo))
        {
            gvRules.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindValidationRules();
        }
    }

    protected void gvRules_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        if (e.CommandName != "ToggleRuleStatus")
            return;

        string[] parts = e.CommandArgument.ToString().Split('|');
        if (parts.Length != 2)
            return;

        int ruleId;
        if (!int.TryParse(parts[0], out ruleId))
            return;

        string currentStatus = parts[1];
        bool activate = !string.Equals(currentStatus, "Active", StringComparison.OrdinalIgnoreCase);

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                using (MySqlCommand cmd = new MySqlCommand(@"
                    UPDATE fin_posting_rules
                    SET is_active = @isActive,
                        updated_at = NOW()
                    WHERE rule_id = @ruleId;", conn))
                {
                    cmd.Parameters.AddWithValue("@isActive", activate ? 1 : 0);
                    cmd.Parameters.AddWithValue("@ruleId", ruleId);
                    cmd.ExecuteNonQuery();
                }
            }

            lblValidationInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblValidationInfo.Text = string.Format("Rule #{0} has been {1} successfully.", ruleId, activate ? "activated" : "deactivated");
            BindValidationRules();
        }
        catch (Exception ex)
        {
            lblValidationInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblValidationInfo.Text = "Unable to update rule status: " + ex.Message;
        }
    }

    private void BindValidationRules()
    {
        DataTable dt = CreateRulesSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_posting_rules"))
                {
                    lblValidationInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblValidationInfo.Text = "fin_posting_rules table is not yet available in this environment. Apply roadmap database scripts first.";
                    gvRules.DataSource = dt;
                    gvRules.DataBind();
                    return;
                }

                bool batchTableExists = FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_batch");

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT
                        rule_id AS RuleId,
                        rule_name AS RuleName,
                        transaction_type AS TransactionType,
                        enforce_level AS Enforcement,
                        CASE WHEN is_active = 1 THEN 'Active' ELSE 'Inactive' END AS Status,
                        0 AS RecentViolations
                    FROM fin_posting_rules
                    ORDER BY is_active DESC, rule_name ASC
                    LIMIT 200;", conn))
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }

                if (batchTableExists)
                {
                    using (MySqlCommand summaryCmd = new MySqlCommand(@"
                        SELECT 
                            SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS ActiveRules,
                            COUNT(*) AS TotalRules
                        FROM fin_posting_rules;", conn))
                    using (MySqlDataReader reader = summaryCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int activeRules = reader.IsDBNull(0) ? 0 : reader.GetInt32(0);
                            int totalRules = reader.IsDBNull(1) ? 0 : reader.GetInt32(1);
                            lblRuleSummary.Text = string.Format("Active Rules: <b>{0}</b> of <b>{1}</b>. Recent Violations are estimated using failed or unbalanced transaction batches where available.", activeRules, totalRules);
                        }
                    }

                    using (MySqlCommand violationCmd = new MySqlCommand(@"
                        SELECT batch_type, COUNT(*) AS FailedCount
                        FROM fin_transaction_batch
                        WHERE status = 'Failed' OR ABS(COALESCE(total_debit,0) - COALESCE(total_credit,0)) >= 0.01
                        GROUP BY batch_type;", conn))
                    using (MySqlDataAdapter daViolations = new MySqlDataAdapter(violationCmd))
                    {
                        DataTable violations = new DataTable();
                        daViolations.Fill(violations);

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            string txType = dt.Rows[i]["TransactionType"].ToString();
                            DataRow[] matches = violations.Select("batch_type = '" + txType.Replace("'", "''") + "'");
                            dt.Rows[i]["RecentViolations"] = matches.Length > 0 ? matches[0]["FailedCount"].ToString() : "0";
                        }
                    }
                }
                else
                {
                    lblRuleSummary.Text = "Active rule metrics loaded. Recent violation counts will become available once fin_transaction_batch is deployed.";
                }
            }

            gvRules.DataSource = dt;
            gvRules.DataBind();

            lblValidationInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblValidationInfo.Text = dt.Rows.Count == 0
                ? "No posting rules found yet."
                : string.Format("Loaded {0} posting rule record(s).", dt.Rows.Count);
        }
        catch (Exception ex)
        {
            gvRules.DataSource = dt;
            gvRules.DataBind();
            lblValidationInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblValidationInfo.Text = "Unable to load validation rules: " + ex.Message;
        }
    }

    private static DataTable CreateRulesSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("RuleId");
        dt.Columns.Add("RuleName");
        dt.Columns.Add("TransactionType");
        dt.Columns.Add("Enforcement");
        dt.Columns.Add("Status");
        dt.Columns.Add("RecentViolations");
        return dt;
    }
}
