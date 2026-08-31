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

    /// <summary>Band heights shrink with the text, but not quite as fast: a row still
    /// needs a little more than its glyph height or descenders clip.</summary>
    public const float BandScale = 0.82F;

    /// <summary>Left/right padding kept so adjacent borderless columns do not touch.</summary>
    private const int SideGap = 1;

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
            try
            {
                // The margin bands carry no content; shrinking them only risks clipping.
                if (!(band is TopMarginBand) && !(band is BottomMarginBand))
                    band.HeightF = Math.Max(0F, band.HeightF * BandScale);
                Strip(band);
            }
            catch { }
            try { Walk(band); } catch { }
        }
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
                Strip(child);

                // A table's own height drives its rows; scale it with everything else.
                if (child is XRTable || child is XRTableRow)
                    child.HeightF = Math.Max(0F, child.HeightF * BandScale);

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
