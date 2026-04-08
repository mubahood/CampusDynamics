using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

public partial class API_v2_academic : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "results":
                    HandleResults();
                    break;
                case "transcript":
                    HandleTranscript();
                    break;
                case "gpa":
                    HandleGPA();
                    break;
                case "available_courses":
                    HandleAvailableCourses();
                    break;
                case "registered_courses":
                    HandleRegisteredCourses();
                    break;
                case "register_course":
                    HandleRegisterCourse();
                    break;
                case "drop_course":
                    HandleDropCourse();
                    break;
                case "semester_registration":
                    HandleSemesterRegistration();
                    break;
                case "registration_history":
                    HandleRegistrationHistory();
                    break;
                case "enrollment_status":
                    HandleEnrollmentStatus();
                    break;
                case "course_details":
                    HandleCourseDetails();
                    break;
                case "course_enrollments":
                    HandleCourseEnrollments();
                    break;
                case "programme_curriculum":
                    HandleProgrammeCurriculum();
                    break;
                case "grading_scheme":
                    HandleGradingScheme();
                    break;
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: results, transcript, gpa, available_courses, registered_courses, register_course, drop_course, semester_registration, registration_history, enrollment_status, course_details, course_enrollments, programme_curriculum, grading_scheme", "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>Get auth and resolve the student reg number (staff can pass ?regno=).</summary>
    private string GetStudentRegNo(out TokenInfo auth)
    {
        auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return null;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", "")
            : auth.UserId;

        if (auth.UserType == "student")
            regno = auth.UserId;

        if (string.IsNullOrEmpty(regno))
        {
            ApiHelper.Error(Response, "Student registration number required. Pass ?regno= parameter.", "MISSING_PARAM");
            return null;
        }

        return regno;
    }

    private void HandleResults()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        string semester = ApiHelper.Param(Request, "semester", "");

        try
        {
            // Use the existing MobileData adapter for all results
            MobileDataTableAdapters.acad_GetAllResultsTableAdapter RESULTS = new MobileDataTableAdapters.acad_GetAllResultsTableAdapter();
            DataTable dt = RESULTS.GetData(regno);

            // Apply filters if provided
            if (!string.IsNullOrEmpty(acad_year) || !string.IsNullOrEmpty(semester))
            {
                string filter = "";
                if (!string.IsNullOrEmpty(acad_year))
                    filter += "acad = '" + acad_year.Replace("'", "") + "'";
                if (!string.IsNullOrEmpty(semester))
                {
                    if (filter.Length > 0) filter += " AND ";
                    filter += "semester = " + semester.Replace("'", "");
                }

                DataView dv = new DataView(dt);
                dv.RowFilter = filter;
                dt = dv.ToTable();
            }

            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching results: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleTranscript()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            // Get student profile
            DataTable profileDt = ApiHelper.Query(
                @"SELECT s.firstname, s.othername, p.progname AS programme, s.progid, s.entryyear, s.intake
                  FROM acad_student s
                  LEFT JOIN acad_programme p ON s.progid = p.progcode
                  WHERE s.regno = @reg",
                new MySqlParameter("@reg", regno)
            );

            // Get all results
            MobileDataTableAdapters.acad_GetAllResultsTableAdapter RESULTS = new MobileDataTableAdapters.acad_GetAllResultsTableAdapter();
            DataTable resultsDt = RESULTS.GetData(regno);

            // Build structured transcript
            var transcript = new Dictionary<string, object>();
            if (profileDt.Rows.Count > 0)
            {
                transcript["student"] = ApiHelper.FirstRowToDict(profileDt);
            }

            // Group results by acad_year and semester
            var semesters = new List<Dictionary<string, object>>();
            DataView dv = new DataView(resultsDt);
            DataTable distinctSems = dv.ToTable(true, "acad", "semester");

            double totalWeightedGP = 0;
            int totalCredits = 0;

            foreach (DataRow semRow in distinctSems.Rows)
            {
                string ay = semRow["acad"].ToString();
                string sem = semRow["semester"].ToString();

                DataView semView = new DataView(resultsDt);
                semView.RowFilter = "acad = '" + ay.Replace("'", "") + "' AND semester = " + sem;
                DataTable semResults = semView.ToTable();

                var courses = ApiHelper.TableToList(semResults);

                // Calculate semester GPA
                double semWeightedGP = 0;
                int semCredits = 0;
                foreach (var course in courses)
                {
                    int cu = 0;
                    double gp = 0;
                    if (course.ContainsKey("CreditUnits") && course["CreditUnits"] != null)
                        int.TryParse(course["CreditUnits"].ToString(), out cu);
                    if (course.ContainsKey("gradept") && course["gradept"] != null)
                        double.TryParse(course["gradept"].ToString(), out gp);

                    semWeightedGP += gp * cu;
                    semCredits += cu;
                }

                double semGPA = semCredits > 0 ? Math.Round(semWeightedGP / semCredits, 2) : 0;
                totalWeightedGP += semWeightedGP;
                totalCredits += semCredits;

                semesters.Add(new Dictionary<string, object>
                {
                    { "acad_year", ay },
                    { "semester", sem },
                    { "courses", courses },
                    { "semester_gpa", semGPA },
                    { "semester_credits", semCredits }
                });
            }

            double cgpa = totalCredits > 0 ? Math.Round(totalWeightedGP / totalCredits, 2) : 0;

            transcript["semesters"] = semesters;
            transcript["cgpa"] = cgpa;
            transcript["total_credits"] = totalCredits;
            transcript["classification"] = GetClassification(cgpa);

            ApiHelper.Success(Response, transcript);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error building transcript: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleGPA()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            MobileDataTableAdapters.acad_GetAllResultsTableAdapter RESULTS = new MobileDataTableAdapters.acad_GetAllResultsTableAdapter();
            DataTable resultsDt = RESULTS.GetData(regno);

            DataView dv = new DataView(resultsDt);
            DataTable distinctSems = dv.ToTable(true, "acad", "semester");

            var semesterGPAs = new List<Dictionary<string, object>>();
            double totalWeightedGP = 0;
            int totalCredits = 0;

            foreach (DataRow semRow in distinctSems.Rows)
            {
                string ay = semRow["acad"].ToString();
                string sem = semRow["semester"].ToString();

                DataView semView = new DataView(resultsDt);
                semView.RowFilter = "acad = '" + ay.Replace("'", "") + "' AND semester = " + sem;
                DataTable semResults = semView.ToTable();

                double semWeightedGP = 0;
                int semCredits = 0;

                foreach (DataRow r in semResults.Rows)
                {
                    int cu = 0;
                    double gp = 0;
                    if (r["CreditUnits"] != DBNull.Value) int.TryParse(r["CreditUnits"].ToString(), out cu);
                    if (r["gradept"] != DBNull.Value) double.TryParse(r["gradept"].ToString(), out gp);
                    semWeightedGP += gp * cu;
                    semCredits += cu;
                }

                double semGPA = semCredits > 0 ? Math.Round(semWeightedGP / semCredits, 2) : 0;
                totalWeightedGP += semWeightedGP;
                totalCredits += semCredits;

                semesterGPAs.Add(new Dictionary<string, object>
                {
                    { "acad_year", ay },
                    { "semester", sem },
                    { "gpa", semGPA },
                    { "credits", semCredits }
                });
            }

            double cgpa = totalCredits > 0 ? Math.Round(totalWeightedGP / totalCredits, 2) : 0;

            var data = new Dictionary<string, object>
            {
                { "semesters", semesterGPAs },
                { "cgpa", cgpa },
                { "total_credits", totalCredits },
                { "classification", GetClassification(cgpa) }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error calculating GPA: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleAvailableCourses()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        try
        {
            PortalContentTableAdapters.acad_GetPendingCoursesTableAdapter COURSELIST = new PortalContentTableAdapters.acad_GetPendingCoursesTableAdapter();
            DataTable dt = COURSELIST.GetData(regno, acad_year, semester, "Normal");
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching available courses: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleRegisteredCourses()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        try
        {
            MobileDataTableAdapters.acad_course_registrationTableAdapter COURSES = new MobileDataTableAdapters.acad_course_registrationTableAdapter();
            DataTable dt = COURSES.GetStudCourseRegistration(regno, acad_year, semester);
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching registered courses: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleRegisterCourse()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        // Only students can register for courses
        if (auth.UserType != "student")
        {
            ApiHelper.Error(Response, "Only students can register for courses.", "ACCESS_DENIED");
            return;
        }

        string courseId = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        try
        {
            // Get student profile for programme info
            StudentDataTableAdapters.acad_studentTableAdapter STUD = new StudentDataTableAdapters.acad_studentTableAdapter();
            DataTable profile = STUD.GetBioData(regno);

            if (profile.Rows.Count == 0)
            {
                ApiHelper.Error(Response, "Student profile not found.", "NOT_FOUND");
                return;
            }

            MobileDataTableAdapters.acad_course_registrationTableAdapter COURSE = new MobileDataTableAdapters.acad_course_registrationTableAdapter();
            COURSE.Insert(
                regno,
                courseId,
                acad_year,
                (uint)semester,
                "Normal",
                profile.Rows[0]["progid"].ToString(),
                profile.Rows[0]["studsesion"].ToString()
            );

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "course_id", courseId },
                { "acad_year", acad_year },
                { "semester", semester }
            }, "Course registered successfully");
        }
        catch (Exception ex)
        {
            string msg = ex.Message.ToLower().Contains("duplicate")
                ? "This course is already registered."
                : "Error registering course: " + ex.Message;
            ApiHelper.Error(Response, msg, "SERVER_ERROR");
        }
    }

    private void HandleDropCourse()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        if (auth.UserType != "student")
        {
            ApiHelper.Error(Response, "Only students can drop courses.", "ACCESS_DENIED");
            return;
        }

        string regIdStr = ApiHelper.RequireParam(Request, Response, "registration_id");
        if (regIdStr == null) return;

        uint regId;
        if (!uint.TryParse(regIdStr, out regId))
        {
            ApiHelper.Error(Response, "Invalid registration_id.", "MISSING_PARAM");
            return;
        }

        try
        {
            MobileDataTableAdapters.acad_course_registrationTableAdapter COURSE = new MobileDataTableAdapters.acad_course_registrationTableAdapter();
            COURSE.Delete(regId);
            ApiHelper.Success(Response, null, "Course dropped successfully");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error dropping course: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleSemesterRegistration()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        if (auth.UserType != "student")
        {
            ApiHelper.Error(Response, "Only students can process semester registration.", "ACCESS_DENIED");
            return;
        }

        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        try
        {
            // Process registration
            PortalContentTableAdapters.acad_StudentRegistrationTableAdapter REG = new PortalContentTableAdapters.acad_StudentRegistrationTableAdapter();
            string regResult = REG.ProcessRegister(regno, acad_year, semester, regno).ToString();

            // Auto-billing via stored procedure on accounts DB
            // Wrapped separately so billing duplicates (error 1062) don't
            // block the registration success response.
            bool billingOk = true;
            try
            {
                ApiHelper.QueryAccounts(
                    "CALL fin_Autobilling(@reg, @acad, @sems, @typ, @usr, @csid)",
                    new MySqlParameter("@reg", regno),
                    new MySqlParameter("@acad", acad_year),
                    new MySqlParameter("@sems", semester),
                    new MySqlParameter("@typ", "REG"),
                    new MySqlParameter("@usr", regno),
                    new MySqlParameter("@csid", "-")
                );
                ApiHelper.QueryAccounts(
                    "CALL fin_Autobilling(@reg, @acad, @sems, @typ, @usr, @csid)",
                    new MySqlParameter("@reg", regno),
                    new MySqlParameter("@acad", acad_year),
                    new MySqlParameter("@sems", semester),
                    new MySqlParameter("@typ", "ACCOMO"),
                    new MySqlParameter("@usr", regno),
                    new MySqlParameter("@csid", "-")
                );
            }
            catch (MySqlException mex)
            {
                // Error 1062 = duplicate key — student already billed for this
                // semester. This is safe to ignore (DB prevented a duplicate bill).
                if (mex.Number != 1062) billingOk = false;
            }
            catch { billingOk = false; }

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "registration_result", regResult },
                { "acad_year", acad_year },
                { "semester", semester },
                { "billing_processed", billingOk }
            }, "Semester registration completed");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Registration error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleRegistrationHistory()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            MobileDataTableAdapters.acad_registrationTableAdapter REGHISTORY = new MobileDataTableAdapters.acad_registrationTableAdapter();
            DataTable dt = REGHISTORY.GetRegistrationHistory(regno);
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching registration history: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>Returns the degree classification based on CGPA.</summary>
    private string GetClassification(double cgpa)
    {
        if (cgpa >= 4.4) return "First Class";
        if (cgpa >= 3.6) return "Second Class Upper";
        if (cgpa >= 2.8) return "Second Class Lower";
        if (cgpa >= 2.0) return "Pass";
        return "Below Pass";
    }

    // ═══════════════════════════════════════════════════════════════════
    //  NEW ACADEMIC ENDPOINTS
    // ═══════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns a student's enrollment verification status for a specific semester.
    /// Useful to confirm active enrollment for third parties (employers, embassies, etc.).
    /// Returns registration status, programme, study year, and semester details.
    /// </summary>
    private void HandleEnrollmentStatus()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        int semester = ApiHelper.ParamInt(Request, "semester", 0);

        try
        {
            // Student biodata
            DataTable profileDt = ApiHelper.Query(
                @"SELECT s.regno, s.entryno, s.firstname, s.othername,
                         p.progname AS programme, s.progid AS programme_code,
                         s.stud_status AS status, s.entryyear AS entry_year,
                         s.studsesion AS session,
                         COALESCE(c.campus_name, '') AS campus
                  FROM acad_student s
                  LEFT JOIN acad_programme p ON s.progid = p.progcode
                  LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
                  WHERE s.regno = @reg",
                new MySqlParameter("@reg", regno)
            );

            if (profileDt.Rows.Count == 0)
            {
                ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
                return;
            }

            var profile = ApiHelper.FirstRowToDict(profileDt);

            // Get registration records
            string regSql = @"SELECT r.acad_year, r.semester, r.studyyear AS study_year,
                                     r.status AS reg_status,
                                     DATE_FORMAT(r.reg_date, '%Y-%m-%d') AS registration_date,
                                     r.campusid AS campus_id
                              FROM acad_registration r
                              WHERE r.regno = @reg";

            var parms = new List<MySqlParameter>();
            parms.Add(new MySqlParameter("@reg", regno));

            if (!string.IsNullOrEmpty(acad_year))
            {
                regSql += " AND r.acad_year = @acad";
                parms.Add(new MySqlParameter("@acad", acad_year));
            }
            if (semester > 0)
            {
                regSql += " AND r.semester = @sem";
                parms.Add(new MySqlParameter("@sem", semester));
            }

            regSql += " ORDER BY r.acad_year DESC, r.semester DESC";

            DataTable regDt = ApiHelper.Query(regSql, parms.ToArray());

            bool isCurrentlyEnrolled = false;
            foreach (DataRow row in regDt.Rows)
            {
                string regStatus = row["reg_status"] != DBNull.Value ? row["reg_status"].ToString() : "";
                if (regStatus.ToLower() == "active" || regStatus.ToLower() == "registered")
                {
                    isCurrentlyEnrolled = true;
                    break;
                }
            }

            var data = new Dictionary<string, object>
            {
                { "student", profile },
                { "is_enrolled", isCurrentlyEnrolled },
                { "total_semesters_registered", regDt.Rows.Count },
                { "registrations", ApiHelper.TableToList(regDt) }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error checking enrollment status: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// ODEL: Get detailed information for a single course.
    /// Returns metadata, department, credit units, and which programmes include it.
    /// </summary>
    private void HandleCourseDetails()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string courseCode = ApiHelper.RequireParam(Request, Response, "course_code");
        if (courseCode == null) return;

        DataTable dt = ApiHelper.Query(
            @"SELECT c.courseID AS course_code, c.courseName AS course_name,
                     c.CreditUnit AS credit_units, c.courseCategory AS category,
                     d.dept_name AS department, f.faculty_name AS faculty
              FROM acad_course c
              LEFT JOIN hrm_departments d ON c.courseDept = d.ID
              LEFT JOIN acad_faculty f ON d.fax_code = f.fax_code
              WHERE c.courseID = @code
              LIMIT 1",
            new MySqlParameter("@code", courseCode)
        );

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Course not found.", "NOT_FOUND");
            return;
        }

        var course = ApiHelper.FirstRowToDict(dt);

        // Get programmes that include this course
        DataTable dtProgs = ApiHelper.Query(
            @"SELECT DISTINCT pc.progcode, p.progname AS programme_name,
                     pc.studyYear AS study_year, pc.semester
              FROM acad_programmecourses pc
              LEFT JOIN acad_programme p ON pc.progcode = p.progcode
              WHERE pc.courseID = @code
              ORDER BY p.progname, pc.studyYear, pc.semester",
            new MySqlParameter("@code", courseCode)
        );

        course["programmes"] = ApiHelper.TableToList(dtProgs);

        // Get prerequisites if table exists
        try
        {
            DataTable dtPre = ApiHelper.Query(
                @"SELECT prerequisite_course AS course_code, c.courseName AS course_name
                  FROM acad_prerequisites pr
                  LEFT JOIN acad_course c ON pr.prerequisite_course = c.courseID
                  WHERE pr.courseID = @code",
                new MySqlParameter("@code", courseCode)
            );
            course["prerequisites"] = ApiHelper.TableToList(dtPre);
        }
        catch
        {
            course["prerequisites"] = new List<object>();
        }

        ApiHelper.Success(Response, course);
    }

    /// <summary>
    /// ODEL: Get all students enrolled in a specific course for a given semester.
    /// Staff only. Used by Moodle to sync course rosters.
    /// </summary>
    private void HandleCourseEnrollments()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "Only staff can view course enrollments.", "ACCESS_DENIED");
            return;
        }

        string courseCode = ApiHelper.RequireParam(Request, Response, "course_code");
        if (courseCode == null) return;
        string acadYear = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acadYear == null) return;
        string semester = ApiHelper.RequireParam(Request, Response, "semester");
        if (semester == null) return;

        DataTable dt = ApiHelper.Query(
            @"SELECT cr.regno, s.firstname, s.othername, s.email,
                     s.progid AS progcode, p.progname AS programme,
                     cr.registration_status AS status,
                     s.studPhone AS phone, s.gender
              FROM acad_course_registration cr
              INNER JOIN acad_student s ON cr.regno = s.regno
              LEFT JOIN acad_programme p ON s.progid = p.progcode
              WHERE cr.courseID = @code
                AND cr.academic_year = @ay
                AND cr.semester = @sem
              ORDER BY s.firstname, s.othername",
            new MySqlParameter("@code", courseCode),
            new MySqlParameter("@ay", acadYear),
            new MySqlParameter("@sem", semester)
        );

        var students = ApiHelper.TableToList(dt);

        // Also get course info
        DataTable dtCourse = ApiHelper.Query(
            "SELECT courseID AS course_code, courseName AS course_name, CreditUnit AS credit_units FROM acad_course WHERE courseID = @code",
            new MySqlParameter("@code", courseCode)
        );

        var data = new Dictionary<string, object>
        {
            { "course_code", courseCode },
            { "course_name", dtCourse.Rows.Count > 0 ? Convert.ToString(dtCourse.Rows[0]["course_name"]) : "" },
            { "credit_units", dtCourse.Rows.Count > 0 ? Convert.ToString(dtCourse.Rows[0]["credit_units"]) : "" },
            { "academic_year", acadYear },
            { "semester", semester },
            { "total_enrolled", students.Count },
            { "students", students }
        };
        ApiHelper.Success(Response, data);
    }

    /// <summary>
    /// ODEL: Get full programme curriculum grouped by year and semester.
    /// Used by Moodle to auto-create course structures.
    /// </summary>
    private void HandleProgrammeCurriculum()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string progcode = ApiHelper.RequireParam(Request, Response, "progcode");
        if (progcode == null) return;

        // Get programme info
        DataTable dtProg = ApiHelper.Query(
            @"SELECT p.progcode, p.progname, f.faculty_name AS faculty,
                     d.dept_name AS department, p.proglevel AS level,
                     p.progduration AS duration_years
              FROM acad_programme p
              LEFT JOIN acad_faculty f ON p.progfaculty = f.fax_code
              LEFT JOIN hrm_departments d ON p.progdept = d.ID
              WHERE p.progcode = @prog
              LIMIT 1",
            new MySqlParameter("@prog", progcode)
        );

        if (dtProg.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Programme not found.", "NOT_FOUND");
            return;
        }

        var progInfo = ApiHelper.FirstRowToDict(dtProg);

        // Get all courses in programme curriculum
        DataTable dtCourses = ApiHelper.Query(
            @"SELECT pc.courseID AS course_code, c.courseName AS course_name,
                     c.CreditUnit AS credit_units, pc.studyYear AS study_year,
                     pc.semester, pc.courseType AS course_type,
                     c.courseCategory AS category
              FROM acad_programmecourses pc
              LEFT JOIN acad_course c ON pc.courseID = c.courseID
              WHERE pc.progcode = @prog
              ORDER BY pc.studyYear, pc.semester, c.courseName",
            new MySqlParameter("@prog", progcode)
        );

        // Group courses by year and semester
        var curriculum = new Dictionary<string, object>();
        int totalCredits = 0;
        foreach (DataRow row in dtCourses.Rows)
        {
            string year = Convert.ToString(row["study_year"]);
            string sem = Convert.ToString(row["semester"]);
            string key = "Year " + year + " - Semester " + sem;

            if (!curriculum.ContainsKey(key))
            {
                curriculum[key] = new List<Dictionary<string, object>>();
            }

            var courseDict = new Dictionary<string, object>
            {
                { "course_code", Convert.ToString(row["course_code"]) },
                { "course_name", Convert.ToString(row["course_name"]) },
                { "credit_units", Convert.ToString(row["credit_units"]) },
                { "course_type", Convert.ToString(row["course_type"]) },
                { "category", Convert.ToString(row["category"]) }
            };

            ((List<Dictionary<string, object>>)curriculum[key]).Add(courseDict);

            int cu;
            if (int.TryParse(Convert.ToString(row["credit_units"]), out cu))
                totalCredits += cu;
        }

        var data = new Dictionary<string, object>
        {
            { "programme", progInfo },
            { "total_courses", dtCourses.Rows.Count },
            { "total_credit_units", totalCredits },
            { "curriculum", curriculum }
        };
        ApiHelper.Success(Response, data);
    }

    /// <summary>
    /// ODEL: Get the grading scheme/scale used by MRU.
    /// Public endpoint (no auth required). Used by Moodle to configure grade mappings.
    /// </summary>
    private void HandleGradingScheme()
    {
        // No auth required - public information
        var gradeScale = new List<Dictionary<string, object>>();

        // Standard MRU grading scale
        string[][] grades = new string[][] {
            new string[] { "A", "90", "100", "5.0", "Excellent" },
            new string[] { "B+", "80", "89", "4.5", "Very Good" },
            new string[] { "B", "70", "79", "4.0", "Good" },
            new string[] { "C+", "60", "69", "3.5", "Fairly Good" },
            new string[] { "C", "50", "59", "3.0", "Pass" },
            new string[] { "D+", "45", "49", "2.5", "Marginal Pass" },
            new string[] { "D", "40", "44", "2.0", "Marginal Fail" },
            new string[] { "F", "0", "39", "0.0", "Fail" }
        };

        foreach (string[] g in grades)
        {
            gradeScale.Add(new Dictionary<string, object>
            {
                { "letter", g[0] },
                { "min_score", Convert.ToInt32(g[1]) },
                { "max_score", Convert.ToInt32(g[2]) },
                { "grade_point", Convert.ToDouble(g[3]) },
                { "remark", g[4] }
            });
        }

        // Try to load from DB if a grading table exists
        try
        {
            DataTable dt = ApiHelper.Query(
                @"SELECT grade_letter AS letter, min_score, max_score, grade_point, remark
                  FROM acad_grading_scale ORDER BY min_score DESC"
            );
            if (dt.Rows.Count > 0)
            {
                gradeScale = new List<Dictionary<string, object>>();
                foreach (DataRow row in dt.Rows)
                {
                    gradeScale.Add(new Dictionary<string, object>
                    {
                        { "letter", Convert.ToString(row["letter"]) },
                        { "min_score", Convert.ToInt32(row["min_score"]) },
                        { "max_score", Convert.ToInt32(row["max_score"]) },
                        { "grade_point", Convert.ToDouble(row["grade_point"]) },
                        { "remark", Convert.ToString(row["remark"]) }
                    });
                }
            }
        }
        catch
        {
            // Table doesn't exist, use hardcoded scale
        }

        var data = new Dictionary<string, object>
        {
            { "institution", "Mountains of the Moon University" },
            { "pass_mark", 50 },
            { "max_gpa", 5.0 },
            { "total_grades", gradeScale.Count },
            { "scale", gradeScale }
        };
        ApiHelper.Success(Response, data);
    }
}
