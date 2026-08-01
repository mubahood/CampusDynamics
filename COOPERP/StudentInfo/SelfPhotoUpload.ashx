<%@ WebHandler Language="C#" Class="SelfPhotoUpload" %>

// ---------------------------------------------------------------------------
//  SelfPhotoUpload.ashx  (main app / eadmin)
//
//  Canonical student self-service profile-photo endpoint.
//
//  Storage is IDENTICAL to NewStudentInfo.aspx.cs (the eadmin admin uploader):
//     imageManager.MakeThumb()  ->  {guid}.jpg
//     saved to  ~/COOPERP/StudentInfo/photos/
//     filename stored in  acad_student.photofile
//     served from https://eadmin.mru.ac.ug/COOPERP/StudentInfo/photos/{file}
//
//  The eportal (a SEPARATE app on eportal.mru.ac.ug) cannot MapPath to this
//  app's disk, so the student's browser POSTs the image here directly. The
//  request is authorised by a short-lived HMAC token that the eportal issues,
//  bound to the student's regno, so a user can only replace their OWN photo.
//  No cookies/credentials are used -> a plain CORS request is sufficient.
// ---------------------------------------------------------------------------

using System;
using System.IO;
using System.Text;
using System.Web;
using System.Configuration;
using System.Globalization;
using System.Security.Cryptography;
using MySql.Data.MySqlClient;

public class SelfPhotoUpload : IHttpHandler
{
    // Shared with the eportal token issuer. Overridable via web.config appSetting
    // "StudentPhoto.UploadSecret" (must match on both apps). Kept as a constant so
    // the feature works out-of-the-box without a config change.
    private const string DefaultSecret = "MRU-StudentPhoto-2026-c7f3a9e1b284d6f05a1e9c3b7d24f8a6";

