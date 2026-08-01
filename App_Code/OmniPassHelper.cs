using System;
using System.Configuration;
using System.Net;
using System.Text;
using MySql.Data.MySqlClient;

/// <summary>
/// Centralised helper for the OmniPass Student Card API.
///   • Checks a single student's card-printing status via the external API.
///   • Caches the result in acad_student.id_card_status / id_card_checked_at.
///   • Supports a configurable stale-window (default 6 h) — callers decide
///     whether to use the cached value or force a live refresh.
///
/// OmniPass API docs:
///   GET https://omnipass.mru.ac.ug/api/external/student-cards/{mru_number}
///   Header: X-Access-Key
///   Response: { response_info:{code,message}, data:{card_printed:bool} }
///
/// DB columns (added by migration):
///   acad_student.id_card_status   VARCHAR(30)  — 'PRINTED','NOT_PRINTED','NOT_FOUND','ERROR','UNKNOWN'
///   acad_student.id_card_checked_at DATETIME   — last successful check
/// </summary>
public static class OmniPassHelper
{
    // ── Configuration ──────────────────────────────────────────────────
    private static readonly string ApiBaseUrl =
        ConfigurationManager.AppSettings["OmniPass_BaseUrl"]
        ?? "https://omnipass.mru.ac.ug/api/external/student-cards";

    private static readonly string AccessKey =
        ConfigurationManager.AppSettings["OmniPass_AccessKey"]
        ?? "24233eaa-26fc-4a67-8183-9b04e5736c5a";

    /// <summary>Hours before a cached status is considered stale.</summary>
    public static int StaleHours
    {
        get
        {
            string v = ConfigurationManager.AppSettings["OmniPass_StaleHours"];
            int h;
            if (!string.IsNullOrEmpty(v) && int.TryParse(v, out h) && h > 0) return h;
            return 6;
        }
    }

    // ── Schema auto-migration ───────────────────────────────────────
    private static bool _schemaReady = false;
    private static readonly object _schemaLock = new object();

    /// <summary>Ensures the id_card_status / id_card_checked_at columns exist. Runs once per app lifetime.</summary>
    private static void EnsureSchema(MySqlConnection conn)
    {
        if (_schemaReady) return;
        lock (_schemaLock)
        {
            if (_schemaReady) return;
            try
            {
                bool opened = false;
                if (conn.State != System.Data.ConnectionState.Open) { conn.Open(); opened = true; }
                try
                {
                    bool exists = false;
                    using (MySqlCommand chk = new MySqlCommand(
                        "SELECT COUNT(*) FROM information_schema.COLUMNS " +
                        "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='acad_student' AND COLUMN_NAME='id_card_status'", conn))
                    {
                        exists = Convert.ToInt32(chk.ExecuteScalar()) > 0;
                    }
                    if (!exists)
                    {
                        using (MySqlCommand alt = new MySqlCommand(
                            "ALTER TABLE acad_student " +
                            "ADD COLUMN id_card_status VARCHAR(30) DEFAULT NULL, " +
                            "ADD COLUMN id_card_checked_at DATETIME DEFAULT NULL", conn))
                        {
                            alt.ExecuteNonQuery();
                        }
                        try
                        {
                            using (MySqlCommand idx = new MySqlCommand(
                                "CREATE INDEX idx_student_card_status ON acad_student (id_card_status)", conn))
                            { idx.ExecuteNonQuery(); }
                        }
                        catch { }
                    }
                }
                finally { if (opened) conn.Close(); }
                _schemaReady = true;
            }
            catch { /* let downstream queries surface real errors */ }
        }
    }

    // ── Public methods ─────────────────────────────────────────────────

    /// <summary>
    /// Get the card status for a single student.
    /// Returns the cached value if it is younger than <paramref name="maxAgeHours"/>,
    /// otherwise calls the OmniPass API and persists the result.
    /// Set <paramref name="forceRefresh"/> = true to always call the API.
    /// </summary>
    public static CardStatus GetStatus(string regno, MySqlConnection acadConn, bool forceRefresh)
    {
        return GetStatus(regno, acadConn, forceRefresh, StaleHours);
    }

