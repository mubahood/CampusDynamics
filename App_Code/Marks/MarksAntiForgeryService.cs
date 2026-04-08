using System;
using System.Security.Cryptography;
using System.Web;

/// <summary>
/// MarksAntiForgeryService — CSRF protection for the marks module.
///
/// Generates a cryptographically random token per session and validates it on every
/// mutation (POST) request. Tokens are stored in Session and emitted in a meta tag
/// on each page. JavaScript reads the token and includes it in AJAX requests as
/// either a form field (__csrf) or header (X-CSRF-Token).
///
/// Design: C# 5 compatible (no ?. operator, no string interpolation).
/// Addresses: P68 (no CSRF tokens on marks entry forms)
/// Task: C-03
/// </summary>
public static class MarksAntiForgeryService
{
    private const string SESSION_KEY = "__MarksCSRF";

    // ─────────────────────── Token Generation ───────────────────────────

    /// <summary>
    /// Returns the current CSRF token, creating one if it doesn't exist.
    /// Safe to call from .aspx page expressions: &lt;%= MarksAntiForgeryService.GetToken() %&gt;
    /// </summary>
    public static string GetToken()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Session == null) return "";

        object existing = ctx.Session[SESSION_KEY];
        if (existing != null)
        {
            return existing.ToString();
        }

        // Generate a new cryptographic token
        string token = GenerateToken();
        ctx.Session[SESSION_KEY] = token;
        return token;
    }

    /// <summary>
    /// Validates the CSRF token from the current request.
    /// Checks both X-CSRF-Token header and __csrf form field.
    /// Returns true if valid, false if invalid or missing.
    /// </summary>
    public static bool ValidateRequest()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Session == null) return false;

        object stored = ctx.Session[SESSION_KEY];
        if (stored == null) return false;
        string expected = stored.ToString();

        // Check header first (used by fetch-based pages with JSON body)
        string headerToken = ctx.Request.Headers["X-CSRF-Token"];
        if (!string.IsNullOrEmpty(headerToken))
        {
            return SecureCompare(headerToken, expected);
        }

        // Check form field (used by form-encoded POST pages)
        string formToken = ctx.Request.Form["__csrf"];
        if (!string.IsNullOrEmpty(formToken))
        {
            return SecureCompare(formToken, expected);
        }

        return false;
    }

    /// <summary>
    /// Writes a standard CSRF error JSON response and ends the request.
    /// Use when ValidateRequest() returns false.
    /// </summary>
    public static void RejectRequest(HttpResponse response)
    {
        response.Clear();
        response.ContentType = "application/json";
        response.StatusCode = 403;
        response.Write("{\"error\":\"Security validation failed. Please refresh the page and try again.\"}");
        response.End();
    }

    /// <summary>
    /// Forces generation of a new token, invalidating the previous one.
    /// Call after high-risk operations (e.g., password change) to rotate the token.
    /// </summary>
    public static void RotateToken()
    {
        HttpContext ctx = HttpContext.Current;
        if (ctx == null || ctx.Session == null) return;
        ctx.Session[SESSION_KEY] = GenerateToken();
    }

    // ─────────────────────── Internal Helpers ───────────────────────────

    /// <summary>
    /// Generates a 32-character hex string from 16 random bytes.
    /// Uses RNGCryptoServiceProvider for cryptographic security.
    /// </summary>
    private static string GenerateToken()
    {
        byte[] bytes = new byte[16];
        using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
        {
            rng.GetBytes(bytes);
        }
        return BitConverter.ToString(bytes).Replace("-", "").ToLowerInvariant();
    }

    /// <summary>
    /// Constant-time string comparison to prevent timing attacks.
    /// </summary>
    private static bool SecureCompare(string a, string b)
    {
        if (a == null || b == null) return false;
        if (a.Length != b.Length) return false;

        int diff = 0;
        for (int i = 0; i < a.Length; i++)
        {
            diff |= a[i] ^ b[i];
        }
        return diff == 0;
    }
}
