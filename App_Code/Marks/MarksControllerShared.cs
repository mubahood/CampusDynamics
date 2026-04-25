using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public static class MarksControllerShared
{
    private const int DefaultPageSize = 100;
    private const string StatusPending = "pending";
    private const string StatusApproved = "approved";
    private const string StatusRejected = "rejected";
    private const string StatusPublished = "published";
    private const string StatusNotEntered = "not_entered";
    private const string ActionUnpublish = "unpublish";
    private const string ActionReprocess = "reprocess";

    private sealed class ProvisionalActionResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public decimal SemesterGpa { get; set; }
        public decimal Cgpa { get; set; }
        public string AwardClass { get; set; }
    }

    public static string ConnectionString
    {
        get { return WebConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    public static void EnsureProvisionalColumns(MySqlConnection conn)
    {
        const string schema = "campus_dynamics_portal";
        const string table = "acad_course_registration";
        try { EnsureNullableColumn(conn, schema, table, "provisional_course_work_marks", "INT NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_exam_marks", "INT NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_total_marks", "INT NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_marks_status", "VARCHAR(20) NULL DEFAULT 'pending'"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_marks_review_comments", "TEXT NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_marks_reviewed_by", "VARCHAR(150) NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_marks_review_date", "DATETIME NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_submitted_by", "VARCHAR(150) NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_published_by", "VARCHAR(150) NULL"); } catch { }
        try { EnsureNullableColumn(conn, schema, table, "provisional_published_date", "DATETIME NULL"); } catch { }
    }

    public static void LoadFilters(HttpRequest request, MySqlConnection conn,
        DropDownList ddlYear, DropDownList ddlSemester, DropDownList ddlStatus, DropDownList ddlProg,
        DropDownList ddlLecturer, DropDownList ddlPageSize, TextBox txtSearch, AdminMarksPageKind kind)
    {
        ddlYear.Items.Clear();
        ddlYear.Items.Add(new ListItem("All Years", ""));
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT DISTINCT acad_year FROM campus_dynamics_portal.acad_course_registration WHERE acad_year IS NOT NULL AND acad_year <> '' ORDER BY acad_year DESC", conn))
        using (MySqlDataReader rdr = cmd.ExecuteReader())
        {
            while (rdr.Read())
                ddlYear.Items.Add(new ListItem(rdr.GetString(0)));
        }

        ddlProg.Items.Clear();
        ddlProg.Items.Add(new ListItem("All Programmes", ""));
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT DISTINCT p.progcode, COALESCE(p.progname, p.progcode) FROM acad_programme p INNER JOIN campus_dynamics_portal.acad_course_registration cr ON cr.prog_id = p.progcode ORDER BY 2", conn))
        using (MySqlDataReader rdr = cmd.ExecuteReader())
        {
            while (rdr.Read())
                ddlProg.Items.Add(new ListItem(rdr.GetString(1), rdr.GetString(0)));
        }

        ddlLecturer.Items.Clear();
        ddlLecturer.Items.Add(new ListItem("All Lecturers", ""));
        try
        {
            using (MySqlCommand cmd = new MySqlCommand(
                "SELECT DISTINCT e.empID, COALESCE(TRIM(e.emp_name),'') AS lname " +
                "FROM hrm_employee e " +
                "INNER JOIN acad_programmecourses pc ON pc.lecturer_id = e.empID " +
                "WHERE pc.lecturer_id IS NOT NULL AND pc.lecturer_id > 0 " +
                "ORDER BY lname", conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    string lname = rdr.IsDBNull(1) ? "" : rdr.GetString(1).Trim();
                    if (!string.IsNullOrEmpty(lname))
                        ddlLecturer.Items.Add(new ListItem(lname, rdr.GetString(0)));
                }
            }
        }
        catch { }

        ConfigureStatusDropdown(ddlStatus, kind);

        string qYear = request.QueryString["year"] ?? "";
        string qSem = request.QueryString["sem"] ?? "";
        string qStatus = GetDefaultStatus(kind, request.QueryString["status"] ?? "");
        string qProg = request.QueryString["prog"] ?? "";
        string qLect = request.QueryString["lect"] ?? "";
        string qSearch = request.QueryString["q"] ?? "";
        string qPs = request.QueryString["ps"] ?? "";

        SafeSelect(ddlYear, qYear);
        SafeSelect(ddlSemester, qSem);
        SafeSelect(ddlStatus, qStatus);
        SafeSelect(ddlProg, qProg);
        SafeSelect(ddlLecturer, qLect);
        SafeSelect(ddlPageSize, qPs);
        txtSearch.Text = qSearch;
    }

    public static void LoadStats(MySqlConnection conn, Literal litStatTotal, Literal litPending, Literal litApproved, Literal litRejected, Literal litPublished, Literal litNotEntered)
    {
        string sql = @"
            SELECT
                COUNT(*) AS cnt_total,
                SUM(CASE WHEN provisional_course_work_marks IS NULL AND provisional_exam_marks IS NULL THEN 1 ELSE 0 END) AS cnt_not_entered,
                SUM(CASE WHEN (provisional_course_work_marks IS NOT NULL OR provisional_exam_marks IS NOT NULL)
                              AND COALESCE(provisional_marks_status,'pending') = 'pending' THEN 1 ELSE 0 END) AS cnt_pending,
                SUM(CASE WHEN provisional_marks_status = 'approved' THEN 1 ELSE 0 END) AS cnt_approved,
                SUM(CASE WHEN provisional_marks_status = 'rejected' THEN 1 ELSE 0 END) AS cnt_rejected,
                SUM(CASE WHEN provisional_marks_status = 'published' THEN 1 ELSE 0 END) AS cnt_published
            FROM campus_dynamics_portal.acad_course_registration";

        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        using (MySqlDataReader rdr = cmd.ExecuteReader())
        {
            if (rdr.Read())
            {
                litStatTotal.Text = (rdr.IsDBNull(0) ? 0 : Convert.ToInt32(rdr[0])).ToString();
                litNotEntered.Text = (rdr.IsDBNull(1) ? 0 : Convert.ToInt32(rdr[1])).ToString();
                litPending.Text = (rdr.IsDBNull(2) ? 0 : Convert.ToInt32(rdr[2])).ToString();
                litApproved.Text = (rdr.IsDBNull(3) ? 0 : Convert.ToInt32(rdr[3])).ToString();
                litRejected.Text = (rdr.IsDBNull(4) ? 0 : Convert.ToInt32(rdr[4])).ToString();
                litPublished.Text = (rdr.IsDBNull(5) ? 0 : Convert.ToInt32(rdr[5])).ToString();
            }
        }
    }

    public static void BindGrid(HttpRequest request, MySqlConnection conn,
        DropDownList ddlYear, DropDownList ddlSemester, DropDownList ddlStatus, DropDownList ddlProg,
        DropDownList ddlLecturer, DropDownList ddlPageSize, TextBox txtSearch,
        Literal litRows, Literal litFrom, Literal litTo, Literal litTotal, Literal litTotal2,
        Literal litPage, Literal litPageCount, Literal litPager, Literal litPager2,
        AdminMarksPageKind kind)
    {
        int page = 1;
        if (!string.IsNullOrEmpty(request.QueryString["pg"])) int.TryParse(request.QueryString["pg"], out page);
        if (page < 1) page = 1;

        int pageSize = DefaultPageSize;
        if (!string.IsNullOrEmpty(ddlPageSize.SelectedValue)) int.TryParse(ddlPageSize.SelectedValue, out pageSize);
        if (pageSize < 1) pageSize = DefaultPageSize;

        string year = ddlYear.SelectedValue;
        string sem = ddlSemester.SelectedValue;
        string status = GetEffectiveStatus(kind, ddlStatus.SelectedValue);
        string prog = ddlProg.SelectedValue;
        string lect = ddlLecturer.SelectedValue;
        string search = txtSearch.Text.Trim();
        string courseCol = GetCourseColumnExpression(conn, "cr");

        if (string.IsNullOrEmpty(courseCol))
        {
            litRows.Text = "<tr><td colspan='14' style='padding:16px;color:#b42318;font-size:11px;'>Course column not found on acad_course_registration.</td></tr>";
            litFrom.Text = litTo.Text = litTotal.Text = litTotal2.Text = "0";
            litPage.Text = litPageCount.Text = "1";
            litPager.Text = litPager2.Text = "";
            return;
        }

        bool useStatusParam = false;
        StringBuilder where = BuildGridWhere(kind, status, ref useStatusParam);

        if (!string.IsNullOrEmpty(year)) where.Append(" AND cr.acad_year = @year");
        if (!string.IsNullOrEmpty(sem)) where.Append(" AND cr.semester = @sem");
        if (!string.IsNullOrEmpty(prog)) where.Append(" AND cr.prog_id = @prog");
        if (!string.IsNullOrEmpty(search))
            where.Append(" AND (cr.regno LIKE @q OR " + courseCol + " LIKE @q OR TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) LIKE @q)");
        if (!string.IsNullOrEmpty(lect))
            where.Append(" AND EXISTS (SELECT 1 FROM acad_programmecourses pc2 WHERE pc2.lecturer_id = @lect AND pc2.course_code = " + courseCol + " AND pc2.progcode = cr.prog_id)");

        string joins = @"
            FROM campus_dynamics_portal.acad_course_registration cr
            LEFT JOIN acad_student s ON s.regno = cr.regno
            LEFT JOIN acad_course c ON c.courseID = " + courseCol + @"
            LEFT JOIN (
                SELECT course_code, progcode, MAX(lecturer_id) AS lecturer_id
                FROM acad_programmecourses
                WHERE lecturer_id IS NOT NULL AND lecturer_id > 0
                GROUP BY course_code, progcode
            ) pc ON pc.course_code = " + courseCol + @" AND pc.progcode = cr.prog_id
            LEFT JOIN hrm_employee e ON e.empID = pc.lecturer_id";

        int total;
        using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) " + joins + " " + where.ToString(), conn))
        {
            AddParams(cmd, year, sem, prog, status, useStatusParam, lect, search);
            total = Convert.ToInt32(cmd.ExecuteScalar());
        }

        int pageCount = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
        if (page > pageCount) page = pageCount;
        int offset = (page - 1) * pageSize;

        string dataSql = @"
            SELECT cr.id, cr.regno,
                   TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                   COALESCE(cr.prog_id,'') AS prog_id,
                   " + courseCol + @" AS courseID,
                   COALESCE(c.courseName, " + courseCol + @") AS course_name,
                   cr.acad_year, cr.semester,
                   COALESCE((SELECT MAX(r2.studyyear) FROM acad_registration r2 WHERE r2.regno=cr.regno AND r2.acad_year=cr.acad_year AND r2.semester=cr.semester),1) AS study_year,
                   cr.provisional_course_work_marks,
                   cr.provisional_exam_marks,
                   cr.provisional_total_marks,
                   (SELECT ar3.score FROM acad_results ar3 WHERE ar3.regno=cr.regno AND ar3.courseid=" + courseCol + @" AND ar3.semester=cr.semester AND ar3.acad=cr.acad_year ORDER BY ar3.ID DESC LIMIT 1) AS published_mark,
                   (SELECT ar4.grade FROM acad_results ar4 WHERE ar4.regno=cr.regno AND ar4.courseid=" + courseCol + @" AND ar4.semester=cr.semester AND ar4.acad=cr.acad_year ORDER BY ar4.ID DESC LIMIT 1) AS published_grade,
                   CASE
                     WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL THEN 'not_entered'
                     ELSE COALESCE(cr.provisional_marks_status,'pending')
                   END AS prov_status
            " + joins + " " + where.ToString() + @"
            ORDER BY cr.id DESC
            LIMIT @offset, @pageSize";

        StringBuilder sb = new StringBuilder();
        using (MySqlCommand cmd = new MySqlCommand(dataSql, conn))
        {
            AddParams(cmd, year, sem, prog, status, useStatusParam, lect, search);
            cmd.Parameters.AddWithValue("@offset", offset);
            cmd.Parameters.AddWithValue("@pageSize", pageSize);
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    int id = Convert.ToInt32(rdr["id"]);
                    string regno = rdr["regno"].ToString();
                    string studentName = rdr["student_name"].ToString().Trim();
                    string courseID = rdr["courseID"].ToString();
                    string courseName = rdr["course_name"].ToString();
                    string progId = rdr["prog_id"].ToString();
                    string acadYear = rdr["acad_year"].ToString();
                    string semester = rdr["semester"].ToString();
                    string studyYear = rdr["study_year"].ToString();
                    string provStatus = NormalizeStatus(rdr["prov_status"].ToString());
                    string cwMarks = rdr.IsDBNull(rdr.GetOrdinal("provisional_course_work_marks")) ? null : rdr["provisional_course_work_marks"].ToString();
                    string exMarks = rdr.IsDBNull(rdr.GetOrdinal("provisional_exam_marks")) ? null : rdr["provisional_exam_marks"].ToString();
                    string totMarks = rdr.IsDBNull(rdr.GetOrdinal("provisional_total_marks")) ? null : rdr["provisional_total_marks"].ToString();
                    string pubMark = rdr.IsDBNull(rdr.GetOrdinal("published_mark")) ? "-" : rdr["published_mark"].ToString();
                    string pubGrade = rdr.IsDBNull(rdr.GetOrdinal("published_grade")) ? "-" : rdr["published_grade"].ToString();

                    string pillCss = "pm-pill--pending";
                    string rowCss = "row--pending";
                    switch (provStatus)
                    {
                        case StatusApproved: pillCss = "pm-pill--approved"; rowCss = "row--approved"; break;
                        case StatusRejected: pillCss = "pm-pill--rejected"; rowCss = "row--rejected"; break;
                        case StatusPublished: pillCss = "pm-pill--published"; rowCss = "row--published"; break;
                        case StatusNotEntered: pillCss = "pm-pill--not_entered"; rowCss = string.Empty; break;
                    }

                    Func<string, string> markCell = delegate(string v)
                    {
                        return v != null ? "<span class='pm-mark'>" + HtmlEnc(v) + "</span>" : "<span class='pm-mark pm-mark--na'>&mdash;</span>";
                    };

                    sb.AppendFormat("<tr class='{0}'>", rowCss);
                    sb.AppendFormat("<td class='col-sel pm-center'><input type='checkbox' class='pm-row-chk pm-row-sel' value='{0}' title='Select for batch action' /></td>", id);
                    sb.AppendFormat("<td class='col-regno' title='{0}'><span class='pm-code pm-ellipsis'>{0}</span></td>", HtmlEnc(regno));
                    sb.AppendFormat("<td class='col-student' title='{0}'><span class='pm-ellipsis'>{0}</span></td>", HtmlEnc(studentName));
                    sb.AppendFormat("<td class='col-course' title='{1}'><span class='pm-code pm-ellipsis'>{0}</span></td>", HtmlEnc(courseID), HtmlEnc(courseName));
                    sb.AppendFormat("<td class='col-prog pm-muted'><span class='pm-ellipsis'>{0}</span></td>", HtmlEnc(progId));
                    sb.AppendFormat("<td class='col-yr pm-muted'>{0}</td>", HtmlEnc(acadYear));
                    sb.AppendFormat("<td class='col-sem pm-muted'><strong>Yr {0}, Sem {1}</strong></td>", HtmlEnc(studyYear), HtmlEnc(semester));
                    sb.AppendFormat("<td class='col-mark pm-center'>{0}</td>", markCell(cwMarks));
                    sb.AppendFormat("<td class='col-mark pm-center'>{0}</td>", markCell(exMarks));
                    sb.AppendFormat("<td class='col-mark pm-center'>{0}</td>", markCell(totMarks));
                    sb.AppendFormat("<td class='col-pub pm-center'><span class='pm-mark'>{0}</span></td>", HtmlEnc(pubMark));
                    sb.AppendFormat("<td class='col-grade pm-center'><span class='pm-mark'>{0}</span></td>", HtmlEnc(pubGrade));
                    sb.AppendFormat("<td class='col-status pm-center'><span class='pm-pill {0}'>{1}</span></td>", pillCss, HtmlEnc(provStatus.Replace("_", " ")));
                                        sb.AppendFormat(@"<td class='col-act pm-center'>
  <div class='pm-row-wrap'>
    <button type='button' class='pm-row-trigger' onclick='toggleRowMenu(this)' title='Actions' aria-label='Open row actions'>&#8942;</button>
        <div class='pm-row-menu'>{1}</div>
  </div>
</td></tr>", id, BuildRowActions(kind, id));
                }
            }
        }

        if (sb.Length == 0)
            sb.Append("<tr><td colspan='14' style='padding:14px;text-align:center;color:#6b7280;font-size:11px;'>No records found for the selected filters.</td></tr>");

        litRows.Text = sb.ToString();
        int displayFrom = total == 0 ? 0 : offset + 1;
        int displayTo = Math.Min(offset + pageSize, total);
        litFrom.Text = displayFrom.ToString();
        litTo.Text = displayTo.ToString();
        litTotal.Text = total.ToString();
        litTotal2.Text = total.ToString();
        litPage.Text = page.ToString();
        litPageCount.Text = pageCount.ToString();
        string pagerHtml = BuildPager(page, pageCount, year, sem, prog, status, lect, search, pageSize.ToString());
        litPager.Text = pagerHtml;
        litPager2.Text = pagerHtml;
    }

    public static string GetProvisionalRecord(int id)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string courseCol = GetCourseColumnExpression(conn, "cr");
                if (string.IsNullOrEmpty(courseCol))
                    return js.Serialize(new { success = false, message = "Course column not found on acad_course_registration." });

                string sql = @"
                    SELECT cr.id, cr.regno, " + courseCol + @" AS courseID, COALESCE(cr.prog_id,'') AS prog_id,
                           COALESCE((SELECT MAX(r2.studyyear) FROM acad_registration r2 WHERE r2.regno=cr.regno AND r2.acad_year=cr.acad_year AND r2.semester=cr.semester),1) AS study_year,
                           cr.acad_year, cr.semester,
                           cr.provisional_course_work_marks,
                           cr.provisional_exam_marks,
                           cr.provisional_total_marks,
                           CASE WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL THEN 'not_entered'
                                ELSE COALESCE(cr.provisional_marks_status,'pending') END AS provisional_marks_status,
                           COALESCE(cr.provisional_marks_review_comments,'') AS provisional_marks_review_comments,
                           COALESCE(cr.provisional_marks_reviewed_by,'') AS provisional_marks_reviewed_by,
                           COALESCE(cr.provisional_submitted_by,'') AS submitted_by,
                           TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name
                    FROM campus_dynamics_portal.acad_course_registration cr
                    LEFT JOIN acad_student s ON s.regno = cr.regno
                    WHERE cr.id = @id LIMIT 1";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                            return js.Serialize(new { success = false, message = "Record not found." });

                        Dictionary<string, object> record = new Dictionary<string, object>();
                        record["id"] = Convert.ToInt32(rdr["id"]);
                        record["regno"] = rdr["regno"].ToString();
                        record["courseID"] = rdr["courseID"].ToString();
                        record["prog_id"] = rdr["prog_id"].ToString();
                        record["study_year"] = rdr["study_year"].ToString();
                        record["acad_year"] = rdr["acad_year"].ToString();
                        record["semester"] = rdr["semester"].ToString();
                        record["student_name"] = rdr["student_name"].ToString().Trim();
                        record["provisional_course_work_marks"] = rdr.IsDBNull(rdr.GetOrdinal("provisional_course_work_marks")) ? null : (object)Convert.ToInt32(rdr["provisional_course_work_marks"]);
                        record["provisional_exam_marks"] = rdr.IsDBNull(rdr.GetOrdinal("provisional_exam_marks")) ? null : (object)Convert.ToInt32(rdr["provisional_exam_marks"]);
                        record["provisional_total_marks"] = rdr.IsDBNull(rdr.GetOrdinal("provisional_total_marks")) ? null : (object)Convert.ToInt32(rdr["provisional_total_marks"]);
                        record["provisional_marks_status"] = rdr["provisional_marks_status"].ToString();
                        record["provisional_marks_review_comments"] = rdr["provisional_marks_review_comments"].ToString();
                        record["provisional_marks_reviewed_by"] = rdr["provisional_marks_reviewed_by"].ToString();
                        record["submitted_by"] = rdr["submitted_by"].ToString();
                        return js.Serialize(new { success = true, record = record });
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    public static string GetRecordDetails(int id)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string courseCol = GetCourseColumnExpression(conn, "cr");
                if (string.IsNullOrEmpty(courseCol))
                    return js.Serialize(new { success = false, message = "Course column not found on acad_course_registration." });

                string sql = @"
                    SELECT cr.id, cr.regno, " + courseCol + @" AS courseID,
                           COALESCE((SELECT MAX(r2.studyyear) FROM acad_registration r2 WHERE r2.regno=cr.regno AND r2.acad_year=cr.acad_year AND r2.semester=cr.semester),1) AS study_year,
                           COALESCE(c.courseName, " + courseCol + @") AS course_name,
                           COALESCE(cr.prog_id,'') AS prog_id,
                           cr.acad_year, cr.semester,
                           cr.provisional_course_work_marks,
                           cr.provisional_exam_marks,
                           cr.provisional_total_marks,
                           CASE
                             WHEN cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL THEN 'not_entered'
                             ELSE COALESCE(cr.provisional_marks_status,'pending')
                           END AS provisional_marks_status,
                           COALESCE(cr.provisional_marks_review_comments,'') AS provisional_marks_review_comments,
                           COALESCE(cr.provisional_marks_reviewed_by,'') AS provisional_marks_reviewed_by,
                           COALESCE(DATE_FORMAT(cr.provisional_marks_review_date, '%Y-%m-%d %H:%i'),'') AS provisional_marks_review_date,
                           COALESCE(cr.provisional_submitted_by,'') AS submitted_by,
                           COALESCE(cr.provisional_published_by,'') AS provisional_published_by,
                           COALESCE(DATE_FORMAT(cr.provisional_published_date, '%Y-%m-%d %H:%i'),'') AS provisional_published_date,
                           TRIM(CONCAT(COALESCE(s.firstname,''),' ',COALESCE(s.othername,''))) AS student_name,
                           COALESCE(TRIM(e.emp_name),'') AS lecturer_name
                    FROM campus_dynamics_portal.acad_course_registration cr
                    LEFT JOIN acad_student s ON s.regno = cr.regno
                    LEFT JOIN acad_course c ON c.courseID = " + courseCol + @"
                    LEFT JOIN (
                        SELECT course_code, progcode, MAX(lecturer_id) AS lecturer_id
                        FROM acad_programmecourses
                        WHERE lecturer_id IS NOT NULL AND lecturer_id > 0
                        GROUP BY course_code, progcode
                    ) pc ON pc.course_code = " + courseCol + @" AND pc.progcode = cr.prog_id
                    LEFT JOIN hrm_employee e ON e.empID = pc.lecturer_id
                    WHERE cr.id = @id LIMIT 1";

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    using (MySqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (!rdr.Read())
                            return js.Serialize(new { success = false, message = "Record not found." });

                        Dictionary<string, object> record = new Dictionary<string, object>();
                        record["id"] = Convert.ToInt32(rdr["id"]);
                        record["regno"] = rdr["regno"].ToString();
                        record["student_name"] = rdr["student_name"].ToString().Trim();
                        record["courseID"] = rdr["courseID"].ToString();
                        record["course_name"] = rdr["course_name"].ToString();
                        record["prog_id"] = rdr["prog_id"].ToString();
                        record["study_year"] = rdr["study_year"].ToString();
                        record["acad_year"] = rdr["acad_year"].ToString();
                        record["semester"] = rdr["semester"].ToString();
                        record["lecturer_name"] = rdr["lecturer_name"].ToString().Trim();
                        record["submitted_by"] = rdr["submitted_by"].ToString();
                        record["provisional_course_work_marks"] = rdr.IsDBNull(rdr.GetOrdinal("provisional_course_work_marks")) ? null : (object)Convert.ToInt32(rdr["provisional_course_work_marks"]);
                        record["provisional_exam_marks"] = rdr.IsDBNull(rdr.GetOrdinal("provisional_exam_marks")) ? null : (object)Convert.ToInt32(rdr["provisional_exam_marks"]);
                        record["provisional_total_marks"] = rdr.IsDBNull(rdr.GetOrdinal("provisional_total_marks")) ? null : (object)Convert.ToInt32(rdr["provisional_total_marks"]);
                        record["provisional_marks_status"] = rdr["provisional_marks_status"].ToString();
                        record["provisional_marks_review_comments"] = rdr["provisional_marks_review_comments"].ToString();
                        record["provisional_marks_reviewed_by"] = rdr["provisional_marks_reviewed_by"].ToString();
                        record["provisional_marks_review_date"] = rdr["provisional_marks_review_date"].ToString();
                        record["provisional_published_by"] = rdr["provisional_published_by"].ToString();
                        record["provisional_published_date"] = rdr["provisional_published_date"].ToString();
                        return js.Serialize(new { success = true, record = record });
                    }
                }
            }
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    public static string ReviewProvisionalMarks(int id, string action, string comment)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();
        string normalizedAction = NormalizeStatus(action);

        if (normalizedAction != StatusRejected && normalizedAction != StatusPublished)
            return js.Serialize(new { success = false, message = "Invalid action." });
        if (normalizedAction == StatusRejected && string.IsNullOrWhiteSpace(comment))
            return js.Serialize(new { success = false, message = "Comment required for rejection." });

        try
        {
            string reviewer = MarksAuthorizationService.GetCurrentUser();
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                using (MySqlTransaction tx = conn.BeginTransaction())
                {
                    ProvisionalActionResult result = ProcessProvisionalAction(conn, tx, id, normalizedAction, reviewer, comment);
                    if (!result.Success)
                    {
                        tx.Rollback();
                        return js.Serialize(new { success = false, message = result.Message });
                    }

                    tx.Commit();
                    return js.Serialize(new { success = true, message = result.Message });
                }
            }
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    public static string PublishMarks(int id)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();

        try
        {
            string publisher = MarksAuthorizationService.GetCurrentUser();
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                using (MySqlTransaction tx = conn.BeginTransaction())
                {
                    ProvisionalActionResult result = ProcessProvisionalAction(conn, tx, id, StatusPublished, publisher, "");
                    if (!result.Success)
                    {
                        tx.Rollback();
                        return js.Serialize(new { success = false, message = result.Message });
                    }

                    tx.Commit();
                    return js.Serialize(new
                    {
                        success = true,
                        message = result.Message,
                        semesterGpa = result.SemesterGpa.ToString("F2"),
                        cgpa = result.Cgpa.ToString("F2"),
                        awardClass = result.AwardClass
                    });
                }
            }
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    /// <summary>
    /// Reverse a published record back to pending state and remove corresponding final-result row.
    /// The operation also regenerates semester GPA and cumulative CGPA within the same transaction.
    /// </summary>
    public static string UnpublishMark(int id, string comment)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();

        try
        {
            string actor = MarksAuthorizationService.GetCurrentUser();
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                using (MySqlTransaction tx = conn.BeginTransaction())
                {
                    ProvisionalActionResult result = ProcessUnpublishAction(conn, tx, id, actor, comment);
                    if (!result.Success)
                    {
                        tx.Rollback();
                        return js.Serialize(new { success = false, message = result.Message });
                    }

                    tx.Commit();
                    return js.Serialize(new
                    {
                        success = true,
                        message = result.Message,
                        semesterGpa = result.SemesterGpa.ToString("F2"),
                        cgpa = result.Cgpa.ToString("F2"),
                        awardClass = result.AwardClass
                    });
                }
            }
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    /// <summary>
    /// Re-run publish pipeline for a published record to regenerate score/grade/GPA/CGPA consistently.
    /// </summary>
    public static string ReprocessPublishedMark(int id)
    {
        return PublishMarks(id);
    }

    public static string SaveAdminMarks(int id, int? cw, int? exam, int? total, string note)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();
        try
        {
            if (cw == null && exam == null && total == null)
                return js.Serialize(new { success = false, message = "At least one mark value is required." });

            int? computedTotal = total;
            if (computedTotal == null && cw != null && exam != null)
                computedTotal = cw.Value + exam.Value;

            string actor = MarksAuthorizationService.GetCurrentUser();
            string reviewComment = string.IsNullOrWhiteSpace(note) ? "Admin mark override" : note.Trim();

            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string sql = @"UPDATE campus_dynamics_portal.acad_course_registration
                               SET provisional_course_work_marks = @cw,
                                   provisional_exam_marks = @exam,
                                   provisional_total_marks = @total,
                                   provisional_marks_status = @pending,
                                   provisional_marks_reviewed_by = @actor,
                                   provisional_marks_review_comments = @comment,
                                   provisional_marks_review_date = NOW()
                               WHERE id = @id";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@cw", (object)cw ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@exam", (object)exam ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@total", (object)computedTotal ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@pending", StatusPending);
                    cmd.Parameters.AddWithValue("@actor", actor);
                    cmd.Parameters.AddWithValue("@comment", reviewComment);
                    cmd.Parameters.AddWithValue("@id", id);
                    if (cmd.ExecuteNonQuery() == 0)
                        return js.Serialize(new { success = false, message = "Record not found." });
                }
            }
            return js.Serialize(new { success = true, message = "Marks saved. Status reset to pending for re-review." });
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    public static string ResetToPending(int id)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();
        try
        {
            string actor = MarksAuthorizationService.GetCurrentUser();
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string sql = @"UPDATE campus_dynamics_portal.acad_course_registration
                               SET provisional_marks_status = @pending,
                                   provisional_marks_review_comments = CONCAT(COALESCE(provisional_marks_review_comments,''), ' [Reset by admin: ', @actor, ']'),
                                   provisional_marks_reviewed_by = @actor,
                                   provisional_marks_review_date = NOW()
                               WHERE id = @id";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@pending", StatusPending);
                    cmd.Parameters.AddWithValue("@actor", actor);
                    cmd.Parameters.AddWithValue("@id", id);
                    if (cmd.ExecuteNonQuery() == 0)
                        return js.Serialize(new { success = false, message = "Record not found." });
                }
            }
            return js.Serialize(new { success = true, message = "Record reset to pending." });
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    public static string BulkAction(int[] ids, string action, string comment)
    {
        string connStr = ConnectionString;
        JavaScriptSerializer js = new JavaScriptSerializer();

        if (ids == null || ids.Length == 0)
            return js.Serialize(new { success = false, message = "No records supplied." });

        string normalizedAction = NormalizeStatus(action);
        if (normalizedAction != StatusRejected && normalizedAction != StatusPublished && normalizedAction != ActionUnpublish && normalizedAction != ActionReprocess)
            return js.Serialize(new { success = false, message = "Invalid action." });
        if (normalizedAction == StatusRejected && string.IsNullOrWhiteSpace(comment))
            return js.Serialize(new { success = false, message = "Comment required for bulk rejection." });

        try
        {
            string actor = MarksAuthorizationService.GetCurrentUser();
            int affected = 0;
            int failed = 0;
            string firstError = string.Empty;

            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();

                for (int i = 0; i < ids.Length; i++)
                {
                    if (ids[i] <= 0) continue;
                    using (MySqlTransaction tx = conn.BeginTransaction())
                    {
                        ProvisionalActionResult result;
                        if (normalizedAction == ActionUnpublish)
                            result = ProcessUnpublishAction(conn, tx, ids[i], actor, comment);
                        else if (normalizedAction == ActionReprocess)
                            result = ProcessProvisionalAction(conn, tx, ids[i], StatusPublished, actor, comment);
                        else
                            result = ProcessProvisionalAction(conn, tx, ids[i], normalizedAction, actor, comment);
                        if (result.Success)
                        {
                            tx.Commit();
                            affected++;
                        }
                        else
                        {
                            tx.Rollback();
                            failed++;
                            if (string.IsNullOrEmpty(firstError)) firstError = result.Message;
                        }
                    }
                }
            }

            string msg = affected + " record(s) " + normalizedAction + " successfully.";
            if (failed > 0)
                msg += " " + failed + " failed." + (string.IsNullOrEmpty(firstError) ? "" : " First error: " + firstError);

            return js.Serialize(new { success = affected > 0, message = msg, affected = affected, failed = failed });
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    public static string PreviewBatchWorkflow(string action, string scope, int[] ids, string year, string sem, string prog, AdminMarksPageKind kind)
    {
        JavaScriptSerializer js = new JavaScriptSerializer();
        string connStr = ConnectionString;
        string normalizedAction = NormalizeStatus(action);
        string normalizedScope = NormalizeStatus(scope);

        if (normalizedAction != StatusPublished)
            return js.Serialize(new { success = false, message = "Invalid workflow action." });
        if (normalizedScope != "selected" && normalizedScope != "programme")
            return js.Serialize(new { success = false, message = "Invalid workflow scope." });

        try
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string courseCol = GetCourseColumnExpression(conn, "cr");
                if (string.IsNullOrEmpty(courseCol))
                    return js.Serialize(new { success = false, message = "Course column not found on acad_course_registration." });

                List<int> targetIds = ResolveWorkflowTargetIds(conn, normalizedAction, normalizedScope, ids, year, sem, prog, kind);
                if (targetIds.Count == 0)
                    return js.Serialize(new { success = true, count = 0, rows = new object[0], message = "No eligible records found for this workflow." });

                string idList = string.Join(",", targetIds.ToArray());
                string previewSql = @"
                    SELECT cr.id, cr.regno, " + courseCol + @" AS courseID, COALESCE(cr.prog_id,'') AS prog_id,
                           cr.acad_year, cr.semester,
                           COALESCE(cr.provisional_total_marks,'') AS total_marks,
                           COALESCE(cr.provisional_marks_status,'pending') AS status
                    FROM campus_dynamics_portal.acad_course_registration cr
                    WHERE cr.id IN (" + idList + @")
                    ORDER BY cr.id DESC
                    LIMIT 30";

                List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
                using (MySqlCommand cmd = new MySqlCommand(previewSql, conn))
                using (MySqlDataReader rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        Dictionary<string, object> row = new Dictionary<string, object>();
                        row["id"] = Convert.ToInt32(rdr["id"]);
                        row["regno"] = rdr["regno"].ToString();
                        row["courseID"] = rdr["courseID"].ToString();
                        row["prog_id"] = rdr["prog_id"].ToString();
                        row["acad_year"] = rdr["acad_year"].ToString();
                        row["semester"] = rdr["semester"].ToString();
                        row["total_marks"] = rdr["total_marks"].ToString();
                        row["status"] = rdr["status"].ToString();
                        rows.Add(row);
                    }
                }

                return js.Serialize(new { success = true, count = targetIds.Count, rows = rows, message = "Preview ready." });
            }
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    public static string ExecuteBatchWorkflow(string action, string scope, int[] ids, string year, string sem, string prog, string comment, AdminMarksPageKind kind)
    {
        JavaScriptSerializer js = new JavaScriptSerializer();
        string connStr = ConnectionString;
        string normalizedAction = NormalizeStatus(action);
        string normalizedScope = NormalizeStatus(scope);

        if (normalizedAction != StatusPublished)
            return js.Serialize(new { success = false, message = "Invalid workflow action." });
        if (normalizedScope != "selected" && normalizedScope != "programme")
            return js.Serialize(new { success = false, message = "Invalid workflow scope." });

        try
        {
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                List<int> targetIds = ResolveWorkflowTargetIds(conn, normalizedAction, normalizedScope, ids, year, sem, prog, kind);
                if (targetIds.Count == 0)
                    return js.Serialize(new { success = false, message = "No eligible records found for execution." });

                int affected = 0;
                int failed = 0;
                string firstError = string.Empty;

                for (int i = 0; i < targetIds.Count; i++)
                {
                    using (MySqlTransaction tx = conn.BeginTransaction())
                    {
                        ProvisionalActionResult result = ProcessProvisionalAction(conn, tx, targetIds[i], normalizedAction, MarksAuthorizationService.GetCurrentUser(), comment);
                        if (result.Success)
                        {
                            tx.Commit();
                            affected++;
                        }
                        else
                        {
                            tx.Rollback();
                            failed++;
                            if (string.IsNullOrEmpty(firstError)) firstError = result.Message;
                        }
                    }
                }

                string msg = affected + " record(s) processed.";
                if (failed > 0)
                    msg += " " + failed + " failed." + (string.IsNullOrEmpty(firstError) ? "" : " First error: " + firstError);

                return js.Serialize(new { success = affected > 0, message = msg, affected = affected, failed = failed, total = targetIds.Count });
            }
        }
        catch (Exception ex)
        {
            return js.Serialize(new { success = false, message = "Error: " + ex.Message });
        }
    }

    private static void ConfigureStatusDropdown(DropDownList ddlStatus, AdminMarksPageKind kind)
    {
        ddlStatus.Items.Clear();
        ddlStatus.Enabled = true;

        switch (kind)
        {
            case AdminMarksPageKind.AllMarks:
                ddlStatus.Items.Add(new ListItem("All Statuses", ""));
                ddlStatus.Items.Add(new ListItem("Not Entered", StatusNotEntered));
                ddlStatus.Items.Add(new ListItem("Pending", StatusPending));
                ddlStatus.Items.Add(new ListItem("Rejected", StatusRejected));
                ddlStatus.Items.Add(new ListItem("Published", StatusPublished));
                break;
            case AdminMarksPageKind.Published:
                ddlStatus.Items.Add(new ListItem("Published Only", StatusPublished));
                ddlStatus.Enabled = false;
                break;
            case AdminMarksPageKind.PendingCoursework:
                ddlStatus.Items.Add(new ListItem("Missing Coursework Only", ""));
                ddlStatus.Enabled = false;
                break;
            case AdminMarksPageKind.PendingExam:
                ddlStatus.Items.Add(new ListItem("Missing Exam Only", ""));
                ddlStatus.Enabled = false;
                break;
            default:
                ddlStatus.Items.Add(new ListItem("Pending Publish Only", StatusPending));
                ddlStatus.Enabled = false;
                break;
        }
    }

    private static string GetDefaultStatus(AdminMarksPageKind kind, string queryStatus)
    {
        switch (kind)
        {
            case AdminMarksPageKind.AllMarks:
                return NormalizeStatus(queryStatus);
            case AdminMarksPageKind.Published:
                return StatusPublished;
            case AdminMarksPageKind.ProvisionalPending:
                return StatusPending;
            default:
                return string.Empty;
        }
    }

    private static string GetEffectiveStatus(AdminMarksPageKind kind, string selectedStatus)
    {
        switch (kind)
        {
            case AdminMarksPageKind.ProvisionalPending:
                return StatusPending;
            case AdminMarksPageKind.Published:
                return StatusPublished;
            case AdminMarksPageKind.AllMarks:
                return NormalizeStatus(selectedStatus);
            default:
                return string.Empty;
        }
    }

    private static StringBuilder BuildGridWhere(AdminMarksPageKind kind, string status, ref bool useStatusParam)
    {
        useStatusParam = false;
        switch (kind)
        {
            case AdminMarksPageKind.AllMarks:
                if (status == StatusNotEntered)
                    return new StringBuilder("WHERE cr.provisional_course_work_marks IS NULL AND cr.provisional_exam_marks IS NULL");
                if (!string.IsNullOrEmpty(status))
                {
                    useStatusParam = true;
                    return new StringBuilder("WHERE COALESCE(cr.provisional_marks_status,'pending') = @status");
                }
                return new StringBuilder("WHERE 1=1");
            case AdminMarksPageKind.Published:
                return new StringBuilder("WHERE COALESCE(cr.provisional_marks_status,'pending') = 'published'");
            case AdminMarksPageKind.PendingCoursework:
                return new StringBuilder("WHERE cr.provisional_course_work_marks IS NULL");
            case AdminMarksPageKind.PendingExam:
                return new StringBuilder("WHERE cr.provisional_course_work_marks IS NOT NULL AND cr.provisional_exam_marks IS NULL");
            default:
                return new StringBuilder("WHERE (cr.provisional_course_work_marks IS NOT NULL OR cr.provisional_exam_marks IS NOT NULL) AND COALESCE(cr.provisional_marks_status,'pending') = 'pending'");
        }
    }

    private static void AddParams(MySqlCommand cmd, string year, string sem, string prog, string status, bool useStatusParam, string lect, string search)
    {
        if (!string.IsNullOrEmpty(year)) cmd.Parameters.AddWithValue("@year", year);
        if (!string.IsNullOrEmpty(sem)) cmd.Parameters.AddWithValue("@sem", sem);
        if (!string.IsNullOrEmpty(prog)) cmd.Parameters.AddWithValue("@prog", prog);
        if (useStatusParam && !string.IsNullOrEmpty(status)) cmd.Parameters.AddWithValue("@status", status);
        if (!string.IsNullOrEmpty(lect)) cmd.Parameters.AddWithValue("@lect", lect);
        if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@q", "%" + search + "%");
    }

    private static string BuildPager(int page, int pageCount, string year, string sem, string prog, string status, string lect, string q, string ps)
    {
        StringBuilder sb = new StringBuilder();
        int startP = Math.Max(1, page - 3);
        int endP = Math.Min(pageCount, page + 3);

        Func<int, string> url = delegate(int p)
        {
            return string.Format("?pg={0}&year={1}&sem={2}&prog={3}&status={4}&lect={5}&ps={6}&q={7}",
                p,
                Uri.EscapeDataString(year ?? string.Empty),
                Uri.EscapeDataString(sem ?? string.Empty),
                Uri.EscapeDataString(prog ?? string.Empty),
                Uri.EscapeDataString(status ?? string.Empty),
                Uri.EscapeDataString(lect ?? string.Empty),
                Uri.EscapeDataString(ps ?? string.Empty),
                Uri.EscapeDataString(q ?? string.Empty));
        };

        if (page > 1) sb.AppendFormat("<a href='{0}'>&laquo;</a>", url(page - 1));
        for (int i = startP; i <= endP; i++)
        {
            if (i == page) sb.AppendFormat("<span class='active'>{0}</span>", i);
            else sb.AppendFormat("<a href='{0}'>{1}</a>", url(i), i);
        }
        if (page < pageCount) sb.AppendFormat("<a href='{0}'>&raquo;</a>", url(page + 1));
        return sb.ToString();
    }

    private static List<int> ResolveWorkflowTargetIds(MySqlConnection conn, string action, string scope, int[] ids, string year, string sem, string prog, AdminMarksPageKind kind)
    {
        List<int> targetIds = new List<int>();
        if (scope == "selected")
        {
            if (ids != null)
            {
                for (int i = 0; i < ids.Length; i++)
                    if (ids[i] > 0) targetIds.Add(ids[i]);
            }
            return targetIds;
        }

        StringBuilder sql = new StringBuilder("SELECT cr.id FROM campus_dynamics_portal.acad_course_registration cr WHERE 1=1");

        switch (kind)
        {
            case AdminMarksPageKind.ProvisionalPending:
                sql.Append(" AND (cr.provisional_course_work_marks IS NOT NULL OR cr.provisional_exam_marks IS NOT NULL) AND COALESCE(cr.provisional_marks_status,'pending')='pending'");
                break;
            case AdminMarksPageKind.Published:
                sql.Append(" AND COALESCE(cr.provisional_marks_status,'pending')='published'");
                break;
            case AdminMarksPageKind.PendingCoursework:
                sql.Append(" AND cr.provisional_course_work_marks IS NULL");
                break;
            case AdminMarksPageKind.PendingExam:
                sql.Append(" AND cr.provisional_course_work_marks IS NOT NULL AND cr.provisional_exam_marks IS NULL");
                break;
        }

        sql.Append(" AND cr.provisional_course_work_marks IS NOT NULL AND cr.provisional_exam_marks IS NOT NULL AND cr.provisional_total_marks IS NOT NULL AND COALESCE(cr.provisional_marks_status,'pending') IN ('pending','approved','published')");

        if (!string.IsNullOrEmpty(year)) sql.Append(" AND cr.acad_year=@year");
        if (!string.IsNullOrEmpty(sem)) sql.Append(" AND cr.semester=@sem");
        if (!string.IsNullOrEmpty(prog)) sql.Append(" AND cr.prog_id=@prog");

        using (MySqlCommand cmd = new MySqlCommand(sql.ToString(), conn))
        {
            if (!string.IsNullOrEmpty(year)) cmd.Parameters.AddWithValue("@year", year);
            if (!string.IsNullOrEmpty(sem)) cmd.Parameters.AddWithValue("@sem", sem);
            if (!string.IsNullOrEmpty(prog)) cmd.Parameters.AddWithValue("@prog", prog);
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                    targetIds.Add(Convert.ToInt32(rdr["id"]));
            }
        }

        return targetIds;
    }

        private static string BuildRowActions(AdminMarksPageKind kind, int id)
        {
                if (kind == AdminMarksPageKind.Published)
                {
                        return string.Format(@"
            <button type='button' class='pm-row-menu__item act--edit' onclick='closeMenuThen(this,function(){{openEdit({0});}})'>&#9998; Edit Marks</button>
            <button type='button' class='pm-row-menu__item act--approve' onclick='closeMenuThen(this,function(){{openDetails({0});}})'>&#9432; View Details</button>
            <div class='pm-row-menu__sep'></div>
            <button type='button' class='pm-row-menu__item act--publish' onclick='closeMenuThen(this,function(){{reprocessMark({0});}})'>&#10227; Reprocess</button>
            <button type='button' class='pm-row-menu__item act--reset' onclick='closeMenuThen(this,function(){{unpublishMark({0});}})'>&#8634; Unpublish</button>", id);
                }

                return string.Format(@"
            <button type='button' class='pm-row-menu__item act--edit' onclick='closeMenuThen(this,function(){{openEdit({0});}})'>&#9998; Edit Marks</button>
            <button type='button' class='pm-row-menu__item act--approve' onclick='closeMenuThen(this,function(){{openDetails({0});}})'>&#9432; View Details</button>
            <button type='button' class='pm-row-menu__item act--approve' onclick='closeMenuThen(this,function(){{openReview({0});}})'>&#10003; Review</button>
            <div class='pm-row-menu__sep'></div>
            <button type='button' class='pm-row-menu__item act--publish' onclick='closeMenuThen(this,function(){{openPublish({0});}})'>&#8679; Publish</button>
            <button type='button' class='pm-row-menu__item act--reset' onclick='closeMenuThen(this,function(){{resetToPending({0});}})'>&#8635; Reset</button>", id);
        }

    /// <summary>
    /// Centralized transition engine for provisional row actions.
    /// Single-row APIs and batch APIs both call this method to guarantee identical rules.
    /// </summary>
    private static ProvisionalActionResult ProcessProvisionalAction(MySqlConnection conn, MySqlTransaction tx, int id, string normalizedAction, string actor, string comment)
    {
        ProvisionalActionResult result = new ProvisionalActionResult { Success = false, Message = "Unable to process action." };

        if (normalizedAction != StatusRejected && normalizedAction != StatusPublished)
        {
            result.Message = "Invalid action.";
            return result;
        }

        string courseCol = GetCourseColumnExpression(conn, "cr");
        if (string.IsNullOrEmpty(courseCol))
        {
            result.Message = "Course column not found on acad_course_registration.";
            return result;
        }

        string regno = string.Empty;
        string courseId = string.Empty;
        string acadYear = string.Empty;
        string semester = string.Empty;
        string provStatus = string.Empty;
        int? cw = null;
        int? exam = null;
        int? total = null;
        int studyYear = 0;

        string fetchSql = @"
            SELECT cr.regno,
                   " + courseCol + @" AS courseID,
                   cr.acad_year,
                   cr.semester,
                   cr.provisional_course_work_marks,
                   cr.provisional_exam_marks,
                   cr.provisional_total_marks,
                   COALESCE(cr.provisional_marks_status,'pending') AS prov_status,
                   COALESCE((SELECT MAX(r2.studyyear)
                             FROM acad_registration r2
                             WHERE r2.regno = cr.regno
                               AND r2.acad_year = cr.acad_year
                               AND r2.semester = cr.semester), 0) AS study_year
            FROM campus_dynamics_portal.acad_course_registration cr
            WHERE cr.id = @id
            LIMIT 1";

        using (MySqlCommand cmd = new MySqlCommand(fetchSql, conn, tx))
        {
            cmd.Parameters.AddWithValue("@id", id);
            using (MySqlDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow))
            {
                if (!rdr.Read())
                {
                    result.Message = "Record not found.";
                    return result;
                }

                regno = rdr["regno"].ToString();
                courseId = rdr["courseID"].ToString();
                acadYear = rdr["acad_year"].ToString();
                semester = rdr["semester"].ToString();
                provStatus = NormalizeStatus(rdr["prov_status"].ToString());
                cw = rdr.IsDBNull(rdr.GetOrdinal("provisional_course_work_marks")) ? (int?)null : Convert.ToInt32(rdr["provisional_course_work_marks"]);
                exam = rdr.IsDBNull(rdr.GetOrdinal("provisional_exam_marks")) ? (int?)null : Convert.ToInt32(rdr["provisional_exam_marks"]);
                total = rdr.IsDBNull(rdr.GetOrdinal("provisional_total_marks")) ? (int?)null : Convert.ToInt32(rdr["provisional_total_marks"]);
                studyYear = rdr.IsDBNull(rdr.GetOrdinal("study_year")) ? 0 : Convert.ToInt32(rdr["study_year"]);
            }
        }

        if (normalizedAction == StatusRejected)
        {
            if (string.IsNullOrWhiteSpace(comment))
            {
                result.Message = "Comment required for rejection.";
                return result;
            }

            using (MySqlCommand cmd = new MySqlCommand(@"
                UPDATE campus_dynamics_portal.acad_course_registration
                SET provisional_marks_status = @status,
                    provisional_marks_review_comments = @comment,
                    provisional_marks_reviewed_by = @reviewer,
                    provisional_marks_review_date = NOW()
                WHERE id = @id", conn, tx))
            {
                cmd.Parameters.AddWithValue("@status", StatusRejected);
                cmd.Parameters.AddWithValue("@comment", comment.Trim());
                cmd.Parameters.AddWithValue("@reviewer", actor);
                cmd.Parameters.AddWithValue("@id", id);
                if (cmd.ExecuteNonQuery() <= 0)
                {
                    result.Message = "Rejection update failed.";
                    return result;
                }
            }

            result.Success = true;
            result.Message = "Marks rejected successfully.";
            return result;
        }

        // Publish path (classic aligned)
        // - Grade scale: A..E (5-point model)
        // - Grade points + Credit Units are written to acad_results
        // - Semester GPA is recalculated and propagated to all rows of that semester context
        // - CGPA is recomputed cumulatively for messaging/classification context
        if (!(cw.HasValue && exam.HasValue))
        {
            result.Message = "Coursework and exam marks must both be present before publish.";
            return result;
        }
        if (!(provStatus == StatusPending || provStatus == StatusApproved || provStatus == StatusPublished))
        {
            result.Message = "Only pending, approved, or published records with complete marks can be published.";
            return result;
        }

        int finalTotal = cw.Value + exam.Value;
        total = finalTotal;

        string grade = ComputeGrade(total.Value);
        decimal gradePt = ComputeGradePoint(grade);

        int creditUnits = 3;
        string courseCreditCol = ResolveCourseCreditUnitsColumn(conn);
        if (!string.IsNullOrEmpty(courseCreditCol))
        {
            using (MySqlCommand cuCmd = new MySqlCommand(
                "SELECT COALESCE(NULLIF(" + courseCreditCol + ",0),3) FROM acad_course WHERE courseID=@courseID LIMIT 1", conn, tx))
            {
                cuCmd.Parameters.AddWithValue("@courseID", courseId);
                object cuObj = cuCmd.ExecuteScalar();
                if (cuObj != null && cuObj != DBNull.Value)
                {
                    int parsed;
                    if (int.TryParse(cuObj.ToString(), out parsed) && parsed > 0) creditUnits = parsed;
                }
            }
        }

        string resultsCreditCol = ResolveResultsCreditUnitsColumn(conn);

        EnsureResultCommentTextNullable(conn);
        string finalComment = "Published from provisional marks by " + actor;

        int updateCount;
        using (MySqlCommand upd = new MySqlCommand(@"
            UPDATE acad_results
            SET score = @score,
                grade = @grade,
                gradept = @gradept,
                " + resultsCreditCol + @" = @cu,
                studyyear = @studyyear,
                result_comment = @comment
            WHERE regno = @regno
              AND courseid = @courseid
              AND acad = @acad
              AND semester = @semester", conn, tx))
        {
            upd.Parameters.AddWithValue("@score", total.Value);
            upd.Parameters.AddWithValue("@grade", grade);
            upd.Parameters.AddWithValue("@gradept", gradePt);
            upd.Parameters.AddWithValue("@cu", creditUnits);
            upd.Parameters.AddWithValue("@studyyear", studyYear <= 0 ? (object)DBNull.Value : studyYear);
            upd.Parameters.AddWithValue("@comment", finalComment);
            upd.Parameters.AddWithValue("@regno", regno);
            upd.Parameters.AddWithValue("@courseid", courseId);
            upd.Parameters.AddWithValue("@acad", acadYear);
            upd.Parameters.AddWithValue("@semester", ParseIntSafe(semester, 0));
            updateCount = upd.ExecuteNonQuery();
        }

        if (updateCount == 0)
        {
            using (MySqlCommand ins = new MySqlCommand(@"
                INSERT INTO acad_results
                    (regno, courseid, acad, semester, studyyear, score, grade, gradept, " + resultsCreditCol + @", result_comment)
                VALUES
                    (@regno, @courseid, @acad, @semester, @studyyear, @score, @grade, @gradept, @cu, @comment)", conn, tx))
            {
                ins.Parameters.AddWithValue("@regno", regno);
                ins.Parameters.AddWithValue("@courseid", courseId);
                ins.Parameters.AddWithValue("@acad", acadYear);
                ins.Parameters.AddWithValue("@semester", ParseIntSafe(semester, 0));
                ins.Parameters.AddWithValue("@studyyear", studyYear <= 0 ? (object)DBNull.Value : studyYear);
                ins.Parameters.AddWithValue("@score", total.Value);
                ins.Parameters.AddWithValue("@grade", grade);
                ins.Parameters.AddWithValue("@gradept", gradePt);
                ins.Parameters.AddWithValue("@cu", creditUnits);
                ins.Parameters.AddWithValue("@comment", finalComment);
                ins.ExecuteNonQuery();
            }
        }

        decimal semesterGpa = ComputeSemesterGpa(conn, tx, regno, acadYear, ParseIntSafe(semester, 0));
        decimal cgpa = ComputeStudentCgpa(conn, tx, regno);
        string awardClass = ComputeAwardClass(cgpa);

        using (MySqlCommand cmd = new MySqlCommand(@"
            UPDATE acad_results
            SET gpa = @gpa
            WHERE regno = @regno
              AND acad = @acad
              AND semester = @semester", conn, tx))
        {
            cmd.Parameters.AddWithValue("@gpa", semesterGpa);
            cmd.Parameters.AddWithValue("@regno", regno);
            cmd.Parameters.AddWithValue("@acad", acadYear);
            cmd.Parameters.AddWithValue("@semester", ParseIntSafe(semester, 0));
            cmd.ExecuteNonQuery();
        }

        using (MySqlCommand cmd = new MySqlCommand(@"
            UPDATE campus_dynamics_portal.acad_course_registration
            SET provisional_total_marks = @total,
                provisional_marks_status = @published,
                provisional_published_by = @publisher,
                provisional_published_date = NOW()
            WHERE id = @id", conn, tx))
        {
            cmd.Parameters.AddWithValue("@total", total.Value);
            cmd.Parameters.AddWithValue("@published", StatusPublished);
            cmd.Parameters.AddWithValue("@publisher", actor);
            cmd.Parameters.AddWithValue("@id", id);
            if (cmd.ExecuteNonQuery() <= 0)
            {
                result.Message = "Provisional publish status update failed.";
                return result;
            }
        }

        result.Success = true;
        result.SemesterGpa = semesterGpa;
        result.Cgpa = cgpa;
        result.AwardClass = awardClass;
        result.Message = "Marks published to final results. Semester GPA " + semesterGpa.ToString("F2") + ", CGPA " + cgpa.ToString("F2") + " (" + awardClass + ").";
        return result;
    }

    private static ProvisionalActionResult ProcessUnpublishAction(MySqlConnection conn, MySqlTransaction tx, int id, string actor, string comment)
    {
        ProvisionalActionResult result = new ProvisionalActionResult { Success = false, Message = "Unable to unpublish record." };

        string courseCol = GetCourseColumnExpression(conn, "cr");
        if (string.IsNullOrEmpty(courseCol))
        {
            result.Message = "Course column not found on acad_course_registration.";
            return result;
        }

        string regno = string.Empty;
        string courseId = string.Empty;
        string acadYear = string.Empty;
        string semester = string.Empty;
        string provStatus = string.Empty;

        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT cr.regno,
                   " + courseCol + @" AS courseID,
                   cr.acad_year,
                   cr.semester,
                   COALESCE(cr.provisional_marks_status,'pending') AS prov_status
            FROM campus_dynamics_portal.acad_course_registration cr
            WHERE cr.id = @id
            LIMIT 1", conn, tx))
        {
            cmd.Parameters.AddWithValue("@id", id);
            using (MySqlDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow))
            {
                if (!rdr.Read())
                {
                    result.Message = "Record not found.";
                    return result;
                }

                regno = rdr["regno"].ToString();
                courseId = rdr["courseID"].ToString();
                acadYear = rdr["acad_year"].ToString();
                semester = rdr["semester"].ToString();
                provStatus = NormalizeStatus(rdr["prov_status"].ToString());
            }
        }

        if (provStatus != StatusPublished)
        {
            result.Message = "Only published records can be unpublished.";
            return result;
        }

        using (MySqlCommand del = new MySqlCommand(@"
            DELETE FROM acad_results
            WHERE regno = @regno
              AND courseid = @courseid
              AND acad = @acad
              AND semester = @semester", conn, tx))
        {
            del.Parameters.AddWithValue("@regno", regno);
            del.Parameters.AddWithValue("@courseid", courseId);
            del.Parameters.AddWithValue("@acad", acadYear);
            del.Parameters.AddWithValue("@semester", ParseIntSafe(semester, 0));
            del.ExecuteNonQuery();
        }

        string note = string.IsNullOrWhiteSpace(comment)
            ? "[Unpublished by " + actor + "]"
            : "[Unpublished by " + actor + ": " + comment.Trim() + "]";

        using (MySqlCommand upd = new MySqlCommand(@"
            UPDATE campus_dynamics_portal.acad_course_registration
            SET provisional_marks_status = @pending,
                provisional_published_by = NULL,
                provisional_published_date = NULL,
                provisional_marks_review_comments = CONCAT(COALESCE(provisional_marks_review_comments,''), ' ', @note),
                provisional_marks_reviewed_by = @actor,
                provisional_marks_review_date = NOW()
            WHERE id = @id", conn, tx))
        {
            upd.Parameters.AddWithValue("@pending", StatusPending);
            upd.Parameters.AddWithValue("@note", note);
            upd.Parameters.AddWithValue("@actor", actor);
            upd.Parameters.AddWithValue("@id", id);
            if (upd.ExecuteNonQuery() <= 0)
            {
                result.Message = "Unpublish update failed.";
                return result;
            }
        }

        int semesterInt = ParseIntSafe(semester, 0);
        decimal semesterGpa = ComputeSemesterGpa(conn, tx, regno, acadYear, semesterInt);
        decimal cgpa = ComputeStudentCgpa(conn, tx, regno);
        string awardClass = ComputeAwardClass(cgpa);

        using (MySqlCommand gpaUpd = new MySqlCommand(@"
            UPDATE acad_results
            SET gpa = @gpa
            WHERE regno = @regno
              AND acad = @acad
              AND semester = @semester", conn, tx))
        {
            gpaUpd.Parameters.AddWithValue("@gpa", semesterGpa);
            gpaUpd.Parameters.AddWithValue("@regno", regno);
            gpaUpd.Parameters.AddWithValue("@acad", acadYear);
            gpaUpd.Parameters.AddWithValue("@semester", semesterInt);
            gpaUpd.ExecuteNonQuery();
        }

        result.Success = true;
        result.SemesterGpa = semesterGpa;
        result.Cgpa = cgpa;
        result.AwardClass = awardClass;
        result.Message = "Record unpublished and moved back to pending. Semester GPA " + semesterGpa.ToString("F2") + ", CGPA " + cgpa.ToString("F2") + " (" + awardClass + ").";
        return result;
    }

    /// <summary>Weighted semester GPA: SUM(gradept*CU)/SUM(CU)</summary>
    private static decimal ComputeSemesterGpa(MySqlConnection conn, MySqlTransaction tx, string regno, string acadYear, int semester)
    {
        string resultsCreditCol = ResolveResultsCreditUnitsColumn(conn);
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT ROUND(SUM(COALESCE(gradept,0) * COALESCE(NULLIF(" + resultsCreditCol + @",0),3)) /
                         NULLIF(SUM(COALESCE(NULLIF(" + resultsCreditCol + @",0),3)), 0), 2)
            FROM acad_results
            WHERE regno = @regno AND acad = @acad AND semester = @semester", conn, tx))
        {
            cmd.Parameters.AddWithValue("@regno", regno);
            cmd.Parameters.AddWithValue("@acad", acadYear);
            cmd.Parameters.AddWithValue("@semester", semester);
            object value = cmd.ExecuteScalar();
            if (value == null || value == DBNull.Value) return 0m;
            return Convert.ToDecimal(value);
        }
    }

    /// <summary>Cumulative CGPA across all results for the student.</summary>
    private static decimal ComputeStudentCgpa(MySqlConnection conn, MySqlTransaction tx, string regno)
    {
        string resultsCreditCol = ResolveResultsCreditUnitsColumn(conn);
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT ROUND(SUM(COALESCE(gradept,0) * COALESCE(NULLIF(" + resultsCreditCol + @",0),3)) /
                         NULLIF(SUM(COALESCE(NULLIF(" + resultsCreditCol + @",0),3)), 0), 2)
            FROM acad_results
            WHERE regno = @regno", conn, tx))
        {
            cmd.Parameters.AddWithValue("@regno", regno);
            object value = cmd.ExecuteScalar();
            if (value == null || value == DBNull.Value) return 0m;
            return Convert.ToDecimal(value);
        }
    }

    /// <summary>Classification thresholds aligned to ResultsUpdates/NewStudentInfo (4.40/3.60/2.80/2.00).</summary>
    private static string ComputeAwardClass(decimal cgpa)
    {
        if (cgpa >= 4.40m) return "FIRST CLASS";
        if (cgpa >= 3.60m) return "SECOND CLASS UPPER";
        if (cgpa >= 2.80m) return "SECOND CLASS LOWER";
        if (cgpa >= 2.00m) return "PASS";
        return "RETAKE";
    }

    private static string NormalizeStatus(string status)
    {
        return (status ?? string.Empty).Trim().ToLowerInvariant();
    }

    private static int ParseIntSafe(string value, int fallback)
    {
        int parsed;
        if (!int.TryParse(value, out parsed)) return fallback;
        return parsed;
    }

    private static string ComputeGrade(int score)
    {
        if (score >= 80) return "A";
        if (score >= 75) return "A-";
        if (score >= 70) return "B+";
        if (score >= 65) return "B";
        if (score >= 60) return "B-";
        if (score >= 55) return "C+";
        if (score >= 50) return "C";
        if (score >= 45) return "C-";
        if (score >= 40) return "D";
        return "E";
    }

    private static decimal ComputeGradePoint(string grade)
    {
        switch ((grade ?? string.Empty).Trim().ToUpperInvariant())
        {
            case "A": return 5.0m;
            case "A-": return 4.5m;
            case "B+": return 4.0m;
            case "B": return 3.5m;
            case "B-": return 3.0m;
            case "C+": return 2.5m;
            case "C": return 2.0m;
            case "C-": return 1.5m;
            case "D": return 1.0m;
            default: return 0.0m;
        }
    }

    private static string HtmlEnc(string s)
    {
        return HttpUtility.HtmlEncode(s ?? string.Empty);
    }

    private static void EnsureResultCommentTextNullable(MySqlConnection conn)
    {
        try
        {
            using (MySqlCommand cmd = new MySqlCommand(@"
                SELECT DATA_TYPE, IS_NULLABLE
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA='campus_dynamics'
                  AND TABLE_NAME='acad_results'
                  AND COLUMN_NAME='result_comment'
                LIMIT 1", conn))
            using (MySqlDataReader rdr = cmd.ExecuteReader())
            {
                if (!rdr.Read()) return;
                string dataType = rdr.IsDBNull(0) ? string.Empty : rdr.GetString(0).ToLowerInvariant();
                string isNullable = rdr.IsDBNull(1) ? "YES" : rdr.GetString(1).ToUpperInvariant();
                if (dataType == "text" && isNullable == "YES") return;
            }

            using (MySqlCommand alter = new MySqlCommand("ALTER TABLE campus_dynamics.acad_results MODIFY COLUMN result_comment TEXT NULL", conn))
            {
                alter.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private static void SafeSelect(DropDownList ddl, string val)
    {
        ListItem item = ddl.Items.FindByValue(val);
        if (item != null) item.Selected = true;
    }

    private static bool ColumnExists(MySqlConnection conn, string schema, string table, string column)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@s AND TABLE_NAME=@t AND COLUMN_NAME=@c", conn))
        {
            cmd.Parameters.AddWithValue("@s", schema);
            cmd.Parameters.AddWithValue("@t", table);
            cmd.Parameters.AddWithValue("@c", column);
            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }
    }

    private static void EnsureNullableColumn(MySqlConnection conn, string schema, string table, string column, string sqlType)
    {
        if (ColumnExists(conn, schema, table, column)) return;
        using (MySqlCommand cmd = new MySqlCommand(
            "ALTER TABLE " + schema + "." + table + " ADD COLUMN " + column + " " + sqlType, conn))
        {
            cmd.ExecuteNonQuery();
        }
    }

    private static string GetCourseColumnExpression(MySqlConnection conn, string alias)
    {
        bool hasCourseId = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "courseID");
        bool hasCourseCode = ColumnExists(conn, "campus_dynamics_portal", "acad_course_registration", "course_code");

        string prefix = string.IsNullOrEmpty(alias) ? string.Empty : alias + ".";
        if (hasCourseId) return prefix + "courseID";
        if (hasCourseCode) return prefix + "course_code";
        return null;
    }

    private static string ResolveCourseCreditUnitsColumn(MySqlConnection conn)
    {
        string[] candidates = new string[] { "CreditUnits", "creditunits", "credit_units", "creditunit", "credit_unit", "cu" };
        for (int i = 0; i < candidates.Length; i++)
        {
            string existing = GetActualColumnName(conn, "campus_dynamics", "acad_course", candidates[i]);
            if (!string.IsNullOrEmpty(existing)) return existing;
        }
        return null;
    }

    private static string ResolveResultsCreditUnitsColumn(MySqlConnection conn)
    {
        string[] candidates = new string[] { "CreditUnits", "creditunits", "credit_units", "creditunit", "credit_unit", "cu" };
        for (int i = 0; i < candidates.Length; i++)
        {
            string existing = GetActualColumnName(conn, "campus_dynamics", "acad_results", candidates[i]);
            if (!string.IsNullOrEmpty(existing)) return existing;
        }

        try { EnsureNullableColumn(conn, "campus_dynamics", "acad_results", "CreditUnits", "INT NULL"); } catch { }
        return "CreditUnits";
    }

    private static string GetActualColumnName(MySqlConnection conn, string schema, string table, string columnCandidate)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA=@s AND TABLE_NAME=@t AND LOWER(COLUMN_NAME)=@c LIMIT 1", conn))
        {
            cmd.Parameters.AddWithValue("@s", schema);
            cmd.Parameters.AddWithValue("@t", table);
            cmd.Parameters.AddWithValue("@c", (columnCandidate ?? string.Empty).ToLowerInvariant());
            object value = cmd.ExecuteScalar();
            return value == null || value == DBNull.Value ? null : value.ToString();
        }
    }
}
