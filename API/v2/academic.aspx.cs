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
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: results, transcript, gpa, available_courses, registered_courses, register_course, drop_course, semester_registration, registration_history", "INVALID_ACTION");
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
                    filter += "acad_year = '" + acad_year.Replace("'", "") + "'";
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
                @"SELECT s.surname, s.othername, p.programme, s.progid, s.entryyear, s.intake
                  FROM acad_student s
                  LEFT JOIN acad_programmes p ON s.progid = p.progcode
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
            DataTable distinctSems = dv.ToTable(true, "acad_year", "semester");

            double totalWeightedGP = 0;
            int totalCredits = 0;

            foreach (DataRow semRow in distinctSems.Rows)
            {
                string ay = semRow["acad_year"].ToString();
                string sem = semRow["semester"].ToString();

                DataView semView = new DataView(resultsDt);
                semView.RowFilter = "acad_year = '" + ay.Replace("'", "") + "' AND semester = " + sem;
                DataTable semResults = semView.ToTable();

                var courses = ApiHelper.TableToList(semResults);

                // Calculate semester GPA
                double semWeightedGP = 0;
                int semCredits = 0;
                foreach (var course in courses)
                {
                    int cu = 0;
                    double gp = 0;
                    if (course.ContainsKey("cu") && course["cu"] != null)
                        int.TryParse(course["cu"].ToString(), out cu);
                    if (course.ContainsKey("gp") && course["gp"] != null)
                        double.TryParse(course["gp"].ToString(), out gp);

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
            DataTable distinctSems = dv.ToTable(true, "acad_year", "semester");

            var semesterGPAs = new List<Dictionary<string, object>>();
            double totalWeightedGP = 0;
            int totalCredits = 0;

            foreach (DataRow semRow in distinctSems.Rows)
            {
                string ay = semRow["acad_year"].ToString();
                string sem = semRow["semester"].ToString();

                DataView semView = new DataView(resultsDt);
                semView.RowFilter = "acad_year = '" + ay.Replace("'", "") + "' AND semester = " + sem;
                DataTable semResults = semView.ToTable();

                double semWeightedGP = 0;
                int semCredits = 0;

                foreach (DataRow r in semResults.Rows)
                {
                    int cu = 0;
                    double gp = 0;
                    if (r["cu"] != DBNull.Value) int.TryParse(r["cu"].ToString(), out cu);
                    if (r["gp"] != DBNull.Value) double.TryParse(r["gp"].ToString(), out gp);
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

            // Auto-billing
            fin_GetStudentFeesTrackListTableAdapter BILLING = new fin_GetStudentFeesTrackListTableAdapter();
            BILLING.fin_Autobilling(regno, acad_year, semester, "REG", regno, "-");
            BILLING.fin_Autobilling(regno, acad_year, semester, "ACCOMO", regno, "-");

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "registration_result", regResult },
                { "acad_year", acad_year },
                { "semester", semester },
                { "billing_processed", true }
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
}
