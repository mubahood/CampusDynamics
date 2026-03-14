using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Security.Cryptography;
using System.Text;
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
        // email address, or staff username.
        string resolvedUsername = null;
        string userType = null;
        string fullName = "";

        try
        {
            resolvedUsername = ResolveUsername(username.Trim(), out userType, out fullName);
        }
        catch { /* Resolution failure will be handled below */ }

        // If we couldn't resolve the identifier, try the raw input as-is
        if (string.IsNullOrEmpty(resolvedUsername))
        {
            resolvedUsername = username.Trim();
            if (userType == null) userType = "staff";
        }

        // Validate credentials directly against the membership tables.
        // Students are in campus_dynamics_portal.my_aspnet_*, staff in campus_dynamics.my_aspnet_*.
        // We bypass Membership.ValidateUser() because the API runs in CampusDynamics which
        // points to the wrong membership database for students.
        bool isValid = ValidatePassword(resolvedUsername, password, userType);

        if (!isValid)
        {
            ApiHelper.Error(Response, "Invalid username or password.", "AUTH_LOGIN_FAILED");
            return;
        }

        // If we hadn't fetched the full name yet (fallback path), fetch it now
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
    /// Validates a password directly against the MySQL membership tables.
    /// Students are checked in campus_dynamics_portal, staff in campus_dynamics.
    /// If the primary database fails, we also try the other one as fallback.
    /// </summary>
    private bool ValidatePassword(string membershipUsername, string password, string userType)
    {
        // Try the primary database for this user type
        if (userType == "student")
        {
            // Students: portal DB first, then main DB as fallback
            if (CheckMembershipPassword(membershipUsername, password, usePortalDb: true))
                return true;
            if (CheckMembershipPassword(membershipUsername, password, usePortalDb: false))
                return true;
        }
        else
        {
            // Staff: main DB first, then portal DB as fallback
            if (CheckMembershipPassword(membershipUsername, password, usePortalDb: false))
                return true;
            if (CheckMembershipPassword(membershipUsername, password, usePortalDb: true))
                return true;
        }

        return false;
    }

    /// <summary>
    /// Checks a password against the my_aspnet_membership table in the specified database.
    /// Uses the same HMACSHA256 hashing that MySQLMembershipProvider uses.
    /// </summary>
    private bool CheckMembershipPassword(string username, string password, bool usePortalDb)
    {
        try
        {
            string dbPrefix = usePortalDb ? "campus_dynamics_portal" : "campus_dynamics";
            string sql = @"SELECT m.password, m.passwordKey 
                           FROM " + dbPrefix + @".my_aspnet_membership m
                           INNER JOIN " + dbPrefix + @".my_aspnet_users u ON m.userId = u.id
                           WHERE TRIM(u.name) = @username 
                             AND (m.IsLockedOut = 0 OR m.IsLockedOut IS NULL)
                           LIMIT 1";

            DataTable dt = ApiHelper.Query(sql, new MySqlParameter("@username", username));

            if (dt.Rows.Count == 0) return false;

            string storedHash = dt.Rows[0]["password"].ToString();
            string storedSalt = dt.Rows[0]["passwordKey"].ToString();

            string computedHash = HashPasswordWithSalt(password, storedSalt);
            return string.Equals(storedHash, computedHash, StringComparison.Ordinal);
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Hashes a password using HMACSHA256 with the given salt, matching the
    /// ASP.NET MySQLMembershipProvider passwordFormat="Hashed" algorithm.
    /// Algorithm: HMACSHA256(key=salt_bytes, data=salt_bytes + Unicode_bytes(password))
    /// </summary>
    private string HashPasswordWithSalt(string password, string base64Salt)
    {
        byte[] saltBytes = Convert.FromBase64String(base64Salt);
        byte[] passwordBytes = Encoding.Unicode.GetBytes(password);

        byte[] combined = new byte[saltBytes.Length + passwordBytes.Length];
        System.Buffer.BlockCopy(saltBytes, 0, combined, 0, saltBytes.Length);
        System.Buffer.BlockCopy(passwordBytes, 0, combined, saltBytes.Length, passwordBytes.Length);

        using (HMACSHA256 hmac = new HMACSHA256(saltBytes))
        {
            byte[] hashBytes = hmac.ComputeHash(combined);
            return Convert.ToBase64String(hashBytes);
        }
    }

    /// <summary>
    /// Resolves a login identifier (reg number, student/entry number, email, or staff username)
    /// to the actual membership username (= regno for students, = usernames for staff).
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

        // --- 1. Try student by registration number ---
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

        // --- 2. Try student by entry/student number ---
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
