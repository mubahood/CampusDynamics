using System;
using System.Drawing;
using DevExpress.XtraReports.UI;
using DevExpress.DataAccess.Sql;

/// <summary>
/// Template 2 transcript body — the "list format" counterpart of
/// <see cref="FinalTranscriptCol1"/>.
///
/// It reuses FinalTranscriptCol1's exact layout, styling, grouping (by
/// studyyear + semester), column headers and data bindings by inheriting from it,
/// then makes only two changes in the constructor:
///   1. Repoints the backing query to <c>acad_GetSingleStudentTranscript_All</c>,
///      which returns EVERY semester in chronological order (instead of the fixed
///      left-column subset), so all semesters render as one continuous vertical list.
///   2. Widens the page and every result control from the half-page (A5, 383pt)
///      column width to full page width, since it is no longer sharing the row with
///      a second column.
///
/// The query's logical Name — and therefore the report DataMember and every field
/// binding ("...Col1.courseid", etc.) — is left unchanged; only the stored procedure
/// the query points at changes. Because _All returns the identical column set, all
/// inherited bindings resolve exactly as before.
/// </summary>
public class FinalTranscriptListCol : FinalTranscriptCol1
{
    // Full content width (mirrors _Col1's page-minus-10 proportion: 766 - 10).
    private const float FullWidth = 756F;

    public FinalTranscriptListCol()
    {
        // base() has already run FinalTranscriptCol1.InitializeComponent(), building the
        // half-width two-column layout. Adjust it into a full-width single list here.
        try
        {
            RepointQueryToAllSemesters();
        }
        catch { }

        try
        {
            this.PageWidth = 766;
            WidenControl("xrTable1", FullWidth);          // course data row template
            WidenControl("xrTableColHeaders", FullWidth); // CODE / COURSE / CU / GRADE header row
            WidenControl("xrLabel1", FullWidth);          // semester title bar
            WidenControl("xrLabel3", FullWidth);          // per-semester GPA/CGPA summary bar
        }
        catch { }
    }

    private void RepointQueryToAllSemesters()
    {
        SqlDataSource sds = this.DataSource as SqlDataSource;
        if (sds == null || sds.Queries.Count == 0)
            return;

        StoredProcQuery query = sds.Queries[0] as StoredProcQuery;
        if (query != null)
            query.StoredProcName = "campus_dynamics.acad_GetSingleStudentTranscript_All";
    }

    private void WidenControl(string name, float width)
    {
        XRControl control = FindControl(name, true) as XRControl;
        if (control != null)
            control.SizeF = new SizeF(width, control.SizeF.Height);
    }
}
