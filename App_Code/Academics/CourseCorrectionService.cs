using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

// =====================================================================
//  COURSE RECORDS CORRECTION CENTRE — the engine.
//
//  Preview and Apply are driven by ONE candidate loader and ONE verdict
//  function, so they can never disagree. Apply re-runs both inside the
//  transaction and compares a checksum taken at preview time; if anything
//  moved in between, the batch aborts having written nothing.
//
//  Every record touched is snapshotted whole (before + after) into
//  acad_correction_row in the same transaction as the write, so an applied
//  change can never exist without its snapshot.
//
//  SET-BASED BY DESIGN. Real batches reach 5,000+ registrations (FND1101B
//  alone carries 5,270). A row-at-a-time implementation would fire ~60,000
//  statements inside one transaction and hold locks for minutes. Instead
//  every phase reads, writes and records in chunks, and the after-image is
//  computed in memory rather than read back — the same batch costs a few
//  hundred statements. A chunk that trips a unique index falls back to
//  row-at-a-time so one bad record cannot fail its neighbours.
//
//  Governing rule: this module never deletes a mark and never overwrites
//  one mark with another. Anything that would require it is reported.
//
//  Both schemas are InnoDB on one server, so a single connection wraps
//  campus_dynamics and campus_dynamics_portal in one transaction.
// =====================================================================
public static class CourseCorrectionService
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };

    public const int MaxBatchRows = 20000;
    private const int ReadChunk = 400;    // ids per SELECT / UPDATE
    private const int WriteChunk = 150;   // snapshot rows per INSERT
    private const string SourcePage = "CourseCorrectionCentre";

    public static string ConnStr()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        return cs != null ? cs.ConnectionString
                          : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";
    }

    // ─────────────────────────────────────────────────────────────────
    //  Helpers
    // ─────────────────────────────────────────────────────────────────
    private static string S(IDataRecord r, int i) { return r.IsDBNull(i) ? "" : Convert.ToString(r[i]).Trim(); }
    private static int I(IDataRecord r, int i) { return r.IsDBNull(i) ? 0 : Convert.ToInt32(r[i]); }
    private static string Key(params string[] parts) { return string.Join("", parts).ToUpperInvariant(); }

    private static MySqlCommand Cmd(string sql, MySqlConnection c, MySqlTransaction t)
    {
        var cmd = new MySqlCommand(sql, c, t);
        cmd.CommandTimeout = 900;
        return cmd;
    }

    private static List<List<T>> Chunks<T>(List<T> src, int size)
    {
        var outp = new List<List<T>>();
        for (int i = 0; i < src.Count; i += size)
            outp.Add(src.GetRange(i, Math.Min(size, src.Count - i)));
        return outp;
    }

    private static string Quote(string v)
    {
        return "'" + (v ?? "").Replace("\\", "\\\\").Replace("'", "''") + "'";
    }

    /// <summary>Which (student, course) pairs in the set already carry a published result. A
    /// registration can look unmarked while a result exists, and removing it would orphan that
    /// result — so the result counts as a mark for the purposes of the decision.</summary>
    private static HashSet<string> ResultBearingStudents(MySqlConnection c, MySqlTransaction t, List<PreviewRow> rows)
    {
        var found = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var regnos = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var r in rows) if (seen.Add(r.regno)) regnos.Add(r.regno);
        if (regnos.Count == 0) return found;

        foreach (var chunk in Chunks(regnos, ReadChunk))
        {
            try
            {
                using (var cmd = Cmd("SELECT regno, courseid FROM campus_dynamics.acad_results WHERE regno IN (" + InList(chunk) + ")", c, t))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) found.Add(S(r, 0) + "|" + S(r, 1));
            }
            catch { }
        }
        return found;
    }

    private static string InList(IEnumerable<string> vals)
    {
        var sb = new StringBuilder();
        foreach (var v in vals) { if (sb.Length > 0) sb.Append(","); sb.Append(Quote(v)); }
        return sb.Length == 0 ? "''" : sb.ToString();
    }

    private static string InListRaw(IEnumerable<object> vals)
    {
        var sb = new StringBuilder();
        foreach (var v in vals) { if (sb.Length > 0) sb.Append(","); sb.Append(Quote(Convert.ToString(v))); }
        return sb.Length == 0 ? "''" : sb.ToString();
    }

    /// <summary>Attribute any mark movement to the real user — the acad_results triggers read
    /// this by CONNECTION_ID() and would otherwise record 'system'.</summary>
    private static void SetAuditContext(MySqlConnection c, MySqlTransaction t, string user, string reason, string ip)
    {
        try
        {
            using (var cmd = Cmd(
                "INSERT INTO campus_dynamics.mark_audit_context (conn_id, actor, source, reason, ip, set_at) " +
                "VALUES (CONNECTION_ID(), @a, @s, @r, @i, NOW()) " +
                "ON DUPLICATE KEY UPDATE actor=VALUES(actor), source=VALUES(source), reason=VALUES(reason), ip=VALUES(ip), set_at=NOW()", c, t))
            {
                cmd.Parameters.AddWithValue("@a", (object)user ?? "");
                cmd.Parameters.AddWithValue("@s", SourcePage);
                cmd.Parameters.AddWithValue("@r", Trunc(reason, 200));
                cmd.Parameters.AddWithValue("@i", (object)ip ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
        catch { /* attribution is best-effort and must never stop a correction */ }
    }

    private static object Trunc(string s, int max)
    {
        if (s == null) return DBNull.Value;
        return s.Length <= max ? s : s.Substring(0, max);
    }

    // ─────────────────────────────────────────────────────────────────
    //  Student list — accepts either form of number
    //
    //  Staff work from whichever number is in front of them: the student
    //  number (MRU2027000002) or the entry number (27/U/BAED/0001/K/DAY).
    //  Both are accepted in the same box and resolved to student numbers
    //  here. Entry numbers contain slashes, which is why the list is split
    //  on commas, semicolons and whitespace only.
    //
    //  A token that matches no entry number is still passed through as a
    //  student number, because some students hold a registration without an
    //  acad_student row (see the orphan backfill of August 2026) and must
    //  not silently drop out of a correction.
    // ─────────────────────────────────────────────────────────────────
    private class StudentResolution
    {
        public List<string> Regnos = new List<string>();
        public Dictionary<string, string> TokenToRegno = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        public int FromEntryNo;
    }

    private static StudentResolution ResolveStudents(MySqlConnection c, MySqlTransaction t, List<string> tokens)
    {
        var res = new StudentResolution();
        if (tokens.Count == 0) return res;

        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var tk in tokens)
        {
            res.TokenToRegno[tk] = tk;                 // assume it is a student number
            if (seen.Add(tk)) res.Regnos.Add(tk);
        }

        foreach (var chunk in Chunks(tokens, ReadChunk))
        {
            string inl = InList(chunk);
            try
            {
                using (var cmd = Cmd("SELECT regno, IFNULL(entryno,'') FROM campus_dynamics.acad_student " +
                                     "WHERE entryno IN (" + inl + ")", c, t))
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                    {
                        string rg = S(r, 0), en = S(r, 1);
                        if (rg == "" || en == "") continue;
                        res.TokenToRegno[en] = rg;     // it was an entry number after all
                        if (seen.Add(rg)) { res.Regnos.Add(rg); res.FromEntryNo++; }
                    }
            }
            catch { /* an unreadable lookup must not lose the student numbers already collected */ }
        }
        return res;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Candidate loading
    // ─────────────────────────────────────────────────────────────────
    private static string BuildMasterWhere(CorrectionConfig cfg, MarksScope scope, Dictionary<string, object> p,
                                           List<string> studentRegnos)
    {
        var w = new StringBuilder(" WHERE 1=1 ");

        if (cfg.IsMarksReset)
        {
            // The course code is optional here: a reset may be aimed at one course, or at a
            // programme or a named list of students across whatever they are registered for.
            if (!string.IsNullOrEmpty(cfg.sourceCode)) { w.Append(" AND cr.courseID=@srcCode "); p["@srcCode"] = cfg.sourceCode; }
            if (!string.IsNullOrEmpty(cfg.sourceYear)) { w.Append(" AND cr.acad_year=@srcYear "); p["@srcYear"] = cfg.sourceYear; }
            if (!string.IsNullOrEmpty(cfg.sourceSemester)) { w.Append(" AND cr.semester=@srcSem "); p["@srcSem"] = cfg.sourceSemester; }
        }
        else if (cfg.IsRemoval)
        {
            // What should not have been registered. The two curriculum-driven bases are the
            // reason this operation exists: a student registered for a subject that was never
            // theirs to take.
            if (cfg.removalBasis == RemovalBasis.NotInCurriculum)
            {
                w.Append(" AND NOT EXISTS (SELECT 1 FROM campus_dynamics.acad_programmecourses pc " +
                         "  WHERE pc.progcode=cr.prog_id AND pc.course_code=cr.courseID) ");
            }
            else if (cfg.removalBasis == RemovalBasis.OtherSpecialisation)
            {
                // The course is specialised, and none of its curriculum entries is either core
                // (specialisation 0/NULL) or the student's own specialisation.
                w.Append(" AND EXISTS (SELECT 1 FROM campus_dynamics.acad_programmecourses pc " +
                         "  WHERE pc.progcode=cr.prog_id AND pc.course_code=cr.courseID AND IFNULL(pc.specialisation_id,0)>0) " +
                         " AND NOT EXISTS (SELECT 1 FROM campus_dynamics.acad_programmecourses pc2 " +
                         "  WHERE pc2.progcode=cr.prog_id AND pc2.course_code=cr.courseID " +
                         "    AND (IFNULL(pc2.specialisation_id,0)=0 " +
                         "         OR pc2.specialisation_id = CAST(NULLIF(TRIM(IFNULL(s.specialisation,'')),'') AS UNSIGNED))) ");
            }
            else
            {
                w.Append(" AND cr.courseID=@srcCode "); p["@srcCode"] = cfg.sourceCode;
            }
            if (!string.IsNullOrEmpty(cfg.sourceYear)) { w.Append(" AND cr.acad_year=@srcYear "); p["@srcYear"] = cfg.sourceYear; }
            if (!string.IsNullOrEmpty(cfg.sourceSemester)) { w.Append(" AND cr.semester=@srcSem "); p["@srcSem"] = cfg.sourceSemester; }
        }
        else if (cfg.operation == CorrectionOp.TermTransfer)
        {
            w.Append(" AND cr.acad_year=@srcYear "); p["@srcYear"] = cfg.sourceYear;
            if (!string.IsNullOrEmpty(cfg.sourceSemester)) { w.Append(" AND cr.semester=@srcSem "); p["@srcSem"] = cfg.sourceSemester; }
            if (!string.IsNullOrEmpty(cfg.sourceCode)) { w.Append(" AND cr.courseID=@srcCode "); p["@srcCode"] = cfg.sourceCode; }
        }
        else
        {
            w.Append(" AND cr.courseID=@srcCode "); p["@srcCode"] = cfg.sourceCode;
            if (!string.IsNullOrEmpty(cfg.sourceYear)) { w.Append(" AND cr.acad_year=@srcYear "); p["@srcYear"] = cfg.sourceYear; }
            if (!string.IsNullOrEmpty(cfg.sourceSemester)) { w.Append(" AND cr.semester=@srcSem "); p["@srcSem"] = cfg.sourceSemester; }
        }

        if (!string.IsNullOrEmpty(cfg.programme)) { w.Append(" AND cr.prog_id=@prog "); p["@prog"] = cfg.programme; }
        int spec;
        if (!string.IsNullOrEmpty(cfg.specialisation) && int.TryParse(cfg.specialisation, out spec) && spec > 0)
        {
            // acad_student.specialisation is text that holds a spec_id, so it is cast rather
            // than compared as a string (see §2.5b of the plan).
            w.Append(" AND CAST(NULLIF(TRIM(IFNULL(s.specialisation,'')),'') AS UNSIGNED)=@spec ");
            p["@spec"] = spec;
        }
        if (!string.IsNullOrEmpty(cfg.markStage)) { w.Append(" AND IFNULL(cr.mark_stage,'NOT_ENTERED')=@stage "); p["@stage"] = cfg.markStage; }
        if (!string.IsNullOrEmpty(cfg.registrationType)) { w.Append(" AND cr.registration_type=@rtype "); p["@rtype"] = cfg.registrationType; }
        if (!string.IsNullOrEmpty(cfg.courseStatus)) { w.Append(" AND cr.course_status=@cstatus "); p["@cstatus"] = cfg.courseStatus; }
        if (!string.IsNullOrEmpty(cfg.faculty)) { w.Append(" AND pr.faculty_code=@fac "); p["@fac"] = cfg.faculty; }
        int dep;
        if (!string.IsNullOrEmpty(cfg.department) && int.TryParse(cfg.department, out dep)) { w.Append(" AND pr.department_id=@dep "); p["@dep"] = dep; }

        if (studentRegnos != null && studentRegnos.Count > 0)
        {
            var sb = new StringBuilder();
            for (int i = 0; i < studentRegnos.Count; i++)
            {
                if (i > 0) sb.Append(",");
                string pn = "@stu" + i; sb.Append(pn); p[pn] = studentRegnos[i];
            }
            w.Append(" AND cr.regno IN (").Append(sb).Append(") ");
        }

        // Scope is applied in SQL. The browser cannot widen it.
        w.Append(scope.ProgFilter("cr", "prog_id"));
        return w.ToString();
    }

    private static List<PreviewRow> LoadCandidates(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg,
                                                   MarksScope scope, StudentResolution resolution = null)
    {
        var rows = new List<PreviewRow>();
        var p = new Dictionary<string, object>();
        var tokens = cfg.StudentList();
        var sr = tokens.Count > 0 ? ResolveStudents(c, t, tokens) : new StudentResolution();
        if (resolution != null) { resolution.Regnos = sr.Regnos; resolution.TokenToRegno = sr.TokenToRegno; resolution.FromEntryNo = sr.FromEntryNo; }
        string where = BuildMasterWhere(cfg, scope, p, sr.Regnos);

        string sql =
            "SELECT cr.ID, cr.regno, cr.courseID, cr.acad_year, cr.semester, cr.course_status, " +
            "       IFNULL(cr.mark_stage,'NOT_ENTERED') stage, cr.provisional_total_marks, cr.prog_id, " +
            "       CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) nm " +
            "  FROM campus_dynamics_portal.acad_course_registration cr " +
            "  LEFT JOIN campus_dynamics.acad_student s ON s.regno=cr.regno " +
            "  LEFT JOIN campus_dynamics.acad_programme pr ON pr.progcode=cr.prog_id " +
            where +
            " ORDER BY cr.regno, cr.acad_year, cr.semester, cr.ID LIMIT " + (MaxBatchRows + 1);

        using (var cmd = Cmd(sql, c, t))
        {
            foreach (var kv in p) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                    rows.Add(new PreviewRow
                    {
                        id = Convert.ToInt64(r[0]),
                        regno = S(r, 1),
                        courseCode = S(r, 2),
                        acadYear = S(r, 3),
                        semester = I(r, 4),
                        courseStatus = S(r, 5),
                        markStage = S(r, 6),
                        total = r.IsDBNull(7) ? (int?)null : Convert.ToInt32(r[7]),
                        progId = S(r, 8),
                        studentName = S(r, 9)
                    });
        }
        return rows;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Verdicts — set-wise, and chunked so a 20,000-student batch does not
    //  build a single enormous IN list.
    // ─────────────────────────────────────────────────────────────────
    private static void ApplyVerdicts(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, List<PreviewRow> rows)
    {
        if (rows.Count == 0) return;

        // Removal has no destination, so it needs no collision analysis — only a decision
        // about marks, which is the one thing that makes a removal irreversible in spirit.
        // Marks reset needs no destination either — only whether there is a mark to erase.
        if (cfg.IsMarksReset)
        {
            var hasResult = ResultBearingStudents(c, t, rows);
            foreach (var row in rows)
            {
                bool marked = row.total.HasValue
                              || (row.markStage != "" && row.markStage != "NOT_ENTERED")
                              || hasResult.Contains(row.regno + "|" + row.courseCode);
                row.verdict = marked ? CorrectionVerdict.WillReset : CorrectionVerdict.SkippedNoMarks;
            }
            return;
        }

        if (cfg.IsRemoval)
        {
            var hasResult = ResultBearingStudents(c, t, rows);
            foreach (var row in rows)
            {
                bool marked = row.total.HasValue
                              || (row.markStage != "" && row.markStage != "NOT_ENTERED")
                              || hasResult.Contains(row.regno + "|" + row.courseCode);
                if (marked && !cfg.removeMarked) { row.verdict = CorrectionVerdict.SkippedHasMarks; continue; }
                if (marked) row.note = "A mark is recorded against this registration and will be removed with it.";
                row.verdict = CorrectionVerdict.WillRemove;
            }
            return;
        }

        bool isTerm = cfg.operation == CorrectionOp.TermTransfer;
        var regnos = new List<string>();
        var seenReg = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var r in rows) if (seenReg.Add(r.regno)) regnos.Add(r.regno);

        // 1) Destination slots already occupied in the registration table. The occupant's id,
        //    mark and stage are carried too, so a duplicate can be settled on the evidence
        //    rather than merely reported.
        var occupied = new Dictionary<string, PreviewRow>();
        foreach (var chunk in Chunks(regnos, ReadChunk))
        {
            string sql = isTerm
                ? "SELECT regno, courseID, course_status, ID, provisional_total_marks, IFNULL(mark_stage,'NOT_ENTERED') " +
                  "FROM campus_dynamics_portal.acad_course_registration " +
                  "WHERE regno IN (" + InList(chunk) + ") AND acad_year=@ty AND semester=@ts"
                : "SELECT regno, acad_year, semester, course_status, ID, provisional_total_marks, IFNULL(mark_stage,'NOT_ENTERED') " +
                  "FROM campus_dynamics_portal.acad_course_registration " +
                  "WHERE regno IN (" + InList(chunk) + ") AND courseID=@tc";
            using (var cmd = Cmd(sql, c, t))
            {
                if (isTerm) { cmd.Parameters.AddWithValue("@ty", cfg.targetYear); cmd.Parameters.AddWithValue("@ts", cfg.targetSemester); }
                else cmd.Parameters.AddWithValue("@tc", cfg.targetCode);
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                    {
                        string k; PreviewRow d = new PreviewRow();
                        if (isTerm)
                        {
                            k = Key(S(r, 0), S(r, 1), S(r, 2));
                            d.id = Convert.ToInt64(r[3]);
                            d.total = r.IsDBNull(4) ? (int?)null : Convert.ToInt32(r[4]);
                            d.markStage = S(r, 5);
                        }
                        else
                        {
                            k = Key(S(r, 0), S(r, 1), I(r, 2).ToString(CultureInfo.InvariantCulture), S(r, 3));
                            d.id = Convert.ToInt64(r[4]);
                            d.total = r.IsDBNull(5) ? (int?)null : Convert.ToInt32(r[5]);
                            d.markStage = S(r, 6);
                        }
                        occupied[k] = d;
                    }
            }
        }

        // 2) acad_results is UNIQUE on (regno, courseid) with no term, so a code transfer
        //    collides whenever the student already holds a result on the destination code.
        var resultOnTarget = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var resultOnSource = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (!isTerm && cfg.moveResults)
        {
            foreach (var chunk in Chunks(regnos, ReadChunk))
                using (var cmd = Cmd("SELECT regno, courseid FROM campus_dynamics.acad_results " +
                                     "WHERE regno IN (" + InList(chunk) + ") AND courseid IN (@sc,@tc)", c, t))
                {
                    cmd.Parameters.AddWithValue("@sc", cfg.sourceCode);
                    cmd.Parameters.AddWithValue("@tc", cfg.targetCode);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string rg = S(r, 0), cc = S(r, 1);
                            if (string.Equals(cc, cfg.targetCode, StringComparison.OrdinalIgnoreCase)) resultOnTarget.Add(rg);
                            else resultOnSource.Add(rg);
                        }
                }
        }

        // 3) Rows in THIS batch that would land on the same destination slot as each other.
        //    Without this, two source rows both look free and the second is rejected by the
        //    index mid-run. Detecting it here keeps the preview honest.
        var claimed = new HashSet<string>();

        foreach (var row in rows)
        {
            if (!isTerm && string.Equals(row.courseCode, cfg.targetCode, StringComparison.OrdinalIgnoreCase))
            { row.verdict = CorrectionVerdict.SkippedSameTarget; continue; }

            if (isTerm && string.Equals(row.acadYear, cfg.targetYear, StringComparison.OrdinalIgnoreCase)
                       && row.semester.ToString(CultureInfo.InvariantCulture) == cfg.targetSemester)
            { row.verdict = CorrectionVerdict.SkippedSameTarget; continue; }

            if (!cfg.includePublished && row.markStage == "PUBLISHED")
            { row.verdict = CorrectionVerdict.SkippedPublished; continue; }

            string slot = isTerm
                ? Key(row.regno, row.courseCode, row.courseStatus)
                : Key(row.regno, row.acadYear, row.semester.ToString(CultureInfo.InvariantCulture), row.courseStatus);

            PreviewRow dest;
            if (occupied.TryGetValue(slot, out dest))
            {
                row.targetId = dest.id;
                row.targetTotal = dest.total;
                row.targetStage = dest.markStage;
                row.verdict = cfg.Resolving ? Settle(row.total, dest.total) : CorrectionVerdict.SkippedDuplicate;
                continue;
            }

            if (!claimed.Add(slot))
            { row.verdict = CorrectionVerdict.SkippedDuplicate; row.note = "Another record in this same correction already moves to that slot."; continue; }

            if (!isTerm && cfg.moveResults && resultOnSource.Contains(row.regno) && resultOnTarget.Contains(row.regno))
            {
                // Under the settling policy the two results are compared and the better one kept,
                // exactly as for the registration; otherwise the record is left alone.
                row.verdict = cfg.Resolving ? CorrectionVerdict.Moved : CorrectionVerdict.SkippedResultClash;
                if (cfg.Resolving) row.note = "The result on the destination code is compared with this one; the higher mark is kept.";
                continue;
            }

            row.verdict = CorrectionVerdict.Moved;
        }
    }

    /// <summary>Which way a duplicate is settled, comparing the source mark with the one already
    /// on the destination. The better mark survives on the destination and the duplicate source
    /// record is removed, so nothing is left behind on the retired code.
    ///   destination has no mark      → fill it from the source
    ///   source is higher             → overwrite the destination
    ///   destination equal or higher  → keep it, discard the source
    /// A missing mark never beats a real one, and equal marks never cause a needless rewrite.</summary>
    private static string Settle(int? sourceMark, int? destMark)
    {
        if (sourceMark.HasValue && !destMark.HasValue) return CorrectionVerdict.ResolvedFilled;
        if (sourceMark.HasValue && destMark.HasValue && sourceMark.Value > destMark.Value) return CorrectionVerdict.ResolvedOverwrite;
        return CorrectionVerdict.ResolvedDiscard;
    }

    /// <summary>The mark-bearing columns copied from a source registration onto the destination
    /// when the source wins. Provenance travels with the mark so the audit trail stays truthful
    /// about who entered, approved and published it.</summary>
    private static readonly string[] MarkColumns = {
        "provisional_course_work_marks", "provisional_exam_marks", "provisional_total_marks",
        "provisional_marks_status", "provisional_marks_review_comments", "provisional_marks_reviewed_by",
        "provisional_marks_review_date", "provisional_submitted_by", "provisional_published_by",
        "provisional_published_date", "mark_stage", "capture_record_id", "approve_record_id",
        "publish_record_id", "mark_stage_changed_at", "mark_stage_changed_by"
    };

    /// <summary>The equivalent for a published result row.</summary>
    private static readonly string[] ResultColumns = {
        "score", "grade", "gradept", "gpa", "CreditUnits", "result_comment"
    };

    /// <summary>Fingerprint of the candidate set and its relevant state. Any edit between
    /// preview and apply changes it, and the batch refuses to run.</summary>
    private static string Checksum(List<PreviewRow> rows)
    {
        var sb = new StringBuilder();
        foreach (var r in rows)
            sb.Append(r.id).Append('|').Append(r.courseCode).Append('|').Append(r.acadYear).Append('|')
              .Append(r.semester).Append('|').Append(r.courseStatus).Append('|').Append(r.markStage).Append('|')
              .Append(r.total.HasValue ? r.total.Value.ToString(CultureInfo.InvariantCulture) : "-").Append('|')
              // the destination is part of the decision, so a change there must invalidate it too
              .Append(r.targetId).Append('|')
              .Append(r.targetTotal.HasValue ? r.targetTotal.Value.ToString(CultureInfo.InvariantCulture) : "-").Append(';');
        using (var sha = SHA1.Create())
            return BitConverter.ToString(sha.ComputeHash(Encoding.UTF8.GetBytes(sb.ToString()))).Replace("-", "").Substring(0, 20);
    }

    // ─────────────────────────────────────────────────────────────────
    //  PREVIEW
    // ─────────────────────────────────────────────────────────────────
    public static PreviewResult Preview(CorrectionConfig cfg, MarksScope scope)
    {
        var res = new PreviewResult { scopeLabel = scope.Label, roleNote = scope.RoleNote };
        string err = Validate(cfg, scope);
        if (err != null) { res.success = false; res.message = err; return res; }

        using (var c = new MySqlConnection(ConnStr()))
        {
            c.Open();
            LoadCourseFacts(c, null, cfg, res);

            var resolution = new StudentResolution();
            var rows = LoadCandidates(c, null, cfg, scope, resolution);
            res.resolvedFromEntryNo = resolution.FromEntryNo;

            // Any number that produced no registration at all is named, so a typo or a student
            // who simply is not on this course cannot pass unnoticed.
            var withRows = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var r in rows) withRows.Add(r.regno);
            foreach (var kv in resolution.TokenToRegno)
                if (!withRows.Contains(kv.Value) && !res.unmatchedStudents.Contains(kv.Key))
                    res.unmatchedStudents.Add(kv.Key);

            if (rows.Count > MaxBatchRows)
            {
                res.success = false;
                res.message = "This selection covers more than " + MaxBatchRows.ToString("N0") +
                              " registrations. Narrow it by programme, academic year or semester and try again.";
                return res;
            }
            ApplyVerdicts(c, null, cfg, rows);
            res.satelliteRows = cfg.IsMarksReset ? 0 : CountSatellites(c, null, cfg, rows);
            if (cfg.IsMarksReset) PreviewResetImpact(c, cfg, rows, res);

            res.rows = rows;
            res.scanned = rows.Count;
            res.checksum = Checksum(rows);

            var counts = new Dictionary<string, int>();
            var studs = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var r in rows)
            {
                if (!counts.ContainsKey(r.verdict)) counts[r.verdict] = 0;
                counts[r.verdict]++;
                if (CorrectionVerdict.IsActionable(r.verdict)) { res.actionable++; studs.Add(r.regno); }
                else res.skipped++;
            }
            res.students = studs.Count;
            foreach (var kv in counts)
                res.verdictCounts.Add(new { verdict = kv.Key, label = CorrectionVerdict.Explain(kv.Key), count = kv.Value });
        }
        return res;
    }

    /// <summary>What a reset would cost, worked out before anything is written: how many
    /// published results and component marks disappear, and what each student's CGPA becomes.
    /// CGPA is derived, so this is the only way to see the effect in advance.</summary>
    private static void PreviewResetImpact(MySqlConnection c, CorrectionConfig cfg, List<PreviewRow> rows, PreviewResult res)
    {
        var byStudent = new Dictionary<string, List<PreviewRow>>(StringComparer.OrdinalIgnoreCase);
        foreach (var r in rows)
        {
            if (r.verdict != CorrectionVerdict.WillReset) continue;
            List<PreviewRow> l;
            if (!byStudent.TryGetValue(r.regno, out l)) { l = new List<PreviewRow>(); byStudent[r.regno] = l; }
            l.Add(r);
        }
        if (byStudent.Count == 0) return;

        foreach (var kv in byStudent)
        {
            double before = Cgpa(c, null, kv.Key);

            // What the CGPA becomes: the same credit-weighted mean, with the rows about to be
            // erased taken out. Computed rather than guessed, and without touching anything.
            var codes = new List<string>();
            foreach (var r in kv.Value) if (!codes.Contains(r.courseCode)) codes.Add(r.courseCode);
            // Both figures are read one after the other, never nested — a second command on a
            // connection whose reader is still open throws, and a swallowed exception here would
            // quietly report "no change" for a reset that does change the CGPA.
            double after = before; int losing = 0;
            double lostPts = 0, lostCu = 0, allPts = 0, allCu = 0;

            using (var cmd = Cmd(
                "SELECT IFNULL(SUM(CreditUnits*gradept),0), IFNULL(SUM(CreditUnits),0), COUNT(*) " +
                "FROM campus_dynamics.acad_results WHERE regno=@r AND courseid IN (" + InList(codes) + ")", c, null))
            {
                cmd.Parameters.AddWithValue("@r", kv.Key);
                using (var rr = cmd.ExecuteReader())
                    if (rr.Read())
                    {
                        lostPts = rr.IsDBNull(0) ? 0 : Convert.ToDouble(rr[0]);
                        lostCu = rr.IsDBNull(1) ? 0 : Convert.ToDouble(rr[1]);
                        losing = rr.IsDBNull(2) ? 0 : Convert.ToInt32(rr[2]);
                    }
            }

            using (var cmd = Cmd("SELECT IFNULL(SUM(CreditUnits*gradept),0), IFNULL(SUM(CreditUnits),0) " +
                                 "FROM campus_dynamics.acad_results WHERE regno=@r", c, null))
            {
                cmd.Parameters.AddWithValue("@r", kv.Key);
                using (var rr = cmd.ExecuteReader())
                    if (rr.Read())
                    {
                        allPts = rr.IsDBNull(0) ? 0 : Convert.ToDouble(rr[0]);
                        allCu = rr.IsDBNull(1) ? 0 : Convert.ToDouble(rr[1]);
                    }
            }

            double cuLeft = allCu - lostCu;
            after = cuLeft > 0 ? Math.Round((allPts - lostPts) / cuLeft, 2) : 0;

            res.publishedResults += losing;
            res.cgpaImpact.Add(new
            {
                regno = kv.Key,
                courses = kv.Value.Count,
                resultsLost = losing,
                cgpaBefore = Math.Round(before, 2),
                cgpaAfter = after,
                change = Math.Round(after - Math.Round(before, 2), 2)
            });
        }
    }

    private static string Validate(CorrectionConfig cfg, MarksScope scope)
    {
        if (!scope.HasAccess) return "You do not have a marks-management scope. Contact the administrator.";

        if (cfg.IsMarksReset)
        {
            // Erasing marks is the most destructive thing in this module, so it may never run
            // across the whole institution by accident — it must be aimed at something.
            if (string.IsNullOrEmpty(cfg.sourceCode) && string.IsNullOrEmpty(cfg.programme) && string.IsNullOrEmpty(cfg.students))
                return "Choose at least a course, a programme or a list of students. A marks reset cannot be run across everything.";
            return null;
        }

        if (cfg.IsRemoval)
        {
            if (cfg.removalBasis == RemovalBasis.Code && string.IsNullOrEmpty(cfg.sourceCode))
                return "Choose the course code whose registrations should be removed.";
            if (cfg.removalBasis != RemovalBasis.Code
                && string.IsNullOrEmpty(cfg.programme) && string.IsNullOrEmpty(cfg.students) && !scope.IsAdmin)
                return "Narrow this to a programme or a list of students before removing registrations.";
            return null;
        }

        if (cfg.operation == CorrectionOp.TermTransfer)
        {
            if (string.IsNullOrEmpty(cfg.sourceYear)) return "Choose the academic year to move registrations from.";
            if (string.IsNullOrEmpty(cfg.targetYear)) return "Choose the academic year to move registrations to.";
            if (string.IsNullOrEmpty(cfg.targetSemester)) return "Choose the semester to move registrations to.";
            if (cfg.sourceYear == cfg.targetYear && cfg.sourceSemester == cfg.targetSemester)
                return "The source and destination term are the same.";
            return null;
        }

        if (string.IsNullOrEmpty(cfg.sourceCode)) return "Choose the course code to move registrations from.";
        if (string.IsNullOrEmpty(cfg.targetCode)) return "Choose the course code to move registrations to.";
        if (string.Equals(cfg.sourceCode.Trim(), cfg.targetCode.Trim(), StringComparison.OrdinalIgnoreCase))
            return "The source and destination course code are the same.";
        if (cfg.operation == CorrectionOp.CourseMerge && !scope.IsAdmin)
            return "Course Code Merge changes the catalogue for the whole institution and is restricted to administrators.";
        return null;
    }

    private static void LoadCourseFacts(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, PreviewResult res)
    {
        if (cfg.operation == CorrectionOp.TermTransfer) return;
        using (var cmd = Cmd("SELECT courseID, IFNULL(courseName,''), IFNULL(CreditUnit,0) FROM campus_dynamics.acad_course " +
                             "WHERE courseID IN (@a,@b)", c, t))
        {
            cmd.Parameters.AddWithValue("@a", cfg.sourceCode);
            cmd.Parameters.AddWithValue("@b", cfg.targetCode);
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                {
                    string code = S(r, 0);
                    if (string.Equals(code, cfg.sourceCode, StringComparison.OrdinalIgnoreCase))
                    { res.sourceCourseName = S(r, 1); res.sourceCredit = r.IsDBNull(2) ? 0 : Convert.ToDouble(r[2]); }
                    else
                    { res.targetExists = true; res.targetCourseName = S(r, 1); res.targetCredit = r.IsDBNull(2) ? 0 : Convert.ToDouble(r[2]); }
                }
        }
        res.creditConflict = res.targetExists && res.sourceCredit > 0 && res.targetCredit > 0
                             && Math.Abs(res.sourceCredit - res.targetCredit) > 0.001;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Satellite matching — the same grouping drives both the preview count
    //  and the actual move, so what is promised is what happens.
    // ─────────────────────────────────────────────────────────────────
    private class SatGroup
    {
        public string course, year; public int sem;
        public List<string> regnos = new List<string>();
    }

    private static List<SatGroup> GroupActionable(List<PreviewRow> rows)
    {
        var map = new Dictionary<string, SatGroup>();
        foreach (var r in rows)
        {
            if (!CorrectionVerdict.IsActionable(r.verdict)) continue;
            string k = Key(r.courseCode, r.acadYear, r.semester.ToString(CultureInfo.InvariantCulture));
            SatGroup g;
            if (!map.TryGetValue(k, out g))
            { g = new SatGroup { course = r.courseCode, year = r.acadYear, sem = r.semester }; map[k] = g; }
            g.regnos.Add(r.regno);
        }
        return new List<SatGroup>(map.Values);
    }

    /// <summary>Rows of a satellite table belonging to a group.
    /// OnePerCourse tables hold at most one row per (student, course) and carry no term in
    /// their key, so the term is not used to find them. Otherwise the term must match, unless
    /// the operator asked for all terms.</summary>
    private static string SatWhere(CourseTableDef def, CorrectionConfig cfg, SatGroup g, bool includeTerm)
    {
        var w = new StringBuilder(def.RegnoCol + " IN (" + InList(g.regnos) + ") AND " + def.CourseCol + "=" + Quote(g.course));
        if (includeTerm) w.Append(" AND ").Append(def.YearCol).Append("=").Append(Quote(g.year))
                          .Append(" AND ").Append(def.SemCol).Append("=").Append(g.sem);
        return w.ToString();
    }

    private static bool TermBound(CourseTableDef def, CorrectionConfig cfg)
    {
        return def.HasTerm && !def.OnePerCourse && !cfg.allTerms;
    }

    private static bool SkipSatellite(CourseTableDef def, CorrectionConfig cfg)
    {
        return !cfg.moveResults && (def.Table == "acad_results" || def.Table == "acad_transcript_results");
    }

    private static int CountSatellites(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, List<PreviewRow> rows)
    {
        var groups = GroupActionable(rows);
        if (groups.Count == 0) return 0;
        int total = 0;
        foreach (var def in CourseTableRegistry.Satellites)
        {
            if (SkipSatellite(def, cfg)) continue;
            foreach (var g in groups)
                foreach (var chunk in Chunks(g.regnos, ReadChunk))
                {
                    var sub = new SatGroup { course = g.course, year = g.year, sem = g.sem, regnos = chunk };
                    try
                    {
                        using (var cmd = Cmd("SELECT COUNT(*) FROM " + def.Qualified + " WHERE " +
                                             SatWhere(def, cfg, sub, TermBound(def, cfg)), c, t))
                        {
                            object o = cmd.ExecuteScalar();
                            if (o != null && o != DBNull.Value) total += Convert.ToInt32(o);
                        }
                    }
                    catch { /* a satellite that cannot be counted reports zero, never fatal */ }
                }
        }
        return total;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Snapshot plumbing
    // ─────────────────────────────────────────────────────────────────
    private class Pending
    {
        public CourseTableDef def;
        public object pk;
        public string regno, course, action, verdict, note;
        public Dictionary<string, object> before, after;
    }

    private static Dictionary<string, object> RowToDict(IDataRecord r)
    {
        var d = new Dictionary<string, object>();
        for (int i = 0; i < r.FieldCount; i++)
        {
            object v = r.IsDBNull(i) ? null : r.GetValue(i);
            if (v is DateTime) v = ((DateTime)v).ToString("yyyy-MM-dd HH:mm:ss");
            else if (v is byte[]) v = Convert.ToBase64String((byte[])v);
            d[r.GetName(i)] = v;
        }
        return d;
    }

    /// <summary>The after-image is computed rather than read back — it is fully determined by
    /// the before-image plus the columns being set. Halves the statement count on large batches.</summary>
    private static Dictionary<string, object> WithSets(Dictionary<string, object> before, Dictionary<string, object> sets)
    {
        var after = new Dictionary<string, object>(before);
        foreach (var kv in sets)
        {
            // match the column name as the reader returned it, whatever its casing
            string real = null;
            foreach (var k in before.Keys)
                if (string.Equals(k, kv.Key, StringComparison.OrdinalIgnoreCase)) { real = k; break; }
            after[real ?? kv.Key] = kv.Value;
        }
        return after;
    }

    private static void FlushSnapshots(MySqlConnection c, MySqlTransaction t, long batchId, List<Pending> pend)
    {
        if (pend.Count == 0) return;
        foreach (var chunk in Chunks(pend, WriteChunk))
        {
            var sb = new StringBuilder(
                "INSERT INTO campus_dynamics.acad_correction_row " +
                "(batch_id, db_name, table_name, pk_column, pk_value, regno, course_code, action, verdict, before_json, after_json, note) VALUES ");
            var cmd = Cmd("", c, t);
            for (int i = 0; i < chunk.Count; i++)
            {
                if (i > 0) sb.Append(',');
                sb.Append("(@b,@db").Append(i).Append(",@tb").Append(i).Append(",@pc").Append(i).Append(",@pv").Append(i)
                  .Append(",@rg").Append(i).Append(",@cc").Append(i).Append(",@ac").Append(i).Append(",@vd").Append(i)
                  .Append(",@bj").Append(i).Append(",@aj").Append(i).Append(",@nt").Append(i).Append(")");
                var x = chunk[i];
                cmd.Parameters.AddWithValue("@db" + i, x.def.Db);
                cmd.Parameters.AddWithValue("@tb" + i, x.def.Table);
                cmd.Parameters.AddWithValue("@pc" + i, x.def.PkCol);
                cmd.Parameters.AddWithValue("@pv" + i, Convert.ToString(x.pk));
                cmd.Parameters.AddWithValue("@rg" + i, (object)x.regno ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@cc" + i, (object)x.course ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@ac" + i, x.action);
                cmd.Parameters.AddWithValue("@vd" + i, x.verdict);
                cmd.Parameters.AddWithValue("@bj" + i, x.before == null ? (object)DBNull.Value : Json.Serialize(x.before));
                cmd.Parameters.AddWithValue("@aj" + i, x.after == null ? (object)DBNull.Value : Json.Serialize(x.after));
                cmd.Parameters.AddWithValue("@nt" + i, Trunc(x.note, 300));
            }
            cmd.Parameters.AddWithValue("@b", batchId);
            cmd.CommandText = sb.ToString();
            using (cmd) cmd.ExecuteNonQuery();
        }
        pend.Clear();
    }

    /// <summary>Update a chunk of rows in one statement. If the chunk trips a unique index the
    /// whole statement is rejected, so it is retried row by row — one bad record must not take
    /// its neighbours down. Returns the primary keys that were actually written.</summary>
    private static List<object> UpdateChunk(MySqlConnection c, MySqlTransaction t, CourseTableDef def,
                                            List<object> pks, Dictionary<string, object> sets,
                                            List<Pending> rejected, Dictionary<string, Pending> byPk)
    {
        var done = new List<object>();
        var setSql = new StringBuilder();
        int n = 0;
        foreach (var kv in sets)
        {
            if (n++ > 0) setSql.Append(", ");
            setSql.Append(kv.Key).Append("=@s").Append(n);
        }

        try
        {
            using (var cmd = Cmd("UPDATE " + def.Qualified + " SET " + setSql + " WHERE " + def.PkCol +
                                 " IN (" + InListRaw(pks) + ")", c, t))
            {
                int k = 0;
                foreach (var kv in sets) cmd.Parameters.AddWithValue("@s" + (++k), kv.Value ?? (object)DBNull.Value);
                cmd.ExecuteNonQuery();
            }
            done.AddRange(pks);
            return done;
        }
        catch (MySqlException)
        {
            // Fall back to one statement per row so the survivors still move.
            foreach (var pk in pks)
            {
                try
                {
                    using (var cmd = Cmd("UPDATE " + def.Qualified + " SET " + setSql + " WHERE " + def.PkCol + "=@pk", c, t))
                    {
                        int k = 0;
                        foreach (var kv in sets) cmd.Parameters.AddWithValue("@s" + (++k), kv.Value ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@pk", pk);
                        if (cmd.ExecuteNonQuery() > 0) done.Add(pk);
                    }
                }
                catch (MySqlException mex)
                {
                    Pending p;
                    if (byPk != null && byPk.TryGetValue(Convert.ToString(pk), out p))
                    {
                        p.action = "SKIP";
                        p.verdict = CorrectionVerdict.SkippedDuplicate;
                        p.after = null;
                        p.note = "Rejected by the database: " + mex.Message;
                        rejected.Add(p);
                    }
                }
            }
            return done;
        }
    }

    // ─────────────────────────────────────────────────────────────────
    //  APPLY
    // ─────────────────────────────────────────────────────────────────
    public static ApplyResult Apply(CorrectionConfig cfg, MarksScope scope, string user, string ip, string expectedChecksum)
    {
        var sw = System.Diagnostics.Stopwatch.StartNew();
        var res = new ApplyResult();

        string err = Validate(cfg, scope);
        if (err != null) { res.success = false; res.message = err; return res; }
        if (string.IsNullOrEmpty(cfg.reason) || cfg.reason.Trim().Length < 5)
        { res.success = false; res.message = "Give a reason for this correction (at least five characters). It is stored with the batch."; return res; }

        using (var c = new MySqlConnection(ConnStr()))
        {
            c.Open();
            SetAuditContext(c, null, user, cfg.reason, ip);

            using (var t = c.BeginTransaction())
            {
                try
                {
                    var rows = LoadCandidates(c, t, cfg, scope);
                    ApplyVerdicts(c, t, cfg, rows);
                    string nowSum = Checksum(rows);
                    if (!string.IsNullOrEmpty(expectedChecksum) && nowSum != expectedChecksum)
                    {
                        t.Rollback();
                        res.success = false;
                        res.message = "These records changed after you previewed them, so nothing was altered. Preview again to see the current position.";
                        return res;
                    }

                    var actionable = rows.FindAll(r => CorrectionVerdict.IsActionable(r.verdict));
                    if (actionable.Count == 0)
                    {
                        t.Rollback();
                        res.success = false;
                        res.message = "Nothing in this selection can be moved. See the preview for the reason against each record.";
                        return res;
                    }

                    // Marks reset takes its own path: the registration stays, the mark goes.
                    if (cfg.IsMarksReset)
                    {
                        long mid; string mref;
                        CreateBatch(c, t, cfg, scope, user, ip, rows.Count, out mid, out mref);
                        var mTouched = new HashSet<string>();
                        var mStudents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                        var mPend = new List<Pending>();
                        int pub, comp;

                        int done = ResetMarks(c, t, mid, cfg, actionable, mPend, mTouched, mStudents, out pub, out comp);
                        FlushSnapshots(c, t, mid, mPend);
                        FinishBatch(c, t, mid, done, rows.Count - done, mStudents.Count, 0,
                                    string.Join(", ", new List<string>(mTouched).ToArray()), (int)sw.ElapsedMilliseconds);
                        t.Commit();

                        res.batchId = mid; res.batchRef = mref;
                        res.rowsApplied = done; res.rowsSkipped = rows.Count - done;
                        res.students = mStudents.Count; res.satelliteRows = pub + comp;
                        res.tablesTouched = string.Join(", ", new List<string>(mTouched).ToArray());
                        res.durationMs = (int)sw.ElapsedMilliseconds;
                        res.message = "Reset " + mref + " erased the marks on " + done.ToString("N0") + " registration" +
                                      (done == 1 ? "" : "s") + " across " + mStudents.Count.ToString("N0") + " student" +
                                      (mStudents.Count == 1 ? "" : "s") + " — " + pub.ToString("N0") + " published result" +
                                      (pub == 1 ? "" : "s") + " and " + comp.ToString("N0") + " component mark" +
                                      (comp == 1 ? "" : "s") + " removed. Everything erased is recorded and can be put back.";
                        return res;
                    }

                    // Removal takes its own path: there is no destination to move anything to.
                    if (cfg.IsRemoval)
                    {
                        long rid; string rref;
                        CreateBatch(c, t, cfg, scope, user, ip, rows.Count, out rid, out rref);
                        var rTouched = new HashSet<string>();
                        var rStudents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                        var rPend = new List<Pending>();

                        int removed = RemoveRegistrations(c, t, rid, cfg, actionable, rPend, rTouched, rStudents);
                        FlushSnapshots(c, t, rid, rPend);
                        FinishBatch(c, t, rid, removed, rows.Count - removed, rStudents.Count, 0,
                                    string.Join(", ", new List<string>(rTouched).ToArray()), (int)sw.ElapsedMilliseconds);
                        t.Commit();

                        res.batchId = rid; res.batchRef = rref;
                        res.rowsApplied = removed; res.rowsSkipped = rows.Count - removed;
                        res.students = rStudents.Count;
                        res.tablesTouched = string.Join(", ", new List<string>(rTouched).ToArray());
                        res.durationMs = (int)sw.ElapsedMilliseconds;
                        res.message = "Removal " + rref + " deleted " + removed.ToString("N0") + " registration" +
                                      (removed == 1 ? "" : "s") + " across " + rStudents.Count.ToString("N0") + " student" +
                                      (rStudents.Count == 1 ? "" : "s") + ". Everything removed is recorded and can be put back.";
                        return res;
                    }

                    bool isMerge = cfg.operation == CorrectionOp.CourseMerge;
                    if (isMerge)
                    {
                        string mErr = MergeGuard(c, t, cfg);
                        if (mErr != null) { t.Rollback(); res.success = false; res.message = mErr; return res; }
                    }

                    long batchId; string batchRef;
                    CreateBatch(c, t, cfg, scope, user, ip, rows.Count, out batchId, out batchRef);

                    var touched = new HashSet<string>();
                    var students = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    var pend = new List<Pending>();
                    bool isTerm = cfg.operation == CorrectionOp.TermTransfer;
                    int satellitesResolved = 0;

                    var masterSets = isTerm
                        ? new Dictionary<string, object> { { "acad_year", cfg.targetYear }, { "semester", cfg.targetSemester } }
                        : new Dictionary<string, object> { { "courseID", cfg.targetCode } };

                    var plainMove = actionable.FindAll(r => r.verdict == CorrectionVerdict.Moved);
                    var settle = actionable.FindAll(r => CorrectionVerdict.IsResolved(r.verdict));

                    // Duplicates are settled first: the surviving mark is placed on the destination
                    // and the duplicate source registration is removed. Doing this before the plain
                    // moves frees the destination slots, so no move can trip the unique index.
                    int resolved = SettleDuplicates(c, t, batchId, cfg, settle, pend, touched, students);

                    int applied = MoveTable(c, t, batchId, CourseTableRegistry.Master, masterSets,
                                            BuildMasterIdChunks(plainMove), null, pend, touched, students) + resolved;

                    // With the registrations settled, the single published result each student may
                    // hold per code is settled the same way, before the generic satellite move runs.
                    if (settle.Count > 0 && cfg.moveResults && !isTerm)
                        satellitesResolved = SettleResults(c, t, batchId, cfg, settle, pend, touched);

                    // Satellites, grouped so each phase is a handful of statements.
                    int satellites = satellitesResolved;
                    var groups = GroupActionable(rows);
                    foreach (var def in CourseTableRegistry.Satellites)
                    {
                        if (SkipSatellite(def, cfg)) continue;
                        var sets = isTerm
                            ? (def.HasTerm ? new Dictionary<string, object> { { def.YearCol, cfg.targetYear }, { def.SemCol, cfg.targetSemester } } : null)
                            : NewCodeSets(def, cfg.targetCode);
                        if (sets == null) continue;
                        satellites += MoveSatelliteTable(c, t, batchId, def, cfg, groups, sets, pend, touched, students);
                    }

                    // Course Code Merge additionally consolidates the catalogue.
                    int catalogue = 0;
                    if (isMerge) catalogue = MergeCatalogue(c, t, batchId, cfg, pend, touched);

                    FlushSnapshots(c, t, batchId, pend);

                    int residual = CountResidual(c, t, cfg, students);
                    FinishBatch(c, t, batchId, applied, rows.Count - applied, students.Count, residual,
                                string.Join(", ", new List<string>(touched).ToArray()), (int)sw.ElapsedMilliseconds);

                    t.Commit();

                    res.batchId = batchId; res.batchRef = batchRef;
                    res.rowsApplied = applied; res.rowsSkipped = rows.Count - applied;
                    res.students = students.Count; res.satelliteRows = satellites + catalogue; res.residual = residual;
                    res.tablesTouched = string.Join(", ", new List<string>(touched).ToArray());
                    res.durationMs = (int)sw.ElapsedMilliseconds;
                    res.message = "Correction " + batchRef + " applied to " + applied.ToString("N0") + " registration" +
                                  (applied == 1 ? "" : "s") + " across " + students.Count.ToString("N0") + " student" +
                                  (students.Count == 1 ? "" : "s") + ".";
                    return res;
                }
                catch (Exception ex)
                {
                    try { t.Rollback(); } catch { }
                    res.success = false;
                    res.message = "The correction was abandoned and nothing was changed. " + ex.Message;
                    return res;
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    //  MARKS RESET
    //
    //  Returns a registration to the state of never having been marked: the
    //  student stays on the course, the mark goes. Used when a mark was
    //  entered against the wrong student, captured twice, or approved on a
    //  sheet that has since been withdrawn.
    //
    //  A mark is written in six places, and erasing some but not others is
    //  how a record ends up saying "Not Entered" while a published result
    //  still counts toward the GPA. All six are cleared together:
    //
    //    acad_course_registration   provisional CW / exam / total, status,
    //                               stage and the capture-approve-publish trail
    //    acad_results               the published result   (row deleted)
    //    acad_transcript_results    the transcript entry   (row deleted)
    //    acad_examresults_faculty   the faculty sheet row  (row deleted)
    //    acad_coursework_marks      the component marks the total was built from
    //    acad_practicalexam_marks   the practical equivalent
    //
    //  CGPA is NOT stored — acad_CGPAFinder derives it from acad_results — so
    //  deleting those rows moves it on its own, with no field to rewrite. The
    //  preview reports each student's CGPA before and after so the effect is
    //  seen before anything is written. The single place a CGPA IS stored,
    //  acad_graduands.cgpa, is a graduation snapshot and is refreshed here,
    //  because leaving it would have a graduand's certificate disagree with
    //  their transcript.
    // ─────────────────────────────────────────────────────────────────

    /// <summary>Everything on the registration that records a mark or how it got there.</summary>
    private static Dictionary<string, object> ResetSets()
    {
        var d = new Dictionary<string, object>();
        d["provisional_course_work_marks"] = null;
        d["provisional_exam_marks"] = null;
        d["provisional_total_marks"] = null;
        d["provisional_marks_status"] = "not_entered";
        d["provisional_marks_review_comments"] = null;
        d["provisional_marks_reviewed_by"] = null;
        d["provisional_marks_review_date"] = null;
        d["provisional_submitted_by"] = null;
        d["provisional_published_by"] = null;
        d["provisional_published_date"] = null;
        d["mark_stage"] = "NOT_ENTERED";
        d["capture_record_id"] = null;
        d["approve_record_id"] = null;
        d["publish_record_id"] = null;
        d["mark_stage_changed_at"] = null;
        d["mark_stage_changed_by"] = null;
        d["mark_returned_reason"] = null;
        return d;
    }

    /// <summary>CGPA as the institution computes it — the same stored function the transcripts
    /// use, so the figure shown here is the figure the student sees.</summary>
    private static double Cgpa(MySqlConnection c, MySqlTransaction t, string regno)
    {
        try
        {
            using (var cmd = Cmd("SELECT IFNULL(campus_dynamics.acad_CGPAFinder(@r),0)", c, t))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                object o = cmd.ExecuteScalar();
                return o == null || o == DBNull.Value ? 0 : Convert.ToDouble(o);
            }
        }
        catch { return 0; }
    }

    private static int ResetMarks(MySqlConnection c, MySqlTransaction t, long batchId, CorrectionConfig cfg,
                                  List<PreviewRow> targets, List<Pending> pend, HashSet<string> touched,
                                  HashSet<string> students, out int published, out int components)
    {
        published = 0; components = 0;
        if (targets.Count == 0) return 0;
        var master = CourseTableRegistry.Master;
        var sets = ResetSets();
        int reset = 0;

        foreach (var chunk in Chunks(targets, ReadChunk))
        {
            // 1. The registration itself — cleared, never deleted. The student stays on the course.
            var ids = new List<object>();
            foreach (var r in chunk) ids.Add(r.id);
            reset += MoveTable(c, t, batchId, master, sets, Chunks(ids, ReadChunk), null, pend, touched, students);

            foreach (var row in chunk)
            {
                students.Add(row.regno);

                // 2. Published result, transcript entry and faculty sheet. A result row with a
                //    null score would still be counted by every GPA query, so the row goes.
                if (cfg.resetPublished)
                {
                    foreach (var def in new[] {
                        CourseTableRegistry.Find(CourseTableRegistry.MainDb, "acad_results"),
                        CourseTableRegistry.Find(CourseTableRegistry.MainDb, "acad_transcript_results"),
                        CourseTableRegistry.Find(CourseTableRegistry.MainDb, "acad_examresults_faculty") })
                    {
                        if (def == null) continue;
                        // acad_results holds one row per (student, course) with no term, so the
                        // term is not used to find it; the other two are term-specific.
                        var where = new StringBuilder(def.RegnoCol + "=@rg AND " + def.CourseCol + "=@cc");
                        bool byTerm = !def.OnePerCourse && def.HasTerm;
                        if (byTerm) where.Append(" AND ").Append(def.YearCol).Append("=@y AND ").Append(def.SemCol).Append("=@s");

                        var hit = new List<object>();
                        try
                        {
                            using (var cmd = Cmd("SELECT " + def.PkCol + " FROM " + def.Qualified + " WHERE " + where, c, t))
                            {
                                cmd.Parameters.AddWithValue("@rg", row.regno);
                                cmd.Parameters.AddWithValue("@cc", row.courseCode);
                                if (byTerm) { cmd.Parameters.AddWithValue("@y", row.acadYear); cmd.Parameters.AddWithValue("@s", row.semester); }
                                using (var r = cmd.ExecuteReader()) while (r.Read()) hit.Add(r.GetValue(0));
                            }
                        }
                        catch { continue; }
                        foreach (var hc in Chunks(hit, ReadChunk))
                        {
                            int n = DeleteChunk(c, t, def, hc, pend, touched, "Erased with the mark reset.");
                            if (def.Table == "acad_results") published += n;
                        }
                    }
                }

                // 3. The component marks the total was built from. These hang off a settings row
                //    (course + term + programme), not off the course code, so they are reached
                //    through it rather than by the registration's own columns.
                if (cfg.resetComponents)
                {
                    components += ClearComponents(c, t, batchId, "acad_coursework_marks", "acad_coursework_settings", row, pend, touched);
                    components += ClearComponents(c, t, batchId, "acad_practicalexam_marks", "acad_practicalexam_settings", row, pend, touched);
                }
            }
            if (pend.Count >= 800) FlushSnapshots(c, t, batchId, pend);
        }

        // 4. The one stored CGPA. Recomputed rather than left to disagree with the transcript.
        RefreshGraduandCgpa(c, t, batchId, students, pend, touched);
        return reset;
    }

    /// <summary>Component marks for one registration, found through the coursework/practical
    /// settings row that ties a course, term and programme together.</summary>
    private static int ClearComponents(MySqlConnection c, MySqlTransaction t, long batchId,
                                       string marksTable, string settingsTable, PreviewRow row,
                                       List<Pending> pend, HashSet<string> touched)
    {
        var def = new CourseTableDef
        {
            Db = CourseTableRegistry.PortalDb, Table = marksTable, PkCol = "ID",
            RegnoCol = "reg_no", CourseCol = "CSID", Label = marksTable
        };
        var ids = new List<object>();
        try
        {
            using (var cmd = Cmd(
                "SELECT m.ID FROM " + CourseTableRegistry.PortalDb + "." + marksTable + " m " +
                " JOIN " + CourseTableRegistry.PortalDb + "." + settingsTable + " s ON s.ID=m.CSID " +
                " WHERE m.reg_no=@rg AND s.courseID=@cc AND s.acadyear=@y AND s.semester=@sm", c, t))
            {
                cmd.Parameters.AddWithValue("@rg", row.regno);
                cmd.Parameters.AddWithValue("@cc", row.courseCode);
                cmd.Parameters.AddWithValue("@y", row.acadYear);
                cmd.Parameters.AddWithValue("@sm", row.semester);
                using (var r = cmd.ExecuteReader()) while (r.Read()) ids.Add(r.GetValue(0));
            }
        }
        catch { return 0; }

        int n = 0;
        foreach (var ch in Chunks(ids, ReadChunk))
            n += DeleteChunk(c, t, def, ch, pend, touched, "Component mark erased with the reset.");
        return n;
    }

    /// <summary>acad_graduands.cgpa is a snapshot taken at graduation and is the only stored
    /// CGPA in the system. If a graduand's marks are erased it must be recomputed, or the
    /// certificate and the transcript will disagree.</summary>
    private static void RefreshGraduandCgpa(MySqlConnection c, MySqlTransaction t, long batchId,
                                            HashSet<string> students, List<Pending> pend, HashSet<string> touched)
    {
        if (students.Count == 0) return;
        var def = new CourseTableDef
        {
            Db = CourseTableRegistry.MainDb, Table = "acad_graduands", PkCol = "ID",
            RegnoCol = "regno", CourseCol = "regno", Label = "Graduand record"
        };
        var all = new List<string>(students);
        foreach (var chunk in Chunks(all, ReadChunk))
        {
            var rows = new List<object[]>();
            try
            {
                using (var cmd = Cmd("SELECT ID, regno FROM campus_dynamics.acad_graduands WHERE regno IN (" + InList(chunk) + ")", c, t))
                using (var r = cmd.ExecuteReader())
                    while (r.Read()) rows.Add(new object[] { r.GetValue(0), S(r, 1) });
            }
            catch { continue; }

            foreach (var g in rows)
            {
                var before = ReadOne(c, t, def, g[0]);
                if (before == null) continue;
                double now = Cgpa(c, t, (string)g[1]);
                var sets = new Dictionary<string, object> { { "cgpa", now } };
                var rejected = new List<Pending>();
                if (UpdateChunk(c, t, def, new List<object> { g[0] }, sets, rejected, null).Count == 0) continue;
                pend.Add(new Pending
                {
                    def = def, pk = g[0], regno = (string)g[1], action = "UPDATE",
                    verdict = CorrectionVerdict.WillReset, before = before, after = WithSets(before, sets),
                    note = "Graduation CGPA recomputed after the mark reset."
                });
                touched.Add(def.Table);
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    //  Registration removal
    //
    //  For registrations that should never have been made — a subject that
    //  was never on the student's curriculum, or one belonging to another
    //  specialisation. The registration goes, and anything recorded against
    //  it goes with it, so no orphan result or upload is left behind.
    //
    //  Every deleted row is snapshotted whole first, and the reversal
    //  re-inserts it, so a removal is as undoable as a move.
    // ─────────────────────────────────────────────────────────────────
    private static int RemoveRegistrations(MySqlConnection c, MySqlTransaction t, long batchId, CorrectionConfig cfg,
                                           List<PreviewRow> targets, List<Pending> pend, HashSet<string> touched,
                                           HashSet<string> students)
    {
        if (targets.Count == 0) return 0;
        var master = CourseTableRegistry.Master;
        int removed = 0;

        foreach (var chunk in Chunks(targets, ReadChunk))
        {
            // Dependants first, so nothing is left pointing at a row that has gone.
            foreach (var def in CourseTableRegistry.Satellites)
                foreach (var row in chunk)
                {
                    bool bound = TermBound(def, cfg);
                    var ids = new List<object>();
                    try
                    {
                        var g = new SatGroup { course = row.courseCode, year = row.acadYear, sem = row.semester, regnos = new List<string> { row.regno } };
                        using (var cmd = Cmd("SELECT " + def.PkCol + " FROM " + def.Qualified + " WHERE " + SatWhere(def, cfg, g, bound), c, t))
                        using (var r = cmd.ExecuteReader())
                            while (r.Read()) ids.Add(r.GetValue(0));
                    }
                    catch { continue; }
                    if (ids.Count == 0) continue;
                    foreach (var idChunk in Chunks(ids, ReadChunk))
                        DeleteChunk(c, t, def, idChunk, pend, touched,
                                    "Removed with the registration it belonged to.");
                }

            // Then the registrations themselves.
            var pks = new List<object>();
            foreach (var row in chunk) pks.Add(row.id);
            var before = ReadMany(c, t, master, pks);
            var drop = new List<object>();
            foreach (var row in chunk)
            {
                Dictionary<string, object> b;
                if (!before.TryGetValue(Convert.ToString(row.id), out b)) continue;
                pend.Add(new Pending
                {
                    def = master, pk = row.id, regno = row.regno, course = row.courseCode,
                    action = "DELETE", verdict = CorrectionVerdict.WillRemove, before = b, after = null,
                    note = "Removed — " + RemovalBasis.Explain(cfg.removalBasis) + "."
                });
                drop.Add(row.id);
                students.Add(row.regno);
                removed++;
            }
            if (drop.Count > 0)
            {
                using (var cmd = Cmd("DELETE FROM " + master.Qualified + " WHERE ID IN (" + InListRaw(drop) + ")", c, t))
                    cmd.ExecuteNonQuery();
                touched.Add(master.Table);
            }
            if (pend.Count >= 1000) FlushSnapshots(c, t, batchId, pend);
        }
        return removed;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Settling duplicates
    //
    //  A duplicate means the student holds the same course twice — once on the
    //  code being retired and once on the code being kept. Leaving both is the
    //  fault this module exists to remove, so the pair is reduced to one:
    //  the better mark ends up on the destination, and the duplicate goes.
    //
    //  Both sides are snapshotted whole before anything is touched — the
    //  destination before it is overwritten, and the source before it is
    //  deleted — so the reversal restores the overwritten mark AND re-creates
    //  the removed row.
    // ─────────────────────────────────────────────────────────────────
    private static int SettleDuplicates(MySqlConnection c, MySqlTransaction t, long batchId, CorrectionConfig cfg,
                                        List<PreviewRow> settle, List<Pending> pend, HashSet<string> touched,
                                        HashSet<string> students)
    {
        if (settle.Count == 0) return 0;
        var master = CourseTableRegistry.Master;
        int done = 0;

        foreach (var chunk in Chunks(settle, ReadChunk))
        {
            // Read both sides of every pair in two statements.
            var srcIds = new List<object>(); var dstIds = new List<object>();
            foreach (var r in chunk) { srcIds.Add(r.id); if (r.targetId > 0) dstIds.Add(r.targetId); }

            var srcRows = ReadMany(c, t, master, srcIds);
            var dstRows = ReadMany(c, t, master, dstIds);

            var toDelete = new List<object>();
            foreach (var r in chunk)
            {
                Dictionary<string, object> src, dst;
                if (!srcRows.TryGetValue(Convert.ToString(r.id), out src)) continue;
                if (!dstRows.TryGetValue(Convert.ToString(r.targetId), out dst)) continue;

                // The destination only changes when the source actually carries the better mark.
                if (r.verdict == CorrectionVerdict.ResolvedOverwrite || r.verdict == CorrectionVerdict.ResolvedFilled)
                {
                    var sets = CopyColumns(src, MarkColumns);
                    if (sets.Count > 0)
                    {
                        var rejected = new List<Pending>();
                        var ok = UpdateChunk(c, t, master, new List<object> { r.targetId }, sets, rejected, null);
                        if (ok.Count > 0)
                        {
                            pend.Add(new Pending
                            {
                                def = master, pk = r.targetId, regno = r.regno, course = cfg.targetCode,
                                action = "UPDATE", verdict = r.verdict, before = dst, after = WithSets(dst, sets),
                                note = "Mark taken from the duplicate on " + r.courseCode +
                                       " (" + MarkText(r.total) + " against " + MarkText(r.targetTotal) + ")."
                            });
                            touched.Add(master.Table);
                        }
                    }
                }

                // The duplicate itself goes, whichever way the comparison fell.
                pend.Add(new Pending
                {
                    def = master, pk = r.id, regno = r.regno, course = r.courseCode,
                    action = "DELETE", verdict = r.verdict, before = src, after = null,
                    note = r.verdict == CorrectionVerdict.ResolvedDiscard
                        ? "Duplicate removed — the destination already held " + MarkText(r.targetTotal) + "."
                        : "Duplicate removed after its mark was moved to the destination."
                });
                toDelete.Add(r.id);
                students.Add(r.regno);
                done++;
            }

            if (toDelete.Count > 0)
            {
                // Anything pointing at the row about to go is repointed at the survivor first,
                // so no retake record is left hanging.
                RepointRetakes(c, t, chunk);
                using (var cmd = Cmd("DELETE FROM " + master.Qualified + " WHERE ID IN (" + InListRaw(toDelete) + ")", c, t))
                    cmd.ExecuteNonQuery();
                touched.Add(master.Table);
            }
            if (pend.Count >= 1000) FlushSnapshots(c, t, batchId, pend);
        }
        return done;
    }

    /// <summary>A retake row linked to the registration being removed is pointed at the survivor.</summary>
    private static void RepointRetakes(MySqlConnection c, MySqlTransaction t, List<PreviewRow> pairs)
    {
        foreach (var r in pairs)
        {
            if (r.targetId <= 0) continue;
            try
            {
                using (var cmd = Cmd("UPDATE campus_dynamics_portal.acad_retake_registrations " +
                                     "SET course_reg_id=@d WHERE course_reg_id=@s", c, t))
                {
                    cmd.Parameters.AddWithValue("@d", r.targetId);
                    cmd.Parameters.AddWithValue("@s", r.id);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }
    }

    /// <summary>acad_results allows one row per (student, course), so a settled student may hold
    /// two: one on each code. The same comparison applies — the better mark stays on the
    /// destination code and the other row is removed.</summary>
    private static int SettleResults(MySqlConnection c, MySqlTransaction t, long batchId, CorrectionConfig cfg,
                                     List<PreviewRow> settle, List<Pending> pend, HashSet<string> touched)
    {
        var def = CourseTableRegistry.Find(CourseTableRegistry.MainDb, "acad_results");
        if (def == null) return 0;

        var regnos = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var r in settle) if (seen.Add(r.regno)) regnos.Add(r.regno);

        int done = 0;
        foreach (var chunk in Chunks(regnos, ReadChunk))
        {
            var src = new Dictionary<string, Dictionary<string, object>>(StringComparer.OrdinalIgnoreCase);
            var dst = new Dictionary<string, Dictionary<string, object>>(StringComparer.OrdinalIgnoreCase);
            using (var cmd = Cmd("SELECT * FROM " + def.Qualified + " WHERE regno IN (" + InList(chunk) + ") AND courseid IN (@sc,@tc)", c, t))
            {
                cmd.Parameters.AddWithValue("@sc", cfg.sourceCode);
                cmd.Parameters.AddWithValue("@tc", cfg.targetCode);
                using (var r = cmd.ExecuteReader())
                    while (r.Read())
                    {
                        var row = RowToDict(r);
                        string rg = Convert.ToString(row["regno"]).Trim();
                        string cc = Convert.ToString(row["courseid"]).Trim();
                        if (string.Equals(cc, cfg.targetCode, StringComparison.OrdinalIgnoreCase)) dst[rg] = row;
                        else src[rg] = row;
                    }
            }

            var drop = new List<object>();
            foreach (var kv in src)
            {
                Dictionary<string, object> d;
                if (!dst.TryGetValue(kv.Key, out d)) continue;   // no clash — the generic move handles it

                int? sScore = AsInt(kv.Value, "score");
                int? dScore = AsInt(d, "score");
                string verdict = Settle(sScore, dScore);

                if (verdict != CorrectionVerdict.ResolvedDiscard)
                {
                    var sets = CopyColumns(kv.Value, ResultColumns);
                    if (sets.Count > 0)
                    {
                        var rejected = new List<Pending>();
                        object dPk = d[def.PkCol];
                        var ok = UpdateChunk(c, t, def, new List<object> { dPk }, sets, rejected, null);
                        if (ok.Count > 0)
                        {
                            pend.Add(new Pending
                            {
                                def = def, pk = dPk, regno = kv.Key, course = cfg.targetCode,
                                action = "UPDATE", verdict = verdict, before = d, after = WithSets(d, sets),
                                note = "Result taken from the duplicate on " + cfg.sourceCode +
                                       " (" + MarkText(sScore) + " against " + MarkText(dScore) + ")."
                            });
                            touched.Add(def.Table);
                        }
                    }
                }

                object sPk = kv.Value[def.PkCol];
                pend.Add(new Pending
                {
                    def = def, pk = sPk, regno = kv.Key, course = cfg.sourceCode,
                    action = "DELETE", verdict = verdict, before = kv.Value, after = null,
                    note = "Duplicate result on the retired code removed."
                });
                drop.Add(sPk);
                done++;
            }

            if (drop.Count > 0)
            {
                using (var cmd = Cmd("DELETE FROM " + def.Qualified + " WHERE " + def.PkCol + " IN (" + InListRaw(drop) + ")", c, t))
                    cmd.ExecuteNonQuery();
                touched.Add(def.Table);
            }
        }
        return done;
    }

    private static Dictionary<string, Dictionary<string, object>> ReadMany(MySqlConnection c, MySqlTransaction t,
                                                                          CourseTableDef def, List<object> pks)
    {
        var map = new Dictionary<string, Dictionary<string, object>>();
        if (pks.Count == 0) return map;
        using (var cmd = Cmd("SELECT * FROM " + def.Qualified + " WHERE " + def.PkCol + " IN (" + InListRaw(pks) + ")", c, t))
        using (var r = cmd.ExecuteReader())
            while (r.Read())
            {
                var row = RowToDict(r);
                if (row.ContainsKey(def.PkCol)) map[Convert.ToString(row[def.PkCol])] = row;
            }
        return map;
    }

    /// <summary>The named columns of a row, using whatever casing the reader returned.</summary>
    private static Dictionary<string, object> CopyColumns(Dictionary<string, object> row, string[] names)
    {
        var sets = new Dictionary<string, object>();
        foreach (var want in names)
            foreach (var k in row.Keys)
                if (string.Equals(k, want, StringComparison.OrdinalIgnoreCase)) { sets[k] = row[k]; break; }
        return sets;
    }

    private static int? AsInt(Dictionary<string, object> row, string col)
    {
        foreach (var k in row.Keys)
            if (string.Equals(k, col, StringComparison.OrdinalIgnoreCase))
            {
                if (row[k] == null) return null;
                int v; return int.TryParse(Convert.ToString(row[k], CultureInfo.InvariantCulture), out v) ? (int?)v : null;
            }
        return null;
    }

    private static string MarkText(int? m) { return m.HasValue ? m.Value.ToString(CultureInfo.InvariantCulture) : "no mark"; }

    private static Dictionary<string, object> NewCodeSets(CourseTableDef def, string target)
    {
        var d = new Dictionary<string, object> { { def.CourseCol, target } };
        if (!string.IsNullOrEmpty(def.CourseCol2)) d[def.CourseCol2] = target;
        return d;
    }

    private static List<List<object>> BuildMasterIdChunks(List<PreviewRow> actionable)
    {
        var ids = new List<object>();
        foreach (var r in actionable) ids.Add(r.id);
        return Chunks(ids, ReadChunk);
    }

    /// <summary>Read → update → record, in chunks, for a set of primary keys.</summary>
    private static int MoveTable(MySqlConnection c, MySqlTransaction t, long batchId, CourseTableDef def,
                                 Dictionary<string, object> sets, List<List<object>> pkChunks, string whereExtra,
                                 List<Pending> pend, HashSet<string> touched, HashSet<string> students)
    {
        int moved = 0;
        foreach (var chunk in pkChunks)
        {
            var byPk = new Dictionary<string, Pending>();
            using (var cmd = Cmd("SELECT * FROM " + def.Qualified + " WHERE " + def.PkCol + " IN (" + InListRaw(chunk) + ")" +
                                 (string.IsNullOrEmpty(whereExtra) ? "" : " AND " + whereExtra), c, t))
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                {
                    var before = RowToDict(r);
                    object pk = before.ContainsKey(def.PkCol) ? before[def.PkCol] : null;
                    if (pk == null) continue;
                    byPk[Convert.ToString(pk)] = new Pending
                    {
                        def = def, pk = pk,
                        regno = def.RegnoCol != null && before.ContainsKey(def.RegnoCol) ? Convert.ToString(before[def.RegnoCol]) : null,
                        course = before.ContainsKey(def.CourseCol) ? Convert.ToString(before[def.CourseCol]) : null,
                        action = "UPDATE", verdict = CorrectionVerdict.Moved,
                        before = before, after = WithSets(before, sets)
                    };
                }
            if (byPk.Count == 0) continue;

            var pks = new List<object>();
            foreach (var p in byPk.Values) pks.Add(p.pk);

            var rejected = new List<Pending>();
            var done = UpdateChunk(c, t, def, pks, sets, rejected, byPk);

            foreach (var pk in done)
            {
                Pending p;
                if (!byPk.TryGetValue(Convert.ToString(pk), out p)) continue;
                if (p.action == "SKIP") continue;
                pend.Add(p); moved++;
                touched.Add(def.Table);
                if (!string.IsNullOrEmpty(p.regno)) students.Add(p.regno);
            }
            foreach (var p in rejected) pend.Add(p);
            if (pend.Count >= 1000) FlushSnapshots(c, t, batchId, pend);
        }
        return moved;
    }

    private static int MoveSatelliteTable(MySqlConnection c, MySqlTransaction t, long batchId, CourseTableDef def,
                                          CorrectionConfig cfg, List<SatGroup> groups, Dictionary<string, object> sets,
                                          List<Pending> pend, HashSet<string> touched, HashSet<string> students)
    {
        int moved = 0;
        bool bound = TermBound(def, cfg);
        foreach (var g in groups)
            foreach (var chunk in Chunks(g.regnos, ReadChunk))
            {
                var sub = new SatGroup { course = g.course, year = g.year, sem = g.sem, regnos = chunk };
                var ids = new List<object>();
                try
                {
                    using (var cmd = Cmd("SELECT " + def.PkCol + " FROM " + def.Qualified + " WHERE " + SatWhere(def, cfg, sub, bound), c, t))
                    using (var r = cmd.ExecuteReader())
                        while (r.Read()) ids.Add(r.GetValue(0));
                }
                catch { continue; }
                if (ids.Count == 0) continue;
                moved += MoveTable(c, t, batchId, def, sets, Chunks(ids, ReadChunk), null, pend, touched, students);
            }
        return moved;
    }

    // ─────────────────────────────────────────────────────────────────
    //  COURSE CODE MERGE — the catalogue phases
    // ─────────────────────────────────────────────────────────────────
    /// <summary>Refuses a merge that would silently change credit units, because every GPA
    /// computed from the mark depends on them.</summary>
    private static string MergeGuard(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg)
    {
        double srcCu = 0, tgtCu = 0; bool tgtExists = false;
        using (var cmd = Cmd("SELECT courseID, IFNULL(CreditUnit,0) FROM campus_dynamics.acad_course WHERE courseID IN (@a,@b)", c, t))
        {
            cmd.Parameters.AddWithValue("@a", cfg.sourceCode);
            cmd.Parameters.AddWithValue("@b", cfg.targetCode);
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                {
                    if (string.Equals(S(r, 0), cfg.sourceCode, StringComparison.OrdinalIgnoreCase)) srcCu = r.IsDBNull(1) ? 0 : Convert.ToDouble(r[1]);
                    else { tgtExists = true; tgtCu = r.IsDBNull(1) ? 0 : Convert.ToDouble(r[1]); }
                }
        }
        if (!tgtExists)
            return "The surviving code is not in the course catalogue. Add it before merging, otherwise the merged records would have no title or credit units.";
        if (srcCu > 0 && tgtCu > 0 && Math.Abs(srcCu - tgtCu) > 0.001 && string.IsNullOrEmpty(cfg.creditUnitWinner))
            return "The two codes carry different credit units (" + srcCu + " against " + tgtCu +
                   "). Choose which value the merged course should keep before continuing — every GPA computed from these marks depends on it.";
        return null;
    }

    /// <summary>Repoints curriculum, delivery and settings onto the surviving code, then archives
    /// the retired catalogue entry. A curriculum row that would become a duplicate of one that
    /// already exists is removed — after its snapshot is stored, so the reversal can put it back.</summary>
    private static int MergeCatalogue(MySqlConnection c, MySqlTransaction t, long batchId, CorrectionConfig cfg,
                                      List<Pending> pend, HashSet<string> touched)
    {
        int changed = 0;
        var noStudents = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var def in CourseTableRegistry.CatalogueTables)
        {
            var ids = new List<object>();
            try
            {
                using (var cmd = Cmd("SELECT " + def.PkCol + " FROM " + def.Qualified + " WHERE " + def.CourseCol + "=@sc", c, t))
                {
                    cmd.Parameters.AddWithValue("@sc", cfg.sourceCode);
                    using (var r = cmd.ExecuteReader()) while (r.Read()) ids.Add(r.GetValue(0));
                }
            }
            catch { continue; }
            if (ids.Count == 0) continue;

            // acad_programmecourses is unique per (programme, course, year, semester) in practice;
            // a repoint that would collide is removed instead, with its snapshot kept.
            if (def.Table == "acad_programmecourses")
            {
                var drop = new List<object>();
                var keep = new List<object>();
                foreach (var pk in ids)
                {
                    bool clash = false;
                    try
                    {
                        using (var cmd = Cmd(
                            "SELECT COUNT(*) FROM " + def.Qualified + " x JOIN " + def.Qualified + " y " +
                            "  ON y.progcode=x.progcode AND y.study_year=x.study_year AND y.semester=x.semester " +
                            " WHERE x." + def.PkCol + "=@pk AND y.course_code=@tc AND y." + def.PkCol + "<>x." + def.PkCol, c, t))
                        {
                            cmd.Parameters.AddWithValue("@pk", pk);
                            cmd.Parameters.AddWithValue("@tc", cfg.targetCode);
                            clash = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                        }
                    }
                    catch { }
                    if (clash) drop.Add(pk); else keep.Add(pk);
                }

                foreach (var chunk in Chunks(drop, ReadChunk))
                    changed += DeleteChunk(c, t, def, chunk, pend, touched, "Removed — the surviving code already has this curriculum entry.");
                if (keep.Count > 0)
                    changed += MoveTable(c, t, batchId, def, NewCodeSets(def, cfg.targetCode), Chunks(keep, ReadChunk), null, pend, touched, noStudents);
                continue;
            }

            changed += MoveTable(c, t, batchId, def, NewCodeSets(def, cfg.targetCode), Chunks(ids, ReadChunk), null, pend, touched, noStudents);
        }

        // If the operator chose the retiring code's credit units, apply them to the survivor first.
        if (string.Equals(cfg.creditUnitWinner, "source", StringComparison.OrdinalIgnoreCase))
        {
            var courseDef = new CourseTableDef { Db = CourseTableRegistry.MainDb, Table = "acad_course", PkCol = "courseID", CourseCol = "courseID", Label = "Course" };
            double srcCu = 0;
            using (var cmd = Cmd("SELECT IFNULL(CreditUnit,0) FROM campus_dynamics.acad_course WHERE courseID=@c", c, t))
            { cmd.Parameters.AddWithValue("@c", cfg.sourceCode); object o = cmd.ExecuteScalar(); srcCu = o == null || o == DBNull.Value ? 0 : Convert.ToDouble(o); }
            changed += MoveTable(c, t, batchId, courseDef, new Dictionary<string, object> { { "CreditUnit", srcCu } },
                                 new List<List<object>> { new List<object> { cfg.targetCode } }, null, pend, touched, noStudents);
        }

        // Archive rather than delete, using the columns the 2026-07 consolidation already added.
        var archDef = new CourseTableDef { Db = CourseTableRegistry.MainDb, Table = "acad_course", PkCol = "courseID", CourseCol = "courseID", Label = "Course" };
        changed += MoveTable(c, t, batchId, archDef,
            new Dictionary<string, object> { { "course_state", "MERGED" }, { "merged_into", cfg.targetCode }, { "merged_at", DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") }, { "stat", "MERGED" } },
            new List<List<object>> { new List<object> { cfg.sourceCode } }, null, pend, touched, noStudents);

        return changed;
    }

    private static int DeleteChunk(MySqlConnection c, MySqlTransaction t, CourseTableDef def, List<object> pks,
                                   List<Pending> pend, HashSet<string> touched, string note)
    {
        if (pks.Count == 0) return 0;
        int n = 0;
        using (var cmd = Cmd("SELECT * FROM " + def.Qualified + " WHERE " + def.PkCol + " IN (" + InListRaw(pks) + ")", c, t))
        using (var r = cmd.ExecuteReader())
            while (r.Read())
            {
                var before = RowToDict(r);
                pend.Add(new Pending
                {
                    def = def, pk = before.ContainsKey(def.PkCol) ? before[def.PkCol] : null,
                    course = before.ContainsKey(def.CourseCol) ? Convert.ToString(before[def.CourseCol]) : null,
                    action = "DELETE", verdict = CorrectionVerdict.Moved, before = before, after = null, note = note
                });
                n++;
            }
        using (var cmd = Cmd("DELETE FROM " + def.Qualified + " WHERE " + def.PkCol + " IN (" + InListRaw(pks) + ")", c, t))
            cmd.ExecuteNonQuery();
        touched.Add(def.Table);
        return n;
    }

    /// <summary>Records still carrying the old code for the students touched — surfaced so a
    /// partial correction is never mistaken for a complete one.</summary>
    private static int CountResidual(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, HashSet<string> students)
    {
        if (cfg.operation == CorrectionOp.TermTransfer || students.Count == 0) return 0;
        int total = 0;
        var all = new List<string>(students);
        foreach (var def in CourseTableRegistry.StudentTables)
            foreach (var chunk in Chunks(all, ReadChunk))
            {
                try
                {
                    using (var cmd = Cmd("SELECT COUNT(*) FROM " + def.Qualified + " WHERE " + def.RegnoCol +
                                         " IN (" + InList(chunk) + ") AND " + def.CourseCol + "=@sc", c, t))
                    {
                        cmd.Parameters.AddWithValue("@sc", cfg.sourceCode);
                        object o = cmd.ExecuteScalar();
                        if (o != null && o != DBNull.Value) total += Convert.ToInt32(o);
                    }
                }
                catch { }
            }
        return total;
    }

    private static void CreateBatch(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, MarksScope scope,
                                    string user, string ip, int scanned, out long batchId, out string batchRef)
    {
        batchRef = NextRef(c, t);
        using (var cmd = Cmd(
            "INSERT INTO campus_dynamics.acad_correction_batch " +
            "(batch_ref, operation, status, source_code, target_code, source_year, target_year, source_semester, target_semester, " +
            " config_json, scope_label, rows_scanned, performed_by, performed_at, performed_ip, reason) " +
            "VALUES (@ref,@op,'APPLIED',@sc,@tc,@sy,@ty,@ss,@ts,@cfg,@scope,@scan,@by,NOW(),@ip,@reason)", c, t))
        {
            cmd.Parameters.AddWithValue("@ref", batchRef);
            cmd.Parameters.AddWithValue("@op", cfg.operation);
            cmd.Parameters.AddWithValue("@sc", NullIfEmpty(cfg.sourceCode));
            cmd.Parameters.AddWithValue("@tc", NullIfEmpty(cfg.targetCode));
            cmd.Parameters.AddWithValue("@sy", NullIfEmpty(cfg.sourceYear));
            cmd.Parameters.AddWithValue("@ty", NullIfEmpty(cfg.targetYear));
            cmd.Parameters.AddWithValue("@ss", NullIfEmptyInt(cfg.sourceSemester));
            cmd.Parameters.AddWithValue("@ts", NullIfEmptyInt(cfg.targetSemester));
            cmd.Parameters.AddWithValue("@cfg", Json.Serialize(cfg));
            cmd.Parameters.AddWithValue("@scope", Trunc(scope.RoleNote + " — " + scope.Label, 200));
            cmd.Parameters.AddWithValue("@scan", scanned);
            cmd.Parameters.AddWithValue("@by", user ?? "");
            cmd.Parameters.AddWithValue("@ip", (object)ip ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@reason", Trunc(cfg.reason ?? "", 400));
            cmd.ExecuteNonQuery();
            batchId = cmd.LastInsertedId;
        }
    }

    private static object NullIfEmpty(string s) { return string.IsNullOrEmpty(s) ? (object)DBNull.Value : s; }
    private static object NullIfEmptyInt(string s)
    {
        int v; return (!string.IsNullOrEmpty(s) && int.TryParse(s, out v)) ? (object)v : DBNull.Value;
    }

    private static void FinishBatch(MySqlConnection c, MySqlTransaction t, long batchId, int applied, int skipped,
                                    int students, int residual, string tables, int ms)
    {
        using (var cmd = Cmd(
            "UPDATE campus_dynamics.acad_correction_batch SET rows_applied=@a, rows_skipped=@s, students_affected=@st, " +
            "residual_rows=@r, tables_touched=@tb, duration_ms=@d WHERE id=@id", c, t))
        {
            cmd.Parameters.AddWithValue("@a", applied);
            cmd.Parameters.AddWithValue("@s", skipped);
            cmd.Parameters.AddWithValue("@st", students);
            cmd.Parameters.AddWithValue("@r", residual);
            cmd.Parameters.AddWithValue("@tb", Trunc(tables ?? "", 500));
            cmd.Parameters.AddWithValue("@d", ms);
            cmd.Parameters.AddWithValue("@id", batchId);
            cmd.ExecuteNonQuery();
        }
    }

    /// <summary>Sequence taken from the highest reference already issued today, so a deleted
    /// batch cannot cause a duplicate reference.</summary>
    private static string NextRef(MySqlConnection c, MySqlTransaction t)
    {
        string day = DateTime.Now.ToString("yyyyMMdd");
        int n = 1;
        using (var cmd = Cmd("SELECT IFNULL(MAX(CAST(SUBSTRING(batch_ref,13) AS UNSIGNED)),0)+1 " +
                             "FROM campus_dynamics.acad_correction_batch WHERE batch_ref LIKE @p", c, t))
        {
            cmd.Parameters.AddWithValue("@p", "CC-" + day + "-%");
            object o = cmd.ExecuteScalar();
            if (o != null && o != DBNull.Value) n = Convert.ToInt32(o);
        }
        return "CC-" + day + "-" + n.ToString("D4");
    }

    // ─────────────────────────────────────────────────────────────────
    //  REVERSE — itself a batch, so the trail stays append-only
    // ─────────────────────────────────────────────────────────────────
    public static ApplyResult Reverse(long batchId, string reason, MarksScope scope, string user, string ip, string onlyRegno)
    {
        var sw = System.Diagnostics.Stopwatch.StartNew();
        var res = new ApplyResult();
        if (!scope.HasAccess) { res.success = false; res.message = "You do not have a marks-management scope."; return res; }
        if (string.IsNullOrEmpty(reason) || reason.Trim().Length < 5)
        { res.success = false; res.message = "Give a reason for reversing this correction (at least five characters)."; return res; }

        using (var c = new MySqlConnection(ConnStr()))
        {
            c.Open();
            SetAuditContext(c, null, user, "Reversal: " + reason, ip);

            using (var t = c.BeginTransaction())
            {
                try
                {
                    string status = "", srcCode = "", tgtCode = "", ranBy = "";
                    using (var cmd = Cmd("SELECT status, IFNULL(source_code,''), IFNULL(target_code,''), performed_by " +
                                         "FROM campus_dynamics.acad_correction_batch WHERE id=@id FOR UPDATE", c, t))
                    {
                        cmd.Parameters.AddWithValue("@id", batchId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { t.Rollback(); res.success = false; res.message = "That correction batch was not found."; return res; }
                            status = S(r, 0); srcCode = S(r, 1); tgtCode = S(r, 2); ranBy = S(r, 3);
                        }
                    }
                    if (!scope.IsAdmin && !string.Equals(ranBy, user, StringComparison.OrdinalIgnoreCase))
                    { t.Rollback(); res.success = false; res.message = "You can only reverse corrections you made yourself."; return res; }
                    if (status == "REVERSED" && string.IsNullOrEmpty(onlyRegno))
                    { t.Rollback(); res.success = false; res.message = "This correction has already been reversed in full."; return res; }

                    var work = new List<object[]>();
                    string sql = "SELECT id, db_name, table_name, pk_column, pk_value, IFNULL(regno,''), before_json, after_json, action " +
                                 "FROM campus_dynamics.acad_correction_row " +
                                 "WHERE batch_id=@b AND action IN ('UPDATE','DELETE') AND reversed=0 " +
                                 (string.IsNullOrEmpty(onlyRegno) ? "" : "AND regno=@rg ") +
                                 "ORDER BY id DESC";
                    using (var cmd = Cmd(sql, c, t))
                    {
                        cmd.Parameters.AddWithValue("@b", batchId);
                        if (!string.IsNullOrEmpty(onlyRegno)) cmd.Parameters.AddWithValue("@rg", onlyRegno);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                                work.Add(new object[] { Convert.ToInt64(r[0]), S(r, 1), S(r, 2), S(r, 3), S(r, 4), S(r, 5), S(r, 6), S(r, 7), S(r, 8) });
                    }
                    if (work.Count == 0)
                    { t.Rollback(); res.success = false; res.message = "There is nothing left to reverse in this correction."; return res; }

                    long revId; string revRef;
                    var cfg = new CorrectionConfig { operation = CorrectionOp.Reversal, sourceCode = tgtCode, targetCode = srcCode, reason = reason };
                    CreateBatch(c, t, cfg, scope, user, ip, work.Count, out revId, out revRef);
                    using (var cmd = Cmd("UPDATE campus_dynamics.acad_correction_batch SET reverses_batch_id=@o WHERE id=@r", c, t))
                    { cmd.Parameters.AddWithValue("@o", batchId); cmd.Parameters.AddWithValue("@r", revId); cmd.ExecuteNonQuery(); }

                    int restored = 0, blocked = 0;
                    var touched = new HashSet<string>();
                    var students = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    var pend = new List<Pending>();
                    var restoredIds = new List<long>();

                    foreach (var w in work)
                    {
                        long rowId = (long)w[0];
                        var def = CourseTableRegistry.Find((string)w[1], (string)w[2]);
                        if (def == null && (string)w[2] == "acad_course")
                            def = new CourseTableDef { Db = (string)w[1], Table = "acad_course", PkCol = "courseID", CourseCol = "courseID", Label = "Course" };
                        if (def == null) { blocked++; continue; }
                        string pkVal = (string)w[4], regno = (string)w[5], action = (string)w[8];

                        Dictionary<string, object> before = null, after = null;
                        try
                        {
                            before = Json.Deserialize<Dictionary<string, object>>((string)w[6]);
                            if (!string.IsNullOrEmpty((string)w[7])) after = Json.Deserialize<Dictionary<string, object>>((string)w[7]);
                        }
                        catch { blocked++; continue; }
                        if (before == null) { blocked++; continue; }

                        // A row this module DELETED is put back by re-inserting its snapshot.
                        if (action == "DELETE")
                        {
                            try
                            {
                                if (ReInsert(c, t, def, before))
                                {
                                    pend.Add(new Pending { def = def, pk = pkVal, regno = regno, action = "INSERT", verdict = CorrectionVerdict.Reversed, before = null, after = before, note = "Re-created from " + revRef });
                                    restoredIds.Add(rowId); touched.Add(def.Table); restored++;
                                }
                                else blocked++;
                            }
                            catch { blocked++; }
                            continue;
                        }

                        var current = ReadOne(c, t, def, pkVal);
                        if (current == null)
                        {
                            pend.Add(new Pending { def = def, pk = pkVal, regno = regno, action = "SKIP", verdict = CorrectionVerdict.ChangedSince, before = after, after = null, note = "The record no longer exists." });
                            blocked++; continue;
                        }

                        // Only the columns this module changed are compared and restored, so an
                        // unrelated later edit is left intact.
                        var changed = new List<string>();
                        if (after != null)
                            foreach (var kv in after)
                            {
                                object b; if (!before.TryGetValue(kv.Key, out b)) continue;
                                if (!SameValue(b, kv.Value)) changed.Add(kv.Key);
                            }
                        if (changed.Count == 0) { blocked++; continue; }

                        bool drifted = false;
                        foreach (var col in changed)
                        {
                            object expect; after.TryGetValue(col, out expect);
                            object nowv; current.TryGetValue(col, out nowv);
                            if (!SameValue(expect, nowv)) { drifted = true; break; }
                        }
                        if (drifted)
                        {
                            pend.Add(new Pending { def = def, pk = pkVal, regno = regno, action = "SKIP", verdict = CorrectionVerdict.ChangedSince, before = current, after = null, note = "Changed after the correction — left as it is." });
                            blocked++; continue;
                        }

                        var sets = new Dictionary<string, object>();
                        foreach (var col in changed) { object v; before.TryGetValue(col, out v); sets[col] = v; }

                        var rejected = new List<Pending>();
                        var done = UpdateChunk(c, t, def, new List<object> { pkVal }, sets, rejected, null);
                        if (done.Count == 0)
                        {
                            pend.Add(new Pending { def = def, pk = pkVal, regno = regno, action = "SKIP", verdict = CorrectionVerdict.SkippedDuplicate, before = current, after = null, note = "Cannot restore — the original slot is taken." });
                            blocked++; continue;
                        }

                        pend.Add(new Pending { def = def, pk = pkVal, regno = regno, action = "UPDATE", verdict = CorrectionVerdict.Reversed, before = current, after = WithSets(current, sets), note = "Restored by " + revRef });
                        restoredIds.Add(rowId);
                        touched.Add(def.Table);
                        if (!string.IsNullOrEmpty(regno)) students.Add(regno);
                        restored++;
                        if (pend.Count >= 1000) FlushSnapshots(c, t, revId, pend);
                    }

                    FlushSnapshots(c, t, revId, pend);

                    foreach (var chunk in Chunks(restoredIds, ReadChunk))
                    {
                        var sb = new StringBuilder();
                        foreach (var id in chunk) { if (sb.Length > 0) sb.Append(','); sb.Append(id); }
                        using (var cmd = Cmd("UPDATE campus_dynamics.acad_correction_row SET reversed=1, reversed_at=NOW() WHERE id IN (" + sb + ")", c, t))
                            cmd.ExecuteNonQuery();
                    }

                    int left;
                    using (var cmd = Cmd("SELECT COUNT(*) FROM campus_dynamics.acad_correction_row WHERE batch_id=@b AND action IN ('UPDATE','DELETE') AND reversed=0", c, t))
                    { cmd.Parameters.AddWithValue("@b", batchId); left = Convert.ToInt32(cmd.ExecuteScalar()); }

                    using (var cmd = Cmd(
                        "UPDATE campus_dynamics.acad_correction_batch SET status=@st, reversed_by=@by, reversed_at=NOW(), " +
                        "reverse_reason=@rr, reverse_batch_ref=@rb WHERE id=@id", c, t))
                    {
                        cmd.Parameters.AddWithValue("@st", left == 0 ? "REVERSED" : "PARTIALLY_REVERSED");
                        cmd.Parameters.AddWithValue("@by", user ?? "");
                        cmd.Parameters.AddWithValue("@rr", Trunc(reason, 400));
                        cmd.Parameters.AddWithValue("@rb", revRef);
                        cmd.Parameters.AddWithValue("@id", batchId);
                        cmd.ExecuteNonQuery();
                    }

                    FinishBatch(c, t, revId, restored, blocked, students.Count, 0,
                                string.Join(", ", new List<string>(touched).ToArray()), (int)sw.ElapsedMilliseconds);
                    t.Commit();

                    res.batchId = revId; res.batchRef = revRef;
                    res.rowsApplied = restored; res.rowsSkipped = blocked; res.students = students.Count;
                    res.durationMs = (int)sw.ElapsedMilliseconds;
                    res.tablesTouched = string.Join(", ", new List<string>(touched).ToArray());
                    res.message = "Reversal " + revRef + " restored " + restored.ToString("N0") + " record" + (restored == 1 ? "" : "s") +
                                  (blocked > 0 ? ", leaving " + blocked.ToString("N0") + " that had changed since." : ".");
                    return res;
                }
                catch (Exception ex)
                {
                    try { t.Rollback(); } catch { }
                    res.success = false;
                    res.message = "The reversal was abandoned and nothing was changed. " + ex.Message;
                    return res;
                }
            }
        }
    }

    private static Dictionary<string, object> ReadOne(MySqlConnection c, MySqlTransaction t, CourseTableDef def, object pk)
    {
        using (var cmd = Cmd("SELECT * FROM " + def.Qualified + " WHERE " + def.PkCol + "=@pk LIMIT 1", c, t))
        {
            cmd.Parameters.AddWithValue("@pk", pk);
            using (var r = cmd.ExecuteReader())
                return r.Read() ? RowToDict(r) : null;
        }
    }

    private static bool ReInsert(MySqlConnection c, MySqlTransaction t, CourseTableDef def, Dictionary<string, object> row)
    {
        var cols = new StringBuilder(); var vals = new StringBuilder();
        var cmd = Cmd("", c, t);
        int i = 0;
        foreach (var kv in row)
        {
            if (i > 0) { cols.Append(','); vals.Append(','); }
            cols.Append(kv.Key); vals.Append("@p").Append(i);
            cmd.Parameters.AddWithValue("@p" + i, kv.Value ?? DBNull.Value);
            i++;
        }
        cmd.CommandText = "INSERT INTO " + def.Qualified + " (" + cols + ") VALUES (" + vals + ")";
        using (cmd) return cmd.ExecuteNonQuery() > 0;
    }

    private static bool SameValue(object a, object b)
    {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return string.Equals(Convert.ToString(a, CultureInfo.InvariantCulture),
                             Convert.ToString(b, CultureInfo.InvariantCulture), StringComparison.Ordinal);
    }
}
