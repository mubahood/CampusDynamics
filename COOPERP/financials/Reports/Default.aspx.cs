using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using CrystalDecisions.CrystalReports.Engine;
using StudentAccountingDataTableAdapters;

public partial class Accounting_Reports_Default : System.Web.UI.Page
{
    readonly ReportDocument myRpt = new ReportDocument();
    readonly StudentAccountingData studACCDS = new StudentAccountingData();
    protected void Page_Load(object sender, EventArgs e)
    {

        try
        {
            if (Session["ReportType"].ToString() == "ScholarshipList")
            {
                //Response.Write(string.Format("Wuuuuuuuuuuuuuu! SID={0}, Year:={1}, Term:{2}",Session["sid"].ToString(),Session["year"].ToString(), Session["term"]));
                StudentAccountingDataTableAdapters.schoolTableAdapter sch = new StudentAccountingDataTableAdapters.schoolTableAdapter();
                 scholarshipstudentsTableAdapter list = new scholarshipstudentsTableAdapter();   
                 list.ScholarshipStudent(studACCDS.scholarshipstudents, int.Parse(Session["sid"].ToString()), int.Parse(Session["year"].ToString()), 
                     int.Parse(Session["term"].ToString()));
                 sch.Fill(studACCDS.school);
                myRpt.Load(Server.MapPath("ScholarshipLists.rpt")); //
                myRpt.SetDataSource(studACCDS);
                financeReportViewer.ReportSource = myRpt;
            }

            /*
             else if (Session["ReportType"] == "CorePayroll")
             {
                 using (financeDataTableAdapters.smis_fin_PayrollDetailsByIDTableAdapter Payroll = new financeDataTableAdapters.smis_fin_PayrollDetailsByIDTableAdapter())
                 {
                     Payroll.Fill(FinanceDS.smis_fin_PayrollDetailsByID, long.Parse(Session["PID"].ToString()));
                     using (financeDataTableAdapters.schoolTableAdapter school = new financeDataTableAdapters.schoolTableAdapter())
                     {
                        
                         school.Fill(FinanceDS.school);
                     }
                    
                 }
                 if (Session["subreport"] == "paye")
                 {
                     myRpt.Load(Server.MapPath("PayeSchedule.rpt")); //
                 }
                 else if (Session["subreport"] == "nssf")
                 {
                     myRpt.Load(Server.MapPath("Nssfschedule.rpt")); //
                 }
                 else
                 {
                     myRpt.Load(Server.MapPath("PayrollMain.rpt")); //
                 }
                 myRpt.SetDataSource(FinanceDS);
                 financeReportViewer.ReportSource = myRpt;

             }
             */
            


        }
        catch (Exception ex)
        {
            lbl_comments.Text = "Error: " + ex.Message;
        }
        

    }

    protected void myReports_Unload(object sender, EventArgs e)
    {
        myRpt.Dispose();
    }

    protected void Page_PreInit()
    {
        HttpCookie cookie = Request.Cookies.Get("themeCookie");
        if (cookie == null)
        {
            Page.Theme = "Glass"; //default theme
        }
        else
        {
            Page.Theme = cookie.Value;
        }
    }

    //string MapPath(string filename)
    //{
    //    return string.Format("E:/Projects/SchoolMIS/Accounting/Reports/{0}", filename);
    //}
}