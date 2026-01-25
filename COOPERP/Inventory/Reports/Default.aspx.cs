using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using examsDataTableAdapters;
using admissions_and_classesTableAdapters;
using CrystalDecisions.CrystalReports.Engine;
using MySql.Data.MySqlClient;
using System.IO;
using SchoolInventoryTableAdapters;

public partial class COOPERP_examinations_Reports_Default : System.Web.UI.Page
{

     ReportDocument myRpt = new ReportDocument();
     SchoolInventory DS = new SchoolInventory();

    protected void Page_Load(object sender, EventArgs e)
    {

        if (Session["report"].ToString() == "MaterialsReport")
        {
            inv_GetTermlyMaterialsReportTableAdapter REP = new inv_GetTermlyMaterialsReportTableAdapter();
            REP.Fill(DS.inv_GetTermlyMaterialsReport,int.Parse(Session["term"].ToString()),int.Parse(Session["year"].ToString()));
            myRpt.Load(Server.MapPath("AnnualSummary.rpt"));
            myRpt.SetDataSource(DS);
            myReportsViewer.ReportSource = myRpt;

        }

        else
        {

        }
    }
    protected void Page_PreInit(object sender, EventArgs e)
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

    protected void myReports_Unload(object sender, EventArgs e)
    {
        myRpt.Dispose();
    }
}
            