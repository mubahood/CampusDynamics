using System;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// Centralised financial period logic. Provides:
///  - Open period detection
///  - Date-in-period validation  
///  - Default date range for reports/filters
///  - Period listing for dropdowns
///
/// Uses the fin_financial_years table:
///   id | finacial_Year (VARCHAR — note: column has legacy typo) | start_date | end_date | status ENUM('Open','Closed')
///
/// Current data (3 periods): 2023/2024 Closed, 2024/2025 Closed, 2025/2026 Open
/// </summary>
public static class FinancePeriod
{
    // ───────────────────────── Open Period Queries ────────────────────────

    /// <summary>
    /// Returns the currently open financial period, or null if none.
    /// If multiple periods are open (config error), returns the most recent.
    /// </summary>
    public static PeriodInfo GetOpenPeriod()
    {
        const string sql = @"SELECT id, finacial_Year, start_date, end_date, status 
                             FROM fin_financial_years 
                             WHERE status = 'Open' 
                             ORDER BY start_date DESC 
                             LIMIT 1";

        PeriodInfo info = null;
        FinanceDB.ExecuteReader(sql, reader =>
        {
            if (reader.Read())
            {
                info = new PeriodInfo
                {
                    Id = reader.GetInt32("id"),
                    Label = reader.GetString("finacial_Year"),
                    StartDate = reader.GetDateTime("start_date"),
                    EndDate = reader.GetDateTime("end_date"),
                    Status = reader.GetString("status")
                };
            }
        });

        return info;
    }

    /// <summary>
    /// Checks whether there is any open financial period that covers today's date.
    /// Replacement for the inline check in JournalEntries.cs.
    /// </summary>
    public static bool IsInOpenFinancialPeriod()
    {
        return IsDateInOpenPeriod(DateTime.Today);
    }

    /// <summary>
    /// Checks whether the given date falls within the currently open financial period.
    /// </summary>
    public static bool IsDateInOpenPeriod(DateTime date)
    {
        int count = FinanceDB.ExecuteScalar<int>(
            "SELECT COUNT(*) FROM fin_financial_years WHERE status = 'Open' AND @dt BETWEEN start_date AND end_date",
            FinanceDB.P("@dt", date));
        return count > 0;
    }

    // ───────────────────────── Default Date Range ─────────────────────────

    /// <summary>
    /// Returns the start/end dates of the open financial period for use as
    /// default filter values. Falls back to current calendar month if no
    /// open period exists.
    ///
    /// Usage in Page_Load:
    ///   var range = FinancePeriod.GetDefaultDateRange();
    ///   txtStartDate.Text = range.Item1.ToString("yyyy-MM-dd");
    ///   txtEndDate.Text   = range.Item2.ToString("yyyy-MM-dd");
    /// </summary>
    public static Tuple<DateTime, DateTime> GetDefaultDateRange()
    {
        var period = GetOpenPeriod();
        if (period != null)
        {
            // Clamp end date to today if period extends into the future
            DateTime effectiveEnd = period.EndDate > DateTime.Today ? DateTime.Today : period.EndDate;
            return Tuple.Create(period.StartDate, effectiveEnd);
        }

        // Fallback: current calendar month
        DateTime monthStart = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        return Tuple.Create(monthStart, DateTime.Today);
    }

    /// <summary>
    /// Returns a date range that goes back to the earliest transaction date
    /// (Jan 2000 as historical floor), suitable for balance sheet / cumulative reports.
    /// </summary>
    public static Tuple<DateTime, DateTime> GetCumulativeRange(DateTime asAtDate)
    {
        return Tuple.Create(GetEarliestPeriodStart(), asAtDate);
    }

    /// <summary>
    /// Parameterless cumulative range: from the earliest financial-period start
    /// (or a year-2000 historical floor if none) up to today. Used by the
    /// Balance Sheet for an as-at-date position report.
    /// </summary>
    public static Tuple<DateTime, DateTime> GetCumulativeRange()
    {
        return Tuple.Create(GetEarliestPeriodStart(), DateTime.Today);
    }

    /// <summary>
    /// Earliest financial-period start date, falling back to 2000-01-01 if the
    /// table is empty or unavailable. Never throws.
    /// </summary>
    private static DateTime GetEarliestPeriodStart()
    {
        DateTime floor = new DateTime(2000, 1, 1);
        try
        {
            DateTime earliest = FinanceDB.ExecuteScalar<DateTime>(
                "SELECT MIN(start_date) FROM fin_financial_years");
            return earliest.Year > 1900 ? earliest : floor;
        }
        catch
        {
            return floor;
        }
    }

    // ───────────────────────── Period Listing ─────────────────────────────

    /// <summary>
    /// Returns all financial periods ordered by start_date DESC for display in grids/dropdowns.
    /// </summary>
    public static DataTable GetAllPeriods()
    {
        return FinanceDB.ExecuteDataTable(
            "SELECT id, finacial_Year, start_date, end_date, status FROM fin_financial_years ORDER BY start_date DESC");
    }

