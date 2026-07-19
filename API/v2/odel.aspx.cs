using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// API v2 — ODEL (Online Distance E-Learning) module.
/// Powers student learning + lecturer teaching frontends. All odel_* tables live in
/// campus_dynamics_portal (ApiHelper.*Portal helpers); academic tables are reached
/// cross-DB via the campus_dynamics. prefix. Auth = token (TokenManager.RequireAuth).
/// See ODEL_API_MASTER_PLAN.md for the full contract.
/// </summary>
public partial class API_v2_odel : System.Web.UI.Page
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
                // ── student ──
                case "my_learning":      HandleMyLearning();      break;
                case "space":            HandleSpace();           break;
                case "assignment":       HandleAssignment();      break;
                case "dashboard":        HandleStudentDashboard(); break;
                case "lectures":         HandleStudentLectures(); break;
                case "updates":          HandleStudentUpdates();  break;
                case "attendance":       HandleStudentAttendance(); break;
                case "submit_autosave":  HandleSubmitAutosave();  break;
                case "submit_finalize":  HandleSubmitFinalize();  break;
                case "mark_update_read": HandleMarkUpdateRead();  break;
                case "self_checkin":     HandleSelfCheckin();     break;
                // ── lecturer ──
                case "teaching_spaces":   HandleTeachingSpaces();   break;
                case "course_dashboard":  HandleCourseDashboard();  break;
                case "roster":            HandleRoster();           break;
                case "assignments":       HandleAssignments();      break;
                case "assignment_students": HandleAssignmentStudents(); break;
                case "grading_queue":     HandleGradingQueue();     break;
                case "lecture_list":      HandleLectureList();      break;
                case "roll_roster":       HandleRollRoster();       break;
                case "attendance_summary": HandleAttendanceSummary(); break;
                case "update_list":       HandleUpdateList();       break;
                case "save_grade":        HandleSaveGrade();        break;
                case "update_save":       HandleUpdateSave();       break;
                case "update_delete":     HandleUpdateDelete();     break;
                case "mark_attendance":   HandleMarkAttendance();   break;
                case "lecture_set_status": HandleLectureSetStatus(); break;
                case "ping":              HandlePing();             break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". See /API/v2/docs.aspx for the ODEL action list.",
                        "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════ shared helpers ═══════════════════════

    /// <summary>Resolves a staff login username to hrm_employee.empID (0 if not staff).</summary>
    private static int StaffEmpId(string username)
    {
        object o = ApiHelper.Scalar(
            @"SELECT empID FROM hrm_employee
              WHERE UPPER(TRIM(usernames))=UPPER(TRIM(@u)) OR UPPER(TRIM(EMP_CODE))=UPPER(TRIM(@u)) OR TRIM(emp_email)=TRIM(@u)
              ORDER BY empID LIMIT 1",
            new MySqlParameter("@u", username ?? ""));
        return (o == null || o == DBNull.Value) ? 0 : Convert.ToInt32(o);
    }

    /// <summary>Per-space authorization: empid is a space staff member OR the assigned lecturer of the course.</summary>
    private static bool StaffOnSpace(long spaceId, int empid)
    {
        object o = ApiHelper.ScalarPortal(
            @"SELECT 1 FROM odel_course_space sp
              WHERE sp.id=@sid AND (
                    EXISTS(SELECT 1 FROM odel_space_staff ss WHERE ss.space_id=sp.id AND ss.empid=@e)
                 OR EXISTS(SELECT 1 FROM campus_dynamics.acad_programmecourses pc
                           WHERE TRIM(pc.course_code)=TRIM(sp.courseID) AND pc.semester=sp.semester AND pc.lecturer_id=@e))
              LIMIT 1",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@e", empid));
        return o != null && o != DBNull.Value;
    }

    /// <summary>Requires a staff caller; returns their empID or -1 (after emitting an error) on failure.</summary>
    private int RequireStaff(TokenInfo auth)
    {
        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This action requires a staff/lecturer account.", "ACCESS_DENIED");
            return -1;
        }
        int empid = StaffEmpId(auth.UserId);
        if (empid == 0)
        {
            ApiHelper.Error(Response, "Signed-in user is not a recognised staff member.", "NOT_FOUND");
            return -1;
        }
        return empid;
    }

    /// <summary>Requires the staff caller to own/teach the space; returns empID or -1 (after error).</summary>
    private int RequireStaffOnSpace(TokenInfo auth, long spaceId)
    {
        int empid = RequireStaff(auth);
        if (empid < 0) return -1;
        if (!StaffOnSpace(spaceId, empid))
        {
            ApiHelper.Error(Response, "You do not teach this course space.", "ACCESS_DENIED");
            return -1;
        }
        return empid;
    }

    /// <summary>True if the student (regno) is APPROVED-enrolled in the course behind this space.</summary>
    private static bool StudentOnSpace(long spaceId, string regno)
    {
        object o = ApiHelper.ScalarPortal(
            @"SELECT 1 FROM odel_course_space sp
              JOIN acad_course_registration cr
                ON TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester
              WHERE sp.id=@sid AND TRIM(cr.regno)=TRIM(@r)
                AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))<>'REMOVED'
              LIMIT 1",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@r", regno));
        return o != null && o != DBNull.Value;
    }

    private static Dictionary<string, object> Page(int page, int limit, long total)
    {
        return new Dictionary<string, object> {
            { "page", page }, { "limit", limit }, { "total", total },
            { "total_pages", limit > 0 ? (int)Math.Ceiling((double)total / limit) : 1 }
        };
    }

    // ═══════════════════════ STUDENT ═══════════════════════

    /// <summary>action=my_learning — the student's online course spaces (approved enrolments).</summary>
    private void HandleMyLearning()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        string regno = auth.UserType == "staff" ? ApiHelper.Param(Request, "regno", "") : auth.UserId;
        if (string.IsNullOrEmpty(regno)) { ApiHelper.Error(Response, "regno is required for staff callers.", "MISSING_PARAM"); return; }

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT sp.id AS space_id, TRIM(sp.courseID) AS course_code, TRIM(IFNULL(c.courseName, sp.courseID)) AS course_name,
                     sp.acad_year, sp.semester, sp.title, sp.status,
                     UPPER(IFNULL(cr.lecturer_status,'APPROVED')) AS enrolment_status,
                     IFNULL(e.emp_name,'') AS lecturer,
                     (SELECT COUNT(*) FROM odel_assignment a WHERE a.space_id=sp.id AND a.is_published=1 AND a.archived_at IS NULL) AS assignments,
                     (SELECT COUNT(*) FROM odel_topic_material tm JOIN odel_topic t ON t.id=tm.topic_id
                        WHERE t.space_id=sp.id AND tm.is_published=1) AS materials,
                     IFNULL((SELECT gb.odel_points FROM odel_gradebook gb WHERE gb.space_id=sp.id AND TRIM(gb.regno)=TRIM(cr.regno)),0) AS odel_points
              FROM acad_course_registration cr
              JOIN odel_course_space sp
                ON TRIM(sp.courseID)=TRIM(cr.courseID) AND sp.acad_year=cr.acad_year AND sp.semester=cr.semester
              LEFT JOIN campus_dynamics.acad_course c ON TRIM(c.courseID)=TRIM(sp.courseID)
              LEFT JOIN campus_dynamics.hrm_employee e ON e.empID=sp.owner_empid
              WHERE TRIM(cr.regno)=TRIM(@r) AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))<>'REMOVED'
              GROUP BY sp.id
              ORDER BY sp.acad_year DESC, sp.semester DESC, course_name",
            new MySqlParameter("@r", regno));

        var active = new List<Dictionary<string, object>>();
        var pending = new List<Dictionary<string, object>>();
        foreach (var row in ApiHelper.TableToList(dt))
        {
            string es = Convert.ToString(row["enrolment_status"]);
            string st = Convert.ToString(row["status"]);
            if (es == "APPROVED" && st != "DRAFT") active.Add(row); else pending.Add(row);
        }
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "regno", regno },
            { "active_courses", active },
            { "pending_courses", pending },
            { "active_count", active.Count }, { "pending_count", pending.Count }
        });
    }

    /// <summary>action=space — full space view: chapters›topics›materials + assignments with the student's status.</summary>
    private void HandleSpace()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }

        bool isStudent = auth.UserType == "student";
        string regno = isStudent ? auth.UserId : ApiHelper.Param(Request, "regno", "");
        if (isStudent && !StudentOnSpace(spaceId, regno)) { ApiHelper.Error(Response, "You are not enrolled in this course space.", "ACCESS_DENIED"); return; }
        if (!isStudent && RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable spDt = ApiHelper.QueryPortal(
            @"SELECT sp.id AS space_id, TRIM(sp.courseID) AS course_code, TRIM(IFNULL(c.courseName,sp.courseID)) AS course_name,
                     sp.acad_year, sp.semester, sp.title, sp.status, sp.default_meet_link, IFNULL(e.emp_name,'') AS lecturer
              FROM odel_course_space sp
              LEFT JOIN campus_dynamics.acad_course c ON TRIM(c.courseID)=TRIM(sp.courseID)
              LEFT JOIN campus_dynamics.hrm_employee e ON e.empID=sp.owner_empid
              WHERE sp.id=@sid",
            new MySqlParameter("@sid", spaceId));
        if (spDt.Rows.Count == 0) { ApiHelper.Error(Response, "Course space not found.", "NOT_FOUND"); return; }

        // chapters › topics › materials
        DataTable chapters = ApiHelper.QueryPortal(
            "SELECT id AS chapter_id, title, sort_order, is_published FROM odel_chapter WHERE space_id=@sid AND is_published=1 ORDER BY sort_order, id",
            new MySqlParameter("@sid", spaceId));
        DataTable topics = ApiHelper.QueryPortal(
            "SELECT id AS topic_id, chapter_id, title, sort_order, is_published FROM odel_topic WHERE space_id=@sid AND is_published=1 ORDER BY sort_order, id",
            new MySqlParameter("@sid", spaceId));
        DataTable mats = ApiHelper.QueryPortal(
            @"SELECT tm.topic_id, tm.id AS link_id, tm.sort_order, m.id AS material_id, m.title, m.kind, m.url, m.description, m.file_id,
                     IFNULL(f.orig_name,'') AS file_name, IFNULL(f.mime,'') AS file_mime
              FROM odel_topic_material tm
              JOIN odel_topic t ON t.id=tm.topic_id
              JOIN odel_material m ON m.id=tm.material_id
              LEFT JOIN odel_file f ON f.id=m.file_id
              WHERE t.space_id=@sid AND tm.is_published=1
              ORDER BY tm.topic_id, tm.sort_order, tm.id",
            new MySqlParameter("@sid", spaceId));

        // assignments + this student's status
        DataTable asgs = ApiHelper.QueryPortal(
            @"SELECT a.id AS assignment_id, a.title, a.instructions, a.topic_id, a.open_at, a.due_at, a.late_until,
                     a.max_points, a.weight_points, a.submission_type, a.max_attempts, a.counts_toward_cw,
                     (SELECT s.status FROM odel_submission s WHERE s.assignment_id=a.id AND TRIM(s.regno)=TRIM(@r) ORDER BY s.attempt_no DESC LIMIT 1) AS my_status,
                     (SELECT sg.final_marks FROM odel_submission s JOIN odel_submission_grade sg ON sg.submission_id=s.id
                        WHERE s.assignment_id=a.id AND TRIM(s.regno)=TRIM(@r) AND sg.is_current=1 ORDER BY s.attempt_no DESC LIMIT 1) AS my_marks,
                     (SELECT COUNT(*) FROM odel_submission s WHERE s.assignment_id=a.id AND TRIM(s.regno)=TRIM(@r) AND s.status='SUBMITTED') AS my_attempts
              FROM odel_assignment a
              WHERE a.space_id=@sid AND a.is_published=1 AND a.archived_at IS NULL
              ORDER BY a.sort_order, a.due_at",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@r", regno ?? ""));

        var data = new Dictionary<string, object> {
            { "space", ApiHelper.FirstRowToDict(spDt) },
            { "chapters", ApiHelper.TableToList(chapters) },
            { "topics", ApiHelper.TableToList(topics) },
            { "materials", ApiHelper.TableToList(mats) },
            { "assignments", ApiHelper.TableToList(asgs) }
        };
        ApiHelper.Success(Response, data);
    }

    /// <summary>action=assignment — one assignment + the student's current attempt & files.</summary>
    private void HandleAssignment()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long aid = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (aid <= 0) { ApiHelper.Error(Response, "assignment_id is required.", "MISSING_PARAM"); return; }
        string regno = auth.UserType == "student" ? auth.UserId : ApiHelper.Param(Request, "regno", "");

        DataTable a = ApiHelper.QueryPortal(
            @"SELECT a.id AS assignment_id, a.space_id, a.title, a.instructions, a.topic_id, a.open_at, a.due_at, a.late_until,
                     a.max_points, a.weight_points, a.submission_type, a.max_attempts, a.late_penalty_pct, a.counts_toward_cw
              FROM odel_assignment a WHERE a.id=@a AND a.is_published=1",
            new MySqlParameter("@a", aid));
        if (a.Rows.Count == 0) { ApiHelper.Error(Response, "Assignment not found.", "NOT_FOUND"); return; }
        long spaceId = Convert.ToInt64(a.Rows[0]["space_id"]);
        if (auth.UserType == "student" && !StudentOnSpace(spaceId, regno)) { ApiHelper.Error(Response, "Not enrolled in this course.", "ACCESS_DENIED"); return; }

        DataTable sub = ApiHelper.QueryPortal(
            @"SELECT s.id AS submission_id, s.attempt_no, s.text_answer, s.status, s.submitted_at, s.is_late, s.receipt_code
              FROM odel_submission s WHERE s.assignment_id=@a AND TRIM(s.regno)=TRIM(@r) ORDER BY s.attempt_no DESC LIMIT 1",
            new MySqlParameter("@a", aid), new MySqlParameter("@r", regno ?? ""));
        Dictionary<string, object> current = ApiHelper.FirstRowToDict(sub);
        List<Dictionary<string, object>> files = new List<Dictionary<string, object>>();
        if (current != null)
        {
            DataTable fdt = ApiHelper.QueryPortal(
                @"SELECT sf.file_id, IFNULL(f.orig_name,'') AS file_name, IFNULL(f.mime,'') AS mime, IFNULL(f.size_bytes,0) AS size_bytes
                  FROM odel_submission_file sf LEFT JOIN odel_file f ON f.id=sf.file_id WHERE sf.submission_id=@s",
                new MySqlParameter("@s", current["submission_id"]));
            files = ApiHelper.TableToList(fdt);
        }
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "assignment", ApiHelper.FirstRowToDict(a) },
            { "my_submission", current },
            { "my_files", files }
        });
    }

    /// <summary>action=dashboard — cross-course student ODEL summary.</summary>
    private void HandleStudentDashboard()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "student") { ApiHelper.Error(Response, "Student account required.", "ACCESS_DENIED"); return; }
        string regno = auth.UserId;

        long spaces = ToLong(ApiHelper.ScalarPortal(
            @"SELECT COUNT(*) FROM acad_course_registration cr JOIN odel_course_space sp
                ON TRIM(sp.courseID)=TRIM(cr.courseID) AND sp.acad_year=cr.acad_year AND sp.semester=cr.semester
              WHERE TRIM(cr.regno)=TRIM(@r) AND sp.status='ACTIVE' AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED'",
            new MySqlParameter("@r", regno)));
        long liveLectures = ToLong(ApiHelper.ScalarPortal(
            @"SELECT COUNT(*) FROM odel_lecture l JOIN odel_course_space sp ON sp.id=l.space_id
              JOIN acad_course_registration cr ON TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester
              WHERE TRIM(cr.regno)=TRIM(@r) AND l.status='LIVE' AND l.is_published=1", new MySqlParameter("@r", regno)));
        long unreadUpdates = ToLong(ApiHelper.ScalarPortal(
            @"SELECT COUNT(*) FROM odel_course_update u JOIN odel_course_space sp ON sp.id=u.space_id
              JOIN acad_course_registration cr ON TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester
              WHERE TRIM(cr.regno)=TRIM(@r) AND u.is_published=1
                AND NOT EXISTS(SELECT 1 FROM odel_update_read r WHERE r.update_id=u.id AND TRIM(r.regno)=TRIM(@r))",
            new MySqlParameter("@r", regno)));
        DataTable next = ApiHelper.QueryPortal(
            @"SELECT l.id AS lecture_id, l.space_id, l.title, l.scheduled_start, l.status, l.meet_link
              FROM odel_lecture l JOIN odel_course_space sp ON sp.id=l.space_id
              JOIN acad_course_registration cr ON TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester
              WHERE TRIM(cr.regno)=TRIM(@r) AND l.is_published=1 AND l.status IN('PENDING','LIVE') AND l.scheduled_start>=NOW()-INTERVAL 2 HOUR
              ORDER BY l.scheduled_start LIMIT 1", new MySqlParameter("@r", regno));

        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "active_spaces", spaces },
            { "live_lectures", liveLectures },
            { "unread_updates", unreadUpdates },
            { "next_lecture", ApiHelper.FirstRowToDict(next) }
        });
    }

    /// <summary>action=lectures — lectures for a space (student view). param: space_id.</summary>
    private void HandleStudentLectures()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        string regno = auth.UserType == "student" ? auth.UserId : ApiHelper.Param(Request, "regno", "");
        if (auth.UserType == "student" && !StudentOnSpace(spaceId, regno)) { ApiHelper.Error(Response, "Not enrolled.", "ACCESS_DENIED"); return; }

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT l.id AS lecture_id, l.title, l.description, l.meet_link, l.meet_provider, l.location,
                     l.scheduled_start, l.scheduled_end, l.status, l.attendance_open,
                     (SELECT a.status FROM odel_attendance a WHERE a.lecture_id=l.id AND TRIM(a.regno)=TRIM(@r) LIMIT 1) AS my_attendance
              FROM odel_lecture l WHERE l.space_id=@sid AND l.is_published=1
              ORDER BY l.scheduled_start DESC",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@r", regno ?? ""));
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "lectures", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count }
        });
    }

    /// <summary>action=updates — announcements for a space + unread count (student).</summary>
    private void HandleStudentUpdates()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        string regno = auth.UserType == "student" ? auth.UserId : ApiHelper.Param(Request, "regno", "");

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT u.id AS update_id, u.title, u.body, u.pinned, u.author_name, u.created_at,
                     (SELECT 1 FROM odel_update_read r WHERE r.update_id=u.id AND TRIM(r.regno)=TRIM(@r) LIMIT 1) AS is_read
              FROM odel_course_update u WHERE u.space_id=@sid AND u.is_published=1
              ORDER BY u.pinned DESC, u.created_at DESC",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@r", regno ?? ""));
        var list = ApiHelper.TableToList(dt);
        int unread = 0; foreach (var r in list) if (r["is_read"] == null) unread++;
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "updates", list }, { "unread_count", unread }
        });
    }

    /// <summary>action=attendance — student's attendance record + rate for a space.</summary>
    private void HandleStudentAttendance()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        string regno = auth.UserType == "student" ? auth.UserId : ApiHelper.Param(Request, "regno", "");

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT l.id AS lecture_id, l.title, l.scheduled_start, l.status AS lecture_status,
                     IFNULL(a.status,'ABSENT') AS attendance, a.method, a.marked_at
              FROM odel_lecture l
              LEFT JOIN odel_attendance a ON a.lecture_id=l.id AND TRIM(a.regno)=TRIM(@r)
              WHERE l.space_id=@sid AND l.is_published=1 AND l.status='ENDED'
              ORDER BY l.scheduled_start DESC",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@r", regno ?? ""));
        var list = ApiHelper.TableToList(dt);
        int present = 0; foreach (var r in list) { string s = Convert.ToString(r["attendance"]); if (s == "PRESENT" || s == "LATE") present++; }
        double rate = list.Count > 0 ? Math.Round(present * 100.0 / list.Count, 1) : 0;
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "records", list }, { "total_lectures", list.Count }, { "attended", present }, { "attendance_rate", rate }
        });
    }

    /// <summary>action=submit_autosave — save a DRAFT text answer (write).</summary>
    private void HandleSubmitAutosave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "student") { ApiHelper.Error(Response, "Student account required.", "ACCESS_DENIED"); return; }
        long aid = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (aid <= 0) { ApiHelper.Error(Response, "assignment_id is required.", "MISSING_PARAM"); return; }
        string text = ApiHelper.Param(Request, "text", "");
        string regno = auth.UserId;

        DataTable a = ApiHelper.QueryPortal("SELECT space_id, submission_type FROM odel_assignment WHERE id=@a AND is_published=1", new MySqlParameter("@a", aid));
        if (a.Rows.Count == 0) { ApiHelper.Error(Response, "Assignment not found.", "NOT_FOUND"); return; }
        if (!StudentOnSpace(Convert.ToInt64(a.Rows[0]["space_id"]), regno)) { ApiHelper.Error(Response, "Not enrolled.", "ACCESS_DENIED"); return; }

        // upsert the current DRAFT attempt (attempt_no = max existing, or 1)
        object existing = ApiHelper.ScalarPortal("SELECT id FROM odel_submission WHERE assignment_id=@a AND TRIM(regno)=TRIM(@r) AND status='DRAFT' ORDER BY attempt_no DESC LIMIT 1",
            new MySqlParameter("@a", aid), new MySqlParameter("@r", regno));
        long subId;
        if (existing != null && existing != DBNull.Value)
        {
            subId = Convert.ToInt64(existing);
            ApiHelper.ExecutePortal("UPDATE odel_submission SET text_answer=@t, updated_at=NOW() WHERE id=@id",
                new MySqlParameter("@t", text), new MySqlParameter("@id", subId));
        }
        else
        {
            object mx = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(attempt_no),0)+1 FROM odel_submission WHERE assignment_id=@a AND TRIM(regno)=TRIM(@r)",
                new MySqlParameter("@a", aid), new MySqlParameter("@r", regno));
            int attempt = Convert.ToInt32(mx);
            subId = ApiHelper.ExecuteInsertPortal(
                "INSERT INTO odel_submission (assignment_id, regno, attempt_no, text_answer, status, updated_at) VALUES (@a,@r,@n,@t,'DRAFT',NOW())",
                new MySqlParameter("@a", aid), new MySqlParameter("@r", regno), new MySqlParameter("@n", attempt), new MySqlParameter("@t", text));
        }
        ApiHelper.Success(Response, new Dictionary<string, object> { { "submission_id", subId }, { "status", "DRAFT" } }, "Draft saved");
    }

    /// <summary>action=submit_finalize — submit the current attempt (write).</summary>
    private void HandleSubmitFinalize()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "student") { ApiHelper.Error(Response, "Student account required.", "ACCESS_DENIED"); return; }
        long aid = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (aid <= 0) { ApiHelper.Error(Response, "assignment_id is required.", "MISSING_PARAM"); return; }
        string text = ApiHelper.Param(Request, "text", "");
        string regno = auth.UserId;

        DataTable a = ApiHelper.QueryPortal("SELECT space_id, due_at, late_until, max_attempts, submission_type FROM odel_assignment WHERE id=@a AND is_published=1", new MySqlParameter("@a", aid));
        if (a.Rows.Count == 0) { ApiHelper.Error(Response, "Assignment not found.", "NOT_FOUND"); return; }
        DataRow ar = a.Rows[0];
        if (!StudentOnSpace(Convert.ToInt64(ar["space_id"]), regno)) { ApiHelper.Error(Response, "Not enrolled.", "ACCESS_DENIED"); return; }

        // window + attempt-limit checks
        int maxAttempts = ar["max_attempts"] == DBNull.Value ? 0 : Convert.ToInt32(ar["max_attempts"]);
        long usedAttempts = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_submission WHERE assignment_id=@a AND TRIM(regno)=TRIM(@r) AND status='SUBMITTED'",
            new MySqlParameter("@a", aid), new MySqlParameter("@r", regno)));
        if (maxAttempts > 0 && usedAttempts >= maxAttempts) { ApiHelper.Error(Response, "You have used all " + maxAttempts + " attempt(s).", "VALIDATION_ERROR"); return; }

        bool isLate = false;
        object closeAt = (ar["late_until"] != DBNull.Value) ? ar["late_until"] : ar["due_at"];
        object lateFlag = ApiHelper.ScalarPortal("SELECT CASE WHEN @due IS NOT NULL AND NOW()>@due THEN 1 ELSE 0 END",
            new MySqlParameter("@due", ar["due_at"] == DBNull.Value ? (object)DBNull.Value : ar["due_at"]));
        isLate = Convert.ToInt32(lateFlag) == 1;
        // hard close: reject after late_until (or due if no late window)
        if (closeAt != DBNull.Value)
        {
            object past = ApiHelper.ScalarPortal("SELECT CASE WHEN NOW()>@c THEN 1 ELSE 0 END", new MySqlParameter("@c", closeAt));
            if (Convert.ToInt32(past) == 1) { ApiHelper.Error(Response, "The submission window for this assignment has closed.", "VALIDATION_ERROR"); return; }
        }

        // finalize current draft, or create a fresh submitted attempt
        object draft = ApiHelper.ScalarPortal("SELECT id FROM odel_submission WHERE assignment_id=@a AND TRIM(regno)=TRIM(@r) AND status='DRAFT' ORDER BY attempt_no DESC LIMIT 1",
            new MySqlParameter("@a", aid), new MySqlParameter("@r", regno));
        long subId;
        string receipt = "R" + DateTime.UtcNow.ToString("yyMMddHHmmss").Substring(0, 11);
        if (draft != null && draft != DBNull.Value)
        {
            subId = Convert.ToInt64(draft);
            ApiHelper.ExecutePortal("UPDATE odel_submission SET text_answer=@t, status='SUBMITTED', submitted_at=NOW(), is_late=@l, receipt_code=@rc, updated_at=NOW() WHERE id=@id",
                new MySqlParameter("@t", text), new MySqlParameter("@l", isLate ? 1 : 0), new MySqlParameter("@rc", receipt), new MySqlParameter("@id", subId));
        }
        else
        {
            object mx = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(attempt_no),0)+1 FROM odel_submission WHERE assignment_id=@a AND TRIM(regno)=TRIM(@r)",
                new MySqlParameter("@a", aid), new MySqlParameter("@r", regno));
            subId = ApiHelper.ExecuteInsertPortal(
                "INSERT INTO odel_submission (assignment_id, regno, attempt_no, text_answer, status, submitted_at, is_late, receipt_code, updated_at) VALUES (@a,@r,@n,@t,'SUBMITTED',NOW(),@l,@rc,NOW())",
                new MySqlParameter("@a", aid), new MySqlParameter("@r", regno), new MySqlParameter("@n", Convert.ToInt32(mx)),
                new MySqlParameter("@t", text), new MySqlParameter("@l", isLate ? 1 : 0), new MySqlParameter("@rc", receipt));
        }
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "submission_id", subId }, { "status", "SUBMITTED" }, { "is_late", isLate }, { "receipt_code", receipt }
        }, "Submitted successfully");
    }

    /// <summary>action=mark_update_read — mark one (or all) announcements read (write).</summary>
    private void HandleMarkUpdateRead()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "student") { ApiHelper.Error(Response, "Student account required.", "ACCESS_DENIED"); return; }
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long updateId = ApiHelper.ParamInt(Request, "update_id", 0); // 0 = all in space
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        string regno = auth.UserId;

        int n = ApiHelper.ExecutePortal(
            @"INSERT IGNORE INTO odel_update_read (update_id, regno, read_at)
              SELECT u.id, @r, NOW() FROM odel_course_update u
              WHERE u.space_id=@sid AND u.is_published=1 AND (@uid=0 OR u.id=@uid)
                AND NOT EXISTS(SELECT 1 FROM odel_update_read x WHERE x.update_id=u.id AND TRIM(x.regno)=TRIM(@r))",
            new MySqlParameter("@r", regno), new MySqlParameter("@sid", spaceId), new MySqlParameter("@uid", updateId));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "marked_read", n } }, "Marked as read");
    }

    /// <summary>action=self_checkin — student self roll-call during an open window (write).</summary>
    private void HandleSelfCheckin()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "student") { ApiHelper.Error(Response, "Student account required.", "ACCESS_DENIED"); return; }
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        if (lectureId <= 0) { ApiHelper.Error(Response, "lecture_id is required.", "MISSING_PARAM"); return; }
        string code = ApiHelper.Param(Request, "code", "");
        string regno = auth.UserId;

        DataTable l = ApiHelper.QueryPortal(
            "SELECT space_id, attendance_open, attendance_close_at, attendance_code FROM odel_lecture WHERE id=@l", new MySqlParameter("@l", lectureId));
        if (l.Rows.Count == 0) { ApiHelper.Error(Response, "Lecture not found.", "NOT_FOUND"); return; }
        DataRow lr = l.Rows[0];
        if (!StudentOnSpace(Convert.ToInt64(lr["space_id"]), regno)) { ApiHelper.Error(Response, "Not enrolled.", "ACCESS_DENIED"); return; }
        if (Convert.ToInt32(lr["attendance_open"] == DBNull.Value ? 0 : lr["attendance_open"]) != 1)
        { ApiHelper.Error(Response, "Self check-in is not open for this lecture.", "VALIDATION_ERROR"); return; }
        if (lr["attendance_close_at"] != DBNull.Value)
        {
            object past = ApiHelper.ScalarPortal("SELECT CASE WHEN NOW()>@c THEN 1 ELSE 0 END", new MySqlParameter("@c", lr["attendance_close_at"]));
            if (Convert.ToInt32(past) == 1) { ApiHelper.Error(Response, "The check-in window has closed.", "VALIDATION_ERROR"); return; }
        }
        string reqCode = Convert.ToString(lr["attendance_code"] ?? "");
        if (!string.IsNullOrEmpty(reqCode) && !string.Equals(reqCode.Trim(), code.Trim(), StringComparison.OrdinalIgnoreCase))
        { ApiHelper.Error(Response, "Incorrect check-in code.", "VALIDATION_ERROR"); return; }

        ApiHelper.ExecutePortal(
            @"INSERT INTO odel_attendance (lecture_id, regno, status, method, marked_at)
              VALUES (@l,@r,'PRESENT','SELF',NOW())
              ON DUPLICATE KEY UPDATE status='PRESENT', method='SELF', marked_at=NOW()",
            new MySqlParameter("@l", lectureId), new MySqlParameter("@r", regno));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "lecture_id", lectureId }, { "status", "PRESENT" } }, "Checked in");
    }

    // ═══════════════════════ LECTURER ═══════════════════════

    /// <summary>action=teaching_spaces — the lecturer's course spaces with quick counts.</summary>
    private void HandleTeachingSpaces()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        int empid = RequireStaff(auth); if (empid < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT sp.id AS space_id, TRIM(sp.courseID) AS course_code, TRIM(IFNULL(c.courseName,sp.courseID)) AS course_name,
                     sp.acad_year, sp.semester, sp.title, sp.status,
                     (SELECT COUNT(*) FROM acad_course_registration cr WHERE TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED') AS roster,
                     (SELECT COUNT(*) FROM odel_assignment a WHERE a.space_id=sp.id AND a.archived_at IS NULL) AS assignments,
                     (SELECT COUNT(*) FROM odel_submission s JOIN odel_assignment a ON a.id=s.assignment_id
                        WHERE a.space_id=sp.id AND s.status='SUBMITTED'
                        AND NOT EXISTS(SELECT 1 FROM odel_submission_grade g WHERE g.submission_id=s.id AND g.is_current=1)) AS ungraded
              FROM odel_course_space sp
              LEFT JOIN campus_dynamics.acad_course c ON TRIM(c.courseID)=TRIM(sp.courseID)
              WHERE EXISTS(SELECT 1 FROM odel_space_staff ss WHERE ss.space_id=sp.id AND ss.empid=@e)
                 OR EXISTS(SELECT 1 FROM campus_dynamics.acad_programmecourses pc WHERE TRIM(pc.course_code)=TRIM(sp.courseID) AND pc.semester=sp.semester AND pc.lecturer_id=@e)
              ORDER BY sp.acad_year DESC, sp.semester DESC, course_name",
            new MySqlParameter("@e", empid));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "spaces", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=course_dashboard — one space overview for the lecturer.</summary>
    private void HandleCourseDashboard()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable sp = ApiHelper.QueryPortal(
            @"SELECT sp.id AS space_id, TRIM(sp.courseID) AS course_code, TRIM(IFNULL(c.courseName,sp.courseID)) AS course_name,
                     sp.acad_year, sp.semester, sp.title, sp.status
              FROM odel_course_space sp LEFT JOIN campus_dynamics.acad_course c ON TRIM(c.courseID)=TRIM(sp.courseID) WHERE sp.id=@sid",
            new MySqlParameter("@sid", spaceId));
        if (sp.Rows.Count == 0) { ApiHelper.Error(Response, "Space not found.", "NOT_FOUND"); return; }

        long roster = ToLong(ApiHelper.ScalarPortal(
            @"SELECT COUNT(*) FROM acad_course_registration cr JOIN odel_course_space sp ON sp.id=@sid
              WHERE TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED'",
            new MySqlParameter("@sid", spaceId)));
        long asg = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_assignment WHERE space_id=@sid AND archived_at IS NULL", new MySqlParameter("@sid", spaceId)));
        long published = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_assignment WHERE space_id=@sid AND is_published=1 AND archived_at IS NULL", new MySqlParameter("@sid", spaceId)));
        long ungraded = ToLong(ApiHelper.ScalarPortal(
            @"SELECT COUNT(*) FROM odel_submission s JOIN odel_assignment a ON a.id=s.assignment_id
              WHERE a.space_id=@sid AND s.status='SUBMITTED' AND NOT EXISTS(SELECT 1 FROM odel_submission_grade g WHERE g.submission_id=s.id AND g.is_current=1)",
            new MySqlParameter("@sid", spaceId)));
        long materials = ToLong(ApiHelper.ScalarPortal(
            "SELECT COUNT(*) FROM odel_topic_material tm JOIN odel_topic t ON t.id=tm.topic_id WHERE t.space_id=@sid AND tm.is_published=1", new MySqlParameter("@sid", spaceId)));
        long lectures = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_lecture WHERE space_id=@sid", new MySqlParameter("@sid", spaceId)));

        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "space", ApiHelper.FirstRowToDict(sp) },
            { "stats", new Dictionary<string, object> {
                { "roster", roster }, { "assignments", asg }, { "published_assignments", published },
                { "ungraded_submissions", ungraded }, { "materials", materials }, { "lectures", lectures } } }
        });
    }

    /// <summary>action=roster — enrolled students in a space (lecturer).</summary>
    private void HandleRoster()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        int page = ApiHelper.ParamInt(Request, "page", 1); if (page < 1) page = 1;
        int limit = ApiHelper.ParamInt(Request, "limit", 50); if (limit > 200) limit = 200; if (limit < 1) limit = 50;
        int offset = (page - 1) * limit;
        string q = ApiHelper.Param(Request, "q", "");

        string where = @"FROM acad_course_registration cr
              JOIN odel_course_space sp ON sp.id=@sid
              LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(cr.regno)
              WHERE TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester
                AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED'";
        var parms = new List<MySqlParameter> { new MySqlParameter("@sid", spaceId) };
        if (!string.IsNullOrEmpty(q)) { where += " AND (TRIM(cr.regno) LIKE @q OR CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) LIKE @q)"; parms.Add(new MySqlParameter("@q", "%" + q + "%")); }

        long total = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) " + where, parms.ToArray()));
        var lp = new List<MySqlParameter>(parms) { new MySqlParameter("@lim", limit), new MySqlParameter("@off", offset) };
        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT TRIM(cr.regno) AS regno, TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) AS name, IFNULL(s.email,'') AS email,
                     IFNULL((SELECT gb.odel_points FROM odel_gradebook gb WHERE gb.space_id=sp.id AND TRIM(gb.regno)=TRIM(cr.regno)),0) AS odel_points " + where +
            " ORDER BY name LIMIT @lim OFFSET @off", lp.ToArray());
        ApiHelper.Success(Response, new Dictionary<string, object> { { "students", ApiHelper.TableToList(dt) }, { "pagination", Page(page, limit, total) } });
    }

    /// <summary>action=assignments — assignment list for a space with submission stats (lecturer).</summary>
    private void HandleAssignments()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;
        string filter = ApiHelper.Param(Request, "filter", "all").ToLower();

        string cond = "a.space_id=@sid";
        if (filter == "published") cond += " AND a.is_published=1 AND a.archived_at IS NULL";
        else if (filter == "draft") cond += " AND a.is_published=0 AND a.archived_at IS NULL";
        else if (filter == "archived") cond += " AND a.archived_at IS NOT NULL";
        else cond += " AND a.archived_at IS NULL";

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT a.id AS assignment_id, a.title, a.topic_id, a.open_at, a.due_at, a.late_until, a.max_points, a.weight_points,
                     a.submission_type, a.max_attempts, a.counts_toward_cw, a.is_published, a.archived_at, a.sort_order,
                     (SELECT COUNT(DISTINCT s.regno) FROM odel_submission s WHERE s.assignment_id=a.id AND s.status='SUBMITTED') AS submitted,
                     (SELECT COUNT(*) FROM odel_submission s JOIN odel_submission_grade g ON g.submission_id=s.id
                        WHERE s.assignment_id=a.id AND g.is_current=1) AS graded
              FROM odel_assignment a WHERE " + cond + " ORDER BY a.sort_order, a.due_at, a.id",
            new MySqlParameter("@sid", spaceId));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "assignments", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=assignment_students — per-student submission status for one assignment (lecturer).</summary>
    private void HandleAssignmentStudents()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long aid = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (spaceId <= 0 || aid <= 0) { ApiHelper.Error(Response, "space_id and assignment_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT TRIM(cr.regno) AS regno, TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) AS name,
                     sub.submission_id, sub.status, sub.submitted_at, sub.is_late, sub.final_marks
              FROM acad_course_registration cr
              JOIN odel_course_space sp ON sp.id=@sid
              LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(cr.regno)
              LEFT JOIN (
                   SELECT s2.regno, s2.id AS submission_id, s2.status, s2.submitted_at, s2.is_late,
                          (SELECT g.final_marks FROM odel_submission_grade g WHERE g.submission_id=s2.id AND g.is_current=1 LIMIT 1) AS final_marks
                   FROM odel_submission s2
                   WHERE s2.assignment_id=@a AND s2.attempt_no=(SELECT MAX(s3.attempt_no) FROM odel_submission s3 WHERE s3.assignment_id=@a AND TRIM(s3.regno)=TRIM(s2.regno))
              ) sub ON TRIM(sub.regno)=TRIM(cr.regno)
              WHERE TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED'
              ORDER BY name",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@a", aid));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "students", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=grading_queue — paginated grading queue for an assignment (lecturer).</summary>
    private void HandleGradingQueue()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long aid = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (spaceId <= 0 || aid <= 0) { ApiHelper.Error(Response, "space_id and assignment_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;
        int page = ApiHelper.ParamInt(Request, "page", 1); if (page < 1) page = 1;
        int limit = ApiHelper.ParamInt(Request, "limit", 20); if (limit > 100) limit = 100; if (limit < 1) limit = 20;
        int offset = (page - 1) * limit;
        bool onlyUngraded = ApiHelper.Param(Request, "only_ungraded", "") == "1";

        string cond = "s.assignment_id=@a AND s.status='SUBMITTED' AND s.attempt_no=(SELECT MAX(s2.attempt_no) FROM odel_submission s2 WHERE s2.assignment_id=@a AND TRIM(s2.regno)=TRIM(s.regno) AND s2.status='SUBMITTED')";
        if (onlyUngraded) cond += " AND NOT EXISTS(SELECT 1 FROM odel_submission_grade g WHERE g.submission_id=s.id AND g.is_current=1)";
        var parms = new List<MySqlParameter> { new MySqlParameter("@a", aid) };

        long total = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_submission s WHERE " + cond, parms.ToArray()));
        var lp = new List<MySqlParameter>(parms) { new MySqlParameter("@lim", limit), new MySqlParameter("@off", offset) };
        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT s.id AS submission_id, TRIM(s.regno) AS regno, TRIM(CONCAT(IFNULL(st.firstname,''),' ',IFNULL(st.othername,''))) AS name,
                     s.attempt_no, s.text_answer, s.submitted_at, s.is_late, s.receipt_code,
                     g.final_marks, g.raw_marks, g.feedback, g.graded_at
              FROM odel_submission s
              LEFT JOIN campus_dynamics.acad_student st ON TRIM(st.regno)=TRIM(s.regno)
              LEFT JOIN odel_submission_grade g ON g.submission_id=s.id AND g.is_current=1
              WHERE " + cond + " ORDER BY s.is_late DESC, s.submitted_at LIMIT @lim OFFSET @off", lp.ToArray());
        ApiHelper.Success(Response, new Dictionary<string, object> { { "submissions", ApiHelper.TableToList(dt) }, { "pagination", Page(page, limit, total) } });
    }

    /// <summary>action=lecture_list — lectures for a space (lecturer).</summary>
    private void HandleLectureList()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT l.id AS lecture_id, l.title, l.description, l.meet_link, l.meet_provider, l.location,
                     l.scheduled_start, l.scheduled_end, l.status, l.is_published, l.attendance_open,
                     (SELECT COUNT(*) FROM odel_attendance a WHERE a.lecture_id=l.id AND a.status IN('PRESENT','LATE')) AS present_count
              FROM odel_lecture l WHERE l.space_id=@sid ORDER BY l.scheduled_start DESC",
            new MySqlParameter("@sid", spaceId));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "lectures", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=roll_roster — roster with attendance marks for one lecture (lecturer).</summary>
    private void HandleRollRoster()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        if (spaceId <= 0 || lectureId <= 0) { ApiHelper.Error(Response, "space_id and lecture_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT TRIM(cr.regno) AS regno, TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) AS name,
                     IFNULL(a.status,'') AS attendance, a.method, a.marked_at
              FROM acad_course_registration cr JOIN odel_course_space sp ON sp.id=@sid
              LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(cr.regno)
              LEFT JOIN odel_attendance a ON a.lecture_id=@l AND TRIM(a.regno)=TRIM(cr.regno)
              WHERE TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED'
              ORDER BY name",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@l", lectureId));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "roster", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=attendance_summary — per-lecture attendance counts for a space (lecturer).</summary>
    private void HandleAttendanceSummary()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT l.id AS lecture_id, l.title, l.scheduled_start, l.status,
                     (SELECT COUNT(*) FROM odel_attendance a WHERE a.lecture_id=l.id AND a.status IN('PRESENT','LATE')) AS present,
                     (SELECT COUNT(*) FROM odel_attendance a WHERE a.lecture_id=l.id AND a.status='ABSENT') AS absent
              FROM odel_lecture l WHERE l.space_id=@sid AND l.is_published=1 ORDER BY l.scheduled_start DESC",
            new MySqlParameter("@sid", spaceId));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "lectures", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=update_list — announcements for a space with read-counts (lecturer).</summary>
    private void HandleUpdateList()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT u.id AS update_id, u.title, u.body, u.pinned, u.is_published, u.author_name, u.created_at, u.updated_at,
                     (SELECT COUNT(*) FROM odel_update_read r WHERE r.update_id=u.id) AS read_count
              FROM odel_course_update u WHERE u.space_id=@sid ORDER BY u.pinned DESC, u.created_at DESC",
            new MySqlParameter("@sid", spaceId));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "updates", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=save_grade — grade a submission (versioned) and recompute the gradebook (write).</summary>
    private void HandleSaveGrade()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long submissionId = ApiHelper.ParamInt(Request, "submission_id", 0);
        if (spaceId <= 0 || submissionId <= 0) { ApiHelper.Error(Response, "space_id and submission_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        string rawStr = ApiHelper.Param(Request, "raw_marks", "");
        double raw;
        if (!double.TryParse(rawStr, out raw)) { ApiHelper.Error(Response, "raw_marks must be a number.", "INVALID_PARAM"); return; }
        string feedback = ApiHelper.Param(Request, "feedback", "");

        // resolve submission + assignment (late penalty + max)
        DataTable s = ApiHelper.QueryPortal(
            @"SELECT s.id, s.regno, s.is_late, a.space_id, a.max_points, a.late_penalty_pct
              FROM odel_submission s JOIN odel_assignment a ON a.id=s.assignment_id WHERE s.id=@s",
            new MySqlParameter("@s", submissionId));
        if (s.Rows.Count == 0) { ApiHelper.Error(Response, "Submission not found.", "NOT_FOUND"); return; }
        DataRow sr = s.Rows[0];
        if (Convert.ToInt64(sr["space_id"]) != spaceId) { ApiHelper.Error(Response, "Submission does not belong to this space.", "VALIDATION_ERROR"); return; }
        double maxPts = sr["max_points"] == DBNull.Value ? 100 : Convert.ToDouble(sr["max_points"]);
        if (raw < 0) raw = 0; if (raw > maxPts) raw = maxPts;
        double penaltyPct = (Convert.ToInt32(sr["is_late"] == DBNull.Value ? 0 : sr["is_late"]) == 1 && sr["late_penalty_pct"] != DBNull.Value)
            ? Convert.ToDouble(sr["late_penalty_pct"]) : 0;
        double finalMarks = Math.Round(raw * (1 - penaltyPct / 100.0), 2);
        string regno = Convert.ToString(sr["regno"]);

        // version: supersede current, insert new is_current=1
        ApiHelper.ExecutePortal("UPDATE odel_submission_grade SET is_current=0 WHERE submission_id=@s AND is_current=1", new MySqlParameter("@s", submissionId));
        object verObj = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(version),0)+1 FROM odel_submission_grade WHERE submission_id=@s", new MySqlParameter("@s", submissionId));
        int ver = Convert.ToInt32(verObj);
        ApiHelper.ExecutePortal(
            @"INSERT INTO odel_submission_grade (submission_id, raw_marks, penalty_pct, final_marks, feedback, graded_by_empid, graded_at, version, is_current)
              VALUES (@s,@raw,@pen,@fin,@fb,@e,NOW(),@v,1)",
            new MySqlParameter("@s", submissionId), new MySqlParameter("@raw", raw), new MySqlParameter("@pen", penaltyPct),
            new MySqlParameter("@fin", finalMarks), new MySqlParameter("@fb", feedback), new MySqlParameter("@e", empid), new MySqlParameter("@v", ver));

        RecomputeGradebook(spaceId, regno);
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "submission_id", submissionId }, { "final_marks", finalMarks }, { "penalty_pct", penaltyPct }, { "version", ver }
        }, "Grade saved");
    }

    /// <summary>Recomputes odel_gradebook.odel_points = Σ(final/max × weight) over latest graded attempts.</summary>
    private static void RecomputeGradebook(long spaceId, string regno)
    {
        object pts = ApiHelper.ScalarPortal(
            @"SELECT IFNULL(SUM( (g.final_marks / NULLIF(a.max_points,0)) * a.weight_points ),0)
              FROM odel_submission s
              JOIN odel_assignment a ON a.id=s.assignment_id
              JOIN odel_submission_grade g ON g.submission_id=s.id AND g.is_current=1
              WHERE a.space_id=@sid AND TRIM(s.regno)=TRIM(@r) AND a.is_published=1 AND a.counts_toward_cw=1
                AND s.attempt_no=(SELECT MAX(s2.attempt_no) FROM odel_submission s2 WHERE s2.assignment_id=a.id AND TRIM(s2.regno)=TRIM(s.regno) AND s2.status='SUBMITTED')",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@r", regno));
        double points = (pts == null || pts == DBNull.Value) ? 0 : Convert.ToDouble(pts);
        ApiHelper.ExecutePortal(
            @"INSERT INTO odel_gradebook (space_id, regno, odel_points, computed_at) VALUES (@sid,@r,@p,NOW())
              ON DUPLICATE KEY UPDATE odel_points=@p, computed_at=NOW()",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@r", regno), new MySqlParameter("@p", points));
    }

    /// <summary>action=update_save — create/update an announcement (write).</summary>
    private void HandleUpdateSave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        long updateId = ApiHelper.ParamInt(Request, "update_id", 0);
        string title = ApiHelper.Param(Request, "title", "").Trim();
        string body = ApiHelper.Param(Request, "body", "");
        int pinned = ApiHelper.Param(Request, "pinned", "0") == "1" ? 1 : 0;
        int published = ApiHelper.Param(Request, "is_published", "1") == "0" ? 0 : 1;
        if (title == "") { ApiHelper.Error(Response, "title is required.", "VALIDATION_ERROR"); return; }

        if (updateId > 0)
        {
            int n = ApiHelper.ExecutePortal(
                "UPDATE odel_course_update SET title=@t, body=@b, pinned=@p, is_published=@pub, updated_at=NOW() WHERE id=@id AND space_id=@sid",
                new MySqlParameter("@t", title), new MySqlParameter("@b", body), new MySqlParameter("@p", pinned),
                new MySqlParameter("@pub", published), new MySqlParameter("@id", updateId), new MySqlParameter("@sid", spaceId));
            if (n == 0) { ApiHelper.Error(Response, "Announcement not found in this space.", "NOT_FOUND"); return; }
            ApiHelper.Success(Response, new Dictionary<string, object> { { "update_id", updateId } }, "Announcement updated");
        }
        else
        {
            long id = ApiHelper.ExecuteInsertPortal(
                @"INSERT INTO odel_course_update (space_id, title, body, pinned, is_published, created_by, author_name, created_at, updated_at)
                  VALUES (@sid,@t,@b,@p,@pub,@e,@an,NOW(),NOW())",
                new MySqlParameter("@sid", spaceId), new MySqlParameter("@t", title), new MySqlParameter("@b", body),
                new MySqlParameter("@p", pinned), new MySqlParameter("@pub", published), new MySqlParameter("@e", empid),
                new MySqlParameter("@an", auth.FullName ?? ""));
            ApiHelper.Success(Response, new Dictionary<string, object> { { "update_id", id } }, "Announcement created");
        }
    }

    /// <summary>action=update_delete — delete an announcement (write).</summary>
    private void HandleUpdateDelete()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long updateId = ApiHelper.ParamInt(Request, "update_id", 0);
        if (spaceId <= 0 || updateId <= 0) { ApiHelper.Error(Response, "space_id and update_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;
        ApiHelper.ExecutePortal("DELETE FROM odel_update_read WHERE update_id=@id", new MySqlParameter("@id", updateId));
        int n = ApiHelper.ExecutePortal("DELETE FROM odel_course_update WHERE id=@id AND space_id=@sid", new MySqlParameter("@id", updateId), new MySqlParameter("@sid", spaceId));
        if (n == 0) { ApiHelper.Error(Response, "Announcement not found in this space.", "NOT_FOUND"); return; }
        ApiHelper.Success(Response, null, "Announcement deleted");
    }

    /// <summary>action=mark_attendance — mark one student's attendance for a lecture (write).</summary>
    private void HandleMarkAttendance()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        string regno = ApiHelper.Param(Request, "regno", "").Trim();
        string status = ApiHelper.Param(Request, "status", "").Trim().ToUpper();
        if (spaceId <= 0 || lectureId <= 0 || regno == "") { ApiHelper.Error(Response, "space_id, lecture_id and regno are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (status != "PRESENT" && status != "ABSENT" && status != "LATE" && status != "EXCUSED" && status != "CLEAR")
        { ApiHelper.Error(Response, "status must be PRESENT, ABSENT, LATE, EXCUSED or CLEAR.", "INVALID_PARAM"); return; }

        if (status == "CLEAR")
        {
            ApiHelper.ExecutePortal("DELETE FROM odel_attendance WHERE lecture_id=@l AND TRIM(regno)=TRIM(@r)", new MySqlParameter("@l", lectureId), new MySqlParameter("@r", regno));
            ApiHelper.Success(Response, new Dictionary<string, object> { { "regno", regno }, { "status", "CLEARED" } }, "Attendance cleared");
            return;
        }
        ApiHelper.ExecutePortal(
            @"INSERT INTO odel_attendance (lecture_id, regno, status, method, marked_by, marked_at) VALUES (@l,@r,@st,'MANUAL',@e,NOW())
              ON DUPLICATE KEY UPDATE status=@st, method='MANUAL', marked_by=@e, marked_at=NOW()",
            new MySqlParameter("@l", lectureId), new MySqlParameter("@r", regno), new MySqlParameter("@st", status), new MySqlParameter("@e", empid));
        ApiHelper.Success(Response, new Dictionary<string, object> { { "regno", regno }, { "status", status } }, "Attendance marked");
    }

    /// <summary>action=lecture_set_status — transition a lecture PENDING/LIVE/ENDED/CANCELLED (write).</summary>
    private void HandleLectureSetStatus()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        string status = ApiHelper.Param(Request, "status", "").Trim().ToUpper();
        if (spaceId <= 0 || lectureId <= 0) { ApiHelper.Error(Response, "space_id and lecture_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;
        if (status != "PENDING" && status != "LIVE" && status != "ENDED" && status != "CANCELLED")
        { ApiHelper.Error(Response, "status must be PENDING, LIVE, ENDED or CANCELLED.", "INVALID_PARAM"); return; }

        string extra = status == "LIVE" ? ", actual_start=IFNULL(actual_start,NOW())" : status == "ENDED" ? ", actual_end=NOW()" : "";
        int n = ApiHelper.ExecutePortal(
            "UPDATE odel_lecture SET status=@st" + extra + ", updated_at=NOW() WHERE id=@l AND space_id=@sid",
            new MySqlParameter("@st", status), new MySqlParameter("@l", lectureId), new MySqlParameter("@sid", spaceId));
        if (n == 0) { ApiHelper.Error(Response, "Lecture not found in this space.", "NOT_FOUND"); return; }
        ApiHelper.Success(Response, new Dictionary<string, object> { { "lecture_id", lectureId }, { "status", status } }, "Lecture status updated");
    }

    /// <summary>action=ping — module health (public).</summary>
    private void HandlePing()
    {
        long spaces = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_course_space"));
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "status", "ok" }, { "module", "odel" }, { "spaces", spaces }, { "timestamp", DateTime.UtcNow.ToString("o") }
        });
    }

    private static long ToLong(object o) { return (o == null || o == DBNull.Value) ? 0 : Convert.ToInt64(o); }
}
