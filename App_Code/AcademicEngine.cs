using System;
using System.Collections.Generic;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// AcademicEngine — THE single source of truth for all student academic computations.
///
/// Every academic endpoint that computes GPA, registration status, or academic standing
/// must use these methods. Centralizing here prevents the divergence bugs that arise from
/// duplicating logic across multiple handlers.
///
/// Design contract:
///   • ComputeGPA()                 → GpaResult from a results DataTable (no extra DB hit)
///   • GetClassification()          → "First Class" / "Second Class Upper" / etc.
///   • MapRegistrationStatus()      → human-readable label for raw DB status string
///   • IsActiveRegistrationStatus() → bool: is the status an active enrollment?
///   • IsSemesterOpen()             → reads acad_acadyears to test registration window
///   • GetRetakeCourses()           → failed courses not yet passed (from results DataTable)
/// </summary>
public static class AcademicEngine
{
    // ═══════════════════════════════════════════════════════════════════
    //  GPA COMPUTATION
    //  Call with a DataTable from acad_GetAllResultsTableAdapter.
    //  No extra DB round-trip — computation is purely in-memory.
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Computes CGPA and per-semester GPAs from a results DataTable.
    /// Expected columns: acad, semester, CreditUnits, gradept.
    /// Returns a GpaResult containing semester breakdowns, CGPA, total credits, and classification.
    /// </summary>
    public static GpaResult ComputeGPA(DataTable results)
    {
        var semesters = new List<SemesterGPA>();
        double totalWeightedGP = 0;
        int totalCredits = 0;

        if (results != null && results.Rows.Count > 0)
        {
            DataView dv = new DataView(results);
            DataTable distinctSems = dv.ToTable(true, "acad", "semester");

            foreach (DataRow semRow in distinctSems.Rows)
            {
                string ay  = semRow["acad"].ToString();
                string sem = semRow["semester"].ToString();

                DataView semView = new DataView(results);
                semView.RowFilter = "acad = '" + ay.Replace("'", "") + "' AND semester = " + sem;
                DataTable semResults = semView.ToTable();

                double semWeightedGP = 0;
                int semCredits = 0;

                foreach (DataRow r in semResults.Rows)
                {
                    int cu = 0;
                    double gp = 0;
                    if (r["CreditUnits"] != DBNull.Value) int.TryParse(r["CreditUnits"].ToString(), out cu);
                    if (cu == 0) continue; // skip rows with no credit units (excluded from GPA)
                    if (r["gradept"] != DBNull.Value && r["gradept"].ToString().Trim() != "")
                        double.TryParse(r["gradept"].ToString(), out gp);
                    else
                        gp = GradeToPoint(Col(r, "grade")); // fallback: derive from letter grade
                    semWeightedGP += gp * cu;
                    semCredits    += cu;
                }

                double semGPA = semCredits > 0 ? Math.Round(semWeightedGP / semCredits, 2) : 0;
                totalWeightedGP += semWeightedGP;
                totalCredits    += semCredits;

                semesters.Add(new SemesterGPA
                {
                    AcadYear = ay,
                    Semester = sem,
                    GPA      = semGPA,
                    Credits  = semCredits
                });
            }
        }

        double cgpa = totalCredits > 0 ? Math.Round(totalWeightedGP / totalCredits, 2) : 0;

        return new GpaResult
        {
            Semesters      = semesters,
            CGPA           = cgpa,
            TotalCredits   = totalCredits,
            Classification = GetClassification(cgpa)
        };
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DEGREE CLASSIFICATION
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>Returns the degree classification string for a given CGPA.</summary>
    public static string GetClassification(double cgpa)
    {
        if (cgpa >= 4.4) return "First Class";
        if (cgpa >= 3.6) return "Second Class Upper";
        if (cgpa >= 2.8) return "Second Class Lower";
        if (cgpa >= 2.0) return "Pass";
        return "Below Pass";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  REGISTRATION STATUS
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Maps the raw DB registration status value to a human-readable label.
    /// This is THE canonical mapping — do not define it elsewhere.
    /// </summary>
    public static string MapRegistrationStatus(string raw)
    {
        switch ((raw ?? "").ToUpper().Trim())
        {
            case "REGISTERED":      return "Registered";
            case "LATE REGISTERED": return "Late Registered";
            case "CLEARED":         return "Cleared";
            case "UNREGISTERED":    return "Unregistered";
            case "DISCONTINUED":    return "Discontinued";
            case "HALTED":          return "Halted";
            case "DEAD YEAR":       return "Dead Year";
            case "ACTIVE":          return "Registered";
            default:
                return string.IsNullOrEmpty(raw) ? "Unknown" : raw;
        }
    }

    /// <summary>
    /// Returns true for statuses that indicate the student is actively enrolled.
    /// Used to compute is_enrolled / is_active_registration flags across endpoints.
    /// </summary>
    public static bool IsActiveRegistrationStatus(string raw)
    {
        switch ((raw ?? "").ToUpper().Trim())
        {
            case "REGISTERED":
            case "LATE REGISTERED":
            case "CLEARED":
            case "ACTIVE":
                return true;
            default:
                return false;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SEMESTER OPEN CHECK
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns true when the specified semester is open for registration.
    /// Reads semester_N_is_active from acad_acadyears. Returns false on any error
    /// or when the academic year row is not found.
    /// semester must be 1, 2, or 3.
    /// </summary>
    public static bool IsSemesterOpen(string acadYear, int semester)
    {
        if (string.IsNullOrEmpty(acadYear) || semester < 1 || semester > 3) return false;
        try
        {
            string semCol = "semester_" + semester + "_is_active";
            DataTable dt = ApiHelper.Query(
                "SELECT " + semCol + " AS is_active FROM acad_acadyears WHERE acad_year = @acad LIMIT 1",
                new MySqlParameter("@acad", acadYear)
            );
            if (dt.Rows.Count > 0)
            {
                string v = dt.Rows[0]["is_active"] != DBNull.Value
                    ? dt.Rows[0]["is_active"].ToString().Trim() : "No";
                return v.Equals("Yes", StringComparison.OrdinalIgnoreCase);
            }
        }
        catch { }
        return false;
    }

    // ═══════════════════════════════════════════════════════════════════
    //  RETAKE COURSES
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Derives retakable courses from a results DataTable.
    /// A course is retakable when the student has ever failed it (grade F or E)
    /// AND the most recent attempt is still a fail — meaning no subsequent pass exists.
    /// Expected columns: courseID, courseName, CreditUnits, grade, marks, acad, semester.
    /// Rows must be ordered ASC by date (standard adapter output).
    /// </summary>
    public static List<Dictionary<string, object>> GetRetakeCourses(DataTable results)
    {
        var latestByCode = new Dictionary<string, DataRow>(StringComparer.OrdinalIgnoreCase);
        var failedOnce   = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        if (results != null)
        {
            foreach (DataRow row in results.Rows)
            {
                string code = Col(row, "courseID");
                if (string.IsNullOrEmpty(code)) continue;

                string grade = Col(row, "grade").ToUpper();
                if (grade == "F" || grade == "E") failedOnce.Add(code);

                latestByCode[code] = row; // ASC order → last assignment is the most recent
            }
        }

        var retakable = new List<Dictionary<string, object>>();
        foreach (string code in failedOnce)
        {
            if (!latestByCode.ContainsKey(code)) continue;
            DataRow latest = latestByCode[code];

            string latestGrade = Col(latest, "grade").ToUpper();
            if (latestGrade != "F" && latestGrade != "E") continue;

            retakable.Add(new Dictionary<string, object>
            {
                { "course_code",  code                       },
                { "course_name",  Col(latest, "courseName")  },
                { "credit_units", Col(latest, "CreditUnits") },
                { "latest_grade", latestGrade                },
                { "latest_score", Col(latest, "marks")       },
                { "acad_year",    Col(latest, "acad")        },
                { "semester",     Col(latest, "semester")    }
            });
        }
        return retakable;
    }

    // ─── Internal helpers ─────────────────────────────────────────────

    /// <summary>Maps a letter grade to a numeric grade point (5-point scale). Returns 0 for F/E/unknown.</summary>
    private static double GradeToPoint(string grade)
    {
        switch ((grade ?? "").ToUpper().Trim())
        {
            case "A":  return 5.0;
            case "B+": return 4.5;
            case "B":  return 4.0;
            case "C+": return 3.5;
            case "C":  return 3.0;
            case "D+": return 2.5;
            case "D":  return 2.0;
            default:   return 0.0; // F, E, X, NE, blank
        }
    }

    private static string Col(DataRow row, string name)
    {
        if (row.Table.Columns.Contains(name) && row[name] != DBNull.Value)
            return Convert.ToString(row[name]);
        return "";
    }
}

// ═══════════════════════════════════════════════════════════════════════
//  DATA TRANSFER OBJECTS
// ═══════════════════════════════════════════════════════════════════════

/// <summary>
/// Full GPA computation result returned by AcademicEngine.ComputeGPA().
/// Use ToDictionary() to serialize for JSON output — field names are defined once here.
/// </summary>
public class GpaResult
{
    public List<SemesterGPA> Semesters      { get; set; }
    public double            CGPA           { get; set; }
    public int               TotalCredits   { get; set; }
    public string            Classification { get; set; }

    public Dictionary<string, object> ToDictionary()
    {
        var sems = new List<Dictionary<string, object>>();
        if (Semesters != null)
            foreach (SemesterGPA s in Semesters)
                sems.Add(s.ToDictionary());

        return new Dictionary<string, object>
        {
            { "semesters",      sems           },
            { "cgpa",           CGPA           },
            { "total_credits",  TotalCredits   },
            { "classification", Classification }
        };
    }
}

/// <summary>Per-semester GPA entry within a GpaResult.</summary>
public class SemesterGPA
{
    public string AcadYear { get; set; }
    public string Semester { get; set; }
    public double GPA      { get; set; }
    public int    Credits  { get; set; }

    public Dictionary<string, object> ToDictionary()
    {
        return new Dictionary<string, object>
        {
            { "acad_year", AcadYear },
            { "semester",  Semester },
            { "gpa",       GPA      },
            { "credits",   Credits  }
        };
    }
}

/// <summary>
/// Snapshot of a student's most recent academic registration record.
/// Returned by the student_academic_summary and academic_standing endpoints.
/// </summary>
public class RegistrationState
{
    public string AcadYear    { get; set; }
    public int    Semester    { get; set; }
    public string Status      { get; set; }
    public string StatusLabel { get; set; }
    public bool   IsActive    { get; set; }
    public string StudyYear   { get; set; }

    public Dictionary<string, object> ToDictionary()
    {
        return new Dictionary<string, object>
        {
            { "acad_year",    AcadYear    },
            { "semester",     Semester    },
            { "status",       Status      },
            { "status_label", StatusLabel },
            { "is_active",    IsActive    },
            { "study_year",   StudyYear   }
        };
    }
}
