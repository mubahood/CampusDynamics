using System;
using System.Data;
using MySql.Data.MySqlClient;

public partial class COOPERP_Finance_Admin_TransactionAuditTrail : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblAuditInfo))
        {
            gvAudit.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindAuditRows();
        }
    }

    protected void btnSearchAudit_Click(object sender, EventArgs e)
    {
        BindAuditRows(txtAuditSearch.Text.Trim());
    }

    protected void btnClearAuditSearch_Click(object sender, EventArgs e)
    {
        txtAuditSearch.Text = string.Empty;
        BindAuditRows();
    }

    private void BindAuditRows(string searchTerm = "")
    {
        DataTable dt = CreateAuditSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_log"))
                {
                    lblAuditInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblAuditInfo.Text = "fin_transaction_log table is not yet available. Apply roadmap schema scripts first.";
                    gvAudit.DataSource = dt;
                    gvAudit.DataBind();
                    return;
                }

                string sql = @"
                    SELECT
                        DATE_FORMAT(changed_at, '%Y-%m-%d %H:%i') AS ActionTime,
                        action AS ActionName,
                        changed_by AS ChangedBy,
                        COALESCE(reason_code, '-') AS ReasonCode,
                        CONCAT(table_name, '#', COALESCE(record_id, 0)) AS TargetRecord
                    FROM fin_transaction_log";

                bool hasOldJson = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_transaction_log", "old_value");
                bool hasNewJson = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_transaction_log", "new_value");
                bool hasReasonText = FinanceSystemRealignmentHelper.ColumnExists(conn, "fin_transaction_log", "reason_text");

                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    sql += @" WHERE (
                        action LIKE @search OR
                        changed_by LIKE @search OR
                        table_name LIKE @search OR
                        CAST(record_id AS CHAR) LIKE @search OR
                        COALESCE(reason_code, '') LIKE @search";

                    if (hasReasonText)
                        sql += " OR COALESCE(reason_text, '') LIKE @search";
                    if (hasOldJson)
                        sql += " OR CAST(old_value AS CHAR) LIKE @search";
                    if (hasNewJson)
                        sql += " OR CAST(new_value AS CHAR) LIKE @search";

                    sql += ")";
                }

                sql += " ORDER BY changed_at DESC LIMIT 300;";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    if (!string.IsNullOrWhiteSpace(searchTerm))
                        cmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");

                    da.Fill(dt);
                }
            }

            gvAudit.DataSource = dt;
            gvAudit.DataBind();

            lblAuditInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblAuditInfo.Text = dt.Rows.Count == 0
                ? (string.IsNullOrWhiteSpace(searchTerm) ? "No transaction audit entries found yet." : "No audit records matched your search.")
                : (string.IsNullOrWhiteSpace(searchTerm)
                    ? string.Format("Loaded {0} transaction audit record(s).", dt.Rows.Count)
                    : string.Format("Found {0} audit record(s) matching '{1}'.", dt.Rows.Count, searchTerm));
        }
        catch (Exception ex)
        {
            gvAudit.DataSource = dt;
            gvAudit.DataBind();
            lblAuditInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblAuditInfo.Text = "Unable to load transaction audit trail: " + ex.Message;
        }
    }

    private static DataTable CreateAuditSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ActionTime");
        dt.Columns.Add("ActionName");
        dt.Columns.Add("ChangedBy");
        dt.Columns.Add("ReasonCode");
        dt.Columns.Add("TargetRecord");
        return dt;
    }
}
