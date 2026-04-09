using System;
using System.Drawing;
using System.Collections.Generic;
using System.ComponentModel;
using DevExpress.XtraReports.UI;
using System.Globalization;

/// <summary>
/// Masters Letter of Award — Professional A4 academic letter.
/// Fonts  : "Times New Roman" (headings/name/degree) | "Georgia" (body) | "Calibri" (metadata)
/// Color  : #002365 (primary navy) for all emphasis, borders and headings
/// Layout : Single A4 page, TenthsOfAMillimeter coordinate system (2100×2970)
/// QR     : https://eadmin.mru.ac.ug/Verify.aspx?reg_no={regno} — centered, 190×190
/// Ref    : Auto-generated "MLA/{REGNO}/{YEAR}" from data column
/// Date   : Auto-generated DateTime.Now — no popup required
/// Senate : SenateApprovalDate parameter — the only value collected from popup
/// </summary>
public class MastersLetterOfAward : DevExpress.XtraReports.UI.XtraReport
{
    private DevExpress.XtraReports.UI.DetailBand Detail;
    private DevExpress.XtraReports.UI.TopMarginBand TopMargin;
    private DevExpress.XtraReports.UI.BottomMarginBand BottomMargin;
    private DevExpress.XtraReports.UI.PageHeaderBand PageHeader;
    private ResultsData resultsData1;
    private System.ComponentModel.IContainer components = null;

    // Class-level fields for controls that have BeforePrint handlers.
    // Required pattern for DX v16.1 — lambda closures are not serialisable
    // and cause NullReferenceException in ReportWebMediator.GenerateExportOptions.
    private XRLabel lblRef;
    private XRLabel lblDate;
    private XRLabel lblSubject;
    private XRLabel lblName;
    private XRLabel lblRegComp;
    private XRLabel lblDegree;
    private XRLabel lblThesisHeader;
    private XRLabel lblThesisTitle;
    private XRLabel lblSupervisorHeader;
    private XRLabel lblSupervisorName;
    private XRLabel lblSenate;
    private XRLabel lblGraduation;
    private XRBarCode qrcode;

