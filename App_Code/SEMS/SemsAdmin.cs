using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

// =====================================================================
//  SEMS — Student Email Management System (eAdmin side).
//  Eligibility, idempotent generation, email creation, lifecycle, stats,
//  list/search and complaint handling. Tables live in campus_dynamics_portal
//  (sems_*); reached cross-DB from the campus_dynamics (vac) connection.
// =====================================================================
public static class SemsAdmin
{
    private const decimal MinPaid = 100000m;

    private static string Conn
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // Eligible-students source. Payments are pre-aggregated ONCE (grouped) then joined, instead
    // of a per-row correlated subquery — so this stays fast over the whole 2026+ intake.
    private static readonly string EligibleFrom =
        "FROM campus_dynamics.acad_student s " +
        "JOIN (SELECT TRIM(regno) rg, SUM(amount) paid FROM campus_dynamics_accounts.fin_studentfeestracking " +
        "      WHERE trans_type='Payment' GROUP BY TRIM(regno)) pay ON pay.rg = TRIM(s.regno) " +
        "WHERE s.entryyear >= 2026 " +
        "  AND IFNULL(TRIM(s.email),'') = '' " +
        "  AND pay.paid >= " + MinPaid.ToString("0") + " " +
        "  AND NOT EXISTS (SELECT 1 FROM campus_dynamics_portal.sems_email_creations e WHERE e.regno=TRIM(s.regno)) ";

    private static string Actor()
    {
        try { var u = HttpContext.Current.Session["username"]; return u == null ? "admin" : u.ToString(); }
        catch { return "admin"; }
    }

