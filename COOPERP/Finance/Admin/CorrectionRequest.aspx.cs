using System;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Initiate Correction Request — Finance System Realignment.
/// Allows a finance user to:
///   1. Search for a posted voucher by voucher number
///   2. Review the associated fin_ledger lines
///   3. Specify a correction type and provide corrected values
///   4. Submit a correction record into fin_transaction_reversal (reversal_type='Correction') as Pending
///
/// A correction differs from a simple reversal:
///   - The system stores both the original values and the proposed corrected values in reversal_reason.
///   - The Finance Admin reviews and, upon approval, posts a paired reversal + repost.
///   - This page does NOT post entries — it only records the request.
///   - Picked up by ReversalApprovals.aspx for Finance Admin action.
/// </summary>
public partial class COOPERP_Finance_Admin_CorrectionRequest : System.Web.UI.Page
{
    // ViewState keys
    private const string VS_VOUCHER_NO = "_cr_vno";
    private const string VS_ORIG_AMT   = "_cr_amt";

    // ─── Page Load ────────────────────────────────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblStatus))
        {
            pnlVoucherLines.Visible   = false;
            pnlCorrectionForm.Visible = false;
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

        pnlVoucherLines.Visible   = false;
        pnlCorrectionForm.Visible = false;
        lblStatus.Text            = string.Empty;

        DataTable dt = BuildLedgerSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                string voucherCol    = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "voucherno", "voucher_no", "voucher_number", "ref_no", "narration" });
                string accountCodeCol= FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "account_code", "acc_code", "code" });
                string accountNameCol= FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "account_name", "acc_name", "name" });
                string drcrCol       = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "dr_cr", "entry_type", "drcr", "type" });
                string amountCol     = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "amount", "entry_amount", "value" });
                string narrationCol  = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "narration", "description", "remarks", "memo" });
                string dateCol       = FinanceSystemRealignmentHelper.GetFirstExistingColumn(conn, "fin_ledger", new[] { "entry_date", "trans_date", "date", "posting_date" });

                if (voucherCol == null || amountCol == null)
                {
                    ShowError("fin_ledger schema is missing required columns. Apply Phase 1 schema scripts.");
                    return;
                }

                string sql = string.Format(
                    @"SELECT
                        l.ledger_id                                         AS LedgerId,
                        {0}                                                 AS AccountCode,
                        {1}                                                 AS AccountName,
                        {2}                                                 AS EntryType,
                        l.{3}                                               AS Amount,
                        {4}                                                 AS Narration,
                        {5}                                                 AS EntryDate
                    FROM fin_ledger l
                    WHERE l.{6} = @voucherNo
                    ORDER BY l.ledger_id;",
                    accountCodeCol != null ? "l." + accountCodeCol : "NULL",
                    accountNameCol != null ? "l." + accountNameCol : "''",
                    drcrCol        != null ? "l." + drcrCol        : "''",
                    amountCol,
                    narrationCol   != null ? "l." + narrationCol   : "''",
                    dateCol        != null ? string.Format("DATE_FORMAT(l.{0}, '%Y-%m-%d')", dateCol) : "''",
                    voucherCol);

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@voucherNo", voucherNo);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }

            if (dt.Rows.Count == 0)
            {
                ShowError(string.Format("No ledger entries found for voucher '{0}'. Verify the voucher number.", voucherNo));
                return;
            }

            // Compute total debit for pre-filling
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

            // Store in ViewState for the form
            ViewState[VS_VOUCHER_NO] = voucherNo;
            ViewState[VS_ORIG_AMT]   = totalDr;
            hdnVoucherNo.Value       = voucherNo;
            hdnOriginalAmount.Value  = totalDr.ToString("F4");

            lblOriginalAmount.Text   = totalDr.ToString("N2");
            txtCorrectedAmount.Text  = totalDr > 0 ? totalDr.ToString("F2") : string.Empty;

            pnlVoucherLines.Visible   = true;
            pnlCorrectionForm.Visible = true;

            // Ensure sub-panels default to hidden
            pnlAmountFields.Visible    = false;
            pnlAccountFields.Visible   = false;
            pnlNarrationField.Visible  = false;
            pnlDateField.Visible       = false;
            ddlCorrectionType.SelectedIndex = 0;

            ShowInfo(string.Format(
                "Voucher '{0}' found with {1} ledger line(s). Complete Step 3 to submit your correction request.",
                voucherNo, dt.Rows.Count));
        }
        catch (Exception ex)
        {
            ShowError("Error searching for voucher: " + ex.Message);
        }
    }

    // ─── Correction Type Selector ─────────────────────────────────────────────

    protected void ddlCorrectionType_Changed(object sender, EventArgs e)
    {
        string val = ddlCorrectionType.SelectedValue;

        pnlAmountFields.Visible   = val == "WrongAmount" || val == "WrongAmountAndAccount";
        pnlAccountFields.Visible  = val == "WrongAccount" || val == "WrongAmountAndAccount";
        pnlNarrationField.Visible = val == "WrongNarration";
        pnlDateField.Visible      = val == "WrongDate";
    }

    // ─── Step 3: Submit Correction Request ───────────────────────────────────

    protected void btnSubmitRequest_Click(object sender, EventArgs e)
    {
        string voucherNo      = hdnVoucherNo.Value.Trim();
        string correctionType = ddlCorrectionType.SelectedValue;
        string notes          = txtNotes.Text.Trim();
        string requestedBy    = Session["username"] != null ? Session["username"].ToString() : User.Identity.Name;
        string amountRaw      = txtCorrectedAmount.Text.Trim();

        // ── Validate ─────────────────────────────────────────────────────────

        if (string.IsNullOrEmpty(voucherNo))
        {
            ShowError("Session expired or voucher not loaded. Please search again.");
            return;
        }
        if (string.IsNullOrEmpty(correctionType))
        {
            ShowError("Please select a Correction Type.");
            return;
        }
        if (correctionType == "Other" && string.IsNullOrEmpty(notes))
        {
            ShowError("Supporting notes are required when correction type is 'Other'.");
            return;
        }

        // Amount validation for amount-based corrections
        decimal correctedAmount = 0m;
        if (correctionType == "WrongAmount" || correctionType == "WrongAmountAndAccount")
        {
            if (string.IsNullOrEmpty(amountRaw) || !decimal.TryParse(amountRaw, out correctedAmount) || correctedAmount <= 0)
            {
                ShowError("A valid positive Corrected Amount is required for this correction type.");
                return;
            }
        }

        // Account validation for account-based corrections
        if (correctionType == "WrongAccount" || correctionType == "WrongAmountAndAccount")
        {
            if (string.IsNullOrEmpty(txtCorrectedAccount.Text.Trim()))
            {
                ShowError("A Corrected Account Code is required for this correction type.");
                return;
            }
            if (string.IsNullOrEmpty(txtLedgerLineId.Text.Trim()))
            {
                ShowError("Please enter the Ledger Line ID (from Step 2) that contains the wrong account.");
                return;
            }
        }

        // Date validation for date corrections
        if (correctionType == "WrongDate")
        {
            DateTime parsedDate;
            if (string.IsNullOrEmpty(txtCorrectedDate.Text.Trim()) ||
                !DateTime.TryParse(txtCorrectedDate.Text.Trim(), out parsedDate))
            {
                ShowError("A valid Corrected Posting Date (YYYY-MM-DD) is required for this correction type.");
                return;
            }
        }

        // ── Build combined reason_text ────────────────────────────────────────
        System.Text.StringBuilder reasonSb = new System.Text.StringBuilder();
        reasonSb.Append("CorrectionType=").Append(correctionType);

        if (correctionType == "WrongAmount" || correctionType == "WrongAmountAndAccount")
        {
            decimal origAmt = 0m;
            decimal.TryParse(hdnOriginalAmount.Value, out origAmt);
            reasonSb.AppendFormat(" | OrigAmt={0:N2} → CorrAmt={1:N2}", origAmt, correctedAmount);
        }
        if (correctionType == "WrongAccount" || correctionType == "WrongAmountAndAccount")
        {
            reasonSb.AppendFormat(" | LedgerLine={0} → Account={1}",
                txtLedgerLineId.Text.Trim(),
                txtCorrectedAccount.Text.Trim());
        }
        if (correctionType == "WrongNarration" && !string.IsNullOrEmpty(txtCorrectedNarration.Text.Trim()))
            reasonSb.AppendFormat(" | NewNarration={0}", txtCorrectedNarration.Text.Trim());
        if (correctionType == "WrongDate" && !string.IsNullOrEmpty(txtCorrectedDate.Text.Trim()))
            reasonSb.AppendFormat(" | NewDate={0}", txtCorrectedDate.Text.Trim());
        if (!string.IsNullOrEmpty(notes))
            reasonSb.AppendFormat(" | Notes: {0}", notes);

        string fullReason = reasonSb.ToString();

        // ── Determine the amount to store (original if not an amount correction) -
        decimal originalAmount = 0m;
        decimal.TryParse(hdnOriginalAmount.Value, out originalAmount);
        decimal storedAmount = correctedAmount > 0 ? correctedAmount : originalAmount;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_transaction_reversal"))
                {
                    ShowError("fin_transaction_reversal table is not yet available. Apply Phase 1 schema scripts.");
                    return;
                }

                // Guard: no pending correction already exists for this voucher of type Correction
                int existingPending;
                using (MySqlCommand chk = new MySqlCommand(
                    @"SELECT COUNT(*) FROM fin_transaction_reversal
                      WHERE original_voucherno = @voucher
                        AND reversal_type = 'Correction'
                        AND approved_at IS NULL;", conn))
                {
                    chk.Parameters.AddWithValue("@voucher", voucherNo);
                    existingPending = Convert.ToInt32(chk.ExecuteScalar());
                }

                if (existingPending > 0)
                {
                    ShowError(string.Format(
                        "A correction request for voucher '{0}' is already pending approval. " +
                        "Wait for it to be actioned before submitting another.",
                        voucherNo));
                    return;
                }

                // Insert as Correction type into fin_transaction_reversal
                using (MySqlCommand ins = new MySqlCommand(
                    @"INSERT INTO fin_transaction_reversal
                        (reversal_type, original_voucherno, original_amount,
                         reversal_reason, requested_by, requested_at)
                      VALUES
                        ('Correction', @voucher, @amount,
                         @reason, @requestedBy, NOW());", conn))
                {
                    ins.Parameters.AddWithValue("@voucher",     voucherNo);
                    ins.Parameters.AddWithValue("@amount",      storedAmount);
                    ins.Parameters.AddWithValue("@reason",      fullReason);
                    ins.Parameters.AddWithValue("@requestedBy", requestedBy);
                    ins.ExecuteNonQuery();
                }

                // Audit log
                FinanceSystemRealignmentHelper.LogAction(conn,
                    action:    "CorrectionRequestSubmitted",
                    tableName: "fin_transaction_reversal",
                    recordId:  0,
                    batchId:   0,
                    changedBy: requestedBy,
                    reasonCode: correctionType,
                    reasonText: string.Format("Voucher={0}, Type={1}", voucherNo, correctionType));
            }

            // Reset form
            pnlVoucherLines.Visible   = false;
            pnlCorrectionForm.Visible = false;
            txtVoucherNo.Text         = string.Empty;
            hdnVoucherNo.Value        = string.Empty;
            hdnOriginalAmount.Value   = string.Empty;
            ddlCorrectionType.SelectedIndex = 0;
            pnlAmountFields.Visible   = false;
            pnlAccountFields.Visible  = false;
            pnlNarrationField.Visible = false;
            pnlDateField.Visible      = false;
            txtCorrectedAmount.Text   = string.Empty;
            txtCorrectedAccount.Text  = string.Empty;
            txtLedgerLineId.Text      = string.Empty;
            txtCorrectedNarration.Text = string.Empty;
            txtCorrectedDate.Text     = string.Empty;
            txtNotes.Text             = string.Empty;

            ShowSuccess(string.Format(
                "Correction request for voucher '{0}' submitted successfully. " +
                "It is now Pending approval in Reversal and Correction Approvals.",
                voucherNo));

            BindRecentRequests();
        }
        catch (Exception ex)
        {
            ShowError("Error submitting correction request: " + ex.Message);
        }
    }

    // ─── Clear / Start Over ───────────────────────────────────────────────────

    protected void btnClearForm_Click(object sender, EventArgs e)
    {
        txtVoucherNo.Text   = string.Empty;
        hdnVoucherNo.Value  = string.Empty;
        hdnOriginalAmount.Value = string.Empty;
        pnlVoucherLines.Visible   = false;
        pnlCorrectionForm.Visible = false;
        pnlAmountFields.Visible   = false;
        pnlAccountFields.Visible  = false;
        pnlNarrationField.Visible = false;
        pnlDateField.Visible      = false;
        ddlCorrectionType.SelectedIndex = 0;
        txtCorrectedAmount.Text   = string.Empty;
        txtCorrectedAccount.Text  = string.Empty;
        txtLedgerLineId.Text      = string.Empty;
        txtCorrectedNarration.Text = string.Empty;
        txtCorrectedDate.Text     = string.Empty;
        txtNotes.Text             = string.Empty;
        lblStatus.Text            = string.Empty;
        BindRecentRequests();
    }

    // ─── Recent Requests Grid ─────────────────────────────────────────────────

    private void BindRecentRequests()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("RequestRef",      typeof(string));
        dt.Columns.Add("OriginalVoucher", typeof(string));
        dt.Columns.Add("CorrectionType",  typeof(string));
        dt.Columns.Add("ReversalReason",  typeof(string));
        dt.Columns.Add("OriginalAmount",  typeof(decimal));
        dt.Columns.Add("RequestedAt",     typeof(string));
        dt.Columns.Add("Status",          typeof(string));
        dt.Columns.Add("ApprovalNotes",   typeof(string));

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
                        CONCAT('COR-', LPAD(reversal_id, 5, '0'))                   AS RequestRef,
                        original_voucherno                                           AS OriginalVoucher,
                        reversal_type                                                AS CorrectionType,
                        reversal_reason                                              AS ReversalReason,
                        original_amount                                              AS OriginalAmount,
                        DATE_FORMAT(requested_at, '%Y-%m-%d %H:%i')                 AS RequestedAt,
                        CASE
                            WHEN approved_at IS NOT NULL
                             AND approval_comments LIKE 'REJECTED:%' THEN 'Rejected'
                            WHEN approved_at IS NOT NULL              THEN 'Approved'
                            ELSE 'Pending'
                        END                                                          AS Status,
                        IFNULL(approval_comments, '')                                AS ApprovalNotes
                    FROM fin_transaction_reversal
                    WHERE reversal_type = 'Correction'
                      AND requested_by  = @requestedBy
                    ORDER BY requested_at DESC
                    LIMIT 50;", conn))
                {
                    cmd.Parameters.AddWithValue("@requestedBy", requestedBy);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }

            gvRecentRequests.DataSource = dt;
            gvRecentRequests.DataBind();
        }
        catch (Exception ex)
        {
            gvRecentRequests.DataSource = dt;
            gvRecentRequests.DataBind();
            if (string.IsNullOrEmpty(lblStatus.Text))
                ShowError("Could not load recent requests: " + ex.Message);
        }
    }

    // ─── Schema Helper ────────────────────────────────────────────────────────

    private DataTable BuildLedgerSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("LedgerId",    typeof(string));
        dt.Columns.Add("AccountCode", typeof(string));
        dt.Columns.Add("AccountName", typeof(string));
        dt.Columns.Add("EntryType",   typeof(string));
        dt.Columns.Add("Amount",      typeof(decimal));
        dt.Columns.Add("Narration",   typeof(string));
        dt.Columns.Add("EntryDate",   typeof(string));
        return dt;
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
