using System;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using MySql.Data.MySqlClient;

/// <summary>
/// Changing and resetting a password, for the v2 API.
///
/// Until now the API could authenticate a student but never let one change their password, and
/// had no account recovery at all — an app built on it could sign a student in and then strand
/// them. Applicants (the `apply` module) have had all three since May; students had none.
///
/// WHERE THE CREDENTIALS LIVE. ASP.NET membership, split across two databases: students in
/// campus_dynamics_portal.my_aspnet_*, staff in campus_dynamics.my_aspnet_*. The hash is
/// HMACSHA256 over (salt bytes ++ UTF-16 password bytes), keyed by the same salt, base64 —
/// which is what the login path already computes, so this reads and writes exactly what
/// Membership itself does. Changing that algorithm here would lock everyone out of the web
/// portal, so it is deliberately identical and deliberately not "improved".
///
/// The reset PIN is stored in api_password_resets rather than in the membership tables, so a
/// pending reset can never be mistaken for a credential.
/// </summary>
public static class PasswordService
{
    private const int MIN_LENGTH = 6;
    private const string DEFAULT_PORTAL_PASSWORD = "123";   // the factory password students are issued
    private const int PIN_MINUTES = 30;
    private const int MAX_PIN_ATTEMPTS = 5;

    // ─────────────────────────────────────────────────────────────────
    //  Schema for the reset PINs — created on demand so there is no
    //  deployment step to forget.
    // ─────────────────────────────────────────────────────────────────
    public static void EnsureSchema()
    {
        try
        {
            ApiHelper.Execute(
                "CREATE TABLE IF NOT EXISTS api_password_resets (" +
                "  id INT UNSIGNED NOT NULL AUTO_INCREMENT," +
                "  username VARCHAR(100) NOT NULL," +
                "  user_type VARCHAR(12) NOT NULL," +
                "  pin_hash VARCHAR(120) NOT NULL," +
                "  sent_to VARCHAR(160) NULL," +
                "  channel VARCHAR(12) NOT NULL DEFAULT 'email'," +
                "  attempts INT NOT NULL DEFAULT 0," +
                "  used TINYINT(1) NOT NULL DEFAULT 0," +
                "  ip_address VARCHAR(45) NULL," +
                "  created_at DATETIME NOT NULL," +
                "  expires_at DATETIME NOT NULL," +
                "  PRIMARY KEY (id), KEY ix_user (username, used), KEY ix_exp (expires_at)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8");
        }
        catch { }
    }

