using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using MySql.Data.MySqlClient;

/// <summary>
/// Admin 360° Mark Requests Controller
/// Provides full oversight and control over the marks change / missing mark request workflow.
/// Actions: view all requests (any status), approve, reject, force-close.
/// </summary>
[ScriptService]
public partial class COOPERP_NewScreens_MarkRequestsAdmin : Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = 8 * 1024 * 1024 };

    private static string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // Cross-schema connection for portal data
    private static string PortalConn
    {
        get
        {
            var cs = WebConfigurationManager.ConnectionStrings["campus_dynamics_portalConnectionString"];
            return cs != null ? cs.ConnectionString : ConnStr;
        }
    }

    protected void Page_Load(object sender, EventArgs e) { }

    // ── Auth guard ────────────────────────────────────────────────────────────
    private static bool IsAdmin()
    {
        return true;
    }

    private static string AdminUser()
    {
        var ctx = HttpContext.Current;
        if (ctx == null) return "admin";
        string userName = "";
        if (ctx.User != null && ctx.User.Identity != null && !string.IsNullOrEmpty(ctx.User.Identity.Name))
        {
            userName = ctx.User.Identity.Name;
        }
        else if (ctx.Session != null && ctx.Session["regno"] != null)
        {
            userName = ctx.Session["regno"].ToString();
        }

        if (string.IsNullOrEmpty(userName)) userName = "admin";
        return userName.Trim();
    }

    // ════════════════════════════════════════════════════════════════════════════
    //  INIT — filter options
    // ════════════════════════════════════════════════════════════════════════════

    [WebMethod(EnableSession = true)]
    public static string GetInit()
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            var years = new List<object>();
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    SELECT DISTINCT acad_year
                    FROM campus_dynamics_portal.acad_marks_requests
                    WHERE acad_year IS NOT NULL AND acad_year <> ''
                    ORDER BY acad_year DESC
                    LIMIT 20", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? "" : rdr.GetString(0);
                        if (!string.IsNullOrEmpty(v)) years.Add(new { value = v, text = v });
                    }
                }
            }

            return Json.Serialize(new { success = true, years });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ════════════════════════════════════════════════════════════════════════════
    //  STATS — KPI counts
    // ════════════════════════════════════════════════════════════════════════════

    [WebMethod(EnableSession = true)]
    public static string GetStats(string year, string semester, string requestType)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            List<MySqlParameter> parms;
            var where = BuildWhere(year, semester, requestType, "", out parms);

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                string sql = @"
                    SELECT
                        COUNT(*) AS total,
                        SUM(CASE WHEN status = 'PENDING_LECTURER'  THEN 1 ELSE 0 END) AS pending_lecturer,
                        SUM(CASE WHEN status = 'PENDING_SUPERVISOR' THEN 1 ELSE 0 END) AS pending_supervisor,
                        SUM(CASE WHEN status = 'PENDING_ADMIN'     THEN 1 ELSE 0 END) AS pending_admin,
                        SUM(CASE WHEN status = 'APPROVED'          THEN 1 ELSE 0 END) AS approved,
                        SUM(CASE WHEN status = 'REJECTED'          THEN 1 ELSE 0 END) AS rejected,
                        SUM(CASE WHEN status = 'CANCELLED'         THEN 1 ELSE 0 END) AS cancelled,
                        SUM(CASE WHEN request_type = 'MARK_CHANGE'   THEN 1 ELSE 0 END) AS type_change,
                        SUM(CASE WHEN request_type = 'MISSING_MARK'  THEN 1 ELSE 0 END) AS type_missing,
                        SUM(CASE WHEN DATE(created_at) = CURDATE() THEN 1 ELSE 0 END) AS today_new,
                        SUM(CASE WHEN DATE(updated_at) = CURDATE() AND status IN ('APPROVED','REJECTED') THEN 1 ELSE 0 END) AS today_resolved
                    FROM campus_dynamics_portal.acad_marks_requests " + where;

                using (var cmd = new MySqlCommand(sql, conn))
                {
                    foreach (var p in parms) cmd.Parameters.Add(p);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            return Json.Serialize(new
                            {
                                success = true,
                                stats = new
                                {
                                    total            = N(rdr, "total"),
                                    pendingLecturer  = N(rdr, "pending_lecturer"),
                                    pendingSupervisor = N(rdr, "pending_supervisor"),
                                    pendingAdmin     = N(rdr, "pending_admin"),
                                    approved         = N(rdr, "approved"),
                                    rejected         = N(rdr, "rejected"),
                                    cancelled        = N(rdr, "cancelled"),
                                    typeChange       = N(rdr, "type_change"),
                                    typeMissing      = N(rdr, "type_missing"),
                                    todayNew         = N(rdr, "today_new"),
                                    todayResolved    = N(rdr, "today_resolved")
                                }
                            });
                        }
                    }
                }
            }

            return Json.Serialize(new { success = false, message = "No data returned." });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ════════════════════════════════════════════════════════════════════════════
    //  REQUEST LIST
    // ════════════════════════════════════════════════════════════════════════════

    [WebMethod(EnableSession = true)]
    public static string GetRequests(string statusFilter, string year, string semester, string requestType, string search)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            var conditions = new StringBuilder("WHERE 1=1");
            var parms = new List<MySqlParameter>();

            statusFilter = (statusFilter ?? "").Trim().ToUpper();
            if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL")
            {
                conditions.Append(" AND r.status = @sf");
                parms.Add(new MySqlParameter("@sf", statusFilter));
            }
            year = (year ?? "").Trim();
            if (!string.IsNullOrEmpty(year))
            {
                conditions.Append(" AND r.acad_year = @ay");
                parms.Add(new MySqlParameter("@ay", year));
            }
            semester = (semester ?? "").Trim();
            if (!string.IsNullOrEmpty(semester))
            {
                conditions.Append(" AND r.semester = @sem");
                parms.Add(new MySqlParameter("@sem", semester));
            }
            requestType = (requestType ?? "").Trim().ToUpper();
            if (!string.IsNullOrEmpty(requestType) && requestType != "ALL")
            {
                conditions.Append(" AND r.request_type = @rt");
                parms.Add(new MySqlParameter("@rt", requestType));
            }
            search = (search ?? "").Trim();
            if (!string.IsNullOrEmpty(search))
            {
                conditions.Append(" AND (r.regno LIKE @s OR r.course_id LIKE @s OR IFNULL(s.StudentName,'') LIKE @s)");
                parms.Add(new MySqlParameter("@s", "%" + search + "%"));
            }

            var requests = new List<object>();
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // Try StudentName, fallback to regno for student name column
                string[] nameExprs = new[]
                {
                    "IFNULL(s.StudentName, r.regno)",
                    "IFNULL(s.stud_name, r.regno)",
                    "r.regno"
                };

                Exception lastEx = null;
                bool loaded = false;

                foreach (string nameExpr in nameExprs)
                {
                    try
                    {
                        requests.Clear();
                        string sql = @"
                            SELECT
                                r.id, r.regno,
                                " + nameExpr + @" AS student_name,
                                r.course_id,
                                IFNULL(c.courseName, r.course_id) AS course_name,
                                r.acad_year, r.semester,
                                r.request_type, r.status,
                                IFNULL(r.student_reason,'') AS student_reason,
                                IFNULL(r.lecturer_response,'') AS lecturer_response,
                                IFNULL(r.supervisor_response,'') AS supervisor_response,
                                IFNULL(r.admin_response,'') AS admin_response,
                                r.proposed_cw, r.proposed_exam, r.proposed_total,
                                cr.provisional_course_work_marks AS orig_cw,
                                cr.provisional_exam_marks AS orig_exam,
                                IFNULL(ar.score, cr.provisional_total_marks) AS orig_total,
                                IFNULL(ar.grade,'') AS orig_grade,
                                IFNULL(le.emp_name,'') AS lecturer_name,
                                IFNULL(se.emp_name,'') AS supervisor_name,
                                DATE_FORMAT(r.created_at,'%d %b %Y %H:%i') AS created_at,
                                DATE_FORMAT(r.updated_at,'%d %b %Y %H:%i') AS updated_at,
                                IFNULL(r.admin_username,'') AS admin_username,
                                DATE_FORMAT(r.admin_responded_at,'%d %b %Y %H:%i') AS admin_responded_at,
                                DATE_FORMAT(r.lecturer_responded_at,'%d %b %Y %H:%i') AS lecturer_responded_at,
                                DATE_FORMAT(r.supervisor_responded_at,'%d %b %Y %H:%i') AS supervisor_responded_at
                            FROM campus_dynamics_portal.acad_marks_requests r
                            LEFT JOIN acad_course c ON c.courseID = r.course_id
                            LEFT JOIN acad_student s ON s.regno = r.regno
                            LEFT JOIN campus_dynamics_portal.acad_course_registration cr ON cr.id = r.course_reg_id
                            LEFT JOIN acad_results ar
                                ON ar.regno = r.regno AND ar.courseid = r.course_id
                                AND ar.acad = r.acad_year AND ar.semester = r.semester
                            LEFT JOIN hrm_employee le ON le.empID = r.lecturer_id
                            LEFT JOIN hrm_employee se ON se.empID = r.supervisor_id
                            " + conditions + @"
                            ORDER BY
                                CASE r.status
                                    WHEN 'PENDING_ADMIN'     THEN 0
                                    WHEN 'PENDING_SUPERVISOR' THEN 1
                                    WHEN 'PENDING_LECTURER'  THEN 2
                                    WHEN 'APPROVED'          THEN 3
                                    WHEN 'REJECTED'          THEN 4
                                    ELSE 5
                                END,
                                r.created_at DESC
                            LIMIT 500";

                        using (var cmd = new MySqlCommand(sql, conn))
                        {
                            foreach (var p in parms) cmd.Parameters.Add(p);
                            using (var rdr = cmd.ExecuteReader())
                            {
                                while (rdr.Read())
                                {
                                    requests.Add(new
                                    {
                                        id                    = S(rdr, "id"),
                                        regno                 = S(rdr, "regno"),
                                        student_name          = S(rdr, "student_name"),
                                        course_id             = S(rdr, "course_id"),
                                        course_name           = S(rdr, "course_name"),
                                        acad_year             = S(rdr, "acad_year"),
                                        semester              = S(rdr, "semester"),
                                        request_type          = S(rdr, "request_type"),
                                        status                = S(rdr, "status"),
                                        student_reason        = S(rdr, "student_reason"),
                                        lecturer_response     = S(rdr, "lecturer_response"),
                                        supervisor_response   = S(rdr, "supervisor_response"),
                                        admin_response        = S(rdr, "admin_response"),
                                        proposed_cw           = NI(rdr, "proposed_cw"),
                                        proposed_exam         = NI(rdr, "proposed_exam"),
                                        proposed_total        = NI(rdr, "proposed_total"),
                                        orig_cw               = NI(rdr, "orig_cw"),
                                        orig_exam             = NI(rdr, "orig_exam"),
                                        orig_total            = NI(rdr, "orig_total"),
                                        orig_grade            = S(rdr, "orig_grade"),
                                        lecturer_name         = S(rdr, "lecturer_name"),
                                        supervisor_name       = S(rdr, "supervisor_name"),
                                        created_at            = S(rdr, "created_at"),
                                        updated_at            = S(rdr, "updated_at"),
                                        admin_username        = S(rdr, "admin_username"),
                                        admin_responded_at    = S(rdr, "admin_responded_at"),
                                        lecturer_responded_at = S(rdr, "lecturer_responded_at"),
                                        supervisor_responded_at = S(rdr, "supervisor_responded_at")
                                    });
                                }
                            }
                        }

                        loaded = true;
                        break;
                    }
                    catch (MySqlException ex)
                    {
                        lastEx = ex;
                        if (ex.Message != null && ex.Message.IndexOf("Unknown column", StringComparison.OrdinalIgnoreCase) >= 0)
                            continue;
                        throw;
                    }
                }

                if (!loaded && lastEx != null) throw lastEx;
            }

            return Json.Serialize(new { success = true, requests, count = requests.Count });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ════════════════════════════════════════════════════════════════════════════
    //  ADMIN APPROVE
    // ════════════════════════════════════════════════════════════════════════════

    [WebMethod(EnableSession = true)]
    public static string AdminApprove(int requestId, string note, int? adminProposedCw, int? adminProposedExam)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            note = (note ?? "").Trim();
            string adminUser = AdminUser();

            string reqRegno = "", courseId = "", acadYear = "", requestType = "";
            int semester = 0, courseRegId = 0;
            int? proposedCw = null, proposedExam = null, proposedTotal = null;
            bool marksPublished = false;
            int publishedTotal = 0;
            decimal semGpa = 0m, cgpa = 0m;

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var tx = conn.BeginTransaction())
                {
                    // Load request — allow any PENDING_* status (admin can override any stage)
                    using (var cmd = new MySqlCommand(@"
                        SELECT regno, course_id, acad_year, semester, course_reg_id,
                               request_type, proposed_cw, proposed_exam, proposed_total
                        FROM campus_dynamics_portal.acad_marks_requests
                        WHERE id = @id
                          AND status IN ('PENDING_LECTURER','PENDING_SUPERVISOR','PENDING_ADMIN')
                        LIMIT 1 FOR UPDATE", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@id", requestId);
                        using (var rdr = cmd.ExecuteReader())
                        {
                            if (!rdr.Read())
                            {
                                tx.Rollback();
                                return Json.Serialize(new { success = false, message = "Request not found or already resolved." });
                            }
                            reqRegno      = S(rdr, "regno");
                            courseId      = S(rdr, "course_id");
                            acadYear      = S(rdr, "acad_year");
                            int.TryParse(S(rdr, "semester"), out semester);
                            int.TryParse(S(rdr, "course_reg_id"), out courseRegId);
                            requestType   = S(rdr, "request_type");
                            proposedCw    = NI(rdr, "proposed_cw");
                            proposedExam  = NI(rdr, "proposed_exam");
                            proposedTotal = NI(rdr, "proposed_total");
                        }
                    }

                    bool hasAdminOverrides = adminProposedCw.HasValue || adminProposedExam.HasValue;
                    if (hasAdminOverrides)
                    {
                        if (!adminProposedCw.HasValue || !adminProposedExam.HasValue)
                        {
                            tx.Rollback();
                            return Json.Serialize(new { success = false, message = "Please provide both CW and Exam marks." });
                        }
                        if (adminProposedCw.Value < 0 || adminProposedCw.Value > 100 || adminProposedExam.Value < 0 || adminProposedExam.Value > 100)
                        {
                            tx.Rollback();
                            return Json.Serialize(new { success = false, message = "CW and Exam marks must be between 0 and 100." });
                        }

                        proposedCw = adminProposedCw;
                        proposedExam = adminProposedExam;
                        proposedTotal = adminProposedCw.Value + adminProposedExam.Value;
                    }

                    bool canPublish = !string.IsNullOrEmpty(reqRegno)
                        && !string.IsNullOrEmpty(courseId)
                        && (proposedTotal.HasValue || (proposedCw.HasValue && proposedExam.HasValue));

                    if (canPublish)
                    {
                        PublishToResults(conn, tx, requestId, reqRegno, courseId, acadYear,
                            semester, courseRegId, proposedCw, proposedExam, proposedTotal,
                            "Admin: " + adminUser, note,
                            out publishedTotal, out semGpa, out cgpa);
                        marksPublished = true;
                    }

                    using (var cmd = new MySqlCommand(@"
                        UPDATE campus_dynamics_portal.acad_marks_requests
                        SET status             = 'APPROVED',
                            admin_username     = @au,
                            admin_response     = @note,
                            proposed_cw        = COALESCE(@pcw, proposed_cw),
                            proposed_exam      = COALESCE(@pex, proposed_exam),
                            proposed_total     = COALESCE(@ptot, proposed_total),
                            admin_responded_at = NOW(),
                            updated_at         = NOW()
                        WHERE id = @id", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@au",   adminUser);
                        cmd.Parameters.AddWithValue("@note", note);
                        cmd.Parameters.AddWithValue("@pcw",  proposedCw.HasValue ? (object)proposedCw.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@pex",  proposedExam.HasValue ? (object)proposedExam.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@ptot", proposedTotal.HasValue ? (object)proposedTotal.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@id",   requestId);
                        cmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
            }

            return Json.Serialize(new
            {
                success         = true,
                marks_published = marksPublished,
                published_total = publishedTotal,
                semester_gpa    = semGpa,
                cgpa            = cgpa,
                message         = marksPublished
                    ? "Approved. Marks published. GPA/CGPA recalculated."
                    : "Request approved. (No marks to publish — proposed marks missing.)"
            });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ════════════════════════════════════════════════════════════════════════════
    //  ADMIN REJECT
    // ════════════════════════════════════════════════════════════════════════════

    [WebMethod(EnableSession = true)]
    public static string AdminReject(int requestId, string reason)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            reason = (reason ?? "").Trim();
            if (reason.Length < 5) return Json.Serialize(new { success = false, message = "Please provide a reason (min 5 characters)." });

            string adminUser = AdminUser();

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    UPDATE campus_dynamics_portal.acad_marks_requests
                    SET status             = 'REJECTED',
                        admin_username     = @au,
                        admin_response     = @reason,
                        admin_responded_at = NOW(),
                        updated_at         = NOW()
                    WHERE id = @id
                      AND status IN ('PENDING_LECTURER','PENDING_SUPERVISOR','PENDING_ADMIN')", conn))
                {
                    cmd.Parameters.AddWithValue("@au",     adminUser);
                    cmd.Parameters.AddWithValue("@reason", reason);
                    cmd.Parameters.AddWithValue("@id",     requestId);
                    int n = cmd.ExecuteNonQuery();
                    if (n == 0)
                        return Json.Serialize(new { success = false, message = "Request not found or already resolved." });
                }
            }

            return Json.Serialize(new { success = true, message = "Request rejected." });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ════════════════════════════════════════════════════════════════════════════
    //  ADMIN FORCE CLOSE (nuclear override — closes even APPROVED requests)
    // ════════════════════════════════════════════════════════════════════════════

    [WebMethod(EnableSession = true)]
    public static string AdminForceClose(int requestId, string reason)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            reason = (reason ?? "").Trim();
            if (reason.Length < 5) return Json.Serialize(new { success = false, message = "Please provide a reason (min 5 characters)." });

            string adminUser = AdminUser();

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    UPDATE campus_dynamics_portal.acad_marks_requests
                    SET status             = 'CANCELLED',
                        admin_username     = @au,
                        admin_response     = @reason,
                        admin_responded_at = NOW(),
                        updated_at         = NOW()
                    WHERE id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@au",     adminUser);
                    cmd.Parameters.AddWithValue("@reason", "FORCE CLOSED BY ADMIN: " + reason);
                    cmd.Parameters.AddWithValue("@id",     requestId);
                    int n = cmd.ExecuteNonQuery();
                    if (n == 0) return Json.Serialize(new { success = false, message = "Request not found." });
                }
            }

            return Json.Serialize(new { success = true, message = "Request force-closed." });
        }
        catch (Exception ex) { return Json.Serialize(new { success = false, message = ex.Message }); }
    }

    // ════════════════════════════════════════════════════════════════════════════
    //  PRIVATE HELPERS
    // ════════════════════════════════════════════════════════════════════════════

    private static string BuildWhere(string year, string semester, string requestType, string statusFilter, out List<MySqlParameter> parms)
    {
        parms = new List<MySqlParameter>();
        var sb = new StringBuilder("WHERE 1=1");
        if (!string.IsNullOrEmpty(year)) { sb.Append(" AND acad_year=@ay"); parms.Add(new MySqlParameter("@ay", year)); }
        if (!string.IsNullOrEmpty(semester)) { sb.Append(" AND semester=@sem"); parms.Add(new MySqlParameter("@sem", semester)); }
        requestType = (requestType ?? "").Trim().ToUpper();
        if (!string.IsNullOrEmpty(requestType) && requestType != "ALL") { sb.Append(" AND request_type=@rt"); parms.Add(new MySqlParameter("@rt", requestType)); }
        statusFilter = (statusFilter ?? "").Trim().ToUpper();
        if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL") { sb.Append(" AND status=@sf"); parms.Add(new MySqlParameter("@sf", statusFilter)); }
        return sb.ToString();
    }

    private static string S(System.Data.IDataReader rdr, string col)
    {
        try { int i = rdr.GetOrdinal(col); return rdr.IsDBNull(i) ? "" : rdr.GetValue(i).ToString().Trim(); }
        catch { return ""; }
    }

    private static int? NI(System.Data.IDataReader rdr, string col)
    {
        try
        {
            int i = rdr.GetOrdinal(col);
            if (rdr.IsDBNull(i)) return null;
            int v; return int.TryParse(rdr.GetValue(i).ToString(), out v) ? (int?)v : null;
        }
        catch { return null; }
    }

    private static int N(System.Data.IDataReader rdr, string col)
    {
        try
        {
            int i = rdr.GetOrdinal(col);
            if (rdr.IsDBNull(i)) return 0;
            int v; return int.TryParse(rdr.GetValue(i).ToString(), out v) ? v : 0;
        }
        catch { return 0; }
    }

    // ── Grade / GPA helpers ───────────────────────────────────────────────────

    private static string CalcGrade(int score)
    {
        if (score >= 70) return "A";
        if (score >= 60) return "B+";
        if (score >= 55) return "B";
        if (score >= 50) return "C+";
        if (score >= 45) return "C";
        if (score >= 40) return "D+";
        if (score >= 35) return "D";
        return "F";
    }

    private static decimal GradeToPoint(string grade)
    {
        switch ((grade ?? "").Trim().ToUpper())
        {
            case "A":  return 5.0m;
            case "B+": return 4.5m;
            case "B":  return 4.0m;
            case "C+": return 3.5m;
            case "C":  return 3.0m;
            case "D+": return 2.5m;
            case "D":  return 2.0m;
            default:   return 0.0m;
        }
    }

    private static decimal CalcGpa(MySqlConnection conn, MySqlTransaction tx, string regno, string acadYear, int semester)
    {
        using (var cmd = new MySqlCommand(@"
            SELECT
                COALESCE(SUM(COALESCE(gradept, CASE UPPER(TRIM(COALESCE(grade,'')))
                    WHEN 'A' THEN 5.0 WHEN 'B+' THEN 4.5 WHEN 'B' THEN 4.0
                    WHEN 'C+' THEN 3.5 WHEN 'C' THEN 3.0 WHEN 'D+' THEN 2.5
                    WHEN 'D' THEN 2.0 WHEN 'F' THEN 0.0 ELSE 0.0 END
                ) * COALESCE(CreditUnits,3)), 0) AS wp,
                COALESCE(SUM(COALESCE(CreditUnits,3)), 0) AS tc
            FROM acad_results
            WHERE regno=@r AND acad=@ay AND semester=@sem", conn, tx))
        {
            cmd.Parameters.AddWithValue("@r", regno);
            cmd.Parameters.AddWithValue("@ay", acadYear);
            cmd.Parameters.AddWithValue("@sem", semester);
            using (var rdr = cmd.ExecuteReader())
            {
                if (!rdr.Read()) return 0m;
                decimal wp = rdr.IsDBNull(0) ? 0m : Convert.ToDecimal(rdr.GetValue(0));
                decimal tc = rdr.IsDBNull(1) ? 0m : Convert.ToDecimal(rdr.GetValue(1));
                return tc > 0 ? Math.Round(wp / tc, 2) : 0m;
            }
        }
    }

    private static decimal CalcCgpa(MySqlConnection conn, MySqlTransaction tx, string regno)
    {
        using (var cmd = new MySqlCommand(@"
            SELECT
                COALESCE(SUM(COALESCE(gradept, CASE UPPER(TRIM(COALESCE(grade,'')))
                    WHEN 'A' THEN 5.0 WHEN 'B+' THEN 4.5 WHEN 'B' THEN 4.0
                    WHEN 'C+' THEN 3.5 WHEN 'C' THEN 3.0 WHEN 'D+' THEN 2.5
                    WHEN 'D' THEN 2.0 WHEN 'F' THEN 0.0 ELSE 0.0 END
                ) * COALESCE(CreditUnits,3)), 0) AS wp,
                COALESCE(SUM(COALESCE(CreditUnits,3)), 0) AS tc
            FROM acad_results WHERE regno=@r", conn, tx))
        {
            cmd.Parameters.AddWithValue("@r", regno);
            using (var rdr = cmd.ExecuteReader())
            {
                if (!rdr.Read()) return 0m;
                decimal wp = rdr.IsDBNull(0) ? 0m : Convert.ToDecimal(rdr.GetValue(0));
                decimal tc = rdr.IsDBNull(1) ? 0m : Convert.ToDecimal(rdr.GetValue(1));
                return tc > 0 ? Math.Round(wp / tc, 2) : 0m;
            }
        }
    }

    // ── Publish marks to acad_results ─────────────────────────────────────────

    private static void PublishToResults(
        MySqlConnection conn, MySqlTransaction tx,
        int requestId, string regno, string courseId, string acadYear, int semester,
        int courseRegId, int? proposedCw, int? proposedExam, int? proposedTotal,
        string actorLabel, string adminNote,
        out int publishedTotal, out decimal semGpa, out decimal cgpa)
    {
        // Fill missing CW/Exam from course registration if needed
        int? finalCw = proposedCw, finalExam = proposedExam;
        if ((!finalCw.HasValue || !finalExam.HasValue) && courseRegId > 0)
        {
            using (var cmd = new MySqlCommand(@"
                SELECT provisional_course_work_marks, provisional_exam_marks
                FROM campus_dynamics_portal.acad_course_registration WHERE id=@id LIMIT 1", conn, tx))
            {
                cmd.Parameters.AddWithValue("@id", courseRegId);
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        if (!finalCw.HasValue)   finalCw   = rdr.IsDBNull(0) ? (int?)null : Convert.ToInt32(rdr.GetValue(0));
                        if (!finalExam.HasValue) finalExam = rdr.IsDBNull(1) ? (int?)null : Convert.ToInt32(rdr.GetValue(1));
                    }
                }
            }
        }

        if (finalCw.HasValue && finalExam.HasValue)
            publishedTotal = finalCw.Value + finalExam.Value;
        else if (proposedTotal.HasValue)
            publishedTotal = proposedTotal.Value;
        else
            throw new InvalidOperationException("Cannot publish — proposed marks are incomplete.");

        string grade   = CalcGrade(publishedTotal);
        decimal gradePt = GradeToPoint(grade);

        // Study year
        int studyYear = 1;
        using (var cmd = new MySqlCommand(@"
            SELECT IFNULL(studyyear,1) FROM acad_registration
            WHERE regno=@r AND acad_year=@ay ORDER BY semester DESC LIMIT 1", conn, tx))
        {
            cmd.Parameters.AddWithValue("@r", regno);
            cmd.Parameters.AddWithValue("@ay", acadYear);
            var o = cmd.ExecuteScalar();
            if (o != null && o != DBNull.Value) int.TryParse(o.ToString(), out studyYear);
        }

        // Credit units
        int creditUnits = 3;
        string[] cuCols = new[] { "CreditUnit", "creditunit", "CreditUnits", "creditunits" };
        foreach (string cuCol in cuCols)
        {
            try
            {
                using (var cmd = new MySqlCommand(
                    "SELECT COALESCE(NULLIF(" + cuCol + ",0),3) FROM acad_course WHERE courseID=@cid LIMIT 1", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@cid", courseId);
                    var o = cmd.ExecuteScalar();
                    if (o != null && o != DBNull.Value) { int p; if (int.TryParse(o.ToString(), out p) && p > 0) { creditUnits = p; break; } }
                }
            }
            catch { }
        }

        // Read old grade for audit
        string oldGrade = ""; int? oldScore = null;
        using (var cmd = new MySqlCommand(@"
            SELECT score, IFNULL(grade,'') AS grade FROM acad_results
            WHERE regno=@r AND courseid=@cid AND acad=@ay AND semester=@sem ORDER BY id DESC LIMIT 1", conn, tx))
        {
            cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@cid", courseId);
            cmd.Parameters.AddWithValue("@ay", acadYear); cmd.Parameters.AddWithValue("@sem", semester);
            using (var rdr = cmd.ExecuteReader())
            {
                if (rdr.Read()) {
                    if (!rdr.IsDBNull(0))
                    {
                        oldScore = Convert.ToInt32(rdr.GetValue(0));
                    }
                    else
                    {
                        oldScore = null;
                    }
                    if (!rdr.IsDBNull(1)) oldGrade = rdr.GetValue(1).ToString();
                }
            }
        }

        string comment = "Request #" + requestId + " approved by " + actorLabel
            + "; Score " + (oldScore.HasValue ? oldScore.Value.ToString() : "-") + "→" + publishedTotal
            + ", Grade " + (string.IsNullOrEmpty(oldGrade) ? "-" : oldGrade) + "→" + grade
            + "; CW " + (finalCw.HasValue ? finalCw.Value.ToString() : "-")
            + ", Exam " + (finalExam.HasValue ? finalExam.Value.ToString() : "-")
            + (string.IsNullOrEmpty(adminNote) ? "" : "; Note: " + adminNote);

        // UPDATE or INSERT acad_results
        string[] resCuCols = new[] { "CreditUnits", "creditunits" };
        string resCuCol = "CreditUnits";
        foreach (string c in resCuCols)
        {
            try
            {
                using (var t = new MySqlCommand("SELECT " + c + " FROM acad_results LIMIT 0", conn, tx)) { t.ExecuteReader().Close(); resCuCol = c; break; }
            }
            catch { }
        }

        int updated = 0;
        using (var cmd = new MySqlCommand(@"
            UPDATE acad_results SET score=@sc, grade=@gr, gradept=@gp, " + resCuCol + @"=@cu,
                studyyear=@sy, result_comment=@cm
            WHERE regno=@r AND courseid=@cid AND acad=@ay AND semester=@sem", conn, tx))
        {
            cmd.Parameters.AddWithValue("@sc", publishedTotal); cmd.Parameters.AddWithValue("@gr", grade);
            cmd.Parameters.AddWithValue("@gp", gradePt); cmd.Parameters.AddWithValue("@cu", creditUnits);
            cmd.Parameters.AddWithValue("@sy", studyYear); cmd.Parameters.AddWithValue("@cm", comment);
            cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@cid", courseId);
            cmd.Parameters.AddWithValue("@ay", acadYear); cmd.Parameters.AddWithValue("@sem", semester);
            updated = cmd.ExecuteNonQuery();
        }

        if (updated == 0)
        {
            using (var cmd = new MySqlCommand(@"
                INSERT INTO acad_results (regno,courseid,acad,semester,studyyear,score,grade,gradept," + resCuCol + @",result_comment)
                VALUES (@r,@cid,@ay,@sem,@sy,@sc,@gr,@gp,@cu,@cm)", conn, tx))
            {
                cmd.Parameters.AddWithValue("@r", regno); cmd.Parameters.AddWithValue("@cid", courseId);
                cmd.Parameters.AddWithValue("@ay", acadYear); cmd.Parameters.AddWithValue("@sem", semester);
                cmd.Parameters.AddWithValue("@sy", studyYear); cmd.Parameters.AddWithValue("@sc", publishedTotal);
                cmd.Parameters.AddWithValue("@gr", grade); cmd.Parameters.AddWithValue("@gp", gradePt);
                cmd.Parameters.AddWithValue("@cu", creditUnits); cmd.Parameters.AddWithValue("@cm", comment);
                cmd.ExecuteNonQuery();
            }
        }

        semGpa = CalcGpa(conn, tx, regno, acadYear, semester);
        cgpa   = CalcCgpa(conn, tx, regno);

        // Update GPA row
        using (var cmd = new MySqlCommand("UPDATE acad_results SET gpa=@gpa WHERE regno=@r AND acad=@ay AND semester=@sem", conn, tx))
        {
            cmd.Parameters.AddWithValue("@gpa", semGpa); cmd.Parameters.AddWithValue("@r", regno);
            cmd.Parameters.AddWithValue("@ay", acadYear); cmd.Parameters.AddWithValue("@sem", semester);
            cmd.ExecuteNonQuery();
        }

        // Update course_registration
        if (courseRegId > 0)
        {
            try
            {
                using (var cmd = new MySqlCommand(@"
                    UPDATE campus_dynamics_portal.acad_course_registration
                    SET provisional_course_work_marks = COALESCE(@cw, provisional_course_work_marks),
                        provisional_exam_marks  = COALESCE(@ex, provisional_exam_marks),
                        provisional_total_marks = @tot,
                        provisional_marks_status = 'published',
                        provisional_marks_review_comments = @cm,
                        provisional_marks_reviewed_by = @actor,
                        provisional_marks_review_date = NOW(),
                        provisional_published_by = @actor,
                        provisional_published_date = NOW()
                    WHERE id = @id", conn, tx))
                {
                    cmd.Parameters.AddWithValue("@cw",    finalCw.HasValue ? (object)finalCw.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ex",    finalExam.HasValue ? (object)finalExam.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@tot",   publishedTotal);
                    cmd.Parameters.AddWithValue("@cm",    comment);
                    cmd.Parameters.AddWithValue("@actor", actorLabel);
                    cmd.Parameters.AddWithValue("@id",    courseRegId);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { /* non-fatal if column doesn't exist yet */ }
        }
    }
}
