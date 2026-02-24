using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ResultsDataTableAdapters;
using System.IO;
public partial class COOPERP_XtraReports_Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            if (Session["Report"].ToString() == "ResultStatement")
            {
                ResultsStatement RPT = new ResultsStatement();
                acad_GetStudentTranscriptTableAdapter ResStatement = new acad_GetStudentTranscriptTableAdapter();
                ResultsData DS = new ResultsData();
                ResStatement.Fill(DS.acad_GetStudentTranscript, Session["regno"].ToString());
                RPT.DataSource = DS;
                ReportViewer1.Report = RPT;
            }
            else if (Session["Report"].ToString() == "GraduationLists")
            {
                GraduationLists RPT = new GraduationLists();
                acad_Get_GraduationCompletionDataTableAdapter GradList = new acad_Get_GraduationCompletionDataTableAdapter();
                acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
                ResultsData DS = new ResultsData();
                UNIV.Fill(DS.acad_university);
                GradList.Fill(DS.acad_Get_GraduationCompletionData, Session["acad"].ToString(), Session["prog"].ToString(),
                    int.Parse(Session["yr"].ToString()),
                    Session["cat"].ToString(), DateTime.Parse(Session["gdate"].ToString()), Session["sems"].ToString(), Session["intk"].ToString());
                RPT.DataSource = DS;
                ReportViewer1.Report = RPT;
            }
            else if (Session["Report"].ToString() == "Batch Certificates" || Session["Report"].ToString() == "Batch Completion Letters")
            {
                acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
                Certificate RPT = new Certificate();
                LetterOfCompletion LTR = new LetterOfCompletion();
                acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
                ResultsData DS = new ResultsData();
                DS.EnforceConstraints = false;
                ResStatement.Fill(DS.acad_GetBatchStudentTranscriptData, Session["prog"].ToString(), Session["acad"].ToString());
                UNIV.Fill(DS.acad_university);
                RPT.DataSource = DS;
                LTR.DataSource = DS;
                if (Session["Report"].ToString() == "Batch Certificates")
                    ReportViewer1.Report = RPT;
                else
                    ReportViewer1.Report = LTR;
            }
            else if (Session["Report"].ToString() == "Single Certificate" || Session["Report"].ToString() == "Single Completion Letter" || Session["Report"].ToString() == "Basic Completion Letter")
            {
                //Basic Completion Letter
                Certificate RPT = new Certificate();
                acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
                LetterOfCompletion LTR = new LetterOfCompletion();
                LetterOfCompletion_Caution LTR_B = new LetterOfCompletion_Caution();
                acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
                ResultsData DS = new ResultsData();
                DS.EnforceConstraints = false;
                UNIV.Fill(DS.acad_university);
                string regNo = Session["reg"].ToString().Trim();
                ResStatement.SingleTranscript(DS.acad_GetBatchStudentTranscriptData, regNo);
                CertificateDataHelper.EnsureSingleStudentData(DS, regNo);
                RPT.DataSource = DS;
                LTR.DataSource = DS;
                LTR_B.DataSource = DS;
                if (Session["Report"].ToString() == "Single Certificate")
                    ReportViewer1.Report = RPT;
                else if (Session["Report"].ToString() == "Basic Completion Letter")
                    ReportViewer1.Report = LTR_B;
                else
                    ReportViewer1.Report = LTR;
            }
            else if (Session["Report"].ToString() == "Legacy Certificate")
            {
                //Basic Completion Letter
                Certificate RPT = new Certificate();
                acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
                ResultsData DS = new ResultsData();
                DS.EnforceConstraints = false;
                string regNo = Session["reg"].ToString().Trim();
                ResStatement.LegacyTranscriptData(DS.acad_GetBatchStudentTranscriptData, regNo);
                CertificateDataHelper.EnsureSingleStudentData(DS, regNo);
                RPT.DataSource = DS;

                ReportViewer1.Report = RPT;

            }
            else if (Session["Report"].ToString() == "Single Transcript")
            {

                acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
                acad_GetBatchStudentTranscript_Col1TableAdapter COL_1 = new acad_GetBatchStudentTranscript_Col1TableAdapter();
                acad_GetBatchStudentTranscript_Col2TableAdapter COL_2 = new acad_GetBatchStudentTranscript_Col2TableAdapter();
                acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
                ResultsData DS = new ResultsData();
                DS.EnforceConstraints = false;
                string regNo = Session["reg"].ToString().Trim();
                ResStatement.SingleTranscript(DS.acad_GetBatchStudentTranscriptData, regNo);
                CertificateDataHelper.EnsureSingleStudentData(DS, regNo);
                //ResStatement.Fill(DS.acad_GetBatchStudentTranscriptData, Session["prog"].ToString(), Session["acad"].ToString());
                UNIV.Fill(DS.acad_university);
                FinalTranscript TRANS_RPT = new FinalTranscript();
                TRANS_RPT.DataSource = (DS);
                ReportViewer1.Report = TRANS_RPT;
                // Response.Write(string.Format("Printing Marksheet PG{0},ACAD {1}", Session["prog"].ToString(), Session["acad"].ToString()));
            }
            else if (Session["Report"].ToString() == "Batch Transcripts")
            {

                acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
                acad_GetBatchStudentTranscript_Col1TableAdapter COL_1 = new acad_GetBatchStudentTranscript_Col1TableAdapter();
                acad_GetBatchStudentTranscript_Col2TableAdapter COL_2 = new acad_GetBatchStudentTranscript_Col2TableAdapter();
                acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
                ResultsData DS = new ResultsData();
                DS.EnforceConstraints = false;
                //ResStatement.SingleTranscript(DS.acad_GetBatchStudentTranscriptData, Session["reg"].ToString());
                ResStatement.Fill(DS.acad_GetBatchStudentTranscriptData, Session["prog"].ToString(), Session["acad"].ToString());
                UNIV.Fill(DS.acad_university);
                FinalTranscript TRANS_RPT = new FinalTranscript();
                TRANS_RPT.DataSource = (DS);
                ReportViewer1.Report = TRANS_RPT;
                // Response.Write(string.Format("Printing Marksheet PG{0},ACAD {1}", Session["prog"].ToString(), Session["acad"].ToString()));
            }

            else if (Session["Report"].ToString() == "SFSS")
            {
                Transcript RPT = new Transcript();
                acad_GetStudentTranscriptTableAdapter ResStatement = new acad_GetStudentTranscriptTableAdapter();
                acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
                ResultsData DS = new ResultsData();
                ResStatement.Fill(DS.acad_GetStudentTranscript, Session["reg"].ToString());
                UNIV.Fill(DS.acad_university);
                RPT.DataSource = DS;
                ReportViewer1.Report = RPT;

            }
            else if (Session["Report"].ToString() == "StudentList")
            {
                StudentDataTableAdapters.acad_universityTableAdapter UNIV = new StudentDataTableAdapters.acad_universityTableAdapter();
                StudentData ds = new StudentData();
                StudentDataTableAdapters.acad_StudentListTableAdapter LIST = new StudentDataTableAdapters.acad_StudentListTableAdapter();
                LIST.Fill(ds.acad_StudentList, Session["fax"].ToString(), Session["prog"].ToString(), Session["acad"].ToString(), int.Parse(Session["sem"].ToString()), Session["sess"].ToString(),
                    Session["intake"].ToString(), Session["nat"].ToString(), int.Parse(Session["EntYear"].ToString()), int.Parse(Session["Campus"].ToString()), Session["DocType"].ToString());
                UNIV.Fill(ds.acad_university);

                if (Session["DocType"].ToString() == "REGISTERED")
                {
                    StudentAttendanceList attendlist = new StudentAttendanceList();
                    attendlist.DataSource = ds;
                    ReportViewer1.Report = attendlist;
                }
                else
                {
                    BasicStudentList studrpt = new BasicStudentList();
                    StudentAttendanceList attendlist = new StudentAttendanceList();
                    studrpt.DataSource = ds;
                    ReportViewer1.Report = studrpt;
                }
            }
            else if (Session["Report"].ToString() == "Identity Cards")
            {
                IDCard RPT = new IDCard();
                RPT.Parameters["fax"].Value = Session["fax"];
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acad"].Value = Session["acad"];
                RPT.Parameters["sem"].Value = Session["sem"];
                RPT.Parameters["cardType"].Value = Session["Report"];
                RPT.Parameters["intk"].Value = Session["intk"];
                RPT.Parameters["reg"].Value = Session["reg"];
                ReportViewer1.Report = RPT;
            }
            else if (Session["Report"].ToString() == "Faculty Marksheet")
            {
                FacultyMarksheet RPT = new FacultyMarksheet();
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acad"].Value = Session["acad"];
                RPT.Parameters["sems"].Value = Session["sems"];
                RPT.Parameters["csid"].Value = Session["csid"];
                RPT.Parameters["sess"].Value = Session["sess"];
                RPT.Parameters["yr"].Value = Session["yr"];
                RPT.Parameters["stat"].Value = Session["stat"];
                RPT.Parameters["intak"].Value = Session["intak"];
                RPT.Parameters["entyr"].Value = Session["entyr"];
                RPT.Parameters["camp"].Value = Session["campus"];
                ReportViewer1.Report = RPT;
            }
            //else if (Session["Report"].ToString() == "Faculty Marksheet")
            //{
            //    FacultyMarksheet RPT = new FacultyMarksheet();
            //    RPT.Parameters["prog"].Value = Session["prog"];
            //    RPT.Parameters["acad"].Value = Session["acad"];
            //    RPT.Parameters["sems"].Value = Session["sems"];
            //    RPT.Parameters["csid"].Value = Session["csid"];
            //    RPT.Parameters["sess"].Value = Session["sess"];
            //    RPT.Parameters["yr"].Value = Session["yr"];
            //    RPT.Parameters["stat"].Value = Session["stat"];
            //    ReportViewer1.Report = RPT;
            //}
            else if (Session["Report"].ToString() == "Marksheet")
            {
                MarksheetPrint RPT = new MarksheetPrint();
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acadyr"].Value = Session["acad"];
                RPT.Parameters["sem"].Value = Session["sem"];
                RPT.Parameters["yr"].Value = Session["yr"];
                RPT.Parameters["intk"].Value = Session["intk"];
                RPT.Parameters["sess"].Value = Session["sess"];
                RPT.Parameters["entyr"].Value = int.Parse(Session["entyr"].ToString());
                ReportViewer1.Report = RPT;
            }
            else if (Session["Report"].ToString() == "Redo Marksheet")
            {
                Redo_MarkSheet RPT = new Redo_MarkSheet();
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acad_year"].Value = Session["acad"];
                RPT.Parameters["sem"].Value = Session["sem"];
                RPT.Parameters["intak"].Value = Session["intk"];
                ReportViewer1.Report = RPT;
            }
            else if (Session["Report"].ToString() == "Results Summary")
            {
                ResultSummary RPT = new ResultSummary();
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acad_year"].Value = Session["acad"];
                RPT.Parameters["sem"].Value = Session["sem"];
                RPT.Parameters["intak"].Value = Session["intk"];
                RPT.Parameters["studyr"].Value = Session["yr"];
                RPT.Parameters["sess"].Value = Session["sess"];
                RPT.Parameters["entyr"].Value = int.Parse(Session["entyr"].ToString());
                ReportViewer1.Report = RPT;
            }

            else if (Session["Report"].ToString() == "Redo Results Summary")
            {
                RetakeStudents RPT = new RetakeStudents();
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acad_year"].Value = Session["acad"];
                RPT.Parameters["sem"].Value = Session["sem"];
                RPT.Parameters["intak"].Value = Session["intk"];
                ReportViewer1.Report = RPT;
            }
            else if (Session["Report"].ToString() == "Exam Card")
            {
                ExamPass RPT = new ExamPass();
                RPT.Parameters["acad"].Value = Session["acad"];
                RPT.Parameters["sem"].Value = Session["sem"];
                RPT.Parameters["reg"].Value = Session["regno"];
                RPT.Parameters["prog"].Value = "-";
                RPT.Parameters["entyear"].Value = 0;
                RPT.Parameters["typ"].Value = Session["typ"];

                ReportViewer1.Report = RPT;
            }
            else if (Session["Report"].ToString() == "Batch Exam Card")
            {
                ExamPass RPT = new ExamPass();
                RPT.Parameters["acad"].Value = Session["acad"];
                RPT.Parameters["sem"].Value = Session["sem"];
                RPT.Parameters["reg"].Value = "ALL";
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["entyear"].Value = Session["entyear"];
                RPT.Parameters["typ"].Value = Session["typ"];

                ReportViewer1.Report = RPT;
            }

            else if (Session["Report"].ToString() == "Blank CourseWork Marksheet")
            {
                BlankCourseWorkSheet RPT = new BlankCourseWorkSheet();
                //RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acad"].Value = Session["acad"];
                RPT.Parameters["sems"].Value = Session["sems"];
                //RPT.Parameters["csid"].Value = Session["csid"];
                //RPT.Parameters["sess"].Value = Session["sess"];
                RPT.Parameters["yr"].Value = Session["yr"];
                //RPT.Parameters["stat"].Value = Session["stat"];
                RPT.Parameters["intak"].Value = Session["intak"];
                RPT.Parameters["entyr"].Value = Session["entyr"];
                RPT.Parameters["camp"].Value = Session["campus"];
                ReportViewer1.Report = RPT;
            }

            else if (Session["Report"].ToString() == "Blank Exam Marksheet")
            {
                BlankExamSheet RPT = new BlankExamSheet();
                // RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["acad"].Value = Session["acad"];
                RPT.Parameters["sems"].Value = Session["sems"];
                // RPT.Parameters["csid"].Value = Session["csid"];
                // RPT.Parameters["sess"].Value = Session["sess"];
                RPT.Parameters["yr"].Value = Session["yr"];
                // RPT.Parameters["stat"].Value = Session["stat"];
                RPT.Parameters["intak"].Value = Session["intak"];
                RPT.Parameters["entyr"].Value = Session["entyr"];
                RPT.Parameters["camp"].Value = Session["campus"];
                ReportViewer1.Report = RPT;
            }

            else if (Session["Report"].ToString() == "Program Structures")
            {
                ProgramCourseStructure RPT = new ProgramCourseStructure();
                RPT.Parameters["prog"].Value = Session["prog"];
                RPT.Parameters["currID"].Value = int.Parse(Session["CurrID"].ToString());
                ReportViewer1.Report = RPT;
            }

        }
        catch (Exception ex)
        {
            if (ex.Message.Contains("Object reference not set to an instance of an object"))
                lbl_response.Text = "Error! Make Sure you have selected all required fields.";
            else
            lbl_response.Text = "Error!!!!!! " + UnwrapExceptionMessage(ex);
        }
    }

    static string UnwrapExceptionMessage(Exception ex)
    {
        return ex.InnerException != null ? UnwrapExceptionMessage(ex.InnerException) : ex.Message;
    }
   
}