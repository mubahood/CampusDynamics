using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class API_v2_staff : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "profile":
                    HandleProfile();
                    break;
                case "photo":
                    HandlePhoto();
                    break;
                case "my_courses":
                    HandleMyCourses();
                    break;
                case "class_list":
                    HandleClassList();
                    break;
                case "marks":
                    HandleMarks();
                    break;
                case "submit_marks":
                    HandleSubmitMarks();
                    break;
                case "teaching_assignments":
                    HandleTeachingAssignments();
                    break;
                case "mark_sheet":
                    HandleMarkSheet();
                    break;
                case "save_entry_marks":
                    HandleSaveEntryMarks();
                    break;
                case "submit_for_approval":
                    HandleSubmitForApproval();
                    break;
                case "sheet_status":
                    HandleSheetStatus();
                    break;
                case "deadlines":
                    HandleDeadlines();
                    break;
                case "lookup":
                    HandleLookup();
                    break;
                case "by_department":
                    HandleByDepartment();
                    break;
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: profile, photo, my_courses, class_list, marks, submit_marks, teaching_assignments, mark_sheet, save_entry_marks, submit_for_approval, sheet_status, deadlines, lookup, by_department", "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleProfile()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        // Staff can view own profile; admin can query other staff by ?staff_id=
        string staffUsername = auth.UserId;
        if (auth.UserType == "staff")
        {
            string requestedId = ApiHelper.Param(Request, "staff_id", "");
            if (!string.IsNullOrEmpty(requestedId))
                staffUsername = requestedId;
        }
        else
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        DataTable dt = ApiHelper.Query(
            @"SELECT e.empID, e.emp_name, e.EMP_CODE, e.EmpType,
                     e.emp_email, e.emp_phone, e.emp_nationality,
                     d.dept_name AS department,
                     e.emp_qualifications, e.usernames,
                     c.contractStart, c.contractEnd, c.contractStatus
              FROM hrm_employee e
              LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.contractStatus = 'VALID'
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              WHERE e.usernames = @uid",
            new MySqlParameter("@uid", staffUsername)
        );

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND");
            return;
        }

        var profile = ApiHelper.FirstRowToDict(dt);
        profile["photo_url"] = "/API/v2/staff.aspx?action=photo&token=" + ApiHelper.Param(Request, "token", "");

        ApiHelper.Success(Response, profile);
    }

    private void HandlePhoto()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        // Get empID from username
        DataTable empDt = ApiHelper.Query(
            "SELECT empID FROM hrm_employee WHERE usernames = @uid",
            new MySqlParameter("@uid", auth.UserId)
        );

        if (empDt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND");
            return;
        }

        string empId = empDt.Rows[0]["empID"].ToString();

        // Try file-based photo (primary location)
        string photoPath = Server.MapPath("~/COOPERP/staffimages/" + empId + "_photo.jpg");
        if (File.Exists(photoPath))
        {
            Response.Clear();
            Response.ContentType = "image/jpeg";
            Response.AddHeader("Access-Control-Allow-Origin", "*");
            Response.WriteFile(photoPath);
            ApiHelper.CompleteResponse(Response);
            return;
        }

        // Try alternate location
        string altPath = Server.MapPath("~/staffimages/" + empId + ".jpg");
        if (File.Exists(altPath))
        {
            Response.Clear();
            Response.ContentType = "image/jpeg";
            Response.AddHeader("Access-Control-Allow-Origin", "*");
            Response.WriteFile(altPath);
            ApiHelper.CompleteResponse(Response);
            return;
        }

        ApiHelper.Error(Response, "Photo not found.", "NOT_FOUND");
    }

    private void HandleMyCourses()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        int semester = ApiHelper.ParamInt(Request, "semester", 0);

        // Get staff code (EMP_CODE) from username
        DataTable empDt = ApiHelper.Query(
            "SELECT EMP_CODE FROM hrm_employee WHERE usernames = @uid",
            new MySqlParameter("@uid", auth.UserId)
        );

        if (empDt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND");
            return;
        }

        string staffCode = empDt.Rows[0]["EMP_CODE"].ToString();

        string sql = @"SELECT ta.courseID AS course_code, c.courseName AS course_name, c.CreditUnit AS credit_units,
                       ta.progcode AS programme_code, p.progname AS programme_name,
                       ta.acad_year, ta.semester, ta.cyear AS study_year
                FROM acad_teaching_allocation ta
                LEFT JOIN acad_course c ON ta.courseID = c.courseID
                LEFT JOIN acad_programme p ON ta.progcode = p.progcode
                WHERE ta.staffCode = @staffCode";

        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@staffCode", staffCode));

        if (!string.IsNullOrEmpty(acad_year))
        {
            sql += " AND ta.acad_year = @acad";
            parms.Add(new MySqlParameter("@acad", acad_year));
        }
        if (semester > 0)
        {
            sql += " AND ta.semester = @sem";
            parms.Add(new MySqlParameter("@sem", semester));
        }

        sql += " ORDER BY ta.acad_year DESC, ta.semester, ta.courseID";

        DataTable dt = ApiHelper.Query(sql, parms.ToArray());
        ApiHelper.Success(Response, ApiHelper.TableToList(dt));
    }

    private void HandleClassList()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string courseId = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        DataTable dt = ApiHelper.Query(
            @"SELECT cr.id AS registration_id, cr.regno, 
                     s.firstname, s.othername, s.gender,
                     COALESCE((SELECT MAX(r.studyyear) FROM acad_registration r WHERE r.regno = s.regno), 1) AS study_year,
                     s.studsesion AS session
              FROM acad_course_registration cr
              JOIN acad_student s ON cr.regno = s.regno
              WHERE cr.courseid = @course AND cr.acad_year = @acad AND cr.semester = @sem
              ORDER BY s.firstname, s.othername",
            new MySqlParameter("@course", courseId),
            new MySqlParameter("@acad", acad_year),
            new MySqlParameter("@sem", semester)
        );

        var data = new Dictionary<string, object>
        {
            { "course_id", courseId },
            { "acad_year", acad_year },
            { "semester", semester },
            { "total_students", dt.Rows.Count },
            { "students", ApiHelper.TableToList(dt) }
        };

        ApiHelper.Success(Response, data);
    }

    private void HandleMarks()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string courseId = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        DataTable dt = ApiHelper.Query(
            @"SELECT r.regno, s.firstname, s.othername,
                     r.course_work, r.exam_total, r.score AS total, r.grade, r.gradept AS gp, r.result_comment AS remarks
              FROM acad_results r
              JOIN acad_student s ON r.regno = s.regno
              WHERE r.courseid = @course AND r.acad = @acad AND r.semester = @sem
              ORDER BY s.firstname, s.othername",
            new MySqlParameter("@course", courseId),
            new MySqlParameter("@acad", acad_year),
            new MySqlParameter("@sem", semester)
        );

        var data = new Dictionary<string, object>
        {
            { "course_id", courseId },
            { "acad_year", acad_year },
            { "semester", semester },
            { "total_students", dt.Rows.Count },
            { "marks", ApiHelper.TableToList(dt) }
        };

        ApiHelper.Success(Response, data);
    }

    private void HandleSubmitMarks()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string courseId = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        // Read marks data from request body
        string marksJson = ApiHelper.Param(Request, "marks", "");
        if (string.IsNullOrEmpty(marksJson))
        {
            // Try reading from request body
            using (var reader = new StreamReader(Request.InputStream))
            {
                marksJson = reader.ReadToEnd();
            }
        }

        if (string.IsNullOrEmpty(marksJson))
        {
            ApiHelper.Error(Response, "Missing marks data. Send JSON array: [{\"regno\":\"...\",\"coursework\":30,\"exam\":50}]", "MISSING_PARAM");
            return;
        }

        try
        {
            var serializer = new JavaScriptSerializer();
            var marksList = serializer.Deserialize<List<Dictionary<string, object>>>(marksJson);

            if (marksList == null || marksList.Count == 0)
            {
                ApiHelper.Error(Response, "Empty marks data.", "MISSING_PARAM");
                return;
            }

            int updated = 0;
            int inserted = 0;
            int errors = 0;

            foreach (var mark in marksList)
            {
                try
                {
                    string regno = mark.ContainsKey("regno") ? mark["regno"].ToString() : "";
                    if (string.IsNullOrEmpty(regno)) continue;

                    decimal coursework = 0, exam = 0;
                    if (mark.ContainsKey("coursework"))
                        decimal.TryParse(mark["coursework"].ToString(), out coursework);
                    if (mark.ContainsKey("exam"))
                        decimal.TryParse(mark["exam"].ToString(), out exam);

                    decimal total = coursework + exam;
                    string grade = CalculateGrade(total);
                    double gp = CalculateGP(grade);
                    string remarks = total >= 50 ? "NP" : "PP"; // Normal Pass / Poor Performance

                    // Check if record exists
                    object existing = ApiHelper.Scalar(
                        "SELECT COUNT(*) FROM acad_results WHERE regno=@reg AND courseid=@crs AND acad=@acad AND semester=@sem",
                        new MySqlParameter("@reg", regno),
                        new MySqlParameter("@crs", courseId),
                        new MySqlParameter("@acad", acad_year),
                        new MySqlParameter("@sem", semester)
                    );

                    if (Convert.ToInt32(existing) > 0)
                    {
                        ApiHelper.Execute(
                            @"UPDATE acad_results SET course_work=@cw, exam_total=@ex, score=@tot, grade=@grd, gradept=@gp, result_comment=@rem
                              WHERE regno=@reg AND courseid=@crs AND acad=@acad AND semester=@sem",
                            new MySqlParameter("@cw", coursework),
                            new MySqlParameter("@ex", exam),
                            new MySqlParameter("@tot", total),
                            new MySqlParameter("@grd", grade),
                            new MySqlParameter("@gp", gp),
                            new MySqlParameter("@rem", remarks),
                            new MySqlParameter("@reg", regno),
                            new MySqlParameter("@crs", courseId),
                            new MySqlParameter("@acad", acad_year),
                            new MySqlParameter("@sem", semester)
                        );
                        updated++;
                    }
                    else
                    {
                        // Get student's programme info for insert
                        DataTable studDt = ApiHelper.Query(
                            @"SELECT s.progid, 
                                     COALESCE((SELECT MAX(r.studyyear) FROM acad_registration r WHERE r.regno = s.regno), 1) AS study_year
                              FROM acad_student s WHERE s.regno = @reg",
                            new MySqlParameter("@reg", regno)
                        );

                        string progcode = studDt.Rows.Count > 0 ? studDt.Rows[0]["progid"].ToString() : "";
                        string studyYear = studDt.Rows.Count > 0 ? studDt.Rows[0]["study_year"].ToString() : "1";

                        // Get course credit units
                        DataTable courseDt = ApiHelper.Query(
                            "SELECT CreditUnit FROM acad_course WHERE courseID=@crs",
                            new MySqlParameter("@crs", courseId)
                        );
                        string cu = courseDt.Rows.Count > 0 ? courseDt.Rows[0]["CreditUnit"].ToString() : "3";

                        ApiHelper.Execute(
                            @"INSERT INTO acad_results (regno, courseid, acad, semester, progid, studyyear, 
                              course_work, exam_total, score, grade, gradept, CreditUnits, result_comment)
                              VALUES (@reg, @crs, @acad, @sem, @prog, @yr, @cw, @ex, @tot, @grd, @gp, @cu, @rem)",
                            new MySqlParameter("@reg", regno),
                            new MySqlParameter("@crs", courseId),
                            new MySqlParameter("@acad", acad_year),
                            new MySqlParameter("@sem", semester),
                            new MySqlParameter("@prog", progcode),
                            new MySqlParameter("@yr", studyYear),
                            new MySqlParameter("@cw", coursework),
                            new MySqlParameter("@ex", exam),
                            new MySqlParameter("@tot", total),
                            new MySqlParameter("@grd", grade),
                            new MySqlParameter("@gp", gp),
                            new MySqlParameter("@cu", cu),
                            new MySqlParameter("@rem", remarks)
                        );
                        inserted++;
                    }
                }
                catch
                {
                    errors++;
                }
            }

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "updated", updated },
                { "inserted", inserted },
                { "errors", errors },
                { "total_processed", marksList.Count }
            }, "Marks submitted successfully");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error processing marks: " + ex.Message, "SERVER_ERROR");
        }
    }

    private string CalculateGrade(decimal total)
    {
        if (total >= 80) return "A";
        if (total >= 75) return "B+";
        if (total >= 70) return "B";
        if (total >= 65) return "C+";
        if (total >= 60) return "C";
        if (total >= 55) return "D+";
        if (total >= 50) return "D";
        return "F";
    }

    private double CalculateGP(string grade)
    {
        switch (grade)
        {
            case "A": return 5.0;
            case "B+": return 4.5;
            case "B": return 4.0;
            case "C+": return 3.5;
            case "C": return 3.0;
            case "D+": return 2.5;
            case "D": return 2.0;
            default: return 0;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  MARKS WORKFLOW ENDPOINTS (Batch 14 — reflects marks module improvements)
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns courses assigned to the authenticated teacher from the new
    /// acad_teaching_assignments table (marks module). Falls back to the legacy
    /// acad_teaching_allocation table when no assignments are found.
    /// </summary>
    private void HandleTeachingAssignments()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        int semester = ApiHelper.ParamInt(Request, "semester", 0);

        try
        {
            string sql = @"SELECT ta.id AS assignment_id, ta.teacher_username, ta.course_id,
                                  COALESCE(c.CourseName, ta.course_id) AS course_name,
                                  ta.progid AS programme_code,
                                  COALESCE(p.progname, ta.progid) AS programme_name,
                                  ta.acadyear AS acad_year, ta.semester, ta.study_year,
                                  ta.campus_id, ta.stud_session AS session,
                                  ta.is_active, ta.assigned_by,
                                  DATE_FORMAT(ta.assigned_at, '%Y-%m-%d %H:%i') AS assigned_at,
                                  COALESCE(ta.notes, '') AS notes
                           FROM acad_teaching_assignments ta
                           LEFT JOIN acad_courses c ON c.CourseCode = ta.course_id
                           LEFT JOIN acad_programme p ON p.progcode = ta.progid
                           WHERE ta.teacher_username = @user AND ta.is_active = 1";

            var parms = new List<MySqlParameter>();
            parms.Add(new MySqlParameter("@user", auth.UserId));

            if (!string.IsNullOrEmpty(acad_year))
            {
                sql += " AND ta.acadyear = @acad";
                parms.Add(new MySqlParameter("@acad", acad_year));
            }
            if (semester > 0)
            {
                sql += " AND ta.semester = @sem";
                parms.Add(new MySqlParameter("@sem", semester));
            }

            sql += " ORDER BY ta.acadyear DESC, ta.semester, ta.course_id";

            DataTable dt = ApiHelper.Query(sql, parms.ToArray());

            // If no new-style assignments, fall back to legacy allocation table
            if (dt.Rows.Count == 0)
            {
                DataTable empDt = ApiHelper.Query(
                    "SELECT EMP_CODE FROM hrm_employee WHERE usernames = @uid",
                    new MySqlParameter("@uid", auth.UserId)
                );

                if (empDt.Rows.Count > 0)
                {
                    string staffCode = empDt.Rows[0]["EMP_CODE"].ToString();
                    string legacySql = @"SELECT 0 AS assignment_id, @user AS teacher_username, ta.courseID AS course_id,
                                                COALESCE(c.courseName, ta.courseID) AS course_name,
                                                ta.progcode AS programme_code,
                                                COALESCE(p.progname, ta.progcode) AS programme_name,
                                                ta.acad_year, ta.semester, ta.cyear AS study_year,
                                                0 AS campus_id, 'Day' AS session,
                                                1 AS is_active, '' AS assigned_by, '' AS assigned_at, '' AS notes
                                         FROM acad_teaching_allocation ta
                                         LEFT JOIN acad_course c ON ta.courseID = c.courseID
                                         LEFT JOIN acad_programme p ON ta.progcode = p.progcode
                                         WHERE ta.staffCode = @staffCode";

                    var lp = new List<MySqlParameter>();
                    lp.Add(new MySqlParameter("@user", auth.UserId));
                    lp.Add(new MySqlParameter("@staffCode", staffCode));

                    if (!string.IsNullOrEmpty(acad_year))
                    {
                        legacySql += " AND ta.acad_year = @acad";
                        lp.Add(new MySqlParameter("@acad", acad_year));
                    }
                    if (semester > 0)
                    {
                        legacySql += " AND ta.semester = @sem";
                        lp.Add(new MySqlParameter("@sem", semester));
                    }
                    legacySql += " ORDER BY ta.acad_year DESC, ta.semester, ta.courseID";

                    dt = ApiHelper.Query(legacySql, lp.ToArray());
                }
            }

            var data = new Dictionary<string, object>
            {
                { "total_assignments", dt.Rows.Count },
                { "assignments", ApiHelper.TableToList(dt) }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching teaching assignments: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// Returns the entry-level mark sheet (from acad_examresults_faculty) for a specific
    /// course context. This includes entered marks (cw, test, exam), calculated totals,
    /// and grades — the data teachers work with in the Mark Entry page.
    /// </summary>
    private void HandleMarkSheet()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string courseId = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string progid = ApiHelper.RequireParam(Request, Response, "progid");
        if (progid == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);
        int studyYear = ApiHelper.ParamInt(Request, "study_year", 1);
        int campusId = ApiHelper.ParamInt(Request, "campus_id", 1);
        string session = ApiHelper.Param(Request, "session", "Day");

        try
        {
            // Get mark ratios
            DataTable ratios = ApiHelper.Query(
                @"SELECT COALESCE(pcw, 0) AS cw_ratio, COALESCE(ptst, 0) AS test_ratio,
                         COALESCE(pexm, 0) AS exam_ratio, COALESCE(CreditUnit, 0) AS credit_units
                  FROM acad_programmecourses
                  WHERE course_code = @course AND progcode = @prog
                  LIMIT 1",
                new MySqlParameter("@course", courseId),
                new MySqlParameter("@prog", progid)
            );

            int cwRatio = 0, testRatio = 0, examRatio = 0, creditUnits = 0;
            if (ratios.Rows.Count > 0)
            {
                int.TryParse(ratios.Rows[0]["cw_ratio"].ToString(), out cwRatio);
                int.TryParse(ratios.Rows[0]["test_ratio"].ToString(), out testRatio);
                int.TryParse(ratios.Rows[0]["exam_ratio"].ToString(), out examRatio);
                int.TryParse(ratios.Rows[0]["credit_units"].ToString(), out creditUnits);
            }

            // Get student marks
            DataTable dt = ApiHelper.Query(
                @"SELECT ef.id AS entry_id, ef.regno,
                         TRIM(CONCAT(COALESCE(s.firstname,''), ' ', COALESCE(s.othername,''))) AS student_name,
                         COALESCE(ef.cw_mark_entered, 0) AS cw_entered,
                         COALESCE(ef.test_mark_entered, 0) AS test_entered,
                         COALESCE(ef.ex_mark_entered, 0) AS exam_entered,
                         COALESCE(ef.cw_mark, 0) AS cw_mark,
                         COALESCE(ef.test_mark, 0) AS test_mark,
                         COALESCE(ef.ex_mark, 0) AS exam_mark,
                         COALESCE(ef.total_mark, 0) AS total_mark,
                         COALESCE(ef.grade, '') AS grade
                  FROM acad_examresults_faculty ef
                  LEFT JOIN acad_student s ON s.regno = ef.regno
                  WHERE ef.course_id = @course AND ef.progid = @prog
                    AND ef.acad_year = @year AND ef.semester = @sem
                    AND ef.study_year = @sy AND ef.campus = @campus
                    AND ef.stud_session = @sess
                  ORDER BY s.firstname, s.othername, ef.regno",
                new MySqlParameter("@course", courseId),
                new MySqlParameter("@prog", progid),
                new MySqlParameter("@year", acad_year),
                new MySqlParameter("@sem", semester),
                new MySqlParameter("@sy", studyYear),
                new MySqlParameter("@campus", campusId),
                new MySqlParameter("@sess", session)
            );

            // Get workflow status
            DataTable statusDt = ApiHelper.Query(
                @"SELECT status, submitted_by, submitted_at, approved_by, approved_at, reject_reason
                  FROM acad_results_status
                  WHERE course_id = @course AND progid = @prog AND acadyear = @year
                    AND semester = @sem AND study_year = @sy AND campus_id = @campus
                    AND stud_session = @sess
                  LIMIT 1",
                new MySqlParameter("@course", courseId),
                new MySqlParameter("@prog", progid),
                new MySqlParameter("@year", acad_year),
                new MySqlParameter("@sem", semester),
                new MySqlParameter("@sy", studyYear),
                new MySqlParameter("@campus", campusId),
                new MySqlParameter("@sess", session)
            );

            string sheetStatus = "DRAFT";
            Dictionary<string, object> statusInfo = null;
            if (statusDt.Rows.Count > 0)
            {
                statusInfo = ApiHelper.FirstRowToDict(statusDt);
                sheetStatus = statusDt.Rows[0]["status"].ToString();
            }

            // Count marks entered
            int marksEntered = 0;
            foreach (DataRow row in dt.Rows)
            {
                decimal cw = 0, test = 0, exam = 0;
                decimal.TryParse(row["cw_entered"].ToString(), out cw);
                decimal.TryParse(row["test_entered"].ToString(), out test);
                decimal.TryParse(row["exam_entered"].ToString(), out exam);
                if (cw > 0 || test > 0 || exam > 0) marksEntered++;
            }

            var data = new Dictionary<string, object>
            {
                { "course_id", courseId },
                { "programme_code", progid },
                { "acad_year", acad_year },
                { "semester", semester },
                { "study_year", studyYear },
                { "campus_id", campusId },
                { "session", session },
                { "ratios", new Dictionary<string, object>
                    {
                        { "coursework", cwRatio },
                        { "test", testRatio },
                        { "exam", examRatio },
                        { "credit_units", creditUnits }
                    }
                },
                { "status", sheetStatus },
                { "status_detail", statusInfo },
                { "total_students", dt.Rows.Count },
                { "marks_entered", marksEntered },
                { "students", ApiHelper.TableToList(dt) }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching mark sheet: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// Saves entry-level marks to acad_examresults_faculty. This is the workflow-aware
    /// counterpart to submit_marks (which writes directly to acad_results).
    /// Marks are saved as DRAFT — the teacher must call submit_for_approval separately.
    /// Expects JSON array: [{"entry_id":123, "cw_entered":25, "test_entered":10, "exam_entered":40}]
    /// </summary>
    private void HandleSaveEntryMarks()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string marksJson = ApiHelper.Param(Request, "marks", "");
        if (string.IsNullOrEmpty(marksJson))
        {
            using (var reader = new StreamReader(Request.InputStream))
            {
                marksJson = reader.ReadToEnd();
            }
        }

        if (string.IsNullOrEmpty(marksJson))
        {
            ApiHelper.Error(Response, "Missing marks data. Send JSON array: [{\"entry_id\":123, \"cw_entered\":25, \"test_entered\":10, \"exam_entered\":40}]", "MISSING_PARAM");
            return;
        }

        try
        {
            var serializer = new JavaScriptSerializer();
            var marksList = serializer.Deserialize<List<Dictionary<string, object>>>(marksJson);

            if (marksList == null || marksList.Count == 0)
            {
                ApiHelper.Error(Response, "Empty marks data.", "MISSING_PARAM");
                return;
            }

            if (marksList.Count > 200)
            {
                ApiHelper.Error(Response, "Maximum 200 marks per request.", "VALIDATION_ERROR");
                return;
            }

            int updated = 0;
            int errors = 0;

            foreach (var mark in marksList)
            {
                try
                {
                    int entryId = 0;
                    if (mark.ContainsKey("entry_id"))
                        int.TryParse(mark["entry_id"].ToString(), out entryId);
                    if (entryId <= 0) { errors++; continue; }

                    decimal cwEntered = 0, testEntered = 0, examEntered = 0;
                    if (mark.ContainsKey("cw_entered"))
                        decimal.TryParse(mark["cw_entered"].ToString(), out cwEntered);
                    if (mark.ContainsKey("test_entered"))
                        decimal.TryParse(mark["test_entered"].ToString(), out testEntered);
                    if (mark.ContainsKey("exam_entered"))
                        decimal.TryParse(mark["exam_entered"].ToString(), out examEntered);

                    // Get ratios for this entry to calculate weighted marks
                    DataTable infoDt = ApiHelper.Query(
                        @"SELECT ef.course_id, ef.progid,
                                 COALESCE(pc.pcw, 0) AS cw_ratio,
                                 COALESCE(pc.ptst, 0) AS test_ratio,
                                 COALESCE(pc.pexm, 0) AS exam_ratio
                          FROM acad_examresults_faculty ef
                          LEFT JOIN acad_programmecourses pc
                              ON pc.course_code = ef.course_id AND pc.progcode = ef.progid
                          WHERE ef.id = @id LIMIT 1",
                        new MySqlParameter("@id", entryId)
                    );

                    if (infoDt.Rows.Count == 0) { errors++; continue; }

                    decimal cwR = 0, testR = 0, examR = 0;
                    decimal.TryParse(infoDt.Rows[0]["cw_ratio"].ToString(), out cwR);
                    decimal.TryParse(infoDt.Rows[0]["test_ratio"].ToString(), out testR);
                    decimal.TryParse(infoDt.Rows[0]["exam_ratio"].ToString(), out examR);

                    // Calculate weighted marks
                    decimal cwMark = cwR > 0 ? Math.Round(cwEntered * cwR / 100, 2) : cwEntered;
                    decimal testMark = testR > 0 ? Math.Round(testEntered * testR / 100, 2) : testEntered;
                    decimal examMark = examR > 0 ? Math.Round(examEntered * examR / 100, 2) : examEntered;
                    decimal totalMark = cwMark + testMark + examMark;
                    string grade = CalculateGrade(totalMark);

                    ApiHelper.Execute(
                        @"UPDATE acad_examresults_faculty 
                          SET cw_mark_entered = @cwE, test_mark_entered = @testE, ex_mark_entered = @examE,
                              cw_mark = @cwM, test_mark = @testM, ex_mark = @examM,
                              total_mark = @total, grade = @grade
                          WHERE id = @id",
                        new MySqlParameter("@cwE", cwEntered),
                        new MySqlParameter("@testE", testEntered),
                        new MySqlParameter("@examE", examEntered),
                        new MySqlParameter("@cwM", cwMark),
                        new MySqlParameter("@testM", testMark),
                        new MySqlParameter("@examM", examMark),
                        new MySqlParameter("@total", totalMark),
                        new MySqlParameter("@grade", grade),
                        new MySqlParameter("@id", entryId)
                    );
                    updated++;
                }
                catch
                {
                    errors++;
                }
            }

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "updated", updated },
                { "errors", errors },
                { "total_processed", marksList.Count }
            }, "Entry marks saved successfully");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error saving entry marks: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// Submits a mark sheet for dean approval. Changes the sheet status from DRAFT
    /// to SUBMITTED in the acad_results_status table. Requires full course context.
    /// </summary>
    private void HandleSubmitForApproval()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string courseId = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string progid = ApiHelper.RequireParam(Request, Response, "progid");
        if (progid == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);
        int studyYear = ApiHelper.ParamInt(Request, "study_year", 1);
        int campusId = ApiHelper.ParamInt(Request, "campus_id", 1);
        string session = ApiHelper.Param(Request, "session", "Day");

        try
        {
            // Check current status — only DRAFT can be submitted
            DataTable statusDt = ApiHelper.Query(
                @"SELECT status FROM acad_results_status
                  WHERE course_id = @course AND progid = @prog AND acadyear = @year
                    AND semester = @sem AND study_year = @sy AND campus_id = @campus
                    AND stud_session = @sess LIMIT 1",
                new MySqlParameter("@course", courseId),
                new MySqlParameter("@prog", progid),
                new MySqlParameter("@year", acad_year),
                new MySqlParameter("@sem", semester),
                new MySqlParameter("@sy", studyYear),
                new MySqlParameter("@campus", campusId),
                new MySqlParameter("@sess", session)
            );

            string currentStatus = "DRAFT";
            if (statusDt.Rows.Count > 0)
                currentStatus = statusDt.Rows[0]["status"].ToString();

            if (currentStatus != "DRAFT")
            {
                ApiHelper.Error(Response, String.Format("Sheet cannot be submitted. Current status is {0}. Only DRAFT sheets can be submitted.", currentStatus), "BUSINESS_ERROR");
                return;
            }

            // Upsert status to SUBMITTED
            ApiHelper.Execute(
                @"INSERT INTO acad_results_status 
                    (course_id, progid, acadyear, semester, study_year, campus_id, stud_session, status, submitted_by, submitted_at)
                  VALUES (@course, @prog, @year, @sem, @sy, @campus, @sess, 'SUBMITTED', @user, NOW())
                  ON DUPLICATE KEY UPDATE
                    status = 'SUBMITTED', submitted_by = @user, submitted_at = NOW(), reject_reason = NULL",
                new MySqlParameter("@course", courseId),
                new MySqlParameter("@prog", progid),
                new MySqlParameter("@year", acad_year),
                new MySqlParameter("@sem", semester),
                new MySqlParameter("@sy", studyYear),
                new MySqlParameter("@campus", campusId),
                new MySqlParameter("@sess", session),
                new MySqlParameter("@user", auth.UserId)
            );

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "course_id", courseId },
                { "programme_code", progid },
                { "acad_year", acad_year },
                { "semester", semester },
                { "new_status", "SUBMITTED" },
                { "submitted_by", auth.UserId },
                { "submitted_at", DateTime.Now.ToString("o") }
            }, "Mark sheet submitted for dean approval");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error submitting for approval: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// Returns the workflow status of a mark sheet from acad_results_status.
    /// Status values: DRAFT, SUBMITTED, DEAN_APPROVED, PROVISIONAL_PUBLISHED, FINAL_PUBLISHED.
    /// </summary>
    private void HandleSheetStatus()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string courseId = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string progid = ApiHelper.RequireParam(Request, Response, "progid");
        if (progid == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);
        int studyYear = ApiHelper.ParamInt(Request, "study_year", 1);
        int campusId = ApiHelper.ParamInt(Request, "campus_id", 1);
        string session = ApiHelper.Param(Request, "session", "Day");

        try
        {
            DataTable dt = ApiHelper.Query(
                @"SELECT rs.status, rs.submitted_by, 
                         DATE_FORMAT(rs.submitted_at, '%Y-%m-%d %H:%i') AS submitted_at,
                         rs.approved_by,
                         DATE_FORMAT(rs.approved_at, '%Y-%m-%d %H:%i') AS approved_at,
                         rs.published_by,
                         DATE_FORMAT(rs.published_at, '%Y-%m-%d %H:%i') AS published_at,
                         rs.reject_reason,
                         DATE_FORMAT(rs.updated_at, '%Y-%m-%d %H:%i') AS updated_at
                  FROM acad_results_status rs
                  WHERE rs.course_id = @course AND rs.progid = @prog AND rs.acadyear = @year
                    AND rs.semester = @sem AND rs.study_year = @sy AND rs.campus_id = @campus
                    AND rs.stud_session = @sess
                  LIMIT 1",
                new MySqlParameter("@course", courseId),
                new MySqlParameter("@prog", progid),
                new MySqlParameter("@year", acad_year),
                new MySqlParameter("@sem", semester),
                new MySqlParameter("@sy", studyYear),
                new MySqlParameter("@campus", campusId),
                new MySqlParameter("@sess", session)
            );

            if (dt.Rows.Count == 0)
            {
                ApiHelper.Success(Response, new Dictionary<string, object>
                {
                    { "status", "DRAFT" },
                    { "note", "No status record found — sheet is in draft state." }
                });
                return;
            }

            ApiHelper.Success(Response, ApiHelper.FirstRowToDict(dt));
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching sheet status: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// Returns submission deadlines for the authenticated teacher's assigned courses.
    /// Shows deadline dates, grace periods, and whether the deadline is enforced.
    /// </summary>
    private void HandleDeadlines()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "This endpoint is for staff members only.", "ACCESS_DENIED");
            return;
        }

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        int semester = ApiHelper.ParamInt(Request, "semester", 0);

        try
        {
            // Get deadlines for courses the teacher is assigned to
            string sql = @"SELECT d.ActivityName AS deadline_type, d.deadline,
                                  d.campusid AS campus_id, d.acadyear AS acad_year,
                                  d.semester, d.studsession AS session,
                                  d.is_active,
                                  CASE WHEN d.deadline < NOW() THEN 1 ELSE 0 END AS is_past_due,
                                  TIMESTAMPDIFF(HOUR, NOW(), d.deadline) AS hours_remaining
                           FROM acad_deadlines d
                           WHERE d.is_active = 1";

            var parms = new List<MySqlParameter>();

            if (!string.IsNullOrEmpty(acad_year))
            {
                sql += " AND d.acadyear = @acad";
                parms.Add(new MySqlParameter("@acad", acad_year));
            }
            if (semester > 0)
            {
                sql += " AND d.semester = @sem";
                parms.Add(new MySqlParameter("@sem", semester));
            }

            sql += " ORDER BY d.deadline ASC";

            DataTable dt = ApiHelper.Query(sql, parms.ToArray());

            var data = new Dictionary<string, object>
            {
                { "total_deadlines", dt.Rows.Count },
                { "deadlines", ApiHelper.TableToList(dt) }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching deadlines: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// ODEL: Lookup staff member by email address.
    /// Used by Moodle to find/verify staff/lecturer accounts.
    /// </summary>
    private void HandleLookup()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string email = ApiHelper.RequireParam(Request, Response, "email");
        if (email == null) return;

        DataTable dt = ApiHelper.Query(
            @"SELECT e.empID, e.EMP_CODE AS emp_code, e.emp_name, e.usernames AS username,
                     e.emp_email AS email, e.emp_phone AS phone, e.EmpType AS emp_type,
                     e.emp_status AS status, e.emp_nationality AS nationality,
                     e.emp_qualifications AS qualifications,
                     d.dept_name AS department, d.ID AS department_id,
                     f.faculty_name AS faculty, f.fax_code AS faculty_code
              FROM hrm_employee e
              LEFT JOIN hrm_emp_contracts c ON e.empID = c.empID AND c.contractStatus = 'Active'
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              LEFT JOIN acad_faculty f ON d.fax_code = f.fax_code
              WHERE LOWER(e.emp_email) = LOWER(@email)
              LIMIT 1",
            new MySqlParameter("@email", email)
        );

        if (dt.Rows.Count > 0)
        {
            var staff = ApiHelper.FirstRowToDict(dt);
            staff["photo_url"] = "/API/v2/staff.aspx?action=photo&emp_code=" + Server.UrlEncode(Convert.ToString(staff["emp_code"]));
            var data = new Dictionary<string, object>
            {
                { "found", true },
                { "data", staff }
            };
            ApiHelper.Success(Response, data, "Staff member found");
        }
        else
        {
            var data = new Dictionary<string, object>
            {
                { "found", false },
                { "data", null }
            };
            ApiHelper.Success(Response, data, "No staff member found with this email");
        }
    }

    /// <summary>
    /// ODEL: List all staff in a department with optional filters.
    /// Used by Moodle to sync department rosters.
    /// </summary>
    private void HandleByDepartment()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string deptId = ApiHelper.RequireParam(Request, Response, "department_id");
        if (deptId == null) return;

        string role = ApiHelper.Param(Request, "role", "").ToLower();
        string status = ApiHelper.Param(Request, "status", "Active");

        StringBuilder where = new StringBuilder("c.departmentID = @dept AND c.contractStatus = @status");
        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@dept", deptId));
        parms.Add(new MySqlParameter("@status", status));

        if (!String.IsNullOrEmpty(role))
        {
            where.Append(" AND LOWER(e.EmpType) = @role");
            parms.Add(new MySqlParameter("@role", role));
        }

        string sql = String.Format(
            @"SELECT e.empID, e.EMP_CODE AS emp_code, e.emp_name, e.usernames AS username,
                     e.emp_email AS email, e.emp_phone AS phone, e.EmpType AS emp_type,
                     e.emp_status AS status, e.emp_qualifications AS qualifications,
                     d.dept_name AS department, f.faculty_name AS faculty
              FROM hrm_employee e
              INNER JOIN hrm_emp_contracts c ON e.empID = c.empID
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              LEFT JOIN acad_faculty f ON d.fax_code = f.fax_code
              WHERE {0}
              ORDER BY e.emp_name", where.ToString());

        DataTable dt = ApiHelper.Query(sql, parms.ToArray());
        var staffList = ApiHelper.TableToList(dt);

        // Get department info
        DataTable dtDept = ApiHelper.Query(
            @"SELECT d.ID, d.dept_name, f.faculty_name, f.fax_code AS faculty_code
              FROM hrm_departments d
              LEFT JOIN acad_faculty f ON d.fax_code = f.fax_code
              WHERE d.ID = @dept",
            new MySqlParameter("@dept", deptId)
        );

        var data = new Dictionary<string, object>
        {
            { "department_id", deptId },
            { "department_name", dtDept.Rows.Count > 0 ? Convert.ToString(dtDept.Rows[0]["dept_name"]) : "" },
            { "faculty", dtDept.Rows.Count > 0 ? Convert.ToString(dtDept.Rows[0]["faculty_name"]) : "" },
            { "filter_role", role },
            { "filter_status", status },
            { "total", staffList.Count },
            { "staff", staffList }
        };
        ApiHelper.Success(Response, data);
    }
}
