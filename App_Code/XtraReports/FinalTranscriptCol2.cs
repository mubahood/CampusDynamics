using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

/// <summary>
/// Summary description for FinalTranscriptCol2
/// </summary>
public class FinalTranscriptCol2 : DevExpress.XtraReports.UI.XtraReport
{
	private DevExpress.XtraReports.UI.DetailBand Detail;
	private DevExpress.XtraReports.UI.TopMarginBand TopMargin;
	private DevExpress.XtraReports.UI.BottomMarginBand BottomMargin;
    private DevExpress.DataAccess.Sql.SqlDataSource sqlDataSource1;
    private DevExpress.XtraReports.Parameters.Parameter reg;
    private GroupHeaderBand GroupHeader2;
    private GroupFooterBand GroupFooter1;
    // Semester title label
    private XRLabel xrLabel1;
    // GPA / scores summary label
    private XRLabel xrLabel3;
    // Data row table
    private XRTable xrTable1;
    private XRTableRow xrTableRow1;
    private XRTableCell xrTableCell1; // courseid (hidden spacer)
    private XRTableCell xrTableCell2; // coursename
    private XRTableCell xrTableCell4; // CreditUnits
    private XRTableCell xrTableCell5; // grade
    // Column header table (mirrors data row weights exactly)
    private XRTable xrTableColHeaders;
    private XRTableRow xrTableRowHeader;
    private XRTableCell xrHdrCell1;
    private XRTableCell xrHdrCell2;
    private XRTableCell xrHdrCell4;
    private XRTableCell xrHdrCell5;
	/// <summary>
	/// Required designer variable.
	/// </summary>
	private System.ComponentModel.IContainer components = null;

