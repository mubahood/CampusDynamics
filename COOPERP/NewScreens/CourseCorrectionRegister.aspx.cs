using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

// =====================================================================
//  CORRECTION REGISTER — every correction ever made, what it touched,
//  and the button that puts it back.
//
//  The register is append-only: a reversal is itself a batch, so undoing
//  something is as visible as doing it.
// =====================================================================
public partial class COOPERP_NewScreens_CourseCorrectionRegister : System.Web.UI.Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
    private const string PAGE = "CourseCorrectionRegister";

    protected void Page_Load(object sender, EventArgs e)
    {
        MarksScope scope = MarksScopeResolver.Resolve();
        litScope.Text = scope.HasAccess
            ? HttpUtility.HtmlEncode(scope.RoleNote + " — " + scope.Label)
            : "No access";
    }

    private static string CurrentUser()
    {
        var ctx = HttpContext.Current;
        if (ctx != null && ctx.Session != null)
        {
            string u = ctx.Session["username"] as string;
            if (!string.IsNullOrEmpty(u)) return u;
        }
        return "unknown";
    }

    private static string Ip()
    {
        try
        {
            var rq = HttpContext.Current.Request;
            string f = rq.ServerVariables["HTTP_X_FORWARDED_FOR"];
            if (!string.IsNullOrEmpty(f)) return f.Split(',')[0].Trim();
            return rq.ServerVariables["REMOTE_ADDR"] ?? rq.UserHostAddress;
        }
        catch { return null; }
    }

    private static string S(MySqlDataReader r, int i) { return r.IsDBNull(i) ? "" : Convert.ToString(r[i]).Trim(); }
    private static int N(MySqlDataReader r, int i) { return r.IsDBNull(i) ? 0 : Convert.ToInt32(r[i]); }
    private static string Fail(string m) { return Json.Serialize(new { success = false, message = m }); }

    [WebMethod(EnableSession = true)]
    public static string GetBatches(string operation, string status, string search, int page, int pageSize)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            if (!scope.HasAccess) return Fail("You do not have a marks-management scope.");

            if (page < 1) page = 1;
            if (pageSize < 5 || pageSize > 200) pageSize = 25;

            var w = new StringBuilder(" WHERE 1=1 ");
            var ps = new Dictionary<string, object>();
            if (!string.IsNullOrEmpty(operation)) { w.Append(" AND b.operation=@op "); ps["@op"] = operation; }
            if (!string.IsNullOrEmpty(status)) { w.Append(" AND b.status=@st "); ps["@st"] = status; }
            if (!string.IsNullOrEmpty(search))
            {
                w.Append(" AND (b.batch_ref LIKE @q OR b.source_code LIKE @q OR b.target_code LIKE @q OR b.performed_by LIKE @q OR b.reason LIKE @q) ");
                ps["@q"] = "%" + search.Trim() + "%";
            }
            // A Dean or HOD sees the batches they ran; administrators see everything.
            if (!scope.IsAdmin) { w.Append(" AND b.performed_by=@me "); ps["@me"] = CurrentUser(); }

            var items = new List<object>();
            int total = 0;
            using (var c = new MySqlConnection(CourseCorrectionService.ConnStr()))
            {
                c.Open();
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_correction_batch b" + w, c))
                {
                    foreach (var kv in ps) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    total = Convert.ToInt32(cmd.ExecuteScalar());
                }
                using (var cmd = new MySqlCommand(
                    "SELECT b.id, b.batch_ref, b.operation, b.status, IFNULL(b.source_code,''), IFNULL(b.target_code,''), " +
                    "       IFNULL(b.source_year,''), IFNULL(b.target_year,''), IFNULL(b.source_semester,0), IFNULL(b.target_semester,0), " +
                    "       b.rows_applied, b.rows_skipped, b.students_affected, b.residual_rows, b.performed_by, " +
                    "       DATE_FORMAT(b.performed_at,'%d %b %Y %H:%i'), IFNULL(b.reason,''), IFNULL(b.scope_label,''), " +
                    "       IFNULL(b.reversed_by,''), IFNULL(DATE_FORMAT(b.reversed_at,'%d %b %Y %H:%i'),''), " +
                    "       IFNULL(b.reverse_batch_ref,''), IFNULL(b.tables_touched,''), b.duration_ms, IFNULL(b.reverses_batch_id,0) " +
                    "FROM acad_correction_batch b" + w +
                    " ORDER BY b.id DESC LIMIT " + pageSize + " OFFSET " + ((page - 1) * pageSize), c))
                {
                    foreach (var kv in ps) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            items.Add(new
                            {
                                id = N(r, 0), batchRef = S(r, 1), operation = S(r, 2), status = S(r, 3),
                                sourceCode = S(r, 4), targetCode = S(r, 5),
                                sourceYear = S(r, 6), targetYear = S(r, 7), sourceSem = N(r, 8), targetSem = N(r, 9),
                                applied = N(r, 10), skipped = N(r, 11), students = N(r, 12), residual = N(r, 13),
                                by = S(r, 14), at = S(r, 15), reason = S(r, 16), scope = S(r, 17),
                                reversedBy = S(r, 18), reversedAt = S(r, 19), reverseRef = S(r, 20),
                                tables = S(r, 21), ms = N(r, 22), reverses = N(r, 23)
                            });
                }
            }
            return Json.Serialize(new { success = true, items, total, page, pageSize, isAdmin = scope.IsAdmin });
        }
        catch (Exception ex) { return Fail(ex.Message); }
    }

    [WebMethod(EnableSession = true)]
    public static string GetBatchRows(int batchId, string search)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            if (!scope.HasAccess) return Fail("You do not have a marks-management scope.");

            var rows = new List<object>();
            var students = new List<object>();
            int totalRows = 0;
            using (var c = new MySqlConnection(CourseCorrectionService.ConnStr()))
            {
                c.Open();
                string extra = string.IsNullOrEmpty(search) ? "" : " AND (regno LIKE @q OR table_name LIKE @q) ";
                using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_correction_row WHERE batch_id=@b" + extra, c))
                {
                    cmd.Parameters.AddWithValue("@b", batchId);
                    if (extra != "") cmd.Parameters.AddWithValue("@q", "%" + search.Trim() + "%");
                    totalRows = Convert.ToInt32(cmd.ExecuteScalar());
                }
                using (var cmd = new MySqlCommand(
                    "SELECT id, db_name, table_name, pk_column, pk_value, IFNULL(regno,''), IFNULL(course_code,''), " +
                    "       action, verdict, IFNULL(note,''), reversed, before_json, after_json " +
                    "FROM acad_correction_row WHERE batch_id=@b" + extra + " ORDER BY id LIMIT 3000", c))
                {
                    cmd.Parameters.AddWithValue("@b", batchId);
                    if (extra != "") cmd.Parameters.AddWithValue("@q", "%" + search.Trim() + "%");
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            rows.Add(new
                            {
                                id = N(r, 0), db = S(r, 1), table = S(r, 2), pkCol = S(r, 3), pk = S(r, 4),
                                regno = S(r, 5), course = S(r, 6), action = S(r, 7), verdict = S(r, 8),
                                verdictText = CorrectionVerdict.Explain(S(r, 8)),
                                note = S(r, 9), reversed = N(r, 10) == 1,
                                before = Summarise(S(r, 11)), after = Summarise(S(r, 12))
                            });
                }
                using (var cmd = new MySqlCommand(
                    "SELECT regno, COUNT(*) n, SUM(reversed) rv FROM acad_correction_row " +
                    "WHERE batch_id=@b AND action='UPDATE' AND regno IS NOT NULL AND regno<>'' GROUP BY regno ORDER BY regno LIMIT 2000", c))
                {
                    cmd.Parameters.AddWithValue("@b", batchId);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                            students.Add(new { regno = S(r, 0), rows = N(r, 1), reversed = N(r, 2) });
                }
            }
            return Json.Serialize(new { success = true, rows, students, totalRows, shown = rows.Count });
        }
        catch (Exception ex) { return Fail(ex.Message); }
    }

    /// <summary>The columns a reader actually cares about, pulled out of the full row image.</summary>
    private static object Summarise(string json)
    {
        if (string.IsNullOrEmpty(json)) return null;
        try
        {
            var d = Json.Deserialize<Dictionary<string, object>>(json);
            if (d == null) return null;
            var keep = new Dictionary<string, object>();
            foreach (var k in new[] { "courseID", "courseid", "course_code", "acad_year", "acad", "acadyear",
                                      "semester", "retake_acad_year", "retake_semester", "prog_id", "progid",
                                      "course_status", "mark_stage", "provisional_total_marks", "score", "grade" })
            {
                object v;
                if (d.TryGetValue(k, out v) && v != null) keep[k] = v;
            }
            return keep;
        }
        catch { return null; }
    }

    [WebMethod(EnableSession = true)]
    public static string ReverseBatch(int batchId, string reason, string regno)
    {
        var sw = MarksActionLogger.StartTimer();
        string outcome = MarksActionLogger.OUTCOME_SUCCESS, detail = "";
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            var res = CourseCorrectionService.Reverse(batchId, reason, scope, CurrentUser(), Ip(),
                                                      string.IsNullOrEmpty(regno) ? null : regno.Trim());
            if (!res.success) { outcome = MarksActionLogger.OUTCOME_VALIDATION; detail = res.message; }
            else detail = res.batchRef + ": restored " + res.rowsApplied;
            return Json.Serialize(res);
        }
        catch (Exception ex)
        {
            outcome = MarksActionLogger.OUTCOME_ERROR; detail = ex.Message;
            return Fail(ex.Message);
        }
        finally
        {
            try
            {
                var ctx = new Dictionary<string, string> {
                    { "batchId", batchId.ToString() }, { "student", regno ?? "" },
                    { "reason", reason ?? "" }, { "result", detail }, { "actor", CurrentUser() } };
                MarksActionLogger.StopAndLog(sw, PAGE, "CORRECTION_REVERSE", outcome, ctx, null);
            }
            catch { }
        }
    }
}
