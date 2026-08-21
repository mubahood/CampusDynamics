using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using MySql.Data.MySqlClient;

/// <summary>
/// Name Arrangements — the trail of every name a student has reordered in the portal, and the
/// means to put one back.
///
/// Students may reorder the words of their name themselves (eportal MyName.aspx) because
/// reordering asserts nothing new about who they are. That makes it safe to allow, not safe to
/// leave unrecorded: the name on a transcript and a certificate is the name the University
/// stands behind, so every rearrangement is logged and every one can be reversed here.
///
/// REVERSAL IS NOT A BLIND WRITE. The stored name is compared against what the entry said it
/// became before anything is undone. If it no longer matches — a later rearrangement, or a
/// member of staff editing the record directly — the reversal is refused with the current value
/// shown, rather than silently overwriting whatever happened since. That is the same rule the
/// Correction Register uses, and for the same reason.
///
/// A reversal is itself recorded as a new entry, so the trail only ever grows. Undoing is as
/// visible as doing.
/// </summary>
public partial class COOPERP_NewScreens_NameArrangements : Page
{
    private static readonly JavaScriptSerializer J = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
    private const string PAGE = "NameArrangements";

    protected void Page_Load(object sender, EventArgs e)
    {
        MarksScope scope = MarksScopeResolver.Resolve();
        litScope.Text = scope.HasAccess
            ? HttpUtility.HtmlEncode(scope.RoleNote + " — " + scope.Label)
            : "No access";
    }

