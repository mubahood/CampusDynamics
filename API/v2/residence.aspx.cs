using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class API_v2_residence : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (ApiHelper.HandleCors(Request, Response)) return;
        if (ApiHelper.IsRateLimited(Request, Response)) return;

        string action = ApiHelper.Param(Request, "action", "").ToLower();

        try
        {
            switch (action)
            {
                case "halls":           HandleHalls();          break;
                case "allocations":     HandleAllocations();    break;
                case "allocate":        HandleAllocate();       break;
                case "deallocate":      HandleDeallocate();     break;
                case "residence_stats": HandleResidenceStats(); break;
                default:
                    ApiHelper.Error(Response,
                        "Unknown action: " + action + ". Valid actions: halls, allocations, allocate, deallocate, residence_stats",
                        "INVALID_ACTION");
                    break;
            }
        }
        catch (Exception ex)
        {
            ApiHelper.Error(Response, "Internal server error: " + ex.Message, "SERVER_ERROR");
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HALLS  — list halls with capacity + current occupancy
    // ═══════════════════════════════════════════════════════════════════

    private void HandleHalls()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        int semester    = ApiHelper.ParamInt(Request, "semester", 0);

        string occWhere = " WHERE 1=1";
        var occParms = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(acadYear)) { occWhere += " AND r.acadyear = @ay"; occParms.Add(new MySqlParameter("@ay", acadYear)); }
        if (semester > 0) { occWhere += " AND r.semester = @sem"; occParms.Add(new MySqlParameter("@sem", semester)); }

        DataTable dt = ApiHelper.Query(
            @"SELECT h.id AS hall_id, h.hall_name, h.hall_capacity,
                     COALESCE(occ.occupied, 0) AS occupied,
                     h.hall_capacity - COALESCE(occ.occupied, 0) AS available,
                     CASE WHEN h.hall_capacity > 0
                          THEN ROUND(COALESCE(occ.occupied, 0) * 100.0 / h.hall_capacity, 1)
                          ELSE 0 END AS occupancy_pct
              FROM acad_halls h
              LEFT JOIN (
                  SELECT hall_id, COUNT(*) AS occupied
                  FROM acad_residence r" + occWhere + @"
                  GROUP BY hall_id
              ) occ ON occ.hall_id = h.id
              ORDER BY h.hall_name",
            occParms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total_halls", dt.Rows.Count },
            { "halls", ApiHelper.TableToList(dt) }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ALLOCATIONS  — all allocations for a year/semester
    // ═══════════════════════════════════════════════════════════════════

    private void HandleAllocations()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        int semester    = ApiHelper.ParamInt(Request, "semester", 0);
        string prog     = ApiHelper.Param(Request, "prog", "");
        int hallId      = ApiHelper.ParamInt(Request, "hall_id", 0);
        string q        = ApiHelper.Param(Request, "q", "");
        int page        = Math.Max(1, ApiHelper.ParamInt(Request, "page", 1));
        int size        = Math.Min(100, Math.Max(1, ApiHelper.ParamInt(Request, "size", 20)));
        int offset      = (page - 1) * size;

        var where = new StringBuilder("WHERE 1=1");
        var parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(acadYear)) { where.Append(" AND r.acadyear = @ay"); parms.Add(new MySqlParameter("@ay", acadYear)); }
        if (semester > 0) { where.Append(" AND r.semester = @sem"); parms.Add(new MySqlParameter("@sem", semester)); }
        if (hallId > 0) { where.Append(" AND r.hall_id = @hid"); parms.Add(new MySqlParameter("@hid", hallId)); }
        if (!string.IsNullOrEmpty(prog)) { where.Append(" AND s.progid = @prog"); parms.Add(new MySqlParameter("@prog", prog)); }
        if (!string.IsNullOrEmpty(q))
        {
            where.Append(" AND (r.regno LIKE @q OR s.firstname LIKE @q OR s.othername LIKE @q)");
            parms.Add(new MySqlParameter("@q", "%" + q + "%"));
        }

        string baseFrom = @"FROM acad_residence r
                            LEFT JOIN acad_student s ON TRIM(s.regno) = TRIM(r.regno)
                            LEFT JOIN acad_halls h ON h.id = r.hall_id " + where;

        var countParms = new List<MySqlParameter>(parms);
        int total = Convert.ToInt32(ApiHelper.Scalar("SELECT COUNT(*) " + baseFrom, countParms.ToArray()));

        parms.Add(new MySqlParameter("@lim", size));
        parms.Add(new MySqlParameter("@off", offset));

        DataTable dt = ApiHelper.Query(
            @"SELECT r.id AS allocation_id, r.regno,
                     CONCAT(TRIM(COALESCE(s.firstname,'')), ' ', TRIM(COALESCE(s.othername,''))) AS student_name,
                     s.progid AS programme_code, r.hall_id, h.hall_name,
                     r.room_id, r.acadyear, r.semester
              " + baseFrom + " ORDER BY h.hall_name, r.room_id LIMIT @lim OFFSET @off",
            parms.ToArray());

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total", total }, { "page", page }, { "size", size },
            { "pages", (int)Math.Ceiling(total / (double)size) },
            { "allocations", ApiHelper.TableToList(dt) }
        });
    }

    // ═══════════════════════════════════════════════════════════════════
    //  ALLOCATE  — assign student to hall/room
    // ═══════════════════════════════════════════════════════════════════

    private void HandleAllocate()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string regno  = ApiHelper.RequireParam(Request, Response, "regno"); if (regno == null) return;
        int hallId    = ApiHelper.ParamInt(Request, "hall_id", 0);
        if (hallId <= 0) { ApiHelper.Error(Response, "hall_id is required.", "MISSING_PARAM"); return; }
        string roomId = ApiHelper.Param(Request, "room_id", "");
        string acadYear = ApiHelper.RequireParam(Request, Response, "acad_year"); if (acadYear == null) return;
        int semester  = ApiHelper.ParamInt(Request, "semester", 1);

        // Check hall capacity
        DataTable hallDt = ApiHelper.Query(
            "SELECT hall_name, hall_capacity FROM acad_halls WHERE id = @id LIMIT 1",
            new MySqlParameter("@id", hallId));
        if (hallDt.Rows.Count == 0) { ApiHelper.Error(Response, "Hall not found.", "NOT_FOUND"); return; }

        int capacity = Convert.ToInt32(hallDt.Rows[0]["hall_capacity"]);
        int occupied = Convert.ToInt32(ApiHelper.Scalar(
            "SELECT COUNT(*) FROM acad_residence WHERE hall_id = @hid AND acadyear = @ay AND semester = @sem",
            new MySqlParameter("@hid", hallId),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sem", semester)));

        if (capacity > 0 && occupied >= capacity)
        {
            ApiHelper.Error(Response, "Hall is at full capacity (" + capacity + " rooms).", "HALL_FULL"); return;
        }

        // Check if student already allocated this semester
        object existingAlloc = ApiHelper.Scalar(
            "SELECT COUNT(*) FROM acad_residence WHERE TRIM(regno) = TRIM(@r) AND acadyear = @ay AND semester = @sem",
            new MySqlParameter("@r",   regno),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sem", semester));
        if (Convert.ToInt32(existingAlloc) > 0)
        {
            ApiHelper.Error(Response, "Student is already allocated for this semester. Deallocate first.", "ALREADY_ALLOCATED"); return;
        }

        ApiHelper.Execute(
            "INSERT INTO acad_residence (regno, hall_id, room_id, acadyear, semester) VALUES (@r, @hid, @rid, @ay, @sem)",
            new MySqlParameter("@r",   regno),
            new MySqlParameter("@hid", hallId),
            new MySqlParameter("@rid", string.IsNullOrEmpty(roomId) ? (object)DBNull.Value : roomId),
            new MySqlParameter("@ay",  acadYear),
            new MySqlParameter("@sem", semester));

        // Update acad_registration.residence_status
        try
        {
            ApiHelper.Execute(
                "UPDATE acad_registration SET residence_status = 'RESIDENT' WHERE TRIM(regno) = TRIM(@r) AND acad_year = @ay AND semester = @sem",
                new MySqlParameter("@r",   regno),
                new MySqlParameter("@ay",  acadYear),
                new MySqlParameter("@sem", semester));
        }
        catch { }

        int allocId = Convert.ToInt32(ApiHelper.Scalar("SELECT LAST_INSERT_ID()"));

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "allocation_id", allocId }, { "regno", regno }, { "hall_id", hallId },
            { "hall_name", hallDt.Rows[0]["hall_name"].ToString() },
            { "room_id", roomId }, { "acad_year", acadYear }, { "semester", semester }
        }, "Student allocated to hall");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DEALLOCATE  — remove student from hall
    // ═══════════════════════════════════════════════════════════════════

    private void HandleDeallocate()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string regno    = ApiHelper.RequireParam(Request, Response, "regno"); if (regno == null) return;
        string acadYear = ApiHelper.RequireParam(Request, Response, "acad_year"); if (acadYear == null) return;
        int semester    = ApiHelper.ParamInt(Request, "semester", 1);

        object existing = ApiHelper.Scalar(
            "SELECT COUNT(*) FROM acad_residence WHERE TRIM(regno) = TRIM(@r) AND acadyear = @ay AND semester = @sem",
            new MySqlParameter("@r", regno), new MySqlParameter("@ay", acadYear), new MySqlParameter("@sem", semester));

        if (Convert.ToInt32(existing) == 0)
        {
            ApiHelper.Error(Response, "No allocation found for this student and semester.", "NOT_FOUND"); return;
        }

        ApiHelper.Execute(
            "DELETE FROM acad_residence WHERE TRIM(regno) = TRIM(@r) AND acadyear = @ay AND semester = @sem",
            new MySqlParameter("@r", regno), new MySqlParameter("@ay", acadYear), new MySqlParameter("@sem", semester));

        // Revert residence_status
        try
        {
            ApiHelper.Execute(
                "UPDATE acad_registration SET residence_status = 'NON-RESIDENT' WHERE TRIM(regno) = TRIM(@r) AND acad_year = @ay AND semester = @sem",
                new MySqlParameter("@r", regno), new MySqlParameter("@ay", acadYear), new MySqlParameter("@sem", semester));
        }
        catch { }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "regno", regno }, { "acad_year", acadYear }, { "semester", semester }
        }, "Allocation removed");
    }

    // ═══════════════════════════════════════════════════════════════════
    //  RESIDENCE_STATS  — occupancy summary per hall
    // ═══════════════════════════════════════════════════════════════════

    private void HandleResidenceStats()
    {
        TokenInfo auth = TokenManager.RequireAuth(Request, Response);
        if (auth == null) return;
        if (auth.UserType != "staff") { ApiHelper.Error(Response, "Staff access required.", "FORBIDDEN"); return; }

        string acadYear = ApiHelper.Param(Request, "acad_year", "");
        int semester    = ApiHelper.ParamInt(Request, "semester", 0);

        string occFilter = " WHERE 1=1";
        var parms = new List<MySqlParameter>();
        if (!string.IsNullOrEmpty(acadYear)) { occFilter += " AND r.acadyear = @ay"; parms.Add(new MySqlParameter("@ay", acadYear)); }
        if (semester > 0) { occFilter += " AND r.semester = @sem"; parms.Add(new MySqlParameter("@sem", semester)); }

        DataTable dt = ApiHelper.Query(
            @"SELECT h.id AS hall_id, h.hall_name, h.hall_capacity,
                     COALESCE(occ.occupied, 0) AS occupied,
                     h.hall_capacity - COALESCE(occ.occupied, 0) AS available,
                     CASE WHEN h.hall_capacity > 0
                          THEN ROUND(COALESCE(occ.occupied, 0) * 100.0 / h.hall_capacity, 1)
                          ELSE 0 END AS occupancy_pct
              FROM acad_halls h
              LEFT JOIN (
                  SELECT hall_id, COUNT(*) AS occupied FROM acad_residence r" + occFilter + " GROUP BY hall_id
              ) occ ON occ.hall_id = h.id
              ORDER BY occupancy_pct DESC",
            parms.ToArray());

        var halls = ApiHelper.TableToList(dt);
        int totalCapacity = 0, totalOccupied = 0;
        foreach (var h in halls)
        {
            totalCapacity += Convert.ToInt32(h["hall_capacity"]);
            totalOccupied += Convert.ToInt32(h["occupied"]);
        }

        ApiHelper.Success(Response, new Dictionary<string, object>
        {
            { "total_capacity", totalCapacity },
            { "total_occupied", totalOccupied },
            { "total_available", totalCapacity - totalOccupied },
            { "overall_occupancy_pct", totalCapacity > 0 ? Math.Round(totalOccupied * 100.0 / totalCapacity, 1) : 0.0 },
            { "halls", halls }
        });
    }
}
