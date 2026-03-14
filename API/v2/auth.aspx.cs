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

        // Resolve the input identifier to the actual membership username.
        // Users may login with: registration number (MRU...), student number (entry number with /),
        // email address, or staff username. We look up the real membership username first.
        string resolvedUsername = null;
        string userType = null;
        string fullName = "";

        try
        {
            resolvedUsername = ResolveUsername(username.Trim(), out userType, out fullName);
        }
        catch { /* Resolution failure will be handled below */ }

        // If we couldn't resolve the identifier, try the raw input as-is (staff username)
        if (string.IsNullOrEmpty(resolvedUsername))
        {
            resolvedUsername = username.Trim();
            // Default to staff if we couldn't resolve
            if (userType == null) userType = "staff";
        }

        // Validate credentials against ASP.NET Membership
        bool isValid = Membership.ValidateUser(resolvedUsername, password);

        if (!isValid)
        {
            ApiHelper.Error(Response, "Invalid username or password.", "AUTH_LOGIN_FAILED");
            return;
        }

        // If we hadn't fetched the full name yet (e.g. staff fallback), fetch it now
        if (string.IsNullOrEmpty(fullName))
        {
            try
            {
                if (userType == "student")
                {
                    DataTable dt = ApiHelper.Query(
                        "SELECT CONCAT(IFNULL(firstname,''), ' ', IFNULL(othername,'')) AS full_name FROM acad_student WHERE TRIM(regno) = @reg",
                        new MySqlParameter("@reg", resolvedUsername)
                    );
                    if (dt.Rows.Count > 0)
                        fullName = dt.Rows[0]["full_name"].ToString().Trim();
                }
                else
                {
                    DataTable dt = ApiHelper.Query(
                        "SELECT CONCAT(IFNULL(emp_surname,''), ' ', IFNULL(emp_othernames,'')) AS full_name FROM hrm_employee WHERE TRIM(usernames) = @uid",
                        new MySqlParameter("@uid", resolvedUsername)
                    );
                    if (dt.Rows.Count > 0)
                        fullName = dt.Rows[0]["full_name"].ToString().Trim();
                }
            }
            catch { /* Name lookup failure shouldn't block login */ }
        }

        // Create token using the resolved membership username
        string ipAddress = Request.UserHostAddress;
        TokenInfo tokenInfo = TokenManager.CreateToken(resolvedUsername, userType, fullName, ipAddress);

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

    /// <summary>
    /// Resolves a login identifier (reg number, student/entry number, email, or staff username)
    /// to the actual ASP.NET Membership username.
    /// 
    /// Resolution order:
    ///   1. Student by registration number (regno) — e.g. "MRU2025003204"
    ///   2. Student by entry/student number (entryno) — e.g. "2025/AUG/BSCS/0001"
    ///   3. Student by email address
    ///   4. Staff by username (usernames column)
    ///   5. Staff by email (emp_email column)
    /// </summary>
    private string ResolveUsername(string input, out string userType, out string fullName)
    {
        userType = null;
        fullName = "";

        if (string.IsNullOrEmpty(input)) return null;

        // --- 1. Try student by registration number (contains "MRU" or starts with known pattern) ---
        DataTable dt = ApiHelper.Query(
            @"SELECT TRIM(regno) AS regno, 
                     CONCAT(IFNULL(firstname,''), ' ', IFNULL(othername,'')) AS full_name 
              FROM acad_student 
              WHERE TRIM(regno) = @input 
              LIMIT 1",
            new MySqlParameter("@input", input)
        );
        if (dt.Rows.Count > 0)
        {
            userType = "student";
            fullName = dt.Rows[0]["full_name"].ToString().Trim();
            return dt.Rows[0]["regno"].ToString().Trim();
        }

        // --- 2. Try student by entry/student number (entryno — typically contains "/") ---
        dt = ApiHelper.Query(
            @"SELECT TRIM(regno) AS regno, 
                     CONCAT(IFNULL(firstname,''), ' ', IFNULL(othername,'')) AS full_name 
              FROM acad_student 
              WHERE TRIM(entryno) = @input 
              LIMIT 1",
            new MySqlParameter("@input", input)
        );
        if (dt.Rows.Count > 0)
        {
            userType = "student";
            fullName = dt.Rows[0]["full_name"].ToString().Trim();
            return dt.Rows[0]["regno"].ToString().Trim();
        }

        // --- 3. Try student by email ---
        if (input.Contains("@"))
        {
            dt = ApiHelper.Query(
                @"SELECT TRIM(regno) AS regno, 
                         CONCAT(IFNULL(firstname,''), ' ', IFNULL(othername,'')) AS full_name 
                  FROM acad_student 
                  WHERE TRIM(email) = @input 
                  LIMIT 1",
                new MySqlParameter("@input", input)
            );
            if (dt.Rows.Count > 0)
            {
                userType = "student";
                fullName = dt.Rows[0]["full_name"].ToString().Trim();
                return dt.Rows[0]["regno"].ToString().Trim();
            }
        }

        // --- 4. Try staff by username ---
        dt = ApiHelper.Query(
            @"SELECT TRIM(usernames) AS usernames, 
                     CONCAT(IFNULL(emp_surname,''), ' ', IFNULL(emp_othernames,'')) AS full_name 
              FROM hrm_employee 
              WHERE TRIM(usernames) = @input 
              LIMIT 1",
            new MySqlParameter("@input", input)
        );
        if (dt.Rows.Count > 0)
        {
            userType = "staff";
            fullName = dt.Rows[0]["full_name"].ToString().Trim();
            return dt.Rows[0]["usernames"].ToString().Trim();
        }

        // --- 5. Try staff by email ---
        if (input.Contains("@"))
        {
            dt = ApiHelper.Query(
                @"SELECT TRIM(usernames) AS usernames, 
                         CONCAT(IFNULL(emp_surname,''), ' ', IFNULL(emp_othernames,'')) AS full_name 
                  FROM hrm_employee 
                  WHERE TRIM(emp_email) = @input 
                  LIMIT 1",
                new MySqlParameter("@input", input)
            );
            if (dt.Rows.Count > 0)
            {
                userType = "staff";
                fullName = dt.Rows[0]["full_name"].ToString().Trim();
                return dt.Rows[0]["usernames"].ToString().Trim();
            }
        }

        // Not found in any table — return null, caller will try raw input
        return null;
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
