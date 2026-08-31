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

    // Biggest upload accepted. The stored photo is a 300x400 thumbnail whatever
    // arrives, so this is only a memory guard, not a quality rule — a phone photo
    // is 3-8 MB and used to be refused at 2 MB for no benefit to anyone.
    // (web.config allows 50 MB at the transport layer, so this is the real limit.)
    private const int MaxUploadBytes = 5 * 1024 * 1024;

    // A JPEG's *file* size says nothing about how much memory decoding it needs:
    // a few MB can encode hundreds of megapixels of flat colour, and decoding that
    // would take the app pool down. Real photographs are far below this.
    private const long MaxSourcePixels = 60000000L;   // 60 megapixels

    // Faces at 300x400 end up printed on ID cards; 90 is worth the ~10 KB.
    private const long ThumbJpegQuality = 90L;

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

            if (posted.ContentLength > MaxUploadBytes)
            {
                WriteJson(res, false, "This photo is " + SizeLabel(posted.ContentLength) + ", and the biggest we can take is "
                    + SizeLabel(MaxUploadBytes) + ". Please send a smaller copy of the photo.", null);
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

            /* The file is judged by its CONTENT, not by its name.
               Judging by extension was wrong in both directions: it turned away
               photographs GDI+ reads perfectly well (a camera file with no extension,
               the .jfif that Windows sometimes writes, a canvas blob with no name at
               all), and it waved through anything at all that had been named .jpg.
               Sniffing the first bytes is both safer and more forgiving, and it lets
               us name the exact problem instead of saying "not an image". */
            string why;
            if (!ReadableImage(original, out why))
            {
                WriteJson(res, false, why, null);
                return;
            }

            // Same processing pipeline as the admin uploader: normalise to a 300x400
            // JPEG thumbnail regardless of the uploaded format/size.
            imageManager im = new imageManager();
            byte[] thumb;
            try
            {
                thumb = im.MakeThumb(original, ThumbJpegQuality);
            }
            catch (OutOfMemoryException)
            {
                // GDI+ reports a corrupt or unsupported image as OutOfMemoryException,
                // which is almost never about memory. Say something a student can act on.
                WriteJson(res, false, "This photo file is damaged and could not be opened. Please ask the photo studio for another copy, saved as JPG.", null);
                return;
            }
            catch
            {
                WriteJson(res, false, "This photo could not be opened. Please ask the photo studio for a JPG copy and send that instead.", null);
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

                // Capture the photo being replaced + its status + ban flag.
                string oldPhoto = "";
                string oldStatus = "";
                bool banned = false;
                using (MySqlCommand sel = new MySqlCommand("SELECT COALESCE(photofile,''), COALESCE(photo_status,'APPROVED'), COALESCE(photo_banned,0) FROM acad_student WHERE regno=@r LIMIT 1", conn))
                {
                    sel.Parameters.AddWithValue("@r", regno);
                    using (MySqlDataReader rd = sel.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            oldPhoto = rd.IsDBNull(0) ? "" : rd.GetString(0);
                            oldStatus = rd.IsDBNull(1) ? "" : rd.GetString(1).Trim().ToUpperInvariant();
                            banned = !rd.IsDBNull(2) && rd.GetValue(2).ToString().Trim() == "1";
                        }
                    }
                }

                // Banned students cannot upload until an admin lifts the ban.
                if (banned)
                {
                    WriteJson(res, false, "Your photograph uploads have been suspended after repeated rejections. Please visit the Academic Registrar's / administrator's office to lift the restriction before you can upload again.", null);
                    return;
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

                // Auto-resume: if the photo had been REJECTED, any ID card requests halted awaiting a
                // new photo re-enter the print queue (HALTED -> SUBMITTED). Keeps the student's dashboard
                // alert / photo-gate and the card bureau's queue consistent without manual intervention.
                if (oldStatus == "REJECTED")
                {
                    try
                    {
                        var halted = new System.Collections.Generic.List<int>();
                        using (MySqlCommand sel = new MySqlCommand("SELECT id FROM idcard_requests WHERE regno=@r AND status='HALTED'", conn))
                        {
                            sel.Parameters.AddWithValue("@r", regno);
                            using (MySqlDataReader rd = sel.ExecuteReader())
                                while (rd.Read()) halted.Add(rd.GetInt32(0));
                        }
                        foreach (int rid in halted)
                        {
                            using (MySqlCommand up = new MySqlCommand("UPDATE idcard_requests SET status='SUBMITTED', halt_reason=NULL, updated_at=NOW() WHERE id=@id AND status='HALTED'", conn))
                            { up.Parameters.AddWithValue("@id", rid); up.ExecuteNonQuery(); }
                            using (MySqlCommand ev = new MySqlCommand(
                                "INSERT INTO idcard_request_events (request_id, from_status, to_status, actor, actor_role, channel, note, created_at) " +
                                "VALUES (@id,'HALTED','SUBMITTED','system','system','eportal','Auto-resubmitted after the student updated their photograph', NOW())", conn))
                            { ev.Parameters.AddWithValue("@id", rid); ev.ExecuteNonQuery(); }
                        }
                    }
                    catch { /* non-critical — photo update already succeeded */ }
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

    // -------- what kind of file is this, really? --------
    //
    // Every rejection below has to hand the student a reason they can act on.
    // "Only image files are allowed" is useless to someone holding a photograph
    // their phone is happy to display; "this is an iPhone HEIC photo, here is the
    // setting to change" is not.

    private enum PicKind { Unknown, Jpeg, Png, Gif, Bmp, Tiff, Heic, Avif, Webp }

    /// <summary>
    /// Decides whether GDI+ will be able to open this file, and if not, sets
    /// <paramref name="why"/> to a plain-English reason naming the actual problem.
    /// Also refuses images whose pixel count would exhaust memory when decoded.
    /// </summary>
    private static bool ReadableImage(byte[] b, out string why)
    {
        why = "";
        PicKind kind = Sniff(b);

        switch (kind)
        {
            case PicKind.Heic:
                // Windows Server 2019 has no HEIF codec, so GDI+ cannot open these at all.
                why = "This photo is saved in the HEIC format, which our system cannot open. "
                    + "iPhones save photos this way. On your iPhone go to Settings, then Camera, then Formats, "
                    + "and choose \"Most Compatible\". Take the photo again and send it. "
                    + "Any photo studio can also give you a JPG copy.";
                return false;

            case PicKind.Avif:
                why = "This photo is saved in the AVIF format, which our system cannot open. "
                    + "Some newer Android phones save photos this way. In your camera settings, "
                    + "look for the photo format and choose JPG, then take the photo again. "
                    + "Any photo studio can also give you a JPG copy.";
                return false;

            case PicKind.Webp:
                why = "This picture is in the WEBP format, which our system cannot open. "
                    + "This usually happens when a picture is saved from a website. "
                    + "Please send a real photograph saved as JPG.";
                return false;

            case PicKind.Unknown:
                why = "This file is not a photograph. Please choose a picture from your phone or computer.";
                return false;
        }

        int w, h;
        if (TryReadSize(b, kind, out w, out h) && w > 0 && h > 0)
        {
            long pixels = (long)w * (long)h;
            if (pixels > MaxSourcePixels)
            {
                why = "This picture is " + w + " by " + h + " and is too big for our system to open. "
                    + "Please send a normal photograph taken with a phone or camera.";
                return false;
            }
        }

        return true;
    }

    /// <summary>Identifies the format from its leading bytes (the "magic number").</summary>
    private static PicKind Sniff(byte[] b)
    {
        if (b == null || b.Length < 12) return PicKind.Unknown;

        if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return PicKind.Jpeg;

        if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47 &&
            b[4] == 0x0D && b[5] == 0x0A && b[6] == 0x1A && b[7] == 0x0A) return PicKind.Png;

        if (b[0] == 'G' && b[1] == 'I' && b[2] == 'F' && b[3] == '8') return PicKind.Gif;

        if (b[0] == 'B' && b[1] == 'M') return PicKind.Bmp;

        if ((b[0] == 0x49 && b[1] == 0x49 && b[2] == 0x2A && b[3] == 0x00) ||
            (b[0] == 0x4D && b[1] == 0x4D && b[2] == 0x00 && b[3] == 0x2A)) return PicKind.Tiff;

        if (b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F' &&
            b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P') return PicKind.Webp;

        // ISO base media container: [size:4]["ftyp"][brand:4]. Covers HEIC/HEIF from
        // iPhones and AVIF from newer Android phones — none of which GDI+ can read.
        if (b[4] == 'f' && b[5] == 't' && b[6] == 'y' && b[7] == 'p')
        {
            string brand = new string(new char[] { (char)b[8], (char)b[9], (char)b[10], (char)b[11] }).ToLowerInvariant();
            switch (brand)
            {
                case "heic": case "heix": case "heim": case "heis":
                case "hevc": case "hevx": case "mif1": case "msf1":
                    return PicKind.Heic;
                case "avif": case "avis":
                    return PicKind.Avif;
            }
        }

        return PicKind.Unknown;
    }

    /// <summary>
    /// Reads the pixel dimensions straight out of the file header, WITHOUT decoding.
    /// This has to happen before GDI+ touches the file: Image.FromStream allocates the
    /// full decoded bitmap, so by the time a Width property could be read the memory
    /// has already been taken. Returns false for formats not worth parsing.
    /// </summary>
    private static bool TryReadSize(byte[] b, PicKind kind, out int w, out int h)
    {
        w = 0; h = 0;
        try
        {
            switch (kind)
            {
                case PicKind.Png:
                    // IHDR is always the first chunk: width and height are big-endian at 16 and 20.
                    if (b.Length < 24) return false;
                    w = BE32(b, 16); h = BE32(b, 20);
                    return true;

                case PicKind.Gif:
                    if (b.Length < 10) return false;
                    w = b[6] | (b[7] << 8); h = b[8] | (b[9] << 8);
                    return true;

                case PicKind.Bmp:
                    if (b.Length < 26) return false;
                    w = LE32(b, 18); h = Math.Abs(LE32(b, 22));   // height is negative for top-down bitmaps
                    return true;

                case PicKind.Jpeg:
                    return TryReadJpegSize(b, out w, out h);
            }
        }
        catch { /* malformed header — let GDI+ be the judge */ }
        return false;
    }

    /// <summary>
    /// Walks the JPEG marker segments to the start-of-frame, which carries the real
    /// dimensions. Everything before it (EXIF, thumbnails, colour profiles) is skipped
    /// by its declared length.
    /// </summary>
    private static bool TryReadJpegSize(byte[] b, out int w, out int h)
    {
        w = 0; h = 0;
        int i = 2;                                   // past SOI (FF D8)
        while (i + 3 < b.Length)
        {
            if (b[i] != 0xFF) { i++; continue; }      // resynchronise on padding
            int marker = b[i + 1];
            if (marker == 0xFF) { i++; continue; }    // fill byte
            if (marker == 0xD8 || marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) { i += 2; continue; }
            if (marker == 0xD9 || marker == 0xDA) return false;   // end of image / start of scan

            int segLen = (b[i + 2] << 8) | b[i + 3];
            if (segLen < 2) return false;

            // SOF0-SOF15 carry the frame size. C4 = Huffman tables, C8 = extension,
            // CC = arithmetic coding tables — those share the range but are not frames.
            bool isFrame = marker >= 0xC0 && marker <= 0xCF
                           && marker != 0xC4 && marker != 0xC8 && marker != 0xCC;
            if (isFrame)
            {
                if (i + 9 >= b.Length) return false;
                h = (b[i + 5] << 8) | b[i + 6];
                w = (b[i + 7] << 8) | b[i + 8];
                return true;
            }
            i += 2 + segLen;
        }
        return false;
    }

    private static int BE32(byte[] b, int o) { return (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3]; }
    private static int LE32(byte[] b, int o) { return b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24); }

    private static string SizeLabel(long bytes)
    {
        if (bytes >= 1048576) return (bytes / 1048576.0).ToString("0.#", CultureInfo.InvariantCulture) + " MB";
        return Math.Max(1, (int)Math.Round(bytes / 1024.0)).ToString(CultureInfo.InvariantCulture) + " KB";
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
