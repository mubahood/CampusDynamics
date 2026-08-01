using System;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Initiate Reversal Request — Finance System Realignment.
/// Allows a finance user to:
///   1. Search for a posted voucher by voucher number
///   2. Review the associated fin_ledger lines
///   3. Submit a reversal/correction request into fin_transaction_reversal as Pending
///
/// The request is picked up by ReversalApprovals.aspx for Finance Admin action.
/// This page does NOT post any reversal entries; it only records the request.
/// </summary>
public partial class COOPERP_Finance_Admin_ReversalRequest : System.Web.UI.Page
{
    // ─── Page Load ───────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblStatus))
        {
            pnlVoucherLines.Visible = false;
            pnlRequestForm.Visible  = false;
            return;
        }

        if (!IsPostBack)
        {
            BindRecentRequests();

            string voucherFromQuery = Request.QueryString["voucher"];
            if (!string.IsNullOrEmpty(voucherFromQuery))
            {
                txtVoucherNo.Text = voucherFromQuery.Trim();
                btnSearch_Click(btnSearch, EventArgs.Empty);
            }
        }
    }

    // ─── Step 1: Voucher Search ───────────────────────────────────────────────

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string voucherNo = txtVoucherNo.Text.Trim();

        if (string.IsNullOrEmpty(voucherNo))
        {
            ShowError("Please enter a voucher number to search.");
            return;
        }

        pnlVoucherLines.Visible = false;
        pnlRequestForm.Visible  = false;
        lblStatus.Text          = string.Empty;

        DataTable dt = new DataTable();
        dt.Columns.Add("LedgerId",    typeof(string));
        dt.Columns.Add("AccountCode", typeof(string));
        dt.Columns.Add("AccountName", typeof(string));
        dt.Columns.Add("EntryType",   typeof(string));
        dt.Columns.Add("Amount",      typeof(decimal));
        dt.Columns.Add("Narration",   typeof(string));
        dt.Columns.Add("EntryDate",   typeof(string));

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                // Determine the correct voucher/account columns via schema guard
                string ledgerIdCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "TID", "tid", "ledger_id", "id" });

                string voucherCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "voucherNo", "voucherno", "voucher_no", "voucher_number", "RefNo", "ref_no", "journal_no", "narration", "particulars" });

                string accountCodeCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "accountcode", "AccountCode", "account_code", "acc_code", "code" });

                string accountNameCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "acc_name", "accountname", "AccountName", "account_name", "name" });

                string drcrCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "transactionType", "transactiontype", "dr_cr", "entry_type", "drcr", "type" });

                string amountCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "actual_amount", "transaction_amount", "amount", "entry_amount", "value" });

                string narrationCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "particulars", "narration", "description", "remarks", "memo" });

                string dateCol = FinanceSystemRealignmentHelper.GetFirstExistingColumn(
                    conn, "fin_ledger", new[] { "transactionDate", "transactiondate", "entry_date", "trans_date", "date", "posting_date" });

                if (voucherCol == null || amountCol == null)
                {
                    ShowError("fin_ledger schema missing required columns. Apply Phase 1 schema scripts.");
                    return;
                }

                string sql = string.Format(
                    @"SELECT
                        {0}                                                     AS LedgerId,
                        {1}                                                     AS AccountCode,
                        {2}                                                     AS AccountName,
                        {3}                                                     AS EntryType,
                        {4}                                                     AS Amount,
                        {5}                                                     AS Narration,
                        {6}                                                     AS EntryDate
                    FROM fin_ledger l
                    WHERE l.{7} = @voucherNo
                    ORDER BY {8};",
                    ledgerIdCol    != null ? "l." + ledgerIdCol    : "0",
                    accountCodeCol != null ? "l." + accountCodeCol : "NULL",
                    accountNameCol != null ? "l." + accountNameCol : "''",
                    drcrCol        != null ? "l." + drcrCol        : "''",
                    amountCol == "actual_amount" && FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "transaction_amount" }) != null
                        ? "COALESCE(NULLIF(l.actual_amount,0), l.transaction_amount, 0)"
                        : "l." + amountCol,
                    narrationCol   != null ? "l." + narrationCol   : "''",
                    dateCol        != null ? string.Format("DATE_FORMAT(l.{0}, '%Y-%m-%d')", dateCol) : "''",
                    voucherCol,
                    ledgerIdCol    != null ? "l." + ledgerIdCol    : "l." + voucherCol);

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@voucherNo", voucherNo);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            if (dt.Rows.Count == 0)
            {
                ShowError(string.Format("No ledger entries found for voucher '{0}'. Verify the voucher number and try again.", voucherNo));
                return;
            }

            // Compute total debit amount as the voucher amount (for default reversal amount)
            decimal totalDr = 0m;
            foreach (DataRow row in dt.Rows)
            {
                string et = row["EntryType"] == DBNull.Value ? "" : row["EntryType"].ToString().ToUpper();
                if (et == "DR" || et == "DEBIT" || et == "D")
                    totalDr += row["Amount"] == DBNull.Value ? 0m : Convert.ToDecimal(row["Amount"]);
            }

            lblVoucherSummary.Text = string.Format(
                "<b>Voucher:</b> {0} &nbsp;|&nbsp; <b>Lines:</b> {1} &nbsp;|&nbsp; <b>Total Dr:</b> {2:N2}",
                Server.HtmlEncode(voucherNo), dt.Rows.Count, totalDr);

            gvVoucherLines.DataSource = dt;
            gvVoucherLines.DataBind();

            hdnVoucherNo.Value     = voucherNo;
            hdnVoucherAmount.Value = totalDr.ToString("F4");

            pnlVoucherLines.Visible = true;
            pnlRequestForm.Visible  = true;

            // Pre-fill reversal amount with the full voucher amount
            txtReversalAmount.Text = totalDr > 0 ? totalDr.ToString("F2") : string.Empty;

            ShowInfo(string.Format("Voucher '{0}' found with {1} ledger line(s). Complete Step 3 to submit your request.", voucherNo, dt.Rows.Count));
        }
        catch (Exception ex)
        {
            ShowError("Error searching for voucher: " + ex.Message);
        }
    }

    // ─── Step 3: Submit Request ───────────────────────────────────────────────

    protected void btnSubmitRequest_Click(object sender, EventArgs e)
    {
        string voucherNo    = hdnVoucherNo.Value.Trim();
        string reversalType = ddlReversalType.SelectedValue;
        string reasonCode   = ddlReasonCode.SelectedValue;
        string notes        = txtNotes.Text.Trim();
        string amountRaw    = txtReversalAmount.Text.Trim();
        string requestedBy  = Session["username"] != null ? Session["username"].ToString() : User.Identity.Name;

        // ── Validate inputs ──────────────────────────────────────────────────
        if (string.IsNullOrEmpty(voucherNo))
        {
            ShowError("Session expired or voucher not loaded. Please search again.");
            return;
        }
        if (string.IsNullOrEmpty(reversalType))
        {
            ShowError("Please select a Reversal Type.");
            return;
        }
        if (string.IsNullOrEmpty(reasonCode))
        {
            ShowError("Please select a Reason Code.");
            return;
        }
        if (reasonCode == "Other" && string.IsNullOrEmpty(notes))
        {
            ShowError("Supporting notes are required when the reason is 'Other'.");
            return;
        }

        decimal reversalAmount = 0m;
        decimal orig = 0m;

        if (!string.IsNullOrEmpty(amountRaw))
        {
            if (!decimal.TryParse(amountRaw, out reversalAmount) || reversalAmount <= 0)
            {
                ShowError("Reversal Amount must be a positive number.");
                return;
            }
        }
        else if (decimal.TryParse(hdnVoucherAmount.Value, out orig) && orig > 0)
        {
            reversalAmount = orig;
        }

        // ── Build combined reversal_reason string ────────────────────────────
        string fullReason = reasonCode;
        if (!string.IsNullOrEmpty(notes))
            fullReason = reasonCode + " — " + notes;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_reversal"))
                {
                    ShowError("fin_transaction_reversal table is not yet available. Apply Phase 1 schema scripts first.");
                    return;
                }

                // Check for an existing Pending request for the same voucher
                int existing;
                using (MySqlCommand chk = new MySqlCommand(
                    @"SELECT COUNT(*) FROM fin_transaction_reversal
                      WHERE original_voucherno = @voucher AND approved_at IS NULL;", conn))
                {
                    chk.Parameters.AddWithValue("@voucher", voucherNo);
                    existing = Convert.ToInt32(chk.ExecuteScalar());
                }

                if (existing > 0)
                {
                    ShowError(string.Format(
                        "A reversal request for voucher '{0}' is already pending approval. Please wait for it to be actioned before submitting another.",
                        voucherNo));
                    return;
                }

                // Insert the reversal request as Pending
                using (MySqlCommand ins = new MySqlCommand(
                    @"INSERT INTO fin_transaction_reversal
                        (reversal_type, original_voucherno, original_amount, reversal_reason,
                         requested_by, requested_at)
                      VALUES
                        (@rtype, @voucher, @amount, @reason,
                         @requestedBy, NOW());", conn))
                {
                    ins.Parameters.AddWithValue("@rtype",       reversalType);
                    ins.Parameters.AddWithValue("@voucher",     voucherNo);
                    ins.Parameters.AddWithValue("@amount",      reversalAmount);
                    ins.Parameters.AddWithValue("@reason",      fullReason);
                    ins.Parameters.AddWithValue("@requestedBy", requestedBy);
                    ins.ExecuteNonQuery();
                }

                // Log the action
                FinanceSystemRealignmentHelper.LogAction(conn,
                    action:    "ReversalRequestSubmitted",
                    tableName: "fin_transaction_reversal",
                    recordId:  0,
                    batchId:   0,
                    changedBy: requestedBy,
                    reasonCode: reasonCode,
                    reasonText: string.Format("Voucher={0}, Type={1}, Amount={2:N2}", voucherNo, reversalType, reversalAmount));
            }

            // Reset the form
            pnlVoucherLines.Visible = false;
            pnlRequestForm.Visible  = false;
            txtVoucherNo.Text       = string.Empty;
            hdnVoucherNo.Value      = string.Empty;
            hdnVoucherAmount.Value  = string.Empty;
            ddlReversalType.SelectedIndex = 0;
            ddlReasonCode.SelectedIndex   = 0;
            txtReversalAmount.Text        = string.Empty;
            txtNotes.Text                 = string.Empty;

            ShowSuccess(string.Format(
                "Reversal request for voucher '{0}' submitted successfully. " +
                "It is now Pending approval in Reversal and Correction Approvals.",
                voucherNo));

            BindRecentRequests();
        }
        catch (Exception ex)
        {
            ShowError("Error submitting reversal request: " + ex.Message);
        }
    }

    // ─── Clear / Start Over ───────────────────────────────────────────────────

    protected void btnClearForm_Click(object sender, EventArgs e)
    {
        txtVoucherNo.Text       = string.Empty;
        hdnVoucherNo.Value      = string.Empty;
        hdnVoucherAmount.Value  = string.Empty;
        pnlVoucherLines.Visible = false;
        pnlRequestForm.Visible  = false;
        ddlReversalType.SelectedIndex = 0;
        ddlReasonCode.SelectedIndex   = 0;
        txtReversalAmount.Text        = string.Empty;
        txtNotes.Text                 = string.Empty;
        lblStatus.Text                = string.Empty;
        BindRecentRequests();
    }

    // ─── Recent Requests Grid ─────────────────────────────────────────────────

    private void BindRecentRequests()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("RequestRef",     typeof(string));
        dt.Columns.Add("OriginalVoucher", typeof(string));
        dt.Columns.Add("ReversalType",   typeof(string));
        dt.Columns.Add("ReversalReason", typeof(string));
        dt.Columns.Add("OriginalAmount", typeof(decimal));
        dt.Columns.Add("RequestedAt",    typeof(string));
        dt.Columns.Add("Status",         typeof(string));
        dt.Columns.Add("ApprovalNotes",  typeof(string));

        try
        {
            string requestedBy = Session["username"] != null ? Session["username"].ToString() : User.Identity.Name;

            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_reversal"))
                {
                    gvRecentRequests.DataSource = dt;
                    gvRecentRequests.DataBind();
                    return;
                }

                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT
                        CONCAT('REV-', LPAD(reversal_id, 5, '0'))           AS RequestRef,
                        original_voucherno                                   AS OriginalVoucher,
                        reversal_type                                        AS ReversalType,
                        reversal_reason                                      AS ReversalReason,
                        original_amount                                      AS OriginalAmount,
                        DATE_FORMAT(requested_at, '%Y-%m-%d %H:%i')         AS RequestedAt,
                        CASE
                            WHEN approved_at IS NOT NULL AND approval_comments LIKE 'REJECTED:%' THEN 'Rejected'
                            WHEN approved_at IS NOT NULL                                         THEN 'Approved'
                            ELSE 'Pending'
                        END                                                  AS Status,
                        IFNULL(approval_comments, '')                        AS ApprovalNotes
                    FROM fin_transaction_reversal
                    WHERE requested_by = @requestedBy
                    ORDER BY requested_at DESC
                    LIMIT 50;", conn))
                {
                    cmd.Parameters.AddWithValue("@requestedBy", requestedBy);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            gvRecentRequests.DataSource = dt;
            gvRecentRequests.DataBind();
        }
        catch (Exception ex)
        {
            // Non-critical — grid simply stays empty
            gvRecentRequests.DataSource = dt;
            gvRecentRequests.DataBind();
            // Surface error non-intrusively only if no other status message set
            if (string.IsNullOrEmpty(lblStatus.Text))
                ShowError("Could not load recent requests: " + ex.Message);
        }
    }

    // ─── Status Helpers ───────────────────────────────────────────────────────

    private void ShowError(string message)
    {
        lblStatus.ForeColor = System.Drawing.Color.DarkRed;
        lblStatus.Text      = message;
    }

    private void ShowInfo(string message)
    {
        lblStatus.ForeColor = System.Drawing.Color.DarkBlue;
        lblStatus.Text      = message;
    }

    private void ShowSuccess(string message)
    {
        lblStatus.ForeColor = System.Drawing.Color.DarkGreen;
        lblStatus.Text      = message;
    }
}
