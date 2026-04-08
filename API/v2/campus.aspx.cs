using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

public partial class API_v2_campus : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "notices":
                    HandleNotices();
                    break;
                case "directory":
                    HandleDirectory();
                    break;
                case "academic_years":
                    HandleAcademicYears();
                    break;
                case "current_semester":
                    HandleCurrentSemester();
                    break;
                case "programmes":
                    HandleProgrammes();
                    break;
                case "campuses":
                    HandleCampuses();
                    break;
                case "faculties":
                    HandleFaculties();
                    break;
                case "departments":
                    HandleDepartments();
                    break;
                case "academic_calendar":
                    HandleAcademicCalendar();
                    break;
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: notices, directory, academic_years, current_semester, programmes, campuses, faculties, departments, academic_calendar", "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleNotices()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        int page = ApiHelper.ParamInt(Request, "page", 1);
        int limit = ApiHelper.ParamInt(Request, "limit", 20);
        if (limit > 50) limit = 50;
        if (page < 1) page = 1;
        int offset = (page - 1) * limit;

        try
        {
            // Ensure acad_notices table exists
            ApiHelper.Execute(@"CREATE TABLE IF NOT EXISTS acad_notices (
                ID INT AUTO_INCREMENT PRIMARY KEY,
                Notice_Title VARCHAR(500),
                Notice_detail TEXT,
                Author VARCHAR(200),
                Notice_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                Target_category VARCHAR(100) DEFAULT 'All',
                Archive_Status VARCHAR(20) DEFAULT 'Active'
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8");

            // Get total count
            object totalObj = ApiHelper.Scalar("SELECT COUNT(*) FROM acad_notices WHERE Archive_Status = 'Active'");
            int total = Convert.ToInt32(totalObj);

            DataTable dt = ApiHelper.Query(
                @"SELECT ID AS notice_id, Notice_Title AS title, Notice_detail AS content, 
                         Author AS created_by, 
                         DATE_FORMAT(Notice_date, '%Y-%m-%d %H:%i') AS date_created,
                         Target_category AS target_audience
                  FROM acad_notices 
                  WHERE Archive_Status = 'Active'
                  ORDER BY Notice_date DESC
                  LIMIT @limit OFFSET @offset",
                new MySqlParameter("@limit", limit),
                new MySqlParameter("@offset", offset)
            );

            var data = new Dictionary<string, object>
            {
                { "notices", ApiHelper.TableToList(dt) },
                { "pagination", new Dictionary<string, object>
                    {
                        { "page", page },
                        { "limit", limit },
                        { "total", total },
                        { "total_pages", (int)Math.Ceiling((double)total / limit) }
                    }
                }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching notices: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleDirectory()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string category = ApiHelper.Param(Request, "category", "");

        try
        {
            // Use existing mobile directory adapter
            MobileDataTableAdapters.mobile_GetDirectoryTableAdapter DIR = new MobileDataTableAdapters.mobile_GetDirectoryTableAdapter();
            DataTable dt = DIR.GetData(string.IsNullOrEmpty(category) ? "%" : category);
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            // Fallback: direct query
            try
            {
                string sql = @"SELECT e.empID, e.emp_name AS full_name,
                               e.EmpType, e.emp_email, e.emp_phone,
                               d.dept_name AS department
                        FROM hrm_employee e
                        LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID AND c.contractStatus = 'VALID'
                        LEFT JOIN hrm_departments d ON c.departmentID = d.ID
                        WHERE c.contractStatus = 'VALID' OR c.contractStatus IS NOT NULL";

                var parms = new List<MySqlParameter>();

                if (!string.IsNullOrEmpty(category))
                {
                    sql += " AND (d.dept_name LIKE @cat OR e.EmpType LIKE @cat)";
                    parms.Add(new MySqlParameter("@cat", "%" + category + "%"));
                }

                sql += " ORDER BY e.emp_name";

                DataTable dt = ApiHelper.Query(sql, parms.ToArray());
                ApiHelper.Success(Response, ApiHelper.TableToList(dt));
            }
            catch (Exception ex2)
            {
                ApiHelper.Error(Response, "Error fetching directory: " + ex2.Message, "SERVER_ERROR");
            }
        }
    }

    /// <summary>No auth required — public endpoint.</summary>
    private void HandleAcademicYears()
    {
        try
        {
            DataTable dt = ApiHelper.Query(
                "SELECT DISTINCT academic_year AS acad_year FROM acad_calender ORDER BY academic_year DESC"
            );
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            // Fallback: generate academic years programmatically
            var years = new List<Dictionary<string, object>>();
            int currentYear = DateTime.Now.Year;
            for (int y = currentYear + 1; y >= currentYear - 10; y--)
            {
                years.Add(new Dictionary<string, object>
                {
                    { "acad_year", (y - 1) + "/" + y }
                });
            }
            ApiHelper.Success(Response, years);
        }
    }

    /// <summary>No auth required — public endpoint.</summary>
    private void HandleCurrentSemester()
    {
        try
        {
            DataTable dt = ApiHelper.Query(
                @"SELECT academic_year AS acad_year
                  FROM acad_calender 
                  WHERE is_current = 1
                  LIMIT 1"
            );

            if (dt.Rows.Count > 0)
            {
                var result = ApiHelper.FirstRowToDict(dt);
                ApiHelper.Success(Response, result);
            }
            else
            {
                // Calculate based on date
                int year = DateTime.Now.Year;
                int month = DateTime.Now.Month;
                int sem = month >= 1 && month <= 6 ? 2 : 1;
                string acadYear = sem == 1 ? year + "/" + (year + 1) : (year - 1) + "/" + year;

                ApiHelper.Success(Response, new Dictionary<string, object>
                {
                    { "acad_year", acadYear },
                    { "semester", sem },
                    { "note", "Calculated from system date" }
                });
            }
        }
        catch (Exception ex)
        {
            // Fallback: calculate from system date
            int year = DateTime.Now.Year;
            int month = DateTime.Now.Month;
            int sem = month >= 1 && month <= 6 ? 2 : 1;
            string acadYear = sem == 1 ? year + "/" + (year + 1) : (year - 1) + "/" + year;

            ApiHelper.Success(Response, new Dictionary<string, object>
            {
                { "acad_year", acadYear },
                { "semester", sem },
                { "note", "Calculated from system date" }
            });
        }
    }

    /// <summary>No auth required — public endpoint. Enhanced for ODEL with faculty/department/level.</summary>
    private void HandleProgrammes()
    {
        string facultyCode = ApiHelper.Param(Request, "faculty_code", "");
        string level = ApiHelper.Param(Request, "level", "");

        try
        {
            string sql = @"SELECT p.progcode, p.progname AS programme,
                                  COALESCE(f.fax_code, '') AS faculty_code,
                                  COALESCE(f.faculty_name, '') AS faculty,
                                  COALESCE(d.dept_name, '') AS department,
                                  COALESCE(p.proglevel, '') AS level,
                                  COALESCE(p.progduration, 0) AS duration_years,
                                  COALESCE(p.progtype, '') AS study_mode
                           FROM acad_programme p
                           LEFT JOIN acad_faculty f ON p.progfaculty = f.fax_code
                           LEFT JOIN hrm_departments d ON p.progdept = d.ID
                           WHERE p.progcode IS NOT NULL AND TRIM(p.progcode) <> ''";

            var parms = new List<MySqlParameter>();

            if (!string.IsNullOrEmpty(facultyCode))
            {
                sql += " AND p.progfaculty = @fax";
                parms.Add(new MySqlParameter("@fax", facultyCode));
            }
            if (!string.IsNullOrEmpty(level))
            {
                sql += " AND p.proglevel = @lvl";
                parms.Add(new MySqlParameter("@lvl", level));
            }

            sql += " ORDER BY p.progname";

            DataTable dt = ApiHelper.Query(sql, parms.ToArray());

            var data = new Dictionary<string, object>
            {
                { "count", dt.Rows.Count },
                { "programmes", ApiHelper.TableToList(dt) }
            };
            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching programmes: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>No auth required — public endpoint.</summary>
    private void HandleCampuses()
    {
        try
        {
            DataTable dt = ApiHelper.Query(
                "SELECT campus_code AS campus_id, campus_name FROM acad_campuses WHERE TRIM(campus_name) <> '' ORDER BY campus_name"
            );
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching campuses: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    //  NEW CAMPUS ENDPOINTS
    // ═══════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Returns all faculties with nested departments. No auth required — public endpoint.
    /// Enhanced for ODEL: each faculty includes its departments array.
    /// </summary>
    private void HandleFaculties()
    {
        try
        {
            // Get faculties
            DataTable dtFac = ApiHelper.Query(
                @"SELECT fax_code AS faculty_code, faculty_name
                  FROM acad_faculty
                  WHERE TRIM(faculty_name) <> ''
                  ORDER BY faculty_name"
            );

            // Get all departments
            DataTable dtDepts = ApiHelper.Query(
                @"SELECT d.ID AS department_id, d.dept_name AS department_name,
                         COALESCE(d.fax_code, '') AS faculty_code
                  FROM hrm_departments d
                  WHERE TRIM(d.dept_name) <> ''
                  ORDER BY d.dept_name"
            );

            // Group departments by faculty
            var deptsByFaculty = new Dictionary<string, List<Dictionary<string, object>>>();
            foreach (DataRow row in dtDepts.Rows)
            {
                string faxCode = Convert.ToString(row["faculty_code"]);
                if (!deptsByFaculty.ContainsKey(faxCode))
                    deptsByFaculty[faxCode] = new List<Dictionary<string, object>>();

                deptsByFaculty[faxCode].Add(new Dictionary<string, object>
                {
                    { "department_id", Convert.ToString(row["department_id"]) },
                    { "department_name", Convert.ToString(row["department_name"]) }
                });
            }

            // Build faculties with nested departments
            var faculties = new List<Dictionary<string, object>>();
            foreach (DataRow row in dtFac.Rows)
            {
                string facCode = Convert.ToString(row["faculty_code"]);
                var fac = new Dictionary<string, object>
                {
                    { "faculty_code", facCode },
                    { "faculty_name", Convert.ToString(row["faculty_name"]) },
                    { "departments", deptsByFaculty.ContainsKey(facCode) ? (object)deptsByFaculty[facCode] : new List<Dictionary<string, object>>() }
                };
                faculties.Add(fac);
            }

            var data = new Dictionary<string, object>
            {
                { "count", faculties.Count },
                { "faculties", faculties }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching faculties: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// Returns all departments, optionally filtered by faculty.
    /// No auth required — public endpoint.
    /// Query params: faculty_code (optional) — filter by faculty.
    /// </summary>
    private void HandleDepartments()
    {
        string facultyCode = ApiHelper.Param(Request, "faculty_code", "");

        try
        {
            string sql = @"SELECT d.ID AS department_id, d.dept_name AS department_name,
                                  COALESCE(d.fax_code, '') AS faculty_code,
                                  COALESCE(f.faculty_name, '') AS faculty_name
                           FROM hrm_departments d
                           LEFT JOIN acad_faculty f ON d.fax_code = f.fax_code
                           WHERE TRIM(d.dept_name) <> ''";

            var parms = new List<MySqlParameter>();

            if (!string.IsNullOrEmpty(facultyCode))
            {
                sql += " AND d.fax_code = @fax";
                parms.Add(new MySqlParameter("@fax", facultyCode));
            }

            sql += " ORDER BY d.dept_name";

            DataTable dt = ApiHelper.Query(sql, parms.ToArray());

            var data = new Dictionary<string, object>
            {
                { "count", dt.Rows.Count },
                { "faculty_filter", string.IsNullOrEmpty(facultyCode) ? "all" : facultyCode },
                { "departments", ApiHelper.TableToList(dt) }
            };

            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching departments: " + ex.Message, "SERVER_ERROR");
        }
    }

    /// <summary>
    /// ODEL: Returns academic calendar with semester dates, exam periods, etc.
    /// No auth required — public endpoint.
    /// </summary>
    private void HandleAcademicCalendar()
    {
        string acadYear = ApiHelper.Param(Request, "acad_year", "");

        try
        {
            string sql;
            MySqlParameter[] parms;

            if (!string.IsNullOrEmpty(acadYear))
            {
                sql = @"SELECT academic_year AS acad_year, semester,
                               COALESCE(DATE_FORMAT(sem_start, '%Y-%m-%d'), '') AS semester_start,
                               COALESCE(DATE_FORMAT(sem_end, '%Y-%m-%d'), '') AS semester_end,
                               COALESCE(DATE_FORMAT(exam_start, '%Y-%m-%d'), '') AS exam_start,
                               COALESCE(DATE_FORMAT(exam_end, '%Y-%m-%d'), '') AS exam_end,
                               COALESCE(DATE_FORMAT(reg_deadline, '%Y-%m-%d'), '') AS registration_deadline,
                               is_current
                        FROM acad_calender
                        WHERE academic_year = @ay
                        ORDER BY semester";
                parms = new MySqlParameter[] { new MySqlParameter("@ay", acadYear) };
            }
            else
            {
                sql = @"SELECT academic_year AS acad_year, semester,
                               COALESCE(DATE_FORMAT(sem_start, '%Y-%m-%d'), '') AS semester_start,
                               COALESCE(DATE_FORMAT(sem_end, '%Y-%m-%d'), '') AS semester_end,
                               COALESCE(DATE_FORMAT(exam_start, '%Y-%m-%d'), '') AS exam_start,
                               COALESCE(DATE_FORMAT(exam_end, '%Y-%m-%d'), '') AS exam_end,
                               COALESCE(DATE_FORMAT(reg_deadline, '%Y-%m-%d'), '') AS registration_deadline,
                               is_current
                        FROM acad_calender
                        ORDER BY academic_year DESC, semester";
                parms = new MySqlParameter[] { };
            }

            DataTable dt = ApiHelper.Query(sql, parms);
            var periods = ApiHelper.TableToList(dt);

            // Find current period
            string currentYear = "";
            string currentSem = "";
            foreach (DataRow row in dt.Rows)
            {
                if (Convert.ToString(row["is_current"]) == "1" || Convert.ToString(row["is_current"]).ToLower() == "true")
                {
                    currentYear = Convert.ToString(row["acad_year"]);
                    currentSem = Convert.ToString(row["semester"]);
                    break;
                }
            }

            var data = new Dictionary<string, object>
            {
                { "current_academic_year", currentYear },
                { "current_semester", currentSem },
                { "total_periods", periods.Count },
                { "periods", periods }
            };
            ApiHelper.Success(Response, data);
        }
        catch (Exception ex)
        {
            // Fallback: return basic info from current_semester logic
            int year = DateTime.Now.Year;
            int month = DateTime.Now.Month;
            int sem = month >= 1 && month <= 6 ? 2 : 1;
            string ay = sem == 1 ? year + "/" + (year + 1) : (year - 1) + "/" + year;

            var data = new Dictionary<string, object>
            {
                { "current_academic_year", ay },
                { "current_semester", sem },
                { "total_periods", 0 },
                { "periods", new List<object>() },
                { "note", "Calendar table not fully configured. Basic data returned." }
            };
            ApiHelper.Success(Response, data);
        }
    }
}
