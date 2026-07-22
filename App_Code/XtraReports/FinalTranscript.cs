using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

/// <summary>
/// Summary description for FinalTranscript
/// </summary>
public class FinalTranscript : DevExpress.XtraReports.UI.XtraReport
{
	private DevExpress.XtraReports.UI.DetailBand Detail;
	private DevExpress.XtraReports.UI.TopMarginBand TopMargin;
	private DevExpress.XtraReports.UI.BottomMarginBand BottomMargin;
    private ResultsData resultsData1;
    private GroupHeaderBand GroupHeader1;
    private GroupFooterBand GroupFooter1;
    private XRPictureBox xrPictureBox1;
    private XRLabel xrLabel3;
    private XRPictureBox xrPictureBox2;
    private XRLabel xrLabel5;
    private XRLabel xrLabel4;
    private XRLabel xrLabel6;
    private XRLabel xrLabel7;
    private XRLabel xrLabel8;
    private XRLabel xrLabel9;
    private XRLabel xrLabel12;
    private XRLabel xrLabel11;
    private XRLabel xrLabel13;
    private XRLabel xrLabel19;
    private XRLabel xrLabel18;
    private XRLabel xrLabel17;
    private XRLabel xrLabel16;
    private XRLabel xrLabel15;
    private XRLabel xrLabel14;
    private XRLabel xrLabel20;
    private XRLabel xrLabel21;
    private XRLabel xrLabel25;
    private XRLabel xrLabel24;
    private XRLabel xrLabel23;
    private XRLabel xrLabel22;
    private XRPageInfo xrPageInfo1;
    private XRLabel xrLabel28;
    private XRLine xrLine7;
    private PageFooterBand PageFooter;
    private XRSubreport xrSubreport1;
    private XRSubreport xrSubreport2;
    private XRLabel xrLabel30;
    private XRLabel xrLabel34;
    private XRLabel xrLabel38;
    private XRLabel xrLabel37;
    private XRBarCode xrBarCode2;
    private XRLabel xrLabel2;
    private XRLine xrLine6;
    private XRLine xrLine5;
    private XRLabel xrLabel1;
    private XRPanel xrPanel1;
    private XRLabel xrLabel27;
    private XRLabel xrLabel26;
    private XRPictureBox xrPictureBox3;
    private XRLabel xrLabel10;
    private XRLabel xrLabel29;
    private GroupHeaderBand GroupHeader2;
    private GroupFooterBand GroupFooter2;
    private XRSubreport xrSubreport3;
    private XRLabel lblThesisLabel;
    private XRLabel lblThesisValue;
    private XRLabel lblSupervisorLabel;
    private XRLabel lblSupervisorValue;
    private XRLine xrLineThesisTop;
    private XRLine xrLineThesisBottom;
    private XRLine xrLine8;
    // Running per-page identity header — repeats the student's name/regno/programme
    // at the top of every continuation page when a transcript spans more than one page.
    private DevExpress.XtraReports.UI.PageHeaderBand PageHeaderIdentity;
    private XRLabel lblRunIdentity;
    private XRLine lineRunIdentity;
	/// <summary>
	/// Required designer variable.
	/// </summary>
	private System.ComponentModel.IContainer components = null;

