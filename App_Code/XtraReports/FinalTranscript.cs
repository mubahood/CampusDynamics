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
    private XRCrossBandBox xrCrossBandBox1;
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
            this.xrCrossBandBox1 = new DevExpress.XtraReports.UI.XRCrossBandBox();
            this.GroupHeader2 = new DevExpress.XtraReports.UI.GroupHeaderBand();
            this.GroupFooter2 = new DevExpress.XtraReports.UI.GroupFooterBand();
            this.xrSubreport3 = new DevExpress.XtraReports.UI.XRSubreport();
            this.xrLineThesisTop = new DevExpress.XtraReports.UI.XRLine();
            this.xrLineThesisBottom = new DevExpress.XtraReports.UI.XRLine();
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
            this.xrLabel29.Font = new System.Drawing.Font("Times New Roman", 5F);
            this.xrLabel29.LocationFloat = new DevExpress.Utils.PointFloat(671.8702F, 276.36F);
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
            this.xrLabel37.Font = new System.Drawing.Font("Tahoma", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel37.LocationFloat = new DevExpress.Utils.PointFloat(15.85321F, 173.2456F);
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
            this.xrBarCode2.LocationFloat = new DevExpress.Utils.PointFloat(11.52839F, 186.4588F);
            this.xrBarCode2.Name = "xrBarCode2";
            this.xrBarCode2.Padding = new DevExpress.XtraPrinting.PaddingInfo(10, 10, 0, 0, 100F);
            this.xrBarCode2.ShowText = false;
            this.xrBarCode2.SizeF = new System.Drawing.SizeF(100.3167F, 75.6245F);
            qrCodeGenerator1.CompactionMode = DevExpress.XtraPrinting.BarCode.QRCodeCompactionMode.Byte;
            qrCodeGenerator1.ErrorCorrectionLevel = DevExpress.XtraPrinting.BarCode.QRCodeErrorCorrectionLevel.H;
            qrCodeGenerator1.Version = DevExpress.XtraPrinting.BarCode.QRCodeVersion.Version8;
            this.xrBarCode2.Symbology = qrCodeGenerator1;
            // 
            // xrLabel2
            // 
            this.xrLabel2.Dpi = 100F;
            this.xrLabel2.Font = new System.Drawing.Font("Times New Roman", 10F, System.Drawing.FontStyle.Bold);
            this.xrLabel2.LocationFloat = new DevExpress.Utils.PointFloat(3.624992F, 137.6846F);
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
            this.xrLine6.LocationFloat = new DevExpress.Utils.PointFloat(5.25F, 168.1429F);
            this.xrLine6.Name = "xrLine6";
            this.xrLine6.SizeF = new System.Drawing.SizeF(762.5F, 2.083328F);
            this.xrLine6.StylePriority.UseForeColor = false;
            // 
            // xrLine5
            // 
            this.xrLine5.Dpi = 100F;
            this.xrLine5.ForeColor = System.Drawing.Color.DarkBlue;
            this.xrLine5.LocationFloat = new DevExpress.Utils.PointFloat(5.25F, 135.1429F);
            this.xrLine5.Name = "xrLine5";
            this.xrLine5.SizeF = new System.Drawing.SizeF(762.5F, 2.083328F);
            this.xrLine5.StylePriority.UseForeColor = false;
            // 
            // xrLabel1
            // 
            this.xrLabel1.Dpi = 100F;
            this.xrLabel1.LocationFloat = new DevExpress.Utils.PointFloat(93.1667F, 120.3333F);
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
            this.xrLabel38.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel38.LocationFloat = new DevExpress.Utils.PointFloat(241.9015F, 237.2679F);
            this.xrLabel38.Name = "xrLabel38";
            this.xrLabel38.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel38.SizeF = new System.Drawing.SizeF(431.9905F, 11.33328F);
            this.xrLabel38.StylePriority.UseFont = false;
            this.xrLabel38.Text = ": [prog]";
            // 
            // xrLabel34
            // 
            this.xrLabel34.Dpi = 100F;
            this.xrLabel34.Font = new System.Drawing.Font("Times New Roman", 9F);
            this.xrLabel34.LocationFloat = new DevExpress.Utils.PointFloat(127.8163F, 236.518F);
            this.xrLabel34.Name = "xrLabel34";
            this.xrLabel34.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel34.SizeF = new System.Drawing.SizeF(94.03407F, 11.33331F);
            this.xrLabel34.StylePriority.UseFont = false;
            this.xrLabel34.Text = "PROGRAM";
            // 
            // xrLabel30
            // 
            this.xrLabel30.Dpi = 100F;
            this.xrLabel30.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel30.LocationFloat = new DevExpress.Utils.PointFloat(242.9015F, 185.8513F);
            this.xrLabel30.Name = "xrLabel30";
            this.xrLabel30.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel30.SizeF = new System.Drawing.SizeF(277.5929F, 11.33339F);
            this.xrLabel30.StylePriority.UseFont = false;
            this.xrLabel30.Text = ": [entryno]";
            // 
            // xrSubreport2
            // 
            this.xrSubreport2.Dpi = 100F;
            this.xrSubreport2.LocationFloat = new DevExpress.Utils.PointFloat(392.8836F, 290.06F);
            this.xrSubreport2.Name = "xrSubreport2";
            this.xrSubreport2.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("reg", null, "acad_GetBatchStudentTranscriptData.regno"));
            this.xrSubreport2.ReportSource = new FinalTranscriptCol2();
            this.xrSubreport2.SizeF = new System.Drawing.SizeF(374.5331F, 23.00003F);
            // 
            // xrSubreport1
            // 
            this.xrSubreport1.Dpi = 100F;
            this.xrSubreport1.LocationFloat = new DevExpress.Utils.PointFloat(3.803968F, 290.54F);
            this.xrSubreport1.Name = "xrSubreport1";
            this.xrSubreport1.ParameterBindings.Add(new DevExpress.XtraReports.UI.ParameterBinding("reg", null, "acad_GetBatchStudentTranscriptData.regno"));
            this.xrSubreport1.ReportSource = new FinalTranscriptCol1();
            this.xrSubreport1.SizeF = new System.Drawing.SizeF(382.1643F, 23.00003F);
            // 
            // xrPictureBox2
            // 
            this.xrPictureBox2.BackColor = System.Drawing.Color.White;
            this.xrPictureBox2.Borders = DevExpress.XtraPrinting.BorderSide.None;
            this.xrPictureBox2.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("ImageUrl", null, "acad_GetBatchStudentTranscriptData.photo")});
            this.xrPictureBox2.Dpi = 100F;
            this.xrPictureBox2.LocationFloat = new DevExpress.Utils.PointFloat(678.9771F, 171.625F);
            this.xrPictureBox2.Name = "xrPictureBox2";
            this.xrPictureBox2.SizeF = new System.Drawing.SizeF(86.74243F, 74.55296F);
            this.xrPictureBox2.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
            this.xrPictureBox2.StylePriority.UseBackColor = false;
            this.xrPictureBox2.StylePriority.UseBorders = false;
            // 
            // xrLabel13
            // 
            this.xrLabel13.Dpi = 100F;
            this.xrLabel13.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel13.LocationFloat = new DevExpress.Utils.PointFloat(242.5682F, 199.5833F);
            this.xrLabel13.Name = "xrLabel13";
            this.xrLabel13.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel13.SizeF = new System.Drawing.SizeF(277.9263F, 12.16666F);
            this.xrLabel13.StylePriority.UseFont = false;
            this.xrLabel13.Text = ": [gen]";
            // 
            // xrLabel12
            // 
            this.xrLabel12.Dpi = 100F;
            this.xrLabel12.Font = new System.Drawing.Font("Times New Roman", 9F);
            this.xrLabel12.LocationFloat = new DevExpress.Utils.PointFloat(128.2993F, 211.8447F);
            this.xrLabel12.Name = "xrLabel12";
            this.xrLabel12.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel12.SizeF = new System.Drawing.SizeF(110.5359F, 11.33328F);
            this.xrLabel12.StylePriority.UseFont = false;
            this.xrLabel12.Text = "DATE OF BIRTH";
            // 
            // xrLabel11
            // 
            this.xrLabel11.Dpi = 100F;
            this.xrLabel11.Font = new System.Drawing.Font("Times New Roman", 9F);
            this.xrLabel11.LocationFloat = new DevExpress.Utils.PointFloat(127.3731F, 198.5833F);
            this.xrLabel11.Name = "xrLabel11";
            this.xrLabel11.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel11.SizeF = new System.Drawing.SizeF(112.4621F, 11.33331F);
            this.xrLabel11.StylePriority.UseFont = false;
            this.xrLabel11.Text = "SEX                  ";
            // 
            // xrLabel9
            // 
            this.xrLabel9.Dpi = 100F;
            this.xrLabel9.Font = new System.Drawing.Font("Times New Roman", 9F);
            this.xrLabel9.LocationFloat = new DevExpress.Utils.PointFloat(127.0833F, 185.6847F);
            this.xrLabel9.Name = "xrLabel9";
            this.xrLabel9.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel9.SizeF = new System.Drawing.SizeF(113.2007F, 10.49992F);
            this.xrLabel9.StylePriority.UseFont = false;
            this.xrLabel9.Text = "REG NO.            ";
            // 
            // xrLabel8
            // 
            this.xrLabel8.Dpi = 100F;
            this.xrLabel8.Font = new System.Drawing.Font("Times New Roman", 9F);
            this.xrLabel8.LocationFloat = new DevExpress.Utils.PointFloat(127.7104F, 224.4167F);
            this.xrLabel8.Name = "xrLabel8";
            this.xrLabel8.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel8.SizeF = new System.Drawing.SizeF(112.1987F, 11.33331F);
            this.xrLabel8.StylePriority.UseFont = false;
            this.xrLabel8.Text = "NATIONALITY";
            // 
            // xrLabel7
            // 
            this.xrLabel7.Dpi = 100F;
            this.xrLabel7.Font = new System.Drawing.Font("Times New Roman", 9F);
            this.xrLabel7.LocationFloat = new DevExpress.Utils.PointFloat(127.4584F, 172.2557F);
            this.xrLabel7.Name = "xrLabel7";
            this.xrLabel7.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel7.SizeF = new System.Drawing.SizeF(111.1174F, 12.16663F);
            this.xrLabel7.StylePriority.UseFont = false;
            this.xrLabel7.Text = "NAME               ";
            // 
            // xrLabel6
            // 
            this.xrLabel6.Dpi = 100F;
            this.xrLabel6.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel6.LocationFloat = new DevExpress.Utils.PointFloat(242.9015F, 212.5833F);
            this.xrLabel6.Name = "xrLabel6";
            this.xrLabel6.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel6.SizeF = new System.Drawing.SizeF(277.5929F, 11.33331F);
            this.xrLabel6.StylePriority.UseFont = false;
            this.xrLabel6.Text = ": [dobs!dd MMMM, yyyy]";
            // 
            // xrLabel5
            // 
            this.xrLabel5.Dpi = 100F;
            this.xrLabel5.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel5.LocationFloat = new DevExpress.Utils.PointFloat(242.5682F, 225.0852F);
            this.xrLabel5.Name = "xrLabel5";
            this.xrLabel5.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel5.SizeF = new System.Drawing.SizeF(278.2596F, 11.33334F);
            this.xrLabel5.StylePriority.UseFont = false;
            this.xrLabel5.Text = ": [nat]";
            // 
            // xrLabel4
            // 
            this.xrLabel4.Dpi = 100F;
            this.xrLabel4.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel4.LocationFloat = new DevExpress.Utils.PointFloat(242.5682F, 172.2556F);
            this.xrLabel4.Name = "xrLabel4";
            this.xrLabel4.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel4.SizeF = new System.Drawing.SizeF(396.928F, 12.1667F);
            this.xrLabel4.StylePriority.UseFont = false;
            this.xrLabel4.Text = ": [studnm]";
            // 
            // xrLabel3
            // 
            this.xrLabel3.Dpi = 100F;
            this.xrLabel3.Font = new System.Drawing.Font("Times New Roman", 10F, System.Drawing.FontStyle.Bold);
            this.xrLabel3.LocationFloat = new DevExpress.Utils.PointFloat(4.500007F, 151.5179F);
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
            this.xrPictureBox1.LocationFloat = new DevExpress.Utils.PointFloat(133.7046F, 0.3333282F);
            this.xrPictureBox1.Name = "xrPictureBox1";
            this.xrPictureBox1.SizeF = new System.Drawing.SizeF(492.5188F, 118.4734F);
            this.xrPictureBox1.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
            // 
            // GroupFooter1
            // 
            this.lblThesisLabel = new DevExpress.XtraReports.UI.XRLabel();
            this.lblThesisValue = new DevExpress.XtraReports.UI.XRLabel();
            this.lblSupervisorLabel = new DevExpress.XtraReports.UI.XRLabel();
            this.lblSupervisorValue = new DevExpress.XtraReports.UI.XRLabel();
            this.GroupFooter1.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
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
            this.GroupFooter1.HeightF = 140F;
            this.GroupFooter1.Name = "GroupFooter1";
            this.GroupFooter1.PageBreak = DevExpress.XtraReports.UI.PageBreak.AfterBand;
            this.GroupFooter1.PrintAtBottom = true;
            // 
            // ── Thesis block — placed in GroupHeader1, below the results subreports ────
            //
            // xrLineThesisTop — separator above thesis block (Y just below subreports)
            //
            this.xrLineThesisTop.Dpi = 100F;
            this.xrLineThesisTop.ForeColor = System.Drawing.Color.DarkBlue;
            this.xrLineThesisTop.LocationFloat = new DevExpress.Utils.PointFloat(4F, 293F);
            this.xrLineThesisTop.Name = "xrLineThesisTop";
            this.xrLineThesisTop.SizeF = new System.Drawing.SizeF(761.3333F, 1.5F);
            //
            // lblThesisLabel — "RESEARCH / THESIS TITLE:" heading, bold dark blue
            //
            this.lblThesisLabel.Dpi = 100F;
            this.lblThesisLabel.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold);
            this.lblThesisLabel.ForeColor = System.Drawing.Color.DarkBlue;
            this.lblThesisLabel.LocationFloat = new DevExpress.Utils.PointFloat(4F, 297F);
            this.lblThesisLabel.Name = "lblThesisLabel";
            this.lblThesisLabel.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblThesisLabel.SizeF = new System.Drawing.SizeF(761.3333F, 13F);
            this.lblThesisLabel.StylePriority.UseFont = false;
            this.lblThesisLabel.StylePriority.UseForeColor = false;
            this.lblThesisLabel.Text = "RESEARCH / THESIS TITLE:";
            this.lblThesisLabel.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblThesisLabel_BeforePrint);
            //
            // lblThesisValue — actual title text, large bold italic, multiline
            //
            this.lblThesisValue.Dpi = 100F;
            this.lblThesisValue.Font = new System.Drawing.Font("Times New Roman", 11F, (System.Drawing.FontStyle)(System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic));
            this.lblThesisValue.LocationFloat = new DevExpress.Utils.PointFloat(4F, 312F);
            this.lblThesisValue.Multiline = true;
            this.lblThesisValue.Name = "lblThesisValue";
            this.lblThesisValue.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblThesisValue.SizeF = new System.Drawing.SizeF(761.3333F, 30F);
            this.lblThesisValue.StylePriority.UseFont = false;
            this.lblThesisValue.Text = "";
            this.lblThesisValue.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblThesisValue_BeforePrint);
            //
            // lblSupervisorLabel — "SUPERVISOR:" tag
            //
            this.lblSupervisorLabel.Dpi = 100F;
            this.lblSupervisorLabel.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Bold);
            this.lblSupervisorLabel.LocationFloat = new DevExpress.Utils.PointFloat(4F, 346F);
            this.lblSupervisorLabel.Name = "lblSupervisorLabel";
            this.lblSupervisorLabel.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblSupervisorLabel.SizeF = new System.Drawing.SizeF(110F, 13F);
            this.lblSupervisorLabel.StylePriority.UseFont = false;
            this.lblSupervisorLabel.Text = "SUPERVISOR:";
            this.lblSupervisorLabel.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblSupervisorLabel_BeforePrint);
            //
            // lblSupervisorValue — supervisor name, bold
            //
            this.lblSupervisorValue.Dpi = 100F;
            this.lblSupervisorValue.Font = new System.Drawing.Font("Times New Roman", 10F, System.Drawing.FontStyle.Bold);
            this.lblSupervisorValue.LocationFloat = new DevExpress.Utils.PointFloat(118F, 346F);
            this.lblSupervisorValue.Name = "lblSupervisorValue";
            this.lblSupervisorValue.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.lblSupervisorValue.SizeF = new System.Drawing.SizeF(500F, 13F);
            this.lblSupervisorValue.StylePriority.UseFont = false;
            this.lblSupervisorValue.Text = "";
            this.lblSupervisorValue.BeforePrint += new System.Drawing.Printing.PrintEventHandler(this.lblSupervisorValue_BeforePrint);
            //
            // xrLineThesisBottom — separator below thesis block
            //
            this.xrLineThesisBottom.Dpi = 100F;
            this.xrLineThesisBottom.ForeColor = System.Drawing.Color.DarkBlue;
            this.xrLineThesisBottom.LocationFloat = new DevExpress.Utils.PointFloat(4F, 362F);
            this.xrLineThesisBottom.Name = "xrLineThesisBottom";
            this.xrLineThesisBottom.SizeF = new System.Drawing.SizeF(761.3333F, 1.5F);
            // Add thesis controls to GroupHeader1 (below the subreports)
            this.GroupHeader1.Controls.Add(this.xrLineThesisTop);
            this.GroupHeader1.Controls.Add(this.lblThesisLabel);
            this.GroupHeader1.Controls.Add(this.lblThesisValue);
            this.GroupHeader1.Controls.Add(this.lblSupervisorLabel);
            this.GroupHeader1.Controls.Add(this.lblSupervisorValue);
            this.GroupHeader1.Controls.Add(this.xrLineThesisBottom);
            // 
            // xrPanel1
            // 
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
            this.xrPanel1.LocationFloat = new DevExpress.Utils.PointFloat(7.08334F, 58F);
            this.xrPanel1.Name = "xrPanel1";
            this.xrPanel1.SizeF = new System.Drawing.SizeF(753.2498F, 71.66667F);
            this.xrPanel1.StylePriority.UseBackColor = false;
            // 
            // xrLabel27
            // 
            this.xrLabel27.Dpi = 100F;
            this.xrLabel27.Font = new System.Drawing.Font("Times New Roman", 6F);
            this.xrLabel27.LocationFloat = new DevExpress.Utils.PointFloat(24.17424F, 5F);
            this.xrLabel27.Multiline = true;
            this.xrLabel27.Name = "xrLabel27";
            this.xrLabel27.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel27.SizeF = new System.Drawing.SizeF(289.7348F, 27.66663F);
            this.xrLabel27.StylePriority.UseFont = false;
            this.xrLabel27.Text = "1. This transcript is invalid without an official seal\r\n2. The transcript can be " +
    "verified using a QR Code";
            // 
            // xrLabel26
            // 
            this.xrLabel26.Dpi = 100F;
            this.xrLabel26.Font = new System.Drawing.Font("Times New Roman", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel26.LocationFloat = new DevExpress.Utils.PointFloat(5.111688F, 5F);
            this.xrLabel26.Name = "xrLabel26";
            this.xrLabel26.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel26.SizeF = new System.Drawing.SizeF(18.06811F, 22.99998F);
            this.xrLabel26.StylePriority.UseFont = false;
            this.xrLabel26.Text = "NB";
            // 
            // xrPictureBox3
            // 
            this.xrPictureBox3.Dpi = 100F;
            this.xrPictureBox3.Image = ((System.Drawing.Image)(resources.GetObject("xrPictureBox3.Image")));
            this.xrPictureBox3.LocationFloat = new DevExpress.Utils.PointFloat(596.4753F, 0F);
            this.xrPictureBox3.Name = "xrPictureBox3";
            this.xrPictureBox3.SizeF = new System.Drawing.SizeF(152.9224F, 47.66663F);
            this.xrPictureBox3.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
            // 
            // xrLabel10
            // 
            this.xrLabel10.Dpi = 100F;
            this.xrLabel10.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel10.LocationFloat = new DevExpress.Utils.PointFloat(596.1421F, 50.99998F);
            this.xrLabel10.Name = "xrLabel10";
            this.xrLabel10.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel10.SizeF = new System.Drawing.SizeF(153.2556F, 10.16668F);
            this.xrLabel10.StylePriority.UseFont = false;
            this.xrLabel10.StylePriority.UseTextAlignment = false;
            this.xrLabel10.Text = "Dr. Musisi Fred Kamoga";
            this.xrLabel10.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // xrLabel28
            // 
            this.xrLabel28.Dpi = 100F;
            this.xrLabel28.Font = new System.Drawing.Font("Times New Roman", 8F, System.Drawing.FontStyle.Bold);
            this.xrLabel28.LocationFloat = new DevExpress.Utils.PointFloat(544.3961F, 34.16661F);
            this.xrLabel28.Name = "xrLabel28";
            this.xrLabel28.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel28.SizeF = new System.Drawing.SizeF(51.74603F, 16.83335F);
            this.xrLabel28.StylePriority.UseFont = false;
            this.xrLabel28.StylePriority.UseTextAlignment = false;
            this.xrLabel28.Text = "Sign";
            this.xrLabel28.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
            // 
            // xrLine7
            // 
            this.xrLine7.Dpi = 100F;
            this.xrLine7.LineStyle = System.Drawing.Drawing2D.DashStyle.Dot;
            this.xrLine7.LocationFloat = new DevExpress.Utils.PointFloat(596.8088F, 47.99998F);
            this.xrLine7.Name = "xrLine7";
            this.xrLine7.SizeF = new System.Drawing.SizeF(153.5889F, 2F);
            // 
            // xrPageInfo1
            // 
            this.xrPageInfo1.Dpi = 100F;
            this.xrPageInfo1.Font = new System.Drawing.Font("Times New Roman", 7F, System.Drawing.FontStyle.Bold);
            this.xrPageInfo1.Format = "{0:dd MMMM yyyy}";
            this.xrPageInfo1.LocationFloat = new DevExpress.Utils.PointFloat(592.2424F, 61.83331F);
            this.xrPageInfo1.Name = "xrPageInfo1";
            this.xrPageInfo1.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrPageInfo1.PageInfo = DevExpress.XtraPrinting.PageInfo.DateTime;
            this.xrPageInfo1.SizeF = new System.Drawing.SizeF(158.5984F, 9.833321F);
            this.xrPageInfo1.StylePriority.UseFont = false;
            this.xrPageInfo1.StylePriority.UseTextAlignment = false;
            this.xrPageInfo1.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            // 
            // xrLabel25
            // 
            this.xrLabel25.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.min_load")});
            this.xrLabel25.Dpi = 100F;
            this.xrLabel25.Font = new System.Drawing.Font("Times New Roman", 6F);
            this.xrLabel25.LocationFloat = new DevExpress.Utils.PointFloat(560.3788F, 14.40908F);
            this.xrLabel25.Name = "xrLabel25";
            this.xrLabel25.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel25.SizeF = new System.Drawing.SizeF(148.5454F, 10.49998F);
            this.xrLabel25.StylePriority.UseFont = false;
            this.xrLabel25.Text = "xrLabel23";
            // 
            // xrLabel24
            // 
            this.xrLabel24.Dpi = 100F;
            this.xrLabel24.Font = new System.Drawing.Font("Times New Roman", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel24.LocationFloat = new DevExpress.Utils.PointFloat(452.3239F, 14.09087F);
            this.xrLabel24.Name = "xrLabel24";
            this.xrLabel24.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel24.SizeF = new System.Drawing.SizeF(107.8882F, 10.49998F);
            this.xrLabel24.StylePriority.UseFont = false;
            this.xrLabel24.Text = "Minimum Graduation Load:";
            // 
            // xrLabel23
            // 
            this.xrLabel23.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.totalCU")});
            this.xrLabel23.Dpi = 100F;
            this.xrLabel23.Font = new System.Drawing.Font("Times New Roman", 6F);
            this.xrLabel23.LocationFloat = new DevExpress.Utils.PointFloat(509.3788F, 0F);
            this.xrLabel23.Name = "xrLabel23";
            this.xrLabel23.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel23.SizeF = new System.Drawing.SizeF(147.1022F, 10.49998F);
            this.xrLabel23.StylePriority.UseFont = false;
            this.xrLabel23.Text = "xrLabel23";
            // 
            // xrLabel22
            // 
            this.xrLabel22.Dpi = 100F;
            this.xrLabel22.Font = new System.Drawing.Font("Times New Roman", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel22.LocationFloat = new DevExpress.Utils.PointFloat(452.2804F, 0F);
            this.xrLabel22.Name = "xrLabel22";
            this.xrLabel22.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel22.SizeF = new System.Drawing.SizeF(56.26877F, 10.49998F);
            this.xrLabel22.StylePriority.UseFont = false;
            this.xrLabel22.Text = "Total Credits:";
            // 
            // xrLabel20
            // 
            this.xrLabel20.Dpi = 100F;
            this.xrLabel20.Font = new System.Drawing.Font("Times New Roman", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel20.LocationFloat = new DevExpress.Utils.PointFloat(12.08905F, 13.70172F);
            this.xrLabel20.Name = "xrLabel20";
            this.xrLabel20.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel20.SizeF = new System.Drawing.SizeF(64.73476F, 12.99998F);
            this.xrLabel20.StylePriority.UseFont = false;
            this.xrLabel20.Text = "Class of Award:";
            // 
            // xrLabel21
            // 
            this.xrLabel21.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.deg")});
            this.xrLabel21.Dpi = 100F;
            this.xrLabel21.Font = new System.Drawing.Font("Times New Roman", 6F);
            this.xrLabel21.LocationFloat = new DevExpress.Utils.PointFloat(77.28227F, 15.12781F);
            this.xrLabel21.Name = "xrLabel21";
            this.xrLabel21.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel21.SizeF = new System.Drawing.SizeF(360.9658F, 12.16665F);
            this.xrLabel21.StylePriority.UseFont = false;
            this.xrLabel21.Text = "xrLabel16";
            // 
            // xrLabel19
            // 
            this.xrLabel19.Dpi = 100F;
            this.xrLabel19.Font = new System.Drawing.Font("Times New Roman", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel19.LocationFloat = new DevExpress.Utils.PointFloat(12.66667F, 0F);
            this.xrLabel19.Name = "xrLabel19";
            this.xrLabel19.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel19.SizeF = new System.Drawing.SizeF(33.06811F, 12.99998F);
            this.xrLabel19.StylePriority.UseFont = false;
            this.xrLabel19.Text = "Award:";
            // 
            // xrLabel18
            // 
            this.xrLabel18.Dpi = 100F;
            this.xrLabel18.Font = new System.Drawing.Font("Times New Roman", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel18.LocationFloat = new DevExpress.Utils.PointFloat(453.7159F, 26.7046F);
            this.xrLabel18.Name = "xrLabel18";
            this.xrLabel18.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel18.SizeF = new System.Drawing.SizeF(33.06808F, 10.49998F);
            this.xrLabel18.StylePriority.UseFont = false;
            this.xrLabel18.Text = "CGPA:";
            // 
            // xrLabel17
            // 
            this.xrLabel17.Dpi = 100F;
            this.xrLabel17.Font = new System.Drawing.Font("Times New Roman", 6F, System.Drawing.FontStyle.Bold);
            this.xrLabel17.LocationFloat = new DevExpress.Utils.PointFloat(11.86172F, 28.10225F);
            this.xrLabel17.Name = "xrLabel17";
            this.xrLabel17.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel17.SizeF = new System.Drawing.SizeF(71.40144F, 12.16665F);
            this.xrLabel17.StylePriority.UseFont = false;
            this.xrLabel17.Text = "Completion Date:";
            // 
            // xrLabel16
            // 
            this.xrLabel16.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.prog")});
            this.xrLabel16.Dpi = 100F;
            this.xrLabel16.Font = new System.Drawing.Font("Times New Roman", 6F);
            this.xrLabel16.LocationFloat = new DevExpress.Utils.PointFloat(46.20446F, 0F);
            this.xrLabel16.Name = "xrLabel16";
            this.xrLabel16.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel16.SizeF = new System.Drawing.SizeF(390.1326F, 12.99998F);
            this.xrLabel16.StylePriority.UseFont = false;
            this.xrLabel16.Text = "xrLabel16";
            // 
            // xrLabel15
            // 
            this.xrLabel15.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.cgpa")});
            this.xrLabel15.Dpi = 100F;
            this.xrLabel15.Font = new System.Drawing.Font("Times New Roman", 6F);
            this.xrLabel15.LocationFloat = new DevExpress.Utils.PointFloat(488.3788F, 26.07763F);
            this.xrLabel15.Name = "xrLabel15";
            this.xrLabel15.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel15.SizeF = new System.Drawing.SizeF(149.1325F, 10.49998F);
            this.xrLabel15.StylePriority.UseFont = false;
            // 
            // xrLabel14
            // 
            this.xrLabel14.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.formated_comp_date")});
            this.xrLabel14.Dpi = 100F;
            this.xrLabel14.Font = new System.Drawing.Font("Times New Roman", 6F);
            this.xrLabel14.LocationFloat = new DevExpress.Utils.PointFloat(83.3826F, 28.67614F);
            this.xrLabel14.Name = "xrLabel14";
            this.xrLabel14.Padding = new DevExpress.XtraPrinting.PaddingInfo(2, 2, 0, 0, 100F);
            this.xrLabel14.SizeF = new System.Drawing.SizeF(216.4773F, 12.16665F);
            this.xrLabel14.StylePriority.UseFont = false;
            this.xrLabel14.Text = "xrLabel14";
            // 
            // PageFooter
            // 
            this.PageFooter.Dpi = 100F;
            this.PageFooter.HeightF = 0F;
            this.PageFooter.Name = "PageFooter";
            // 
            // xrCrossBandBox1
            // 
            this.xrCrossBandBox1.BorderColor = System.Drawing.Color.DarkBlue;
            this.xrCrossBandBox1.BorderWidth = 1F;
            this.xrCrossBandBox1.Dpi = 100F;
            this.xrCrossBandBox1.EndBand = this.GroupHeader1;
            this.xrCrossBandBox1.EndPointFloat = new DevExpress.Utils.PointFloat(0.6666629F, 314.81F);
            this.xrCrossBandBox1.LocationFloat = new DevExpress.Utils.PointFloat(0.6666629F, 288.67F);
            this.xrCrossBandBox1.Name = "xrCrossBandBox1";
            this.xrCrossBandBox1.StartBand = this.GroupHeader1;
            this.xrCrossBandBox1.StartPointFloat = new DevExpress.Utils.PointFloat(0.6666629F, 288.67F);
            this.xrCrossBandBox1.WidthF = 768.3329F;
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
            // FinalTranscript
            // 
            this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.Detail,
            this.TopMargin,
            this.BottomMargin,
            this.GroupHeader1,
            this.GroupFooter1,
            this.PageFooter,
            this.GroupHeader2,
            this.GroupFooter2});
            this.CrossBandControls.AddRange(new DevExpress.XtraReports.UI.XRCrossBandControl[] {
            this.xrCrossBandBox1});
            this.DataMember = "acad_GetBatchStudentTranscriptData";
            this.DataSource = this.resultsData1;
            this.Font = new System.Drawing.Font("Times New Roman", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
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

    /// <summary>"RESEARCH TITLE" label — hidden for non-masters or if no thesis.</summary>
    private void lblThesisLabel_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        EnsureThesisData();
        if (!ShouldShowThesisSection())
            e.Cancel = true;
    }

    /// <summary>Research title value — hidden for non-masters or if no thesis.</summary>
    private void lblThesisValue_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        if (!ShouldShowThesisSection())
        {
            e.Cancel = true;
        }
        else
        {
            (sender as XRLabel).Text = GetThesisColumnSafe("thesis_title");
        }
    }

    /// <summary>"SUPERVISOR" label — hidden for non-masters or if no thesis/supervisor.</summary>
    private void lblSupervisorLabel_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        string supervisor = GetThesisColumnSafe("supervisor_name");
        if (!ShouldShowThesisSection() || string.IsNullOrEmpty(supervisor))
            e.Cancel = true;
    }

    /// <summary>Supervisor name value — hidden for non-masters or if no thesis/supervisor.</summary>
    private void lblSupervisorValue_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        string supervisor = GetThesisColumnSafe("supervisor_name");
        if (!ShouldShowThesisSection() || string.IsNullOrEmpty(supervisor))
        {
            e.Cancel = true;
        }
        else
        {
            (sender as XRLabel).Text = supervisor;
        }
    }

    // ── Dynamic header height: collapse thesis rows for non-graduate students ──
    private const float HEADER_HEIGHT_WITH_THESIS = 316.2F;
    private const float HEADER_HEIGHT_NO_THESIS = 290.7F;
    private const float SHIFT_AMOUNT = 25.5F;

    private void GroupHeader1_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        EnsureThesisData();
        bool hasThesis = ShouldShowThesisSection();

        // Subreports (results table column headers) always stay at compact positions.
        // Only the band height changes: grow downward to reveal the thesis block.
        xrLabel29.LocationFloat    = new DevExpress.Utils.PointFloat(671.8702F, 250.8619F);
        xrSubreport1.LocationFloat = new DevExpress.Utils.PointFloat(5.803968F,  265.036F);
        xrSubreport2.LocationFloat = new DevExpress.Utils.PointFloat(392.8836F,  264.5572F);
        xrCrossBandBox1.LocationFloat    = new DevExpress.Utils.PointFloat(0.6666629F, 263.1667F);
        xrCrossBandBox1.StartPointFloat  = new DevExpress.Utils.PointFloat(0.6666629F, 263.1667F);
        xrCrossBandBox1.EndPointFloat    = new DevExpress.Utils.PointFloat(0.6666629F, 289.3122F);

        if (hasThesis)
            GroupHeader1.HeightF = 370F;   // compact (290.7) + thesis block (~79)
        else
            GroupHeader1.HeightF = HEADER_HEIGHT_NO_THESIS;
    }
}
