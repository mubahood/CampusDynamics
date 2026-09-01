using System;
using DevExpress.XtraReports.UI;

/// <summary>
/// Template 3 — the compact, single-page academic transcript.
///
/// It IS <see cref="FinalTranscript"/> (Template 1): same letterhead, student bio,
/// photo, QR verification, award and classification block, thesis and supervisor
/// section, the same two-column semester grid fed by the same stored procedures. All of
/// it is inherited, so Template 1 is not touched and Template 3 cannot drift away from
/// it.
///
/// Template 1's grid is kept rather than Template 2's vertical list, and that is the
/// single most important decision in this file. Two columns side by side consume half
/// the vertical space of the same semesters listed one after another, and vertical
/// space is the entire problem when the requirement is one page.
///
/// WHAT CHANGES, and why each one earns its place on the page:
///
///   Lines hidden.   Every border, everywhere.
///   Padding gone.   It only existed to hold text away from those borders.
///   Small type.     Every font scaled by one factor so the hierarchy survives.
///   ALL CAPITALS.   Applied at print time, so data-bound text is caught too.
///   Tight margins.  27pt left and right down to 14; the letterhead is centred on the
///                   page width, so trimming both sides equally leaves it centred.
///
/// AND ONE PAGE, which needs more than shrinking:
///
///   Template 1 deliberately forces the key-to-grades onto a page of its own
///   (GroupFooter1.PageBreak = AfterBand) and carries a running identity header plus a
///   "Page X of Y" counter for the continuation pages. On a document defined by fitting
///   on one page, a guaranteed second page is a contradiction, and a page counter has
///   nothing to count. Both are removed here. Templates 1 and 2 keep theirs.
///
/// The key-to-grades page being dropped is a real content difference, not a cosmetic
/// one — it is the only thing Template 3 does not carry over — so it is called out
/// here, in the document-type dropdown, and in the commit message rather than left to
/// be discovered.
/// </summary>
public class FinalTranscriptCompact : FinalTranscript
{
    /// <summary>
    /// Page margins in report units (100 dpi). Template 1 uses 27/27/3/0; the sides
    /// come in to 14, which is about 3.5mm — still inside the non-printable edge of
    /// every common office laser printer, so nothing is clipped.
    /// </summary>
    private const int SideMargin = 14;

    public FinalTranscriptCompact()
    {
        // base() has already built the whole Template 1 report.

        // 1. The two result columns, restyled. Done by swapping in the compact
        //    subclasses rather than restyling the originals in place, because
        //    XRSubreport.ReportSource instances are per-report and reaching into the
        //    base class's own instances would restyle Template 1 for this process too.
        try
        {
            XRSubreport left = FindControl("xrSubreport1", true) as XRSubreport;
            if (left != null) left.ReportSource = new FinalTranscriptCompactCol1();

            XRSubreport right = FindControl("xrSubreport2", true) as XRSubreport;
            if (right != null) right.ReportSource = new FinalTranscriptCompactCol2();

            // Spread the two columns across the whole printable width.
            //
            // Template 1 puts them at x=3 and x=390, each 383 wide, ending at 773 — sized
            // for its 27-unit side margins. Template 3 trimmed those to 14, so 799 units
            // are printable and 26 of them were doing nothing. Widening the columns is
            // what pays for the larger type: the limit on this template has always been
            // horizontal, never vertical.
            float w = TranscriptCompactStyle.ColumnOuterWidth;
            float g = TranscriptCompactStyle.ColumnGutter;
            if (left != null)
            {
                left.LocationFloat = new DevExpress.Utils.PointFloat(0F, left.TopF);
                left.SizeF = new System.Drawing.SizeF(w, left.SizeF.Height);
            }
            if (right != null)
            {
                right.LocationFloat = new DevExpress.Utils.PointFloat(w + g, right.TopF);
                right.SizeF = new System.Drawing.SizeF(w, right.SizeF.Height);
            }
        }
        catch { }

        // 2. Everything on the outer report — letterhead, bio, award block, footer:
        //    borders off, padding out, fonts down, band heights in, uppercase hooked.
        try { TranscriptCompactStyle.Apply(this); }
        catch { }

        // 3. Margins. After Apply, so it cannot be undone by the band pass.
        try { TranscriptCompactStyle.TightenMargins(this, SideMargin, SideMargin, 3, 0); }
        catch { }

        // 4. Everything that exists only to serve a multi-page document.
        try { MakeSinglePage(); }
        catch { }

        // 5. Close the gap under the VERIFICATION caption.
        try { TightenVerificationBlock(); }
        catch { }
    }

