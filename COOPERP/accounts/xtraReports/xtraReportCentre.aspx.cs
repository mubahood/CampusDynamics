using CoopERPDataTableAdapters;
using DevExpress.XtraPrinting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


public partial class Accounting_xtraReports_xtraReportCentre : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        companyinfoTableAdapter comp = new companyinfoTableAdapter();

        if (Session["Report"].ToString() == "Trial Balance")
        {
            TrialBalance RPT = new TrialBalance();
            fin_TrialBalanceTableAdapter TBalance = new fin_TrialBalanceTableAdapter();
            CoopERPData DS = new CoopERPData();
            TBalance.Fill(DS.fin_TrialBalance, DateTime.Parse(Session["startDate"].ToString()), DateTime.Parse(Session["endDate"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
        else if (Session["Report"].ToString() == "Income Statement")
        {
            IncomeStatement RPT = new IncomeStatement();
            fin_IncomeStatementTableAdapter IncomeStatement = new fin_IncomeStatementTableAdapter();
            CoopERPData DS = new CoopERPData();
            IncomeStatement.Fill(DS.fin_IncomeStatement, DateTime.Parse(Session["startDate"].ToString()), DateTime.Parse(Session["endDate"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
        else if (Session["Report"].ToString() == "Balance Sheet")
        {
            IncomeStatement RPT = new IncomeStatement();
            fin_IncomeStatementTableAdapter IncomeStatement = new fin_IncomeStatementTableAdapter();
            CoopERPData DS = new CoopERPData();
            IncomeStatement.BalanceSheet(DS.fin_IncomeStatement, DateTime.Parse(Session["startDate"].ToString()), DateTime.Parse(Session["endDate"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
        else if (Session["Report"].ToString() == "Legder")
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
        else if (Session["Report"].ToString() == "StudentLedger")
        {

            StudentLedger RPT = new StudentLedger();
            RPT.Parameters["regno"].Value = Session["accno"];
            RPT.Parameters["sDate"].Value = Session["sDate"];
            RPT.Parameters["eDate"].Value = Session["eDate"];
            myReports.Report = RPT;
           
        }
        else if (Session["Report"].ToString() == "SupplierLedger")
        {

            SupplierLedger RPT = new SupplierLedger();
            RPT.Parameters["sid"].Value = Session["SupplierCode"];
            RPT.Parameters["sDate"].Value = Session["sDate"];
            RPT.Parameters["eDate"].Value = Session["eDate"];
            myReports.Report = RPT;

        }
        else if (Session["Report"].ToString() == "Fees List")
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
        else if (Session["Report"].ToString() == "Receipt")
        {

            ReceiptPrint RPT = new ReceiptPrint();
            RPT.Parameters["Vno"].Value = Session["accno"];
            myReports.Report = RPT;

        }
        else if (Session["Report"].ToString() == "Journal")
        {

            JournalPrint RPT = new JournalPrint();
            RPT.Parameters["jno"].Value = Session["accno"];
            myReports.Report = RPT;

        }
        else if (Session["Report"].ToString() == "Payment Voucher")
        {

            PayVoucher RPT = new PayVoucher();
            RPT.Parameters["jno"].Value = Session["accno"];
            myReports.Report = RPT;

        }
        else if (Session["Report"].ToString() == "Reconciliation")
        {
            ReconciliationStatement RPT = new ReconciliationStatement();
            RPT.Parameters["RID"].Value = Session["RID"];
            RPT.Parameters["bankcode"].Value = Session["bankcode"];
            myReports.Report = RPT;
        }
        else if (Session["Report"].ToString() == "FeesStructure")
        {
            FeesStructurePrint RPT = new FeesStructurePrint();
            StudentAccountingDataTableAdapters.fin_FeesStructurePrintTableAdapter FS = new StudentAccountingDataTableAdapters.fin_FeesStructurePrintTableAdapter();
            StudentAccountingDataTableAdapters.companyinfoTableAdapter com = new StudentAccountingDataTableAdapters.companyinfoTableAdapter();

            StudentAccountingData DS = new StudentAccountingData();
            FS.Fill(DS.fin_FeesStructurePrint,Session["acad"].ToString(),Session["prog"].ToString(),int.Parse(Session["bid"].ToString()));
            com.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
    }
}