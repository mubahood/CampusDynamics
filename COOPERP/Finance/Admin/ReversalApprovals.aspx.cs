using System;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Reversal and Correction Approval Workflow.
/// Finance Administrators review, approve, or reject pending reversal/correction requests.
/// All actions write back to fin_transaction_reversal with approver username, timestamp, and
/// mandatory comments. Actions are fully auditable and double-submit protected.
/// </summary>
public partial class COOPERP_Finance_Admin_ReversalApprovals : System.Web.UI.Page
{
    // ─── Page Load ───────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblApprovalInfo))
        {
            gvApprovals.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindApprovals();
        }
    }

    // ─── GridView Data Binding ────────────────────────────────────────────────

    private void BindApprovals()
    {
        DataTable dt = CreateApprovalSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_reversal"))
                {
                    lblApprovalInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblApprovalInfo.Text = "fin_transaction_reversal table is not yet available. Apply roadmap Phase 1 schema scripts first.";
                    gvApprovals.DataSource = dt;
                    gvApprovals.DataBind();
                    return;
                }

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT
                        reversal_id                                              AS ReversalId,
                        CONCAT('REV-', LPAD(reversal_id, 5, '0'))               AS RequestId,
                        reversal_type                                            AS RequestType,
                        original_voucherno                                       AS OriginalVoucher,
                        original_amount                                          AS Amount,
                        requested_by                                             AS RequestedBy,
                        DATE_FORMAT(requested_at, '%Y-%m-%d %H:%i')             AS RequestedAt,
                        reversal_reason                                          AS ReversalReason,
                        CASE
                            WHEN approved_at IS NOT NULL AND approval_comments LIKE 'REJECTED:%' THEN 'Rejected'
                            WHEN approved_at IS NOT NULL                                         THEN 'Approved'
                            ELSE 'Pending'
                        END                                                      AS Status
                    FROM fin_transaction_reversal
                    ORDER BY
                        CASE WHEN approved_at IS NULL THEN 0 ELSE 1 END,
                        requested_at DESC
                    LIMIT 300;", conn))
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvApprovals.DataSource = dt;
            gvApprovals.DataBind();

            int pending = 0, approved = 0, rejected = 0;
            foreach (DataRow row in dt.Rows)
            {
                string s = row["Status"].ToString();
                if (s == "Pending")       pending++;
                else if (s == "Approved") approved++;
                else                      rejected++;
            }

            lblApprovalInfo.ForeColor = pending > 0
                ? System.Drawing.Color.DarkOrange
                : System.Drawing.Color.DarkGreen;

            lblApprovalInfo.Text = string.Format(
                "Total: {0} request(s) — {1} pending approval, {2} approved, {3} rejected.",
                dt.Rows.Count, pending, approved, rejected);
        }
        catch (Exception ex)
        {
            gvApprovals.DataSource = dt;
            gvApprovals.DataBind();
            lblApprovalInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblApprovalInfo.Text = "Error loading reversal/correction approvals: " + ex.Message;
        }
    }

    // ─── GridView Row Command (Approve / Reject buttons) ─────────────────────

    protected void gvApprovals_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "ApproveReversal" && e.CommandName != "RejectReversal")
            return;

        string reversalId = e.CommandArgument.ToString();
        string action     = e.CommandName == "ApproveReversal" ? "Approve" : "Reject";

        // Populate comments panel so the user can enter notes before confirming
        hdnReversalId.Value = reversalId;
        hdnAction.Value     = action;
        txtComments.Text    = string.Empty;

        lblActionTitle.Text = action == "Approve"
            ? string.Format("Approving Request REV-{0} — Enter any approval notes:", reversalId.PadLeft(5, '0'))
            : string.Format("Rejecting Request REV-{0} — A rejection reason is required:", reversalId.PadLeft(5, '0'));

        pnlActionPanel.Visible = true;
    }

    // ─── Confirm Action ───────────────────────────────────────────────────────

    protected void btnConfirmAction_Click(object sender, EventArgs e)
    {
        string reversalId = hdnReversalId.Value.Trim();
        string action     = hdnAction.Value.Trim();
        string comments   = txtComments.Text.Trim();
        string approver   = Session["username"] != null ? Session["username"].ToString() : "system";

        // Reject requires a reason
        if (action == "Reject" && string.IsNullOrEmpty(comments))
        {
            lblApprovalInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblApprovalInfo.Text = "A rejection reason is required. Please enter a comment before confirming.";
            return;
        }

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                // Double-submit guard: ensure record is still pending
                int stillPending;
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM fin_transaction_reversal WHERE reversal_id = @rid AND approved_at IS NULL;", conn))
                {
                    chk.Parameters.AddWithValue("@rid", reversalId);
                    stillPending = Convert.ToInt32(chk.ExecuteScalar());
                }

                if (stillPending == 0)
                {
                    lblApprovalInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblApprovalInfo.Text = "This request has already been actioned by another approver. List refreshed.";
                    pnlActionPanel.Visible = false;
                    BindApprovals();
                    return;
                }

                // Prefix REJECTED: so the Status CASE query in BindApprovals can distinguish correctly
                string storedComment = action == "Reject"
                    ? "REJECTED: " + comments
                    : (string.IsNullOrEmpty(comments) ? "Approved." : comments);

                using (MySqlCommand upd = new MySqlCommand(@"
                    UPDATE fin_transaction_reversal
                    SET
                        approved_by       = @approver,
                        approved_at       = NOW(),
                        approval_comments = @comments
                    WHERE reversal_id = @rid
                      AND approved_at IS NULL;", conn))
                {
                    upd.Parameters.AddWithValue("@approver", approver);
                    upd.Parameters.AddWithValue("@comments", storedComment);
                    upd.Parameters.AddWithValue("@rid",      reversalId);
                    upd.ExecuteNonQuery();
                }
            }

            pnlActionPanel.Visible = false;
            lblApprovalInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblApprovalInfo.Text = string.Format(
                "Request REV-{0} has been {1} by {2}.",
                reversalId.PadLeft(5, '0'),
                action == "Approve" ? "approved" : "rejected",
                approver);

            BindApprovals();
        }
        catch (Exception ex)
        {
            lblApprovalInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblApprovalInfo.Text = "Error processing action: " + ex.Message;
        }
    }

    // ─── Cancel Action ────────────────────────────────────────────────────────

    protected void btnCancelAction_Click(object sender, EventArgs e)
    {
        pnlActionPanel.Visible = false;
        lblApprovalInfo.ForeColor = System.Drawing.Color.Gray;
        lblApprovalInfo.Text = "Action cancelled. No changes made.";
        BindApprovals();
    }

    // ─── DataTable Schema ─────────────────────────────────────────────────────

    private static DataTable CreateApprovalSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ReversalId",     typeof(int));
        dt.Columns.Add("RequestId");
        dt.Columns.Add("RequestType");
        dt.Columns.Add("OriginalVoucher");
        dt.Columns.Add("Amount",         typeof(decimal));
        dt.Columns.Add("RequestedBy");
        dt.Columns.Add("RequestedAt");
        dt.Columns.Add("ReversalReason");
        dt.Columns.Add("Status");
        return dt;
    }
}
