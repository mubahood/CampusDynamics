using System;
using System.Drawing;
using System.Drawing.Printing;
using DevExpress.XtraPrinting;
using DevExpress.XtraReports.UI;

/// <summary>
/// The styling engine behind Template 3 (the compact, single-page transcript).
///
/// It takes a report that has ALREADY been built by Template 1's designer code and
/// restyles it in place. Nothing here knows anything about transcripts specifically —
/// it walks whatever control tree it is handed. That is deliberate: Template 3 is
/// three thin subclasses plus this file, so any future change to the shared Template 1
/// letterhead flows into Template 3 automatically, exactly as Template 2 does.
///
/// Four things are done, in the order the requirements were given:
///
///   1. LINES OFF.   Every border on every control is removed. Borders in these
///                   reports are set per-control by the designer, so they have to be
///                   cleared per-control; StylePriority.UseBorders is also forced true
///                   so the control's own (empty) value wins over any inherited style.
///
///   2. PADDING OUT. The padding in Template 1 exists to hold text off the cell
///                   borders. With the borders gone it is dead space, and dead space
///                   is what pushes a transcript onto a second page. A single point is
///                   kept left and right — with no line between two columns, glyphs
///                   from adjacent cells would otherwise touch and read as one word.
///
///   3. SMALLER.     Every font is scaled by one factor rather than being reset to a
///                   fixed size, so the designed hierarchy survives: a heading that
///                   was larger than body text stays larger. A floor stops the scale
///                   producing something unreadable.
///
///   4. ALL CAPS.    Applied at BeforePrint rather than by rewriting Text, because
///                   most of the text on a transcript arrives from a data binding and
///                   does not exist until the band prints. BeforePrint is the first
///                   moment the resolved value can be read and changed.
///
/// Band heights are scaled with the fonts. A band whose height is left at the original
/// value while its text shrinks just turns the saved space into white space.
/// </summary>
public static class TranscriptCompactStyle
{
    /// <summary>
    /// Font scale. 0.78 takes Template 1's 8.5pt body text to 6.6pt — small, still
    /// comfortably legible in print, and enough to buy roughly a quarter of the page
    /// back in vertical space once the padding goes with it.
    /// </summary>
    public const float FontScale = 0.78F;

    /// <summary>Nothing is ever scaled below this; past about 5.5pt a laser printer
    /// starts losing thin strokes and the document stops being a legal record.</summary>
    public const float MinFontSize = 5.5F;

    /// <summary>Left/right padding kept so adjacent borderless columns do not touch.</summary>
    private const int SideGap = 1;

    /// <summary>
    /// Body size for the semester result tables, in points — set outright rather than
    /// scaled, because this is the one measurement the whole page turns on.
    ///
    /// v16.1 has NO line-spacing property on XRLabel (checked against the assembly, not
    /// assumed). A row's height is therefore max(table height, the font's own line box),
    /// and once the table height is below the line box only the FONT moves the row. So
    /// "reduce the line height" and "reduce the body font" are the same instruction here.
    ///
    /// 5.8pt was chosen by measuring 1,939 real course names: it takes the line box from
    /// 10.6 to 9.8 units, about 7% off every row, while still printing cleanly. Below
    /// about 5.5pt a laser printer starts dropping thin strokes.
    /// </summary>
    public const float ResultFontSize = 5.8F;

    /// <summary>Calibri's line box as a multiple of point size — the number that turns a
    /// font size into the height a row will actually occupy.</summary>
    private const float LineBox = 1.22F;

    /// <summary>
    /// Column proportions for the result tables, replacing Template 1's
    /// 1.20 / 3.31 / 0.65 / 0.75. Only the ratios matter, so the same four numbers give
    /// the same proportions in both the left column (373u) and the right (360u).
    ///
    /// Sized from the data, not from taste. Across every transcript row on file the
    /// longest course code is 10 characters (one row; 9 characters covers all but that
    /// one, 8 covers 48,721 of them), a grade is never wider than "D+", and the widest
    /// credit-unit value is 3 digits. Those three columns were between two and three
    /// times wider than their worst real content, and the course name — which is the
    /// only column that ever needs to wrap — was starved.
    ///
    /// Measured effect over 1,939 real course names: names that wrap to a second line
    /// fall from 5.7% to 0.5%. A wrapped row costs a whole extra line, so this alone is
    /// worth more than the font reduction.
    /// </summary>
    public const double WeightCode   = 0.75D;
    public const double WeightCourse = 4.38D;
    public const double WeightCu     = 0.30D;
    public const double WeightGrade  = 0.48D;