	public FinalTranscriptCol2()
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
            string resourceFileName = "FinalTranscriptCol2.resx";
            System.Resources.ResourceManager resources = global::Resources.FinalTranscriptCol2.ResourceManager;
            this.components         = new System.ComponentModel.Container();
            DevExpress.DataAccess.Sql.StoredProcQuery storedProcQuery1 = new DevExpress.DataAccess.Sql.StoredProcQuery();
            DevExpress.DataAccess.Sql.QueryParameter  queryParameter1  = new DevExpress.DataAccess.Sql.QueryParameter();
            // Bands
            this.Detail          = new DevExpress.XtraReports.UI.DetailBand();
            this.TopMargin       = new DevExpress.XtraReports.UI.TopMarginBand();
            this.BottomMargin    = new DevExpress.XtraReports.UI.BottomMarginBand();
            this.GroupHeader2    = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.GroupFooter1    = new DevExpress.XtraReports.UI.GroupFooterBand();
            // Data row table
            this.xrTable1        = new DevExpress.XtraReports.UI.XRTable();
            this.xrTableRow1     = new DevExpress.XtraReports.UI.XRTableRow();
            this.xrTableCell1    = new DevExpress.XtraReports.UI.XRTableCell();
            this.xrTableCell2    = new DevExpress.XtraReports.UI.XRTableCell();
            this.xrTableCell4    = new DevExpress.XtraReports.UI.XRTableCell();
            this.xrTableCell5    = new DevExpress.XtraReports.UI.XRTableCell();
            // Column-header table (mirrors data row weights exactly)
            this.xrTableColHeaders  = new DevExpress.XtraReports.UI.XRTable();
            this.xrTableRowHeader   = new DevExpress.XtraReports.UI.XRTableRow();
            this.xrHdrCell1         = new DevExpress.XtraReports.UI.XRTableCell();
            this.xrHdrCell2         = new DevExpress.XtraReports.UI.XRTableCell();
            this.xrHdrCell4         = new DevExpress.XtraReports.UI.XRTableCell();
            this.xrHdrCell5         = new DevExpress.XtraReports.UI.XRTableCell();
            // Labels
            this.xrLabel1        = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel3        = new DevExpress.XtraReports.UI.XRLabel();
            // Data source + parameters
            this.sqlDataSource1  = new DevExpress.DataAccess.Sql.SqlDataSource(this.components);
            this.reg             = new DevExpress.XtraReports.Parameters.Parameter();
            ((System.ComponentModel.ISupportInitialize)(this.xrTable1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrTableColHeaders)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this)).BeginInit();
            // ── Detail band ──────────────────────────────────────────────────────────
            this.Detail.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] { this.xrTable1 });
            this.Detail.Dpi           = 100F;
            this.Detail.HeightF       = 9.6F;
            this.Detail.Name          = "Detail";
            this.Detail.Padding       = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.Detail.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // ── xrTable1 (data row template, no container border) ────────────────────
            this.xrTable1.Dpi           = 100F;
            this.xrTable1.Font          = new System.Drawing.Font("Calibri", 8.5F);
            this.xrTable1.LocationFloat = new DevExpress.Utils.PointFloat(2.291673F, 0F);
            this.xrTable1.Name          = "xrTable1";
            this.xrTable1.Rows.AddRange(new DevExpress.XtraReports.UI.XRTableRow[] { this.xrTableRow1 });
            this.xrTable1.SizeF         = new System.Drawing.SizeF(360F, 9.6F);
            this.xrTable1.Borders       = DevExpress.XtraPrinting.BorderSide.None;
            this.xrTable1.StylePriority.UseBorders       = false;
            this.xrTable1.StylePriority.UseFont          = false;
            this.xrTable1.StylePriority.UseTextAlignment = false;
            this.xrTable1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            this.xrTableRow1.Cells.AddRange(new DevExpress.XtraReports.UI.XRTableCell[] {
            this.xrTableCell1, this.xrTableCell2, this.xrTableCell4, this.xrTableCell5 });
            this.xrTableRow1.Dpi    = 100F;
            this.xrTableRow1.Name   = "xrTableRow1";
            this.xrTableRow1.Weight = 1D;
            // xrTableCell1 – course code (first visible column)
            this.xrTableCell1.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "campus_dynamics_acad_GetSingleStudentTranscript_Col2.courseid") });
            this.xrTableCell1.Dpi     = 100F;
            this.xrTableCell1.Font    = new System.Drawing.Font("Calibri", 8.5F);
            this.xrTableCell1.Name    = "xrTableCell1";
            this.xrTableCell1.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 1, 0, 0, 100F);
            this.xrTableCell1.Borders = (DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom);
            this.xrTableCell1.StylePriority.UseBorders       = false;
            this.xrTableCell1.StylePriority.UseFont          = false;
            this.xrTableCell1.StylePriority.UsePadding       = false;
            this.xrTableCell1.StylePriority.UseTextAlignment = false;
            this.xrTableCell1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            this.xrTableCell1.Weight  = 1.20D;
            // xrTableCell2 – coursename
            this.xrTableCell2.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "campus_dynamics_acad_GetSingleStudentTranscript_Col2.coursename") });
            this.xrTableCell2.Dpi     = 100F;
            this.xrTableCell2.Font    = new System.Drawing.Font("Calibri", 8F);
            this.xrTableCell2.Name    = "xrTableCell2";
            this.xrTableCell2.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 1, 0, 0, 100F);
            this.xrTableCell2.Borders = (DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom);
            this.xrTableCell2.StylePriority.UseBorders       = false;
            this.xrTableCell2.StylePriority.UseFont          = false;
            this.xrTableCell2.StylePriority.UsePadding       = false;
            this.xrTableCell2.StylePriority.UseTextAlignment = false;
            this.xrTableCell2.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            this.xrTableCell2.Weight        = 3.26D;
            // xrTableCell4 – CreditUnits
            this.xrTableCell4.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "campus_dynamics_acad_GetSingleStudentTranscript_Col2.CreditUnits") });
            this.xrTableCell4.Dpi     = 100F;
            this.xrTableCell4.Font    = new System.Drawing.Font("Calibri", 8.5F);
            this.xrTableCell4.Name    = "xrTableCell4";
            this.xrTableCell4.Padding = new DevExpress.XtraPrinting.PaddingInfo(1, 1, 0, 0, 100F);
            this.xrTableCell4.Borders = (DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom);
            this.xrTableCell4.StylePriority.UseBorders       = false;
            this.xrTableCell4.StylePriority.UseFont          = false;
            this.xrTableCell4.StylePriority.UsePadding       = false;
            this.xrTableCell4.StylePriority.UseTextAlignment = false;
            this.xrTableCell4.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            this.xrTableCell4.Weight        = 0.65D;
            // xrTableCell5 – grade
            this.xrTableCell5.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "campus_dynamics_acad_GetSingleStudentTranscript_Col2.grade") });
            this.xrTableCell5.Dpi     = 100F;
            this.xrTableCell5.Font    = new System.Drawing.Font("Calibri", 8.5F);
            this.xrTableCell5.Name    = "xrTableCell5";
            this.xrTableCell5.Padding = new DevExpress.XtraPrinting.PaddingInfo(1, 1, 0, 0, 100F);
            this.xrTableCell5.Borders = (DevExpress.XtraPrinting.BorderSide.Left | DevExpress.XtraPrinting.BorderSide.Right | DevExpress.XtraPrinting.BorderSide.Bottom);
            this.xrTableCell5.StylePriority.UseBorders       = false;
            this.xrTableCell5.StylePriority.UseFont          = false;
            this.xrTableCell5.StylePriority.UsePadding       = false;
            this.xrTableCell5.StylePriority.UseTextAlignment = false;
            this.xrTableCell5.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            this.xrTableCell5.Weight        = 0.75D;
            // ── TopMargin / BottomMargin ──────────────────────────────────────────────
            this.TopMargin.Dpi            = 100F;
            this.TopMargin.HeightF        = 0F;
            this.TopMargin.Name           = "TopMargin";
            this.TopMargin.Padding        = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.TopMargin.TextAlignment  = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            this.BottomMargin.Dpi         = 100F;
            this.BottomMargin.HeightF     = 5F;
            this.BottomMargin.Name        = "BottomMargin";
            this.BottomMargin.Padding     = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
            this.BottomMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
            // ── Data source ───────────────────────────────────────────────────────────
            this.sqlDataSource1.ConnectionName = "localhost_campus_dynamics_Connection 1";
            this.sqlDataSource1.Name           = "sqlDataSource1";
            storedProcQuery1.Name              = "campus_dynamics_acad_GetSingleStudentTranscript_Col2";
            queryParameter1.Name  = "@reg";
            queryParameter1.Type  = typeof(DevExpress.DataAccess.Expression);
            queryParameter1.Value = new DevExpress.DataAccess.Expression("[Parameters.reg]", typeof(string));
            storedProcQuery1.Parameters.Add(queryParameter1);
            storedProcQuery1.StoredProcName = "campus_dynamics.acad_GetSingleStudentTranscript_Col2";
            this.sqlDataSource1.Queries.AddRange(new DevExpress.DataAccess.Sql.SqlQuery[] { storedProcQuery1 });
            this.sqlDataSource1.ResultSchemaSerializable = resources.GetString("sqlDataSource1.ResultSchemaSerializable");
            this.reg.Name = "reg";
            // ── GroupFooter1 ──────────────────────────────────────────────────────────
            this.GroupFooter1.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] { this.xrLabel3 });
            this.GroupFooter1.Dpi     = 100F;
            this.GroupFooter1.HeightF = 24F;
            this.GroupFooter1.Name    = "GroupFooter1";
            // xrLabel3 – SemesterScores summary (styled bottom of each semester block)
            this.xrLabel3.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "campus_dynamics_acad_GetSingleStudentTranscript_Col2.SemesterScores") });
            this.xrLabel3.Dpi           = 100F;
            this.xrLabel3.Font          = new System.Drawing.Font("Calibri", 8.5F, System.Drawing.FontStyle.Bold);
            this.xrLabel3.ForeColor     = System.Drawing.Color.FromArgb(5, 52, 135);
            this.xrLabel3.BackColor     = System.Drawing.Color.FromArgb(235, 240, 252);
            this.xrLabel3.Borders       = DevExpress.XtraPrinting.BorderSide.All;
            this.xrLabel3.BorderColor   = System.Drawing.Color.FromArgb(3, 40, 110);
            this.xrLabel3.LocationFloat = new DevExpress.Utils.PointFloat(2.291673F, 0F);
            this.xrLabel3.Name          = "xrLabel3";
            this.xrLabel3.Padding       = new DevExpress.XtraPrinting.PaddingInfo(2, 1, 0, 0, 100F);
            this.xrLabel3.SizeF         = new System.Drawing.SizeF(360F, 13F);
            this.xrLabel3.StylePriority.UseBackColor    = false;
            this.xrLabel3.StylePriority.UseBorderColor  = false;
            this.xrLabel3.StylePriority.UseBorders      = false;
            this.xrLabel3.StylePriority.UseFont         = false;
            this.xrLabel3.StylePriority.UseForeColor    = false;
            this.xrLabel3.StylePriority.UsePadding      = false;
            this.xrLabel3.StylePriority.UseTextAlignment = false;
            this.xrLabel3.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            // ── GroupHeader2 ─────────────────────────────────────────────────────────
            // xrLabel1 – semester title bar (top of each semester block)
            this.xrLabel1.Dpi           = 100F;
            this.xrLabel1.Font          = new System.Drawing.Font("Calibri", 8.5F, System.Drawing.FontStyle.Bold);
            this.xrLabel1.ForeColor     = System.Drawing.Color.Black;
            this.xrLabel1.BackColor     = System.Drawing.Color.White;
            this.xrLabel1.Borders       = DevExpress.XtraPrinting.BorderSide.All;
            this.xrLabel1.BorderColor   = System.Drawing.Color.Silver;
            this.xrLabel1.LocationFloat = new DevExpress.Utils.PointFloat(2.291673F, 1F);
            this.xrLabel1.Name          = "xrLabel1";
            this.xrLabel1.Padding       = new DevExpress.XtraPrinting.PaddingInfo(4, 2, 0, 0, 100F);
            this.xrLabel1.SizeF         = new System.Drawing.SizeF(360F, 13F);
            this.xrLabel1.StylePriority.UseBackColor    = false;
            this.xrLabel1.StylePriority.UseBorderColor  = false;
            this.xrLabel1.StylePriority.UseBorders      = false;
            this.xrLabel1.StylePriority.UseFont         = false;
            this.xrLabel1.StylePriority.UseForeColor    = false;
            this.xrLabel1.StylePriority.UsePadding      = false;
            this.xrLabel1.StylePriority.UseTextAlignment = false;
            this.xrLabel1.Text          = "Year [studyyear]  —  [sys] [semester]  |  Academic Year [acad]";
            this.xrLabel1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            // xrTableColHeaders – column header row (IDENTICAL weights to xrTable1 → guaranteed alignment)
            this.xrTableColHeaders.Dpi           = 100F;
            this.xrTableColHeaders.Font          = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrTableColHeaders.LocationFloat = new DevExpress.Utils.PointFloat(2.291673F, 14.5F);
            this.xrTableColHeaders.Name          = "xrTableColHeaders";
            this.xrTableColHeaders.Rows.AddRange(new DevExpress.XtraReports.UI.XRTableRow[] { this.xrTableRowHeader });
            this.xrTableColHeaders.SizeF         = new System.Drawing.SizeF(360F, 9.6F);
            this.xrTableColHeaders.Borders       = DevExpress.XtraPrinting.BorderSide.None;
            this.xrTableColHeaders.StylePriority.UseBorders       = false;
            this.xrTableColHeaders.StylePriority.UseFont          = false;
            this.xrTableColHeaders.StylePriority.UseTextAlignment = false;
            this.xrTableColHeaders.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            this.xrTableRowHeader.Cells.AddRange(new DevExpress.XtraReports.UI.XRTableCell[] {
            this.xrHdrCell1, this.xrHdrCell2, this.xrHdrCell4, this.xrHdrCell5 });
            this.xrTableRowHeader.Dpi    = 100F;
            this.xrTableRowHeader.Name   = "xrTableRowHeader";
            this.xrTableRowHeader.Weight = 1D;
            // xrHdrCell1 – CODE header (matches xrTableCell1)
            this.xrHdrCell1.Dpi     = 100F;
            this.xrHdrCell1.Font    = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrHdrCell1.Name    = "xrHdrCell1";
            this.xrHdrCell1.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 1, 0, 0, 100F);
            this.xrHdrCell1.Borders = DevExpress.XtraPrinting.BorderSide.All;
            this.xrHdrCell1.BorderColor = System.Drawing.Color.Silver;
            this.xrHdrCell1.BackColor = System.Drawing.Color.White;
            this.xrHdrCell1.StylePriority.UseBackColor = false;
            this.xrHdrCell1.StylePriority.UseBorderColor = false;
            this.xrHdrCell1.StylePriority.UseBorders = false;
            this.xrHdrCell1.StylePriority.UseFont = false;
            this.xrHdrCell1.StylePriority.UsePadding = false;
            this.xrHdrCell1.StylePriority.UseTextAlignment = false;
            this.xrHdrCell1.Text = "CODE";
            this.xrHdrCell1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            this.xrHdrCell1.Weight  = 1.20D;
            // xrHdrCell2 – COURSE header (matches xrTableCell2)
            this.xrHdrCell2.Dpi         = 100F;
            this.xrHdrCell2.Font        = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrHdrCell2.Name        = "xrHdrCell2";
            this.xrHdrCell2.Padding     = new DevExpress.XtraPrinting.PaddingInfo(2, 1, 0, 0, 100F);
            this.xrHdrCell2.Borders     = DevExpress.XtraPrinting.BorderSide.All;
            this.xrHdrCell2.BorderColor = System.Drawing.Color.Silver;
            this.xrHdrCell2.BackColor   = System.Drawing.Color.White;
            this.xrHdrCell2.StylePriority.UseBackColor    = false;
            this.xrHdrCell2.StylePriority.UseBorderColor  = false;
            this.xrHdrCell2.StylePriority.UseBorders      = false;
            this.xrHdrCell2.StylePriority.UseFont         = false;
            this.xrHdrCell2.StylePriority.UsePadding      = false;
            this.xrHdrCell2.StylePriority.UseTextAlignment = false;
            this.xrHdrCell2.Text          = "COURSE";
            this.xrHdrCell2.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            this.xrHdrCell2.Weight        = 3.26D;
            // xrHdrCell4 – CU header (matches xrTableCell4)
            this.xrHdrCell4.Dpi         = 100F;
            this.xrHdrCell4.Font        = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrHdrCell4.Name        = "xrHdrCell4";
            this.xrHdrCell4.Padding     = new DevExpress.XtraPrinting.PaddingInfo(1, 1, 0, 0, 100F);
            this.xrHdrCell4.Borders     = DevExpress.XtraPrinting.BorderSide.All;
            this.xrHdrCell4.BorderColor = System.Drawing.Color.Silver;
            this.xrHdrCell4.BackColor   = System.Drawing.Color.White;
            this.xrHdrCell4.StylePriority.UseBackColor    = false;
            this.xrHdrCell4.StylePriority.UseBorderColor  = false;
            this.xrHdrCell4.StylePriority.UseBorders      = false;
            this.xrHdrCell4.StylePriority.UseFont         = false;
            this.xrHdrCell4.StylePriority.UsePadding      = false;
            this.xrHdrCell4.StylePriority.UseTextAlignment = false;
            this.xrHdrCell4.Text          = "CU";
            this.xrHdrCell4.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            this.xrHdrCell4.Weight        = 0.65D;
            // xrHdrCell5 – GRADE header (matches xrTableCell5)
            this.xrHdrCell5.Dpi         = 100F;
            this.xrHdrCell5.Font        = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrHdrCell5.Name        = "xrHdrCell5";
            this.xrHdrCell5.Padding     = new DevExpress.XtraPrinting.PaddingInfo(1, 1, 0, 0, 100F);
            this.xrHdrCell5.Borders     = DevExpress.XtraPrinting.BorderSide.All;
            this.xrHdrCell5.BorderColor = System.Drawing.Color.Silver;
            this.xrHdrCell5.BackColor   = System.Drawing.Color.White;
            this.xrHdrCell5.StylePriority.UseBackColor    = false;
            this.xrHdrCell5.StylePriority.UseBorderColor  = false;
            this.xrHdrCell5.StylePriority.UseBorders      = false;
            this.xrHdrCell5.StylePriority.UseFont         = false;
            this.xrHdrCell5.StylePriority.UsePadding      = false;
            this.xrHdrCell5.StylePriority.UseTextAlignment = false;
            this.xrHdrCell5.Text          = "GRADE";
            this.xrHdrCell5.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            this.xrHdrCell5.Weight        = 0.75D;
            // GroupHeader2 – semester title + aligned column-header table
            this.GroupHeader2.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel1,
            this.xrTableColHeaders });
            this.GroupHeader2.Dpi     = 100F;
            this.GroupHeader2.GroupFields.AddRange(new DevExpress.XtraReports.UI.GroupField[] {
            new DevExpress.XtraReports.UI.GroupField("studyyear", DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending),
            new DevExpress.XtraReports.UI.GroupField("semester",  DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending) });
            this.GroupHeader2.HeightF = 25F;
            this.GroupHeader2.Level   = 1;
            this.GroupHeader2.Name    = "GroupHeader2";
            // ── Report root ───────────────────────────────────────────────────────────
            this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.Detail, this.TopMargin, this.BottomMargin, this.GroupHeader2, this.GroupFooter1 });
            this.ComponentStorage.AddRange(new System.ComponentModel.IComponent[] { this.sqlDataSource1 });
            this.DataMember = "campus_dynamics_acad_GetSingleStudentTranscript_Col2";
            this.DataSource = this.sqlDataSource1;
            this.Font       = new System.Drawing.Font("Calibri", 9F);
            this.Margins    = new System.Drawing.Printing.Margins(10, 10, 0, 0);
            this.PageHeight = 827;
            this.PageWidth  = 383;
            this.PaperKind  = System.Drawing.Printing.PaperKind.A5;
            this.Parameters.AddRange(new DevExpress.XtraReports.Parameters.Parameter[] { this.reg });
            this.SnappingMode  = DevExpress.XtraReports.UI.SnappingMode.SnapToGrid;
            this.SnapToGrid    = false;
            this.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            this.Version       = "16.1";
            ((System.ComponentModel.ISupportInitialize)(this.xrTable1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.xrTableColHeaders)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this)).EndInit();

	}

	#endregion
}

