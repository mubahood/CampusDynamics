using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using MySql.Data.MySqlClient;

/// <summary>
/// ID Card module engine (Phase 0). Single source of truth for the request
/// lifecycle: create → transition (audited) → terminal. Every state change from
/// eportal, eadmin, or the XAXU API funnels through <see cref="Transition"/>, so
/// there is exactly one place that validates the state machine, stamps the
/// timeline, writes an audit event, and (later) triggers email.
///
/// Design doc: COOPERP/IDCARD_WORKFLOW_DESIGN.md.
/// </summary>
public static partial class IDCardService
{
    // ── connection to campus_dynamics ──
    // NOTE: this service is compiled into BOTH the eadmin app AND the eportal app, and the
    // named connection strings differ between them (e.g. the portal's "vacConnectionString"
    // points at campus_dynamics_portal, the WRONG db). Both apps run against the same local
    // MySQL, so we resolve a connection that truly targets campus_dynamics: an explicit
    // "IDCard.ConnStr" app-setting override wins; otherwise the hardcoded local connection.
    public static string ConnStr
    {
        get
        {
            var ov = ConfigurationManager.AppSettings["IDCard.ConnStr"];
            if (!string.IsNullOrEmpty(ov)) return ov;
            return "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    // campus_dynamics_accounts (name differs across apps too — resolve robustly)
    public static string AccountsConnStr
    {
        get
        {
            var ov = ConfigurationManager.AppSettings["IDCard.AccountsConnStr"];
            if (!string.IsNullOrEmpty(ov)) return ov;
            var a = ConfigurationManager.ConnectionStrings["accountsConnectionString"]
                 ?? ConfigurationManager.ConnectionStrings["campus_dynamics_accountsConnectionString"];
            if (a != null && a.ConnectionString.IndexOf("campus_dynamics_accounts", StringComparison.OrdinalIgnoreCase) >= 0)
                return a.ConnectionString;
            return "server=localhost;User Id=root;password=24thdecember1977;database=campus_dynamics_accounts;DefaultCommandTimeout=600;Convert Zero Datetime=True;charset=utf8";
        }
    }

    // Email hook — each host app wires this to its own EmailSenderProtocol in Application_Start,
    // because the two apps' SendHtmlEmail signatures differ. Signature: (toEmail, subject, htmlBody).
    // If unset, notifications are silently skipped (never breaks a transition).
    public static Action<string, string, string> Mailer;

    // ── statuses ──
    public const string REQUESTED     = "REQUESTED";
    public const string FINANCE_CHECK = "FINANCE_CHECK";
    public const string BLOCKED       = "BLOCKED";
    public const string SUBMITTED     = "SUBMITTED";
    public const string APPROVED      = "APPROVED";
    public const string HALTED        = "HALTED";
    public const string PRINTED       = "PRINTED";
    public const string READY         = "READY";
    public const string COLLECTED     = "COLLECTED";
    public const string CANCELLED     = "CANCELLED";

    // Terminal states = request is closed; a person may open a new one.
    private static readonly HashSet<string> Terminal =
        new HashSet<string>(StringComparer.OrdinalIgnoreCase) { COLLECTED, CANCELLED };

    // Legal transitions (from → allowed set). Anything not listed is rejected.
    private static readonly Dictionary<string, HashSet<string>> Allowed =
        new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase)
    {
        { REQUESTED,     Set(FINANCE_CHECK, SUBMITTED, CANCELLED) },   // SUBMITTED = staff (no finance gate)
        { FINANCE_CHECK, Set(SUBMITTED, BLOCKED, CANCELLED) },
        { BLOCKED,       Set(FINANCE_CHECK, CANCELLED) },
        { SUBMITTED,     Set(APPROVED, HALTED, CANCELLED) },
        { APPROVED,      Set(PRINTED, HALTED) },
        { HALTED,        Set(SUBMITTED, CANCELLED) },
        { PRINTED,       Set(READY) },
        { READY,         Set(COLLECTED) },
        { COLLECTED,     Set() },
        { CANCELLED,     Set() },
    };

    // status → timeline column stamped on entry (NULL = none)
    private static string TimeCol(string status)
    {
        switch ((status ?? "").ToUpperInvariant())
        {
            case SUBMITTED: return "submitted_at";
            case APPROVED:  return "approved_at";
            case PRINTED:   return "printed_at";
            case READY:     return "ready_at";
            case COLLECTED: return "collected_at";
            default:        return null;
        }
    }
    // status → actor column stamped on entry (NULL = none)
    private static string ActorCol(string status)
    {
        switch ((status ?? "").ToUpperInvariant())
        {
            case APPROVED:  return "approved_by";
            case PRINTED:   return "printed_by";
            case COLLECTED: return "collected_by";
            default:        return null;
        }
    }

    public static bool IsTerminal(string status) { return Terminal.Contains(status ?? ""); }

    // ── schema self-heal (safe on every controller load) ──
    public static void EnsureSchema(MySqlConnection conn)
    {
        try
        {
            Exec(conn, "CREATE TABLE IF NOT EXISTS idcard_requests (" +
                " id INT PRIMARY KEY AUTO_INCREMENT, request_no VARCHAR(20) NOT NULL," +
                " requester_type VARCHAR(10) NOT NULL, regno VARCHAR(35) NULL, emp_id INT NULL," +
                " card_type VARCHAR(15) NOT NULL, status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED'," +
                " photo_ref VARCHAR(255) NULL, photo_confirmed TINYINT NOT NULL DEFAULT 0, guidelines_ack TINYINT NOT NULL DEFAULT 0," +
                " finance_ok TINYINT NULL, finance_snapshot_json TEXT NULL," +
                " replacement_fee_ref VARCHAR(60) NULL, replacement_fee_date DATE NULL, replacement_fee_method VARCHAR(20) NULL, replacement_fee_notes VARCHAR(255) NULL," +
                " window_id INT NULL, halt_reason VARCHAR(255) NULL," +
                " submitted_at DATETIME NULL, approved_at DATETIME NULL, printed_at DATETIME NULL, ready_at DATETIME NULL, collected_at DATETIME NULL," +
                " approved_by VARCHAR(150) NULL, printed_by VARCHAR(150) NULL, collected_by VARCHAR(150) NULL," +
                " notes VARCHAR(255) NULL, created_by VARCHAR(150) NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, updated_at DATETIME NULL," +
                " UNIQUE KEY uq_request_no (request_no), KEY ix_status (status), KEY ix_regno (regno), KEY ix_emp (emp_id), KEY ix_type (requester_type), KEY ix_window (window_id)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8");
            Exec(conn, "CREATE TABLE IF NOT EXISTS idcard_request_events (" +
                " id INT PRIMARY KEY AUTO_INCREMENT, request_id INT NOT NULL, from_status VARCHAR(20) NULL, to_status VARCHAR(20) NOT NULL," +
                " actor VARCHAR(150) NULL, actor_role VARCHAR(40) NULL, channel VARCHAR(12) NULL, note VARCHAR(500) NULL, email_sent TINYINT NULL," +
                " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, KEY ix_req (request_id), KEY ix_to (to_status)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8");
            Exec(conn, "CREATE TABLE IF NOT EXISTS idcard_windows (" +
                " id INT PRIMARY KEY AUTO_INCREMENT, title VARCHAR(150) NOT NULL, requester_scope VARCHAR(10) NOT NULL DEFAULT 'BOTH'," +
                " opens_at DATETIME NOT NULL, closes_at DATETIME NOT NULL, is_active TINYINT NOT NULL DEFAULT 1, notes VARCHAR(255) NULL," +
                " created_by VARCHAR(150) NULL, created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, KEY ix_active (is_active), KEY ix_range (opens_at, closes_at)" +
                ") ENGINE=InnoDB DEFAULT CHARSET=utf8");
            AddCol(conn, "idcard_requests", "collection_point", "VARCHAR(200) NULL");
            AddCol(conn, "hrm_employee", "photo_file", "VARCHAR(255) NULL");
            AddCol(conn, "hrm_employee", "photo_updated_at", "DATETIME NULL");
        }
        catch { /* never break a page on self-heal */ }
    }

    // ── one active request per person ──
    /// <summary>Returns the request_no of the person's current non-terminal request, or null.</summary>
    public static string ActiveRequestNo(MySqlConnection conn, string requesterType, string regno, int empId)
    {
        string w = IsStaff(requesterType) ? " emp_id=@e " : " TRIM(regno)=TRIM(@r) ";
        using (var cmd = new MySqlCommand(
            "SELECT request_no FROM idcard_requests WHERE requester_type=@t AND" + w +
            " AND status NOT IN ('COLLECTED','CANCELLED') ORDER BY id DESC LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@t", Norm(requesterType));
            if (IsStaff(requesterType)) cmd.Parameters.AddWithValue("@e", empId);
            else cmd.Parameters.AddWithValue("@r", regno ?? "");
            object v = cmd.ExecuteScalar();
            return (v == null || v == DBNull.Value) ? null : v.ToString();
        }
    }

    // ── create a request (Step 1) ──
    public class CreateResult { public bool Ok; public string RequestNo; public int Id; public string Message; }

    public static CreateResult CreateRequest(string requesterType, string regno, int empId, string cardType,
        string photoRef, bool photoConfirmed, bool guidelinesAck, int windowId, string createdBy)
    {
        var res = new CreateResult();
        string type = Norm(requesterType);
        if (type != "STUDENT" && type != "STAFF") { res.Message = "Invalid requester type."; return res; }
        string ct = (cardType ?? "").Trim().ToUpperInvariant();
        if (ct != "NEW" && ct != "REPLACEMENT") { res.Message = "Choose New or Replacement."; return res; }
        if (type == "STUDENT" && string.IsNullOrEmpty((regno ?? "").Trim())) { res.Message = "Missing student number."; return res; }
        if (type == "STAFF" && empId <= 0) { res.Message = "Missing staff id."; return res; }

        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            EnsureSchema(conn);

            string active = ActiveRequestNo(conn, type, regno, empId);
            if (active != null) { res.Message = "You already have an active request (" + active + "). Only one active request is allowed."; return res; }

            // generate a unique request_no, retry on the rare unique-key clash
            for (int attempt = 0; attempt < 5; attempt++)
            {
                string rn = NextRequestNo(conn);
                try
                {
                    int id;
                    using (var cmd = new MySqlCommand(
                        "INSERT INTO idcard_requests (request_no, requester_type, regno, emp_id, card_type, status," +
                        " photo_ref, photo_confirmed, guidelines_ack, window_id, created_by, created_at, updated_at)" +
                        " VALUES (@rn,@t,@r,@e,@ct,'REQUESTED',@pr,@pc,@ga,@w,@by,NOW(),NOW())", conn))
                    {
                        cmd.Parameters.AddWithValue("@rn", rn);
                        cmd.Parameters.AddWithValue("@t", type);
                        cmd.Parameters.AddWithValue("@r", type == "STUDENT" ? (object)regno.Trim() : DBNull.Value);
                        cmd.Parameters.AddWithValue("@e", type == "STAFF" ? (object)empId : DBNull.Value);
                        cmd.Parameters.AddWithValue("@ct", ct);
                        cmd.Parameters.AddWithValue("@pr", (object)(photoRef ?? "") );
                        cmd.Parameters.AddWithValue("@pc", photoConfirmed ? 1 : 0);
                        cmd.Parameters.AddWithValue("@ga", guidelinesAck ? 1 : 0);
                        cmd.Parameters.AddWithValue("@w", windowId > 0 ? (object)windowId : DBNull.Value);
                        cmd.Parameters.AddWithValue("@by", createdBy ?? "");
                        cmd.ExecuteNonQuery();
                        id = (int)cmd.LastInsertedId;
                    }
                    LogEvent(conn, id, null, REQUESTED, createdBy, RoleFor(type), "eportal", "Request created");
                    res.Ok = true; res.RequestNo = rn; res.Id = id; res.Message = "Request " + rn + " created.";
                    return res;
                }
                catch (MySqlException ex)
                {
                    if (ex.Number == 1062) continue;   // duplicate request_no → regenerate
                    res.Message = "Could not create request: " + ex.Message; return res;
                }
            }
            res.Message = "Could not allocate a request number, please retry.";
            return res;
        }
    }

