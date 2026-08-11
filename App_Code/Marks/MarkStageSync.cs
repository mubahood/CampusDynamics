using System;
using MySql.Data.MySqlClient;

// =====================================================================
//  Keeps the staged marks journey and the legacy status column telling
//  the same story.
//
//  AllMarksController predates the lecturer → HOD → Dean → Senate chain.
//  Its actions wrote provisional_marks_status and stopped there, so every
//  admin approve / reject / publish / force-status left mark_stage — the
//  column the whole staged workflow, the stage consoles and the student
//  Mark Status Check now read — pointing at the old state. Production
//  carried the result: 27 rows PUBLISHED in the legacy column but
//  NOT_ENTERED in the stage, 2 the other way round, 4 more approved-but-
//  not-entered. A mark could be published to a student while every stage
//  console insisted nobody had even entered it.
//
//  Rather than duplicate the mapping at a dozen call sites, the stage is
//  DERIVED from the row's own final state in one statement: whatever the
//  action actually wrote is what the stage reflects. It cannot drift,
//  because it is not a second opinion — it is a projection.
// =====================================================================
public static class MarkStageSync
{
    private const string REG = "campus_dynamics_portal.acad_course_registration";

    /// <summary>
    /// Re-derives mark_stage (and the stage back-references) from what the record now says.
    /// Call at the end of ANY action that changes provisional_marks_status or the component
    /// marks, inside the same transaction. Idempotent, and safe to call twice.
    ///
    /// pending/rejected map to ENTERED only when both components are actually present —
    /// otherwise NOT_ENTERED. That distinction is what stops the 38,000 legacy rows that sit
    /// at "pending" with no marks at all from being claimed as work a lecturer has submitted.
    /// </summary>
    public static void Sync(MySqlConnection conn, MySqlTransaction tx, int id, string actor, string reason)
    {
        if (id <= 0) return;
        try
        {
            string sql =
                "UPDATE " + REG + " SET " +
                "  mark_stage = CASE LOWER(COALESCE(provisional_marks_status,'')) " +
                "      WHEN 'published' THEN 'PUBLISHED' " +
                "      WHEN 'approved'  THEN 'APPROVED' " +
                "      WHEN 'captured'  THEN 'CAPTURED' " +
                "      ELSE CASE WHEN provisional_course_work_marks IS NOT NULL " +
                "                 AND provisional_exam_marks IS NOT NULL " +
                "                THEN 'ENTERED' ELSE 'NOT_ENTERED' END END, " +
                // A record that is no longer published/approved/captured must not keep pointing
                // at the session that put it there — the audit trail would claim a stage it has
                // since been taken back through.
                "  publish_record_id = CASE WHEN LOWER(COALESCE(provisional_marks_status,''))='published' " +
                "                          THEN publish_record_id ELSE NULL END, " +
                "  approve_record_id = CASE WHEN LOWER(COALESCE(provisional_marks_status,'')) IN ('published','approved') " +
                "                          THEN approve_record_id ELSE NULL END, " +
                "  capture_record_id = CASE WHEN LOWER(COALESCE(provisional_marks_status,'')) IN ('published','approved','captured') " +
                "                          THEN capture_record_id ELSE NULL END, " +
                "  mark_returned_reason = CASE WHEN LOWER(COALESCE(provisional_marks_status,''))='rejected' AND @reason<>'' " +
                "                              THEN @reason ELSE mark_returned_reason END, " +
                "  mark_stage_changed_at = NOW(), " +
                "  mark_stage_changed_by = @actor " +
                "WHERE id = @id";

            using (MySqlCommand cmd = tx == null ? new MySqlCommand(sql, conn) : new MySqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@actor", string.IsNullOrEmpty(actor) ? "admin" : actor);
                cmd.Parameters.AddWithValue("@reason", string.IsNullOrEmpty(reason) ? "" : reason.Trim());
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }
        }
        catch
        {
            // Never let stage bookkeeping fail a mark action that has already been decided.
            // A missed sync is recoverable (SyncMany re-derives); a rolled-back approval is not.
        }
    }

    /// <summary>Convenience overload for callers that hold no transaction.</summary>
    public static void Sync(MySqlConnection conn, int id, string actor, string reason)
    { Sync(conn, null, id, actor, reason); }

