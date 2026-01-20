using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HRMDataTableAdapters;

public partial class UserControls_HumanResource_XtraReportsPrinter : System.Web.UI.UserControl
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["Report"].ToString() == "MainPayroll")
        {
            MainPayroll RPT = new MainPayroll();
            hrm_payroll_detailsTableAdapter PayrollData = new hrm_payroll_detailsTableAdapter();
            hrm_payrollTableAdapter PayrolInfo = new hrm_payrollTableAdapter();
            companyinfoTableAdapter comp = new companyinfoTableAdapter();
            HRMData DS = new HRMData();
            PayrolInfo.PayrollByID(DS.hrm_payroll,int.Parse(Session["pid"].ToString()));
            PayrollData.DetailsByPayroll(DS.hrm_payroll_details,int.Parse(Session["pid"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            ReportViewer1.Report = RPT;
        }
        else if (Session["Report"].ToString() == "MainPayrollBranch")
        {
            PayrollByStation RPT = new PayrollByStation();
            hrm_payroll_detailsTableAdapter PayrollData = new hrm_payroll_detailsTableAdapter();
            hrm_payrollTableAdapter PayrolInfo = new hrm_payrollTableAdapter();
            companyinfoTableAdapter comp = new companyinfoTableAdapter();
            HRMData DS = new HRMData();
            PayrolInfo.PayrollByID(DS.hrm_payroll, int.Parse(Session["pid"].ToString()));
            PayrollData.DetailsByPayroll(DS.hrm_payroll_details, int.Parse(Session["pid"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            ReportViewer1.Report = RPT;
        }
        else if (Session["Report"].ToString() == "BankSchedule")
        {
            BankSchedules RPT = new BankSchedules();
            hrm_payroll_detailsTableAdapter PayrollData = new hrm_payroll_detailsTableAdapter();
            hrm_payrollTableAdapter PayrolInfo = new hrm_payrollTableAdapter();
            companyinfoTableAdapter comp = new companyinfoTableAdapter();
            HRMData DS = new HRMData();
            PayrolInfo.PayrollByID(DS.hrm_payroll, int.Parse(Session["pid"].ToString()));
            PayrollData.DetailsByPayroll(DS.hrm_payroll_details, int.Parse(Session["pid"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            ReportViewer1.Report = RPT;
        }
        else if (Session["Report"].ToString() == "PAYE")
        {
            PAYE_Schedule RPT = new PAYE_Schedule();
            hrm_payroll_detailsTableAdapter PayrollData = new hrm_payroll_detailsTableAdapter();
            hrm_payrollTableAdapter PayrolInfo = new hrm_payrollTableAdapter();
            companyinfoTableAdapter comp = new companyinfoTableAdapter();
            HRMData DS = new HRMData();
            PayrolInfo.PayrollByID(DS.hrm_payroll, int.Parse(Session["pid"].ToString()));
            PayrollData.DetailsByPayroll(DS.hrm_payroll_details, int.Parse(Session["pid"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            ReportViewer1.Report = RPT;
        }
        else if (Session["Report"].ToString() == "NSSF")
        {
            NSSF_Schedule RPT = new NSSF_Schedule();
            hrm_payroll_detailsTableAdapter PayrollData = new hrm_payroll_detailsTableAdapter();
            hrm_payrollTableAdapter PayrolInfo = new hrm_payrollTableAdapter();
            companyinfoTableAdapter comp = new companyinfoTableAdapter();
            HRMData DS = new HRMData();
            PayrolInfo.PayrollByID(DS.hrm_payroll, int.Parse(Session["pid"].ToString()));
            PayrollData.DetailsByPayroll(DS.hrm_payroll_details, int.Parse(Session["pid"].ToString()));
            comp.Fill(DS.companyinfo);
            RPT.DataSource = DS;
            ReportViewer1.Report = RPT;
        }
        else if (Session["Report"].ToString() == "STAFFID")
        {
            StaffIDocument RPT = new StaffIDocument();
            RPT.Parameters["ID"].Value = Session["ID"];
            ReportViewer1.Report = RPT;
        }
    }
}