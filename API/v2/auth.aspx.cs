using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Security;
using MySql.Data.MySqlClient;

public partial class API_v2_auth : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "login":
                    HandleLogin();
                    break;
                case "logout":
                    HandleLogout();
                    break;
                case "validate":
                    HandleValidate();
                    break;
                default:
                    ApiHelper.Error(Response, "Unknown action: " + action + ". Valid actions: login, logout, validate", "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    private void HandleLogin()
    {
        string username = ApiHelper.RequireParam(Request, Response, "username");
        string password = ApiHelper.RequireParam(Request, Response, "password");

        // Use ASP.NET Membership to validate credentials
        bool isValid = Membership.ValidateUser(username, password);

        if (!isValid)
        {
            ApiHelper.Error(Response, "Invalid username or password.", "AUTH_LOGIN_FAILED");
            return;
        }

        // Determine user type: student usernames contain "MRU"
        string userType = username.ToUpper().Contains("MRU") ? "student" : "staff";
        string fullName = "";

        // Fetch the user's full name
        try
        {
            if (userType == "student")
            {
                DataTable dt = ApiHelper.Query(
                    "SELECT CONCAT(IFNULL(surname,''), ' ', IFNULL(othername,'')) AS full_name FROM acad_student WHERE regno = @reg",
                    new MySqlParameter("@reg", username)
                );
                if (dt.Rows.Count > 0)
                    fullName = dt.Rows[0]["full_name"].ToString().Trim();
            }
            else
            {
                DataTable dt = ApiHelper.Query(
                    "SELECT CONCAT(IFNULL(emp_surname,''), ' ', IFNULL(emp_othernames,'')) AS full_name FROM hrm_employee WHERE usernames = @uid",
                    new MySqlParameter("@uid", username)
                );
                if (dt.Rows.Count > 0)
                    fullName = dt.Rows[0]["full_name"].ToString().Trim();
            }
        }
        catch { /* Name lookup failure shouldn't block login */ }

        // Create token
        string ipAddress = Request.UserHostAddress;
        TokenInfo tokenInfo = TokenManager.CreateToken(username, userType, fullName, ipAddress);

        // Clean up old expired tokens (housekeeping)
        try { TokenManager.CleanupExpired(); } catch { }

        var responseData = new Dictionary<string, object>
        {
            { "token", tokenInfo.Token },
            { "user_type", tokenInfo.UserType },
            { "user_id", tokenInfo.UserId },
            { "full_name", tokenInfo.FullName },
            { "expires", tokenInfo.ExpiresAt.ToString("o") }
        };

        ApiHelper.Success(Response, responseData, "Login successful");
    }

    private void HandleLogout()
    {
        string token = ApiHelper.RequireParam(Request, Response, "token");
        TokenManager.InvalidateToken(token);
        ApiHelper.Success(Response, null, "Logged out successfully");
    }

    private void HandleValidate()
    {
        string token = ApiHelper.RequireParam(Request, Response, "token");
        TokenInfo info = TokenManager.ValidateToken(token);

        if (info == null)
        {
            ApiHelper.Error(Response, "Token is invalid or expired.", "AUTH_INVALID_TOKEN");
            return;
        }

        var responseData = new Dictionary<string, object>
        {
            { "user_id", info.UserId },
            { "user_type", info.UserType },
            { "full_name", info.FullName },
            { "expires", info.ExpiresAt.ToString("o") }
        };

        ApiHelper.Success(Response, responseData, "Token is valid");
    }
}
