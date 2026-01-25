using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

/// <summary>
/// Summary description for ResultSummary
/// </summary>
public class ResultSummary : DevExpress.XtraReports.UI.XtraReport
{
	private DevExpress.XtraReports.UI.DetailBand Detail;
	private DevExpress.XtraReports.UI.TopMarginBand TopMargin;
	private DevExpress.XtraReports.UI.BottomMarginBand BottomMargin;
    private DevExpress.DataAccess.Sql.SqlDataSource sqlDataSource1;
    private GroupHeaderBand GroupHeader1;
    private XRBarCode xrBarCode1;
    private XRLabel xrLabel2;
    private XRLabel xrLabel3;
    private GroupHeaderBand GroupHeader2;
    private XRLine xrLine1;
    private DevExpress.XtraReports.Parameters.Parameter prog;
    private DevExpress.XtraReports.Parameters.Parameter acad_year;
    private DevExpress.XtraReports.Parameters.Parameter sem;
    private DevExpress.XtraReports.Parameters.Parameter intak;
    private DevExpress.XtraReports.Parameters.Parameter studyr;
    private XRRichText xrRichText1;
    private XRLabel xrLabel4;
    private XRSubreport xrSubreport1;
    private XRSubreport xrSubreport2;
    private XRRichText xrRichText2;
    private XRLabel xrLabel5;
    private PageFooterBand PageFooter;
    private XRPageInfo xrPageInfo1;
    private XRLine xrLine2;
    private XRSubreport xrSubreport3;
    private PageHeaderBand PageHeader;
    private XRSubreport xrSubreport6;
    private XRLabel xrLabel6;
    private XRRichText xrRichText3;
    private XRLabel xrLabel7;
    private XRRichText xrRichText4;
    private XRSubreport xrSubreport4;
    private XRSubreport xrSubreport5;
    private XRRichText xrRichText5;
    private XRLabel xrLabel8;
    private DevExpress.XtraReports.Parameters.Parameter sess;
    private DevExpress.XtraReports.Parameters.Parameter entyr;
    private CalculatedField AllIntakes_Text;
    private CalculatedField SessionText;
    private XRRichText xrRichText6;
    private ReportFooterBand ReportFooter;
    private XRLabel xrLabel9;
    private XRLabel xrLabel1;
	/// <summary>
	/// Required designer variable.
	/// </summary>
	private System.ComponentModel.IContainer components = null;

	public ResultSummary()
	{
		InitializeComponent();
		//
		// TODO: Add constructor logic here
		//
	}
	
	/// <summary> 
	/// Clean up any resources being used.
	/// </summary>
	/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
	protected override void Dispose(bool disposing) {
		if (disposing && (components != null)) {
			components.Dispose();
		}
		base.Dispose(disposing);
	}

	#region Designer generated code