    public void ProcessRequest(HttpContext ctx)
    {
        HttpResponse res = ctx.Response;
        HttpRequest req = ctx.Request;

        string origin = req.Headers["Origin"];
        res.AppendHeader("Access-Control-Allow-Origin", string.IsNullOrEmpty(origin) ? "*" : origin);
        res.AppendHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
        res.AppendHeader("Access-Control-Allow-Headers", "Content-Type");
        res.AppendHeader("Cache-Control", "no-store");
        res.ContentType = "application/json";

        if (string.Equals(req.HttpMethod, "OPTIONS", StringComparison.OrdinalIgnoreCase))
        {
            res.StatusCode = 200;
            return;
        }

        try
        {
            if (!string.Equals(req.HttpMethod, "POST", StringComparison.OrdinalIgnoreCase))
            {
                WriteJson(res, false, "Invalid request method.", null);
                return;
            }

            string token = req.Form["token"];
            if (string.IsNullOrEmpty(token)) token = req.QueryString["token"];

            string regno;
            string tokenError;
            if (!ValidateToken(token, out regno, out tokenError))
            {
                WriteJson(res, false, "Authorisation failed: " + tokenError, null);
                return;
            }

            HttpPostedFile posted = req.Files["photoFile"];
            if (posted == null || posted.ContentLength <= 0)
            {
                WriteJson(res, false, "Please select a photo to upload.", null);
                return;
            }

            string ext = Path.GetExtension(posted.FileName == null ? "" : posted.FileName).ToLowerInvariant();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".bmp" && ext != ".gif")
            {
                WriteJson(res, false, "Only image files are allowed (jpg, jpeg, png, bmp, gif).", null);
                return;
            }

            if (posted.ContentLength > 2 * 1024 * 1024)
            {
                WriteJson(res, false, "Image is too large. Maximum size is 2 MB.", null);
                return;
            }

            byte[] original;
            using (Stream input = posted.InputStream)
            {
                int len = Convert.ToInt32(input.Length);
                original = new byte[len];
                int off = 0;
                int read;
                while (off < len && (read = input.Read(original, off, len - off)) > 0) off += read;
            }

            // Same processing pipeline as the admin uploader: normalise to a 300x400
            // JPEG thumbnail regardless of the uploaded format/size.
            imageManager im = new imageManager();
            byte[] thumb;
            try
            {
                thumb = im.MakeThumb(original);
            }
            catch
            {
                WriteJson(res, false, "That file could not be read as an image. Please upload a valid JPG or PNG photo.", null);
                return;
            }

            string fileName = Guid.NewGuid().ToString("N") + ".jpg";
            string photosFolder = ctx.Server.MapPath("~/COOPERP/StudentInfo/photos/");
            if (!Directory.Exists(photosFolder)) Directory.CreateDirectory(photosFolder);
            File.WriteAllBytes(Path.Combine(photosFolder, fileName), thumb);

            int rows;
            using (MySqlConnection conn = new MySqlConnection(ConnStr()))
            {
                conn.Open();

                // Capture the photo being replaced, for the change-tracking record.
                string oldPhoto = "";
                using (MySqlCommand sel = new MySqlCommand("SELECT COALESCE(photofile,'') FROM acad_student WHERE regno=@r LIMIT 1", conn))
                {
                    sel.Parameters.AddWithValue("@r", regno);
                    object o = sel.ExecuteScalar();
                    oldPhoto = o == null || o == DBNull.Value ? "" : o.ToString();
                }

                // The new photo goes live but PENDING admin approval (photo change tracker).
                using (MySqlCommand cmd = new MySqlCommand("UPDATE acad_student SET photofile = @photofile, photo_status = 'PENDING' WHERE regno = @regno", conn))
                {
                    cmd.Parameters.AddWithValue("@photofile", fileName);
                    cmd.Parameters.AddWithValue("@regno", regno);
                    rows = cmd.ExecuteNonQuery();
                }

                if (rows > 0)
                {
                    // One record per change — admin approves/rejects it in eadmin.
                    using (MySqlCommand ins = new MySqlCommand(
                        "INSERT INTO stud_photo_change (regno, old_photofile, new_photofile, status, source, requested_at) " +
                        "VALUES (@r, @o, @n, 'PENDING', 'eportal-self', NOW())", conn))
                    {
                        ins.Parameters.AddWithValue("@r", regno);
                        ins.Parameters.AddWithValue("@o", oldPhoto);
                        ins.Parameters.AddWithValue("@n", fileName);
                        ins.ExecuteNonQuery();
                    }
                }
            }

            if (rows <= 0)
            {
                WriteJson(res, false, "Student record not found. Photo was not updated.", null);
                return;
            }

            string photoUrl = "https://eadmin.mru.ac.ug/COOPERP/StudentInfo/photos/" + fileName;
            WriteJson(res, true, "Photo uploaded. It is now pending administrator approval.", photoUrl);
        }
        catch (Exception ex)
        {
            WriteJson(res, false, "Error updating photo: " + ex.Message, null);
        }
    }

    // -------- token (HMAC-SHA256 over "regno.expiryUnix") --------

    private static bool ValidateToken(string token, out string regno, out string error)
    {
        regno = "";
        error = "";
        if (string.IsNullOrEmpty(token)) { error = "missing token"; return false; }

        string[] parts = token.Split('.');
        if (parts.Length != 3) { error = "malformed token"; return false; }

        string r = parts[0];
        string expStr = parts[1];
        string sig = parts[2];

        if (string.IsNullOrEmpty(r)) { error = "missing subject"; return false; }

        long exp;
        if (!long.TryParse(expStr, NumberStyles.Integer, CultureInfo.InvariantCulture, out exp))
        {
            error = "bad expiry";
            return false;
        }

        long now = (long)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalSeconds;
        if (now > exp) { error = "the upload session expired, please reload the page and try again"; return false; }

        string expected = Sign(r + "." + expStr);
        if (!ConstEquals(expected, sig)) { error = "invalid signature"; return false; }

        regno = r;
        return true;
    }

    private static string Sign(string data)
    {
        string secret = ConfigurationManager.AppSettings["StudentPhoto.UploadSecret"];
        if (string.IsNullOrEmpty(secret)) secret = DefaultSecret;
        using (HMACSHA256 h = new HMACSHA256(Encoding.UTF8.GetBytes(secret)))
        {
            return ToHex(h.ComputeHash(Encoding.UTF8.GetBytes(data)));
        }
    }

    private static string ToHex(byte[] bytes)
    {
        StringBuilder sb = new StringBuilder(bytes.Length * 2);
        for (int i = 0; i < bytes.Length; i++) sb.Append(bytes[i].ToString("x2", CultureInfo.InvariantCulture));
        return sb.ToString();
    }

    private static bool ConstEquals(string a, string b)
    {
        if (a == null || b == null) return false;
        if (a.Length != b.Length) return false;
        int diff = 0;
        for (int i = 0; i < a.Length; i++) diff |= a[i] ^ b[i];
        return diff == 0;
    }

    private static string ConnStr()
    {
        var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
        if (cs != null && !string.IsNullOrEmpty(cs.ConnectionString)) return cs.ConnectionString;
        return "server=localhost;User Id=root;password=24thdecember1977;Persist Security Info=True;database=campus_dynamics;charset=utf8";
    }

    private static void WriteJson(HttpResponse res, bool success, string message, string photoUrl)
    {
        StringBuilder sb = new StringBuilder();
        sb.Append("{\"success\":").Append(success ? "true" : "false");
        sb.Append(",\"message\":\"").Append(JsonEsc(message)).Append("\"");
        if (photoUrl != null) sb.Append(",\"photoUrl\":\"").Append(JsonEsc(photoUrl)).Append("\"");
        sb.Append("}");
        res.Write(sb.ToString());
    }

    private static string JsonEsc(string s)
    {
        if (string.IsNullOrEmpty(s)) return "";
        StringBuilder sb = new StringBuilder(s.Length + 8);
        foreach (char c in s)
        {
            switch (c)
            {
                case '\\': sb.Append("\\\\"); break;
                case '"': sb.Append("\\\""); break;
                case '\r': break;
                case '\n': sb.Append(' '); break;
                case '\t': sb.Append(' '); break;
                default: sb.Append(c); break;
            }
        }
        return sb.ToString();
    }

    public bool IsReusable { get { return false; } }
}
