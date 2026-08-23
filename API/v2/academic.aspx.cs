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
        if (ApiHelper.IsRateLimited(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "results":                   HandleResults();                  break;
                case "transcript":                HandleTranscript();               break;
                case "gpa":                       HandleGPA();                      break;
                case "available_courses":         HandleAvailableCourses();         break;
                case "registered_courses":        HandleRegisteredCourses();        break;
                case "register_course":           HandleRegisterCourse();           break;
                case "drop_course":               HandleDropCourse();               break;
                case "semester_registration":     HandleSemesterRegistration();     break;
                case "registration_history":      HandleRegistrationHistory();      break;
                case "enrollment_status":         HandleEnrollmentStatus();         break;
                case "course_details":            HandleCourseDetails();            break;
                case "course_enrollments":        HandleCourseEnrollments();        break;
                case "programme_curriculum":      HandleProgrammeCurriculum();      break;
                case "grading_scheme":            HandleGradingScheme();            break;
                case "semester_status":           HandleSemesterStatus();           break;
                case "retake_courses":            HandleRetakeCourses();            break;
                case "student_academic_summary":       HandleStudentAcademicSummary();        break;
                case "academic_standing":              HandleAcademicStanding();               break;
                case "semester_deletion_requests":     HandleSemesterDeletionRequests();       break;
                case "semester_deletion_request":      HandleSemesterDeletionRequest();        break;
                case "submit_semester_deletion":       HandleSubmitSemesterDeletion();         break;
                case "decide_semester_deletion":       HandleDecideSemesterDeletion();         break;
                case "batch_decide_semester_deletion": HandleBatchDecideSemesterDeletion();    break;
                case "course_bank":                    HandleCourseBank();                     break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". Valid actions: results, transcript, gpa, " +
                        "available_courses, registered_courses, register_course, drop_course, " +
                        "semester_registration, registration_history, enrollment_status, course_details, " +
                        "course_enrollments, programme_curriculum, grading_scheme, semester_status, " +
                        "retake_courses, student_academic_summary, academic_standing, " +
                        "semester_deletion_requests, semester_deletion_request, submit_semester_deletion, " +
                        "decide_semester_deletion, batch_decide_semester_deletion, course_bank",
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
    //  AUTH HELPER
    // ═══════════════════════════════════════════════════════════════════

    // ═══════════════════════════════════════════════════════════════════
    //  COURSE BANK — search the catalogue
    //
    //  The portal's Course Bank lets a student look a course code up and see what it is worth.
    //  Archived and merged codes are excluded: they are history, and offering them for search
    //  invites a student to register against a code that no longer exists.
    // ═══════════════════════════════════════════════════════════════════

    private void HandleCourseBank()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string q = ApiHelper.Param(Request, "q", "").Trim();
        string prog = ApiHelper.Param(Request, "programme", "").Trim();
        int page = ApiHelper.ParamInt(Request, "page", 1); if (page < 1) page = 1;
        int limit = ApiHelper.ParamInt(Request, "limit", 25); if (limit < 1 || limit > 100) limit = 25;

        // A blank code is a junk row, not a course; offering it for search is offering nothing.
        string where = "WHERE IFNULL(c.course_state,'ACTIVE') = 'ACTIVE' AND TRIM(IFNULL(c.courseID,'')) <> ''";
        var ps = new List<MySqlParameter>();
        if (q != "")
        {
            where += " AND (TRIM(c.courseID) LIKE @q OR c.courseName LIKE @q)";
            ps.Add(new MySqlParameter("@q", "%" + q + "%"));
        }
        if (prog != "")
        {
            where += " AND EXISTS (SELECT 1 FROM acad_programmecourses pc WHERE TRIM(pc.course_code)=TRIM(c.courseID) AND pc.progcode=@p)";
            ps.Add(new MySqlParameter("@p", prog));
        }

        object totalObj = ApiHelper.Scalar("SELECT COUNT(*) FROM acad_course c " + where, ps.ToArray());
        int total = totalObj == null ? 0 : Convert.ToInt32(totalObj);

        var ps2 = new List<MySqlParameter>(ps);
        DataTable dt = ApiHelper.Query(
            "SELECT TRIM(c.courseID) AS course_code, IFNULL(c.courseName,'') AS course_name, " +
            "  IFNULL(c.CreditUnit,0) AS credit_units, IFNULL(c.CoreStatus,'') AS core_status, " +
            "  IFNULL(c.LectureHr,0) AS lecture_hours, IFNULL(c.PracticalHr,0) AS practical_hours, " +
            "  (SELECT COUNT(DISTINCT pc.progcode) FROM acad_programmecourses pc " +
            "     WHERE TRIM(pc.course_code)=TRIM(c.courseID)) AS programme_count " +
            "FROM acad_course c " + where +
            " ORDER BY c.courseID LIMIT " + limit + " OFFSET " + ((page - 1) * limit),
            ps2.ToArray());

        var items = new List<object>();
        foreach (DataRow r in dt.Rows)
            items.Add(new
            {
                course_code = Convert.ToString(r["course_code"]).Trim(),
                course_name = Convert.ToString(r["course_name"]).Trim(),
                credit_units = Convert.ToDouble(r["credit_units"]),
                core_status = Convert.ToString(r["core_status"]).Trim(),
                lecture_hours = Convert.ToDouble(r["lecture_hours"]),
                practical_hours = Convert.ToDouble(r["practical_hours"]),
                offered_on_programmes = Convert.ToInt32(r["programme_count"])
            });

        ApiHelper.Success(Response, new
        {
            courses = items,
            pagination = new { page = page, limit = limit, total = total, total_pages = (int)Math.Ceiling(total / (double)limit) }
        }, "Course bank");
    }

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

    // ═══════════════════════════════════════════════════════════════════
    //  RESULTS
    // ═══════════════════════════════════════════════════════════════════

    private void HandleResults()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        string semester  = ApiHelper.Param(Request, "semester", "");

        try
        {
            DataTable dt = ApiHelper.QueryProc("acad_GetAllResults", new MySqlParameter("@reg", regno));

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

    // ═══════════════════════════════════════════════════════════════════
    //  TRANSCRIPT  — uses AcademicEngine.ComputeGPA()
    // ═══════════════════════════════════════════════════════════════════

    private void HandleTranscript()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            DataTable profileDt = ApiHelper.Query(
                @"SELECT s.firstname, s.othername, p.progname AS programme, s.progid, s.entryyear, s.intake
                  FROM acad_student s
                  LEFT JOIN acad_programme p ON s.progid = p.progcode
                  WHERE s.regno = @reg",
                new MySqlParameter("@reg", regno)
            );

            DataTable resultsDt = ApiHelper.QueryProc("acad_GetAllResults", new MySqlParameter("@reg", regno));

            GpaResult gpa = AcademicEngine.ComputeGPA(resultsDt);

            // Build semesters with course lists attached to each GPA entry
            var semesters = new List<Dictionary<string, object>>();
            foreach (SemesterGPA sem in gpa.Semesters)
            {
                DataView semView = new DataView(resultsDt);
                semView.RowFilter = "acad = '" + sem.AcadYear.Replace("'", "") + "' AND semester = " + sem.Semester;
                DataTable semResults = semView.ToTable();

                semesters.Add(new Dictionary<string, object>
                {
                    { "acad_year",        sem.AcadYear                   },
                    { "semester",         sem.Semester                    },
                    { "semester_gpa",     sem.GPA                         },
                    { "semester_credits", sem.Credits                     },
                    { "courses",          ApiHelper.TableToList(semResults) }
                });
            }

            var transcript = new Dictionary<string, object>
            {
                { "student",        profileDt.Rows.Count > 0 ? ApiHelper.FirstRowToDict(profileDt) : null },
                { "semesters",      semesters          },
                { "cgpa",           gpa.CGPA           },
                { "total_credits",  gpa.TotalCredits   },
                { "classification", gpa.Classification }
            };

            ApiHelper.Success(Response, transcript);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error building transcript: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  GPA  — uses AcademicEngine.ComputeGPA()
    // ═══════════════════════════════════════════════════════════════════

    private void HandleGPA()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            DataTable resultsDt = ApiHelper.QueryProc("acad_GetAllResults", new MySqlParameter("@reg", regno));

            GpaResult gpa = AcademicEngine.ComputeGPA(resultsDt);
            ApiHelper.Success(Response, gpa.ToDictionary());
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error calculating GPA: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AVAILABLE COURSES
    // ═══════════════════════════════════════════════════════════════════

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
            // 1. Student profile — progid + study year for the requested semester
            DataTable studDt = ApiHelper.Query(
                @"SELECT s.progid,
                         COALESCE(
                             (SELECT r.studyyear FROM acad_registration r
                              WHERE r.regno = s.regno AND r.acad_year = @acad AND r.semester = @sem
                              LIMIT 1),
                             (SELECT r.studyyear FROM acad_registration r
                              WHERE r.regno = s.regno AND r.acad_year = @acad
                              LIMIT 1),
                             (SELECT LEAST(r.studyyear + 1, 5) FROM acad_registration r
                              WHERE r.regno = s.regno AND r.acad_year < @acad
                              ORDER BY r.acad_year DESC, r.semester DESC LIMIT 1),
                             1
                         ) AS study_year
                  FROM acad_student s WHERE s.regno = @reg LIMIT 1",
                new MySqlParameter("@reg",  regno),
                new MySqlParameter("@acad", acad_year),
                new MySqlParameter("@sem",  semester)
            );

            if (studDt.Rows.Count == 0)
            {
                ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
                return;
            }

            string progid     = studDt.Rows[0]["progid"].ToString();
            int    study_year = 1;
            int.TryParse(studDt.Rows[0]["study_year"].ToString(), out study_year);

            // 2. Programme curriculum for this year/semester
            DataTable currDt = ApiHelper.Query(
                @"SELECT pc.course_code, c.courseName AS course_name,
                         IFNULL(c.CreditUnit, 0) AS credit_units,
                         pc.study_year, pc.semester,
                         IFNULL(pc.course_type, 'CORE') AS course_type
                  FROM acad_programmecourses pc
                  LEFT JOIN acad_course c ON pc.course_code = c.courseID
                  WHERE pc.progcode   = @prog
                    AND pc.semester   = @sem
                    AND pc.study_year = @sy
                  ORDER BY pc.course_type, c.courseName",
                new MySqlParameter("@prog", progid),
                new MySqlParameter("@sem",  semester),
                new MySqlParameter("@sy",   study_year)
            );

            // 3. Already-registered course IDs — separate query avoids cross-DB JOIN parameter issues
            var registeredSet = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);
            try
            {
                DataTable regDt = ApiHelper.Query(
                    @"SELECT courseID FROM campus_dynamics_portal.acad_course_registration
                      WHERE regno = @reg AND acad_year = @acad AND semester = @sem",
                    new MySqlParameter("@reg",  regno),
                    new MySqlParameter("@acad", acad_year),
                    new MySqlParameter("@sem",  semester)
                );
                foreach (DataRow rr in regDt.Rows)
                    registeredSet.Add(rr["courseID"].ToString().Trim());
            }
            catch { /* registration table unreachable — is_registered defaults to 0 */ }

            // 4. Merge
            var courses = new List<Dictionary<string, object>>();
            foreach (DataRow row in currDt.Rows)
            {
                string code = row["course_code"].ToString().Trim();
                courses.Add(new Dictionary<string, object>
                {
                    { "course_code",   code },
                    { "course_name",   row["course_name"]   },
                    { "credit_units",  row["credit_units"]  },
                    { "study_year",    row["study_year"]    },
                    { "semester",      row["semester"]      },
                    { "course_type",   row["course_type"]   },
                    { "is_registered", registeredSet.Contains(code) ? 1 : 0 }
                });
            }

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "programme",  progid     },
                { "study_year", study_year },
                { "semester",   semester   },
                { "acad_year",  acad_year  },
                { "total",      courses.Count },
                { "registered", registeredSet.Count },
                { "courses",    courses    }
            });
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching available courses: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  REGISTERED COURSES
    // ═══════════════════════════════════════════════════════════════════

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
            // LEFT JOIN so registrations are returned even if courseID is absent from the catalog
            DataTable dt = ApiHelper.Query(
                @"SELECT cr.ID, cr.regno, cr.courseID, cr.acad_year, cr.semester,
                         cr.course_status, cr.prog_id, cr.stud_session,
                         COALESCE(c.courseName, '') AS courseName,
                         COALESCE(c.CreditUnit, 0) AS creditUnit
                  FROM campus_dynamics_portal.acad_course_registration cr
                  LEFT JOIN acad_course c ON c.courseID = cr.courseID
                  WHERE cr.regno = @reg AND cr.acad_year = @acad AND cr.semester = @sem
                  ORDER BY c.courseName ASC",
                new MySqlParameter("@reg",  regno),
                new MySqlParameter("@acad", acad_year),
                new MySqlParameter("@sem",  semester)
            );
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching registered courses: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  REGISTER COURSE
    // ═══════════════════════════════════════════════════════════════════

    private void HandleRegisterCourse()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        if (auth.UserType != "student")
        {
            ApiHelper.Error(Response, "Only students can register for courses.", "ACCESS_DENIED");
            return;
        }

        string courseId  = ApiHelper.RequireParam(Request, Response, "course_id");
        if (courseId == null) return;
        string acad_year = ApiHelper.RequireParam(Request, Response, "acad_year");
        if (acad_year == null) return;
        int semester = ApiHelper.ParamInt(Request, "semester", 1);

        try
        {
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
                { "course_id", courseId  },
                { "acad_year", acad_year },
                { "semester",  semester  }
            }, "Course registered successfully");
        }
        catch (Exception ex)
        {
            bool isDuplicate = ex.Message.ToLower().Contains("duplicate");
            string msg  = isDuplicate ? "This course is already registered." : "Error registering course: " + ex.Message;
            string code = isDuplicate ? "ALREADY_REGISTERED" : "SERVER_ERROR";
            ApiHelper.Error(Response, msg, code);
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DROP COURSE
    // ═══════════════════════════════════════════════════════════════════

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

    // ═══════════════════════════════════════════════════════════════════
    //  SEMESTER REGISTRATION  — uses AcademicEngine.IsSemesterOpen()
    // ═══════════════════════════════════════════════════════════════════

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
            // Semester-open check is advisory only — don't block if not configured
            bool semOpen = AcademicEngine.IsSemesterOpen(acad_year, semester);
            string semWarning = semOpen ? null
                : "Semester " + semester + " of " + acad_year + " is not marked open, but registration was processed.";

            // Full student profile needed for billing + course auto-registration
            // study_year derivation (in priority order):
            //   1. Already registered for this exact year+semester → use that (idempotent re-call)
            //   2. Other semester in same academic year already exists → use same studyyear
            //   3. Previous academic year exists → last studyyear + 1 (new year of study)
            //   4. Default: Year 1 (first-ever registration)
            DataTable dtStud = ApiHelper.Query(
                @"SELECT IFNULL(billingID, '-') AS billingID,
                         IFNULL(progid, '')     AS progid,
                         IFNULL(studsesion, '') AS studsesion,
                         COALESCE(
                             (SELECT r.studyyear FROM acad_registration r
                              WHERE r.regno = acad_student.regno
                                AND r.acad_year = @acad AND r.semester = @sem LIMIT 1),
                             (SELECT r.studyyear FROM acad_registration r
                              WHERE r.regno = acad_student.regno
                                AND r.acad_year = @acad LIMIT 1),
                             (SELECT LEAST(r.studyyear + 1, 5) FROM acad_registration r
                              WHERE r.regno = acad_student.regno
                                AND r.acad_year < @acad
                              ORDER BY r.acad_year DESC, r.semester DESC LIMIT 1),
                             1
                         ) AS study_year
                  FROM acad_student WHERE regno = @reg LIMIT 1",
                new MySqlParameter("@reg",  regno),
                new MySqlParameter("@acad", acad_year),
                new MySqlParameter("@sem",  semester)
            );

            if (dtStud.Rows.Count == 0)
            {
                ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
                return;
            }

            string billingId  = dtStud.Rows[0]["billingID"].ToString();
            string progid     = dtStud.Rows[0]["progid"].ToString();
            string session    = dtStud.Rows[0]["studsesion"].ToString();
            int    study_year = 1;
            int.TryParse(dtStud.Rows[0]["study_year"].ToString(), out study_year);
            if (string.IsNullOrEmpty(billingId)) billingId = "-";

            // Process the semester registration record — direct INSERT, no SP gating
            string regResult;
            bool regCreated = false;
            bool alreadyRegistered = false;

            long existCount = 0;
            DataTable existReg = ApiHelper.Query(
                "SELECT COUNT(*) AS cnt FROM acad_registration WHERE regno=@r AND acad_year=@ay AND semester=@sem",
                new MySqlParameter("@r",   regno),
                new MySqlParameter("@ay",  acad_year),
                new MySqlParameter("@sem", semester)
            );
            if (existReg.Rows.Count > 0)
                long.TryParse(existReg.Rows[0]["cnt"].ToString(), out existCount);

            if (existCount > 0)
            {
                alreadyRegistered = true;
                // Forward-enforce the rule: a pre-existing stub row (e.g. created as
                // UNREGISTERED by admission/promotion) must be promoted to REGISTERED so a
                // student is never left billed-but-unregistered. Billing runs unconditionally
                // below. Guard preserves an already-active status and the original registrar.
                ApiHelper.Execute(
                    @"UPDATE acad_registration
                      SET regstatus = 'REGISTERED',
                          examClearance = CASE WHEN IFNULL(TRIM(examClearance),'') = '' THEN 'UNCLEARED' ELSE examClearance END,
                          registeredBy  = CASE WHEN IFNULL(TRIM(registeredBy),'')  = '' THEN @user ELSE registeredBy END
                      WHERE regno = @r AND acad_year = @ay AND semester = @sem
                        AND UPPER(TRIM(IFNULL(regstatus,''))) NOT IN ('REGISTERED','LATE REGISTERED','CLEARED')",
                    new MySqlParameter("@r",    regno),
                    new MySqlParameter("@ay",   acad_year),
                    new MySqlParameter("@sem",  semester),
                    new MySqlParameter("@user", regno)
                );
                regResult = "Registered for " + acad_year + " Semester " + semester;
            }
            else
            {
                // Outstanding balance check — student must owe nothing before a new semester registration.
                // Credit balance (student overpaid) is fine. Only a positive (DR > CR) balance blocks.
                // On accounts DB error we allow registration (infrastructure failure must not lock out all students).
                try
                {
                    object balObj = ApiHelper.ScalarAccounts(
                        @"SELECT COALESCE(
                            SUM(CASE WHEN transactionType = 'DR' THEN transaction_amount ELSE 0 END) -
                            SUM(CASE WHEN transactionType = 'CR' THEN transaction_amount ELSE 0 END),
                          0) AS balance
                          FROM fin_ledger
                          WHERE TRIM(accountcode) = TRIM(@r)
                            AND account_type = 'Student'",
                        new MySqlParameter("@r", regno)
                    );
                    decimal outstandingBalance = (balObj == null || balObj == DBNull.Value)
                        ? 0m : Convert.ToDecimal(balObj);

                    if (outstandingBalance > 0)
                    {
                        ApiHelper.Error(Response,
                            string.Format(
                                "You have an outstanding balance of UGX {0:N0}. " +
                                "Your account must be cleared before you can register for a new semester. " +
                                "Please visit the Finance Office to make payment.",
                                outstandingBalance),
                            "OUTSTANDING_BALANCE");
                        return;
                    }
                }
                catch { /* accounts DB unreachable — allow registration, do not block */ }

                string residenceStatus = string.IsNullOrEmpty(session) ? "NON RESIDENT" : session;
                int inserted = ApiHelper.Execute(
                    @"INSERT INTO acad_registration
                        (regno, acad_year, semester, studyyear, regstatus,
                         id_cardStatus, residence_status, examClearance, registeredBy)
                      VALUES (@r, @ay, @sem, @sy, 'REGISTERED',
                         'UNPRINTED', @res, 'UNCLEARED', @user)",
                    new MySqlParameter("@r",    regno),
                    new MySqlParameter("@ay",   acad_year),
                    new MySqlParameter("@sem",  semester),
                    new MySqlParameter("@sy",   study_year),
                    new MySqlParameter("@res",  residenceStatus),
                    new MySqlParameter("@user", regno)
                );
                regCreated = inserted > 0;
                regResult = regCreated
                    ? "Registered for " + acad_year + " Semester " + semester
                    : "Registration insert failed — please try again.";
            }

            // Auto-register all programme courses for this semester (skip already-registered)
            int coursesAdded  = 0;
            int coursesSkipped = 0;
            string courseWarning = null;
            try
            {
                DataTable currDt = ApiHelper.Query(
                    @"SELECT pc.course_code FROM acad_programmecourses pc
                      WHERE pc.progcode = @prog AND pc.semester = @sem AND pc.study_year = @sy",
                    new MySqlParameter("@prog", progid),
                    new MySqlParameter("@sem",  semester),
                    new MySqlParameter("@sy",   study_year)
                );

                // Get already-registered courses to avoid duplicates
                var alreadyReg = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);
                DataTable existDt = ApiHelper.Query(
                    @"SELECT courseID FROM campus_dynamics_portal.acad_course_registration
                      WHERE regno = @reg AND acad_year = @acad AND semester = @sem",
                    new MySqlParameter("@reg",  regno),
                    new MySqlParameter("@acad", acad_year),
                    new MySqlParameter("@sem",  semester)
                );
                foreach (DataRow er in existDt.Rows)
                    alreadyReg.Add(er["courseID"].ToString().Trim());

                foreach (DataRow cr in currDt.Rows)
                {
                    string courseId = cr["course_code"].ToString().Trim();
                    if (alreadyReg.Contains(courseId)) { coursesSkipped++; continue; }
                    try
                    {
                        ApiHelper.Execute(
                            @"INSERT INTO campus_dynamics_portal.acad_course_registration
                              (regno, courseID, acad_year, semester, course_status, prog_id, stud_session)
                              VALUES (@r, @c, @ay, @sem, 'Normal', @prog, @sess)",
                            new MySqlParameter("@r",    regno),
                            new MySqlParameter("@c",    courseId),
                            new MySqlParameter("@ay",   acad_year),
                            new MySqlParameter("@sem",  semester),
                            new MySqlParameter("@prog", progid),
                            new MySqlParameter("@sess", session)
                        );
                        coursesAdded++;
                    }
                    catch (MySqlException mex2)
                    {
                        if (mex2.Number == 1062) coursesSkipped++; // duplicate — safe
                        else courseWarning = "Some courses could not be registered: " + mex2.Message;
                    }
                }
            }
            catch (Exception courseEx)
            {
                courseWarning = "Course auto-registration skipped: " + courseEx.Message;
            }

            // Auto-billing via the proper wrapper SP.
            // fin_AutoBillOnRegistration checks registration status internally,
            // handles ACCOMO only for RESIDENT students, and calls fin_Autobilling.
            // fin_TermlyItemBillingFN has a pre-check — safe to call multiple times.
            bool billingOk = true;
            string billingMsg = null;
            int billRowsAfter = 0;
            try
            {
                ApiHelper.QueryAccounts(
                    "CALL fin_AutoBillOnRegistration(@r, @a, @s, @u)",
                    new MySqlParameter("@r", regno),
                    new MySqlParameter("@a", acad_year),
                    new MySqlParameter("@s", semester),
                    new MySqlParameter("@u", regno)
                );

                // Post-billing verification: confirm at least one bill row exists
                object billCount = ApiHelper.ScalarAccounts(
                    "SELECT COUNT(*) FROM fin_studentfeestracking WHERE TRIM(regno)=TRIM(@r) AND acadyear=@a AND semester=@s AND trans_type='Bill'",
                    new MySqlParameter("@r", regno),
                    new MySqlParameter("@a", acad_year),
                    new MySqlParameter("@s", semester)
                );
                billRowsAfter = Convert.ToInt32(billCount);
                if (billRowsAfter == 0)
                {
                    billingOk  = false;
                    billingMsg = "Billing SP ran but no bill rows were created. Check fee schedule for " + progid + ".";
                    ApiHelper.LogBillingError(regno, acad_year, semester, billingMsg, "API-NoRows");
                }
            }
            catch (MySqlException mex)
            {
                if (mex.Number != 1062) // 1062 = duplicate key — already billed, safe to swallow
                {
                    billingOk  = false;
                    billingMsg = mex.Message;
                    try { ApiHelper.LogBillingError(regno, acad_year, semester, mex.Message, "API-MySql"); } catch { }
                }
            }
            catch (Exception bex)
            {
                billingOk  = false;
                billingMsg = bex.Message;
                try { ApiHelper.LogBillingError(regno, acad_year, semester, bex.Message, "API-Exception"); } catch { }
            }

            var result = new Dictionary<string, object>
            {
                { "registration_result",   regResult        },
                { "newly_registered",      regCreated        },
                { "already_registered",    alreadyRegistered },
                { "acad_year",             acad_year        },
                { "semester",              semester         },
                { "study_year",            study_year       },
                { "programme",             progid           },
                { "courses_auto_added",    coursesAdded     },
                { "courses_already_done",  coursesSkipped   },
                { "billing_processed",     billingOk        },
                { "bill_rows_created",     billRowsAfter    }
            };
            if (semWarning    != null) result["semester_warning"]  = semWarning;
            if (courseWarning != null) result["course_warning"]    = courseWarning;
            if (billingMsg    != null) result["billing_warning"]   = billingMsg;

            string msg = regCreated       ? "Semester registration completed"
                       : alreadyRegistered ? "Already registered for this semester"
                       : "Registration failed";
            ApiHelper.Success(Response, result, msg);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Registration error: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  REGISTRATION HISTORY  — uses AcademicEngine status helpers
    // ═══════════════════════════════════════════════════════════════════

    private void HandleRegistrationHistory()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            MobileDataTableAdapters.acad_registrationTableAdapter REGHISTORY = new MobileDataTableAdapters.acad_registrationTableAdapter();
            DataTable dt = REGHISTORY.GetRegistrationHistory(regno);

            var rows = ApiHelper.TableToList(dt);
            foreach (var row in rows)
            {
                string raw = row.ContainsKey("regstatus") && row["regstatus"] != null
                    ? row["regstatus"].ToString() : "";
                row["status_label"]          = AcademicEngine.MapRegistrationStatus(raw);
                row["is_active_registration"] = AcademicEngine.IsActiveRegistrationStatus(raw);
            }
            ApiHelper.Success(Response, rows);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching registration history: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ENROLLMENT STATUS  — uses AcademicEngine status helpers
    // ═══════════════════════════════════════════════════════════════════

    private void HandleEnrollmentStatus()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        int semester     = ApiHelper.ParamInt(Request, "semester", 0);

        try
        {
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

            string regSql = @"SELECT r.acad_year, r.semester, r.studyyear AS study_year,
                                     r.regstatus AS reg_status
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
            var registrations = ApiHelper.TableToList(regDt);
            foreach (var row in registrations)
            {
                string regStatus = row.ContainsKey("reg_status") && row["reg_status"] != null
                    ? row["reg_status"].ToString() : "";
                row["status_label"] = AcademicEngine.MapRegistrationStatus(regStatus);
                row["is_active"]    = AcademicEngine.IsActiveRegistrationStatus(regStatus);
                if (AcademicEngine.IsActiveRegistrationStatus(regStatus)) isCurrentlyEnrolled = true;
            }

            var data = new Dictionary<string, object>
            {
                { "student",                    profile                },
                { "is_enrolled",                isCurrentlyEnrolled   },
                { "total_semesters_registered", registrations.Count   },
                { "registrations",              registrations         }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error checking enrollment status: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  COURSE DETAILS  (ODEL)
    // ═══════════════════════════════════════════════════════════════════

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

        DataTable dtProgs = ApiHelper.Query(
            @"SELECT DISTINCT pc.progcode, p.progname AS programme_name,
                     pc.study_year AS study_year, pc.semester
              FROM acad_programmecourses pc
              LEFT JOIN acad_programme p ON pc.progcode = p.progcode
              WHERE pc.course_code = @code
              ORDER BY p.progname, pc.study_year, pc.semester",
            new MySqlParameter("@code", courseCode)
        );

        course["programmes"] = ApiHelper.TableToList(dtProgs);

        // FIX-11: Lecturer assignments
        try
        {
            DataTable dtLec = ApiHelper.Query(
                @"SELECT DISTINCT e.emp_no,
                         CONCAT(IFNULL(e.firstname,''), ' ', IFNULL(e.lastname,'')) AS full_name,
                         e.email, e.studPhone AS phone,
                         pc.progcode, pc.study_year, pc.semester
                  FROM acad_programmecourses pc
                  LEFT JOIN hrm_employee e ON pc.lecturer_id = e.emp_no
                  WHERE pc.course_code = @code
                    AND pc.lecturer_id IS NOT NULL AND pc.lecturer_id <> ''
                  ORDER BY pc.study_year, pc.semester",
                new MySqlParameter("@code", courseCode)
            );
            course["lecturers"] = ApiHelper.TableToList(dtLec);
        }
        catch
        {
            course["lecturers"] = new List<object>();
        }

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

    // ═══════════════════════════════════════════════════════════════════
    //  COURSE ENROLLMENTS  (ODEL, staff only)
    // ═══════════════════════════════════════════════════════════════════

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

        DataTable dtCourse = ApiHelper.Query(
            "SELECT courseID AS course_code, courseName AS course_name, CreditUnit AS credit_units FROM acad_course WHERE courseID = @code",
            new MySqlParameter("@code", courseCode)
        );

        var data = new Dictionary<string, object>
        {
            { "course_code",   courseCode },
            { "course_name",   dtCourse.Rows.Count > 0 ? Convert.ToString(dtCourse.Rows[0]["course_name"]) : "" },
            { "credit_units",  dtCourse.Rows.Count > 0 ? Convert.ToString(dtCourse.Rows[0]["credit_units"]) : "" },
            { "academic_year", acadYear },
            { "semester",      semester },
            { "total_enrolled",students.Count },
            { "students",      students }
        };
        ApiHelper.Success(Response, data);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PROGRAMME CURRICULUM  (ODEL)
    // ═══════════════════════════════════════════════════════════════════

    private void HandleProgrammeCurriculum()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string progcode = ApiHelper.RequireParam(Request, Response, "progcode");
        if (progcode == null) return;

        DataTable dtProg = ApiHelper.Query(
            @"SELECT p.progcode, p.progname, f.faculty_name AS faculty,
                     p.levelCode AS level,
                     p.couselength AS duration_years
              FROM acad_programme p
              LEFT JOIN acad_faculty f ON p.faculty_code = f.faculty_code
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

        DataTable dtCourses = ApiHelper.Query(
            @"SELECT pc.course_code AS course_code, c.courseName AS course_name,
                     c.CreditUnit AS credit_units, pc.study_year AS study_year,
                     pc.semester, IFNULL(pc.course_type, 'CORE') AS course_type,
                     c.courseCategory AS category
              FROM acad_programmecourses pc
              LEFT JOIN acad_course c ON pc.course_code = c.courseID
              WHERE pc.progcode = @prog
              ORDER BY pc.study_year, pc.semester, c.courseName",
            new MySqlParameter("@prog", progcode)
        );

        var curriculum = new Dictionary<string, object>();
        int totalCredits = 0;
        foreach (DataRow row in dtCourses.Rows)
        {
            string year = Convert.ToString(row["study_year"]);
            string sem  = Convert.ToString(row["semester"]);
            string key  = "Year " + year + " - Semester " + sem;

            if (!curriculum.ContainsKey(key))
                curriculum[key] = new List<Dictionary<string, object>>();

            var courseDict = new Dictionary<string, object>
            {
                { "course_code", Convert.ToString(row["course_code"]) },
                { "course_name", Convert.ToString(row["course_name"]) },
                { "credit_units",Convert.ToString(row["credit_units"]) },
                { "course_type", Convert.ToString(row["course_type"]) },
                { "category",    Convert.ToString(row["category"])    }
            };

            ((List<Dictionary<string, object>>)curriculum[key]).Add(courseDict);

            int cu;
            if (int.TryParse(Convert.ToString(row["credit_units"]), out cu))
                totalCredits += cu;
        }

        var data = new Dictionary<string, object>
        {
            { "programme",          progInfo           },
            { "total_courses",      dtCourses.Rows.Count },
            { "total_credit_units", totalCredits       },
            { "curriculum",         curriculum         }
        };
        ApiHelper.Success(Response, data);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  GRADING SCHEME
    // ═══════════════════════════════════════════════════════════════════

    private void HandleGradingScheme()
    {
        var gradeScale = new List<Dictionary<string, object>>();

        string[][] grades = new string[][] {
            new string[] { "A",  "90", "100", "5.0", "Excellent"     },
            new string[] { "B+", "80", "89",  "4.5", "Very Good"     },
            new string[] { "B",  "70", "79",  "4.0", "Good"          },
            new string[] { "C+", "60", "69",  "3.5", "Fairly Good"   },
            new string[] { "C",  "50", "59",  "3.0", "Pass"          },
            new string[] { "D+", "45", "49",  "2.5", "Marginal Pass" },
            new string[] { "D",  "40", "44",  "2.0", "Marginal Fail" },
            new string[] { "F",  "0",  "39",  "0.0", "Fail"          }
        };

        foreach (string[] g in grades)
        {
            gradeScale.Add(new Dictionary<string, object>
            {
                { "letter",      g[0] },
                { "min_score",   Convert.ToInt32(g[1])  },
                { "max_score",   Convert.ToInt32(g[2])  },
                { "grade_point", Convert.ToDouble(g[3]) },
                { "remark",      g[4] }
            });
        }

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
                        { "letter",      Convert.ToString(row["letter"])              },
                        { "min_score",   Convert.ToInt32(row["min_score"])            },
                        { "max_score",   Convert.ToInt32(row["max_score"])            },
                        { "grade_point", Convert.ToDouble(row["grade_point"])         },
                        { "remark",      Convert.ToString(row["remark"])              }
                    });
                }
            }
        }
        catch { /* acad_grading_scale may not exist; hardcoded scale is used */ }

        var data = new Dictionary<string, object>
        {
            { "institution",  "Mountains of the Moon University" },
            { "pass_mark",    50   },
            { "max_gpa",      5.0  },
            { "total_grades", gradeScale.Count },
            { "scale",        gradeScale }
        };
        ApiHelper.Success(Response, data);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SEMESTER STATUS
    // ═══════════════════════════════════════════════════════════════════

    private void HandleSemesterStatus()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string acad_year = ApiHelper.Param(Request, "acad_year", "");

        try
        {
            string sql = @"SELECT acad_year,
                                  semester_1_is_active, semester_2_is_active, semester_3_is_active
                           FROM acad_acadyears";
            var parms = new List<MySqlParameter>();

            if (!string.IsNullOrEmpty(acad_year))
            {
                if (!ApiHelper.ValidateAcadYear(acad_year, Response)) return;
                sql += " WHERE acad_year = @acad LIMIT 1";
                parms.Add(new MySqlParameter("@acad", acad_year));
            }
            else
            {
                sql += " ORDER BY acad_year DESC LIMIT 5";
            }

            DataTable dt = ApiHelper.Query(sql, parms.ToArray());
            var result = new List<Dictionary<string, object>>();

            foreach (DataRow row in dt.Rows)
            {
                string ay = row["acad_year"].ToString();
                bool s1 = row["semester_1_is_active"] != DBNull.Value &&
                          row["semester_1_is_active"].ToString().Equals("Yes", StringComparison.OrdinalIgnoreCase);
                bool s2 = row["semester_2_is_active"] != DBNull.Value &&
                          row["semester_2_is_active"].ToString().Equals("Yes", StringComparison.OrdinalIgnoreCase);
                bool s3 = row["semester_3_is_active"] != DBNull.Value &&
                          row["semester_3_is_active"].ToString().Equals("Yes", StringComparison.OrdinalIgnoreCase);

                result.Add(new Dictionary<string, object>
                {
                    { "acad_year", ay },
                    { "semesters", new Dictionary<string, object>
                        {
                            { "1", new Dictionary<string, object> { { "is_open", s1 }, { "label", s1 ? "Open" : "Closed" } } },
                            { "2", new Dictionary<string, object> { { "is_open", s2 }, { "label", s2 ? "Open" : "Closed" } } },
                            { "3", new Dictionary<string, object> { { "is_open", s3 }, { "label", s3 ? "Open" : "Closed" } } }
                        }
                    }
                });
            }

            ApiHelper.Success(Response, result);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching semester status: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  RETAKE COURSES  — uses AcademicEngine.GetRetakeCourses()
    // ═══════════════════════════════════════════════════════════════════

    private void HandleRetakeCourses()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            DataTable dt = ApiHelper.QueryProc("acad_GetAllResults", new MySqlParameter("@reg", regno));

            List<Dictionary<string, object>> retakable = AcademicEngine.GetRetakeCourses(dt);

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "total_retakable", retakable.Count },
                { "courses",         retakable        }
            });
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching retake courses: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  STUDENT ACADEMIC SUMMARY  — single-call comprehensive snapshot
    //  Returns profile, GPA, registration state, and retake list.
    // ═══════════════════════════════════════════════════════════════════

    private void HandleStudentAcademicSummary()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        try
        {
            // Profile
            DataTable profileDt = ApiHelper.Query(
                @"SELECT s.regno, s.firstname, s.othername, s.email,
                         p.progname AS programme, s.progid AS programme_code,
                         s.stud_status, s.entryyear AS entry_year,
                         s.studsesion AS session, s.nationality
                  FROM acad_student s
                  LEFT JOIN acad_programme p ON s.progid = p.progcode
                  WHERE s.regno = @reg",
                new MySqlParameter("@reg", regno)
            );

            if (profileDt.Rows.Count == 0)
            {
                ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
                return;
            }

            var profile = ApiHelper.FirstRowToDict(profileDt);

            // GPA
            DataTable resultsDt = ApiHelper.QueryProc("acad_GetAllResults", new MySqlParameter("@reg", regno));
            GpaResult gpa = AcademicEngine.ComputeGPA(resultsDt);

            // Latest registration
            DataTable regDt = ApiHelper.Query(
                @"SELECT r.acad_year, r.semester, r.studyyear AS study_year,
                         r.regstatus AS reg_status
                  FROM acad_registration r
                  WHERE r.regno = @reg
                  ORDER BY r.acad_year DESC, r.semester DESC
                  LIMIT 1",
                new MySqlParameter("@reg", regno)
            );

            object latestReg = null;
            bool isEnrolled  = false;
            int historyCount = 0;
            try
            {
                DataTable histDt = ApiHelper.Query(
                    "SELECT COUNT(*) AS cnt FROM acad_registration WHERE regno = @reg",
                    new MySqlParameter("@reg", regno)
                );
                if (histDt.Rows.Count > 0) int.TryParse(histDt.Rows[0]["cnt"].ToString(), out historyCount);
            }
            catch { }

            if (regDt.Rows.Count > 0)
            {
                DataRow rr = regDt.Rows[0];
                string rawStatus = rr["reg_status"] != DBNull.Value ? rr["reg_status"].ToString() : "";
                isEnrolled = AcademicEngine.IsActiveRegistrationStatus(rawStatus);
                int sem = 0;
                if (rr["semester"] != DBNull.Value) int.TryParse(rr["semester"].ToString(), out sem);

                var rs = new RegistrationState
                {
                    AcadYear    = rr["acad_year"] != DBNull.Value ? rr["acad_year"].ToString() : "",
                    Semester    = sem,
                    Status      = rawStatus,
                    StatusLabel = AcademicEngine.MapRegistrationStatus(rawStatus),
                    IsActive    = isEnrolled,
                    StudyYear   = rr["study_year"] != DBNull.Value ? rr["study_year"].ToString() : ""
                };
                latestReg = rs.ToDictionary();
            }

            // Retake courses
            List<Dictionary<string, object>> retakable = AcademicEngine.GetRetakeCourses(resultsDt);

            var data = new Dictionary<string, object>
            {
                { "student",      profile },
                { "gpa",          gpa.ToDictionary() },
                { "registration", new Dictionary<string, object>
                    {
                        { "is_currently_enrolled", isEnrolled    },
                        { "history_count",          historyCount  },
                        { "latest",                 latestReg     }
                    }
                },
                { "retake", new Dictionary<string, object>
                    {
                        { "total_retakable", retakable.Count },
                        { "courses",         retakable        }
                    }
                }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching academic summary: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ACADEMIC STANDING  — boolean verdict with per-rule checks
    //  Rules: minimum GPA (≥ 2.0), active enrollment, no outstanding fails.
    //  Returns "good_standing" | "academic_probation".
    // ═══════════════════════════════════════════════════════════════════

    private void HandleAcademicStanding()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        // Configurable threshold (can be extended to read from DB in future)
        const double MIN_GPA           = 2.0;
        const int    MAX_RETAKE_WARNING = 3;    // ≥ 3 retakable courses = warning note

        try
        {
            // GPA
            DataTable resultsDt = ApiHelper.QueryProc("acad_GetAllResults", new MySqlParameter("@reg", regno));
            GpaResult gpa = AcademicEngine.ComputeGPA(resultsDt);

            // Registration
            DataTable regDt = ApiHelper.Query(
                @"SELECT r.acad_year, r.semester, r.studyyear AS study_year,
                         r.regstatus AS reg_status
                  FROM acad_registration r
                  WHERE r.regno = @reg
                  ORDER BY r.acad_year DESC, r.semester DESC
                  LIMIT 1",
                new MySqlParameter("@reg", regno)
            );

            bool isEnrolled   = false;
            string latestAcadYear = "", latestRegLabel = "No registrations found";
            if (regDt.Rows.Count > 0)
            {
                string raw = regDt.Rows[0]["reg_status"] != DBNull.Value ? regDt.Rows[0]["reg_status"].ToString() : "";
                isEnrolled    = AcademicEngine.IsActiveRegistrationStatus(raw);
                latestAcadYear = regDt.Rows[0]["acad_year"] != DBNull.Value ? regDt.Rows[0]["acad_year"].ToString() : "";
                latestRegLabel = AcademicEngine.MapRegistrationStatus(raw);
            }

            // Retakes
            List<Dictionary<string, object>> retakable = AcademicEngine.GetRetakeCourses(resultsDt);
            int retakeCount = retakable.Count;

            // ── Evaluate checks ─────────────────────────────────────────
            var checks = new List<Dictionary<string, object>>();

            bool gpaPass = gpa.CGPA >= MIN_GPA || gpa.TotalCredits == 0;
            checks.Add(new Dictionary<string, object>
            {
                { "rule",         "Minimum GPA"                                   },
                { "passed",       gpaPass                                          },
                { "threshold",    "CGPA ≥ " + MIN_GPA.ToString("F1")         },
                { "actual_value", gpa.CGPA.ToString("F2")                         },
                { "detail",       gpaPass
                    ? string.Format("CGPA {0:F2} meets minimum of {1:F1}.", gpa.CGPA, MIN_GPA)
                    : string.Format("CGPA {0:F2} is below the required minimum of {1:F1}.", gpa.CGPA, MIN_GPA) }
            });

            bool enrollPass = isEnrolled || regDt.Rows.Count == 0;
            checks.Add(new Dictionary<string, object>
            {
                { "rule",         "Active Enrollment"                              },
                { "passed",       enrollPass                                        },
                { "threshold",    "At least one active registration"               },
                { "actual_value", latestRegLabel                                   },
                { "detail",       enrollPass
                    ? "Active registration found (" + latestAcadYear + ")."
                    : "No active registration. Last status: " + latestRegLabel + "." }
            });

            bool retakePass = retakeCount < MAX_RETAKE_WARNING;
            checks.Add(new Dictionary<string, object>
            {
                { "rule",         "Outstanding Fails"                               },
                { "passed",       retakePass                                         },
                { "threshold",    "Fewer than " + MAX_RETAKE_WARNING + " retakable courses" },
                { "actual_value", retakeCount + " course(s)"                        },
                { "detail",       retakePass
                    ? string.Format("{0} retakable course(s) — within acceptable range.", retakeCount)
                    : string.Format("{0} courses still failing and eligible for retake.", retakeCount) }
            });

            bool hasGoodStanding = gpaPass && enrollPass;
            string verdict = hasGoodStanding ? "good_standing" : "academic_probation";

            int rulesPassed = 0;
            foreach (var c in checks) { if ((bool)c["passed"]) rulesPassed++; }

            var data = new Dictionary<string, object>
            {
                { "has_good_standing",  hasGoodStanding },
                { "verdict",            verdict         },
                { "verdict_reason",     string.Format("{0}/{1} standing checks passed.", rulesPassed, checks.Count) },
                { "checks",             checks          },
                { "gpa",                gpa.ToDictionary() },
                { "retake_summary", new Dictionary<string, object>
                    {
                        { "total_retakable", retakeCount },
                        { "courses",         retakable   }
                    }
                },
                { "evaluated_at", DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ") }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error evaluating academic standing: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SEMESTER DELETION REQUESTS
    // ═══════════════════════════════════════════════════════════════════

    private void EnsureSemesterDeletionSchema()
    {
        try
        {
            ApiHelper.Query(@"CREATE TABLE IF NOT EXISTS campus_dynamics_portal.acad_semester_deletion_requests (
                id                INT AUTO_INCREMENT PRIMARY KEY,
                regno             VARCHAR(50)  NOT NULL,
                student_name      VARCHAR(200) NOT NULL DEFAULT '',
                programme_code    VARCHAR(50)  NOT NULL DEFAULT '',
                programme_name    VARCHAR(200) NOT NULL DEFAULT '',
                acad_year         VARCHAR(20)  NOT NULL,
                study_year        INT          NOT NULL DEFAULT 1,
                semester          INT          NOT NULL,
                request_reason    TEXT         NOT NULL,
                status            ENUM('PENDING','APPROVED','REJECTED','AUTO_APPROVED') NOT NULL DEFAULT 'PENDING',
                admin_username    VARCHAR(100) NULL,
                admin_comment     TEXT         NULL,
                deletion_executed TINYINT(1)   NOT NULL DEFAULT 0,
                deletion_executed_at DATETIME  NULL,
                student_notified  TINYINT(1)   NOT NULL DEFAULT 0,
                student_notified_at DATETIME   NULL,
                student_seen      TINYINT(1)   NOT NULL DEFAULT 0,
                student_seen_at   DATETIME     NULL,
                created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
                decided_at        DATETIME     NULL,
                INDEX idx_sdr_regno  (regno),
                INDEX idx_sdr_status (status)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

            // Expand status ENUM on existing tables to include AUTO_APPROVED
            try { ApiHelper.Query("ALTER TABLE campus_dynamics_portal.acad_semester_deletion_requests MODIFY status ENUM('PENDING','APPROVED','REJECTED','AUTO_APPROVED') NOT NULL DEFAULT 'PENDING'"); } catch { }
            // Add missing columns if they were not in the original API-created schema
            try { ApiHelper.Query("ALTER TABLE campus_dynamics_portal.acad_semester_deletion_requests ADD COLUMN deletion_executed_at DATETIME NULL AFTER deletion_executed"); } catch { }
            try { ApiHelper.Query("ALTER TABLE campus_dynamics_portal.acad_semester_deletion_requests ADD COLUMN student_notified TINYINT(1) NOT NULL DEFAULT 0"); } catch { }
            try { ApiHelper.Query("ALTER TABLE campus_dynamics_portal.acad_semester_deletion_requests ADD COLUMN student_notified_at DATETIME NULL"); } catch { }
            try { ApiHelper.Query("ALTER TABLE campus_dynamics_portal.acad_semester_deletion_requests ADD COLUMN student_seen TINYINT(1) NOT NULL DEFAULT 0"); } catch { }
            try { ApiHelper.Query("ALTER TABLE campus_dynamics_portal.acad_semester_deletion_requests ADD COLUMN student_seen_at DATETIME NULL"); } catch { }
        }
        catch { }
    }

    private void HandleSemesterDeletionRequests()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureSemesterDeletionSchema();

        string status   = ApiHelper.Param(Request, "status", "");
        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        string q        = ApiHelper.Param(Request, "q", "");
        int page        = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size        = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 20)));
        int offset      = (page - 1) * size;

        var where = new System.Text.StringBuilder("WHERE 1=1");
        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(status)) { where.Append(" AND r.status = @st"); parms.Add(new MySqlParameter("@st", status.ToUpper())); }
        if (!string.IsNullOrEmpty(acadYear)) { where.Append(" AND r.acad_year = @ay"); parms.Add(new MySqlParameter("@ay", acadYear)); }
        if (!string.IsNullOrEmpty(q))
        {
            where.Append(" AND (r.regno LIKE @q OR r.student_name LIKE @q OR r.programme_code LIKE @q)");
            parms.Add(new MySqlParameter("@q", "%" + q + "%"));
        }

        var countParms = new List<MySqlParameter>(parms);
        int total = Convert.ToInt32(ApiHelper.Scalar(
            "SELECT COUNT(*) FROM campus_dynamics_portal.acad_semester_deletion_requests r " + where,
            countParms.ToArray()));

        parms.Add(new MySqlParameter("@lim", size));
        parms.Add(new MySqlParameter("@off", offset));

        DataTable dt = ApiHelper.Query(
            @"SELECT r.id, r.regno, r.student_name, r.programme_code, r.programme_name,
                     r.acad_year, r.study_year, r.semester, r.request_reason,
                     r.status, r.admin_username, r.admin_comment, r.deletion_executed,
                     DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i') AS created_at,
                     DATE_FORMAT(r.decided_at, '%Y-%m-%d %H:%i') AS decided_at
              FROM campus_dynamics_portal.acad_semester_deletion_requests r "
            + where + " ORDER BY r.created_at DESC LIMIT @lim OFFSET @off",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "requests", ApiHelper.TableToList(dt) }
        });
    }

    private void HandleSemesterDeletionRequest()
    {
        TokenInfo auth;
        string regno = GetStudentRegNo(out auth);
        if (regno == null) return;

        EnsureSemesterDeletionSchema();

        int id = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }

        string sql = @"SELECT r.id, r.regno, r.student_name, r.programme_code, r.programme_name,
                              r.acad_year, r.study_year, r.semester, r.request_reason,
                              r.status, r.admin_username, r.admin_comment, r.deletion_executed,
                              DATE_FORMAT(r.created_at, '%Y-%m-%d %H:%i') AS created_at,
                              DATE_FORMAT(r.decided_at, '%Y-%m-%d %H:%i') AS decided_at
                       FROM campus_dynamics_portal.acad_semester_deletion_requests r
                       WHERE r.id = @id";

        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@id", id));

        // Students may only see their own
        if (auth.UserType != "staff")
        {
            sql += " AND r.regno = @r";
            parms.Add(new MySqlParameter("@r", regno));
        }

        DataTable dt = ApiHelper.Query(sql + " LIMIT 1", parms.ToArray());
        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Request not found.", "NOT_FOUND"); return; }

        ApiHelper.Success(Response, ApiHelper.FirstRowToDict(dt));
    }

    private void HandleSubmitSemesterDeletion()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType == "staff") { ApiHelper.Error(Response, "This endpoint is for students only.", "FORBIDDEN"); return; }

        EnsureSemesterDeletionSchema();

        string acadYear  = ApiHelper.RequireParam(Request, Response, "acad_year"); if (acadYear == null) return;
        int semester     = ApiHelper.ParamInt(Request, "semester", 0);
        if (semester <= 0) { ApiHelper.Error(Response, "semester is required.", "MISSING_PARAM"); return; }
        string reason    = ApiHelper.RequireParam(Request, Response, "reason"); if (reason == null) return;
        string regno     = auth.UserId;

        // Verify the semester registration exists and get the exact studyyear
        DataTable regRow = ApiHelper.Query(
            "SELECT studyyear FROM acad_registration WHERE TRIM(regno)=@r AND acad_year=@ay AND semester=@sem LIMIT 1",
            new MySqlParameter("@r",   regno),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sem", semester));
        if (regRow.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Semester registration not found.", "NOT_FOUND"); return;
        }
        int studyYearInt = regRow.Rows[0]["studyyear"] != DBNull.Value ? Convert.ToInt32(regRow.Rows[0]["studyyear"]) : 1;
        string studyYear = studyYearInt.ToString();

        // Get student info for name and programme
        string studentName = regno, progCode = "", progName = "";
        try
        {
            DataTable sDt = ApiHelper.Query(
                @"SELECT CONCAT(TRIM(COALESCE(s.firstname,'')), ' ', TRIM(COALESCE(s.othername,''))) AS full_name,
                         s.progid AS programme_code, IFNULL(p.progname,'') AS programme_name
                  FROM acad_student s
                  LEFT JOIN acad_programme p ON s.progid = p.progcode
                  WHERE s.regno = @r LIMIT 1",
                new MySqlParameter("@r", regno));
            if (sDt.Rows.Count > 0)
            {
                studentName = sDt.Rows[0]["full_name"].ToString().Trim();
                progCode    = sDt.Rows[0]["programme_code"].ToString();
                progName    = sDt.Rows[0]["programme_name"].ToString();
            }
        }
        catch { }

        // Check whether any results exist for this semester — same logic as portal MyCourses.
        // This must run BEFORE the duplicate-pending check: if no marks exist the semester is
        // auto-deletable and the duplicate guard must not block it.
        object marksCount = ApiHelper.Scalar(
            @"SELECT COUNT(*) FROM acad_results
              WHERE TRIM(regno)=@r AND acad=@ay AND semester=@sem
                AND ((score IS NOT NULL AND TRIM(CAST(score AS CHAR)) <> '')
                  OR (grade IS NOT NULL AND TRIM(grade) <> ''))",
            new MySqlParameter("@r",   regno),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sem", semester));
        bool hasMarks = Convert.ToInt32(marksCount) > 0;

        if (!hasMarks)
        {
            // Auto-delete: no results recorded — execute immediately without admin review
            ApiHelper.Execute(
                "DELETE FROM campus_dynamics_portal.acad_course_registration WHERE TRIM(regno)=@r AND acad_year=@ay AND semester=@sem",
                new MySqlParameter("@r",   regno),
                new MySqlParameter("@ay",  acadYear),
                new MySqlParameter("@sem", semester));

            int deleted = ApiHelper.Execute(
                "DELETE FROM acad_registration WHERE TRIM(regno)=@r AND acad_year=@ay AND studyyear=@sy AND semester=@sem LIMIT 1",
                new MySqlParameter("@r",   regno),
                new MySqlParameter("@ay",  acadYear),
                new MySqlParameter("@sy",  studyYearInt),
                new MySqlParameter("@sem", semester));

            if (deleted == 0)
            {
                ApiHelper.Error(Response, "Semester registration could not be deleted. Please try again.", "DELETE_FAILED"); return;
            }

            // Record the auto-approved deletion for audit trail
            ApiHelper.Execute(
                @"INSERT INTO campus_dynamics_portal.acad_semester_deletion_requests
                  (regno, student_name, programme_code, programme_name, acad_year, study_year, semester,
                   request_reason, status, admin_username, admin_comment, decided_at,
                   deletion_executed, deletion_executed_at, student_notified, student_notified_at)
                  VALUES (@r, @n, @pc, @pn, @ay, @sy, @sem, @rsn,
                          'AUTO_APPROVED', 'SYSTEM', 'Auto-approved: no results recorded for this semester.',
                          NOW(), 1, NOW(), 1, NOW())",
                new MySqlParameter("@r",   regno),
                new MySqlParameter("@n",   studentName),
                new MySqlParameter("@pc",  progCode),
                new MySqlParameter("@pn",  progName),
                new MySqlParameter("@ay",  acadYear),
                new MySqlParameter("@sy",  studyYear),
                new MySqlParameter("@sem", semester),
                new MySqlParameter("@rsn", reason));

            int newId = Convert.ToInt32(ApiHelper.Scalar("SELECT LAST_INSERT_ID()"));

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "id", newId }, { "status", "AUTO_APPROVED" }, { "auto_deleted", true }
            }, "Semester deleted successfully — no results were recorded for this semester.");
            return;
        }

        // Has marks — submit for admin review; enforce one pending request per semester
        object existing = ApiHelper.Scalar(
            "SELECT COUNT(*) FROM campus_dynamics_portal.acad_semester_deletion_requests WHERE regno = @r AND acad_year = @ay AND semester = @sem AND status = 'PENDING'",
            new MySqlParameter("@r",   regno),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sem", semester));
        if (Convert.ToInt32(existing) > 0)
        {
            ApiHelper.Error(Response, "You already have a pending request for this semester.", "DUPLICATE"); return;
        }

        ApiHelper.Execute(
            @"INSERT INTO campus_dynamics_portal.acad_semester_deletion_requests
              (regno, student_name, programme_code, programme_name, acad_year, study_year, semester, request_reason)
              VALUES (@r, @n, @pc, @pn, @ay, @sy, @sem, @rsn)",
            new MySqlParameter("@r",   regno),
            new MySqlParameter("@n",   studentName),
            new MySqlParameter("@pc",  progCode),
            new MySqlParameter("@pn",  progName),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sy",  studyYear),
            new MySqlParameter("@sem", semester),
            new MySqlParameter("@rsn", reason));

        int requestId = Convert.ToInt32(ApiHelper.Scalar("SELECT LAST_INSERT_ID()"));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "id", requestId }, { "status", "PENDING" }, { "auto_deleted", false }
        }, "Results exist for this semester — deletion request submitted for admin review.");
    }

    private void HandleDecideSemesterDeletion()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureSemesterDeletionSchema();

        int id         = ApiHelper.ParamInt(Request, "id", 0);
        if (id <= 0) { ApiHelper.Error(Response, "id is required.", "MISSING_PARAM"); return; }
        string decision= ApiHelper.RequireParam(Request, Response, "decision"); if (decision == null) return;
        string comment = ApiHelper.Param(Request, "comment", "");

        decision = decision.ToUpper();
        if (decision != "APPROVED" && decision != "REJECTED")
        {
            ApiHelper.Error(Response, "decision must be APPROVED or REJECTED.", "VALIDATION_ERROR"); return;
        }

        DataTable dt = ApiHelper.Query(
            "SELECT id, status, deletion_executed, regno, acad_year, semester FROM campus_dynamics_portal.acad_semester_deletion_requests WHERE id = @id LIMIT 1",
            new MySqlParameter("@id", id));
        if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Request not found.", "NOT_FOUND"); return; }

        if (Convert.ToInt32(dt.Rows[0]["deletion_executed"]) == 1)
        {
            ApiHelper.Error(Response, "This request has already been executed and cannot be changed.", "ALREADY_EXECUTED"); return;
        }

        ApiHelper.Execute(
            @"UPDATE campus_dynamics_portal.acad_semester_deletion_requests
              SET status = @dec, admin_username = @admin, admin_comment = @cmt, decided_at = NOW()
              WHERE id = @id",
            new MySqlParameter("@dec",   decision),
            new MySqlParameter("@admin", auth.UserId),
            new MySqlParameter("@cmt",   comment),
            new MySqlParameter("@id",    id));

        // If approved, execute the deletion of course registrations
        if (decision == "APPROVED")
        {
            string regno    = dt.Rows[0]["regno"].ToString();
            string acadYear = dt.Rows[0]["acad_year"].ToString();
            int semester    = Convert.ToInt32(dt.Rows[0]["semester"]);

            try
            {
                ApiHelper.Execute(
                    "DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno = @r AND acad_year = @ay AND semester = @sem",
                    new MySqlParameter("@r",   regno),
                    new MySqlParameter("@ay",  acadYear),
                    new MySqlParameter("@sem", semester));

                ApiHelper.Execute(
                    "UPDATE campus_dynamics_portal.acad_semester_deletion_requests SET deletion_executed = 1 WHERE id = @id",
                    new MySqlParameter("@id", id));
            }
            catch (Exception delEx)
            {
                ApiHelper.Success(Response, new Dictionary<string, object>
                {
                    { "id", id }, { "decision", decision },
                    { "deletion_warning", "Decision saved but deletion failed: " + delEx.Message }
                }, "Decision saved, deletion partially failed");
                return;
            }
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "id", id }, { "decision", decision }
        }, "Decision recorded");
    }

    private void HandleBatchDecideSemesterDeletion()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        EnsureSemesterDeletionSchema();

        string idsParam = ApiHelper.Param(Request, "ids", "");
        string decision = ApiHelper.Param(Request, "decision", "").ToUpper();
        string comment  = ApiHelper.Param(Request, "comment", "");

        if (string.IsNullOrEmpty(idsParam)) { ApiHelper.Error(Response, "ids is required (comma-separated).", "MISSING_PARAM"); return; }
        if (decision != "APPROVED" && decision != "REJECTED")
        {
            ApiHelper.Error(Response, "decision must be APPROVED or REJECTED.", "VALIDATION_ERROR"); return;
        }

        var ids = new List<int>();
        foreach (var part in idsParam.Split(','))
        {
            int i;
            if (int.TryParse(part.Trim(), out i) && i > 0) ids.Add(i);
        }
        if (ids.Count == 0) { ApiHelper.Error(Response, "No valid IDs provided.", "VALIDATION_ERROR"); return; }
        if (ids.Count > 50) { ApiHelper.Error(Response, "Maximum 50 IDs per batch.", "VALIDATION_ERROR"); return; }

        int succeeded = 0, failed = 0;
        foreach (int id in ids)
        {
            try
            {
                DataTable dt = ApiHelper.Query(
                    "SELECT id, status, deletion_executed, regno, acad_year, semester FROM campus_dynamics_portal.acad_semester_deletion_requests WHERE id = @id AND status = 'PENDING' LIMIT 1",
                    new MySqlParameter("@id", id));
                if (dt.Rows.Count == 0 || Convert.ToInt32(dt.Rows[0]["deletion_executed"]) == 1) { failed++; continue; }

                ApiHelper.Execute(
                    "UPDATE campus_dynamics_portal.acad_semester_deletion_requests SET status = @dec, admin_username = @admin, admin_comment = @cmt, decided_at = NOW() WHERE id = @id",
                    new MySqlParameter("@dec",   decision),
                    new MySqlParameter("@admin", auth.UserId),
                    new MySqlParameter("@cmt",   comment),
                    new MySqlParameter("@id",    id));

                if (decision == "APPROVED")
                {
                    string regno    = dt.Rows[0]["regno"].ToString();
                    string acadYear = dt.Rows[0]["acad_year"].ToString();
                    int semester    = Convert.ToInt32(dt.Rows[0]["semester"]);

                    ApiHelper.Execute(
                        "DELETE FROM campus_dynamics_portal.acad_course_registration WHERE regno = @r AND acad_year = @ay AND semester = @sem",
                        new MySqlParameter("@r", regno), new MySqlParameter("@ay", acadYear), new MySqlParameter("@sem", semester));
                    ApiHelper.Execute(
                        "UPDATE campus_dynamics_portal.acad_semester_deletion_requests SET deletion_executed = 1 WHERE id = @id",
                        new MySqlParameter("@id", id));
                }
                succeeded++;
            }
            catch { failed++; }
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", ids.Count }, { "succeeded", succeeded }, { "failed", failed }, { "decision", decision }
        }, "Batch decision completed");
    }
}
