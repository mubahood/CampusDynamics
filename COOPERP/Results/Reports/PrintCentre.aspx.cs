using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using CrystalDecisions.CrystalReports.Engine;
using ResultsDataTableAdapters;
using System.IO;

public partial class COOPERP_Results_Reports_PrintCentre : System.Web.UI.Page
{
    ReportDocument RPT = new ReportDocument();
    protected void Page_Load(object sender, EventArgs e)
    {
        
        if (Session["report"] == "Marksheet")
        {
           
            ResultsData DS = new ResultsData();
            ResultsDataTableAdapters.acad_GetMarkSheetTableAdapter MSheet = new ResultsDataTableAdapters.acad_GetMarkSheetTableAdapter();
            ResultsDataTableAdapters.acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
            MSheet.Fill(DS.acad_GetMarkSheet, Session["prog"].ToString(), int.Parse(Session["yr"].ToString()), int.Parse(Session["sem"].ToString()),
                Session["acad"].ToString());
            UNIV.Fill(DS.acad_university);
            RPT.Load(Server.MapPath("Marksheet.rpt"));
            RPT.SetDataSource(DS);
            CRV_Results.ReportSource = RPT;
            //RPT.Dispose();
            //Response.Write(string.Format("Printing Marksheet PG{0},YR{1},SM{2},AC{3}", Session["prog"].ToString(), Session["yr"].ToString(), Session["sem"].ToString(), Session["acad"].ToString()));
        }
        else if (Session["report"] == "Provisional Marksheet")
        {

            ResultsData DS = new ResultsData();
            ResultsDataTableAdapters.acad_GetMarkSheetTableAdapter MSheet = new ResultsDataTableAdapters.acad_GetMarkSheetTableAdapter();
            ResultsDataTableAdapters.acad_universityTableAdapter UNIV = new acad_universityTableAdapter();
            MSheet.ProvisionalMarkSheet(DS.acad_GetMarkSheet, Session["prog"].ToString(), int.Parse(Session["yr"].ToString()), int.Parse(Session["sem"].ToString()),
                Session["acad"].ToString());
            UNIV.Fill(DS.acad_university);
            RPT.Load(Server.MapPath("BasicMarksheet.rpt"));
            RPT.SetDataSource(DS);
            CRV_Results.ReportSource = RPT;
            //RPT.Dispose();
            //Response.Write(string.Format("Printing Marksheet PG{0},YR{1},SM{2},AC{3}", Session["prog"].ToString(), Session["yr"].ToString(), Session["sem"].ToString(), Session["acad"].ToString()));
        }
        else if (Session["Report"].ToString() == "Batch Transcripts")
        {
           
            acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
            acad_GetBatchStudentTranscript_Col1TableAdapter COL_1 = new acad_GetBatchStudentTranscript_Col1TableAdapter();
            acad_GetBatchStudentTranscript_Col2TableAdapter COL_2 = new acad_GetBatchStudentTranscript_Col2TableAdapter();
            ResultsData DS = new ResultsData();
            DS.EnforceConstraints = false;
            ResStatement.Fill(DS.acad_GetBatchStudentTranscriptData, Session["prog"].ToString(), Session["acad"].ToString());
            //********************** Add Photo To List of selected data based on image file names*************************************************
            string ImageFile, PhotoPath;
            for (int i = 0; i < DS.acad_GetBatchStudentTranscriptData.Count; i++)
            {
                try
                {
                    PhotoPath = DS.acad_GetBatchStudentTranscriptData.Rows[i][8].ToString();
                    ImageFile = Server.MapPath(PhotoPath);
                    FileStream fs = new FileStream(ImageFile, FileMode.Open);
                    BinaryReader br = new BinaryReader(fs);
                    DS.acad_GetBatchStudentTranscriptData.Rows[i][10] = br.ReadBytes(Convert.ToInt32(br.BaseStream.Length));
                    fs.Dispose();
                }
                catch (Exception ex)
                {
                    //Response.Write(ex.Message);

                }

            }
            //***********************************************************************************************************************************
            COL_1.Fill(DS.acad_GetBatchStudentTranscript_Col1, Session["prog"].ToString(), Session["acad"].ToString());
            COL_2.Fill(DS.acad_GetBatchStudentTranscript_Col2, Session["prog"].ToString(), Session["acad"].ToString());
            if (Session["prog"].ToString() == "03505")
            {
                RPT.Load(Server.MapPath("FoundationTranscriptTemplate.rpt"));
            }
            else
            {
                RPT.Load(Server.MapPath("TranscriptTemplate.rpt"));
            }
            RPT.SetDataSource(DS);
           // Response.Write(string.Format("Printing Marksheet PG{0},ACAD {1}", Session["prog"].ToString(), Session["acad"].ToString()));
            CRV_Results.ReportSource = RPT;
        }
        else if (Session["Report"].ToString() == "Single Transcript")
        {
            
            acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
            acad_GetBatchStudentTranscript_Col1TableAdapter COL_1 = new acad_GetBatchStudentTranscript_Col1TableAdapter();
            acad_GetBatchStudentTranscript_Col2TableAdapter COL_2 = new acad_GetBatchStudentTranscript_Col2TableAdapter();
            ResultsData DS = new ResultsData();
            ResStatement.SingleTranscript(DS.acad_GetBatchStudentTranscriptData, Session["reg"].ToString());
            //********************** Add Photo To List of selected data based on image file names*************************************************
            string ImageFile, PhotoPath;
            for (int i = 0; i < DS.acad_GetBatchStudentTranscriptData.Count; i++)
            {
                try
                {
                    PhotoPath = DS.acad_GetBatchStudentTranscriptData.Rows[i][8].ToString();
                    ImageFile = Server.MapPath(PhotoPath);
                    FileStream fs = new FileStream(ImageFile, FileMode.Open);
                    BinaryReader br = new BinaryReader(fs);
                    DS.acad_GetBatchStudentTranscriptData.Rows[i][10] = br.ReadBytes(Convert.ToInt32(br.BaseStream.Length));
                    fs.Dispose();
                }
                catch (Exception ex)
                {
                    //Response.Write(ex.Message);

                }

            }
            //***********************************************************************************************************************************
            COL_1.SingleTranscriptColumn_1(DS.acad_GetBatchStudentTranscript_Col1, Session["reg"].ToString());
            COL_2.SingleTranscriptColumn2(DS.acad_GetBatchStudentTranscript_Col2, Session["reg"].ToString());
            if (Session["reg"].ToString().Contains("FCP"))
            {
                RPT.Load(Server.MapPath("FoundationTranscriptTemplate.rpt"));
            }
            else
            {
                RPT.Load(Server.MapPath("TranscriptTemplate.rpt"));
            }
            RPT.SetDataSource(DS);
            // Response.Write(string.Format("Printing Marksheet PG{0},ACAD {1}", Session["prog"].ToString(), Session["acad"].ToString()));
            CRV_Results.ReportSource = RPT;
        }

        else if (Session["Report"].ToString() == "Legacy Transcript")
        {

            LegacyDataTableAdapters.acad_GetBatchStudentTranscriptDataTableAdapter RES = new LegacyDataTableAdapters.acad_GetBatchStudentTranscriptDataTableAdapter();
            LegacyDataTableAdapters.acad_GetBatchStudentTranscript_Col1TableAdapter COL_1 = new LegacyDataTableAdapters.acad_GetBatchStudentTranscript_Col1TableAdapter();
            LegacyDataTableAdapters.acad_GetBatchStudentTranscript_Col2TableAdapter COL_2 = new LegacyDataTableAdapters.acad_GetBatchStudentTranscript_Col2TableAdapter();
            LegacyData DS = new LegacyData();
            DS.EnforceConstraints = false;
            RES.SingleTranscript(DS.acad_GetBatchStudentTranscriptData, Session["reg"].ToString());
            //********************** Add Photo To List of selected data based on image file names*************************************************
            string ImageFile, PhotoPath;
            for (int i = 0; i < DS.acad_GetBatchStudentTranscriptData.Count; i++)
            {
                try
                {
                    PhotoPath = DS.acad_GetBatchStudentTranscriptData.Rows[i][8].ToString();
                    ImageFile = Server.MapPath(PhotoPath);
                    FileStream fs = new FileStream(ImageFile, FileMode.Open);
                    BinaryReader br = new BinaryReader(fs);
                    DS.acad_GetBatchStudentTranscriptData.Rows[i][10] = br.ReadBytes(Convert.ToInt32(br.BaseStream.Length));
                    fs.Dispose();
                }
                catch (Exception ex)
                {
                    //Response.Write(ex.Message);

                }

            }
            //***********************************************************************************************************************************
            COL_1.SingleTranscriptColumn_1(DS.acad_GetBatchStudentTranscript_Col1, Session["reg"].ToString());
            COL_2.SingleTranscriptColumn2(DS.acad_GetBatchStudentTranscript_Col2, Session["reg"].ToString());
            RPT.Load(Server.MapPath("LegacyTranscriptTemplate.rpt"));
            RPT.SetDataSource(DS);
            // Response.Write(string.Format("Printing Marksheet PG{0},ACAD {1}", Session["prog"].ToString(), Session["acad"].ToString()));
            CRV_Results.ReportSource = RPT;
        }

        else if (Session["Report"].ToString() == "ResultStatement")
        {

            acad_GetBatchStudentTranscriptDataTableAdapter ResStatement = new acad_GetBatchStudentTranscriptDataTableAdapter();
            acad_GetBatchStudentTranscript_Col1TableAdapter COL_1 = new acad_GetBatchStudentTranscript_Col1TableAdapter();
            acad_GetBatchStudentTranscript_Col2TableAdapter COL_2 = new acad_GetBatchStudentTranscript_Col2TableAdapter();
            ResultsData DS = new ResultsData();
            ResStatement.SingleResultsStatements(DS.acad_GetBatchStudentTranscriptData, Session["regno"].ToString());
            //********************** Add Photo To List of selected data based on image file names*************************************************
            string ImageFile, PhotoPath;
            for (int i = 0; i < DS.acad_GetBatchStudentTranscriptData.Count; i++)
            {
                try
                {
                    PhotoPath = DS.acad_GetBatchStudentTranscriptData.Rows[i][8].ToString();
                    ImageFile = Server.MapPath(PhotoPath);
                    FileStream fs = new FileStream(ImageFile, FileMode.Open);
                    BinaryReader br = new BinaryReader(fs);
                    DS.acad_GetBatchStudentTranscriptData.Rows[i][10] = br.ReadBytes(Convert.ToInt32(br.BaseStream.Length));
                    fs.Dispose();
                }
                catch (Exception ex)
                {
                    //Response.Write(ex.Message);

                }

            }
            //***********************************************************************************************************************************
            COL_1.SingleResultsStatement_Col1(DS.acad_GetBatchStudentTranscript_Col1, Session["regno"].ToString());
            COL_2.SingleResultsStatement_COL2 (DS.acad_GetBatchStudentTranscript_Col2, Session["regno"].ToString());
            RPT.Load(Server.MapPath("ResultsStatementTemplate.rpt"));
            RPT.SetDataSource(DS);
            // Response.Write(string.Format("Printing Marksheet PG{0},ACAD {1}", Session["prog"].ToString(), Session["acad"].ToString()));
            CRV_Results.ReportSource = RPT;
        }
        
    }
    protected void CRV_Results_Unload(object sender, EventArgs e)
    {
       RPT.Dispose();
    }
    protected void CRV_Results_Disposed(object sender, EventArgs e)
    {
       RPT.Dispose();
    }
}