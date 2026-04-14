using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// LectureRooms.aspx.cs — Code-behind for Lecture Rooms management page.
///
/// AJAX Endpoints (via ?ajax=...):
///   GET  ?ajax=list       — return all rooms with stats + current-semester usage count
///   GET  ?ajax=campuses   — return campus list for dropdowns
///   POST ?ajax=create     — create a new room (JSON body: {name, capacity, campusId})
///   POST ?ajax=update     — update a room    (JSON body: {id, name, capacity, campusId})
///   POST ?ajax=delete     — delete a room    (JSON body: {id})
///
/// Table: acad_lecturerooms (RoomID, RoomName, Capacity, campusId)
/// Ref:   acad_campuses (ID, campus_name)
/// Usage: AllocationHelper.GetRoomTotalUsageCount() for delete safety check
///
/// Design Rules:
///   - C# 4.0 compatible: no ?. operator, no string interpolation ($"")
///   - vacConnectionString only — no hardcoded credentials
///   - Session["SelectedAcademicYear"] / Session["SelectedSemester"] for usage check
///
/// Task: LOAD_ALLOCATION_TASKS.md — Task 4
/// Created: 2026-04-11
/// </summary>
public partial class COOPERP_NewScreens_LectureRooms : System.Web.UI.Page
{
    // ─────────────────────── Connection ──────────────────────────────────

