using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using HRMDataTableAdapters;
using CrystalDecisions.CrystalReports.Engine;
using MySql.Data.MySqlClient;
using System.IO;

public partial class COOPERP_examinations_Reports_Default : System.Web.UI.Page
{
    
     ReportDocument myRpt = new ReportDocument();
    HRMData DS = new HRMData();

    protected void Page_Load(object sender, EventArgs e)
    {
        DS.EnforceConstraints = false;

        if (Session["Report"].ToString() == "LargePayroll")
        {
            hrm_GetPayrollDetailsFullTableAdapter PR = new hrm_GetPayrollDetailsFullTableAdapter();
            acad_universityTableAdapter COMP = new acad_universityTableAdapter();
            PR.Fill(DS.hrm_GetPayrollDetailsFull, int.Parse(Session["pid"].ToString()),Session["branch"].ToString());
            COMP.Fill(DS.acad_university);
            myRpt.Load(Server.MapPath("LargePayroll.rpt"));
            myRpt.SetDataSource(DS);
            myReportsViewer.ReportSource = myRpt;
        }
    }

   
    protected void myReports_Unload(object sender, EventArgs e)
    {
        myRpt.Dispose();
    }
}
            