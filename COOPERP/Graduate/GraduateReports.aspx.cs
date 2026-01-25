using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class COOPERP_Graduate_GraduateReports : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Int32.Parse( Session["Reportname"].ToString()) == 0) 
        {
            SuperviorLetter report = new SuperviorLetter();
            report.Parameters["rid"].Value = Session["ReschID"];
            gradReportDV.Report = report;
        }

        else if (Int32.Parse(Session["Reportname"].ToString()) == 1)
        {
            Recommendation report = new Recommendation();
            report.Parameters["rid"].Value = Session["ReschID"];
            gradReportDV.Report = report;
        }

        else if (Int32.Parse(Session["Reportname"].ToString()) == 2)
        {
            FieldLetter report = new FieldLetter();
            report.Parameters["rid"].Value = Session["ReschID"];
            gradReportDV.Report = report;
        }
        else if (Int32.Parse(Session["Reportname"].ToString()) == 3)
        {
            AppointmentReviewer report = new AppointmentReviewer();
            report.Parameters["ReId"].Value = Session["ReschID"];
            gradReportDV.Report = report;
        }
    }
}