using CoopERPDataTableAdapters;
using DevExpress.XtraPrinting;
using MySql.Data.MySqlClient;
using System;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Accounting_xtraReports_xtraReportCentre : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        companyinfoTableAdapter comp = new companyinfoTableAdapter();
        string reportName = Session["Report"] == null ? string.Empty : Session["Report"].ToString();

        if (reportName == "Trial Balance")
        {
            TrialBalance RPT = new TrialBalance();
            fin_TrialBalanceTableAdapter TBalance = new fin_TrialBalanceTableAdapter();
            CoopERPData DS = new CoopERPData();
            TBalance.Fill(DS.fin_TrialBalance, DateTime.Parse(Session["startDate"].ToString()), DateTime.Parse(Session["endDate"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
        else if (reportName == "Income Statement" || reportName == "Statement of Income and Expenditure" || reportName == "Income and Expenditure Statement")
        {
            IncomeStatement RPT = new IncomeStatement();
            fin_IncomeStatementTableAdapter IncomeStatement = new fin_IncomeStatementTableAdapter();
            CoopERPData DS = new CoopERPData();
            IncomeStatement.Fill(DS.fin_IncomeStatement, DateTime.Parse(Session["startDate"].ToString()), DateTime.Parse(Session["endDate"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
        else if (reportName == "Balance Sheet" || reportName == "Statement of Financial Position" || reportName == "Statement of Financial Position (Balance Sheet)")
        {
            StatementOfFinancialPosition RPT = new StatementOfFinancialPosition();
            CoopERPData DS = new CoopERPData();
            DateTime startDate = DateTime.Parse(Session["startDate"].ToString());
            DateTime endDate = DateTime.Parse(Session["endDate"].ToString());

            FillStatementOfFinancialPosition(DS.fin_IncomeStatement, startDate, endDate);
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
        else if (reportName == "Legder")
        {
            AccountLedger RPT = new AccountLedger();
            fin_GetAccountLedgerTableAdapter Ledger = new fin_GetAccountLedgerTableAdapter();
            CoopERPData DS = new CoopERPData();
            Ledger.Fill(DS.fin_GetAccountLedger, Session["accno"].ToString(), DateTime.Parse(Session["startDate"].ToString()), DateTime.Parse(Session["endDate"].ToString()),
                Session["typ"].ToString(), Session["disp_curr"].ToString());
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
        else if (reportName == "StudentLedger")
        {
            StudentLedger RPT = new StudentLedger();
            RPT.Parameters["regno"].Value = Session["accno"];
            RPT.Parameters["sDate"].Value = Session["sDate"];
            RPT.Parameters["eDate"].Value = Session["eDate"];
            myReports.Report = RPT;
        }
        else if (reportName == "SupplierLedger")
        {
            SupplierLedger RPT = new SupplierLedger();
            RPT.Parameters["sid"].Value = Session["SupplierCode"];
            RPT.Parameters["sDate"].Value = Session["sDate"];
            RPT.Parameters["eDate"].Value = Session["eDate"];
            myReports.Report = RPT;
        }
        else if (reportName == "AllSupplierLedgers")
        {
            AllSupplierLedgers RPT = new AllSupplierLedgers();
            DataTable dt = Session["AllSupplierLedgersData"] as DataTable;
            DateTime sDate = Session["sDate"] != null ? Convert.ToDateTime(Session["sDate"]) : DateTime.Now;
            DateTime eDate = Session["eDate"] != null ? Convert.ToDateTime(Session["eDate"]) : DateTime.Now;
            RPT.SetData(dt, sDate, eDate);
            myReports.Report = RPT;
        }
        else if (reportName == "Fees List")
        {
            FeesTrackingList RPT = new FeesTrackingList();
            RPT.Parameters["prog"].Value = Session["prog"];
            RPT.Parameters["sess"].Value = Session["sess"];
            RPT.Parameters["acad"].Value = Session["acad"];
            RPT.Parameters["prog"].Value = Session["prog"];
            RPT.Parameters["yr"].Value = Session["yr"];
            RPT.Parameters["sem"].Value = Session["sem"];
            RPT.Parameters["stat"].Value = Session["stat"];
            RPT.Parameters["sDate"].Value = Session["sDate"];
            RPT.Parameters["eDate"].Value = Session["eDate"];
            myReports.Report = RPT;
        }
        else if (reportName == "Receipt")
        {
            ReceiptPrint RPT = new ReceiptPrint();
            RPT.Parameters["Vno"].Value = Session["accno"];
            myReports.Report = RPT;
        }
        else if (reportName == "Journal")
        {
            JournalPrint RPT = new JournalPrint();
            RPT.Parameters["jno"].Value = Session["accno"];
            myReports.Report = RPT;
        }
        else if (reportName == "Payment Voucher")
        {
            PayVoucher RPT = new PayVoucher();
            RPT.Parameters["jno"].Value = Session["accno"];
            myReports.Report = RPT;
        }
        else if (reportName == "Reconciliation")
        {
            ReconciliationStatement RPT = new ReconciliationStatement();
            RPT.Parameters["RID"].Value = Session["RID"];
            RPT.Parameters["bankcode"].Value = Session["bankcode"];
            myReports.Report = RPT;
        }
        else if (reportName == "FeesStructure")
        {
            FeesStructurePrint RPT = new FeesStructurePrint();
            StudentAccountingDataTableAdapters.fin_FeesStructurePrintTableAdapter FS = new StudentAccountingDataTableAdapters.fin_FeesStructurePrintTableAdapter();
            StudentAccountingDataTableAdapters.companyinfoTableAdapter com = new StudentAccountingDataTableAdapters.companyinfoTableAdapter();

            StudentAccountingData DS = new StudentAccountingData();
            FS.Fill(DS.fin_FeesStructurePrint, Session["acad"].ToString(), Session["prog"].ToString(), int.Parse(Session["bid"].ToString()));
            com.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
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

    private void FillStatementOfFinancialPosition(DataTable target, DateTime startDate, DateTime endDate)
    {
        DataTable source = ExecuteDataTable("CALL fin_DocumentCentre_StatementOfFinancialPosition(@sDate,@eDate)", startDate, endDate);
        string reportTitle = "STATEMENT OF FINANCIAL POSITION";
        string lastSection = string.Empty;

        foreach (DataRow sourceRow in source.Rows)
        {
            // Force the standard title for this report route; amounts still come from the DB procedure.
            reportTitle = "STATEMENT OF FINANCIAL POSITION";

            string sectionName = ReadString(sourceRow, "SectionName");
            string description = ReadString(sourceRow, "LineDescription");
            string lineType = ReadString(sourceRow, "LineType").ToUpperInvariant();
            bool hasAmount = HasValue(sourceRow, "Amount");
            decimal amount = hasAmount ? Convert.ToDecimal(sourceRow["Amount"]) : 0;

            if (!string.IsNullOrEmpty(sectionName) && sectionName != lastSection && lineType != "TOTAL" && lineType != "SUBTOTAL" && lineType != "GRANDTOTAL")
            {
                AddFinancialPositionRow(target, sectionName, string.Empty, string.Empty, reportTitle, startDate, endDate);
                lastSection = sectionName;
            }

            if (string.IsNullOrEmpty(description) && (lineType == "HEADER" || lineType == "SECTION"))
            {
                continue;
            }

            if (lineType == "TOTAL" || lineType == "SUBTOTAL" || lineType == "GRANDTOTAL")
            {
                AddFinancialPositionRow(target, description, string.Empty, hasAmount ? FormatAmount(amount) : string.Empty, reportTitle, startDate, endDate);
            }
            else
            {
                AddFinancialPositionRow(target, string.Empty, description, hasAmount ? FormatAmount(amount) : string.Empty, reportTitle, startDate, endDate);
            }
        }
    }

    private void AddFinancialPositionRow(DataTable target, string header, string accountName, string amount, string reportTitle, DateTime startDate, DateTime endDate)
    {
        DataRow targetRow = target.NewRow();

        SetSafeValue(targetRow, target, "header", Truncate(header, 45));
        SetSafeValue(targetRow, target, "startDate", startDate.ToString("dd/MM/yyyy"));
        SetSafeValue(targetRow, target, "endDate", endDate.ToString("dd/MM/yyyy"));
        SetSafeValue(targetRow, target, "accountcode", string.Empty);
        SetSafeValue(targetRow, target, "accountname", Truncate(accountName, 45));
        SetSafeValue(targetRow, target, "DRBalance", amount);
        SetSafeValue(targetRow, target, "CRBalance", string.Empty);
        SetSafeValue(targetRow, target, "docHeader", string.IsNullOrEmpty(reportTitle) ? "STATEMENT OF FINANCIAL POSITION" : reportTitle);

        foreach (DataColumn column in target.Columns)
        {
            if (targetRow.IsNull(column) && !column.AllowDBNull)
            {
                targetRow[column] = GetDefaultValue(column);
            }
        }

        target.Rows.Add(targetRow);
    }

    private void SetSafeValue(DataRow row, DataTable table, string columnName, object value)
    {
        if (!table.Columns.Contains(columnName))
        {
            return;
        }

        DataColumn column = table.Columns[columnName];
        if (value == null || value == DBNull.Value)
        {
            row[column] = column.AllowDBNull ? (object)DBNull.Value : GetDefaultValue(column);
            return;
        }

        if (column.DataType == typeof(string))
        {
            string text = value.ToString();
            if (column.MaxLength > 0 && text.Length > column.MaxLength)
            {
                text = text.Substring(0, column.MaxLength);
            }
            row[column] = text;
            return;
        }

        row[column] = value;
    }

    private object GetDefaultValue(DataColumn column)
    {
        if (column.DataType == typeof(string))
        {
            return string.Empty;
        }
        if (column.DataType == typeof(DateTime))
        {
            return DateTime.MinValue;
        }
        if (column.DataType == typeof(decimal))
        {
            return 0m;
        }
        if (column.DataType == typeof(int))
        {
            return 0;
        }
        if (column.DataType == typeof(long))
        {
            return 0L;
        }
        if (column.DataType == typeof(double))
        {
            return 0d;
        }
        if (column.DataType == typeof(float))
        {
            return 0f;
        }
        if (column.DataType == typeof(bool))
        {
            return false;
        }
        return string.Empty;
    }

    private string ReadString(DataRow row, string columnName)
    {
        if (row == null || row.Table == null || !row.Table.Columns.Contains(columnName) || row[columnName] == DBNull.Value)
        {
            return string.Empty;
        }
        return row[columnName].ToString().Trim();
    }

    private bool HasValue(DataRow row, string columnName)
    {
        return row != null && row.Table != null && row.Table.Columns.Contains(columnName) && row[columnName] != DBNull.Value;
    }

    private string FormatAmount(decimal value)
    {
        if (value == 0)
        {
            return "-";
        }
        if (value < 0)
        {
            return "(" + Math.Abs(value).ToString("N0") + ")";
        }
        return value.ToString("N0");
    }

    private string Truncate(string value, int maxLength)
    {
        if (string.IsNullOrEmpty(value) || maxLength <= 0 || value.Length <= maxLength)
        {
            return value == null ? string.Empty : value;
        }
        return value.Substring(0, maxLength);
    }
}
