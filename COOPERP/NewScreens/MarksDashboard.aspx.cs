using System;
using System.Collections.Generic;
using System.Text;
using System.Web.Configuration;
using System.Web.Services;
using System.Web.UI;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_MarksDashboard : Page
{
    private static readonly JavaScriptSerializer Json = new JavaScriptSerializer();

    private string ConnStr
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // AJAX-powered dashboard; no server-side page binding required.
    }

    [WebMethod]
    public static string GetDashboardInit()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();

                List<FilterOption> years = new List<FilterOption>();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT DISTINCT cr.acad_year
                    FROM campus_dynamics_portal.acad_course_registration cr
                    INNER JOIN acad_student s ON s.regno = cr.regno
                    WHERE UPPER(COALESCE(s.new_status,'')) = 'ACTIVE'
                      AND cr.acad_year IS NOT NULL AND TRIM(cr.acad_year) <> ''
                    ORDER BY cr.acad_year DESC", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? string.Empty : rdr.GetString(0);
                        if (!string.IsNullOrEmpty(v)) years.Add(new FilterOption { value = v, text = v });
                    }
                }

                List<FilterOption> programmes = new List<FilterOption>();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT DISTINCT p.progcode, COALESCE(p.progname, p.progcode) AS progname
                    FROM acad_programme p
                    INNER JOIN campus_dynamics_portal.acad_course_registration cr ON cr.prog_id = p.progcode
                    INNER JOIN acad_student s ON s.regno = cr.regno
                    WHERE UPPER(COALESCE(s.new_status,'')) = 'ACTIVE'
                    ORDER BY progname", conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string v = rdr.IsDBNull(0) ? string.Empty : rdr.GetString(0);
                        string t = rdr.IsDBNull(1) ? v : rdr.GetString(1);
                        if (!string.IsNullOrEmpty(v)) programmes.Add(new FilterOption { value = v, text = t });
                    }
                }

                return Json.Serialize(new
                {
                    success = true,
                    years = years,
                    programmes = programmes
                });
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load dashboard filters: " + ex.Message });
        }
    }

    [WebMethod]
    public static string GetDashboardStats(string year, string semester, string programme)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(GetConnStr()))
            {
                conn.Open();
                DashboardStats stats = BuildStats(conn, year, semester, programme);
                return Json.Serialize(new { success = true, stats = stats });
            }
        }
        catch (Exception ex)
        {
            return Json.Serialize(new { success = false, message = "Failed to load dashboard stats: " + ex.Message });
        }
    }

    private static DashboardStats BuildStats(MySqlConnection conn, string year, string semester, string programme)
    {
        string courseExpr = GetCourseColumnExpression(conn, "cr");
        string courseCountSql = string.IsNullOrEmpty(courseExpr)
            ? "0"
            : "COUNT(DISTINCT " + courseExpr + ")";

        // Main stats query (all records)
        StringBuilder sql = new StringBuilder(@"
            SELECT
                COUNT(DISTINCT cr.regno) AS active_students,
                " + courseCountSql + @" AS course_count,
                COUNT(*) AS marks_records,
                SUM(CASE WHEN UPPER(IFNULL(TRIM(cr.provisional_marks_status),'PENDING')) = 'PUBLISHED' THEN 1 ELSE 0 END) AS published_count,
                SUM(CASE WHEN UPPER(IFNULL(TRIM(cr.provisional_marks_status),'')) = 'APPROVED' THEN 1 ELSE 0 END) AS approved_count,
                SUM(CASE WHEN (cr.provisional_course_work_marks IS NOT NULL OR cr.provisional_exam_marks IS NOT NULL)
                              AND UPPER(IFNULL(TRIM(cr.provisional_marks_status),'PENDING')) <> 'PUBLISHED' THEN 1 ELSE 0 END) AS pending_count,
                SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND UPPER(IFNULL(TRIM(cr.provisional_marks_status),'PENDING')) <> 'PUBLISHED' THEN 1 ELSE 0 END) AS missing_coursework_count,
                SUM(CASE WHEN cr.provisional_exam_marks IS NULL AND UPPER(IFNULL(TRIM(cr.provisional_marks_status),'PENDING')) <> 'PUBLISHED' THEN 1 ELSE 0 END) AS missing_exam_count
            FROM campus_dynamics_portal.acad_course_registration cr");

        // Active student stats query
        StringBuilder sqlActive = new StringBuilder(@"
            SELECT
                SUM(CASE WHEN cr.provisional_course_work_marks IS NULL AND UPPER(IFNULL(TRIM(cr.provisional_marks_status),'PENDING')) <> 'PUBLISHED' THEN 1 ELSE 0 END) AS not_entered_cw,
                SUM(CASE WHEN cr.provisional_exam_marks IS NULL AND UPPER(IFNULL(TRIM(cr.provisional_marks_status),'PENDING')) <> 'PUBLISHED' THEN 1 ELSE 0 END) AS not_entered_exam
            FROM campus_dynamics_portal.acad_course_registration cr
            INNER JOIN acad_student s ON s.regno = cr.regno
            WHERE UPPER(COALESCE(s.new_status,'')) = 'ACTIVE'");

        using (MySqlCommand cmd = new MySqlCommand())
        {
            cmd.Connection = conn;

            if (!string.IsNullOrEmpty(year))
            {
                sql.Append(" AND cr.acad_year = @year");
                sqlActive.Append(" AND cr.acad_year = @year");
                cmd.Parameters.AddWithValue("@year", year);
            }
            if (!string.IsNullOrEmpty(semester))
            {
                sql.Append(" AND CAST(cr.semester AS CHAR) = @semester");
                sqlActive.Append(" AND CAST(cr.semester AS CHAR) = @semester");
                cmd.Parameters.AddWithValue("@semester", semester);
            }
            if (!string.IsNullOrEmpty(programme))
            {
                sql.Append(" AND cr.prog_id = @programme");
                sqlActive.Append(" AND cr.prog_id = @programme");
                cmd.Parameters.AddWithValue("@programme", programme);
            }

            cmd.CommandText = sql.ToString();
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                if (!rdr.Read()) return new DashboardStats();
                var stats = new DashboardStats
                {
                    activeStudents = ToInt(rdr[0]),
                    courseCount = ToInt(rdr[1]),
                    marksRecords = ToInt(rdr[2]),
                    publishedCount = ToInt(rdr[3]),
                    approvedCount = ToInt(rdr[4]),
                    pendingCount = ToInt(rdr[5]),
                    missingCourseworkCount = ToInt(rdr[6]),
                    missingExamCount = ToInt(rdr[7])
                };
                rdr.Close();

                // Get active student stats
                cmd.CommandText = sqlActive.ToString();
                using (MySqlDataReader rdrActive = cmd.ExecuteReader())
                {
                    if (rdrActive.Read())
                    {
                        stats.notEnteredCourseworkActive = ToInt(rdrActive[0]);
                        stats.notEnteredExamActive = ToInt(rdrActive[1]);
                    }
                }

                // Get top courses with missing marks
                cmd.CommandText = @"
                    SELECT " + courseExpr + @" AS course, COUNT(*) as missing_count
                    FROM campus_dynamics_portal.acad_course_registration cr
                    INNER JOIN acad_student s ON s.regno = cr.regno
                    WHERE UPPER(COALESCE(s.new_status,'')) = 'ACTIVE'
                      AND (cr.provisional_course_work_marks IS NULL OR cr.provisional_exam_marks IS NULL)
                      AND UPPER(IFNULL(TRIM(cr.provisional_marks_status),'PENDING')) <> 'PUBLISHED'" +
                    (string.IsNullOrEmpty(year) ? "" : " AND cr.acad_year = @year") +
                    (string.IsNullOrEmpty(semester) ? "" : " AND CAST(cr.semester AS CHAR) = @semester") +
                    (string.IsNullOrEmpty(programme) ? "" : " AND cr.prog_id = @programme") +
                    @" GROUP BY " + courseExpr + @" ORDER BY missing_count DESC LIMIT 10";

                using (MySqlDataReader rdrTop = cmd.ExecuteReader())
                {
                    stats.topMissingCourses = new List<TopCourse>();
                    while (rdrTop.Read())
                    {
                        stats.topMissingCourses.Add(new TopCourse
                        {
                            course = rdrTop[0]?.ToString() ?? "-",
                            missingCount = ToInt(rdrTop[1])
                        });
                    }
                }

                return stats;
            }
        }
    }

    private static int ToInt(object value)
    {
        return value == null || value == DBNull.Value ? 0 : Convert.ToInt32(value);
    }

    private static string GetConnStr()
    {
        return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    }

    private static string GetCourseColumnExpression(MySqlConnection conn, string alias)
    {
        string prefix = string.IsNullOrEmpty(alias) ? string.Empty : alias + ".";
        if (ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "courseID"))
            return prefix + "courseID";
        if (ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "course_code"))
            return prefix + "course_code";
        return null;
    }

    private static bool ColumnExists(MySqlConnection conn, string schema, string table, string column)
    {
        const string sql = @"SELECT COUNT(*)
                             FROM information_schema.COLUMNS
                             WHERE TABLE_SCHEMA=@schema AND TABLE_NAME=@table AND COLUMN_NAME=@column";
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@schema", schema);
            cmd.Parameters.AddWithValue("@table", table);
            cmd.Parameters.AddWithValue("@column", column);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    private class FilterOption
    {
        public string value { get; set; }
        public string text { get; set; }
    }

    private class TopCourse
    {
        public string course { get; set; }
        public int missingCount { get; set; }
    }

    private class DashboardStats
    {
        public int activeStudents { get; set; }
        public int courseCount { get; set; }
        public int marksRecords { get; set; }
        public int publishedCount { get; set; }
        public int approvedCount { get; set; }
        public int pendingCount { get; set; }
        public int missingCourseworkCount { get; set; }
        public int missingExamCount { get; set; }
        public int notEnteredCourseworkActive { get; set; }
        public int notEnteredExamActive { get; set; }
        public List<TopCourse> topMissingCourses { get; set; }
    }
}
