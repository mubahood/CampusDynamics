using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_RoomsBuildings : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        TimetableService.EnsureSchema();
    }

    // ── helpers ──
    private static int I(DataRow r, string c) { return r.Table.Columns.Contains(c) && r[c] != DBNull.Value ? Convert.ToInt32(r[c]) : 0; }
    private static string S(DataRow r, string c) { return r.Table.Columns.Contains(c) && r[c] != DBNull.Value ? r[c].ToString() : ""; }
    private static MySqlParameter P(string n, object v) { return new MySqlParameter(n, v == null ? DBNull.Value : v); }

    // ── lookups (campuses + active buildings for the room dropdown) ──
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object GetLookups()
    {
        TimetableService.EnsureSchema();
        List<object> campuses = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT ID, campus_name, campus_short_name FROM acad_campuses ORDER BY ID").Rows)
            campuses.Add(new Dictionary<string, object> { { "id", I(r, "ID") }, { "name", S(r, "campus_name") }, { "shortName", S(r, "campus_short_name") } });
        List<object> buildings = new List<object>();
        foreach (DataRow r in TimetableService.Query("SELECT building_id, building_name, campus_id FROM acad_building WHERE is_active=1 ORDER BY building_name").Rows)
            buildings.Add(new Dictionary<string, object> { { "id", I(r, "building_id") }, { "name", S(r, "building_name") }, { "campusId", I(r, "campus_id") } });
        return new { ok = true, campuses = campuses, buildings = buildings };
    }

    // ── BUILDINGS ──
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object ListBuildings()
    {
        TimetableService.EnsureSchema();
        List<object> rows = new List<object>();
        DataTable dt = TimetableService.Query(
            "SELECT b.building_id, b.building_name, IFNULL(b.building_code,'') building_code, b.campus_id, IFNULL(cp.campus_name,'All campuses') campus_name, " +
            "IFNULL(b.floors,0) floors, IFNULL(b.notes,'') notes, b.is_active, " +
            "(SELECT COUNT(*) FROM acad_lecturerooms r WHERE r.building_id=b.building_id) rooms " +
            "FROM acad_building b LEFT JOIN acad_campuses cp ON cp.ID=b.campus_id ORDER BY b.building_name");
        foreach (DataRow r in dt.Rows)
            rows.Add(new Dictionary<string, object> {
                { "id", I(r, "building_id") }, { "name", S(r, "building_name") }, { "code", S(r, "building_code") },
                { "campusId", I(r, "campus_id") }, { "campusName", S(r, "campus_name") }, { "floors", I(r, "floors") },
                { "notes", S(r, "notes") }, { "active", I(r, "is_active") }, { "rooms", I(r, "rooms") } });
        return new { ok = true, rows = rows };
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object SaveBuilding(int id, string name, string code, int campusId, int floors, string notes, int active)
    {
        TimetableService.EnsureSchema();
        name = (name ?? "").Trim();
        if (name == "") return new { ok = false, message = "Building name is required." };
        try
        {
            if (id > 0)
                TimetableService.Exec("UPDATE acad_building SET building_name=@n, building_code=@c, campus_id=@cp, floors=@f, notes=@no, is_active=@a, updated_at=NOW() WHERE building_id=@id",
                    P("@n", name), P("@c", code), P("@cp", campusId), P("@f", floors), P("@no", notes), P("@a", active == 0 ? 0 : 1), P("@id", id));
            else
            {
                TimetableService.Exec("INSERT INTO acad_building (building_name, building_code, campus_id, floors, notes, is_active, created_at) VALUES (@n,@c,@cp,@f,@no,@a,NOW())",
                    P("@n", name), P("@c", code), P("@cp", campusId), P("@f", floors), P("@no", notes), P("@a", active == 0 ? 0 : 1));
                object nid = TimetableService.Scalar("SELECT LAST_INSERT_ID()");
                id = nid == null || nid == DBNull.Value ? 0 : Convert.ToInt32(nid);
            }
            return new { ok = true, id = id };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object DeleteBuilding(int id)
    {
        TimetableService.EnsureSchema();
        try
        {
            TimetableService.Exec("UPDATE acad_lecturerooms SET building_id=NULL WHERE building_id=@id", P("@id", id));
            TimetableService.Exec("DELETE FROM acad_building WHERE building_id=@id", P("@id", id));
            return new { ok = true };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    // ── ROOMS (extend the legacy acad_lecturerooms) ──
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object ListRooms()
    {
        TimetableService.EnsureSchema();
        List<object> rows = new List<object>();
        DataTable dt = TimetableService.Query(
            "SELECT r.RoomID, r.RoomName, IFNULL(r.Capacity,0) Capacity, IFNULL(r.campusId,0) campusId, IFNULL(cp.campus_name,'All campuses') campus_name, " +
            "IFNULL(r.building_id,0) building_id, IFNULL(b.building_name,'') building_name, IFNULL(r.room_type,'') room_type, IFNULL(r.is_active,1) is_active " +
            "FROM acad_lecturerooms r LEFT JOIN acad_campuses cp ON cp.ID=r.campusId LEFT JOIN acad_building b ON b.building_id=r.building_id ORDER BY r.RoomName");
        foreach (DataRow r in dt.Rows)
            rows.Add(new Dictionary<string, object> {
                { "id", I(r, "RoomID") }, { "name", S(r, "RoomName") }, { "capacity", I(r, "Capacity") },
                { "campusId", I(r, "campusId") }, { "campusName", S(r, "campus_name") }, { "buildingId", I(r, "building_id") },
                { "buildingName", S(r, "building_name") }, { "roomType", S(r, "room_type") }, { "active", I(r, "is_active") } });
        return new { ok = true, rows = rows };
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object SaveRoom(int id, string name, int capacity, int campusId, int buildingId, string roomType, int active)
    {
        TimetableService.EnsureSchema();
        name = (name ?? "").Trim();
        if (name == "") return new { ok = false, message = "Room name is required." };
        try
        {
            object bId = buildingId > 0 ? (object)buildingId : null;
            if (id > 0)
                TimetableService.Exec("UPDATE acad_lecturerooms SET RoomName=@n, Capacity=@cap, campusId=@cp, building_id=@b, room_type=@rt, is_active=@a WHERE RoomID=@id",
                    P("@n", name), P("@cap", capacity), P("@cp", campusId), P("@b", bId), P("@rt", roomType), P("@a", active == 0 ? 0 : 1), P("@id", id));
            else
            {
                // acad_lecturerooms.RoomID is a plain int (legacy, not auto-increment) — allocate MAX+1.
                object mx = TimetableService.Scalar("SELECT IFNULL(MAX(RoomID),0)+1 FROM acad_lecturerooms");
                id = mx == null || mx == DBNull.Value ? 1 : Convert.ToInt32(mx);
                TimetableService.Exec("INSERT INTO acad_lecturerooms (RoomID, RoomName, Capacity, campusId, building_id, room_type, is_active) VALUES (@id,@n,@cap,@cp,@b,@rt,@a)",
                    P("@id", id), P("@n", name), P("@cap", capacity), P("@cp", campusId), P("@b", bId), P("@rt", roomType), P("@a", active == 0 ? 0 : 1));
            }
            return new { ok = true, id = id };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object DeleteRoom(int id)
    {
        TimetableService.EnsureSchema();
        try
        {
            object used = TimetableService.Scalar("SELECT COUNT(*) FROM acad_timetable_item WHERE room_id=@id AND status='ACTIVE'", P("@id", id));
            if (used != null && Convert.ToInt64(used) > 0)
                return new { ok = false, message = "This room is used by active timetable sessions. Reassign or cancel them first." };
            TimetableService.Exec("DELETE FROM acad_lecturerooms WHERE RoomID=@id", P("@id", id));
            return new { ok = true };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }

    // ── Find free rooms for a slot ──
    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static object FindFreeRooms(string acadYear, int dayNo, string start, int durationMin, int campusId, int minCapacity)
    {
        TimetableService.EnsureSchema();
        try
        {
            string st = TimetableService.NormTime(start);
            string et = TimetableService.EndTime(start, durationMin);
            string campusFilter = campusId > 0 ? " AND (r.campusId=@cp OR r.campusId=0) " : "";
            List<MySqlParameter> ps = new List<MySqlParameter> {
                P("@ay", acadYear), P("@day", dayNo), P("@st", st), P("@et", et), P("@cap", minCapacity)
            };
            if (campusId > 0) ps.Add(P("@cp", campusId));
            DataTable dt = TimetableService.Query(
                "SELECT r.RoomID, r.RoomName, IFNULL(r.Capacity,0) Capacity, IFNULL(b.building_name,'') bn, IFNULL(cp.campus_name,'') cn " +
                "FROM acad_lecturerooms r LEFT JOIN acad_building b ON b.building_id=r.building_id LEFT JOIN acad_campuses cp ON cp.ID=r.campusId " +
                "WHERE IFNULL(r.is_active,1)=1 AND IFNULL(r.Capacity,0)>=@cap " + campusFilter +
                "AND NOT EXISTS (SELECT 1 FROM acad_timetable_item it WHERE it.room_id=r.RoomID AND it.status='ACTIVE' AND it.acad_year=@ay AND it.day_no=@day AND it.start_time < @et AND @st < it.end_time) " +
                "ORDER BY r.Capacity, r.RoomName", ps.ToArray());
            List<object> rooms = new List<object>();
            foreach (DataRow r in dt.Rows)
                rooms.Add(new Dictionary<string, object> { { "id", I(r, "RoomID") }, { "name", S(r, "RoomName") }, { "capacity", I(r, "Capacity") }, { "building", S(r, "bn") }, { "campus", S(r, "cn") } });
            return new { ok = true, rooms = rooms };
        }
        catch (Exception ex) { return new { ok = false, message = ex.Message }; }
    }
}
