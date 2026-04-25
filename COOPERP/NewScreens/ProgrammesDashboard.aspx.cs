using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_ProgrammesDashboard : System.Web.UI.Page
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
        LoadDashboard();
    }

    private bool HasLecturerAssignmentColumns()
    {
        return GetCount(@"
            SELECT COUNT(*)
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'acad_programmecourses'
              AND COLUMN_NAME IN ('is_lecturere_assigned','lecturer_id','status')") == 3;
    }

    private bool HasAllocationRequestColumns()
    {
        return GetCount(@"
            SELECT COUNT(*)
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'acad_programmecourses'
              AND COLUMN_NAME IN (
                  'allocation_request_status',
                  'allocation_request_lecturer_id',
                  'allocation_request_date',
                  'allocation_request_message',
                  'allocation_request_admin_status',
                  'allocation_request_admin_message')") == 6;
    }

    private void LoadDashboard()
    {
        bool hasLecturerCols = HasLecturerAssignmentColumns();
        bool hasRequestCols = HasAllocationRequestColumns();

        int facultyCount = GetCount("SELECT COUNT(*) FROM acad_faculty");
        int programmeCount = GetCount("SELECT COUNT(*) FROM acad_programme");
        int specialisationCount = GetCount("SELECT COUNT(*) FROM acad_specialisation WHERE spec <> '-'");
        int courseCount = GetCount("SELECT COUNT(*) FROM acad_course");
        int mappedCourseCount = GetCount("SELECT COUNT(*) FROM acad_programmecourses");
        int activeProgrammeCount = GetCount("SELECT COUNT(DISTINCT progcode) FROM acad_programmecourses");
        int loadCount = GetCount(@"SELECT COUNT(*) FROM acad_teaching_allocation WHERE acad_year = @year AND semester = @sem",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));
        int lecturersWithLoad = GetCount(@"SELECT COUNT(DISTINCT CAST(staffCode AS UNSIGNED)) FROM acad_teaching_allocation WHERE acad_year = @year AND semester = @sem",
            new MySqlParameter("@year", CurrentAcadYear),
            new MySqlParameter("@sem", CurrentSemester));

        int assignedCount = 0;
        int unassignedCount = 0;
        int inactiveAssignmentCount = 0;
        if (hasLecturerCols)
        {
            assignedCount = GetCount(@"SELECT COUNT(*) FROM acad_programmecourses WHERE IFNULL(is_lecturere_assigned,'No')='Yes' AND IFNULL(lecturer_id,0) > 0");
            unassignedCount = GetCount(@"SELECT COUNT(*) FROM acad_programmecourses WHERE IFNULL(is_lecturere_assigned,'No') <> 'Yes' OR IFNULL(lecturer_id,0)=0");
            inactiveAssignmentCount = GetCount(@"SELECT COUNT(*) FROM acad_programmecourses WHERE IFNULL(is_lecturere_assigned,'No')='Yes' AND UPPER(IFNULL(status,'Active'))='INACTIVE'");
        }

        int pendingRequests = 0;
        int approvedRequests = 0;
        int rejectedRequests = 0;
        if (hasRequestCols)
        {
            pendingRequests = GetCount(@"SELECT COUNT(*) FROM acad_programmecourses WHERE IFNULL(allocation_request_lecturer_id,0) > 0 AND UPPER(IFNULL(allocation_request_admin_status,'Pending'))='PENDING'");
            approvedRequests = GetCount(@"SELECT COUNT(*) FROM acad_programmecourses WHERE UPPER(IFNULL(allocation_request_admin_status,'Pending'))='APPROVED'");
            rejectedRequests = GetCount(@"SELECT COUNT(*) FROM acad_programmecourses WHERE UPPER(IFNULL(allocation_request_admin_status,'Pending'))='REJECTED'");
        }

        litFacultyCount.Text = facultyCount.ToString("N0");
        litProgrammeCount.Text = programmeCount.ToString("N0");
        litProgrammeSub.Text = activeProgrammeCount.ToString("N0") + " programme(s) already mapped to courses" + (specialisationCount > 0 ? " • " + specialisationCount.ToString("N0") + " specialisations" : "");
        litMappingCount.Text = mappedCourseCount.ToString("N0");
        litMappingSub.Text = hasLecturerCols
            ? (assignedCount.ToString("N0") + " assigned • " + unassignedCount.ToString("N0") + " still need lecturer mapping")
            : "Mapped courses across programmes";
        litCourseCount.Text = courseCount.ToString("N0");
        litCourseSub.Text = mappedCourseCount > 0
            ? Math.Round((mappedCourseCount * 100.0m) / Math.Max(courseCount, 1), 1).ToString("N1") + "% mapping volume vs course bank"
            : "Course bank records";
        litPendingRequests.Text = pendingRequests.ToString("N0");
        litPendingRequestsSub.Text = hasRequestCols
            ? (approvedRequests.ToString("N0") + " approved • " + rejectedRequests.ToString("N0") + " rejected")
            : "Request workflow columns are not yet enabled";
        litLoadCount.Text = loadCount.ToString("N0");
        litLoadSub.Text = lecturersWithLoad.ToString("N0") + " lecturer(s) carrying load this semester";

        litFacultyBars.Text = BuildFacultyBars();
        litPriorityTasks.Text = BuildPriorityTasks(unassignedCount, pendingRequests, inactiveAssignmentCount, loadCount, activeProgrammeCount, mappedCourseCount);
        litYearMix.Text = BuildYearMix();
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

    private string H(object value)
    {
        return HttpUtility.HtmlEncode(value == null || value == DBNull.Value ? "" : value.ToString());
    }

    private string BuildFacultyBars()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT f.faculty_name,
                   COUNT(DISTINCT p.progcode) AS programme_count,
                   COUNT(DISTINCT pc.ID) AS mapped_courses
            FROM acad_faculty f
            LEFT JOIN acad_programme p ON p.faculty_code = f.faculty_code
            LEFT JOIN acad_programmecourses pc ON pc.progcode = p.progcode
            GROUP BY f.faculty_code, f.faculty_name
            ORDER BY programme_count DESC, f.faculty_name ASC");

        if (dt.Rows.Count == 0) return "<div class=\"pgd-empty\">No faculty statistics are available yet.</div>";

        int maxCount = 1;
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            int count = Convert.ToInt32(dt.Rows[i]["programme_count"]);
            if (count > maxCount) maxCount = count;
        }

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            DataRow row = dt.Rows[i];
            int programmeCount = Convert.ToInt32(row["programme_count"]);
            int mappedCourses = Convert.ToInt32(row["mapped_courses"]);
            int width = maxCount == 0 ? 0 : (int)Math.Round((programmeCount * 100.0) / maxCount);
            sb.Append("<div class=\"pgd-bar__row\">");
            sb.Append("<div class=\"pgd-bar__label\">" + H(row["faculty_name"]) + "</div>");
            sb.Append("<div class=\"pgd-bar__track\"><div class=\"pgd-bar__fill\" style=\"width:" + width.ToString() + "%\"></div></div>");
            sb.Append("<div class=\"pgd-bar__value\">" + programmeCount.ToString("N0") + " programmes • " + mappedCourses.ToString("N0") + " mapped courses</div>");
            sb.Append("</div>");
        }
        return sb.ToString();
    }

    private string BuildPriorityTasks(int unassignedCount, int pendingRequests, int inactiveAssignmentCount, int loadCount, int activeProgrammeCount, int mappedCourseCount)
    {
        StringBuilder sb = new StringBuilder();
        AppendTask(sb, "ProgrammeLoadRequests.aspx", "Review pending load requests", pendingRequests, pendingRequests > 0 ? "Lecturer requests waiting for programme/admin review." : "No pending load requests right now.");
        AppendTask(sb, "NewProgrammeCourses.aspx?asg=No", "Assign lecturers to mapped courses", unassignedCount, unassignedCount > 0 ? "Mapped courses without lecturer assignment should be completed." : "All mapped courses currently have lecturer assignments.");
        AppendTask(sb, "NewProgrammeCourses.aspx?rq=Pending", "Follow up request decisions", pendingRequests, "Open requested course rows and approve or reject lecturer requests.");
        AppendTask(sb, "NewProgrammeCourses.aspx", "Audit inactive assignments", inactiveAssignmentCount, inactiveAssignmentCount > 0 ? "Some lecturer-linked mappings are marked inactive and should be reviewed." : "No inactive lecturer assignments detected.");
        AppendTask(sb, "ProgrammeLecturerLoads.aspx", "Balance current teaching loads", loadCount, loadCount > 0 ? "Review current semester teaching allocation coverage." : "No current semester teaching allocations are loaded yet.");
        AppendTask(sb, "CourseRegistrationLedgerController.aspx", "Review programme-course controller", mappedCourseCount, activeProgrammeCount.ToString("N0") + " programme(s) represented in the controller.");

        return sb.ToString();
    }

    private void AppendTask(StringBuilder sb, string url, string title, int count, string sub)
    {
        sb.Append("<a class=\"pgd-task\" href=\"").Append(H(url)).Append("\">");
        sb.Append("<div class=\"pgd-task__top\">");
        sb.Append("<div class=\"pgd-task__title\">" + H(title) + "</div>");
        sb.Append("<span class=\"pgd-task__count\">" + count.ToString("N0") + "</span>");
        sb.Append("</div>");
        sb.Append("<div class=\"pgd-task__sub\">" + H(sub) + "</div>");
        sb.Append("</a>");
    }

    private string BuildYearMix()
    {
        bool hasLecturerCols = HasLecturerAssignmentColumns();
         string sql = hasLecturerCols
             ? @"
             SELECT study_year,
                 COUNT(*) AS row_count,
                 SUM(CASE WHEN IFNULL(is_lecturere_assigned,'No')='Yes' AND IFNULL(lecturer_id,0) > 0 THEN 1 ELSE 0 END) AS assigned_count
             FROM acad_programmecourses
             GROUP BY study_year
             ORDER BY study_year"
             : @"
             SELECT study_year,
                 COUNT(*) AS row_count,
                 0 AS assigned_count
             FROM acad_programmecourses
             GROUP BY study_year
             ORDER BY study_year";

         DataTable dt = ExecuteQuery(sql);

        int total = 0;
        for (int i = 0; i < dt.Rows.Count; i++) total += Convert.ToInt32(dt.Rows[i]["row_count"]);

        StringBuilder sb = new StringBuilder();
        for (int year = 1; year <= 4; year++)
        {
            int count = 0;
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                if (Convert.ToInt32(dt.Rows[i]["study_year"]) == year)
                {
                    count = Convert.ToInt32(dt.Rows[i]["row_count"]);
                    int assignedCount = dt.Rows[i]["assigned_count"] == DBNull.Value ? 0 : Convert.ToInt32(dt.Rows[i]["assigned_count"]);
                    double pct = total == 0 ? 0 : (count * 100.0 / total);
                    string sub = pct.ToString("N1") + "% of mapped courses";
                    if (hasLecturerCols && count > 0)
                        sub += " • " + Math.Round((assignedCount * 100.0) / count, 1).ToString("N1") + "% assigned";
                    sb.Append("<div class=\"pgd-yearmix__card\">");
                    sb.Append("<div class=\"pgd-yearmix__title\">Year " + year.ToString() + "</div>");
                    sb.Append("<div class=\"pgd-yearmix__value\">" + count.ToString("N0") + "</div>");
                    sb.Append("<div class=\"pgd-yearmix__sub\">" + sub + "</div>");
                    sb.Append("</div>");
                    break;
                }
            }
            if (count == 0)
            {
                sb.Append("<div class=\"pgd-yearmix__card\">");
                sb.Append("<div class=\"pgd-yearmix__title\">Year " + year.ToString() + "</div>");
                sb.Append("<div class=\"pgd-yearmix__value\">0</div>");
                sb.Append("<div class=\"pgd-yearmix__sub\">No mapped courses</div>");
                sb.Append("</div>");
            }
        }
        return sb.ToString();
    }
}