    public static CardStatus GetStatus(string regno, MySqlConnection acadConn, bool forceRefresh, int maxAgeHours)
    {
        if (string.IsNullOrEmpty(regno)) return CardStatus.Error("Missing registration number.");

        EnsureSchema(acadConn);

        // 1. Read cached value
        if (!forceRefresh)
        {
            CardStatus cached = ReadCached(regno, acadConn);
            if (cached != null && cached.CheckedAt.HasValue)
            {
                double age = (DateTime.Now - cached.CheckedAt.Value).TotalHours;
                if (age < maxAgeHours)
                    return cached;
            }
        }

        // 2. Call OmniPass API
        CardStatus live = CallApi(regno);

        // 3. Persist
        SaveStatus(regno, live, acadConn);

        return live;
    }

    /// <summary>
    /// Read only the cached status from the DB (no API call).
    /// Returns null if no row or columns are NULL.
    /// </summary>
    public static CardStatus ReadCached(string regno, MySqlConnection acadConn)
    {
        EnsureSchema(acadConn);
        bool opened = false;
        if (acadConn.State != System.Data.ConnectionState.Open) { acadConn.Open(); opened = true; }
        try
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT id_card_status, id_card_checked_at FROM acad_student WHERE regno=@r LIMIT 1", acadConn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        string st = rdr["id_card_status"] != DBNull.Value ? rdr["id_card_status"].ToString() : null;
                        DateTime? dt = rdr["id_card_checked_at"] != DBNull.Value
                            ? (DateTime?)Convert.ToDateTime(rdr["id_card_checked_at"]) : null;
                        if (st != null)
                            return new CardStatus { Status = st, CheckedAt = dt, FromCache = true };
                    }
                }
            }
            return null;
        }
        finally { if (opened) acadConn.Close(); }
    }

    /// <summary>
    /// Call OmniPass for a single student. Does NOT touch the DB.
    /// </summary>
    public static CardStatus CallApi(string regno)
    {
        try
        {
            // Force TLS 1.2 — .NET 4.0 defaults to TLS 1.0 which modern servers reject
            System.Net.ServicePointManager.SecurityProtocol =
                System.Net.SecurityProtocolType.Tls | (System.Net.SecurityProtocolType)3072;

            string url = ApiBaseUrl.TrimEnd('/') + "/" + Uri.EscapeDataString(regno);
            using (WebClient wc = new WebClient())
            {
                wc.Encoding = Encoding.UTF8;
                wc.Headers.Add("X-Access-Key", AccessKey);
                string json = wc.DownloadString(url);
                return ParseResponse(json);
            }
        }
        catch (WebException wex)
        {
            HttpWebResponse resp = wex.Response as HttpWebResponse;
            if (resp != null)
            {
                int code = (int)resp.StatusCode;
                if (code == 404)
                    return new CardStatus { Status = "NOT_FOUND", Message = "Student not found in OmniPass system.", CheckedAt = DateTime.Now };
                if (code == 401)
                    return CardStatus.Error("OmniPass authentication failed (401).");
            }
            return CardStatus.Error("OmniPass API error: " + wex.Message);
        }
        catch (Exception ex)
        {
            return CardStatus.Error("OmniPass call failed: " + ex.Message);
        }
    }

    /// <summary>Persist status + timestamp into acad_student.</summary>
    public static void SaveStatus(string regno, CardStatus status, MySqlConnection acadConn)
    {
        bool opened = false;
        if (acadConn.State != System.Data.ConnectionState.Open) { acadConn.Open(); opened = true; }
        try
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "UPDATE acad_student SET id_card_status=@s, id_card_checked_at=@d WHERE regno=@r", acadConn))
            {
                cmd.Parameters.AddWithValue("@s", status.Status ?? "UNKNOWN");
                cmd.Parameters.AddWithValue("@d", status.CheckedAt.HasValue ? (object)status.CheckedAt.Value : DBNull.Value);
                cmd.Parameters.AddWithValue("@r", regno);
                cmd.ExecuteNonQuery();
            }
        }
        finally { if (opened) acadConn.Close(); }
    }

    /// <summary>
    /// Batch-refresh: fetch all cards from OmniPass and update any student records
    /// whose cached status differs or is older than <paramref name="maxAgeHours"/>.
    /// Returns number of records updated.
    /// </summary>
    public static int BatchSync(MySqlConnection acadConn, int maxAgeHours)
    {
        EnsureSchema(acadConn);

        // Fetch all cards list
        string allJson;
        try
        {
            System.Net.ServicePointManager.SecurityProtocol =
                System.Net.SecurityProtocolType.Tls | (System.Net.SecurityProtocolType)3072;

            using (WebClient wc = new WebClient())
            {
                wc.Encoding = Encoding.UTF8;
                wc.Headers.Add("X-Access-Key", AccessKey);
                allJson = wc.DownloadString(ApiBaseUrl.TrimEnd('/'));
            }
        }
        catch (Exception ex) { return -1; }

        // Parse the array from the response
        // Single-student API returns snake_case: mru_number, card_printed
        // Batch list API returns camelCase:     mruNumber, cardPrinted
        int updated = 0;
        bool opened = false;
        if (acadConn.State != System.Data.ConnectionState.Open) { acadConn.Open(); opened = true; }

        try
        {
            // Simple JSON array extraction — find "data":[ ... ]
            int dataIdx = allJson.IndexOf("\"data\"");
            if (dataIdx < 0) return 0;
            int arrStart = allJson.IndexOf('[', dataIdx);
            if (arrStart < 0) return 0;

            // Walk through each object in the array
            int pos = arrStart + 1;
            while (pos < allJson.Length)
            {
                int objStart = allJson.IndexOf('{', pos);
                if (objStart < 0) break;
                int objEnd = allJson.IndexOf('}', objStart);
                if (objEnd < 0) break;

                string obj = allJson.Substring(objStart, objEnd - objStart + 1);
                pos = objEnd + 1;

                // Try both camelCase (batch) and snake_case (single) field names
                string mruNum = ExtractJsonString(obj, "mruNumber");
                if (string.IsNullOrEmpty(mruNum))
                    mruNum = ExtractJsonString(obj, "mru_number");
                if (string.IsNullOrEmpty(mruNum)) continue;

                // Check both camelCase and snake_case for the boolean
                bool printed = obj.IndexOf("\"cardPrinted\":true", StringComparison.OrdinalIgnoreCase) >= 0
                            || obj.IndexOf("\"cardPrinted\": true", StringComparison.OrdinalIgnoreCase) >= 0
                            || obj.IndexOf("\"card_printed\":true", StringComparison.OrdinalIgnoreCase) >= 0
                            || obj.IndexOf("\"card_printed\": true", StringComparison.OrdinalIgnoreCase) >= 0;
                string newStatus = printed ? "PRINTED" : "NOT_PRINTED";

                using (MySqlCommand cmd = new MySqlCommand(
                    "UPDATE acad_student SET id_card_status=@s, id_card_checked_at=@d " +
                    "WHERE regno=@r AND (id_card_status IS NULL OR id_card_status != @s OR " +
                    "id_card_checked_at IS NULL OR id_card_checked_at < DATE_SUB(NOW(), INTERVAL @h HOUR))", acadConn))
                {
                    cmd.Parameters.AddWithValue("@s", newStatus);
                    cmd.Parameters.AddWithValue("@d", DateTime.Now);
                    cmd.Parameters.AddWithValue("@r", mruNum);
                    cmd.Parameters.AddWithValue("@h", maxAgeHours);
                    updated += cmd.ExecuteNonQuery();
                }
            }

            // Mark active students NOT in OmniPass as NOT_FOUND.
            // We just updated everyone who IS in OmniPass above (their id_card_checked_at is NOW()).
            // So anyone still active whose checked_at is older (or NULL) was not in the list.
            using (MySqlCommand cmd = new MySqlCommand(
                "UPDATE acad_student SET id_card_status='NOT_FOUND', id_card_checked_at=NOW() " +
                "WHERE UPPER(COALESCE(new_status,''))='ACTIVE' " +
                "AND (id_card_checked_at IS NULL OR id_card_checked_at < DATE_SUB(NOW(), INTERVAL 1 MINUTE))", acadConn))
            {
                cmd.CommandTimeout = 120;
                updated += cmd.ExecuteNonQuery();
            }
        }
        finally { if (opened) acadConn.Close(); }

        // Ongoing backfill: auto-create a PRINTED ID-card request for every student
        // now reported PRINTED who does not have one yet (idempotent, capped, no emails).
        try { IDCardService.SyncPrintedRequests("OMNIPASS-SYNC", 2000); } catch { }

        return updated;
    }

    // ── Internals ──────────────────────────────────────────────────────

    private static CardStatus ParseResponse(string json)
    {
        // Check for 404 (person not found) — returned as HTTP 200 with "code":404 in body
        if (json.IndexOf("\"code\":404", StringComparison.OrdinalIgnoreCase) >= 0
         || json.IndexOf("\"code\": 404", StringComparison.OrdinalIgnoreCase) >= 0
         || json.IndexOf("\"code\":\"404\"", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return new CardStatus
            {
                Status = "NOT_FOUND",
                Message = "Student not found in OmniPass system.",
                CheckedAt = DateTime.Now
            };
        }

        // Extract "card_printed" boolean
        bool printed = json.IndexOf("\"card_printed\":true", StringComparison.OrdinalIgnoreCase) >= 0
                    || json.IndexOf("\"card_printed\": true", StringComparison.OrdinalIgnoreCase) >= 0;

        // Check for success: "code":"200-1" (string) or "code":200 (number)
        bool success = json.IndexOf("\"code\":\"200-1\"", StringComparison.OrdinalIgnoreCase) >= 0
                    || json.IndexOf("\"code\": \"200-1\"", StringComparison.OrdinalIgnoreCase) >= 0
                    || json.IndexOf("\"code\":200", StringComparison.OrdinalIgnoreCase) >= 0
                    || json.IndexOf("\"code\": 200", StringComparison.OrdinalIgnoreCase) >= 0;

        if (success)
        {
            if (printed)
            {
                return new CardStatus
                {
                    Status = "PRINTED",
                    Message = "ID card has been printed and is ready for collection.",
                    CheckedAt = DateTime.Now,
                    CardPrinted = true
                };
            }
            else
            {
                return new CardStatus
                {
                    Status = "NOT_PRINTED",
                    Message = "ID card has not been printed yet.",
                    CheckedAt = DateTime.Now,
                    CardPrinted = false
                };
            }
        }

        // Fallback — look at data for card_printed even without a clean code match
        if (json.IndexOf("\"card_printed\"", StringComparison.OrdinalIgnoreCase) >= 0)
        {
            return new CardStatus
            {
                Status = printed ? "PRINTED" : "NOT_PRINTED",
                Message = printed ? "ID card has been printed." : "ID card has not been printed yet.",
                CheckedAt = DateTime.Now,
                CardPrinted = printed
            };
        }

        string msg = ExtractJsonString(json, "message");
        return new CardStatus
        {
            Status = "ERROR",
            Message = !string.IsNullOrEmpty(msg) ? msg : "Unexpected API response.",
            CheckedAt = DateTime.Now
        };
    }

    /// <summary>Quick-and-dirty JSON string value extractor (no library dependency).</summary>
    private static string ExtractJsonString(string json, string key)
    {
        string pattern = "\"" + key + "\"";
        int idx = json.IndexOf(pattern, StringComparison.OrdinalIgnoreCase);
        if (idx < 0) return null;
        int colon = json.IndexOf(':', idx + pattern.Length);
        if (colon < 0) return null;
        int qStart = json.IndexOf('"', colon + 1);
        if (qStart < 0) return null;
        int qEnd = json.IndexOf('"', qStart + 1);
        if (qEnd < 0) return null;
        return json.Substring(qStart + 1, qEnd - qStart - 1);
    }

    // ── Data class ─────────────────────────────────────────────────────

    public class CardStatus
    {
        public string Status;        // PRINTED, NOT_PRINTED, NOT_FOUND, ERROR, UNKNOWN
        public string Message;
        public DateTime? CheckedAt;
        public bool CardPrinted;
        public bool FromCache;

        public static CardStatus Error(string msg)
        {
            return new CardStatus { Status = "ERROR", Message = msg, CheckedAt = DateTime.Now };
        }

        /// <summary>User-friendly label for the status.</summary>
        public string DisplayLabel
        {
            get
            {
                switch (Status)
                {
                    case "PRINTED": return "Printed";
                    case "NOT_PRINTED": return "Not Printed";
                    case "NOT_FOUND": return "Not in System";
                    case "ERROR": return "Check Failed";
                    default: return "Unknown";
                }
            }
        }

        /// <summary>CSS modifier class (for badges).</summary>
        public string CssClass
        {
            get
            {
                switch (Status)
                {
                    case "PRINTED": return "printed";
                    case "NOT_PRINTED": return "not-printed";
                    case "NOT_FOUND": return "not-found";
                    case "ERROR": return "error";
                    default: return "unknown";
                }
            }
        }
    }
}