    /// <summary>
    /// Pulls the QR code up under its caption.
    ///
    /// The caption (xrLabel37, "VERIFICATION") is a 12.14-unit box holding one line of
    /// 6pt text, and the QR sits at a FIXED y of 149.5 below it. Shrinking the caption's
    /// font — as the compact pass does — empties the bottom of that box but moves
    /// nothing, because every position in this report is absolute. The result is the
    /// caption floating well above the code with a band of nothing between them.
    ///
    /// So the caption is shrunk to the one line it holds and the QR is moved up to meet
    /// it. The QR's own size is deliberately NOT touched: it is a scannable artefact
    /// with an error-correction level and a fixed module count, and resizing it is how a
    /// verification code stops scanning.
    /// </summary>
    private void TightenVerificationBlock()
    {
        XRControl caption = FindControl("xrLabel37", true) as XRControl;
        XRControl qr = FindControl("xrBarCode2", true) as XRControl;
        if (caption == null || qr == null) return;

        // The caption is TopCenter aligned, so every unit of slack in its box shows as a
        // gap UNDERNEATH the word — between the caption and the code. That is the gap
        // being complained about, and centring the text in the box halves it before the
        // box is even shrunk. Costs nothing and cannot clip.
        try
        {
            caption.TextAlignment = DevExpress.XtraPrinting.TextAlignment.MiddleCenter;
            caption.StylePriority.UseTextAlignment = true;
        }
        catch { }

        // One line at the caption's (already reduced) size, plus a hair.
        float line = caption.Font != null
            ? TranscriptCompactStyle.LineHeight(caption.Font.Size) + 1F
            : caption.HeightF;
        if (line < caption.HeightF) caption.HeightF = line;

        // Sit the code directly under the caption. Guard against moving it DOWN: if the
        // caption were ever taller than the original gap, this must not push the QR into
        // the student's details below it.
        float y = caption.TopF + caption.HeightF + 1F;
        if (y < qr.TopF)
            qr.LocationFloat = new DevExpress.Utils.PointFloat(qr.LeftF, y);
    }

    /// <summary>
    /// Removes the two things that would put a second page on the paper regardless of
    /// how small the type is.
    /// </summary>
    private void MakeSinglePage()
    {
        // The key-to-grades subreport, and the page break that exists solely to give it
        // a page. Clearing ReportSource as well as hiding it matters: a hidden subreport
        // with a source still runs its query.
        try
        {
            XRSubreport key = FindControl("xrSubreport3", true) as XRSubreport;
            if (key != null) { key.ReportSource = null; key.Visible = false; }
        }
        catch { }

        foreach (Band band in AllBands())
        {
            try
            {
                // GroupHeader1 keeps its BeforeBand break — that is what starts each
                // student on a fresh page in a batch, which is still correct here.
                if (band is GroupHeaderBand) continue;

                if (band.PageBreak != PageBreak.None)
                    band.PageBreak = PageBreak.None;

                // GroupFooter2 exists only to carry the key-to-grades.
                if (band is GroupFooterBand && band.Name == "GroupFooter2")
                {
                    band.Visible = false;
                    band.HeightF = 0F;
                }

                // The running identity strip and page counter are for continuation
                // pages, of which there are now none.
                if (band is PageHeaderBand)
                {
                    band.Visible = false;
                    band.HeightF = 0F;
                }
            }
            catch { }
        }

        // The first-page copy of the page counter sits in the letterhead, not the page
        // header band, so it has to be hidden by name.
        Hide("pgInfoHead");
        Hide("pgInfoRun");
        Hide("lblRunIdentity");
        Hide("lineRunIdentity");
    }

    /// <summary>
    /// Snapshot of the report's bands. Deliberately NOT called Bands() — that is an
    /// inherited property on XtraReportBase, and shadowing it compiles to something
    /// that reads like a collection but is a method group.
    /// </summary>
    private System.Collections.Generic.List<Band> AllBands()
    {
        var list = new System.Collections.Generic.List<Band>();
        try { foreach (Band b in this.Bands) if (b != null) list.Add(b); } catch { }
        return list;
    }

    private void Hide(string name)
    {
        try
        {
            XRControl c = FindControl(name, true) as XRControl;
            if (c != null) c.Visible = false;
        }
        catch { }
    }
}
