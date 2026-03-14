using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Manages API v2 tokens — creation, validation, and cleanup.
/// Tokens are stored in the `api_tokens` table in the campus_dynamics database.
/// 
/// TABLE CREATION SQL (run once):
/// CREATE TABLE IF NOT EXISTS api_tokens (
///   id INT AUTO_INCREMENT PRIMARY KEY,
///   token VARCHAR(64) NOT NULL UNIQUE,
///   user_id VARCHAR(100) NOT NULL,
///   user_type ENUM('student','staff') NOT NULL DEFAULT 'student',
///   full_name VARCHAR(200),
///   created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
///   expires_at DATETIME NOT NULL,
///   is_active TINYINT(1) NOT NULL DEFAULT 1,
///   last_used DATETIME,
///   ip_address VARCHAR(45),
///   INDEX idx_token (token),
///   INDEX idx_user (user_id),
///   INDEX idx_expires (expires_at)
/// ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/// </summary>
public static class TokenManager
{
    private const int TOKEN_EXPIRY_HOURS = 87600; // ~10 years (effectively unlimited)

    /// <summary>
    /// Creates the api_tokens table if it doesn't exist.
    /// Called automatically on first use.
    /// </summary>
    public static void EnsureTable()
    {
        string sql = @"CREATE TABLE IF NOT EXISTS api_tokens (
            id INT AUTO_INCREMENT PRIMARY KEY,
            token VARCHAR(64) NOT NULL UNIQUE,
            user_id VARCHAR(100) NOT NULL,
            user_type VARCHAR(20) NOT NULL DEFAULT 'student',
            full_name VARCHAR(200),
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            expires_at DATETIME NOT NULL,
            is_active TINYINT(1) NOT NULL DEFAULT 1,
            last_used DATETIME,
            ip_address VARCHAR(45),
            INDEX idx_token (token),
            INDEX idx_user (user_id),
            INDEX idx_expires (expires_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;";
        ApiHelper.Execute(sql);
    }

    /// <summary>
    /// Creates a new token for a user. Deactivates any existing tokens for the same user.
    /// </summary>
    public static TokenInfo CreateToken(string userId, string userType, string fullName, string ipAddress)
    {
        EnsureTable();

        // Deactivate old tokens for this user
        ApiHelper.Execute(
            "UPDATE api_tokens SET is_active = 0 WHERE user_id = @uid",
            new MySqlParameter("@uid", userId)
        );

        string token = ApiHelper.GenerateToken();
        DateTime expiresAt = DateTime.Now.AddHours(TOKEN_EXPIRY_HOURS);

        ApiHelper.Execute(
            @"INSERT INTO api_tokens (token, user_id, user_type, full_name, expires_at, ip_address, last_used) 
              VALUES (@token, @uid, @utype, @name, @expires, @ip, NOW())",
            new MySqlParameter("@token", token),
            new MySqlParameter("@uid", userId),
            new MySqlParameter("@utype", userType),
            new MySqlParameter("@name", fullName),
            new MySqlParameter("@expires", expiresAt),
            new MySqlParameter("@ip", ipAddress ?? "")
        );

        return new TokenInfo
        {
            Token = token,
            UserId = userId,
            UserType = userType,
            FullName = fullName,
            ExpiresAt = expiresAt
        };
    }

    /// <summary>
    /// Validates a token and returns its info. Returns null if invalid or expired.
    /// Also updates last_used timestamp.
    /// </summary>
    public static TokenInfo ValidateToken(string token)
    {
        if (string.IsNullOrEmpty(token)) return null;

        EnsureTable();

        DataTable dt = ApiHelper.Query(
            @"SELECT token, user_id, user_type, full_name, expires_at 
              FROM api_tokens 
              WHERE token = @token AND is_active = 1 AND expires_at > NOW()",
            new MySqlParameter("@token", token)
        );

        if (dt.Rows.Count == 0) return null;

        // Update last_used
        ApiHelper.Execute(
            "UPDATE api_tokens SET last_used = NOW() WHERE token = @token",
            new MySqlParameter("@token", token)
        );

        DataRow row = dt.Rows[0];
        return new TokenInfo
        {
            Token = row["token"].ToString(),
            UserId = row["user_id"].ToString(),
            UserType = row["user_type"].ToString(),
            FullName = row["full_name"].ToString(),
            ExpiresAt = Convert.ToDateTime(row["expires_at"])
        };
    }

    /// <summary>
    /// Validates the token from the request. Sends error response if invalid.
    /// Returns null (after ending response) if token is invalid.
    /// </summary>
    public static TokenInfo RequireAuth(HttpRequest request, HttpResponse response)
    {
        string token = request["token"];
        if (string.IsNullOrEmpty(token))
        {
            ApiHelper.Error(response, "Authentication required. Please provide a valid token.", "AUTH_MISSING_TOKEN");
            return null;
        }

        TokenInfo info = ValidateToken(token);
        if (info == null)
        {
            ApiHelper.Error(response, "Token is invalid or expired. Please login again.", "AUTH_INVALID_TOKEN");
            return null;
        }

        return info;
    }

    /// <summary>
    /// Requires auth and checks that user_type matches. Sends error if not.
    /// </summary>
    public static TokenInfo RequireAuthType(HttpRequest request, HttpResponse response, string requiredType)
    {
        TokenInfo info = RequireAuth(request, response);
        if (info != null && info.UserType != requiredType)
        {
            ApiHelper.Error(response, "Access denied. This endpoint requires " + requiredType + " access.", "ACCESS_DENIED");
            return null;
        }
        return info;
    }

    /// <summary>Invalidates (logs out) a token.</summary>
    public static void InvalidateToken(string token)
    {
        if (string.IsNullOrEmpty(token)) return;
        ApiHelper.Execute(
            "UPDATE api_tokens SET is_active = 0 WHERE token = @token",
            new MySqlParameter("@token", token)
        );
    }

    /// <summary>Cleans up expired tokens (call periodically for housekeeping).</summary>
    public static int CleanupExpired()
    {
        return ApiHelper.Execute("DELETE FROM api_tokens WHERE expires_at < NOW() OR is_active = 0");
    }
}

/// <summary>Holds token information returned from validation.</summary>
public class TokenInfo
{
    public string Token { get; set; }
    public string UserId { get; set; }
    public string UserType { get; set; }
    public string FullName { get; set; }
    public DateTime ExpiresAt { get; set; }
}
