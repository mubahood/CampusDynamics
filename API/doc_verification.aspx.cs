using ResultsDataTableAdapters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class API_doc_verification : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request["doc"] == "ResultStatement")
        {
            Transcript RPT = new Transcript();
            acad_GetStudentTranscriptTableAdapter ResStatement = new acad_GetStudentTranscriptTableAdapter();
            acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
            ResultsData DS = new ResultsData();
            ResStatement.Fill(DS.acad_GetStudentTranscript, Request["reg"].ToString());
            UNIV.Fill(DS.acad_university);
            RPT.DataSource = DS;
            ReportViewer1.Report = RPT;
        }
        else if (Request["doc"] == "Transcript")
        {
            acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
            acad_GetBatchStudentTranscript_Col1TableAdapter COL_1 = new acad_GetBatchStudentTranscript_Col1TableAdapter();
            acad_GetBatchStudentTranscript_Col2TableAdapter COL_2 = new acad_GetBatchStudentTranscript_Col2TableAdapter();
            acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
            ResultsData DS = new ResultsData();
            ResStatement.SingleTranscript(DS.acad_GetBatchStudentTranscriptData, Request["reg"].ToString());
            //ResStatement.Fill(DS.acad_GetBatchStudentTranscriptData, Session["prog"].ToString(), Session["acad"].ToString());
            UNIV.Fill(DS.acad_university);
            FinalTranscript TRANS_RPT = new FinalTranscript();
            TRANS_RPT.DataSource = (DS);
            ReportViewer1.Report = TRANS_RPT;
            // Response.Write(string.Format("Printing Marksheet PG{0},ACAD {1}", Session["prog"].ToString(), Session["acad"].ToString()));
        }
       else if (Request["doc"] == "Certificate")
        {
            Certificate RPT = new Certificate();
            acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
            acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
            ResultsData DS = new ResultsData();
            UNIV.Fill(DS.acad_university);
            ResStatement.SingleTranscript(DS.acad_GetBatchStudentTranscriptData, Request["reg"].ToString());
            RPT.DataSource = DS;
            ReportViewer1.Report = RPT;
        }


        else if (Request["doc"] == "StudentLedger")
        {
            StudentLedger RPT = new StudentLedger();
            RPT.Parameters["regno"].Value = Request["reg"];
            RPT.Parameters["sDate"].Value = DateTime.Today.AddYears(-3);
            RPT.Parameters["eDate"].Value = DateTime.Today;
            ReportViewer1.Report = RPT;

        }

        else if (Request["doc"] == "Student Exam Card")
        {
            ExamPass RPT = new ExamPass();
            RPT.Parameters["acad"].Value = Request["acadyear"];
            RPT.Parameters["sem"].Value = Request["sem"];
            RPT.Parameters["reg"].Value = Request["reg"];
            RPT.Parameters["prog"].Value = "-";
            RPT.Parameters["entyear"].Value = 0;
            RPT.Parameters["typ"].Value = Request["typ"];

            ReportViewer1.Report = RPT;
        }
    }
}