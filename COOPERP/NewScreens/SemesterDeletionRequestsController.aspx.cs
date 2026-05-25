using System;
using System.Collections.Generic;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using MySql.Data.MySqlClient;

[ScriptService]
public partial class COOPERP_NewScreens_SemesterDeletionRequestsController : Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer { MaxJsonLength = 8 * 1024 * 1024 };

    private static string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string status = (Request.QueryString["status"] ?? "PENDING").Trim().ToUpperInvariant();
            var valid = new[] { "PENDING", "APPROVED", "REJECTED", "ALL" };
            bool ok = false;
            foreach (var v in valid) { if (status == v) { ok = true; break; } }
            if (!ok) status = "PENDING";

            string year = (Request.QueryString["year"] ?? "").Trim();
            string q    = (Request.QueryString["q"] ?? "").Trim();
            int page = 1;
            int per  = 25;
            int.TryParse(Request.QueryString["page"] ?? "1", out page);
            int.TryParse(Request.QueryString["per"] ?? "25", out per);
            if (page < 1) page = 1;
            if (per < 10) per = 10;
            if (per > 100) per = 100;

            litInitVars.Text = string.Format(
                "<script>var _sdrInit={{status:'{0}',year:'{1}',q:'{2}',page:{3},per:{4}}};</script>",
                HttpUtility.JavaScriptStringEncode(status),
                HttpUtility.JavaScriptStringEncode(year),
                HttpUtility.JavaScriptStringEncode(q),
                page, per);
        }
    }

    private static bool IsAdmin()
    {
        return true;
    }

    private static string AdminUser()
    {
        var ctx = HttpContext.Current;
        if (ctx == null) return "admin";
        if (ctx.Session != null && ctx.Session["username"] != null && !string.IsNullOrWhiteSpace(ctx.Session["username"].ToString()))
            return ctx.Session["username"].ToString().Trim();
        if (ctx.User != null && ctx.User.Identity != null && !string.IsNullOrWhiteSpace(ctx.User.Identity.Name))
            return ctx.User.Identity.Name.Trim();
        return "admin";
    }

    [WebMethod(EnableSession = true)]
    public static string GetRequests(string statusFilter, string acadYear, string search, int page, int pageSize)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            string status = (statusFilter ?? "PENDING").Trim().ToUpperInvariant();
            string year   = (acadYear ?? "").Trim();
            string q      = (search ?? "").Trim();
            if (page < 1) page = 1;
            if (pageSize < 10) pageSize = 10;
            if (pageSize > 100) pageSize = 100;

            var where = new List<string> { "1=1" };
            var parms = new List<MySqlParameter>();

            if (!string.Equals(status, "ALL", StringComparison.OrdinalIgnoreCase))
            {
                where.Add("r.status=@st");
                parms.Add(new MySqlParameter("@st", status));
            }
            if (!string.IsNullOrWhiteSpace(year))
            {
                where.Add("r.acad_year=@ay");
                parms.Add(new MySqlParameter("@ay", year));
            }
            if (!string.IsNullOrWhiteSpace(q))
            {
                where.Add("(r.regno LIKE @q OR IFNULL(r.student_name,'') LIKE @q OR IFNULL(r.programme_name,'') LIKE @q)");
                parms.Add(new MySqlParameter("@q", "%" + q + "%"));
            }

            string whereClause = string.Join(" AND ", where);
            int total = 0, pending = 0, approved = 0, rejected = 0, totalPages = 1;
            var rows = new List<object>();

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                using (var cmd = new MySqlCommand(
                    "SELECT COUNT(*) AS total, " +
                    "SUM(CASE WHEN r.status='PENDING' THEN 1 ELSE 0 END) AS pending, " +
                    "SUM(CASE WHEN r.status='APPROVED' THEN 1 ELSE 0 END) AS approved, " +
                    "SUM(CASE WHEN r.status='REJECTED' THEN 1 ELSE 0 END) AS rejected " +
                    "FROM campus_dynamics_portal.acad_semester_deletion_requests r WHERE " + whereClause, conn))
                {
                    foreach (var p in parms)
                        cmd.Parameters.Add(new MySqlParameter(p.ParameterName, p.Value));
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            total    = ToInt(rdr["total"]);
                            pending  = ToInt(rdr["pending"]);
                            approved = ToInt(rdr["approved"]);
                            rejected = ToInt(rdr["rejected"]);
                        }
                    }
                }

                int offset = (page - 1) * pageSize;
                totalPages = total == 0 ? 1 : (int)Math.Ceiling((double)total / pageSize);

                using (var cmd = new MySqlCommand(@"
                    SELECT r.id,
                           r.regno,
                           IFNULL(r.student_name,'') AS student_name,
                           IFNULL(r.programme_code,'') AS programme_code,
                           IFNULL(r.programme_name,'') AS programme_name,
                           r.acad_year,
                           r.study_year,
                           r.semester,
                           IFNULL(r.request_reason,'') AS request_reason,
                           r.status,
                           IFNULL(r.admin_username,'') AS admin_username,
                           IFNULL(r.admin_comment,'') AS admin_comment,
                           DATE_FORMAT(r.created_at,'%d %b %Y %H:%i') AS created_at,
                           DATE_FORMAT(r.decided_at,'%d %b %Y %H:%i') AS decided_at
                    FROM campus_dynamics_portal.acad_semester_deletion_requests r
                    WHERE " + whereClause + @"
                    ORDER BY r.created_at DESC
                    LIMIT @lim OFFSET @off", conn))
                {
                    foreach (var p in parms)
                        cmd.Parameters.Add(new MySqlParameter(p.ParameterName, p.Value));
                    cmd.Parameters.AddWithValue("@lim", pageSize);
                    cmd.Parameters.AddWithValue("@off", offset);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            rows.Add(new
                            {
                                id             = ToInt(rdr["id"]),
                                regno          = rdr["regno"].ToString(),
                                student_name   = rdr["student_name"].ToString(),
                                programme_code = rdr["programme_code"].ToString(),
                                programme_name = rdr["programme_name"].ToString(),
                                acad_year      = rdr["acad_year"].ToString(),
                                study_year     = ToInt(rdr["study_year"]),
                                semester       = ToInt(rdr["semester"]),
                                request_reason = rdr["request_reason"].ToString(),
                                status         = rdr["status"].ToString(),
                                admin_username = rdr["admin_username"].ToString(),
                                admin_comment  = rdr["admin_comment"].ToString(),
                                created_at     = rdr["created_at"].ToString(),
                                decided_at     = rdr["decided_at"].ToString()
                            });
                        }
                    }
                }
            }

            return Json.Serialize(new
            {
                success     = true,
                requests    = rows,
                total       = total,
                pending     = pending,
                approved    = approved,
                rejected    = rejected,
                page        = page,
                pageSize    = pageSize,
                total_pages = totalPages
            });
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = ex.Message });
        }
    }

    [WebMethod(EnableSession = true)]
    public static string BatchDecide(string idsJson, string decision, string comment)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });

            string d = (decision ?? "").Trim().ToUpperInvariant();
            string c = (comment ?? "").Trim();
            if (d != "APPROVE" && d != "REJECT")
                return Json.Serialize(new { success = false, message = "Decision must be APPROVE or REJECT." });
            if (d == "REJECT" && string.IsNullOrWhiteSpace(c))
                return Json.Serialize(new { success = false, message = "Comment is required for batch rejection." });

            int[] ids;
            try { ids = (new JavaScriptSerializer()).Deserialize<int[]>(idsJson ?? "[]"); }
            catch { return Json.Serialize(new { success = false, message = "Invalid ID list." }); }

            if (ids == null || ids.Length == 0)
                return Json.Serialize(new { success = false, message = "No requests selected." });

            int processed = 0, skipped = 0;
            var errors = new List<string>();

            foreach (int id in ids)
            {
                try
                {
                    var resultJson = DecideRequest(id, d, c);
                    var result = (new JavaScriptSerializer()).Deserialize<Dictionary<string, object>>(resultJson);
                    object successVal;
                    if (result != null && result.TryGetValue("success", out successVal) && true.Equals(successVal))
                        processed++;
                    else
                    {
                        skipped++;
                        object msg;
                        if (result != null && result.TryGetValue("message", out msg))
                            errors.Add("ID " + id + ": " + (msg ?? "unknown error").ToString());
                    }
                }
                catch (Exception ex)
                {
                    skipped++;
                    errors.Add("ID " + id + ": " + ex.Message);
                }
            }

            return Json.Serialize(new
            {
                success   = true,
                processed = processed,
                skipped   = skipped,
                errors    = errors,
                message   = processed + " request(s) " + (d == "APPROVE" ? "approved" : "rejected") +
                            (skipped > 0 ? ", " + skipped + " skipped" : "") + "."
            });
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = ex.Message });
        }
    }

    [WebMethod(EnableSession = true)]
    public static string GetRequest(int id)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });
            if (id <= 0) return Json.Serialize(new { success = false, message = "Invalid request id." });

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    SELECT id, regno, IFNULL(student_name,'') AS student_name,
                           IFNULL(programme_code,'') AS programme_code,
                           IFNULL(programme_name,'') AS programme_name,
                           acad_year, study_year, semester,
                           IFNULL(request_reason,'') AS request_reason,
                           status, IFNULL(admin_username,'') AS admin_username,
                           IFNULL(admin_comment,'') AS admin_comment,
                           DATE_FORMAT(created_at,'%d %b %Y %H:%i') AS created_at,
                           DATE_FORMAT(decided_at,'%d %b %Y %H:%i') AS decided_at,
                           deletion_executed
                    FROM campus_dynamics_portal.acad_semester_deletion_requests
                    WHERE id=@id
                    LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) return Json.Serialize(new { success = false, message = "Request not found." });

                        var row = new
                        {
                            id             = ToInt(rdr["id"]),
                            regno          = rdr["regno"].ToString(),
                            student_name   = rdr["student_name"].ToString(),
                            programme_code = rdr["programme_code"].ToString(),
                            programme_name = rdr["programme_name"].ToString(),
                            acad_year      = rdr["acad_year"].ToString(),
                            study_year     = ToInt(rdr["study_year"]),
                            semester       = ToInt(rdr["semester"]),
                            request_reason = rdr["request_reason"].ToString(),
                            status         = rdr["status"].ToString(),
                            admin_username = rdr["admin_username"].ToString(),
                            admin_comment  = rdr["admin_comment"].ToString(),
                            created_at     = rdr["created_at"].ToString(),
                            decided_at     = rdr["decided_at"].ToString(),
                            deletion_executed = ToInt(rdr["deletion_executed"]) == 1
                        };

                        return Json.Serialize(new { success = true, request = row });
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = ex.Message });
        }
    }

    [WebMethod(EnableSession = true)]
    public static string DecideRequest(int id, string decision, string comment)
    {
        try
        {
            if (!IsAdmin()) return Json.Serialize(new { success = false, message = "Access denied." });
            if (id <= 0) return Json.Serialize(new { success = false, message = "Invalid request id." });

            string d = (decision ?? "").Trim().ToUpperInvariant();
            string c = (comment ?? "").Trim();
            if (d != "APPROVE" && d != "REJECT") return Json.Serialize(new { success = false, message = "Decision must be APPROVE or REJECT." });
            if (d == "REJECT" && string.IsNullOrWhiteSpace(c)) return Json.Serialize(new { success = false, message = "Comment is required for rejection." });

            string regno;
            string acadYear;
            int studyYear;
            int semester;
            string status;

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    SELECT regno, acad_year, study_year, semester, status
                    FROM campus_dynamics_portal.acad_semester_deletion_requests
                    WHERE id=@id
                    LIMIT 1", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (var rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read()) return Json.Serialize(new { success = false, message = "Request not found." });
                        regno     = rdr["regno"].ToString();
                        acadYear  = rdr["acad_year"].ToString();
                        studyYear = ToInt(rdr["study_year"]);
                        semester  = ToInt(rdr["semester"]);
                        status    = rdr["status"].ToString();
                    }
                }
            }

            int deletedRegs = 0;
            int deletedCourses = 0;

            if (d == "APPROVE")
            {
                using (var conn = new MySqlConnection(ConnStr))
                {
                    conn.Open();
                    using (var cmd = new MySqlCommand(@"
                        DELETE FROM campus_dynamics.acad_registration
                        WHERE TRIM(regno)=@r AND acad_year=@a AND studyyear=@y AND semester=@s
                        LIMIT 1", conn))
                    {
                        cmd.Parameters.AddWithValue("@r", regno.Trim());
                        cmd.Parameters.AddWithValue("@a", acadYear);
                        cmd.Parameters.AddWithValue("@y", studyYear);
                        cmd.Parameters.AddWithValue("@s", semester);
                        deletedRegs = cmd.ExecuteNonQuery();
                    }

                    using (var cmd = new MySqlCommand(@"
                        DELETE FROM campus_dynamics_portal.acad_course_registration
                        WHERE TRIM(regno)=@r AND acad_year=@a AND semester=@s", conn))
                    {
                        cmd.Parameters.AddWithValue("@r", regno.Trim());
                        cmd.Parameters.AddWithValue("@a", acadYear);
                        cmd.Parameters.AddWithValue("@s", semester);
                        deletedCourses = cmd.ExecuteNonQuery();
                    }
                }
            }

            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(@"
                    UPDATE campus_dynamics_portal.acad_semester_deletion_requests
                    SET status=@st,
                        admin_username=@au,
                        admin_comment=@ac,
                        decided_at=NOW(),
                        deletion_executed=@dex,
                        deletion_executed_at=CASE WHEN @dex=1 THEN NOW() ELSE deletion_executed_at END,
                        student_notified=1,
                        student_notified_at=NOW(),
                        student_seen=0,
                        student_seen_at=NULL
                    WHERE id=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@st", d == "APPROVE" ? "APPROVED" : "REJECTED");
                    cmd.Parameters.AddWithValue("@au", AdminUser());
                    cmd.Parameters.AddWithValue("@ac", c);
                    cmd.Parameters.AddWithValue("@dex", d == "APPROVE" ? 1 : 0);
                    cmd.Parameters.AddWithValue("@id", id);
                    if (cmd.ExecuteNonQuery() <= 0)
                        return Json.Serialize(new { success = false, message = "Request not found. Refresh and retry." });
                }
            }

            return Json.Serialize(new
            {
                success = true,
                message = d == "APPROVE" ? "Request approved and semester registration deleted." : "Request rejected.",
                data    = new { deleted_semester_registration = deletedRegs, deleted_course_rows = deletedCourses }
            });
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = ex.Message });
        }
    }

    private static int ToInt(object value)
    {
        if (value == null || value == DBNull.Value) return 0;
        int outVal;
        return int.TryParse(value.ToString(), out outVal) ? outVal : 0;
    }
}