    // ─────────────────────────────────────────────────────────────────────────
    // entry points
    // ─────────────────────────────────────────────────────────────────────────

    /// <summary>
    /// Restyles an entire report: borders, padding, fonts, band heights, and the
    /// uppercase hook. Safe to call on any XtraReport; unknown controls are left alone.
    /// </summary>
    public static void Apply(XtraReport report)
    {
        if (report == null) return;

        try { ScaleFont(report); } catch { }

        foreach (Band band in Bands(report))
        {
            try { Strip(band); } catch { }

            // Controls FIRST — fonts and label heights have to come down before a band
            // can be told how much room its contents really need.
            try { Walk(band); } catch { }

            // Then pack the band down onto its contents.
            //
            // An earlier version scaled every band by a flat factor, which was wrong in
            // both directions: it left slack in a loose band and, worse, it shrank a
            // PACKED one below what it holds. GroupHeader2 in the result columns carries
            // the semester title AND the column-header row and needs 24.1 units; a flat
            // 0.82 gave it 20.5, which is a clipped or silently re-grown band. Measuring
            // the contents cannot make that mistake.
            try
            {
                if (band is TopMarginBand || band is BottomMarginBand) continue;
                float need = ContentBottom(band);
                if (need > 0F && need + 1F < band.HeightF) band.HeightF = need + 1F;
            }
            catch { }
        }
    }

    /// <summary>
    /// Packs every band down onto its contents, without touching anything else.
    ///
    /// Apply already does this, but it does it while the tables are still at their
    /// designed heights. A caller that re-sizes controls afterwards — as the result
    /// columns do — has to ask for the packing again, or the space it just freed stays
    /// as white space inside a band nobody shrank.
    /// </summary>
    public static void RepackBands(XtraReport report)
    {
        if (report == null) return;
        foreach (Band band in Bands(report))
        {
            try
            {
                if (band is TopMarginBand || band is BottomMarginBand) continue;
                float need = ContentBottom(band);
                if (need > 0F && need + 1F < band.HeightF) band.HeightF = need + 1F;
            }
            catch { }
        }
    }

    /// <summary>Lowest edge of anything inside this band, in report units.</summary>
    private static float ContentBottom(XRControl parent)
    {
        float bottom = 0F;
        foreach (XRControl c in Children(parent))
        {
            try
            {
                if (!c.Visible) continue;
                float b = c.TopF + c.HeightF;
                if (b > bottom) bottom = b;
            }
            catch { }
        }
        return bottom;
    }

    /// <summary>
    /// Tightens the page margins. Kept separate from Apply because only the outer
    /// report owns margins — a subreport's are ignored by the host.
    /// </summary>
    public static void TightenMargins(XtraReport report, int left, int right, int top, int bottom)
    {
        if (report == null) return;
        try { report.Margins = new Margins(left, right, top, bottom); } catch { }
    }

    /// <summary>The height one line of text occupies at a given point size, in report
    /// units (1/100 inch). This is the number that decides how tall a row will be.</summary>
    public static float LineHeight(float pointSize)
    {
        return pointSize / 72F * 100F * LineBox;
    }

