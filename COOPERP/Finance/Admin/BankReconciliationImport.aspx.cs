using System;
using System.Data;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using MySql.Data.MySqlClient;

public partial class COOPERP_Finance_Admin_BankReconciliationImport : System.Web.UI.Page
{
    // ViewState keys for carrying upload data across the confirmation postback
    private const string VS_FILE_HASH     = "_brk_hash";
    private const string VS_FILE_NAME     = "_brk_fname";
    private const string VS_LINE_COUNT    = "_brk_lines";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!FinanceSystemRealignmentHelper.EnsureFinanceAdminAccess(this, lblImportInfo))
        {
            gvImports.Visible = false;
            pnlPreview.Visible = false;
            return;
        }

        if (!IsPostBack)
        {
            BindImportSummary();
        }
    }

    // ─── Upload: preview + hash ───────────────────────────────────────────────

    protected void btnUploadStatement_Click(object sender, EventArgs e)
    {
        pnlPreview.Visible = false;

        if (!fuStatement.HasFile || fuStatement.FileBytes.Length == 0)
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkOrange;
            lblImportInfo.Text = "Please select a file before clicking Preview.";
            return;
        }

        string accountIdRaw = txtBankAccountId.Text.Trim();
        int bankAccountId;
        if (!int.TryParse(accountIdRaw, out bankAccountId) || bankAccountId <= 0)
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkOrange;
            lblImportInfo.Text = "Please enter a valid numeric Bank Account ID.";
            return;
        }

        string statDateRaw = txtStatementDate.Text.Trim();
        DateTime statementDate;
        if (string.IsNullOrWhiteSpace(statDateRaw) || !DateTime.TryParse(statDateRaw, out statementDate))
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkOrange;
            lblImportInfo.Text = "Please enter a valid Statement Date (YYYY-MM-DD).";
            return;
        }

        byte[] fileBytes = fuStatement.FileBytes;
        string fileName  = Path.GetFileName(fuStatement.FileName);

        // SHA-256 hash
        string fileHash;
        using (SHA256 sha = SHA256.Create())
        {
            byte[] hashBytes = sha.ComputeHash(fileBytes);
            StringBuilder sb = new StringBuilder(64);
            for (int i = 0; i < hashBytes.Length; i++)
                sb.Append(hashBytes[i].ToString("x2"));
            fileHash = sb.ToString();
        }

        // Parse preview lines (first 25 text lines)
        string previewText;
        int lineCount = 0;
        try
        {
            string fullText = Encoding.UTF8.GetString(fileBytes);
            string[] lines = fullText.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            lineCount = lines.Length;
            int previewRows = Math.Min(25, lineCount);
            StringBuilder preview = new StringBuilder();
            for (int i = 0; i < previewRows; i++)
                preview.AppendLine(lines[i]);
            if (lineCount > previewRows)
                preview.AppendLine(string.Format("... [{0} more row(s) not shown]", lineCount - previewRows));
            previewText = System.Web.HttpUtility.HtmlEncode(preview.ToString());
        }
        catch
        {
            previewText = "(Binary file — text preview is not available)";
        }

        // Store in ViewState for the confirmation postback
        ViewState[VS_FILE_HASH]  = fileHash;
        ViewState[VS_FILE_NAME]  = fileName;
        ViewState[VS_LINE_COUNT] = lineCount;

        // Show preview panel
        litPreviewContent.Text = previewText;
        lblPreviewMeta.Text = string.Format(
            "<strong>File:</strong> {0} &nbsp;|&nbsp; <strong>Lines:</strong> {1} &nbsp;|&nbsp; <strong>SHA-256:</strong> <code style='font-size:11px;'>{2}</code>",
            System.Web.HttpUtility.HtmlEncode(fileName),
            lineCount,
            fileHash);

        pnlPreview.Visible = true;

        lblImportInfo.ForeColor = System.Drawing.Color.DarkGreen;
        lblImportInfo.Text = "File processed. Review the preview below and click Confirm to save the import record.";
    }

    // ─── Confirm: insert into fin_reco_bank_statement_import ─────────────────

    protected void btnConfirmImport_Click(object sender, EventArgs e)
    {
        string fileHash  = ViewState[VS_FILE_HASH]  as string;
        string fileName  = ViewState[VS_FILE_NAME]  as string;
        int lineCount    = ViewState[VS_LINE_COUNT] != null ? (int)ViewState[VS_LINE_COUNT] : 0;

        if (string.IsNullOrWhiteSpace(fileHash))
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblImportInfo.Text = "Session data expired. Please re-upload the file.";
            pnlPreview.Visible = false;
            return;
        }

        int bankAccountId;
        if (!int.TryParse(txtBankAccountId.Text.Trim(), out bankAccountId) || bankAccountId <= 0)
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblImportInfo.Text = "Bank Account ID is invalid. Please re-upload.";
            return;
        }

        DateTime statementDate;
        if (!DateTime.TryParse(txtStatementDate.Text.Trim(), out statementDate))
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblImportInfo.Text = "Statement Date is invalid. Please re-upload.";
            return;
        }

        decimal openingBalance = 0m, closingBalance = 0m;
        decimal.TryParse(txtOpeningBalance.Text.Trim(), out openingBalance);
        decimal.TryParse(txtClosingBalance.Text.Trim(), out closingBalance);

        string importFormat = ddlImportFormat.SelectedValue;
        string importedBy   = User.Identity.Name;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_reco_bank_statement_import"))
                {
                    lblImportInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblImportInfo.Text = "fin_reco_bank_statement_import table is not yet deployed. Please run the Phase 1.3 SQL script first.";
                    return;
                }

                // Duplicate hash guard
                int duplicateCount = 0;
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM fin_reco_bank_statement_import WHERE file_hash = @hash;", conn))
                {
                    chk.Parameters.AddWithValue("@hash", fileHash);
                    duplicateCount = Convert.ToInt32(chk.ExecuteScalar());
                }

                if (duplicateCount > 0)
                {
                    lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
                    lblImportInfo.Text = string.Format(
                        "Import rejected: this file has already been imported ({0} matching record(s) found). Duplicate imports are not allowed.",
                        duplicateCount);
                    pnlPreview.Visible = false;
                    return;
                }

                // Insert new record
                using (MySqlCommand ins = new MySqlCommand(@"
                    INSERT INTO fin_reco_bank_statement_import
                        (bank_account_id, imported_by, original_filename, file_hash,
                         import_format, statement_date,
                         statement_start_balance, statement_end_balance,
                         line_count, validation_status, validation_errors)
                    VALUES
                        (@bankAccId, @importedBy, @filename, @hash,
                         @format, @statDate,
                         @openBal, @closeBal,
                         @lineCount, 'Pending', 0);", conn))
                {
                    ins.Parameters.AddWithValue("@bankAccId",  bankAccountId);
                    ins.Parameters.AddWithValue("@importedBy", importedBy);
                    ins.Parameters.AddWithValue("@filename",   fileName ?? string.Empty);
                    ins.Parameters.AddWithValue("@hash",       fileHash);
                    ins.Parameters.AddWithValue("@format",     importFormat);
                    ins.Parameters.AddWithValue("@statDate",   statementDate.ToString("yyyy-MM-dd"));
                    ins.Parameters.AddWithValue("@openBal",    openingBalance);
                    ins.Parameters.AddWithValue("@closeBal",   closingBalance);
                    ins.Parameters.AddWithValue("@lineCount",  lineCount);
                    ins.ExecuteNonQuery();
                }
            }

            // Clear upload state
            ViewState.Remove(VS_FILE_HASH);
            ViewState.Remove(VS_FILE_NAME);
            ViewState.Remove(VS_LINE_COUNT);
            pnlPreview.Visible = false;

            lblImportInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblImportInfo.Text = string.Format(
                "Import record saved for '{0}'. SHA-256: {1}. Run Validation to confirm the record.",
                fileName,
                fileHash.Substring(0, 16) + "...");

            BindImportSummary();
        }
        catch (Exception ex)
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblImportInfo.Text = "Failed to save import record: " + ex.Message;
        }
    }

    protected void btnCancelUpload_Click(object sender, EventArgs e)
    {
        pnlPreview.Visible = false;
        ViewState.Remove(VS_FILE_HASH);
        ViewState.Remove(VS_FILE_NAME);
        ViewState.Remove(VS_LINE_COUNT);
        lblImportInfo.ForeColor = System.Drawing.Color.DimGray;
        lblImportInfo.Text = "Upload cancelled.";
    }

    protected void gvImports_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        if (e.CommandName != "ValidateImport")
            return;

        int importId;
        if (!int.TryParse(e.CommandArgument.ToString(), out importId))
            return;

        ExecuteImportValidation(importId);
    }

    private void BindImportSummary()
    {
        DataTable dt = CreateImportSchema();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_reco_bank_statement_import"))
                {
                    lblImportInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblImportInfo.Text = "fin_reco_bank_statement_import table is not yet available. Apply roadmap schema scripts first.";
                    gvImports.DataSource = dt;
                    gvImports.DataBind();
                    return;
                }

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT
                        import_id                                       AS ImportId,
                        COALESCE(original_filename, '(no filename)')    AS OriginalFilename,
                        DATE_FORMAT(statement_date, '%Y-%m-%d')         AS StatementDate,
                        imported_by                                     AS ImportedBy,
                        validation_status                               AS ValidationStatus,
                        reconciliation_status                           AS ReconciliationStatus
                    FROM fin_reco_bank_statement_import
                    ORDER BY import_date DESC
                    LIMIT 200;", conn))
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvImports.DataSource = dt;
            gvImports.DataBind();

            lblImportInfo.ForeColor = System.Drawing.Color.DarkGreen;
            lblImportInfo.Text = dt.Rows.Count == 0
                ? "No bank statement imports found yet."
                : string.Format("Loaded {0} bank statement import record(s).", dt.Rows.Count);
        }
        catch (Exception ex)
        {
            gvImports.DataSource = dt;
            gvImports.DataBind();
            lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblImportInfo.Text = "Unable to load bank import summary: " + ex.Message;
        }
    }

    private void ExecuteImportValidation(int importId)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                if (!FinanceSystemRealignmentHelper.TableExists(conn, "fin_reco_bank_statement_import"))
                {
                    lblImportInfo.ForeColor = System.Drawing.Color.DarkOrange;
                    lblImportInfo.Text = "Validation could not run because fin_reco_bank_statement_import is not yet available.";
                    return;
                }

                string fileHash = string.Empty;
                string importedBy = string.Empty;
                string validationStatus = string.Empty;
                int duplicateCount = 0;

                using (MySqlCommand readCmd = new MySqlCommand(@"
                    SELECT COALESCE(file_hash, ''), COALESCE(imported_by, ''), COALESCE(validation_status, 'Pending')
                    FROM fin_reco_bank_statement_import
                    WHERE import_id = @importId
                    LIMIT 1;", conn))
                {
                    readCmd.Parameters.AddWithValue("@importId", importId);
                    using (MySqlDataReader reader = readCmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
                            lblImportInfo.Text = "The selected import record could not be found.";
                            return;
                        }

                        fileHash = reader.GetString(0);
                        importedBy = reader.GetString(1);
                        validationStatus = reader.GetString(2);
                    }
                }

                if (!string.IsNullOrWhiteSpace(fileHash))
                {
                    using (MySqlCommand dupCmd = new MySqlCommand(@"
                        SELECT COUNT(*)
                        FROM fin_reco_bank_statement_import
                        WHERE file_hash = @fileHash
                          AND import_id <> @importId;", conn))
                    {
                        dupCmd.Parameters.AddWithValue("@fileHash", fileHash);
                        dupCmd.Parameters.AddWithValue("@importId", importId);
                        duplicateCount = Convert.ToInt32(dupCmd.ExecuteScalar());
                    }
                }

                string nextStatus;
                string notes;
                int validationErrors = 0;

                if (string.IsNullOrWhiteSpace(fileHash))
                {
                    nextStatus = "Failed";
                    notes = "Validation failed: file_hash is missing, so duplicate protection cannot be enforced.";
                    validationErrors = 1;
                }
                else if (duplicateCount > 0)
                {
                    nextStatus = "Failed";
                    notes = string.Format("Validation failed: duplicate file hash detected in {0} other import record(s).", duplicateCount);
                    validationErrors = duplicateCount;
                }
                else if (string.IsNullOrWhiteSpace(importedBy))
                {
                    nextStatus = "Warnings";
                    notes = "Validation warning: imported_by is missing. Record passes duplicate checks but audit ownership is incomplete.";
                    validationErrors = 1;
                }
                else
                {
                    nextStatus = "Passed";
                    notes = "Validation passed: file hash is unique and required audit metadata is present.";
                    validationErrors = 0;
                }

                using (MySqlCommand updCmd = new MySqlCommand(@"
                    UPDATE fin_reco_bank_statement_import
                    SET validation_status = @status,
                        validation_errors = @errors,
                        validation_notes = @notes
                    WHERE import_id = @importId;", conn))
                {
                    updCmd.Parameters.AddWithValue("@status", nextStatus);
                    updCmd.Parameters.AddWithValue("@errors", validationErrors);
                    updCmd.Parameters.AddWithValue("@notes", notes);
                    updCmd.Parameters.AddWithValue("@importId", importId);
                    updCmd.ExecuteNonQuery();
                }

                lblImportInfo.ForeColor = nextStatus == "Passed"
                    ? System.Drawing.Color.DarkGreen
                    : (nextStatus == "Warnings" ? System.Drawing.Color.DarkOrange : System.Drawing.Color.DarkRed);
                lblImportInfo.Text = string.Format("Import #{0} validation completed. Status: {1}.", importId, nextStatus);
            }

            BindImportSummary();
        }
        catch (Exception ex)
        {
            lblImportInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblImportInfo.Text = "Unable to execute import validation: " + ex.Message;
        }
    }

    private static DataTable CreateImportSchema()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ImportId");
        dt.Columns.Add("OriginalFilename");
        dt.Columns.Add("StatementDate");
        dt.Columns.Add("ImportedBy");
        dt.Columns.Add("ValidationStatus");
        dt.Columns.Add("ReconciliationStatus");
        return dt;
    }
}