    /// <summary>
    /// Returns the most recent N financial periods.
    /// </summary>
    public static DataTable GetRecentPeriods(int limit = 5)
    {
        return FinanceDB.ExecuteDataTable(
            "SELECT finacial_Year, start_date, end_date, status FROM fin_financial_years ORDER BY start_date DESC LIMIT @lim",
            FinanceDB.P("@lim", limit));
    }

    // ───────────────────────── Period Management ──────────────────────────

    /// <summary>
    /// Opens a financial period by ID, automatically closing all others.
    /// Returns true if successful.
    /// </summary>
    public static bool OpenPeriod(int periodId, string userName)
    {
        FinanceDB.ExecuteInTransaction((conn, tx) =>
        {
            // Close all currently open periods
            using (var cmd = new MySqlCommand(
                "UPDATE fin_financial_years SET status = 'Closed' WHERE status = 'Open'", conn))
            {
                cmd.Transaction = tx;
                cmd.ExecuteNonQuery();
            }

            // Open the target period
            using (var cmd = new MySqlCommand(
                "UPDATE fin_financial_years SET status = 'Open' WHERE id = @id", conn))
            {
                cmd.Transaction = tx;
                cmd.Parameters.AddWithValue("@id", periodId);
                cmd.ExecuteNonQuery();
            }
        });

        FinanceLogger.LogAction("PERIOD_OPEN",
            string.Format("Financial period {0} opened", periodId), userName);
        return true;
    }

    /// <summary>
    /// Closes a financial period by ID.
    /// </summary>
    public static bool ClosePeriod(int periodId, string userName)
    {
        FinanceDB.ExecuteNonQuery(
            "UPDATE fin_financial_years SET status = 'Closed' WHERE id = @id",
            FinanceDB.P("@id", periodId));

        FinanceLogger.LogAction("PERIOD_CLOSE",
            string.Format("Financial period {0} closed", periodId), userName);
        return true;
    }

    /// <summary>
    /// Adds a new financial period. Validates that end > start and no overlap
    /// with existing periods.
    /// Returns the new period ID on success, or throws on validation failure.
    /// </summary>
    public static int AddPeriod(string label, DateTime startDate, DateTime endDate, string status)
    {
        if (endDate <= startDate)
            throw new ArgumentException("End date must be after start date.");

        // Check for overlapping periods
        int overlap = FinanceDB.ExecuteScalar<int>(
            @"SELECT COUNT(*) FROM fin_financial_years 
              WHERE (start_date <= @ed AND end_date >= @sd)",
            FinanceDB.P("@sd", startDate),
            FinanceDB.P("@ed", endDate));

        if (overlap > 0)
            throw new InvalidOperationException(
                "The specified date range overlaps with an existing financial period.");

        FinanceDB.ExecuteNonQuery(
            "INSERT INTO fin_financial_years (finacial_Year, start_date, end_date, status) VALUES (@fy, @sd, @ed, @st)",
            FinanceDB.P("@fy", label),
            FinanceDB.P("@sd", startDate.ToString("yyyy-MM-dd")),
            FinanceDB.P("@ed", endDate.ToString("yyyy-MM-dd")),
            FinanceDB.P("@st", status));

        return FinanceDB.ExecuteScalar<int>("SELECT LAST_INSERT_ID()");
    }

    /// <summary>
    /// Deletes a financial period by ID. Prevents deletion of open periods
    /// and periods that have associated transactions.
    /// </summary>
    public static void DeletePeriod(int periodId)
    {
        // Check if open
        string status = FinanceDB.ExecuteScalar<string>(
            "SELECT status FROM fin_financial_years WHERE id = @id",
            FinanceDB.P("@id", periodId));

        if (string.Equals(status, "Open", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("Cannot delete an open financial period. Close it first.");

        // Check if there are transactions in this period's date range
        int txCount = FinanceDB.ExecuteScalar<int>(
            @"SELECT COUNT(*) FROM fin_ledger l
              INNER JOIN fin_financial_years fy ON fy.id = @id
              WHERE l.transactionDate BETWEEN fy.start_date AND fy.end_date",
            FinanceDB.P("@id", periodId));

        if (txCount > 0)
            throw new InvalidOperationException(
                string.Format("Cannot delete period: {0} ledger transaction(s) exist within its date range.", txCount));

        FinanceDB.ExecuteNonQuery(
            "DELETE FROM fin_financial_years WHERE id = @id",
            FinanceDB.P("@id", periodId));
    }
}

/// <summary>
/// Lightweight DTO for a financial period.
/// </summary>
public class PeriodInfo
{
    public int Id { get; set; }
    public string Label { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public string Status { get; set; }

    public bool IsOpen { get { return string.Equals(Status, "Open", StringComparison.OrdinalIgnoreCase); } }
}
