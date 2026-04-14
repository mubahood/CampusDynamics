using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

/// <summary>
/// LoadAllocationDashboard.aspx.cs — Code-behind for Load Allocation Dashboard.
///
/// AJAX Endpoints (via ?ajax=...):
///   GET  ?ajax=dashboard — returns all dashboard data in a single response:
///        stats (total, scheduled, unscheduled, lecturers) + year-over-year comparison,
///        alerts (unscheduled, unassigned, collisions),
///        programme coverage, recent activity from audit columns.
///
/// Tables:
///   acad_teaching_allocation — allocation records (stats, coverage, activity)
///   acad_course              — course names (for activity details)
///   hrm_employee             — lecturer names (for activity details)
///   acad_programme           — programme abbreviations (for coverage)
///   acad_programmecourses    — total courses per programme (for coverage)
///   acad_campuses            — campus name
///   AllocationHelper.cs      — collision summary (reuse from Task 9)
///
/// Design Rules:
///   - C# 4.0 compatible: no ?. operator, no string interpolation ($"")
///   - vacConnectionString only
///   - Session from SidebarMaster for acad year, semester, campus
///   - Reuses AllocationHelper.GetCollisionSummary() from Task 9
///   - Year-over-year: compare current semester to same semester of previous year
///
/// Task: LOAD_ALLOCATION_TASKS.md — Task 8
/// Implementation Log: LOAD_ALLOCATION_IMPLEMENTATION_LOG.md
/// Created: 2026-04-10
/// </summary>
public partial class COOPERP_NewScreens_LoadAllocationDashboard : System.Web.UI.Page
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

    private string RespondJson(object obj)
    {
        JavaScriptSerializer ser = new JavaScriptSerializer();
        ser.MaxJsonLength = int.MaxValue;
        string json = ser.Serialize(obj);
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

    private string SafeStr(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int result;
        if (int.TryParse(val.ToString(), out result)) return result;
        return 0;
    }

    // ─────────────────────── Session Context ─────────────────────────────

    private string CurrentAcadYear
    {
        get
        {
            string v = GetSession("SelectedAcademicYear");
            if (string.IsNullOrEmpty(v)) v = AcademicYearHelper.GetCurrentAcademicYear();
            return v;
        }
    }

    private string CurrentSemester
    {
        get
        {
            string v = GetSession("SelectedSemester");
            if (string.IsNullOrEmpty(v)) v = "1";
            return v;
        }
    }

    private string CurrentCampusId
    {
        get
        {
            string v = GetSession("SelectedCampus");
            if (string.IsNullOrEmpty(v)) v = "1";
            return v;
        }
    }

    private string CurrentCampusName
    {
        get
        {
            string v = GetSession("SelectedCampusName");
            if (!string.IsNullOrEmpty(v)) return v;

            // Fallback — look it up
            DataTable dt = ExecuteQuery(
                "SELECT campus_name FROM acad_campuses WHERE ID = @id",
                new MySqlParameter("@id", CurrentCampusId));
            if (dt.Rows.Count > 0) return SafeStr(dt.Rows[0]["campus_name"]);
            return "Campus " + CurrentCampusId;
        }
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
                case "dashboard": HandleDashboard(); break;
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

    // ─────────────────────── AJAX: dashboard ────────────────────────────

    private void HandleDashboard()
    {
        string year   = CurrentAcadYear;
        string sem    = CurrentSemester;
        string campus = CurrentCampusId;

        // ── 1. Current semester stats ────────────────────────────────────
        string statsSql = @"
            SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN ta.lectureday != '-' AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL THEN 1 ELSE 0 END) AS scheduled,
                SUM(CASE WHEN ta.lectureday = '-' OR ta.StartTime IS NULL OR ta.EndTime IS NULL THEN 1 ELSE 0 END) AS unscheduled,
                COUNT(DISTINCT CASE WHEN ta.staffCode != '0' THEN ta.staffCode END) AS lecturers,
                SUM(CASE WHEN ta.staffCode = '0' THEN 1 ELSE 0 END) AS unassignedCount
            FROM acad_teaching_allocation ta
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus";

        DataTable dtStats = ExecuteQuery(statsSql,
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        int totalAlloc    = 0, schedCount = 0, unschedCount = 0, lecturerCount = 0, unassignedCount = 0;
        if (dtStats.Rows.Count > 0)
        {
            DataRow sr = dtStats.Rows[0];
            totalAlloc    = SafeInt(sr["total"]);
            schedCount    = SafeInt(sr["scheduled"]);
            unschedCount  = SafeInt(sr["unscheduled"]);
            lecturerCount = SafeInt(sr["lecturers"]);
            unassignedCount = SafeInt(sr["unassignedCount"]);
        }

        // ── 2. Previous year/semester stats for trend comparison ─────────
        string prevYear = GetPreviousAcadYear(year);
        int prevTotal = 0, prevScheduled = 0, prevUnscheduled = 0, prevLecturers = 0;

        if (!string.IsNullOrEmpty(prevYear))
        {
            DataTable dtPrev = ExecuteQuery(statsSql,
                new MySqlParameter("@year",   prevYear),
                new MySqlParameter("@sem",    sem),
                new MySqlParameter("@campus", campus));

            if (dtPrev.Rows.Count > 0)
            {
                DataRow pr = dtPrev.Rows[0];
                prevTotal       = SafeInt(pr["total"]);
                prevScheduled   = SafeInt(pr["scheduled"]);
                prevUnscheduled = SafeInt(pr["unscheduled"]);
                prevLecturers   = SafeInt(pr["lecturers"]);
            }
        }

        // ── 3. Alerts ───────────────────────────────────────────────────
        var alerts = new List<object>();

        if (unschedCount > 0)
        {
            alerts.Add(new {
                severity = "warn",
                message  = unschedCount + " allocation(s) have no timetable schedule (no day/time set)"
            });
        }

        if (unassignedCount > 0)
        {
            alerts.Add(new {
                severity = "warn",
                message  = unassignedCount + " course(s) have no lecturer assigned (staffCode = 0)"
            });
        }

        // Collision alerts using AllocationHelper
        try
        {
            AllocationHelper.CollisionSummary collisions = AllocationHelper.GetCollisionSummary(year, sem, campus);
            if (collisions.RoomCollisionCount > 0)
            {
                alerts.Add(new {
                    severity = "danger",
                    message  = collisions.RoomCollisionCount + " room collision(s) detected — rooms double-booked at the same time"
                });
            }
            if (collisions.LecturerCollisionCount > 0)
            {
                alerts.Add(new {
                    severity = "danger",
                    message  = collisions.LecturerCollisionCount + " lecturer time conflict(s) detected — lecturers scheduled in multiple places simultaneously"
                });
            }
        }
        catch
        {
            // Silently degrade if collision check fails
        }

        if (alerts.Count == 0)
        {
            alerts.Add(new {
                severity = "info",
                message  = "No issues detected — all allocations look good!"
            });
        }

        // ── 4. Programme Coverage ────────────────────────────────────────
        string covSql = @"
            SELECT p.progcode, IFNULL(p.abbrev, p.progcode) AS progAbbrev,
                   (SELECT COUNT(DISTINCT pc.course_code)
                    FROM acad_programmecourses pc
                    WHERE pc.progcode = p.progcode
                      AND pc.semester = @sem) AS totalCourses,
                   COUNT(DISTINCT ta.courseID) AS allocated,
                   SUM(CASE WHEN ta.lectureday != '-' AND ta.StartTime IS NOT NULL THEN 1 ELSE 0 END) AS scheduled
            FROM acad_programme p
            INNER JOIN acad_teaching_allocation ta ON ta.progcode = p.progcode
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
            GROUP BY p.progcode, p.abbrev
            ORDER BY allocated DESC
            LIMIT 15";

        DataTable dtCov = ExecuteQuery(covSql,
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        var coverage = new List<object>();
        foreach (DataRow row in dtCov.Rows)
        {
            int totalCourses = SafeInt(row["totalCourses"]);
            int allocated    = SafeInt(row["allocated"]);
            // Use allocated as totalCourses fallback if the programmecourses table has no data
            if (totalCourses == 0 && allocated > 0) totalCourses = allocated;

            coverage.Add(new {
                progAbbrev   = SafeStr(row["progAbbrev"]),
                totalCourses = totalCourses,
                allocated    = allocated,
                scheduled    = SafeInt(row["scheduled"])
            });
        }

        // ── 5. Recent Activity (from audit columns) ─────────────────────
        string actSql = @"
            SELECT 'Created' AS action, ta.created_by AS user,
                   CONCAT(IFNULL(c.courseName, ta.courseID), ' → ', IFNULL(p.abbrev, ta.progcode), ' Yr ', ta.cyear) AS details,
                   ta.created_at AS ts
            FROM acad_teaching_allocation ta
            LEFT JOIN acad_course c ON c.courseID = ta.courseID
            LEFT JOIN acad_programme p ON p.progcode = ta.progcode
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
              AND ta.created_at IS NOT NULL AND ta.created_by IS NOT NULL AND ta.created_by != ''
            UNION ALL
            SELECT 'Updated' AS action, ta.updated_by AS user,
                   CONCAT(IFNULL(c.courseName, ta.courseID), ' → ', IFNULL(p.abbrev, ta.progcode), ' Yr ', ta.cyear) AS details,
                   ta.updated_at AS ts
            FROM acad_teaching_allocation ta
            LEFT JOIN acad_course c ON c.courseID = ta.courseID
            LEFT JOIN acad_programme p ON p.progcode = ta.progcode
            WHERE ta.acad_year = @year AND ta.semester = @sem AND ta.campusId = @campus
              AND ta.updated_at IS NOT NULL AND ta.updated_by IS NOT NULL AND ta.updated_by != ''
            ORDER BY ts DESC
            LIMIT 20";

        DataTable dtAct = ExecuteQuery(actSql,
            new MySqlParameter("@year",   year),
            new MySqlParameter("@sem",    sem),
            new MySqlParameter("@campus", campus));

        var activity = new List<object>();
        foreach (DataRow row in dtAct.Rows)
        {
            string timeAgo = FormatTimeAgo(row["ts"]);
            activity.Add(new {
                action  = SafeStr(row["action"]),
                user    = SafeStr(row["user"]),
                details = SafeStr(row["details"]),
                timeAgo = timeAgo
            });
        }

        // ── 6. Respond ──────────────────────────────────────────────────
        RespondJson(new {
            ok               = true,
            acadYear         = year,
            semester         = sem,
            campusId         = campus,
            campusName       = CurrentCampusName,
            totalAllocations = totalAlloc,
            scheduledCount   = schedCount,
            unscheduledCount = unschedCount,
            lecturerCount    = lecturerCount,
            prevTotal        = prevTotal,
            prevScheduled    = prevScheduled,
            prevUnscheduled  = prevUnscheduled,
            prevLecturers    = prevLecturers,
            alerts           = alerts,
            coverage         = coverage,
            activity         = activity
        });
    }

    // ─────────────────────── Utility Methods ─────────────────────────────

    /// <summary>
    /// Compute the previous academic year string.
    /// "2025/2026" → "2024/2025"
    /// </summary>
    private string GetPreviousAcadYear(string currentYear)
    {
        if (string.IsNullOrEmpty(currentYear)) return "";
        string[] parts = currentYear.Split('/');
        if (parts.Length != 2) return "";
        int y1 = 0;
        int y2 = 0;
        if (!int.TryParse(parts[0], out y1) || !int.TryParse(parts[1], out y2)) return "";
        return (y1 - 1) + "/" + (y2 - 1);
    }

    /// <summary>
    /// Format a DateTime value as a human-readable "time ago" string.
    /// </summary>
    private string FormatTimeAgo(object val)
    {
        if (val == null || val == DBNull.Value) return "Unknown";
        DateTime ts;
        if (!DateTime.TryParse(val.ToString(), out ts)) return "Unknown";

        TimeSpan diff = DateTime.Now - ts;

        if (diff.TotalMinutes < 1) return "Just now";
        if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + " min ago";
        if (diff.TotalHours < 24) return (int)diff.TotalHours + " hr ago";
        if (diff.TotalDays < 7) return (int)diff.TotalDays + " day(s) ago";
        return ts.ToString("MMM dd, yyyy");
    }
}
