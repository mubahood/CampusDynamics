using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

public partial class API_v2_timetable : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "lectures":
                    HandleLectures();
                    break;
                case "exams":
                    HandleExams();
                    break;
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: lectures, exams", "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleLectures()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        string semester = ApiHelper.Param(Request, "semester", "");

        try
        {
            string userId = auth.UserId;

            if (auth.UserType == "student")
            {
                // Get student's programme info
                DataTable studentDt = ApiHelper.Query(
                    @"SELECT s.progid, 
                            COALESCE((SELECT MAX(r.studyyear) FROM acad_registration r WHERE r.regno = s.regno), 1) AS study_year,
                            s.studsesion, s.studCampus, s.entryyear, s.intake
                      FROM acad_student s WHERE s.regno = @reg",
                    new MySqlParameter("@reg", userId)
                );

                if (studentDt.Rows.Count == 0)
                {
                    ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
                    return;
                }

                DataRow sr = studentDt.Rows[0];
                string progid = sr["progid"].ToString();
                string studyYear = sr["study_year"].ToString();

                // Get timetable for the student's programme
                string sql = @"SELECT t.day_of_week, t.start_time, t.end_time, 
                               t.course_code, c.courseName AS course_name,
                               t.room, t.building,
                               CONCAT(IFNULL(e.emp_surname,''), ' ', IFNULL(e.emp_othernames,'')) AS lecturer
                        FROM acad_timetable t
                        LEFT JOIN acad_course c ON t.course_code = c.courseID
                        LEFT JOIN hrm_employee e ON t.lecturer_id = e.emp_id
                        WHERE t.programme_code = @prog AND t.study_year = @yr";

                var parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@prog", progid));
                parms.Add(new MySqlParameter("@yr", studyYear));

                if (!string.IsNullOrEmpty(acad_year))
                {
                    sql += " AND t.acad_year = @acad";
                    parms.Add(new MySqlParameter("@acad", acad_year));
                }
                if (!string.IsNullOrEmpty(semester))
                {
                    sql += " AND t.semester = @sem";
                    parms.Add(new MySqlParameter("@sem", semester));
                }

                sql += " ORDER BY FIELD(t.day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'), t.start_time";

                DataTable dt = ApiHelper.Query(sql, parms.ToArray());
                ApiHelper.Success(Response, ApiHelper.TableToList(dt));
            }
            else
            {
                // Staff: get timetable for courses they teach
                string sql = @"SELECT t.day_of_week, t.start_time, t.end_time, 
                               t.course_code, c.courseName AS course_name,
                               t.room, t.building, t.programme_code, p.progname AS programme_name
                        FROM acad_timetable t
                        LEFT JOIN acad_course c ON t.course_code = c.courseID
                        LEFT JOIN acad_programme p ON t.programme_code = p.progcode
                        LEFT JOIN hrm_employee e ON t.lecturer_id = e.emp_id
                        WHERE e.usernames = @uid";

                var parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@uid", userId));

                if (!string.IsNullOrEmpty(acad_year))
                {
                    sql += " AND t.acad_year = @acad";
                    parms.Add(new MySqlParameter("@acad", acad_year));
                }
                if (!string.IsNullOrEmpty(semester))
                {
                    sql += " AND t.semester = @sem";
                    parms.Add(new MySqlParameter("@sem", semester));
                }

                sql += " ORDER BY FIELD(t.day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'), t.start_time";

                DataTable dt = ApiHelper.Query(sql, parms.ToArray());
                ApiHelper.Success(Response, ApiHelper.TableToList(dt));
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching lecture timetable: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleExams()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;

        string acad_year = ApiHelper.Param(Request, "acad_year", "");
        string semester = ApiHelper.Param(Request, "semester", "");

        try
        {
            string userId = auth.UserId;

            if (auth.UserType == "student")
            {
                // Get student's registered courses and their exam schedule
                DataTable studentDt = ApiHelper.Query(
                    "SELECT progid, study_yr FROM acad_student WHERE regno = @reg",
                    new MySqlParameter("@reg", userId)
                );

                if (studentDt.Rows.Count == 0)
                {
                    ApiHelper.Error(Response, "Student not found.", "NOT_FOUND");
                    return;
                }

                string progid = studentDt.Rows[0]["progid"].ToString();
                string studyYear = studentDt.Rows[0]["study_yr"].ToString();

                string sql = @"SELECT et.exam_date, et.start_time, et.end_time,
                               et.course_code, c.courseName AS course_name,
                               et.venue, et.exam_type
                        FROM acad_exam_timetable et
                        LEFT JOIN acad_course c ON et.course_code = c.courseID
                        WHERE et.programme_code = @prog AND et.study_year = @yr";

                var parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@prog", progid));
                parms.Add(new MySqlParameter("@yr", studyYear));

                if (!string.IsNullOrEmpty(acad_year))
                {
                    sql += " AND et.acad_year = @acad";
                    parms.Add(new MySqlParameter("@acad", acad_year));
                }
                if (!string.IsNullOrEmpty(semester))
                {
                    sql += " AND et.semester = @sem";
                    parms.Add(new MySqlParameter("@sem", semester));
                }

                sql += " ORDER BY et.exam_date, et.start_time";

                DataTable dt = ApiHelper.Query(sql, parms.ToArray());
                ApiHelper.Success(Response, ApiHelper.TableToList(dt));
            }
            else
            {
                // Staff: exam timetable for their courses
                string sql = @"SELECT et.exam_date, et.start_time, et.end_time,
                               et.course_code, c.courseName AS course_name,
                               et.venue, et.exam_type, et.programme_code
                        FROM acad_exam_timetable et
                        LEFT JOIN acad_course c ON et.course_code = c.courseID
                        LEFT JOIN hrm_employee e ON et.invigilator_id = e.emp_id
                        WHERE e.usernames = @uid";

                var parms = new List<MySqlParameter>();
                parms.Add(new MySqlParameter("@uid", userId));

                if (!string.IsNullOrEmpty(acad_year))
                {
                    sql += " AND et.acad_year = @acad";
                    parms.Add(new MySqlParameter("@acad", acad_year));
                }
                if (!string.IsNullOrEmpty(semester))
                {
                    sql += " AND et.semester = @sem";
                    parms.Add(new MySqlParameter("@sem", semester));
                }

                sql += " ORDER BY et.exam_date, et.start_time";

                DataTable dt = ApiHelper.Query(sql, parms.ToArray());
                ApiHelper.Success(Response, ApiHelper.TableToList(dt));
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Error fetching exam timetable: " + ex.Message, "SERVER_ERROR");
        }
    }
}
