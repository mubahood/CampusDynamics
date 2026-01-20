using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

/// <summary>
/// Summary description for MarkSheet_Results
/// </summary>
public class MarkSheet_Results : DevExpress.XtraReports.UI.XtraReport
{
	private DevExpress.XtraReports.UI.DetailBand Detail;
	private DevExpress.XtraReports.UI.TopMarginBand TopMargin;
	private DevExpress.XtraReports.UI.BottomMarginBand BottomMargin;
    private DevExpress.DataAccess.Sql.SqlDataSource sqlDataSource1;
    private ReportHeaderBand ReportHeader;
    private ReportFooterBand ReportFooter;
    private XRPivotGrid xrPivotGrid1;
    private DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField fieldSNO;
    private DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField REGNO;
    private DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField STUDNAME;
    private DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField CODE;
    private DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField SCORES;
    private DevExpress.XtraReports.Parameters.Parameter prog;
    private DevExpress.XtraReports.Parameters.Parameter yr;
    private DevExpress.XtraReports.Parameters.Parameter sem;
    private DevExpress.XtraReports.Parameters.Parameter acadyr;
    private DevExpress.XtraReports.Parameters.Parameter intk;
    private DevExpress.XtraReports.Parameters.Parameter sess;
    private DevExpress.XtraReports.Parameters.Parameter entyr;
    private DevExpress.XtraReports.Parameters.Parameter spe;
    private PageFooterBand PageFooter;
	/// <summary>
	/// Required designer variable.
	/// </summary>
	private System.ComponentModel.IContainer components = null;

