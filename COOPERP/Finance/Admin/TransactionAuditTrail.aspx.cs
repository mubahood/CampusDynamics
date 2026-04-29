using System;
using System.Data;
using System.IO;
using System.Text;
using MySql.Data.MySqlClient;
using DevExpress.XtraReports.UI;

public partial class COOPERP_Finance_Admin_TransactionAuditTrail : System.Web.UI.Page
{
    private const string AuditExportSessionKey = "FinanceAuditTrailExportData";

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

    protected void btnExportAuditPdf_Click(object sender, EventArgs e)
    {
        DataTable dt = Session[AuditExportSessionKey] as DataTable;
        if (dt == null || dt.Rows.Count == 0)
        {
            lblAuditInfo.ForeColor = System.Drawing.Color.DarkOrange;
            lblAuditInfo.Text = "There is no audit data to export. Run a search first.";
            return;
        }

        XtraReport report = BuildAuditReport(dt, txtAuditSearch.Text.Trim());
        using (MemoryStream ms = new MemoryStream())
        {
            report.ExportToPdf(ms);
            ms.Position = 0;
            Response.Clear();
            Response.ContentType = "application/pdf";
            Response.AddHeader("content-disposition", "attachment;filename=Transaction_Audit_Trail_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".pdf");
            Response.BinaryWrite(ms.ToArray());
            Response.Flush();
            Response.End();
        }
    }

    protected void gvAudit_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
    {
        if (e.CommandName != "ViewAuditDetail")
            return;

        ShowAuditDetail(e.CommandArgument.ToString());
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
                        log_id AS LogId,
                        DATE_FORMAT(changed_at, '%Y-%m-%d %H:%i') AS ActionTime,
                        action AS ActionName,
                        changed_by AS ChangedBy,
                        COALESCE(reason_code, '-') AS ReasonCode,
                        CONCAT(table_name, '#', COALESCE(record_id, 0)) AS TargetRecord,
                        COALESCE(CAST(old_value AS CHAR), '') AS OldValue,
                        COALESCE(CAST(new_value AS CHAR), '') AS NewValue,
                        COALESCE(reason_text, '') AS ReasonText
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
            Session[AuditExportSessionKey] = dt;

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
        dt.Columns.Add("LogId", typeof(long));
        dt.Columns.Add("ActionTime");
        dt.Columns.Add("ActionName");
        dt.Columns.Add("ChangedBy");
        dt.Columns.Add("ReasonCode");
        dt.Columns.Add("TargetRecord");
        dt.Columns.Add("OldValue");
        dt.Columns.Add("NewValue");
        dt.Columns.Add("ReasonText");
        return dt;
    }

    private void ShowAuditDetail(string logId)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(FinanceSystemRealignmentHelper.GetFinanceConnectionString()))
            {
                conn.Open();

                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT action, changed_by, changed_at, table_name, record_id,
                           COALESCE(CAST(old_value AS CHAR), '') AS old_value,
                           COALESCE(CAST(new_value AS CHAR), '') AS new_value,
                           COALESCE(reason_text, '') AS reason_text
                    FROM fin_transaction_log
                    WHERE log_id = @id
                    LIMIT 1;", conn))
                {
                    cmd.Parameters.AddWithValue("@id", logId);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                        {
                            pnlAuditDetail.Visible = false;
                            return;
                        }

                        lblAuditDetailHeader.Text = string.Format(
                            "<b>Action:</b> {0} &nbsp;|&nbsp; <b>Changed By:</b> {1} &nbsp;|&nbsp; <b>When:</b> {2} &nbsp;|&nbsp; <b>Target:</b> {3}#{4}",
                            Server.HtmlEncode(rdr["action"].ToString()),
                            Server.HtmlEncode(rdr["changed_by"].ToString()),
                            rdr["changed_at"] == DBNull.Value ? "-" : Convert.ToDateTime(rdr["changed_at"]).ToString("yyyy-MM-dd HH:mm"),
                            Server.HtmlEncode(rdr["table_name"].ToString()),
                            rdr["record_id"] == DBNull.Value ? "0" : rdr["record_id"].ToString());

                        txtOldValue.Text = BeautifyJson(rdr["old_value"].ToString());
                        txtNewValue.Text = BeautifyJson(rdr["new_value"].ToString());
                        lblAuditReasonText.Text = Server.HtmlEncode(rdr["reason_text"].ToString());
                        pnlAuditDetail.Visible = true;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            pnlAuditDetail.Visible = false;
            lblAuditInfo.ForeColor = System.Drawing.Color.DarkRed;
            lblAuditInfo.Text = "Unable to load audit detail: " + ex.Message;
        }
    }