    private static string ConnStr()
    {
        var cs = System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"];
        return cs != null ? cs.ConnectionString
                          : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";
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
    private static string Clip(string s, int n) { s = s ?? ""; return s.Length <= n ? s : s.Substring(0, n); }
    private static string Fail(string m) { return J.Serialize(new { success = false, message = m }); }

    /// <summary>Whether the entry is a student's own rearrangement or an administrator putting
    /// one back — read from the source, so the two never blur together in the list.</summary>
    private static bool IsReversal(string source) { return (source ?? "").IndexOf("reversal", StringComparison.OrdinalIgnoreCase) >= 0; }

    /// <summary>What the student record holds right now, in the same shape the entry stored it:
    /// the rendered name for a name, the ISO date for a date of birth. One expression, so the
    /// list, the counts and the reversal guard can never be comparing different things.</summary>
    private const string CUR_SQL =
        "CASE WHEN a.record_type='DOB' THEN IFNULL(DATE_FORMAT(s.dob,'%Y-%m-%d'),'') " +
        "     ELSE TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) END";

    /// <summary>A stored value made fit to read. Dates are held as ISO — that is what a reversal
    /// writes back — but they are shown the way the transcript prints them.</summary>
    private static string Show(string recordType, string stored)
    {
        if (recordType != "DOB") return stored;
        if (string.IsNullOrEmpty(stored)) return "not recorded";
        DateTime d;
        if (!DateTime.TryParseExact(stored, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                                    DateTimeStyles.None, out d)) return stored;
        return d.ToString("dd", CultureInfo.InvariantCulture) + " " +
               CultureInfo.InvariantCulture.DateTimeFormat.GetMonthName(d.Month) + "," + d.Year;
    }

    // ─────────────────────────────────────────────────────────────────
    //  List
    // ─────────────────────────────────────────────────────────────────
    [WebMethod(EnableSession = true)]
    public static string GetList(string q, string kind, string type, int page, int pageSize)
    {
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            if (!scope.HasAccess) return Fail("You do not have access to student records.");

            if (page < 1) page = 1;
            if (pageSize < 5 || pageSize > 200) pageSize = 25;

            var w = new StringBuilder(" WHERE 1=1 ");
            var ps = new Dictionary<string, object>();
            if (!string.IsNullOrEmpty(q))
            {
                w.Append(" AND (a.regno LIKE @q OR a.old_full LIKE @q OR a.new_full LIKE @q OR a.changed_by LIKE @q OR IFNULL(s.entryno,'') LIKE @q) ");
                ps["@q"] = "%" + q.Trim() + "%";
            }
            string k = (kind ?? "").Trim().ToUpperInvariant();
            if (k == "STUDENT") w.Append(" AND a.source NOT LIKE '%reversal%' ");
            else if (k == "REVERSAL") w.Append(" AND a.source LIKE '%reversal%' ");

            string t = (type ?? "").Trim().ToUpperInvariant();
            if (t == "NAME" || t == "DOB")
            {
                w.Append(" AND a.record_type=@t ");
                ps["@t"] = t;
            }

            // A Dean or HOD sees only students on programmes within their scope.
            w.Append(scope.ProgFilterExpr("IFNULL(s.progid,'')"));

            var items = new List<object>();
            int total = 0, nStudent = 0, nReversal = 0, nDrift = 0;
            using (var c = new MySqlConnection(ConnStr()))
            {
                c.Open();
                // Counted over the whole filtered set, not the visible page — a figure that
                // means "on this page" but reads as "in total" is worse than no figure.
                // BINARY, because the reversal guard compares ordinally: a name differing only
                // in case has drifted, and utf8_general_ci would call the two equal.
                using (var cmd = new MySqlCommand(
                    "SELECT COUNT(*), " +
                    "  SUM(a.source NOT LIKE '%reversal%'), " +
                    "  SUM(a.source LIKE '%reversal%'), " +
                    "  SUM(a.source NOT LIKE '%reversal%' AND s.regno IS NOT NULL " +
                    "      AND BINARY " + CUR_SQL + " <> BINARY IFNULL(a.new_full,'')) " +
                    "FROM stud_name_arrangement a LEFT JOIN acad_student s ON s.regno=a.regno" + w, c))
                {
                    foreach (var kv in ps) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    using (var r = cmd.ExecuteReader())
                        if (r.Read())
                        {
                            total = Convert.ToInt32(r[0]);
                            nStudent = r.IsDBNull(1) ? 0 : Convert.ToInt32(r[1]);
                            nReversal = r.IsDBNull(2) ? 0 : Convert.ToInt32(r[2]);
                            nDrift = r.IsDBNull(3) ? 0 : Convert.ToInt32(r[3]);
                        }
                }
                using (var cmd = new MySqlCommand(
                    "SELECT a.id, a.regno, IFNULL(s.entryno,'') entryno, IFNULL(s.progid,'') progid, " +
                    "  IFNULL(a.old_full,'') old_full, IFNULL(a.new_full,'') new_full, " +
                    "  a.changed_by, IFNULL(a.source,'') source, IFNULL(a.ip_address,'') ip, " +
                    "  DATE_FORMAT(a.changed_at,'%d %b %Y, %H:%i') at_, " +
                    // What the record says right now — the only way to tell whether the entry
                    // still describes reality, and therefore whether it can be put back.
                    "  " + CUR_SQL + " current_full, " +
                    "  IFNULL(a.reason,'') reason, IFNULL(a.reversal_of,0) reversal_of, " +
                    "  a.record_type, (s.regno IS NOT NULL) have_record " +
                    "FROM stud_name_arrangement a LEFT JOIN acad_student s ON s.regno=a.regno" + w +
                    " ORDER BY a.id DESC LIMIT " + pageSize + " OFFSET " + ((page - 1) * pageSize), c))
                {
                    foreach (var kv in ps) cmd.Parameters.AddWithValue(kv.Key, kv.Value);
                    using (var r = cmd.ExecuteReader())
                        while (r.Read())
                        {
                            string newFull = S(r, 5), curFull = S(r, 10), oldFull = S(r, 4);
                            bool reversal = IsReversal(S(r, 7));
                            string rtype = S(r, 13);
                            bool haveRecord = Convert.ToInt32(r[14]) == 1;
                            // Reversible only while the record still holds what this entry produced,
                            // and only when it would actually change something.
                            bool canReverse = !reversal
                                && haveRecord
                                && string.Equals(curFull, newFull, StringComparison.Ordinal)
                                && !string.Equals(oldFull, newFull, StringComparison.Ordinal);
                            items.Add(new
                            {
                                id = Convert.ToInt32(r[0]),
                                regno = S(r, 1), entryno = S(r, 2), progid = S(r, 3),
                                type = rtype,
                                typeLabel = rtype == "DOB" ? "Date of birth" : "Name",
                                oldFull = Show(rtype, oldFull), newFull = Show(rtype, newFull),
                                by = S(r, 6), source = S(r, 7), ip = S(r, 8), at = S(r, 9),
                                reason = S(r, 11),
                                reversalOf = Convert.ToInt32(r[12]),
                                currentFull = Show(rtype, curFull),
                                isReversal = reversal,
                                canReverse = canReverse,
                                drifted = !reversal && haveRecord && !string.Equals(curFull, newFull, StringComparison.Ordinal)
                            });
                        }
                }
            }
            return J.Serialize(new { success = true, items, total, page, pageSize,
                                     nStudent, nReversal, nDrift, isAdmin = scope.IsAdmin });
        }
        catch (Exception ex) { return Fail(ex.Message); }
    }

