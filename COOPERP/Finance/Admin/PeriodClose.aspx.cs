using System;
using MySql.Data.MySqlClient;

public partial class COOPERP_Finance_Admin_PeriodClose : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblCloseInfo))
        {
            chkCloseChecklist.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindCloseReadiness();
            PrefillLatestPeriod();
        }
    }

    protected void btnExecutePeriodClose_Click(object sender, EventArgs e)
    {
        string fiscalYear = txtCloseFiscalYear.Text.Trim();
        int periodNumber;
        string actingUser = Session["username"] != null ? Session["username"].ToString() : "system";

        if (string.IsNullOrWhiteSpace(fiscalYear) || !int.TryParse(txtClosePeriodNumber.Text.Trim(), out periodNumber))
        {
            lblCloseInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblCloseInfo.Text = "Enter a valid fiscal year and period number before running month-end close.";
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                bool procedureExists = StoredProcedureExists(conn, "sp_MonthEndClose");
                if (!procedureExists)
                {
                    lblCloseInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblCloseInfo.Text = "Month-end close procedure is not deployed yet. Apply the roadmap stored procedure script before executing operational close from this screen.";
                    return;
                }

                using (MySqlCommand cmd = new MySqlCommand("sp_MonthEndClose", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@FiscalYear", fiscalYear);
                    cmd.Parameters.AddWithValue("@PeriodNumber", periodNumber);
                    cmd.Parameters.AddWithValue("@ClosedBy", actingUser);
                    cmd.ExecuteNonQuery();
                }
            }

            lblCloseInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblCloseInfo.Text = string.Format("Month-end close executed successfully for fiscal year {0}, period {1}.", fiscalYear, periodNumber);
            BindCloseReadiness();
        }
        catch (Exception ex)
        {
            lblCloseInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblCloseInfo.Text = "Unable to execute month-end close: " + ex.Message;
        }
    }

    private void BindCloseReadiness()
    {
        ResetChecklist();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                bool hasBatchTable = FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_batch");
                bool hasPeriodTable = FinanceSystemRealignmentHelper.TableExists(conn, "fin_accounting_periods");
                bool hasBankImportTable = FinanceSystemRealignmentHelper.TableExists(conn, "fin_reco_bank_statement_import");

                if (!hasBatchTable || !hasPeriodTable || !hasBankImportTable)
                {
                    lblCloseInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblCloseInfo.Text = "Some roadmap tables are not yet available for full close-readiness checks (requires fin_transaction_batch, fin_accounting_periods, fin_reco_bank_statement_import).";
                    return;
                }

                bool allBatchesCompleted = IsBatchCompletionHealthy(conn);
                bool trialBalanceBalanced = IsLatestPeriodTrialBalanceBalanced(conn);
                bool bankReconciliationComplete = IsLatestBankImportReconciled(conn);
                bool depreciationPosted = IsLatestPeriodFlagSet(conn, "depreciation_posted");
                bool revenueFinalized = IsLatestPeriodFlagSet(conn, "revenue_finalized");

                chkCloseChecklist.Items[0].Selected = allBatchesCompleted;
                chkCloseChecklist.Items[1].Selected = trialBalanceBalanced;
                chkCloseChecklist.Items[2].Selected = bankReconciliationComplete;
                chkCloseChecklist.Items[3].Selected = depreciationPosted;
                chkCloseChecklist.Items[4].Selected = revenueFinalized;

                int completeCount = 0;
                for (int i = 0; i < chkCloseChecklist.Items.Count; i++)
                {
                    if (chkCloseChecklist.Items[i].Selected)
                    {
                        completeCount++;
                    }
                }

                lblCloseInfo.ForeColor = completeCount == chkCloseChecklist.Items.Count
                    ? System.Drawing.Color.DarkGreen
                    : System.Drawing.Color.DarkBlue;
                lblCloseInfo.Text = string.Format("Period close readiness: {0}/{1} checklist checks satisfied.", completeCount, chkCloseChecklist.Items.Count);
            }
        }
        catch (Exception ex)
        {
            lblCloseInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblCloseInfo.Text = "Unable to evaluate period close readiness: " + ex.Message;
        }
    }

    private void PrefillLatestPeriod()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();
                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_accounting_periods"))
                    return;

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT fiscal_year, period_number
                    FROM fin_accounting_periods
                    ORDER BY fiscal_year DESC, period_number DESC
                    LIMIT 1;", conn))
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        txtCloseFiscalYear.Text = reader.IsDBNull(0) ? string.Empty : reader.GetString(0);
                        txtClosePeriodNumber.Text = reader.IsDBNull(1) ? string.Empty : reader.GetInt32(1).ToString();
                    }
                }
            }
        }
        catch
        {
            // non-critical prefill only
        }
    }

    private void ResetChecklist()
    {
        for (int i = 0; i < chkCloseChecklist.Items.Count; i++)
        {
            chkCloseChecklist.Items[i].Selected = false;
        }
    }

    private static bool IsBatchCompletionHealthy(MySqlConnection conn)
    {
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT COUNT(*)
            FROM fin_transaction_batch
            WHERE status IN ('Draft', 'InProgress', 'Failed');", conn))
        {
            object scalar = cmd.ExecuteScalar();
            int count;
            if (scalar != null && int.TryParse(scalar.ToString(), out count))
            {
                return count == 0;
            }

            return false;
        }
    }

    private static bool IsLatestPeriodTrialBalanceBalanced(MySqlConnection conn)
    {
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT COALESCE(trial_balance_balanced, 0)
            FROM fin_accounting_periods
            ORDER BY fiscal_year DESC, period_number DESC
            LIMIT 1;", conn))
        {
            object scalar = cmd.ExecuteScalar();
            return ToBool(scalar);
        }
    }

    private static bool IsLatestBankImportReconciled(MySqlConnection conn)
    {
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT reconciliation_status
            FROM fin_reco_bank_statement_import
            ORDER BY import_date DESC
            LIMIT 1;", conn))
        {
            object scalar = cmd.ExecuteScalar();
            string value = scalar == null ? string.Empty : scalar.ToString();
            return value.Equals("Complete", StringComparison.OrdinalIgnoreCase)
                || value.Equals("Completed", StringComparison.OrdinalIgnoreCase);
        }
    }

    private static bool IsLatestPeriodFlagSet(MySqlConnection conn, string flagColumn)
    {
        using (MySqlCommand checkCmd = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = @db AND table_name = 'fin_accounting_periods' AND column_name = @column", conn))
        {
            checkCmd.Parameters.AddWithValue("@db", conn.Database);
            checkCmd.Parameters.AddWithValue("@column", flagColumn);
            object hasColumnObj = checkCmd.ExecuteScalar();
            int hasColumn;
            if (hasColumnObj == null || !int.TryParse(hasColumnObj.ToString(), out hasColumn) || hasColumn == 0)
            {
                return false;
            }
        }

        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COALESCE(" + flagColumn + ", 0) FROM fin_accounting_periods ORDER BY fiscal_year DESC, period_number DESC LIMIT 1;", conn))
        {
            object scalar = cmd.ExecuteScalar();
            return ToBool(scalar);
        }
    }

    private static bool ToBool(object value)
    {
        if (value == null)
        {
            return false;
        }

        bool asBool;
        if (bool.TryParse(value.ToString(), out asBool))
        {
            return asBool;
        }

        int asInt;
        if (int.TryParse(value.ToString(), out asInt))
        {
            return asInt != 0;
        }

        string text = value.ToString();
        return text.Equals("Y", StringComparison.OrdinalIgnoreCase)
            || text.Equals("Yes", StringComparison.OrdinalIgnoreCase)
            || text.Equals("True", StringComparison.OrdinalIgnoreCase);
    }

    private static bool StoredProcedureExists(MySqlConnection conn, string procedureName)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = @db AND routine_type = 'PROCEDURE' AND routine_name = @proc;", conn))
        {
            cmd.Parameters.AddWithValue("@db", conn.Database);
            cmd.Parameters.AddWithValue("@proc", procedureName);
            object scalar = cmd.ExecuteScalar();
            int count;
            return scalar != null && int.TryParse(scalar.ToString(), out count) && count > 0;
        }
    }
}
