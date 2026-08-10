using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Approve / reject / reverse a student's request to delete a course registration that
/// carries marks.
///
/// Context: a student can delete their own course pick only while it has NO marks. Once a
/// mark exists — provisional coursework/exam/total on the registration row, or a published
/// row in acad_results — self-service delete is refused, because removing it silently would
/// drop a real academic record. Those cases now become a request that an administrator
/// decides on, and every approved deletion is fully reversible.
///
/// The three things this class is careful about:
///
///  1. A course with marks lives in TWO places. Deleting only the registration would leave
///     the published result behind, so the student would still see the course on their
///     transcript and the deletion would appear not to have worked. Both are removed, and
///     both are snapshotted.
///
///  2. The snapshot is generic. Every column of every affected row is captured as
///     name/value pairs rather than a fixed list, so a restore keeps working if either
///     table gains or loses a column later — which they have, repeatedly.
///
///  3. Removing (or restoring) a published result changes the student's semester GPA, so
///     the affected semester is recomputed on both the delete and the reverse. Skipping
///     that would leave a GPA that silently disagrees with the results behind it.
/// </summary>
public static class CourseDeletionService
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    private const string REQ_TABLE = "campus_dynamics_portal.acad_course_deletion_requests";
    private const string REG_TABLE = "campus_dynamics_portal.acad_course_registration";
    private const string RES_TABLE = "campus_dynamics.acad_results";

    private static string Conn
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
            return cs != null ? cs.ConnectionString
                              : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";
        }
    }

    // ── Generic row capture / restore ────────────────────────────────────────
    // Deliberately schema-agnostic: SELECT * and keep whatever comes back. A hard-coded
    // column list would silently stop restoring any column added after this was written.

    private static List<Dictionary<string, object>> CaptureRows(MySqlConnection c, MySqlTransaction tx,
        string sql, params MySqlParameter[] ps)
    {
        var list = new List<Dictionary<string, object>>();
        using (var cmd = new MySqlCommand(sql, c, tx))
        {
            foreach (var p in ps) cmd.Parameters.Add(new MySqlParameter(p.ParameterName, p.Value));
            using (var rd = cmd.ExecuteReader())
                while (rd.Read())
                {
                    var row = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
                    for (int i = 0; i < rd.FieldCount; i++)
                    {
                        object v = rd.GetValue(i);
                        if (v == DBNull.Value) v = null;
                        else if (v is DateTime) v = ((DateTime)v).ToString("yyyy-MM-dd HH:mm:ss");
                        else if (!(v is string) && !(v is bool)) v = Convert.ToString(v, System.Globalization.CultureInfo.InvariantCulture);
                        row[rd.GetName(i)] = v;
                    }
                    list.Add(row);
                }
        }
        return list;
    }

    /// <summary>
    /// Re-insert a captured row. Columns that no longer exist on the target table are
    /// dropped rather than throwing — a restore should still put back everything it can if
    /// the schema has moved on since the snapshot was taken.
    /// </summary>
    private static int RestoreRow(MySqlConnection c, MySqlTransaction tx, string table,
        Dictionary<string, object> row, HashSet<string> liveColumns)
    {
        var cols = new List<string>();
        var vals = new List<string>();
        var cmd = new MySqlCommand("", c, tx);
        int i = 0;
        foreach (var kv in row)
        {
            if (!liveColumns.Contains(kv.Key)) continue;   // column has since been dropped
            string p = "@p" + i++;
            cols.Add("`" + kv.Key + "`");
            vals.Add(p);
            cmd.Parameters.AddWithValue(p, kv.Value ?? (object)DBNull.Value);
        }
        if (cols.Count == 0) return 0;
        cmd.CommandText = "INSERT INTO " + table + " (" + string.Join(",", cols.ToArray()) +
                          ") VALUES (" + string.Join(",", vals.ToArray()) + ")";
        using (cmd) return cmd.ExecuteNonQuery();
    }

    private static HashSet<string> LiveColumns(MySqlConnection c, MySqlTransaction tx, string schema, string table)
    {
        var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        using (var cmd = new MySqlCommand(
            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@s AND TABLE_NAME=@t", c, tx))
        {
            cmd.Parameters.AddWithValue("@s", schema);
            cmd.Parameters.AddWithValue("@t", table);
            using (var rd = cmd.ExecuteReader()) while (rd.Read()) set.Add(rd.GetString(0));
        }
        return set;
    }

    // ── Admin: list ──────────────────────────────────────────────────────────
    public static string List(string status, string q, int page, int pageSize)
    {
        if (page < 1) page = 1;
        if (pageSize < 1 || pageSize > 200) pageSize = 25;
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                var w = new StringBuilder("WHERE 1=1");
                var ps = new List<MySqlParameter>();
                status = (status ?? "PENDING").Trim().ToUpperInvariant();
                if (status != "ALL") { w.Append(" AND status=@st"); ps.Add(new MySqlParameter("@st", status)); }
                if (!string.IsNullOrWhiteSpace(q))
                {
                    // Tokenised so a student number, reg no or either name part all work, in
                    // any order — the same behaviour as the other consoles.
                    string[] toks = q.Trim().Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                    for (int i = 0; i < toks.Length && i < 5; i++)
                    {
                        string p = "@q" + i;
                        w.Append(" AND (regno LIKE ").Append(p)
                         .Append(" OR student_name LIKE ").Append(p)
                         .Append(" OR course_id LIKE ").Append(p)
                         .Append(" OR course_name LIKE ").Append(p).Append(")");
                        ps.Add(new MySqlParameter(p, "%" + toks[i] + "%"));
                    }
                }

                int total;
                using (var cc = new MySqlCommand("SELECT COUNT(*) FROM " + REQ_TABLE + " " + w, c))
                { foreach (var p in ps) cc.Parameters.AddWithValue(p.ParameterName, p.Value); total = Convert.ToInt32(cc.ExecuteScalar()); }

                int pages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
                if (page > pages) page = pages;

                var rows = new List<object>();
                using (var cmd = new MySqlCommand(
                    "SELECT id, regno, student_name, programme_code, course_id, course_name, acad_year, study_year, semester," +
                    " had_marks, cw_marks, exam_marks, total_marks, mark_stage, published_score, published_grade," +
                    " request_reason, status, admin_username, admin_comment, DATE_FORMAT(decided_at,'%Y-%m-%d %H:%i') decided_at," +
                    " deletion_executed, DATE_FORMAT(deletion_executed_at,'%Y-%m-%d %H:%i') executed_at, snapshot_rows," +
                    " reversed_by, DATE_FORMAT(reversed_at,'%Y-%m-%d %H:%i') reversed_at," +
                    " DATE_FORMAT(created_at,'%Y-%m-%d %H:%i') created_at" +
                    " FROM " + REQ_TABLE + " " + w +
                    " ORDER BY (status='PENDING') DESC, id DESC LIMIT " + ((page - 1) * pageSize) + "," + pageSize, c))
                {
                    foreach (var p in ps) cmd.Parameters.AddWithValue(p.ParameterName, p.Value);
                    using (var rd = cmd.ExecuteReader())
                        while (rd.Read())
                            rows.Add(new
                            {
                                id = Convert.ToInt32(rd["id"]),
                                regno = S(rd["regno"]), name = S(rd["student_name"]), prog = S(rd["programme_code"]),
                                courseId = S(rd["course_id"]), courseName = S(rd["course_name"]),
                                acadYear = S(rd["acad_year"]), studyYear = S(rd["study_year"]), semester = S(rd["semester"]),
                                hadMarks = ToI(rd["had_marks"]) == 1,
                                cw = NI(rd["cw_marks"]), exam = NI(rd["exam_marks"]), total = NI(rd["total_marks"]),
                                markStage = S(rd["mark_stage"]),
                                pubScore = NI(rd["published_score"]), pubGrade = S(rd["published_grade"]),
                                reason = S(rd["request_reason"]), status = S(rd["status"]),
                                admin = S(rd["admin_username"]), adminComment = S(rd["admin_comment"]),
                                decidedAt = S(rd["decided_at"]),
                                executed = ToI(rd["deletion_executed"]) == 1, executedAt = S(rd["executed_at"]),
                                snapshotRows = NI(rd["snapshot_rows"]),
                                reversedBy = S(rd["reversed_by"]), reversedAt = S(rd["reversed_at"]),
                                createdAt = S(rd["created_at"])
                            });
                }

                int pending;
                using (var pc = new MySqlCommand("SELECT COUNT(*) FROM " + REQ_TABLE + " WHERE status='PENDING'", c))
                    pending = Convert.ToInt32(pc.ExecuteScalar());

                return Json.Serialize(new { success = true, rows, total, page, pages, pageSize, pending });
            }
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── Admin: reject ────────────────────────────────────────────────────────
    public static string Reject(int id, string admin, string comment)
    {
        if (string.IsNullOrWhiteSpace(comment))
            return Json.Serialize(new { success = false, message = "A reason is required when declining a request — the student is shown it." });
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                using (var cmd = new MySqlCommand(
                    "UPDATE " + REQ_TABLE + " SET status='REJECTED', admin_username=@by, admin_comment=@cm," +
                    " decided_at=NOW(), student_seen=0 WHERE id=@id AND status='PENDING'", c))
                {
                    cmd.Parameters.AddWithValue("@by", admin ?? "");
                    cmd.Parameters.AddWithValue("@cm", comment.Trim());
                    cmd.Parameters.AddWithValue("@id", id);
                    if (cmd.ExecuteNonQuery() == 0)
                        return Json.Serialize(new { success = false, message = "This request is no longer pending — it may have been decided by someone else." });
                }
                return Json.Serialize(new { success = true, message = "Request declined. The student will see your reason." });
            }
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── Admin: approve → snapshot, delete, settle GPA ────────────────────────
    public static string Approve(int id, string admin, string comment)
    {
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                string regno, courseId, acadYear; int semester;

                // Claim the request first, so two administrators clicking Approve at the same
                // moment cannot both run the deletion.
                using (var claim = new MySqlCommand(
                    "UPDATE " + REQ_TABLE + " SET status='APPROVED', admin_username=@by, admin_comment=@cm," +
                    " decided_at=NOW(), student_seen=0 WHERE id=@id AND status='PENDING'", c))
                {
                    claim.Parameters.AddWithValue("@by", admin ?? "");
                    claim.Parameters.AddWithValue("@cm", (object)(comment ?? "").Trim() ?? DBNull.Value);
                    claim.Parameters.AddWithValue("@id", id);
                    if (claim.ExecuteNonQuery() == 0)
                        return Json.Serialize(new { success = false, message = "This request is no longer pending — it may have been decided by someone else." });
                }

                using (var g = new MySqlCommand("SELECT regno, course_id, acad_year, semester FROM " + REQ_TABLE + " WHERE id=@id", c))
                {
                    g.Parameters.AddWithValue("@id", id);
                    using (var rd = g.ExecuteReader())
                    {
                        if (!rd.Read()) return Json.Serialize(new { success = false, message = "Request not found." });
                        regno = rd.GetString(0); courseId = rd.GetString(1); acadYear = rd.GetString(2); semester = Convert.ToInt32(rd[3]);
                    }
                }

                int regRows, resRows;
                using (var tx = c.BeginTransaction())
                {
                    try
                    {
                        // 1. Snapshot BEFORE touching anything.
                        var regSnap = CaptureRows(c, tx,
                            "SELECT * FROM " + REG_TABLE + " WHERE TRIM(regno)=@r AND courseID=@c AND acad_year=@a AND semester=@s",
                            new MySqlParameter("@r", regno), new MySqlParameter("@c", courseId),
                            new MySqlParameter("@a", acadYear), new MySqlParameter("@s", semester));

                        var resSnap = CaptureRows(c, tx,
                            "SELECT * FROM " + RES_TABLE + " WHERE TRIM(regno)=@r AND UPPER(TRIM(courseid))=UPPER(TRIM(@c)) AND acad=@a AND semester=@s",
                            new MySqlParameter("@r", regno), new MySqlParameter("@c", courseId),
                            new MySqlParameter("@a", acadYear), new MySqlParameter("@s", semester));

                        if (regSnap.Count == 0 && resSnap.Count == 0)
                        {
                            tx.Rollback();
                            return Json.Serialize(new { success = false, message = "Nothing to delete — the registration is already gone. The request has been marked approved but no change was made." });
                        }

                        string snapshot = Json.Serialize(new
                        {
                            takenAt = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
                            registration = regSnap,
                            results = resSnap
                        });

                        using (var up = new MySqlCommand(
                            "UPDATE " + REQ_TABLE + " SET snapshot_json=@j, snapshot_rows=@n WHERE id=@id", c, tx))
                        {
                            up.Parameters.AddWithValue("@j", snapshot);
                            up.Parameters.AddWithValue("@n", regSnap.Count + resSnap.Count);
                            up.Parameters.AddWithValue("@id", id);
                            up.ExecuteNonQuery();
                        }

                        // 2. Delete the published result FIRST. Leaving it behind would keep the
                        //    course on the transcript and make the deletion look like it failed.
                        resRows = 0;
                        if (resSnap.Count > 0)
                        {
                            MarksAuditContext(c, tx, admin, "CourseDeletion:approve",
                                "Course registration deleted on approved student request #" + id);
                            using (var d = new MySqlCommand(
                                "DELETE FROM " + RES_TABLE + " WHERE TRIM(regno)=@r AND UPPER(TRIM(courseid))=UPPER(TRIM(@c)) AND acad=@a AND semester=@s", c, tx))
                            {
                                d.Parameters.AddWithValue("@r", regno); d.Parameters.AddWithValue("@c", courseId);
                                d.Parameters.AddWithValue("@a", acadYear); d.Parameters.AddWithValue("@s", semester);
                                resRows = d.ExecuteNonQuery();
                            }
                        }

                        // 3. Then the registration row itself.
                        using (var d = new MySqlCommand(
                            "DELETE FROM " + REG_TABLE + " WHERE TRIM(regno)=@r AND courseID=@c AND acad_year=@a AND semester=@s", c, tx))
                        {
                            d.Parameters.AddWithValue("@r", regno); d.Parameters.AddWithValue("@c", courseId);
                            d.Parameters.AddWithValue("@a", acadYear); d.Parameters.AddWithValue("@s", semester);
                            regRows = d.ExecuteNonQuery();
                        }

                        // 4. The semester GPA was computed including the result just removed.
                        RecomputeSemesterGpa(c, tx, regno, acadYear, semester);

                        using (var fin = new MySqlCommand(
                            "UPDATE " + REQ_TABLE + " SET deletion_executed=1, deletion_executed_at=NOW() WHERE id=@id", c, tx))
                        { fin.Parameters.AddWithValue("@id", id); fin.ExecuteNonQuery(); }

                        tx.Commit();
                    }
                    catch (Exception)
                    {
                        try { tx.Rollback(); } catch { }
                        // Hand the request back so it can be retried rather than being stuck APPROVED-but-not-executed.
                        try
                        {
                            using (var rb = new MySqlCommand("UPDATE " + REQ_TABLE + " SET status='PENDING', decided_at=NULL WHERE id=@id AND deletion_executed=0", c))
                            { rb.Parameters.AddWithValue("@id", id); rb.ExecuteNonQuery(); }
                        }
                        catch { }
                        throw;
                    }
                }

                return Json.Serialize(new
                {
                    success = true,
                    message = "Deleted " + regRows + " registration row and " + resRows + " published result row. This can be reversed from the request record.",
                    registrationRows = regRows,
                    resultRows = resRows
                });
            }
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = "Approve failed: " + ex.Message }); }
    }

    // ── Admin: reverse → put everything back exactly as captured ─────────────
    public static string Reverse(int id, string admin, string comment)
    {
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                string snapshot, regno, acadYear; int semester;
                using (var g = new MySqlCommand(
                    "SELECT IFNULL(snapshot_json,''), regno, acad_year, semester, status, deletion_executed FROM " + REQ_TABLE + " WHERE id=@id", c))
                {
                    g.Parameters.AddWithValue("@id", id);
                    using (var rd = g.ExecuteReader())
                    {
                        if (!rd.Read()) return Json.Serialize(new { success = false, message = "Request not found." });
                        snapshot = rd.GetString(0); regno = rd.GetString(1); acadYear = rd.GetString(2);
                        semester = Convert.ToInt32(rd[3]);
                        string st = rd.GetString(4);
                        bool executed = Convert.ToInt32(rd[5]) == 1;
                        if (st == "REVERSED") return Json.Serialize(new { success = false, message = "This deletion has already been reversed." });
                        if (!executed) return Json.Serialize(new { success = false, message = "Nothing to reverse — this request was never executed." });
                    }
                }
                if (string.IsNullOrEmpty(snapshot))
                    return Json.Serialize(new { success = false, message = "No snapshot stored for this request, so it cannot be reversed automatically." });

                var snap = Json.Deserialize<Dictionary<string, object>>(snapshot);
                var regRows = ToRowList(snap.ContainsKey("registration") ? snap["registration"] : null);
                var resRows = ToRowList(snap.ContainsKey("results") ? snap["results"] : null);

                int restoredReg = 0, restoredRes = 0, skipped = 0;
                using (var tx = c.BeginTransaction())
                {
                    try
                    {
                        var regCols = LiveColumns(c, tx, "campus_dynamics_portal", "acad_course_registration");
                        var resCols = LiveColumns(c, tx, "campus_dynamics", "acad_results");

                        foreach (var row in regRows)
                        {
                            // Never create a duplicate: if the student re-registered for the
                            // same course in the meantime, leave the live row alone.
                            if (RegistrationExists(c, tx, row)) { skipped++; continue; }
                            restoredReg += RestoreRow(c, tx, REG_TABLE, row, regCols);
                        }
                        foreach (var row in resRows)
                        {
                            if (ResultExists(c, tx, row)) { skipped++; continue; }
                            restoredRes += RestoreRow(c, tx, RES_TABLE, row, resCols);
                        }

                        // Putting a result back changes the semester GPA again.
                        RecomputeSemesterGpa(c, tx, regno, acadYear, semester);

                        using (var up = new MySqlCommand(
                            "UPDATE " + REQ_TABLE + " SET status='REVERSED', reversed_by=@by, reversed_at=NOW()," +
                            " reverse_comment=@cm, student_seen=0 WHERE id=@id", c, tx))
                        {
                            up.Parameters.AddWithValue("@by", admin ?? "");
                            up.Parameters.AddWithValue("@cm", (object)(comment ?? "").Trim() ?? DBNull.Value);
                            up.Parameters.AddWithValue("@id", id);
                            up.ExecuteNonQuery();
                        }
                        tx.Commit();
                    }
                    catch (Exception) { try { tx.Rollback(); } catch { } throw; }
                }

                return Json.Serialize(new
                {
                    success = true,
                    message = "Restored " + restoredReg + " registration row and " + restoredRes + " result row." +
                              (skipped > 0 ? " " + skipped + " row(s) were skipped because a live record already exists." : ""),
                    restoredRegistration = restoredReg, restoredResults = restoredRes, skipped
                });
            }
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = "Reverse failed: " + ex.Message }); }
    }

    /// <summary>Full detail for one request, including the decoded snapshot.</summary>
    public static string Detail(int id)
    {
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                using (var cmd = new MySqlCommand("SELECT * FROM " + REQ_TABLE + " WHERE id=@id LIMIT 1", c))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (!rd.Read()) return Json.Serialize(new { success = false, message = "Request not found." });
                        var rec = new Dictionary<string, object>();
                        for (int i = 0; i < rd.FieldCount; i++)
                        {
                            object v = rd.GetValue(i);
                            rec[rd.GetName(i)] = v == DBNull.Value ? null
                                : (v is DateTime ? ((DateTime)v).ToString("yyyy-MM-dd HH:mm") : Convert.ToString(v));
                        }
                        object snapObj = null;
                        try
                        {
                            string sj = rec.ContainsKey("snapshot_json") ? (rec["snapshot_json"] as string) : null;
                            if (!string.IsNullOrEmpty(sj)) snapObj = Json.DeserializeObject(sj);
                        }
                        catch { }
                        rec.Remove("snapshot_json");
                        return Json.Serialize(new { success = true, record = rec, snapshot = snapObj });
                    }
                }
            }
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private static List<Dictionary<string, object>> ToRowList(object o)
    {
        var outList = new List<Dictionary<string, object>>();
        var arr = o as object[];
        if (arr == null)
        {
            var lst = o as List<object>;
            if (lst != null) arr = lst.ToArray();
        }
        if (arr == null) return outList;
        foreach (var item in arr)
        {
            var d = item as Dictionary<string, object>;
            if (d != null) outList.Add(new Dictionary<string, object>(d, StringComparer.OrdinalIgnoreCase));
        }
        return outList;
    }

    private static bool RegistrationExists(MySqlConnection c, MySqlTransaction tx, Dictionary<string, object> row)
    {
        string reg = Get(row, "regno"), crs = Get(row, "courseID"), ay = Get(row, "acad_year"), sem = Get(row, "semester");
        using (var cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM " + REG_TABLE + " WHERE TRIM(regno)=@r AND courseID=@c AND acad_year=@a AND semester=@s", c, tx))
        {
            cmd.Parameters.AddWithValue("@r", (reg ?? "").Trim());
            cmd.Parameters.AddWithValue("@c", crs); cmd.Parameters.AddWithValue("@a", ay); cmd.Parameters.AddWithValue("@s", sem);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    private static bool ResultExists(MySqlConnection c, MySqlTransaction tx, Dictionary<string, object> row)
    {
        string reg = Get(row, "regno"), crs = Get(row, "courseid");
        using (var cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM " + RES_TABLE + " WHERE TRIM(regno)=@r AND UPPER(TRIM(courseid))=UPPER(TRIM(@c))", c, tx))
        {
            cmd.Parameters.AddWithValue("@r", (reg ?? "").Trim());
            cmd.Parameters.AddWithValue("@c", crs);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    /// <summary>
    /// Rewrite acad_results.gpa for the affected student/semester. Both deleting and
    /// restoring a result change the weighted mean, so this runs on either path.
    /// </summary>
    private static void RecomputeSemesterGpa(MySqlConnection c, MySqlTransaction tx, string regno, string acadYear, int semester)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "UPDATE " + RES_TABLE + " t" +
                " JOIN (SELECT ROUND(SUM(COALESCE(gradept,0) * COALESCE(NULLIF(CreditUnits,0),3)) /" +
                "              NULLIF(SUM(COALESCE(NULLIF(CreditUnits,0),3)),0),2) AS g" +
                "       FROM " + RES_TABLE + " WHERE TRIM(regno)=@r AND acad=@a AND semester=@s) x" +
                " SET t.gpa = x.g" +
                " WHERE TRIM(t.regno)=@r AND t.acad=@a AND t.semester=@s", c, tx))
            {
                cmd.Parameters.AddWithValue("@r", (regno ?? "").Trim());
                cmd.Parameters.AddWithValue("@a", acadYear);
                cmd.Parameters.AddWithValue("@s", semester);
                cmd.ExecuteNonQuery();
            }
        }
        catch { /* GPA settle is best-effort; it must not roll back a valid deletion */ }
    }

    /// <summary>Attribute the acad_results change for the audit trigger (keyed by CONNECTION_ID()).</summary>
    private static void MarksAuditContext(MySqlConnection c, MySqlTransaction tx, string actor, string source, string reason)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "INSERT INTO mark_audit_context (conn_id, actor, source, reason, set_at) VALUES (CONNECTION_ID(),@a,@s,@r,NOW()) " +
                "ON DUPLICATE KEY UPDATE actor=VALUES(actor), source=VALUES(source), reason=VALUES(reason), set_at=VALUES(set_at)", c, tx))
            {
                cmd.Parameters.AddWithValue("@a", actor ?? "admin");
                cmd.Parameters.AddWithValue("@s", source);
                cmd.Parameters.AddWithValue("@r", reason);
                cmd.ExecuteNonQuery();
            }
        }
        catch { /* audit attribution is best-effort */ }
    }

    private static string Get(Dictionary<string, object> d, string k)
    { object v; return d.TryGetValue(k, out v) && v != null ? Convert.ToString(v) : ""; }
    private static string S(object v) { return v == null || v == DBNull.Value ? "" : v.ToString(); }
    private static int ToI(object v) { return v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v); }
    private static object NI(object v) { return v == null || v == DBNull.Value ? null : (object)Convert.ToInt32(v); }
}