    private static string BeautifyJson(string json)
    {
        if (string.IsNullOrWhiteSpace(json))
            return "(empty)";

        json = json.Trim();
        if (!(json.StartsWith("{") || json.StartsWith("[")))
            return json;

        StringBuilder sb = new StringBuilder();
        int indent = 0;
        bool inQuotes = false;
        for (int i = 0; i < json.Length; i++)
        {
            char ch = json[i];
            if (ch == '"' && (i == 0 || json[i - 1] != '\\'))
                inQuotes = !inQuotes;

            if (!inQuotes)
            {
                if (ch == '{' || ch == '[')
                {
                    sb.Append(ch).AppendLine();
                    indent++;
                    sb.Append(new string(' ', indent * 2));
                    continue;
                }
                if (ch == '}' || ch == ']')
                {
                    sb.AppendLine();
                    indent = Math.Max(0, indent - 1);
                    sb.Append(new string(' ', indent * 2)).Append(ch);
                    continue;
                }
                if (ch == ',')
                {
                    sb.Append(ch).AppendLine().Append(new string(' ', indent * 2));
                    continue;
                }
                if (ch == ':')
                {
                    sb.Append(": ");
                    continue;
                }
            }

            sb.Append(ch);
        }
        return sb.ToString();
    }

    private static XtraReport BuildAuditReport(DataTable dt, string filterText)
    {
        XtraReport report = new XtraReport();
        report.DataSource = dt;
        report.PaperKind = System.Drawing.Printing.PaperKind.A4;
        report.Landscape = true;
        report.Margins = new System.Drawing.Printing.Margins(30, 30, 30, 30);

        ReportHeaderBand header = new ReportHeaderBand();
        header.HeightF = 70;
        report.Bands.Add(header);

        XRLabel title = new XRLabel();
        title.Text = "Finance Transaction Audit Trail";
        title.Font = new System.Drawing.Font("Arial", 14, System.Drawing.FontStyle.Bold);
        title.BoundsF = new System.Drawing.RectangleF(0, 0, 700, 24);
        header.Controls.Add(title);

        XRLabel subtitle = new XRLabel();
        subtitle.Text = string.IsNullOrWhiteSpace(filterText) ? "Current audit results" : "Filter: " + filterText;
        subtitle.Font = new System.Drawing.Font("Arial", 9);
        subtitle.BoundsF = new System.Drawing.RectangleF(0, 28, 700, 18);
        header.Controls.Add(subtitle);

        XRLabel generated = new XRLabel();
        generated.Text = "Generated: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm");
        generated.Font = new System.Drawing.Font("Arial", 8);
        generated.BoundsF = new System.Drawing.RectangleF(0, 48, 700, 16);
        header.Controls.Add(generated);

        DetailBand detail = new DetailBand();
        detail.HeightF = 22;
        report.Bands.Add(detail);

        string[] fields = { "ActionTime", "ActionName", "ChangedBy", "ReasonCode", "TargetRecord", "ReasonText" };
        float[] widths = { 110f, 90f, 90f, 90f, 120f, 250f };

        PageHeaderBand pageHeader = new PageHeaderBand();
        pageHeader.HeightF = 24;
        report.Bands.Add(pageHeader);

        float left = 0;
        for (int i = 0; i < fields.Length; i++)
        {
            XRLabel hdr = new XRLabel();
            hdr.Text = fields[i];
            hdr.BackColor = System.Drawing.Color.FromArgb(5, 39, 92);
            hdr.ForeColor = System.Drawing.Color.White;
            hdr.Font = new System.Drawing.Font("Arial", 8, System.Drawing.FontStyle.Bold);
            hdr.Borders = DevExpress.XtraPrinting.BorderSide.All;
            hdr.BoundsF = new System.Drawing.RectangleF(left, 0, widths[i], 24);
            pageHeader.Controls.Add(hdr);

            XRLabel val = new XRLabel();
            val.ExpressionBindings.Add(new ExpressionBinding("BeforePrint", "Text", "[" + fields[i] + "]"));
            val.Font = new System.Drawing.Font("Arial", 8);
            val.Borders = DevExpress.XtraPrinting.BorderSide.All;
            val.Multiline = true;
            val.CanGrow = false;
            val.BoundsF = new System.Drawing.RectangleF(left, 0, widths[i], 22);
            detail.Controls.Add(val);

            left += widths[i];
        }

        return report;
    }
}
