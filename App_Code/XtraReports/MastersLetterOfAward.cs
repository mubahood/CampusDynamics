using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

/// <summary>
/// Masters Letter of Award - Custom report for Master's degree recipients
/// </summary>
public class MastersLetterOfAward : DevExpress.XtraReports.UI.XtraReport
{
    private DevExpress.XtraReports.UI.DetailBand Detail;
    private DevExpress.XtraReports.UI.TopMarginBand TopMargin;
    private DevExpress.XtraReports.UI.BottomMarginBand BottomMargin;
    private ResultsData resultsData1;
    
    private XRLabel letterDateLabel;
    private XRLabel refNumberLabel;
    private XRLabel subjectLineLabel;
    private XRLabel studentNameLabel;
    private XRLabel registrationLabel;
    private XRLabel degreeNameLabel;
    private XRLabel universityNameLabel;
    private XRLabel senateApprovalLabel;
    private XRLabel graduationDateLabel;
    private XRLabel closingLabel;
    private XRLabel universityHeadingLabel;
    private XRLabel certNumberLabel;
    private XRBarCode barCode;
    private XRBarCode qrCode;
    private XRPictureBox universityLogo;

    private System.ComponentModel.IContainer components = null;

    public MastersLetterOfAward()
    {
        InitializeComponent();
        this.BeforePrint += new System.Drawing.Printing.PrintEventHandler(MastersLetterOfAward_BeforePrint);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    #region Designer generated code

    private void InitializeComponent()
    {
        this.Detail = new DevExpress.XtraReports.UI.DetailBand();
        this.TopMargin = new DevExpress.XtraReports.UI.TopMarginBand();
        this.BottomMargin = new DevExpress.XtraReports.UI.BottomMarginBand();
        this.resultsData1 = new ResultsData();
        ((System.ComponentModel.ISupportInitialize)(this.resultsData1)).BeginInit();
        ((System.ComponentModel.ISupportInitialize)(this)).BeginInit();

        // Parameters
        DevExpress.XtraReports.Parameters.Parameter paramLetterDate = new DevExpress.XtraReports.Parameters.Parameter();
        paramLetterDate.Name = "LetterDate";
        paramLetterDate.Type = typeof(string);
        paramLetterDate.Value = "";

        DevExpress.XtraReports.Parameters.Parameter paramRefNumber = new DevExpress.XtraReports.Parameters.Parameter();
        paramRefNumber.Name = "RefNumber";
        paramRefNumber.Type = typeof(string);
        paramRefNumber.Value = "";

        // degree name will be taken from dataset (acad_GetBatchStudentTranscriptData.deg)

        DevExpress.XtraReports.Parameters.Parameter paramSenateApprovalDate = new DevExpress.XtraReports.Parameters.Parameter();
        paramSenateApprovalDate.Name = "SenateApprovalDate";
        paramSenateApprovalDate.Type = typeof(string);
        paramSenateApprovalDate.Value = "";

        DevExpress.XtraReports.Parameters.Parameter paramGraduationDate = new DevExpress.XtraReports.Parameters.Parameter();
        paramGraduationDate.Name = "GraduationDate";
        paramGraduationDate.Type = typeof(string);
        paramGraduationDate.Value = "";
        
        DevExpress.XtraReports.Parameters.Parameter paramHonours = new DevExpress.XtraReports.Parameters.Parameter();
        paramHonours.Name = "Honours";
        paramHonours.Type = typeof(string);
        paramHonours.Value = "";

        this.Parameters.AddRange(new DevExpress.XtraReports.Parameters.Parameter[] {
            paramLetterDate,
            paramRefNumber,
            paramSenateApprovalDate,
            paramGraduationDate,
            paramHonours
        });

        // Detail Band
        this.Detail.HeightF = 950F;
        this.Detail.Name = "Detail";
        this.Detail.Padding = new DevExpress.XtraPrinting.PaddingInfo(30, 30, 30, 30, 100F);
        this.Detail.PageBreak = DevExpress.XtraReports.UI.PageBreak.BeforeBand;
        this.Detail.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;

        // resource manager (reuse certificate resources for branding images)
        string resourceFileName = "Certificate.resx";
        System.Resources.ResourceManager resources = global::Resources.Certificate.ResourceManager;

        // University Heading
        this.universityHeadingLabel = new XRLabel();
        this.universityHeadingLabel.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_university.name")});
        this.universityHeadingLabel.Font = new System.Drawing.Font("Calibri", 14F, System.Drawing.FontStyle.Bold);
        this.universityHeadingLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 30F);
        this.universityHeadingLabel.Name = "universityHeadingLabel";
        this.universityHeadingLabel.SizeF = new System.Drawing.SizeF(540F, 25F);
        this.universityHeadingLabel.StylePriority.UseFont = false;
        this.universityHeadingLabel.StylePriority.UseTextAlignment = false;
        this.universityHeadingLabel.Text = "Mutesa I Royal University";
        this.universityHeadingLabel.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;

        // branding logos (left and right)
        XRPictureBox logoLeft = new XRPictureBox();
        logoLeft.Image = ((System.Drawing.Image)(resources.GetObject("xrPictureBox3.Image")));
        logoLeft.LocationFloat = new DevExpress.Utils.PointFloat(30F, 20F);
        logoLeft.SizeF = new System.Drawing.SizeF(120F, 60F);
        logoLeft.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;

        XRPictureBox logoRight = new XRPictureBox();
        logoRight.Image = ((System.Drawing.Image)(resources.GetObject("xrPictureBox2.Image")));
        logoRight.LocationFloat = new DevExpress.Utils.PointFloat(450F, 20F);
        logoRight.SizeF = new System.Drawing.SizeF(120F, 60F);
        logoRight.Sizing = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;

        // Letter Date
        this.letterDateLabel = new XRLabel();
        this.letterDateLabel.Font = new System.Drawing.Font("Calibri", 11F);
        this.letterDateLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 70F);
        this.letterDateLabel.Name = "letterDateLabel";
        this.letterDateLabel.SizeF = new System.Drawing.SizeF(540F, 20F);
        this.letterDateLabel.StylePriority.UseFont = false;
        this.letterDateLabel.Text = "Date:";

