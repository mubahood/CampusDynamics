using System;
using System.Configuration;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

/// <summary>
/// Data-access layer for the support ticket system — admin-side copy.
/// Connects to campus_dynamics_portal DB via campus_dynamics_portalConnectionString.
/// Mirrors App_Code/SupportTicketDB.cs in CampusDynamics_Portal.
/// </summary>
public static class SupportTicketDB
{
    // ── Connection ───────────────────────────────────────────────────────────────

    private static string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["campus_dynamics_portalConnectionString"];
            if (cs != null) return cs.ConnectionString;
            cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
            return cs != null ? cs.ConnectionString
                              : ConfigurationManager.ConnectionStrings["LocalMySqlServer"].ConnectionString;
        }
    }

    // ── Schema auto-init ─────────────────────────────────────────────────────────

    public static void EnsureSchema()
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            var sqls = new[]
            {
                @"CREATE TABLE IF NOT EXISTS support_tickets (
                    ticket_id      INT AUTO_INCREMENT PRIMARY KEY,
                    submitter_regno VARCHAR(50)  NOT NULL,
                    submitter_name  VARCHAR(150) NOT NULL,
                    submitter_type  ENUM('STUDENT','LECTURER','STAFF') NOT NULL DEFAULT 'STUDENT',
                    issue_type     VARCHAR(80)  NOT NULL,
                    subject        VARCHAR(250) NOT NULL,
                    status         ENUM('OPEN','IN_PROGRESS','AWAITING_REPLY','RESOLVED','CLOSED')
                                   NOT NULL DEFAULT 'OPEN',
                    priority       ENUM('LOW','NORMAL','HIGH','URGENT') NOT NULL DEFAULT 'NORMAL',
                    assigned_to    VARCHAR(100) NULL,
                    created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
                    closed_at      DATETIME NULL,
                    closed_by      VARCHAR(100) NULL,
                    INDEX idx_regno  (submitter_regno),
                    INDEX idx_status (status)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",

                @"CREATE TABLE IF NOT EXISTS support_ticket_messages (
                    message_id   INT AUTO_INCREMENT PRIMARY KEY,
                    ticket_id    INT NOT NULL,
                    sender_regno VARCHAR(50)  NOT NULL,
                    sender_name  VARCHAR(150) NOT NULL,
                    sender_role  ENUM('SUBMITTER','ADMIN','SYSTEM') NOT NULL DEFAULT 'SUBMITTER',
                    message      TEXT NOT NULL,
                    is_internal  TINYINT(1) NOT NULL DEFAULT 0,
                    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_msg_ticket (ticket_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4",

                @"CREATE TABLE IF NOT EXISTS support_ticket_attachments (
                    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
                    ticket_id     INT  NOT NULL,
                    message_id    INT  NULL,
                    original_name VARCHAR(255) NOT NULL,
                    stored_name   VARCHAR(255) NOT NULL,
                    file_size     INT  NOT NULL DEFAULT 0,
                    mime_type     VARCHAR(100) NULL,
                    uploaded_by   VARCHAR(100) NOT NULL,
                    uploaded_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    INDEX idx_att_ticket  (ticket_id),
                    INDEX idx_att_message (message_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
            };

            foreach (var sql in sqls)
            {
                using (var cmd = new MySqlCommand(sql, conn))
                    cmd.ExecuteNonQuery();
            }
        }
    }

    // ── Ticket operations ────────────────────────────────────────────────────────

    public static DataRow GetTicket(int ticketId)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT * FROM support_tickets WHERE ticket_id = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", ticketId);
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
        }
    }

    public static DataTable GetAllTickets(string statusFilter, string issueFilter,
                                          string search, int limit, int offset,
                                          string priority = "", string assignedTo = "")
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            var where  = new StringBuilder("WHERE 1=1");
            bool hasSF = !string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL";
            bool hasIF = !string.IsNullOrEmpty(issueFilter)  && issueFilter  != "ALL";
            bool hasSQ = !string.IsNullOrEmpty(search);
            bool hasPR = !string.IsNullOrEmpty(priority);
            bool hasAT = !string.IsNullOrEmpty(assignedTo);

            if (hasSF) where.Append(" AND status = @sf");
            if (hasIF) where.Append(" AND issue_type LIKE @it");
            if (hasSQ) where.Append(" AND (submitter_name LIKE @s OR submitter_regno LIKE @s OR subject LIKE @s)");
            if (hasPR) where.Append(" AND priority = @pr");
            if (hasAT) where.Append(" AND assigned_to = @at");

            string sql = "SELECT ticket_id, submitter_regno, submitter_name, submitter_type, " +
                         "       issue_type, subject, status, priority, assigned_to, created_at, updated_at " +
                         "FROM support_tickets " + where +
                         " ORDER BY FIELD(status,'OPEN','IN_PROGRESS','AWAITING_REPLY','RESOLVED','CLOSED')," +
                         " FIELD(priority,'URGENT','HIGH','NORMAL','LOW'), updated_at DESC LIMIT @lim OFFSET @off";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                if (hasSF) cmd.Parameters.AddWithValue("@sf", statusFilter);
                if (hasIF) cmd.Parameters.AddWithValue("@it", issueFilter + "%");
                if (hasSQ) cmd.Parameters.AddWithValue("@s",  "%" + search + "%");
                if (hasPR) cmd.Parameters.AddWithValue("@pr", priority);
                if (hasAT) cmd.Parameters.AddWithValue("@at", assignedTo);
                cmd.Parameters.AddWithValue("@lim", limit);
                cmd.Parameters.AddWithValue("@off", offset);
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    public static int CountAllTickets(string statusFilter, string issueFilter, string search,
                                      string priority = "", string assignedTo = "")
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            var where  = new StringBuilder("WHERE 1=1");
            bool hasSF = !string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL";
            bool hasIF = !string.IsNullOrEmpty(issueFilter)  && issueFilter  != "ALL";
            bool hasSQ = !string.IsNullOrEmpty(search);
            bool hasPR = !string.IsNullOrEmpty(priority);
            bool hasAT = !string.IsNullOrEmpty(assignedTo);

            if (hasSF) where.Append(" AND status = @sf");
            if (hasIF) where.Append(" AND issue_type LIKE @it");
            if (hasSQ) where.Append(" AND (submitter_name LIKE @s OR submitter_regno LIKE @s OR subject LIKE @s)");
            if (hasPR) where.Append(" AND priority = @pr");
            if (hasAT) where.Append(" AND assigned_to = @at");

            using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM support_tickets " + where, conn))
            {
                if (hasSF) cmd.Parameters.AddWithValue("@sf", statusFilter);
                if (hasIF) cmd.Parameters.AddWithValue("@it", issueFilter + "%");
                if (hasSQ) cmd.Parameters.AddWithValue("@s",  "%" + search + "%");
                if (hasPR) cmd.Parameters.AddWithValue("@pr", priority);
                if (hasAT) cmd.Parameters.AddWithValue("@at", assignedTo);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    public static DataRow GetAdminStats()
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) AS total," +
                "SUM(status='OPEN') AS cnt_open," +
                "SUM(status='IN_PROGRESS') AS cnt_progress," +
                "SUM(status='AWAITING_REPLY') AS cnt_awaiting," +
                "SUM(status='RESOLVED') AS cnt_resolved," +
                "SUM(status='CLOSED') AS cnt_closed," +
                "SUM(priority='URGENT' AND status NOT IN ('RESOLVED','CLOSED')) AS cnt_urgent " +
                "FROM support_tickets", conn))
            {
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
        }
    }

    // ── Student / submitter ops ──────────────────────────────────────────────────

    /// <summary>Creates ticket header + opening message with explicit priority. Returns new ticket_id.</summary>
    public static int CreateTicket(string regno, string name, string submitterType,
                                   string issueType, string subject, string description,
                                   string priority)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();

            using (var cmd = new MySqlCommand(
                "INSERT INTO support_tickets " +
                "(submitter_regno, submitter_name, submitter_type, issue_type, subject, priority) " +
                "VALUES (@r, @n, @st, @it, @s, @pri)", conn))
            {
                cmd.Parameters.AddWithValue("@r",   regno);
                cmd.Parameters.AddWithValue("@n",   name);
                cmd.Parameters.AddWithValue("@st",  submitterType);
                cmd.Parameters.AddWithValue("@it",  issueType);
                cmd.Parameters.AddWithValue("@s",   subject);
                cmd.Parameters.AddWithValue("@pri", priority);
                cmd.ExecuteNonQuery();
            }

            int ticketId;
            using (var idCmd = new MySqlCommand("SELECT LAST_INSERT_ID()", conn))
                ticketId = Convert.ToInt32(idCmd.ExecuteScalar());

            using (var msgCmd = new MySqlCommand(
                "INSERT INTO support_ticket_messages " +
                "(ticket_id, sender_regno, sender_name, sender_role, message) " +
                "VALUES (@tid, @r, @n, 'SUBMITTER', @m)", conn))
            {
                msgCmd.Parameters.AddWithValue("@tid", ticketId);
                msgCmd.Parameters.AddWithValue("@r",   regno);
                msgCmd.Parameters.AddWithValue("@n",   name);
                msgCmd.Parameters.AddWithValue("@m",   description);
                msgCmd.ExecuteNonQuery();
            }

            return ticketId;
        }
    }

    public static DataTable GetUserTickets(string regno, string statusFilter, int limit, int offset)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            string where = "WHERE submitter_regno = @r";
            bool hasFilter = !string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL";
            if (hasFilter) where += " AND status = @sf";

            using (var cmd = new MySqlCommand(
                "SELECT ticket_id, issue_type, subject, status, priority, assigned_to, created_at, updated_at " +
                "FROM support_tickets " + where +
                " ORDER BY FIELD(status,'OPEN','IN_PROGRESS','AWAITING_REPLY','RESOLVED','CLOSED'), updated_at DESC" +
                " LIMIT @lim OFFSET @off", conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                if (hasFilter) cmd.Parameters.AddWithValue("@sf", statusFilter);
                cmd.Parameters.AddWithValue("@lim", limit);
                cmd.Parameters.AddWithValue("@off", offset);
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    public static int CountUserTickets(string regno, string statusFilter)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            string where = "WHERE submitter_regno = @r";
            bool hasFilter = !string.IsNullOrEmpty(statusFilter) && statusFilter != "ALL";
            if (hasFilter) where += " AND status = @sf";

            using (var cmd = new MySqlCommand("SELECT COUNT(*) FROM support_tickets " + where, conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                if (hasFilter) cmd.Parameters.AddWithValue("@sf", statusFilter);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    public static bool IsTicketOwner(int ticketId, string regno)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM support_tickets WHERE ticket_id = @id AND submitter_regno = @r", conn))
            {
                cmd.Parameters.AddWithValue("@id", ticketId);
                cmd.Parameters.AddWithValue("@r",  regno);
                return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
            }
        }
    }

    public static DataRow GetUserStats(string regno)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) AS total," +
                "SUM(status='OPEN') AS cnt_open," +
                "SUM(status='IN_PROGRESS') AS cnt_progress," +
                "SUM(status='AWAITING_REPLY') AS cnt_awaiting," +
                "SUM(status='RESOLVED') AS cnt_resolved," +
                "SUM(status='CLOSED') AS cnt_closed " +
                "FROM support_tickets WHERE submitter_regno = @r", conn))
            {
                cmd.Parameters.AddWithValue("@r", regno);
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
        }
    }

    /// <summary>Count tickets submitted by regno in the last periodMinutes. For rate limiting.</summary>
    public static int CountRecentTickets(string regno, int periodMinutes)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT COUNT(*) FROM support_tickets " +
                "WHERE submitter_regno = @r AND created_at >= DATE_SUB(NOW(), INTERVAL @mins MINUTE)", conn))
            {
                cmd.Parameters.AddWithValue("@r",    regno);
                cmd.Parameters.AddWithValue("@mins", periodMinutes);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    /// <summary>Fetches a single attachment by attachment_id + ticket_id (ownership guard).</summary>
    public static DataRow GetAttachment(int attachmentId, int ticketId)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT attachment_id, ticket_id, message_id, original_name, stored_name, " +
                "file_size, mime_type FROM support_ticket_attachments " +
                "WHERE attachment_id = @aid AND ticket_id = @tid LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@aid", attachmentId);
                cmd.Parameters.AddWithValue("@tid", ticketId);
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt.Rows.Count > 0 ? dt.Rows[0] : null;
            }
        }
    }

    /// <summary>Resolves the upload folder path. Tries shared portal path first, falls back to local.</summary>
    public static string GetUploadFolder(HttpServerUtility server)
    {
        string local = server.MapPath("~/COOPERP/Support/Uploads/");
        if (Directory.Exists(local)) return local;

        try
        {
            string adminRoot   = server.MapPath("~/");
            string sharedPath  = Path.GetFullPath(Path.Combine(adminRoot, @"..\..\CampusDynamics_Portal\COOPERP\Support\Uploads\"));
            if (Directory.Exists(sharedPath)) return sharedPath;
        }
        catch { }

        Directory.CreateDirectory(local);
        return local;
    }

    // ── Messages ─────────────────────────────────────────────────────────────────

    public static DataTable GetMessages(int ticketId, bool includeInternal)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            string iw = includeInternal ? "" : " AND m.is_internal = 0";
            using (var cmd = new MySqlCommand(
                "SELECT m.message_id, m.sender_regno, m.sender_name, " +
                "       m.sender_role, m.message, m.is_internal, m.created_at " +
                "FROM support_ticket_messages m " +
                "WHERE m.ticket_id = @tid" + iw + " ORDER BY m.created_at ASC", conn))
            {
                cmd.Parameters.AddWithValue("@tid", ticketId);
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    public static int AddMessage(int ticketId, string senderRegno, string senderName,
                                 string role, string message, bool isInternal)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "INSERT INTO support_ticket_messages " +
                "(ticket_id, sender_regno, sender_name, sender_role, message, is_internal) " +
                "VALUES (@tid, @r, @n, @role, @m, @int)", conn))
            {
                cmd.Parameters.AddWithValue("@tid",  ticketId);
                cmd.Parameters.AddWithValue("@r",    senderRegno);
                cmd.Parameters.AddWithValue("@n",    senderName);
                cmd.Parameters.AddWithValue("@role", role);
                cmd.Parameters.AddWithValue("@m",    message);
                cmd.Parameters.AddWithValue("@int",  isInternal ? 1 : 0);
                cmd.ExecuteNonQuery();
            }

            int msgId;
            using (var idCmd = new MySqlCommand("SELECT LAST_INSERT_ID()", conn))
                msgId = Convert.ToInt32(idCmd.ExecuteScalar());

            if (!isInternal)
            {
                string newStatus = (role == "ADMIN") ? "AWAITING_REPLY" : "IN_PROGRESS";
                using (var updCmd = new MySqlCommand(
                    "UPDATE support_tickets SET updated_at = NOW(), " +
                    "status = CASE WHEN status NOT IN ('RESOLVED','CLOSED') THEN @ns ELSE status END " +
                    "WHERE ticket_id = @tid", conn))
                {
                    updCmd.Parameters.AddWithValue("@ns",  newStatus);
                    updCmd.Parameters.AddWithValue("@tid", ticketId);
                    updCmd.ExecuteNonQuery();
                }
            }

            return msgId;
        }
    }

    // ── Attachments ──────────────────────────────────────────────────────────────

    public static void AddAttachment(int ticketId, int messageId,
                                     string originalName, string storedName,
                                     int fileSize, string mimeType, string uploadedBy)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "INSERT INTO support_ticket_attachments " +
                "(ticket_id, message_id, original_name, stored_name, file_size, mime_type, uploaded_by) " +
                "VALUES (@tid, @mid, @on, @sn, @fs, @mt, @ub)", conn))
            {
                cmd.Parameters.AddWithValue("@tid", ticketId);
                cmd.Parameters.AddWithValue("@mid", messageId);
                cmd.Parameters.AddWithValue("@on",  originalName);
                cmd.Parameters.AddWithValue("@sn",  storedName);
                cmd.Parameters.AddWithValue("@fs",  fileSize);
                cmd.Parameters.AddWithValue("@mt",  mimeType ?? "application/octet-stream");
                cmd.Parameters.AddWithValue("@ub",  uploadedBy);
                cmd.ExecuteNonQuery();
            }
        }
    }

    public static DataTable GetTicketAttachments(int ticketId)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "SELECT attachment_id, message_id, original_name, stored_name, file_size, mime_type " +
                "FROM support_ticket_attachments WHERE ticket_id = @tid ORDER BY uploaded_at ASC", conn))
            {
                cmd.Parameters.AddWithValue("@tid", ticketId);
                var da = new MySqlDataAdapter(cmd);
                var dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }
    }

    // ── Status / admin ops ───────────────────────────────────────────────────────

    public static void UpdateStatus(int ticketId, string newStatus,
                                    string adminRegno, string adminName)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            bool closing = (newStatus == "CLOSED" || newStatus == "RESOLVED");
            string sql = "UPDATE support_tickets SET status = @s, updated_at = NOW(), " +
                         "assigned_to = COALESCE(NULLIF(assigned_to,''), @ar)" +
                         (closing ? ", closed_at = NOW(), closed_by = @an" : "") +
                         " WHERE ticket_id = @tid";

            using (var cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@s",   newStatus);
                cmd.Parameters.AddWithValue("@ar",  adminRegno);
                cmd.Parameters.AddWithValue("@an",  adminName);
                cmd.Parameters.AddWithValue("@tid", ticketId);
                cmd.ExecuteNonQuery();
            }

            using (var msgCmd = new MySqlCommand(
                "INSERT INTO support_ticket_messages " +
                "(ticket_id, sender_regno, sender_name, sender_role, message) " +
                "VALUES (@tid, @r, @n, 'SYSTEM', @m)", conn))
            {
                msgCmd.Parameters.AddWithValue("@tid", ticketId);
                msgCmd.Parameters.AddWithValue("@r",   adminRegno);
                msgCmd.Parameters.AddWithValue("@n",   adminName);
                msgCmd.Parameters.AddWithValue("@m",   "STATUS_CHANGE:" + newStatus);
                msgCmd.ExecuteNonQuery();
            }
        }
    }

    public static void UpdatePriority(int ticketId, string priority)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "UPDATE support_tickets SET priority = @p, updated_at = NOW() WHERE ticket_id = @tid", conn))
            {
                cmd.Parameters.AddWithValue("@p",   priority);
                cmd.Parameters.AddWithValue("@tid", ticketId);
                cmd.ExecuteNonQuery();
            }
        }
    }

    public static void AssignTicket(int ticketId, string assignee)
    {
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (var cmd = new MySqlCommand(
                "UPDATE support_tickets SET assigned_to = @a, updated_at = NOW() WHERE ticket_id = @tid", conn))
            {
                cmd.Parameters.AddWithValue("@a",   assignee);
                cmd.Parameters.AddWithValue("@tid", ticketId);
                cmd.ExecuteNonQuery();
            }
        }
    }

    // ── File upload helpers ──────────────────────────────────────────────────────

    public static readonly string[] AllowedExtensions =
        { ".jpg", ".jpeg", ".png", ".gif", ".pdf", ".doc", ".docx", ".txt" };

    public static bool IsAllowedExtension(string ext)
    {
        string lower = (ext ?? "").ToLower();
        foreach (var a in AllowedExtensions)
            if (lower == a) return true;
        return false;
    }

    public static bool IsImageExtension(string ext)
    {
        string lower = (ext ?? "").ToLower();
        return lower == ".jpg" || lower == ".jpeg" || lower == ".png" || lower == ".gif";
    }

    public static bool IsWithinSizeLimit(int bytes)
    {
        return bytes <= 5 * 1024 * 1024;
    }

    // ── Display helpers ──────────────────────────────────────────────────────────

    public static string FormatRef(int ticketId)
    {
        return "TKT-" + ticketId.ToString("D5");
    }

    public static string GetStatusLabel(string status)
    {
        switch (status)
        {
            case "OPEN":            return "Open";
            case "IN_PROGRESS":    return "In Progress";
            case "AWAITING_REPLY": return "Awaiting Reply";
            case "RESOLVED":       return "Resolved";
            case "CLOSED":         return "Closed";
            default:               return status ?? "";
        }
    }

    public static string GetStatusColor(string status)
    {
        switch (status)
        {
            case "OPEN":            return "#174DA4";
            case "IN_PROGRESS":    return "#d97706";
            case "AWAITING_REPLY": return "#7c3aed";
            case "RESOLVED":       return "#16a34a";
            case "CLOSED":         return "#6b7280";
            default:               return "#174DA4";
        }
    }

    public static string GetStatusBg(string status)
    {
        switch (status)
        {
            case "OPEN":            return "rgba(23,77,164,.12)";
            case "IN_PROGRESS":    return "rgba(217,119,6,.12)";
            case "AWAITING_REPLY": return "rgba(124,58,237,.12)";
            case "RESOLVED":       return "rgba(22,163,74,.12)";
            case "CLOSED":         return "rgba(107,114,128,.12)";
            default:               return "rgba(23,77,164,.12)";
        }
    }

    public static string GetPriorityColor(string priority)
    {
        switch (priority)
        {
            case "URGENT": return "#dc3545";
            case "HIGH":   return "#d97706";
            case "NORMAL": return "#174DA4";
            case "LOW":    return "#6b7280";
            default:       return "#6b7280";
        }
    }

    public static string GetIssueTypeShort(string issueType)
    {
        if (string.IsNullOrEmpty(issueType)) return "Other";
        int em = issueType.IndexOf('—');
        if (em > 0) return issueType.Substring(0, em).Trim();
        int hyph = issueType.IndexOf(" - ");
        if (hyph > 0) return issueType.Substring(0, hyph).Trim();
        return issueType.Length > 20 ? issueType.Substring(0, 20) + "..." : issueType;
    }

    public static string GetIssueTypeColor(string issueType)
    {
        if (string.IsNullOrEmpty(issueType)) return "#6b7280";
        string lower = issueType.ToLower();
        if (lower.StartsWith("academic"))      return "#174DA4";
        if (lower.StartsWith("financial"))     return "#16a34a";
        if (lower.StartsWith("technical"))     return "#dc3545";
        if (lower.StartsWith("registration"))  return "#d97706";
        if (lower.StartsWith("library"))       return "#0d9488";
        if (lower.StartsWith("accommodation")) return "#ea580c";
        if (lower.StartsWith("lecturer"))      return "#7c3aed";
        return "#6b7280";
    }

    public static string FormatTimeAgo(DateTime dt)
    {
        TimeSpan diff = DateTime.Now - dt;
        if (diff.TotalSeconds < 60) return "just now";
        if (diff.TotalMinutes < 60) return ((int)diff.TotalMinutes) + "m ago";
        if (diff.TotalHours   < 24) return ((int)diff.TotalHours)   + "h ago";
        if (diff.TotalDays    < 7)  return ((int)diff.TotalDays)    + "d ago";
        return dt.ToString("dd MMM yyyy");
    }

    public static string FormatDateTime(DateTime dt)
    {
        return dt.ToString("dd MMM yyyy, h:mm tt");
    }

    public static string FormatFileSize(int bytes)
    {
        if (bytes < 1024)        return bytes + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024) + " KB";
        return string.Format("{0:0.0} MB", bytes / (1024.0 * 1024));
    }
}
