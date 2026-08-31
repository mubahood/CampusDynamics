using System;
using DevExpress.XtraReports.UI;

/// <summary>
/// Template 3 body, left column — <see cref="FinalTranscriptCol1"/> with the compact
/// styling applied.
///
/// Everything comes from the base class: the same stored procedure, the same grouping
/// by study year and semester, the same column headers, the same bindings, the same
/// GPA/CGPA summary bar. Only the presentation changes, and it changes through
/// <see cref="TranscriptCompactStyle"/> rather than by re-declaring any of it here —
/// so a future correction to the Template 1 column body reaches Template 3 by itself.
/// </summary>
public class FinalTranscriptCompactCol1 : FinalTranscriptCol1
{
    public FinalTranscriptCompactCol1()
    {
        // base() has already built the full Template 1 half-width column.
        try { TranscriptCompactStyle.Apply(this); }
        catch { }

        // Then the result-table specifics: column proportions and the body size the
        // page is planned around. After Apply, because it overrides the general scale.
        try { TranscriptCompactStyle.CompactResultColumn(this); }
        catch { }

        // Apply packed the bands before the tables were re-sized, so pack again now
        // that the rows and the title bar know their final heights.
        try { TranscriptCompactStyle.RepackBands(this); }
        catch { }
    }
}