    // IDR-YYYY-NNNNNN  (year-scoped running sequence)
    private static string NextRequestNo(MySqlConnection conn)
    {
        int year = ServerYear(conn);
        string prefix = "IDR-" + year + "-";
        int next = 1;
        using (var cmd = new MySqlCommand(
            "SELECT IFNULL(MAX(CAST(SUBSTRING(request_no, LENGTH(@p)+1) AS UNSIGNED)),0)+1 FROM idcard_requests WHERE request_no LIKE CONCAT(@p,'%')", conn))
        {
            cmd.Parameters.AddWithValue("@p", prefix);
            object v = cmd.ExecuteScalar();
            if (v != null && v != DBNull.Value) next = Convert.ToInt32(v);
        }
        return prefix + next.ToString("D6", CultureInfo.InvariantCulture);
    }

    // ── the single transition funnel ──
    public class TransitionResult { public bool Ok; public string Status; public string Message; public int RequestId; }

    public static TransitionResult Transition(string requestNo, string toStatus, string actor, string actorRole,
        string channel, string note, string haltReason)
    {
        var res = new TransitionResult();
        string to = Norm(toStatus);
        using (var conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            EnsureSchema(conn);

            int id; string from;
            using (var cmd = new MySqlCommand("SELECT id, status FROM idcard_requests WHERE request_no=@rn LIMIT 1", conn))
            {
                cmd.Parameters.AddWithValue("@rn", requestNo ?? "");
                using (var r = cmd.ExecuteReader())
                {
                    if (!r.Read()) { res.Message = "Request not found."; return res; }
                    id = r.GetInt32(0); from = r.GetString(1);
                }
            }
            res.RequestId = id; res.Status = from;

            if (string.Equals(from, to, StringComparison.OrdinalIgnoreCase))
            { res.Ok = true; res.Message = "Already " + to + "."; return res; }   // idempotent

            HashSet<string> ok;
            if (!Allowed.TryGetValue(from.ToUpperInvariant(), out ok) || !ok.Contains(to))
            { res.Message = "Cannot move from " + from + " to " + to + "."; return res; }

            if (to == HALTED && string.IsNullOrEmpty((haltReason ?? "").Trim()))
            { res.Message = "A reason is required to halt a request."; return res; }

            string tc = TimeCol(to), ac = ActorCol(to);
            var sb = new System.Text.StringBuilder("UPDATE idcard_requests SET status=@to, updated_at=NOW()");
            if (tc != null) sb.Append(", " + tc + "=NOW()");
            if (ac != null) sb.Append(", " + ac + "=@actor");
            if (to == HALTED) sb.Append(", halt_reason=@hr");
            sb.Append(" WHERE id=@id AND status=@from");   // optimistic guard: state must not have moved
            using (var up = new MySqlCommand(sb.ToString(), conn))
            {
                up.Parameters.AddWithValue("@to", to);
                if (ac != null) up.Parameters.AddWithValue("@actor", actor ?? "");
                if (to == HALTED) up.Parameters.AddWithValue("@hr", (haltReason ?? "").Trim());
                up.Parameters.AddWithValue("@id", id);
                up.Parameters.AddWithValue("@from", from);
                if (up.ExecuteNonQuery() == 0) { res.Message = "The request changed state — reload and retry."; return res; }
            }

            string evNote = note;
            if (to == HALTED) evNote = "Halted: " + (haltReason ?? "").Trim() + (string.IsNullOrEmpty(note) ? "" : (" — " + note));
            LogEvent(conn, id, from, to, actor, actorRole, channel, evNote);
            TryNotify(conn, id, to);   // email the requester on notable status changes (best-effort)

            res.Ok = true; res.Status = to; res.Message = "Moved to " + to + ".";
            return res;
        }
    }

