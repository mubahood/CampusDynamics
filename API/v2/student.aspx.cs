using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
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
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: profile, photo, lock_status, summary", "INVALID_ACTION");
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
}
