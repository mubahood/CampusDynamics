using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
public partial class COOPERP_Timetables_XtraReports_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

        if (Session["Report"].ToString() == "Teaching Allocations")
        {
            TeachingAllocations RPT = new TeachingAllocations();
            RPT.Parameters["prog"].Value = Session["prog"];
            RPT.Parameters["acad"].Value = Session["acad"];
            RPT.Parameters["sems"].Value = Session["sems"];
            RPT.Parameters["cyr"].Value = Session["cyear"];
            RPT.Parameters["in_take"].Value = Session["intake"];
            RPT.Parameters["sess"].Value = Session["sess"];
            RPT.Parameters["campusno"].Value = Session["campusno"];
            RPT.Parameters["entyear"].Value = Session["EntYr"];
            ReportViewer1.Report = RPT;

            /* Session["prog"] = txtProgramme.Value;
        Session["acad"] = txtAcad.Text;
        Session["sems"] = txtSemester.Text;
        Session["cyear"] = txtStudyYear.Text;
        Session["intake"] = txtintake.Text;
        Session["sess"] = txtsession.Text;
        Session["campusno"] = txtCampus.Value;*/
        }
        else if (Session["Report"].ToString() == "Coursework Timetable")
        {
            CourseworkTimetables RPT = new CourseworkTimetables();
            RPT.Parameters["prog"].Value = Session["prog"];
            RPT.Parameters["acad"].Value = Session["acad"];
            RPT.Parameters["sems"].Value = Session["sems"];
            RPT.Parameters["cyr"].Value = Session["cyear"];
            RPT.Parameters["in_take"].Value = Session["intake"];
            RPT.Parameters["sess"].Value = Session["sess"];
            RPT.Parameters["campusno"].Value = Session["campusno"];
            ReportViewer1.Report = RPT;
        }
        else if (Session["Report"].ToString() == "Exam Timetable")
        {
            ExamTimetable RPT = new ExamTimetable();
            RPT.Parameters["fac"].Value = Session["fac"];
            RPT.Parameters["prog"].Value = Session["prog"];
            RPT.Parameters["acad"].Value = Session["acad"];
            RPT.Parameters["sems"].Value = Session["sems"];
            RPT.Parameters["cyr"].Value = Session["cyear"];
            RPT.Parameters["in_take"].Value = Session["intake"];
            RPT.Parameters["sess"].Value = Session["sess"];
            RPT.Parameters["entyr"].Value = int.Parse(Session["entyr"].ToString());
            RPT.Parameters["campusno"].Value = Session["campusno"];
            RPT.Parameters["exmtyp"].Value = Session["exmtyp"];
            ReportViewer1.Report = RPT;
        }

        //else if (Session["Report"].ToString() == "ExamPaper")
        //{
        //    ExaminationPaper pap = new ExaminationPaper();
        //    pap.Parameters["ExamNo"].Value = long.Parse(Session["mid"].ToString());
        //    ReportViewer1.Report = pap;
        //}
       
         
    }
}