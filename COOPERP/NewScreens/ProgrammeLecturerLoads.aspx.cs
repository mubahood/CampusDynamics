using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_ProgrammeLecturerLoads : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private string CurrentAcadYear
    {
        get
        {
            string value = Session["SelectedAcademicYear"] == null ? "" : Session["SelectedAcademicYear"].ToString();
            if (string.IsNullOrEmpty(value)) value = AcademicYearHelper.GetCurrentAcademicYear();
            return value;
        }
    }

    private string CurrentSemester
    {
        get
        {
            string value = Session["SelectedSemester"] == null ? "" : Session["SelectedSemester"].ToString();
            if (string.IsNullOrEmpty(value)) value = "1";
            return value;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;

        litCurrentPeriod.Text = HttpUtility.HtmlEncode(CurrentAcadYear + " / Semester " + CurrentSemester);
        LoadStats();
        LoadList();
        LoadDetail();
    }

    private void LoadStats()
    {
        litLecturerCount.Text = GetCount("SELECT COUNT(*) FROM hrm_employee WHERE EmpType = 'Academic'").ToString("N0");
        litLecturersWithLoad.Text = GetCount(@"SELECT COUNT(DISTINCT CAST(staffCode AS UNSIGNED)) FROM acad_teaching_allocation WHERE acad_year = @year AND semester = @sem",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester)).ToString("N0");
        litAllocatedCourses.Text = GetCount(@"SELECT COUNT(*) FROM acad_teaching_allocation WHERE acad_year = @year AND semester = @sem",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester)).ToString("N0");

        object hoursObj = ExecuteScalar(@"
            SELECT COALESCE(SUM(
                CASE
                    WHEN lectureday <> '-' AND StartTime IS NOT NULL AND EndTime IS NOT NULL
                    THEN TIMESTAMPDIFF(MINUTE, STR_TO_DATE(StartTime,'%H:%i'), STR_TO_DATE(EndTime,'%H:%i')) / 60.0
                    ELSE 0
                END
            ), 0)
            FROM acad_teaching_allocation
            WHERE acad_year = @year AND semester = @sem",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        decimal hours;
        decimal.TryParse(Convert.ToString(hoursObj), out hours);
        litScheduledHours.Text = hours.ToString("N1");
    }

    private void LoadList()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT e.empID,
                   IFNULL(e.emp_name, '') AS emp_name,
                   IFNULL(e.EMP_CODE, '') AS emp_code,
                   IFNULL(d.dept_name, '') AS department_name,
                   IFNULL(c.contract_type, '') AS contract_type,
                   IFNULL(w.course_count, 0) AS course_count,
                   IFNULL(w.programme_count, 0) AS programme_count,
                   IFNULL(w.scheduled_hours, 0) AS scheduled_hours,
                     IFNULL(w.courses_preview, '') AS courses_preview,
                   IFNULL(w.programmes, '') AS programmes,
                   IFNULL(w.faculties, '') AS faculties
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
               AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN (
                SELECT CAST(ta.staffCode AS UNSIGNED) AS emp_id,
                       COUNT(*) AS course_count,
                       COUNT(DISTINCT ta.progcode) AS programme_count,
                       COALESCE(SUM(
                           CASE
                               WHEN ta.lectureday <> '-' AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL
                               THEN TIMESTAMPDIFF(MINUTE, STR_TO_DATE(ta.StartTime,'%H:%i'), STR_TO_DATE(ta.EndTime,'%H:%i')) / 60.0
                               ELSE 0
                           END
                       ), 0) AS scheduled_hours,
                       GROUP_CONCAT(DISTINCT CONCAT(ta.courseID, ' - ', IFNULL(crs.courseName, '')) ORDER BY ta.courseID SEPARATOR '||') AS courses_preview,
                       GROUP_CONCAT(DISTINCT IFNULL(p.progname, ta.progcode) ORDER BY IFNULL(p.progname, ta.progcode) SEPARATOR ', ') AS programmes,
                       GROUP_CONCAT(DISTINCT IFNULL(f.faculty_name, '') ORDER BY IFNULL(f.faculty_name, '') SEPARATOR ', ') AS faculties
                FROM acad_teaching_allocation ta
                LEFT JOIN acad_course crs ON crs.courseID = ta.courseID
                LEFT JOIN acad_programme p ON p.progcode = ta.progcode
                LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code
                WHERE ta.acad_year = @year AND ta.semester = @sem
                GROUP BY CAST(ta.staffCode AS UNSIGNED)
            ) w ON w.emp_id = e.empID
            WHERE e.EmpType = 'Academic' OR IFNULL(w.course_count, 0) > 0
            ORDER BY IFNULL(w.course_count, 0) DESC, e.emp_name ASC",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        if (dt.Rows.Count == 0)
        {
            litRows.Text = "<tr><td colspan=\"5\"><div class=\"pll-empty\">No lecturer load records were found.</div></td></tr>";
            return;
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            DataRow row = dt.Rows[i];
            string search = string.Join(" ", new string[]
            {
                Safe(row["emp_name"]), Safe(row["emp_code"]), Safe(row["department_name"]), Safe(row["programmes"]), Safe(row["faculties"]), Safe(row["courses_preview"])
            });

            sb.Append("<tr data-load-row=\"1\" data-search=\"").Append(A(search)).Append("\">");
            sb.Append("<td><div style=\"font-weight:800;color:#05275C;\">" + H(row["emp_name"]) + "</div><div class=\"pll-code\">" + H(row["emp_code"]) + "</div><div class=\"pll-muted\">" + H(row["department_name"]) + "</div></td>");
            sb.Append("<td>" + BuildCourseSnapshotHtml(row["courses_preview"], row["course_count"]) + "</td>");
            sb.Append("<td>" + (string.IsNullOrEmpty(Safe(row["programmes"])) ? "<span class=\"pll-muted\">No current allocations</span>" : H(row["programmes"])) + "<div class=\"pll-muted\" style=\"margin-top:5px;\"><span class=\"pll-pill\">" + Convert.ToInt32(row["programme_count"]).ToString("N0") + " programme(s)</span></div><div class=\"pll-muted\" style=\"margin-top:4px;\">" + H(row["faculties"]) + "</div></td>");
            sb.Append("<td>" + Convert.ToDecimal(row["scheduled_hours"]).ToString("N1") + "<div class=\"pll-muted\">contact hours</div></td>");
            sb.Append("<td><a class=\"pll-link\" href=\"ProgrammeLecturerLoads.aspx?id=" + H(row["empID"]) + "\">Details</a><div style=\"margin-top:6px;\"><a class=\"pll-link\" href=\"ProgrammeLecturers.aspx?id=" + H(row["empID"]) + "\">Lecturer Profile</a></div></td>");
            sb.Append("</tr>");
        }

        litRows.Text = sb.ToString();
    }

    private void LoadDetail()
    {
        int lecturerId;
        if (!int.TryParse(Request.QueryString["id"], out lecturerId) || lecturerId <= 0)
        {
            phDetail.Visible = false;
            return;
        }

        DataTable dtSummary = ExecuteQuery(@"
            SELECT e.empID,
                   IFNULL(e.emp_name, '') AS emp_name,
                   IFNULL(e.EMP_CODE, '') AS emp_code,
                   IFNULL(d.dept_name, '') AS department_name,
                   IFNULL(c.contract_type, '') AS contract_type,
                   COUNT(*) AS course_count,
                   COUNT(DISTINCT ta.progcode) AS programme_count,
                   COALESCE(SUM(
                       CASE
                           WHEN ta.lectureday <> '-' AND ta.StartTime IS NOT NULL AND ta.EndTime IS NOT NULL
                           THEN TIMESTAMPDIFF(MINUTE, STR_TO_DATE(ta.StartTime,'%H:%i'), STR_TO_DATE(ta.EndTime,'%H:%i')) / 60.0
                           ELSE 0
                       END
                   ), 0) AS scheduled_hours,
                   GROUP_CONCAT(DISTINCT IFNULL(p.progname, ta.progcode) ORDER BY IFNULL(p.progname, ta.progcode) SEPARATOR ', ') AS programmes
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
               AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN acad_teaching_allocation ta ON CAST(ta.staffCode AS UNSIGNED) = e.empID
               AND ta.acad_year = @year AND ta.semester = @sem
            LEFT JOIN acad_programme p ON p.progcode = ta.progcode
            WHERE e.empID = @id
            GROUP BY e.empID, e.emp_name, e.EMP_CODE, d.dept_name, c.contract_type",
            new MySqlParameter("@id", lecturerId),
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        if (dtSummary.Rows.Count == 0)
        {
            phDetail.Visible = false;
            return;
        }

        DataRow row = dtSummary.Rows[0];
        DataTable dtAllocations = ExecuteQuery(@"
            SELECT ta.courseID,
                   IFNULL(c.courseName, '') AS course_name,
                   IFNULL(p.progname, ta.progcode) AS programme_name,
                   IFNULL(f.faculty_name, '') AS faculty_name,
                   IFNULL(ta.lectureday, '-') AS lecture_day,
                   CONCAT(IFNULL(ta.StartTime, '-'), ' - ', IFNULL(ta.EndTime, '-')) AS time_slot,
                   IFNULL(r.RoomName, ta.roomid) AS room_name
            FROM acad_teaching_allocation ta
            LEFT JOIN acad_course c ON c.courseID = ta.courseID
            LEFT JOIN acad_programme p ON p.progcode = ta.progcode
            LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code
            LEFT JOIN acad_lecturerooms r ON r.RoomID = ta.roomid
            WHERE CAST(ta.staffCode AS UNSIGNED) = @id
              AND ta.acad_year = @year AND ta.semester = @sem
            ORDER BY ta.progcode, ta.courseID",
            new MySqlParameter("@id", lecturerId),
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class=\"pll-detail\">");
        sb.Append("<div class=\"pll-box\">");
        sb.Append(BuildKv("Lecturer", row["emp_name"]));
        sb.Append(BuildKv("Code", row["emp_code"]));
        sb.Append(BuildKv("Department", row["department_name"]));
        sb.Append(BuildKv("Contract", row["contract_type"]));
        sb.Append(BuildKv("Courses", Convert.ToInt32(row["course_count"]).ToString("N0")));
        sb.Append(BuildKv("Programmes", Convert.ToInt32(row["programme_count"]).ToString("N0")));
        sb.Append(BuildKv("Hours", Convert.ToDecimal(row["scheduled_hours"]).ToString("N1") + " contact hours"));
        sb.Append(BuildKv("Programme Mix", string.IsNullOrEmpty(Safe(row["programmes"])) ? "No allocations" : Safe(row["programmes"])));
        sb.Append("</div>");

        sb.Append("<div class=\"pll-box\">");
        sb.Append("<div class=\"pll-card__title\" style=\"margin-bottom:10px;\">Allocation Breakdown</div>");
        if (dtAllocations.Rows.Count == 0)
        {
            sb.Append("<div class=\"pll-empty\" style=\"padding:12px 0;\">No allocations found for this lecturer in the selected period.</div>");
        }
        else
        {
            for (int i = 0; i < dtAllocations.Rows.Count; i++)
            {
                DataRow alloc = dtAllocations.Rows[i];
                sb.Append("<div class=\"pll-rowcard\">");
                sb.Append("<div style=\"font-weight:800;color:#05275C;\">" + H(alloc["courseID"]) + " - " + H(alloc["course_name"]) + "</div>");
                sb.Append("<div class=\"pll-muted\" style=\"margin-top:4px;\">" + H(alloc["programme_name"]) + " &bull; " + H(alloc["faculty_name"]) + "</div>");
                sb.Append("<div class=\"pll-muted\" style=\"margin-top:4px;\">" + H(alloc["lecture_day"]) + " &bull; " + H(alloc["time_slot"]) + " &bull; Room: " + H(alloc["room_name"]) + "</div>");
                sb.Append("</div>");
            }
        }
        sb.Append("</div>");
        sb.Append("</div>");

        litDetail.Text = sb.ToString();
        phDetail.Visible = true;
    }

    private string BuildKv(string key, object value)
    {
        return "<div class=\"pll-kv\"><div class=\"pll-kv__k\">" + H(key) + "</div><div class=\"pll-kv__v\">" + H(value) + "</div></div>";
    }

    private string BuildCourseSnapshotHtml(object coursesPreviewObj, object courseCountObj)
    {
        int courseCount;
        int.TryParse(Safe(courseCountObj), out courseCount);

        string preview = Safe(coursesPreviewObj);
        if (string.IsNullOrEmpty(preview) || courseCount <= 0)
        {
            return "<span class=\"pll-muted\">No current allocations</span>";
        }

        string[] courses = preview.Split(new string[] { "||" }, StringSplitOptions.RemoveEmptyEntries);
        int showCount = courses.Length > 4 ? 4 : courses.Length;

        StringBuilder html = new StringBuilder();
        html.Append("<span class=\"pll-pill\">").Append(courseCount.ToString("N0")).Append(" course(s)</span>");
        html.Append("<div class=\"pll-chip-wrap\">");
        for (int i = 0; i < showCount; i++)
        {
            html.Append("<span class=\"pll-chip\" title=\"").Append(A(courses[i])).Append("\">").Append(H(courses[i])).Append("</span>");
        }

        if (courseCount > showCount)
        {
            html.Append("<span class=\"pll-chip pll-chip--more\">+").Append(courseCount - showCount).Append(" more</span>");
        }

        html.Append("</div>");
        return html.ToString();
    }

    private int GetCount(string sql, params MySqlParameter[] parms)
    {
        object value = ExecuteScalar(sql, parms);
        int result;
        return int.TryParse(Convert.ToString(value), out result) ? result : 0;
    }

    private object ExecuteScalar(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                {
                    for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
                }
                return cmd.ExecuteScalar();
            }
        }
    }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                {
                    for (int i = 0; i < parms.Length; i++) cmd.Parameters.Add(parms[i]);
                }
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
        }
        return dt;
    }

    private string Safe(object value)
    {
        return value == null || value == DBNull.Value ? "" : value.ToString();
    }

    private string H(object value)
    {
        return HttpUtility.HtmlEncode(Safe(value));
    }

    private string A(string value)
    {
        return HttpUtility.HtmlAttributeEncode(value ?? "");
    }
}
