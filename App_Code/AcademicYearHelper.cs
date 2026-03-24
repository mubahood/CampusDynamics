using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

/// <summary>
/// Centralised helper for academic year management.
/// Uses the acad_acadyears table as the single source of truth.
/// All pages should call these static methods instead of
/// duplicating year-calculation logic locally.
/// </summary>
public static class AcademicYearHelper
{
    // ───────────────────────────────────────────────────────────
    //  CONNECTION
    // ───────────────────────────────────────────────────────────

    private static string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ───────────────────────────────────────────────────────────
    //  GET CURRENT ACADEMIC YEAR  (DB first, date-based fallback)
    // ───────────────────────────────────────────────────────────

    /// <summary>
    /// Returns the current academic year string (e.g. "2025/2026").
    /// Reads is_current_year = 'Yes' from acad_acadyears first;
    /// if none is set, falls back to date-based calculation.
    /// </summary>
    public static string GetCurrentAcademicYear()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT acadyear FROM acad_acadyears WHERE is_current_year = 'Yes' LIMIT 1", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string yr = result.ToString().Trim();
                        if (yr.Length > 0) return yr;
                    }
                }
            }
        }
        catch { /* fallback below */ }

        return CalculateAcademicYearFromDate(DateTime.Now);
    }

    /// <summary>
    /// Returns the current financial year string (e.g. "2025/2026").
    /// Reads is_current_financial_year = 'Yes' from acad_acadyears;
    /// falls back to current academic year.
    /// </summary>
    public static string GetCurrentFinancialYear()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT acadyear FROM acad_acadyears WHERE is_current_financial_year = 'Yes' LIMIT 1", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string yr = result.ToString().Trim();
                        if (yr.Length > 0) return yr;
                    }
                }
            }
        }
        catch { /* fallback */ }

        return GetCurrentAcademicYear();
    }

    // ───────────────────────────────────────────────────────────
    //  CURRENT SEMESTER (date-based)
    // ───────────────────────────────────────────────────────────

    /// <summary>
    /// Returns current semester number: Aug-Dec → 1, Jan-Apr → 2, May-Jul → 3.
    /// </summary>
    public static int GetCurrentSemester()
    {
        int month = DateTime.Now.Month;
        if (month >= 8 && month <= 12) return 1;
        if (month >= 1 && month <= 4) return 2;
        return 3;
    }

    // ───────────────────────────────────────────────────────────
    //  DATE-BASED FALLBACK CALCULATION
    // ───────────────────────────────────────────────────────────

    /// <summary>
    /// Calculates the academic year from a date. Aug-Dec → YYYY/(YYYY+1); Jan-Jul → (YYYY-1)/YYYY.
    /// </summary>
    public static string CalculateAcademicYearFromDate(DateTime dt)
    {
        int year = dt.Year;
        int month = dt.Month;
        if (month >= 8)
            return string.Format("{0}/{1}", year, year + 1);
        else
            return string.Format("{0}/{1}", year - 1, year);
    }

    // ───────────────────────────────────────────────────────────
    //  DROPDOWN POPULATION
    // ───────────────────────────────────────────────────────────

    /// <summary>
    /// Populates a DropDownList with active academic years from the DB.
    /// Filters to (currentYear + 1) maximum. Optionally adds an "All" item.
    /// </summary>
    /// <param name="ddl">The DropDownList to populate.</param>
    /// <param name="includeAll">If true, inserts "All Academic Years" (value = "") at position 0.</param>
    /// <param name="selectCurrent">If true, sets selection to the current academic year.</param>
    public static void PopulateDropDown(DropDownList ddl, bool includeAll, bool selectCurrent)
    {
        ddl.Items.Clear();
        if (includeAll)
            ddl.Items.Add(new ListItem("All Academic Years", ""));

        string currentAcad = GetCurrentAcademicYear();

        // Calculate the maximum year we should show (current calendar year + 1)
        int maxStartYear = DateTime.Now.Year + 1;
        string maxYear = string.Format("{0}/{1}", maxStartYear, maxStartYear + 1);

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT acadyear FROM acad_acadyears WHERE status = 'Active' AND acadyear <= @maxYear ORDER BY acadyear DESC", conn))
                {
                    cmd.Parameters.AddWithValue("@maxYear", maxYear);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string yr = rdr["acadyear"].ToString();
                            ddl.Items.Add(new ListItem(yr, yr));
                        }
                    }
                }
            }
        }
        catch
        {
            // Fallback: generate years in code if DB unavailable
            int cy = DateTime.Now.Year;
            for (int i = cy + 1; i >= cy - 10; i--)
            {
                string lbl = string.Format("{0}/{1}", i, i + 1);
                ddl.Items.Add(new ListItem(lbl, lbl));
            }
        }

        if (selectCurrent && ddl.Items.FindByValue(currentAcad) != null)
            ddl.SelectedValue = currentAcad;
    }

    /// <summary>
    /// Overload: populate with "All" option and auto-select current year.
    /// </summary>
    public static void PopulateDropDown(DropDownList ddl)
    {
        PopulateDropDown(ddl, true, true);
    }

    /// <summary>
    /// Populates a DropDownList with entry years (plain integers, not acad year format).
    /// Shows from (currentYear + 1) down to (currentYear - 10).
    /// </summary>
    public static void PopulateEntryYearDropDown(DropDownList ddl)
    {
        ddl.Items.Clear();
        int cy = DateTime.Now.Year;
        for (int i = cy + 1; i >= cy - 10; i--)
            ddl.Items.Add(new ListItem(i.ToString(), i.ToString()));
    }

    // ───────────────────────────────────────────────────────────
    //  CRUD — called by management page
    // ───────────────────────────────────────────────────────────

    /// <summary>Returns all academic years ordered by acadyear DESC.</summary>
    public static DataTable GetAllAcademicYears()
    {
        DataTable dt = new DataTable();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlDataAdapter da = new MySqlDataAdapter(
                    "SELECT * FROM acad_acadyears ORDER BY acadyear DESC", conn))
                {
                    da.Fill(dt);
                }
            }
        }
        catch { /* empty table returned */ }
        return dt;
    }

    /// <summary>Returns a single academic year row by its acadyear string.</summary>
    public static DataRow GetAcademicYear(string acadyear)
    {
        DataTable dt = new DataTable();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT * FROM acad_acadyears WHERE acadyear = @ay", conn))
                {
                    cmd.Parameters.AddWithValue("@ay", acadyear);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
        }
        catch { }
        return dt.Rows.Count > 0 ? dt.Rows[0] : null;
    }

    /// <summary>Returns a single academic year row by its ID.</summary>
    public static DataRow GetAcademicYearById(int id)
    {
        DataTable dt = new DataTable();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT * FROM acad_acadyears WHERE ID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
                }
            }
        }
        catch { }
        return dt.Rows.Count > 0 ? dt.Rows[0] : null;
    }

    /// <summary>
    /// Adds a new academic year. Returns empty string on success, error message on failure.
    /// </summary>
    public static string AddAcademicYear(string acadyear, DateTime startDate, DateTime endDate,
        int semesterCount, string description, string status, string createdBy)
    {
        string err = ValidateAcademicYear(acadyear, startDate, endDate);
        if (!string.IsNullOrEmpty(err)) return err;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                // Check duplicate
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_acadyears WHERE acadyear = @ay", conn))
                {
                    chk.Parameters.AddWithValue("@ay", acadyear);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        return "Academic year '" + acadyear + "' already exists.";
                }

                using (MySqlCommand cmd = new MySqlCommand(@"
                    INSERT INTO acad_acadyears (acadyear, start_date, end_date, semester_count, description, status, created_date, modified_by)
                    VALUES (@ay, @sd, @ed, @sc, @desc, @st, NOW(), @by)", conn))
                {
                    cmd.Parameters.AddWithValue("@ay", acadyear);
                    cmd.Parameters.AddWithValue("@sd", startDate);
                    cmd.Parameters.AddWithValue("@ed", endDate);
                    cmd.Parameters.AddWithValue("@sc", semesterCount);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                    cmd.Parameters.AddWithValue("@st", status);
                    cmd.Parameters.AddWithValue("@by", createdBy);
                    cmd.ExecuteNonQuery();
                }
            }
            return "";
        }
        catch (Exception ex)
        {
            return "Database error: " + ex.Message;
        }
    }

    /// <summary>
    /// Updates an existing academic year. Returns empty string on success.
    /// </summary>
    public static string UpdateAcademicYear(int id, string acadyear, DateTime startDate, DateTime endDate,
        int semesterCount, string description, string status, string modifiedBy)
    {
        string err = ValidateAcademicYear(acadyear, startDate, endDate);
        if (!string.IsNullOrEmpty(err)) return err;

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                // Check duplicate (exclude self)
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_acadyears WHERE acadyear = @ay AND ID != @id", conn))
                {
                    chk.Parameters.AddWithValue("@ay", acadyear);
                    chk.Parameters.AddWithValue("@id", id);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        return "Academic year '" + acadyear + "' already exists.";
                }

                using (MySqlCommand cmd = new MySqlCommand(@"
                    UPDATE acad_acadyears SET
                        acadyear = @ay, start_date = @sd, end_date = @ed,
                        semester_count = @sc, description = @desc, status = @st,
                        modified_date = NOW(), modified_by = @by
                    WHERE ID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@ay", acadyear);
                    cmd.Parameters.AddWithValue("@sd", startDate);
                    cmd.Parameters.AddWithValue("@ed", endDate);
                    cmd.Parameters.AddWithValue("@sc", semesterCount);
                    cmd.Parameters.AddWithValue("@desc", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                    cmd.Parameters.AddWithValue("@st", status);
                    cmd.Parameters.AddWithValue("@by", modifiedBy);
                    cmd.ExecuteNonQuery();
                }
            }
            return "";
        }
        catch (Exception ex)
        {
            return "Database error: " + ex.Message;
        }
    }

    /// <summary>
    /// Deletes an academic year (only if not used anywhere). Returns empty string on success.
    /// </summary>
    public static string DeleteAcademicYear(int id)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Get the acadyear value first
                string acadyear = "";
                using (MySqlCommand getCmd = new MySqlCommand("SELECT acadyear FROM acad_acadyears WHERE ID = @id", conn))
                {
                    getCmd.Parameters.AddWithValue("@id", id);
                    object r = getCmd.ExecuteScalar();
                    if (r == null) return "Academic year not found.";
                    acadyear = r.ToString();
                }

                // Check if used in registrations
                using (MySqlCommand chk = new MySqlCommand(
                    "SELECT COUNT(*) FROM acad_registration WHERE acad_year = @ay LIMIT 1", conn))
                {
                    chk.Parameters.AddWithValue("@ay", acadyear);
                    if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                        return "Cannot delete — this academic year has registration records.";
                }

                using (MySqlCommand cmd = new MySqlCommand("DELETE FROM acad_acadyears WHERE ID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
            }
            return "";
        }
        catch (Exception ex)
        {
            return "Database error: " + ex.Message;
        }
    }

    /// <summary>
    /// Sets is_current_year = 'Yes' for the given acadyear and 'No' for all others.
    /// </summary>
    public static string SetCurrentAcademicYear(string acadyear, string modifiedBy)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    UPDATE acad_acadyears SET is_current_year = 'No', modified_date = NOW(), modified_by = @by;
                    UPDATE acad_acadyears SET is_current_year = 'Yes', modified_date = NOW(), modified_by = @by WHERE acadyear = @ay;", conn))
                {
                    cmd.Parameters.AddWithValue("@ay", acadyear);
                    cmd.Parameters.AddWithValue("@by", modifiedBy);
                    cmd.ExecuteNonQuery();
                }
            }
            return "";
        }
        catch (Exception ex)
        {
            return "Database error: " + ex.Message;
        }
    }

    /// <summary>
    /// Sets is_current_financial_year = 'Yes' for the given acadyear and 'No' for all others.
    /// </summary>
    public static string SetCurrentFinancialYear(string acadyear, string modifiedBy)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    UPDATE acad_acadyears SET is_current_financial_year = 'No', modified_date = NOW(), modified_by = @by;
                    UPDATE acad_acadyears SET is_current_financial_year = 'Yes', modified_date = NOW(), modified_by = @by WHERE acadyear = @ay;", conn))
                {
                    cmd.Parameters.AddWithValue("@ay", acadyear);
                    cmd.Parameters.AddWithValue("@by", modifiedBy);
                    cmd.ExecuteNonQuery();
                }
            }
            return "";
        }
        catch (Exception ex)
        {
            return "Database error: " + ex.Message;
        }
    }

    // ───────────────────────────────────────────────────────────
    //  VALIDATION
    // ───────────────────────────────────────────────────────────

    /// <summary>
    /// Validates the acadyear format (e.g. "2025/2026") and date range.
    /// Returns empty string on success, error message on failure.
    /// </summary>
    public static string ValidateAcademicYear(string acadyear, DateTime startDate, DateTime endDate)
    {
        if (string.IsNullOrEmpty(acadyear))
            return "Academic year is required.";

        string[] parts = acadyear.Split('/');
        if (parts.Length != 2)
            return "Academic year must be in the format YYYY/YYYY (e.g. 2025/2026).";

        int y1, y2;
        if (!int.TryParse(parts[0], out y1) || !int.TryParse(parts[1], out y2))
            return "Academic year must contain valid years (e.g. 2025/2026).";

        if (y2 != y1 + 1)
            return "The second year must be exactly one more than the first (e.g. 2025/2026).";

        if (y1 < 2000 || y1 > 2099)
            return "Academic year must be between 2000 and 2099.";

        if (endDate <= startDate)
            return "End date must be after start date.";

        return "";
    }

    /// <summary>
    /// Validates only the format of an acadyear string. Returns true if valid.
    /// </summary>
    public static bool IsValidFormat(string acadyear)
    {
        if (string.IsNullOrEmpty(acadyear)) return false;
        string[] parts = acadyear.Split('/');
        if (parts.Length != 2) return false;
        int y1, y2;
        if (!int.TryParse(parts[0], out y1) || !int.TryParse(parts[1], out y2)) return false;
        return y2 == y1 + 1;
    }
}
