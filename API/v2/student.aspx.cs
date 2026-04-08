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
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: profile, photo, lock_status, summary, lookup, verify, search, by_programme", "INVALID_ACTION");
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
}