    // ─────────────────────────────────────────────────────────────────
    //  Reverse
    // ─────────────────────────────────────────────────────────────────
    [WebMethod(EnableSession = true)]
    public static string Reverse(int id, string reason)
    {
        var sw = MarksActionLogger.StartTimer();
        string outcome = MarksActionLogger.OUTCOME_SUCCESS, detail = "", logType = "";
        try
        {
            MarksScope scope = MarksScopeResolver.Resolve();
            if (!scope.HasAccess) { outcome = MarksActionLogger.OUTCOME_AUTH_FAIL; return Fail("You do not have access to student records."); }
            if (string.IsNullOrEmpty(reason) || reason.Trim().Length < 5)
            { outcome = MarksActionLogger.OUTCOME_VALIDATION; return Fail("Give a reason for putting this back (at least five characters). It is stored with the entry."); }

            using (var c = new MySqlConnection(ConnStr()))
            {
                c.Open();

                string regno = "", oldFirst = "", oldOther = "", oldFull = "", newFull = "", src = "", rtype = "NAME";
                bool found = false;
                using (var cmd = new MySqlCommand(
                    "SELECT regno, IFNULL(old_firstname,''), IFNULL(old_othername,''), IFNULL(old_full,''), " +
                    "       IFNULL(new_full,''), IFNULL(source,''), IFNULL(record_type,'NAME') " +
                    "FROM stud_name_arrangement WHERE id=@i LIMIT 1", c))
                {
                    cmd.Parameters.AddWithValue("@i", id);
                    using (var r = cmd.ExecuteReader())
                        if (r.Read())
                        { found = true; regno = S(r, 0); oldFirst = S(r, 1); oldOther = S(r, 2); oldFull = S(r, 3); newFull = S(r, 4); src = S(r, 5); rtype = S(r, 6); }
                }
                if (!found) { outcome = MarksActionLogger.OUTCOME_VALIDATION; return Fail("That entry was not found."); }
                if (IsReversal(src)) { outcome = MarksActionLogger.OUTCOME_VALIDATION; return Fail("That entry is itself a reversal. Reverse the original instead, or ask the student to correct it again."); }

                bool isDob = rtype == "DOB";
                string what = isDob ? "date of birth" : "name";
                logType = rtype;

                string curFirst = "", curOther = "", curDob = "", progid = "";
                using (var cmd = new MySqlCommand(
                    "SELECT IFNULL(firstname,''), IFNULL(othername,''), IFNULL(progid,''), " +
                    "       IFNULL(DATE_FORMAT(dob,'%Y-%m-%d'),'') FROM acad_student WHERE regno=@r LIMIT 1", c))
                {
                    cmd.Parameters.AddWithValue("@r", regno);
                    using (var r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) { outcome = MarksActionLogger.OUTCOME_VALIDATION; return Fail("That student record no longer exists."); }
                        curFirst = S(r, 0); curOther = S(r, 1); progid = S(r, 2); curDob = S(r, 3);
                    }
                }
                if (!scope.AllowsProg(progid))
                { outcome = MarksActionLogger.OUTCOME_AUTH_FAIL; return Fail("That student is on a programme outside your scope."); }

                // The guard: only put it back if the record still holds what this entry produced.
                // Compared in the shape it was stored — ISO for a date, the rendered name for a
                // name — so the comparison is exact either way.
                string curFull = isDob ? curDob : (curFirst + " " + curOther).Trim();
                if (!string.Equals(curFull, newFull, StringComparison.Ordinal))
                {
                    outcome = MarksActionLogger.OUTCOME_VALIDATION;
                    return Fail("The " + what + " has changed since this entry, so it was left alone. It now reads \"" +
                                Show(rtype, curFull) + "\", not \"" + Show(rtype, newFull) + "\". Reverse the most recent entry instead.");
                }
                if (string.Equals(oldFull, newFull, StringComparison.Ordinal))
                { outcome = MarksActionLogger.OUTCOME_SKIPPED; return Fail("That entry did not change the " + what + ", so there is nothing to put back."); }

                using (var tx = c.BeginTransaction())
                {
                    // A date of birth that was blank before goes back to blank, not to the epoch:
                    // an empty old_full means the student filled in something the University never
                    // held, and undoing that has to leave it empty again.
                    string sql = isDob ? "UPDATE acad_student SET dob=@d WHERE regno=@r"
                                       : "UPDATE acad_student SET firstname=@f, othername=@o WHERE regno=@r";
                    using (var cmd = new MySqlCommand(sql, c, tx))
                    {
                        if (isDob)
                        {
                            DateTime back;
                            cmd.Parameters.AddWithValue("@d",
                                DateTime.TryParseExact(oldFull, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                                                       DateTimeStyles.None, out back) ? (object)back : DBNull.Value);
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@f", oldFirst);
                            cmd.Parameters.AddWithValue("@o", oldOther);
                        }
                        cmd.Parameters.AddWithValue("@r", regno);
                        if (cmd.ExecuteNonQuery() == 0)
                        { tx.Rollback(); outcome = MarksActionLogger.OUTCOME_ERROR; return Fail("The " + what + " could not be put back. Please try again."); }
                    }

                    // Recorded as a new entry rather than by editing the old one, so the trail is
                    // append-only and a reversal is as visible as the change it undoes.
                    using (var cmd = new MySqlCommand(
                        "INSERT INTO stud_name_arrangement (regno, record_type, old_firstname, old_othername, new_firstname, new_othername, " +
                        " old_full, new_full, changed_by, reason, reversal_of, source, ip_address, changed_at) " +
                        "VALUES (@r,@rt,@of,@oo,@nf,@no,@ofull,@nfull,@by,@why,@rev,'eadmin-reversal',@ip,NOW())", c, tx))
                    {
                        cmd.Parameters.AddWithValue("@r", regno);
                        cmd.Parameters.AddWithValue("@rt", rtype);
                        cmd.Parameters.AddWithValue("@of", isDob ? (object)DBNull.Value : curFirst);
                        cmd.Parameters.AddWithValue("@oo", isDob ? (object)DBNull.Value : curOther);
                        cmd.Parameters.AddWithValue("@nf", isDob ? (object)DBNull.Value : oldFirst);
                        cmd.Parameters.AddWithValue("@no", isDob ? (object)DBNull.Value : oldOther);
                        cmd.Parameters.AddWithValue("@ofull", curFull);
                        cmd.Parameters.AddWithValue("@nfull", oldFull);
                        // Actor and reason are kept apart, and each is cut to what its column
                        // holds. The database runs in strict mode: an over-long value is an
                        // aborted reversal, not a truncated one.
                        cmd.Parameters.AddWithValue("@by", Clip(CurrentUser(), 100));
                        cmd.Parameters.AddWithValue("@why", Clip(reason.Trim(), 255));
                        cmd.Parameters.AddWithValue("@rev", id);
                        cmd.Parameters.AddWithValue("@ip", (object)Ip() ?? DBNull.Value);
                        cmd.ExecuteNonQuery();
                    }
                    tx.Commit();
                }

                detail = regno + " (" + rtype + "): \"" + newFull + "\" put back to \"" + oldFull + "\"";
                return J.Serialize(new { success = true, message = "Put back. " + regno + "'s " + what +
                    (oldFull.Length == 0 ? " is blank again, as it was before." : " reads \"" + Show(rtype, oldFull) + "\" again.") });
            }
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
                    { "entryId", id.ToString() }, { "type", logType }, { "reason", reason ?? "" },
                    { "result", detail }, { "actor", CurrentUser() } };
                MarksActionLogger.StopAndLog(sw, PAGE, "STUDENT_RECORD_REVERSE", outcome, ctx, null);
            }
            catch { }
        }
    }
}
