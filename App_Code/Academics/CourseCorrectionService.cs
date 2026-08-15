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
//  function, so the two can never disagree. Apply re-runs both inside the
//  transaction and compares a checksum taken at preview time; if anything
//  moved in between, the batch aborts having written nothing.
//
//  Every record touched is snapshotted whole (before + after) into
//  acad_correction_row BEFORE it is written, in the same transaction, so
//  an applied change can never exist without its snapshot.
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
    private const string SourcePage = "CourseCorrectionCentre";

    public static string ConnStr()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        return cs != null ? cs.ConnectionString
                          : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";
    }

    // ─────────────────────────────────────────────────────────────────
    //  Small helpers
    // ─────────────────────────────────────────────────────────────────
    private static string S(IDataRecord r, int i) { return r.IsDBNull(i) ? "" : Convert.ToString(r[i]).Trim(); }
    private static int I(IDataRecord r, int i) { return r.IsDBNull(i) ? 0 : Convert.ToInt32(r[i]); }
    private static string Esc(string s) { return (s ?? "").Replace("`", ""); }   // identifiers come from the registry only
    private static string Key(params string[] parts) { return string.Join("", parts).ToUpperInvariant(); }

    private static MySqlCommand Cmd(string sql, MySqlConnection c, MySqlTransaction t)
    {
        var cmd = new MySqlCommand(sql, c, t);
        cmd.CommandTimeout = 600;
        return cmd;
    }

    /// <summary>Attribute any mark movement to the real user — the acad_results triggers
    /// read this by CONNECTION_ID() and otherwise record 'system'.</summary>
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
                cmd.Parameters.AddWithValue("@r", (object)(reason ?? "") ?? "");
                cmd.Parameters.AddWithValue("@i", (object)ip ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
        catch { /* attribution is best-effort; it must never stop a correction */ }
    }

    // ─────────────────────────────────────────────────────────────────
    //  Candidate loading — the single source of truth for "what is in play"
    // ─────────────────────────────────────────────────────────────────
    private static string BuildMasterWhere(CorrectionConfig cfg, MarksScope scope, Dictionary<string, object> p)
    {
        var w = new StringBuilder(" WHERE 1=1 ");

        if (cfg.operation == CorrectionOp.TermTransfer)
        {
            // Term transfer works on a term, and optionally narrows to one course code.
            w.Append(" AND cr.acad_year=@srcYear "); p["@srcYear"] = cfg.sourceYear;
            if (!string.IsNullOrEmpty(cfg.sourceSemester)) { w.Append(" AND cr.semester=@srcSem "); p["@srcSem"] = cfg.sourceSemester; }
            if (!string.IsNullOrEmpty(cfg.sourceCode)) { w.Append(" AND cr.courseID=@srcCode "); p["@srcCode"] = cfg.sourceCode; }
        }
        else
        {
            // Course transfer / merge work on a course code, optionally narrowed to a term.
            w.Append(" AND cr.courseID=@srcCode "); p["@srcCode"] = cfg.sourceCode;
            if (!string.IsNullOrEmpty(cfg.sourceYear)) { w.Append(" AND cr.acad_year=@srcYear "); p["@srcYear"] = cfg.sourceYear; }
            if (!string.IsNullOrEmpty(cfg.sourceSemester)) { w.Append(" AND cr.semester=@srcSem "); p["@srcSem"] = cfg.sourceSemester; }
        }

        if (!string.IsNullOrEmpty(cfg.programme)) { w.Append(" AND cr.prog_id=@prog "); p["@prog"] = cfg.programme; }
        if (!string.IsNullOrEmpty(cfg.markStage)) { w.Append(" AND IFNULL(cr.mark_stage,'NOT_ENTERED')=@stage "); p["@stage"] = cfg.markStage; }
        if (!string.IsNullOrEmpty(cfg.registrationType)) { w.Append(" AND cr.registration_type=@rtype "); p["@rtype"] = cfg.registrationType; }
        if (!string.IsNullOrEmpty(cfg.courseStatus)) { w.Append(" AND cr.course_status=@cstatus "); p["@cstatus"] = cfg.courseStatus; }

        if (!string.IsNullOrEmpty(cfg.faculty)) { w.Append(" AND pr.faculty_code=@fac "); p["@fac"] = cfg.faculty; }
        int dep;
        if (!string.IsNullOrEmpty(cfg.department) && int.TryParse(cfg.department, out dep)) { w.Append(" AND pr.department_id=@dep "); p["@dep"] = dep; }

        var studs = cfg.StudentList();
        if (studs.Count > 0)
        {
            var sb = new StringBuilder();
            for (int i = 0; i < studs.Count; i++)
            {
                if (i > 0) sb.Append(",");
                string pn = "@stu" + i; sb.Append(pn); p[pn] = studs[i];
            }
            w.Append(" AND cr.regno IN (").Append(sb).Append(") ");
        }

        // Scope is applied in SQL. The browser cannot widen it.
        w.Append(scope.ProgFilter("cr", "prog_id"));
        return w.ToString();
    }

    private static List<PreviewRow> LoadCandidates(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, MarksScope scope)
    {
        var rows = new List<PreviewRow>();
        var p = new Dictionary<string, object>();
        string where = BuildMasterWhere(cfg, scope, p);

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
    //  Verdicts — computed set-wise, so a 5,000-row batch is 3 queries
    //  rather than 15,000.
    // ─────────────────────────────────────────────────────────────────
    private static void ApplyVerdicts(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, List<PreviewRow> rows)
    {
        if (rows.Count == 0) return;

        bool isTerm = cfg.operation == CorrectionOp.TermTransfer;
        var regnos = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var r in rows) if (seen.Add(r.regno)) regnos.Add(r.regno);

        string inRegs = InList(regnos);

        // 1) Registration slots already occupied at the destination.
        //    Course transfer  → (regno, targetCode, year, sem, status)
        //    Term transfer    → (regno, code, targetYear, targetSem, status)
        var occupied = new HashSet<string>();
        string occSql = isTerm
            ? "SELECT regno, courseID, course_status FROM campus_dynamics_portal.acad_course_registration " +
              "WHERE regno IN (" + inRegs + ") AND acad_year=@ty AND semester=@ts"
            : "SELECT regno, acad_year, semester, course_status FROM campus_dynamics_portal.acad_course_registration " +
              "WHERE regno IN (" + inRegs + ") AND courseID=@tc";
        using (var cmd = Cmd(occSql, c, t))
        {
            if (isTerm) { cmd.Parameters.AddWithValue("@ty", cfg.targetYear); cmd.Parameters.AddWithValue("@ts", cfg.targetSemester); }
            else cmd.Parameters.AddWithValue("@tc", cfg.targetCode);
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                    occupied.Add(isTerm
                        ? Key(S(r, 0), S(r, 1), S(r, 2))
                        : Key(S(r, 0), S(r, 1), I(r, 2).ToString(CultureInfo.InvariantCulture), S(r, 3)));
        }

        // 2) acad_results is UNIQUE on (regno, courseid) with no term — so a course-code
        //    transfer collides whenever the student already has a result on the target code.
        var resultOnTarget = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var resultOnSource = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (!isTerm && cfg.moveResults)
        {
            using (var cmd = Cmd("SELECT regno, courseid FROM campus_dynamics.acad_results " +
                                 "WHERE regno IN (" + inRegs + ") AND courseid IN (@sc,@tc)", c, t))
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
            if (occupied.Contains(slot))
            { row.verdict = CorrectionVerdict.SkippedDuplicate; continue; }

            if (!isTerm && cfg.moveResults && resultOnSource.Contains(row.regno) && resultOnTarget.Contains(row.regno))
            { row.verdict = CorrectionVerdict.SkippedResultClash; continue; }

            row.verdict = CorrectionVerdict.Moved;
        }
    }

    private static string InList(List<string> vals)
    {
        if (vals.Count == 0) return "''";
        var sb = new StringBuilder();
        for (int i = 0; i < vals.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.Append("'").Append(vals[i].Replace("\\", "\\\\").Replace("'", "''")).Append("'");
        }
        return sb.ToString();
    }

    /// <summary>Fingerprint of the candidate set AND its relevant state. Any edit between
    /// preview and apply changes it, and the batch refuses to run.</summary>
    private static string Checksum(List<PreviewRow> rows)
    {
        var sb = new StringBuilder();
        foreach (var r in rows)
            sb.Append(r.id).Append('|').Append(r.courseCode).Append('|').Append(r.acadYear).Append('|')
              .Append(r.semester).Append('|').Append(r.courseStatus).Append('|').Append(r.markStage).Append('|')
              .Append(r.total.HasValue ? r.total.Value.ToString(CultureInfo.InvariantCulture) : "-").Append(';');
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

            var rows = LoadCandidates(c, null, cfg, scope);
            if (rows.Count > MaxBatchRows)
            {
                res.success = false;
                res.message = "This selection covers more than " + MaxBatchRows.ToString("N0") +
                              " registrations. Narrow it by programme, academic year or semester and try again.";
                return res;
            }
            ApplyVerdicts(c, null, cfg, rows);
            CountSatellites(c, null, cfg, rows, res);

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

    private static string Validate(CorrectionConfig cfg, MarksScope scope)
    {
        if (!scope.HasAccess) return "You do not have a marks-management scope. Contact the administrator.";

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

    /// <summary>How many satellite records would travel with the actionable registrations.</summary>
    private static void CountSatellites(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, List<PreviewRow> rows, PreviewResult res)
    {
        var regs = new List<string>();
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var r in rows) if (CorrectionVerdict.IsActionable(r.verdict) && seen.Add(r.regno)) regs.Add(r.regno);
        if (regs.Count == 0) return;

        string inRegs = InList(regs);
        int total = 0;
        foreach (var def in CourseTableRegistry.Satellites)
        {
            if (!cfg.moveResults && (def.Table == "acad_results" || def.Table == "acad_transcript_results")) continue;
            string sql = "SELECT COUNT(*) FROM " + def.Qualified + " WHERE " + def.RegnoCol + " IN (" + inRegs + ") AND " +
                         def.CourseCol + "=@code";
            try
            {
                using (var cmd = Cmd(sql, c, t))
                {
                    cmd.Parameters.AddWithValue("@code", cfg.operation == CorrectionOp.TermTransfer ? cfg.sourceCode : cfg.sourceCode);
                    if (cfg.operation == CorrectionOp.TermTransfer && string.IsNullOrEmpty(cfg.sourceCode))
                    {
                        // term transfer with no code filter — count by term instead
                        cmd.CommandText = "SELECT COUNT(*) FROM " + def.Qualified + " WHERE " + def.RegnoCol + " IN (" + inRegs + ")" +
                                          (def.HasTerm ? " AND " + def.YearCol + "=@y" : "");
                        cmd.Parameters.Clear();
                        if (def.HasTerm) cmd.Parameters.AddWithValue("@y", cfg.sourceYear);
                    }
                    object o = cmd.ExecuteScalar();
                    if (o != null && o != DBNull.Value) total += Convert.ToInt32(o);
                }
            }
            catch { /* a satellite that cannot be counted is reported as zero, never fatal */ }
        }
        res.satelliteRows = total;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Row snapshots
    // ─────────────────────────────────────────────────────────────────
    private static Dictionary<string, object> ReadRow(MySqlConnection c, MySqlTransaction t, CourseTableDef def, object pk)
    {
        using (var cmd = Cmd("SELECT * FROM " + def.Qualified + " WHERE " + def.PkCol + "=@pk LIMIT 1", c, t))
        {
            cmd.Parameters.AddWithValue("@pk", pk);
            using (var r = cmd.ExecuteReader())
            {
                if (!r.Read()) return null;
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
        }
    }

    private static void RecordRow(MySqlConnection c, MySqlTransaction t, long batchId, CourseTableDef def,
                                  object pk, string regno, string courseCode, string action, string verdict,
                                  Dictionary<string, object> before, Dictionary<string, object> after, string note)
    {
        using (var cmd = Cmd(
            "INSERT INTO campus_dynamics.acad_correction_row " +
            "(batch_id, db_name, table_name, pk_column, pk_value, regno, course_code, action, verdict, before_json, after_json, note) " +
            "VALUES (@b,@db,@tb,@pc,@pv,@rg,@cc,@ac,@vd,@bj,@aj,@nt)", c, t))
        {
            cmd.Parameters.AddWithValue("@b", batchId);
            cmd.Parameters.AddWithValue("@db", def.Db);
            cmd.Parameters.AddWithValue("@tb", def.Table);
            cmd.Parameters.AddWithValue("@pc", def.PkCol);
            cmd.Parameters.AddWithValue("@pv", Convert.ToString(pk));
            cmd.Parameters.AddWithValue("@rg", (object)regno ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@cc", (object)courseCode ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ac", action);
            cmd.Parameters.AddWithValue("@vd", verdict);
            cmd.Parameters.AddWithValue("@bj", before == null ? (object)DBNull.Value : Json.Serialize(before));
            cmd.Parameters.AddWithValue("@aj", after == null ? (object)DBNull.Value : Json.Serialize(after));
            cmd.Parameters.AddWithValue("@nt", (object)note ?? DBNull.Value);
            cmd.ExecuteNonQuery();
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
                    // Re-run preview inside the transaction. If anything moved since the
                    // operator looked at it, nothing is written.
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

                    long batchId; string batchRef;
                    CreateBatch(c, t, cfg, scope, user, ip, rows.Count, out batchId, out batchRef);

                    int applied = 0, satellites = 0;
                    var touched = new HashSet<string>();
                    var students = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    var master = CourseTableRegistry.Master;
                    bool isTerm = cfg.operation == CorrectionOp.TermTransfer;

                    foreach (var row in actionable)
                    {
                        var before = ReadRow(c, t, master, row.id);
                        if (before == null) continue;

                        int n;
                        string note = null;
                        try
                        {
                            if (isTerm)
                            {
                                using (var cmd = Cmd("UPDATE " + master.Qualified + " SET acad_year=@y, semester=@s WHERE ID=@id", c, t))
                                {
                                    cmd.Parameters.AddWithValue("@y", cfg.targetYear);
                                    cmd.Parameters.AddWithValue("@s", cfg.targetSemester);
                                    cmd.Parameters.AddWithValue("@id", row.id);
                                    n = cmd.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                using (var cmd = Cmd("UPDATE " + master.Qualified + " SET courseID=@c WHERE ID=@id", c, t))
                                {
                                    cmd.Parameters.AddWithValue("@c", cfg.targetCode);
                                    cmd.Parameters.AddWithValue("@id", row.id);
                                    n = cmd.ExecuteNonQuery();
                                }
                            }
                        }
                        catch (MySqlException mex)
                        {
                            // 1062 = the unique index caught something the verdict engine did not.
                            // Record it and carry on; the transaction is unharmed by a failed statement.
                            RecordRow(c, t, batchId, master, row.id, row.regno, row.courseCode, "SKIP",
                                      CorrectionVerdict.SkippedDuplicate, before, null,
                                      "Rejected by the database: " + mex.Message);
                            continue;
                        }
                        if (n == 0) continue;

                        var after = ReadRow(c, t, master, row.id);
                        RecordRow(c, t, batchId, master, row.id, row.regno, row.courseCode, "UPDATE",
                                  CorrectionVerdict.Moved, before, after, note);
                        touched.Add(master.Table);
                        students.Add(row.regno);
                        applied++;

                        satellites += MoveSatellites(c, t, batchId, cfg, row, touched);
                    }

                    int residual = CountResidual(c, t, cfg, students);
                    FinishBatch(c, t, batchId, applied, rows.Count - applied, students.Count, residual,
                                string.Join(", ", new List<string>(touched).ToArray()), (int)sw.ElapsedMilliseconds);

                    t.Commit();

                    res.batchId = batchId; res.batchRef = batchRef;
                    res.rowsApplied = applied; res.rowsSkipped = rows.Count - applied;
                    res.students = students.Count; res.satelliteRows = satellites; res.residual = residual;
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

    /// <summary>Move every satellite record belonging to this registration.</summary>
    private static int MoveSatellites(MySqlConnection c, MySqlTransaction t, long batchId, CorrectionConfig cfg,
                                      PreviewRow row, HashSet<string> touched)
    {
        int moved = 0;
        bool isTerm = cfg.operation == CorrectionOp.TermTransfer;

        foreach (var def in CourseTableRegistry.Satellites)
        {
            if (!cfg.moveResults && (def.Table == "acad_results" || def.Table == "acad_transcript_results")) continue;

            // Which rows belong to this registration?
            //   • OnePerCourse tables hold at most one row per (student, course) and carry no
            //     term in their key, so the term is not used to find them.
            //   • Otherwise the term must match, unless the operator asked for all terms.
            var where = new StringBuilder(def.RegnoCol + "=@rg AND " + def.CourseCol + "=@sc");
            bool termBound = def.HasTerm && !def.OnePerCourse && !cfg.allTerms;
            if (termBound) where.Append(" AND ").Append(def.YearCol).Append("=@y AND ").Append(def.SemCol).Append("=@s");

            var ids = new List<object>();
            try
            {
                using (var cmd = Cmd("SELECT " + def.PkCol + " FROM " + def.Qualified + " WHERE " + where, c, t))
                {
                    cmd.Parameters.AddWithValue("@rg", row.regno);
                    cmd.Parameters.AddWithValue("@sc", row.courseCode);
                    if (termBound) { cmd.Parameters.AddWithValue("@y", row.acadYear); cmd.Parameters.AddWithValue("@s", row.semester); }
                    using (var r = cmd.ExecuteReader()) while (r.Read()) ids.Add(r.GetValue(0));
                }
            }
            catch { continue; }

            foreach (var pk in ids)
            {
                var before = ReadRow(c, t, def, pk);
                if (before == null) continue;

                string sets = isTerm
                    ? (def.HasTerm ? def.YearCol + "=@ny, " + def.SemCol + "=@ns" : null)
                    : def.CourseCol + "=@nc" + (string.IsNullOrEmpty(def.CourseCol2) ? "" : ", " + def.CourseCol2 + "=@nc");
                if (sets == null) continue;

                try
                {
                    using (var cmd = Cmd("UPDATE " + def.Qualified + " SET " + sets + " WHERE " + def.PkCol + "=@pk", c, t))
                    {
                        if (isTerm) { cmd.Parameters.AddWithValue("@ny", cfg.targetYear); cmd.Parameters.AddWithValue("@ns", cfg.targetSemester); }
                        else cmd.Parameters.AddWithValue("@nc", cfg.targetCode);
                        cmd.Parameters.AddWithValue("@pk", pk);
                        if (cmd.ExecuteNonQuery() == 0) continue;
                    }
                }
                catch (MySqlException mex)
                {
                    RecordRow(c, t, batchId, def, pk, row.regno, row.courseCode, "SKIP",
                              CorrectionVerdict.SkippedDuplicate, before, null, "Rejected by the database: " + mex.Message);
                    continue;
                }

                var after = ReadRow(c, t, def, pk);
                RecordRow(c, t, batchId, def, pk, row.regno, row.courseCode, "UPDATE", CorrectionVerdict.Moved, before, after, null);
                touched.Add(def.Table);
                moved++;
            }
        }
        return moved;
    }

    /// <summary>Records still carrying the old code for the students we touched — surfaced so a
    /// partial correction is never mistaken for a complete one.</summary>
    private static int CountResidual(MySqlConnection c, MySqlTransaction t, CorrectionConfig cfg, HashSet<string> students)
    {
        if (cfg.operation == CorrectionOp.TermTransfer || students.Count == 0) return 0;
        var list = new List<string>(students);
        string inRegs = InList(list);
        int total = 0;
        foreach (var def in CourseTableRegistry.StudentTables)
        {
            try
            {
                using (var cmd = Cmd("SELECT COUNT(*) FROM " + def.Qualified + " WHERE " + def.RegnoCol + " IN (" + inRegs + ") AND " +
                                     def.CourseCol + "=@sc", c, t))
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
            cmd.Parameters.AddWithValue("@scope", scope.RoleNote + " — " + scope.Label);
            cmd.Parameters.AddWithValue("@scan", scanned);
            cmd.Parameters.AddWithValue("@by", user ?? "");
            cmd.Parameters.AddWithValue("@ip", (object)ip ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@reason", cfg.reason ?? "");
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
            cmd.Parameters.AddWithValue("@tb", tables ?? "");
            cmd.Parameters.AddWithValue("@d", ms);
            cmd.Parameters.AddWithValue("@id", batchId);
            cmd.ExecuteNonQuery();
        }
    }

    private static string NextRef(MySqlConnection c, MySqlTransaction t)
    {
        string day = DateTime.Now.ToString("yyyyMMdd");
        using (var cmd = Cmd("SELECT COUNT(*)+1 FROM campus_dynamics.acad_correction_batch WHERE batch_ref LIKE @p", c, t))
        {
            cmd.Parameters.AddWithValue("@p", "CC-" + day + "-%");
            object o = cmd.ExecuteScalar();
            int n = (o == null || o == DBNull.Value) ? 1 : Convert.ToInt32(o);
            return "CC-" + day + "-" + n.ToString("D4");
        }
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
                    string op = "", status = "", srcCode = "", tgtCode = "";
                    using (var cmd = Cmd("SELECT operation, status, IFNULL(source_code,''), IFNULL(target_code,'') " +
                                         "FROM campus_dynamics.acad_correction_batch WHERE id=@id FOR UPDATE", c, t))
                    {
                        cmd.Parameters.AddWithValue("@id", batchId);
                        using (var r = cmd.ExecuteReader())
                        {
                            if (!r.Read()) { t.Rollback(); res.success = false; res.message = "That correction batch was not found."; return res; }
                            op = S(r, 0); status = S(r, 1); srcCode = S(r, 2); tgtCode = S(r, 3);
                        }
                    }
                    if (status == "REVERSED" && string.IsNullOrEmpty(onlyRegno))
                    { t.Rollback(); res.success = false; res.message = "This correction has already been reversed in full."; return res; }

                    // Rows are restored newest-first so a chain of edits unwinds in order.
                    var work = new List<object[]>();
                    string sql = "SELECT id, db_name, table_name, pk_column, pk_value, regno, before_json, after_json " +
                                 "FROM campus_dynamics.acad_correction_row " +
                                 "WHERE batch_id=@b AND action='UPDATE' AND reversed=0 " +
                                 (string.IsNullOrEmpty(onlyRegno) ? "" : "AND regno=@rg ") +
                                 "ORDER BY id DESC";
                    using (var cmd = Cmd(sql, c, t))
                    {
                        cmd.Parameters.AddWithValue("@b", batchId);
                        if (!string.IsNullOrEmpty(onlyRegno)) cmd.Parameters.AddWithValue("@rg", onlyRegno);
                        using (var r = cmd.ExecuteReader())
                            while (r.Read())
                                work.Add(new object[] { Convert.ToInt64(r[0]), S(r, 1), S(r, 2), S(r, 3), S(r, 4), S(r, 5), S(r, 6), S(r, 7) });
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

                    foreach (var w in work)
                    {
                        long rowId = (long)w[0];
                        var def = CourseTableRegistry.Find((string)w[1], (string)w[2]);
                        if (def == null) { blocked++; continue; }
                        string pkVal = (string)w[4], regno = (string)w[5];

                        Dictionary<string, object> before = null, after = null;
                        try
                        {
                            before = Json.Deserialize<Dictionary<string, object>>((string)w[6]);
                            after = Json.Deserialize<Dictionary<string, object>>((string)w[7]);
                        }
                        catch { blocked++; continue; }
                        if (before == null || after == null) { blocked++; continue; }

                        var current = ReadRow(c, t, def, pkVal);
                        if (current == null)
                        {
                            RecordRow(c, t, revId, def, pkVal, regno, null, "SKIP", CorrectionVerdict.ChangedSince,
                                      after, null, "The record no longer exists.");
                            blocked++; continue;
                        }

                        // Only the columns this module changed are compared and restored. An
                        // unrelated later edit (a lecturer status, a comment) is left intact.
                        var changed = new List<string>();
                        foreach (var kv in after)
                        {
                            object b; if (!before.TryGetValue(kv.Key, out b)) continue;
                            if (!SameValue(b, kv.Value)) changed.Add(kv.Key);
                        }
                        if (changed.Count == 0) { blocked++; continue; }

                        bool drifted = false;
                        foreach (var col in changed)
                        {
                            object cur; after.TryGetValue(col, out cur);
                            object nowv; current.TryGetValue(col, out nowv);
                            if (!SameValue(cur, nowv)) { drifted = true; break; }
                        }
                        if (drifted)
                        {
                            RecordRow(c, t, revId, def, pkVal, regno, null, "SKIP", CorrectionVerdict.ChangedSince,
                                      current, null, "Changed after the correction — left as it is.");
                            blocked++; continue;
                        }

                        var sets = new StringBuilder();
                        var ps = new List<MySqlParameter>();
                        for (int i = 0; i < changed.Count; i++)
                        {
                            if (i > 0) sets.Append(", ");
                            sets.Append(changed[i]).Append("=@v").Append(i);
                            object v; before.TryGetValue(changed[i], out v);
                            ps.Add(new MySqlParameter("@v" + i, v ?? DBNull.Value));
                        }

                        try
                        {
                            using (var cmd = Cmd("UPDATE " + def.Qualified + " SET " + sets + " WHERE " + def.PkCol + "=@pk", c, t))
                            {
                                foreach (var pp in ps) cmd.Parameters.Add(pp);
                                cmd.Parameters.AddWithValue("@pk", pkVal);
                                if (cmd.ExecuteNonQuery() == 0) { blocked++; continue; }
                            }
                        }
                        catch (MySqlException mex)
                        {
                            RecordRow(c, t, revId, def, pkVal, regno, null, "SKIP", CorrectionVerdict.SkippedDuplicate,
                                      current, null, "Cannot restore — the original slot is taken: " + mex.Message);
                            blocked++; continue;
                        }

                        var restoredRow = ReadRow(c, t, def, pkVal);
                        RecordRow(c, t, revId, def, pkVal, regno, null, "UPDATE", CorrectionVerdict.Reversed,
                                  current, restoredRow, "Restored from " + revRef);
                        using (var cmd = Cmd("UPDATE campus_dynamics.acad_correction_row SET reversed=1, reversed_at=NOW() WHERE id=@id", c, t))
                        { cmd.Parameters.AddWithValue("@id", rowId); cmd.ExecuteNonQuery(); }

                        touched.Add(def.Table);
                        if (!string.IsNullOrEmpty(regno)) students.Add(regno);
                        restored++;
                    }

                    // Fully or partly reversed?
                    int left;
                    using (var cmd = Cmd("SELECT COUNT(*) FROM campus_dynamics.acad_correction_row WHERE batch_id=@b AND action='UPDATE' AND reversed=0", c, t))
                    { cmd.Parameters.AddWithValue("@b", batchId); left = Convert.ToInt32(cmd.ExecuteScalar()); }

                    using (var cmd = Cmd(
                        "UPDATE campus_dynamics.acad_correction_batch SET status=@st, reversed_by=@by, reversed_at=NOW(), " +
                        "reverse_reason=@rr, reverse_batch_ref=@rb WHERE id=@id", c, t))
                    {
                        cmd.Parameters.AddWithValue("@st", left == 0 ? "REVERSED" : "PARTIALLY_REVERSED");
                        cmd.Parameters.AddWithValue("@by", user ?? "");
                        cmd.Parameters.AddWithValue("@rr", reason);
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

    private static bool SameValue(object a, object b)
    {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return string.Equals(Convert.ToString(a, CultureInfo.InvariantCulture),
                             Convert.ToString(b, CultureInfo.InvariantCulture), StringComparison.Ordinal);
    }
}
