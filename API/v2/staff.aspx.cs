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
                // ── Provisional Marks ──
                case "provisional_marks_list":
                    HandleProvisionalMarksList();
                    break;
                case "provisional_mark_detail":
                    HandleProvisionalMarkDetail();
                    break;
                case "save_provisional_mark":
                    HandleSaveProvisionalMark();
                    break;
                case "save_provisional_mark_inline":
                    HandleSaveProvisionalMarkInline();
                    break;
                case "provisional_marks_summary":
                    HandleProvisionalMarksSummary();
                    break;
                // ── HR Employees ──
                case "employees":
                    HandleEmployees();
                    break;
                case "employee":
                    HandleEmployee();
                    break;
                case "create_employee":
                    HandleCreateEmployee();
                    break;
                case "update_employee":
                    HandleUpdateEmployee();
                    break;
                case "update_contract":
                    HandleUpdateContract();
                    break;
                case "departments":
                    HandleDepartments();
                    break;
                // ── Mark Requests ──
                case "mark_requests_list":
                    HandleMarkRequestsList();
                    break;
                case "create_mark_request":
                    HandleCreateMarkRequest();
                    break;
                case "mark_request_detail":
                    HandleMarkRequestDetail();
                    break;
                case "cancel_mark_request":
                    HandleCancelMarkRequest();
                    break;
                case "admin_mark_requests":
                    HandleAdminMarkRequests();
                    break;
                case "decide_mark_request":
                    HandleDecideMarkRequest();
                    break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". Valid actions: profile, photo, my_courses, class_list, marks, submit_marks, " +
                        "teaching_assignments, mark_sheet, save_entry_marks, submit_for_approval, sheet_status, deadlines, lookup, by_department, " +
                        "provisional_marks_list, provisional_mark_detail, save_provisional_mark, save_provisional_mark_inline, provisional_marks_summary, " +
                        "employees, employee, create_employee, update_employee, update_contract, departments, " +
                        "mark_requests_list, create_mark_request, mark_request_detail, cancel_mark_request, admin_mark_requests, decide_mark_request",
                        "INVALID_ACTION");
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

            // ROB-07: Fetch mark-sheet maxima for this course/semester to validate scores
            decimal maxCoursework = 50m; // default
            decimal maxExam       = 60m; // default
            try
            {
                DataTable msDef = ApiHelper.Query(
                    @"SELECT max_coursework, max_exam FROM acad_mark_sheets
                      WHERE course_id = @crs AND acad_year = @acad AND semester = @sem LIMIT 1",
                    new MySqlParameter("@crs", courseId),
                    new MySqlParameter("@acad", acad_year),
                    new MySqlParameter("@sem", semester)
                );
                if (msDef.Rows.Count > 0)
                {
                    decimal msCw, msEx;
                    if (decimal.TryParse(msDef.Rows[0]["max_coursework"].ToString(), out msCw) && msCw > 0) maxCoursework = msCw;
                    if (decimal.TryParse(msDef.Rows[0]["max_exam"].ToString(), out msEx) && msEx > 0) maxExam = msEx;
                }
            }
            catch { /* table may not exist; use defaults */ }

            int updated = 0;
            int inserted = 0;
            int errors = 0;
            var validationErrors = new List<string>();

            foreach (var mark in marksList)
            {
                try
                {
                    string regno = mark.ContainsKey("regno") ? mark["regno"].ToString() : "";
                    if (string.IsNullOrEmpty(regno)) continue;

                    // ROB-07: Validate scores are numeric and within range
                    decimal coursework = 0, exam = 0;
                    bool cwValid = true, exValid = true;

                    if (mark.ContainsKey("coursework"))
                        cwValid = decimal.TryParse(mark["coursework"].ToString(), out coursework);
                    if (mark.ContainsKey("exam"))
                        exValid = decimal.TryParse(mark["exam"].ToString(), out exam);

                    if (!cwValid || !exValid)
                    {
                        validationErrors.Add(regno + ": scores must be numeric");
                        errors++; continue;
                    }
                    if (coursework < 0 || exam < 0)
                    {
                        validationErrors.Add(regno + ": scores cannot be negative");
                        errors++; continue;
                    }
                    if (coursework > maxCoursework)
                    {
                        validationErrors.Add(regno + ": coursework " + coursework + " exceeds max " + maxCoursework);
                        errors++; continue;
                    }
                    if (exam > maxExam)
                    {
                        validationErrors.Add(regno + ": exam " + exam + " exceeds max " + maxExam);
                        errors++; continue;
                    }

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

            var resultData = new Dictionary<string, object>
            {
                { "updated", updated },
                { "inserted", inserted },
                { "errors", errors },
                { "total_processed", marksList.Count },
                { "max_coursework", maxCoursework },
                { "max_exam", maxExam }
            };
            if (validationErrors.Count > 0)
                resultData["validation_errors"] = validationErrors;

            string msg = errors > 0
                ? "Marks partially submitted — " + errors + " error(s). Check validation_errors."
                : "Marks submitted successfully";
            ApiHelper.Success(Response, resultData, msg);
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

    // ═══════════════════════════════════════════════════════════════════
    //  PROVISIONAL MARKS
    // ═══════════════════════════════════════════════════════════════════

    private string GetLecturerEmpId(string username)
    {
        DataTable dt = ApiHelper.Query(
            "SELECT empID FROM hrm_employee WHERE usernames = @u LIMIT 1",
            new MySqlParameter("@u", username));
        return dt.Rows.Count > 0 ? dt.Rows[0]["empID"].ToString() : null;
    }

    private void HandleProvisionalMarksList()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string empId = GetLecturerEmpId(auth.UserId);
        if (empId == null) { ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND"); return; }

        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        int semester    = ApiHelper.ParamInt(Request, "semester", 0);
        string prog     = ApiHelper.Param(Request, "prog", "");
        string status   = ApiHelper.Param(Request, "status", "");
        string sq       = ApiHelper.Param(Request, "sq", "");
        int page        = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size        = Math.Min(200, Math.Max(1, ApiHelper.ParamInt(Request, "size", 50)));
        int offset      = (page - 1) * size;

        string baseFrom = @"FROM campus_dynamics_portal.acad_course_registration cr
                            LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(cr.regno)
                            LEFT JOIN acad_course c ON c.courseID = cr.courseID
                            INNER JOIN acad_programmecourses pc ON pc.course_code = cr.courseID
                              AND pc.progcode = cr.progid
                              AND pc.lecturer_id = @empId";

        var where = new System.Text.StringBuilder(" WHERE cr.regno IS NOT NULL");
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@empId", empId));

        if (!string.IsNullOrEmpty(acadYear)) { where.Append(" AND cr.acad_year = @ay"); parms.Add(new MySqlParameter("@ay", acadYear)); }
        if (semester > 0) { where.Append(" AND cr.semester = @sem"); parms.Add(new MySqlParameter("@sem", semester)); }
        if (!string.IsNullOrEmpty(prog)) { where.Append(" AND cr.progid = @prog"); parms.Add(new MySqlParameter("@prog", prog)); }
        if (!string.IsNullOrEmpty(status))
        {
            if (status == "not_entered")
                where.Append(" AND cr.provisional_total_marks IS NULL");
            else if (status == "pending")
                where.Append(" AND cr.provisional_total_marks IS NOT NULL AND COALESCE(cr.provisional_marks_status,'pending') = 'pending'");
            else
            {
                where.Append(" AND cr.provisional_marks_status = @status");
                parms.Add(new MySqlParameter("@status", status));
            }
        }
        if (!string.IsNullOrEmpty(sq))
        {
            where.Append(@" AND (TRIM(cr.regno) LIKE @sq
                             OR TRIM(IFNULL(s.entryno,'')) LIKE @sq
                             OR TRIM(IFNULL(s.firstname,'')) LIKE @sq
                             OR TRIM(IFNULL(s.othername,'')) LIKE @sq
                             OR CONCAT(TRIM(COALESCE(s.firstname,'')), ' ', TRIM(COALESCE(s.othername,''))) LIKE @sq)");
            parms.Add(new MySqlParameter("@sq", "%" + sq + "%"));
        }

        var countParms = new List<MySqlParameter>(parms);
        int total = Convert.ToInt32(ApiHelper.Scalar("SELECT COUNT(*) " + baseFrom + where, countParms.ToArray()));

        parms.Add(new MySqlParameter("@lim", size));
        parms.Add(new MySqlParameter("@off", offset));

        string dataSql = @"SELECT cr.id, TRIM(cr.regno) AS regno,
                                  CONCAT(TRIM(COALESCE(s.firstname,'')), ' ', TRIM(COALESCE(s.othername,''))) AS student_name,
                                  cr.courseID AS course_code, c.courseName AS course_name,
                                  cr.acad_year, cr.semester, cr.progid AS programme_code,
                                  cr.provisional_course_work_marks AS cw_marks,
                                  cr.provisional_exam_marks AS exam_marks,
                                  cr.provisional_total_marks AS total_marks,
                                  COALESCE(cr.provisional_marks_status, 'pending') AS prov_status "
                        + baseFrom + where
                        + " ORDER BY COALESCE(cr.provisional_marks_status,'pending'), s.firstname, s.othername LIMIT @lim OFFSET @off";

        DataTable dt = ApiHelper.Query(dataSql, parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "rows", ApiHelper.TableToList(dt) }
        });
    }

    private void HandleProvisionalMarkDetail()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        string empId = GetLecturerEmpId(auth.UserId);
        if (empId == null) { ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND"); return; }

        DataTable dt = ApiHelper.Query(
            @"SELECT cr.id, TRIM(cr.regno) AS regno,
                     CONCAT(TRIM(COALESCE(s.firstname,'')), ' ', TRIM(COALESCE(s.othername,''))) AS student_name,
                     cr.courseID AS course_code, c.courseName AS course_name,
                     cr.acad_year, cr.semester, cr.progid AS programme_code,
                     cr.provisional_course_work_marks AS cw_marks,
                     cr.provisional_exam_marks AS exam_marks,
                     cr.provisional_total_marks AS total_marks,
                     COALESCE(cr.provisional_marks_status,'pending') AS prov_status
              FROM campus_dynamics_portal.acad_course_registration cr
              LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(cr.regno)
              LEFT JOIN acad_course c ON c.courseID = cr.courseID
              INNER JOIN acad_programmecourses pc ON pc.course_code = cr.courseID
                AND pc.progcode = cr.progid AND pc.lecturer_id = @empId
              WHERE cr.id = @id LIMIT 1",
            new MySqlParameter("@empId", empId),
            new MySqlParameter("@id", id));

        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Record not found or you do not have access.", "NOT_FOUND"); return; }

        ApiHelper.Success(Response, ApiHelper.FirstRowToDict(dt));
    }

    private void HandleSaveProvisionalMark()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        string cwStr   = ApiHelper.RequireParam(Request, Response, "cw"); if (cwStr == null) return;
        string examStr = ApiHelper.RequireParam(Request, Response, "exam"); if (examStr == null) return;

        decimal cw, exam;
        if (!decimal.TryParse(cwStr, out cw) || !decimal.TryParse(examStr, out exam))
        {
            ApiHelper.Error(Response, "cw and exam must be numeric.", "VALIDATION_ERROR"); return;
        }
        if (cw < 0 || cw > 40) { ApiHelper.Error(Response, "Coursework must be 0–40.", "VALIDATION_ERROR"); return; }
        if (exam < 0 || exam > 60) { ApiHelper.Error(Response, "Exam must be 0–60.", "VALIDATION_ERROR"); return; }

        string empId = GetLecturerEmpId(auth.UserId);
        if (empId == null) { ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND"); return; }

        // Lock check
        DataTable lockDt = ApiHelper.Query(
            @"SELECT cr.id, COALESCE(cr.provisional_marks_status,'pending') AS prov_status
              FROM campus_dynamics_portal.acad_course_registration cr
              INNER JOIN acad_programmecourses pc ON pc.course_code = cr.courseID
                AND pc.progcode = cr.progid AND pc.lecturer_id = @empId
              WHERE cr.id = @id LIMIT 1",
            new MySqlParameter("@empId", empId),
            new MySqlParameter("@id", id));

        if (lockDt.Rows.Count == 0) { ApiHelper.Error(Response, "Record not found or access denied.", "NOT_FOUND"); return; }
        if (lockDt.Rows[0]["prov_status"].ToString() == "published")
        {
            ApiHelper.Error(Response, "This record is published and cannot be modified.", "MARKS_LOCKED"); return;
        }

        decimal total = cw + exam;

        ApiHelper.Execute(
            @"UPDATE campus_dynamics_portal.acad_course_registration
              SET provisional_course_work_marks = @cw,
                  provisional_exam_marks = @exam,
                  provisional_total_marks = @total,
                  provisional_marks_status = CASE WHEN provisional_marks_status IN ('approved','published') THEN provisional_marks_status ELSE 'pending' END
              WHERE id = @id",
            new MySqlParameter("@cw",    cw),
            new MySqlParameter("@exam",  exam),
            new MySqlParameter("@total", total),
            new MySqlParameter("@id",    id));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "id", id }, { "cw_marks", cw }, { "exam_marks", exam }, { "total_marks", total }
        }, "Provisional marks saved");
    }

    private void HandleSaveProvisionalMarkInline()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        int id    = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }
        string field = ApiHelper.RequireParam(Request, Response, "field"); if (field == null) return;
        string val   = ApiHelper.RequireParam(Request, Response, "value"); if (val == null) return;

        string empId = GetLecturerEmpId(auth.UserId);
        if (empId == null) { ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND"); return; }

        // Lock check + fetch current values
        DataTable lockDt = ApiHelper.Query(
            @"SELECT cr.id, COALESCE(cr.provisional_marks_status,'pending') AS prov_status,
                     COALESCE(cr.provisional_course_work_marks, 0) AS cur_cw,
                     COALESCE(cr.provisional_exam_marks, 0) AS cur_exam
              FROM campus_dynamics_portal.acad_course_registration cr
              INNER JOIN acad_programmecourses pc ON pc.course_code = cr.courseID
                AND pc.progcode = cr.progid AND pc.lecturer_id = @empId
              WHERE cr.id = @id LIMIT 1",
            new MySqlParameter("@empId", empId),
            new MySqlParameter("@id", id));

        if (lockDt.Rows.Count == 0) { ApiHelper.Error(Response, "Record not found or access denied.", "NOT_FOUND"); return; }
        if (lockDt.Rows[0]["prov_status"].ToString() == "published")
        {
            ApiHelper.Error(Response, "This record is published and cannot be modified.", "MARKS_LOCKED"); return;
        }

        decimal curCw   = Convert.ToDecimal(lockDt.Rows[0]["cur_cw"]);
        decimal curExam = Convert.ToDecimal(lockDt.Rows[0]["cur_exam"]);

        decimal newVal;
        if (!decimal.TryParse(val, out newVal))
        {
            ApiHelper.Error(Response, "value must be numeric.", "VALIDATION_ERROR"); return;
        }

        decimal newCw = curCw, newExam = curExam;
        if (field == "cw")
        {
            if (newVal < 0 || newVal > 40) { ApiHelper.Error(Response, "Coursework must be 0–40.", "VALIDATION_ERROR"); return; }
            newCw = newVal;
        }
        else if (field == "exam")
        {
            if (newVal < 0 || newVal > 60) { ApiHelper.Error(Response, "Exam must be 0–60.", "VALIDATION_ERROR"); return; }
            newExam = newVal;
        }
        else
        {
            ApiHelper.Error(Response, "field must be 'cw' or 'exam'.", "VALIDATION_ERROR"); return;
        }

        decimal total = newCw + newExam;

        ApiHelper.Execute(
            @"UPDATE campus_dynamics_portal.acad_course_registration
              SET provisional_course_work_marks = @cw,
                  provisional_exam_marks = @exam,
                  provisional_total_marks = @total,
                  provisional_marks_status = CASE WHEN provisional_marks_status IN ('approved','published') THEN provisional_marks_status ELSE 'pending' END
              WHERE id = @id",
            new MySqlParameter("@cw",    newCw),
            new MySqlParameter("@exam",  newExam),
            new MySqlParameter("@total", total),
            new MySqlParameter("@id",    id));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "id", id }, { "field", field }, { "new_value", newVal }, { "total_marks", total }
        }, "Mark saved inline");
    }

    private void HandleProvisionalMarksSummary()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string empId = GetLecturerEmpId(auth.UserId);
        if (empId == null) { ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND"); return; }

        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        int semester    = ApiHelper.ParamInt(Request, "semester", 0);

        var where = new System.Text.StringBuilder(" WHERE cr.regno IS NOT NULL");
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@empId", empId));

        if (!string.IsNullOrEmpty(acadYear)) { where.Append(" AND cr.acad_year = @ay"); parms.Add(new MySqlParameter("@ay", acadYear)); }
        if (semester > 0) { where.Append(" AND cr.semester = @sem"); parms.Add(new MySqlParameter("@sem", semester)); }

        string sql = @"SELECT cr.courseID AS course_code, c.courseName AS course_name,
                              cr.acad_year, cr.semester, cr.progid AS programme_code,
                              COUNT(*) AS total,
                              SUM(cr.provisional_total_marks IS NOT NULL) AS entered,
                              SUM(cr.provisional_total_marks IS NULL) AS not_entered,
                              SUM(COALESCE(cr.provisional_marks_status,'pending') = 'pending' AND cr.provisional_total_marks IS NOT NULL) AS pending,
                              SUM(cr.provisional_marks_status = 'approved') AS approved,
                              SUM(cr.provisional_marks_status = 'published') AS published
                       FROM campus_dynamics_portal.acad_course_registration cr
                       LEFT JOIN acad_course c ON c.courseID = cr.courseID
                       INNER JOIN acad_programmecourses pc ON pc.course_code = cr.courseID
                         AND pc.progcode = cr.progid AND pc.lecturer_id = @empId"
                    + where + " GROUP BY cr.courseID, cr.acad_year, cr.semester, cr.progid ORDER BY cr.acad_year DESC, cr.semester, cr.courseID";

        DataTable dt = ApiHelper.Query(sql, parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total_courses", dt.Rows.Count },
            { "courses", ApiHelper.TableToList(dt) }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HR EMPLOYEES
    // ═══════════════════════════════════════════════════════════════════

    private void HandleEmployees()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string dept   = ApiHelper.Param(Request, "dept", "");
        string type   = ApiHelper.Param(Request, "type", "");
        string status = ApiHelper.Param(Request, "status", "");
        string q      = ApiHelper.Param(Request, "q", "");
        int page      = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size      = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 20)));
        int offset    = (page - 1) * size;

        var where = new System.Text.StringBuilder("WHERE 1=1");
        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(dept)) { where.Append(" AND d.ID = @dept"); parms.Add(new MySqlParameter("@dept", dept)); }
        if (!string.IsNullOrEmpty(type)) { where.Append(" AND e.EmpType LIKE @type"); parms.Add(new MySqlParameter("@type", "%" + type + "%")); }
        if (!string.IsNullOrEmpty(status)) { where.Append(" AND e.emp_status = @st"); parms.Add(new MySqlParameter("@st", status)); }
        if (!string.IsNullOrEmpty(q))
        {
            where.Append(" AND (e.emp_name LIKE @q OR e.EMP_CODE LIKE @q OR e.emp_email LIKE @q)");
            parms.Add(new MySqlParameter("@q", "%" + q + "%"));
        }

        string baseSql = @"FROM hrm_employee e
                           LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.contractStatus = 'VALID'
                           LEFT JOIN hrm_departments d ON c.departmentID = d.ID " + where;

        var countParms = new List<MySqlParameter>(parms);
        int total = Convert.ToInt32(ApiHelper.Scalar("SELECT COUNT(DISTINCT e.empID) " + baseSql, countParms.ToArray()));

        parms.Add(new MySqlParameter("@lim", size));
        parms.Add(new MySqlParameter("@off", offset));

        DataTable dt = ApiHelper.Query(
            @"SELECT e.empID, e.EMP_CODE AS emp_code, e.emp_name, e.EmpType AS emp_type,
                     e.emp_email AS email, e.emp_phone AS phone,
                     e.emp_status AS status, e.emp_nationality AS nationality,
                     d.dept_name AS department, d.ID AS department_id,
                     c.contractStart AS contract_start, c.contractEnd AS contract_end,
                     c.contractStatus AS contract_status "
            + baseSql + " GROUP BY e.empID ORDER BY e.emp_name LIMIT @lim OFFSET @off",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "employees", ApiHelper.TableToList(dt) }
        });
    }

    private void HandleEmployee()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string empId = ApiHelper.RequireParam(Request, Response, "emp_id"); if (empId == null) return;

        DataTable dt = ApiHelper.Query(
            @"SELECT e.empID, e.EMP_CODE AS emp_code, e.emp_name, e.EmpType AS emp_type,
                     e.emp_email AS email, e.emp_phone AS phone,
                     e.emp_status AS status, e.emp_nationality AS nationality,
                     e.emp_qualifications AS qualifications,
                     d.dept_name AS department, d.ID AS department_id
              FROM hrm_employee e
              LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.contractStatus = 'VALID'
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              WHERE e.empID = @id LIMIT 1",
            new MySqlParameter("@id", empId));

        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Employee not found.", "NOT_FOUND"); return; }

        var emp = ApiHelper.FirstRowToDict(dt);

        // Contract history (excluding password/account fields)
        DataTable contracts = ApiHelper.Query(
            @"SELECT c.id, c.contractStart AS start_date, c.contractEnd AS end_date,
                     c.contractStatus AS status, c.departmentID AS department_id,
                     d.dept_name AS department
              FROM hrm_emp_contracts c
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              WHERE c.empID = @id ORDER BY c.contractStart DESC",
            new MySqlParameter("@id", empId));

        emp["contracts"] = ApiHelper.TableToList(contracts);

        ApiHelper.Success(Response, emp);
    }

    private void HandleCreateEmployee()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string empCode     = ApiHelper.RequireParam(Request, Response, "emp_code"); if (empCode == null) return;
        string empName     = ApiHelper.RequireParam(Request, Response, "emp_name"); if (empName == null) return;
        string empType     = ApiHelper.Param(Request, "emp_type", "Academic");
        string empEmail    = ApiHelper.Param(Request, "emp_email", "");
        string empPhone    = ApiHelper.Param(Request, "emp_phone", "");
        string nationality = ApiHelper.Param(Request, "nationality", "");
        string qualifications = ApiHelper.Param(Request, "qualifications", "");
        string empStatus   = ApiHelper.Param(Request, "status", "Active");

        // Check for duplicate emp_code
        object existing = ApiHelper.Scalar(
            "SELECT COUNT(*) FROM hrm_employee WHERE EMP_CODE = @code",
            new MySqlParameter("@code", empCode));
        if (Convert.ToInt32(existing) > 0)
        {
            ApiHelper.Error(Response, "An employee with this code already exists.", "DUPLICATE"); return;
        }

        ApiHelper.Execute(
            @"INSERT INTO hrm_employee (EMP_CODE, emp_name, EmpType, emp_email, emp_phone, emp_nationality, emp_qualifications, emp_status)
              VALUES (@code, @name, @type, @email, @phone, @nat, @qual, @st)",
            new MySqlParameter("@code",  empCode),
            new MySqlParameter("@name",  empName),
            new MySqlParameter("@type",  empType),
            new MySqlParameter("@email", empEmail),
            new MySqlParameter("@phone", empPhone),
            new MySqlParameter("@nat",   nationality),
            new MySqlParameter("@qual",  qualifications),
            new MySqlParameter("@st",    empStatus));

        int newId = Convert.ToInt32(ApiHelper.Scalar("SELECT LAST_INSERT_ID()"));

        ApiHelper.Success(Response, new Dictionary<string, object> { { "emp_id", newId }, { "emp_code", empCode } },
            "Employee created");
    }

    private void HandleUpdateEmployee()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string empId  = ApiHelper.RequireParam(Request, Response, "emp_id"); if (empId == null) return;

        DataTable existing = ApiHelper.Query(
            "SELECT empID FROM hrm_employee WHERE empID = @id LIMIT 1",
            new MySqlParameter("@id", empId));
        if (existing.Rows.Count == 0) { ApiHelper.Error(Response, "Employee not found.", "NOT_FOUND"); return; }

        // Build dynamic update from provided fields
        var sets = new List<string>();
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@id", empId));

        string empName  = ApiHelper.Param(Request, "emp_name", "");
        string empType  = ApiHelper.Param(Request, "emp_type", "");
        string empEmail = ApiHelper.Param(Request, "emp_email", "");
        string empPhone = ApiHelper.Param(Request, "emp_phone", "");
        string nat      = ApiHelper.Param(Request, "nationality", "");
        string qual     = ApiHelper.Param(Request, "qualifications", "");
        string status   = ApiHelper.Param(Request, "status", "");

        if (!string.IsNullOrEmpty(empName))  { sets.Add("emp_name = @name");    parms.Add(new MySqlParameter("@name",  empName));  }
        if (!string.IsNullOrEmpty(empType))  { sets.Add("EmpType = @type");      parms.Add(new MySqlParameter("@type",  empType));  }
        if (!string.IsNullOrEmpty(empEmail)) { sets.Add("emp_email = @email");   parms.Add(new MySqlParameter("@email", empEmail)); }
        if (!string.IsNullOrEmpty(empPhone)) { sets.Add("emp_phone = @phone");   parms.Add(new MySqlParameter("@phone", empPhone)); }
        if (!string.IsNullOrEmpty(nat))      { sets.Add("emp_nationality = @nat"); parms.Add(new MySqlParameter("@nat",  nat));     }
        if (!string.IsNullOrEmpty(qual))     { sets.Add("emp_qualifications = @qual"); parms.Add(new MySqlParameter("@qual", qual)); }
        if (!string.IsNullOrEmpty(status))   { sets.Add("emp_status = @st");     parms.Add(new MySqlParameter("@st",    status));   }

        if (sets.Count == 0) { ApiHelper.Error(Response, "No fields to update.", "VALIDATION_ERROR"); return; }

        ApiHelper.Execute(
            "UPDATE hrm_employee SET " + string.Join(", ", sets) + " WHERE empID = @id",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object> { { "emp_id", empId } }, "Employee updated");
    }

    private void HandleUpdateContract()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string empId        = ApiHelper.RequireParam(Request, Response, "emp_id"); if (empId == null) return;
        string contractStart= ApiHelper.RequireParam(Request, Response, "contract_start"); if (contractStart == null) return;
        string contractEnd  = ApiHelper.RequireParam(Request, Response, "contract_end"); if (contractEnd == null) return;
        string contractStatus = ApiHelper.Param(Request, "contract_status", "VALID");
        string departmentId = ApiHelper.Param(Request, "department_id", "");

        // Expire existing VALID contracts for this employee
        ApiHelper.Execute(
            "UPDATE hrm_emp_contracts SET contractStatus = 'EXPIRED' WHERE empID = @eid AND contractStatus = 'VALID'",
            new MySqlParameter("@eid", empId));

        ApiHelper.Execute(
            @"INSERT INTO hrm_emp_contracts (empID, contractStart, contractEnd, contractStatus, departmentID)
              VALUES (@eid, @start, @end, @st, @dept)",
            new MySqlParameter("@eid",   empId),
            new MySqlParameter("@start", contractStart),
            new MySqlParameter("@end",   contractEnd),
            new MySqlParameter("@st",    contractStatus),
            new MySqlParameter("@dept",  string.IsNullOrEmpty(departmentId) ? (object)DBNull.Value : departmentId));

        int contractId = Convert.ToInt32(ApiHelper.Scalar("SELECT LAST_INSERT_ID()"));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "emp_id", empId }, { "contract_id", contractId }, { "status", contractStatus }
        }, "Contract updated");
    }

    private void HandleDepartments()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        // Cache for 1 hour
        const string cacheKey = "api_v2_departments";
        var cached = HttpRuntime.Cache[cacheKey] as List<Dictionary<string, object>>;
        if (cached != null)
        {
            ApiHelper.Success(Response, new Dictionary<string, object> { { "departments", cached } });
            return;
        }

        DataTable dt = ApiHelper.Query(
            @"SELECT d.ID AS department_id, d.dept_name AS department_name,
                     f.faculty_name AS faculty, f.fax_code AS faculty_code,
                     COUNT(DISTINCT ec.empID) AS employee_count
              FROM hrm_departments d
              LEFT JOIN acad_faculty f ON d.fax_code = f.fax_code
              LEFT JOIN hrm_emp_contracts ec ON ec.departmentID = d.ID AND ec.contractStatus = 'VALID'
              GROUP BY d.ID ORDER BY d.dept_name");

        var rows = ApiHelper.TableToList(dt);
        HttpRuntime.Cache.Insert(cacheKey, rows, null,
            DateTime.Now.AddHours(1), System.Web.Caching.Cache.NoSlidingExpiration);

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", rows.Count }, { "departments", rows }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  MARK REQUESTS
    // ═══════════════════════════════════════════════════════════════════

    private static readonly string[] VALID_REQUEST_TYPES = { "MARK_CHANGE", "INITIAL_SUBMISSION", "CORRECTION", "OTHER" };

    private void EnsureMarkRequestsSchema()
    {
        try
        {
            ApiHelper.Execute(@"CREATE TABLE IF NOT EXISTS acad_mark_requests (
                id               INT AUTO_INCREMENT PRIMARY KEY,
                teacher_username VARCHAR(100) NOT NULL,
                course_id        VARCHAR(50)  NOT NULL,
                regno            VARCHAR(50)  NOT NULL,
                registration_id  INT          NULL,
                acad_year        VARCHAR(20)  NOT NULL,
                semester         INT          NOT NULL DEFAULT 1,
                request_type     VARCHAR(80)  NOT NULL DEFAULT 'MARK_CHANGE',
                reason           TEXT         NOT NULL,
                old_cw           DECIMAL(5,2) NULL,
                old_exam         DECIMAL(5,2) NULL,
                new_cw           DECIMAL(5,2) NULL,
                new_exam         DECIMAL(5,2) NULL,
                status           VARCHAR(30)  NOT NULL DEFAULT 'PENDING',
                admin_comment    TEXT         NULL,
                decided_by       VARCHAR(100) NULL,
                created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                decided_at       DATETIME     NULL,
                INDEX idx_mr_teacher (teacher_username),
                INDEX idx_mr_status  (status),
                INDEX idx_mr_regno   (regno),
                INDEX idx_mr_reg_id  (registration_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        }
        catch { }

        // Migrate existing tables: add columns silently if they don't exist yet
        string[] migrationAlters = {
            "ALTER TABLE acad_mark_requests ADD COLUMN registration_id INT NULL AFTER regno",
            "ALTER TABLE acad_mark_requests ADD COLUMN old_cw   DECIMAL(5,2) NULL AFTER reason",
            "ALTER TABLE acad_mark_requests ADD COLUMN old_exam DECIMAL(5,2) NULL AFTER old_cw",
            "ALTER TABLE acad_mark_requests ADD COLUMN new_cw   DECIMAL(5,2) NULL AFTER old_exam",
            "ALTER TABLE acad_mark_requests ADD COLUMN new_exam DECIMAL(5,2) NULL AFTER new_cw"
        };
        foreach (string alter in migrationAlters) { try { ApiHelper.Execute(alter); } catch { } }
    }

    // Common SELECT used by list, detail, and admin list handlers
    private const string MARK_REQUEST_SELECT =
        @"SELECT mr.id, mr.teacher_username, mr.course_id,
                 c.courseName AS course_name,
                 mr.regno,
                 CONCAT(TRIM(COALESCE(s.firstname,'')), ' ', TRIM(COALESCE(s.othername,''))) AS student_name,
                 mr.registration_id, mr.acad_year, mr.semester,
                 mr.request_type, mr.reason,
                 mr.old_cw, mr.old_exam,
                 ROUND(COALESCE(mr.old_cw,0) + COALESCE(mr.old_exam,0), 2) AS old_total,
                 mr.new_cw, mr.new_exam,
                 ROUND(COALESCE(mr.new_cw,0) + COALESCE(mr.new_exam,0), 2) AS new_total,
                 mr.status, mr.admin_comment, mr.decided_by,
                 DATE_FORMAT(mr.created_at, '%Y-%m-%d %H:%i') AS created_at,
                 DATE_FORMAT(mr.decided_at, '%Y-%m-%d %H:%i') AS decided_at
          FROM acad_mark_requests mr
          LEFT JOIN acad_course c ON c.courseID = mr.course_id
          LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(mr.regno)";

    private void HandleMarkRequestsList()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureMarkRequestsSchema();

        string status = ApiHelper.Param(Request, "status", "");
        int page      = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size      = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 20)));
        int offset    = (page - 1) * size;

        var where = new System.Text.StringBuilder("WHERE mr.teacher_username = @u");
        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@u", auth.UserId));

        if (!string.IsNullOrEmpty(status))
        {
            where.Append(" AND mr.status = @st");
            parms.Add(new MySqlParameter("@st", status.ToUpper()));
        }

        var countParms = new List<MySqlParameter>(parms);
        int total = Convert.ToInt32(ApiHelper.Scalar(
            "SELECT COUNT(*) FROM acad_mark_requests mr " + where, countParms.ToArray()));

        parms.Add(new MySqlParameter("@lim", size));
        parms.Add(new MySqlParameter("@off", offset));

        DataTable dt = ApiHelper.Query(
            MARK_REQUEST_SELECT + " " + where + " ORDER BY mr.created_at DESC LIMIT @lim OFFSET @off",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "requests", ApiHelper.TableToList(dt) }
        });
    }

    private void HandleCreateMarkRequest()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureMarkRequestsSchema();

        string courseId    = ApiHelper.RequireParam(Request, Response, "course_id"); if (courseId == null) return;
        string regno       = ApiHelper.RequireParam(Request, Response, "regno");     if (regno == null) return;
        string reason      = ApiHelper.RequireParam(Request, Response, "reason");    if (reason == null) return;
        string acadYear    = ApiHelper.Param(Request, "acad_year", "");
        int    semester    = ApiHelper.ParamInt(Request, "semester", 1);
        string requestType = ApiHelper.Param(Request, "request_type", "MARK_CHANGE").ToUpper();
        int    regId       = ApiHelper.ParamInt(Request, "registration_id", 0);

        // Validate request_type
        bool validType = false;
        foreach (string t in VALID_REQUEST_TYPES) if (t == requestType) { validType = true; break; }
        if (!validType)
        {
            ApiHelper.Error(Response, "Invalid request_type. Valid values: " + string.Join(", ", VALID_REQUEST_TYPES), "VALIDATION_ERROR");
            return;
        }

        // Parse optional mark values
        decimal? oldCw = null, oldExam = null, newCw = null, newExam = null;
        string oldCwStr   = ApiHelper.Param(Request, "old_cw",   "");
        string oldExamStr = ApiHelper.Param(Request, "old_exam", "");
        string newCwStr   = ApiHelper.Param(Request, "new_cw",   "");
        string newExamStr = ApiHelper.Param(Request, "new_exam", "");

        decimal tmp;
        if (!string.IsNullOrEmpty(oldCwStr))
        {
            if (!decimal.TryParse(oldCwStr, out tmp) || tmp < 0 || tmp > 40)
            { ApiHelper.Error(Response, "old_cw must be a number between 0 and 40.", "VALIDATION_ERROR"); return; }
            oldCw = tmp;
        }
        if (!string.IsNullOrEmpty(oldExamStr))
        {
            if (!decimal.TryParse(oldExamStr, out tmp) || tmp < 0 || tmp > 60)
            { ApiHelper.Error(Response, "old_exam must be a number between 0 and 60.", "VALIDATION_ERROR"); return; }
            oldExam = tmp;
        }
        if (!string.IsNullOrEmpty(newCwStr))
        {
            if (!decimal.TryParse(newCwStr, out tmp) || tmp < 0 || tmp > 40)
            { ApiHelper.Error(Response, "new_cw must be a number between 0 and 40.", "VALIDATION_ERROR"); return; }
            newCw = tmp;
        }
        if (!string.IsNullOrEmpty(newExamStr))
        {
            if (!decimal.TryParse(newExamStr, out tmp) || tmp < 0 || tmp > 60)
            { ApiHelper.Error(Response, "new_exam must be a number between 0 and 60.", "VALIDATION_ERROR"); return; }
            newExam = tmp;
        }

        // If registration_id supplied, fetch existing marks automatically to populate old_cw/old_exam
        if (regId > 0 && (oldCw == null || oldExam == null))
        {
            DataTable regDt = ApiHelper.Query(
                @"SELECT provisional_course_work_marks, provisional_exam_marks
                  FROM campus_dynamics_portal.acad_course_registration WHERE id = @id LIMIT 1",
                new MySqlParameter("@id", regId));
            if (regDt.Rows.Count > 0)
            {
                if (oldCw == null && regDt.Rows[0]["provisional_course_work_marks"] != DBNull.Value)
                    oldCw = Convert.ToDecimal(regDt.Rows[0]["provisional_course_work_marks"]);
                if (oldExam == null && regDt.Rows[0]["provisional_exam_marks"] != DBNull.Value)
                    oldExam = Convert.ToDecimal(regDt.Rows[0]["provisional_exam_marks"]);
            }
        }

        // Guard: block duplicate PENDING request for same teacher/course/student/semester
        int pendingCount = Convert.ToInt32(ApiHelper.Scalar(
            @"SELECT COUNT(*) FROM acad_mark_requests
              WHERE teacher_username = @u AND course_id = @cid AND regno = @r
                AND acad_year = @ay AND semester = @sem AND status = 'PENDING'",
            new MySqlParameter("@u",   auth.UserId),
            new MySqlParameter("@cid", courseId),
            new MySqlParameter("@r",   regno),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sem", semester)));

        if (pendingCount > 0)
        {
            ApiHelper.Error(Response,
                "A pending mark request already exists for this student and course. " +
                "Cancel or wait for the existing request to be decided before submitting another.",
                "DUPLICATE_REQUEST");
            return;
        }

        long newId = ApiHelper.ExecuteInsert(
            @"INSERT INTO acad_mark_requests
                (teacher_username, course_id, regno, registration_id, acad_year, semester,
                 request_type, reason, old_cw, old_exam, new_cw, new_exam)
              VALUES (@u, @cid, @r, @regid, @ay, @sem, @rt, @rs, @ocw, @oex, @ncw, @nex)",
            new MySqlParameter("@u",     auth.UserId),
            new MySqlParameter("@cid",   courseId),
            new MySqlParameter("@r",     regno),
            new MySqlParameter("@regid", regId > 0 ? (object)regId : DBNull.Value),
            new MySqlParameter("@ay",    acadYear),
            new MySqlParameter("@sem",   semester),
            new MySqlParameter("@rt",    requestType),
            new MySqlParameter("@rs",    reason),
            new MySqlParameter("@ocw",   oldCw.HasValue   ? (object)oldCw.Value   : DBNull.Value),
            new MySqlParameter("@oex",   oldExam.HasValue ? (object)oldExam.Value : DBNull.Value),
            new MySqlParameter("@ncw",   newCw.HasValue   ? (object)newCw.Value   : DBNull.Value),
            new MySqlParameter("@nex",   newExam.HasValue ? (object)newExam.Value : DBNull.Value));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "id",           newId },
            { "status",       "PENDING" },
            { "request_type", requestType },
            { "old_cw",       oldCw },
            { "old_exam",     oldExam },
            { "new_cw",       newCw },
            { "new_exam",     newExam }
        }, "Mark change request submitted and is pending admin review");
    }

    private void HandleMarkRequestDetail()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureMarkRequestsSchema();

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        // Teacher can only see their own; admin staff can pass ?admin=1 to bypass that restriction
        bool isAdmin = ApiHelper.Param(Request, "admin", "0") == "1";
        string whereClause = isAdmin
            ? "WHERE mr.id = @id LIMIT 1"
            : "WHERE mr.id = @id AND mr.teacher_username = @u LIMIT 1";

        var parms = new List<MySqlParameter> { new MySqlParameter("@id", id) };
        if (!isAdmin) parms.Add(new MySqlParameter("@u", auth.UserId));

        DataTable dt = ApiHelper.Query(MARK_REQUEST_SELECT + " " + whereClause, parms.ToArray());

        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Request not found.", "NOT_FOUND"); return; }

        ApiHelper.Success(Response, ApiHelper.FirstRowToDict(dt));
    }

    private void HandleCancelMarkRequest()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureMarkRequestsSchema();

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        // Fetch the request — must belong to this teacher and be PENDING
        DataTable dt = ApiHelper.Query(
            "SELECT id, status FROM acad_mark_requests WHERE id = @id AND teacher_username = @u LIMIT 1",
            new MySqlParameter("@id", id),
            new MySqlParameter("@u",  auth.UserId));

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Request not found.", "NOT_FOUND");
            return;
        }

        string currentStatus = dt.Rows[0]["status"].ToString();
        if (currentStatus != "PENDING")
        {
            ApiHelper.Error(Response,
                "Only PENDING requests can be cancelled. This request is " + currentStatus + ".",
                "INVALID_STATUS");
            return;
        }

        ApiHelper.Execute(
            "UPDATE acad_mark_requests SET status = 'CANCELLED', decided_at = NOW() WHERE id = @id",
            new MySqlParameter("@id", id));

        ApiHelper.Success(Response, new Dictionary<string, object> { { "id", id }, { "status", "CANCELLED" } },
            "Mark request cancelled");
    }

    private void HandleAdminMarkRequests()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureMarkRequestsSchema();

        string status          = ApiHelper.Param(Request, "status",           "PENDING");
        string teacherUsername = ApiHelper.Param(Request, "teacher_username", "");
        string filterCourseId  = ApiHelper.Param(Request, "course_id",        "");
        string filterAcadYear  = ApiHelper.Param(Request, "acad_year",        "");
        int    filterSemester  = ApiHelper.ParamInt(Request, "semester",      0);
        int    page            = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int    size            = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 20)));
        int    offset          = (page - 1) * size;

        var where = new System.Text.StringBuilder("WHERE 1=1");
        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(status))          { where.Append(" AND mr.status = @st");  parms.Add(new MySqlParameter("@st",  status.ToUpper())); }
        if (!string.IsNullOrEmpty(teacherUsername)) { where.Append(" AND mr.teacher_username = @tu"); parms.Add(new MySqlParameter("@tu", teacherUsername)); }
        if (!string.IsNullOrEmpty(filterCourseId)) { where.Append(" AND mr.course_id = @ci"); parms.Add(new MySqlParameter("@ci", filterCourseId)); }
        if (!string.IsNullOrEmpty(filterAcadYear)) { where.Append(" AND mr.acad_year = @ay"); parms.Add(new MySqlParameter("@ay", filterAcadYear)); }
        if (filterSemester > 0)                    { where.Append(" AND mr.semester = @sem"); parms.Add(new MySqlParameter("@sem", filterSemester)); }

        var countParms = new List<MySqlParameter>(parms);
        int total = Convert.ToInt32(ApiHelper.Scalar(
            "SELECT COUNT(*) FROM acad_mark_requests mr " + where, countParms.ToArray()));

        parms.Add(new MySqlParameter("@lim", size));
        parms.Add(new MySqlParameter("@off", offset));

        DataTable dt = ApiHelper.Query(
            MARK_REQUEST_SELECT + " " + where + " ORDER BY mr.created_at DESC LIMIT @lim OFFSET @off",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "requests", ApiHelper.TableToList(dt) }
        });
    }

    private void HandleDecideMarkRequest()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureMarkRequestsSchema();

        int    id           = ApiHelper.ParamInt(Request, "id", 0);
        string decision     = ApiHelper.Param(Request, "decision", "").ToUpper();
        string adminComment = ApiHelper.Param(Request, "admin_comment", "");

        if (id <= 0)
        {
            ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return;
        }
        if (decision != "APPROVED" && decision != "REJECTED")
        {
            ApiHelper.Error(Response, "decision must be APPROVED or REJECTED.", "VALIDATION_ERROR"); return;
        }

        // Fetch the request — must be PENDING
        DataTable dt = ApiHelper.Query(
            @"SELECT id, teacher_username, course_id, regno, registration_id,
                     acad_year, semester, request_type, new_cw, new_exam, status
              FROM acad_mark_requests WHERE id = @id LIMIT 1",
            new MySqlParameter("@id", id));

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Request not found.", "NOT_FOUND"); return;
        }

        string currentStatus = dt.Rows[0]["status"].ToString();
        if (currentStatus != "PENDING")
        {
            ApiHelper.Error(Response,
                "This request has already been decided (status: " + currentStatus + ").",
                "INVALID_STATUS");
            return;
        }

        // Update the request record
        ApiHelper.Execute(
            @"UPDATE acad_mark_requests
              SET status = @dec, admin_comment = @cmt, decided_by = @by, decided_at = NOW()
              WHERE id = @id",
            new MySqlParameter("@dec", decision),
            new MySqlParameter("@cmt", adminComment),
            new MySqlParameter("@by",  auth.UserId),
            new MySqlParameter("@id",  id));

        string markUpdateResult = null;

        // When APPROVED and new marks are supplied, apply the mark change to acad_course_registration
        if (decision == "APPROVED")
        {
            object regIdObj = dt.Rows[0]["registration_id"];
            bool hasRegId = regIdObj != DBNull.Value && regIdObj != null;
            int regId = hasRegId ? Convert.ToInt32(regIdObj) : 0;

            bool hasNewCw   = dt.Rows[0]["new_cw"]   != DBNull.Value && dt.Rows[0]["new_cw"] != null;
            bool hasNewExam = dt.Rows[0]["new_exam"]  != DBNull.Value && dt.Rows[0]["new_exam"] != null;

            if (regId > 0 && (hasNewCw || hasNewExam))
            {
                try
                {
                    // Fetch current marks to fill in any partial values
                    DataTable regDt = ApiHelper.Query(
                        @"SELECT provisional_course_work_marks, provisional_exam_marks, provisional_marks_status
                          FROM campus_dynamics_portal.acad_course_registration WHERE id = @id LIMIT 1",
                        new MySqlParameter("@id", regId));

                    if (regDt.Rows.Count > 0)
                    {
                        decimal curCw   = regDt.Rows[0]["provisional_course_work_marks"] != DBNull.Value
                            ? Convert.ToDecimal(regDt.Rows[0]["provisional_course_work_marks"]) : 0m;
                        decimal curExam = regDt.Rows[0]["provisional_exam_marks"] != DBNull.Value
                            ? Convert.ToDecimal(regDt.Rows[0]["provisional_exam_marks"]) : 0m;

                        decimal applyCw   = hasNewCw   ? Convert.ToDecimal(dt.Rows[0]["new_cw"])   : curCw;
                        decimal applyExam = hasNewExam ? Convert.ToDecimal(dt.Rows[0]["new_exam"]) : curExam;
                        decimal applyTotal = applyCw + applyExam;

                        // Reset status to 'approved' (unlocks from published so the change takes effect)
                        ApiHelper.Execute(
                            @"UPDATE campus_dynamics_portal.acad_course_registration
                              SET provisional_course_work_marks = @cw,
                                  provisional_exam_marks        = @ex,
                                  provisional_total_marks       = @tot,
                                  provisional_marks_status      = 'approved'
                              WHERE id = @id",
                            new MySqlParameter("@cw",  applyCw),
                            new MySqlParameter("@ex",  applyExam),
                            new MySqlParameter("@tot", applyTotal),
                            new MySqlParameter("@id",  regId));

                        markUpdateResult = string.Format(
                            "Marks updated: CW={0}, Exam={1}, Total={2}",
                            applyCw, applyExam, applyTotal);
                    }
                    else
                    {
                        markUpdateResult = "Warning: registration record " + regId + " not found; marks not updated.";
                    }
                }
                catch (Exception ex)
                {
                    markUpdateResult = "Request approved but mark update failed: " + ex.Message;
                }
            }
            else if (regId <= 0)
            {
                markUpdateResult = "Request approved. No registration_id supplied — apply marks manually.";
            }
            else
            {
                markUpdateResult = "Request approved. No new mark values supplied — no marks were changed.";
            }
        }

        var responseData = new Dictionary<string, object>
        {
            { "id",       id },
            { "decision", decision },
            { "decided_by", auth.UserId }
        };
        if (markUpdateResult != null) responseData["mark_update"] = markUpdateResult;

        ApiHelper.Success(Response, responseData,
            decision == "APPROVED" ? "Request approved" : "Request rejected");
    }
}
