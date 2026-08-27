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
                case "update_pin":        HandleUpdatePin();        break;
                case "teaching_summary":  HandleTeachingSummary();  break;
                // ── lecturer: assignment authoring & lifecycle ──
                case "assignment_save":      HandleAssignmentSave();      break;
                case "assignment_publish":   HandleAssignmentPublish();   break;
                case "assignment_close":     HandleAssignmentClose();     break;
                case "assignment_delete":    HandleAssignmentDelete();    break;
                case "assignment_duplicate": HandleAssignmentDuplicate(); break;
                case "assignment_extend":    HandleAssignmentExtend();    break;
                case "assignment_unextend":  HandleAssignmentUnextend();  break;
                case "assignment_stats":     HandleAssignmentStats();     break;
                // ── lecturer: content authoring ──
                case "content_outline":   HandleContentOutline();   break;
                case "content_publish":   HandleContentPublish();   break;
                case "content_reorder":   HandleContentReorder();   break;
                case "chapter_save":      HandleChapterSave();      break;
                case "chapter_delete":    HandleChapterDelete();    break;
                case "topic_save":        HandleTopicSave();        break;
                case "topic_delete":      HandleTopicDelete();      break;
                case "material_save":     HandleMaterialSave();     break;
                case "material_delete":   HandleMaterialDelete();   break;
                // ── lecturer: lectures & attendance sessions ──
                case "lecture_save":        HandleLectureSave();       break;
                case "lecture_get":         HandleLectureGet();        break;
                case "lecture_delete":      HandleLectureDelete();     break;
                case "lecture_series_save": HandleLectureSeriesSave(); break;
                case "attendance_open":     HandleAttendanceOpen();    break;
                case "attendance_close":    HandleAttendanceClose();   break;
                case "attendance_bulk":     HandleAttendanceBulk();    break;
                // ── lecturer: coursework push to official marks ──
                case "push_preview":      HandlePushPreview();      break;
                case "push_commit":       HandlePushCommit();       break;
                case "push_history":      HandlePushHistory();      break;
                case "push_snapshot":     HandlePushSnapshot();     break;
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

    /// <summary>
    /// Resolves a staff login username to hrm_employee.empID (0 if not staff).
    ///
    /// The columns are tried in order of how strongly they identify one person, and EMP_CODE is
    /// tried LAST and only when it is unambiguous. EMP_CODE is not unique — 19 codes are shared by
    /// more than one employee (BJ07032022L belongs to both Baguma James and Baguma Davis) — so
    /// matching it in one OR'd query with ORDER BY empID LIMIT 1 silently resolves to whichever row
    /// sorts first. In a teaching API that means one lecturer editing another's assignments and
    /// grading another's students. An ambiguous code is refused rather than guessed.
    ///
    /// An email-style login also falls back to its local part, because some records store "bagumaj"
    /// against a "bagumaj@mru.ac.ug" login — a fallback, never a replacement.
    /// (Mirrors CampusDynamics_Portal/App_Code/Portal/StaffLookup.cs.)
    /// </summary>
    private static int StaffEmpId(string username)
    {
        string full = (username ?? "").Trim();
        if (full == "") return 0;
        string local = full.Contains("@") ? full.Substring(0, full.IndexOf('@')).Trim() : "";

        object o = ApiHelper.Scalar(
            @"SELECT empID FROM hrm_employee WHERE UPPER(TRIM(IFNULL(usernames,'')))=UPPER(TRIM(@u))
              AND TRIM(IFNULL(usernames,'')) NOT IN ('','-') ORDER BY empID LIMIT 1",
            new MySqlParameter("@u", full));
        if (o != null && o != DBNull.Value) return Convert.ToInt32(o);

        if (local != "")
        {
            o = ApiHelper.Scalar(
                @"SELECT empID FROM hrm_employee WHERE UPPER(TRIM(IFNULL(usernames,'')))=UPPER(TRIM(@u))
                  AND TRIM(IFNULL(usernames,'')) NOT IN ('','-') ORDER BY empID LIMIT 1",
                new MySqlParameter("@u", local));
            if (o != null && o != DBNull.Value) return Convert.ToInt32(o);
        }

        o = ApiHelper.Scalar(
            @"SELECT empID FROM hrm_employee WHERE UPPER(TRIM(IFNULL(emp_email,'')))=UPPER(TRIM(@u))
              AND TRIM(IFNULL(emp_email,'')) NOT IN ('','-') ORDER BY empID LIMIT 1",
            new MySqlParameter("@u", full));
        if (o != null && o != DBNull.Value) return Convert.ToInt32(o);

        foreach (string key in new[] { full, local })
        {
            if (key == "") continue;
            object c = ApiHelper.Scalar(
                @"SELECT COUNT(*) FROM hrm_employee WHERE UPPER(TRIM(IFNULL(EMP_CODE,'')))=UPPER(TRIM(@u))
                  AND TRIM(IFNULL(EMP_CODE,'')) NOT IN ('','-')",
                new MySqlParameter("@u", key));
            int n = (c == null || c == DBNull.Value) ? 0 : Convert.ToInt32(c);
            if (n != 1) continue;   // 0 = no match; >1 = shared code, refuse rather than guess
            o = ApiHelper.Scalar(
                @"SELECT empID FROM hrm_employee WHERE UPPER(TRIM(IFNULL(EMP_CODE,'')))=UPPER(TRIM(@u))
                  AND TRIM(IFNULL(EMP_CODE,'')) NOT IN ('','-') ORDER BY empID LIMIT 1",
                new MySqlParameter("@u", key));
            if (o != null && o != DBNull.Value) return Convert.ToInt32(o);
        }
        return 0;
    }

    /// <summary>Writes an odel_activity_log entry. Never throws — auditing must not fail a request.</summary>
    private static void LogActivity(int empid, long spaceId, string verb, string objectType, long objectId, string detail)
    {
        try
        {
            ApiHelper.ExecutePortal(
                @"INSERT INTO odel_activity_log (actor_type, actor_ref, space_id, verb, object_type, object_id, detail, created_at)
                  VALUES ('STAFF',@ar,@sp,@v,@ot,@oid,@d,NOW())",
                new MySqlParameter("@ar", empid.ToString()), new MySqlParameter("@sp", spaceId),
                new MySqlParameter("@v", verb ?? ""), new MySqlParameter("@ot", objectType ?? ""),
                new MySqlParameter("@oid", objectId), new MySqlParameter("@d", detail ?? ""));
        }
        catch { }
    }

    /// <summary>
    /// True when an assignment belongs to the given space. Every assignment-scoped action checks
    /// this: the caller is authorised against a SPACE, so accepting an assignment_id without
    /// confirming it lives in that space would let a lecturer reach into any other course's work
    /// by passing a space they legitimately teach plus someone else's assignment id.
    /// </summary>
    private static bool AssignmentInSpace(long assignmentId, long spaceId)
    {
        object o = ApiHelper.ScalarPortal("SELECT 1 FROM odel_assignment WHERE id=@a AND space_id=@s LIMIT 1",
            new MySqlParameter("@a", assignmentId), new MySqlParameter("@s", spaceId));
        return o != null && o != DBNull.Value;
    }

    /// <summary>Same containment check for a lecture.</summary>
    private static bool LectureInSpace(long lectureId, long spaceId)
    {
        object o = ApiHelper.ScalarPortal("SELECT 1 FROM odel_lecture WHERE id=@l AND space_id=@s LIMIT 1",
            new MySqlParameter("@l", lectureId), new MySqlParameter("@s", spaceId));
        return o != null && o != DBNull.Value;
    }

    /// <summary>Parses an optional datetime parameter. Returns DBNull when blank, or null when unparseable.</summary>
    private static object ParseDate(string raw, out bool bad)
    {
        bad = false;
        if (string.IsNullOrEmpty(raw) || raw.Trim() == "") return DBNull.Value;
        DateTime d;
        if (DateTime.TryParse(raw.Trim(), out d)) return d;
        bad = true;
        return DBNull.Value;
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

    // ═══════════════════ lecturer: assignment authoring & lifecycle ═══════════════════

    /// <summary>
    /// action=assignment_save — create or update an assignment (write).
    /// Pass assignment_id to update, omit it to create. Only the fields you send are changed on an
    /// update, so a client editing one field cannot blank the rest by omission.
    /// </summary>
    private void HandleAssignmentSave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;

        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        string title = ApiHelper.Param(Request, "title", "").Trim();
        string instructions = ApiHelper.Param(Request, "instructions", "");
        long topicId = ApiHelper.ParamInt(Request, "topic_id", 0);
        string subType = ApiHelper.Param(Request, "submission_type", "").Trim().ToUpper();
        int maxPoints = ApiHelper.ParamInt(Request, "max_points", 100);
        int weight = ApiHelper.ParamInt(Request, "weight_points", 0);
        int maxAttempts = ApiHelper.ParamInt(Request, "max_attempts", 1);
        int latePenalty = ApiHelper.ParamInt(Request, "late_penalty_pct", 0);
        int countsCw = ApiHelper.Param(Request, "counts_toward_cw", "1") == "0" ? 0 : 1;

        bool badDate;
        object openAt = ParseDate(ApiHelper.Param(Request, "open_at", ""), out badDate);
        if (badDate) { ApiHelper.Error(Response, "open_at is not a valid date/time.", "INVALID_PARAM"); return; }
        object dueAt = ParseDate(ApiHelper.Param(Request, "due_at", ""), out badDate);
        if (badDate) { ApiHelper.Error(Response, "due_at is not a valid date/time.", "INVALID_PARAM"); return; }
        object lateUntil = ParseDate(ApiHelper.Param(Request, "late_until", ""), out badDate);
        if (badDate) { ApiHelper.Error(Response, "late_until is not a valid date/time.", "INVALID_PARAM"); return; }

        if (subType != "" && subType != "TEXT" && subType != "FILE" && subType != "BOTH")
        { ApiHelper.Error(Response, "submission_type must be TEXT, FILE or BOTH.", "INVALID_PARAM"); return; }
        if (maxPoints <= 0) { ApiHelper.Error(Response, "max_points must be greater than zero.", "VALIDATION_ERROR"); return; }
        if (weight < 0) { ApiHelper.Error(Response, "weight_points cannot be negative.", "VALIDATION_ERROR"); return; }
        if (latePenalty < 0 || latePenalty > 100) { ApiHelper.Error(Response, "late_penalty_pct must be between 0 and 100.", "VALIDATION_ERROR"); return; }
        if (maxAttempts < 1) { ApiHelper.Error(Response, "max_attempts must be at least 1.", "VALIDATION_ERROR"); return; }
        // Ordering rules — a window that closes before it opens silently locks every student out.
        if (openAt != DBNull.Value && dueAt != DBNull.Value && (DateTime)dueAt < (DateTime)openAt)
        { ApiHelper.Error(Response, "due_at cannot be earlier than open_at.", "VALIDATION_ERROR"); return; }
        if (dueAt != DBNull.Value && lateUntil != DBNull.Value && (DateTime)lateUntil < (DateTime)dueAt)
        { ApiHelper.Error(Response, "late_until cannot be earlier than due_at.", "VALIDATION_ERROR"); return; }
        if (topicId > 0)
        {
            object t = ApiHelper.ScalarPortal("SELECT 1 FROM odel_topic WHERE id=@t AND space_id=@s LIMIT 1",
                new MySqlParameter("@t", topicId), new MySqlParameter("@s", spaceId));
            if (t == null || t == DBNull.Value) { ApiHelper.Error(Response, "topic_id does not belong to this space.", "VALIDATION_ERROR"); return; }
        }

        if (assignmentId > 0)
        {
            if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }
            if (title == "") { ApiHelper.Error(Response, "title cannot be blank.", "VALIDATION_ERROR"); return; }
            ApiHelper.ExecutePortal(
                @"UPDATE odel_assignment
                     SET title=@t, instructions=@i, topic_id=@tp, submission_type=IFNULL(NULLIF(@st,''),submission_type),
                         max_points=@mp, weight_points=@w, max_attempts=@ma, late_penalty_pct=@lp,
                         counts_toward_cw=@cw, open_at=@oa, due_at=@da, late_until=@lu, updated_at=NOW()
                   WHERE id=@id AND space_id=@sid",
                new MySqlParameter("@t", title), new MySqlParameter("@i", instructions),
                new MySqlParameter("@tp", topicId > 0 ? (object)topicId : DBNull.Value),
                new MySqlParameter("@st", subType), new MySqlParameter("@mp", maxPoints),
                new MySqlParameter("@w", weight), new MySqlParameter("@ma", maxAttempts),
                new MySqlParameter("@lp", latePenalty), new MySqlParameter("@cw", countsCw),
                new MySqlParameter("@oa", openAt), new MySqlParameter("@da", dueAt), new MySqlParameter("@lu", lateUntil),
                new MySqlParameter("@id", assignmentId), new MySqlParameter("@sid", spaceId));
            LogActivity(empid, spaceId, "UPDATED", "assignment", assignmentId, "Assignment edited: " + title);
            ApiHelper.Success(Response, new Dictionary<string, object> { { "assignment_id", assignmentId } }, "Assignment updated");
            return;
        }

        if (title == "") { ApiHelper.Error(Response, "title is required.", "VALIDATION_ERROR"); return; }
        object sortObj = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(sort_order),0)+1 FROM odel_assignment WHERE space_id=@s",
            new MySqlParameter("@s", spaceId));
        long newId = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_assignment
                (space_id, topic_id, title, instructions, open_at, due_at, late_until, max_points, weight_points,
                 counts_toward_cw, submission_type, max_attempts, late_penalty_pct, is_published, created_by, created_at, sort_order, updated_at)
              VALUES (@sid,@tp,@t,@i,@oa,@da,@lu,@mp,@w,@cw,@st,@ma,@lp,0,@e,NOW(),@so,NOW())",
            new MySqlParameter("@sid", spaceId), new MySqlParameter("@tp", topicId > 0 ? (object)topicId : DBNull.Value),
            new MySqlParameter("@t", title), new MySqlParameter("@i", instructions),
            new MySqlParameter("@oa", openAt), new MySqlParameter("@da", dueAt), new MySqlParameter("@lu", lateUntil),
            new MySqlParameter("@mp", maxPoints), new MySqlParameter("@w", weight), new MySqlParameter("@cw", countsCw),
            new MySqlParameter("@st", subType == "" ? "BOTH" : subType), new MySqlParameter("@ma", maxAttempts),
            new MySqlParameter("@lp", latePenalty), new MySqlParameter("@e", empid),
            new MySqlParameter("@so", sortObj == null || sortObj == DBNull.Value ? 1 : Convert.ToInt32(sortObj)));
        LogActivity(empid, spaceId, "CREATED", "assignment", newId, "Assignment created: " + title);
        ApiHelper.Success(Response, new Dictionary<string, object> { { "assignment_id", newId }, { "is_published", 0 } },
            "Assignment created as a draft. Publish it when you are ready for students to see it.");
    }

    /// <summary>
    /// action=assignment_publish — publish or unpublish an assignment (write). publish=1|0.
    /// Unpublishing is refused once work has been graded: the grade feeds odel_gradebook, which
    /// feeds the coursework push, so hiding the assignment would silently change students' marks.
    /// </summary>
    private void HandleAssignmentPublish()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (spaceId <= 0 || assignmentId <= 0) { ApiHelper.Error(Response, "space_id and assignment_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }
        int publish = ApiHelper.Param(Request, "publish", "1") == "0" ? 0 : 1;

        if (publish == 0)
        {
            long graded = ToLong(ApiHelper.ScalarPortal(
                @"SELECT COUNT(*) FROM odel_submission s
                  JOIN odel_submission_grade g ON g.submission_id=s.id AND g.is_current=1
                  WHERE s.assignment_id=@a", new MySqlParameter("@a", assignmentId)));
            if (graded > 0)
            {
                ApiHelper.Error(Response,
                    "This assignment has " + graded + " graded submission(s), so it cannot be unpublished — " +
                    "its marks already count toward the gradebook. Close it instead (assignment_close), " +
                    "or set counts_toward_cw=0 with assignment_save to take it out of the coursework total.",
                    "VALIDATION_ERROR");
                return;
            }
        }

        ApiHelper.ExecutePortal(
            @"UPDATE odel_assignment SET is_published=@p,
                     published_at=CASE WHEN @p=1 AND published_at IS NULL THEN NOW() ELSE published_at END,
                     updated_at=NOW()
               WHERE id=@a AND space_id=@s",
            new MySqlParameter("@p", publish), new MySqlParameter("@a", assignmentId), new MySqlParameter("@s", spaceId));
        LogActivity(empid, spaceId, publish == 1 ? "PUBLISHED" : "UNPUBLISHED", "assignment", assignmentId, "");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "assignment_id", assignmentId }, { "is_published", publish } },
            publish == 1 ? "Assignment published" : "Assignment unpublished");
    }

    /// <summary>
    /// action=assignment_close — stop accepting work now (write). Sets due_at and late_until to the
    /// current time, leaving the assignment published so students keep their feedback and grades.
    /// </summary>
    private void HandleAssignmentClose()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (spaceId <= 0 || assignmentId <= 0) { ApiHelper.Error(Response, "space_id and assignment_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }

        ApiHelper.ExecutePortal(
            "UPDATE odel_assignment SET due_at=NOW(), late_until=NOW(), updated_at=NOW() WHERE id=@a AND space_id=@s",
            new MySqlParameter("@a", assignmentId), new MySqlParameter("@s", spaceId));
        LogActivity(empid, spaceId, "CLOSED", "assignment", assignmentId, "");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "assignment_id", assignmentId } },
            "Assignment closed. Students can no longer submit; existing submissions and grades are untouched.");
    }

    /// <summary>
    /// action=assignment_delete — delete an assignment (write).
    /// Refused while any submission exists unless force=1, and refused outright once a submission has
    /// been graded, because deleting graded work silently lowers the coursework mark it fed.
    /// </summary>
    private void HandleAssignmentDelete()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (spaceId <= 0 || assignmentId <= 0) { ApiHelper.Error(Response, "space_id and assignment_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }

        long graded = ToLong(ApiHelper.ScalarPortal(
            @"SELECT COUNT(*) FROM odel_submission s
              JOIN odel_submission_grade g ON g.submission_id=s.id AND g.is_current=1
              WHERE s.assignment_id=@a", new MySqlParameter("@a", assignmentId)));
        if (graded > 0)
        {
            ApiHelper.Error(Response,
                "This assignment has " + graded + " graded submission(s) and cannot be deleted — those marks " +
                "count toward the gradebook. Close it (assignment_close) or take it out of the coursework " +
                "total with counts_toward_cw=0.", "VALIDATION_ERROR");
            return;
        }
        long subs = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_submission WHERE assignment_id=@a",
            new MySqlParameter("@a", assignmentId)));
        bool force = ApiHelper.Param(Request, "force", "0") == "1";
        if (subs > 0 && !force)
        {
            ApiHelper.Error(Response,
                "This assignment has " + subs + " student submission(s). Re-send with force=1 to delete it and them.",
                "VALIDATION_ERROR");
            return;
        }

        // Children first — these tables have no cascade, so an unguarded delete orphans their rows.
        ApiHelper.ExecutePortal(
            @"DELETE g FROM odel_submission_grade g JOIN odel_submission s ON s.id=g.submission_id WHERE s.assignment_id=@a",
            new MySqlParameter("@a", assignmentId));
        ApiHelper.ExecutePortal(
            @"DELETE f FROM odel_submission_file f JOIN odel_submission s ON s.id=f.submission_id WHERE s.assignment_id=@a",
            new MySqlParameter("@a", assignmentId));
        ApiHelper.ExecutePortal("DELETE FROM odel_submission WHERE assignment_id=@a", new MySqlParameter("@a", assignmentId));
        ApiHelper.ExecutePortal("DELETE FROM odel_assignment_extension WHERE assignment_id=@a", new MySqlParameter("@a", assignmentId));
        int n = ApiHelper.ExecutePortal("DELETE FROM odel_assignment WHERE id=@a AND space_id=@s",
            new MySqlParameter("@a", assignmentId), new MySqlParameter("@s", spaceId));
        if (n == 0) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }
        LogActivity(empid, spaceId, "DELETED", "assignment", assignmentId, "Deleted with " + subs + " submission(s)");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "assignment_id", assignmentId }, { "submissions_deleted", subs } },
            "Assignment deleted");
    }

    /// <summary>
    /// action=assignment_duplicate — copy an assignment into this or another space you teach (write).
    /// The copy is always an UNPUBLISHED draft with no submissions, so duplicating can never expose
    /// work or marks. target_space_id defaults to the source space.
    /// </summary>
    private void HandleAssignmentDuplicate()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (spaceId <= 0 || assignmentId <= 0) { ApiHelper.Error(Response, "space_id and assignment_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }

        long target = ApiHelper.ParamInt(Request, "target_space_id", 0);
        if (target <= 0) target = spaceId;
        // Authorise the DESTINATION separately — teaching the source says nothing about the target.
        if (target != spaceId && !StaffOnSpace(target, empid))
        { ApiHelper.Error(Response, "You do not teach the target course space.", "ACCESS_DENIED"); return; }

        string newTitle = ApiHelper.Param(Request, "title", "").Trim();
        object sortObj = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(sort_order),0)+1 FROM odel_assignment WHERE space_id=@s",
            new MySqlParameter("@s", target));
        int sort = sortObj == null || sortObj == DBNull.Value ? 1 : Convert.ToInt32(sortObj);

        // topic_id is deliberately NOT carried across spaces: a topic belongs to one space, so
        // copying the id would attach the new assignment to another course's outline.
        long newId = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_assignment
                (space_id, topic_id, title, instructions, open_at, due_at, late_until, max_points, weight_points,
                 counts_toward_cw, submission_type, max_attempts, late_penalty_pct, rubric_id, is_published,
                 created_by, created_at, sort_order, updated_at)
              SELECT @tgt, CASE WHEN @tgt=space_id THEN topic_id ELSE NULL END,
                     CASE WHEN @nt='' THEN CONCAT(title,' (copy)') ELSE @nt END,
                     instructions, open_at, due_at, late_until, max_points, weight_points,
                     counts_toward_cw, submission_type, max_attempts, late_penalty_pct, rubric_id, 0,
                     @e, NOW(), @so, NOW()
                FROM odel_assignment WHERE id=@a",
            new MySqlParameter("@tgt", target), new MySqlParameter("@nt", newTitle),
            new MySqlParameter("@e", empid), new MySqlParameter("@so", sort), new MySqlParameter("@a", assignmentId));
        LogActivity(empid, target, "CREATED", "assignment", newId, "Duplicated from assignment #" + assignmentId);
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "assignment_id", newId }, { "space_id", target }, { "is_published", 0 }
        }, "Assignment duplicated as an unpublished draft");
    }

    /// <summary>
    /// action=assignment_extend — give one student a later deadline or extra attempts (write).
    /// Upserts on (assignment_id, regno), so re-sending revises the existing extension.
    /// </summary>
    private void HandleAssignmentExtend()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        string regno = ApiHelper.Param(Request, "regno", "").Trim();
        if (spaceId <= 0 || assignmentId <= 0 || regno == "")
        { ApiHelper.Error(Response, "space_id, assignment_id and regno are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }
        if (!StudentOnSpace(spaceId, regno)) { ApiHelper.Error(Response, "That student is not enrolled in this course space.", "VALIDATION_ERROR"); return; }

        bool badDate;
        object dueAt = ParseDate(ApiHelper.Param(Request, "due_at", ""), out badDate);
        if (badDate) { ApiHelper.Error(Response, "due_at is not a valid date/time.", "INVALID_PARAM"); return; }
        object lateUntil = ParseDate(ApiHelper.Param(Request, "late_until", ""), out badDate);
        if (badDate) { ApiHelper.Error(Response, "late_until is not a valid date/time.", "INVALID_PARAM"); return; }
        int extraAttempts = ApiHelper.ParamInt(Request, "extra_attempts", 0);
        string reason = ApiHelper.Param(Request, "reason", "").Trim();
        if (dueAt == DBNull.Value && lateUntil == DBNull.Value && extraAttempts <= 0)
        { ApiHelper.Error(Response, "Supply at least one of due_at, late_until or extra_attempts.", "VALIDATION_ERROR"); return; }
        if (extraAttempts < 0) { ApiHelper.Error(Response, "extra_attempts cannot be negative.", "VALIDATION_ERROR"); return; }
        if (dueAt != DBNull.Value && lateUntil != DBNull.Value && (DateTime)lateUntil < (DateTime)dueAt)
        { ApiHelper.Error(Response, "late_until cannot be earlier than due_at.", "VALIDATION_ERROR"); return; }

        ApiHelper.ExecutePortal(
            @"INSERT INTO odel_assignment_extension (assignment_id, regno, due_at, late_until, extra_attempts, reason, created_by, created_at)
              VALUES (@a,@r,@d,@l,@x,@rs,@e,NOW())
              ON DUPLICATE KEY UPDATE due_at=@d, late_until=@l, extra_attempts=@x, reason=@rs, created_by=@e, created_at=NOW()",
            new MySqlParameter("@a", assignmentId), new MySqlParameter("@r", regno), new MySqlParameter("@d", dueAt),
            new MySqlParameter("@l", lateUntil), new MySqlParameter("@x", extraAttempts),
            new MySqlParameter("@rs", reason), new MySqlParameter("@e", empid));
        LogActivity(empid, spaceId, "EXTENDED", "assignment", assignmentId, "Extension for " + regno + (reason == "" ? "" : ": " + reason));
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "assignment_id", assignmentId }, { "regno", regno }, { "extra_attempts", extraAttempts }
        }, "Extension saved");
    }

    /// <summary>action=assignment_unextend — remove a student's extension (write).</summary>
    private void HandleAssignmentUnextend()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        string regno = ApiHelper.Param(Request, "regno", "").Trim();
        if (spaceId <= 0 || assignmentId <= 0 || regno == "")
        { ApiHelper.Error(Response, "space_id, assignment_id and regno are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }

        int n = ApiHelper.ExecutePortal("DELETE FROM odel_assignment_extension WHERE assignment_id=@a AND TRIM(regno)=TRIM(@r)",
            new MySqlParameter("@a", assignmentId), new MySqlParameter("@r", regno));
        if (n == 0) { ApiHelper.Error(Response, "That student has no extension on this assignment.", "NOT_FOUND"); return; }
        LogActivity(empid, spaceId, "UNEXTENDED", "assignment", assignmentId, "Extension removed for " + regno);
        ApiHelper.Success(Response, new Dictionary<string, object> { { "assignment_id", assignmentId }, { "regno", regno } },
            "Extension removed");
    }

    /// <summary>
    /// action=assignment_stats — submission and grade distribution for one assignment (read).
    /// The denominator is the APPROVED roster, so "not submitted" counts real students rather than
    /// being inferred from the submissions that happen to exist.
    /// </summary>
    private void HandleAssignmentStats()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long assignmentId = ApiHelper.ParamInt(Request, "assignment_id", 0);
        if (spaceId <= 0 || assignmentId <= 0) { ApiHelper.Error(Response, "space_id and assignment_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;
        if (!AssignmentInSpace(assignmentId, spaceId)) { ApiHelper.Error(Response, "Assignment not found in this space.", "NOT_FOUND"); return; }

        DataTable head = ApiHelper.QueryPortal(
            @"SELECT a.id AS assignment_id, a.title, a.max_points, a.weight_points, a.counts_toward_cw,
                     a.is_published, a.open_at, a.due_at, a.late_until, a.submission_type, a.max_attempts,
                     (SELECT COUNT(*) FROM acad_course_registration cr, odel_course_space sp
                       WHERE sp.id=@sid AND TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year
                         AND cr.semester=sp.semester AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED') AS roster,
                     (SELECT COUNT(DISTINCT TRIM(s.regno)) FROM odel_submission s WHERE s.assignment_id=a.id AND s.status='SUBMITTED') AS submitted,
                     (SELECT COUNT(DISTINCT TRIM(s.regno)) FROM odel_submission s WHERE s.assignment_id=a.id AND s.status='SUBMITTED' AND s.is_late=1) AS late,
                     (SELECT COUNT(*) FROM odel_submission s JOIN odel_submission_grade g ON g.submission_id=s.id AND g.is_current=1
                       WHERE s.assignment_id=a.id) AS graded,
                     (SELECT COUNT(*) FROM odel_assignment_extension x WHERE x.assignment_id=a.id) AS extensions
              FROM odel_assignment a WHERE a.id=@a",
            new MySqlParameter("@a", assignmentId), new MySqlParameter("@sid", spaceId));
        Dictionary<string, object> h = ApiHelper.FirstRowToDict(head);
        if (h == null) { ApiHelper.Error(Response, "Assignment not found.", "NOT_FOUND"); return; }

        DataTable dist = ApiHelper.QueryPortal(
            @"SELECT COUNT(*) AS graded_count, ROUND(AVG(g.final_marks),2) AS mean,
                     MIN(g.final_marks) AS lowest, MAX(g.final_marks) AS highest,
                     SUM(g.final_marks >= a.max_points*0.8) AS band_80_100,
                     SUM(g.final_marks >= a.max_points*0.6 AND g.final_marks < a.max_points*0.8) AS band_60_79,
                     SUM(g.final_marks >= a.max_points*0.5 AND g.final_marks < a.max_points*0.6) AS band_50_59,
                     SUM(g.final_marks <  a.max_points*0.5) AS band_below_50
              FROM odel_submission s
              JOIN odel_assignment a ON a.id=s.assignment_id
              JOIN odel_submission_grade g ON g.submission_id=s.id AND g.is_current=1
              WHERE s.assignment_id=@a",
            new MySqlParameter("@a", assignmentId));

        long roster = Convert.ToInt64(h["roster"]);
        long submitted = Convert.ToInt64(h["submitted"]);
        h["not_submitted"] = roster > submitted ? roster - submitted : 0;
        h["awaiting_grading"] = submitted - Convert.ToInt64(h["graded"]) > 0 ? submitted - Convert.ToInt64(h["graded"]) : 0;
        h["distribution"] = ApiHelper.FirstRowToDict(dist);
        ApiHelper.Success(Response, h);
    }

    // ═══════════════════════ lecturer: content authoring ═══════════════════════

    /// <summary>
    /// action=content_outline — the whole Chapter &gt; Topic &gt; Material tree for a space (read).
    /// Assembled from three flat reads rather than a nested join so a chapter with no topics, and a
    /// topic with no materials, still appear — an author needs to see the empty shelf they just made.
    /// </summary>
    private void HandleContentOutline()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable chapters = ApiHelper.QueryPortal(
            @"SELECT id AS chapter_id, title, sort_order, is_published, is_system, created_at, updated_at
              FROM odel_chapter WHERE space_id=@s ORDER BY sort_order, id", new MySqlParameter("@s", spaceId));
        DataTable topics = ApiHelper.QueryPortal(
            @"SELECT id AS topic_id, chapter_id, title, sort_order, is_published, is_system, created_at, updated_at
              FROM odel_topic WHERE space_id=@s ORDER BY sort_order, id", new MySqlParameter("@s", spaceId));
        DataTable materials = ApiHelper.QueryPortal(
            @"SELECT m.id AS material_id, tm.topic_id, m.type, m.kind, m.title, m.url, m.file_id,
                     m.description, tm.sort_order, tm.is_published, m.created_at
              FROM odel_topic_material tm
              JOIN odel_material m ON m.id=tm.material_id
              JOIN odel_topic t ON t.id=tm.topic_id
              WHERE t.space_id=@s ORDER BY tm.topic_id, tm.sort_order, tm.id", new MySqlParameter("@s", spaceId));

        var matsByTopic = new Dictionary<long, List<Dictionary<string, object>>>();
        foreach (var m in ApiHelper.TableToList(materials))
        {
            long tid = Convert.ToInt64(m["topic_id"]);
            if (!matsByTopic.ContainsKey(tid)) matsByTopic[tid] = new List<Dictionary<string, object>>();
            matsByTopic[tid].Add(m);
        }
        var topicsByChapter = new Dictionary<long, List<Dictionary<string, object>>>();
        var looseTopics = new List<Dictionary<string, object>>();
        foreach (var t in ApiHelper.TableToList(topics))
        {
            long tid = Convert.ToInt64(t["topic_id"]);
            t["materials"] = matsByTopic.ContainsKey(tid) ? matsByTopic[tid] : new List<Dictionary<string, object>>();
            t["material_count"] = ((List<Dictionary<string, object>>)t["materials"]).Count;
            // chapter_id is nullable: topics authored before chapters existed sit outside the tree.
            if (t["chapter_id"] == null) { looseTopics.Add(t); continue; }
            long cid = Convert.ToInt64(t["chapter_id"]);
            if (!topicsByChapter.ContainsKey(cid)) topicsByChapter[cid] = new List<Dictionary<string, object>>();
            topicsByChapter[cid].Add(t);
        }
        var tree = new List<Dictionary<string, object>>();
        foreach (var c in ApiHelper.TableToList(chapters))
        {
            long cid = Convert.ToInt64(c["chapter_id"]);
            c["topics"] = topicsByChapter.ContainsKey(cid) ? topicsByChapter[cid] : new List<Dictionary<string, object>>();
            c["topic_count"] = ((List<Dictionary<string, object>>)c["topics"]).Count;
            tree.Add(c);
        }

        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "space_id", spaceId },
            { "chapters", tree },
            { "unfiled_topics", looseTopics },
            { "counts", new Dictionary<string, object> {
                { "chapters", chapters.Rows.Count }, { "topics", topics.Rows.Count }, { "materials", materials.Rows.Count } } }
        });
    }

    /// <summary>action=chapter_save — create or rename a chapter (write). Pass chapter_id to update.</summary>
    private void HandleChapterSave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        long chapterId = ApiHelper.ParamInt(Request, "chapter_id", 0);
        string title = ApiHelper.Param(Request, "title", "").Trim();
        if (title == "") { ApiHelper.Error(Response, "title is required.", "VALIDATION_ERROR"); return; }

        if (chapterId > 0)
        {
            int n = ApiHelper.ExecutePortal("UPDATE odel_chapter SET title=@t, updated_at=NOW() WHERE id=@id AND space_id=@s",
                new MySqlParameter("@t", title), new MySqlParameter("@id", chapterId), new MySqlParameter("@s", spaceId));
            if (n == 0) { ApiHelper.Error(Response, "Chapter not found in this space.", "NOT_FOUND"); return; }
            LogActivity(empid, spaceId, "UPDATED", "chapter", chapterId, title);
            ApiHelper.Success(Response, new Dictionary<string, object> { { "chapter_id", chapterId } }, "Chapter renamed");
            return;
        }
        object so = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(sort_order),0)+1 FROM odel_chapter WHERE space_id=@s",
            new MySqlParameter("@s", spaceId));
        long id = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_chapter (space_id, title, sort_order, is_published, is_system, created_at, updated_at)
              VALUES (@s,@t,@so,0,0,NOW(),NOW())",
            new MySqlParameter("@s", spaceId), new MySqlParameter("@t", title),
            new MySqlParameter("@so", so == null || so == DBNull.Value ? 1 : Convert.ToInt32(so)));
        LogActivity(empid, spaceId, "CREATED", "chapter", id, title);
        ApiHelper.Success(Response, new Dictionary<string, object> { { "chapter_id", id }, { "is_published", 0 } }, "Chapter created");
    }

    /// <summary>
    /// action=chapter_delete — delete a chapter (write).
    /// Its topics are detached rather than destroyed: they become unfiled topics (chapter_id NULL)
    /// and keep their materials, so removing a heading never removes the teaching content under it.
    /// System chapters are protected.
    /// </summary>
    private void HandleChapterDelete()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long chapterId = ApiHelper.ParamInt(Request, "chapter_id", 0);
        if (spaceId <= 0 || chapterId <= 0) { ApiHelper.Error(Response, "space_id and chapter_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;

        object sys = ApiHelper.ScalarPortal("SELECT is_system FROM odel_chapter WHERE id=@c AND space_id=@s",
            new MySqlParameter("@c", chapterId), new MySqlParameter("@s", spaceId));
        if (sys == null || sys == DBNull.Value) { ApiHelper.Error(Response, "Chapter not found in this space.", "NOT_FOUND"); return; }
        if (Convert.ToInt32(sys) == 1) { ApiHelper.Error(Response, "This is a system chapter and cannot be deleted.", "VALIDATION_ERROR"); return; }

        int detached = ApiHelper.ExecutePortal("UPDATE odel_topic SET chapter_id=NULL, updated_at=NOW() WHERE chapter_id=@c AND space_id=@s",
            new MySqlParameter("@c", chapterId), new MySqlParameter("@s", spaceId));
        ApiHelper.ExecutePortal("DELETE FROM odel_chapter WHERE id=@c AND space_id=@s",
            new MySqlParameter("@c", chapterId), new MySqlParameter("@s", spaceId));
        LogActivity(empid, spaceId, "DELETED", "chapter", chapterId, detached + " topic(s) kept as unfiled");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "chapter_id", chapterId }, { "topics_unfiled", detached } },
            detached > 0
                ? "Chapter deleted. Its " + detached + " topic(s) were kept and are now unfiled."
                : "Chapter deleted");
    }

    /// <summary>action=topic_save — create or update a topic (write). Pass topic_id to update.</summary>
    private void HandleTopicSave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        long topicId = ApiHelper.ParamInt(Request, "topic_id", 0);
        long chapterId = ApiHelper.ParamInt(Request, "chapter_id", 0);
        string title = ApiHelper.Param(Request, "title", "").Trim();
        if (title == "") { ApiHelper.Error(Response, "title is required.", "VALIDATION_ERROR"); return; }
        if (chapterId > 0)
        {
            object c = ApiHelper.ScalarPortal("SELECT 1 FROM odel_chapter WHERE id=@c AND space_id=@s LIMIT 1",
                new MySqlParameter("@c", chapterId), new MySqlParameter("@s", spaceId));
            if (c == null || c == DBNull.Value) { ApiHelper.Error(Response, "chapter_id does not belong to this space.", "VALIDATION_ERROR"); return; }
        }

        if (topicId > 0)
        {
            int n = ApiHelper.ExecutePortal(
                "UPDATE odel_topic SET title=@t, chapter_id=@c, updated_at=NOW() WHERE id=@id AND space_id=@s",
                new MySqlParameter("@t", title), new MySqlParameter("@c", chapterId > 0 ? (object)chapterId : DBNull.Value),
                new MySqlParameter("@id", topicId), new MySqlParameter("@s", spaceId));
            if (n == 0) { ApiHelper.Error(Response, "Topic not found in this space.", "NOT_FOUND"); return; }
            LogActivity(empid, spaceId, "UPDATED", "topic", topicId, title);
            ApiHelper.Success(Response, new Dictionary<string, object> { { "topic_id", topicId } }, "Topic updated");
            return;
        }
        object so = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(sort_order),0)+1 FROM odel_topic WHERE space_id=@s",
            new MySqlParameter("@s", spaceId));
        long id = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_topic (space_id, chapter_id, title, sort_order, is_published, is_system, created_at, updated_at)
              VALUES (@s,@c,@t,@so,0,0,NOW(),NOW())",
            new MySqlParameter("@s", spaceId), new MySqlParameter("@c", chapterId > 0 ? (object)chapterId : DBNull.Value),
            new MySqlParameter("@t", title), new MySqlParameter("@so", so == null || so == DBNull.Value ? 1 : Convert.ToInt32(so)));
        LogActivity(empid, spaceId, "CREATED", "topic", id, title);
        ApiHelper.Success(Response, new Dictionary<string, object> { { "topic_id", id }, { "is_published", 0 } }, "Topic created");
    }

    /// <summary>
    /// action=topic_delete — delete a topic (write).
    /// Only the topic's LINKS to materials are removed; the materials themselves stay in the library
    /// so they remain reusable in other topics and courses. Refused while assignments hang off it.
    /// </summary>
    private void HandleTopicDelete()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long topicId = ApiHelper.ParamInt(Request, "topic_id", 0);
        if (spaceId <= 0 || topicId <= 0) { ApiHelper.Error(Response, "space_id and topic_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;

        object sys = ApiHelper.ScalarPortal("SELECT is_system FROM odel_topic WHERE id=@t AND space_id=@s",
            new MySqlParameter("@t", topicId), new MySqlParameter("@s", spaceId));
        if (sys == null || sys == DBNull.Value) { ApiHelper.Error(Response, "Topic not found in this space.", "NOT_FOUND"); return; }
        if (Convert.ToInt32(sys) == 1) { ApiHelper.Error(Response, "This is a system topic and cannot be deleted.", "VALIDATION_ERROR"); return; }

        long asg = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_assignment WHERE topic_id=@t", new MySqlParameter("@t", topicId)));
        if (asg > 0)
        {
            ApiHelper.Error(Response,
                "This topic holds " + asg + " assignment(s). Move or delete them first, or the assignments would " +
                "lose their place in the outline.", "VALIDATION_ERROR");
            return;
        }
        int links = ApiHelper.ExecutePortal("DELETE FROM odel_topic_material WHERE topic_id=@t", new MySqlParameter("@t", topicId));
        ApiHelper.ExecutePortal("DELETE FROM odel_topic WHERE id=@t AND space_id=@s",
            new MySqlParameter("@t", topicId), new MySqlParameter("@s", spaceId));
        LogActivity(empid, spaceId, "DELETED", "topic", topicId, links + " material link(s) removed");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "topic_id", topicId }, { "material_links_removed", links } },
            "Topic deleted. The materials themselves remain in the library.");
    }

    /// <summary>
    /// action=material_save — add or edit a material and attach it to a topic (write).
    /// type/kind: PAGE (page_html), LINK (url), FILE (file_id). Pass material_id to edit.
    /// </summary>
    private void HandleMaterialSave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long topicId = ApiHelper.ParamInt(Request, "topic_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;

        long materialId = ApiHelper.ParamInt(Request, "material_id", 0);
        string title = ApiHelper.Param(Request, "title", "").Trim();
        string type = ApiHelper.Param(Request, "type", "").Trim().ToUpper();
        string url = ApiHelper.Param(Request, "url", "").Trim();
        string pageHtml = ApiHelper.Param(Request, "page_html", "");
        string description = ApiHelper.Param(Request, "description", "").Trim();
        long fileId = ApiHelper.ParamInt(Request, "file_id", 0);

        if (topicId > 0)
        {
            object t = ApiHelper.ScalarPortal("SELECT 1 FROM odel_topic WHERE id=@t AND space_id=@s LIMIT 1",
                new MySqlParameter("@t", topicId), new MySqlParameter("@s", spaceId));
            if (t == null || t == DBNull.Value) { ApiHelper.Error(Response, "topic_id does not belong to this space.", "VALIDATION_ERROR"); return; }
        }

        if (materialId > 0)
        {
            // Editing is confined to materials owned by this space, so a material_id from another
            // course cannot be rewritten by someone who merely teaches this one.
            int n = ApiHelper.ExecutePortal(
                @"UPDATE odel_material SET title=IFNULL(NULLIF(@t,''),title), url=@u, page_html=@ph,
                         description=@d, updated_at=NOW()
                   WHERE id=@id AND space_id=@s",
                new MySqlParameter("@t", title), new MySqlParameter("@u", url == "" ? (object)DBNull.Value : url),
                new MySqlParameter("@ph", pageHtml == "" ? (object)DBNull.Value : pageHtml),
                new MySqlParameter("@d", description), new MySqlParameter("@id", materialId), new MySqlParameter("@s", spaceId));
            if (n == 0) { ApiHelper.Error(Response, "Material not found in this space.", "NOT_FOUND"); return; }
            LogActivity(empid, spaceId, "UPDATED", "material", materialId, title);
            ApiHelper.Success(Response, new Dictionary<string, object> { { "material_id", materialId } }, "Material updated");
            return;
        }

        if (title == "") { ApiHelper.Error(Response, "title is required.", "VALIDATION_ERROR"); return; }
        if (type != "PAGE" && type != "LINK" && type != "FILE")
        { ApiHelper.Error(Response, "type must be PAGE, LINK or FILE.", "INVALID_PARAM"); return; }
        if (type == "LINK" && url == "") { ApiHelper.Error(Response, "url is required for a LINK material.", "VALIDATION_ERROR"); return; }
        if (type == "FILE" && fileId <= 0) { ApiHelper.Error(Response, "file_id is required for a FILE material.", "VALIDATION_ERROR"); return; }
        if (type == "PAGE" && pageHtml == "") { ApiHelper.Error(Response, "page_html is required for a PAGE material.", "VALIDATION_ERROR"); return; }
        if (topicId <= 0) { ApiHelper.Error(Response, "topic_id is required when creating a material.", "MISSING_PARAM"); return; }

        long id = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_material (topic_id, space_id, type, kind, title, description, url, page_html, file_id,
                                         sort_order, is_published, owner_empid, visibility, created_at, updated_at)
              VALUES (@tp,@s,@ty,@ty,@t,@d,@u,@ph,@f,0,0,@e,'COURSE',NOW(),NOW())",
            new MySqlParameter("@tp", topicId), new MySqlParameter("@s", spaceId), new MySqlParameter("@ty", type),
            new MySqlParameter("@t", title), new MySqlParameter("@d", description),
            new MySqlParameter("@u", url == "" ? (object)DBNull.Value : url),
            new MySqlParameter("@ph", pageHtml == "" ? (object)DBNull.Value : pageHtml),
            new MySqlParameter("@f", fileId > 0 ? (object)fileId : DBNull.Value), new MySqlParameter("@e", empid));

        object so = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(sort_order),0)+1 FROM odel_topic_material WHERE topic_id=@t",
            new MySqlParameter("@t", topicId));
        ApiHelper.ExecutePortal(
            @"INSERT INTO odel_topic_material (topic_id, material_id, sort_order, is_published, added_by, created_at)
              VALUES (@tp,@m,@so,0,@e,NOW())",
            new MySqlParameter("@tp", topicId), new MySqlParameter("@m", id),
            new MySqlParameter("@so", so == null || so == DBNull.Value ? 1 : Convert.ToInt32(so)), new MySqlParameter("@e", empid));
        LogActivity(empid, spaceId, "CREATED", "material", id, type + ": " + title);
        ApiHelper.Success(Response, new Dictionary<string, object> { { "material_id", id }, { "topic_id", topicId }, { "is_published", 0 } },
            "Material added as a draft. Publish it with content_publish when it is ready.");
    }

    /// <summary>
    /// action=material_delete — remove a material (write).
    /// By default only the link to the topic is cut, leaving the material in the library for reuse.
    /// Pass purge=1 to delete the material itself, which is refused while other topics still use it.
    /// </summary>
    private void HandleMaterialDelete()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long materialId = ApiHelper.ParamInt(Request, "material_id", 0);
        long topicId = ApiHelper.ParamInt(Request, "topic_id", 0);
        if (spaceId <= 0 || materialId <= 0) { ApiHelper.Error(Response, "space_id and material_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;

        object owned = ApiHelper.ScalarPortal(
            @"SELECT 1 FROM odel_material m
              WHERE m.id=@m AND (m.space_id=@s OR EXISTS(SELECT 1 FROM odel_topic_material tm
                    JOIN odel_topic t ON t.id=tm.topic_id WHERE tm.material_id=m.id AND t.space_id=@s)) LIMIT 1",
            new MySqlParameter("@m", materialId), new MySqlParameter("@s", spaceId));
        if (owned == null || owned == DBNull.Value) { ApiHelper.Error(Response, "Material not found in this space.", "NOT_FOUND"); return; }

        bool purge = ApiHelper.Param(Request, "purge", "0") == "1";
        if (topicId > 0)
            ApiHelper.ExecutePortal("DELETE FROM odel_topic_material WHERE topic_id=@t AND material_id=@m",
                new MySqlParameter("@t", topicId), new MySqlParameter("@m", materialId));
        else
            ApiHelper.ExecutePortal(
                @"DELETE tm FROM odel_topic_material tm JOIN odel_topic t ON t.id=tm.topic_id
                  WHERE tm.material_id=@m AND t.space_id=@s",
                new MySqlParameter("@m", materialId), new MySqlParameter("@s", spaceId));

        if (!purge)
        {
            LogActivity(empid, spaceId, "UNLINKED", "material", materialId, topicId > 0 ? "from topic #" + topicId : "from this space");
            ApiHelper.Success(Response, new Dictionary<string, object> { { "material_id", materialId }, { "purged", false } },
                "Material removed from the topic. It is still in the library.");
            return;
        }

        long stillUsed = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_topic_material WHERE material_id=@m",
            new MySqlParameter("@m", materialId)));
        if (stillUsed > 0)
        {
            ApiHelper.Error(Response,
                "This material is still used by " + stillUsed + " other topic(s), so it was unlinked here but not deleted.",
                "VALIDATION_ERROR");
            return;
        }
        ApiHelper.ExecutePortal("DELETE FROM odel_material WHERE id=@m", new MySqlParameter("@m", materialId));
        LogActivity(empid, spaceId, "DELETED", "material", materialId, "purged from library");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "material_id", materialId }, { "purged", true } },
            "Material deleted from the library");
    }

    /// <summary>
    /// action=content_publish — publish or hide one outline node (write).
    /// node=chapter|topic|material, node_id, publish=1|0. Publishing a chapter or topic also
    /// publishes what is inside it, because a visible heading over hidden content reads to a student
    /// as an empty course.
    /// </summary>
    private void HandleContentPublish()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long nodeId = ApiHelper.ParamInt(Request, "node_id", 0);
        string node = ApiHelper.Param(Request, "node", "").Trim().ToLower();
        if (spaceId <= 0 || nodeId <= 0 || node == "")
        { ApiHelper.Error(Response, "space_id, node and node_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        int publish = ApiHelper.Param(Request, "publish", "1") == "0" ? 0 : 1;
        bool cascade = ApiHelper.Param(Request, "cascade", "1") != "0";

        int touched;
        if (node == "chapter")
        {
            touched = ApiHelper.ExecutePortal("UPDATE odel_chapter SET is_published=@p, updated_at=NOW() WHERE id=@id AND space_id=@s",
                new MySqlParameter("@p", publish), new MySqlParameter("@id", nodeId), new MySqlParameter("@s", spaceId));
            if (touched == 0) { ApiHelper.Error(Response, "Chapter not found in this space.", "NOT_FOUND"); return; }
            if (cascade)
            {
                ApiHelper.ExecutePortal("UPDATE odel_topic SET is_published=@p, updated_at=NOW() WHERE chapter_id=@id AND space_id=@s",
                    new MySqlParameter("@p", publish), new MySqlParameter("@id", nodeId), new MySqlParameter("@s", spaceId));
                ApiHelper.ExecutePortal(
                    @"UPDATE odel_topic_material tm JOIN odel_topic t ON t.id=tm.topic_id
                         SET tm.is_published=@p WHERE t.chapter_id=@id AND t.space_id=@s",
                    new MySqlParameter("@p", publish), new MySqlParameter("@id", nodeId), new MySqlParameter("@s", spaceId));
            }
        }
        else if (node == "topic")
        {
            touched = ApiHelper.ExecutePortal("UPDATE odel_topic SET is_published=@p, updated_at=NOW() WHERE id=@id AND space_id=@s",
                new MySqlParameter("@p", publish), new MySqlParameter("@id", nodeId), new MySqlParameter("@s", spaceId));
            if (touched == 0) { ApiHelper.Error(Response, "Topic not found in this space.", "NOT_FOUND"); return; }
            if (cascade)
                ApiHelper.ExecutePortal("UPDATE odel_topic_material SET is_published=@p WHERE topic_id=@id",
                    new MySqlParameter("@p", publish), new MySqlParameter("@id", nodeId));
        }
        else if (node == "material")
        {
            touched = ApiHelper.ExecutePortal(
                @"UPDATE odel_topic_material tm JOIN odel_topic t ON t.id=tm.topic_id
                     SET tm.is_published=@p WHERE tm.material_id=@id AND t.space_id=@s",
                new MySqlParameter("@p", publish), new MySqlParameter("@id", nodeId), new MySqlParameter("@s", spaceId));
            if (touched == 0) { ApiHelper.Error(Response, "Material not found in this space.", "NOT_FOUND"); return; }
            ApiHelper.ExecutePortal(
                @"UPDATE odel_material SET is_published=@p, published_at=CASE WHEN @p=1 THEN NOW() ELSE published_at END,
                         updated_at=NOW() WHERE id=@id AND space_id=@s",
                new MySqlParameter("@p", publish), new MySqlParameter("@id", nodeId), new MySqlParameter("@s", spaceId));
        }
        else { ApiHelper.Error(Response, "node must be chapter, topic or material.", "INVALID_PARAM"); return; }

        LogActivity(empid, spaceId, publish == 1 ? "PUBLISHED" : "UNPUBLISHED", node, nodeId, cascade ? "cascaded" : "single node");
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "node", node }, { "node_id", nodeId }, { "is_published", publish }, { "cascaded", cascade }
        }, publish == 1 ? "Published" : "Hidden from students");
    }

    /// <summary>
    /// action=content_reorder — reorder outline nodes (write).
    /// node=chapter|topic|material, and ids = a comma-separated list in the order you want. Every id
    /// is verified to belong to this space before anything is written, so one stray id from another
    /// course fails the whole call rather than half-applying a new order.
    /// </summary>
    private void HandleContentReorder()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        string node = ApiHelper.Param(Request, "node", "").Trim().ToLower();
        string ids = ApiHelper.Param(Request, "ids", "").Trim();
        if (spaceId <= 0 || node == "" || ids == "")
        { ApiHelper.Error(Response, "space_id, node and ids are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        long topicId = ApiHelper.ParamInt(Request, "topic_id", 0);
        if (node == "material" && topicId <= 0)
        { ApiHelper.Error(Response, "topic_id is required when reordering materials.", "MISSING_PARAM"); return; }

        var ordered = new List<long>();
        foreach (string part in ids.Split(','))
        {
            long v;
            if (!long.TryParse(part.Trim(), out v) || v <= 0)
            { ApiHelper.Error(Response, "ids must be a comma-separated list of positive numbers.", "INVALID_PARAM"); return; }
            if (!ordered.Contains(v)) ordered.Add(v);
        }

        string verify =
            node == "chapter"  ? "SELECT COUNT(*) FROM odel_chapter WHERE space_id=@s AND id=@id" :
            node == "topic"    ? "SELECT COUNT(*) FROM odel_topic   WHERE space_id=@s AND id=@id" :
            node == "material" ? "SELECT COUNT(*) FROM odel_topic_material tm JOIN odel_topic t ON t.id=tm.topic_id WHERE t.space_id=@s AND tm.topic_id=@tp AND tm.material_id=@id" :
            null;
        if (verify == null) { ApiHelper.Error(Response, "node must be chapter, topic or material.", "INVALID_PARAM"); return; }

        foreach (long id in ordered)
        {
            object c = node == "material"
                ? ApiHelper.ScalarPortal(verify, new MySqlParameter("@s", spaceId), new MySqlParameter("@tp", topicId), new MySqlParameter("@id", id))
                : ApiHelper.ScalarPortal(verify, new MySqlParameter("@s", spaceId), new MySqlParameter("@id", id));
            if (c == null || c == DBNull.Value || Convert.ToInt32(c) == 0)
            { ApiHelper.Error(Response, "Id " + id + " is not a " + node + " in this space. Nothing was reordered.", "VALIDATION_ERROR"); return; }
        }

        int pos = 0;
        foreach (long id in ordered)
        {
            pos++;
            if (node == "chapter")
                ApiHelper.ExecutePortal("UPDATE odel_chapter SET sort_order=@o, updated_at=NOW() WHERE id=@id AND space_id=@s",
                    new MySqlParameter("@o", pos), new MySqlParameter("@id", id), new MySqlParameter("@s", spaceId));
            else if (node == "topic")
                ApiHelper.ExecutePortal("UPDATE odel_topic SET sort_order=@o, updated_at=NOW() WHERE id=@id AND space_id=@s",
                    new MySqlParameter("@o", pos), new MySqlParameter("@id", id), new MySqlParameter("@s", spaceId));
            else
                ApiHelper.ExecutePortal("UPDATE odel_topic_material SET sort_order=@o WHERE topic_id=@tp AND material_id=@id",
                    new MySqlParameter("@o", pos), new MySqlParameter("@tp", topicId), new MySqlParameter("@id", id));
        }
        LogActivity(empid, spaceId, "REORDERED", node, topicId > 0 ? topicId : spaceId, ordered.Count + " item(s)");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "node", node }, { "reordered", ordered.Count } }, "Order saved");
    }

    // ═══════════════════ lecturer: lectures & attendance sessions ═══════════════════

    /// <summary>action=lecture_get — one lecture with its resources and attendance tally (read).</summary>
    private void HandleLectureGet()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        if (spaceId <= 0 || lectureId <= 0) { ApiHelper.Error(Response, "space_id and lecture_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT l.id AS lecture_id, l.space_id, l.series_id, l.title, l.description, l.meet_link, l.meet_provider,
                     l.location, l.scheduled_start, l.scheduled_end, l.status, l.actual_start, l.actual_end,
                     l.attendance_open, l.attendance_close_at, l.attendance_code, l.attendance_opened_at,
                     l.is_published, l.min_fee_percent, l.created_at, l.updated_at,
                     (SELECT COUNT(*) FROM odel_attendance a WHERE a.lecture_id=l.id AND a.status='PRESENT') AS present,
                     (SELECT COUNT(*) FROM odel_attendance a WHERE a.lecture_id=l.id AND a.status='LATE')    AS late,
                     (SELECT COUNT(*) FROM odel_attendance a WHERE a.lecture_id=l.id AND a.status='ABSENT')  AS absent,
                     (SELECT COUNT(*) FROM odel_attendance a WHERE a.lecture_id=l.id AND a.status='EXCUSED') AS excused
              FROM odel_lecture l WHERE l.id=@l AND l.space_id=@s",
            new MySqlParameter("@l", lectureId), new MySqlParameter("@s", spaceId));
        Dictionary<string, object> row = ApiHelper.FirstRowToDict(dt);
        if (row == null) { ApiHelper.Error(Response, "Lecture not found in this space.", "NOT_FOUND"); return; }

        DataTable res = ApiHelper.QueryPortal(
            @"SELECT id AS resource_id, kind, title, url, file_id, material_id, note_text, sort_order, created_at
              FROM odel_lecture_resource WHERE lecture_id=@l ORDER BY sort_order, id", new MySqlParameter("@l", lectureId));
        row["resources"] = ApiHelper.TableToList(res);
        ApiHelper.Success(Response, row);
    }

    /// <summary>
    /// action=lecture_save — schedule or edit a lecture (write). Pass lecture_id to update.
    /// scheduled_start is required on create; scheduled_end must not precede it.
    /// </summary>
    private void HandleLectureSave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;

        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        string title = ApiHelper.Param(Request, "title", "").Trim();
        string description = ApiHelper.Param(Request, "description", "");
        string meetLink = ApiHelper.Param(Request, "meet_link", "").Trim();
        string provider = ApiHelper.Param(Request, "meet_provider", "").Trim();
        string location = ApiHelper.Param(Request, "location", "").Trim();
        int minFee = ApiHelper.ParamInt(Request, "min_fee_percent", 0);
        int published = ApiHelper.Param(Request, "is_published", "1") == "0" ? 0 : 1;

        bool badDate;
        object start = ParseDate(ApiHelper.Param(Request, "scheduled_start", ""), out badDate);
        if (badDate) { ApiHelper.Error(Response, "scheduled_start is not a valid date/time.", "INVALID_PARAM"); return; }
        object end = ParseDate(ApiHelper.Param(Request, "scheduled_end", ""), out badDate);
        if (badDate) { ApiHelper.Error(Response, "scheduled_end is not a valid date/time.", "INVALID_PARAM"); return; }
        if (start != DBNull.Value && end != DBNull.Value && (DateTime)end < (DateTime)start)
        { ApiHelper.Error(Response, "scheduled_end cannot be earlier than scheduled_start.", "VALIDATION_ERROR"); return; }
        if (minFee < 0 || minFee > 100) { ApiHelper.Error(Response, "min_fee_percent must be between 0 and 100.", "VALIDATION_ERROR"); return; }

        if (lectureId > 0)
        {
            if (!LectureInSpace(lectureId, spaceId)) { ApiHelper.Error(Response, "Lecture not found in this space.", "NOT_FOUND"); return; }
            if (title == "") { ApiHelper.Error(Response, "title cannot be blank.", "VALIDATION_ERROR"); return; }
            ApiHelper.ExecutePortal(
                @"UPDATE odel_lecture
                     SET title=@t, description=@d, meet_link=@ml, meet_provider=@mp, location=@loc,
                         scheduled_start=IFNULL(@ss,scheduled_start), scheduled_end=@se,
                         min_fee_percent=@mf, is_published=@pub, updated_at=NOW()
                   WHERE id=@id AND space_id=@s",
                new MySqlParameter("@t", title), new MySqlParameter("@d", description),
                new MySqlParameter("@ml", meetLink), new MySqlParameter("@mp", provider), new MySqlParameter("@loc", location),
                new MySqlParameter("@ss", start), new MySqlParameter("@se", end),
                new MySqlParameter("@mf", minFee), new MySqlParameter("@pub", published),
                new MySqlParameter("@id", lectureId), new MySqlParameter("@s", spaceId));
            LogActivity(empid, spaceId, "UPDATED", "lecture", lectureId, title);
            ApiHelper.Success(Response, new Dictionary<string, object> { { "lecture_id", lectureId } }, "Lecture updated");
            return;
        }

        if (title == "") { ApiHelper.Error(Response, "title is required.", "VALIDATION_ERROR"); return; }
        if (start == DBNull.Value) { ApiHelper.Error(Response, "scheduled_start is required.", "VALIDATION_ERROR"); return; }
        long id = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_lecture
                (space_id, title, description, meet_link, meet_provider, location, scheduled_start, scheduled_end,
                 status, attendance_open, is_published, min_fee_percent, created_by, created_at, updated_at)
              VALUES (@s,@t,@d,@ml,@mp,@loc,@ss,@se,'PENDING',0,@pub,@mf,@e,NOW(),NOW())",
            new MySqlParameter("@s", spaceId), new MySqlParameter("@t", title), new MySqlParameter("@d", description),
            new MySqlParameter("@ml", meetLink), new MySqlParameter("@mp", provider), new MySqlParameter("@loc", location),
            new MySqlParameter("@ss", start), new MySqlParameter("@se", end),
            new MySqlParameter("@pub", published), new MySqlParameter("@mf", minFee), new MySqlParameter("@e", empid));
        LogActivity(empid, spaceId, "CREATED", "lecture", id, title);
        ApiHelper.Success(Response, new Dictionary<string, object> { { "lecture_id", id }, { "status", "PENDING" } }, "Lecture scheduled");
    }

    /// <summary>
    /// action=lecture_delete — delete a lecture (write).
    /// Refused once attendance has been recorded unless force=1, because attendance is the register
    /// of who actually turned up and deleting it cannot be undone.
    /// </summary>
    private void HandleLectureDelete()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        if (spaceId <= 0 || lectureId <= 0) { ApiHelper.Error(Response, "space_id and lecture_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!LectureInSpace(lectureId, spaceId)) { ApiHelper.Error(Response, "Lecture not found in this space.", "NOT_FOUND"); return; }

        long marks = ToLong(ApiHelper.ScalarPortal("SELECT COUNT(*) FROM odel_attendance WHERE lecture_id=@l",
            new MySqlParameter("@l", lectureId)));
        if (marks > 0 && ApiHelper.Param(Request, "force", "0") != "1")
        {
            ApiHelper.Error(Response,
                "This lecture has " + marks + " attendance record(s). Cancel it instead " +
                "(lecture_set_status with status=CANCELLED), or re-send with force=1 to delete the register too.",
                "VALIDATION_ERROR");
            return;
        }
        ApiHelper.ExecutePortal("DELETE FROM odel_attendance WHERE lecture_id=@l", new MySqlParameter("@l", lectureId));
        ApiHelper.ExecutePortal("DELETE FROM odel_lecture_resource WHERE lecture_id=@l", new MySqlParameter("@l", lectureId));
        ApiHelper.ExecutePortal("DELETE FROM odel_lecture WHERE id=@l AND space_id=@s",
            new MySqlParameter("@l", lectureId), new MySqlParameter("@s", spaceId));
        LogActivity(empid, spaceId, "DELETED", "lecture", lectureId, marks + " attendance record(s) removed");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "lecture_id", lectureId }, { "attendance_deleted", marks } },
            "Lecture deleted");
    }

    /// <summary>
    /// action=lecture_series_save — create a recurring series and generate its lectures (write).
    /// days_mask is a 7-character string of 0/1 starting Monday, e.g. 1010100 = Mon, Wed, Fri.
    /// Generation is capped at 200 lectures so a mistyped until_date cannot flood the timetable.
    /// </summary>
    private void HandleLectureSeriesSave()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;

        string title = ApiHelper.Param(Request, "title", "").Trim();
        string description = ApiHelper.Param(Request, "description", "");
        string meetLink = ApiHelper.Param(Request, "meet_link", "").Trim();
        string daysMask = ApiHelper.Param(Request, "days_mask", "").Trim();
        string startTime = ApiHelper.Param(Request, "start_time", "").Trim();
        int durationMin = ApiHelper.ParamInt(Request, "duration_min", 0);
        if (title == "") { ApiHelper.Error(Response, "title is required.", "VALIDATION_ERROR"); return; }
        if (daysMask.Length != 7) { ApiHelper.Error(Response, "days_mask must be 7 characters of 0/1 starting Monday, e.g. 1010100.", "INVALID_PARAM"); return; }
        foreach (char ch in daysMask) if (ch != '0' && ch != '1')
        { ApiHelper.Error(Response, "days_mask may contain only 0 and 1.", "INVALID_PARAM"); return; }
        if (daysMask.IndexOf('1') < 0) { ApiHelper.Error(Response, "days_mask selects no days.", "VALIDATION_ERROR"); return; }
        if (durationMin <= 0) { ApiHelper.Error(Response, "duration_min must be greater than zero.", "VALIDATION_ERROR"); return; }

        TimeSpan tod;
        if (!TimeSpan.TryParse(startTime, out tod)) { ApiHelper.Error(Response, "start_time must be HH:MM (24-hour).", "INVALID_PARAM"); return; }
        bool badDate;
        object sd = ParseDate(ApiHelper.Param(Request, "start_date", ""), out badDate);
        if (badDate || sd == DBNull.Value) { ApiHelper.Error(Response, "start_date is required and must be a valid date.", "INVALID_PARAM"); return; }
        object ud = ParseDate(ApiHelper.Param(Request, "until_date", ""), out badDate);
        if (badDate || ud == DBNull.Value) { ApiHelper.Error(Response, "until_date is required and must be a valid date.", "INVALID_PARAM"); return; }
        DateTime startDate = ((DateTime)sd).Date, untilDate = ((DateTime)ud).Date;
        if (untilDate < startDate) { ApiHelper.Error(Response, "until_date cannot be earlier than start_date.", "VALIDATION_ERROR"); return; }

        var skip = new List<string>();
        foreach (string s in ApiHelper.Param(Request, "skip_dates", "").Split(','))
        {
            DateTime d;
            if (s.Trim() != "" && DateTime.TryParse(s.Trim(), out d)) skip.Add(d.ToString("yyyy-MM-dd"));
        }

        long seriesId = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_lecture_series (space_id, title, description, meet_link, repeat_kind, days_mask,
                                               start_time, duration_min, start_date, until_date, skip_dates, created_by, created_at)
              VALUES (@s,@t,@d,@ml,'WEEKLY',@dm,@st,@dur,@sd,@ud,@sk,@e,NOW())",
            new MySqlParameter("@s", spaceId), new MySqlParameter("@t", title), new MySqlParameter("@d", description),
            new MySqlParameter("@ml", meetLink), new MySqlParameter("@dm", daysMask), new MySqlParameter("@st", tod),
            new MySqlParameter("@dur", durationMin), new MySqlParameter("@sd", startDate), new MySqlParameter("@ud", untilDate),
            new MySqlParameter("@sk", string.Join(",", skip.ToArray())), new MySqlParameter("@e", empid));

        const int MaxGenerated = 200;
        int created = 0; bool capped = false;
        for (DateTime day = startDate; day <= untilDate; day = day.AddDays(1))
        {
            // DayOfWeek is Sunday-based; days_mask is Monday-based.
            int idx = ((int)day.DayOfWeek + 6) % 7;
            if (daysMask[idx] != '1') continue;
            if (skip.Contains(day.ToString("yyyy-MM-dd"))) continue;
            if (created >= MaxGenerated) { capped = true; break; }
            DateTime s0 = day.Add(tod);
            ApiHelper.ExecutePortal(
                @"INSERT INTO odel_lecture (space_id, series_id, title, description, meet_link, scheduled_start, scheduled_end,
                                            status, attendance_open, is_published, created_by, created_at, updated_at)
                  VALUES (@s,@ser,@t,@d,@ml,@ss,@se,'PENDING',0,1,@e,NOW(),NOW())",
                new MySqlParameter("@s", spaceId), new MySqlParameter("@ser", seriesId), new MySqlParameter("@t", title),
                new MySqlParameter("@d", description), new MySqlParameter("@ml", meetLink),
                new MySqlParameter("@ss", s0), new MySqlParameter("@se", s0.AddMinutes(durationMin)),
                new MySqlParameter("@e", empid));
            created++;
        }
        LogActivity(empid, spaceId, "CREATED", "lecture_series", seriesId, created + " lecture(s) generated");
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "series_id", seriesId }, { "lectures_created", created }, { "capped", capped }
        }, capped
            ? "Series saved, but generation stopped at the " + MaxGenerated + "-lecture limit. Shorten until_date and save another series if you need more."
            : "Series saved and " + created + " lecture(s) scheduled");
    }

    /// <summary>
    /// action=attendance_open — open the register so students can self check in (write).
    /// Issues a short code and an optional auto-close time (close_in_minutes).
    /// </summary>
    private void HandleAttendanceOpen()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        if (spaceId <= 0 || lectureId <= 0) { ApiHelper.Error(Response, "space_id and lecture_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!LectureInSpace(lectureId, spaceId)) { ApiHelper.Error(Response, "Lecture not found in this space.", "NOT_FOUND"); return; }

        int minutes = ApiHelper.ParamInt(Request, "close_in_minutes", 0);
        if (minutes < 0 || minutes > 480) { ApiHelper.Error(Response, "close_in_minutes must be between 0 and 480.", "VALIDATION_ERROR"); return; }
        string code = ApiHelper.Param(Request, "attendance_code", "").Trim().ToUpper();
        if (code == "")
        {
            // 6 characters from an unambiguous alphabet — no O/0 or I/1 to mis-read on a projector.
            const string alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
            var rnd = new Random();
            var sb = new System.Text.StringBuilder();
            for (int i = 0; i < 6; i++) sb.Append(alphabet[rnd.Next(alphabet.Length)]);
            code = sb.ToString();
        }
        object closeAt = minutes > 0 ? (object)DateTime.Now.AddMinutes(minutes) : DBNull.Value;

        ApiHelper.ExecutePortal(
            @"UPDATE odel_lecture SET attendance_open=1, attendance_code=@c, attendance_close_at=@ca,
                     attendance_opened_by=@e, attendance_opened_at=NOW(),
                     status=CASE WHEN status='PENDING' THEN 'LIVE' ELSE status END,
                     actual_start=IFNULL(actual_start,NOW()), updated_at=NOW()
               WHERE id=@l AND space_id=@s",
            new MySqlParameter("@c", code), new MySqlParameter("@ca", closeAt), new MySqlParameter("@e", empid),
            new MySqlParameter("@l", lectureId), new MySqlParameter("@s", spaceId));
        LogActivity(empid, spaceId, "ATTENDANCE_OPENED", "lecture", lectureId, "code " + code);
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "lecture_id", lectureId }, { "attendance_code", code },
            { "attendance_close_at", closeAt == DBNull.Value ? null : closeAt }
        }, "Register open. Students can check in with code " + code + ".");
    }

    /// <summary>
    /// action=attendance_close — close the register (write).
    /// mark_absent=1 additionally records ABSENT for every enrolled student with no mark, turning an
    /// open register into a complete one in a single call.
    /// </summary>
    private void HandleAttendanceClose()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        if (spaceId <= 0 || lectureId <= 0) { ApiHelper.Error(Response, "space_id and lecture_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!LectureInSpace(lectureId, spaceId)) { ApiHelper.Error(Response, "Lecture not found in this space.", "NOT_FOUND"); return; }

        ApiHelper.ExecutePortal(
            "UPDATE odel_lecture SET attendance_open=0, attendance_close_at=NOW(), updated_at=NOW() WHERE id=@l AND space_id=@s",
            new MySqlParameter("@l", lectureId), new MySqlParameter("@s", spaceId));

        int absent = 0;
        if (ApiHelper.Param(Request, "mark_absent", "0") == "1")
            absent = ApiHelper.ExecutePortal(
                @"INSERT INTO odel_attendance (lecture_id, regno, status, method, marked_by, marked_at)
                  SELECT @l, TRIM(cr.regno), 'ABSENT', 'AUTO', @e, NOW()
                    FROM acad_course_registration cr
                    JOIN odel_course_space sp ON sp.id=@s
                   WHERE TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester
                     AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED'
                     AND NOT EXISTS (SELECT 1 FROM odel_attendance a WHERE a.lecture_id=@l AND TRIM(a.regno)=TRIM(cr.regno))",
                new MySqlParameter("@l", lectureId), new MySqlParameter("@e", empid), new MySqlParameter("@s", spaceId));

        LogActivity(empid, spaceId, "ATTENDANCE_CLOSED", "lecture", lectureId, absent + " auto-absent");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "lecture_id", lectureId }, { "marked_absent", absent } },
            absent > 0 ? "Register closed. " + absent + " student(s) recorded absent." : "Register closed");
    }

    /// <summary>
    /// action=attendance_bulk — mark many students at once (write).
    /// entries = "REGNO:STATUS,REGNO:STATUS,...". Every entry is validated before anything is
    /// written, so a typo in the last entry does not leave the first half of a register applied.
    /// </summary>
    private void HandleAttendanceBulk()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long lectureId = ApiHelper.ParamInt(Request, "lecture_id", 0);
        string entries = ApiHelper.Param(Request, "entries", "").Trim();
        if (spaceId <= 0 || lectureId <= 0 || entries == "")
        { ApiHelper.Error(Response, "space_id, lecture_id and entries are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        if (!LectureInSpace(lectureId, spaceId)) { ApiHelper.Error(Response, "Lecture not found in this space.", "NOT_FOUND"); return; }

        var parsed = new List<KeyValuePair<string, string>>();
        foreach (string raw in entries.Split(','))
        {
            string item = raw.Trim();
            if (item == "") continue;
            int colon = item.LastIndexOf(':');
            if (colon <= 0 || colon == item.Length - 1)
            { ApiHelper.Error(Response, "Each entry must be REGNO:STATUS — '" + item + "' is not. Nothing was marked.", "INVALID_PARAM"); return; }
            string regno = item.Substring(0, colon).Trim();
            string status = item.Substring(colon + 1).Trim().ToUpper();
            if (status != "PRESENT" && status != "ABSENT" && status != "LATE" && status != "EXCUSED" && status != "CLEAR")
            { ApiHelper.Error(Response, "Status '" + status + "' for " + regno + " must be PRESENT, ABSENT, LATE, EXCUSED or CLEAR. Nothing was marked.", "INVALID_PARAM"); return; }
            if (!StudentOnSpace(spaceId, regno))
            { ApiHelper.Error(Response, regno + " is not enrolled in this course space. Nothing was marked.", "VALIDATION_ERROR"); return; }
            parsed.Add(new KeyValuePair<string, string>(regno, status));
        }
        if (parsed.Count == 0) { ApiHelper.Error(Response, "entries contained no usable REGNO:STATUS pairs.", "VALIDATION_ERROR"); return; }

        int marked = 0, cleared = 0;
        foreach (var kv in parsed)
        {
            if (kv.Value == "CLEAR")
            {
                ApiHelper.ExecutePortal("DELETE FROM odel_attendance WHERE lecture_id=@l AND TRIM(regno)=TRIM(@r)",
                    new MySqlParameter("@l", lectureId), new MySqlParameter("@r", kv.Key));
                cleared++;
                continue;
            }
            ApiHelper.ExecutePortal(
                @"INSERT INTO odel_attendance (lecture_id, regno, status, method, marked_by, marked_at)
                  VALUES (@l,@r,@st,'MANUAL',@e,NOW())
                  ON DUPLICATE KEY UPDATE status=@st, method='MANUAL', marked_by=@e, marked_at=NOW()",
                new MySqlParameter("@l", lectureId), new MySqlParameter("@r", kv.Key),
                new MySqlParameter("@st", kv.Value), new MySqlParameter("@e", empid));
            marked++;
        }
        LogActivity(empid, spaceId, "ATTENDANCE_BULK", "lecture", lectureId, marked + " marked, " + cleared + " cleared");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "marked", marked }, { "cleared", cleared } },
            "Register updated: " + marked + " marked, " + cleared + " cleared");
    }

    // ═══════════════ lecturer: coursework push to official marks ═══════════════

    /// <summary>Space header used by the push actions.</summary>
    private class PushSpace { public long Id; public string CourseId; public string AcadYear; public int Semester; public string Title; }

    private static PushSpace LoadPushSpace(long spaceId)
    {
        DataTable dt = ApiHelper.QueryPortal(
            "SELECT id, courseID, acad_year, semester, title FROM odel_course_space WHERE id=@s LIMIT 1",
            new MySqlParameter("@s", spaceId));
        if (dt.Rows.Count == 0) return null;
        DataRow r = dt.Rows[0];
        return new PushSpace {
            Id = Convert.ToInt64(r["id"]), CourseId = Convert.ToString(r["courseID"]),
            AcadYear = Convert.ToString(r["acad_year"]), Semester = Convert.ToInt32(r["semester"]),
            Title = Convert.ToString(r["title"])
        };
    }

    /// <summary>Resolves an ODEL policy value, preferring a COURSE_TERM override over the institution default.</summary>
    private static string PushPolicy(string key, PushSpace sp, string fallback)
    {
        object o = ApiHelper.ScalarPortal(
            @"SELECT pvalue FROM odel_policy_value
               WHERE policy_key=@k AND active=1
                 AND ((scope_level='COURSE_TERM' AND scope_ref=@ref) OR scope_level='INSTITUTION')
               ORDER BY (scope_level='COURSE_TERM') DESC, id DESC LIMIT 1",
            new MySqlParameter("@k", key),
            new MySqlParameter("@ref", (sp.CourseId ?? "") + "|" + (sp.AcadYear ?? "") + "|" + sp.Semester));
        return (o == null || o == DBNull.Value) ? fallback : Convert.ToString(o);
    }

    /// <summary>
    /// Coursework from ODEL points. Mirrors OdelCore.CwFromPoints so the API and the portal screen
    /// can never disagree about a student's mark: same rounding (away from zero), same cap.
    /// </summary>
    private static int CwFromPoints(double points, int cwShare, double denominator)
    {
        if (denominator <= 0) return 0;
        int cw = (int)Math.Round(points * cwShare / denominator, MidpointRounding.AwayFromZero);
        if (cw < 0) cw = 0;
        int cap = cwShare < 40 ? cwShare : 40;
        return cw > cap ? cap : cw;
    }

    /// <summary>
    /// The per-student push rows for a space.
    /// ungradedAsZero=true  → denominator is the full published weight, so ungraded work counts as 0.
    /// ungradedAsZero=false → denominator is only what THIS student has had graded, i.e. "coursework
    ///                        out of what has been marked so far".
    /// </summary>
    private static DataTable PushRows(PushSpace sp, bool ungradedAsZero, int cwShare, double totalWeight)
    {
        return ApiHelper.QueryPortal(
            @"SELECT cr.ID AS reg_id, TRIM(cr.regno) AS regno,
                     TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) AS name,
                     cr.provisional_course_work_marks AS current_cw, cr.provisional_exam_marks AS exam,
                     IFNULL(cr.mark_stage,'') AS mark_stage, IFNULL(gb.odel_points,0) AS points,
                     (SELECT IFNULL(SUM(a2.weight_points),0) FROM odel_assignment a2
                        JOIN odel_submission s2 ON s2.assignment_id=a2.id AND s2.status='SUBMITTED'
                        JOIN odel_submission_grade g2 ON g2.submission_id=s2.id AND g2.is_current=1
                       WHERE a2.space_id=@sp AND a2.is_published=1 AND a2.counts_toward_cw=1
                         AND TRIM(s2.regno)=TRIM(cr.regno)) AS graded_weight
              FROM acad_course_registration cr
              LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(cr.regno)
              LEFT JOIN odel_gradebook gb ON gb.space_id=@sp AND TRIM(gb.regno)=TRIM(cr.regno)
             WHERE TRIM(cr.courseID)=TRIM(@c) AND cr.acad_year=@ay AND cr.semester=@sem
               AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED'
             ORDER BY cr.regno",
            new MySqlParameter("@sp", sp.Id), new MySqlParameter("@c", sp.CourseId),
            new MySqlParameter("@ay", sp.AcadYear), new MySqlParameter("@sem", sp.Semester));
    }

    /// <summary>A mark may only be overwritten while it is still the lecturer's to change.</summary>
    private static bool StageEditable(string stage)
    {
        return string.IsNullOrEmpty(stage) || stage == "NOT_ENTERED" || stage == "ENTERED";
    }

    /// <summary>
    /// action=push_preview — what a coursework push WOULD write, changing nothing (read).
    /// Always call this before push_commit: it reports ungraded work still outstanding and whether
    /// the published assignment weights actually add up to the coursework share.
    /// </summary>
    private void HandlePushPreview()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;
        PushSpace sp = LoadPushSpace(spaceId);
        if (sp == null) { ApiHelper.Error(Response, "Course space not found.", "NOT_FOUND"); return; }
        bool ungradedAsZero = ApiHelper.Param(Request, "ungraded_as_zero", "0") == "1";

        int cwShare; if (!int.TryParse(PushPolicy("cw_share", sp, "40"), out cwShare)) cwShare = 40;
        string cwMode = PushPolicy("cw_mode", sp, "PARTIAL");
        double totalWeight = Convert.ToDouble(ApiHelper.ScalarPortal(
            "SELECT IFNULL(SUM(weight_points),0) FROM odel_assignment WHERE space_id=@s AND is_published=1 AND counts_toward_cw=1",
            new MySqlParameter("@s", spaceId)));
        long ungraded = ToLong(ApiHelper.ScalarPortal(
            @"SELECT COUNT(*) FROM odel_submission s JOIN odel_assignment a ON a.id=s.assignment_id
               WHERE a.space_id=@s AND a.is_published=1 AND a.counts_toward_cw=1 AND s.status='SUBMITTED'
                 AND NOT EXISTS (SELECT 1 FROM odel_submission_grade g WHERE g.submission_id=s.id AND g.is_current=1)",
            new MySqlParameter("@s", spaceId)));

        DataTable dt = PushRows(sp, ungradedAsZero, cwShare, totalWeight);
        var rows = new List<Dictionary<string, object>>();
        int editable = 0, zeros = 0; double sum = 0;
        foreach (DataRow r in dt.Rows)
        {
            double points = Convert.ToDouble(r["points"]);
            double denom = ungradedAsZero ? totalWeight : Convert.ToDouble(r["graded_weight"]);
            int cw = CwFromPoints(points, cwShare, denom);
            string stage = Convert.ToString(r["mark_stage"]);
            bool ed = StageEditable(stage);
            if (ed) editable++;
            if (cw == 0) zeros++;
            sum += cw;
            rows.Add(new Dictionary<string, object> {
                { "regno", Convert.ToString(r["regno"]) }, { "name", Convert.ToString(r["name"]) },
                { "points", Math.Round(points, 2) }, { "graded_weight", Convert.ToDouble(r["graded_weight"]) },
                { "computed_cw", cw }, { "current_cw", r["current_cw"] == DBNull.Value ? null : r["current_cw"] },
                { "exam", r["exam"] == DBNull.Value ? null : r["exam"] },
                { "mark_stage", stage }, { "editable", ed }
            });
        }

        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "space", new Dictionary<string, object> {
                { "space_id", sp.Id }, { "course_id", sp.CourseId }, { "title", sp.Title },
                { "acad_year", sp.AcadYear }, { "semester", sp.Semester } } },
            { "cw_share", cwShare }, { "cw_mode", cwMode }, { "total_weight", totalWeight },
            { "ungraded_as_zero", ungradedAsZero },
            { "formula", "cw = round(points x " + cwShare + " / " + (ungradedAsZero ? totalWeight.ToString() : "the student's graded weight") + ")" },
            { "readiness", new Dictionary<string, object> {
                { "ungraded_submissions", ungraded },
                { "weight_mismatch", Math.Abs(totalWeight - cwShare) > 0.01 },
                { "weight_mismatch_note", Math.Abs(totalWeight - cwShare) > 0.01
                    ? "Published assignment weights total " + totalWeight + " but the coursework share is " + cwShare +
                      ". Marks are scaled to the share, so this is only a problem if it was not intended."
                    : "" },
                { "editable", editable }, { "locked", dt.Rows.Count - editable } } },
            { "stats", new Dictionary<string, object> {
                { "students", dt.Rows.Count },
                { "mean_cw", dt.Rows.Count > 0 ? Math.Round(sum / dt.Rows.Count, 1) : 0 },
                { "zeros", zeros } } },
            { "rows", rows }
        });
    }

    /// <summary>
    /// action=push_commit — write ODEL coursework into the official provisional marks (write).
    ///
    /// Only rows still at NOT_ENTERED or ENTERED are written; anything already submitted up the
    /// staged workflow (SUBMITTED/APPROVED/PUBLISHED) is counted as skipped and left exactly as it
    /// is, so a push can never overwrite a mark a Dean or Senate has already acted on.
    ///
    /// Every push is recorded as an immutable snapshot in odel_cw_push + odel_cw_push_detail,
    /// including the previous coursework value of each row, so any push can be audited afterwards.
    /// overrides_json = {"REGNO":{"cw":32,"reason":"..."}} replaces the computed value for a student.
    /// </summary>
    private void HandlePushCommit()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        PushSpace sp = LoadPushSpace(spaceId);
        if (sp == null) { ApiHelper.Error(Response, "Course space not found.", "NOT_FOUND"); return; }
        bool ungradedAsZero = ApiHelper.Param(Request, "ungraded_as_zero", "0") == "1";

        var overrides = new Dictionary<string, Dictionary<string, object>>(StringComparer.OrdinalIgnoreCase);
        string rawOverrides = ApiHelper.Param(Request, "overrides_json", "").Trim();
        if (rawOverrides != "")
        {
            try
            {
                var ser = new System.Web.Script.Serialization.JavaScriptSerializer();
                var parsed = ser.Deserialize<Dictionary<string, object>>(rawOverrides);
                foreach (var kv in parsed)
                {
                    var inner = kv.Value as Dictionary<string, object>;
                    if (inner != null) overrides[kv.Key.Trim()] = inner;
                }
            }
            catch (Exception ex)
            {
                ApiHelper.Error(Response, "overrides_json is not valid JSON: " + ex.Message, "INVALID_PARAM");
                return;
            }
        }

        int cwShare; if (!int.TryParse(PushPolicy("cw_share", sp, "40"), out cwShare)) cwShare = 40;
        string cwMode = PushPolicy("cw_mode", sp, "PARTIAL");
        double totalWeight = Convert.ToDouble(ApiHelper.ScalarPortal(
            "SELECT IFNULL(SUM(weight_points),0) FROM odel_assignment WHERE space_id=@s AND is_published=1 AND counts_toward_cw=1",
            new MySqlParameter("@s", spaceId)));
        DataTable dt = PushRows(sp, ungradedAsZero, cwShare, totalWeight);
        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "No approved students are enrolled in this course space.", "VALIDATION_ERROR"); return; }

        object verObj = ApiHelper.ScalarPortal("SELECT IFNULL(MAX(version),0)+1 FROM odel_cw_push WHERE space_id=@s",
            new MySqlParameter("@s", spaceId));
        int version = verObj == null || verObj == DBNull.Value ? 1 : Convert.ToInt32(verObj);
        long pushId = ApiHelper.ExecuteInsertPortal(
            @"INSERT INTO odel_cw_push (space_id, version, pushed_by_empid, pushed_at, cw_mode, odel_share,
                                        ungraded_as_zero, formula_note, student_count)
              VALUES (@s,@v,@e,NOW(),@m,@sh,@u,@f,@n)",
            new MySqlParameter("@s", spaceId), new MySqlParameter("@v", version), new MySqlParameter("@e", empid),
            new MySqlParameter("@m", cwMode), new MySqlParameter("@sh", cwShare),
            new MySqlParameter("@u", ungradedAsZero ? 1 : 0),
            new MySqlParameter("@f", "cw = round(points * " + cwShare + " / " + totalWeight + ")"),
            new MySqlParameter("@n", dt.Rows.Count));

        int written = 0, skipped = 0;
        foreach (DataRow r in dt.Rows)
        {
            string regno = Convert.ToString(r["regno"]);
            long regId = Convert.ToInt64(r["reg_id"]);
            double points = Convert.ToDouble(r["points"]);
            double denom = ungradedAsZero ? totalWeight : Convert.ToDouble(r["graded_weight"]);
            int computed = CwFromPoints(points, cwShare, denom);
            int finalCw = computed;
            object overrideCw = DBNull.Value, overrideReason = DBNull.Value;

            Dictionary<string, object> ov;
            if (overrides.TryGetValue(regno, out ov))
            {
                object cwo;
                if (ov.TryGetValue("cw", out cwo))
                {
                    int cwv;
                    if (int.TryParse(Convert.ToString(cwo), out cwv)) { finalCw = cwv; overrideCw = cwv; }
                }
                object ro;
                if (ov.TryGetValue("reason", out ro)) overrideReason = Convert.ToString(ro);
            }
            if (finalCw < 0) finalCw = 0;
            if (finalCw > 40) finalCw = 40;

            // Re-read the live mark inside the write step: the preview may be minutes old and the
            // mark may have moved up the staged workflow since.
            DataTable cur = ApiHelper.QueryPortal(
                "SELECT provisional_course_work_marks AS cw, provisional_exam_marks AS exam, IFNULL(mark_stage,'') AS stage FROM acad_course_registration WHERE ID=@id",
                new MySqlParameter("@id", regId));
            object prevCw = DBNull.Value, exam = DBNull.Value; string stage = "";
            if (cur.Rows.Count > 0) { prevCw = cur.Rows[0]["cw"]; exam = cur.Rows[0]["exam"]; stage = Convert.ToString(cur.Rows[0]["stage"]); }

            if (StageEditable(stage))
            {
                bool hasExam = exam != DBNull.Value;
                object total = hasExam ? (object)(finalCw + Convert.ToInt32(exam)) : finalCw;
                int n = ApiHelper.ExecutePortal(
                    @"UPDATE acad_course_registration
                         SET provisional_course_work_marks=@cw, provisional_total_marks=@tot,
                             provisional_marks_status=@ps, mark_stage=@ms,
                             mark_stage_changed_at=NOW(), mark_stage_changed_by=@by
                       WHERE ID=@id AND IFNULL(mark_stage,'NOT_ENTERED') IN ('NOT_ENTERED','ENTERED')",
                    new MySqlParameter("@cw", finalCw), new MySqlParameter("@tot", total),
                    new MySqlParameter("@ps", hasExam ? "pending" : "not_entered"),
                    new MySqlParameter("@ms", hasExam ? "ENTERED" : "NOT_ENTERED"),
                    new MySqlParameter("@by", "ODEL:" + empid), new MySqlParameter("@id", regId));
                if (n > 0) written++; else skipped++;
            }
            else skipped++;

            ApiHelper.ExecutePortal(
                @"INSERT INTO odel_cw_push_detail (push_id, regno, computed_points, computed_cw, override_cw,
                                                   override_reason, final_cw, prev_cw, mark_stage_at_push)
                  VALUES (@p,@r,@pts,@cc,@ov,@rs,@fc,@pv,@st)",
                new MySqlParameter("@p", pushId), new MySqlParameter("@r", regno),
                new MySqlParameter("@pts", Math.Round(points, 2)), new MySqlParameter("@cc", computed),
                new MySqlParameter("@ov", overrideCw), new MySqlParameter("@rs", overrideReason),
                new MySqlParameter("@fc", finalCw), new MySqlParameter("@pv", prevCw), new MySqlParameter("@st", stage));
        }

        LogActivity(empid, spaceId, "PUSHED", "space", spaceId, "Coursework push v" + version + ": " + written + " written, " + skipped + " skipped");
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "push_id", pushId }, { "version", version }, { "students", dt.Rows.Count },
            { "written", written }, { "skipped", skipped }
        }, skipped > 0
            ? written + " coursework mark(s) written. " + skipped + " were skipped because their marks have already moved beyond the lecturer stage."
            : written + " coursework mark(s) written.");
    }

    /// <summary>action=push_history — every past coursework push for a space (read).</summary>
    private void HandlePushHistory()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        if (spaceId <= 0) { ApiHelper.Error(Response, "space_id is required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT p.id AS push_id, p.version, p.pushed_at, p.cw_mode, p.odel_share, p.ungraded_as_zero,
                     p.formula_note, p.student_count, p.superseded_by, IFNULL(e.emp_name,'') AS pushed_by,
                     (SELECT COUNT(*) FROM odel_cw_push_detail d
                       WHERE d.push_id=p.id AND IFNULL(d.mark_stage_at_push,'') IN ('','NOT_ENTERED','ENTERED')) AS written,
                     (SELECT COUNT(*) FROM odel_cw_push_detail d WHERE d.push_id=p.id AND d.override_cw IS NOT NULL) AS overrides
              FROM odel_cw_push p
              LEFT JOIN campus_dynamics.hrm_employee e ON e.empID=p.pushed_by_empid
             WHERE p.space_id=@s ORDER BY p.version DESC",
            new MySqlParameter("@s", spaceId));
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "pushes", ApiHelper.TableToList(dt) }, { "count", dt.Rows.Count } });
    }

    /// <summary>action=push_snapshot — the frozen per-student detail of one past push (read).</summary>
    private void HandlePushSnapshot()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long pushId = ApiHelper.ParamInt(Request, "push_id", 0);
        if (spaceId <= 0 || pushId <= 0) { ApiHelper.Error(Response, "space_id and push_id are required.", "MISSING_PARAM"); return; }
        if (RequireStaffOnSpace(auth, spaceId) < 0) return;
        // Confirm the push belongs to this space before releasing another course's marks.
        object owns = ApiHelper.ScalarPortal("SELECT 1 FROM odel_cw_push WHERE id=@p AND space_id=@s LIMIT 1",
            new MySqlParameter("@p", pushId), new MySqlParameter("@s", spaceId));
        if (owns == null || owns == DBNull.Value) { ApiHelper.Error(Response, "Push not found in this space.", "NOT_FOUND"); return; }

        DataTable head = ApiHelper.QueryPortal(
            @"SELECT p.id AS push_id, p.version, p.pushed_at, p.cw_mode, p.odel_share, p.ungraded_as_zero,
                     p.formula_note, p.student_count, IFNULL(e.emp_name,'') AS pushed_by
              FROM odel_cw_push p LEFT JOIN campus_dynamics.hrm_employee e ON e.empID=p.pushed_by_empid
             WHERE p.id=@p", new MySqlParameter("@p", pushId));
        DataTable rows = ApiHelper.QueryPortal(
            @"SELECT d.regno, TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) AS name,
                     d.computed_points, d.computed_cw, d.override_cw, d.override_reason,
                     d.final_cw, d.prev_cw, d.mark_stage_at_push
              FROM odel_cw_push_detail d
              LEFT JOIN campus_dynamics.acad_student s ON TRIM(s.regno)=TRIM(d.regno)
             WHERE d.push_id=@p ORDER BY d.regno", new MySqlParameter("@p", pushId));

        Dictionary<string, object> h = ApiHelper.FirstRowToDict(head) ?? new Dictionary<string, object>();
        h["rows"] = ApiHelper.TableToList(rows);
        ApiHelper.Success(Response, h);
    }

    // ═══════════════════════════ lecturer: misc ═══════════════════════════

    /// <summary>
    /// action=update_pin — pin or unpin an announcement (write).
    /// Pinning is exclusive: pinning one announcement unpins the rest, because two "top" items in a
    /// list ordered by pinned DESC is just an arbitrary order with extra steps.
    /// </summary>
    private void HandleUpdatePin()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        long spaceId = ApiHelper.ParamInt(Request, "space_id", 0);
        long updateId = ApiHelper.ParamInt(Request, "update_id", 0);
        if (spaceId <= 0 || updateId <= 0) { ApiHelper.Error(Response, "space_id and update_id are required.", "MISSING_PARAM"); return; }
        int empid = RequireStaffOnSpace(auth, spaceId); if (empid < 0) return;
        int pin = ApiHelper.Param(Request, "pinned", "1") == "0" ? 0 : 1;

        object exists = ApiHelper.ScalarPortal("SELECT 1 FROM odel_course_update WHERE id=@id AND space_id=@s LIMIT 1",
            new MySqlParameter("@id", updateId), new MySqlParameter("@s", spaceId));
        if (exists == null || exists == DBNull.Value) { ApiHelper.Error(Response, "Announcement not found in this space.", "NOT_FOUND"); return; }

        if (pin == 1)
            ApiHelper.ExecutePortal("UPDATE odel_course_update SET pinned=0, updated_at=NOW() WHERE space_id=@s AND pinned=1 AND id<>@id",
                new MySqlParameter("@s", spaceId), new MySqlParameter("@id", updateId));
        ApiHelper.ExecutePortal("UPDATE odel_course_update SET pinned=@p, updated_at=NOW() WHERE id=@id AND space_id=@s",
            new MySqlParameter("@p", pin), new MySqlParameter("@id", updateId), new MySqlParameter("@s", spaceId));
        LogActivity(empid, spaceId, pin == 1 ? "PINNED" : "UNPINNED", "update", updateId, "");
        ApiHelper.Success(Response, new Dictionary<string, object> { { "update_id", updateId }, { "pinned", pin } },
            pin == 1 ? "Announcement pinned to the top" : "Announcement unpinned");
    }

    /// <summary>
    /// action=teaching_summary — one screen of "what needs me" across every space I teach (read).
    /// Answers the question a lecturer actually opens the app with: where is work waiting to be
    /// graded, which registers are still open, and which courses have never been pushed to marks.
    /// </summary>
    private void HandleTeachingSummary()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        int empid = RequireStaff(auth); if (empid < 0) return;

        DataTable dt = ApiHelper.QueryPortal(
            @"SELECT sp.id AS space_id, sp.courseID AS course_id, sp.title, sp.acad_year, sp.semester, sp.status,
                     (SELECT COUNT(*) FROM acad_course_registration cr
                       WHERE TRIM(cr.courseID)=TRIM(sp.courseID) AND cr.acad_year=sp.acad_year AND cr.semester=sp.semester
                         AND UPPER(IFNULL(cr.lecturer_status,'APPROVED'))='APPROVED') AS roster,
                     (SELECT COUNT(*) FROM odel_assignment a WHERE a.space_id=sp.id AND a.is_published=1) AS published_assignments,
                     (SELECT COUNT(*) FROM odel_assignment a WHERE a.space_id=sp.id AND a.is_published=0) AS draft_assignments,
                     (SELECT COUNT(*) FROM odel_submission s JOIN odel_assignment a ON a.id=s.assignment_id
                       WHERE a.space_id=sp.id AND s.status='SUBMITTED'
                         AND NOT EXISTS(SELECT 1 FROM odel_submission_grade g WHERE g.submission_id=s.id AND g.is_current=1)) AS awaiting_grading,
                     (SELECT COUNT(*) FROM odel_lecture l WHERE l.space_id=sp.id AND l.attendance_open=1) AS registers_open,
                     (SELECT COUNT(*) FROM odel_lecture l WHERE l.space_id=sp.id AND l.status='PENDING'
                         AND l.scheduled_start >= NOW()) AS upcoming_lectures,
                     (SELECT COUNT(*) FROM odel_cw_push p WHERE p.space_id=sp.id) AS pushes,
                     (SELECT MAX(p.pushed_at) FROM odel_cw_push p WHERE p.space_id=sp.id) AS last_push_at
              FROM odel_course_space sp
             WHERE EXISTS(SELECT 1 FROM odel_space_staff ss WHERE ss.space_id=sp.id AND ss.empid=@e)
                OR EXISTS(SELECT 1 FROM campus_dynamics.acad_programmecourses pc
                          WHERE TRIM(pc.course_code)=TRIM(sp.courseID) AND pc.semester=sp.semester AND pc.lecturer_id=@e)
             ORDER BY sp.acad_year DESC, sp.semester DESC, sp.courseID",
            new MySqlParameter("@e", empid));

        var spaces = ApiHelper.TableToList(dt);
        long grading = 0, openRegs = 0, upcoming = 0, neverPushed = 0;
        foreach (var s in spaces)
        {
            grading  += Convert.ToInt64(s["awaiting_grading"]);
            openRegs += Convert.ToInt64(s["registers_open"]);
            upcoming += Convert.ToInt64(s["upcoming_lectures"]);
            if (Convert.ToInt64(s["pushes"]) == 0) neverPushed++;
        }
        ApiHelper.Success(Response, new Dictionary<string, object> {
            { "spaces", spaces },
            { "totals", new Dictionary<string, object> {
                { "spaces", spaces.Count }, { "awaiting_grading", grading },
                { "registers_open", openRegs }, { "upcoming_lectures", upcoming },
                { "courses_never_pushed", neverPushed } } }
        });
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
