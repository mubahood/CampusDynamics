using System;
using System.Collections.Generic;

// =====================================================================
//  COURSE RECORDS CORRECTION CENTRE — types and the table registry.
//
//  The registry is the single place where a table's column names are
//  written down. Every query in the service is built from it, so a
//  column name is never typed twice and never guessed. Column names
//  genuinely differ between tables (courseID vs courseid; acad vs
//  acad_year vs acadyear), which is exactly why this exists.
//
//  Verified against the live schema on 15 August 2026.
// =====================================================================

public static class CorrectionOp
{
    public const string CourseTransfer = "COURSE_TRANSFER";
    public const string TermTransfer   = "TERM_TRANSFER";
    public const string CourseMerge    = "COURSE_MERGE";
    public const string Reversal       = "REVERSAL";
}

public static class CorrectionVerdict
{
    public const string Moved              = "MOVED";
    public const string SkippedDuplicate   = "SKIPPED_DUPLICATE";
    public const string SkippedResultClash = "SKIPPED_RESULT_CLASH";
    public const string SkippedPublished   = "SKIPPED_PUBLISHED";
    public const string SkippedOutOfScope  = "SKIPPED_OUT_OF_SCOPE";
    public const string SkippedSameTarget  = "SKIPPED_SAME_TARGET";
    public const string ChangedSince       = "CHANGED_SINCE";
    public const string Reversed           = "REVERSED";

    // Conflict resolution (policy = "resolve"). A duplicate is settled rather than left:
    // the better mark survives on the destination and the duplicate source row is removed.
    public const string ResolvedOverwrite  = "RESOLVED_OVERWRITE";  // source mark was better — copied over, source removed
    public const string ResolvedDiscard    = "RESOLVED_DISCARD";    // destination already as good or better — source removed
    public const string ResolvedFilled     = "RESOLVED_FILLED";     // destination had no mark — filled from the source, source removed

    /// <summary>Human sentence for a verdict, shown in the preview and the register.</summary>
    public static string Explain(string v)
    {
        switch (v)
        {
            case Moved:              return "Will be moved";
            case SkippedDuplicate:   return "Student already holds the target code for this term and status";
            case SkippedResultClash: return "Student already has a published result on the target code (one result per course code is allowed)";
            case SkippedPublished:   return "Marks are published — not included unless published records are ticked";
            case SkippedOutOfScope:  return "Programme is outside your scope";
            case SkippedSameTarget:  return "Source and target are the same";
            case ChangedSince:       return "Record changed after the correction — left as it is";
            case Reversed:           return "Restored to its original value";
            case ResolvedOverwrite:  return "Duplicate settled — the higher mark replaces the one on the destination, and the duplicate is removed";
            case ResolvedFilled:     return "Duplicate settled — the destination had no mark, so it takes this one, and the duplicate is removed";
            case ResolvedDiscard:    return "Duplicate settled — the destination already holds a mark as good or better, so the duplicate is removed";
            default:                 return v;
        }
    }

    /// <summary>True when the correction will act on the record.</summary>
    public static bool IsActionable(string v)
    {
        return v == Moved || IsResolved(v);
    }

    /// <summary>True for the three duplicate-settling outcomes, all of which remove the source row.</summary>
    public static bool IsResolved(string v)
    {
        return v == ResolvedOverwrite || v == ResolvedDiscard || v == ResolvedFilled;
    }
}

/// <summary>One table that carries a student's course record, and the exact column names it uses.</summary>
public class CourseTableDef
{
    public string Db;              // campus_dynamics | campus_dynamics_portal
    public string Table;
    public string PkCol;
    public string RegnoCol;        // null for catalogue tables
    public string CourseCol;
    public string CourseCol2;      // second course column (acad_teaching_allocation carries both)
    public string YearCol;         // null when the table has no term
    public string SemCol;
    public string ProgCol;
    public string Label;

    /// <summary>True when at most one row may exist per (student, course) — the term is not part
    /// of the key, so a course-code transfer must move it regardless of which term it records.</summary>
    public bool OnePerCourse;

    /// <summary>True for the registration table itself, which drives everything else.</summary>
    public bool IsMaster;

    /// <summary>Catalogue tables are only touched by Course Code Merge.</summary>
    public bool IsCatalogue;

    public string Qualified { get { return Db + "." + Table; } }
    public bool HasTerm { get { return !string.IsNullOrEmpty(YearCol); } }
}