	public MarkSheet_Results()
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
            string resourceFileName = "MarkSheet_Results.resx";
            System.Resources.ResourceManager resources = global::Resources.MarkSheet_Results.ResourceManager;
            this.components = new System.ComponentModel.Container();
            DevExpress.DataAccess.Sql.StoredProcQuery storedProcQuery1 = new DevExpress.DataAccess.Sql.StoredProcQuery();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter1 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter2 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter3 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter4 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter5 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter6 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter7 = new DevExpress.DataAccess.Sql.QueryParameter();
            DevExpress.DataAccess.Sql.QueryParameter queryParameter8 = new DevExpress.DataAccess.Sql.QueryParameter();
            this.Detail = new DevExpress.XtraReports.UI.DetailBand();
            this.TopMargin = new DevExpress.XtraReports.UI.TopMarginBand();
            this.BottomMargin = new DevExpress.XtraReports.UI.BottomMarginBand();
            this.sqlDataSource1 = new DevExpress.DataAccess.Sql.SqlDataSource(this.components);
            this.ReportHeader = new DevExpress.XtraReports.UI.ReportHeaderBand();
            this.ReportFooter = new DevExpress.XtraReports.UI.ReportFooterBand();
            this.xrPivotGrid1 = new DevExpress.XtraReports.UI.XRPivotGrid();
            this.fieldSNO = new DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField();
            this.REGNO = new DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField();
            this.STUDNAME = new DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField();
            this.CODE = new DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField();
            this.SCORES = new DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField();
            this.prog = new DevExpress.XtraReports.Parameters.Parameter();
            this.yr = new DevExpress.XtraReports.Parameters.Parameter();
            this.sem = new DevExpress.XtraReports.Parameters.Parameter();
            this.acadyr = new DevExpress.XtraReports.Parameters.Parameter();
            this.intk = new DevExpress.XtraReports.Parameters.Parameter();
            this.sess = new DevExpress.XtraReports.Parameters.Parameter();
            this.entyr = new DevExpress.XtraReports.Parameters.Parameter();
            this.spe = new DevExpress.XtraReports.Parameters.Parameter();
            this.PageFooter = new DevExpress.XtraReports.UI.PageFooterBand();
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
            this.TopMargin.HeightF = 0F;
            this.TopMargin.Name = "TopMargin";
            this.TopMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.TopMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // BottomMargin
            // 
            this.BottomMargin.Dpi = 100F;
            this.BottomMargin.HeightF = 0F;
            this.BottomMargin.Name = "BottomMargin";
            this.BottomMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.BottomMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // 
            // sqlDataSource1
            // 
            this.sqlDataSource1.ConnectionName = "localhost_campus_dynamics_Connection";
            this.sqlDataSource1.Name = "sqlDataSource1";
            storedProcQuery1.Name = "campus_dynamics_acad_GetMarkSheet_BySpecialistaion";
            queryParameter1.Name = "@prog";
            queryParameter1.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter1.Value = new DevExpress.DataAccess.Expression("[Parameters.prog]", typeof(string));
            queryParameter2.Name = "@yr";
            queryParameter2.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter2.Value = new DevExpress.DataAccess.Expression("[Parameters.yr]", typeof(int));
            queryParameter3.Name = "@sem";
            queryParameter3.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter3.Value = new DevExpress.DataAccess.Expression("[Parameters.sem]", typeof(int));
            queryParameter4.Name = "@acadyr";
            queryParameter4.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter4.Value = new DevExpress.DataAccess.Expression("[Parameters.acadyr]", typeof(string));
            queryParameter5.Name = "@intk";
            queryParameter5.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter5.Value = new DevExpress.DataAccess.Expression("[Parameters.intk]", typeof(string));
            queryParameter6.Name = "@sess";
            queryParameter6.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter6.Value = new DevExpress.DataAccess.Expression("[Parameters.sess]", typeof(string));
            queryParameter7.Name = "@entyr";
            queryParameter7.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter7.Value = new DevExpress.DataAccess.Expression("[Parameters.entyr]", typeof(int));
            queryParameter8.Name = "@spe";
            queryParameter8.Type = typeof(DevExpress.DataAccess.Expression);
            queryParameter8.Value = new DevExpress.DataAccess.Expression("[Parameters.spe]", typeof(int));
            storedProcQuery1.Parameters.Add(queryParameter1);
            storedProcQuery1.Parameters.Add(queryParameter2);
            storedProcQuery1.Parameters.Add(queryParameter3);
            storedProcQuery1.Parameters.Add(queryParameter4);
            storedProcQuery1.Parameters.Add(queryParameter5);
            storedProcQuery1.Parameters.Add(queryParameter6);
            storedProcQuery1.Parameters.Add(queryParameter7);
            storedProcQuery1.Parameters.Add(queryParameter8);
            storedProcQuery1.StoredProcName = "campus_dynamics.acad_GetMarkSheet_BySpecialistaion";
            this.sqlDataSource1.Queries.AddRange(new DevExpress.DataAccess.Sql.SqlQuery[] {
            storedProcQuery1});
            this.sqlDataSource1.ResultSchemaSerializable = resources.GetString("sqlDataSource1.ResultSchemaSerializable");
            // 
            // ReportHeader
            // 
            this.ReportHeader.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrPivotGrid1});
            this.ReportHeader.Dpi = 100F;
            this.ReportHeader.HeightF = 73.04762F;
            this.ReportHeader.Name = "ReportHeader";
            // 
            // ReportFooter
            // 
            this.ReportFooter.Dpi = 100F;
            this.ReportFooter.HeightF = 0F;
            this.ReportFooter.Name = "ReportFooter";
            // 
            // xrPivotGrid1
            // 
            this.xrPivotGrid1.AnchorHorizontal = ((DevExpress.XtraReports.UI.HorizontalAnchorStyles)((DevExpress.XtraReports.UI.HorizontalAnchorStyles.Left | DevExpress.XtraReports.UI.HorizontalAnchorStyles.Right)));
            this.xrPivotGrid1.Appearance.Cell.Font = new System.Drawing.Font("Tahoma", 10F);
            this.xrPivotGrid1.Appearance.Cell.TextHorizontalAlignment = DevExpress.Utils.HorzAlignment.Near;
            this.xrPivotGrid1.Appearance.FieldHeader.Font = new System.Drawing.Font("Tahoma", 9F, System.Drawing.FontStyle.Bold);
            this.xrPivotGrid1.Appearance.FieldValue.Font = new System.Drawing.Font("Tahoma", 10F);
            this.xrPivotGrid1.Appearance.FieldValue.TextHorizontalAlignment = DevExpress.Utils.HorzAlignment.Near;
            this.xrPivotGrid1.Appearance.GrandTotalCell.ForeColor = System.Drawing.Color.Transparent;
            this.xrPivotGrid1.Appearance.Lines.BackColor = System.Drawing.Color.Transparent;
            this.xrPivotGrid1.Appearance.Lines.BorderColor = System.Drawing.Color.Black;
            this.xrPivotGrid1.Appearance.Lines.Font = new System.Drawing.Font("Tahoma", 9F);
            this.xrPivotGrid1.Appearance.Lines.ForeColor = System.Drawing.Color.Black;
            this.xrPivotGrid1.DataMember = "campus_dynamics_acad_GetMarkSheet_BySpecialistaion";
            this.xrPivotGrid1.DataSource = this.sqlDataSource1;
            this.xrPivotGrid1.Dpi = 100F;
            this.xrPivotGrid1.Fields.AddRange(new DevExpress.XtraReports.UI.PivotGrid.XRPivotGridField[] {
            this.fieldSNO,
            this.REGNO,
            this.STUDNAME,
            this.CODE,
            this.SCORES});
            this.xrPivotGrid1.LocationFloat = new DevExpress.Utils.PointFloat(12.5F, 4F);
            this.xrPivotGrid1.Name = "xrPivotGrid1";
            this.xrPivotGrid1.OptionsDataField.ColumnValueLineCount = 2;
            this.xrPivotGrid1.OptionsDataField.RowValueLineCount = 2;
            this.xrPivotGrid1.OptionsPrint.FilterSeparatorBarPadding = 3;
            this.xrPivotGrid1.OptionsPrint.PrintColumnHeaders = DevExpress.Utils.DefaultBoolean.False;
            this.xrPivotGrid1.OptionsPrint.PrintHeadersOnEveryPage = true;
            this.xrPivotGrid1.OptionsPrint.PrintHorzLines = DevExpress.Utils.DefaultBoolean.True;
            this.xrPivotGrid1.OptionsPrint.PrintVertLines = DevExpress.Utils.DefaultBoolean.True;
            this.xrPivotGrid1.OptionsView.ShowDataHeaders = false;
            this.xrPivotGrid1.OptionsView.ShowFilterHeaders = false;
            this.xrPivotGrid1.OptionsView.ShowRowTotals = false;
            this.xrPivotGrid1.SizeF = new System.Drawing.SizeF(1579.286F, 69.04762F);
            // 
            // fieldSNO
            // 
            this.fieldSNO.Area = DevExpress.XtraPivotGrid.PivotArea.RowArea;
            this.fieldSNO.AreaIndex = 0;
            this.fieldSNO.Caption = "SNO";
            this.fieldSNO.FieldName = "SNO";
            this.fieldSNO.Name = "fieldSNO";
            this.fieldSNO.SummaryType = DevExpress.Data.PivotGrid.PivotSummaryType.Custom;
            this.fieldSNO.TotalsVisibility = DevExpress.XtraPivotGrid.PivotTotalsVisibility.None;
            this.fieldSNO.Width = 30;
            // 
            // REGNO
            // 
            this.REGNO.Appearance.Cell.Font = new System.Drawing.Font("Tahoma", 8F);
            this.REGNO.Appearance.FieldValue.Font = new System.Drawing.Font("Tahoma", 8F);
            this.REGNO.Area = DevExpress.XtraPivotGrid.PivotArea.RowArea;
            this.REGNO.AreaIndex = 1;
            this.REGNO.Caption = "REGNO";
            this.REGNO.FieldName = "entryno";
            this.REGNO.Name = "REGNO";
            this.REGNO.Width = 140;
            // 
            // STUDNAME
            // 
            this.STUDNAME.Appearance.FieldValue.Font = new System.Drawing.Font("Tahoma", 8F);
            this.STUDNAME.Appearance.FieldValue.WordWrap = true;
            this.STUDNAME.Area = DevExpress.XtraPivotGrid.PivotArea.RowArea;
            this.STUDNAME.AreaIndex = 2;
            this.STUDNAME.Caption = "STUD NAME";
            this.STUDNAME.FieldName = "stud_name";
            this.STUDNAME.Name = "STUDNAME";
            this.STUDNAME.RowValueLineCount = 2;
            this.STUDNAME.Width = 140;
            // 
            // CODE
            // 
            this.CODE.Appearance.Cell.Font = new System.Drawing.Font("Tahoma", 9F, System.Drawing.FontStyle.Bold);
            this.CODE.Appearance.FieldValue.Font = new System.Drawing.Font("Tahoma", 8F, System.Drawing.FontStyle.Bold);
            this.CODE.Appearance.FieldValue.TextHorizontalAlignment = DevExpress.Utils.HorzAlignment.Near;
            this.CODE.Area = DevExpress.XtraPivotGrid.PivotArea.ColumnArea;
            this.CODE.AreaIndex = 0;
            this.CODE.Caption = "CODE";
            this.CODE.FieldName = "courseid";
            this.CODE.Name = "CODE";
            this.CODE.Width = 80;
            // 
            // SCORES
            // 
            this.SCORES.Appearance.Cell.Font = new System.Drawing.Font("Tahoma", 8F);
            this.SCORES.Appearance.FieldHeader.Font = new System.Drawing.Font("Tahoma", 9F);
            this.SCORES.Appearance.FieldHeader.TextHorizontalAlignment = DevExpress.Utils.HorzAlignment.Center;
            this.SCORES.Appearance.FieldValue.Font = new System.Drawing.Font("Tahoma", 8F);
            this.SCORES.Appearance.FieldValue.TextHorizontalAlignment = DevExpress.Utils.HorzAlignment.Near;
            this.SCORES.Area = DevExpress.XtraPivotGrid.PivotArea.DataArea;
            this.SCORES.AreaIndex = 0;
            this.SCORES.Caption = "SCORE";
            this.SCORES.ColumnValueLineCount = 2;
            this.SCORES.FieldName = "scores";
            this.SCORES.Name = "SCORES";
            this.SCORES.Options.ShowGrandTotal = false;
            this.SCORES.Options.ShowTotals = false;
            this.SCORES.RowValueLineCount = 2;
            this.SCORES.SummaryType = DevExpress.Data.PivotGrid.PivotSummaryType.Max;
            this.SCORES.TotalsVisibility = DevExpress.XtraPivotGrid.PivotTotalsVisibility.None;
            this.SCORES.Width = 108;
            // 
            // prog
            // 
            this.prog.Description = "program";
            this.prog.Name = "prog";
            // 
            // yr
            // 
            this.yr.Description = "Year";
            this.yr.Name = "yr";
            this.yr.Type = typeof(int);
            this.yr.ValueInfo = "0";
            // 
            // sem
            // 
            this.sem.Description = "Semester";
            this.sem.Name = "sem";
            this.sem.Type = typeof(int);
            this.sem.ValueInfo = "0";
            // 
            // acadyr
            // 
            this.acadyr.Description = "Academic Year";
            this.acadyr.Name = "acadyr";
            // 
            // intk
            // 
            this.intk.Description = "Intake";
            this.intk.Name = "intk";
            // 
            // sess
            // 
            this.sess.Description = "Session";
            this.sess.Name = "sess";
            // 
            // entyr
            // 
            this.entyr.Description = "Entry Year";
            this.entyr.Name = "entyr";
            this.entyr.Type = typeof(int);
            this.entyr.ValueInfo = "0";
            // 
            // spe
            // 
            this.spe.Description = "Specialisation";
            this.spe.Name = "spe";
            this.spe.Type = typeof(int);
            this.spe.ValueInfo = "0";
            // 
            // PageFooter
            // 
            this.PageFooter.Dpi = 100F;
            this.PageFooter.HeightF = 0F;
            this.PageFooter.Name = "PageFooter";
            // 
            // MarkSheet_Results
            // 
            this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.Detail,
            this.TopMargin,
            this.BottomMargin,
            this.ReportHeader,
            this.ReportFooter,
            this.PageFooter});
            this.ComponentStorage.AddRange(new System.ComponentModel.IComponent[] {
            this.sqlDataSource1});
            this.DataMember = "campus_dynamics_acad_GetMarkSheet_BySpecialistaion";
            this.DataSource = this.sqlDataSource1;
            this.Landscape = true;
            this.Margins = new System.Drawing.Printing.Margins(25, 15, 0, 0);
            this.PageHeight = 1169;
            this.PageWidth = 1654;
            this.PaperKind = System.Drawing.Printing.PaperKind.A3;
            this.Parameters.AddRange(new DevExpress.XtraReports.Parameters.Parameter[] {
            this.prog,
            this.yr,
            this.sem,
            this.acadyr,
            this.intk,
            this.sess,
            this.entyr,
            this.spe});
            this.SnappingMode = DevExpress.XtraReports.UI.SnappingMode.SnapToGrid;
            this.SnapToGrid = false;
            this.Version = "16.1";
            ((System.ComponentModel.ISupportInitialize)(this)).EndInit();

	}

	#endregion
}
