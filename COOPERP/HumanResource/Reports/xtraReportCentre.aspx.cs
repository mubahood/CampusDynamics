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

        if (Session["Report"].ToString() == "Payroll")
        {
            GeneralPayroll RPT = new GeneralPayroll();
            RPT.Parameters["payrollID"].Value = Session["pid"];
            RPT.Parameters["brch"].Value = Session["branch"];
            myReports.Report = RPT;
        }
        if (Session["Report"].ToString() == "SpecialPayroll")
        {
            SpecialPayments RPT = new SpecialPayments();
            HRMData DS = new HRMData();
            HRMDataTableAdapters.hrm_special_paymentsTableAdapter SPEC = new HRMDataTableAdapters.hrm_special_paymentsTableAdapter();
            HRMDataTableAdapters.acad_universityTableAdapter UNIV = new HRMDataTableAdapters.acad_universityTableAdapter();
            SPEC.SpecialPayList(DS.hrm_special_payments,int.Parse(Session["pid"].ToString()));
            UNIV.Fill(DS.acad_university);
            RPT.DataSource = DS;
            myReports.Report = RPT;
        }
       
    }
}