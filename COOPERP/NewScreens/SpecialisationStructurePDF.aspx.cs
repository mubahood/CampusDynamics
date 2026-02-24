using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using MySql.Data.MySqlClient;
using DXPrint = DevExpress.XtraPrinting;

public partial class COOPERP_NewScreens_SpecialisationStructurePDF : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Colour / font constants (shared between HTML and PDF paths)
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private static readonly System.Drawing.Color ColBrand      = System.Drawing.Color.FromArgb(23,  77, 164);
    private static readonly System.Drawing.Color ColBrandDark  = System.Drawing.Color.FromArgb(17,  60, 130);
    private static readonly System.Drawing.Color ColYearBar    = System.Drawing.Color.FromArgb(30,  95, 191);
    private static readonly System.Drawing.Color ColSemBg      = System.Drawing.Color.FromArgb(238, 242, 255);
    private static readonly System.Drawing.Color ColHeaderBg   = System.Drawing.Color.FromArgb(240, 243, 255);
    private static readonly System.Drawing.Color ColAltRow     = System.Drawing.Color.FromArgb(250, 251, 255);
    private static readonly System.Drawing.Color ColBorder     = System.Drawing.Color.FromArgb(204, 204, 221);
    private static readonly System.Drawing.Color ColText       = System.Drawing.Color.FromArgb( 34,  34,  34);
    private static readonly System.Drawing.Color ColMuted      = System.Drawing.Color.FromArgb(102, 102, 102);
    private static readonly System.Drawing.Color ColGreen      = System.Drawing.Color.FromArgb( 26, 122,  26);
    private static readonly System.Drawing.Color ColWhite      = System.Drawing.Color.White;
    private static readonly System.Drawing.Color ColSumBg      = System.Drawing.Color.FromArgb(240, 244, 255);
    private static readonly System.Drawing.Color ColSumBorder  = System.Drawing.Color.FromArgb(200, 216, 248);

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Inner DTO
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private class SpecInfo
    {
        public int    SpecId;
        public string SpecName   = "";
        public string ProgName   = "";
        public string Abbrev     = "";
        public string IsFullySet = "No";
        public string IsActive   = "Active";
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Entry point
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // PDF download mode â€” stream a real generated PDF and end the response
            if (Request.QueryString["download"] == "1")
            {
                GeneratePdfDownload();
                return;
            }
            // Default: render the HTML preview page
            RenderPage();
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Parse IDs helper  (shared by both paths)
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private List<int> ParseIds()
    {
        var ids = new List<int>();
        string batchParam  = (Request.QueryString["batchIds"] ?? "").Trim();
        string singleParam = (Request.QueryString["specId"]   ?? "").Trim();

        if (!string.IsNullOrEmpty(batchParam))
        {
            foreach (string tok in batchParam.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                int id;
                if (int.TryParse(tok.Trim(), out id) && id > 0) ids.Add(id);
            }
        }
        else if (!string.IsNullOrEmpty(singleParam))
        {
            int id;
            if (int.TryParse(singleParam, out id) && id > 0) ids.Add(id);
        }
        return ids;
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  PDF GENERATION  (DevExpress XtraPrinting)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

    private void GeneratePdfDownload()
    {
        List<int> ids = ParseIds();

        // Build the PDF into a MemoryStream via XtraPrinting
        var ps = new DXPrint.PrintingSystem();
        var lnk = new DXPrint.Link(ps);

        // Capture data before lambda
        List<int>  capturedIds          = ids;
        string     capturedInstitution  = GetInstitutionName();
        string     capturedLogoPath     = GetLogoPath();

        lnk.CreateDetailArea += (s, args) =>
            BuildPdfContent(args.Graph, capturedIds, capturedInstitution, capturedLogoPath);

        // A4 portrait, 0.5" margins (50 = hundredths of an inch)
        ps.PageSettings.PaperKind    = System.Drawing.Printing.PaperKind.A4;
        ps.PageSettings.Landscape    = false;
        ps.PageSettings.LeftMargin   = 50;
        ps.PageSettings.RightMargin  = 50;
        ps.PageSettings.TopMargin    = 50;
        ps.PageSettings.BottomMargin = 50;

        lnk.CreateDocument();

        // Build a descriptive filename
        string suffix    = ids.Count == 1 ? "Spec_" + ids[0] : "Batch_" + ids.Count + "specs";
        string fileName  = string.Format("SpecialisationStructure_{0}_{1}.pdf",
                               suffix, DateTime.Now.ToString("yyyyMMdd_HHmm"));

        Response.Clear();
        Response.Buffer = true;
        Response.ClearHeaders();
        Response.ClearContent();
        Response.ContentType = "application/pdf";
        Response.AddHeader("Content-Disposition",
            "attachment; filename=\"" + fileName + "\"");
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);

        using (var ms = new System.IO.MemoryStream())
        {
            ps.ExportToPdf(ms);
            byte[] bytes = ms.ToArray();
            Response.AddHeader("Content-Length", bytes.Length.ToString());
            Response.BinaryWrite(bytes);
            Response.Flush();
        }

        try { Response.End(); }
        catch (System.Threading.ThreadAbortException) { /* expected */ }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Main PDF content builder  (called by Link.CreateDetailArea)
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private void BuildPdfContent(DXPrint.BrickGraphics gr,
        List<int> ids, string institution, string logoRelPath)
    {
        // Page content width: A4 (595pt) minus 2 Ã— 0.5" margins
        // XtraPrinting uses hundredths-of-an-inch for DrawBrick coords
        // A4 @ 100 units/inch: width = 827, minus 2Ã—50 margin = 727 units
        const float PW = 727f; // usable page width
        float y = 0f;

        // â”€â”€ Fonts â”€â”€
        var fInstitution  = new System.Drawing.Font("Tahoma", 13, System.Drawing.FontStyle.Bold);
        var fSubTitle     = new System.Drawing.Font("Tahoma",  8, System.Drawing.FontStyle.Regular);
        var fSpecTitle    = new System.Drawing.Font("Tahoma", 10, System.Drawing.FontStyle.Bold);
        var fYearHdr      = new System.Drawing.Font("Tahoma",  9, System.Drawing.FontStyle.Bold);
        var fSemHdr       = new System.Drawing.Font("Tahoma",  8, System.Drawing.FontStyle.Bold);
        var fTableHdr     = new System.Drawing.Font("Tahoma",  7, System.Drawing.FontStyle.Bold);
        var fCell         = new System.Drawing.Font("Tahoma",  7, System.Drawing.FontStyle.Regular);
        var fCellBold     = new System.Drawing.Font("Tahoma",  7, System.Drawing.FontStyle.Bold);
        var fMeta         = new System.Drawing.Font("Tahoma",  7, System.Drawing.FontStyle.Regular);
        var fMetaBold     = new System.Drawing.Font("Tahoma",  7, System.Drawing.FontStyle.Bold);
        var fSummary      = new System.Drawing.Font("Tahoma",  8, System.Drawing.FontStyle.Bold);
        var fFooter       = new System.Drawing.Font("Tahoma",  7, System.Drawing.FontStyle.Italic);
        var fSmall        = new System.Drawing.Font("Tahoma",  6, System.Drawing.FontStyle.Regular);

        bool isBatch = ids.Count > 1;
        int  grandCourse = 0;
        double grandCU  = 0;

        // Gather all spec data first
        var specList = new List<Tuple<SpecInfo, DataTable>>();
        foreach (int id in ids)
        {
            SpecInfo info = GetSpecInfo(id);
            DataTable dt  = info != null ? GetAllCoursesForSpec(id) : new DataTable();
            if (info == null) info = new SpecInfo { SpecId = id, SpecName = "(Not found â€” ID " + id + ")" };
            specList.Add(Tuple.Create(info, dt));
            grandCourse += dt.Rows.Count;
            grandCU     += CalcCU(dt);
        }

        // â”€â”€ Institution Header â”€â”€
        y = DrawInstitutionHeader(gr, institution, logoRelPath, PW, y, fInstitution, fSubTitle);
        y += 6;
        PdfDrawLine(gr, 0, y, PW, y, ColBrand, 1.5f);
        y += 8;

        // â”€â”€ Batch Banner or Single Meta â”€â”€
        if (isBatch)
        {
            y = DrawBatchBanner(gr, ids.Count, grandCourse, grandCU, PW, y, fSpecTitle, fMeta);
            y += 8;
        }
        else if (specList.Count > 0)
        {
            SpecInfo si  = specList[0].Item1;
            int      cnt = specList[0].Item2.Rows.Count;
            double   cu  = CalcCU(specList[0].Item2);
            y = DrawSingleMeta(gr, si, cnt, cu, PW, y, fMeta, fMetaBold, fSummary);
            y += 8;
        }

        // â”€â”€ Each specialisation â”€â”€
        for (int idx = 0; idx < specList.Count; idx++)
        {
            SpecInfo  info = specList[idx].Item1;
            DataTable dt   = specList[idx].Item2;
            int       cnt  = dt.Rows.Count;
            double    cu   = CalcCU(dt);

            if (isBatch)
            {
                // Spec title bar
                y = DrawSpecTitleBar(gr, info, idx + 1, ids.Count, PW, y, fSpecTitle, fMeta, fMetaBold, fSummary);
                y += 6;
            }

            if (cnt == 0)
            {
                PdfTextBrick(gr, "(No courses found for this specialisation)", 0, y, PW, 14,
                    fMeta, ColMuted, ColWhite, DXPrint.BorderSide.None, ColBorder,
                    System.Drawing.StringAlignment.Near);
                y += 16;
            }
            else
            {
                y = DrawYearBlocks(gr, dt, PW, y,
                    fYearHdr, fSemHdr, fTableHdr, fCell, fCellBold, fSmall);
            }

            y += 10;

            if (isBatch && idx < specList.Count - 1)
            {
                PdfDrawLine(gr, 0, y, PW, y, ColBorder, 0.5f);
                y += 10;
            }
        }

        // â”€â”€ Footer â”€â”€
        PdfDrawLine(gr, 0, y, PW, y, ColBorder, 0.5f);
        y += 5;
        string footerLeft  = "Campus Dynamics ERP \u2014 Academic Module";
        string footerRight = "Generated: " + DateTime.Now.ToString("dd MMM yyyy  HH:mm");
        PdfTextBrick(gr, footerLeft,  0,          y, PW * 0.55f, 12,
            fFooter, ColMuted, ColWhite, DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Near);
        PdfTextBrick(gr, footerRight, PW * 0.55f, y, PW * 0.45f, 12,
            fFooter, ColMuted, ColWhite, DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Far);
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  PDF section renderers
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private float DrawInstitutionHeader(DXPrint.BrickGraphics gr,
        string institution, string logoRelPath,
        float pw, float y,
        System.Drawing.Font fTitle, System.Drawing.Font fSub)
    {
        // Try to draw logo on the left
        float logoW = 0;
        if (!string.IsNullOrEmpty(logoRelPath))
        {
            try
            {
                string absPath = Server.MapPath("~/" + logoRelPath);
                if (System.IO.File.Exists(absPath))
                {
                    var imgBrick = new DXPrint.ImageBrick();
                    imgBrick.Image = System.Drawing.Image.FromFile(absPath);
                    imgBrick.Sides = DXPrint.BorderSide.None;
                    imgBrick.SizeMode = DXPrint.ImageSizeMode.Squeeze;
                    gr.DrawBrick(imgBrick, new System.Drawing.RectangleF(0, y, 60, 46));
                    logoW = 66;
                }
            }
            catch { }
        }

        PdfTextBrick(gr, institution, logoW, y, pw - logoW, 22,
            fTitle, ColBrand, ColWhite, DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Near);
        PdfTextBrick(gr, "Programme Specialisation \u2014 Course Structure",
            logoW, y + 22, pw - logoW, 14,
            fSub, ColMuted, ColWhite, DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Near);
        return y + 46;
    }

    private float DrawBatchBanner(DXPrint.BrickGraphics gr,
        int specCount, int totalCourses, double totalCU,
        float pw, float y,
        System.Drawing.Font fTitle, System.Drawing.Font fMeta)
    {
        float bh = 38;
        // Background
        PdfFillRect(gr, 0, y, pw, bh, ColBrand);
        PdfTextBrick(gr, "Batch Curriculum Export",
            10, y + 4, pw * 0.6f, 16,
            fTitle, ColWhite, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBrand,
            System.Drawing.StringAlignment.Near);
        PdfTextBrick(gr, specCount + " specialisation" + (specCount == 1 ? "" : "s") + " exported",
            10, y + 20, pw * 0.6f, 12,
            fMeta, System.Drawing.Color.FromArgb(200, 220, 255),
            System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBrand,
            System.Drawing.StringAlignment.Near);
        string right = "Total Courses: " + totalCourses +
                       "   |   Total CU: " + totalCU.ToString("0.##") +
                       "   |   " + DateTime.Now.ToString("dd MMM yyyy");
        PdfTextBrick(gr, right, pw * 0.6f, y + 13, pw * 0.4f - 10, 12,
            fMeta, System.Drawing.Color.FromArgb(200, 220, 255),
            System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBrand,
            System.Drawing.StringAlignment.Far);
        return y + bh;
    }

    private float DrawSingleMeta(DXPrint.BrickGraphics gr,
        SpecInfo info, int cnt, double cu,
        float pw, float y,
        System.Drawing.Font fMeta, System.Drawing.Font fMetaBold, System.Drawing.Font fSummary)
    {
        // 4-cell meta strip
        float cellW = pw / 4f;
        float ch    = 30f;
        string[] labels = { "Programme", "Specialisation", "Status", "Date" };
        string[] vals   = {
            info.ProgName,
            info.SpecName + (string.IsNullOrEmpty(info.Abbrev) ? "" : " (" + info.Abbrev + ")"),
            info.IsActive,
            DateTime.Now.ToString("dd MMM yyyy")
        };
        for (int i = 0; i < 4; i++)
        {
            float cx = i * cellW;
            PdfFillRect(gr, cx, y, cellW, ch, ColWhite);
            PdfDrawRect(gr, cx, y, cellW, ch, ColSumBorder, 0.5f);
            PdfTextBrick(gr, labels[i], cx + 5, y + 3, cellW - 10, 10,
                fMeta, ColMuted, System.Drawing.Color.Transparent,
                DXPrint.BorderSide.None, ColBorder,
                System.Drawing.StringAlignment.Near);
            PdfTextBrick(gr, vals[i], cx + 5, y + 14, cellW - 10, 13,
                fMetaBold, ColText, System.Drawing.Color.Transparent,
                DXPrint.BorderSide.None, ColBorder,
                System.Drawing.StringAlignment.Near);
        }
        y += ch;
        // Summary strip
        float sh = 20f;
        PdfFillRect(gr, 0, y, pw, sh, ColSumBg);
        PdfDrawRect(gr, 0, y, pw, sh, ColSumBorder, 0.5f);
        string summary = string.Format("  Total Courses: {0}     Total Credit Units: {1}     Fully Set: {2}",
            cnt, cu.ToString("0.##"), info.IsFullySet);
        PdfTextBrick(gr, summary, 0, y + 4, pw, 14,
            fSummary, ColBrand, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Near);
        return y + sh;
    }

    private float DrawSpecTitleBar(DXPrint.BrickGraphics gr,
        SpecInfo info, int seq, int total,
        float pw, float y,
        System.Drawing.Font fTitle, System.Drawing.Font fMeta,
        System.Drawing.Font fMetaBold, System.Drawing.Font fSummary)
    {
        // Title bar
        float th = 22f;
        PdfFillRect(gr, 0, y, pw, th, ColBrand);
        PdfTextBrick(gr, info.SpecName, 8, y + 4, pw * 0.8f, 14,
            fTitle, ColWhite, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBrand,
            System.Drawing.StringAlignment.Near);
        PdfTextBrick(gr, seq + " of " + total, pw * 0.8f, y + 6, pw * 0.2f - 5, 12,
            fMeta, System.Drawing.Color.FromArgb(180, 205, 240),
            System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBrand,
            System.Drawing.StringAlignment.Far);
        y += th;

        // Meta row
        float mh = 18f;
        PdfFillRect(gr, 0, y, pw, mh, System.Drawing.Color.FromArgb(248, 249, 255));
        PdfDrawRect(gr, 0, y, pw, mh, ColBorder, 0.5f);
        string meta = string.Format("  Programme: {0}   |   Abbrev: {1}   |   Fully Set: {2}   |   Status: {3}",
            info.ProgName, info.Abbrev, info.IsFullySet, info.IsActive);
        PdfTextBrick(gr, meta, 0, y + 4, pw, 12,
            fMeta, ColMuted, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Near);
        y += mh;

        return y;
    }

    private float DrawYearBlocks(DXPrint.BrickGraphics gr, DataTable dt,
        float pw, float y,
        System.Drawing.Font fYearHdr, System.Drawing.Font fSemHdr,
        System.Drawing.Font fTableHdr, System.Drawing.Font fCell,
        System.Drawing.Font fCellBold, System.Drawing.Font fSmall)
    {
        const float codeW  =  65f;
        const float typeW  =  16f;
        const float cuW    =  24f;
        const float rowH   =  14f;
        const float tblHdrH = 15f;
        const float semHdrH = 18f;
        const float yearHdrH= 20f;

        for (int year = 1; year <= 6; year++)
        {
            DataRow[] yearRows = dt.Select("study_year = " + year, "semester ASC, course_code ASC");
            if (yearRows.Length == 0) continue;

            // Year header
            PdfFillRect(gr, 0, y, pw, yearHdrH, ColYearBar);
            PdfTextBrick(gr, "YEAR " + year, 8, y + 4, pw - 16, 14,
                fYearHdr, ColWhite, System.Drawing.Color.Transparent,
                DXPrint.BorderSide.None, ColBorder,
                System.Drawing.StringAlignment.Near);
            y += yearHdrH + 4;

            // Semesters in 2-column layout  (sem 1 | sem 2,  sem 3 alone if present)
            var semGroups = new Dictionary<int, List<DataRow>>();
            foreach (DataRow row in yearRows)
            {
                int sem = row["semester"] != DBNull.Value ? Convert.ToInt32(row["semester"]) : 1;
                if (!semGroups.ContainsKey(sem)) semGroups[sem] = new List<DataRow>();
                semGroups[sem].Add(row);
            }

            var semKeys = new List<int>(semGroups.Keys);
            semKeys.Sort();

            // Render pairs: (1,2) then (3) alone
            int si = 0;
            while (si < semKeys.Count)
            {
                int  s1   = semKeys[si];
                int? s2   = (si + 1 < semKeys.Count) ? (int?)semKeys[si + 1] : null;
                float colW = s2.HasValue ? (pw - 6) / 2f : pw;
                float x1   = 0;
                float x2   = colW + 6;

                // Measure heights for both columns to align bottom
                float h1 = SemColumnHeight(semGroups[s1].Count, semHdrH, tblHdrH, rowH);
                float h2 = s2.HasValue ? SemColumnHeight(semGroups[s2.Value].Count, semHdrH, tblHdrH, rowH) : 0;
                float colH = Math.Max(h1, h2);

                y = DrawSemColumn(gr, semGroups[s1], s1, x1, y, colW, colH,
                    semHdrH, tblHdrH, rowH, codeW, typeW, cuW,
                    fSemHdr, fTableHdr, fCell, fCellBold, fSmall);

                if (s2.HasValue)
                {
                    // Draw second column at same starting y (y - colH because DrawSemColumn advanced y by colH)
                    float startY = y - colH;
                    DrawSemColumn(gr, semGroups[s2.Value], s2.Value, x2, startY, colW, colH,
                        semHdrH, tblHdrH, rowH, codeW, typeW, cuW,
                        fSemHdr, fTableHdr, fCell, fCellBold, fSmall);
                }

                y += 6;
                si += s2.HasValue ? 2 : 1;
            }

            y += 4;
        }
        return y;
    }

    private float SemColumnHeight(int courseCount, float semHdrH, float tblHdrH, float rowH)
    {
        return semHdrH + tblHdrH + (courseCount * rowH) + rowH; // +rowH for subtotal row
    }

    private float DrawSemColumn(DXPrint.BrickGraphics gr, List<DataRow> rows, int sem,
        float x, float y, float colW, float colH,
        float semHdrH, float tblHdrH, float rowH,
        float codeW, float typeW, float cuW,
        System.Drawing.Font fSemHdr, System.Drawing.Font fTableHdr,
        System.Drawing.Font fCell, System.Drawing.Font fCellBold, System.Drawing.Font fSmall)
    {
        float startY = y;
        double semCU = 0;
        foreach (DataRow r in rows)
            semCU += r["CreditUnit"] != DBNull.Value ? Convert.ToDouble(r["CreditUnit"]) : 0;

        // Semester header
        PdfFillRect(gr, x, y, colW, semHdrH, ColSemBg);
        PdfDrawRect(gr, x, y, colW, semHdrH, ColBrand, 1.5f);
        string semLabel = string.Format("Semester {0}   \u2014   {1} course{2}   \u2022   {3} CU",
            sem, rows.Count, rows.Count == 1 ? "" : "s", semCU.ToString("0.##"));
        PdfTextBrick(gr, semLabel, x + 6, y + 4, colW - 12, 12,
            fSemHdr, System.Drawing.Color.FromArgb(26, 42, 94),
            System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBrand,
            System.Drawing.StringAlignment.Near);
        y += semHdrH;

        // Table header
        float nameW = colW - codeW - typeW - cuW;
        DrawPdfTableHeaderRow(gr, x, y, colW, tblHdrH, codeW, nameW, typeW, cuW, fTableHdr);
        y += tblHdrH;

        // Data rows
        int rowNum = 0;
        foreach (DataRow row in rows)
        {
            string code  = row["course_code"].ToString();
            string name  = (row["courseName"] != DBNull.Value && !string.IsNullOrEmpty(row["courseName"].ToString()))
                            ? row["courseName"].ToString()
                            : code;
            string ctype = (row["course_type"] != DBNull.Value ? row["course_type"].ToString().ToUpper() : "CORE");
            double cu    = row["CreditUnit"] != DBNull.Value ? Convert.ToDouble(row["CreditUnit"]) : 0;
            bool   isE   = ctype == "ELECTIVE";

            System.Drawing.Color rowBg = rowNum % 2 == 0 ? ColWhite : ColAltRow;

            DrawPdfTableRow(gr, x, y, colW, rowH, codeW, nameW, typeW, cuW,
                code, name, isE ? "E" : "C", cu > 0 ? cu.ToString("0.#") : "-",
                rowBg, isE ? ColGreen : ColMuted,
                fCell, fCellBold, fSmall);
            y += rowH;
            rowNum++;
        }

        // Subtotal row
        PdfFillRect(gr, x, y, colW, rowH, ColSumBg);
        PdfDrawRect(gr, x, y, colW, rowH, ColBorder, 0.5f);
        PdfDrawLine(gr, x, y, x + colW, y, ColSumBorder, 1f);
        PdfTextBrick(gr, "Subtotal", x, y + 3, colW - cuW - 4, 11,
            fCellBold, ColBrand, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Far);
        PdfTextBrick(gr, semCU.ToString("0.##"), x + colW - cuW, y + 3, cuW - 2, 11,
            fCellBold, ColBrand, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Center);
        y += rowH;

        return startY + colH; // always advance by the measured column height
    }

    private void DrawPdfTableHeaderRow(DXPrint.BrickGraphics gr,
        float x, float y, float colW, float h,
        float codeW, float nameW, float typeW, float cuW,
        System.Drawing.Font fHdr)
    {
        PdfFillRect(gr, x, y, colW, h, ColHeaderBg);
        float cx = x;
        PdfTextBrick(gr, "CODE",   cx, y + 3, codeW, h - 3, fHdr, ColMuted, System.Drawing.Color.Transparent, DXPrint.BorderSide.None, ColBorder, System.Drawing.StringAlignment.Near);  cx += codeW;
        PdfTextBrick(gr, "COURSE NAME", cx, y + 3, nameW, h - 3, fHdr, ColMuted, System.Drawing.Color.Transparent, DXPrint.BorderSide.None, ColBorder, System.Drawing.StringAlignment.Near);  cx += nameW;
        PdfTextBrick(gr, "T",      cx, y + 3, typeW, h - 3, fHdr, ColMuted, System.Drawing.Color.Transparent, DXPrint.BorderSide.None, ColBorder, System.Drawing.StringAlignment.Center); cx += typeW;
        PdfTextBrick(gr, "CU",     cx, y + 3, cuW,   h - 3, fHdr, ColMuted, System.Drawing.Color.Transparent, DXPrint.BorderSide.None, ColBorder, System.Drawing.StringAlignment.Center);
        PdfDrawLine(gr, x, y + h, x + colW, y + h, ColBorder, 0.5f);
    }

    private void DrawPdfTableRow(DXPrint.BrickGraphics gr,
        float x, float y, float colW, float h,
        float codeW, float nameW, float typeW, float cuW,
        string code, string name, string type, string cu,
        System.Drawing.Color rowBg, System.Drawing.Color typeColor,
        System.Drawing.Font fCell, System.Drawing.Font fCellBold, System.Drawing.Font fSmall)
    {
        PdfFillRect(gr, x, y, colW, h, rowBg);
        PdfDrawLine(gr, x, y + h, x + colW, y + h, ColBorder, 0.3f);

        float cx = x;
        PdfTextBrick(gr, code, cx + 2, y + 3, codeW - 4, h - 4,
            fCellBold, ColBrand, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Near);
        cx += codeW;
        PdfTextBrick(gr, name, cx + 2, y + 3, nameW - 4, h - 4,
            fCell, ColText, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Near);
        cx += nameW;
        PdfTextBrick(gr, type, cx, y + 3, typeW, h - 4,
            fSmall, typeColor, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Center);
        cx += typeW;
        PdfTextBrick(gr, cu, cx, y + 3, cuW - 2, h - 4,
            fCell, ColMuted, System.Drawing.Color.Transparent,
            DXPrint.BorderSide.None, ColBorder,
            System.Drawing.StringAlignment.Center);
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Low-level PDF brick helpers
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private void PdfTextBrick(DXPrint.BrickGraphics gr,
        string text, float x, float y, float w, float h,
        System.Drawing.Font font, System.Drawing.Color fore,
        System.Drawing.Color back, DXPrint.BorderSide sides,
        System.Drawing.Color borderColor,
        System.Drawing.StringAlignment align)
    {
        if (string.IsNullOrEmpty(text)) text = "";
        var b = new DXPrint.TextBrick();
        b.Text        = text;
        b.Font        = font;
        b.ForeColor   = fore;
        b.BackColor   = back;
        b.Sides       = sides;
        b.BorderColor = borderColor;
        b.StringFormat = new DXPrint.BrickStringFormat(align);
        b.Padding     = new DXPrint.PaddingInfo(2, 2, 0, 0);
        gr.DrawBrick(b, new System.Drawing.RectangleF(x, y, w, h));
    }

    private void PdfFillRect(DXPrint.BrickGraphics gr,
        float x, float y, float w, float h,
        System.Drawing.Color color)
    {
        var b = new DXPrint.TextBrick();
        b.Text      = "";
        b.BackColor = color;
        b.Sides     = DXPrint.BorderSide.None;
        gr.DrawBrick(b, new System.Drawing.RectangleF(x, y, w, h));
    }

    private void PdfDrawLine(DXPrint.BrickGraphics gr,
        float x1, float y1, float x2, float y2,
        System.Drawing.Color color, float width)
    {
        var b = new DXPrint.LineBrick();
        b.ForeColor  = color;
        b.LineWidth  = width;
        b.LineStyle  = System.Drawing.Drawing2D.DashStyle.Solid;
        b.Sides      = DXPrint.BorderSide.None;
        gr.DrawBrick(b, new System.Drawing.RectangleF(x1, y1, x2 - x1 + 1, y2 - y1 + 1));
    }

    private void PdfDrawRect(DXPrint.BrickGraphics gr,
        float x, float y, float w, float h,
        System.Drawing.Color borderColor, float borderWidth)
    {
        var b = new DXPrint.TextBrick();
        b.Text        = "";
        b.BackColor   = System.Drawing.Color.Transparent;
        b.Sides       = DXPrint.BorderSide.All;
        b.BorderColor = borderColor;
        b.BorderWidth = borderWidth;
        gr.DrawBrick(b, new System.Drawing.RectangleF(x, y, w, h));
    }

    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
    //  HTML PREVIEW PATH  (unchanged from original logic)
    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

    private void RenderPage()
    {
        var ids = ParseIds();

        litInstitution.Text = Server.HtmlEncode(GetInstitutionName());
        string logo = GetLogoPath();
        if (!string.IsNullOrEmpty(logo)) { imgLogo.ImageUrl = "~/" + logo; imgLogo.Visible = true; }

        if (ids.Count == 0)
        {
            phContent.Controls.Add(new LiteralControl(
                "<div class='no-data'>No specialisation specified.<br/>" +
                "<small style='color:#bbb'>Pass <code>?specId=N</code> or <code>?batchIds=N,N,N</code></small></div>"));
            return;
        }

        bool   isBatch     = ids.Count > 1;
        int    grandCourse = 0;
        double grandCU     = 0;

        var sbContent = new StringBuilder();
        SpecInfo singleInfo  = null;
        int      singleCount = 0;
        double   singleCU    = 0;

        for (int idx = 0; idx < ids.Count; idx++)
        {
            int      specId = ids[idx];
            bool     isLast = (idx == ids.Count - 1);
            SpecInfo info   = GetSpecInfo(specId);

            if (info == null)
            {
                sbContent.AppendFormat(
                    "<div class='err-msg'>Specialisation ID <strong>{0}</strong> was not found &mdash; skipped.</div>", specId);
                continue;
            }

            DataTable dt  = GetAllCoursesForSpec(specId);
            int       cnt = dt.Rows.Count;
            double    cu  = CalcCU(dt);

            grandCourse += cnt;
            grandCU     += cu;

            if (!isBatch) { singleInfo = info; singleCount = cnt; singleCU = cu; }

            if (isBatch)
            {
                sbContent.AppendFormat(
                    "<div class='spec-section'{0}>",
                    isLast ? " style='page-break-after:avoid'" : "");
                sbContent.AppendFormat(
                    "<div class='spec-title-bar'><span>{0}</span><span class='stb-seq'>{1} of {2}</span></div>",
                    Server.HtmlEncode(info.SpecName), idx + 1, ids.Count);
                sbContent.AppendFormat(
                    "<div class='spec-meta-row'>" +
                    "<span><strong>Programme:</strong> {0}</span>" +
                    "<span><strong>Abbrev:</strong> {1}</span>" +
                    "<span><strong>Fully Set:</strong> {2}</span>" +
                    "<span><strong>Status:</strong> {3}</span></div>",
                    Server.HtmlEncode(info.ProgName), Server.HtmlEncode(info.Abbrev),
                    Server.HtmlEncode(info.IsFullySet), Server.HtmlEncode(info.IsActive));
                sbContent.AppendFormat(
                    "<div class='spec-sumbar'><span>Courses: <strong>{0}</strong></span>" +
                    "<span>Credit Units: <strong>{1}</strong></span></div>",
                    cnt, cu.ToString("0.##"));
            }
            else
            {
                sbContent.Append("<div class='spec-section' style='page-break-after:avoid'>");
            }

            if (cnt == 0)
                sbContent.Append("<div class='no-data'>No courses found for this specialisation.</div>");
            else
                RenderYearBlocks(sbContent, dt);

            sbContent.Append("</div>"); // spec-section
        }

        var sbMeta = new StringBuilder();
        if (isBatch)
        {
            sbMeta.AppendFormat(
                "<div class='batch-banner'>" +
                "<div class='bb-left'><div class='bb-title'>Batch Curriculum Export</div>" +
                "<div class='bb-sub'>{0} specialisation{1} exported</div></div>" +
                "<div class='bb-right'>Total Courses: <strong>{2}</strong><br/>" +
                "Total Credit Units: <strong>{3}</strong><br/>" +
                "<span style='font-size:7pt;opacity:.8'>{4}</span></div></div>",
                ids.Count, ids.Count == 1 ? "" : "s",
                grandCourse, grandCU.ToString("0.##"),
                DateTime.Now.ToString("dd MMM yyyy"));
        }
        else if (singleInfo != null)
        {
            sbMeta.Append("<div class='single-meta'>");
            sbMeta.AppendFormat("<div class='sm-card'><div class='sc-label'>Programme</div><div class='sc-value'>{0}</div></div>", Server.HtmlEncode(singleInfo.ProgName));
            sbMeta.AppendFormat("<div class='sm-card'><div class='sc-label'>Specialisation</div><div class='sc-value'>{0} <span style='font-size:7pt;color:#888'>({1})</span></div></div>", Server.HtmlEncode(singleInfo.SpecName), Server.HtmlEncode(singleInfo.Abbrev));
            sbMeta.AppendFormat("<div class='sm-card'><div class='sc-label'>Status</div><div class='sc-value'>{0}</div></div>", Server.HtmlEncode(singleInfo.IsActive));
            sbMeta.AppendFormat("<div class='sm-card'><div class='sc-label'>Date</div><div class='sc-value'>{0}</div></div>", DateTime.Now.ToString("dd MMM yyyy"));
            sbMeta.Append("</div>");
            sbMeta.AppendFormat(
                "<div class='single-summary'><span>Total Courses: <strong>{0}</strong></span>" +
                "<span>Total Credit Units: <strong>{1}</strong></span>" +
                "<span>Fully Set: <strong>{2}</strong></span></div>",
                singleCount, singleCU.ToString("0.##"), Server.HtmlEncode(singleInfo.IsFullySet));
        }

        phMeta.Controls.Add(new LiteralControl(sbMeta.ToString()));
        phContent.Controls.Add(new LiteralControl(sbContent.ToString()));
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  HTML year/semester renderer  (unchanged)
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private void RenderYearBlocks(StringBuilder sb, DataTable dt)
    {
        for (int year = 1; year <= 6; year++)
        {
            DataRow[] yearRows = dt.Select("study_year = " + year, "semester ASC, course_code ASC");
            if (yearRows.Length == 0) continue;

            sb.Append("<div class='year-block'>");
            sb.AppendFormat("<div class='year-hdr'>YEAR {0}</div>", year);
            sb.Append("<div class='sems-row'>");

            for (int sem = 1; sem <= 3; sem++)
            {
                DataRow[] semRows = Array.FindAll(yearRows, r =>
                    r["semester"] != DBNull.Value && Convert.ToInt32(r["semester"]) == sem);
                if (semRows.Length == 0) continue;

                double semCU = CalcCU(semRows);

                sb.Append("<div class='sem-col'>");
                sb.AppendFormat(
                    "<div class='sem-hdr'>Semester {0}<span class='sh-meta'>{1} course{2} &bull; {3} CU</span></div>",
                    sem, semRows.Length, semRows.Length == 1 ? "" : "s", semCU.ToString("0.##"));

                sb.Append("<table class='ct'><thead><tr>" +
                    "<th style='width:58px'>Code</th><th>Course Name</th>" +
                    "<th style='width:14px'>T</th><th style='width:22px'>CU</th>" +
                    "</tr></thead><tbody>");

                foreach (DataRow row in semRows)
                {
                    string code  = Server.HtmlEncode(row["course_code"].ToString());
                    string name  = Server.HtmlEncode(
                        row["courseName"] != DBNull.Value && !string.IsNullOrEmpty(row["courseName"].ToString())
                            ? row["courseName"].ToString() : row["course_code"].ToString());
                    string ctype = row["course_type"] != DBNull.Value ? row["course_type"].ToString().ToUpper() : "CORE";
                    double cu    = row["CreditUnit"]  != DBNull.Value ? Convert.ToDouble(row["CreditUnit"]) : 0;
                    bool   isE   = ctype == "ELECTIVE";

                    sb.AppendFormat("<tr>" +
                        "<td class='ct-code'>{0}</td><td>{1}</td>" +
                        "<td class='ct-type {2}'>{3}</td>" +
                        "<td class='ct-cu'>{4}</td></tr>",
                        code, name,
                        isE ? "ct-e" : "ct-c",
                        isE ? "E" : "C",
                        cu > 0 ? cu.ToString("0.#") : "&mdash;");
                }

                sb.AppendFormat("<tr class='ct-tot'>" +
                    "<td colspan='3' style='text-align:right;padding-right:7px'>Subtotal</td>" +
                    "<td class='ct-cu'>{0}</td></tr>", semCU.ToString("0.##"));

                sb.Append("</tbody></table></div>");
            }

            sb.Append("</div></div>");
        }
    }

    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    //  Shared helpers
    // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    private double CalcCU(DataTable dt)
    {
        double cu = 0;
        foreach (DataRow r in dt.Rows)
            cu += r["CreditUnit"] != DBNull.Value ? Convert.ToDouble(r["CreditUnit"]) : 0;
        return cu;
    }

    private double CalcCU(DataRow[] rows)
    {
        double cu = 0;
        foreach (DataRow r in rows)
            cu += r["CreditUnit"] != DBNull.Value ? Convert.ToDouble(r["CreditUnit"]) : 0;
        return cu;
    }

    private double CalcCU(List<DataRow> rows)
    {
        double cu = 0;
        foreach (DataRow r in rows)
            cu += r["CreditUnit"] != DBNull.Value ? Convert.ToDouble(r["CreditUnit"]) : 0;
        return cu;
    }

    private SpecInfo GetSpecInfo(int specId)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT s.spec,
                             s.abbrev,
                             COALESCE(s.is_fully_set, 'No')     AS is_fully_set,
                             COALESCE(s.is_active,   'Active')  AS is_active,
                             COALESCE(p.progname, s.prog_id)    AS progname
                        FROM acad_specialisation s
                        LEFT JOIN acad_programme p ON s.prog_id = p.progcode
                       WHERE s.spec_id = @id
                       LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", specId);
                    using (MySqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                            return new SpecInfo
                            {
                                SpecId     = specId,
                                SpecName   = r["spec"].ToString(),
                                ProgName   = r["progname"].ToString(),
                                Abbrev     = r["abbrev"].ToString(),
                                IsFullySet = r["is_fully_set"].ToString(),
                                IsActive   = r["is_active"].ToString()
                            };
                    }
                }
            }
        }
        catch { }
        return null;
    }

    private DataTable GetAllCoursesForSpec(int specId)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql =
                @"SELECT pc.course_code,
                         COALESCE(c.courseName, pc.course_code) AS courseName,
                         COALESCE(c.CreditUnit, 0)              AS CreditUnit,
                         pc.study_year,
                         pc.semester,
                         COALESCE(pc.course_type, 'CORE')       AS course_type
                    FROM acad_programmecourses pc
                    LEFT JOIN acad_course c ON pc.course_code = c.courseID
                   WHERE pc.specialisation_id = @specId
                   ORDER BY pc.study_year, pc.semester, pc.course_code";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) da.Fill(dt);
            }
        }
        return dt;
    }

    private string GetInstitutionName()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT SettingValue FROM sys_setting WHERE SettingKey = 'InstitutionName' LIMIT 1", conn))
                {
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) return r.ToString();
                }
            }
        }
        catch { }
        return "Campus Dynamics Institution";
    }

    private string GetLogoPath()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT SettingValue FROM sys_setting WHERE SettingKey = 'LogoPath' LIMIT 1", conn))
                {
                    object r = cmd.ExecuteScalar();
                    if (r != null && r != DBNull.Value) return r.ToString();
                }
            }
        }
        catch { }
        return "";
    }
}