    /// <summary>
    /// Re-proportions a result column and sets its body size.
    ///
    /// Called by the column subclasses AFTER Apply, because it overrides the general
    /// font scaling with the one size the page is actually planned around, and because
    /// the header row and the data row must be given identical weights or the two rows
    /// stop lining up — which is the one failure here that looks like a rendering bug
    /// rather than a styling choice.
    ///
    /// Control names come from Template 1's designer code: cells 1/2/4/5 are
    /// CODE / COURSE / CU / GRADE in both columns.
    /// </summary>
    public static void CompactResultColumn(XtraReport column)
    {
        if (column == null) return;

        Weigh(column, "xrTableCell1", WeightCode);
        Weigh(column, "xrTableCell2", WeightCourse);
        Weigh(column, "xrTableCell4", WeightCu);
        Weigh(column, "xrTableCell5", WeightGrade);

        Weigh(column, "xrHdrCell1", WeightCode);
        Weigh(column, "xrHdrCell2", WeightCourse);
        Weigh(column, "xrHdrCell4", WeightCu);
        Weigh(column, "xrHdrCell5", WeightGrade);

        // The body size, applied to the cells and to the two tables that own them.
        foreach (string n in new string[] { "xrTableCell1", "xrTableCell2", "xrTableCell4", "xrTableCell5",
                                            "xrHdrCell1", "xrHdrCell2", "xrHdrCell4", "xrHdrCell5",
                                            "xrTable1", "xrTableColHeaders" })
            SetSize(column, n, ResultFontSize);

        // Row heights down to exactly one line at that size. Anything taller is padding
        // the engine would honour; anything shorter it ignores, because the text wins.
        float line = LineHeight(ResultFontSize);
        SetHeight(column, "xrTable1", line);
        SetHeight(column, "xrTableRow1", line);
        SetHeight(column, "xrTableColHeaders", line);
        SetHeight(column, "xrTableRowHeader", line);

        // The semester title bar and the GPA/CGPA bar are single-line labels sitting in
        // bands with a lot of slack. Apply's band packing reclaims that slack once these
        // are down to one line.
        SetSize(column, "xrLabel1", ResultFontSize + 0.4F);   // title, a shade larger
        SetSize(column, "xrLabel3", ResultFontSize + 0.4F);   // GPA / CGPA
        SetHeight(column, "xrLabel1", LineHeight(ResultFontSize + 0.4F));
        SetHeight(column, "xrLabel3", LineHeight(ResultFontSize + 0.4F));

        // The column-header row sits below the title; move it up to meet it.
        XRControl title = Find(column, "xrLabel1");
        XRControl hdr = Find(column, "xrTableColHeaders");
        if (title != null && hdr != null)
        {
            try { hdr.LocationFloat = new DevExpress.Utils.PointFloat(hdr.LeftF, title.TopF + title.HeightF + 0.5F); }
            catch { }
        }
    }

    private static XRControl Find(XtraReport r, string name)
    {
        try { return r.FindControl(name, true) as XRControl; } catch { return null; }
    }

    private static void Weigh(XtraReport r, string name, double weight)
    {
        XRTableCell c = Find(r, name) as XRTableCell;
        if (c != null) { try { c.Weight = weight; } catch { } }
    }

    private static void SetSize(XtraReport r, string name, float pt)
    {
        XRControl c = Find(r, name);
        if (c == null || c.Font == null) return;
        try
        {
            c.Font = new Font(c.Font.FontFamily, pt, c.Font.Style);   // keeps bold on the headers
            c.StylePriority.UseFont = true;
        }
        catch { }
    }

