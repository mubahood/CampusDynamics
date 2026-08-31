using System;
using DevExpress.XtraReports.UI;

/// <summary>
/// Template 3 body, right column — <see cref="FinalTranscriptCol2"/> with the compact
/// styling applied. The mirror of <see cref="FinalTranscriptCompactCol1"/>; see that
/// file for why this is a subclass rather than a copy.
/// </summary>
public class FinalTranscriptCompactCol2 : FinalTranscriptCol2
{
    public FinalTranscriptCompactCol2()
    {
        try { TranscriptCompactStyle.Apply(this); }
        catch { }
        try { TranscriptCompactStyle.CompactResultColumn(this); }
        catch { }
        try { TranscriptCompactStyle.RepackBands(this); }
        catch { }
    }
}
