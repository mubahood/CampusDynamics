using System;
using System.Text.RegularExpressions;

/// <summary>
/// MarksInputValidator — Centralized input whitelisting and sanitization for the marks module.
///
/// Validates all user-supplied identifiers (course codes, programme codes, academic years,
/// semesters, etc.) against canonical formats before processing. Prevents data poisoning,
/// log injection, and invalid data from reaching the database.
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P69 (course ID poisoning), P70 (log injection), P71 (SQL injection prevention)
/// Task: C-04
/// </summary>
public static class MarksInputValidator
{
    // ─────────────────────── Format Patterns ────────────────────────────

    // Course code: 2-6 alpha + 3-4 digits, optional suffix (e.g., ACC101, BBA301B, CS2001)
    private static readonly Regex CourseCodePattern = new Regex(
        @"^[A-Za-z]{2,8}[0-9]{2,5}[A-Za-z]?$", RegexOptions.Compiled);

    // Programme code: 2-15 alphanumeric + hyphens/underscores (e.g., BBA-DAY, BCOM_FULL)
    private static readonly Regex ProgCodePattern = new Regex(
        @"^[A-Za-z0-9\-_]{2,25}$", RegexOptions.Compiled);

    // Academic year: YYYY/YYYY where second year = first + 1
    private static readonly Regex AcadYearPattern = new Regex(
        @"^(20[0-9]{2})/(20[0-9]{2})$", RegexOptions.Compiled);

    // Username: alphanumeric + dots, underscores, hyphens (3-50 chars)
    private static readonly Regex UsernamePattern = new Regex(
        @"^[A-Za-z0-9._\-]{3,50}$", RegexOptions.Compiled);

    // ─────────────────────── Validation Methods ─────────────────────────

    /// <summary>
    /// Validates a course code against the expected format.
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateCourseCode(string code)
    {
        if (string.IsNullOrEmpty(code)) return "Course code is required.";
        string trimmed = code.Trim();
        if (trimmed.Length < 3 || trimmed.Length > 25) return "Course code must be 3-25 characters.";
        if (!CourseCodePattern.IsMatch(trimmed)) return "Course code contains invalid characters.";
        return null;
    }

    /// <summary>
    /// Validates a programme code against the expected format.
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateProgrammeCode(string code)
    {
        if (string.IsNullOrEmpty(code)) return "Programme code is required.";
        string trimmed = code.Trim();
        if (trimmed.Length < 2 || trimmed.Length > 25) return "Programme code must be 2-25 characters.";
        if (!ProgCodePattern.IsMatch(trimmed)) return "Programme code contains invalid characters.";
        return null;
    }

    /// <summary>
    /// Validates an academic year string (format: "YYYY/YYYY").
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateAcademicYear(string year)
    {
        if (string.IsNullOrEmpty(year)) return "Academic year is required.";
        string trimmed = year.Trim();
        Match m = AcadYearPattern.Match(trimmed);
        if (!m.Success) return "Academic year must be in format YYYY/YYYY (e.g., 2025/2026).";

        int startYear = int.Parse(m.Groups[1].Value);
        int endYear = int.Parse(m.Groups[2].Value);
        if (endYear != startYear + 1) return "Academic year end must be exactly one year after start.";
        if (startYear < 2000 || startYear > 2099) return "Academic year out of valid range (2000-2099).";
        return null;
    }

    /// <summary>
    /// Validates a semester number (1-6).
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateSemester(int semester)
    {
        if (semester < 1 || semester > 6) return "Semester must be between 1 and 6.";
        return null;
    }

    /// <summary>
    /// Validates a study year number (1-7).
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateStudyYear(int studyYear)
    {
        if (studyYear < 1 || studyYear > 7) return "Study year must be between 1 and 7.";
        return null;
    }

    /// <summary>
    /// Validates a campus ID (positive integer).
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateCampusId(int campusId)
    {
        if (campusId < 1) return "Campus ID must be a positive number.";
        return null;
    }

    /// <summary>
    /// Validates a study session string.
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateStudSession(string session)
    {
        if (string.IsNullOrEmpty(session)) return "Study session is required.";
        string s = session.Trim().ToLower();
        if (s != "day" && s != "evening" && s != "weekend" && s != "distance" && s != "online")
        {
            return "Study session must be one of: Day, Evening, Weekend, Distance, Online.";
        }
        return null;
    }

    /// <summary>
    /// Validates a username format.
    /// Returns null on success, or an error message on failure.
    /// </summary>
    public static string ValidateUsername(string username)
    {
        if (string.IsNullOrEmpty(username)) return "Username is required.";
        string trimmed = username.Trim();
        if (trimmed.Length < 3 || trimmed.Length > 50) return "Username must be 3-50 characters.";
        if (!UsernamePattern.IsMatch(trimmed)) return "Username contains invalid characters.";
        return null;
    }

    // ─────────────────────── Batch Validation ───────────────────────────

    /// <summary>
    /// Validates the common mark entry context parameters.
    /// Returns null on success, or the first validation error found.
    /// </summary>
    public static string ValidateMarkContext(string courseId, string progId, string acadyear, int semester)
    {
        string err;
        err = ValidateCourseCode(courseId);
        if (err != null) return err;
        err = ValidateProgrammeCode(progId);
        if (err != null) return err;
        err = ValidateAcademicYear(acadyear);
        if (err != null) return err;
        err = ValidateSemester(semester);
        if (err != null) return err;
        return null;
    }

    /// <summary>
    /// Validates the full sheet context parameters (course + prog + year + sem + studyYear + campus + session).
    /// Returns null on success, or the first validation error found.
    /// </summary>
    public static string ValidateFullContext(string courseId, string progId, string acadyear,
        int semester, int studyYear, int campusId, string studSession)
    {
        string err;
        err = ValidateMarkContext(courseId, progId, acadyear, semester);
        if (err != null) return err;
        err = ValidateStudyYear(studyYear);
        if (err != null) return err;
        err = ValidateCampusId(campusId);
        if (err != null) return err;
        err = ValidateStudSession(studSession);
        if (err != null) return err;
        return null;
    }

    // ─────────────────────── Sanitization ───────────────────────────────

    /// <summary>
    /// Trims and length-limits a string input. Returns empty string for null.
    /// Use for free-text inputs (reasons, notes) to prevent oversized payloads.
    /// </summary>
    public static string Sanitize(string input, int maxLength)
    {
        if (string.IsNullOrEmpty(input)) return "";
        string trimmed = input.Trim();
        if (trimmed.Length > maxLength) trimmed = trimmed.Substring(0, maxLength);
        return trimmed;
    }

    /// <summary>
    /// Sanitizes a string for safe inclusion in log messages.
    /// Strips control characters and limits length to prevent log injection (P70).
    /// </summary>
    public static string SanitizeForLog(string input, int maxLength)
    {
        if (string.IsNullOrEmpty(input)) return "";
        char[] chars = input.Trim().ToCharArray();
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        for (int i = 0; i < chars.Length && sb.Length < maxLength; i++)
        {
            char c = chars[i];
            if (c >= 32 && c < 127) sb.Append(c);  // printable ASCII only
            else if (c == '\t') sb.Append(' ');       // tab → space
            // skip other control chars, newlines, etc.
        }
        return sb.ToString();
    }
}