    // ─────────────────────────────────────────────────────────────────
    //  Change — the caller already proved who they are with a token, and
    //  must also prove they know the current password.
    // ─────────────────────────────────────────────────────────────────
    public static bool ChangePassword(string username, string userType, string current, string next, out string message)
    {
        message = "";
        username = (username ?? "").Trim();
        if (username == "") { message = "No account on this token."; return false; }

        if (!Acceptable(next, out message)) return false;
        if (string.Equals(current, next, StringComparison.Ordinal))
        { message = "The new password is the same as the current one."; return false; }

        bool portalFirst = string.Equals(userType, "student", StringComparison.OrdinalIgnoreCase);
        bool portal;
        if (!Verify(username, current, portalFirst, out portal))
        { message = "The current password is not correct."; return false; }

        if (!Write(username, next, portal))
        { message = "The password could not be updated. Please try again."; return false; }

        message = "Password changed.";
        return true;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Forgot — issue a PIN. The answer is deliberately the same whether
    //  or not the account exists: this endpoint must not become a way to
    //  find out which registration numbers are real.
    // ─────────────────────────────────────────────────────────────────
    public static bool StartReset(string identifier, string ip, out string message, out string maskedTarget, out string debugPin)
    {
        EnsureSchema();
        message = "If that account exists, a reset code has been sent to the address on record.";
        maskedTarget = "";
        debugPin = null;

        identifier = (identifier ?? "").Trim();
        if (identifier == "") { message = "Give the registration number, student number or email."; return false; }

        string username, userType, email;
        if (!Resolve(identifier, out username, out userType, out email))
            return true;                       // same answer as success, on purpose

        if (string.IsNullOrEmpty(email) || email.IndexOf('@') < 0)
        {
            // Nothing to send to. Still the same outward answer; the student must come in person.
            return true;
        }

        string pin = NewPin();
        try
        {
            ApiHelper.Execute(
                "UPDATE api_password_resets SET used=1 WHERE username=@u AND used=0",
                new MySqlParameter("@u", username));
            ApiHelper.Execute(
                "INSERT INTO api_password_resets (username,user_type,pin_hash,sent_to,channel,ip_address,created_at,expires_at) " +
                "VALUES (@u,@t,@p,@s,'email',@ip,NOW(),DATE_ADD(NOW(), INTERVAL " + PIN_MINUTES + " MINUTE))",
                new MySqlParameter("@u", username), new MySqlParameter("@t", userType),
                new MySqlParameter("@p", HashPin(username, pin)), new MySqlParameter("@s", email),
                new MySqlParameter("@ip", (object)ip ?? DBNull.Value));
        }
        catch (Exception ex) { message = "The reset could not be started: " + ex.Message; return false; }

        maskedTarget = MaskEmail(email);
        bool sent = SendPin(email, pin);
        if (!sent) debugPin = null;            // never leak the PIN when sending failed
        return true;
    }

    // ─────────────────────────────────────────────────────────────────
    //  Reset — consume the PIN.
    // ─────────────────────────────────────────────────────────────────
    public static bool CompleteReset(string identifier, string pin, string next, out string message)
    {
        EnsureSchema();
        message = "";
        if (!Acceptable(next, out message)) return false;

        string username, userType, email;
        if (!Resolve((identifier ?? "").Trim(), out username, out userType, out email))
        { message = "That reset code is not valid."; return false; }

        DataTable dt = ApiHelper.Query(
            "SELECT id, pin_hash, attempts FROM api_password_resets " +
            "WHERE username=@u AND used=0 AND expires_at > NOW() ORDER BY id DESC LIMIT 1",
            new MySqlParameter("@u", username));

        if (dt.Rows.Count == 0)
        { message = "That reset code has expired. Ask for a new one."; return false; }

        int id = Convert.ToInt32(dt.Rows[0]["id"]);
        int attempts = Convert.ToInt32(dt.Rows[0]["attempts"]);
        if (attempts >= MAX_PIN_ATTEMPTS)
        {
            ApiHelper.Execute("UPDATE api_password_resets SET used=1 WHERE id=@i", new MySqlParameter("@i", id));
            message = "Too many attempts on that code. Ask for a new one.";
            return false;
        }

        string stored = Convert.ToString(dt.Rows[0]["pin_hash"]);
        if (!string.Equals(stored, HashPin(username, (pin ?? "").Trim()), StringComparison.Ordinal))
        {
            ApiHelper.Execute("UPDATE api_password_resets SET attempts=attempts+1 WHERE id=@i", new MySqlParameter("@i", id));
            message = "That reset code is not correct.";
            return false;
        }

        bool portal = string.Equals(userType, "student", StringComparison.OrdinalIgnoreCase);
        if (!Exists(username, portal)) portal = !portal;      // whichever database actually holds them
        if (!Write(username, next, portal))
        { message = "The password could not be updated. Please try again."; return false; }

        ApiHelper.Execute("UPDATE api_password_resets SET used=1 WHERE id=@i", new MySqlParameter("@i", id));
        message = "Password reset. You can sign in with the new password.";
        return true;
    }

    /// <summary>True when the password still is the factory default — the portal forces a change
    /// on sign-in in that case, and an app needs to know so it can do the same.</summary>
    public static bool IsFactoryDefault(string username, string userType)
    {
        bool portal;
        return Verify(username, DEFAULT_PORTAL_PASSWORD,
                      string.Equals(userType, "student", StringComparison.OrdinalIgnoreCase), out portal);
    }

    // ─────────────────────────────────────────────────────────────────
    //  internals
    // ─────────────────────────────────────────────────────────────────

    private static bool Acceptable(string p, out string message)
    {
        message = "";
        if (string.IsNullOrEmpty(p)) { message = "Give a new password."; return false; }
        // The factory password is checked BEFORE the length rule. It is shorter than the minimum,
        // so testing length first left this branch unreachable and told a student retyping "123"
        // that it was too short — true, but not the reason that matters.
        if (p == DEFAULT_PORTAL_PASSWORD)
        { message = "That is the factory password everyone is issued. Choose a different one."; return false; }
        if (p.Trim() == "") { message = "A password of spaces is not a password."; return false; }
        if (p.Length < MIN_LENGTH) { message = "The new password must be at least " + MIN_LENGTH + " characters."; return false; }
        return true;
    }

    private static bool Exists(string username, bool portal)
    {
        try
        {
            object v = ApiHelper.Scalar(
                "SELECT COUNT(*) FROM " + Db(portal) + ".my_aspnet_users u " +
                "JOIN " + Db(portal) + ".my_aspnet_membership m ON m.userId=u.id WHERE TRIM(u.name)=@u",
                new MySqlParameter("@u", username));
            return v != null && Convert.ToInt32(v) > 0;
        }
        catch { return false; }
    }

    private static string Db(bool portal) { return portal ? "campus_dynamics_portal" : "campus_dynamics"; }

    /// <summary>Checks the password in one database and then the other, reporting which one
    /// actually held the account so the write goes to the same place.</summary>
    private static bool Verify(string username, string password, bool portalFirst, out bool portal)
    {
        portal = portalFirst;
        if (Check(username, password, portalFirst)) return true;
        if (Check(username, password, !portalFirst)) { portal = !portalFirst; return true; }
        return false;
    }

    private static bool Check(string username, string password, bool portal)
    {
        try
        {
            DataTable dt = ApiHelper.Query(
                "SELECT m.password, m.passwordKey FROM " + Db(portal) + ".my_aspnet_membership m " +
                "INNER JOIN " + Db(portal) + ".my_aspnet_users u ON m.userId = u.id " +
                "WHERE TRIM(u.name) = @u AND (m.IsLockedOut = 0 OR m.IsLockedOut IS NULL) LIMIT 1",
                new MySqlParameter("@u", username));
            if (dt.Rows.Count == 0) return false;
            string storedHash = Convert.ToString(dt.Rows[0]["password"]);
            string salt = Convert.ToString(dt.Rows[0]["passwordKey"]);
            return string.Equals(storedHash, Hash(password, salt), StringComparison.Ordinal);
        }
        catch { return false; }
    }

    private static bool Write(string username, string password, bool portal)
    {
        try
        {
            DataTable dt = ApiHelper.Query(
                "SELECT m.userId, m.passwordKey FROM " + Db(portal) + ".my_aspnet_membership m " +
                "INNER JOIN " + Db(portal) + ".my_aspnet_users u ON m.userId = u.id " +
                "WHERE TRIM(u.name) = @u LIMIT 1", new MySqlParameter("@u", username));
            if (dt.Rows.Count == 0) return false;

            // Keep the existing salt: Membership stores it alongside the hash and re-deriving a
            // new one is unnecessary risk for no gain.
            string salt = Convert.ToString(dt.Rows[0]["passwordKey"]);
            int userId = Convert.ToInt32(dt.Rows[0]["userId"]);

            int n = ApiHelper.Execute(
                "UPDATE " + Db(portal) + ".my_aspnet_membership " +
                "SET password=@p, LastPasswordChangedDate=NOW(), FailedPasswordAttemptCount=0 WHERE userId=@id",
                new MySqlParameter("@p", Hash(password, salt)), new MySqlParameter("@id", userId));
            return n > 0;
        }
        catch { return false; }
    }

    /// <summary>The membership hash: HMACSHA256 over (salt ++ UTF-16 password), keyed by the
    /// salt, base64. Identical to the login path — changing it would lock out the web portal.</summary>
    private static string Hash(string password, string base64Salt)
    {
        byte[] saltBytes = Convert.FromBase64String(base64Salt);
        byte[] passwordBytes = Encoding.Unicode.GetBytes(password ?? "");
        byte[] combined = new byte[saltBytes.Length + passwordBytes.Length];
        Buffer.BlockCopy(saltBytes, 0, combined, 0, saltBytes.Length);
        Buffer.BlockCopy(passwordBytes, 0, combined, saltBytes.Length, passwordBytes.Length);
        using (HMACSHA256 hmac = new HMACSHA256(saltBytes))
            return Convert.ToBase64String(hmac.ComputeHash(combined));
    }

    /// <summary>Resolves a registration number, student number, email or staff username to the
    /// membership username, its type, and the address a code can be sent to.</summary>
    private static bool Resolve(string input, out string username, out string userType, out string email)
    {
        username = null; userType = null; email = "";
        if (string.IsNullOrEmpty(input)) return false;

        try
        {
            DataTable dt = ApiHelper.Query(
                "SELECT TRIM(regno) AS u, IFNULL(email,'') AS e FROM acad_student " +
                "WHERE TRIM(regno)=@i OR TRIM(entryno)=@i OR (IFNULL(email,'')<>'' AND TRIM(email)=@i) LIMIT 1",
                new MySqlParameter("@i", input));
            if (dt.Rows.Count > 0)
            {
                username = Convert.ToString(dt.Rows[0]["u"]).Trim();
                email = Convert.ToString(dt.Rows[0]["e"]).Trim();
                userType = "student";
                return true;
            }

            dt = ApiHelper.Query(
                "SELECT TRIM(usernames) AS u, IFNULL(emp_email,'') AS e FROM hrm_employee " +
                "WHERE TRIM(usernames)=@i OR (IFNULL(emp_email,'')<>'' AND TRIM(emp_email)=@i) LIMIT 1",
                new MySqlParameter("@i", input));
            if (dt.Rows.Count > 0)
            {
                username = Convert.ToString(dt.Rows[0]["u"]).Trim();
                email = Convert.ToString(dt.Rows[0]["e"]).Trim();
                userType = "staff";
                return true;
            }
        }
        catch { }
        return false;
    }

    private static string NewPin()
    {
        byte[] b = new byte[4];
        using (var rng = new RNGCryptoServiceProvider()) rng.GetBytes(b);
        int v = Math.Abs(BitConverter.ToInt32(b, 0)) % 1000000;
        return v.ToString("000000");
    }

    /// <summary>The PIN is stored hashed and bound to the username, so a leaked table row is not
    /// a working code and a code for one account cannot be replayed against another.</summary>
    private static string HashPin(string username, string pin)
    {
        using (SHA256 sha = SHA256.Create())
        {
            byte[] h = sha.ComputeHash(Encoding.UTF8.GetBytes("mru-pwreset|" + username + "|" + pin));
            return Convert.ToBase64String(h);
        }
    }

    private static string MaskEmail(string e)
    {
        if (string.IsNullOrEmpty(e)) return "";
        int at = e.IndexOf('@');
        if (at <= 0) return "***";
        string user = e.Substring(0, at), dom = e.Substring(at);
        if (user.Length <= 2) return user.Substring(0, 1) + "***" + dom;
        return user.Substring(0, 2) + new string('*', Math.Max(3, user.Length - 2)) + dom;
    }

    private static bool SendPin(string email, string pin)
    {
        try
        {
            string body =
                "<p>Your Muteesa I Royal University password reset code is:</p>" +
                "<p style='font-size:24px;font-weight:bold;letter-spacing:4px;'>" + pin + "</p>" +
                "<p>It expires in " + PIN_MINUTES + " minutes. If you did not ask for it, ignore this message — " +
                "your password has not changed.</p>";
            // eadmin's signature is (message, recipients, subject, senderName) and it returns a
            // status string, not a bool — the portal's copy differs, which is why this is spelled
            // out rather than assumed.
            string result = EmailSenderProtocol.SendHtmlEmail(body, email, "Password reset code", "Muteesa I Royal University");
            return result != null && result.IndexOf("error", StringComparison.OrdinalIgnoreCase) < 0
                                  && result.IndexOf("fail", StringComparison.OrdinalIgnoreCase) < 0;
        }
        catch { return false; }
    }
}