    private static void SetHeight(XtraReport r, string name, float h)
    {
        XRControl c = Find(r, name);
        if (c != null) { try { c.HeightF = h; } catch { } }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // the walk
    // ─────────────────────────────────────────────────────────────────────────

    private static System.Collections.Generic.List<Band> Bands(XtraReport report)
    {
        var list = new System.Collections.Generic.List<Band>();
        try { foreach (Band b in report.Bands) if (b != null) list.Add(b); } catch { }
        return list;
    }

    /// <summary>Depth-first over every control, restyling as it goes.</summary>
    private static void Walk(XRControl parent)
    {
        if (parent == null) return;
        foreach (XRControl child in Children(parent))
        {
            try
            {
                float before = child.Font != null ? child.Font.Size : 0F;
                Strip(child);
                float after = child.Font != null ? child.Font.Size : 0F;

                // A table's rows are driven by their own height as well as the text, so
                // bring them down to what the new font needs.
                if (child is XRTable || child is XRTableRow)
                    child.HeightF = Math.Min(child.HeightF, LineHeight(after));

                // Single-line labels keep their designed height when their font shrinks,
                // which turns the saving straight back into white space. Shrink those to
                // one line at the new size — but ONLY those: a label tall enough to hold
                // two or more lines at its ORIGINAL size may well be wrapping (the
                // letterhead address does), and shortening it would clip real text.
                if (child is XRLabel && !(child is XRTableCell) && before > 0F && after < before)
                {
                    float originalLine = LineHeight(before);
                    if (child.HeightF < originalLine * 1.8F)
                        child.HeightF = Math.Min(child.HeightF, LineHeight(after));
                }

                // Long course names must still be allowed to use the space they need.
                // Shrinking the font without this would clip rather than fit.
                XRTableCell cell = child as XRTableCell;
                if (cell != null) { cell.CanGrow = true; cell.WordWrap = true; }

                HookUppercase(child);
            }
            catch { }

            try { Walk(child); } catch { }
        }
    }

    private static System.Collections.Generic.List<XRControl> Children(XRControl parent)
    {
        var list = new System.Collections.Generic.List<XRControl>();
        try { foreach (XRControl c in parent.Controls) if (c != null) list.Add(c); } catch { }
        return list;
    }

    /// <summary>Borders off, padding out, font down — on one control.</summary>
    private static void Strip(XRControl ctl)
    {
        if (ctl == null) return;

        try
        {
            ctl.Borders = BorderSide.None;
            ctl.BorderWidth = 0;
            // Force the control's own value to win. The designer sets several of these
            // to false, which hands the decision back to the inherited style and would
            // quietly put the lines back.
            ctl.StylePriority.UseBorders = true;
            ctl.StylePriority.UseBorderWidth = true;
        }
        catch { }

        try
        {
            ctl.Padding = new PaddingInfo(SideGap, SideGap, 0, 0, 100F);
            ctl.StylePriority.UsePadding = true;
        }
        catch { }

        try { ScaleFont(ctl); } catch { }
    }

    /// <summary>
    /// Scaled size, floored — but never LARGER than what it already was.
    ///
    /// The naive Max(floor, size * scale) quietly enlarges anything already below the
    /// floor. Template 1 has a 5pt label in its letterhead, and that form of the
    /// expression grew it to 5.5pt: a "make everything smaller" pass that made
    /// something bigger. Anything already at or under the floor is left exactly alone.
    /// </summary>
    private static float Scaled(float size)
    {
        if (size <= MinFontSize) return size;
        return Math.Max(MinFontSize, size * FontScale);
    }

    private static void ScaleFont(XRControl ctl)
    {
        Font f = ctl.Font;
        if (f == null) return;
        float size = Scaled(f.Size);
        if (size == f.Size) return;                 // nothing to do; do not churn the object
        ctl.Font = new Font(f.FontFamily, size, f.Style);
        try { ctl.StylePriority.UseFont = true; } catch { }
    }

    private static void ScaleFont(XtraReport report)
    {
        Font f = report.Font;
        if (f == null) return;
        float size = Scaled(f.Size);
        if (size == f.Size) return;
        report.Font = new Font(f.FontFamily, size, f.Style);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ALL CAPS
    // ─────────────────────────────────────────────────────────────────────────

    /// <summary>
    /// Uppercases a control's text at print time.
    ///
    /// Only text-bearing controls are hooked (XRLabel, and XRTableCell which derives
    /// from it) — a picture box or a line has no text and hooking them would be noise.
    ///
    /// XRControl.BeforePrint is a System.Drawing.Printing.PrintEventHandler taking
    /// (object, PrintEventArgs). That is not a guess: AfterPrint on the same class is a
    /// plain EventHandler, and wiring the wrong one is a compile error that takes down
    /// every page in the application, because App_Code builds as a single assembly.
    /// </summary>
    private static void HookUppercase(XRControl ctl)
    {
        if (!(ctl is XRLabel)) return;
        ctl.BeforePrint += UppercaseHandler;
    }

    private static void UppercaseHandler(object sender, PrintEventArgs e)
    {
        try
        {
            XRControl ctl = sender as XRControl;
            if (ctl == null) return;
            string t = ctl.Text;
            if (string.IsNullOrEmpty(t)) return;
            string up = t.ToUpperInvariant();
            if (up != t) ctl.Text = up;
        }
        catch { /* never let cosmetics break a document */ }
    }
}
