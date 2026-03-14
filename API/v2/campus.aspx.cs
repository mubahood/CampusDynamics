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
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: notices, directory, academic_years, current_semester, programmes, campuses", "INVALID_ACTION");
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
                string sql = @"SELECT e.emp_id, 
                               CONCAT(IFNULL(e.emp_surname,''), ' ', IFNULL(e.emp_othernames,'')) AS full_name,
                               e.emp_title, e.emp_designation, e.emp_email, e.emp_telephone,
                               d.dept_name AS department, f.fac_name AS faculty
                        FROM hrm_employee e
                        LEFT JOIN hrm_department d ON e.emp_dept = d.dept_id
                        LEFT JOIN hrm_faculty f ON e.emp_faculty = f.fac_id
                        WHERE e.emp_status = 'Active'";

                var parms = new List<MySqlParameter>();

                if (!string.IsNullOrEmpty(category))
                {
                    sql += " AND (d.dept_name LIKE @cat OR f.fac_name LIKE @cat OR e.emp_designation LIKE @cat)";
                    parms.Add(new MySqlParameter("@cat", "%" + category + "%"));
                }

                sql += " ORDER BY e.emp_surname, e.emp_othernames";

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

    /// <summary>No auth required — public endpoint.</summary>
    private void HandleProgrammes()
    {
        try
        {
            DataTable dt = ApiHelper.Query(
                @"SELECT p.progcode, p.progname AS programme, p.prog_type, p.duration
                  FROM acad_programme p
                  WHERE p.progcode IS NOT NULL AND TRIM(p.progcode) <> ''
                  ORDER BY p.progname"
            );
            ApiHelper.Success(Response, ApiHelper.TableToList(dt));
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
}
