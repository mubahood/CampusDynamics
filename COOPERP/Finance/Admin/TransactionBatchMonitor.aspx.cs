using System;
using System.Data;
using MySql.Data.MySqlClient;

public partial class COOPERP_Finance_Admin_TransactionBatchMonitor : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblStatus))
        {
            gvBatchSummary.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindBatchGrid();
        }
    }

    protected void gvBatchSummary_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        if (e.CommandName != "InspectBatch")
            return;

        int batchId;
        if (!int.TryParse(e.CommandArgument.ToString(), out batchId))
            return;

        BindBatchDetails(batchId);
    }

    private void BindBatchGrid()
    {
        DataTable dt = CreateBatchSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_batch"))
                {
                    lblStatus.ForeColor = System.Drawing.Color.DarkOrange;
                    lblStatus.Text = "fin_transaction_batch table is not yet available in this environment. Apply roadmap database scripts first.";
                    gvBatchSummary.DataSource = dt;
                    gvBatchSummary.DataBind();
                    return;
                }

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT
                        batch_id AS BatchId,
                        batch_type AS BatchType,
                        status AS Status,
                        created_by AS CreatedBy,
                        total_debit AS TotalDebit,
                        total_credit AS TotalCredit
                    FROM fin_transaction_batch
                    ORDER BY created_at DESC
                    LIMIT 200;", conn))
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvBatchSummary.DataSource = dt;
            gvBatchSummary.DataBind();

            lblStatus.ForeColor = System.Drawing.Color.DarkGreen;
            lblStatus.Text = dt.Rows.Count == 0
                ? "No transaction batches found yet."
                : string.Format("Loaded {0} transaction batch record(s).", dt.Rows.Count);
        }
        catch (Exception ex)
        {
            gvBatchSummary.DataSource = dt;
            gvBatchSummary.DataBind();
            lblStatus.ForeColor = System.Drawing.Color.DarkRed;
            lblStatus.Text = "Unable to load transaction batches: " + ex.Message;
        }
    }

    private void BindBatchDetails(int batchId)
    {
        DataTable dt = CreateBatchLineSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_ledger"))
                {
                    pnlBatchDetails.Visible = true;
                    lblBatchDetailsTitle.Text = "Batch Line Inspection";
                    lblBatchDetailsInfo.Text = "fin_ledger table is not available yet, so no batch line drill-down can be shown.";
                    gvBatchLines.DataSource = dt;
                    gvBatchLines.DataBind();
                    return;
                }

                string lineIdColumn = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", "TID", "id", "ledger_id");
                string accountCodeColumn = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", "AccountCode", "account_code", "code");
                string narrationColumn = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", "Details", "details", "narration", "description");
                string debitColumn = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", "debit_amount", "DebitAmount", "dr_amount", "debit");
                string creditColumn = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", "credit_amount", "CreditAmount", "cr_amount", "credit");

                if (string.IsNullOrWhiteSpace(lineIdColumn) || string.IsNullOrWhiteSpace(accountCodeColumn))
                {
                    pnlBatchDetails.Visible = true;
                    lblBatchDetailsTitle.Text = string.Format("Batch #{0} Line Inspection", batchId);
                    lblBatchDetailsInfo.Text = "Unable to resolve key fin_ledger columns required for drill-down in this schema.";
                    gvBatchLines.DataSource = dt;
                    gvBatchLines.DataBind();
                    return;
                }

                string narrationExpr = string.IsNullOrWhiteSpace(narrationColumn) ? "'-'" : "COALESCE(`" + narrationColumn + "`, '-')";
                string debitExpr = string.IsNullOrWhiteSpace(debitColumn) ? "0" : "COALESCE(`" + debitColumn + "`, 0)";
                string creditExpr = string.IsNullOrWhiteSpace(creditColumn) ? "0" : "COALESCE(`" + creditColumn + "`, 0)";

                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT `" + lineIdColumn + "` AS LineId, `" + accountCodeColumn + "` AS AccountCode, " + narrationExpr + " AS Narration, " + debitExpr + " AS DebitAmount, " + creditExpr + " AS CreditAmount FROM fin_ledger WHERE batch_id = @batchId ORDER BY `" + lineIdColumn + "` ASC LIMIT 500;",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@batchId", batchId);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            pnlBatchDetails.Visible = true;
            lblBatchDetailsTitle.Text = string.Format("Batch #{0} — Ledger Line Inspection", batchId);
            lblBatchDetailsInfo.Text = dt.Rows.Count == 0
                ? "No ledger lines are linked to this batch yet."
                : string.Format("Showing {0} ledger line(s) linked to batch #{1}.", dt.Rows.Count, batchId);
            gvBatchLines.DataSource = dt;
            gvBatchLines.DataBind();
        }
        catch (Exception ex)
        {
            pnlBatchDetails.Visible = true;
            lblBatchDetailsTitle.Text = string.Format("Batch #{0} — Ledger Line Inspection", batchId);
            lblBatchDetailsInfo.Text = "Unable to inspect this batch: " + ex.Message;
            gvBatchLines.DataSource = dt;
            gvBatchLines.DataBind();
        }
    }

    private static DataTable CreateBatchSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("BatchId");
        dt.Columns.Add("BatchType");
        dt.Columns.Add("Status");
        dt.Columns.Add("CreatedBy");
        dt.Columns.Add("TotalDebit", typeof(decimal));
        dt.Columns.Add("TotalCredit", typeof(decimal));
        return dt;
    }

    private static DataTable CreateBatchLineSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("LineId");
        dt.Columns.Add("AccountCode");
        dt.Columns.Add("Narration");
        dt.Columns.Add("DebitAmount", typeof(decimal));
        dt.Columns.Add("CreditAmount", typeof(decimal));
        return dt;
    }
}
