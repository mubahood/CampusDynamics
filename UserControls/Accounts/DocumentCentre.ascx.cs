using CoopERPDataTableAdapters;
using DevExpress.Web;
using MySql.Data.MySqlClient;
using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

    public partial class UserControls_Accounts_DocumentCentre : System.Web.UI.UserControl
    {
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (DateTime.Today.Month < 8)
            {
                txtStartDate.Value = "08/01/" + DateTime.Today.AddYears(-1).Year;
            }
            else
            {
                txtStartDate.Value = "08/01/" + DateTime.Today.Year;
            }
            txtEndDate.Text = DateTime.Today.ToShortDateString();
        }

        pop_receipts.Width = 1000;
        pop_receipts.Height = 600;
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        BindDocumentPreview();
    }

    private void BindDocumentPreview()
    {
        lbl_msg.Text = string.Empty;

        DateTime startDate;
        DateTime endDate;
        if (!TryReadDates(out startDate, out endDate))
        {
            gvDocumentPreview.Columns.Clear();
            gvDocumentPreview.DataSource = null;
            gvDocumentPreview.DataBind();
            return;
        }

        string documentType = GetDocumentType();
        DataTable previewData = null;

        try
        {
            if (documentType == "Trial Balance")
            {
                fin_TrialBalanceTableAdapter trialBalance = new fin_TrialBalanceTableAdapter();
                previewData = trialBalance.GetData(startDate, endDate);
            }
            else if (documentType == "Income Statement")
            {
                fin_IncomeStatementTableAdapter incomeStatement = new fin_IncomeStatementTableAdapter();
                previewData = incomeStatement.GetData(startDate, endDate);
            }
            else if (documentType == "Balance Sheet")
            {
                previewData = GetStatementOfFinancialPosition(startDate, endDate);
            }
            else if (documentType == "Cash Flow Statement")
            {
                previewData = GetCashFlowStatement(startDate, endDate);
            }
            else if (documentType == "Cashbook")
            {
                previewData = GetCashbook(startDate, endDate);
            }
            else if (documentType == "General Ledger")
            {
                previewData = GetGeneralLedgerSummary(startDate, endDate);
            }
            else if (documentType == "Payments")
            {
                previewData = GetPaymentsReport(startDate, endDate);
            }
            else if (documentType == "Defaulters")
            {
                previewData = GetReceivablesDefaulters(startDate, endDate);
            }
            else if (documentType == "Payables")
            {
                previewData = GetPayables(startDate, endDate);
            }
            else if (documentType == "Statement of Changes in Fund")
            {
                previewData = GetStatementOfChangesInFund(startDate, endDate);
            }

            BuildPreviewColumns(previewData, documentType);
            gvDocumentPreview.DataSource = previewData;
            gvDocumentPreview.DataBind();

            if (previewData == null || previewData.Rows.Count == 0)
            {
                lbl_msg.Text = "No records found for the selected document and date range.";
            }
        }
        catch (Exception ex)
        {
            gvDocumentPreview.Columns.Clear();
            gvDocumentPreview.DataSource = null;
            gvDocumentPreview.DataBind();
            lbl_msg.Text = ex.Message;
        }
    }

    private string GetDocumentType()
    {
        string documentType = txtDocumentType.Value == null ? txtDocumentType.Text : txtDocumentType.Value.ToString();

        if (documentType == "Income and Expenditure Statement" || documentType == "Statement of Income and Expenditure")
        {
            return "Income Statement";
        }
        if (documentType.IndexOf("Statement of Financial Position", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return "Balance Sheet";
        }
        if (documentType.IndexOf("Receivables", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return "Defaulters";
        }
        if (documentType.IndexOf("Statement of Cash Flows", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return "Cash Flow Statement";
        }
        if (documentType.IndexOf("Fund", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return "Statement of Changes in Fund";
        }

        return documentType;
    }

    private bool TryReadDates(out DateTime startDate, out DateTime endDate)
    {
        startDate = DateTime.MinValue;
        endDate = DateTime.MinValue;

        if (!DateTime.TryParse(txtStartDate.Text, out startDate))
        {
            lbl_msg.Text = "Please select a valid start date.";
            return false;
        }

        if (!DateTime.TryParse(txtEndDate.Text, out endDate))
        {
            lbl_msg.Text = "Please select a valid end date.";
            return false;
        }

        if (startDate > endDate)
        {
            lbl_msg.Text = "Start date cannot be after end date.";
            return false;
        }

        return true;
    }

    private void BuildPreviewColumns(DataTable dataTable, string documentType)
    {
        gvDocumentPreview.Columns.Clear();

        if (dataTable == null)
        {
            return;
        }

        if (HasColumns(dataTable, "SectionName", "LineDescription", "Amount"))
        {
            AddPreviewColumn(dataTable, "SectionName", "Section", false);
            AddPreviewColumn(dataTable, "LineDescription", "Description", false);
            AddPreviewColumn(dataTable, "Amount", "Amount", true);
            return;
        }

        if (documentType == "Income Statement" || documentType == "Balance Sheet")
        {
            AddPreviewColumn(dataTable, "header", "Section", false);
            AddPreviewColumn(dataTable, "accountname", "Description", false);
            AddPreviewColumn(dataTable, "DRBalance", "Amount", true);
            return;
        }

        if (documentType == "Trial Balance")
        {
            AddPreviewColumn(dataTable, "MAC", "Main Account", false);
            AddPreviewColumn(dataTable, "category", "Category", false);
            AddPreviewColumn(dataTable, "subcategory", "Sub Category", false);
            AddPreviewColumn(dataTable, "accountcode", "Account Code", false);
            AddPreviewColumn(dataTable, "accountname", "Account Name", false);
            AddPreviewColumn(dataTable, "DRBalance", "DR", true);
            AddPreviewColumn(dataTable, "CRBalance", "CR", true);
            return;
        }

        foreach (DataColumn column in dataTable.Columns)
        {
            if (!IsInternalColumn(column.ColumnName))
            {
                AddGridColumn(column.ColumnName, column.Caption, IsAmountColumn(column));
            }
        }
    }

    private bool HasColumns(DataTable dataTable, params string[] columnNames)
    {
        foreach (string columnName in columnNames)
        {
            if (!dataTable.Columns.Contains(columnName))
            {
                return false;
            }
        }
        return true;
    }

    private bool IsInternalColumn(string columnName)
    {
        string name = columnName.ToUpperInvariant();
        return name == "ROWNO" || name == "REPORTTITLE" || name == "DATECAPTION" || name == "LINETYPE";
    }

    private void AddPreviewColumn(DataTable dataTable, string fieldName, string caption, bool alignRight)
    {
        if (dataTable.Columns.Contains(fieldName))
        {
            AddGridColumn(fieldName, caption, alignRight);
        }
    }

    private void AddGridColumn(string fieldName, string caption, bool alignRight)
    {
        GridViewDataTextColumn column = new GridViewDataTextColumn();
        column.FieldName = fieldName;
        column.Caption = caption;
        column.VisibleIndex = gvDocumentPreview.Columns.Count;
        column.ShowInCustomizationForm = true;

        if (alignRight)
        {
            column.CellStyle.HorizontalAlign = HorizontalAlign.Right;
            column.PropertiesTextEdit.DisplayFormatString = "{0:#,##0;(#,##0);-}";
        }

        gvDocumentPreview.Columns.Add(column);
    }

    private bool IsAmountColumn(DataColumn column)
    {
        if (column.DataType == typeof(decimal) || column.DataType == typeof(double) || column.DataType == typeof(float) || column.DataType == typeof(int) || column.DataType == typeof(long))
        {
            return true;
        }

        string name = column.ColumnName.ToUpperInvariant();
        return name.Contains("AMOUNT") || name.Contains("BALANCE") || name.Contains("TOTAL") || name.Contains("DR") || name.Contains("CR") || name.Contains("DEBIT") || name.Contains("CREDIT") || name.Contains("INFLOW") || name.Contains("OUTFLOW") || name.Contains("PAYMENT") || name.Contains("PAYMENTS") || name.Contains("RECEIPT") || name.Contains("RECEIPTS") || name.Contains("NET") || name.Contains("SURPLUS") || name.Contains("DEFICIT");
    }

    private string AccountsConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString; }
    }

    private DataTable ExecuteDataTable(string sql, DateTime startDate, DateTime endDate)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(AccountsConnectionString))
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
        {
            cmd.Parameters.Add("@sDate", MySqlDbType.Date).Value = startDate.Date;
            cmd.Parameters.Add("@eDate", MySqlDbType.Date).Value = endDate.Date;
            da.Fill(dt);
        }
        return dt;
    }

    private DataTable GetCashbook(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_Cashbook(@sDate,@eDate)", startDate, endDate);
    }

    private DataTable GetPaymentsReport(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_Payments(@sDate,@eDate)", startDate, endDate);
    }

    private DataTable GetGeneralLedgerSummary(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_GeneralLedgerSummary(@sDate,@eDate)", startDate, endDate);
    }

    private DataTable GetReceivablesDefaulters(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_ReceivablesDefaulters(@sDate,@eDate)", startDate, endDate);
    }

    private DataTable GetPayables(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_Payables(@sDate,@eDate)", startDate, endDate);
    }

    private DataTable GetCashFlowStatement(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_CashFlow(@sDate,@eDate)", startDate, endDate);
    }

    private DataTable GetStatementOfChangesInFund(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_FundChanges(@sDate,@eDate)", startDate, endDate);
    }

    private DataTable GetStatementOfFinancialPosition(DateTime startDate, DateTime endDate)
    {
        return ExecuteDataTable("CALL fin_DocumentCentre_StatementOfFinancialPosition(@sDate,@eDate)", startDate, endDate);
    }

    protected void cmdPrint_Click(object sender, EventArgs e)
    {
        string documentType = GetDocumentType();

        Session["startDate"] = txtStartDate.Text;
        Session["endDate"] = txtEndDate.Text;

        if (documentType == "Trial Balance" || documentType == "Income Statement" || documentType == "Balance Sheet")
        {
            Session["Report"] = documentType;
            pop_receipts.ShowOnPageLoad = true;
            return;
        }

        BindDocumentPreview();
        gvDocumentPreviewExporter.WritePdfToResponse(GetSafeFileName(documentType));
    }

    private string GetSafeFileName(string documentType)
    {
        string fileName = documentType.Replace("/", "_").Replace("\\", "_").Replace(":", "_").Replace(" ", "_");
        return fileName + "_" + DateTime.Today.ToString("yyyyMMdd");
    }
}
