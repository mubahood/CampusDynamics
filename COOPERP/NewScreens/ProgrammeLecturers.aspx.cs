using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_ProgrammeLecturers : System.Web.UI.Page
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

        LoadStats();
        LoadList();
        LoadDetail();
    }

    private void LoadStats()
    {
        litTotalLecturers.Text = GetCount(@"
            SELECT COUNT(*)
            FROM hrm_employee e
            WHERE e.EmpType = 'Academic'").ToString("N0");

        litLoadedLecturers.Text = GetCount(@"
            SELECT COUNT(DISTINCT CAST(ta.staffCode AS UNSIGNED))
            FROM acad_teaching_allocation ta
            WHERE ta.acad_year = @year AND ta.semester = @sem",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester)).ToString("N0");

        litFullTimeLecturers.Text = GetCount(@"
            SELECT COUNT(*)
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
               AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            WHERE e.EmpType = 'Academic' AND UPPER(IFNULL(c.contract_type, '')) LIKE '%FULL%'").ToString("N0");

        litDepartmentCount.Text = GetCount(@"
            SELECT COUNT(DISTINCT c.departmentID)
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
               AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            WHERE e.EmpType = 'Academic' AND c.departmentID IS NOT NULL").ToString("N0");
    }

    private void LoadList()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT e.empID,
                   IFNULL(e.EMP_CODE, '') AS emp_code,
                   IFNULL(e.emp_name, '') AS emp_name,
                   IFNULL(j.jobname, 'Lecturer') AS job_title,
                   IFNULL(d.dept_name, '') AS department_name,
                   IFNULL(st.station_name, '') AS station_name,
                   IFNULL(e.emp_email, '') AS emp_email,
                   IFNULL(e.emp_phone, '') AS emp_phone,
                   IFNULL(c.contract_type, '') AS contract_type,
                   IFNULL(c.contractStatus, '') AS contract_status,
                   IFNULL((
                        SELECT GROUP_CONCAT(DISTINCT f.faculty_name ORDER BY f.faculty_name SEPARATOR ', ')
                        FROM acad_teaching_allocation ta
                        LEFT JOIN acad_programme p ON p.progcode = ta.progcode
                        LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code
                        WHERE CAST(ta.staffCode AS UNSIGNED) = e.empID
                          AND ta.acad_year = @year AND ta.semester = @sem
                   ), '') AS faculty_context,
                   IFNULL((
                        SELECT COUNT(DISTINCT ta.courseID)
                        FROM acad_teaching_allocation ta
                        WHERE CAST(ta.staffCode AS UNSIGNED) = e.empID
                          AND ta.acad_year = @year AND ta.semester = @sem
                   ), 0) AS current_load
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
               AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
            WHERE e.EmpType = 'Academic'
               OR EXISTS (SELECT 1 FROM acad_teaching_allocation ta WHERE CAST(ta.staffCode AS UNSIGNED) = e.empID)
            ORDER BY e.emp_name ASC",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        if (dt.Rows.Count == 0)
        {
            litRows.Text = "<tr><td colspan=\"5\"><div class=\"pl-empty\">No lecturers were found.</div></td></tr>";
            return;
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            DataRow row = dt.Rows[i];
            string search = string.Join(" ", new string[]
            {
                Safe(row["emp_name"]), Safe(row["emp_code"]), Safe(row["department_name"]), Safe(row["faculty_context"]), Safe(row["job_title"])
            });

            sb.Append("<tr data-lecturer-row=\"1\" data-search=\"").Append(A(Safe(search))).Append("\">");
            sb.Append("<td>");
            sb.Append("<div style=\"font-weight:800;color:#05275C;\">" + H(row["emp_name"]) + "</div>");
            sb.Append("<div class=\"pl-code\">" + H(row["emp_code"]) + "</div>");
            sb.Append("<div class=\"pl-muted\">" + H(row["job_title"]) + "</div>");
            sb.Append("</td>");
            sb.Append("<td>" + H(row["department_name"]) + "<div class=\"pl-muted\">" + H(row["station_name"]) + "</div></td>");
            sb.Append("<td>" + (string.IsNullOrEmpty(Safe(row["faculty_context"])) ? "<span class=\"pl-muted\">No active faculty load</span>" : H(row["faculty_context"])) + "</td>");
            sb.Append("<td><span class=\"pl-pill pl-pill--academic\">" + Convert.ToInt32(row["current_load"]).ToString("N0") + " courses</span><div class=\"pl-muted\" style=\"margin-top:5px;\">" + H(row["contract_type"]) + "</div></td>");
            sb.Append("<td>");
            sb.Append("<a class=\"pl-link\" href=\"ProgrammeLecturers.aspx?id=" + H(row["empID"]) + "\">Details</a>");
            sb.Append("<div style=\"margin-top:6px;\"><a class=\"pl-link\" href=\"ProgrammeLecturerLoads.aspx?id=" + H(row["empID"]) + "\">View Loads</a></div>");
            sb.Append("</td>");
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

        DataTable dt = ExecuteQuery(@"
            SELECT e.empID,
                   IFNULL(e.EMP_CODE, '') AS emp_code,
                   IFNULL(e.emp_name, '') AS emp_name,
                   IFNULL(e.emp_email, '') AS emp_email,
                   IFNULL(e.emp_phone, '') AS emp_phone,
                   IFNULL(e.emp_qualifications, '') AS qualifications,
                   IFNULL(j.jobname, 'Lecturer') AS job_title,
                   IFNULL(d.dept_name, '') AS department_name,
                   IFNULL(st.station_name, '') AS station_name,
                   IFNULL(c.contract_type, '') AS contract_type,
                   IFNULL(c.contractStatus, '') AS contract_status,
                   IFNULL((
                        SELECT COUNT(DISTINCT ta.courseID)
                        FROM acad_teaching_allocation ta
                        WHERE CAST(ta.staffCode AS UNSIGNED) = e.empID
                          AND ta.acad_year = @year AND ta.semester = @sem
                   ), 0) AS current_load,
                   IFNULL((
                        SELECT GROUP_CONCAT(DISTINCT p.progname ORDER BY p.progname SEPARATOR ', ')
                        FROM acad_teaching_allocation ta
                        LEFT JOIN acad_programme p ON p.progcode = ta.progcode
                        WHERE CAST(ta.staffCode AS UNSIGNED) = e.empID
                          AND ta.acad_year = @year AND ta.semester = @sem
                   ), '') AS programmes
            FROM hrm_employee e
            LEFT JOIN hrm_emp_contracts c ON c.empID = e.empID
               AND c.ID = (SELECT MAX(c2.ID) FROM hrm_emp_contracts c2 WHERE c2.empID = e.empID)
            LEFT JOIN hrm_jobs j ON j.ID = c.jobID
            LEFT JOIN hrm_departments d ON d.ID = c.departmentID
            LEFT JOIN hrm_stations st ON st.ID = e.Entry_Satation
            WHERE e.empID = @id",
            new MySqlParameter("@id", lecturerId),
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        if (dt.Rows.Count == 0)
        {
            phDetail.Visible = false;
            return;
        }

        DataRow row = dt.Rows[0];
        DataTable dtAllocations = ExecuteQuery(@"
            SELECT ta.courseID,
                   IFNULL(c.courseName, '') AS course_name,
                   IFNULL(p.progname, ta.progcode) AS programme_name,
                   IFNULL(ta.lectureday, '-') AS lecture_day,
                   CONCAT(IFNULL(ta.StartTime, '-'), ' - ', IFNULL(ta.EndTime, '-')) AS time_slot
            FROM acad_teaching_allocation ta
            LEFT JOIN acad_course c ON c.courseID = ta.courseID
            LEFT JOIN acad_programme p ON p.progcode = ta.progcode
            WHERE CAST(ta.staffCode AS UNSIGNED) = @id
              AND ta.acad_year = @year AND ta.semester = @sem
            ORDER BY ta.progcode, ta.courseID",
            new MySqlParameter("@id", lecturerId),
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        StringBuilder sb = new StringBuilder();
        sb.Append("<div class=\"pl-detail\">");
        sb.Append("<div class=\"pl-detail__box\">");
        sb.Append("<div class=\"pl-detail__name\">" + H(row["emp_name"]) + "</div>");
        sb.Append("<div class=\"pl-detail__meta\">" + H(row["emp_code"]) + " &bull; " + H(row["job_title"]) + "</div>");
        sb.Append(BuildKv("Department", row["department_name"]));
        sb.Append(BuildKv("Station", row["station_name"]));
        sb.Append(BuildKv("Email", row["emp_email"]));
        sb.Append(BuildKv("Phone", row["emp_phone"]));
        sb.Append(BuildKv("Contract", row["contract_type"]));
        sb.Append(BuildKv("Status", row["contract_status"]));
        sb.Append(BuildKv("Current Load", Convert.ToInt32(row["current_load"]).ToString("N0") + " course(s)"));
        sb.Append(BuildKv("Programmes", string.IsNullOrEmpty(Safe(row["programmes"])) ? "No active programme load" : Safe(row["programmes"])));
        sb.Append("<div class=\"pl-detail__actions\">");
        sb.Append("<a class=\"pl-btn pl-btn--primary\" href=\"ProgrammeLecturerLoads.aspx?id=" + H(row["empID"]) + "\">Open Lecturer Loads</a>");
        sb.Append("</div>");
        sb.Append("</div>");

        sb.Append("<div class=\"pl-detail__box\">");
        sb.Append("<div class=\"pl-card__title\" style=\"margin-bottom:10px;\">Current Semester Allocations</div>");
        if (dtAllocations.Rows.Count == 0)
        {
            sb.Append("<div class=\"pl-empty\" style=\"padding:12px 0;\">No allocations found for the selected period.</div>");
        }
        else
        {
            for (int i = 0; i < dtAllocations.Rows.Count; i++)
            {
                DataRow allocation = dtAllocations.Rows[i];
                sb.Append("<div style=\"border:1px solid #e7ebf1;background:#fff;padding:10px 12px;margin-bottom:8px;\">");
                sb.Append("<div style=\"font-weight:700;color:#05275C;\">" + H(allocation["courseID"]) + " - " + H(allocation["course_name"]) + "</div>");
                sb.Append("<div class=\"pl-muted\" style=\"margin-top:4px;\">" + H(allocation["programme_name"]) + " &bull; " + H(allocation["lecture_day"]) + " &bull; " + H(allocation["time_slot"]) + "</div>");
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
        return "<div class=\"pl-kv\"><div class=\"pl-kv__k\">" + H(key) + "</div><div class=\"pl-kv__v\">" + H(value) + "</div></div>";
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