	public FinalTranscript()
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
            string resourceFileName = "FinalTranscript.resx";
            System.Resources.ResourceManager resources = global::Resources.FinalTranscript.ResourceManager;
            DevExpress.XtraPrinting.BarCode.QRCodeGenerator qrCodeGenerator1 = new DevExpress.XtraPrinting.BarCode.QRCodeGenerator();
            this.Detail = new DevExpress.XtraReports.UI.DetailBand();
            this.TopMargin = new DevExpress.XtraReports.UI.TopMarginBand();
            this.BottomMargin = new DevExpress.XtraReports.UI.BottomMarginBand();
            this.resultsData1 = new ResultsData();
            this.GroupHeader1 = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.xrLabel29 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel37 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrBarCode2 = new DevExpress.XtraReports.UI.XRBarCode();
            this.xrLabel2 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLine6 = new DevExpress.XtraReports.UI.XRLine();
            this.xrLine5 = new DevExpress.XtraReports.UI.XRLine();
            this.xrLabel1 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel38 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel34 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel30 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrSubreport2 = new DevExpress.XtraReports.UI.XRSubreport();
            this.xrSubreport1 = new DevExpress.XtraReports.UI.XRSubreport();
            this.xrPictureBox2 = new DevExpress.XtraReports.UI.XRPictureBox();
            this.xrLabel13 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel12 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel11 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel9 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel8 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel7 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel6 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel5 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel4 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel3 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrPictureBox1 = new DevExpress.XtraReports.UI.XRPictureBox();
            this.GroupFooter1 = new DevExpress.XtraReports.UI.GroupFooterBand();
            this.xrPanel1 = new DevExpress.XtraReports.UI.XRPanel();
            this.xrLabel27 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel26 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrPictureBox3 = new DevExpress.XtraReports.UI.XRPictureBox();
            this.xrLabel10 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel28 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLine7 = new DevExpress.XtraReports.UI.XRLine();
            this.xrPageInfo1 = new DevExpress.XtraReports.UI.XRPageInfo();
            this.xrLabel25 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel24 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel23 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel22 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel20 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel21 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel19 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel18 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel17 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel16 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel15 = new DevExpress.XtraReports.UI.XRLabel();
            this.xrLabel14 = new DevExpress.XtraReports.UI.XRLabel();
            this.PageFooter = new DevExpress.XtraReports.UI.PageFooterBand();
            this.GroupHeader2 = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.GroupFooter2 = new DevExpress.XtraReports.UI.GroupFooterBand();
            this.xrSubreport3 = new DevExpress.XtraReports.UI.XRSubreport();
            this.xrLineThesisTop = new DevExpress.XtraReports.UI.XRLine();
            this.xrLineThesisBottom = new DevExpress.XtraReports.UI.XRLine();
            this.xrLine8 = new DevExpress.XtraReports.UI.XRLine();
            this.PageHeaderIdentity = new DevExpress.XtraReports.UI.PageHeaderBand();
            this.lblRunIdentity = new DevExpress.XtraReports.UI.XRLabel();
            this.lineRunIdentity = new DevExpress.XtraReports.UI.XRLine();
            ((System.ComponentModel.ISupportInitialize)(this.resultsData1)).BeginInit();
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
            this.TopMargin.HeightF = 3F;
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
            // resultsData1
            // 
            this.resultsData1.DataSetName = "ResultsData";
            this.resultsData1.SchemaSerializationMode = System.Data.SchemaSerializationMode.IncludeSchema;
            // 
            // GroupHeader1
            // 
            this.GroupHeader1.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel29,
            this.xrLabel37,
            this.xrBarCode2,
            this.xrLabel2,
            this.xrLine6,
            this.xrLine5,
            this.xrLabel1,
            this.xrLabel38,
            this.xrLabel34,
            this.xrLabel30,
            this.xrSubreport2,
            this.xrSubreport1,
            this.xrPictureBox2,
            this.xrLabel13,
            this.xrLabel12,
            this.xrLabel11,
            this.xrLabel9,
            this.xrLabel8,
            this.xrLabel7,
            this.xrLabel6,
            this.xrLabel5,
            this.xrLabel4,
            this.xrLabel3,
            this.xrPictureBox1});
            this.GroupHeader1.Dpi = 100F;
            this.GroupHeader1.GroupFields.AddRange(new DevExpress.XtraReports.UI.GroupField[] {
            new DevExpress.XtraReports.UI.GroupField("regno", DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending)});
            this.GroupHeader1.GroupUnion = DevExpress.XtraReports.UI.GroupUnion.WholePage;
            this.GroupHeader1.HeightF = 316.2F;
            this.GroupHeader1.KeepTogether = true;
            this.GroupHeader1.Name = "GroupHeader1";
            this.GroupHeader1.PageBreak = DevExpress.XtraReports.UI.PageBreak.BeforeBand;
            this.GroupHeader1.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.GroupHeader1_BeforePrint);
            // 
            // xrLabel29
            // 
            this.xrLabel29.Dpi = 100F;
            this.xrLabel29.Font = new System.Drawing.Font("Calibri", 5F);
            this.xrLabel29.LocationFloat = new DevExpress.Utils.PointFloat(671.8702F, 239.4F);
            this.xrLabel29.Name = "xrLabel29";
            this.xrLabel29.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel29.SizeF = new System.Drawing.SizeF(97.59283F, 11.3334F);
            this.xrLabel29.StylePriority.UseFont = false;
            this.xrLabel29.StylePriority.UseTextAlignment = false;
            this.xrLabel29.Text = "[regno]";
            this.xrLabel29.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            // 
            // xrLabel37
            // 
            this.xrLabel37.Dpi = 100F;
            this.xrLabel37.Font = new System.Drawing.Font("Calibri", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel37.LocationFloat = new DevExpress.Utils.PointFloat(15.85321F, 136.5F);
            this.xrLabel37.Name = "xrLabel37";
            this.xrLabel37.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel37.SizeF = new System.Drawing.SizeF(89.08978F, 12.14422F);
            this.xrLabel37.StylePriority.UseFont = false;
            this.xrLabel37.StylePriority.UseTextAlignment = false;
            this.xrLabel37.Text = "VERIFICATION";
            this.xrLabel37.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // xrBarCode2
            // 
            this.xrBarCode2.AutoModule = true;
            this.xrBarCode2.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.regno", "https://eadmin.mru.ac.ug/API/doc_verification.aspx?doc=Transcript&reg={0}")});
            this.xrBarCode2.Dpi = 100F;
            this.xrBarCode2.LocationFloat = new DevExpress.Utils.PointFloat(11.52839F, 149.5F);
            this.xrBarCode2.Name = "xrBarCode2";
            this.xrBarCode2.Padding = new DevExpress.XtraPrinting.PaddingInfo(10, 10, 0, 0, 100F);
            this.xrBarCode2.ShowText = false;
            this.xrBarCode2.SizeF = new System.Drawing.SizeF(100.3167F, 92F);
            qrCodeGenerator1.CompactionMode = DevExpress.XtraPrinting.BarCode.QRCodeCompactionMode.Byte;
            qrCodeGenerator1.ErrorCorrectionLevel = DevExpress.XtraPrinting.BarCode.QRCodeErrorCorrectionLevel.H;
            qrCodeGenerator1.Version = DevExpress.XtraPrinting.BarCode.QRCodeVersion.Version8;
            this.xrBarCode2.Symbology = qrCodeGenerator1;
            // 
            // xrLabel2
            // 
            this.xrLabel2.Dpi = 100F;
            this.xrLabel2.Font = new System.Drawing.Font("Calibri", 10F, System.Drawing.FontStyle.Bold);
            this.xrLabel2.LocationFloat = new DevExpress.Utils.PointFloat(3.624992F, 101F);
            this.xrLabel2.Name = "xrLabel2";
            this.xrLabel2.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel2.SizeF = new System.Drawing.SizeF(763.75F, 13.83336F);
            this.xrLabel2.StylePriority.UseFont = false;
            this.xrLabel2.StylePriority.UseTextAlignment = false;
            this.xrLabel2.Text = "OFFICE OF THE ACADEMIC REGISTRAR";
            this.xrLabel2.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            // 
            // xrLine6
            // 
            this.xrLine6.Dpi = 100F;
            this.xrLine6.ForeColor = System.Drawing.Color.DarkBlue;
            this.xrLine6.LocationFloat = new DevExpress.Utils.PointFloat(5.25F, 131F);
            this.xrLine6.Name = "xrLine6";
            this.xrLine6.SizeF = new System.Drawing.SizeF(762.5F, 2.083328F);
            this.xrLine6.StylePriority.UseForeColor = false;
            // 
            // xrLine5
            // 
            this.xrLine5.Dpi = 100F;
            this.xrLine5.ForeColor = System.Drawing.Color.DarkBlue;
            this.xrLine5.LocationFloat = new DevExpress.Utils.PointFloat(5.25F, 98F);
            this.xrLine5.Name = "xrLine5";
            this.xrLine5.SizeF = new System.Drawing.SizeF(762.5F, 2.083328F);
            this.xrLine5.StylePriority.UseForeColor = false;
            // 
            // xrLabel1
            // 
            this.xrLabel1.Dpi = 100F;
            this.xrLabel1.LocationFloat = new DevExpress.Utils.PointFloat(93.1667F, 83F);
            this.xrLabel1.Name = "xrLabel1";
            this.xrLabel1.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel1.SizeF = new System.Drawing.SizeF(570.8334F, 13.83331F);
            this.xrLabel1.StylePriority.UseTextAlignment = false;
            this.xrLabel1.Text = "Address: P.O.Box 14002 Mengo-Kampala, Uganda, P.O.Box 322 Masaka. Email:registrar" +
    "@mru.ac.ug";
            this.xrLabel1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            // 
            // xrLabel38
            // 
            this.xrLabel38.Dpi = 100F;
            this.xrLabel38.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel38.LocationFloat = new DevExpress.Utils.PointFloat(241.9015F, 193F);
            this.xrLabel38.Name = "xrLabel38";
            this.xrLabel38.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel38.SizeF = new System.Drawing.SizeF(431.9905F, 11.33328F);
            this.xrLabel38.StylePriority.UseFont = false;
            this.xrLabel38.Text = ": [prog]";
            // 
            // xrLabel34
            // 
            this.xrLabel34.Dpi = 100F;
            this.xrLabel34.Font = new System.Drawing.Font("Calibri", 9F);
            this.xrLabel34.LocationFloat = new DevExpress.Utils.PointFloat(127.8163F, 193F);
            this.xrLabel34.Name = "xrLabel34";
            this.xrLabel34.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel34.SizeF = new System.Drawing.SizeF(94.03407F, 11.33331F);
            this.xrLabel34.StylePriority.UseFont = false;
            this.xrLabel34.Text = "PROGRAM";
            // 
            // xrLabel30
            // 
            this.xrLabel30.Dpi = 100F;
            this.xrLabel30.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel30.LocationFloat = new DevExpress.Utils.PointFloat(242.9015F, 147F);
            this.xrLabel30.Name = "xrLabel30";
            this.xrLabel30.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel30.SizeF = new System.Drawing.SizeF(277.5929F, 11.33339F);
            this.xrLabel30.StylePriority.UseFont = false;
            this.xrLabel30.Text = ": [entryno]";
            // 
            // xrSubreport2
            // 
            this.xrSubreport2.Dpi = 100F;
            this.xrSubreport2.LocationFloat = new DevExpress.Utils.PointFloat(390F, 220F);
            this.xrSubreport2.Name = "xrSubreport2";
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("reg", null, "acad_GetBatchStudentTranscriptData.regno"));
            this.xrSubreport2.ReportSource = new FinalTranscriptCol2();
            this.xrSubreport2.SizeF = new System.Drawing.SizeF(383F, 23.00003F);
            // 
            // xrSubreport1
            // 
            this.xrSubreport1.Dpi = 100F;
            this.xrSubreport1.LocationFloat = new DevExpress.Utils.PointFloat(3F, 220F);
            this.xrSubreport1.Name = "xrSubreport1";
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("reg", null, "acad_GetBatchStudentTranscriptData.regno"));
            this.xrSubreport1.ReportSource = new FinalTranscriptCol1();
            this.xrSubreport1.SizeF = new System.Drawing.SizeF(383F, 23.00003F);
            // 
            // xrPictureBox2
            // 
            this.xrPictureBox2.BackColor = System.Drawing.Color.White;
            this.xrPictureBox2.Borders = DevExpress.XtraPrinting.BorderSide.None;
            this.xrPictureBox2.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("ImageUrl", null, "acad_GetBatchStudentTranscriptData.photo")});
            this.xrPictureBox2.Dpi = 100F;
            this.xrPictureBox2.LocationFloat = new DevExpress.Utils.PointFloat(670F, 134.5F);
            this.xrPictureBox2.Name = "xrPictureBox2";
            this.xrPictureBox2.SizeF = new System.Drawing.SizeF(97F, 90F);
            this.xrPictureBox2.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
            this.xrPictureBox2.StylePriority.UseBackColor = false;
            this.xrPictureBox2.StylePriority.UseBorders = false;
            // 
            // xrLabel13
            // 
            this.xrLabel13.Dpi = 100F;
            this.xrLabel13.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel13.LocationFloat = new DevExpress.Utils.PointFloat(242.5682F, 158.5F);
            this.xrLabel13.Name = "xrLabel13";
            this.xrLabel13.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel13.SizeF = new System.Drawing.SizeF(277.9263F, 12.16666F);
            this.xrLabel13.StylePriority.UseFont = false;
            this.xrLabel13.Text = ": [gen]";
            // 
            // xrLabel12
            // 
            this.xrLabel12.Dpi = 100F;
            this.xrLabel12.Font = new System.Drawing.Font("Calibri", 9F);
            this.xrLabel12.LocationFloat = new DevExpress.Utils.PointFloat(128.2993F, 170F);
            this.xrLabel12.Name = "xrLabel12";
            this.xrLabel12.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel12.SizeF = new System.Drawing.SizeF(110.5359F, 11.33328F);
            this.xrLabel12.StylePriority.UseFont = false;
            this.xrLabel12.Text = "DATE OF BIRTH";
            // 
            // xrLabel11
            // 
            this.xrLabel11.Dpi = 100F;
            this.xrLabel11.Font = new System.Drawing.Font("Calibri", 9F);
            this.xrLabel11.LocationFloat = new DevExpress.Utils.PointFloat(127.3731F, 158.5F);
            this.xrLabel11.Name = "xrLabel11";
            this.xrLabel11.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel11.SizeF = new System.Drawing.SizeF(112.4621F, 11.33331F);
            this.xrLabel11.StylePriority.UseFont = false;
            this.xrLabel11.Text = "SEX                  ";
            // 
            // xrLabel9
            // 
            this.xrLabel9.Dpi = 100F;
            this.xrLabel9.Font = new System.Drawing.Font("Calibri", 9F);
            this.xrLabel9.LocationFloat = new DevExpress.Utils.PointFloat(127.0833F, 147F);
            this.xrLabel9.Name = "xrLabel9";
            this.xrLabel9.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel9.SizeF = new System.Drawing.SizeF(113.2007F, 10.49992F);
            this.xrLabel9.StylePriority.UseFont = false;
            this.xrLabel9.Text = "REG NO.            ";
            // 
            // xrLabel8
            // 
            this.xrLabel8.Dpi = 100F;
            this.xrLabel8.Font = new System.Drawing.Font("Calibri", 9F);
            this.xrLabel8.LocationFloat = new DevExpress.Utils.PointFloat(127.7104F, 181.5F);
            this.xrLabel8.Name = "xrLabel8";
            this.xrLabel8.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel8.SizeF = new System.Drawing.SizeF(112.1987F, 11.33331F);
            this.xrLabel8.StylePriority.UseFont = false;
            this.xrLabel8.Text = "NATIONALITY";
            // 
            // xrLabel7
            // 
            this.xrLabel7.Dpi = 100F;
            this.xrLabel7.Font = new System.Drawing.Font("Calibri", 9F);
            this.xrLabel7.LocationFloat = new DevExpress.Utils.PointFloat(127.4584F, 135.5F);
            this.xrLabel7.Name = "xrLabel7";
            this.xrLabel7.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel7.SizeF = new System.Drawing.SizeF(111.1174F, 12.16663F);
            this.xrLabel7.StylePriority.UseFont = false;
            this.xrLabel7.Text = "NAME               ";
            // 
            // xrLabel6
            // 
            this.xrLabel6.Dpi = 100F;
            this.xrLabel6.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel6.LocationFloat = new DevExpress.Utils.PointFloat(242.9015F, 170F);
            this.xrLabel6.Name = "xrLabel6";
            this.xrLabel6.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel6.SizeF = new System.Drawing.SizeF(277.5929F, 11.33331F);
            this.xrLabel6.StylePriority.UseFont = false;
            this.xrLabel6.Text = ": [dobs!dd MMMM, yyyy]";
            // 
            // xrLabel5
            // 
            this.xrLabel5.Dpi = 100F;
            this.xrLabel5.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel5.LocationFloat = new DevExpress.Utils.PointFloat(242.5682F, 181.5F);
            this.xrLabel5.Name = "xrLabel5";
            this.xrLabel5.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel5.SizeF = new System.Drawing.SizeF(278.2596F, 11.33334F);
            this.xrLabel5.StylePriority.UseFont = false;
            this.xrLabel5.Text = ": [nat]";
            // 
            // xrLabel4
            // 
            this.xrLabel4.Dpi = 100F;
            this.xrLabel4.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel4.LocationFloat = new DevExpress.Utils.PointFloat(242.5682F, 135.5F);
            this.xrLabel4.Name = "xrLabel4";
            this.xrLabel4.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel4.SizeF = new System.Drawing.SizeF(396.928F, 12.1667F);
            this.xrLabel4.StylePriority.UseFont = false;
            this.xrLabel4.Text = ": [studnm]";
            // 
            // xrLabel3
            // 
            this.xrLabel3.Dpi = 100F;
            this.xrLabel3.Font = new System.Drawing.Font("Calibri", 10F, System.Drawing.FontStyle.Bold);
            this.xrLabel3.LocationFloat = new DevExpress.Utils.PointFloat(4.500007F, 115F);
            this.xrLabel3.Name = "xrLabel3";
            this.xrLabel3.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel3.SizeF = new System.Drawing.SizeF(762.9167F, 14.95834F);
            this.xrLabel3.StylePriority.UseFont = false;
            this.xrLabel3.StylePriority.UseTextAlignment = false;
            this.xrLabel3.Text = "ACADEMIC TRANSCRIPT";
            this.xrLabel3.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            // 
            // xrPictureBox1
            // 
            this.xrPictureBox1.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Image", null, "acad_university.logo")});
            this.xrPictureBox1.Dpi = 100F;
            this.xrPictureBox1.LocationFloat = new DevExpress.Utils.PointFloat(165F, 4F);
            this.xrPictureBox1.Name = "xrPictureBox1";
            this.xrPictureBox1.SizeF = new System.Drawing.SizeF(430F, 75F);
            this.xrPictureBox1.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
            // 
            // GroupFooter1
            // 
            this.lblThesisLabel = new DevExpress.XtraReports.UI.XRLabel();
            this.lblThesisValue = new DevExpress.XtraReports.UI.XRLabel();
            this.lblSupervisorLabel = new DevExpress.XtraReports.UI.XRLabel();
            this.lblSupervisorValue = new DevExpress.XtraReports.UI.XRLabel();
            this.GroupFooter1.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLine8,
            this.xrLineThesisTop,
            this.lblThesisLabel,
            this.lblThesisValue,
            this.lblSupervisorLabel,
            this.lblSupervisorValue,
            this.xrLineThesisBottom,
            this.xrPanel1,
            this.xrLabel25,
            this.xrLabel24,
            this.xrLabel23,
            this.xrLabel22,
            this.xrLabel20,
            this.xrLabel21,
            this.xrLabel19,
            this.xrLabel18,
            this.xrLabel17,
            this.xrLabel16,
            this.xrLabel15,
            this.xrLabel14});
            this.GroupFooter1.Dpi = 100F;
            this.GroupFooter1.HeightF = 44F;
            this.GroupFooter1.Name = "GroupFooter1";
            this.GroupFooter1.PageBreak = DevExpress.XtraReports.UI.PageBreak.AfterBand;
            this.GroupFooter1.PrintAtBottom = false;
            this.GroupFooter1.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.GroupFooter1_BeforePrint);
            // 
            // ── Thesis block — lives in GroupFooter1, positions relative to GroupFooter1 top ──
            //
            // xrLineThesisTop — brand separator above thesis block
            //
            this.xrLineThesisTop.Dpi = 100F;
            this.xrLineThesisTop.ForeColor = System.Drawing.Color.FromArgb(5, 52, 135);
            this.xrLineThesisTop.LineWidth = 2;
            this.xrLineThesisTop.LocationFloat = new DevExpress.Utils.PointFloat(3F, 4F);
            this.xrLineThesisTop.Name = "xrLineThesisTop";
            this.xrLineThesisTop.Visible = false;
            this.xrLineThesisTop.SizeF = new System.Drawing.SizeF(767F, 2F);
            //
            // lblThesisLabel — "RESEARCH / THESIS TITLE:" heading
            //
            this.lblThesisLabel.Dpi = 100F;
            this.lblThesisLabel.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.lblThesisLabel.ForeColor = System.Drawing.Color.FromArgb(5, 52, 135);
            this.lblThesisLabel.LocationFloat = new DevExpress.Utils.PointFloat(5F, 9F);
            this.lblThesisLabel.Name = "lblThesisLabel";
            this.lblThesisLabel.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblThesisLabel.SizeF = new System.Drawing.SizeF(767F, 12F);
            this.lblThesisLabel.StylePriority.UseFont = false;
            this.lblThesisLabel.StylePriority.UseForeColor = false;
            this.lblThesisLabel.Text = "RESEARCH / THESIS TITLE:";
            this.lblThesisLabel.Visible = false;
            this.lblThesisLabel.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblThesisLabel_BeforePrint);
            //
            // lblThesisValue — actual title text, bold italic, multiline
            //
            this.lblThesisValue.Dpi = 100F;
            this.lblThesisValue.Font = new System.Drawing.Font("Calibri", 9F, System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic);
            this.lblThesisValue.LocationFloat = new DevExpress.Utils.PointFloat(5F, 23F);
            this.lblThesisValue.Multiline = true;
            this.lblThesisValue.Name = "lblThesisValue";
            this.lblThesisValue.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblThesisValue.SizeF = new System.Drawing.SizeF(767F, 26F);
            this.lblThesisValue.StylePriority.UseFont = false;
            this.lblThesisValue.Text = "";
            this.lblThesisValue.Visible = false;
            this.lblThesisValue.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblThesisValue_BeforePrint);
            //
            // lblSupervisorLabel — "SUPERVISOR:" tag
            //
            this.lblSupervisorLabel.Dpi = 100F;
            this.lblSupervisorLabel.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.lblSupervisorLabel.ForeColor = System.Drawing.Color.FromArgb(5, 52, 135);
            this.lblSupervisorLabel.LocationFloat = new DevExpress.Utils.PointFloat(5F, 53F);
            this.lblSupervisorLabel.Name = "lblSupervisorLabel";
            this.lblSupervisorLabel.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblSupervisorLabel.SizeF = new System.Drawing.SizeF(90F, 12F);
            this.lblSupervisorLabel.StylePriority.UseFont = false;
            this.lblSupervisorLabel.StylePriority.UseForeColor = false;
            this.lblSupervisorLabel.Text = "SUPERVISOR:";
            this.lblSupervisorLabel.Visible = false;
            this.lblSupervisorLabel.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblSupervisorLabel_BeforePrint);
            //
            // lblSupervisorValue — supervisor name
            //
            this.lblSupervisorValue.Dpi = 100F;
            this.lblSupervisorValue.Font = new System.Drawing.Font("Calibri", 9F, System.Drawing.FontStyle.Bold);
            this.lblSupervisorValue.LocationFloat = new DevExpress.Utils.PointFloat(97F, 53F);
            this.lblSupervisorValue.Name = "lblSupervisorValue";
            this.lblSupervisorValue.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblSupervisorValue.SizeF = new System.Drawing.SizeF(500F, 12F);
            this.lblSupervisorValue.StylePriority.UseFont = false;
            this.lblSupervisorValue.Text = "";
            this.lblSupervisorValue.Visible = false;
            this.lblSupervisorValue.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblSupervisorValue_BeforePrint);
            //
            // xrLineThesisBottom — brand separator below thesis block
            //
            this.xrLineThesisBottom.Dpi = 100F;
            this.xrLineThesisBottom.ForeColor = System.Drawing.Color.FromArgb(5, 52, 135);
            this.xrLineThesisBottom.LineWidth = 2;
            this.xrLineThesisBottom.LocationFloat = new DevExpress.Utils.PointFloat(3F, 68F);
            this.xrLineThesisBottom.Name = "xrLineThesisBottom";
            this.xrLineThesisBottom.Visible = false;
            this.xrLineThesisBottom.SizeF = new System.Drawing.SizeF(767F, 2F);
            // xrLine8 — branded HR separator between results and footer (always visible)
            this.xrLine8.Dpi = 100F;
            this.xrLine8.ForeColor = System.Drawing.Color.FromArgb(5, 52, 135);
            this.xrLine8.LineWidth = 2;
            this.xrLine8.LocationFloat = new DevExpress.Utils.PointFloat(3F, 0F);
            this.xrLine8.Name = "xrLine8";
            this.xrLine8.SizeF = new System.Drawing.SizeF(767F, 2F);
            // 
            // xrPanel1 — right col: NB disclaimer + signature block
            this.xrPanel1.BackColor = System.Drawing.Color.Empty;
            this.xrPanel1.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrLabel27,
            this.xrLabel26,
            this.xrPictureBox3,
            this.xrLabel10,
            this.xrLabel28,
            this.xrLine7,
            this.xrPageInfo1});
            this.xrPanel1.Dpi = 100F;
            this.xrPanel1.LocationFloat = new DevExpress.Utils.PointFloat(470F, 3F);
            this.xrPanel1.Name = "xrPanel1";
            this.xrPanel1.SizeF = new System.Drawing.SizeF(300F, 52F);
            this.xrPanel1.StylePriority.UseBackColor = false;
            // 
            // xrLabel27 — NB disclaimer text
            this.xrLabel27.Dpi = 100F;
            this.xrLabel27.Font = new System.Drawing.Font("Calibri", 7F);
            this.xrLabel27.LocationFloat = new DevExpress.Utils.PointFloat(20F, 4F);
            this.xrLabel27.Multiline = true;
            this.xrLabel27.Name = "xrLabel27";
            this.xrLabel27.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel27.SizeF = new System.Drawing.SizeF(120F, 22F);
            this.xrLabel27.StylePriority.UseFont = false;
            this.xrLabel27.Text = "1. Invalid without official seal\r\n2. Verify via QR Code";
            // 
            // xrLabel26 — NB bold tag
            this.xrLabel26.Dpi = 100F;
            this.xrLabel26.Font = new System.Drawing.Font("Calibri", 7F, System.Drawing.FontStyle.Bold);
            this.xrLabel26.LocationFloat = new DevExpress.Utils.PointFloat(2F, 4F);
            this.xrLabel26.Name = "xrLabel26";
            this.xrLabel26.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel26.SizeF = new System.Drawing.SizeF(18F, 18F);
            this.xrLabel26.StylePriority.UseFont = false;
            this.xrLabel26.Text = "NB";
            // 
            // xrPictureBox3 — registrar seal (right of panel)
            this.xrPictureBox3.Dpi = 100F;
            this.xrPictureBox3.Image = ((System.Drawing.Image)(resources.GetObject("xrPictureBox3.Image")));
            this.xrPictureBox3.LocationFloat = new DevExpress.Utils.PointFloat(148F, 0F);
            this.xrPictureBox3.Name = "xrPictureBox3";
            this.xrPictureBox3.SizeF = new System.Drawing.SizeF(148F, 36F);
            this.xrPictureBox3.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
            // 
            // xrLabel10 — registrar name
            this.xrLabel10.Dpi = 100F;
            this.xrLabel10.Font = new System.Drawing.Font("Calibri", 7F, System.Drawing.FontStyle.Bold);
            this.xrLabel10.LocationFloat = new DevExpress.Utils.PointFloat(148F, 38F);
            this.xrLabel10.Name = "xrLabel10";
            this.xrLabel10.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel10.SizeF = new System.Drawing.SizeF(148F, 10F);
            this.xrLabel10.StylePriority.UseFont = false;
            this.xrLabel10.StylePriority.UseTextAlignment = false;
            this.xrLabel10.Text = "Dr. Musisi Fred Kamoga";
            this.xrLabel10.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // xrLabel28 — Sign label
            this.xrLabel28.Dpi = 100F;
            this.xrLabel28.Font = new System.Drawing.Font("Calibri", 7F, System.Drawing.FontStyle.Bold);
            this.xrLabel28.LocationFloat = new DevExpress.Utils.PointFloat(110F, 28F);
            this.xrLabel28.Name = "xrLabel28";
            this.xrLabel28.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel28.SizeF = new System.Drawing.SizeF(36F, 12F);
            this.xrLabel28.StylePriority.UseFont = false;
            this.xrLabel28.StylePriority.UseTextAlignment = false;
            this.xrLabel28.Text = "Sign";
            this.xrLabel28.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // xrLine7 — signature dotted line
            this.xrLine7.Dpi = 100F;
            this.xrLine7.LineStyle = System.Drawing.Drawing2D.DashStyle.Dot;
            this.xrLine7.LocationFloat = new DevExpress.Utils.PointFloat(148F, 36F);
            this.xrLine7.Name = "xrLine7";
            this.xrLine7.SizeF = new System.Drawing.SizeF(148F, 2F);
            // 
            // xrPageInfo1 — print date
            this.xrPageInfo1.Dpi = 100F;
            this.xrPageInfo1.Font = new System.Drawing.Font("Calibri", 6.5F, System.Drawing.FontStyle.Bold);
            this.xrPageInfo1.Format = "{0:dd MMMM yyyy}";
            this.xrPageInfo1.LocationFloat = new DevExpress.Utils.PointFloat(148F, 48F);
            this.xrPageInfo1.Name = "xrPageInfo1";
            this.xrPageInfo1.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrPageInfo1.PageInfo = DevExpress.XtraPrinting.PageInfo.DateTime;
            this.xrPageInfo1.SizeF = new System.Drawing.SizeF(148F, 8F);
            this.xrPageInfo1.StylePriority.UseFont = false;
            this.xrPageInfo1.StylePriority.UseTextAlignment = false;
            this.xrPageInfo1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            this.xrPageInfo1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            // 
            // xrLabel25 — min_load value | Col2 row3 value
            this.xrLabel25.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.min_load")});
            this.xrLabel25.Dpi = 100F;
            this.xrLabel25.Font = new System.Drawing.Font("Calibri", 8F);
            this.xrLabel25.LocationFloat = new DevExpress.Utils.PointFloat(358F, 30F);
            this.xrLabel25.Name = "xrLabel25";
            this.xrLabel25.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel25.SizeF = new System.Drawing.SizeF(108F, 11F);
            this.xrLabel25.StylePriority.UseFont = false;
            this.xrLabel25.Text = "";
            // 
            // xrLabel24 — Min Grad Load label | Col2 row3
            this.xrLabel24.Dpi = 100F;
            this.xrLabel24.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel24.LocationFloat = new DevExpress.Utils.PointFloat(258F, 30F);
            this.xrLabel24.Name = "xrLabel24";
            this.xrLabel24.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel24.SizeF = new System.Drawing.SizeF(98F, 11F);
            this.xrLabel24.StylePriority.UseFont = false;
            this.xrLabel24.Text = "Min. Grad. Load:";
            // 
            // xrLabel23 — totalCU value | Col2 row1 value
            this.xrLabel23.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.totalCU")});
            this.xrLabel23.Dpi = 100F;
            this.xrLabel23.Font = new System.Drawing.Font("Calibri", 8F);
            this.xrLabel23.LocationFloat = new DevExpress.Utils.PointFloat(358F, 5F);
            this.xrLabel23.Name = "xrLabel23";
            this.xrLabel23.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel23.SizeF = new System.Drawing.SizeF(108F, 11F);
            this.xrLabel23.StylePriority.UseFont = false;
            this.xrLabel23.Text = "";
            // 
            // xrLabel22 — Total Credits label | Col2 row1
            this.xrLabel22.Dpi = 100F;
            this.xrLabel22.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel22.LocationFloat = new DevExpress.Utils.PointFloat(258F, 5F);
            this.xrLabel22.Name = "xrLabel22";
            this.xrLabel22.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel22.SizeF = new System.Drawing.SizeF(98F, 11F);
            this.xrLabel22.StylePriority.UseFont = false;
            this.xrLabel22.Text = "Total Credits:";
            // 
            // xrLabel20 — Class of Award label | Col1 row2
            this.xrLabel20.Dpi = 100F;
            this.xrLabel20.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel20.LocationFloat = new DevExpress.Utils.PointFloat(5F, 18F);
            this.xrLabel20.Name = "xrLabel20";
            this.xrLabel20.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel20.SizeF = new System.Drawing.SizeF(80F, 11F);
            this.xrLabel20.StylePriority.UseFont = false;
            this.xrLabel20.Text = "Class of Award:";
            // 
            // xrLabel21 — deg value | Col1 row2 value
            this.xrLabel21.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.deg")});
            this.xrLabel21.Dpi = 100F;
            this.xrLabel21.Font = new System.Drawing.Font("Calibri", 8F);
            this.xrLabel21.LocationFloat = new DevExpress.Utils.PointFloat(87F, 18F);
            this.xrLabel21.Name = "xrLabel21";
            this.xrLabel21.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel21.SizeF = new System.Drawing.SizeF(163F, 11F);
            this.xrLabel21.StylePriority.UseFont = false;
            this.xrLabel21.Text = "";
            // 
            // xrLabel19 — Award label | Col1 row1
            this.xrLabel19.Dpi = 100F;
            this.xrLabel19.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel19.LocationFloat = new DevExpress.Utils.PointFloat(5F, 5F);
            this.xrLabel19.Name = "xrLabel19";
            this.xrLabel19.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel19.SizeF = new System.Drawing.SizeF(80F, 11F);
            this.xrLabel19.StylePriority.UseFont = false;
            this.xrLabel19.Text = "Award:";
            // 
            // xrLabel18 — CGPA label | Col2 row2
            this.xrLabel18.Dpi = 100F;
            this.xrLabel18.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel18.LocationFloat = new DevExpress.Utils.PointFloat(258F, 18F);
            this.xrLabel18.Name = "xrLabel18";
            this.xrLabel18.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel18.SizeF = new System.Drawing.SizeF(98F, 11F);
            this.xrLabel18.StylePriority.UseFont = false;
            this.xrLabel18.Text = "CGPA:";
            // 
            // xrLabel17 — Completion Date label | Col1 row3
            this.xrLabel17.Dpi = 100F;
            this.xrLabel17.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel17.LocationFloat = new DevExpress.Utils.PointFloat(5F, 30F);
            this.xrLabel17.Name = "xrLabel17";
            this.xrLabel17.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel17.SizeF = new System.Drawing.SizeF(80F, 11F);
            this.xrLabel17.StylePriority.UseFont = false;
            this.xrLabel17.Text = "Completion Date:";
            // 
            // xrLabel16 — prog value | Col1 row1 value
            this.xrLabel16.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.prog")});
            this.xrLabel16.Dpi = 100F;
            this.xrLabel16.Font = new System.Drawing.Font("Calibri", 8F);
            this.xrLabel16.LocationFloat = new DevExpress.Utils.PointFloat(87F, 5F);
            this.xrLabel16.Name = "xrLabel16";
            this.xrLabel16.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel16.SizeF = new System.Drawing.SizeF(163F, 11F);
            this.xrLabel16.StylePriority.UseFont = false;
            this.xrLabel16.Text = "";
            // 
            // xrLabel15 — cgpa value | Col2 row2 value
            this.xrLabel15.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.cgpa")});
            this.xrLabel15.Dpi = 100F;
            this.xrLabel15.Font = new System.Drawing.Font("Calibri", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel15.LocationFloat = new DevExpress.Utils.PointFloat(358F, 18F);
            this.xrLabel15.Name = "xrLabel15";
            this.xrLabel15.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel15.SizeF = new System.Drawing.SizeF(108F, 11F);
            this.xrLabel15.StylePriority.UseFont = false;
            this.xrLabel15.Text = "";
            // 
            // xrLabel14 — formated_comp_date value | Col1 row3 value
            this.xrLabel14.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.formated_comp_date")});
            this.xrLabel14.Dpi = 100F;
            this.xrLabel14.Font = new System.Drawing.Font("Calibri", 8F);
            this.xrLabel14.LocationFloat = new DevExpress.Utils.PointFloat(87F, 30F);
            this.xrLabel14.Name = "xrLabel14";
            this.xrLabel14.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel14.SizeF = new System.Drawing.SizeF(163F, 11F);
            this.xrLabel14.StylePriority.UseFont = false;
            this.xrLabel14.Text = "";
            // 
            // PageFooter
            // 
            this.PageFooter.Dpi = 100F;
            this.PageFooter.HeightF = 0F;
            this.PageFooter.Name = "PageFooter";
            // 
            // GroupHeader2
            // 
            this.GroupHeader2.Dpi = 100F;
            this.GroupHeader2.GroupFields.AddRange(new DevExpress.XtraReports.UI.GroupField[] {
            new DevExpress.XtraReports.UI.GroupField("regno", DevExpress.XtraReports.UI.XRColumnSortOrder.Ascending)});
            this.GroupHeader2.HeightF = 0F;
            this.GroupHeader2.Level = 1;
            this.GroupHeader2.Name = "GroupHeader2";
            // 
            // GroupFooter2
            // 
            this.GroupFooter2.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.xrSubreport3});
            this.GroupFooter2.Dpi = 100F;
            this.GroupFooter2.HeightF = 30.83333F;
            this.GroupFooter2.Level = 1;
            this.GroupFooter2.Name = "GroupFooter2";
            // 
            // xrSubreport3
            // 
            this.xrSubreport3.Dpi = 100F;
            this.xrSubreport3.LocationFloat = new DevExpress.Utils.PointFloat(9.166759F, 3.5F);
            this.xrSubreport3.Name = "xrSubreport3";
            this.xrSubreport3.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("regn", null, "acad_GetBatchStudentTranscriptData.regno"));
            this.xrSubreport3.ReportSource = new FinalTranscript_KeytoGrades();
            this.xrSubreport3.SizeF = new System.Drawing.SizeF(754.9999F, 23F);
            //
            // PageHeaderIdentity — slim running header, suppressed on each student's
            // first page (and single-page transcripts); shown only on continuation pages.
            //
            this.PageHeaderIdentity.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.lblRunIdentity,
            this.lineRunIdentity});
            this.PageHeaderIdentity.Dpi = 100F;
            this.PageHeaderIdentity.HeightF = 28F;
            this.PageHeaderIdentity.Name = "PageHeaderIdentity";
            this.PageHeaderIdentity.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.PageHeaderIdentity_BeforePrint);
            //
            // lblRunIdentity
            //
            this.lblRunIdentity.Dpi = 100F;
            this.lblRunIdentity.Font = new System.Drawing.Font("Calibri", 8.5F, System.Drawing.FontStyle.Bold);
            this.lblRunIdentity.ForeColor = System.Drawing.Color.DarkBlue;
            this.lblRunIdentity.LocationFloat = new DevExpress.Utils.PointFloat(5F, 6F);
            this.lblRunIdentity.Name = "lblRunIdentity";
            this.lblRunIdentity.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblRunIdentity.SizeF = new System.Drawing.SizeF(762.5F, 13F);
            this.lblRunIdentity.StylePriority.UseFont = false;
            this.lblRunIdentity.StylePriority.UseForeColor = false;
            this.lblRunIdentity.StylePriority.UseTextAlignment = false;
            this.lblRunIdentity.Text = "";
            this.lblRunIdentity.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            //
            // lineRunIdentity
            //
            this.lineRunIdentity.Dpi = 100F;
            this.lineRunIdentity.ForeColor = System.Drawing.Color.DarkBlue;
            this.lineRunIdentity.LocationFloat = new DevExpress.Utils.PointFloat(5F, 22F);
            this.lineRunIdentity.Name = "lineRunIdentity";
            this.lineRunIdentity.SizeF = new System.Drawing.SizeF(762.5F, 2.083328F);
            this.lineRunIdentity.StylePriority.UseForeColor = false;
            //
            // FinalTranscript
            //
            this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.Detail,
            this.TopMargin,
            this.BottomMargin,
            this.PageHeaderIdentity,
            this.GroupHeader1,
            this.GroupFooter1,
            this.PageFooter,
            this.GroupHeader2,
            this.GroupFooter2});
            this.DataMember = "acad_GetBatchStudentTranscriptData";
            this.DataSource = this.resultsData1;
            this.Font = new System.Drawing.Font("Calibri", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Margins = new System.Drawing.Printing.Margins(27, 27, 3, 0);
            this.PageHeight = 1169;
            this.PageWidth = 827;
            this.PaperKind = System.Drawing.Printing.PaperKind.A4;
            this.SnappingMode = DevExpress.XtraReports.UI.SnappingMode.SnapToGrid;
            this.SnapToGrid = false;
            this.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleLeft;
            this.Version = "16.1";
            ((System.ComponentModel.ISupportInitialize)(this.resultsData1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this)).EndInit();

	}

	#endregion

    // ════════════════════════════════════════════════════════════════════════
    // Thesis / Supervisor BeforePrint handlers for graduate transcripts
    // ════════════════════════════════════════════════════════════════════════

    private bool _thesisDataEnriched = false;

    /// <summary>
    /// Ensures thesis/supervisor data is in the dataset.
    /// Called once on first thesis label BeforePrint.
    /// </summary>
    private void EnsureThesisData()
    {
        if (_thesisDataEnriched) return;
        _thesisDataEnriched = true;
        try
        {
            // Use actual DataSource (set by Default.aspx.cs), not the designer placeholder
            ResultsData ds = this.DataSource as ResultsData;
            if (ds == null) ds = this.resultsData1;
            GraduateHelper.EnrichTranscriptDataBatch(ds);
        }
        catch { }
    }

    /// <summary>Safely retrieves a thesis/supervisor column value.</summary>
    private string GetThesisColumnSafe(string columnName)
    {
        try
        {
            object val = GetCurrentColumnValue(columnName);
            return (val != null && val != System.DBNull.Value) ? val.ToString().Trim() : "";
        }
        catch
        {
            return "";
        }
    }

    /// <summary>
    /// Returns true only if the student is on a Masters programme AND has
    /// at least a thesis title set. Both conditions must be met for the
    /// RESEARCH TITLE / SUPERVISOR rows to appear on the transcript.
    /// </summary>
    private bool ShouldShowThesisSection()
    {
        // 1) Check programme name — only Masters students
        string prog = "";
        try
        {
            object val = GetCurrentColumnValue("prog");
            if (val != null && val != System.DBNull.Value)
                prog = val.ToString().Trim().ToUpper();
        }
        catch { }

        bool isMasters = prog.IndexOf("MASTER", StringComparison.OrdinalIgnoreCase) >= 0;
        if (!isMasters) return false;

        // 2) Must have a thesis title actually set
        string title = GetThesisColumnSafe("thesis_title");
        return !string.IsNullOrEmpty(title);
    }

    // These individual BeforePrint handlers are defensive no-ops.
    // Actual visibility is set in GroupFooter1_BeforePrint before these fire.
    private void lblThesisLabel_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        var lbl = sender as XRLabel;
        if (lbl == null || !lbl.Visible) e.Cancel = true;
    }
    private void lblThesisValue_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        var lbl = sender as XRLabel;
        if (lbl == null || !lbl.Visible) e.Cancel = true;
    }
    private void lblSupervisorLabel_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        var lbl = sender as XRLabel;
        if (lbl == null || !lbl.Visible) e.Cancel = true;
    }
    private void lblSupervisorValue_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        var lbl = sender as XRLabel;
        if (lbl == null || !lbl.Visible) e.Cancel = true;
    }

    // ── GroupFooter1 dynamic layout — repositions content based on thesis presence ──
    private const float THESIS_BLOCK_HEIGHT = 72F;  // lines + label + value + supervisor
    private const float FOOTER_CONTENT_Y_BASE = 5F; // undergrad: content immediately below HR

    private void GroupFooter1_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        // Reset per-student so batch printing always re-enriches each student
        _thesisDataEnriched = false;
        EnsureThesisData();
        bool hasThesis = ShouldShowThesisSection();

        // ── Thesis block visibility ──
        xrLineThesisTop.Visible    = hasThesis;
        lblThesisLabel.Visible     = hasThesis;
        lblThesisValue.Visible     = hasThesis;
        xrLineThesisBottom.Visible = hasThesis;

        string supervisor = hasThesis ? GetThesisColumnSafe("supervisor_name") : "";
        bool hasSupervisor = hasThesis && !string.IsNullOrEmpty(supervisor);
        lblSupervisorLabel.Visible = hasSupervisor;
        lblSupervisorValue.Visible = hasSupervisor;
        if (hasSupervisor) lblSupervisorValue.Text = supervisor;

        if (hasThesis)
        {
            string title = GetThesisColumnSafe("thesis_title");
            lblThesisValue.Text = string.IsNullOrEmpty(title) ? "[Title not provided]" : title;
        }

        // ── Reposition footer content (Col1, Col2, Panel) ──
        float contentY = hasThesis ? (THESIS_BLOCK_HEIGHT + 4F) : FOOTER_CONTENT_Y_BASE;

        // Col1 rows
        xrLabel19.LocationFloat = new DevExpress.Utils.PointFloat(5F,   contentY);
        xrLabel16.LocationFloat = new DevExpress.Utils.PointFloat(87F,  contentY);
        xrLabel20.LocationFloat = new DevExpress.Utils.PointFloat(5F,   contentY + 12F);
        xrLabel21.LocationFloat = new DevExpress.Utils.PointFloat(87F,  contentY + 12F);
        xrLabel17.LocationFloat = new DevExpress.Utils.PointFloat(5F,   contentY + 24F);
        xrLabel14.LocationFloat = new DevExpress.Utils.PointFloat(87F,  contentY + 24F);
        // Col2 rows
        xrLabel22.LocationFloat = new DevExpress.Utils.PointFloat(258F, contentY);
        xrLabel23.LocationFloat = new DevExpress.Utils.PointFloat(358F, contentY);
        xrLabel18.LocationFloat = new DevExpress.Utils.PointFloat(258F, contentY + 12F);
        xrLabel15.LocationFloat = new DevExpress.Utils.PointFloat(358F, contentY + 12F);
        xrLabel24.LocationFloat = new DevExpress.Utils.PointFloat(258F, contentY + 24F);
        xrLabel25.LocationFloat = new DevExpress.Utils.PointFloat(358F, contentY + 24F);
        // Col3: panel
        xrPanel1.LocationFloat  = new DevExpress.Utils.PointFloat(470F, contentY - 2F);

        // ── Band height: ensure the panel (H=52) always fits below the content rows ──
        // Panel is at Y=(contentY-2), H=52 → bottom edge = contentY+50
        // Content rows span 3×12px = 36px → bottom edge = contentY+36
        // Add 4px bottom padding → required height = contentY + 54
        GroupFooter1.HeightF = hasThesis
            ? (THESIS_BLOCK_HEIGHT + 4F + 54F)  // thesis block + content rows + panel clearance
            : (FOOTER_CONTENT_Y_BASE + 54F);    // just content rows + panel clearance
    }

    private void GroupHeader1_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        // Reset flag per student so GroupFooter1_BeforePrint re-enriches thesis data for each student
        _thesisDataEnriched = false;

        // Position subreports and RegNo label consistently
        xrLabel29.LocationFloat    = new DevExpress.Utils.PointFloat(671.8702F, 214F);
        xrSubreport1.LocationFloat = new DevExpress.Utils.PointFloat(3F, 220F);
        xrSubreport2.LocationFloat = new DevExpress.Utils.PointFloat(390F, 220F);

        // GroupHeader1 has a compact static height; subreports expand the band
        // as needed to show all semester results.  The thesis section is in GroupFooter1.
        GroupHeader1.HeightF = 224F;
    }

    // ── Running per-page identity header ─────────────────────────────────────
    // The full letterhead (name, regno, programme, photo, QR) lives in GroupHeader1
    // and — because the semester results render inside subreports *within* that
    // band — it only prints once, at the top of a student's first page. When a
    // transcript overflows onto further pages, those pages would otherwise carry
    // no identity. This PageHeader band reprints a slim "name · regno · programme"
    // strip on every continuation page, so each page bears the student's basic info.
    //
    // It is suppressed on each student's FIRST page (and therefore on single-page
    // transcripts), detected by a change in regno from the previous physical page.
    // Because each student starts on a fresh page (GroupHeader1.PageBreak.BeforeBand),
    // a page whose regno equals the previous page's regno must be a continuation page.
    private string _phPrevRegno = null;

    private void PageHeaderIdentity_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        string reg = GetThesisColumnSafe("regno");
        bool continuation = reg.Length > 0
            && _phPrevRegno != null
            && string.Equals(_phPrevRegno, reg, StringComparison.OrdinalIgnoreCase);
        _phPrevRegno = reg;

        if (!continuation)
        {
            // First page of this student (or single-page transcript): no running header.
            e.Cancel = true;
            return;
        }

        string name = GetThesisColumnSafe("studnm");
        string prog = GetThesisColumnSafe("prog");
        string who = name.Length > 0 ? name : reg;

        string txt = "MUTEESA I ROYAL UNIVERSITY  •  ACADEMIC TRANSCRIPT      "
                   + who + "  •  " + reg;
        if (prog.Length > 0) txt += "  •  " + prog;
        lblRunIdentity.Text = txt;
    }
}