	/// <summary>
	/// Required method for Designer support - do not modify
	/// the contents of this method with the code editor.
	/// </summary>
	private void InitializeComponent() {
            string resourceFileName = "ResultSummary.resx";
            System.Resources.ResourceManager resources = global::Resources.ResultSummary.ResourceManager;
            this.components = new System.ComponentModel.Container();
            DevExpress.DataAccess.Sql.StoredProcQuery storedProcQuery1 = new DevExpress.DataAccess.Sql.StoredProcQuery();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter1 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter2 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter3 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter4 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter5 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter6 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter7 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.SelectQuery selectQuery1 = new DevExpress.DataAccess.Sql.SelectQuery();
            DevExpress.DataAccess.Sql.AllColumns allColumns1 = new DevExpress.DataAccess.Sql.AllColumns();
            DevExpress.DataAccess.Sql.Table table1 = new DevExpress.DataAccess.Sql.Table();
            DevExpress.XtraPrinting.BarCode.Code93Generator code93Generator1 = new DevExpress.XtraPrinting.BarCode.Code93Generator();
            this.Detail = new DevExpress.XtraReports.UI.DetailBand();
            this.TopMargin = new DevExpress.XtraReports.UI.TopMarginBand();
            this.BottomMargin = new DevExpress.XtraReports.UI.BottomMarginBand();
            this.sqlDataSource1 = new DevExpress.DataAccess.Sql.SqlDataSource(this.components);
            this.GroupHeader1 = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.xrLabel3 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrBarCode1 = new DevExpress.XtraReports.UI.XRBarCode();
            this.xrLabel2 = new DevExpress.XtraReports.UI.XRLabel();
            this.GroupHeader2 = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.xrRichText6 = new DevExpress.XtraReports.UI.XRRichText();
            this.xrLabel6 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrRichText3 = new DevExpress.XtraReports.UI.XRRichText();
            this.xrLabel7 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrRichText4 = new DevExpress.XtraReports.UI.XRRichText();
            this.xrSubreport4 = new DevExpress.XtraReports.UI.XRSubreport();
            this.intak = new DevExpress.XtraReports.Parameters.Parameter();
            this.sess = new DevExpress.XtraReports.Parameters.Parameter();
            this.entyr = new DevExpress.XtraReports.Parameters.Parameter();
            this.xrSubreport5 = new DevExpress.XtraReports.UI.XRSubreport();
            this.xrRichText5 = new DevExpress.XtraReports.UI.XRRichText();
            this.xrLabel8 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrSubreport3 = new DevExpress.XtraReports.UI.XRSubreport();
            this.xrSubreport2 = new DevExpress.XtraReports.UI.XRSubreport();
            this.xrRichText2 = new DevExpress.XtraReports.UI.XRRichText();
            this.xrLabel5 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrRichText1 = new DevExpress.XtraReports.UI.XRRichText();
            this.xrLabel4 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLine1 = new DevExpress.XtraReports.UI.XRLine();
            this.xrSubreport1 = new DevExpress.XtraReports.UI.XRSubreport();
            this.prog = new DevExpress.XtraReports.Parameters.Parameter();
            this.acad_year = new DevExpress.XtraReports.Parameters.Parameter();
            this.sem = new DevExpress.XtraReports.Parameters.Parameter();
            this.studyr = new DevExpress.XtraReports.Parameters.Parameter();
            this.PageFooter = new DevExpress.XtraReports.UI.PageFooterBand();
            this.xrLine2 = new DevExpress.XtraReports.UI.XRLine();
            this.xrPageInfo1 = new DevExpress.XtraReports.UI.XRPageInfo();
            this.PageHeader = new DevExpress.XtraReports.UI.PageHeaderBand();
            this.xrSubreport6 = new DevExpress.XtraReports.UI.XRSubreport();
            this.AllIntakes_Text = new DevExpress.XtraReports.UI.CalculatedField();
            this.SessionText = new DevExpress.XtraReports.UI.CalculatedField();
            this.ReportFooter = new DevExpress.XtraReports.UI.ReportFooterBand();
            this.xrLabel9 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel1 = new DevExpress.XtraReports.UI.XRLabel();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText6)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText3)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText4)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText5)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this)).BeginInit();
            // 
            // Detail
            // 
            this.Detail.Dpi = 100F;
            this.Detail.HeightF = 0F;
            this.Detail.Name = "Detail";
            this.Detail.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.Detail.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // TopMargin
            // 
            this.TopMargin.Dpi = 100F;
            this.TopMargin.HeightF = 11F;
            this.TopMargin.Name = "TopMargin";
            this.TopMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.TopMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // BottomMargin
            // 
            this.BottomMargin.Dpi = 100F;
            this.BottomMargin.HeightF = 0.8333333F;
            this.BottomMargin.Name = "BottomMargin";
            this.BottomMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.BottomMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // sqlDataSource1
            // 
            this.sqlDataSource1.ConnectionName = "localhost_campus_dynamics_Connection";
            this.sqlDataSource1.Name = "sqlDataSource1";
            storedProcQuery1.Name = "campus_dynamics_acad_summary_GetResultSummary_Semester";
            queryParameter1.Name = "@prog";
            queryParameter1.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter1.Value = new DevExpress.DataAccess.Expression("[Parameters.prog]", typeof(string));
            queryParameter2.Name = "@acad_year";
            queryParameter2.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter2.Value = new DevExpress.DataAccess.Expression("[Parameters.acad_year]", typeof(string));
            queryParameter3.Name = "@sem";
            queryParameter3.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter3.Value = new DevExpress.DataAccess.Expression("[Parameters.sem]", typeof(int));
            queryParameter4.Name = "@intak";
            queryParameter4.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter4.Value = new DevExpress.DataAccess.Expression("[Parameters.intak]", typeof(string));
            queryParameter5.Name = "@studyr";
            queryParameter5.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter5.Value = new DevExpress.DataAccess.Expression("[Parameters.studyr]", typeof(int));
            queryParameter6.Name = "@sess";
            queryParameter6.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter6.Value = new DevExpress.DataAccess.Expression("[Parameters.sess]", typeof(string));
            queryParameter7.Name = "@entyr";
            queryParameter7.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter7.Value = new DevExpress.DataAccess.Expression("[Parameters.entyr]", typeof(int));
            storedProcQuery1.Parameters.Add(queryParameter1);
            storedProcQuery1.Parameters.Add(queryParameter2);
            storedProcQuery1.Parameters.Add(queryParameter3);
            storedProcQuery1.Parameters.Add(queryParameter4);
            storedProcQuery1.Parameters.Add(queryParameter5);
            storedProcQuery1.Parameters.Add(queryParameter6);
            storedProcQuery1.Parameters.Add(queryParameter7);
            storedProcQuery1.StoredProcName = "campus_dynamics.acad_summary_GetResultSummary_Semester";
            table1.Name = "acad_university";
            allColumns1.Table = table1;
            selectQuery1.Columns.Add(allColumns1);
            selectQuery1.Name = "acad_university";
            selectQuery1.Tables.Add(table1);
            this.sqlDataSource1.Queries.AddRange(new DevExpress.DataAccess.Sql.SqlQuery[] {
            storedProcQuery1,
            selectQuery1});
            this.sqlDataSource1.ResultSchemaSerializable = resources.GetString("sqlDataSource1.ResultSchemaSerializable");
            // 
            // GroupHeader1
            // 
            this.GroupHeader1.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel3,
            this.xrBarCode1});
            this.GroupHeader1.Dpi = 100F;
            this.GroupHeader1.GroupFields.AddRange(new DevExpress.XtraReports.UI.GroupField[] {
            new DevExpress.XtraReports.UI.GroupField("Faculty", DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending)});
            this.GroupHeader1.GroupUnion = DevExpress.XtraReports.UI.GroupUnion.WithFirstDetail;
            this.GroupHeader1.HeightF = 23.83331F;
            this.GroupHeader1.KeepTogether = true;
            this.GroupHeader1.Level = 1;
            this.GroupHeader1.Name = "GroupHeader1";
            // 
            // xrLabel3
            // 
            this.xrLabel3.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.Faculty")});
            this.xrLabel3.Dpi = 100F;
            this.xrLabel3.Font = new System.Drawing.Font("Tahoma", 12F, System.Drawing.FontStyle.Bold);
            this.xrLabel3.LocationFloat = new DevExpress.Utils.PointFloat(6.166668F, 0F);
            this.xrLabel3.Name = "xrLabel3";
            this.xrLabel3.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel3.SizeF = new System.Drawing.SizeF(693.8332F, 20.66666F);
            this.xrLabel3.StylePriority.UseFont = false;
            this.xrLabel3.StylePriority.UseTextAlignment = false;
            this.xrLabel3.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // xrBarCode1
            // 
            this.xrBarCode1.AutoModule = true;
            this.xrBarCode1.Dpi = 100F;
            this.xrBarCode1.LocationFloat = new DevExpress.Utils.PointFloat(702.0416F, 1F);
            this.xrBarCode1.Name = "xrBarCode1";
            this.xrBarCode1.Padding = new DevExpress.XtraPrinting.PaddingInfo(10, 10, 0, 0, 100F);
            this.xrBarCode1.SizeF = new System.Drawing.SizeF(103.125F, 21.33336F);
            this.xrBarCode1.Symbology = code93Generator1;
            // 
            // xrLabel2
            // 
            this.xrLabel2.Dpi = 100F;
            this.xrLabel2.Font = new System.Drawing.Font("Tahoma", 12F, System.Drawing.FontStyle.Bold);
            this.xrLabel2.LocationFloat = new DevExpress.Utils.PointFloat(8.499991F, 0F);
            this.xrLabel2.Multiline = true;
            this.xrLabel2.Name = "xrLabel2";
            this.xrLabel2.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel2.SizeF = new System.Drawing.SizeF(791.3333F, 51.99997F);
            this.xrLabel2.StylePriority.UseFont = false;
            this.xrLabel2.StylePriority.UseTextAlignment = false;
            this.xrLabel2.Text = "SUMMARY OF PROVISIONAL RESULTS FOR [Progname] \r\nYEAR [studyyear] SEMESTER [semest" +
    "er], [acad] :: INTAKE: [AllIntakes_Text] [Parameters.entyr] :: [SessionText]\r\n";
            this.xrLabel2.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // GroupHeader2
            // 
            this.GroupHeader2.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrRichText6,
            this.xrLabel6,
            this.xrRichText3,
            this.xrLabel7,
            this.xrRichText4,
            this.xrSubreport4,
            this.xrSubreport5,
            this.xrRichText5,
            this.xrLabel8,
            this.xrSubreport3,
            this.xrSubreport2,
            this.xrRichText2,
            this.xrLabel5,
            this.xrRichText1,
            this.xrLabel4,
            this.xrLine1,
            this.xrLabel2,
            this.xrSubreport1});
            this.GroupHeader2.Dpi = 100F;
            this.GroupHeader2.GroupFields.AddRange(new DevExpress.XtraReports.UI.GroupField[] {
            new DevExpress.XtraReports.UI.GroupField("Progname", DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending)});
            this.GroupHeader2.HeightF = 748.6667F;
            this.GroupHeader2.KeepTogether = true;
            this.GroupHeader2.Name = "GroupHeader2";
            // 
            // xrRichText6
            // 
            this.xrRichText6.Dpi = 100F;
            this.xrRichText6.Font = new System.Drawing.Font("Tahoma", 11F);
            this.xrRichText6.LocationFloat = new DevExpress.Utils.PointFloat(5.958309F, 64.25003F);
            this.xrRichText6.Name = "xrRichText6";
            this.xrRichText6.SerializableRtfString = resources.GetString("xrRichText6.SerializableRtfString");
            this.xrRichText6.SizeF = new System.Drawing.SizeF(794.0833F, 60.83328F);
            this.xrRichText6.StylePriority.UseFont = false;
            // 
            // xrLabel6
            // 
            this.xrLabel6.Dpi = 100F;
            this.xrLabel6.Font = new System.Drawing.Font("Tahoma", 11F, System.Drawing.FontStyle.Bold);
            this.xrLabel6.LocationFloat = new DevExpress.Utils.PointFloat(5.5F, 492.9167F);
            this.xrLabel6.Name = "xrLabel6";
            this.xrLabel6.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel6.SizeF = new System.Drawing.SizeF(435.1667F, 22.99999F);
            this.xrLabel6.StylePriority.UseFont = false;
            this.xrLabel6.Text = "4. HALT CASES";
            // 
            // xrRichText3
            // 
            this.xrRichText3.Dpi = 100F;
            this.xrRichText3.Font = new System.Drawing.Font("Tahoma", 11F);
            this.xrRichText3.LocationFloat = new DevExpress.Utils.PointFloat(8.416692F, 515.9167F);
            this.xrRichText3.Name = "xrRichText3";
            this.xrRichText3.SerializableRtfString = resources.GetString("xrRichText3.SerializableRtfString");
            this.xrRichText3.SizeF = new System.Drawing.SizeF(794.0833F, 43.00002F);
            this.xrRichText3.StylePriority.UseFont = false;
            // 
            // xrLabel7
            // 
            this.xrLabel7.Dpi = 100F;
            this.xrLabel7.Font = new System.Drawing.Font("Tahoma", 11F, System.Drawing.FontStyle.Bold);
            this.xrLabel7.LocationFloat = new DevExpress.Utils.PointFloat(5F, 248F);
            this.xrLabel7.Name = "xrLabel7";
            this.xrLabel7.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel7.SizeF = new System.Drawing.SizeF(435.1667F, 22.99999F);
            this.xrLabel7.StylePriority.UseFont = false;
            this.xrLabel7.Text = "2. DEAN\'S LIST";
            // 
            // xrRichText4
            // 
            this.xrRichText4.Dpi = 100F;
            this.xrRichText4.Font = new System.Drawing.Font("Tahoma", 11F);
            this.xrRichText4.LocationFloat = new DevExpress.Utils.PointFloat(8.916626F, 271F);
            this.xrRichText4.Name = "xrRichText4";
            this.xrRichText4.SerializableRtfString = resources.GetString("xrRichText4.SerializableRtfString");
            this.xrRichText4.SizeF = new System.Drawing.SizeF(794.0834F, 24.16663F);
            this.xrRichText4.StylePriority.UseFont = false;
            // 
            // xrSubreport4
            // 
            this.xrSubreport4.Dpi = 100F;
            this.xrSubreport4.LocationFloat = new DevExpress.Utils.PointFloat(7.750123F, 295.1666F);
            this.xrSubreport4.Name = "xrSubreport4";
            this.xrSubreport4.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("prog", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.progid"));
            this.xrSubreport4.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("acad_year", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.acad"));
            this.xrSubreport4.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sem", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.semester"));
            this.xrSubreport4.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("intak", this.intak));
            this.xrSubreport4.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("studyr", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.studyyear"));
            this.xrSubreport4.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sess", this.sess));
            this.xrSubreport4.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("entyr", this.entyr));
            this.xrSubreport4.ReportSource = new ResultSummary_DeansList();
            this.xrSubreport4.SizeF = new System.Drawing.SizeF(794.7499F, 57F);
            // 
            // intak
            // 
            this.intak.Name = "intak";
            // 
            // sess
            // 
            this.sess.Name = "sess";
            // 
            // entyr
            // 
            this.entyr.Description = "Parameter1";
            this.entyr.Name = "entyr";
            this.entyr.Type = typeof(int);
            this.entyr.ValueInfo = "0";
            // 
            // xrSubreport5
            // 
            this.xrSubreport5.Dpi = 100F;
            this.xrSubreport5.LocationFloat = new DevExpress.Utils.PointFloat(7.75F, 186.1666F);
            this.xrSubreport5.Name = "xrSubreport5";
            this.xrSubreport5.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("prog", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.progid"));
            this.xrSubreport5.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("acad_year", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.acad"));
            this.xrSubreport5.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sem", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.semester"));
            this.xrSubreport5.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("intak", this.intak));
            this.xrSubreport5.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("studyr", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.studyyear"));
            this.xrSubreport5.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sess", this.sess));
            this.xrSubreport5.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("entyr", this.entyr));
            this.xrSubreport5.ReportSource = new ResultSummary_VCList();
            this.xrSubreport5.SizeF = new System.Drawing.SizeF(794.7499F, 57F);
            // 
            // xrRichText5
            // 
            this.xrRichText5.Dpi = 100F;
            this.xrRichText5.Font = new System.Drawing.Font("Tahoma", 11F);
            this.xrRichText5.LocationFloat = new DevExpress.Utils.PointFloat(7.333187F, 162F);
            this.xrRichText5.Name = "xrRichText5";
            this.xrRichText5.SerializableRtfString = resources.GetString("xrRichText5.SerializableRtfString");
            this.xrRichText5.SizeF = new System.Drawing.SizeF(794.0834F, 24.16663F);
            this.xrRichText5.StylePriority.UseFont = false;
            // 
            // xrLabel8
            // 
            this.xrLabel8.Dpi = 100F;
            this.xrLabel8.Font = new System.Drawing.Font("Tahoma", 11F, System.Drawing.FontStyle.Bold);
            this.xrLabel8.LocationFloat = new DevExpress.Utils.PointFloat(5.500122F, 139F);
            this.xrLabel8.Name = "xrLabel8";
            this.xrLabel8.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel8.SizeF = new System.Drawing.SizeF(435.1667F, 22.99999F);
            this.xrLabel8.StylePriority.UseFont = false;
            this.xrLabel8.Text = "1. VC\'S LIST";
            // 
            // xrSubreport3
            // 
            this.xrSubreport3.Dpi = 100F;
            this.xrSubreport3.LocationFloat = new DevExpress.Utils.PointFloat(7.750122F, 560.8333F);
            this.xrSubreport3.Name = "xrSubreport3";
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("prog", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.progid"));
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("acad_year", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.acad"));
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sem", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.semester"));
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("intak", this.intak));
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("studyr", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.studyyear"));
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sess", this.sess));
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("entyr", this.entyr));
            this.xrSubreport3.ReportSource = new ResultSummary_HaltCases();
            this.xrSubreport3.SizeF = new System.Drawing.SizeF(794.7499F, 57F);
            // 
            // xrSubreport2
            // 
            this.xrSubreport2.Dpi = 100F;
            this.xrSubreport2.LocationFloat = new DevExpress.Utils.PointFloat(9.916671F, 691.6667F);
            this.xrSubreport2.Name = "xrSubreport2";
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("prog", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.progid"));
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("acad_year", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.acad"));
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sem", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.semester"));
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("intak", this.intak));
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("studyr", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.studyyear"));
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sess", this.sess));
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("entyr", this.entyr));
            this.xrSubreport2.ReportSource = new ResultSummary_RetakeCases();
            this.xrSubreport2.SizeF = new System.Drawing.SizeF(794.7499F, 57F);
            // 
            // xrRichText2
            // 
            this.xrRichText2.Dpi = 100F;
            this.xrRichText2.Font = new System.Drawing.Font("Tahoma", 11F);
            this.xrRichText2.LocationFloat = new DevExpress.Utils.PointFloat(9.916671F, 648.6667F);
            this.xrRichText2.Name = "xrRichText2";
            this.xrRichText2.SerializableRtfString = resources.GetString("xrRichText2.SerializableRtfString");
            this.xrRichText2.SizeF = new System.Drawing.SizeF(794.0833F, 43.00002F);
            this.xrRichText2.StylePriority.UseFont = false;
            // 
            // xrLabel5
            // 
            this.xrLabel5.Dpi = 100F;
            this.xrLabel5.Font = new System.Drawing.Font("Tahoma", 11F, System.Drawing.FontStyle.Bold);
            this.xrLabel5.LocationFloat = new DevExpress.Utils.PointFloat(6F, 625.6667F);
            this.xrLabel5.Name = "xrLabel5";
            this.xrLabel5.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel5.SizeF = new System.Drawing.SizeF(435.1667F, 22.99999F);
            this.xrLabel5.StylePriority.UseFont = false;
            this.xrLabel5.Text = "5. RETAKE CASES";
            // 
            // xrRichText1
            // 
            this.xrRichText1.Dpi = 100F;
            this.xrRichText1.Font = new System.Drawing.Font("Tahoma", 11F);
            this.xrRichText1.LocationFloat = new DevExpress.Utils.PointFloat(8.25002F, 381.6667F);
            this.xrRichText1.Name = "xrRichText1";
            this.xrRichText1.SerializableRtfString = resources.GetString("xrRichText1.SerializableRtfString");
            this.xrRichText1.SizeF = new System.Drawing.SizeF(794.0833F, 43.00002F);
            this.xrRichText1.StylePriority.UseFont = false;
            // 
            // xrLabel4
            // 
            this.xrLabel4.Dpi = 100F;
            this.xrLabel4.Font = new System.Drawing.Font("Tahoma", 11F, System.Drawing.FontStyle.Bold);
            this.xrLabel4.LocationFloat = new DevExpress.Utils.PointFloat(5F, 358.6667F);
            this.xrLabel4.Name = "xrLabel4";
            this.xrLabel4.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel4.SizeF = new System.Drawing.SizeF(435.1667F, 22.99999F);
            this.xrLabel4.StylePriority.UseFont = false;
            this.xrLabel4.Text = "3. NORMAL PROGRESS";
            // 
            // xrLine1
            // 
            this.xrLine1.Dpi = 100F;
            this.xrLine1.LocationFloat = new DevExpress.Utils.PointFloat(0F, 55.3333F);
            this.xrLine1.Name = "xrLine1";
            this.xrLine1.SizeF = new System.Drawing.SizeF(807.6666F, 2.000004F);
            // 
            // xrSubreport1
            // 
            this.xrSubreport1.Dpi = 100F;
            this.xrSubreport1.LocationFloat = new DevExpress.Utils.PointFloat(7.916692F, 428.6667F);
            this.xrSubreport1.Name = "xrSubreport1";
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("prog", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.progid"));
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("acad_year", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.acad"));
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sem", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.semester"));
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("intak", this.intak));
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("studyr", null, "campus_dynamics_acad_summary_GetResultSummary_Semester.studyyear"));
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("sess", this.sess));
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("entyr", this.entyr));
            this.xrSubreport1.ReportSource = new ResultSummary_PassCases();
            this.xrSubreport1.SizeF = new System.Drawing.SizeF(794.7499F, 57F);
            // 
            // prog
            // 
            this.prog.Name = "prog";
            // 
            // acad_year
            // 
            this.acad_year.Name = "acad_year";
            // 
            // sem
            // 
            this.sem.Name = "sem";
            this.sem.Type = typeof(int);
            this.sem.ValueInfo = "0";
            // 
            // studyr
            // 
            this.studyr.Name = "studyr";
            this.studyr.Type = typeof(int);
            this.studyr.ValueInfo = "0";
            // 
            // PageFooter
            // 
            this.PageFooter.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLine2,
            this.xrPageInfo1});
            this.PageFooter.Dpi = 100F;
            this.PageFooter.HeightF = 20F;
            this.PageFooter.Name = "PageFooter";
            // 
            // xrLine2
            // 
            this.xrLine2.Dpi = 100F;
            this.xrLine2.LocationFloat = new DevExpress.Utils.PointFloat(3.250001F, 0F);
            this.xrLine2.Name = "xrLine2";
            this.xrLine2.SizeF = new System.Drawing.SizeF(802.5834F, 2.00002F);
            // 
            // xrPageInfo1
            // 
            this.xrPageInfo1.Dpi = 100F;
            this.xrPageInfo1.Font = new System.Drawing.Font("Tahoma", 10F, System.Drawing.FontStyle.Bold);
            this.xrPageInfo1.Format = "Page {0} of {1}";
            this.xrPageInfo1.LocationFloat = new DevExpress.Utils.PointFloat(680.8333F, 2.00002F);
            this.xrPageInfo1.Name = "xrPageInfo1";
            this.xrPageInfo1.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrPageInfo1.SizeF = new System.Drawing.SizeF(125.8334F, 16.83334F);
            this.xrPageInfo1.StylePriority.UseFont = false;
            this.xrPageInfo1.StylePriority.UseTextAlignment = false;
            this.xrPageInfo1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // PageHeader
            // 
            this.PageHeader.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrSubreport6});
            this.PageHeader.Dpi = 100F;
            this.PageHeader.HeightF = 80F;
            this.PageHeader.Name = "PageHeader";
            // 
            // xrSubreport6
            // 
            this.xrSubreport6.Dpi = 100F;
            this.xrSubreport6.LocationFloat = new DevExpress.Utils.PointFloat(8.166726F, 3.5F);
            this.xrSubreport6.Name = "xrSubreport6";
            this.xrSubreport6.ReportSource = new ReportHeader_Potrait();
            this.xrSubreport6.SizeF = new System.Drawing.SizeF(795.3331F, 75F);
            // 
            // AllIntakes_Text
            // 
            this.AllIntakes_Text.DataMember = "campus_dynamics_acad_summary_GetResultSummary_Semester";
            this.AllIntakes_Text.Expression = "IiF([Parameters.intak]==\'-\',\'ALL INTAKES\',[Parameters.intk])";
            this.AllIntakes_Text.Name = "AllIntakes_Text";
            // 
            // SessionText
            // 
            this.SessionText.DataMember = "campus_dynamics_acad_summary_GetResultSummary_Semester";
            this.SessionText.Expression = "IiF([Parameters.sess]==\'ALL\',\'ALL STUDY SESSIONS\',UPPER([Parameters.sess]))";
            this.SessionText.Name = "SessionText";
            // 
            // ReportFooter
            // 
            this.ReportFooter.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel9,
            this.xrLabel1});
            this.ReportFooter.Dpi = 100F;
            this.ReportFooter.HeightF = 64.71425F;
            this.ReportFooter.KeepTogether = true;
            this.ReportFooter.Name = "ReportFooter";
            this.ReportFooter.PrintAtBottom = true;
            // 
            // xrLabel9
            // 
            this.xrLabel9.Borders = DevExpress.XtraPrinting.BorderSide.Top;
            this.xrLabel9.Dpi = 100F;
            this.xrLabel9.Font = new System.Drawing.Font("Tahoma", 11F, System.Drawing.FontStyle.Bold);
            this.xrLabel9.LocationFloat = new DevExpress.Utils.PointFloat(204.4762F, 45.28567F);
            this.xrLabel9.Name = "xrLabel9";
            this.xrLabel9.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel9.SizeF = new System.Drawing.SizeF(308.2142F, 19.42858F);
            this.xrLabel9.StylePriority.UseBorders = false;
            this.xrLabel9.StylePriority.UseFont = false;
            this.xrLabel9.StylePriority.UseTextAlignment = false;
            this.xrLabel9.Text = "DEAN";
            this.xrLabel9.TextAlignment = DevExpress.XtraPrinting.TextAlignment.BottomCenter;
            // 
            // xrLabel1
            // 
            this.xrLabel1.Dpi = 100F;
            this.xrLabel1.Font = new System.Drawing.Font("Tahoma", 11F);
            this.xrLabel1.LocationFloat = new DevExpress.Utils.PointFloat(205.6667F, 0.8333333F);
            this.xrLabel1.Name = "xrLabel1";
            this.xrLabel1.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel1.SizeF = new System.Drawing.SizeF(307.4999F, 14.66665F);
            this.xrLabel1.StylePriority.UseFont = false;
            this.xrLabel1.StylePriority.UseTextAlignment = false;
            this.xrLabel1.Text = "SIGNATURE";
            this.xrLabel1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // ResultSummary
            // 
            this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.Detail,
            this.TopMargin,
            this.BottomMargin,
            this.GroupHeader1,
            this.GroupHeader2,
            this.PageFooter,
            this.PageHeader,
            this.ReportFooter});
            this.CalculatedFields.AddRange(new DevExpress.XtraReports.UI.CalculatedField[] {
            this.AllIntakes_Text,
            this.SessionText});
            this.ComponentStorage.AddRange(new System.ComponentModel.IComponent[] {
            this.sqlDataSource1});
            this.DataMember = "campus_dynamics_acad_summary_GetResultSummary_Semester";
            this.DataSource = this.sqlDataSource1;
            this.Font = new System.Drawing.Font("Tahoma", 10F);
            this.Margins = new System.Drawing.Printing.Margins(22, 20, 11, 1);
            this.Parameters.AddRange(new DevExpress.XtraReports.Parameters.Parameter[] {
            this.prog,
            this.acad_year,
            this.sem,
            this.intak,
            this.studyr,
            this.sess,
            this.entyr});
            this.SnappingMode = DevExpress.XtraReports.UI.SnappingMode.SnapToGrid;
            this.SnapToGrid = false;
            this.Version = "16.1";
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText6)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText3)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText4)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText5)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrRichText1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this)).EndInit();

	}

	#endregion
}
