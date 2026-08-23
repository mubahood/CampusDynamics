using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// API/v2/requests — everything a student ASKS THE UNIVERSITY FOR.
///
/// Three flows that all have the same shape — the student raises something, somebody decides it,
/// the student watches it move — and which between them account for 1,530 mark requests, 197
/// retake registrations and 35 course-removal requests already sitting in the database with no
/// way for an app to see any of it.
///
/// Reads are self-scoped from the token. Writes re-derive every precondition from storage: that
/// the course registration is really the student's, that a duplicate request is not already open,
/// that a retake is really a failed course. A caller cannot raise a request against someone
/// else's registration by guessing an id.
///
/// These tables live in campus_dynamics_portal, so everything here goes through
/// ApiHelper.QueryPortal / ExecutePortal / ExecuteInsertPortal / ScalarPortal. Academic tables
/// are reached cross-database with the campus_dynamics. prefix.
/// </summary>
public partial class API_v2_requests : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;
        if (ApiHelper.IsRateLimited(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "marks":                   HandleMarks();                break;
                case "mark_detail":             HandleMarkDetail();           break;
                case "submit_mark":             HandleSubmitMark();           break;
                case "cancel_mark":             HandleCancelMark();           break;
                case "course_removals":         HandleCourseRemovals();       break;
                case "submit_course_removal":   HandleSubmitCourseRemoval();  break;
                case "cancel_course_removal":   HandleCancelCourseRemoval();  break;
                case "retakes":                 HandleRetakes();              break;
                case "register_retake":         HandleRegisterRetake();       break;
                case "ping":
                    ApiHelper.Success(Response, new { service = "requests", time = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") }, "OK");
                    break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". Valid actions: marks, mark_detail, submit_mark, " +
                        "cancel_mark, course_removals, submit_course_removal, cancel_course_removal, " +
                        "retakes, register_retake, ping",
                        "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AUTH
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>The signed-in student. Staff (and the superuser token) must name the student
    /// explicitly; a student token is always about itself and ignores any regno given.</summary>
    private string Me(out TokenInfo auth)
    {
        auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return null;

        if (string.Equals(auth.UserType, "student", StringComparison.OrdinalIgnoreCase))
            return (auth.UserId ?? "").Trim();

        string regno = ApiHelper.Param(Request, "regno", "").Trim();
        if (regno == "")
        {
            ApiHelper.Error(Response, "Pass ?regno= to act for a student.", "MISSING_PARAM");
            return null;
        }
        return regno;
    }

    /// <summary>Writes are the student's own business — staff decide requests in eadmin, they do
    /// not raise them. The superuser integration token is allowed through for testing.</summary>
    private string MeForWrite(out TokenInfo auth)
    {
        string regno = Me(out auth);
        if (regno == null) return null;
        if (!string.Equals(auth.UserType, "student", StringComparison.OrdinalIgnoreCase)
            && !TokenManager.IsSpecialToken(auth))
        {
            ApiHelper.Error(Response, "Only the student can raise this request. Staff act on it in eadmin.",
                "STUDENT_TOKEN_REQUIRED");
            return null;
        }
        return regno;
    }

    private static int Page1(HttpRequest r) { int p = ApiHelper.ParamInt(r, "page", 1); return p < 1 ? 1 : p; }
    private static int Limit(HttpRequest r) { int l = ApiHelper.ParamInt(r, "limit", 25); return l < 1 ? 25 : (l > 100 ? 100 : l); }

    private static object Paged(int page, int limit, int total)
    {
        return new { page = page, limit = limit, total = total, total_pages = limit > 0 ? (int)Math.Ceiling(total / (double)limit) : 0 };
    }

    // ═══════════════════════════════════════════════════════════════════
    //  MARK CORRECTION REQUESTS
    // ═══════════════════════════════════════════════════════════════════

    private void HandleMarks()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;

        string status = ApiHelper.Param(Request, "status", "").Trim().ToUpperInvariant();
        int page = Page1(Request), limit = Limit(Request);

        string where = "WHERE TRIM(r.regno) = @r";
        var ps = new List<MySqlParameter> { new MySqlParameter("@r", regno) };
        if (status == "OPEN") where += " AND r.status IN ('PENDING_LECTURER','PENDING_SUPERVISOR','PENDING_ADMIN')";
        else if (status == "CLOSED") where += " AND r.status IN ('APPROVED','REJECTED','CANCELLED')";
        else if (status != "") { where += " AND r.status = @s"; ps.Add(new MySqlParameter("@s", status)); }

        object totalObj = ApiHelper.ScalarPortal("SELECT COUNT(*) FROM acad_marks_requests r " + where, ps.ToArray());
        int total = totalObj == null ? 0 : Convert.ToInt32(totalObj);

        var ps2 = new List<MySqlParameter>(ps);
        DataTable dt = ApiHelper.QueryPortal(
            "SELECT r.id, TRIM(r.course_id) AS course_code, IFNULL(c.courseName,'') AS course_name, " +
            "  r.acad_year, r.semester, r.request_type, r.status, IFNULL(r.student_reason,'') AS student_reason, " +
            "  IFNULL(r.lecturer_response,'') AS lecturer_response, IFNULL(r.supervisor_response,'') AS supervisor_response, " +
            "  IFNULL(r.admin_response,'') AS admin_response, " +
            "  DATE_FORMAT(r.created_at,'%Y-%m-%d %H:%i') AS created_at, " +
            "  IFNULL(DATE_FORMAT(r.updated_at,'%Y-%m-%d %H:%i'),'') AS updated_at, " +
            "  IFNULL(r.proposed_total,0) AS proposed_total " +
            "FROM acad_marks_requests r " +
            "LEFT JOIN campus_dynamics.acad_course c ON TRIM(c.courseID) = TRIM(r.course_id) " +
            where + " ORDER BY r.id DESC LIMIT " + limit + " OFFSET " + ((page - 1) * limit),
            ps2.ToArray());

        var items = new List<object>();
        foreach (DataRow r in dt.Rows)
            items.Add(new
            {
                id = Convert.ToInt32(r["id"]),
                course_code = Convert.ToString(r["course_code"]),
                course_name = Convert.ToString(r["course_name"]),
                acad_year = Convert.ToString(r["acad_year"]),
                semester = r["semester"] == DBNull.Value ? 0 : Convert.ToInt32(r["semester"]),
                request_type = Convert.ToString(r["request_type"]),
                status = Convert.ToString(r["status"]),
                stage = StageOf(Convert.ToString(r["status"])),
                is_open = IsOpen(Convert.ToString(r["status"])),
                student_reason = Convert.ToString(r["student_reason"]),
                lecturer_response = Convert.ToString(r["lecturer_response"]),
                supervisor_response = Convert.ToString(r["supervisor_response"]),
                admin_response = Convert.ToString(r["admin_response"]),
                proposed_total = Convert.ToInt32(r["proposed_total"]),
                created_at = Convert.ToString(r["created_at"]),
                updated_at = Convert.ToString(r["updated_at"])
            });

        ApiHelper.Success(Response, new { requests = items, pagination = Paged(page, limit, total) },
            "Mark correction requests");
    }

    /// <summary>Where a request has got to, in words a student can act on. The status column names
    /// the desk it is sitting on; this says what that means.</summary>
    private static string StageOf(string status)
    {
        switch ((status ?? "").ToUpperInvariant())
        {
            case "PENDING_LECTURER":   return "With the lecturer who taught the course";
            case "PENDING_SUPERVISOR": return "With the Head of Department";
            case "PENDING_ADMIN":      return "With the Academic Registrar";
            case "APPROVED":           return "Approved — the mark has been corrected";
            case "REJECTED":           return "Rejected";
            case "CANCELLED":          return "Withdrawn by you";
            default:                   return status ?? "";
        }
    }

    private static bool IsOpen(string status)
    {
        string s = (status ?? "").ToUpperInvariant();
        return s == "PENDING_LECTURER" || s == "PENDING_SUPERVISOR" || s == "PENDING_ADMIN";
    }

    private void HandleMarkDetail()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        DataTable dt = ApiHelper.QueryPortal(
            "SELECT r.*, IFNULL(c.courseName,'') AS course_name " +
            "FROM acad_marks_requests r " +
            "LEFT JOIN campus_dynamics.acad_course c ON TRIM(c.courseID)=TRIM(r.course_id) " +
            "WHERE r.id=@i AND TRIM(r.regno)=@r LIMIT 1",
            new MySqlParameter("@i", id), new MySqlParameter("@r", regno));

        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "That request was not found.", "NOT_FOUND"); return; }
        DataRow x = dt.Rows[0];

        // The trail, in the order it happened, so an app can draw a timeline.
        var trail = new List<object>();
        trail.Add(new { stage = "Raised by you", at = Fmt(x["created_at"]), note = Str(x["student_reason"]) });
        if (Str(x["lecturer_response"]) != "" || x["lecturer_responded_at"] != DBNull.Value)
            trail.Add(new { stage = "Lecturer", at = Fmt(x["lecturer_responded_at"]), note = Str(x["lecturer_response"]) });
        if (Str(x["supervisor_response"]) != "" || x["supervisor_responded_at"] != DBNull.Value)
            trail.Add(new { stage = "Head of Department", at = Fmt(x["supervisor_responded_at"]), note = Str(x["supervisor_response"]) });
        if (Str(x["admin_response"]) != "" || x["admin_responded_at"] != DBNull.Value)
            trail.Add(new { stage = "Academic Registrar", at = Fmt(x["admin_responded_at"]), note = Str(x["admin_response"]) });

        ApiHelper.Success(Response, new
        {
            id = Convert.ToInt32(x["id"]),
            course_code = Str(x["course_id"]),
            course_name = Str(x["course_name"]),
            acad_year = Str(x["acad_year"]),
            semester = x["semester"] == DBNull.Value ? 0 : Convert.ToInt32(x["semester"]),
            request_type = Str(x["request_type"]),
            status = Str(x["status"]),
            stage = StageOf(Str(x["status"])),
            is_open = IsOpen(Str(x["status"])),
            student_reason = Str(x["student_reason"]),
            proposed = new
            {
                course_work = x["proposed_cw"] == DBNull.Value ? 0 : Convert.ToInt32(x["proposed_cw"]),
                exam = x["proposed_exam"] == DBNull.Value ? 0 : Convert.ToInt32(x["proposed_exam"]),
                total = x["proposed_total"] == DBNull.Value ? 0 : Convert.ToInt32(x["proposed_total"])
            },
            created_at = Fmt(x["created_at"]),
            updated_at = Fmt(x["updated_at"]),
            trail = trail
        }, "Mark correction request");
    }

    private static string Str(object o) { return o == null || o == DBNull.Value ? "" : Convert.ToString(o).Trim(); }
    private static string Fmt(object o)
    {
        if (o == null || o == DBNull.Value) return "";
        try { return Convert.ToDateTime(o).ToString("yyyy-MM-dd HH:mm"); } catch { return Convert.ToString(o); }
    }

    private void HandleSubmitMark()
    {
        TokenInfo auth; string regno = MeForWrite(out auth); if (regno == null) return;

        int courseRegId = ApiHelper.ParamInt(Request, "course_reg_id", 0);
        string type = ApiHelper.Param(Request, "request_type", "MISSING_MARK").Trim().ToUpperInvariant();
        string reason = ApiHelper.Param(Request, "reason", "").Trim();
        int lecturerId = ApiHelper.ParamInt(Request, "assigned_lecturer_id", 0);

        if (courseRegId <= 0) { ApiHelper.Error(Response, "course_reg_id is required — the registration the mark belongs to.", "MISSING_PARAM"); return; }
        if (type != "MISSING_MARK" && type != "MARK_CHANGE")
        { ApiHelper.Error(Response, "request_type must be MISSING_MARK or MARK_CHANGE.", "BAD_PARAM"); return; }
        if (reason.Length < 10)
        { ApiHelper.Error(Response, "Say what is wrong, in at least 10 characters. It is read by the lecturer.", "REASON_TOO_SHORT"); return; }
        if (reason.Length > 2000) reason = reason.Substring(0, 2000);

        // The registration must be the student's own. This is the check that stops a caller
        // raising a request against someone else's mark by guessing an id.
        DataTable reg = ApiHelper.QueryPortal(
            "SELECT ID, TRIM(courseID) AS course_id, acad_year, semester FROM acad_course_registration " +
            "WHERE ID=@i AND TRIM(regno)=@r LIMIT 1",
            new MySqlParameter("@i", courseRegId), new MySqlParameter("@r", regno));
        if (reg.Rows.Count == 0)
        { ApiHelper.Error(Response, "That course registration is not yours, or does not exist.", "NOT_YOURS"); return; }

        string courseId = Str(reg.Rows[0]["course_id"]);
        string acadYear = Str(reg.Rows[0]["acad_year"]);
        int semester = reg.Rows[0]["semester"] == DBNull.Value ? 0 : Convert.ToInt32(reg.Rows[0]["semester"]);

        // One open request per registration — raising a second while the first is still moving
        // just gives two desks the same question.
        object dup = ApiHelper.ScalarPortal(
            "SELECT COUNT(*) FROM acad_marks_requests WHERE TRIM(regno)=@r AND course_reg_id=@c " +
            "AND status IN ('PENDING_LECTURER','PENDING_SUPERVISOR','PENDING_ADMIN')",
            new MySqlParameter("@r", regno), new MySqlParameter("@c", courseRegId));
        if (dup != null && Convert.ToInt32(dup) > 0)
        { ApiHelper.Error(Response, "You already have an open request for this course. Wait for it to be decided.", "ALREADY_OPEN"); return; }

        long id = ApiHelper.ExecuteInsertPortal(
            "INSERT INTO acad_marks_requests (regno, course_reg_id, course_id, acad_year, semester, " +
            " request_type, student_reason, status, assigned_lecturer_id, created_at, updated_at) " +
            "VALUES (@r,@creg,@cid,@ay,@sem,@t,@reason,'PENDING_LECTURER',@lec,NOW(),NOW())",
            new MySqlParameter("@r", regno), new MySqlParameter("@creg", courseRegId),
            new MySqlParameter("@cid", courseId), new MySqlParameter("@ay", acadYear),
            new MySqlParameter("@sem", semester), new MySqlParameter("@t", type),
            new MySqlParameter("@reason", reason),
            new MySqlParameter("@lec", lecturerId > 0 ? (object)lecturerId : DBNull.Value));

        ApiHelper.Success(Response, new
        {
            id = id,
            course_code = courseId,
            status = "PENDING_LECTURER",
            stage = StageOf("PENDING_LECTURER")
        }, "Request raised. It is now with the lecturer who taught the course.");
    }

    private void HandleCancelMark()
    {
        TokenInfo auth; string regno = MeForWrite(out auth); if (regno == null) return;
        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        // Only while it is still with the lecturer: once a Head of Department or the Registrar
        // has it, withdrawing it would erase a decision in progress.
        int n = ApiHelper.ExecutePortal(
            "UPDATE acad_marks_requests SET status='CANCELLED', updated_at=NOW() " +
            "WHERE id=@i AND TRIM(regno)=@r AND status='PENDING_LECTURER'",
            new MySqlParameter("@i", id), new MySqlParameter("@r", regno));

        if (n == 0)
        {
            ApiHelper.Error(Response,
                "That request could not be withdrawn — it is not yours, or it has already moved past the lecturer.",
                "CANNOT_CANCEL");
            return;
        }
        ApiHelper.Success(Response, new { id = id, status = "CANCELLED" }, "Request withdrawn.");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  COURSE REMOVAL REQUESTS
    // ═══════════════════════════════════════════════════════════════════

    private void HandleCourseRemovals()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;
        int page = Page1(Request), limit = Limit(Request);

        object totalObj = ApiHelper.ScalarPortal(
            "SELECT COUNT(*) FROM acad_course_deletion_requests WHERE TRIM(regno)=@r",
            new MySqlParameter("@r", regno));
        int total = totalObj == null ? 0 : Convert.ToInt32(totalObj);

        DataTable dt = ApiHelper.QueryPortal(
            "SELECT id, TRIM(course_id) AS course_code, IFNULL(course_name,'') AS course_name, " +
            "  acad_year, study_year, semester, IFNULL(had_marks,0) AS had_marks, " +
            "  IFNULL(published_score,0) AS published_score, IFNULL(published_grade,'') AS published_grade, " +
            "  IFNULL(request_reason,'') AS request_reason, status, IFNULL(admin_comment,'') AS admin_comment, " +
            "  DATE_FORMAT(created_at,'%Y-%m-%d %H:%i') AS created_at, " +
            "  IFNULL(DATE_FORMAT(decided_at,'%Y-%m-%d %H:%i'),'') AS decided_at " +
            "FROM acad_course_deletion_requests WHERE TRIM(regno)=@r " +
            "ORDER BY id DESC LIMIT " + limit + " OFFSET " + ((page - 1) * limit),
            new MySqlParameter("@r", regno));

        var items = new List<object>();
        foreach (DataRow r in dt.Rows)
            items.Add(new
            {
                id = Convert.ToInt32(r["id"]),
                course_code = Str(r["course_code"]),
                course_name = Str(r["course_name"]),
                acad_year = Str(r["acad_year"]),
                study_year = r["study_year"] == DBNull.Value ? 0 : Convert.ToInt32(r["study_year"]),
                semester = r["semester"] == DBNull.Value ? 0 : Convert.ToInt32(r["semester"]),
                had_marks = Convert.ToInt32(r["had_marks"]) == 1,
                published_score = Convert.ToInt32(r["published_score"]),
                published_grade = Str(r["published_grade"]),
                request_reason = Str(r["request_reason"]),
                status = Str(r["status"]),
                is_open = string.Equals(Str(r["status"]), "PENDING", StringComparison.OrdinalIgnoreCase),
                admin_comment = Str(r["admin_comment"]),
                created_at = Str(r["created_at"]),
                decided_at = Str(r["decided_at"])
            });

        ApiHelper.Success(Response, new { requests = items, pagination = Paged(page, limit, total) },
            "Course removal requests");
    }

    private void HandleSubmitCourseRemoval()
    {
        TokenInfo auth; string regno = MeForWrite(out auth); if (regno == null) return;

        int courseRegId = ApiHelper.ParamInt(Request, "course_reg_id", 0);
        string reason = ApiHelper.Param(Request, "reason", "").Trim();
        if (courseRegId <= 0) { ApiHelper.Error(Response, "course_reg_id is required.", "MISSING_PARAM"); return; }
        if (reason.Length < 10)
        { ApiHelper.Error(Response, "Say why this course should be removed, in at least 10 characters.", "REASON_TOO_SHORT"); return; }
        if (reason.Length > 2000) reason = reason.Substring(0, 2000);

        DataTable reg = ApiHelper.QueryPortal(
            "SELECT cr.ID, TRIM(cr.courseID) AS course_code, cr.acad_year, cr.semester, cr.prog_id, " +
            "  IFNULL(cr.provisional_course_work_marks,0) AS cw, IFNULL(cr.provisional_exam_marks,0) AS exam, " +
            "  IFNULL(cr.provisional_total_marks,0) AS total, IFNULL(cr.mark_stage,'') AS mark_stage, " +
            "  IFNULL(c.courseName,'') AS course_name " +
            "FROM acad_course_registration cr " +
            "LEFT JOIN campus_dynamics.acad_course c ON TRIM(c.courseID)=TRIM(cr.courseID) " +
            "WHERE cr.ID=@i AND TRIM(cr.regno)=@r LIMIT 1",
            new MySqlParameter("@i", courseRegId), new MySqlParameter("@r", regno));
        if (reg.Rows.Count == 0)
        { ApiHelper.Error(Response, "That course registration is not yours, or does not exist.", "NOT_YOURS"); return; }

        DataRow g = reg.Rows[0];

        object dup = ApiHelper.ScalarPortal(
            "SELECT COUNT(*) FROM acad_course_deletion_requests WHERE TRIM(regno)=@r AND course_reg_id=@c AND status='PENDING'",
            new MySqlParameter("@r", regno), new MySqlParameter("@c", courseRegId));
        if (dup != null && Convert.ToInt32(dup) > 0)
        { ApiHelper.Error(Response, "You already have a pending removal request for this course.", "ALREADY_OPEN"); return; }

        int total = Convert.ToInt32(g["total"]);
        bool hadMarks = total > 0;

        // The student's own name and programme are recorded on the request because the eadmin
        // console lists them without joining back — same as the portal writes it.
        DataTable stu = ApiHelper.Query(
            "SELECT TRIM(CONCAT(IFNULL(firstname,''),' ',IFNULL(othername,''))) AS nm, IFNULL(progid,'') AS prog " +
            "FROM acad_student WHERE TRIM(regno)=@r LIMIT 1", new MySqlParameter("@r", regno));
        string nm = stu.Rows.Count > 0 ? Str(stu.Rows[0]["nm"]) : "";
        string prog = stu.Rows.Count > 0 ? Str(stu.Rows[0]["prog"]) : Str(g["prog_id"]);

        long id = ApiHelper.ExecuteInsertPortal(
            "INSERT INTO acad_course_deletion_requests (regno, student_name, programme_code, course_reg_id, " +
            " course_id, course_name, acad_year, study_year, semester, had_marks, cw_marks, exam_marks, " +
            " total_marks, mark_stage, request_reason, status, created_at, updated_at) " +
            "VALUES (@r,@nm,@prog,@creg,@cid,@cname,@ay,@sy,@sem,@had,@cw,@ex,@tot,@stage,@reason,'PENDING',NOW(),NOW())",
            new MySqlParameter("@r", regno), new MySqlParameter("@nm", nm), new MySqlParameter("@prog", prog),
            new MySqlParameter("@creg", courseRegId), new MySqlParameter("@cid", Str(g["course_code"])),
            new MySqlParameter("@cname", Str(g["course_name"])), new MySqlParameter("@ay", Str(g["acad_year"])),
            new MySqlParameter("@sy", 0), new MySqlParameter("@sem", g["semester"] == DBNull.Value ? 0 : Convert.ToInt32(g["semester"])),
            new MySqlParameter("@had", hadMarks ? 1 : 0), new MySqlParameter("@cw", Convert.ToInt32(g["cw"])),
            new MySqlParameter("@ex", Convert.ToInt32(g["exam"])), new MySqlParameter("@tot", total),
            new MySqlParameter("@stage", Str(g["mark_stage"])), new MySqlParameter("@reason", reason));

        ApiHelper.Success(Response, new
        {
            id = id,
            course_code = Str(g["course_code"]),
            had_marks = hadMarks,
            status = "PENDING"
        }, hadMarks
            ? "Request raised. This course already carries marks, so the Registrar will look at it closely."
            : "Request raised. It is with the Academic Registrar.");
    }

    private void HandleCancelCourseRemoval()
    {
        TokenInfo auth; string regno = MeForWrite(out auth); if (regno == null) return;
        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        int n = ApiHelper.ExecutePortal(
            "UPDATE acad_course_deletion_requests SET status='CANCELLED', updated_at=NOW() " +
            "WHERE id=@i AND TRIM(regno)=@r AND status='PENDING'",
            new MySqlParameter("@i", id), new MySqlParameter("@r", regno));

        if (n == 0)
        { ApiHelper.Error(Response, "That request could not be withdrawn — it is not yours, or it has already been decided.", "CANNOT_CANCEL"); return; }
        ApiHelper.Success(Response, new { id = id, status = "CANCELLED" }, "Request withdrawn.");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  RETAKES
    // ═══════════════════════════════════════════════════════════════════

    private void HandleRetakes()
    {
        TokenInfo auth; string regno = Me(out auth); if (regno == null) return;

        // Already registered.
        DataTable mine = ApiHelper.QueryPortal(
            "SELECT ID, TRIM(courseID) AS course_code, IFNULL(course_name,'') AS course_name, " +
            "  IFNULL(credit_units,0) AS credit_units, retake_acad_year, retake_semester, retake_study_year, " +
            "  IFNULL(attempt_no,1) AS attempt_no, IFNULL(retake_fee,0) AS retake_fee, " +
            "  IFNULL(fee_billed,'No') AS fee_billed, IFNULL(status,'') AS status, " +
            "  IFNULL(orig_total,0) AS original_total, IFNULL(orig_grade,'') AS original_grade, " +
            "  IFNULL(new_total,0) AS new_total, IFNULL(new_grade,'') AS new_grade, " +
            "  IFNULL(DATE_FORMAT(registered_at,'%Y-%m-%d %H:%i'),'') AS registered_at " +
            "FROM acad_retake_registrations WHERE TRIM(regno)=@r ORDER BY ID DESC",
            new MySqlParameter("@r", regno));

        var registered = new List<object>();
        var already = new List<string>();
        foreach (DataRow r in mine.Rows)
        {
            string code = Str(r["course_code"]);
            already.Add(code.ToUpperInvariant());
            registered.Add(new
            {
                id = Convert.ToInt32(r["ID"]),
                course_code = code,
                course_name = Str(r["course_name"]),
                credit_units = Convert.ToDouble(r["credit_units"]),
                acad_year = Str(r["retake_acad_year"]),
                semester = r["retake_semester"] == DBNull.Value ? 0 : Convert.ToInt32(r["retake_semester"]),
                study_year = r["retake_study_year"] == DBNull.Value ? 0 : Convert.ToInt32(r["retake_study_year"]),
                attempt_no = Convert.ToInt32(r["attempt_no"]),
                retake_fee = Convert.ToDouble(r["retake_fee"]),
                fee_billed = string.Equals(Str(r["fee_billed"]), "Yes", StringComparison.OrdinalIgnoreCase),
                status = Str(r["status"]),
                original = new { total = Convert.ToInt32(r["original_total"]), grade = Str(r["original_grade"]) },
                outcome = new { total = Convert.ToInt32(r["new_total"]), grade = Str(r["new_grade"]) },
                registered_at = Str(r["registered_at"])
            });
        }

        // Eligible = a failed published result. F is the only failing grade on the MRU scale;
        // the score is checked too so a row with a missing grade still counts.
        DataTable fails = ApiHelper.Query(
            "SELECT r.ID AS result_id, TRIM(r.courseid) AS course_code, IFNULL(c.courseName,'') AS course_name, " +
            "  IFNULL(r.CreditUnits, IFNULL(c.CreditUnit,0)) AS credit_units, r.acad, r.semester, r.studyyear, " +
            "  IFNULL(r.score,0) AS score, IFNULL(r.grade,'') AS grade, IFNULL(r.gradept,0) AS gradept " +
            "FROM acad_results r LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(r.courseid) " +
            "WHERE TRIM(r.regno)=@r AND (UPPER(IFNULL(r.grade,''))='F' OR IFNULL(r.score,0) < 50) " +
            "ORDER BY r.acad, r.semester, r.courseid",
            new MySqlParameter("@r", regno));

        var eligible = new List<object>();
        foreach (DataRow r in fails.Rows)
        {
            string code = Str(r["course_code"]);
            eligible.Add(new
            {
                result_id = Convert.ToInt32(r["result_id"]),
                course_code = code,
                course_name = Str(r["course_name"]),
                credit_units = r["credit_units"] == DBNull.Value ? 0 : Convert.ToDouble(r["credit_units"]),
                failed_in = new
                {
                    acad_year = Str(r["acad"]),
                    semester = r["semester"] == DBNull.Value ? 0 : Convert.ToInt32(r["semester"]),
                    study_year = r["studyyear"] == DBNull.Value ? 0 : Convert.ToInt32(r["studyyear"])
                },
                score = Convert.ToInt32(r["score"]),
                grade = Str(r["grade"]),
                already_registered = already.Contains(code.ToUpperInvariant())
            });
        }

        ApiHelper.Success(Response, new
        {
            eligible_courses = eligible,
            registered_retakes = registered,
            eligible_count = eligible.Count,
            registered_count = registered.Count
        }, "Retakes");
    }

    private void HandleRegisterRetake()
    {
        TokenInfo auth; string regno = MeForWrite(out auth); if (regno == null) return;

        string courseCode = ApiHelper.Param(Request, "course_code", "").Trim();
        string acadYear = ApiHelper.Param(Request, "acad_year", "").Trim();
        int semester = ApiHelper.ParamInt(Request, "semester", 0);

        if (courseCode == "") { ApiHelper.Error(Response, "course_code is required.", "MISSING_PARAM"); return; }
        if (acadYear == "" || semester <= 0)
        { ApiHelper.Error(Response, "acad_year and semester are required — the term you will sit the retake in.", "MISSING_PARAM"); return; }
        if (!ApiHelper.ValidateAcadYear(acadYear, Response)) return;

        // It must be a course this student actually failed. Re-derived here rather than trusted,
        // because a retake carries a fee and a second attempt at a mark.
        DataTable f = ApiHelper.Query(
            "SELECT r.ID AS result_id, TRIM(r.courseid) AS course_code, IFNULL(c.courseName,'') AS course_name, " +
            "  IFNULL(r.CreditUnits, IFNULL(c.CreditUnit,0)) AS credit_units, r.acad, r.semester, r.studyyear, " +
            "  IFNULL(r.score,0) AS score, IFNULL(r.grade,'') AS grade, IFNULL(r.gradept,0) AS gradept, " +
            "  IFNULL(r.progid,'') AS prog_id " +
            "FROM acad_results r LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(r.courseid) " +
            "WHERE TRIM(r.regno)=@r AND UPPER(TRIM(r.courseid))=UPPER(@c) " +
            "  AND (UPPER(IFNULL(r.grade,''))='F' OR IFNULL(r.score,0) < 50) LIMIT 1",
            new MySqlParameter("@r", regno), new MySqlParameter("@c", courseCode));

        if (f.Rows.Count == 0)
        {
            ApiHelper.Error(Response,
                "There is no failed result for that course on your record, so there is nothing to retake.",
                "NOT_ELIGIBLE");
            return;
        }
        DataRow g = f.Rows[0];

        object dup = ApiHelper.ScalarPortal(
            "SELECT COUNT(*) FROM acad_retake_registrations WHERE TRIM(regno)=@r AND UPPER(TRIM(courseID))=UPPER(@c) " +
            "AND retake_acad_year=@ay AND retake_semester=@sem",
            new MySqlParameter("@r", regno), new MySqlParameter("@c", courseCode),
            new MySqlParameter("@ay", acadYear), new MySqlParameter("@sem", semester));
        if (dup != null && Convert.ToInt32(dup) > 0)
        { ApiHelper.Error(Response, "You have already registered this retake for that term.", "ALREADY_REGISTERED"); return; }

        object attemptObj = ApiHelper.ScalarPortal(
            "SELECT IFNULL(MAX(attempt_no),1) FROM acad_retake_registrations WHERE TRIM(regno)=@r AND UPPER(TRIM(courseID))=UPPER(@c)",
            new MySqlParameter("@r", regno), new MySqlParameter("@c", courseCode));
        int attempt = attemptObj == null ? 2 : Convert.ToInt32(attemptObj) + 1;

        long id = ApiHelper.ExecuteInsertPortal(
            "INSERT INTO acad_retake_registrations (regno, courseID, course_name, prog_id, credit_units, " +
            " retake_acad_year, retake_semester, retake_study_year, orig_acad_year, orig_semester, orig_study_year, " +
            " orig_total, orig_grade, orig_gradept, orig_result_id, attempt_no, fee_billed, status, registered_by, registered_at) " +
            "VALUES (@r,@c,@cn,@p,@cu,@ay,@sem,@sy,@oay,@osem,@osy,@ot,@og,@ogp,@orid,@att,'No','REGISTERED',@by,NOW())",
            new MySqlParameter("@r", regno), new MySqlParameter("@c", Str(g["course_code"])),
            new MySqlParameter("@cn", Str(g["course_name"])), new MySqlParameter("@p", Str(g["prog_id"])),
            new MySqlParameter("@cu", g["credit_units"] == DBNull.Value ? 0 : Convert.ToDouble(g["credit_units"])),
            new MySqlParameter("@ay", acadYear), new MySqlParameter("@sem", semester),
            new MySqlParameter("@sy", g["studyyear"] == DBNull.Value ? 0 : Convert.ToInt32(g["studyyear"])),
            new MySqlParameter("@oay", Str(g["acad"])),
            new MySqlParameter("@osem", g["semester"] == DBNull.Value ? 0 : Convert.ToInt32(g["semester"])),
            new MySqlParameter("@osy", g["studyyear"] == DBNull.Value ? 0 : Convert.ToInt32(g["studyyear"])),
            new MySqlParameter("@ot", Convert.ToInt32(g["score"])), new MySqlParameter("@og", Str(g["grade"])),
            new MySqlParameter("@ogp", g["gradept"] == DBNull.Value ? 0 : Convert.ToDouble(g["gradept"])),
            new MySqlParameter("@orid", Convert.ToInt32(g["result_id"])), new MySqlParameter("@att", attempt),
            new MySqlParameter("@by", regno));

        ApiHelper.Success(Response, new
        {
            id = id,
            course_code = Str(g["course_code"]),
            course_name = Str(g["course_name"]),
            acad_year = acadYear,
            semester = semester,
            attempt_no = attempt,
            fee_billed = false,
            status = "REGISTERED"
        }, "Retake registered. The retake fee is billed separately by the Bursar.");
    }
}