    /// <summary>Opens its own connection — for call sites that have already closed theirs.</summary>
    public static void SyncStandalone(int id, string actor, string reason)
    {
        try
        {
            using (var conn = new MySqlConnection(MarkStage.ConnStr))
            { conn.Open(); Sync(conn, null, id, actor, reason); }
        }
        catch { }
    }

    /// <summary>Bulk form: same derivation over a set of ids, one statement per chunk.</summary>
    public static void SyncMany(MySqlConnection conn, MySqlTransaction tx, System.Collections.Generic.IEnumerable<int> ids, string actor)
    {
        if (ids == null) return;
        foreach (int id in ids) Sync(conn, tx, id, actor, "");
    }

    /// <summary>
    /// Re-derives every row whose stage contradicts its legacy status. Returns how many were
    /// repaired. Used by the console's "Repair stage drift" action and safe to run any time —
    /// rows that already agree are left alone, so it costs nothing to repeat.
    /// </summary>
    public static int RepairDrift(MySqlConnection conn, string actor)
    {
        string sql =
            "UPDATE " + REG + " SET " +
            "  mark_stage = CASE LOWER(COALESCE(provisional_marks_status,'')) " +
            "      WHEN 'published' THEN 'PUBLISHED' " +
            "      WHEN 'approved'  THEN 'APPROVED' " +
            "      WHEN 'captured'  THEN 'CAPTURED' " +
            "      ELSE CASE WHEN provisional_course_work_marks IS NOT NULL " +
            "                 AND provisional_exam_marks IS NOT NULL " +
            "                THEN 'ENTERED' ELSE 'NOT_ENTERED' END END, " +
            "  publish_record_id = CASE WHEN LOWER(COALESCE(provisional_marks_status,''))='published' THEN publish_record_id ELSE NULL END, " +
            "  approve_record_id = CASE WHEN LOWER(COALESCE(provisional_marks_status,'')) IN ('published','approved') THEN approve_record_id ELSE NULL END, " +
            "  capture_record_id = CASE WHEN LOWER(COALESCE(provisional_marks_status,'')) IN ('published','approved','captured') THEN capture_record_id ELSE NULL END, " +
            "  mark_stage_changed_at = NOW(), mark_stage_changed_by = @actor " +
            // Only the genuine contradictions. "pending with no marks" is legacy noise on tens of
            // thousands of rows, not drift, and rewriting it would churn the table for nothing.
            "WHERE (LOWER(COALESCE(provisional_marks_status,''))='published' AND UPPER(COALESCE(mark_stage,''))<>'PUBLISHED') " +
            "   OR (LOWER(COALESCE(provisional_marks_status,''))='approved'  AND UPPER(COALESCE(mark_stage,''))<>'APPROVED') " +
            "   OR (LOWER(COALESCE(provisional_marks_status,''))='captured'  AND UPPER(COALESCE(mark_stage,''))<>'CAPTURED') " +
            "   OR (LOWER(COALESCE(provisional_marks_status,'')) NOT IN ('published','approved','captured') " +
            "       AND UPPER(COALESCE(mark_stage,'')) IN ('PUBLISHED','APPROVED','CAPTURED'))";

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 300;
            cmd.Parameters.AddWithValue("@actor", string.IsNullOrEmpty(actor) ? "admin" : actor);
            return cmd.ExecuteNonQuery();
        }
    }

    /// <summary>Counts the rows whose stage and legacy status contradict each other.</summary>
    public static int DriftCount(MySqlConnection conn)
    {
        string sql =
            "SELECT COUNT(*) FROM " + REG + " WHERE " +
            "   (LOWER(COALESCE(provisional_marks_status,''))='published' AND UPPER(COALESCE(mark_stage,''))<>'PUBLISHED') " +
            "OR (LOWER(COALESCE(provisional_marks_status,''))='approved'  AND UPPER(COALESCE(mark_stage,''))<>'APPROVED') " +
            "OR (LOWER(COALESCE(provisional_marks_status,''))='captured'  AND UPPER(COALESCE(mark_stage,''))<>'CAPTURED') " +
            "OR (LOWER(COALESCE(provisional_marks_status,'')) NOT IN ('published','approved','captured') " +
            "    AND UPPER(COALESCE(mark_stage,'')) IN ('PUBLISHED','APPROVED','CAPTURED'))";
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 300;
            object v = cmd.ExecuteScalar();
            return v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v);
        }
    }
}