public static class CourseTableRegistry
{
    public const string MainDb   = "campus_dynamics";
    public const string PortalDb = "campus_dynamics_portal";

    private static readonly List<CourseTableDef> _all = new List<CourseTableDef>
    {
        // ---------- Student-level: the master ----------
        new CourseTableDef {
            Db = PortalDb, Table = "acad_course_registration", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester",
            ProgCol = "prog_id", IsMaster = true, Label = "Course registration" },

        // ---------- Student-level: satellites ----------
        // UNIQUE (regno, courseid) — no term in the key, so exactly one row per student per code.
        new CourseTableDef {
            Db = MainDb, Table = "acad_results", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "courseid", YearCol = "acad", SemCol = "semester",
            ProgCol = "progid", OnePerCourse = true, Label = "Published result" },

        new CourseTableDef {
            Db = MainDb, Table = "acad_transcript_results", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "courseid", YearCol = "acad", SemCol = "semester",
            ProgCol = "progid", Label = "Transcript result" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_retake_registrations", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "courseID", YearCol = "retake_acad_year", SemCol = "retake_semester",
            ProgCol = "prog_id", Label = "Retake registration" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_coursework_exceluploads", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "courseID", YearCol = "acadyear", SemCol = "semester",
            ProgCol = "progID", Label = "Coursework upload" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_exam_exceluploads", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "courseID", YearCol = "acadyear", SemCol = "semester",
            ProgCol = "progID", Label = "Exam upload" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_results_complaints", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "courseid", YearCol = "acadyear", SemCol = "semester",
            ProgCol = "progid", Label = "Result complaint" },

        // ---------- Catalogue: Course Code Merge only ----------
        new CourseTableDef {
            Db = MainDb, Table = "acad_programmecourses", PkCol = "ID",
            CourseCol = "course_code", SemCol = "semester", ProgCol = "progcode",
            IsCatalogue = true, Label = "Curriculum entry" },

        new CourseTableDef {
            Db = MainDb, Table = "acad_teaching_allocation", PkCol = "ID",
            CourseCol = "courseID", CourseCol2 = "course_code", YearCol = "acad_year", SemCol = "semester",
            ProgCol = "progcode", IsCatalogue = true, Label = "Teaching allocation" },

        new CourseTableDef {
            Db = MainDb, Table = "acad_teaching_allocation_for_registration", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester", ProgCol = "progcode",
            IsCatalogue = true, Label = "Allocation (registration)" },

        new CourseTableDef {
            Db = MainDb, Table = "acad_exam_timetable", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester", ProgCol = "progcode",
            IsCatalogue = true, Label = "Exam timetable" },

        new CourseTableDef {
            Db = MainDb, Table = "acad_coursework_timetable", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester", ProgCol = "progcode",
            IsCatalogue = true, Label = "Coursework timetable" },

        new CourseTableDef {
            Db = MainDb, Table = "acad_timetable_item", PkCol = "item_id",
            CourseCol = "course_code", YearCol = "acad_year", SemCol = "semester", ProgCol = "progcode",
            IsCatalogue = true, Label = "Timetable item" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_examsettings", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester", ProgCol = "prog_id",
            IsCatalogue = true, Label = "Exam setting" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_researchexamsettings", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester", ProgCol = "prog_id",
            IsCatalogue = true, Label = "Research exam setting" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_coursework_settings", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acadyear", SemCol = "semester", ProgCol = "progID",
            IsCatalogue = true, Label = "Coursework setting" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_practicalexam_settings", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acadyear", SemCol = "semester", ProgCol = "progID",
            IsCatalogue = true, Label = "Practical exam setting" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_examination_papers", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester", ProgCol = "prog_id",
            IsCatalogue = true, Label = "Examination paper" },

        new CourseTableDef {
            Db = PortalDb, Table = "acad_facultyresultsheets", PkCol = "ID",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester", ProgCol = "prog_id",
            IsCatalogue = true, Label = "Faculty result sheet" },

        new CourseTableDef {
            Db = PortalDb, Table = "odel_course_space", PkCol = "id",
            CourseCol = "courseID", YearCol = "acad_year", SemCol = "semester",
            IsCatalogue = true, Label = "ODEL course space" },
    };

    /// <summary>The registration table — the record everything else hangs off.</summary>
    public static CourseTableDef Master
    {
        get { return _all.Find(t => t.IsMaster); }
    }

    /// <summary>Student-level satellites, in the order they are written.</summary>
    public static List<CourseTableDef> Satellites
    {
        get { return _all.FindAll(t => !t.IsMaster && !t.IsCatalogue); }
    }

