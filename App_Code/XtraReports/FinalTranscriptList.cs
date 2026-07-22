using System;
using System.Drawing;
using DevExpress.XtraReports.UI;

/// <summary>
/// Template 2 — the "list format" academic transcript.
///
/// It is IDENTICAL to <see cref="FinalTranscript"/> (Template 1) in every respect —
/// same letterhead, student bio, photo, QR verification, award/classification block,
/// thesis/supervisor section, key-to-grades footer, running per-page identity header
/// and "Page X of Y" counter — because it inherits all of it.
///
/// The ONLY difference: Template 1 renders semester results as two side-by-side
/// half-width columns (subreports FinalTranscriptCol1 on the left, FinalTranscriptCol2
/// on the right). Template 2 replaces those with a SINGLE full-width vertical list
/// (<see cref="FinalTranscriptListCol"/>) that presents every semester one after
/// another in chronological order.
///
/// Implemented as a subclass so Template 1 is left completely untouched and Template 2
/// automatically stays in lock-step with any future change to the shared letterhead.
/// </summary>
public class FinalTranscriptList : FinalTranscript
{
    public FinalTranscriptList()
    {
        // base() has already built the full Template 1 layout, including the two
        // half-width result subreports inside GroupHeader1. Convert that into a single
        // full-width list body here.
        try
        {
            XRSubreport leftColumn  = FindControl("xrSubreport1", true) as XRSubreport;
            XRSubreport rightColumn = FindControl("xrSubreport2", true) as XRSubreport;

            // Drop the right-hand column entirely (no source => no query, no output).
            if (rightColumn != null)
            {
                rightColumn.ReportSource = null;
                rightColumn.Visible = false;
            }

            // Turn the left column into the full-width chronological list.
            if (leftColumn != null)
            {
                leftColumn.ReportSource = new FinalTranscriptListCol();
                leftColumn.SizeF = new SizeF(760F, leftColumn.SizeF.Height);
                // Its "reg" parameter binding (=> acad_GetBatchStudentTranscriptData.regno)
                // is inherited from the base layout and still applies.
            }
        }
        catch { }
    }
}