    private static void Log(MySqlConnection c, MySqlTransaction tx, int creationId, string regno, string action,
                            string from, string to, string detail)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "INSERT INTO campus_dynamics_portal.sems_activity_log (creation_id,regno,action,stage_from,stage_to,actor,actor_role,detail,created_at) " +
                "VALUES (@id,@r,@a,@f,@t,@who,'ADMIN',@d,NOW())", c, tx))
            {
                cmd.Parameters.AddWithValue("@id", creationId <= 0 ? (object)DBNull.Value : creationId);
                cmd.Parameters.AddWithValue("@r", regno ?? "");
                cmd.Parameters.AddWithValue("@a", action);
                cmd.Parameters.AddWithValue("@f", (object)from ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@t", (object)to ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@who", Actor());
                cmd.Parameters.AddWithValue("@d", (object)detail ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
        catch { /* logging must never break the action */ }
    }

    private static void Notify(MySqlConnection c, MySqlTransaction tx, string regno, string title, string msg, string icon)
    {
        try
        {
            using (var cmd = new MySqlCommand(
                "INSERT INTO campus_dynamics_portal.sems_notifications (regno,title,message,icon,is_read,created_at) VALUES (@r,@t,@m,@i,'No',NOW())", c, tx))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                cmd.Parameters.AddWithValue("@t", title);
                cmd.Parameters.AddWithValue("@m", (object)msg ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@i", (object)icon ?? DBNull.Value);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    // ── Dashboard KPIs ───────────────────────────────────────────────
    public static string Stats()
    {
        var js = new JavaScriptSerializer();
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                int eligible = Scalar(c, "SELECT COUNT(*) " + EligibleFrom);
                Func<string, int> cnt = w => Scalar(c, "SELECT COUNT(*) FROM campus_dynamics_portal.sems_email_creations " + w);
                int total     = cnt("");
                int pending   = cnt("WHERE current_stage='PENDING_CREATION'");
                int ready     = cnt("WHERE current_stage IN ('EMAIL_CREATED','READY_FOR_COLLECTION')");
                int learning  = cnt("WHERE gmail_guide_done_at IS NOT NULL");
                int quiz      = cnt("WHERE quiz_passed_at IS NOT NULL");
                int activated = cnt("WHERE verification_status='VERIFIED'");
                int completed = cnt("WHERE current_stage='COMPLETED'");
                int pwchanged = cnt("WHERE password_changed='Yes'");
                int complaints= Scalar(c, "SELECT COUNT(*) FROM campus_dynamics_portal.sems_complaints WHERE status NOT IN ('RESOLVED','CLOSED')");
                int forgot    = Scalar(c, "SELECT COUNT(*) FROM campus_dynamics_portal.sems_complaints WHERE category='Forgot Password' AND status NOT IN ('RESOLVED','CLOSED')");
                double rate = total > 0 ? Math.Round(completed * 100.0 / total, 1) : 0;
                return js.Serialize(new { success = true, eligible, total, pending, ready, learning, quiz, activated, completed, pwchanged, complaints, forgot, successRate = rate });
            }
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── Generate eligible (idempotent) ───────────────────────────────
    public static string GenerateEligible()
    {
        var js = new JavaScriptSerializer();
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                int created;
                using (var cmd = new MySqlCommand(
                    "INSERT INTO campus_dynamics_portal.sems_email_creations " +
                    " (regno, entryno, admission_year, campus, programme, student_name, current_stage, current_status, creation_date, created_by, paid_amount_snapshot) " +
                    "SELECT TRIM(s.regno), s.entryno, s.entryyear, s.studCampus, s.progid, " +
                    "  NULLIF(TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))),''), " +
                    "  'PENDING_CREATION','PENDING', NOW(), @who, pay.paid " +
                    EligibleFrom, c))
                {
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.AddWithValue("@who", Actor());
                    created = cmd.ExecuteNonQuery();
                }
                Log(c, null, 0, null, "generate_eligible", null, "PENDING_CREATION", created + " record(s) created");
                return js.Serialize(new { success = true, created, message = created + " new eligible student(s) added to the pipeline." });
            }
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── Create the email for one student ─────────────────────────────
    public static string CreateEmail(string regno, string email, string tempPw, string notes)
    {
        var js = new JavaScriptSerializer();
        regno = (regno ?? "").Trim(); email = (email ?? "").Trim();
        if (regno == "" || email == "" || string.IsNullOrWhiteSpace(tempPw))
            return js.Serialize(new { success = false, message = "Email address and temporary password are required." });
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                using (var tx = c.BeginTransaction())
                {
                    int id = 0; string stage = "";
                    using (var q = new MySqlCommand("SELECT id, current_stage FROM campus_dynamics_portal.sems_email_creations WHERE regno=@r LIMIT 1", c, tx))
                    { q.Parameters.AddWithValue("@r", regno); using (var rd = q.ExecuteReader()) if (rd.Read()) { id = Convert.ToInt32(rd[0]); stage = rd[1].ToString(); } }
                    if (id == 0) { tx.Rollback(); return js.Serialize(new { success = false, message = "No pipeline record for that student." }); }

                    using (var up = new MySqlCommand(
                        "UPDATE campus_dynamics_portal.sems_email_creations SET email_address=@e, temp_password=@p, " +
                        "current_stage='READY_FOR_COLLECTION', current_status='READY', email_created_at=NOW(), " +
                        "notes=CONCAT(COALESCE(NULLIF(notes,''),''), CASE WHEN @n<>'' THEN CONCAT(' | ', @n) ELSE '' END), " +
                        "last_updated_by=@who, last_updated_at=NOW() WHERE id=@id", c, tx))
                    {
                        up.Parameters.AddWithValue("@e", email);
                        up.Parameters.AddWithValue("@p", tempPw);
                        up.Parameters.AddWithValue("@n", notes ?? "");
                        up.Parameters.AddWithValue("@who", Actor());
                        up.Parameters.AddWithValue("@id", id);
                        up.ExecuteNonQuery();
                    }
                    Log(c, tx, id, regno, "create_email", stage, "READY_FOR_COLLECTION", email);
                    Notify(c, tx, regno, "Your University Email is Ready", "Open the portal and complete a short guide to access it.", "mail");
                    tx.Commit();
                    return js.Serialize(new { success = true, message = "Email created. Student can now start onboarding." });
                }
            }
        }
        catch (MySqlException mex) when (mex.Number == 1062)
        { return js.Serialize(new { success = false, message = "That email address is already assigned to another student." }); }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── List (GET-filter driven, paginated) ──────────────────────────
    public static string Search(string q, string stage, string campus, string programme, string year, string verification, int page, int pageSize)
    {
        var js = new JavaScriptSerializer();
        if (pageSize < 1 || pageSize > 200) pageSize = 25;
        if (page < 1) page = 1;
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                var wb = new StringBuilder("WHERE 1=1");
                var ps = new List<MySqlParameter>();
                if (!string.IsNullOrWhiteSpace(q)) { wb.Append(" AND (regno LIKE @q OR student_name LIKE @q OR email_address LIKE @q)"); ps.Add(new MySqlParameter("@q", "%" + q.Trim() + "%")); }
                if (!string.IsNullOrWhiteSpace(stage)) { wb.Append(" AND current_stage=@st"); ps.Add(new MySqlParameter("@st", stage)); }
                if (!string.IsNullOrWhiteSpace(campus)) { wb.Append(" AND campus=@cm"); ps.Add(new MySqlParameter("@cm", campus)); }
                if (!string.IsNullOrWhiteSpace(programme)) { wb.Append(" AND programme=@pr"); ps.Add(new MySqlParameter("@pr", programme)); }
                if (!string.IsNullOrWhiteSpace(year)) { wb.Append(" AND admission_year=@yr"); ps.Add(new MySqlParameter("@yr", year)); }
                if (!string.IsNullOrWhiteSpace(verification)) { wb.Append(" AND verification_status=@vs"); ps.Add(new MySqlParameter("@vs", verification)); }
                string where = wb.ToString();

                int total;
                using (var cc = new MySqlCommand("SELECT COUNT(*) FROM campus_dynamics_portal.sems_email_creations " + where, c))
                { foreach (var p in ps) cc.Parameters.Add(Clone(p)); total = Convert.ToInt32(cc.ExecuteScalar()); }
                int pageCount = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
                if (page > pageCount) page = pageCount;

                var rows = new List<object>();
                using (var cmd = new MySqlCommand(
                    "SELECT id, regno, student_name, programme, campus, admission_year, IFNULL(email_address,'') email, " +
                    "current_stage, current_status, verification_status, complaint_status, DATE_FORMAT(creation_date,'%Y-%m-%d') cdate, " +
                    "DATE_FORMAT(last_updated_at,'%Y-%m-%d %H:%i') udate " +
                    "FROM campus_dynamics_portal.sems_email_creations " + where + " ORDER BY id DESC LIMIT @off,@ps", c))
                {
                    foreach (var p in ps) cmd.Parameters.Add(Clone(p));
                    cmd.Parameters.AddWithValue("@off", (page - 1) * pageSize);
                    cmd.Parameters.AddWithValue("@ps", pageSize);
                    using (var rd = cmd.ExecuteReader())
                        while (rd.Read())
                            rows.Add(new
                            {
                                id = Convert.ToInt32(rd["id"]),
                                regno = rd["regno"].ToString(),
                                name = rd["student_name"].ToString(),
                                programme = rd["programme"].ToString(),
                                campus = CampusName(rd["campus"].ToString()),
                                year = rd["admission_year"].ToString(),
                                email = rd["email"].ToString(),
                                stage = rd["current_stage"].ToString(),
                                status = rd["current_status"].ToString(),
                                verification = rd["verification_status"].ToString(),
                                complaint = rd["complaint_status"].ToString(),
                                created = rd["cdate"].ToString(),
                                updated = rd["udate"] == DBNull.Value ? "" : rd["udate"].ToString()
                            });
                }
                return js.Serialize(new { success = true, total, page, pageCount, pageSize, rows });
            }
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── Filter option lists (campuses / programmes present in the pipeline) ──
    public static string Filters()
    {
        var js = new JavaScriptSerializer();
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                var progs = new List<object>();
                using (var cmd = new MySqlCommand(
                    "SELECT DISTINCT e.programme, IFNULL(p.progname,e.programme) nm FROM campus_dynamics_portal.sems_email_creations e " +
                    "LEFT JOIN campus_dynamics.acad_programme p ON p.progcode=e.programme WHERE IFNULL(e.programme,'')<>'' ORDER BY nm", c))
                using (var rd = cmd.ExecuteReader())
                    while (rd.Read()) progs.Add(new { code = rd[0].ToString(), name = rd[1].ToString() });
                return js.Serialize(new { success = true, programmes = progs });
            }
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── Complaint queue (admin) ──────────────────────────────────────
    public static string Complaints(string status)
    {
        var js = new JavaScriptSerializer();
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                string w = string.IsNullOrWhiteSpace(status) ? "WHERE status NOT IN ('RESOLVED','CLOSED')" : "WHERE status=@s";
                var list = new List<object>();
                using (var cmd = new MySqlCommand(
                    "SELECT id, regno, category, description, status, priority, IFNULL(admin_response,'') resp, DATE_FORMAT(created_at,'%Y-%m-%d %H:%i') cat " +
                    "FROM campus_dynamics_portal.sems_complaints " + w + " ORDER BY (status='SUBMITTED') DESC, id DESC LIMIT 200", c))
                {
                    if (!string.IsNullOrWhiteSpace(status)) cmd.Parameters.AddWithValue("@s", status);
                    using (var rd = cmd.ExecuteReader())
                        while (rd.Read())
                            list.Add(new { id = Convert.ToInt64(rd["id"]), regno = rd["regno"].ToString(), category = rd["category"].ToString(),
                                description = rd["description"].ToString(), status = rd["status"].ToString(), priority = rd["priority"].ToString(),
                                response = rd["resp"].ToString(), created = rd["cat"].ToString() });
                }
                return js.Serialize(new { success = true, complaints = list });
            }
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    public static string RespondComplaint(long id, string status, string response)
    {
        var js = new JavaScriptSerializer();
        try
        {
            using (var c = new MySqlConnection(Conn))
            {
                c.Open();
                string regno = "";
                using (var q = new MySqlCommand("SELECT regno FROM campus_dynamics_portal.sems_complaints WHERE id=@id", c))
                { q.Parameters.AddWithValue("@id", id); var o = q.ExecuteScalar(); regno = o == null ? "" : o.ToString(); }
                using (var up = new MySqlCommand(
                    "UPDATE campus_dynamics_portal.sems_complaints SET status=@s, admin_response=@r, handled_by=@who, updated_at=NOW() WHERE id=@id", c))
                {
                    up.Parameters.AddWithValue("@s", string.IsNullOrWhiteSpace(status) ? "RESPONDED" : status);
                    up.Parameters.AddWithValue("@r", (object)response ?? DBNull.Value);
                    up.Parameters.AddWithValue("@who", Actor());
                    up.Parameters.AddWithValue("@id", id);
                    up.ExecuteNonQuery();
                }
                if (regno != "") Notify(c, null, regno, "Update on your email complaint", string.IsNullOrWhiteSpace(response) ? "Status: " + status : response, "help");
                return js.Serialize(new { success = true, message = "Complaint updated." });
            }
        }
        catch (Exception ex) { return js.Serialize(new { success = false, message = ex.Message }); }
    }

    // ── helpers ──────────────────────────────────────────────────────
    private static int Scalar(MySqlConnection c, string sql)
    { using (var cmd = new MySqlCommand(sql, c)) { cmd.CommandTimeout = 60; var v = cmd.ExecuteScalar(); return v == null || v == DBNull.Value ? 0 : Convert.ToInt32(v); } }
    private static MySqlParameter Clone(MySqlParameter p) { return new MySqlParameter(p.ParameterName, p.Value); }
    private static string CampusName(string c)
    { c = (c ?? "").Trim(); return c == "1" ? "Kakeeka" : c == "2" ? "Kirumba" : (c == "" ? "-" : c); }
}