    // ── audit event (also the hook where email will be sent later) ──
    public static void LogEvent(MySqlConnection conn, int requestId, string from, string to,
        string actor, string role, string channel, string note)
    {
        using (var cmd = new MySqlCommand(
            "INSERT INTO idcard_request_events (request_id, from_status, to_status, actor, actor_role, channel, note, created_at)" +
            " VALUES (@r,@f,@t,@a,@ro,@c,@n,NOW())", conn))
        {
            cmd.Parameters.AddWithValue("@r", requestId);
            cmd.Parameters.AddWithValue("@f", (object)from ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@t", to);
            cmd.Parameters.AddWithValue("@a", (object)(actor ?? ""));
            cmd.Parameters.AddWithValue("@ro", (object)(role ?? ""));
            cmd.Parameters.AddWithValue("@c", (object)(channel ?? "system"));
            cmd.Parameters.AddWithValue("@n", (object)(note ?? ""));
            cmd.ExecuteNonQuery();
        }
    }

    // ── helpers ──
    private static HashSet<string> Set(params string[] xs)
    { return new HashSet<string>(xs, StringComparer.OrdinalIgnoreCase); }
    private static bool IsStaff(string t) { return Norm(t) == "STAFF"; }
    private static string Norm(string t) { return (t ?? "").Trim().ToUpperInvariant(); }
    private static string RoleFor(string type) { return Norm(type) == "STAFF" ? "staff" : "student"; }
    private static void Exec(MySqlConnection conn, string sql) { using (var c = new MySqlCommand(sql, conn)) c.ExecuteNonQuery(); }
    private static int ServerYear(MySqlConnection conn) { using (var c = new MySqlCommand("SELECT YEAR(NOW())", conn)) return Convert.ToInt32(c.ExecuteScalar()); }
    private static void AddCol(MySqlConnection conn, string tbl, string col, string def)
    {
        using (var c = new MySqlCommand("SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
        {
            c.Parameters.AddWithValue("@t", tbl); c.Parameters.AddWithValue("@c", col);
            if (Convert.ToInt32(c.ExecuteScalar()) > 0) return;
        }
        using (var a = new MySqlCommand("ALTER TABLE " + tbl + " ADD COLUMN " + col + " " + def, conn)) a.ExecuteNonQuery();
    }
}
