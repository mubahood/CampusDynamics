using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class API_v2_student : System.Web.UI.Page
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
                case "profile":
                    HandleProfile();
                    break;
                case "photo":
                    HandlePhoto();
                    break;
                case "lock_status":
                    HandleLockStatus();
                    break;
                case "summary":
                    HandleSummary();
                    break;
                case "lookup":
                    HandleLookup();
                    break;
                case "verify":
                    HandleVerify();
                    break;
                case "search":
                    HandleSearch();
                    break;
                case "by_programme":
                    HandleByProgramme();
                    break;
                case "bulk_enrollment":
                    HandleBulkEnrollment();
                    break;
                case "onboarding_list":
                    HandleOnboardingList();
                    break;
                case "onboarding_stats":
                    HandleOnboardingStats();
                    break;
                case "resolve_onboarding_email":
                    HandleResolveOnboardingEmail();
                    break;
                case "application_detail":
                    HandleApplicationDetail();
                    break;
                case "update_contact":
                    HandleUpdateContact();
                    break;
                case "guardian":
                    HandleGuardian();
                    break;
                case "update_guardian":
                    HandleUpdateGuardian();
                    break;
                case "enrollment_history":
                    HandleEnrollmentHistory();
                    break;
                case "clearance":
                    HandleClearance();
                    break;
                case "id_card":
                    HandleIdCard();
                    break;
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: profile, photo, lock_status, summary, lookup, verify, search, by_programme, bulk_enrollment, onboarding_list, onboarding_stats, resolve_onboarding_email, application_detail, update_contact, guardian, update_guardian, enrollment_history, clearance, id_card", "INVALID_ACTION");
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

        // Allow staff to query a specific student by passing ?regno=
        string regno = auth.UserType == "staff" 
            ? ApiHelper.Param(Request, "regno", auth.UserId) 
            : auth.UserId;

        // If student, can only view own profile
        if (auth.UserType == "student" && regno != auth.UserId)
        {
            ApiHelper.Error(Response, "Students can only view their own profile.", "ACCESS_DENIED");
            return;
        }

        DataTable dt = ApiHelper.Query(
            @"SELECT s.regno, s.entryno, s.firstname, s.othername, s.gender, 
                     p.progname AS programme, s.progid AS progcode, c.campus_name AS campus,
                     COALESCE((SELECT MAX(r.studyyear) FROM acad_registration r WHERE r.regno = s.regno), 1) AS study_year,
                     s.entryyear AS entry_year, 
                     s.intake, s.studsesion AS session, s.stud_status AS status,
                     s.nationality, s.studPhone AS phone, s.email,
                     s.dob AS date_of_birth, s.home_dist AS district
              FROM acad_student s
              LEFT JOIN acad_programme p ON s.progid = p.progcode
              LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
              WHERE s.regno = @reg",
            new MySqlParameter("@reg", regno)
        );

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
            return;
        }

        var profile = ApiHelper.FirstRowToDict(dt);
        profile["photo_url"] = "/API/student_photo.aspx?id=" + Server.UrlEncode(regno);

        // Optional extended includes: ?include=next_of_kin,sponsor,onboarding
        string include = ApiHelper.Param(Request, "include", "").ToLower();
        if (!string.IsNullOrEmpty(include))
        {
            if (include.Contains("next_of_kin") || include.Contains("sponsor"))
            {
                DataTable extDt = ApiHelper.Query(
                    "SELECT next_kin AS next_of_kin_name, kin_contacts AS next_of_kin_contact, stud_sponsor AS sponsor_name, sponsor_contact FROM acad_student WHERE regno = @reg",
                    new MySqlParameter("@reg", regno));
                if (extDt.Rows.Count > 0)
                {
                    var ext = ApiHelper.FirstRowToDict(extDt);
                    if (include.Contains("next_of_kin"))
                    {
                        profile["next_of_kin_name"]    = ext["next_of_kin_name"];
                        profile["next_of_kin_contact"] = ext["next_of_kin_contact"];
                    }
                    if (include.Contains("sponsor"))
                    {
                        profile["sponsor_name"]    = ext["sponsor_name"];
                        profile["sponsor_contact"] = ext["sponsor_contact"];
                    }
                }
            }
            if (include.Contains("onboarding"))
            {
                object vs = ApiHelper.Scalar(
                    "SELECT CONCAT_WS('|', u.user_verification_status, IFNULL(u.verified_email,''), IFNULL(u.user_type,'STUDENT'), IFNULL(DATE_FORMAT(u.lastactivitydate,'%Y-%m-%d %H:%i:%s'),'')) FROM campus_dynamics_portal.my_aspnet_users u WHERE u.name = @r LIMIT 1",
                    new MySqlParameter("@r", regno));
                if (vs != null && vs != DBNull.Value)
                {
                    string[] parts2 = vs.ToString().Split('|');
                    profile["onboarding_status"]       = parts2.Length > 0 ? parts2[0] : null;
                    profile["portal_email"]            = parts2.Length > 1 ? parts2[1] : null;
                    profile["portal_user_type"]        = parts2.Length > 2 ? parts2[2] : null;
                    profile["portal_last_activity"]    = parts2.Length > 3 ? parts2[3] : null;
                }
                else
                {
                    profile["onboarding_status"]    = null;
                    profile["portal_email"]         = null;
                    profile["portal_user_type"]     = null;
                    profile["portal_last_activity"] = null;
                }
            }
        }

        ApiHelper.Success(Response, profile);
    }

    private void HandlePhoto()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (auth.UserType == "student" && regno != auth.UserId)
        {
            ApiHelper.Error(Response, "Students can only view their own photo.", "ACCESS_DENIED");
            return;
        }

        // Try to get photo from the database
        DataTable dt = ApiHelper.Query(
            "SELECT photofile FROM acad_student WHERE regno = @reg",
            new MySqlParameter("@reg", regno)
        );

        if (dt.Rows.Count > 0 && dt.Rows[0]["photofile"] != DBNull.Value)
        {
            byte[] photoData = (byte[])dt.Rows[0]["photofile"];
            if (photoData.Length > 0)
            {
                Response.Clear();
                Response.ContentType = "image/jpeg";
                Response.AddHeader("Access-Control-Allow-Origin", "*");
                Response.BinaryWrite(photoData);
                ApiHelper.CompleteResponse(Response);
                return;
            }
        }

        // Try file-based photo as fallback
        string photoPath = Server.MapPath("~/patientimages/" + regno.Replace("/", "_") + ".jpg");
        if (File.Exists(photoPath))
        {
            Response.Clear();
            Response.ContentType = "image/jpeg";
            Response.AddHeader("Access-Control-Allow-Origin", "*");
            Response.WriteFile(photoPath);
            ApiHelper.CompleteResponse(Response);
            return;
        }

        ApiHelper.Error(Response, "Photo not found.", "NOT_FOUND");
    }

    private void HandleLockStatus()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (auth.UserType == "student" && regno != auth.UserId)
        {
            ApiHelper.Error(Response, "Students can only check their own lock status.", "ACCESS_DENIED");
            return;
        }

        try
        {
            PortalSecurityTableAdapters.fin_studentlocksTableAdapter LOCK = new PortalSecurityTableAdapters.fin_studentlocksTableAdapter();
            DataTable dt = LOCK.GetLockStatusData(regno);
            var data = ApiHelper.TableToList(dt);
            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error checking lock status: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleSummary()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (auth.UserType == "student" && regno != auth.UserId)
        {
            ApiHelper.Error(Response, "Students can only view their own summary.", "ACCESS_DENIED");
            return;
        }

        try
        {
            MobileDataTableAdapters.mobile_stud_summaryTableAdapter SUMMARY = new MobileDataTableAdapters.mobile_stud_summaryTableAdapter();
            DataTable dt = SUMMARY.GetData(regno);
            var data = ApiHelper.FirstRowToDict(dt);
            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching summary: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// ODEL: Lookup a person (student or staff) by email address.
    /// Used by Moodle during registration to identify existing users.
    /// Returns person_type (student/staff) and relevant profile data.
    /// </summary>
    private void HandleLookup()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string email = ApiHelper.RequireParam(Request, Response, "email");
        if (email == null) return;

        // First, search in students
        DataTable dtStudent = ApiHelper.Query(
            @"SELECT s.regno, s.entryno, s.firstname, s.othername, s.gender,
                     p.progname AS programme, s.progid AS progcode, c.campus_name AS campus,
                     s.entryyear AS entry_year, s.intake, s.studsesion AS session,
                     s.stud_status AS status, s.nationality, s.studPhone AS phone,
                     s.email, s.dob AS date_of_birth, s.home_dist AS district
              FROM acad_student s
              LEFT JOIN acad_programme p ON s.progid = p.progcode
              LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
              WHERE LOWER(s.email) = LOWER(@email) OR LOWER(s.studemail) = LOWER(@email)
              LIMIT 1",
            new MySqlParameter("@email", email)
        );

        if (dtStudent.Rows.Count > 0)
        {
            var person = ApiHelper.FirstRowToDict(dtStudent);
            var data = new Dictionary<string, object>
            {
                { "found", true },
                { "person_type", "student" },
                { "mru_id", person["regno"] },
                { "data", person }
            };
            ApiHelper.Success(Response, data, "Person found as student");
            return;
        }

        // Then, search in staff
        DataTable dtStaff = ApiHelper.Query(
            @"SELECT e.empID, e.EMP_CODE AS emp_code, e.emp_name, e.usernames AS username,
                     e.emp_email AS email, e.emp_phone AS phone, e.EmpType AS emp_type,
                     e.emp_status AS status, e.emp_nationality AS nationality,
                     e.emp_qualifications AS qualifications,
                     d.dept_name AS department, f.faculty_name AS faculty
              FROM hrm_employee e
              LEFT JOIN hrm_emp_contracts c ON e.empID = c.empID AND c.contractStatus = 'Active'
              LEFT JOIN hrm_departments d ON c.departmentID = d.ID
              LEFT JOIN acad_faculty f ON d.fax_code = f.fax_code
              WHERE LOWER(e.emp_email) = LOWER(@email)
              LIMIT 1",
            new MySqlParameter("@email", email)
        );

        if (dtStaff.Rows.Count > 0)
        {
            var person = ApiHelper.FirstRowToDict(dtStaff);
            var data = new Dictionary<string, object>
            {
                { "found", true },
                { "person_type", "staff" },
                { "mru_id", person["emp_code"] },
                { "data", person }
            };
            ApiHelper.Success(Response, data, "Person found as staff");
            return;
        }

        // Not found
        var notFound = new Dictionary<string, object>
        {
            { "found", false },
            { "person_type", null },
            { "mru_id", null },
            { "data", null }
        };
        ApiHelper.Success(Response, notFound, "No person found with this email");
    }

    /// <summary>
    /// ODEL: Quick student verification by registration number.
    /// Returns basic info to confirm identity. Used by Moodle to verify students.
    /// </summary>
    private void HandleVerify()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string id = ApiHelper.RequireParam(Request, Response, "id");
        if (id == null) return;

        DataTable dt = ApiHelper.Query(
            @"SELECT s.regno, CONCAT(s.firstname, ' ', s.othername) AS full_name,
                     s.stud_status AS status, s.progid AS programme_code,
                     p.progname AS programme_name, s.email
              FROM acad_student s
              LEFT JOIN acad_programme p ON s.progid = p.progcode
              WHERE s.regno = @id OR s.entryno = @id
              LIMIT 1",
            new MySqlParameter("@id", id)
        );

        if (dt.Rows.Count > 0)
        {
            var row = ApiHelper.FirstRowToDict(dt);
            var data = new Dictionary<string, object>
            {
                { "verified", true },
                { "mru_id", row["regno"] },
                { "full_name", row["full_name"] },
                { "status", row["status"] },
                { "programme_code", row["programme_code"] },
                { "programme_name", row["programme_name"] },
                { "email", row["email"] }
            };
            ApiHelper.Success(Response, data, "Student verified");
        }
        else
        {
            var data = new Dictionary<string, object>
            {
                { "verified", false },
                { "mru_id", null },
                { "full_name", null },
                { "status", null },
                { "programme_code", null },
                { "programme_name", null },
                { "email", null }
            };
            ApiHelper.Success(Response, data, "Student not found");
        }
    }

    /// <summary>
    /// ODEL: Search students by name, email, or student number.
    /// Staff only. Used by ODEL admin to find students.
    /// </summary>
    private void HandleSearch()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "Only staff can search students.", "ACCESS_DENIED");
            return;
        }

        string q = ApiHelper.RequireParam(Request, Response, "q");
        if (q == null) return;

        string searchType = ApiHelper.Param(Request, "type", "any").ToLower();
        int limit = ApiHelper.ParamInt(Request, "limit", 50);
        if (limit > 200) limit = 200;

        string whereClause;
        switch (searchType)
        {
            case "name":
                whereClause = "(LOWER(s.firstname) LIKE @q OR LOWER(s.othername) LIKE @q OR LOWER(CONCAT(s.firstname, ' ', s.othername)) LIKE @q)";
                break;
            case "email":
                whereClause = "(LOWER(s.email) LIKE @q OR LOWER(s.studemail) LIKE @q)";
                break;
            case "student_no":
                whereClause = "(s.regno LIKE @q OR s.entryno LIKE @q)";
                break;
            default: // "any"
                whereClause = "(s.regno LIKE @q OR s.entryno LIKE @q OR LOWER(s.firstname) LIKE @q OR LOWER(s.othername) LIKE @q OR LOWER(s.email) LIKE @q OR LOWER(s.studemail) LIKE @q)";
                break;
        }

        string sql = String.Format(
            @"SELECT s.regno, s.entryno, s.firstname, s.othername, s.gender,
                     s.progid AS progcode, p.progname AS programme,
                     s.stud_status AS status, s.email, s.studPhone AS phone
              FROM acad_student s
              LEFT JOIN acad_programme p ON s.progid = p.progcode
              WHERE {0}
              ORDER BY s.firstname, s.othername
              LIMIT @lim", whereClause);

        string searchPattern = "%" + q.ToLower() + "%";
        DataTable dt = ApiHelper.Query(sql,
            new MySqlParameter("@q", searchPattern),
            new MySqlParameter("@lim", limit)
        );

        var results = ApiHelper.TableToList(dt);
        var data = new Dictionary<string, object>
        {
            { "count", results.Count },
            { "search_type", searchType },
            { "query", q },
            { "results", results }
        };
        ApiHelper.Success(Response, data);
    }

    /// <summary>
    /// ODEL: Get all students in a programme with optional filters.
    /// Staff only. Supports pagination. Used for bulk sync.
    /// </summary>
    private void HandleByProgramme()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "Only staff can list students by programme.", "ACCESS_DENIED");
            return;
        }

        string progcode = ApiHelper.RequireParam(Request, Response, "progcode");
        if (progcode == null) return;

        string status = ApiHelper.Param(Request, "status", "");
        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        int page = ApiHelper.ParamInt(Request, "page", 1);
        int perPage = ApiHelper.ParamInt(Request, "per_page", 100);
        if (perPage > 500) perPage = 500;
        int offset = (page - 1) * perPage;

        // Build WHERE clause
        StringBuilder where = new StringBuilder("s.progid = @prog");
        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@prog", progcode));

        if (!String.IsNullOrEmpty(status))
        {
            where.Append(" AND s.stud_status = @status");
            parms.Add(new MySqlParameter("@status", status));
        }

        if (!String.IsNullOrEmpty(acadYear))
        {
            where.Append(" AND s.regno IN (SELECT r.regno FROM acad_registration r WHERE r.academic_year = @ay)");
            parms.Add(new MySqlParameter("@ay", acadYear));
        }

        // Get total count
        string countSql = String.Format("SELECT COUNT(*) FROM acad_student s WHERE {0}", where.ToString());
        object totalObj = ApiHelper.Scalar(countSql, parms.ToArray());
        int total = Convert.ToInt32(totalObj);

        // Get paginated results
        parms.Add(new MySqlParameter("@lim", perPage));
        parms.Add(new MySqlParameter("@off", offset));

        string sql = String.Format(
            @"SELECT s.regno, s.entryno, s.firstname, s.othername, s.gender,
                     s.progid AS progcode, p.progname AS programme,
                     s.stud_status AS status, s.email, s.studPhone AS phone,
                     s.entryyear AS entry_year, s.intake, s.nationality
              FROM acad_student s
              LEFT JOIN acad_programme p ON s.progid = p.progcode
              WHERE {0}
              ORDER BY s.firstname, s.othername
              LIMIT @lim OFFSET @off", where.ToString());

        DataTable dt = ApiHelper.Query(sql, parms.ToArray());
        var students = ApiHelper.TableToList(dt);

        var data = new Dictionary<string, object>
        {
            { "programme_code", progcode },
            { "total", total },
            { "page", page },
            { "per_page", perPage },
            { "total_pages", (int)Math.Ceiling((double)total / perPage) },
            { "students", students }
        };
        ApiHelper.Success(Response, data);
    }

    /// <summary>
    /// NEW-07: Batch enrollment status check for Moodle sync.
    /// Staff only. POST a JSON array of student reg numbers (or pass comma-separated
    /// ?regnos=MRU001,MRU002) and receive each student's current enrollment status,
    /// programme, email, and most-recent registration semester — all in one call.
    /// Capped at 500 students per request.
    /// </summary>
    private void HandleBulkEnrollment()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        if (auth.UserType != "staff")
        {
            ApiHelper.Error(Response, "Only staff can use bulk_enrollment.", "ACCESS_DENIED");
            return;
        }

        // Accept regnos as comma-separated query param or from the request body
        string rawList = ApiHelper.Param(Request, "regnos", "");
        if (string.IsNullOrEmpty(rawList))
        {
            try
            {
                using (var sr = new StreamReader(Request.InputStream))
                    rawList = sr.ReadToEnd().Trim();
            }
            catch { }
        }

        if (string.IsNullOrEmpty(rawList))
        {
            ApiHelper.Error(Response, "Pass ?regnos= as a comma-separated list of registration numbers.", "MISSING_PARAM");
            return;
        }

        // Parse and sanitise the list
        string[] parts = rawList.Split(new char[] { ',', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
        var regnos = new List<string>();
        foreach (string p in parts)
        {
            string s = ApiHelper.SanitiseParam(p);
            if (!string.IsNullOrEmpty(s) && regnos.Count < 500)
                regnos.Add(s);
        }

        if (regnos.Count == 0)
        {
            ApiHelper.Error(Response, "No valid registration numbers provided.", "MISSING_PARAM");
            return;
        }

        // Build IN(...) clause with numbered parameters
        var inParms = new List<MySqlParameter>();
        var inPlaceholders = new List<string>();
        for (int i = 0; i < regnos.Count; i++)
        {
            string pname = "@r" + i;
            inPlaceholders.Add(pname);
            inParms.Add(new MySqlParameter(pname, regnos[i]));
        }

        string inClause = string.Join(",", inPlaceholders.ToArray());

        // Profile + most-recent registration per student
        string sql = String.Format(
            @"SELECT s.regno, s.entryno,
                     CONCAT(IFNULL(s.firstname,''), ' ', IFNULL(s.othername,'')) AS full_name,
                     s.email, s.studPhone AS phone,
                     s.progid AS programme_code, p.progname AS programme_name,
                     s.stud_status AS account_status,
                     r.acad_year AS last_acad_year, r.semester AS last_semester,
                     r.status AS last_reg_status,
                     r.studyyear AS last_study_year
              FROM acad_student s
              LEFT JOIN acad_programme p ON s.progid = p.progcode
              LEFT JOIN acad_registration r ON r.regno = s.regno
                    AND r.id = (SELECT id FROM acad_registration
                                WHERE regno = s.regno ORDER BY acad_year DESC, semester DESC LIMIT 1)
              WHERE s.regno IN ({0})
              ORDER BY s.firstname, s.othername", inClause);

        DataTable dt = ApiHelper.Query(sql, inParms.ToArray());
        var found = ApiHelper.TableToList(dt);

        // Annotate with is_enrolled using the shared helper (can't call static method from academic.aspx.cs)
        var foundRegnos = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var row in found)
        {
            string regStatus = row.ContainsKey("last_reg_status") && row["last_reg_status"] != null
                ? row["last_reg_status"].ToString() : "";
            bool active = IsActiveEnrollmentStatus(regStatus);
            row["is_enrolled"] = active;
            row["enrollment_status_label"] = MapEnrollmentStatus(regStatus);

            if (row.ContainsKey("regno") && row["regno"] != null)
                foundRegnos.Add(row["regno"].ToString());
        }

        // Report any regnos not found in the DB
        var notFound = new List<string>();
        foreach (string r in regnos)
            if (!foundRegnos.Contains(r)) notFound.Add(r);

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "requested",  regnos.Count },
            { "found",      found.Count },
            { "not_found_count", notFound.Count },
            { "not_found",  notFound },
            { "students",   found }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ONBOARDING_LIST  — portal onboarding status for students/staff
    // ═══════════════════════════════════════════════════════════════════

    private void HandleOnboardingList()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string statusFilter   = ApiHelper.Param(Request, "status", "");
        string prog           = ApiHelper.Param(Request, "prog", "");
        string userType       = ApiHelper.Param(Request, "user_type", "");
        string q              = ApiHelper.Param(Request, "q", "");
        int page              = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size              = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 50)));
        int offset            = (page - 1) * size;

        string baseSql =
            "FROM campus_dynamics_portal.my_aspnet_users u " +
            "LEFT JOIN acad_student s ON s.regno = u.name " +
            "LEFT JOIN hrm_employee e ON (e.usernames = u.name OR e.EMP_CODE = u.name) " +
            "LEFT JOIN acad_programme p ON p.progcode = s.progid ";

        var where = new StringBuilder("WHERE (u.user_verification_status IS NOT NULL AND u.user_verification_status <> '') ");
        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(statusFilter))
        {
            where.Append("AND u.user_verification_status = @vs ");
            parms.Add(new MySqlParameter("@vs", statusFilter));
        }
        if (!string.IsNullOrEmpty(userType))
        {
            where.Append("AND UPPER(IFNULL(u.user_type,'STUDENT')) = @ut ");
            parms.Add(new MySqlParameter("@ut", userType.ToUpper()));
        }
        if (!string.IsNullOrEmpty(prog))
        {
            where.Append("AND s.progid = @prog ");
            parms.Add(new MySqlParameter("@prog", prog));
        }
        if (!string.IsNullOrEmpty(q))
        {
            where.Append("AND (u.name LIKE @q OR CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,'')) LIKE @q OR u.verified_email LIKE @q) ");
            parms.Add(new MySqlParameter("@q", "%" + q + "%"));
        }

        var countParms = new List<MySqlParameter>(parms);
        int total = Convert.ToInt32(ApiHelper.Scalar("SELECT COUNT(DISTINCT u.name) " + baseSql + where, countParms.ToArray()));

        parms.Add(new MySqlParameter("@lim", size));
        parms.Add(new MySqlParameter("@off", offset));

        DataTable dt = ApiHelper.Query(
            "SELECT u.name AS regno, " +
            "TRIM(CONCAT(IFNULL(s.firstname,''),' ',IFNULL(s.othername,''))) AS student_name, " +
            "UPPER(IFNULL(u.user_type,'STUDENT')) AS user_type, " +
            "IFNULL(p.progname,'') AS programme, " +
            "u.user_verification_status AS onboarding_status, " +
            "IFNULL(u.verified_email,'') AS portal_email, " +
            "IFNULL(DATE_FORMAT(u.lastactivitydate,'%Y-%m-%d %H:%i:%s'),'') AS last_activity " +
            baseSql + where +
            "GROUP BY u.name ORDER BY u.lastactivitydate DESC LIMIT @lim OFFSET @off",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "students", ApiHelper.TableToList(dt) }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ONBOARDING_STATS  — counts by onboarding status
    // ═══════════════════════════════════════════════════════════════════

    private void HandleOnboardingStats()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        DataTable dt = ApiHelper.Query(
            @"SELECT IFNULL(user_verification_status,'(none)') AS status, COUNT(*) AS count
              FROM campus_dynamics_portal.my_aspnet_users
              WHERE user_verification_status IS NOT NULL AND user_verification_status <> ''
              GROUP BY user_verification_status ORDER BY count DESC");

        int total = 0;
        var breakdown = ApiHelper.TableToList(dt);
        foreach (var row in breakdown)
            total += Convert.ToInt32(row["count"]);

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total_onboarded", total },
            { "breakdown", breakdown }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  RESOLVE_ONBOARDING_EMAIL  — look up best email for a student/staff
    // ═══════════════════════════════════════════════════════════════════

    private void HandleResolveOnboardingEmail()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string regno = ApiHelper.RequireParam(Request, Response, "regno"); if (regno == null) return;

        // 1) portal verified_email
        object portalEmail = ApiHelper.Scalar(
            "SELECT verified_email FROM campus_dynamics_portal.my_aspnet_users WHERE LOWER(TRIM(name)) = LOWER(@r) LIMIT 1",
            new MySqlParameter("@r", regno));
        if (portalEmail != null && portalEmail != DBNull.Value && !string.IsNullOrEmpty(portalEmail.ToString().Trim()))
        {
            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "regno", regno }, { "email", portalEmail.ToString().Trim() },
                { "source", "portal.my_aspnet_users.verified_email" }
            }, "Email resolved");
            return;
        }

        // 2) staff emp_email
        object staffEmail = ApiHelper.Scalar(
            "SELECT emp_email FROM hrm_employee WHERE usernames = @r OR EMP_CODE = @r LIMIT 1",
            new MySqlParameter("@r", regno));
        if (staffEmail != null && staffEmail != DBNull.Value && !string.IsNullOrEmpty(staffEmail.ToString().Trim()))
        {
            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "regno", regno }, { "email", staffEmail.ToString().Trim() },
                { "source", "hrm_employee.emp_email" }
            }, "Email resolved");
            return;
        }

        // 3) student email
        object studEmail = ApiHelper.Scalar(
            "SELECT IFNULL(NULLIF(TRIM(email),''), NULLIF(TRIM(studemail),'')) FROM acad_student WHERE regno = @r LIMIT 1",
            new MySqlParameter("@r", regno));
        if (studEmail != null && studEmail != DBNull.Value && !string.IsNullOrEmpty(studEmail.ToString().Trim()))
        {
            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "regno", regno }, { "email", studEmail.ToString().Trim() },
                { "source", "acad_student.email" }
            }, "Email resolved");
            return;
        }

        ApiHelper.Error(Response, "No email found for " + regno + ". Please enter one manually.", "NOT_FOUND");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  APPLICATION_DETAIL  — student views their own admission record
    // ═══════════════════════════════════════════════════════════════════

    private void HandleApplicationDetail()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (auth.UserType == "student" && regno != auth.UserId)
        {
            ApiHelper.Error(Response, "Students can only view their own application.", "ACCESS_DENIED");
            return;
        }

        // Look up via acad_applicant_choices.stud_reg_no = regno
        DataTable dt = ApiHelper.Query(
            @"SELECT a.app_no AS application_number, a.fname AS first_name, a.lname AS last_name,
                     a.gender, a.dob AS date_of_birth, a.phone_no AS phone,
                     a.email, a.nationality,
                     a.adm_status, a.district,
                     a.prog_code AS programme_code,
                     p.progname AS programme_name,
                     a.stud_reg_no AS regno,
                     a.remarks AS admission_remarks,
                     a.app_date AS application_date
              FROM acad_applicants a
              LEFT JOIN acad_applicant_choices ac ON ac.app_no = a.app_no
              LEFT JOIN acad_programme p ON p.progcode = COALESCE(ac.prog_code, a.prog_code)
              WHERE ac.stud_reg_no = @reg OR a.stud_reg_no = @reg
              LIMIT 1",
            new MySqlParameter("@reg", regno));

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "No application record linked to this registration number.", "NOT_FOUND");
            return;
        }

        var row = ApiHelper.FirstRowToDict(dt);

        // Map adm_status to label
        int admStatus = 0;
        int.TryParse(row.ContainsKey("adm_status") && row["adm_status"] != null ? row["adm_status"].ToString() : "0", out admStatus);
        string[] labels = { "PENDING", "ADMITTED", "REJECTED", "WITHDRAWN" };
        row["admission_status"] = admStatus >= 0 && admStatus < labels.Length ? labels[admStatus] : "UNKNOWN";

        ApiHelper.Success(Response, row);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  UPDATE CONTACT  — student updates own phone / email / address
    // ═══════════════════════════════════════════════════════════════════

    private void HandleUpdateContact()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        // Staff can update any student; students update themselves only
        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (string.IsNullOrEmpty(regno)) { ApiHelper.Error(Response, "regno is required.", "MISSING_PARAM"); return; }

        var sets  = new List<string>();
        var parms = new List<MySqlParameter> { new MySqlParameter("@reg", regno) };

        string phone   = ApiHelper.Param(Request, "phone", "");
        string email   = ApiHelper.Param(Request, "email", "");
        string address = ApiHelper.Param(Request, "address", "");

        if (!string.IsNullOrEmpty(phone))   { sets.Add("phone_no = @phone");   parms.Add(new MySqlParameter("@phone",   phone));   }
        if (!string.IsNullOrEmpty(email))   { sets.Add("email = @email");       parms.Add(new MySqlParameter("@email",   email));   }
        if (!string.IsNullOrEmpty(address)) { sets.Add("address = @address");   parms.Add(new MySqlParameter("@address", address)); }

        if (sets.Count == 0) { ApiHelper.Error(Response, "No fields to update. Supply phone, email, or address.", "VALIDATION_ERROR"); return; }

        try
        {
            int affected = ApiHelper.Execute(
                "UPDATE acad_student SET " + string.Join(", ", sets.ToArray()) + " WHERE regno = @reg",
                parms.ToArray()
            );

            if (affected == 0) { ApiHelper.Error(Response, "Student not found or no changes applied.", "NOT_FOUND"); return; }

            ApiHelper.Success(Response, new Dictionary<string, object> { { "regno", regno }, { "updated_fields", sets.Count } }, "Contact updated");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error updating contact: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  GUARDIAN  — student next-of-kin / parent info
    // ═══════════════════════════════════════════════════════════════════

    private void HandleGuardian()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (string.IsNullOrEmpty(regno)) { ApiHelper.Error(Response, "regno is required.", "MISSING_PARAM"); return; }

        try
        {
            DataTable dt = ApiHelper.Query(
                @"SELECT guardian_name, guardian_relationship, guardian_phone,
                         guardian_email, guardian_address, guardian_occupation
                  FROM acad_student WHERE regno = @reg LIMIT 1",
                new MySqlParameter("@reg", regno)
            );

            if (dt.Rows.Count == 0) { ApiHelper.Error(Response, "Student not found.", "NOT_FOUND"); return; }

            ApiHelper.Success(Response, ApiHelper.FirstRowToDict(dt));
        }
        catch (Exception ex)
        {
            // Column may not exist in older schemas — return empty gracefully
            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "guardian_name", "" }, { "guardian_relationship", "" },
                { "guardian_phone", "" }, { "guardian_email", "" },
                { "guardian_address", "" }, { "guardian_occupation", "" },
                { "note", "Guardian fields not configured: " + ex.Message }
            });
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  UPDATE GUARDIAN
    // ═══════════════════════════════════════════════════════════════════

    private void HandleUpdateGuardian()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (string.IsNullOrEmpty(regno)) { ApiHelper.Error(Response, "regno is required.", "MISSING_PARAM"); return; }

        var sets  = new List<string>();
        var parms = new List<MySqlParameter> { new MySqlParameter("@reg", regno) };

        string name   = ApiHelper.Param(Request, "guardian_name", "");
        string rel    = ApiHelper.Param(Request, "guardian_relationship", "");
        string phone  = ApiHelper.Param(Request, "guardian_phone", "");
        string email  = ApiHelper.Param(Request, "guardian_email", "");
        string addr   = ApiHelper.Param(Request, "guardian_address", "");
        string occ    = ApiHelper.Param(Request, "guardian_occupation", "");

        if (!string.IsNullOrEmpty(name))  { sets.Add("guardian_name = @gn");           parms.Add(new MySqlParameter("@gn",  name));  }
        if (!string.IsNullOrEmpty(rel))   { sets.Add("guardian_relationship = @gr");    parms.Add(new MySqlParameter("@gr",  rel));   }
        if (!string.IsNullOrEmpty(phone)) { sets.Add("guardian_phone = @gp");           parms.Add(new MySqlParameter("@gp",  phone)); }
        if (!string.IsNullOrEmpty(email)) { sets.Add("guardian_email = @ge");           parms.Add(new MySqlParameter("@ge",  email)); }
        if (!string.IsNullOrEmpty(addr))  { sets.Add("guardian_address = @ga");         parms.Add(new MySqlParameter("@ga",  addr));  }
        if (!string.IsNullOrEmpty(occ))   { sets.Add("guardian_occupation = @go");      parms.Add(new MySqlParameter("@go",  occ));   }

        if (sets.Count == 0) { ApiHelper.Error(Response, "No guardian fields to update.", "VALIDATION_ERROR"); return; }

        try
        {
            int affected = ApiHelper.Execute(
                "UPDATE acad_student SET " + string.Join(", ", sets.ToArray()) + " WHERE regno = @reg",
                parms.ToArray()
            );

            if (affected == 0) { ApiHelper.Error(Response, "Student not found.", "NOT_FOUND"); return; }

            ApiHelper.Success(Response, new Dictionary<string, object> { { "regno", regno } }, "Guardian info updated");
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error updating guardian: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ENROLLMENT HISTORY  — all registration records across all years
    // ═══════════════════════════════════════════════════════════════════

    private void HandleEnrollmentHistory()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (string.IsNullOrEmpty(regno)) { ApiHelper.Error(Response, "regno is required.", "MISSING_PARAM"); return; }

        try
        {
            DataTable dt = ApiHelper.Query(
                @"SELECT r.ID AS registration_id,
                         r.acad_year, r.semester, r.studyyear,
                         r.regstatus AS status, r.residence_status,
                         r.late_reg, r.reg_date,
                         DATE_FORMAT(r.reg_date, '%Y-%m-%d') AS reg_date_fmt,
                         COALESCE(p.progname, s.progid) AS programme
                  FROM acad_registration r
                  JOIN acad_student s ON s.regno = r.regno
                  LEFT JOIN acad_programme p ON p.progID = s.progid
                  WHERE r.regno = @reg
                  ORDER BY r.acad_year DESC, r.semester ASC",
                new MySqlParameter("@reg", regno)
            );

            var history = new List<Dictionary<string, object>>();
            foreach (DataRow row in dt.Rows)
            {
                history.Add(new Dictionary<string, object>
                {
                    { "registration_id",   Convert.ToInt32(row["registration_id"]) },
                    { "acad_year",         row["acad_year"].ToString()             },
                    { "semester",          row["semester"].ToString()              },
                    { "study_year",        row["studyyear"] != DBNull.Value ? Convert.ToInt32(row["studyyear"]) : 0 },
                    { "status",            MapEnrollmentStatus(row["status"].ToString())                            },
                    { "status_raw",        row["status"].ToString()                },
                    { "is_active",         IsActiveEnrollmentStatus(row["status"].ToString())                       },
                    { "residence_status",  row["residence_status"] != DBNull.Value ? row["residence_status"].ToString() : "" },
                    { "is_late",           row["late_reg"] != DBNull.Value && row["late_reg"].ToString() == "1"    },
                    { "reg_date",          row["reg_date_fmt"].ToString()          },
                    { "programme",         row["programme"].ToString()             }
                });
            }

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "regno",   regno          },
                { "total",   history.Count  },
                { "history", history        }
            });
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching enrollment history: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  CLEARANCE  — aggregated clearance check across all facets
    // ═══════════════════════════════════════════════════════════════════

    private void HandleClearance()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string regno = auth.UserType == "staff"
            ? ApiHelper.Param(Request, "regno", auth.UserId)
            : auth.UserId;

        if (string.IsNullOrEmpty(regno)) { ApiHelper.Error(Response, "regno is required.", "MISSING_PARAM"); return; }

        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        string semester = ApiHelper.Param(Request, "semester", "");

        var checks = new List<Dictionary<string, object>>();
        bool allClear = true;

        // 1. Financial clearance
        try
        {
            FinancialSummary fin = FinanceEngine.ComputePeriodBalance(regno, acadYear, semester);
            bool finClear = fin.Balance <= 0;
            if (!finClear) allClear = false;
            checks.Add(new Dictionary<string, object>
            {
                { "check",     "Financial"                     },
                { "cleared",   finClear                        },
                { "detail",    finClear
                    ? "No outstanding balance."
                    : string.Format("Outstanding balance: UGX {0:N0}", fin.AmountOwing) },
                { "balance",   fin.Balance                     },
                { "currency",  FinanceEngine.CURRENCY          }
            });
        }
        catch
        {
            checks.Add(new Dictionary<string, object>
                { { "check", "Financial" }, { "cleared", false }, { "detail", "Unable to verify financial status." } });
            allClear = false;
        }

        // 2. Registration clearance
        try
        {
            var regParms = new List<MySqlParameter> { new MySqlParameter("@reg", regno) };
            string regWhere = "WHERE r.regno = @reg";
            if (!string.IsNullOrEmpty(acadYear)) { regWhere += " AND r.acad_year = @ay"; regParms.Add(new MySqlParameter("@ay", acadYear)); }
            if (!string.IsNullOrEmpty(semester)) { regWhere += " AND r.semester = @sem";  regParms.Add(new MySqlParameter("@sem", semester)); }

            DataTable regDt = ApiHelper.Query(
                "SELECT r.regstatus FROM acad_registration r " + regWhere + " ORDER BY r.ID DESC LIMIT 1",
                regParms.ToArray()
            );

            bool regClear = regDt.Rows.Count > 0 && IsActiveEnrollmentStatus(regDt.Rows[0]["regstatus"].ToString());
            if (!regClear) allClear = false;
            string regStatus = regDt.Rows.Count > 0 ? regDt.Rows[0]["regstatus"].ToString() : "No registration found";
            checks.Add(new Dictionary<string, object>
            {
                { "check",   "Registration" },
                { "cleared", regClear       },
                { "detail",  regClear ? "Registered for the period." : "Registration status: " + regStatus },
                { "status",  regStatus      }
            });
        }
        catch
        {
            checks.Add(new Dictionary<string, object>
                { { "check", "Registration" }, { "cleared", false }, { "detail", "Unable to verify registration." } });
            allClear = false;
        }

        // 3. Financial lock
        try
        {
            bool locked = FinanceEngine.HasFinancialLock(regno);
            if (locked) allClear = false;
            checks.Add(new Dictionary<string, object>
            {
                { "check",   "Financial Lock" },
                { "cleared", !locked          },
                { "detail",  locked ? "A financial hold is active on this account." : "No financial hold." }
            });
        }
        catch { /* FinancialLock check is non-critical */ }

        int passCount = 0;
        foreach (var c in checks) if ((bool)c["cleared"]) passCount++;

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "regno",       regno              },
            { "overall",     allClear ? "CLEARED" : "NOT_CLEARED" },
            { "is_cleared",  allClear           },
            { "pass_count",  passCount          },
            { "total_checks",checks.Count       },
            { "acad_year",   acadYear           },
            { "semester",    semester           },
            { "checks",      checks             }
        });
    }

    private static bool IsActiveEnrollmentStatus(string raw)
    {
        switch ((raw ?? "").ToUpper().Trim())
        {
            case "REGISTERED": case "LATE REGISTERED": case "CLEARED": case "ACTIVE":
                return true;
            default:
                return false;
        }
    }

    private static string MapEnrollmentStatus(string raw)
    {
        switch ((raw ?? "").ToUpper().Trim())
        {
            case "REGISTERED":      return "Registered";
            case "LATE REGISTERED": return "Late Registered";
            case "CLEARED":         return "Cleared";
            case "UNREGISTERED":    return "Unregistered";
            case "DISCONTINUED":    return "Discontinued";
            case "HALTED":          return "Halted";
            case "DEAD YEAR":       return "Dead Year";
            case "ACTIVE":          return "Registered";
            default:
                return string.IsNullOrEmpty(raw) ? "Unknown" : raw;
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ID CARD PRINTING STATUS
    // ═══════════════════════════════════════════════════════════════════

    private void HandleIdCard()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        // Students see their own card; staff can query any student with ?regno=
        string regno;
        if (auth.UserType == "staff")
        {
            regno = ApiHelper.Param(Request, "regno", "").Trim();
            if (string.IsNullOrEmpty(regno))
            {
                ApiHelper.Error(Response, "Staff must supply ?regno=", "MISSING_PARAM");
                return;
            }
        }
        else
        {
            regno = auth.UserId;
        }

        bool forceRefresh = ApiHelper.Param(Request, "refresh", "0") == "1"
                         || ApiHelper.Param(Request, "refresh", "0").ToLower() == "true";

        // ── 1. OmniPass status (cached unless ?refresh=1) ─────────────
        OmniPassHelper.CardStatus card;
        using (MySqlConnection conn = ApiHelper.GetConnection())
        {
            card = OmniPassHelper.GetStatus(regno, conn, forceRefresh);
        }

        // ── 2. Detailed card record from acad_student_cards (if exists) ─
        Dictionary<string, object> cardRecord = null;
        try
        {
            DataTable cardDt = ApiHelper.Query(
                @"SELECT sc.ID AS card_id, sc.card_type, sc.card_status AS print_status,
                         DATE_FORMAT(sc.expiry_date,'%Y-%m-%d') AS expiry_date,
                         sc.acadyear, sc.semester,
                         DATE_FORMAT(sc.date_created,'%Y-%m-%d %H:%i') AS date_created
                  FROM acad_student_cards sc
                  WHERE sc.reg_no = @r
                  ORDER BY sc.date_created DESC LIMIT 1",
                new MySqlParameter("@r", regno));

            if (cardDt.Rows.Count > 0)
                cardRecord = ApiHelper.FirstRowToDict(cardDt);
        }
        catch { /* acad_student_cards may not exist on all installations */ }

        // ── 3. Collection instructions ────────────────────────────────
        string collectionNote = null;
        if (card.Status == "PRINTED")
            collectionNote = "Your ID card is ready. Please visit the Student Services office with your admission letter or registration slip to collect it.";
        else if (card.Status == "NOT_PRINTED")
            collectionNote = "Your ID card has not been printed yet. Cards are processed in batches — check again in a few days.";
        else if (card.Status == "NOT_FOUND")
            collectionNote = "Your details were not found in the card printing system. Please visit the Student Services office.";

        var result = new Dictionary<string, object>
        {
            { "regno",           regno },
            { "status",          card.Status },
            { "status_label",    card.DisplayLabel },
            { "card_printed",    card.CardPrinted },
            { "message",         card.Message },
            { "collection_note", collectionNote },
            { "checked_at",      card.CheckedAt.HasValue ? card.CheckedAt.Value.ToString("yyyy-MM-dd HH:mm") : null },
            { "from_cache",      card.FromCache },
            { "card_record",     cardRecord }
        };

        ApiHelper.Success(Response, result);
    }
}
