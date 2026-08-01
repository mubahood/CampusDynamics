using System;
using System.Collections.Generic;
using System.Web.Services;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AllMarksController : System.Web.UI.Page
{
    private const AdminMarksPageKind PageKind = AdminMarksPageKind.AllMarks;
    private const string PAGE = "AllMarksController";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Accessible to admin + top management (deans / HODs / registrar). The record-level scope
        // (RecordInScope in MarksControllerShared) then limits WHAT each manager can edit:
        // admin = everything, dean = their faculty's programmes, HOD = their department's.
        MarksScope scope = MarksScopeResolver.Resolve();
        if (!scope.HasAccess)
        {
            if (litRows != null)
                litRows.Text = "<tr><td colspan=\"20\" style=\"text-align:center;padding:44px;color:#b42318;font-weight:600;\">"
                    + "Access denied &mdash; you do not have a marks-management scope. Contact the administrator.</td></tr>";
            return;
        }

        using (MySqlConnection conn = new MySqlConnection(MarksControllerShared.ConnectionString))
        {
            conn.Open();
            MarksControllerShared.EnsureProvisionalColumns(conn);
            MarksControllerShared.LoadFilters(Request, conn, ddlYear, ddlSemester, ddlStatus, ddlProg, ddlLecturer, ddlPageSize, txtSearch, PageKind);
            MarksControllerShared.LoadStats(conn, litStatTotal, litPending, litApproved, litRejected, litPublished, litNotEntered);
            MarksControllerShared.BindGrid(Request, conn, ddlYear, ddlSemester, ddlStatus, ddlProg, ddlLecturer, ddlPageSize, txtSearch, litRows, litFrom, litTo, litTotal, litTotal2, litPage, litPageCount, litPager, litPager2, PageKind);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    //  Per-action logging: EVERY action on this page becomes an independent,
    //  timed, attributed record in acad_marks_action_log (who / what / when /
    //  context / outcome / duration). The logger swallows its own errors, so it
    //  can never break a mark action. Actual data changes are additionally
    //  captured by the acad_results audit trigger (acad_marks_audit).
    // ─────────────────────────────────────────────────────────────────────────
    private static string Run(string action, Dictionary<string, string> ctx, Func<string> op)
    {
        System.Diagnostics.Stopwatch sw = MarksActionLogger.StartTimer();
        string outcome = MarksActionLogger.OUTCOME_SUCCESS;
        try
        {
            string result = op();
            outcome = OutcomeOf(result);
            return result;
        }
        catch (Exception ex)
        {
            outcome = MarksActionLogger.OUTCOME_ERROR;
            if (ctx == null) ctx = new Dictionary<string, string>();
            ctx["error"] = ex.Message;
            throw;
        }
        finally
        {
            try { ctx["actor"] = MarksAuthorizationService.GetCurrentUser(); } catch { }
            MarksActionLogger.StopAndLog(sw, PAGE, action, outcome, ctx, null);
        }
    }

    private static string OutcomeOf(string json)
    {
        if (string.IsNullOrEmpty(json)) return MarksActionLogger.OUTCOME_ERROR;
        if (json.IndexOf("\"success\":true", StringComparison.OrdinalIgnoreCase) >= 0) return MarksActionLogger.OUTCOME_SUCCESS;
        if (json.IndexOf("\"success\":false", StringComparison.OrdinalIgnoreCase) >= 0) return MarksActionLogger.OUTCOME_VALIDATION;
        if (json.IndexOf("\"error\"", StringComparison.OrdinalIgnoreCase) >= 0) return MarksActionLogger.OUTCOME_ERROR;
        return MarksActionLogger.OUTCOME_SUCCESS;
    }

    private static Dictionary<string, string> Ctx(params string[] kv)
    {
        Dictionary<string, string> d = new Dictionary<string, string>();
        if (kv != null)
            for (int i = 0; i + 1 < kv.Length; i += 2)
                if (!string.IsNullOrEmpty(kv[i])) d[kv[i]] = kv[i + 1] ?? "";
        return d;
    }

    private static string Join(int[] ids)
    {
        if (ids == null || ids.Length == 0) return "";
        return string.Join(",", Array.ConvertAll(ids, delegate(int x) { return x.ToString(); }));
    }
    private static string N(int? v) { return v.HasValue ? v.Value.ToString() : ""; }

    // ─────────────────────── WebMethods (delegated + logged) ─────────────────

    [WebMethod(EnableSession = true)]
    public static string GetProvisionalRecord(int id)
    { return Run("view_record", Ctx("id", id.ToString()), delegate { return MarksControllerShared.GetProvisionalRecord(id); }); }

    [WebMethod(EnableSession = true)]
    public static string GetRecordDetails(int id)
    { return Run("view_details", Ctx("id", id.ToString()), delegate { return MarksControllerShared.GetRecordDetails(id); }); }

    [WebMethod(EnableSession = true)]
    public static string ReviewProvisionalMarks(int id, string action, string comment)
    { return Run("review:" + action, Ctx("id", id.ToString(), "action", action, "comment", comment), delegate { return MarksControllerShared.ReviewProvisionalMarks(id, action, comment); }); }

    [WebMethod(EnableSession = true)]
    public static string PublishMarks(int id)
    { return Run("publish", Ctx("id", id.ToString()), delegate { return MarksControllerShared.PublishMarks(id); }); }

    [WebMethod(EnableSession = true)]
    public static string SaveAdminMarks(int id, int? cw, int? exam, int? total, string note)
    { return Run("edit_marks", Ctx("id", id.ToString(), "cw", N(cw), "exam", N(exam), "total", N(total), "note", note), delegate { return MarksControllerShared.SaveAdminMarks(id, cw, exam, total, note); }); }

    [WebMethod(EnableSession = true)]
    public static string ResetToPending(int id)
    { return Run("reset_to_pending", Ctx("id", id.ToString()), delegate { return MarksControllerShared.ResetToPending(id); }); }

    [WebMethod(EnableSession = true)]
    public static string BulkAction(int[] ids, string action, string comment)
    { return Run("bulk:" + action, Ctx("ids", Join(ids), "count", (ids == null ? 0 : ids.Length).ToString(), "comment", comment), delegate { return MarksControllerShared.BulkAction(ids, action, comment); }); }

    [WebMethod(EnableSession = true)]
    public static string ForceSetStatus(int id, string status, string comment)
    { return Run("force_status:" + status, Ctx("id", id.ToString(), "status", status, "comment", comment), delegate { return MarksControllerShared.ForceSetStatus(id, status, comment); }); }

    [WebMethod(EnableSession = true)]
    public static string BulkForceSetStatus(int[] ids, string status, string comment)
    { return Run("bulk_force_status:" + status, Ctx("ids", Join(ids), "count", (ids == null ? 0 : ids.Length).ToString(), "status", status, "comment", comment), delegate { return MarksControllerShared.BulkForceSetStatus(ids, status, comment); }); }

    // ── Admin course-registration management (create / delete) — logged like every action ──

    [WebMethod(EnableSession = true)]
    public static string CreateRegistration(string regno, string course, string acadYear, int semester)
    { return Run("create_registration", Ctx("regno", regno, "course", course, "year", acadYear, "sem", semester.ToString()), delegate { return MarksControllerShared.CreateRegistration(regno, course, acadYear, semester); }); }

    [WebMethod(EnableSession = true)]
    public static string DeleteRegistration(int id)
    { return Run("delete_registration", Ctx("id", id.ToString()), delegate { return MarksControllerShared.DeleteRegistration(id); }); }

    // Read-only lookups powering the register modal — not logged (invoked per keystroke).
    [WebMethod(EnableSession = true)]
    public static string RegSearchStudents(string q)
    { return MarksControllerShared.RegSearchStudents(q); }

    [WebMethod(EnableSession = true)]
    public static string RegSearchCourses(string q)
    { return MarksControllerShared.RegSearchCourses(q); }

    [WebMethod(EnableSession = true)]
    public static string GetStudentRegSummary(string regno)
    { return MarksControllerShared.GetStudentRegSummary(regno); }

    [WebMethod(EnableSession = true)]
    public static string PreviewBatchWorkflow(string action, string scope, int[] ids, string year, string sem, string prog)
    { return Run("batch_preview:" + action, Ctx("scope", scope, "year", year, "sem", sem, "prog", prog, "count", (ids == null ? 0 : ids.Length).ToString()), delegate { return MarksControllerShared.PreviewBatchWorkflow(action, scope, ids, year, sem, prog, PageKind); }); }

    [WebMethod(EnableSession = true)]
    public static string ExecuteBatchWorkflow(string action, string scope, int[] ids, string year, string sem, string prog, string comment)
    { return Run("batch_execute:" + action, Ctx("scope", scope, "year", year, "sem", sem, "prog", prog, "count", (ids == null ? 0 : ids.Length).ToString(), "comment", comment), delegate { return MarksControllerShared.ExecuteBatchWorkflow(action, scope, ids, year, sem, prog, comment, PageKind); }); }
}
