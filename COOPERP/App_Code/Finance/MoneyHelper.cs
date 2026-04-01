using System;

/// <summary>
/// Decimal-based currency helpers for the Finance module.
/// Replaces all uses of "double" for money across finance controllers.
///
/// All operations use 'decimal' to avoid floating-point precision errors.
/// The system currency is UGX (Ugandan Shilling) — no decimal places in display.
///
/// Fixes issues in:
///   - JournalEntries.aspx.cs (double at L237-238)
///   - PaymentVouchers.aspx.cs (double at L121)
///   - ContraVouchers.aspx.cs (double at L86)
///   - FinanceDashboard.aspx.cs (GetDouble for totals)
/// </summary>
public static class MoneyHelper
{
    /// <summary>Default currency code for the system.</summary>
    public const string DefaultCurrency = "UGX";

    // ───────────────────────── Formatting ─────────────────────────────────

    /// <summary>
    /// Formats a decimal value as "UGX 1,234,567".
    /// No decimal places — UGX is a zero-decimal currency.
    /// </summary>
    public static string FormatUGX(decimal value)
    {
        return string.Format("UGX {0:N0}", value);
    }

    /// <summary>
    /// Formats a decimal value with the currency prefix.
    /// Uses N0 formatting (no decimals) for UGX, N2 for others.
    /// </summary>
    public static string Format(decimal value, string currency = null)
    {
        string cur = string.IsNullOrEmpty(currency) ? DefaultCurrency : currency;
        string fmt = string.Equals(cur, "UGX", StringComparison.OrdinalIgnoreCase) ? "N0" : "N2";
        return string.Format("{0} {1}", cur, value.ToString(fmt));
    }

    /// <summary>
    /// Formats as plain number without currency prefix. "1,234,567"
    /// </summary>
    public static string FormatNumber(decimal value)
    {
        return value.ToString("N0");
    }

    /// <summary>
    /// Formats with 2 decimal places (for reports like Trial Balance/Balance Sheet).
    /// "1,234,567.00"
    /// </summary>
    public static string FormatN2(decimal value)
    {
        return value.ToString("N2");
    }

    // ───────────────────────── Parsing ─────────────────────────────────────

    /// <summary>
    /// Safely parses a string to decimal. Returns 0m on failure.
    /// Handles comma-separated values, currency prefixes, whitespace.
    /// 
    /// Replaces: double.TryParse(txtAmount.Text, out amount)
    /// </summary>
    public static decimal ParseMoney(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return 0m;

        // Strip common non-numeric characters
        string cleaned = text
            .Replace("UGX", "")
            .Replace("ugx", "")
            .Replace(",", "")
            .Replace(" ", "")
            .Trim();

        decimal result;
        return decimal.TryParse(cleaned, out result) ? result : 0m;
    }

    /// <summary>
    /// Parses a string to decimal, returning null if invalid or empty.
    /// Useful for nullable amount fields.
    /// </summary>
    public static decimal? ParseMoneyNullable(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return null;

        string cleaned = text
            .Replace("UGX", "")
            .Replace("ugx", "")
            .Replace(",", "")
            .Replace(" ", "")
            .Trim();

        decimal result;
        return decimal.TryParse(cleaned, out result) ? result : (decimal?)null;
    }

    // ───────────────────────── Conversion ──────────────────────────────────

    /// <summary>
    /// Safely converts an object (from DataRow or DbReader) to decimal.
    /// Handles DBNull, null, double, float, int, string values.
    /// 
    /// Replaces: Convert.ToDouble(row["transaction_amount"])
    /// </summary>
    public static decimal ToDecimal(object value)
    {
        if (value == null || value == DBNull.Value)
            return 0m;

        if (value is decimal)
            return (decimal)value;
        if (value is double)
            return (decimal)(double)value;
        if (value is float)
            return (decimal)(float)value;
        if (value is int)
            return (decimal)(int)value;
        if (value is long)
            return (decimal)(long)value;

        decimal result;
        return decimal.TryParse(value.ToString(), out result) ? result : 0m;
    }

    // ───────────────────────── Comparison ──────────────────────────────────

    /// <summary>
    /// Checks if two amounts balance (difference &lt; threshold).
    /// Default threshold is 0.01 (1 cent / 1 smallest unit).
    /// 
    /// Replaces: Math.Abs(totalDR - totalCR) &lt; 0.01
    /// </summary>
    public static bool IsBalanced(decimal debit, decimal credit, decimal threshold = 0.01m)
    {
        return Math.Abs(debit - credit) < threshold;
    }

    /// <summary>
    /// Returns the absolute difference between debit and credit totals.
    /// </summary>
    public static decimal Difference(decimal debit, decimal credit)
    {
        return Math.Abs(debit - credit);
    }

    /// <summary>
    /// Returns "Net DR" or "Net CR" label based on which side is larger.
    /// </summary>
    public static string NetLabel(decimal debit, decimal credit)
    {
        return debit >= credit ? "Net DR" : "Net CR";
    }
}