        // Reference Number
        this.refNumberLabel = new XRLabel();
        this.refNumberLabel.Font = new System.Drawing.Font("Calibri", 11F);
        this.refNumberLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 92F);
        this.refNumberLabel.Name = "refNumberLabel";
        this.refNumberLabel.SizeF = new System.Drawing.SizeF(540F, 20F);
        this.refNumberLabel.StylePriority.UseFont = false;
        this.refNumberLabel.Text = "Ref:";

        // Subject Line
        this.subjectLineLabel = new XRLabel();
        this.subjectLineLabel.Font = new System.Drawing.Font("Calibri", 11F, System.Drawing.FontStyle.Bold);
        this.subjectLineLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 125F);
        this.subjectLineLabel.Name = "subjectLineLabel";
        this.subjectLineLabel.SizeF = new System.Drawing.SizeF(540F, 40F);
        this.subjectLineLabel.StylePriority.UseFont = false;
        this.subjectLineLabel.Text = "RE: LETTER OF AWARD FOR THE DEGREE OF";
        this.subjectLineLabel.WordWrap = true;

        // Greeting
        XRLabel greetingLabel = new XRLabel();
        greetingLabel.Font = new System.Drawing.Font("Calibri", 11F);
        greetingLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 170F);
        greetingLabel.Name = "greetingLabel";
        greetingLabel.SizeF = new System.Drawing.SizeF(540F, 20F);
        greetingLabel.StylePriority.UseFont = false;
        greetingLabel.Text = "This is to certify that";

        // Student Name
        this.studentNameLabel = new XRLabel();
        this.studentNameLabel.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.name")});
        this.studentNameLabel.Font = new System.Drawing.Font("Calibri", 11F, System.Drawing.FontStyle.Bold);
        this.studentNameLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 190F);
        this.studentNameLabel.Name = "studentNameLabel";
        this.studentNameLabel.SizeF = new System.Drawing.SizeF(540F, 20F);
        this.studentNameLabel.StylePriority.UseFont = false;
        this.studentNameLabel.Text = "[Student Name]";

        // Registration Number Line
        this.registrationLabel = new XRLabel();
        this.registrationLabel.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.regno")});
        this.registrationLabel.Font = new System.Drawing.Font("Calibri", 11F);
        this.registrationLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 210F);
        this.registrationLabel.Name = "registrationLabel";
        this.registrationLabel.SizeF = new System.Drawing.SizeF(540F, 40F);
        this.registrationLabel.StylePriority.UseFont = false;
        this.registrationLabel.Text = "Registration Number [REG NO.], has successfully completed the approved programme of study and fulfilled all requirements for the award of the degree of:";
        this.registrationLabel.WordWrap = true;

        // Degree Name II
        this.degreeNameLabel = new XRLabel();
        this.degreeNameLabel.Font = new System.Drawing.Font("Calibri", 12F, System.Drawing.FontStyle.Bold);
        this.degreeNameLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 260F);
        this.degreeNameLabel.Name = "degreeNameLabel";
        this.degreeNameLabel.SizeF = new System.Drawing.SizeF(540F, 35F);
        this.degreeNameLabel.StylePriority.UseFont = false;
        this.degreeNameLabel.StylePriority.UseTextAlignment = false;
        this.degreeNameLabel.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
        this.degreeNameLabel.WordWrap = true;
        this.degreeNameLabel.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.deg")});

        // Honours / Distinction (optional)
        XRLabel honoursLabel = new XRLabel();
        honoursLabel.Font = new System.Drawing.Font("Calibri", 11F, System.Drawing.FontStyle.Italic);
        honoursLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 300F);
        honoursLabel.Name = "honoursLabel";
        honoursLabel.SizeF = new System.Drawing.SizeF(540F, 20F);
        honoursLabel.StylePriority.UseFont = false;
        honoursLabel.StylePriority.UseTextAlignment = false;
        honoursLabel.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
        honoursLabel.BeforePrint += new System.Drawing.Printing.PrintEventHandler((s, e) => {
            string h = this.Parameters["Honours"].Value != null ? this.Parameters["Honours"].Value.ToString() : "";
            honoursLabel.Text = string.IsNullOrEmpty(h) ? "" : h;
        });

        // University Name
        this.universityNameLabel = new XRLabel();
        this.universityNameLabel.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_university.name")});
        this.universityNameLabel.Font = new System.Drawing.Font("Calibri", 11F, System.Drawing.FontStyle.Bold);
        this.universityNameLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 300F);
        this.universityNameLabel.Name = "universityNameLabel";
        this.universityNameLabel.SizeF = new System.Drawing.SizeF(540F, 20F);
        this.universityNameLabel.StylePriority.UseFont = false;
        this.universityNameLabel.StylePriority.UseTextAlignment = false;
        this.universityNameLabel.Text = "of [UNIVERSITY NAME].";
        this.universityNameLabel.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;

        // Senate Approval (bound to session parameter if present, otherwise dataset comp_date)
        this.senateApprovalLabel = new XRLabel();
        this.senateApprovalLabel.Font = new System.Drawing.Font("Calibri", 11F);
        this.senateApprovalLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 330F);
        this.senateApprovalLabel.Name = "senateApprovalLabel";
        this.senateApprovalLabel.SizeF = new System.Drawing.SizeF(540F, 40F);
        this.senateApprovalLabel.StylePriority.UseFont = false;
        this.senateApprovalLabel.WordWrap = true;
        this.senateApprovalLabel.BeforePrint += new System.Drawing.Printing.PrintEventHandler((s, e) => {
            string val = this.Parameters["SenateApprovalDate"].Value != null ? this.Parameters["SenateApprovalDate"].Value.ToString() : "";
            if (!string.IsNullOrEmpty(val))
                this.senateApprovalLabel.Text = "The Senate at its meeting held on " + val + " approved the award of the above degree.";
            else
                this.senateApprovalLabel.Text = "";
        });

        // Graduation Date (bound to parameter or dataset)
        this.graduationDateLabel = new XRLabel();
        this.graduationDateLabel.Font = new System.Drawing.Font("Calibri", 11F);
        this.graduationDateLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 375F);
        this.graduationDateLabel.Name = "graduationDateLabel";
        this.graduationDateLabel.SizeF = new System.Drawing.SizeF(540F, 40F);
        this.graduationDateLabel.StylePriority.UseFont = false;
        this.graduationDateLabel.WordWrap = true;
        this.graduationDateLabel.BeforePrint += new System.Drawing.Printing.PrintEventHandler((s, e) => {
            string val = this.Parameters["GraduationDate"].Value != null ? this.Parameters["GraduationDate"].Value.ToString() : "";
            if (!string.IsNullOrEmpty(val))
                this.graduationDateLabel.Text = "The graduate will be presented for the conferment of this award at the forthcoming Graduation Ceremony scheduled for " + val + ".";
            else
                this.graduationDateLabel.Text = "";
        });

        // Closing Text
        this.closingLabel = new XRLabel();
        this.closingLabel.Font = new System.Drawing.Font("Calibri", 11F);
        this.closingLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 420F);
        this.closingLabel.Name = "closingLabel";
        this.closingLabel.SizeF = new System.Drawing.SizeF(540F, 50F);
        this.closingLabel.StylePriority.UseFont = false;
        this.closingLabel.Text = "This letter is issued upon request and serves as official confirmation that the candidate has qualified for the award of the stated degree.";
        this.closingLabel.WordWrap = true;

        // Signature Area
        XRLabel signatureAreaLabel = new XRLabel();
        signatureAreaLabel.Font = new System.Drawing.Font("Calibri", 11F);
        signatureAreaLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 480F);
        signatureAreaLabel.Name = "signatureAreaLabel";
        signatureAreaLabel.SizeF = new System.Drawing.SizeF(540F, 100F);
        signatureAreaLabel.StylePriority.UseFont = false;
        signatureAreaLabel.Text = "\n\n\n_______________________________\nAuthorised Officer\nMutesa I Royal University";
        signatureAreaLabel.WordWrap = true;

        // Security/Seal Area Label
        XRLabel sealAreaLabel = new XRLabel();
        sealAreaLabel.Font = new System.Drawing.Font("Calibri", 9F, System.Drawing.FontStyle.Italic);
        sealAreaLabel.LocationFloat = new DevExpress.Utils.PointFloat(420F, 480F);
        sealAreaLabel.Name = "sealAreaLabel";
        sealAreaLabel.SizeF = new System.Drawing.SizeF(150F, 100F);
        sealAreaLabel.StylePriority.UseFont = false;
        sealAreaLabel.StylePriority.UseTextAlignment = false;
        sealAreaLabel.Text = "[Official Seal\n& Embossed\nStamp Here]";
        sealAreaLabel.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopCenter;
        sealAreaLabel.BorderColor = System.Drawing.Color.LightGray;
        sealAreaLabel.Borders = DevExpress.XtraPrinting.BorderSide.All;

        // Barcode
        this.certNumberLabel = new XRLabel();
        this.certNumberLabel.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.doc_no")});
        this.certNumberLabel.Font = new System.Drawing.Font("Courier New", 8F);
        this.certNumberLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 590F);
        this.certNumberLabel.Name = "certNumberLabel";
        this.certNumberLabel.SizeF = new System.Drawing.SizeF(200F, 15F);
        this.certNumberLabel.StylePriority.UseFont = false;
        this.certNumberLabel.Text = "Doc Serial: [Cert No]";

        // Verification Code Label
        XRLabel verificationLabel = new XRLabel();
        verificationLabel.Font = new System.Drawing.Font("Courier New", 8F);
        verificationLabel.LocationFloat = new DevExpress.Utils.PointFloat(30F, 610F);
        verificationLabel.Name = "verificationLabel";
        verificationLabel.SizeF = new System.Drawing.SizeF(540F, 15F);
        verificationLabel.StylePriority.UseFont = false;
        verificationLabel.Text = "Verify this document at: https://verify.mru.ac.ug/masters?serial=[Serial]";
        verificationLabel.WordWrap = true;

        DevExpress.XtraPrinting.BarCode.Code128Generator code128Generator1 = new DevExpress.XtraPrinting.BarCode.Code128Generator();
        this.barCode = new DevExpress.XtraReports.UI.XRBarCode();
        this.barCode.DataBindings.AddRange(new DevExpress.XtraReports.UI.XRBinding[] {
            new DevExpress.XtraReports.UI.XRBinding("Text", null, "acad_GetBatchStudentTranscriptData.doc_no")});
        this.barCode.LocationFloat = new DevExpress.Utils.PointFloat(30F, 630F);
        this.barCode.Name = "barCode";
        this.barCode.SizeF = new System.Drawing.SizeF(300F, 50F);
        this.barCode.Symbology = code128Generator1;
        this.barCode.AutoModule = true;

        // QR Code (verification link)
        DevExpress.XtraPrinting.BarCode.QRCodeGenerator qrCodeGenerator1 = new DevExpress.XtraPrinting.BarCode.QRCodeGenerator();
        this.qrCode = new DevExpress.XtraReports.UI.XRBarCode();
        this.qrCode.LocationFloat = new DevExpress.Utils.PointFloat(350F, 630F);
        this.qrCode.Name = "qrCode";
        this.qrCode.SizeF = new System.Drawing.SizeF(100F, 100F);
        this.qrCode.Symbology = qrCodeGenerator1;
        this.qrCode.AutoModule = true;

        // Add controls to Detail
        this.Detail.Controls.AddRange(new DevExpress.XtraReports.UI.XRControl[] {
            logoLeft,
            logoRight,
            this.universityHeadingLabel,
            this.letterDateLabel,
            this.refNumberLabel,
            this.subjectLineLabel,
            greetingLabel,
            this.studentNameLabel,
            this.registrationLabel,
            this.degreeNameLabel,
            honoursLabel,
            this.universityNameLabel,
            this.senateApprovalLabel,
            this.graduationDateLabel,
            this.closingLabel,
            signatureAreaLabel,
            sealAreaLabel,
            this.certNumberLabel,
            verificationLabel,
            this.barCode,
            this.qrCode
        });

        // Top Margin
        this.TopMargin.HeightF = 50F;
        this.TopMargin.Name = "TopMargin";
        this.TopMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
        this.TopMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;

        // Bottom Margin
        this.BottomMargin.HeightF = 50F;
        this.BottomMargin.Name = "BottomMargin";
        this.BottomMargin.Padding = new DevExpress.XtraPrinting.PaddingInfo(0, 0, 0, 0, 100F);
        this.BottomMargin.TextAlignment = DevExpress.XtraPrinting.TextAlignment.TopLeft;

        // Report
        this.Bands.AddRange(new DevExpress.XtraReports.UI.Band[] {
            this.TopMargin,
            this.Detail,
            this.BottomMargin});
        this.DataSource = this.resultsData1;
        this.Font = new System.Drawing.Font("Calibri", 11F);
        this.Margins = new System.Drawing.Printing.Margins(79, 79, 79, 79);
        this.PageHeight = 1169;
        this.PageWidth = 827;
        this.PaperKind = System.Drawing.Printing.PaperKind.A4;
        this.Version = "16.1";
        ((System.ComponentModel.ISupportInitialize)(this.resultsData1)).EndInit();
        ((System.ComponentModel.ISupportInitialize)(this)).EndInit();
    }

    #endregion

    private void MastersLetterOfAward_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
    {
        UpdateParameterValues();
    }

    private void UpdateParameterValues()
    {
        try
        {
            // Update labels with parameter values
            string letterDate = Parameters["LetterDate"].Value != null ? Parameters["LetterDate"].Value.ToString() : "";
            string refNumber = Parameters["RefNumber"].Value != null ? Parameters["RefNumber"].Value.ToString() : "";
            string degreeName = Parameters["DegreeName"].Value != null ? Parameters["DegreeName"].Value.ToString() : "";
            string senateDate = Parameters["SenateApprovalDate"].Value != null ? Parameters["SenateApprovalDate"].Value.ToString() : "";
            string gradDate = Parameters["GraduationDate"].Value != null ? Parameters["GraduationDate"].Value.ToString() : "";

            letterDateLabel.Text = "Date: " + letterDate;
            refNumberLabel.Text = "Ref: " + refNumber;
            subjectLineLabel.Text = "RE: LETTER OF AWARD FOR THE DEGREE OF " + degreeName;
            degreeNameLabel.Text = degreeName;
            senateApprovalLabel.Text = "The Senate at its meeting held on " + senateDate + " approved the award of the above degree.";
            graduationDateLabel.Text = "The graduate will be presented for the conferment of this award at the forthcoming Graduation Ceremony scheduled for " + gradDate + ".";

            // Update verification URL and QR code using document serial
            try
            {
                object serialObj = this.GetCurrentColumnValue("doc_no");
                string serial = serialObj != null ? serialObj.ToString() : "";
                string verifyUrl = "https://verify.mru.ac.ug/masters?serial=" + serial;
                if (this.qrCode != null)
                {
                    this.qrCode.Text = verifyUrl;
                }
                // find verification label (declared locally in InitializeComponent)
                var vlabel = this.FindControl("verificationLabel", true) as XRLabel;
                if (vlabel != null)
                {
                    vlabel.Text = "Verify this document at: " + verifyUrl;
                }
            }
            catch { }
        }
        catch (Exception ex)
        {
            // Silently fail - labels will show default text
        }
    }
}
