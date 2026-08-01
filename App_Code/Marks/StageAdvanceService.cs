using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// Definition of one stage transition (capture / approve / publish). All three
/// share identical mechanics, so one engine (StageAdvanceService) drives them.
/// </summary>
public class StageDef
{
    public string Name;          // "CAPTURE" | "APPROVE" | "PUBLISH"
    public string RecordTable;   // mark_capture_records | mark_approve_records | mark_publish_records
    public string RecordCol;     // capture_record_id | approve_record_id | publish_record_id
    public string FromStage;     // ENTERED | CAPTURED | APPROVED
    public string ToStage;       // CAPTURED | APPROVED | PUBLISHED
    public bool   WritesResults; // true only for PUBLISH (writes acad_results)
}

/// <summary>
/// Session-based, scope-aware stage advance engine:
///   CreateDraft → Preview → Commit (snapshot + advance + back-reference) / Cancel / Return.
/// Every query is restricted by MarksScope (admin=all, dean=faculty, HOD=department).
/// </summary>
public static class StageAdvanceService
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    public static readonly StageDef Capture = new StageDef {
        Name = "CAPTURE", RecordTable = "mark_capture_records", RecordCol = "capture_record_id",
        FromStage = MarkStage.ENTERED, ToStage = MarkStage.CAPTURED, WritesResults = false };
    public static readonly StageDef Approve = new StageDef {
        Name = "APPROVE", RecordTable = "mark_approve_records", RecordCol = "approve_record_id",
        FromStage = MarkStage.CAPTURED, ToStage = MarkStage.APPROVED, WritesResults = false };
    public static readonly StageDef Publish = new StageDef {
        Name = "PUBLISH", RecordTable = "mark_publish_records", RecordCol = "publish_record_id",
        FromStage = MarkStage.APPROVED, ToStage = MarkStage.PUBLISHED, WritesResults = true };

    public static StageDef ByName(string name)
    {
        string n = (name ?? "").Trim().ToUpperInvariant();
        if (n == "APPROVE") return Approve;
        if (n == "PUBLISH") return Publish;
        return Capture;
    }

    // Pass mark (NCHE 2015): a total below this is a failure (grade F).
    private const int PASS_MARK = 50;

    // Failure-filter fragment. EXCLUDE drops marks below the pass mark (nulls — no mark yet —
    // are kept, never silently dropped). INCLUDE (default / anything else) = no fail filter.
    private static string FailClause(string failMode)
    {
        if (string.Equals((failMode ?? "").Trim(), "EXCLUDE", StringComparison.OrdinalIgnoreCase))
            return " AND (cr.provisional_total_marks IS NULL OR cr.provisional_total_marks >= " + PASS_MARK + ") ";
        return "";
    }

    // ── Match WHERE for rows currently in FromStage, within scope + chosen params ──
    private static string BuildWhere(StageDef def, MarksScope scope, MySqlCommand cmd,
        string progId, int yearOfStudy, string acadYear, int semester, string failMode)
    {
        var sb = new StringBuilder(" WHERE cr.mark_stage = @from ");
        cmd.Parameters.AddWithValue("@from", def.FromStage);
        sb.Append(scope.ProgFilter("cr"));
        if (!string.IsNullOrEmpty(progId)) { sb.Append(" AND cr.prog_id = @prog "); cmd.Parameters.AddWithValue("@prog", progId); }
        if (!string.IsNullOrEmpty(acadYear)) { sb.Append(" AND cr.acad_year = @ay "); cmd.Parameters.AddWithValue("@ay", acadYear); }
        if (semester > 0) { sb.Append(" AND cr.semester = @sem "); cmd.Parameters.AddWithValue("@sem", semester); }
        if (yearOfStudy > 0)
        {
            sb.Append(" AND EXISTS (SELECT 1 FROM acad_registration r2 WHERE r2.regno=cr.regno " +
                      "AND r2.acad_year=cr.acad_year AND r2.semester=cr.semester AND r2.studyyear=@yos) ");
            cmd.Parameters.AddWithValue("@yos", yearOfStudy);
        }
        sb.Append(FailClause(failMode));   // no parameters — literal pass mark
        return sb.ToString();
    }

    // ── 1) Create a DRAFT record stamped with scope + params ─────────────────
    public static int CreateDraft(StageDef def, MarksScope scope, string actor, string actorName, string role,
        string progId, int yearOfStudy, string acadYear, int semester, bool all, string notes, string failMode)
    {
        // normalise: only 'EXCLUDE' changes behaviour; everything else = INCLUDE (default).
        string fm = string.Equals((failMode ?? "").Trim(), "EXCLUDE", StringComparison.OrdinalIgnoreCase) ? "EXCLUDE" : "INCLUDE";
        using (var conn = new MySqlConnection(MarkStage.ConnStr))
        {
            conn.Open();
            string paramsJson = Json.Serialize(new {
                progId = progId, yearOfStudy = yearOfStudy, acadYear = acadYear, semester = semester, all = all, failMode = fm });
            using (var cmd = new MySqlCommand(
                "INSERT INTO campus_dynamics_portal." + def.RecordTable +
                " (status, performed_by, performed_by_name, performed_by_role, scope_faculty_code, scope_department_id," +
                "  param_prog_id, param_year_of_study, param_acad_year, param_semester, param_all, param_fail_mode, params_json, notes, created_at)" +
                " VALUES ('DRAFT',@by,@nm,@role,@fac,@dept,@prog,@yos,@ay,@sem,@all,@fm,@pj,@notes,NOW())", conn))
            {
                cmd.Parameters.AddWithValue("@by", actor ?? "");
                cmd.Parameters.AddWithValue("@nm", actorName ?? "");
                cmd.Parameters.AddWithValue("@role", role ?? "");
                cmd.Parameters.AddWithValue("@fac", (scope.FacultyCodes.Count > 0) ? (object)scope.FacultyCodes[0] : DBNull.Value);
                cmd.Parameters.AddWithValue("@dept", (scope.DepartmentIds.Count > 0) ? (object)scope.DepartmentIds[0] : DBNull.Value);
                cmd.Parameters.AddWithValue("@prog", string.IsNullOrEmpty(progId) ? (object)DBNull.Value : progId);
                cmd.Parameters.AddWithValue("@yos", yearOfStudy > 0 ? (object)yearOfStudy : DBNull.Value);
                cmd.Parameters.AddWithValue("@ay", string.IsNullOrEmpty(acadYear) ? (object)DBNull.Value : acadYear);
                cmd.Parameters.AddWithValue("@sem", semester > 0 ? (object)semester : DBNull.Value);
                cmd.Parameters.AddWithValue("@all", all ? 1 : 0);
                cmd.Parameters.AddWithValue("@fm", fm);
                cmd.Parameters.AddWithValue("@pj", paramsJson);
                cmd.Parameters.AddWithValue("@notes", notes ?? "");
                cmd.ExecuteNonQuery();
                return (int)cmd.LastInsertedId;
            }
        }
    }

    // Load a draft record's params back into locals.
    private static bool LoadRecord(MySqlConnection conn, StageDef def, int recordId,
        out string status, out string progId, out int yos, out string acadYear, out int semester, out string failMode)
    {
        status = ""; progId = ""; yos = 0; acadYear = ""; semester = 0; failMode = "INCLUDE";
        using (var cmd = new MySqlCommand(
            "SELECT status, IFNULL(param_prog_id,''), IFNULL(param_year_of_study,0), IFNULL(param_acad_year,''), IFNULL(param_semester,0), IFNULL(param_fail_mode,'INCLUDE') " +
            "FROM campus_dynamics_portal." + def.RecordTable + " WHERE id=@id LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@id", recordId);
            using (var r = cmd.ExecuteReader())
            {
                if (!r.Read()) return false;
                status = r.GetString(0); progId = r.GetString(1); yos = r.GetInt32(2);
                acadYear = r.GetString(3); semester = r.GetInt32(4); failMode = r.GetString(5);
                return true;
            }
        }
    }

    // ── 2) Preview — count + per-programme breakdown + stats snapshot (no writes) ──
    public static object Preview(StageDef def, MarksScope scope, int recordId)
    {
        using (var conn = new MySqlConnection(MarkStage.ConnStr))
        {
            conn.Open();
            string status, progId, acadYear, failMode; int yos, semester;
            if (!LoadRecord(conn, def, recordId, out status, out progId, out yos, out acadYear, out semester, out failMode))
                return new { success = false, message = "Record not found." };

            object stats = MatchStats(conn, def, scope, progId, yos, acadYear, semester, failMode);
            List<object> rows = MatchBreakdown(conn, def, scope, progId, yos, acadYear, semester, failMode);
            int count = 0;
            foreach (var o in rows) { var d = (Dictionary<string, object>)o; count += Convert.ToInt32(d["count"]); }

            // Persist the preview snapshot onto the record.
            using (var up = new MySqlCommand("UPDATE campus_dynamics_portal." + def.RecordTable +
                " SET preview_count=@c, stats_snapshot_json=@s WHERE id=@id", conn))
            {
                up.Parameters.AddWithValue("@c", count);
                up.Parameters.AddWithValue("@s", Json.Serialize(stats));
                up.Parameters.AddWithValue("@id", recordId);
                up.ExecuteNonQuery();
            }
            return new { success = true, recordId = recordId, count = count, fromStage = def.FromStage,
                         toStage = def.ToStage, breakdown = rows, stats = stats };
        }
    }

    private static object MatchStats(MySqlConnection conn, StageDef def, MarksScope scope,
        string progId, int yos, string acadYear, int semester, string failMode)
    {
        using (var cmd = new MySqlCommand("", conn))
        {
            string where = BuildWhere(def, scope, cmd, progId, yos, acadYear, semester, failMode);
            cmd.CommandText =
                "SELECT COUNT(*) c, COUNT(DISTINCT cr.regno) studs, COUNT(DISTINCT cr.prog_id) progs," +
                " ROUND(AVG(cr.provisional_total_marks),1) avg_total," +
                " SUM(cr.provisional_total_marks>=50) passes, SUM(cr.provisional_total_marks>=80) distinctions," +
                " SUM(cr.provisional_total_marks<50) fails" +
                " FROM " + MarkStage.REG + " cr " + where;
            using (var r = cmd.ExecuteReader())
            {
                if (r.Read())
                {
                    int c = ToI(r["c"]); int passes = ToI(r["passes"]);
                    return new {
                        marks = c, students = ToI(r["studs"]), programmes = ToI(r["progs"]),
                        avgTotal = r["avg_total"] == DBNull.Value ? 0 : Convert.ToDouble(r["avg_total"]),
                        passes = passes, passRate = c > 0 ? Math.Round((double)passes * 100 / c, 1) : 0,
                        distinctions = ToI(r["distinctions"]), fails = ToI(r["fails"]) };
                }
            }
        }
        return new { marks = 0, students = 0, programmes = 0, avgTotal = 0, passes = 0, passRate = 0, distinctions = 0, fails = 0 };
    }

    private static List<object> MatchBreakdown(MySqlConnection conn, StageDef def, MarksScope scope,
        string progId, int yos, string acadYear, int semester, string failMode)
    {
        var list = new List<object>();
        using (var cmd = new MySqlCommand("", conn))
        {
            string where = BuildWhere(def, scope, cmd, progId, yos, acadYear, semester, failMode);
            cmd.CommandText =
                "SELECT cr.prog_id, COALESCE(NULLIF(p.progname,''),cr.prog_id) pname, cr.acad_year, cr.semester," +
                " COUNT(*) cnt, COUNT(DISTINCT cr.regno) studs, SUM(cr.provisional_total_marks<50) fails" +
                " FROM " + MarkStage.REG + " cr LEFT JOIN acad_programme p ON p.progcode=cr.prog_id " + where +
                " GROUP BY cr.prog_id, pname, cr.acad_year, cr.semester ORDER BY cnt DESC LIMIT 200";
            using (var r = cmd.ExecuteReader())
                while (r.Read())
                {
                    var d = new Dictionary<string, object>();
                    d["prog_id"] = S(r["prog_id"]); d["prog_name"] = S(r["pname"]);
                    d["acad_year"] = S(r["acad_year"]); d["semester"] = S(r["semester"]);
                    d["count"] = ToI(r["cnt"]); d["students"] = ToI(r["studs"]); d["fails"] = ToI(r["fails"]);
                    list.Add(d);
                }
        }
        return list;
    }

    // ── 3) Commit — advance matched rows, snapshot, back-reference, finalise ──
    public static object Commit(StageDef def, MarksScope scope, int recordId, string actor)
    {
        using (var conn = new MySqlConnection(MarkStage.ConnStr))
        {
            conn.Open();
            string status, progId, acadYear, failMode; int yos, semester;
            if (!LoadRecord(conn, def, recordId, out status, out progId, out yos, out acadYear, out semester, out failMode))
                return new { success = false, message = "Record not found." };
            if (status == "COMMITTED") return new { success = false, message = "This session is already committed." };
            if (status == "CANCELLED") return new { success = false, message = "This session was cancelled." };

            // snapshot BEFORE advancing (captures the state that is being moved)
            object stats = MatchStats(conn, def, scope, progId, yos, acadYear, semester, failMode);
            List<object> breakdown = MatchBreakdown(conn, def, scope, progId, yos, acadYear, semester, failMode);

            int affected = 0;
            using (var tx = conn.BeginTransaction())
            {
                try
                {
                    if (def.WritesResults)
                    {
                        // PUBLISH: write each row to acad_results via the existing engine, then advance.
                        var ids = new List<int>();
                        using (var cmd = new MySqlCommand("", conn, tx))
                        {
                            string where = BuildWhere(def, scope, cmd, progId, yos, acadYear, semester, failMode);
                            cmd.CommandText = "SELECT cr.id FROM " + MarkStage.REG + " cr " + where + " LIMIT 5000";
                            using (var r = cmd.ExecuteReader()) while (r.Read()) ids.Add(Convert.ToInt32(r[0]));
                        }
                        foreach (int id in ids)
                        {
                            if (MarksControllerShared.PublishSingle(conn, tx, id, actor))
                            {
                                StampRow(conn, tx, def, recordId, actor, id);
                                affected++;
                            }
                        }
                    }
                    else
                    {
                        using (var cmd = new MySqlCommand("", conn, tx))
                        {
                            string where = BuildWhere(def, scope, cmd, progId, yos, acadYear, semester, failMode);
                            cmd.CommandText =
                                "UPDATE " + MarkStage.REG + " cr SET cr.mark_stage=@to, cr.provisional_marks_status=@legacy," +
                                " cr." + def.RecordCol + "=@rid, cr.mark_stage_changed_at=NOW(), cr.mark_stage_changed_by=@by " + where;
                            cmd.Parameters.AddWithValue("@to", def.ToStage);
                            cmd.Parameters.AddWithValue("@legacy", MarkStage.LegacyStatus(def.ToStage));
                            cmd.Parameters.AddWithValue("@rid", recordId);
                            cmd.Parameters.AddWithValue("@by", actor ?? "");
                            affected = cmd.ExecuteNonQuery();
                        }
                    }

                    using (var fin = new MySqlCommand("UPDATE campus_dynamics_portal." + def.RecordTable +
                        " SET status='COMMITTED', committed_at=NOW(), affected_count=@n, summary_json=@sum, stats_snapshot_json=@stats," +
                        " performed_by=COALESCE(performed_by,@by) WHERE id=@id", conn, tx))
                    {
                        fin.Parameters.AddWithValue("@n", affected);
                        fin.Parameters.AddWithValue("@sum", Json.Serialize(new { fromStage = def.FromStage, toStage = def.ToStage, breakdown = breakdown }));
                        fin.Parameters.AddWithValue("@stats", Json.Serialize(stats));
                        fin.Parameters.AddWithValue("@by", actor ?? "");
                        fin.Parameters.AddWithValue("@id", recordId);
                        fin.ExecuteNonQuery();
                    }
                    tx.Commit();
                }
                catch (Exception ex)
                {
                    try { tx.Rollback(); } catch { }
                    return new { success = false, message = "Commit failed: " + ex.Message };
                }
            }
            return new { success = true, recordId = recordId, affected = affected,
                         fromStage = def.FromStage, toStage = def.ToStage, stats = stats };
        }
    }

    private static void StampRow(MySqlConnection conn, MySqlTransaction tx, StageDef def, int recordId, string actor, int id)
    {
        using (var cmd = new MySqlCommand("UPDATE " + MarkStage.REG +
            " SET mark_stage=@to, provisional_marks_status=@legacy, " + def.RecordCol + "=@rid," +
            " mark_stage_changed_at=NOW(), mark_stage_changed_by=@by WHERE id=@id", conn, tx))
        {
            cmd.Parameters.AddWithValue("@to", def.ToStage);
            cmd.Parameters.AddWithValue("@legacy", MarkStage.LegacyStatus(def.ToStage));
            cmd.Parameters.AddWithValue("@rid", recordId);
            cmd.Parameters.AddWithValue("@by", actor ?? "");
            cmd.Parameters.AddWithValue("@id", id);
            cmd.ExecuteNonQuery();
        }
    }

    public static object Cancel(StageDef def, int recordId)
    {
        using (var conn = new MySqlConnection(MarkStage.ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand("UPDATE campus_dynamics_portal." + def.RecordTable +
                " SET status='CANCELLED' WHERE id=@id AND status='DRAFT'", conn))
            {
                cmd.Parameters.AddWithValue("@id", recordId);
                int n = cmd.ExecuteNonQuery();
                return new { success = n > 0, message = n > 0 ? "Session cancelled." : "Only draft sessions can be cancelled." };
            }
        }
    }

    // ── Send-back: return specific marks one stage down (with reason) ─────────
    public static object ReturnMarks(StageDef def, MarksScope scope, int[] ids, string reason, string actor)
    {
        if (ids == null || ids.Length == 0) return new { success = false, message = "No marks selected." };
        if (string.IsNullOrEmpty(reason)) return new { success = false, message = "A reason is required to send marks back." };
        string prev = MarkStage.PrevStage(def.FromStage); // one below the stage's source
        using (var conn = new MySqlConnection(MarkStage.ConnStr))
        {
            conn.Open();
            int affected = 0;
            foreach (int id in ids)
            {
                if (!scope.IsAdmin)
                {
                    // scope guard: only return marks within the user's scope + current FromStage
                    using (var chk = new MySqlCommand("SELECT COALESCE(prog_id,'') FROM " + MarkStage.REG + " WHERE id=@id AND mark_stage=@from LIMIT 1", conn))
                    {
                        chk.Parameters.AddWithValue("@id", id);
                        chk.Parameters.AddWithValue("@from", def.FromStage);
                        object v = chk.ExecuteScalar();
                        if (v == null || v == DBNull.Value || !scope.AllowsProg(v.ToString().Trim())) continue;
                    }
                }
                using (var cmd = new MySqlCommand("UPDATE " + MarkStage.REG +
                    " SET mark_stage=@prev, provisional_marks_status=@legacy, mark_returned_reason=@reason," +
                    " mark_stage_changed_at=NOW(), mark_stage_changed_by=@by WHERE id=@id AND mark_stage=@from", conn))
                {
                    cmd.Parameters.AddWithValue("@prev", prev);
                    cmd.Parameters.AddWithValue("@legacy", MarkStage.LegacyStatus(prev));
                    cmd.Parameters.AddWithValue("@reason", reason);
                    cmd.Parameters.AddWithValue("@by", actor ?? "");
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@from", def.FromStage);
                    affected += cmd.ExecuteNonQuery();
                }
            }
            return new { success = affected > 0, affected = affected,
                         message = affected + " mark(s) returned to " + MarkStage.Label(prev) + "." };
        }
    }

    private static int ToI(object v) { return v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v); }
    private static string S(object v) { return v == null || v == DBNull.Value ? "" : v.ToString(); }
}
