using System;
using System.Data;
using System.Collections.Generic;
using System.Text;
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
        if (e.CommandName == "ViewRequest")
        {
            ShowRequestDetail(e.CommandArgument.ToString());
            return;
        }

        if (e.CommandName != "ApproveReversal" && e.CommandName != "RejectReversal")
            return;

        string reversalId = e.CommandArgument.ToString();
        string action     = e.CommandName == "ApproveReversal" ? "Approve" : "Reject";

        // Populate comments panel so the user can enter notes before confirming
        hdnReversalId.Value = reversalId;
        hdnAction.Value     = action;
        txtComments.Text    = string.Empty;
        ShowRequestDetail(reversalId);

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

                TrySendApprovalNotification(conn, reversalId, action, approver, storedComment);
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

    private void ShowRequestDetail(string reversalId)
    {
        DataTable originalLines = CreateOriginalLineSchema();
        DataTable requestedLines = CreateRequestedLineSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                string voucherCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "voucherno", "voucher_no", "voucher_number", "ref_no" });
                string accountCodeCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "account_code", "acc_code", "code" });
                string drcrCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "dr_cr", "entry_type", "drcr", "type" });
                string amountCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "amount", "entry_amount", "value" });
                string narrationCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "narration", "description", "remarks", "memo" });

                DataTable detail = new DataTable();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT reversal_id, reversal_type, original_voucherno, original_amount,
                           requested_by, requested_at, reversal_reason, reversal_notes,
                           approved_by, approved_at, approval_comments
                    FROM fin_transaction_reversal
                    WHERE reversal_id = @rid
                    LIMIT 1;", conn))
                {
                    cmd.Parameters.AddWithValue("@rid", reversalId);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(detail);
                }

                if (detail.Rows.Count == 0)
                {
                    pnlRequestDetail.Visible = false;
                    return;
                }

                DataRow row = detail.Rows[0];
                string originalVoucher = row["original_voucherno"].ToString();

                lblRequestDetail.Text = string.Format(
                    "<b>Request:</b> REV-{0} &nbsp;|&nbsp; <b>Type:</b> {1} &nbsp;|&nbsp; <b>Original Voucher:</b> {2} &nbsp;|&nbsp; <b>Requested By:</b> {3} &nbsp;|&nbsp; <b>Requested At:</b> {4}",
                    reversalId.PadLeft(5, '0'),
                    Server.HtmlEncode(row["reversal_type"].ToString()),
                    Server.HtmlEncode(originalVoucher),
                    Server.HtmlEncode(row["requested_by"].ToString()),
                    row["requested_at"] == DBNull.Value ? "-" : Convert.ToDateTime(row["requested_at"]).ToString("yyyy-MM-dd HH:mm"));

                requestedLines.Rows.Add("Reason", row["reversal_reason"] == DBNull.Value ? "-" : row["reversal_reason"].ToString());
                requestedLines.Rows.Add("Notes", row["reversal_notes"] == DBNull.Value ? "-" : row["reversal_notes"].ToString());
                requestedLines.Rows.Add("Amount", row["original_amount"] == DBNull.Value ? "0.00" : Convert.ToDecimal(row["original_amount"]).ToString("N2"));
                requestedLines.Rows.Add("Approval State", row["approved_at"] == DBNull.Value ? "Pending" : "Actioned");
                if (row["approval_comments"] != DBNull.Value)
                    requestedLines.Rows.Add("Approval Comments", row["approval_comments"].ToString());

                if (voucherCol != null && amountCol != null)
                {
                    string sql = string.Format(@"
                        SELECT
                            l.ledger_id AS LedgerId,
                            {0} AS AccountCode,
                            {1} AS EntryType,
                            l.{2} AS Amount,
                            {3} AS Narration
                        FROM fin_ledger l
                        WHERE l.{4} = @voucher
                        ORDER BY l.ledger_id;",
                        accountCodeCol != null ? "l." + accountCodeCol : "''",
                        drcrCol != null ? "l." + drcrCol : "''",
                        amountCol,
                        narrationCol != null ? "l." + narrationCol : "''",
                        voucherCol);

                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@voucher", originalVoucher);
                        using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                            da.Fill(originalLines);
                    }
                }
            }

            gvOriginalLines.DataSource = originalLines;
            gvOriginalLines.DataBind();
            gvRequestedLines.DataSource = requestedLines;
            gvRequestedLines.DataBind();
            pnlRequestDetail.Visible = true;
        }
        catch
        {
            pnlRequestDetail.Visible = false;
        }
    }

    private static DataTable CreateOriginalLineSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("LedgerId");
        dt.Columns.Add("AccountCode");
        dt.Columns.Add("EntryType");
        dt.Columns.Add("Amount", typeof(decimal));
        dt.Columns.Add("Narration");
        return dt;
    }

    private static DataTable CreateRequestedLineSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("FieldName");
        dt.Columns.Add("FieldValue");
        return dt;
    }

    private void TrySendApprovalNotification(MySqlConnection conn, string reversalId, string action, string approver, string comments)
    {
        try
        {
            DataTable dt = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(@"
                SELECT original_voucherno, reversal_type, requested_by, reversal_reason
                FROM fin_transaction_reversal
                WHERE reversal_id = @rid
                LIMIT 1;", conn))
            {
                cmd.Parameters.AddWithValue("@rid", reversalId);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }

            if (dt.Rows.Count == 0)
                return;

            DataRow row = dt.Rows[0];
            string requestedBy = row["requested_by"] == DBNull.Value ? string.Empty : row["requested_by"].ToString();
            string recipientEmail = ResolveUserEmail(conn, requestedBy);
            if (string.IsNullOrWhiteSpace(recipientEmail))
                return;

            string status = action == "Approve" ? "Approved" : "Rejected";
            StringBuilder sb = new StringBuilder();
            sb.Append("Dear ").Append(string.IsNullOrWhiteSpace(requestedBy) ? "User" : requestedBy).Append(",<br/><br/>");
            sb.Append("Your finance ").Append(Server.HtmlEncode(row["reversal_type"].ToString()).ToLowerInvariant())
              .Append(" request for voucher <b>").Append(Server.HtmlEncode(row["original_voucherno"].ToString())).Append("</b> has been <b>")
              .Append(status).Append("</b>.<br/><br/>");
            sb.Append("<b>Reason:</b> ").Append(Server.HtmlEncode(row["reversal_reason"].ToString())).Append("<br/>");
            sb.Append("<b>Actioned By:</b> ").Append(Server.HtmlEncode(approver)).Append("<br/>");
            sb.Append("<b>Comments:</b> ").Append(Server.HtmlEncode(comments)).Append("<br/><br/>");
            sb.Append("Regards,<br/>Campus Dynamics Finance Realignment");

            EmailSenderProtocol.SendHtmlEmail(
                sb.ToString(),
                recipientEmail,
                "Finance Request " + status + " - " + row["original_voucherno"],
                "Campus Dynamics");
        }
        catch
        {
            // Notification failures must never block the approval path.
        }
    }

    private static string ResolveUserEmail(MySqlConnection conn, string username)
    {
        if (string.IsNullOrWhiteSpace(username))
            return null;

        if (username.Contains("@"))
            return username;

        string[] tableCandidates = { "users", "tbl_users", "sec_users", "useraccounts", "staff", "employees", "fin_users" };
        string[] userColumns = { "username", "user_name", "userid", "user_id", "staff_id", "emailusername", "loginname" };
        string[] emailColumns = { "email", "email_address", "emailaddress", "work_email", "personal_email" };

        for (int t = 0; t < tableCandidates.Length; t++)
        {
            string tableName = tableCandidates[t];
            if (!FinanceSystemRealignmentHelper.TableExists(conn, tableName))
                continue;

            string userCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, tableName, userColumns);
            string emailCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, tableName, emailColumns);
            if (string.IsNullOrEmpty(userCol) || string.IsNullOrEmpty(emailCol))
                continue;

            using (MySqlCommand cmd = new MySqlCommand(
                string.Format("SELECT {0} FROM {1} WHERE {2} = @u LIMIT 1;", emailCol, tableName, userCol), conn))
            {
                cmd.Parameters.AddWithValue("@u", username);
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    string email = result.ToString();
                    if (!string.IsNullOrWhiteSpace(email) && email.Contains("@"))
                        return email;
                }
            }
        }

        return null;
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