    public MastersLetterOfAward()
    {
        InitializeComponent();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null)) components.Dispose();
        base.Dispose(disposing);
    }

    private void InitializeComponent()
    {
        // QR generator settings:
        //   CompactionMode.Byte — required for URL strings (handles / : ? = chars)
        //   ErrorCorrectionLevel.M — "Medium" (15% recovery). Using H (30% recovery) with Version8
        //     limits data capacity to only ~30 bytes; our URL is ~65+ chars so DX auto-upgrades
        //     to a much larger version (e.g. V15 = 77×77 modules) which then fails "boundaries too
        //     small" on any reasonable control size. With M, Version8 supports 86 bytes — enough
        //     for our full verification URL. QR codes on printed letters are always well-lit so
        //     M-level error recovery is entirely sufficient.
        DevExpress.XtraPrinting.BarCode.QRCodeGenerator qrGen =
            new DevExpress.XtraPrinting.BarCode.QRCodeGenerator();
        qrGen.CompactionMode       = DevExpress.XtraPrinting.BarCode.QRCodeCompactionMode.Byte;
        qrGen.ErrorCorrectionLevel = DevExpress.XtraPrinting.BarCode.QRCodeErrorCorrectionLevel.M;
        qrGen.Version              = DevExpress.XtraPrinting.BarCode.QRCodeVersion.Version8;

        this.Detail       = new DevExpress.XtraReports.UI.DetailBand();
        this.TopMargin    = new DevExpress.XtraReports.UI.TopMarginBand();
        this.BottomMargin = new DevExpress.XtraReports.UI.BottomMarginBand();
        this.PageHeader   = new DevExpress.XtraReports.UI.PageHeaderBand();
        this.resultsData1 = new ResultsData();

        this.lblRef        = new XRLabel();
        this.lblDate       = new XRLabel();
        this.lblSubject    = new XRLabel();
        this.lblName       = new XRLabel();
        this.lblRegComp    = new XRLabel();
        this.lblDegree     = new XRLabel();
        this.lblThesisHeader    = new XRLabel();
        this.lblThesisTitle     = new XRLabel();
        this.lblSupervisorHeader = new XRLabel();
        this.lblSupervisorName   = new XRLabel();
        this.lblSenate     = new XRLabel();
        this.lblGraduation = new XRLabel();
        this.qrcode        = new XRBarCode();

        ((System.ComponentModel.ISupportInitialize)(this.resultsData1)).BeginInit();
        ((System.ComponentModel.ISupportInitialize)(this)).BeginInit();

        // ── Parameters (kept for backward-compat with Default.aspx.cs) ─────
        DevExpress.XtraReports.Parameters.Parameter pLetterDate  = new DevExpress.XtraReports.Parameters.Parameter();
        pLetterDate.Name = "LetterDate"; pLetterDate.Type = typeof(string); pLetterDate.Value = "";

        DevExpress.XtraReports.Parameters.Parameter pSenateDate  = new DevExpress.XtraReports.Parameters.Parameter();
        pSenateDate.Name = "SenateApprovalDate"; pSenateDate.Type = typeof(string); pSenateDate.Value = "";

        DevExpress.XtraReports.Parameters.Parameter pGradDate    = new DevExpress.XtraReports.Parameters.Parameter();
        pGradDate.Name = "GraduationDate"; pGradDate.Type = typeof(string); pGradDate.Value = "";

        DevExpress.XtraReports.Parameters.Parameter pRef         = new DevExpress.XtraReports.Parameters.Parameter();
        pRef.Name = "RefNumber"; pRef.Type = typeof(string); pRef.Value = "";

        DevExpress.XtraReports.Parameters.Parameter pHonours     = new DevExpress.XtraReports.Parameters.Parameter();
        pHonours.Name = "Honours"; pHonours.Type = typeof(string); pHonours.Value = "";

        this.Parameters.AddRange(new DevExpress.XtraReports.Parameters.Parameter[] {
            pLetterDate, pSenateDate, pGradDate, pRef, pHonours });

        // ════════════════════════════════════════════════════════════════════
        // PAGE HEADER — University letterhead from DB
        // Same DataBinding pattern as Certificate.cs (acad_university.logo)
        // Reduced height: logo 260 units (26 mm) + rule + padding = 340 total
        // ════════════════════════════════════════════════════════════════════

        XRPictureBox universityLogo = new XRPictureBox();
        universityLogo.Dpi           = 254F;
        universityLogo.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Image", null, "acad_university.logo") });
        universityLogo.LocationFloat = new DevExpress.Utils.PointFloat(200F, 40F);
        universityLogo.SizeF         = new System.Drawing.SizeF(1520F, 270F);   // reduced from 395 → 270
        universityLogo.Sizing        = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
        universityLogo.Name          = "universityLogo";

        // Double navy rule — top thin line + thick base line
        XRLine ruleTop = new XRLine();
        ruleTop.Dpi           = 254F;
        ruleTop.LineWidth     = 1;
        ruleTop.ForeColor     = Color.FromArgb(0, 35, 101);
        ruleTop.LocationFloat = new DevExpress.Utils.PointFloat(0F, 320F);
        ruleTop.SizeF         = new System.Drawing.SizeF(1950F, 4F);

        XRLine ruleBase = new XRLine();
        ruleBase.Dpi           = 254F;
        ruleBase.LineWidth     = 5;
        ruleBase.ForeColor     = Color.FromArgb(0, 35, 101);
        ruleBase.LocationFloat = new DevExpress.Utils.PointFloat(0F, 330F);
        ruleBase.SizeF         = new System.Drawing.SizeF(1950F, 5F);

        this.PageHeader.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            universityLogo, ruleTop, ruleBase });
        this.PageHeader.Dpi     = 254F;
        this.PageHeader.HeightF = 350F;
        this.PageHeader.Name    = "PageHeader";

        // ════════════════════════════════════════════════════════════════════
        // DETAIL BAND
        // Coordinate system: TenthsOfAMillimeter
        //   A4 = 2100 wide, margins 76+76 → usable 1948
        //   contentLeft = 25, contentWidth = 1900 → right edge 1925 ✓
        // ════════════════════════════════════════════════════════════════════

        this.Detail.Dpi           = 254F;
        this.Detail.Name          = "Detail";
        this.Detail.Padding       = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 254F);
        this.Detail.PageBreak     = DevExpress.XtraReports.UI.PageBreak.None;
        this.Detail.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;

        // Design constants
        Color navy  = Color.FromArgb(0, 35, 101);     // #002365 — primary brand colour
        Color rule  = Color.FromArgb(0, 35, 101);
        Color muted = Color.FromArgb(100, 100, 100);
        float L     = 30F;     // content left margin
        float W     = 1880F;   // content width (right edge = 1910, within usable 1948)
        float y     = 22F;     // running Y position

        // ── Reference (left) + Date (right) — top metadata row ───────────

        this.lblRef.Dpi           = 254F;
        this.lblRef.Font          = new Font("Calibri", 9.5F);
        this.lblRef.ForeColor     = muted;
        this.lblRef.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblRef.SizeF         = new System.Drawing.SizeF(W / 2, 28F);
        this.lblRef.StylePriority.UseFont          = false;
        this.lblRef.StylePriority.UseForeColor     = false;
        this.lblRef.StylePriority.UseTextAlignment = false;
        this.lblRef.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
        this.lblRef.Name          = "lblRef";
        this.lblRef.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblRef_BeforePrint);

        this.lblDate.Dpi           = 254F;
        this.lblDate.Font          = new Font("Calibri", 9.5F);
        this.lblDate.ForeColor     = muted;
        this.lblDate.LocationFloat = new DevExpress.Utils.PointFloat(L + W / 2, y);
        this.lblDate.SizeF         = new System.Drawing.SizeF(W / 2, 28F);
        this.lblDate.StylePriority.UseFont          = false;
        this.lblDate.StylePriority.UseForeColor     = false;
        this.lblDate.StylePriority.UseTextAlignment = false;
        this.lblDate.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopRight;
        this.lblDate.Name          = "lblDate";
        this.lblDate.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblDate_BeforePrint);
        y += 36F;

        // Thin divider below metadata
        XRLine divTop = new XRLine();
        divTop.Dpi           = 254F;
        divTop.LineWidth     = 1;
        divTop.ForeColor     = Color.FromArgb(200, 210, 230);
        divTop.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        divTop.SizeF         = new System.Drawing.SizeF(W, 3F);
        y += 14F;

        // ── Subject line ─────────────────────────────────────────────────

        this.lblSubject.Dpi           = 254F;
        this.lblSubject.Font          = new Font("Times New Roman", 11F, FontStyle.Bold);
        this.lblSubject.ForeColor     = navy;
        this.lblSubject.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblSubject.SizeF         = new System.Drawing.SizeF(W, 62F);
        this.lblSubject.StylePriority.UseFont          = false;
        this.lblSubject.StylePriority.UseForeColor     = false;
        this.lblSubject.StylePriority.UseTextAlignment = false;
        this.lblSubject.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
        this.lblSubject.WordWrap      = true;
        this.lblSubject.Name          = "lblSubject";
        this.lblSubject.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblSubject_BeforePrint);
        y += 68F;

        // Underline below subject
        XRLine divSubject = new XRLine();
        divSubject.Dpi           = 254F;
        divSubject.LineWidth     = 2;
        divSubject.ForeColor     = navy;
        divSubject.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        divSubject.SizeF         = new System.Drawing.SizeF(W, 3F);
        y += 18F;

        // ── Greeting ─────────────────────────────────────────────────────

        XRLabel lblGreeting = new XRLabel();
        lblGreeting.Dpi           = 254F;
        lblGreeting.Font          = new Font("Georgia", 11F, FontStyle.Italic);
        lblGreeting.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        lblGreeting.SizeF         = new System.Drawing.SizeF(W, 30F);
        lblGreeting.StylePriority.UseFont = false;
        lblGreeting.Text          = "This is to certify that";
        y += 36F;

        // ── Student name — bold, navy, prominent (Times New Roman 16pt) ──

        this.lblName.Dpi           = 254F;
        this.lblName.Font          = new Font("Times New Roman", 16F, FontStyle.Bold);
        this.lblName.ForeColor     = navy;
        this.lblName.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblName.SizeF         = new System.Drawing.SizeF(W, 62F);
        this.lblName.StylePriority.UseFont          = false;
        this.lblName.StylePriority.UseForeColor     = false;
        this.lblName.StylePriority.UseTextAlignment = false;
        this.lblName.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
        this.lblName.WordWrap      = true;
        this.lblName.Name          = "lblName";
        this.lblName.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblName_BeforePrint);
        y += 68F;

        // ── Registration + completion statement — Georgia body ─────────────

        this.lblRegComp.Dpi           = 254F;
        this.lblRegComp.Font          = new Font("Georgia", 10.5F);
        this.lblRegComp.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblRegComp.SizeF         = new System.Drawing.SizeF(W, 78F);
        this.lblRegComp.StylePriority.UseFont = false;
        this.lblRegComp.WordWrap      = true;
        this.lblRegComp.Name          = "lblRegComp";
        this.lblRegComp.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblRegComp_BeforePrint);
        y += 84F;

        // ── Degree name — bold, navy, centred (Times New Roman 14pt) ─────

        this.lblDegree.Dpi           = 254F;
        this.lblDegree.Font          = new Font("Times New Roman", 14F, FontStyle.Bold);
        this.lblDegree.ForeColor     = navy;
        this.lblDegree.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblDegree.SizeF         = new System.Drawing.SizeF(W, 88F);
        this.lblDegree.StylePriority.UseFont          = false;
        this.lblDegree.StylePriority.UseForeColor     = false;
        this.lblDegree.StylePriority.UseTextAlignment = false;
        this.lblDegree.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
        this.lblDegree.WordWrap      = true;
        this.lblDegree.Name          = "lblDegree";
        this.lblDegree.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblDegree_BeforePrint);
        y += 94F;

        // ── "of MUTESA I ROYAL UNIVERSITY." ──────────────────────────────

        XRLabel lblUniversity = new XRLabel();
        lblUniversity.Dpi           = 254F;
        lblUniversity.Font          = new Font("Georgia", 10.5F);
        lblUniversity.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        lblUniversity.SizeF         = new System.Drawing.SizeF(W, 30F);
        lblUniversity.StylePriority.UseFont          = false;
        lblUniversity.StylePriority.UseTextAlignment = false;
        lblUniversity.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
        lblUniversity.Text          = "of  MUTESA I ROYAL UNIVERSITY.";
        y += 38F;

        // ── Thesis / Dissertation Title (Masters-specific) ───────────────

        this.lblThesisHeader.Dpi           = 254F;
        this.lblThesisHeader.Font          = new Font("Georgia", 10F, FontStyle.Italic);
        this.lblThesisHeader.ForeColor     = muted;
        this.lblThesisHeader.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblThesisHeader.SizeF         = new System.Drawing.SizeF(W, 26F);
        this.lblThesisHeader.StylePriority.UseFont      = false;
        this.lblThesisHeader.StylePriority.UseForeColor = false;
        this.lblThesisHeader.Text          = "Thesis / Dissertation Title:";
        this.lblThesisHeader.Name          = "lblThesisHeader";
        this.lblThesisHeader.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblThesisHeader_BeforePrint);
        y += 28F;

        this.lblThesisTitle.Dpi           = 254F;
        this.lblThesisTitle.Font          = new Font("Times New Roman", 11F, FontStyle.Bold | FontStyle.Italic);
        this.lblThesisTitle.ForeColor     = navy;
        this.lblThesisTitle.LocationFloat = new DevExpress.Utils.PointFloat(L + 20F, y);
        this.lblThesisTitle.SizeF         = new System.Drawing.SizeF(W - 40F, 68F);
        this.lblThesisTitle.StylePriority.UseFont          = false;
        this.lblThesisTitle.StylePriority.UseForeColor     = false;
        this.lblThesisTitle.StylePriority.UseTextAlignment = false;
        this.lblThesisTitle.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
        this.lblThesisTitle.WordWrap      = true;
        this.lblThesisTitle.Name          = "lblThesisTitle";
        this.lblThesisTitle.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblThesisTitle_BeforePrint);
        y += 72F;

        // ── Supervisor ───────────────────────────────────────────────────

        this.lblSupervisorHeader.Dpi           = 254F;
        this.lblSupervisorHeader.Font          = new Font("Georgia", 10F, FontStyle.Italic);
        this.lblSupervisorHeader.ForeColor     = muted;
        this.lblSupervisorHeader.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblSupervisorHeader.SizeF         = new System.Drawing.SizeF(350F, 26F);
        this.lblSupervisorHeader.StylePriority.UseFont      = false;
        this.lblSupervisorHeader.StylePriority.UseForeColor = false;
        this.lblSupervisorHeader.Text          = "Supervisor:";
        this.lblSupervisorHeader.Name          = "lblSupervisorHeader";
        this.lblSupervisorHeader.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblSupervisorHeader_BeforePrint);

        this.lblSupervisorName.Dpi           = 254F;
        this.lblSupervisorName.Font          = new Font("Times New Roman", 11F, FontStyle.Bold);
        this.lblSupervisorName.ForeColor     = navy;
        this.lblSupervisorName.LocationFloat = new DevExpress.Utils.PointFloat(L + 360F, y);
        this.lblSupervisorName.SizeF         = new System.Drawing.SizeF(W - 360F, 26F);
        this.lblSupervisorName.StylePriority.UseFont          = false;
        this.lblSupervisorName.StylePriority.UseForeColor     = false;
        this.lblSupervisorName.StylePriority.UseTextAlignment = false;
        this.lblSupervisorName.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;
        this.lblSupervisorName.Name          = "lblSupervisorName";
        this.lblSupervisorName.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblSupervisorName_BeforePrint);
        y += 32F;

        // Thin section divider
        XRLine divSections = new XRLine();
        divSections.Dpi           = 254F;
        divSections.LineWidth     = 1;
        divSections.ForeColor     = Color.FromArgb(200, 210, 230);
        divSections.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        divSections.SizeF         = new System.Drawing.SizeF(W, 3F);
        y += 13F;

        // ── Senate approval ───────────────────────────────────────────────

        this.lblSenate.Dpi           = 254F;
        this.lblSenate.Font          = new Font("Georgia", 10.5F);
        this.lblSenate.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblSenate.SizeF         = new System.Drawing.SizeF(W, 52F);
        this.lblSenate.StylePriority.UseFont = false;
        this.lblSenate.WordWrap      = true;
        this.lblSenate.Name          = "lblSenate";
        this.lblSenate.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblSenate_BeforePrint);
        y += 58F;

        // ── Graduation ceremony ───────────────────────────────────────────

        this.lblGraduation.Dpi           = 254F;
        this.lblGraduation.Font          = new Font("Georgia", 10.5F);
        this.lblGraduation.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        this.lblGraduation.SizeF         = new System.Drawing.SizeF(W, 60F);
        this.lblGraduation.StylePriority.UseFont = false;
        this.lblGraduation.WordWrap      = true;
        this.lblGraduation.Name          = "lblGraduation";
        this.lblGraduation.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.lblGraduation_BeforePrint);
        y += 66F;

        // ── Closing statement ─────────────────────────────────────────────

        XRLabel lblClosing = new XRLabel();
        lblClosing.Dpi           = 254F;
        lblClosing.Font          = new Font("Georgia", 10.5F);
        lblClosing.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        lblClosing.SizeF         = new System.Drawing.SizeF(W, 50F);
        lblClosing.StylePriority.UseFont = false;
        lblClosing.WordWrap = true;
        lblClosing.Text = "This letter is issued upon request and serves as official confirmation that the above named "
            + "candidate has qualified for the award of the stated degree.";
        y += 56F;

        // ── Signature section ─────────────────────────────────────────────

        y += 22F;

        XRLabel lblSigHeader = new XRLabel();
        lblSigHeader.Dpi           = 254F;
        lblSigHeader.Font          = new Font("Times New Roman", 10.5F, FontStyle.Bold);
        lblSigHeader.ForeColor     = navy;
        lblSigHeader.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        lblSigHeader.SizeF         = new System.Drawing.SizeF(W, 28F);
        lblSigHeader.StylePriority.UseFont      = false;
        lblSigHeader.StylePriority.UseForeColor = false;
        lblSigHeader.Text = "FOR MUTESA I ROYAL UNIVERSITY:";
        y += 34F;

        XRLabel lblSigArea = new XRLabel();
        lblSigArea.Dpi           = 254F;
        lblSigArea.Font          = new Font("Times New Roman", 10F);
        lblSigArea.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        lblSigArea.SizeF         = new System.Drawing.SizeF(720F, 150F);
        lblSigArea.StylePriority.UseFont = false;
        lblSigArea.Multiline     = true;
        lblSigArea.Text = "\n\n_________________________________\n\nACADEMIC REGISTRAR\nMutesa I Royal University";

        XRLabel lblSeal = new XRLabel();
        lblSeal.Dpi              = 254F;
        lblSeal.Font             = new Font("Calibri", 9F, FontStyle.Italic);
        lblSeal.ForeColor        = muted;
        lblSeal.LocationFloat    = new DevExpress.Utils.PointFloat(L + 1080F, y);
        lblSeal.SizeF            = new System.Drawing.SizeF(800F, 150F);
        lblSeal.StylePriority.UseFont          = false;
        lblSeal.StylePriority.UseForeColor     = false;
        lblSeal.StylePriority.UseTextAlignment = false;
        lblSeal.StylePriority.UseBorderColor   = false;
        lblSeal.TextAlignment    = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
        lblSeal.BorderColor      = Color.FromArgb(0, 35, 101);
        lblSeal.Borders          = DevExpress.XtraPrinting.BorderSide.All;
        lblSeal.BorderWidth      = 1;
        lblSeal.BorderDashStyle  = DevExpress.XtraPrinting.BorderDashStyle.Dash;
        lblSeal.Padding          = new DevExpress.XtraPrinting.PaddingInfo(8, 8, 8, 8, 254F);
        lblSeal.Text             = "OFFICIAL SEAL\n& STAMP";
        y += 158F;

        // ── Section divider before QR ─────────────────────────────────────

        y += 12F;
        XRLine divQr = new XRLine();
        divQr.Dpi           = 254F;
        divQr.LineWidth     = 1;
        divQr.ForeColor     = Color.FromArgb(200, 210, 230);
        divQr.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        divQr.SizeF         = new System.Drawing.SizeF(W, 3F);
        y += 10F;

        // ── QR code — centred, 280×280 (28mm) — NO barcode ──────────────
        // URL: https://eadmin.mru.ac.ug/Verify.aspx?reg_no={regno}
        // At 280 units (28mm) with Version8/M (49×49 modules + 8-unit quiet zone = 57 total):
        //   module size = 280/57 ≈ 4.9 units = 0.49mm — comfortably scanneable.
        // AutoModule = true lets DX calculate the exact module size to fill the control.

        this.qrcode.Dpi           = 254F;
        this.qrcode.LocationFloat = new DevExpress.Utils.PointFloat(L + (W - 280F) / 2, y);
        this.qrcode.SizeF         = new System.Drawing.SizeF(280F, 280F);
        this.qrcode.Symbology     = qrGen;
        this.qrcode.AutoModule    = true;
        this.qrcode.ShowText      = false;
        this.qrcode.Name          = "qrcode";
        this.qrcode.BeforePrint  += new System.Drawing.Printing.PrintEventHandler(this.qrcode_BeforePrint);
        y += 288F;

        // Verification instruction
        XRLabel lblVerify = new XRLabel();
        lblVerify.Dpi           = 254F;
        lblVerify.Font          = new Font("Calibri", 8F);
        lblVerify.ForeColor     = muted;
        lblVerify.LocationFloat = new DevExpress.Utils.PointFloat(L, y);
        lblVerify.SizeF         = new System.Drawing.SizeF(W, 38F);
        lblVerify.StylePriority.UseFont          = false;
        lblVerify.StylePriority.UseForeColor     = false;
        lblVerify.StylePriority.UseTextAlignment = false;
        lblVerify.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
        lblVerify.WordWrap      = true;
        lblVerify.Text = "Scan the QR code or visit  https://eadmin.mru.ac.ug/Verify.aspx  "
            + "to verify the authenticity of this letter.";
        y += 44F;

        this.Detail.HeightF = y + 18F;

        this.Detail.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            this.lblRef, this.lblDate, divTop,
            this.lblSubject, divSubject, lblGreeting,
            this.lblName, this.lblRegComp,
            this.lblDegree, lblUniversity,
            this.lblThesisHeader, this.lblThesisTitle,
            this.lblSupervisorHeader, this.lblSupervisorName,
            divSections, this.lblSenate, this.lblGraduation, lblClosing,
            lblSigHeader, lblSigArea, lblSeal,
            divQr, this.qrcode, lblVerify
        });

        // ── Bands ─────────────────────────────────────────────────────────

        this.TopMargin.Dpi     = 254F;
        this.TopMargin.HeightF = 0F;
        this.TopMargin.Name    = "TopMargin";
        this.TopMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 254F);

        this.BottomMargin.Dpi     = 254F;
        this.BottomMargin.HeightF = 29F;
        this.BottomMargin.Name    = "BottomMargin";
        this.BottomMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 254F);

        this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.PageHeader,
            this.TopMargin,
            this.Detail,
            this.BottomMargin
        });

        // ── Report settings — identical to Certificate.cs ─────────────────

        this.resultsData1.DataSetName             = "ResultsData";
        this.resultsData1.SchemaSerializationMode = System.Data.SchemaSerializationMode.IncludeSchema;

        this.DataMember = "acad_GetBatchStudentTranscriptData";
        this.DataSource = this.resultsData1;
        this.Dpi        = 254F;
        this.Font       = new Font("Georgia", 11F);
        this.Margins    = new System.Drawing.Printing.Margins(76, 76, 0, 29);
        this.PageHeight = 2970;
        this.PageWidth  = 2100;
        this.PaperKind  = System.Drawing.Printing.PaperKind.A4;
        this.ReportUnit = DevExpress.XtraReports.UI.ReportUnit.TenthsOfAMillimeter;
        this.Version    = "16.1";

        ((System.ComponentModel.ISupportInitialize)(this.resultsData1)).EndInit();
        ((System.ComponentModel.ISupportInitialize)(this)).EndInit();
    }

    // ════════════════════════════════════════════════════════════════════════
    // Named BeforePrint handlers — no lambdas, no captured closure variables.
    // All text is set via (sender as XRLabel) — serialisation-safe for DX v16.1.
    // ════════════════════════════════════════════════════════════════════════

    /// <summary>Ref: MLA/{REGNO}/{YEAR} — auto-built from regno column, no popup input required.</summary>
    private void lblRef_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        object val = null;
        try { val = GetCurrentColumnValue("regno"); } catch { }
        string reg = (val != null && val != DBNull.Value) ? val.ToString().Trim() : "";
        string refNo = string.IsNullOrEmpty(reg)
            ? "MLA/" + DateTime.Now.Year
            : "MLA/" + reg + "/" + DateTime.Now.Year;
        (sender as XRLabel).Text = "Ref: " + refNo;
    }

    /// <summary>Date: auto-generated from DateTime.Now — no popup input required.</summary>
    private void lblDate_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        (sender as XRLabel).Text = "Date: " + DateTime.Now.ToString("dd MMMM, yyyy",
            CultureInfo.CreateSpecificCulture("en-US"));
    }

    /// <summary>Subject uses the degree name from the dataset (deg column).</summary>
    private void lblSubject_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        object val = null;
        try { val = GetCurrentColumnValue("deg"); } catch { }
        string deg = (val != null && val != DBNull.Value && !string.IsNullOrEmpty(val.ToString().Trim()))
            ? val.ToString().Trim() : "MASTER'S DEGREE";
        (sender as XRLabel).Text = "RE:  LETTER OF AWARD FOR THE DEGREE OF  " + deg.ToUpper();
    }

    /// <summary>Student name: TitleCase, bold, navy — from studnm column.</summary>
    private void lblName_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        object val = null;
        try { val = GetCurrentColumnValue("studnm"); } catch { }
        string name = (val != null && val != DBNull.Value) ? val.ToString().Trim() : "";
        if (!string.IsNullOrEmpty(name))
            name = new CultureInfo("en").TextInfo.ToTitleCase(name.ToLower());
        (sender as XRLabel).Text = name;
    }

    /// <summary>Registration number from regno column.</summary>
    private void lblRegComp_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        object val = null;
        try { val = GetCurrentColumnValue("regno"); } catch { }
        string reg = (val != null && val != DBNull.Value) ? val.ToString().Trim() : "";
        (sender as XRLabel).Text =
            "Registration Number  " + reg + ",  has successfully completed the approved programme "
            + "of study and fulfilled all the requirements for the award of the Degree of:";
    }

    /// <summary>Degree name: from deg column — same source as subject line.</summary>
    private void lblDegree_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        object val = null;
        try { val = GetCurrentColumnValue("deg"); } catch { }
        (sender as XRLabel).Text =
            (val != null && val != DBNull.Value && !string.IsNullOrEmpty(val.ToString().Trim()))
            ? val.ToString().Trim() : "";
    }

    /// <summary>Senate date: from SenateApprovalDate parameter (set from popup input).</summary>
    private void lblSenate_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        string sd = Parameters["SenateApprovalDate"].Value != null
            ? Parameters["SenateApprovalDate"].Value.ToString().Trim() : "";
        (sender as XRLabel).Text =
            "The Senate of Mutesa I Royal University, at its meeting held on  " + sd
            + ",  approved the award of the above degree.";
    }

    /// <summary>Graduation date: from formated_grad_date column in dataset.</summary>
    private void lblGraduation_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        object val = null;
        try { val = GetCurrentColumnValue("formated_grad_date"); } catch { }
        string gd = (val != null && val != DBNull.Value && !string.IsNullOrEmpty(val.ToString().Trim()))
            ? val.ToString().Trim() : "the forthcoming ceremony";
        (sender as XRLabel).Text =
            "The graduate will be presented for the conferment of this award at the Graduation "
            + "Ceremony scheduled for  " + gd + ".";
    }

    /// <summary>QR code: URL https://eadmin.mru.ac.ug/Verify.aspx?reg_no={regno}</summary>
    private void qrcode_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        object val = null;
        try { val = GetCurrentColumnValue("regno"); } catch { }
        string reg = (val != null && val != DBNull.Value) ? val.ToString().Trim() : "";
        (sender as XRBarCode).Text = "https://eadmin.mru.ac.ug/Verify.aspx?reg_no=" + reg;
    }

    // ════════════════════════════════════════════════════════════════════════
    // Thesis / Supervisor BeforePrint handlers
    // ════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Ensures thesis/supervisor data is available in the dataset.
    /// Called once to enrich the data before thesis-specific labels render.
    /// </summary>
    private bool _thesisDataEnriched = false;
    private void EnsureThesisData()
    {
        if (_thesisDataEnriched) return;
        _thesisDataEnriched = true;
        try
        {
            GraduateHelper.EnrichTranscriptDataBatch(this.resultsData1);
        }
        catch { }
    }

    /// <summary>Thesis header label — hidden when no thesis title exists.</summary>
    private void lblThesisHeader_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        EnsureThesisData();
        string title = GetThesisColumnSafe("thesis_title");
        if (string.IsNullOrEmpty(title))
            e.Cancel = true; // Hide the header if no thesis
    }

    /// <summary>Thesis title: from thesis_title column in dataset.</summary>
    private void lblThesisTitle_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        string title = GetThesisColumnSafe("thesis_title");
        if (string.IsNullOrEmpty(title))
        {
            e.Cancel = true; // Hide if no thesis title
        }
        else
        {
            (sender as XRLabel).Text = "\"" + title + "\"";
        }
    }

    /// <summary>Supervisor header — hidden when no supervisor is assigned.</summary>
    private void lblSupervisorHeader_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        string supervisor = GetThesisColumnSafe("supervisor_name");
        if (string.IsNullOrEmpty(supervisor))
            e.Cancel = true;
    }

    /// <summary>Supervisor name: from supervisor_name column in dataset.</summary>
    private void lblSupervisorName_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        string supervisor = GetThesisColumnSafe("supervisor_name");
        if (string.IsNullOrEmpty(supervisor))
        {
            e.Cancel = true;
        }
        else
        {
            (sender as XRLabel).Text = supervisor;
        }
    }

    /// <summary>Safely reads a thesis/supervisor column — returns "" if column does not exist.</summary>
    private string GetThesisColumnSafe(string columnName)
    {
        try
        {
            object val = GetCurrentColumnValue(columnName);
            return (val != null && val != DBNull.Value) ? val.ToString().Trim() : "";
        }
        catch
        {
            return "";
        }
    }
}
