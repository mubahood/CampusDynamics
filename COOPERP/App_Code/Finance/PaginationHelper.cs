using System;
using System.Text;

/// <summary>
/// Shared pagination helper for finance module pages.
/// Eliminates duplicated BuildPagerHtml() methods across controllers.
///
/// Extracted from GeneralLedger.aspx.cs (L183-222).
/// Used by: GeneralLedger, JournalEntries, PaymentVouchers, FinanceAuditTrail 
/// </summary>
public static class PaginationHelper
{
    /// <summary>
    /// Default page size options for dropdowns.
    /// </summary>
    public static readonly int[] StandardPageSizes = { 25, 50, 100, 250, 500 };

    /// <summary>Default page size if not specified.</summary>
    public const int DefaultPageSize = 50;

    // ───────────────────────── Pager HTML ─────────────────────────────────

    /// <summary>
    /// Builds the pagination button bar HTML.
    /// Renders: &laquo; Prev [1] [2] ... [n] Next &raquo;
    /// 
    /// Uses "goPage(n)" JS function which must be defined on the page to
    /// set hfPageIndex.value and trigger postback. This matches the existing
    /// GeneralLedger pattern.
    /// 
    /// <param name="pageIndex">Current 0-based page index.</param>
    /// <param name="totalPages">Total number of pages.</param>
    /// <param name="windowSize">Number of page buttons to show around current page (default 3).</param>
    /// <param name="cssPrefix">CSS class prefix for buttons (default "ft-pager").</param>
    /// <param name="goPageFn">JavaScript function name for navigation (default "goPage").</param>
    /// </summary>
    public static string BuildPagerHtml(
        int pageIndex, int totalPages,
        int windowSize = 3,
        string cssPrefix = "ft-pager",
        string goPageFn = "goPage")
    {
        if (totalPages <= 1) return "";

        var sb = new StringBuilder();
        sb.AppendFormat("<div class=\"{0}__btns\">", cssPrefix);

        bool isFirst = (pageIndex == 0);
        bool isLast = (pageIndex >= totalPages - 1);

        // First & Prev
        sb.AppendFormat(
            "<button type=\"button\" class=\"{0}__btn\" onclick=\"{1}(0)\" {2}>&laquo;</button>",
            cssPrefix, goPageFn, isFirst ? "disabled" : "");
        sb.AppendFormat(
            "<button type=\"button\" class=\"{0}__btn\" onclick=\"{1}({2})\" {3}>&lsaquo; Prev</button>",
            cssPrefix, goPageFn, pageIndex - 1, isFirst ? "disabled" : "");

        // Page number buttons with ellipsis
        int startP = Math.Max(0, pageIndex - windowSize);
        int endP = Math.Min(totalPages - 1, pageIndex + windowSize);

        if (startP > 0)
            sb.AppendFormat("<span class=\"{0}__ellipsis\">&hellip;</span>", cssPrefix);

        for (int i = startP; i <= endP; i++)
        {
            bool active = (i == pageIndex);
            sb.AppendFormat(
                "<button type=\"button\" class=\"{0}__btn{1}\" onclick=\"{2}({3})\">{4}</button>",
                cssPrefix,
                active ? " " + cssPrefix + "__btn--active" : "",
                goPageFn, i, i + 1);
        }

        if (endP < totalPages - 1)
            sb.AppendFormat("<span class=\"{0}__ellipsis\">&hellip;</span>", cssPrefix);

        // Next & Last
        sb.AppendFormat(
            "<button type=\"button\" class=\"{0}__btn\" onclick=\"{1}({2})\" {3}>Next &rsaquo;</button>",
            cssPrefix, goPageFn, pageIndex + 1, isLast ? "disabled" : "");
        sb.AppendFormat(
            "<button type=\"button\" class=\"{0}__btn\" onclick=\"{1}({2})\" {3}>&raquo;</button>",
            cssPrefix, goPageFn, totalPages - 1, isLast ? "disabled" : "");

        sb.Append("</div>");
        return sb.ToString();
    }

    // ───────────────────────── Footer Text ────────────────────────────────

    /// <summary>
    /// Builds the "Showing X-Y of Z entries (N per page)" footer text.
    /// </summary>
    public static string BuildFooterHtml(long totalRows, int pageIndex, int pageSize)
    {
        long showFrom = totalRows > 0 ? (long)(pageIndex * pageSize) + 1 : 0;
        long showTo = Math.Min((long)((pageIndex + 1) * pageSize), totalRows);

        return string.Format(
            "Showing <strong>{0}-{1}</strong> of <strong>{2}</strong> entries ({3} per page)",
            showFrom, showTo, totalRows.ToString("N0"), pageSize);
    }

    // ───────────────────────── Page Index Helpers ─────────────────────────

    /// <summary>
    /// Safely extracts the current page index from a hidden field value.
    /// Returns 0 if invalid or null.
    /// </summary>
    public static int ParsePageIndex(string hiddenFieldValue)
    {
        int index;
        if (!int.TryParse(hiddenFieldValue, out index) || index < 0)
            return 0;
        return index;
    }

    /// <summary>
    /// Safely parses and validates a page size value.
    /// Returns the default if invalid.
    /// </summary>
    public static int ParsePageSize(string selectedValue, int defaultSize = DefaultPageSize)
    {
        int size;
        if (!int.TryParse(selectedValue, out size) || size <= 0)
            return defaultSize;

        // Clamp to reasonable range
        if (size > 1000) size = 1000;
        return size;
    }

    /// <summary>
    /// Clamps the page index to valid range given total pages.
    /// </summary>
    public static int ClampPageIndex(int pageIndex, int totalPages)
    {
        if (totalPages <= 0) return 0;
        if (pageIndex >= totalPages) return totalPages - 1;
        if (pageIndex < 0) return 0;
        return pageIndex;
    }

    /// <summary>
    /// Computes the OFFSET value for SQL LIMIT clauses.
    /// </summary>
    public static int GetOffset(int pageIndex, int pageSize)
    {
        return pageIndex * pageSize;
    }
}
