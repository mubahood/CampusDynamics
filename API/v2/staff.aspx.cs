using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
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
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: profile, photo, my_courses, class_list, marks, submit_marks", "INVALID_ACTION");
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
            @"SELECT e.emp_id, e.emp_surname, e.emp_othernames, e.emp_gender, 
                     e.emp_email, e.emp_phone, e.emp_title, 
                     d.dept_name AS department, f.fac_name AS faculty,
                     e.emp_status, e.emp_designation, e.emp_contract_type,
                     e.emp_date_employed, e.emp_national_id, e.usernames
              FROM hrm_employee e
              LEFT JOIN hrm_department d ON e.emp_dept = d.dept_id
              LEFT JOIN hrm_faculty f ON e.emp_faculty = f.fac_id
              WHERE e.usernames = @uid",
            new MySqlParameter("@uid", staffUsername)
        );

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND");
            return;
        }

        var profile = ApiHelper.FirstRowToDict(dt);
        profile["photo_url"] = "/API/staff_photo.aspx?id=" + Server.UrlEncode(dt.Rows[0]["emp_id"].ToString());

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

        // Get emp_id from username
        DataTable empDt = ApiHelper.Query(
            "SELECT emp_id FROM hrm_employee WHERE usernames = @uid",
            new MySqlParameter("@uid", auth.UserId)
        );

        if (empDt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND");
            return;
        }

        string empId = empDt.Rows[0]["emp_id"].ToString();

        // Try database photo
        DataTable photoDt = ApiHelper.Query(
            "SELECT emp_photo FROM hrm_employee WHERE emp_id = @id",
            new MySqlParameter("@id", empId)
        );

        if (photoDt.Rows.Count > 0 && photoDt.Rows[0]["emp_photo"] != DBNull.Value)
        {
            byte[] photoData = (byte[])photoDt.Rows[0]["emp_photo"];
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

        // Try file-based photo
        string photoPath = Server.MapPath("~/staffimages/" + empId + ".jpg");
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

        // Get lecturer's emp_id
        DataTable empDt = ApiHelper.Query(
            "SELECT emp_id FROM hrm_employee WHERE usernames = @uid",
            new MySqlParameter("@uid", auth.UserId)
        );

        if (empDt.Rows.Count == 0)
        {
            ApiHelper.Error(Response, "Staff member not found.", "NOT_FOUND");
            return;
        }

        string empId = empDt.Rows[0]["emp_id"].ToString();

        string sql = @"SELECT ta.course_code, c.courseName AS course_name, c.CreditUnit AS credit_units,
                       ta.programme_code, p.progname AS programme_name,
                       ta.acad_year, ta.semester, ta.study_year
                FROM acad_teaching_allocation ta
                LEFT JOIN acad_course c ON ta.course_code = c.courseID
                LEFT JOIN acad_programme p ON ta.programme_code = p.progcode
                WHERE ta.lecturer = @empId";

        var parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@empId", empId));

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

        sql += " ORDER BY ta.acad_year DESC, ta.semester, ta.course_code";

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
                     s.study_yr, s.studsesion AS session
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
                            "SELECT progid, study_yr FROM acad_student WHERE regno=@reg",
                            new MySqlParameter("@reg", regno)
                        );

                        string progcode = studDt.Rows.Count > 0 ? studDt.Rows[0]["progid"].ToString() : "";
                        string studyYear = studDt.Rows.Count > 0 ? studDt.Rows[0]["study_yr"].ToString() : "1";

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
}
