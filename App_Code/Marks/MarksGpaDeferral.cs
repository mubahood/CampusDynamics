using System;
using System.Collections.Generic;
using MySql.Data.MySqlClient;

/// <summary>
/// Collects the (student, academic year, semester) buckets touched by a batch publish so
/// the semester-GPA rewrite can happen ONCE per bucket at the end, instead of once per
/// published mark.
///
/// Why: publishing a single mark used to run three extra statements —
///   1. ComputeSemesterGpa   (aggregate over the student's semester)
///   2. ComputeStudentCgpa   (aggregate over the student's ENTIRE result history)
///   3. UPDATE acad_results SET gpa ... WHERE regno AND acad AND semester
/// A student with 8 courses in a semester therefore paid for all three 8 times over,
/// and every one of those runs produced the identical final answer.
///
/// Worse, step 3 write-locks every acad_results row for that student/semester. Repeating
/// it per course multiplied the lock footprint of a publish batch for no benefit — a
/// direct contributor to the lock convoys and deadlocks this refactor targets.
///
/// The CGPA (step 2) was pure waste in a batch: its only consumer was the human-readable
/// per-row success message, which no batch caller reads. It is skipped entirely when
/// deferring, and never persisted anywhere.
/// </summary>
public class MarksGpaDeferral
{
    private readonly Dictionary<string, Bucket> _buckets = new Dictionary<string, Bucket>(StringComparer.Ordinal);

    private class Bucket
    {
        public string Regno;
        public string AcadYear;
        public int Semester;
    }

    /// <summary>Number of distinct (student, year, semester) recomputes still owed.</summary>
    public int PendingCount { get { return _buckets.Count; } }

    /// <summary>Note that this student's semester needs its GPA rewritten.</summary>
    public void Touch(string regno, string acadYear, int semester)
    {
        if (string.IsNullOrEmpty(regno)) return;
        string key = regno + "" + (acadYear ?? "") + "" + semester.ToString();
        if (_buckets.ContainsKey(key)) return;
        _buckets[key] = new Bucket { Regno = regno, AcadYear = acadYear ?? "", Semester = semester };
    }

    public void Clear() { _buckets.Clear(); }

    /// <summary>
    /// Snapshot of the outstanding buckets, ordered deterministically by (regno, acad,
    /// semester). The ordering is not cosmetic: applying GPA updates in a stable order
    /// across concurrent sessions is what stops two publishes from grabbing the same
    /// acad_results rows in opposite orders and deadlocking.
    /// </summary>
    public List<string[]> Snapshot()
    {
        var list = new List<string[]>();
        foreach (Bucket b in _buckets.Values)
            list.Add(new string[] { b.Regno, b.AcadYear, b.Semester.ToString() });
        list.Sort(delegate(string[] a, string[] b)
        {
            int c = string.CompareOrdinal(a[0], b[0]);
            if (c != 0) return c;
            c = string.CompareOrdinal(a[1], b[1]);
            if (c != 0) return c;
            return string.CompareOrdinal(a[2], b[2]);
        });
        return list;
    }

    /// <summary>
    /// Rewrite acad_results.gpa for every collected bucket, then forget them.
    /// Runs inside whatever transaction the caller supplies (pass null for autocommit).
    /// Returns the number of buckets processed.
    /// </summary>
    public int Flush(MySqlConnection conn, MySqlTransaction tx, string resultsCreditCol)
    {
        List<string[]> buckets = Snapshot();
        if (buckets.Count == 0) return 0;

        string cu = string.IsNullOrEmpty(resultsCreditCol) ? "CreditUnits" : resultsCreditCol;

        // Single round-trip per bucket: compute the weighted mean and stamp it in one
        // statement, rather than SELECT-then-UPDATE.
        string sql =
            "UPDATE acad_results t" +
            " JOIN (SELECT ROUND(SUM(COALESCE(gradept,0) * COALESCE(NULLIF(" + cu + ",0),3)) /" +
            "              NULLIF(SUM(COALESCE(NULLIF(" + cu + ",0),3)), 0), 2) AS g" +
            "       FROM acad_results" +
            "       WHERE regno=@regno AND acad=@acad AND semester=@sem) x" +
            " SET t.gpa = x.g" +
            " WHERE t.regno=@regno AND t.acad=@acad AND t.semester=@sem";

        int done = 0;
        foreach (string[] b in buckets)
        {
            using (MySqlCommand cmd = new MySqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@regno", b[0]);
                cmd.Parameters.AddWithValue("@acad", b[1]);
                cmd.Parameters.AddWithValue("@sem", int.Parse(b[2]));
                cmd.ExecuteNonQuery();
            }
            done++;
        }
        _buckets.Clear();
        return done;
    }
}