    /// <summary>Every student-level table, master first.</summary>
    public static List<CourseTableDef> StudentTables
    {
        get { var l = new List<CourseTableDef> { Master }; l.AddRange(Satellites); return l; }
    }

    /// <summary>Catalogue tables, touched only by Course Code Merge.</summary>
    public static List<CourseTableDef> CatalogueTables
    {
        get { return _all.FindAll(t => t.IsCatalogue); }
    }

    public static CourseTableDef Find(string db, string table)
    {
        return _all.Find(t => string.Equals(t.Db, db, StringComparison.OrdinalIgnoreCase)
                           && string.Equals(t.Table, table, StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Frozen archive of the pre-ERP system. Listed here so the exclusion is a stated
    /// decision rather than an omission — it is never read or written by this module.
    /// </summary>
    public static readonly string[] DeliberatelyExcluded =
        { "campus_dynamics.acad_results_legacy", "campus_dynamics_portal.acad_results" };
}

/// <summary>Everything the wizard collects. Round-tripped as JSON so preview and apply
/// are driven by one identical object and cannot diverge.</summary>
public class CorrectionConfig
{
    public string operation = CorrectionOp.CourseTransfer;

    public string sourceCode = "";
    public string targetCode = "";
    public string sourceYear = "";
    public string sourceSemester = "";
    public string targetYear = "";
    public string targetSemester = "";

    // Scope
    public string programme = "";
    public string faculty = "";
    public string department = "";
    public string studyYear = "";
    public string markStage = "";          // "" = any
    public string registrationType = "";   // "" = any | NORMAL | RT
    public string courseStatus = "";       // "" = any
    public string students = "";           // comma/space separated reg numbers; "" = all in scope

    // Behaviour
    public bool includePublished = false;  // published marks are excluded unless ticked
    public bool moveResults = true;        // carry acad_results / transcript rows along
    public bool allTerms = false;          // course transfer: move satellites from any term
    public string creditUnitWinner = "";   // merge only: "source" | "target"

    /// <summary>What to do when the student already holds the destination.
    ///   "leave"   — report the duplicate and change nothing (cautious default).
    ///   "resolve" — settle it: the higher mark ends up on the destination and the
    ///               duplicate source record is removed, so no duplicate survives.
    /// Both are fully snapshotted and reversible.</summary>
    public string conflictPolicy = "leave";

    public bool Resolving { get { return string.Equals(conflictPolicy, "resolve", StringComparison.OrdinalIgnoreCase); } }

    public string reason = "";

    public List<string> StudentList()
    {
        var list = new List<string>();
        if (string.IsNullOrEmpty(students)) return list;
        foreach (var raw in students.Split(new[] { ',', ';', ' ', '\t', '\r', '\n' },
                                           StringSplitOptions.RemoveEmptyEntries))
        {
            string s = raw.Trim();
            if (s.Length > 0 && !list.Contains(s)) list.Add(s);
        }
        return list;
    }
}

/// <summary>One registration considered by the correction, with its decision.</summary>
public class PreviewRow
{
    public long id;
    public string regno = "";
    public string studentName = "";
    public string progId = "";
    public string courseCode = "";
    public string acadYear = "";
    public int semester;
    public string courseStatus = "";
    public string markStage = "";
    public int? total;
    public string verdict = "";
    public string note = "";
    public int satelliteCount;

    // The record already sitting at the destination, when there is one. Shown in the
    // preview beside the source mark so the operator can see which one will survive.
    public long targetId;
    public int? targetTotal;
    public string targetStage = "";
}

public class PreviewResult
{
    public bool success = true;
    public string message = "";
    public string scopeLabel = "";
    public string roleNote = "";
    public int scanned;
    public int actionable;
    public int skipped;
    public int students;
    public int satelliteRows;
    public string checksum = "";        // guards against drift between preview and apply
    public List<PreviewRow> rows = new List<PreviewRow>();
    public List<object> verdictCounts = new List<object>();
    public string sourceCourseName = "";
    public string targetCourseName = "";
    public bool targetExists;
    public double sourceCredit;
    public double targetCredit;
    public bool creditConflict;
}

public class ApplyResult
{
    public bool success = true;
    public string message = "";
    public string batchRef = "";
    public long batchId;
    public int rowsApplied;
    public int rowsSkipped;
    public int students;
    public int satelliteRows;
    public int residual;
    public string tablesTouched = "";
    public int durationMs;
}