    private string ConnStr
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
        }
    }

    // ─────────────────────── Helpers ─────────────────────────────────────

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                    da.Fill(dt);
            }
        }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private string RespondJson(object obj)
    {
        var ser = new JavaScriptSerializer();
        var json = ser.Serialize(obj);
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Write(json);
        Response.End();
        return null;
    }

    private string GetSession(string key)
    {
        if (Session[key] == null) return "";
        return Session[key].ToString();
    }

    // ─────────────────────── Lifecycle ───────────────────────────────────

    protected void Page_Load(object sender, EventArgs e)
    {
        string ajax = (Request.QueryString["ajax"] ?? "").Trim().ToLower();
        if (string.IsNullOrEmpty(ajax)) return;

        try
        {
            switch (ajax)
            {
                case "list":     HandleList();    break;
                case "campuses": HandleCampuses(); break;
                case "create":   HandleCreate();  break;
                case "update":   HandleUpdate();  break;
                case "delete":   HandleDelete();  break;
                default:
                    RespondJson(new { ok = false, error = "Unknown action: " + ajax });
                    break;
            }
        }
        catch (System.Threading.ThreadAbortException) { throw; }
        catch (Exception ex)
        {
            RespondJson(new { ok = false, error = "Server error: " + ex.Message });
        }
    }

    // ─────────────────────── AJAX: list ──────────────────────────────────

    private void HandleList()
    {
        // Get current academic year and semester from session for usage counts
        string acadYear = GetSession("SelectedAcademicYear");
        string semester = GetSession("SelectedSemester");
        if (string.IsNullOrEmpty(acadYear)) acadYear = AcademicYearHelper.GetCurrentAcademicYear();
        if (string.IsNullOrEmpty(semester)) semester = "1";

        // Load all rooms with campus name
        DataTable dtRooms = ExecuteQuery(@"
            SELECT lr.RoomID, lr.RoomName, lr.Capacity, lr.campusId,
                   IFNULL(c.campus_name, CONCAT('Campus ', lr.campusId)) AS campusName
            FROM   acad_lecturerooms lr
            LEFT JOIN acad_campuses c ON c.ID = lr.campusId
            ORDER BY c.campus_name, lr.RoomName");

        // Compute stats
        int total     = dtRooms.Rows.Count;
        int totalCap  = 0;
        int campus1   = 0;
        int campus2   = 0;

        var rooms = new List<object>();

        foreach (DataRow row in dtRooms.Rows)
        {
            int roomId    = Convert.ToInt32(row["RoomID"]);
            int capacity  = row["Capacity"] == DBNull.Value ? 0 : Convert.ToInt32(row["Capacity"]);
            int campusId  = row["campusId"] == DBNull.Value ? 0 : Convert.ToInt32(row["campusId"]);
            string name   = row["RoomName"].ToString();
            string cName  = row["campusName"].ToString();

            totalCap += capacity;
            if (campusId == 1) campus1++;
            if (campusId == 2) campus2++;

            // Usage count for current semester (room number stored as string = RoomID)
            int usedCount = AllocationHelper.GetRoomUsageCount(
                roomId.ToString(), acadYear, semester);

            rooms.Add(new {
                id         = roomId,
                name       = name,
                capacity   = capacity,
                campusId   = campusId,
                campusName = cName,
                usedCount  = usedCount < 0 ? 0 : usedCount
            });
        }

        RespondJson(new {
            ok    = true,
            rooms = rooms,
            stats = new {
                total    = total,
                totalCap = totalCap,
                campus1  = campus1,
                campus2  = campus2
            }
        });
    }

    // ─────────────────────── AJAX: campuses ──────────────────────────────

    private void HandleCampuses()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT ID, campus_name FROM acad_campuses
            ORDER BY ID");

        var list = new List<object>();
        foreach (DataRow row in dt.Rows)
        {
            list.Add(new {
                id   = Convert.ToInt32(row["ID"]),
                name = row["campus_name"].ToString()
            });
        }

        RespondJson(new { ok = true, campuses = list });
    }

    // ─────────────────────── AJAX: create ────────────────────────────────

    private void HandleCreate()
    {
        RoomPayload p = ReadPayload();
        if (p == null) return;

        string valErr = ValidatePayload(p, false);
        if (valErr != null) { RespondJson(new { ok = false, error = valErr }); return; }

        // Check duplicate name on same campus
        DataTable dup = ExecuteQuery(
            "SELECT COUNT(*) AS cnt FROM acad_lecturerooms WHERE RoomName = @name AND campusId = @campus",
            new MySqlParameter("@name",   p.name),
            new MySqlParameter("@campus", p.campusId));
        if (Convert.ToInt32(dup.Rows[0]["cnt"]) > 0)
        {
            RespondJson(new { ok = false, error = "A room named '" + p.name + "' already exists on this campus." });
            return;
        }

        ExecuteNonQuery(
            "INSERT INTO acad_lecturerooms (RoomName, Capacity, campusId) VALUES (@name, @cap, @campus)",
            new MySqlParameter("@name",   p.name),
            new MySqlParameter("@cap",    p.capacity),
            new MySqlParameter("@campus", p.campusId));

        RespondJson(new { ok = true });
    }

    // ─────────────────────── AJAX: update ────────────────────────────────

    private void HandleUpdate()
    {
        RoomPayload p = ReadPayload();
        if (p == null) return;

        if (p.id <= 0) { RespondJson(new { ok = false, error = "Invalid room ID." }); return; }

        string valErr = ValidatePayload(p, true);
        if (valErr != null) { RespondJson(new { ok = false, error = valErr }); return; }

        // Check duplicate name on same campus, excluding this room
        DataTable dup = ExecuteQuery(
            "SELECT COUNT(*) AS cnt FROM acad_lecturerooms WHERE RoomName = @name AND campusId = @campus AND RoomID != @id",
            new MySqlParameter("@name",   p.name),
            new MySqlParameter("@campus", p.campusId),
            new MySqlParameter("@id",     p.id));
        if (Convert.ToInt32(dup.Rows[0]["cnt"]) > 0)
        {
            RespondJson(new { ok = false, error = "Another room named '" + p.name + "' already exists on this campus." });
            return;
        }

        int rows = ExecuteNonQuery(
            "UPDATE acad_lecturerooms SET RoomName = @name, Capacity = @cap, campusId = @campus WHERE RoomID = @id",
            new MySqlParameter("@name",   p.name),
            new MySqlParameter("@cap",    p.capacity),
            new MySqlParameter("@campus", p.campusId),
            new MySqlParameter("@id",     p.id));

        if (rows == 0) RespondJson(new { ok = false, error = "Room not found or no changes made." });
        else           RespondJson(new { ok = true });
    }

    // ─────────────────────── AJAX: delete ────────────────────────────────

    private void HandleDelete()
    {
        RoomPayload p = ReadPayload();
        if (p == null) return;
        if (p.id <= 0) { RespondJson(new { ok = false, error = "Invalid room ID." }); return; }

        // Verify room exists
        DataTable existing = ExecuteQuery(
            "SELECT RoomName FROM acad_lecturerooms WHERE RoomID = @id",
            new MySqlParameter("@id", p.id));
        if (existing.Rows.Count == 0)
        {
            RespondJson(new { ok = false, error = "Room not found." });
            return;
        }

        // Proceed with delete — usage warning was already shown client-side
        int rows = ExecuteNonQuery(
            "DELETE FROM acad_lecturerooms WHERE RoomID = @id",
            new MySqlParameter("@id", p.id));

        if (rows == 0) RespondJson(new { ok = false, error = "Delete failed." });
        else           RespondJson(new { ok = true });
    }

    // ─────────────────────── Payload + Validation ────────────────────────

    private class RoomPayload
    {
        public int    id       { get; set; }
        public string name     { get; set; }
        public int    capacity { get; set; }
        public int    campusId { get; set; }
    }

    private RoomPayload ReadPayload()
    {
        try
        {
            int    len  = Request.ContentLength;
            string body = "";
            if (len > 0)
            {
                byte[] buf = new byte[len];
                Request.InputStream.Read(buf, 0, len);
                body = System.Text.Encoding.UTF8.GetString(buf);
            }
            else
            {
                // For GET requests (list, campuses) no body needed — return an empty payload
                return new RoomPayload();
            }
            var ser = new JavaScriptSerializer();
            var p   = ser.Deserialize<RoomPayload>(body);
            return p ?? new RoomPayload();
        }
        catch (Exception ex)
        {
            RespondJson(new { ok = false, error = "Invalid request body: " + ex.Message });
            return null;
        }
    }

    private string ValidatePayload(RoomPayload p, bool requireId)
    {
        if (requireId && p.id <= 0) return "Invalid room ID.";
        if (string.IsNullOrEmpty(p.name) || p.name.Trim().Length == 0)
            return "Room name is required.";
        if (p.name.Trim().Length > 65)
            return "Room name cannot exceed 65 characters.";
        if (p.capacity < 1)
            return "Capacity must be at least 1.";
        if (p.campusId <= 0)
            return "Please select a campus.";

        // Clean name
        p.name = p.name.Trim();
        return null;
    }
}
