using System;
using System.Data;
using System.Collections.Generic;
using System.Text;
using MySql.Data.MySqlClient;

public partial class COOPERP_Finance_Admin_AccountManagement : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblAccountInfo))
        {
            gvAccounts.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindAccounts();
        }
    }

    protected void gvAccounts_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        if (e.CommandName != "DeactivateAccount" && e.CommandName != "RestoreAccount")
            return;

        string[] parts = e.CommandArgument.ToString().Split('|');
        if (parts.Length < 3)
            return;

        string accountCode = parts[0];
        int ledgerLines = 0;
        int.TryParse(parts[1], out ledgerLines);
        string currentStatus = parts[2];

        if (e.CommandName == "DeactivateAccount")
            ExecuteAccountStatusChange(accountCode, ledgerLines, currentStatus, false);
        else
            ExecuteAccountStatusChange(accountCode, ledgerLines, currentStatus, true);
    }

    private void BindAccounts()
    {
        DataTable dt = CreateAccountSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_subaccounts"))
                {
                    lblAccountInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblAccountInfo.Text = "fin_subaccounts table is not yet available. Apply roadmap schema scripts first.";
                    gvAccounts.DataSource = dt;
                    gvAccounts.DataBind();
                    return;
                }

                string accountCodeColumn = ResolveColumn(conn, "fin_subaccounts", new[] { "AccountCode", "account_code", "code" });
                string accountNameColumn = ResolveColumn(conn, "fin_subaccounts", new[] { "AccountName", "account_name", "name" });
                string accountTypeColumn = ResolveColumn(conn, "fin_subaccounts", new[] { "AccountType", "account_type", "category", "type" });
                string activeColumn = ResolveColumn(conn, "fin_subaccounts", new[] { "is_active", "active", "status" });

                if (string.IsNullOrWhiteSpace(accountCodeColumn) || string.IsNullOrWhiteSpace(accountNameColumn))
                {
                    lblAccountInfo.ForeColor = System.Drawing.Color.DarkRed;
                    lblAccountInfo.Text = "Unable to resolve required account columns in fin_subaccounts.";
                    gvAccounts.DataSource = dt;
                    gvAccounts.DataBind();
                    return;
                }

                bool ledgerExists = FinanceSystemRealignmentHelper.TableExists(conn, "fin_ledger");
                string ledgerAccountCodeColumn = ledgerExists
                    ? ResolveColumn(conn, "fin_ledger", new[] { "AccountCode", "account_code", "code" })
                    : string.Empty;

                string accountTypeExpr = string.IsNullOrWhiteSpace(accountTypeColumn)
                    ? "'-'"
                    : "s.`" + accountTypeColumn + "`";

                string statusExpr = "'Active'";
                if (!string.IsNullOrWhiteSpace(activeColumn))
                {
                    if (activeColumn.Equals("status", StringComparison.OrdinalIgnoreCase))
                    {
                        statusExpr = "CASE WHEN LOWER(COALESCE(s.`" + activeColumn + "`, '')) IN ('inactive','disabled','deleted') THEN 'Inactive' ELSE 'Active' END";
                    }
                    else
                    {
                        statusExpr = "CASE WHEN COALESCE(s.`" + activeColumn + "`, 1) IN (0, '0', 'false', 'False') THEN 'Inactive' ELSE 'Active' END";
                    }
                }

                string joinClause = string.Empty;
                string ledgerLinesExpr = "0";
                if (ledgerExists && !string.IsNullOrWhiteSpace(ledgerAccountCodeColumn))
                {
                    joinClause = " LEFT JOIN fin_ledger l ON l.`" + ledgerAccountCodeColumn + "` = s.`" + accountCodeColumn + "` ";
                    ledgerLinesExpr = "COUNT(l.`" + ledgerAccountCodeColumn + "`)";
                }

                StringBuilder sqlBuilder = new StringBuilder();
                sqlBuilder.Append("SELECT ");
                sqlBuilder.Append("s.`").Append(accountCodeColumn).Append("` AS AccountCode, ");
                sqlBuilder.Append("s.`").Append(accountNameColumn).Append("` AS AccountName, ");
                sqlBuilder.Append(accountTypeExpr).Append(" AS AccountType, ");
                sqlBuilder.Append(statusExpr).Append(" AS Status, ");
                sqlBuilder.Append(ledgerLinesExpr).Append(" AS LedgerLines ");
                sqlBuilder.Append("FROM fin_subaccounts s ");
                sqlBuilder.Append(joinClause);
                sqlBuilder.Append("GROUP BY s.`").Append(accountCodeColumn).Append("`, s.`").Append(accountNameColumn).Append("`, ");
                sqlBuilder.Append(accountTypeExpr).Append(", ").Append(statusExpr).Append(" ");
                sqlBuilder.Append("ORDER BY s.`").Append(accountCodeColumn).Append("` ASC ");
                sqlBuilder.Append("LIMIT 500;");
                string sql = sqlBuilder.ToString();

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvAccounts.DataSource = dt;
            gvAccounts.DataBind();

            lblAccountInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblAccountInfo.Text = dt.Rows.Count == 0
                ? "No chart of accounts records found yet."
                : string.Format("Loaded {0} chart of accounts record(s).", dt.Rows.Count);
        }
        catch (Exception ex)
        {
            gvAccounts.DataSource = dt;
            gvAccounts.DataBind();
            lblAccountInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblAccountInfo.Text = "Unable to load chart of accounts: " + ex.Message;
        }
    }

    private void ExecuteAccountStatusChange(string accountCode, int ledgerLines, string currentStatus, bool activate)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_subaccounts"))
                {
                    lblAccountInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblAccountInfo.Text = "Account lifecycle action cannot continue because fin_subaccounts is unavailable.";
                    return;
                }

                string accountCodeColumn = ResolveColumn(conn, "fin_subaccounts", new[] { "AccountCode", "account_code", "code" });
                string activeColumn = ResolveColumn(conn, "fin_subaccounts", new[] { "is_active", "active", "status" });

                if (string.IsNullOrWhiteSpace(accountCodeColumn) || string.IsNullOrWhiteSpace(activeColumn))
                {
                    lblAccountInfo.ForeColor = System.Drawing.Color.DarkRed;
                    lblAccountInfo.Text = "Unable to resolve required fin_subaccounts columns for lifecycle updates.";
                    return;
                }

                if (!activate && ledgerLines > 0)
                {
                    lblAccountInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblAccountInfo.Text = string.Format("Account {0} cannot be deactivated because it already has {1} linked ledger line(s). Create a replacement account and archive usage first.", accountCode, ledgerLines);
                    return;
                }

                if (activate && string.Equals(currentStatus, "Active", StringComparison.OrdinalIgnoreCase))
                {
                    lblAccountInfo.ForeColor = System.Drawing.Color.DarkBlue;
                    lblAccountInfo.Text = string.Format("Account {0} is already active.", accountCode);
                    return;
                }

                string sql;
                if (activeColumn.Equals("status", StringComparison.OrdinalIgnoreCase))
                {
                    sql = "UPDATE fin_subaccounts SET `" + activeColumn + "` = @statusValue WHERE `" + accountCodeColumn + "` = @accountCode;";
                }
                else
                {
                    sql = "UPDATE fin_subaccounts SET `" + activeColumn + "` = @activeValue WHERE `" + accountCodeColumn + "` = @accountCode;";
                }

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (activeColumn.Equals("status", StringComparison.OrdinalIgnoreCase))
                        cmd.Parameters.AddWithValue("@statusValue", activate ? "active" : "inactive");
                    else
                        cmd.Parameters.AddWithValue("@activeValue", activate ? 1 : 0);

                    cmd.Parameters.AddWithValue("@accountCode", accountCode);
                    cmd.ExecuteNonQuery();
                }

                lblAccountInfo.ForeColor = System.Drawing.Color.DarkGreen;
                lblAccountInfo.Text = string.Format("Account {0} has been {1} successfully.", accountCode, activate ? "restored/activated" : "deactivated");
            }

            BindAccounts();
        }
        catch (Exception ex)
        {
            lblAccountInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblAccountInfo.Text = "Unable to apply account lifecycle update: " + ex.Message;
        }
    }

    private static DataTable CreateAccountSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("AccountCode");
        dt.Columns.Add("AccountName");
        dt.Columns.Add("AccountType");
        dt.Columns.Add("Status");
        dt.Columns.Add("LedgerLines");
        return dt;
    }

    private static string ResolveColumn(MySqlConnection conn, string tableName, IEnumerable<string> candidateColumns)
    {
        foreach (string candidate in candidateColumns)
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = @db AND table_name = @table AND column_name = @column", conn))
            {
                cmd.Parameters.AddWithValue("@db", conn.Database);
                cmd.Parameters.AddWithValue("@table", tableName);
                cmd.Parameters.AddWithValue("@column", candidate);

                object scalar = cmd.ExecuteScalar();
                int count;
                if (scalar != null && int.TryParse(scalar.ToString(), out count) && count > 0)
                {
                    return candidate;
                }
            }
        }

        return string.Empty;
    }
}
