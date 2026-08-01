using System;
using System.Configuration;
using System.Collections.Generic;
using System.Collections;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Services;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_NewProgrammeCourses : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static int ToIntSafe(object value, int fallback)
    {
        if (value == null || value == DBNull.Value) return fallback;
        int parsed;
        return int.TryParse(value.ToString(), out parsed) ? parsed : fallback;
    }

    private static string ToStrSafe(object value)
    {
        if (value == null || value == DBNull.Value) return "";
        return value.ToString();
    }

    private static Dictionary<string, object> ToDictionarySafe(object raw)
    {
        if (raw == null) return null;

        Dictionary<string, object> direct = raw as Dictionary<string, object>;
        if (direct != null) return direct;

        IDictionary map = raw as IDictionary;
        if (map == null) return null;

        Dictionary<string, object> converted = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        foreach (DictionaryEntry de in map)
        {
            string key = de.Key == null ? "" : de.Key.ToString();
            if (!string.IsNullOrEmpty(key)) converted[key] = de.Value;
        }
        return converted;
    }

    private static string ConnStrStatic
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------
    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
        }
        catch { }
        return dt;
    }

    private int ExecuteNonQuery(string sql, params MySqlParameter[] parms)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null) foreach (var p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private void TrySelect(DropDownList ddl, string value)
    {
        ListItem item = ddl.Items.FindByValue(value);
        if (item != null) { ddl.ClearSelection(); item.Selected = true; }
    }

    private string JsEncode(string s)
    {
        if (s == null) return "''";
        return "'" + HttpUtility.JavaScriptStringEncode(s) + "'";
    }

    private string NormalizeYesNo(string val)
    {
        return string.Equals((val ?? "").Trim(), "Yes", StringComparison.OrdinalIgnoreCase) ? "Yes" : "No";
    }

    private string NormalizeStatus(string val)
    {
        return string.Equals((val ?? "").Trim(), "Inactive", StringComparison.OrdinalIgnoreCase) ? "Inactive" : "Active";
    }

    private bool LecturerExists(int lecturerId)
    {
        DataTable dt = ExecuteQuery("SELECT COUNT(*) AS cnt FROM hrm_employee WHERE empID=@id",
            new MySqlParameter("@id", lecturerId));
        return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0]["cnt"]) > 0;
    }

    private bool HasLecturerAssignmentColumns()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT COUNT(*) AS cnt
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'acad_programmecourses'
              AND COLUMN_NAME IN ('is_lecturere_assigned','lecturer_id','status')");
        return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0]["cnt"]) == 3;
    }

    private static bool HasLecturerAssignmentColumnsStatic(MySqlConnection conn, MySqlTransaction tx)
    {
        using (MySqlCommand cmd = new MySqlCommand(@"
            SELECT COUNT(*)
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'acad_programmecourses'
              AND COLUMN_NAME IN ('is_lecturere_assigned','lecturer_id','status')", conn, tx))
        {
            int cnt = Convert.ToInt32(cmd.ExecuteScalar());
            return cnt == 3;
        }
    }

    private bool HasAllocationRequestColumns()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT COUNT(*) AS cnt
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'acad_programmecourses'
              AND COLUMN_NAME IN (
                  'allocation_request_status',
                  'allocation_request_lecturer_id',
                  'allocation_request_date',
                  'allocation_request_message',
                  'allocation_request_admin_status',
                  'allocation_request_admin_message')");
        return dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0]["cnt"]) == 6;
    }

    private static bool HasAllocationRequestColumnsStatic(MySqlConnection conn, MySqlTransaction tx)
    {
        using (MySqlCommand cmd = new MySqlCommand(@"
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
                  'allocation_request_admin_message')", conn, tx))
        {
            int cnt = Convert.ToInt32(cmd.ExecuteScalar());
            return cnt == 6;
        }
    }

    private void EnsureAllocationRequestColumns()
    {
        string[] sqls = new string[]
        {
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_status VARCHAR(3) NULL DEFAULT 'No'",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_lecturer_id INT NULL",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_date DATETIME NULL",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_message TEXT NULL",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_admin_status VARCHAR(20) NULL DEFAULT 'Pending'",
            "ALTER TABLE acad_programmecourses ADD COLUMN allocation_request_admin_message TEXT NULL"
        };

        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            for (int i = 0; i < sqls.Length; i++)
            {
                try
                {
                    using (MySqlCommand cmd = new MySqlCommand(sqls[i], conn)) cmd.ExecuteNonQuery();
                }
                catch { }
            }
        }
    }

    // ---------------------------------------------------------------
    // Page Load
    // ---------------------------------------------------------------
    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureAllocationRequestColumns();
        LoadProgrammes();
        LoadSpecialisations();
        LoadLecturers();
        SetMigrationNotice();

        string postedProg = Request.Form[ddlProgramme.UniqueID];
        if (!string.IsNullOrEmpty(postedProg)) TrySelect(ddlProgramme, postedProg);

        string postedSpec = Request.Form[ddlSpecialisation.UniqueID];
        if (!string.IsNullOrEmpty(postedSpec)) TrySelect(ddlSpecialisation, postedSpec);

        string postedYear = Request.Form[ddlYear.UniqueID];
        if (!string.IsNullOrEmpty(postedYear)) TrySelect(ddlYear, postedYear);

        string postedSem = Request.Form[ddlSemester.UniqueID];
        if (!string.IsNullOrEmpty(postedSem)) TrySelect(ddlSemester, postedSem);

        string postedType = Request.Form[ddlCourseType.UniqueID];
        if (!string.IsNullOrEmpty(postedType)) TrySelect(ddlCourseType, postedType);

        LoadStats();
        BindGrid();
    }

    private void SetMigrationNotice()
    {
        bool ok = HasLecturerAssignmentColumns();
        phMigrationNotice.Visible = !ok;
        if (!ok)
        {
            litMigrationNotice.Text = "Lecturer-assignment migration is not fully applied. Run <strong>COOPERP/NewScreens/migration_programme_course_lecturer_assignment.sql</strong> to enable lecturer assignment save and batch operations.";
        }
    }

    private void LoadProgrammes()
    {
        DataTable dt = ExecuteQuery("SELECT progcode, progname FROM acad_programme ORDER BY progname");
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
        foreach (DataRow r in dt.Rows)
            ddlProgramme.Items.Add(new ListItem(r["progname"].ToString(), r["progcode"].ToString()));
    }

    private void LoadSpecialisations()
    {
        DataTable dt = ExecuteQuery(
            "SELECT spec_id, prog_id, spec FROM acad_specialisation WHERE spec != '-' ORDER BY spec");
        ddlSpecialisation.Items.Clear();
        ddlSpecialisation.Items.Add(new ListItem("-- Select Specialisation --", ""));
        foreach (DataRow r in dt.Rows)
            ddlSpecialisation.Items.Add(new ListItem(r["spec"].ToString(), r["spec_id"].ToString()));
    }

    private void LoadLecturers()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT e.empID,
                   CONCAT(IFNULL(e.emp_name,''),
                          CASE WHEN IFNULL(e.emp_code,'')='' THEN '' ELSE CONCAT(' (', e.emp_code, ')') END) AS lecturer_name
            FROM hrm_employee e
            WHERE IFNULL(TRIM(e.emp_name),'') <> ''
            ORDER BY e.emp_name");

        ddlLecturer.Items.Clear();
        ddlLecturer.Items.Add(new ListItem("-- Select Lecturer --", ""));
        foreach (DataRow r in dt.Rows)
            ddlLecturer.Items.Add(new ListItem(r["lecturer_name"].ToString(), r["empID"].ToString()));
    }

    // ---------------------------------------------------------------
    // Stats
    // ---------------------------------------------------------------
    private void LoadStats()
    {
        string sql = @"
            SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN UPPER(IFNULL(course_type,'CORE'))='CORE'     THEN 1 ELSE 0 END) AS core_count,
                SUM(CASE WHEN UPPER(IFNULL(course_type,'CORE'))='ELECTIVE' THEN 1 ELSE 0 END) AS elective_count,
                COUNT(DISTINCT progcode) AS prog_count
            FROM acad_programmecourses";
        DataTable dt = ExecuteQuery(sql);
        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            litTotal.Text        = r["total"].ToString();
            litCoreCount.Text    = r["core_count"].ToString();
            litElectiveCount.Text= r["elective_count"].ToString();
            litProgCount.Text    = r["prog_count"].ToString();
            litMetaTotal.Text    = r["total"].ToString();
        }

        if (HasAllocationRequestColumns())
        {
            DataTable dtReq = ExecuteQuery(@"SELECT COUNT(*) AS n FROM acad_programmecourses
                                            WHERE IFNULL(allocation_request_lecturer_id,0) > 0
                                              AND UPPER(IFNULL(allocation_request_admin_status,'Pending'))='PENDING'");
            int pending = (dtReq.Rows.Count > 0) ? Convert.ToInt32(dtReq.Rows[0]["n"]) : 0;
            litRequestAlert.Text = pending > 0
                ? ("<span class=\"pc-pill pc-pill--elective\" style=\"margin-left:8px;\">Pending Requests: " + pending + "</span>")
                : "";
        }
        else
        {
            litRequestAlert.Text = "";
        }
    }

    // ---------------------------------------------------------------
    // Grid (server-side paging + URL filters)
    // ---------------------------------------------------------------
    private void BindGrid()
    {
        bool hasLecturerCols = HasLecturerAssignmentColumns();
        bool hasRequestCols = HasAllocationRequestColumns();
        const int PageSize = 50;
        int page = 1;
        int.TryParse(Request.QueryString["page"], out page);
        if (page < 1) page = 1;

        string qYear = (Request.QueryString["yr"]  ?? "").Trim();
        string qSem  = (Request.QueryString["sem"] ?? "").Trim();
        string qAssigned = (Request.QueryString["asg"] ?? "").Trim();
        string qLecturer = (Request.QueryString["lec"] ?? "").Trim();
        string qType = (Request.QueryString["tp"]  ?? "").Trim();
        string qReq = (Request.QueryString["rq"] ?? "").Trim();
        string qSearch = (Request.QueryString["q"]   ?? "").Trim();
        int qFocusId = 0;
        int.TryParse((Request.QueryString["focusId"] ?? "").Trim(), out qFocusId);

        StringBuilder wh = new StringBuilder();
        System.Collections.Generic.List<MySqlParameter> prms =
            new System.Collections.Generic.List<MySqlParameter>();

        if (!string.IsNullOrEmpty(qYear))
        { wh.Append(" AND pc.study_year = @yr"); prms.Add(new MySqlParameter("@yr", qYear)); }
        if (!string.IsNullOrEmpty(qSem))
        { wh.Append(" AND pc.semester = @sem"); prms.Add(new MySqlParameter("@sem", qSem)); }
        if (hasLecturerCols && !string.IsNullOrEmpty(qAssigned))
        {
            string asg = string.Equals(qAssigned, "Yes", StringComparison.OrdinalIgnoreCase) ? "Yes" :
                         string.Equals(qAssigned, "No", StringComparison.OrdinalIgnoreCase) ? "No" : "";
            if (!string.IsNullOrEmpty(asg))
            {
                wh.Append(" AND IFNULL(pc.is_lecturere_assigned,'No') = @asg");
                prms.Add(new MySqlParameter("@asg", asg));
            }
        }
        if (hasLecturerCols && !string.IsNullOrEmpty(qLecturer))
        {
            int lecturerId;
            if (int.TryParse(qLecturer, out lecturerId) && lecturerId > 0)
            {
                wh.Append(" AND IFNULL(pc.lecturer_id,0) = @lec");
                prms.Add(new MySqlParameter("@lec", lecturerId));
            }
        }
        if (!string.IsNullOrEmpty(qType))
        { wh.Append(" AND UPPER(IFNULL(pc.course_type,'CORE')) = @tp"); prms.Add(new MySqlParameter("@tp", qType.ToUpper())); }
        if (hasRequestCols && !string.IsNullOrEmpty(qReq))
        {
            string req = qReq.Trim().ToUpper();
            if (req == "PENDING")
                wh.Append(" AND IFNULL(pc.allocation_request_lecturer_id,0) > 0 AND UPPER(IFNULL(pc.allocation_request_admin_status,'Pending'))='PENDING'");
            else if (req == "APPROVED")
                wh.Append(" AND UPPER(IFNULL(pc.allocation_request_admin_status,'Pending'))='APPROVED'");
            else if (req == "REJECTED")
                wh.Append(" AND UPPER(IFNULL(pc.allocation_request_admin_status,'Pending'))='REJECTED'");
            else if (req == "REQUESTED")
                wh.Append(" AND IFNULL(pc.allocation_request_lecturer_id,0) > 0");
        }
        if (!string.IsNullOrEmpty(qSearch))
        {
            string like = "%" + qSearch + "%";
            wh.Append(" AND (pc.course_code LIKE @qs OR IFNULL(c.courseName,'') LIKE @qs OR IFNULL(p.progname,'') LIKE @qs OR IFNULL(sp.spec,'') LIKE @qs OR pc.progcode LIKE @qs)");
            prms.Add(new MySqlParameter("@qs", like));
        }

        string filterClause = wh.ToString();
        if (qFocusId > 0)
        {
            wh = new StringBuilder(" AND (pc.ID=@focusId OR (1=1" + filterClause + "))");
            prms.Add(new MySqlParameter("@focusId", qFocusId));
        }

        string joins = @"
            FROM acad_programmecourses pc
            LEFT JOIN acad_programme p ON pc.progcode = p.progcode
            LEFT JOIN acad_course c ON pc.course_code = c.courseID
            LEFT JOIN acad_specialisation sp ON pc.specialisation_id = sp.spec_id
            WHERE 1=1 " + wh.ToString();

        if (hasLecturerCols && hasRequestCols)
            joins = joins.Replace("WHERE 1=1", "LEFT JOIN hrm_employee e ON e.empID = pc.lecturer_id\n            LEFT JOIN hrm_employee er ON er.empID = pc.allocation_request_lecturer_id\n            WHERE 1=1");
        else if (hasLecturerCols)
            joins = joins.Replace("WHERE 1=1", "LEFT JOIN hrm_employee e ON e.empID = pc.lecturer_id\n            WHERE 1=1");

        // Count
        DataTable dtCount = ExecuteQuery("SELECT COUNT(*) AS n" + joins, prms.ToArray());
        int totalRows = dtCount.Rows.Count > 0 ? Convert.ToInt32(dtCount.Rows[0]["n"]) : 0;
        int totalPages = (int)Math.Ceiling((double)totalRows / PageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * PageSize;

        // Data
                string sql = @"
            SELECT pc.ID, pc.progcode, IFNULL(p.progname,'') AS progname,
                   pc.course_code, IFNULL(c.courseName,'') AS courseName,
                   IFNULL(c.CreditUnit,0) AS CreditUnit,
                   IFNULL(pc.study_year,1) AS study_year,
                   IFNULL(pc.semester,1) AS semester,
                   IFNULL(pc.CurriculumID,0) AS CurriculumID,
                   IFNULL(pc.specialisation_id,0) AS specialisation_id,
                   IFNULL(sp.spec,'') AS spec_name,
                                         IFNULL(pc.course_type,'CORE') AS course_type" +
                                         (hasLecturerCols ?
                                         ", IFNULL(pc.is_lecturere_assigned,'No') AS is_lecturere_assigned, pc.lecturer_id, IFNULL(pc.status,'Active') AS assignment_status, IFNULL(e.emp_name,'') AS lecturer_name, IFNULL(e.emp_code,'') AS lecturer_code "
                                         : ", 'No' AS is_lecturere_assigned, NULL AS lecturer_id, 'Active' AS assignment_status, '' AS lecturer_name, '' AS lecturer_code ") +
                                         (hasRequestCols
                                         ? ", IFNULL(pc.allocation_request_status,'No') AS req_status, IFNULL(pc.allocation_request_lecturer_id,0) AS req_lecturer_id, DATE_FORMAT(pc.allocation_request_date,'%Y-%m-%d %H:%i') AS req_date, IFNULL(pc.allocation_request_message,'') AS req_message, IFNULL(pc.allocation_request_admin_status,'Pending') AS req_admin_status, IFNULL(pc.allocation_request_admin_message,'') AS req_admin_message, IFNULL(er.emp_name,'') AS req_lecturer_name, IFNULL(er.emp_code,'') AS req_lecturer_code "
                                         : ", 'No' AS req_status, 0 AS req_lecturer_id, '' AS req_date, '' AS req_message, 'Pending' AS req_admin_status, '' AS req_admin_message, '' AS req_lecturer_name, '' AS req_lecturer_code ") +
                                         joins +
            " ORDER BY p.progname, pc.study_year, pc.semester, c.courseName" +
            " LIMIT " + PageSize + " OFFSET " + offset;

        DataTable dt = ExecuteQuery(sql, prms.ToArray());

        // Build rows
        StringBuilder sb = new StringBuilder();
        StringBuilder sbMobile = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            sb.Append("<tr><td colspan=\"17\" class=\"pc-empty\">No records found. Adjust filters or add course assignments.</td></tr>");
            sbMobile.Append("<div class=\"pc-empty\">No records found. Adjust filters or add course assignments.</div>");
        }
        else
        {
            foreach (DataRow r in dt.Rows)
            {
                string id         = r["ID"].ToString();
                string progcode   = HttpUtility.HtmlEncode(r["progcode"].ToString());
                string progname   = HttpUtility.HtmlEncode(r["progname"].ToString());
                string specName   = HttpUtility.HtmlEncode(r["spec_name"].ToString());
                string courseCode = HttpUtility.HtmlEncode(r["course_code"].ToString());
                string courseName = HttpUtility.HtmlEncode(r["courseName"].ToString());
                string cu         = r["CreditUnit"].ToString();
                string yr2        = r["study_year"].ToString();
                string sem2       = r["semester"].ToString();
                string ctRaw      = r["course_type"].ToString().ToUpper();
                string ctDisp     = (ctRaw == "ELECTIVE") ? "Elective" : "Core";
                string ctCls      = (ctRaw == "ELECTIVE") ? "pc-pill--elective" : "pc-pill--core";
                string assignedRaw = r["is_lecturere_assigned"].ToString();
                bool isAssigned = string.Equals(assignedRaw, "Yes", StringComparison.OrdinalIgnoreCase);
                string assignedDisp = isAssigned ? "Yes" : "No";
                string assignedCls = isAssigned ? "pc-pill--core" : "pc-pill--elective";
                string lecturerName = HttpUtility.HtmlEncode(r["lecturer_name"].ToString());
                string lecturerCode = HttpUtility.HtmlEncode(r["lecturer_code"].ToString());
                string lecturerDisp = isAssigned && !string.IsNullOrEmpty(lecturerName)
                    ? (lecturerName + (string.IsNullOrEmpty(lecturerCode) ? "" : " (" + lecturerCode + ")"))
                    : "-";
                string statusRaw = r["assignment_status"].ToString();
                bool isInactive = string.Equals(statusRaw, "Inactive", StringComparison.OrdinalIgnoreCase);
                string statusDisp = isInactive ? "Inactive" : "Active";
                string statusCls = isInactive ? "pc-pill--elective" : "pc-pill--core";
                string reqStatusRaw = r["req_status"].ToString();
                string reqStatus = HttpUtility.HtmlEncode(reqStatusRaw);
                string reqAdminStatusRaw = r["req_admin_status"].ToString();
                string reqAdminStatus = HttpUtility.HtmlEncode(reqAdminStatusRaw);
                string reqDate = HttpUtility.HtmlEncode(r["req_date"].ToString());
                string reqLectName = HttpUtility.HtmlEncode(r["req_lecturer_name"].ToString());
                string reqLectCode = HttpUtility.HtmlEncode(r["req_lecturer_code"].ToString());
                string reqLectDisp = string.IsNullOrEmpty(reqLectName) ? "-"
                    : (reqLectName + (string.IsNullOrEmpty(reqLectCode) ? "" : " (" + reqLectCode + ")"));
                bool canReview = hasRequestCols && !string.IsNullOrEmpty(r["req_lecturer_id"].ToString())
                                 && r["req_lecturer_id"].ToString() != "0"
                                 && string.Equals(reqAdminStatusRaw, "Pending", StringComparison.OrdinalIgnoreCase);
                string searchVal  = HttpUtility.HtmlEncode(
                    (progcode + " " + progname + " " + courseCode + " " + courseName + " " + specName + " " + lecturerDisp + " " + statusDisp + " " + assignedDisp + " " + reqAdminStatus + " " + reqLectDisp).ToLower());
                string jsCode = HttpUtility.JavaScriptStringEncode(r["course_code"].ToString());
                bool isFocused = qFocusId > 0 && string.Equals(id, qFocusId.ToString(), StringComparison.Ordinal);
                string rowStyle = isFocused ? " style=\"outline:2px solid #174DA4;outline-offset:-2px;background:#f0f6ff;\"" : "";

                string adminReqCls = string.Equals(reqAdminStatusRaw, "Approved", StringComparison.OrdinalIgnoreCase)
                    ? "pc-pill--core"
                    : string.Equals(reqAdminStatusRaw, "Rejected", StringComparison.OrdinalIgnoreCase)
                        ? "pc-pill--elective"
                        : "pc-pill--elective";

                string reqStatusDisp;
                string reqStatusCls;
                bool hasReq = string.Equals(reqStatusRaw, "Yes", StringComparison.OrdinalIgnoreCase);
                if (!hasReq)
                {
                    reqStatusDisp = "No Request";
                    reqStatusCls = "pc-pill--muted";
                }
                else if (string.Equals(reqAdminStatusRaw, "Approved", StringComparison.OrdinalIgnoreCase))
                {
                    reqStatusDisp = "Approved";
                    reqStatusCls = "pc-pill--ok";
                }
                else if (string.Equals(reqAdminStatusRaw, "Rejected", StringComparison.OrdinalIgnoreCase))
                {
                    reqStatusDisp = "Rejected";
                    reqStatusCls = "pc-pill--bad";
                }
                else
                {
                    reqStatusDisp = "Pending";
                    reqStatusCls = "pc-pill--warn";
                }

                sb.Append("<tr data-search=\"" + searchVal + "\"" + rowStyle + ">");
                sb.Append("<td data-label=\"Code\"><span class=\"pc-code\">" + progcode + "</span></td>");
                sb.Append("<td data-label=\"Prog\" class=\"pc-col-prog\" title=\"" + HttpUtility.HtmlAttributeEncode(r["progname"].ToString()) + "\">" + progname + "</td>");
                sb.Append("<td data-label=\"Spec\" class=\"pc-muted pc-col-spec\">" + specName + "</td>");
                sb.Append("<td data-label=\"Course\"><span class=\"pc-code\">" + courseCode + "</span></td>");
                sb.Append("<td data-label=\"Name\" class=\"pc-col-name\">" + courseName + "</td>");
                sb.Append("<td data-label=\"CU\" class=\"pc-center\">" + cu + "</td>");
                sb.Append("<td data-label=\"Yr\" class=\"pc-center\">" + yr2 + "</td>");
                sb.Append("<td data-label=\"Sem\" class=\"pc-center\">" + sem2 + "</td>");
                sb.Append("<td data-label=\"Type\" class=\"pc-center\"><span class=\"pc-pill " + ctCls + "\">" + ctDisp + "</span></td>");
                sb.Append("<td data-label=\"Assigned\" class=\"pc-center\"><span class=\"pc-pill " + assignedCls + "\">" + assignedDisp + "</span></td>");
                sb.Append("<td data-label=\"Lecturer\" class=\"pc-col-lect\">" + lecturerDisp + "</td>");
                sb.Append("<td data-label=\"Status\" class=\"pc-center\"><span class=\"pc-pill " + statusCls + "\">" + statusDisp + "</span></td>");
                sb.Append("<td data-label=\"Req Status\" class=\"pc-center\"><span class=\"pc-pill " + reqStatusCls + "\">" + reqStatusDisp + "</span></td>");
                sb.Append("<td data-label=\"Req Date\" class=\"pc-center\">" + (string.IsNullOrEmpty(reqDate) ? "-" : reqDate) + "</td>");
                sb.Append("<td data-label=\"Actions\"><div class=\"pc-actions\">");
                sb.Append("<button type=\"button\" class=\"pc-action-btn\" onclick=\"editRow('" + id + "')\" title=\"Edit\">");
                sb.Append("<svg viewBox=\"0 0 24 24\"><path d=\"M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7\"/><path d=\"M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z\"/></svg>");
                sb.Append("</button>");
                sb.Append("<button type=\"button\" class=\"pc-action-btn danger\" onclick=\"deleteRow('" + id + "','" + jsCode + "')\" title=\"Delete\">");
                sb.Append("<svg viewBox=\"0 0 24 24\"><polyline points=\"3 6 5 6 21 6\"/><path d=\"M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6\"/><path d=\"M10 11v6\"/><path d=\"M14 11v6\"/><path d=\"M9 6V4h6v2\"/></svg>");
                sb.Append("</button>");
                if (canReview)
                {
                    string reqMsgJs = HttpUtility.JavaScriptStringEncode(r["req_message"].ToString());
                    string adminMsgJs = HttpUtility.JavaScriptStringEncode(r["req_admin_message"].ToString());
                    string reqLectJs = HttpUtility.JavaScriptStringEncode(reqLectDisp);
                    string ctxJs = HttpUtility.JavaScriptStringEncode(courseCode + " - " + courseName + " (" + progname + ")");
                    sb.Append("<button type=\"button\" class=\"pc-action-btn\" title=\"Review request\" onclick=\"openRequestDecisionModal('" + id + "','" + ctxJs + "','" + reqLectJs + "','" + reqMsgJs + "','" + adminMsgJs + "')\">");
                    sb.Append("<svg viewBox=\"0 0 24 24\"><path d=\"M3 12h18\"/><path d=\"M12 3v18\"/></svg>");
                    sb.Append("</button>");
                }
                sb.Append("</div></td>");
                sb.Append("</tr>");

                string compactLecturer = lecturerDisp == "-" ? "Unassigned" : lecturerDisp;
                sbMobile.Append("<div class=\"pc-mcard\" data-id=\"" + id + "\"" + rowStyle + ">");
                sbMobile.Append("<div class=\"pc-mcard__head\"><label class=\"pc-check\" title=\"Select this row\"><input type=\"checkbox\" class=\"pc-rowchk\" data-id=\"" + id + "\" data-code=\"" + jsCode + "\" onchange=\"pcToggleRow(this)\"></label><div style=\"flex:1;min-width:0;\"><div class=\"pc-mcard__title\"><span class=\"pc-code\">" + courseCode + "</span> - " + courseName + "</div><div class=\"pc-mcard__sub\">" + progname + "</div></div><span class=\"pc-pill " + reqStatusCls + "\">" + reqStatusDisp + "</span></div>");
                sbMobile.Append("<div class=\"pc-mcard__meta\">");
                sbMobile.Append("<div class=\"pc-mline\"><span class=\"pc-mline__k\">Programme:</span><span class=\"pc-mline__v\"><span class=\"pc-code\">" + progcode + "</span> • " + (string.IsNullOrEmpty(specName) ? "Default" : specName) + "</span></div>");
                sbMobile.Append("<div class=\"pc-mline\"><span class=\"pc-mline__k\">Study Slot:</span><span class=\"pc-mline__v\">Year " + yr2 + " / Semester " + sem2 + "</span></div>");
                sbMobile.Append("<div class=\"pc-mline\"><span class=\"pc-mline__k\">Lecturer:</span><span class=\"pc-mline__v\">" + compactLecturer + "</span></div>");
                sbMobile.Append("<div class=\"pc-mline\"><span class=\"pc-mline__k\">Status:</span><span class=\"pc-mline__v\"><span class=\"pc-pill " + statusCls + "\">" + statusDisp + "</span>" + (string.IsNullOrEmpty(reqDate) ? "" : " <span class=\"pc-muted\">• " + reqDate + "</span>") + "</span></div>");
                sbMobile.Append("</div>");
                sbMobile.Append("<div class=\"pc-mcard__actions\">");
                sbMobile.Append("<button type=\"button\" class=\"pc-btn pc-btn--sm\" onclick=\"editRow('" + id + "')\">Edit</button>");
                sbMobile.Append("<button type=\"button\" class=\"pc-btn pc-btn--sm pc-btn--danger\" onclick=\"deleteRow('" + id + "','" + jsCode + "')\">Delete</button>");
                if (canReview)
                {
                    string reqMsgJs = HttpUtility.JavaScriptStringEncode(r["req_message"].ToString());
                    string adminMsgJs = HttpUtility.JavaScriptStringEncode(r["req_admin_message"].ToString());
                    string reqLectJs = HttpUtility.JavaScriptStringEncode(reqLectDisp);
                    string ctxJs = HttpUtility.JavaScriptStringEncode(courseCode + " - " + courseName + " (" + progname + ")");
                    sbMobile.Append("<button type=\"button\" class=\"pc-btn pc-btn--sm\" onclick=\"openRequestDecisionModal('" + id + "','" + ctxJs + "','" + reqLectJs + "','" + reqMsgJs + "','" + adminMsgJs + "')\">Review Request</button>");
                }
                sbMobile.Append("</div></div>");
            }
        }
        litRows.Text = sb.ToString();
        litRowsMobile.Text = sbMobile.ToString();

        int from = offset + 1;
        int to   = Math.Min(offset + dt.Rows.Count, totalRows);
        litPageInfo.Text  = string.Format("{0}&ndash;{1} of {2}", from, to, totalRows);
        litMetaTotal.Text = totalRows.ToString();

        // Pager
        string qs = BuildQs(qYear, qSem, qAssigned, qLecturer, qType, qReq, qSearch);
        StringBuilder pg = new StringBuilder();
        if (page > 1)
            pg.AppendFormat("<a href=\"?page={0}{1}\">&laquo;</a>", page - 1, qs);
        int start = Math.Max(1, page - 3), end = Math.Min(totalPages, page + 3);
        for (int i = start; i <= end; i++)
        {
            if (i == page)
                pg.AppendFormat("<span class=\"active\">{0}</span>", i);
            else
                pg.AppendFormat("<a href=\"?page={0}{1}\">{0}</a>", i, qs);
        }
        if (page < totalPages)
            pg.AppendFormat("<a href=\"?page={0}{1}\">&raquo;</a>", page + 1, qs);
        litPager.Text = pg.ToString();
    }

    private string BuildQs(string yr, string sem, string asg, string lec, string tp, string rq, string q)
    {
        StringBuilder sb = new StringBuilder();
        if (!string.IsNullOrEmpty(yr))  sb.Append("&yr="  + HttpUtility.UrlEncode(yr));
        if (!string.IsNullOrEmpty(sem)) sb.Append("&sem=" + HttpUtility.UrlEncode(sem));
        if (!string.IsNullOrEmpty(asg)) sb.Append("&asg=" + HttpUtility.UrlEncode(asg));
        if (!string.IsNullOrEmpty(lec)) sb.Append("&lec=" + HttpUtility.UrlEncode(lec));
        if (!string.IsNullOrEmpty(tp))  sb.Append("&tp="  + HttpUtility.UrlEncode(tp));
        if (!string.IsNullOrEmpty(rq))  sb.Append("&rq="  + HttpUtility.UrlEncode(rq));
        if (!string.IsNullOrEmpty(q))   sb.Append("&q="   + HttpUtility.UrlEncode(q));
        return sb.ToString();
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static Dictionary<string, object> GetLecturerFilterOptions()
    {
        Dictionary<string, object> resp = new Dictionary<string, object>();
        resp["Success"] = false;
        resp["Message"] = "";
        resp["Items"] = new List<object>();

        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();

                DataTable dt = new DataTable();
                using (MySqlCommand cmd = new MySqlCommand(@"
                    SELECT e.empID,
                           CONCAT(IFNULL(e.emp_name,''),
                                  CASE WHEN IFNULL(e.emp_code,'')='' THEN '' ELSE CONCAT(' (', e.emp_code, ')') END) AS lecturer_name
                    FROM hrm_employee e
                    WHERE IFNULL(TRIM(e.emp_name),'') <> ''
                    ORDER BY e.emp_name", conn))
                {
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) da.Fill(dt);
                }

                List<object> items = new List<object>();
                foreach (DataRow r in dt.Rows)
                {
                    Dictionary<string, object> item = new Dictionary<string, object>();
                    item["id"] = r["empID"].ToString();
                    item["name"] = r["lecturer_name"].ToString();
                    items.Add(item);
                }

                resp["Success"] = true;
                resp["Items"] = items;
                resp["Message"] = items.Count + " lecturer option(s) loaded.";
                return resp;
            }
        }
        catch (Exception ex)
        {
            resp["Message"] = "Failed to load lecturers: " + ex.Message;
            return resp;
        }
    }

    // ---------------------------------------------------------------
    // JSON builders for client-side cascade & course search
    // ---------------------------------------------------------------
    protected string BuildSpecsJson()
    {
        DataTable dt = ExecuteQuery(
            "SELECT spec_id, prog_id, spec FROM acad_specialisation WHERE spec != '-' ORDER BY spec");
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.AppendFormat("{{id:'{0}',p:'{1}',n:'{2}'}}",
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["spec_id"].ToString()),
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["prog_id"].ToString()),
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["spec"].ToString()));
        }
        sb.Append("]");
        return sb.ToString();
    }

    protected string BuildCoursesJson()
    {
        DataTable dt = ExecuteQuery("SELECT courseID, courseName FROM acad_course ORDER BY courseName");
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.AppendFormat("{{c:'{0}',n:'{1}'}}",
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["courseID"].ToString()),
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["courseName"].ToString()));
        }
        sb.Append("]");
        return sb.ToString();
    }

    protected string BuildProgrammesJson()
    {
        DataTable dt = ExecuteQuery("SELECT progcode, progname FROM acad_programme ORDER BY progname");
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.AppendFormat("{{v:'{0}',t:'{1}'}}",
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["progcode"].ToString()),
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["progname"].ToString()));
        }
        sb.Append("]");
        return sb.ToString();
    }

    protected string BuildLecturersJson()
    {
        DataTable dt = ExecuteQuery(@"
            SELECT e.empID,
                   CONCAT(IFNULL(e.emp_name,''),
                          CASE WHEN IFNULL(e.emp_code,'')='' THEN '' ELSE CONCAT(' (', e.emp_code, ')') END) AS lecturer_name
            FROM hrm_employee e
            WHERE IFNULL(TRIM(e.emp_name),'') <> ''
            ORDER BY e.emp_name");
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.AppendFormat("{{id:'{0}',n:'{1}'}}",
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["empID"].ToString()),
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["lecturer_name"].ToString()));
        }
        sb.Append("]");
        return sb.ToString();
    }

    // ---------------------------------------------------------------
    // Save (Insert or Update)
    // ---------------------------------------------------------------
    /// <summary>
    /// Ensures the unique key on acad_programmecourses reflects the screen's real
    /// natural key (course_code, progcode, CurriculumID, specialisation_id,
    /// study_year, semester). An older deployment created a unique index that omitted
    /// study_year and semester, which wrongly rejected the same course in a different
    /// year/semester as a "Duplicate entry". This self-heals at save time and is a
    /// no-op once the index is already correct. Safe: the new index is a superset of
    /// the old columns, so it never conflicts with existing rows.
    /// </summary>
    private void EnsureProgrammeCourseUniqueIndex()
    {
        try
        {
            DataTable dt = ExecuteQuery(@"
                SELECT index_name,
                       GROUP_CONCAT(LOWER(column_name) ORDER BY seq_in_index SEPARATOR ',') AS cols
                FROM information_schema.statistics
                WHERE table_schema = DATABASE()
                  AND table_name = 'acad_programmecourses'
                  AND non_unique = 0
                  AND index_name <> 'PRIMARY'
                GROUP BY index_name");

            string targetIndex = null;
            string targetCols = null;
            foreach (DataRow r in dt.Rows)
            {
                string cols = r["cols"] != DBNull.Value ? r["cols"].ToString() : "";
                if (cols.Contains("course_code") && cols.Contains("progcode"))
                {
                    targetIndex = r["index_name"].ToString();
                    targetCols = cols;
                    break;
                }
            }

            // No course/programme unique index found, or it already covers
            // study_year + semester → nothing to do.
            if (string.IsNullOrEmpty(targetIndex)) return;
            if (targetCols.Contains("study_year") && targetCols.Contains("semester")) return;

            ExecuteNonQuery("ALTER TABLE acad_programmecourses DROP INDEX `" + targetIndex.Replace("`", "``") + "`");
            ExecuteNonQuery(@"ALTER TABLE acad_programmecourses
                ADD UNIQUE INDEX `FK_acad_programmecourses_2`
                (course_code, progcode, CurriculumID, specialisation_id, study_year, semester)");
        }
        catch
        {
            // Non-fatal: if ALTER privileges are unavailable, the pre-save duplicate
            // check and the duplicate-key handler still keep saving safe.
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!HasLecturerAssignmentColumns())
        {
            ShowModalError("Database migration is required before saving. Run NewScreens/migration_programme_course_lecturer_assignment.sql then retry.");
            return;
        }

        // Prepare the schema: make sure the uniqueness rule matches how the screen
        // actually identifies a course assignment (programme + course + specialisation
        // + study year + semester). A legacy index that ignored year/semester blocked
        // the same course from being offered in different year/semester slots.
        EnsureProgrammeCourseUniqueIndex();

        string mode       = hdnModalMode.Value.Trim().ToUpper();
        string progcode   = Request.Form[ddlProgramme.UniqueID] ?? "";
        string specIdStr  = Request.Form[ddlSpecialisation.UniqueID] ?? "0";
        string courseCode = hdnSelectedCourse.Value.Trim();
        string yearStr    = Request.Form[ddlYear.UniqueID] ?? "1";
        string semStr     = Request.Form[ddlSemester.UniqueID] ?? "1";
        string courseType = Request.Form[ddlCourseType.UniqueID] ?? "CORE";
        string assignedStr = NormalizeYesNo(Request.Form[ddlIsLecturerAssigned.UniqueID] ?? "No");
        string lecturerIdStr = (Request.Form[ddlLecturer.UniqueID] ?? "").Trim();
        string assignmentStatus = NormalizeStatus(Request.Form[ddlAssignmentStatus.UniqueID] ?? "Active");

        if (string.IsNullOrEmpty(progcode))
        { ShowModalError("Please select a Programme."); return; }
        if (string.IsNullOrEmpty(specIdStr) || specIdStr == "0" || specIdStr == "")
        {
            specIdStr = ddlSpecialisation.SelectedValue;
            if (string.IsNullOrEmpty(specIdStr) || specIdStr == "")
            { ShowModalError("Please select a Specialisation."); return; }
        }
        if (string.IsNullOrEmpty(courseCode))
        { ShowModalError("Please search and select a Course."); return; }

        int specId = 0; int.TryParse(specIdStr, out specId);
        int year = 1; int.TryParse(yearStr, out year);
        int sem = 1; int.TryParse(semStr, out sem);
        int lecturerId = 0;
        int.TryParse(lecturerIdStr, out lecturerId);

        if (lecturerId > 0)
            assignedStr = "Yes";

        if (assignedStr == "Yes" && lecturerId <= 0)
        { ShowModalError("Please select a Lecturer when assignment is Yes."); return; }
        if (assignedStr == "No") lecturerId = 0;
        if (lecturerId > 0 && !LecturerExists(lecturerId))
        { ShowModalError("Selected lecturer does not exist."); return; }

        DataTable dtC = ExecuteQuery("SELECT COUNT(*) AS cnt FROM acad_course WHERE courseID=@c",
            new MySqlParameter("@c", courseCode));
        bool courseExistsInMaster = dtC.Rows.Count > 0 && Convert.ToInt32(dtC.Rows[0]["cnt"]) > 0;
        if (!courseExistsInMaster)
        {
            bool isEdit = mode == "EDIT";
            if (!isEdit)
            {
                ShowModalError("Course '" + courseCode + "' does not exist.");
                return;
            }
        }

        try
        {
            if (mode == "EDIT")
            {
                int editId = 0;
                int.TryParse(hdnEditId.Value.Trim(), out editId);
                if (editId <= 0) { ShowModalError("Invalid record ID."); return; }

                DataTable dtExisting = ExecuteQuery(
                    "SELECT course_code FROM acad_programmecourses WHERE ID=@id",
                    new MySqlParameter("@id", editId));
                if (dtExisting.Rows.Count == 0)
                {
                    ShowModalError("Record not found.");
                    return;
                }
                string existingCourseCode = dtExisting.Rows[0]["course_code"] != DBNull.Value
                    ? dtExisting.Rows[0]["course_code"].ToString().Trim()
                    : "";
                if (!string.IsNullOrEmpty(existingCourseCode))
                    courseCode = existingCourseCode;

                DataTable dtDup = ExecuteQuery(
                    @"SELECT COUNT(*) AS cnt FROM acad_programmecourses
                      WHERE progcode=@p AND course_code=@c AND specialisation_id=@sp
                        AND study_year=@y AND semester=@s AND ID!=@id",
                    new MySqlParameter("@p", progcode), new MySqlParameter("@c", courseCode),
                    new MySqlParameter("@sp", specId),  new MySqlParameter("@y", year),
                    new MySqlParameter("@s", sem),      new MySqlParameter("@id", editId));
                if (dtDup.Rows.Count > 0 && Convert.ToInt32(dtDup.Rows[0]["cnt"]) > 0)
                { ShowModalError("This exact course assignment already exists."); return; }

                // Prevent SUBJECT-level duplication: a different course code carrying the
                // same subject must not also be offered in this programme/year/semester.
                string dupSubjEdit = FindDuplicateSubjectCode(progcode, courseCode, year, sem, editId);
                if (dupSubjEdit != null)
                {
                    string[] p = dupSubjEdit.Split(new string[] { "~|~" }, StringSplitOptions.None);
                    ShowModalError("This programme already offers this subject in Year " + year + " Semester " + sem +
                        " as course " + p[0] + " (" + p[1] + "). A subject may appear only once per programme, year and semester — reuse that course, or archive it first.");
                    return;
                }

                ExecuteNonQuery(
                    @"UPDATE acad_programmecourses SET
                        progcode=@p, specialisation_id=@sp,
                                                study_year=@y, semester=@s, course_type=@t,
                                                is_lecturere_assigned=@assigned, lecturer_id=@lecturerId, status=@assignmentStatus
                      WHERE ID=@id",
                    new MySqlParameter("@p", progcode),
                    new MySqlParameter("@sp", specId),  new MySqlParameter("@y", year),
                    new MySqlParameter("@s", sem),      new MySqlParameter("@t", courseType),
                                        new MySqlParameter("@assigned", assignedStr),
                                        new MySqlParameter("@lecturerId", lecturerId > 0 ? (object)lecturerId : DBNull.Value),
                                        new MySqlParameter("@assignmentStatus", assignmentStatus),
                    new MySqlParameter("@id", editId));

                LoadStats(); BindGrid();
                hdnSelectedCourse.Value = "";
                ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                    "closeModal();showToast('Course assignment updated.','success');setTimeout(function(){var u=new URL(window.location.href);u.searchParams.set('focusId','" + editId + "');window.location.href=u.pathname+'?'+u.searchParams.toString();},120);", true);
            }
            else
            {
                DataTable dtDup = ExecuteQuery(
                    @"SELECT COUNT(*) AS cnt FROM acad_programmecourses
                      WHERE progcode=@p AND course_code=@c AND specialisation_id=@sp
                        AND study_year=@y AND semester=@s",
                    new MySqlParameter("@p", progcode), new MySqlParameter("@c", courseCode),
                    new MySqlParameter("@sp", specId),  new MySqlParameter("@y", year),
                    new MySqlParameter("@s", sem));
                if (dtDup.Rows.Count > 0 && Convert.ToInt32(dtDup.Rows[0]["cnt"]) > 0)
                { ShowModalError("This course is already assigned to this programme/specialisation/year/semester."); return; }

                // Prevent SUBJECT-level duplication: a different course code carrying the
                // same subject must not also be offered in this programme/year/semester.
                string dupSubj = FindDuplicateSubjectCode(progcode, courseCode, year, sem, 0);
                if (dupSubj != null)
                {
                    string[] p = dupSubj.Split(new string[] { "~|~" }, StringSplitOptions.None);
                    ShowModalError("This programme already offers this subject in Year " + year + " Semester " + sem +
                        " as course " + p[0] + " (" + p[1] + "). A subject may appear only once per programme, year and semester — reuse that course, or archive it first.");
                    return;
                }

                ExecuteNonQuery(
                    @"INSERT INTO acad_programmecourses
                                                (progcode, course_code, study_year, semester, CurriculumID, specialisation_id, course_type,
                                                 is_lecturere_assigned, lecturer_id, status)
                                            VALUES (@p, @c, @y, @s, 0, @sp, @t, @assigned, @lecturerId, @assignmentStatus)",
                    new MySqlParameter("@p", progcode), new MySqlParameter("@c", courseCode),
                    new MySqlParameter("@y", year),     new MySqlParameter("@s", sem),
                                        new MySqlParameter("@sp", specId),  new MySqlParameter("@t", courseType),
                                        new MySqlParameter("@assigned", assignedStr),
                                        new MySqlParameter("@lecturerId", lecturerId > 0 ? (object)lecturerId : DBNull.Value),
                                        new MySqlParameter("@assignmentStatus", assignmentStatus));

                LoadStats(); BindGrid();
                hdnSelectedCourse.Value = "";
                ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                    "closeModal();showToast('Course added successfully.','success');", true);
            }
        }
        catch (MySqlException mex)
        {
            // 1062 = duplicate unique key. Translate to the screen's own language
            // rather than leaking a raw "Duplicate entry ... for key" message.
            if (mex.Number == 1062)
                ShowModalError("This course is already assigned to this programme, specialisation, study year and semester.");
            else
                ShowModalError("Error: " + mex.Message);
        }
        catch (Exception ex)
        {
            ShowModalError("Error: " + ex.Message);
        }
    }

    // ---------------------------------------------------------------
    // Duplicate-subject guard (Phase 7 prevention). Returns "code~|~name" of an
    // existing DIFFERENT course carrying the same subject already offered in this
    // programme/year/semester, or null if none. Soft-fails (never blocks a save)
    // and matches on course name only, so it works even where the dedup columns
    // (subject_id/course_state) have not been added yet.
    // ---------------------------------------------------------------
    private string FindDuplicateSubjectCode(string progcode, string courseCode, int year, int sem, int excludeId)
    {
        try
        {
            DataTable dt = ExecuteQuery(
                @"SELECT pc.course_code, IFNULL(c.courseName,'') AS courseName
                  FROM acad_programmecourses pc
                  JOIN acad_course c  ON TRIM(c.courseID)  = TRIM(pc.course_code)
                  JOIN acad_course nc ON TRIM(nc.courseID) = TRIM(@c)
                  WHERE pc.progcode = @p
                    AND pc.study_year = @y AND pc.semester = @s
                    AND TRIM(pc.course_code) <> TRIM(@c)
                    AND (@id = 0 OR pc.ID <> @id)
                    AND TRIM(UPPER(c.courseName)) = TRIM(UPPER(nc.courseName))
                    AND TRIM(IFNULL(c.courseName,'')) <> ''
                  LIMIT 1",
                new MySqlParameter("@p", progcode), new MySqlParameter("@c", courseCode),
                new MySqlParameter("@y", year), new MySqlParameter("@s", sem),
                new MySqlParameter("@id", excludeId));
            if (dt.Rows.Count > 0)
                return dt.Rows[0]["course_code"].ToString().Trim() + "~|~" + dt.Rows[0]["courseName"].ToString().Trim();
        }
        catch { /* soft guard: never block a legitimate save on guard failure */ }
        return null;
    }

    // ---------------------------------------------------------------
    // Load for Edit
    // ---------------------------------------------------------------
    protected void btnLoadEdit_Click(object sender, EventArgs e)
    {
        string idStr = hdnEditId.Value.Trim();
        int id = 0;
        if (!int.TryParse(idStr, out id) || id <= 0) return;

                bool hasLecturerCols = HasLecturerAssignmentColumns();

        DataTable dt = ExecuteQuery(
            @"SELECT pc.ID, pc.progcode, pc.course_code, c.courseName,
                     pc.study_year, pc.semester, pc.specialisation_id,
                                                                                 IFNULL(pc.course_type,'CORE') AS course_type" +
                                                                                 (hasLecturerCols
                                                                                        ? ", IFNULL(pc.is_lecturere_assigned,'No') AS is_lecturere_assigned, IFNULL(pc.lecturer_id,0) AS lecturer_id, IFNULL(pc.status,'Active') AS assignment_status"
                                                                                        : ", 'No' AS is_lecturere_assigned, 0 AS lecturer_id, 'Active' AS assignment_status") +
                                                                                 @"
              FROM acad_programmecourses pc
              LEFT JOIN acad_course c ON pc.course_code = c.courseID
              WHERE pc.ID=@id",
            new MySqlParameter("@id", id));

        if (dt.Rows.Count == 0) return;

        DataRow r = dt.Rows[0];
        string progcode2  = r["progcode"].ToString();
        string courseCode = r["course_code"].ToString();
        string courseName = r["courseName"] != DBNull.Value ? r["courseName"].ToString() : courseCode;
        string specId     = r["specialisation_id"] != DBNull.Value ? r["specialisation_id"].ToString() : "0";
        string studyYear  = r["study_year"].ToString();
        string semester2  = r["semester"].ToString();
        string courseType = r["course_type"].ToString();
        string isAssigned = NormalizeYesNo(r["is_lecturere_assigned"].ToString());
        string lecturerId = r["lecturer_id"].ToString();
        string assignmentStatus = NormalizeStatus(r["assignment_status"].ToString());

        TrySelect(ddlProgramme, progcode2);
        TrySelect(ddlSpecialisation, specId);
        TrySelect(ddlYear, studyYear);
        TrySelect(ddlSemester, semester2);
        TrySelect(ddlCourseType, courseType);
        TrySelect(ddlIsLecturerAssigned, isAssigned);
        TrySelect(ddlLecturer, lecturerId);
        TrySelect(ddlAssignmentStatus, assignmentStatus);
        hdnSelectedCourse.Value = courseCode;
        hdnModalMode.Value = "EDIT";

        LoadStats(); BindGrid();

        string js = "openModal('EDIT','" + id + "');" +
            "setTimeout(function(){" +
            "sdSetValue('prog'," + JsEncode(progcode2) + ");" +
            "sdSetData('spec',getSpecsForProg(" + JsEncode(progcode2) + "));" +
            "sdSetValue('spec','" + HttpUtility.JavaScriptStringEncode(specId) + "');" +
            "document.getElementById('" + ddlYear.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(studyYear) + "';" +
            "document.getElementById('uiYear').value='" + HttpUtility.JavaScriptStringEncode(studyYear) + "';" +
            "document.getElementById('" + ddlSemester.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(semester2) + "';" +
            "document.getElementById('uiSemester').value='" + HttpUtility.JavaScriptStringEncode(semester2) + "';" +
            "document.getElementById('" + ddlCourseType.ClientID + "').value=" + JsEncode(courseType) + ";" +
            "document.getElementById('" + ddlIsLecturerAssigned.ClientID + "').value=" + JsEncode(isAssigned) + ";" +
            "document.getElementById('uiIsLecturerAssigned').value=" + JsEncode(isAssigned) + ";" +
            "document.getElementById('" + ddlLecturer.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(lecturerId) + "';" +
            "sdSetValue('lect','" + HttpUtility.JavaScriptStringEncode(lecturerId) + "');" +
            "document.getElementById('" + ddlAssignmentStatus.ClientID + "').value=" + JsEncode(assignmentStatus) + ";" +
            "document.getElementById('uiAssignmentStatus').value=" + JsEncode(assignmentStatus) + ";" +
            "onAssignedFlagChange(" + JsEncode(isAssigned) + ");" +
            "selectCourse(" + JsEncode(courseCode) + "," + JsEncode(courseName) + ");" +
            "},50);";

        ScriptManager.RegisterStartupScript(this, GetType(), "loadEdit", js, true);
    }

    // ---------------------------------------------------------------
    // Delete
    // ---------------------------------------------------------------
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        string idStr = hdnEditId.Value.Trim();
        int id = 0;
        if (!int.TryParse(idStr, out id) || id <= 0) return;

        try
        {
            ExecuteNonQuery("DELETE FROM acad_programmecourses WHERE ID=@id",
                new MySqlParameter("@id", id));
            LoadStats(); BindGrid();
            ScriptManager.RegisterStartupScript(this, GetType(), "deleted",
                "showToast('Course removed from programme.','danger');", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "delerr",
                "showToast('Delete failed: " + HttpUtility.JavaScriptStringEncode(ex.Message) + "','danger');", true);
        }
    }

    // ---------------------------------------------------------------
    // Modal Error (keeps modal open)
    // ---------------------------------------------------------------
    private void ShowModalError(string msg)
    {
        LoadStats(); BindGrid();

        string progcode   = Request.Form[ddlProgramme.UniqueID] ?? "";
        string specId2    = Request.Form[ddlSpecialisation.UniqueID] ?? "";
        string yearVal    = Request.Form[ddlYear.UniqueID] ?? "1";
        string semVal     = Request.Form[ddlSemester.UniqueID] ?? "1";
        string typeVal    = Request.Form[ddlCourseType.UniqueID] ?? "CORE";
        string assignedVal = NormalizeYesNo(Request.Form[ddlIsLecturerAssigned.UniqueID] ?? "No");
        string lecturerVal = Request.Form[ddlLecturer.UniqueID] ?? "";
        string assignmentStatusVal = NormalizeStatus(Request.Form[ddlAssignmentStatus.UniqueID] ?? "Active");
        string courseCode = hdnSelectedCourse.Value.Trim();
        string mode       = hdnModalMode.Value.Trim().ToUpper();

        string courseName = courseCode;
        if (!string.IsNullOrEmpty(courseCode))
        {
            DataTable dtN = ExecuteQuery("SELECT courseName FROM acad_course WHERE courseID=@c",
                new MySqlParameter("@c", courseCode));
            if (dtN.Rows.Count > 0) courseName = dtN.Rows[0]["courseName"].ToString();
        }

        StringBuilder js = new StringBuilder();
        js.Append("openModal('" + (mode == "EDIT" ? "EDIT" : "NEW") + "','" + HttpUtility.JavaScriptStringEncode(hdnEditId.Value) + "');");
        js.Append("setTimeout(function(){");
        js.Append("sdSetValue('prog'," + JsEncode(progcode) + ");");
        js.Append("sdSetData('spec',getSpecsForProg(" + JsEncode(progcode) + "));");
        js.Append("sdSetValue('spec','" + HttpUtility.JavaScriptStringEncode(specId2) + "');");
        js.Append("document.getElementById('" + ddlYear.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(yearVal) + "';");
        js.Append("document.getElementById('" + ddlSemester.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(semVal) + "';");
        js.Append("document.getElementById('" + ddlCourseType.ClientID + "').value=" + JsEncode(typeVal) + ";");
        js.Append("document.getElementById('" + ddlIsLecturerAssigned.ClientID + "').value=" + JsEncode(assignedVal) + ";");
        js.Append("document.getElementById('uiIsLecturerAssigned').value=" + JsEncode(assignedVal) + ";");
        js.Append("document.getElementById('" + ddlLecturer.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(lecturerVal) + "';");
        js.Append("sdSetValue('lect','" + HttpUtility.JavaScriptStringEncode(lecturerVal) + "');");
        js.Append("document.getElementById('" + ddlAssignmentStatus.ClientID + "').value=" + JsEncode(assignmentStatusVal) + ";");
        js.Append("document.getElementById('uiAssignmentStatus').value=" + JsEncode(assignmentStatusVal) + ";");
        js.Append("onAssignedFlagChange(" + JsEncode(assignedVal) + ");");
        if (!string.IsNullOrEmpty(courseCode))
            js.Append("selectCourse(" + JsEncode(courseCode) + "," + JsEncode(courseName) + ");");
        js.Append("var r=document.getElementById('modalResult');r.className='pc-alert pc-alert--error show';");
        js.Append("r.textContent='" + HttpUtility.JavaScriptStringEncode(msg) + "';");
        js.Append("},50);");

        ScriptManager.RegisterStartupScript(this, GetType(), "modalErr", js.ToString(), true);
    }

    public class BatchAssignRequest
    {
        public List<int> courseIds { get; set; }
        public int? lecturerId { get; set; }
        public string isAssigned { get; set; }
        public string status { get; set; }
    }

    public class BatchAssignResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public int UpdatedCount { get; set; }
    }

    public class ImportDiscoveryCandidate
    {
        public int lecturerId { get; set; }
        public string lecturerName { get; set; }
        public string courseId { get; set; }
        public string courseCode { get; set; }
        public string courseName { get; set; }
        public string progcode { get; set; }
        public string progname { get; set; }
        public int specId { get; set; }
        public string specName { get; set; }
        public int study_year { get; set; }
        public int semester { get; set; }
    }

    public class ImportDiscoveryResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<ImportDiscoveryCandidate> Candidates { get; set; }
    }

    public class AllocationDecisionRequest
    {
        public int programmeCourseId { get; set; }
        public string decision { get; set; }
        public string adminMessage { get; set; }
    }

    public class AllocationDecisionResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static AllocationDecisionResponse ProcessAllocationRequestDecision(AllocationDecisionRequest request)
    {
        AllocationDecisionResponse resp = new AllocationDecisionResponse { Success = false, Message = "Invalid request." };
        try
        {
            if (request == null || request.programmeCourseId <= 0)
            {
                resp.Message = "Invalid request payload.";
                return resp;
            }

            string decision = (request.decision ?? "").Trim();
            if (string.IsNullOrEmpty(decision)) decision = "Pending";
            decision = decision.Substring(0, 1).ToUpper() + decision.Substring(1).ToLower();
            if (decision != "Approved" && decision != "Rejected" && decision != "Pending")
            {
                resp.Message = "Decision must be Approved, Rejected or Pending.";
                return resp;
            }

            string adminMessage = (request.adminMessage ?? "").Trim();
            if (adminMessage.Length > 1500) adminMessage = adminMessage.Substring(0, 1500);

            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                using (MySqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        if (!HasAllocationRequestColumnsStatic(conn, tx))
                        {
                            tx.Rollback();
                            resp.Message = "Allocation request columns are missing.";
                            return resp;
                        }

                        int reqLecturerId = 0;
                        using (MySqlCommand cmdGet = new MySqlCommand(@"
                            SELECT IFNULL(allocation_request_lecturer_id,0)
                            FROM acad_programmecourses WHERE ID=@id", conn, tx))
                        {
                            cmdGet.Parameters.AddWithValue("@id", request.programmeCourseId);
                            object v = cmdGet.ExecuteScalar();
                            if (v == null || v == DBNull.Value)
                            {
                                tx.Rollback();
                                resp.Message = "Course assignment context not found.";
                                return resp;
                            }
                            int.TryParse(v.ToString(), out reqLecturerId);
                        }

                        if (reqLecturerId <= 0)
                        {
                            tx.Rollback();
                            resp.Message = "No lecturer request exists for this row.";
                            return resp;
                        }

                        if (decision == "Approved")
                        {
                            using (MySqlCommand cmdUp = new MySqlCommand(@"
                                UPDATE acad_programmecourses
                                SET lecturer_id=@lid,
                                    is_lecturere_assigned='Yes',
                                    status='Active',
                                    allocation_request_status='Yes',
                                    allocation_request_admin_status='Approved',
                                    allocation_request_admin_message=@msg
                                WHERE ID=@id", conn, tx))
                            {
                                cmdUp.Parameters.AddWithValue("@lid", reqLecturerId);
                                cmdUp.Parameters.AddWithValue("@msg", adminMessage);
                                cmdUp.Parameters.AddWithValue("@id", request.programmeCourseId);
                                cmdUp.ExecuteNonQuery();
                            }
                        }
                        else if (decision == "Rejected")
                        {
                            using (MySqlCommand cmdUp = new MySqlCommand(@"
                                UPDATE acad_programmecourses
                                SET allocation_request_status='No',
                                    allocation_request_admin_status='Rejected',
                                    allocation_request_admin_message=@msg
                                WHERE ID=@id", conn, tx))
                            {
                                cmdUp.Parameters.AddWithValue("@msg", adminMessage);
                                cmdUp.Parameters.AddWithValue("@id", request.programmeCourseId);
                                cmdUp.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            using (MySqlCommand cmdUp = new MySqlCommand(@"
                                UPDATE acad_programmecourses
                                SET allocation_request_status='No',
                                    allocation_request_admin_status='Pending',
                                    allocation_request_admin_message=@msg
                                WHERE ID=@id", conn, tx))
                            {
                                cmdUp.Parameters.AddWithValue("@msg", adminMessage);
                                cmdUp.Parameters.AddWithValue("@id", request.programmeCourseId);
                                cmdUp.ExecuteNonQuery();
                            }
                        }

                        tx.Commit();
                        resp.Success = true;
                        resp.Message = "Request updated: " + decision + ".";
                        return resp;
                    }
                    catch (Exception exTx)
                    {
                        try { tx.Rollback(); } catch { }
                        resp.Message = "Failed to update request: " + exTx.Message;
                        return resp;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            resp.Message = "Request decision failed: " + ex.Message;
            return resp;
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static BatchAssignResponse BatchAssignLecturers(BatchAssignRequest request)
    {
        BatchAssignResponse resp = new BatchAssignResponse { Success = false, Message = "Unknown error.", UpdatedCount = 0 };

        try
        {
            if (request == null || request.courseIds == null || request.courseIds.Count == 0)
            {
                resp.Message = "No course IDs were provided.";
                return resp;
            }

            HashSet<int> uniqueIds = new HashSet<int>();
            foreach (int id in request.courseIds)
            {
                if (id > 0) uniqueIds.Add(id);
            }
            if (uniqueIds.Count == 0)
            {
                resp.Message = "No valid course IDs were provided.";
                return resp;
            }
            if (uniqueIds.Count > 5000)
            {
                resp.Message = "Too many rows in one batch. Maximum is 5000 IDs.";
                return resp;
            }

            string assigned = string.Equals(request.isAssigned ?? "", "Yes", StringComparison.OrdinalIgnoreCase) ? "Yes" : "No";
            string status = string.Equals(request.status ?? "", "Inactive", StringComparison.OrdinalIgnoreCase) ? "Inactive" : "Active";
            int lecturerId = request.lecturerId.HasValue ? request.lecturerId.Value : 0;

            if (assigned == "Yes" && lecturerId <= 0)
            {
                resp.Message = "Lecturer is required when assignment is Yes.";
                return resp;
            }
            if (assigned == "No") lecturerId = 0;

            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                using (MySqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        if (!HasLecturerAssignmentColumnsStatic(conn, tx))
                        {
                            tx.Rollback();
                            resp.Message = "Lecturer-assignment columns are missing. Run NewScreens/migration_programme_course_lecturer_assignment.sql first.";
                            return resp;
                        }

                        if (lecturerId > 0)
                        {
                            using (MySqlCommand chkLect = new MySqlCommand("SELECT COUNT(*) FROM hrm_employee WHERE empID=@id", conn, tx))
                            {
                                chkLect.Parameters.AddWithValue("@id", lecturerId);
                                int cnt = Convert.ToInt32(chkLect.ExecuteScalar());
                                if (cnt <= 0)
                                {
                                    tx.Rollback();
                                    resp.Message = "Selected lecturer does not exist.";
                                    return resp;
                                }
                            }
                        }

                        // Validate all IDs exist first (atomicity guarantee)
                        List<int> idList = new List<int>(uniqueIds);
                        int existingCount = 0;
                        const int chunkSize = 500;
                        for (int i = 0; i < idList.Count; i += chunkSize)
                        {
                            int take = Math.Min(chunkSize, idList.Count - i);
                            List<int> chunk = idList.GetRange(i, take);
                            StringBuilder inSb = new StringBuilder();
                            MySqlCommand cmdCount = new MySqlCommand();
                            cmdCount.Connection = conn;
                            cmdCount.Transaction = tx;
                            for (int j = 0; j < chunk.Count; j++)
                            {
                                if (j > 0) inSb.Append(",");
                                string p = "@id" + j;
                                inSb.Append(p);
                                cmdCount.Parameters.AddWithValue(p, chunk[j]);
                            }
                            cmdCount.CommandText = "SELECT COUNT(*) FROM acad_programmecourses WHERE ID IN (" + inSb.ToString() + ")";
                            existingCount += Convert.ToInt32(cmdCount.ExecuteScalar());
                        }

                        if (existingCount != idList.Count)
                        {
                            tx.Rollback();
                            resp.Message = "Some provided IDs do not exist. Batch update was not applied.";
                            return resp;
                        }

                        int totalUpdated = 0;
                        for (int i = 0; i < idList.Count; i += chunkSize)
                        {
                            int take = Math.Min(chunkSize, idList.Count - i);
                            List<int> chunk = idList.GetRange(i, take);
                            StringBuilder inSb = new StringBuilder();
                            MySqlCommand cmdUp = new MySqlCommand();
                            cmdUp.Connection = conn;
                            cmdUp.Transaction = tx;
                            for (int j = 0; j < chunk.Count; j++)
                            {
                                if (j > 0) inSb.Append(",");
                                string p = "@id" + j;
                                inSb.Append(p);
                                cmdUp.Parameters.AddWithValue(p, chunk[j]);
                            }
                            cmdUp.Parameters.AddWithValue("@assigned", assigned);
                            cmdUp.Parameters.AddWithValue("@status", status);
                            if (lecturerId > 0) cmdUp.Parameters.AddWithValue("@lecturerId", lecturerId);
                            else cmdUp.Parameters.AddWithValue("@lecturerId", DBNull.Value);

                            cmdUp.CommandText = @"UPDATE acad_programmecourses
                                                SET is_lecturere_assigned=@assigned,
                                                    lecturer_id=@lecturerId,
                                                    status=@status
                                                WHERE ID IN (" + inSb.ToString() + ")";
                            totalUpdated += cmdUp.ExecuteNonQuery();
                        }

                        tx.Commit();
                        resp.Success = true;
                        resp.Message = "Batch assignment completed.";
                        resp.UpdatedCount = totalUpdated;
                        return resp;
                    }
                    catch (Exception exInner)
                    {
                        try { tx.Rollback(); } catch { }
                        resp.Message = "Batch transaction failed: " + exInner.Message;
                        return resp;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            resp.Message = "Batch request failed: " + ex.Message;
            return resp;
        }
    }

    // ---------------------------------------------------------------
    // Import from Load Allocations - Step 1: Discover Candidates
    // ---------------------------------------------------------------
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static ImportDiscoveryResponse ImportStep_DiscoverCandidates(Dictionary<string, object> request)
    {
        ImportDiscoveryResponse resp = new ImportDiscoveryResponse();
        resp.Success = false;
        resp.Message = "";
        resp.Candidates = new List<ImportDiscoveryCandidate>();

        try
        {
            if (request == null) { resp.Message = "Invalid request."; return resp; }
            
            int studyYear = 0, semester = 0;
            if (request.ContainsKey("year")) int.TryParse(request["year"].ToString(), out studyYear);
            if (request.ContainsKey("semester")) int.TryParse(request["semester"].ToString(), out semester);

            if (studyYear <= 0 || studyYear > 6) { resp.Message = "Invalid year."; return resp; }
            if (semester <= 0 || semester > 3) { resp.Message = "Invalid semester."; return resp; }

            string acadYear = "";
            string campusId = "0";
            if (HttpContext.Current != null && HttpContext.Current.Session != null)
            {
                object sy = HttpContext.Current.Session["SelectedAcademicYear"];
                if (sy != null) acadYear = sy.ToString();

                object sc = HttpContext.Current.Session["SelectedCampus"];
                if (sc != null) campusId = sc.ToString();
            }
            if (string.IsNullOrEmpty(acadYear))
                acadYear = AcademicYearHelper.GetCurrentAcademicYear();

            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

            // Query strategy:
            // 1. Start with load allocations for selected acad_year + semester + study_year(cyear)
            // 2. Match ONLY against existing programme-course rows
            // 3. Return only rows where an existing destination row is still unassigned
            // 4. Never create new destination rows during import
            DataTable dtCandidates = new DataTable();
            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                string sql = @"
                    SELECT 
                        CAST(ta.staffCode AS UNSIGNED) AS lecturerId,
                        e.emp_name AS lecturerName,
                        IFNULL(e.emp_code, '') AS lecturerCode,
                        ta.courseID AS courseCode,
                        IFNULL(c.courseName, ta.courseID) AS courseName,
                        ta.progcode AS progcode,
                        IFNULL(p.progname, ta.progcode) AS progname,
                        pc.specialisation_id AS specId,
                        IFNULL(ps.spec, '-') AS specName,
                        ta.cyear AS study_year,
                        ta.semester AS semester,
                        pc.ID AS pc_id,
                        IFNULL(pc.lecturer_id, 0) AS existing_lecturer_id
                    FROM acad_teaching_allocation ta
                    INNER JOIN hrm_employee e ON CAST(ta.staffCode AS UNSIGNED) = e.empID
                    INNER JOIN acad_programmecourses pc 
                        ON pc.progcode = ta.progcode
                        AND pc.course_code = ta.courseID
                        AND pc.study_year = ta.cyear
                        AND pc.semester = ta.semester
                    LEFT JOIN acad_course c ON c.courseID = ta.courseID
                    LEFT JOIN acad_programme p ON p.progcode = ta.progcode
                    LEFT JOIN acad_specialisation ps ON ps.spec_id = pc.specialisation_id
                    WHERE ta.acad_year = @acadYear 
                      AND ta.cyear = @studyYear
                      AND ta.semester = @sem
                      AND CAST(IFNULL(ta.staffCode,'0') AS UNSIGNED) > 0
                      /**campus_filter**/
                                            AND NOT EXISTS (
                                                    SELECT 1
                                                    FROM acad_programmecourses px
                                                    WHERE px.progcode = ta.progcode
                                                        AND px.course_code = ta.courseID
                                                        AND px.study_year = ta.cyear
                                                        AND px.semester = ta.semester
                                                        AND (IFNULL(px.lecturer_id,0) > 0 OR IFNULL(px.is_lecturere_assigned,'No') = 'Yes')
                                            )
                                                        AND IFNULL(pc.lecturer_id, 0) = 0
                                                        AND IFNULL(pc.is_lecturere_assigned, 'No') = 'No'
                    ORDER BY e.emp_name, ta.courseID";

                if (!string.IsNullOrEmpty(campusId) && campusId != "0")
                    sql = sql.Replace("/**campus_filter**/", " AND ta.campusId = @campus ");
                else
                    sql = sql.Replace("/**campus_filter**/", "");

                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@acadYear", acadYear);
                    cmd.Parameters.AddWithValue("@studyYear", studyYear);
                    cmd.Parameters.AddWithValue("@sem", semester);
                    if (!string.IsNullOrEmpty(campusId) && campusId != "0")
                        cmd.Parameters.AddWithValue("@campus", campusId);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) da.Fill(dtCandidates);
                }

                // Diagnostics: how many source load-allocation rows exist for this filter
                string srcSql = @"
                    SELECT COUNT(*)
                    FROM acad_teaching_allocation ta
                    WHERE ta.acad_year = @acadYear
                      AND ta.cyear = @studyYear
                      AND ta.semester = @sem
                      AND CAST(IFNULL(ta.staffCode,'0') AS UNSIGNED) > 0
                      /**campus_filter**/";
                if (!string.IsNullOrEmpty(campusId) && campusId != "0")
                    srcSql = srcSql.Replace("/**campus_filter**/", " AND ta.campusId = @campus ");
                else
                    srcSql = srcSql.Replace("/**campus_filter**/", "");

                int sourceCount = 0;
                using (MySqlCommand cmdSrc = new MySqlCommand(srcSql, conn))
                {
                    cmdSrc.Parameters.AddWithValue("@acadYear", acadYear);
                    cmdSrc.Parameters.AddWithValue("@studyYear", studyYear);
                    cmdSrc.Parameters.AddWithValue("@sem", semester);
                    if (!string.IsNullOrEmpty(campusId) && campusId != "0")
                        cmdSrc.Parameters.AddWithValue("@campus", campusId);
                    sourceCount = Convert.ToInt32(cmdSrc.ExecuteScalar());
                }

                resp.Message = "Source allocations found: " + sourceCount + " (Academic Year " + acadYear + ", Year " + studyYear + ", Semester " + semester + (campusId != "0" ? ", Campus " + campusId : ", All Campuses") + ").";
            }

            // Deduplicate and build candidate list
            var candidateDict = new Dictionary<string, ImportDiscoveryCandidate>();
            for (int i = 0; i < dtCandidates.Rows.Count; i++)
            {
                DataRow r = dtCandidates.Rows[i];
                int lecturerId = ToIntSafe(r["lecturerId"], 0);
                string courseCode = ToStrSafe(r["courseCode"]);
                int sy = ToIntSafe(r["study_year"], 0);
                int sem = ToIntSafe(r["semester"], 0);
                int specId = ToIntSafe(r["specId"], 0);
                string key = lecturerId + "|" + courseCode + "|" + sy + "|" + sem;

                if (lecturerId > 0 && !string.IsNullOrEmpty(courseCode) && sy > 0 && sem > 0 && !candidateDict.ContainsKey(key))
                {
                    ImportDiscoveryCandidate candidate = new ImportDiscoveryCandidate();
                    candidate.lecturerId = lecturerId;
                    candidate.lecturerName = (r["lecturerName"] != DBNull.Value ? r["lecturerName"].ToString() : "Unknown") +
                                             (r["lecturerCode"] != DBNull.Value && r["lecturerCode"].ToString() != "" ? " (" + r["lecturerCode"].ToString() + ")" : "");
                    candidate.courseId = courseCode;
                    candidate.courseCode = courseCode;
                    candidate.courseName = r["courseName"] != DBNull.Value ? r["courseName"].ToString() : courseCode;
                    candidate.progcode = ToStrSafe(r["progcode"]);
                    candidate.progname = r["progname"] != DBNull.Value ? r["progname"].ToString() : ToStrSafe(r["progcode"]);
                    candidate.specId = specId;
                    candidate.specName = r["specName"] != DBNull.Value ? r["specName"].ToString() : "-";
                    candidate.study_year = sy;
                    candidate.semester = sem;
                    candidateDict[key] = candidate;
                }
            }

            List<ImportDiscoveryCandidate> candidateList = new List<ImportDiscoveryCandidate>();
            foreach (KeyValuePair<string, ImportDiscoveryCandidate> kvp in candidateDict) candidateList.Add(kvp.Value);

            resp.Success = true;
            if (candidateList.Count > 0)
                resp.Message = candidateList.Count + " candidate(s) found.";
            resp.Candidates = candidateList;
            return resp;
        }
        catch (Exception ex)
        {
            resp.Message = "Error during discovery: " + ex.Message;
            return resp;
        }
    }

    // ---------------------------------------------------------------
    // Import from Load Allocations - Step 5: Execute Assignments
    // ---------------------------------------------------------------
    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static Dictionary<string, object> ImportStep_ExecuteAssignments(Dictionary<string, object> request)
    {
        var resp = new Dictionary<string, object> 
        { 
            { "Success", false }, 
            { "Message", "" }, 
            { "SuccessCount", 0 },
            { "SkippedCount", 0 },
            { "ErrorCount", 0 },
            { "Details", "" }
        };

        try
        {
            if (request == null) { resp["Message"] = "Invalid request."; return resp; }
            if (!request.ContainsKey("candidates")) { resp["Message"] = "No candidates provided."; return resp; }

            object candidatesObj = request["candidates"];
            List<object> candidates = new List<object>();

            IList list = candidatesObj as IList;
            if (list != null)
            {
                for (int i = 0; i < list.Count; i++) candidates.Add(list[i]);
            }
            else if (candidatesObj is object[])
            {
                object[] arr = (object[])candidatesObj;
                for (int i = 0; i < arr.Length; i++) candidates.Add(arr[i]);
            }

            if (candidates.Count == 0) { resp["Message"] = "No candidates to process."; return resp; }

            if (candidates.Count > 5000) { resp["Message"] = "Too many candidates (max 5000)."; return resp; }

            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            int successCount = 0, skippedCount = 0, errorCount = 0;
            var detailsList = new List<string>();

            using (MySqlConnection conn = new MySqlConnection(connStr))
            {
                conn.Open();
                MySqlTransaction tx = conn.BeginTransaction();

                try
                {
                    for (int idx = 0; idx < candidates.Count; idx++)
                    {
                        object candObj = candidates[idx];
                        var cand = ToDictionarySafe(candObj);
                        if (cand == null)
                        {
                            errorCount++;
                            detailsList.Add("Candidate " + (idx + 1) + ": Invalid object format");
                            continue;
                        }

                        // Extract candidate fields
                        int lecturerId = ToIntSafe(cand.ContainsKey("lecturerId") ? cand["lecturerId"] : null, 0);
                        string courseCode = ToStrSafe(cand.ContainsKey("courseCode") ? cand["courseCode"] : null).Trim();
                        string progcode = ToStrSafe(cand.ContainsKey("progcode") ? cand["progcode"] : null).Trim();
                        int specId = ToIntSafe(cand.ContainsKey("specId") ? cand["specId"] : null, 0);
                        int year = ToIntSafe(cand.ContainsKey("study_year") ? cand["study_year"] : null, 1);
                        int sem = ToIntSafe(cand.ContainsKey("semester") ? cand["semester"] : null, 1);

                        // Validation
                        if (lecturerId <= 0 || string.IsNullOrEmpty(courseCode) || string.IsNullOrEmpty(progcode))
                        { 
                            errorCount++;
                            detailsList.Add("Candidate " + (idx + 1) + ": Invalid data (missing required fields)");
                            continue;
                        }

                        // Verify lecturer exists
                        using (MySqlCommand cmdCheck = new MySqlCommand("SELECT COUNT(*) FROM hrm_employee WHERE empID=@id", conn, tx))
                        {
                            cmdCheck.Parameters.AddWithValue("@id", lecturerId);
                            int lecturerExists = Convert.ToInt32(cmdCheck.ExecuteScalar());
                            if (lecturerExists == 0)
                            {
                                errorCount++;
                                detailsList.Add("Candidate " + (idx + 1) + ": Lecturer ID " + lecturerId + " not found");
                                continue;
                            }
                        }

                        // Verify course exists
                        using (MySqlCommand cmdCheck = new MySqlCommand("SELECT COUNT(*) FROM acad_course WHERE courseID=@c", conn, tx))
                        {
                            cmdCheck.Parameters.AddWithValue("@c", courseCode);
                            int courseExists = Convert.ToInt32(cmdCheck.ExecuteScalar());
                            if (courseExists == 0)
                            {
                                errorCount++;
                                detailsList.Add("Candidate " + (idx + 1) + ": Course " + courseCode + " not found");
                                continue;
                            }
                        }

                        // Verify programme exists
                        using (MySqlCommand cmdCheck = new MySqlCommand("SELECT COUNT(*) FROM acad_programme WHERE progcode=@p", conn, tx))
                        {
                            cmdCheck.Parameters.AddWithValue("@p", progcode);
                            int progExists = Convert.ToInt32(cmdCheck.ExecuteScalar());
                            if (progExists == 0)
                            {
                                errorCount++;
                                detailsList.Add("Candidate " + (idx + 1) + ": Programme " + progcode + " not found");
                                continue;
                            }
                        }

                        // Normalize existing rows: if lecturer is set, assignment flag must be Yes
                        using (MySqlCommand cmdNormalize = new MySqlCommand(
                            "UPDATE acad_programmecourses SET is_lecturere_assigned='Yes' WHERE progcode=@p AND course_code=@c AND study_year=@y AND semester=@s AND IFNULL(lecturer_id,0) > 0 AND IFNULL(is_lecturere_assigned,'No') <> 'Yes'",
                            conn, tx))
                        {
                            cmdNormalize.Parameters.AddWithValue("@p", progcode);
                            cmdNormalize.Parameters.AddWithValue("@c", courseCode);
                            cmdNormalize.Parameters.AddWithValue("@y", year);
                            cmdNormalize.Parameters.AddWithValue("@s", sem);
                            cmdNormalize.ExecuteNonQuery();
                        }

                        // Check if already assigned (race condition check)
                        using (MySqlCommand cmdCheck = new MySqlCommand(
                            "SELECT COUNT(*) FROM acad_programmecourses WHERE progcode=@p AND course_code=@c AND study_year=@y AND semester=@s AND lecturer_id=@lid AND is_lecturere_assigned='Yes'",
                            conn, tx))
                        {
                            cmdCheck.Parameters.AddWithValue("@p", progcode);
                            cmdCheck.Parameters.AddWithValue("@c", courseCode);
                            cmdCheck.Parameters.AddWithValue("@y", year);
                            cmdCheck.Parameters.AddWithValue("@s", sem);
                            cmdCheck.Parameters.AddWithValue("@lid", lecturerId);
                            int alreadyAssigned = Convert.ToInt32(cmdCheck.ExecuteScalar());
                            if (alreadyAssigned > 0)
                            {
                                skippedCount++;
                                detailsList.Add("Candidate " + (idx + 1) + ": Already assigned (skipped)");
                                continue;
                            }
                        }

                        // Do not touch course contexts that already have any lecturer set
                        using (MySqlCommand cmdAnyAssigned = new MySqlCommand(
                            "SELECT COUNT(*) FROM acad_programmecourses WHERE progcode=@p AND course_code=@c AND study_year=@y AND semester=@s AND (IFNULL(lecturer_id,0) > 0 OR IFNULL(is_lecturere_assigned,'No')='Yes')",
                            conn, tx))
                        {
                            cmdAnyAssigned.Parameters.AddWithValue("@p", progcode);
                            cmdAnyAssigned.Parameters.AddWithValue("@c", courseCode);
                            cmdAnyAssigned.Parameters.AddWithValue("@y", year);
                            cmdAnyAssigned.Parameters.AddWithValue("@s", sem);
                            int anyAssigned = Convert.ToInt32(cmdAnyAssigned.ExecuteScalar());
                            if (anyAssigned > 0)
                            {
                                skippedCount++;
                                detailsList.Add("Candidate " + (idx + 1) + ": Course already has lecturer set (skipped)");
                                continue;
                            }
                        }

                        // Import only into one existing unassigned destination row.
                        // If none exists, or if duplicates exist for same programme/course/year/semester,
                        // skip rather than guessing.
                        int pcId = 0;
                        int pcCount = 0;
                        using (MySqlCommand cmdFind = new MySqlCommand(
                            "SELECT COUNT(*) AS cnt, MIN(ID) AS min_id FROM acad_programmecourses WHERE progcode=@p AND course_code=@c AND study_year=@y AND semester=@s AND IFNULL(lecturer_id,0)=0 AND IFNULL(is_lecturere_assigned,'No')='No'",
                            conn, tx))
                        {
                            cmdFind.Parameters.AddWithValue("@p", progcode);
                            cmdFind.Parameters.AddWithValue("@c", courseCode);
                            cmdFind.Parameters.AddWithValue("@y", year);
                            cmdFind.Parameters.AddWithValue("@s", sem);
                            using (MySqlDataReader rdr = cmdFind.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    pcCount = rdr["cnt"] != DBNull.Value ? Convert.ToInt32(rdr["cnt"]) : 0;
                                    if (pcCount > 0 && rdr["min_id"] != DBNull.Value)
                                        pcId = Convert.ToInt32(rdr["min_id"]);
                                }
                            }
                        }

                        if (pcCount > 1)
                        {
                            skippedCount++;
                            detailsList.Add("Candidate " + (idx + 1) + ": Multiple existing destination rows found for same programme/course/year/semester (skipped)");
                            continue;
                        }

                        if (pcId > 0)
                        {
                            // Update the single existing unassigned record with lecturer
                            using (MySqlCommand cmdUpdate = new MySqlCommand(
                                "UPDATE acad_programmecourses SET is_lecturere_assigned='Yes', lecturer_id=@lid, status='Active' WHERE ID=@id",
                                conn, tx))
                            {
                                cmdUpdate.Parameters.AddWithValue("@lid", lecturerId);
                                cmdUpdate.Parameters.AddWithValue("@id", pcId);
                                int rows = cmdUpdate.ExecuteNonQuery();
                                if (rows > 0)
                                {
                                    successCount++;
                                    detailsList.Add("Candidate " + (idx + 1) + ": Updated existing record (ID " + pcId + ")");
                                }
                                else
                                {
                                    errorCount++;
                                    detailsList.Add("Candidate " + (idx + 1) + ": Update failed");
                                }
                            }
                        }
                        else
                        {
                            skippedCount++;
                            detailsList.Add("Candidate " + (idx + 1) + ": No existing destination programme-course row found (skipped)");
                        }
                    }

                    // Commit transaction
                    tx.Commit();
                    resp["Success"] = true;
                    resp["SuccessCount"] = successCount;
                    resp["SkippedCount"] = skippedCount;
                    resp["ErrorCount"] = errorCount;
                    resp["Message"] = "Import completed: " + successCount + " imported, " + skippedCount + " skipped, " + errorCount + " errors.";
                    
                    // Limit details to 500 chars to avoid bloating response
                    string details = string.Join("\n", detailsList);
                    if (details.Length > 500) details = details.Substring(0, 500) + "...";
                    resp["Details"] = details;

                    return resp;
                }
                catch (Exception txEx)
                {
                    try { tx.Rollback(); } catch { }
                    resp["Message"] = "Import failed (transaction rolled back): " + txEx.Message;
                    return resp;
                }
            }
        }
        catch (Exception ex)
        {
            resp["Message"] = "Error during import execution: " + ex.Message;
            return resp;
        }
    }

    // ===============================================================
    // DATA QUALITY REVIEW PANEL
    //   Surfaces + safely resolves phantom / duplicate programme-course
    //   rows. Every write is guarded (never removes a row that has
    //   students, marks, or a lecturer), backed up into
    //   acad_programmecourses_quarantine, and logged in
    //   acad_programmecourses_dq_audit. Fully reversible.
    // ===============================================================

    private static string REG_TABLE = "campus_dynamics_portal.acad_course_registration";

    private static void DqExec(MySqlConnection conn, MySqlTransaction tx, string sql)
    {
        using (MySqlCommand c = new MySqlCommand(sql, conn, tx)) c.ExecuteNonQuery();
    }

    private static int DqScalar(MySqlConnection conn, MySqlTransaction tx, string sql, params MySqlParameter[] ps)
    {
        using (MySqlCommand c = new MySqlCommand(sql, conn, tx))
        {
            if (ps != null) foreach (MySqlParameter p in ps) c.Parameters.Add(p);
            object o = c.ExecuteScalar();
            return (o == null || o == DBNull.Value) ? 0 : Convert.ToInt32(o);
        }
    }

    private static string DqUser()
    {
        try
        {
            if (HttpContext.Current != null && HttpContext.Current.Session != null)
            {
                object u = HttpContext.Current.Session["username"];
                if (u != null) return u.ToString();
            }
        }
        catch { }
        return "system";
    }

    // Build usage aggregates. MySQL forbids referencing a TEMPORARY table more
    // than once in one query, so each table below is referenced at most once per
    // query: _dq_pc = (prog,course)->regs/res ; _dq_course = course->prog list.
    private static void DqBuildAggregates(MySqlConnection conn)
    {
        DqExec(conn, null, "SET SESSION group_concat_max_len=100000");
        DqExec(conn, null, "DROP TEMPORARY TABLE IF EXISTS _dq_pc");
        DqExec(conn, null, "CREATE TEMPORARY TABLE _dq_pc (p VARCHAR(40) NOT NULL, c VARCHAR(40) NOT NULL, regs INT NOT NULL DEFAULT 0, res INT NOT NULL DEFAULT 0, PRIMARY KEY(p,c)) ENGINE=InnoDB DEFAULT CHARSET=utf8");
        DqExec(conn, null, "INSERT INTO _dq_pc (p,c,regs) SELECT IFNULL(TRIM(prog_id),''), IFNULL(TRIM(courseID),''), COUNT(*) FROM " + REG_TABLE + " GROUP BY IFNULL(TRIM(prog_id),''), IFNULL(TRIM(courseID),'') ON DUPLICATE KEY UPDATE regs=VALUES(regs)");
        DqExec(conn, null, "INSERT INTO _dq_pc (p,c,res) SELECT IFNULL(TRIM(progid),''), IFNULL(TRIM(courseid),''), COUNT(*) FROM acad_results GROUP BY IFNULL(TRIM(progid),''), IFNULL(TRIM(courseid),'') ON DUPLICATE KEY UPDATE res=VALUES(res)");
        DqExec(conn, null, "DROP TEMPORARY TABLE IF EXISTS _dq_course");
        DqExec(conn, null, "CREATE TEMPORARY TABLE _dq_course (c VARCHAR(40) NOT NULL, progs TEXT, PRIMARY KEY(c)) ENGINE=InnoDB DEFAULT CHARSET=utf8");
        DqExec(conn, null, "INSERT INTO _dq_course (c,progs) SELECT c, GROUP_CONCAT(DISTINCT p ORDER BY p SEPARATOR ',') FROM _dq_pc GROUP BY c");
    }

    // Provision quarantine + audit tables (DDL -> implicit commit; call OUTSIDE any txn).
    private static void DqEnsureTables(MySqlConnection conn)
    {
        DqExec(conn, null, "CREATE TABLE IF NOT EXISTS acad_programmecourses_quarantine LIKE acad_programmecourses");
        DqAddCol(conn, "acad_programmecourses_quarantine", "q_reason", "VARCHAR(40) NULL");
        DqAddCol(conn, "acad_programmecourses_quarantine", "q_batch", "VARCHAR(40) NULL");
        DqAddCol(conn, "acad_programmecourses_quarantine", "q_at", "DATETIME NULL");
        DqExec(conn, null, "CREATE TABLE IF NOT EXISTS acad_programmecourses_dq_audit (" +
            "audit_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, pc_id INT UNSIGNED NULL, " +
            "action VARCHAR(20) NULL, old_progcode VARCHAR(20) NULL, new_progcode VARCHAR(20) NULL, " +
            "snapshot TEXT NULL, performed_by VARCHAR(80) NULL, performed_at DATETIME NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8");
    }

    private static void DqAddCol(MySqlConnection conn, string table, string col, string def)
    {
        int has = DqScalar(conn, null,
            "SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=@t AND column_name=@c",
            new MySqlParameter("@t", table), new MySqlParameter("@c", col));
        if (has == 0) DqExec(conn, null, "ALTER TABLE " + table + " ADD COLUMN " + col + " " + def);
    }

    private static string DqSnapshot(MySqlConnection conn, MySqlTransaction tx, int id)
    {
        using (MySqlCommand c = new MySqlCommand(
            "SELECT CONCAT_WS('|',ID,progcode,course_code,study_year,semester,CurriculumID," +
            "IFNULL(specialisation_id,''),course_type,is_lecturere_assigned,IFNULL(lecturer_id,''),status) " +
            "FROM acad_programmecourses WHERE ID=@id", conn, tx))
        {
            c.Parameters.AddWithValue("@id", id);
            object o = c.ExecuteScalar();
            return o == null || o == DBNull.Value ? "" : o.ToString();
        }
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static DqStatsResp DQ_Stats()
    {
        DqStatsResp r = new DqStatsResp();
        r.Success = false; r.Message = "";
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                DqBuildAggregates(conn);
                r.Mismapped = DqScalar(conn, null,
                    "SELECT COUNT(*) FROM acad_programmecourses pc " +
                    "LEFT JOIN _dq_pc j ON j.p=TRIM(pc.progcode) AND j.c=TRIM(pc.course_code) " +
                    "LEFT JOIN _dq_course cc ON cc.c=TRIM(pc.course_code) " +
                    "WHERE j.p IS NULL AND cc.c IS NOT NULL AND TRIM(IFNULL(pc.course_code,''))<>''");
                r.SubjectSlots = DqScalar(conn, null,
                    "SELECT COUNT(*) FROM (SELECT 1 FROM acad_programmecourses pc " +
                    "JOIN acad_course c ON TRIM(c.courseID)=TRIM(pc.course_code) " +
                    "GROUP BY TRIM(pc.progcode),pc.study_year,pc.semester,TRIM(UPPER(c.courseName)) " +
                    "HAVING COUNT(DISTINCT TRIM(pc.course_code))>1) x");
                r.Success = true;
            }
        }
        catch (Exception ex) { r.Message = ex.Message; }
        return r;
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static DqListResp DQ_ListMismapped(int page, int pageSize, string search)
    {
        DqListResp r = new DqListResp();
        r.Success = false; r.Rows = new List<DqRow>();
        try
        {
            if (page < 1) page = 1;
            if (pageSize < 1 || pageSize > 200) pageSize = 25;
            string s = (search ?? "").Trim();
            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                DqBuildAggregates(conn);
                string baseFrom =
                    "FROM acad_programmecourses pc " +
                    "LEFT JOIN _dq_pc j ON j.p=TRIM(pc.progcode) AND j.c=TRIM(pc.course_code) " +
                    "LEFT JOIN _dq_course cc ON cc.c=TRIM(pc.course_code) " +
                    "LEFT JOIN acad_course c ON TRIM(c.courseID)=TRIM(pc.course_code) " +
                    "WHERE j.p IS NULL AND cc.c IS NOT NULL AND TRIM(IFNULL(pc.course_code,''))<>'' ";
                string sc = s == "" ? "" : "AND (pc.progcode LIKE @s OR pc.course_code LIKE @s OR c.courseName LIKE @s) ";
                r.Total = DqScalar(conn, null, "SELECT COUNT(*) " + baseFrom + sc,
                    s == "" ? new MySqlParameter[0] : new MySqlParameter[] { new MySqlParameter("@s", "%" + s + "%") });
                int off = (page - 1) * pageSize;
                string sql =
                    "SELECT pc.ID, TRIM(pc.progcode) progcode, TRIM(pc.course_code) course_code, pc.study_year, pc.semester, " +
                    "UPPER(IFNULL(pc.is_lecturere_assigned,'No')) la, IFNULL(c.courseName,'') cname, IFNULL(cc.progs,'') used_all " +
                    baseFrom + sc +
                    "ORDER BY pc.progcode, pc.study_year, pc.semester, pc.course_code LIMIT " + pageSize + " OFFSET " + off;
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (s != "") cmd.Parameters.AddWithValue("@s", "%" + s + "%");
                    using (MySqlDataReader rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            DqRow row = new DqRow();
                            row.ID = Convert.ToInt32(rd["ID"]);
                            row.Progcode = ToStrSafe(rd["progcode"]);
                            row.CourseCode = ToStrSafe(rd["course_code"]);
                            row.StudyYear = ToIntSafe(rd["study_year"], 0);
                            row.Semester = ToIntSafe(rd["semester"], 0);
                            row.LecturerAssigned = string.Equals(ToStrSafe(rd["la"]), "YES", StringComparison.OrdinalIgnoreCase);
                            row.CourseName = ToStrSafe(rd["cname"]);
                            row.UsedUnder = DqMergeCodes(ToStrSafe(rd["used_all"]), "", row.Progcode);
                            r.Rows.Add(row);
                        }
                    }
                }
                r.Success = true;
            }
        }
        catch (Exception ex) { r.Message = ex.Message; }
        return r;
    }

    private static string DqMergeCodes(string a, string b, string exclude)
    {
        List<string> outp = new List<string>();
        string[] parts = (a + "," + b).Split(',');
        foreach (string raw in parts)
        {
            string t = (raw ?? "").Trim();
            if (t == "" || string.Equals(t, exclude, StringComparison.OrdinalIgnoreCase)) continue;
            bool dup = false;
            foreach (string e in outp) if (string.Equals(e, t, StringComparison.OrdinalIgnoreCase)) { dup = true; break; }
            if (!dup) outp.Add(t);
        }
        outp.Sort(StringComparer.OrdinalIgnoreCase);
        return string.Join(", ", outp.ToArray());
    }

    [WebMethod]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static DqSubjectResp DQ_ListSubjectDups(string search)
    {
        DqSubjectResp r = new DqSubjectResp();
        r.Success = false; r.Rows = new List<DqSubjectRow>();
        try
        {
            string s = (search ?? "").Trim().ToUpperInvariant();
            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                DqBuildAggregates(conn);
                string sql =
                    "SELECT TRIM(pc.progcode) prog, pc.study_year yr, pc.semester sem, TRIM(UPPER(c.courseName)) subject, " +
                    "TRIM(pc.course_code) code, GROUP_CONCAT(pc.ID ORDER BY pc.ID) ids, " +
                    "IFNULL(j.regs,0) regs, IFNULL(j.res,0) res " +
                    "FROM acad_programmecourses pc " +
                    "JOIN acad_course c ON TRIM(c.courseID)=TRIM(pc.course_code) " +
                    "JOIN (SELECT TRIM(p2.progcode) p, p2.study_year y, p2.semester s, TRIM(UPPER(c2.courseName)) nm " +
                    "      FROM acad_programmecourses p2 JOIN acad_course c2 ON TRIM(c2.courseID)=TRIM(p2.course_code) " +
                    "      GROUP BY p,y,s,nm HAVING COUNT(DISTINCT TRIM(p2.course_code))>1) dup " +
                    "  ON dup.p=TRIM(pc.progcode) AND dup.y=pc.study_year AND dup.s=pc.semester AND dup.nm=TRIM(UPPER(c.courseName)) " +
                    "LEFT JOIN _dq_pc j ON j.p=TRIM(pc.progcode) AND j.c=TRIM(pc.course_code) " +
                    "GROUP BY prog,yr,sem,subject,code,j.regs,j.res " +
                    "ORDER BY prog,yr,sem,subject,code";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                using (MySqlDataReader rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        DqSubjectRow row = new DqSubjectRow();
                        row.Prog = ToStrSafe(rd["prog"]);
                        row.Yr = ToIntSafe(rd["yr"], 0);
                        row.Sem = ToIntSafe(rd["sem"], 0);
                        row.Subject = ToStrSafe(rd["subject"]);
                        row.Code = ToStrSafe(rd["code"]);
                        row.Ids = ToStrSafe(rd["ids"]);
                        row.Regs = ToIntSafe(rd["regs"], 0);
                        row.Res = ToIntSafe(rd["res"], 0);
                        if (s != "" &&
                            row.Prog.ToUpperInvariant().IndexOf(s) < 0 &&
                            row.Subject.IndexOf(s) < 0 &&
                            row.Code.ToUpperInvariant().IndexOf(s) < 0) continue;
                        r.Rows.Add(row);
                    }
                }
                r.Success = true;
            }
        }
        catch (Exception ex) { r.Message = ex.Message; }
        return r;
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static DqActionResp DQ_QuarantineRows(DqIdsReq request)
    {
        DqActionResp resp = new DqActionResp();
        resp.Success = false; resp.Removed = 0; resp.Skipped = 0; resp.Message = "";
        List<string> notes = new List<string>();
        try
        {
            if (request == null || request.ids == null || request.ids.Count == 0)
            { resp.Message = "No rows selected."; return resp; }
            HashSet<int> ids = new HashSet<int>();
            foreach (int id in request.ids) if (id > 0) ids.Add(id);
            if (ids.Count == 0) { resp.Message = "No valid rows selected."; return resp; }
            if (ids.Count > 2000) { resp.Message = "Too many rows in one batch (max 2000)."; return resp; }

            string user = DqUser();
            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                DqEnsureTables(conn);
                using (MySqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        foreach (int id in ids)
                        {
                            string prog = null, course = null, la = "No";
                            using (MySqlCommand c = new MySqlCommand(
                                "SELECT TRIM(progcode), TRIM(course_code), UPPER(IFNULL(is_lecturere_assigned,'No')) FROM acad_programmecourses WHERE ID=@id", conn, tx))
                            {
                                c.Parameters.AddWithValue("@id", id);
                                using (MySqlDataReader rd = c.ExecuteReader())
                                {
                                    if (rd.Read()) { prog = rd.IsDBNull(0) ? "" : rd.GetString(0); course = rd.IsDBNull(1) ? "" : rd.GetString(1); la = rd.IsDBNull(2) ? "No" : rd.GetString(2); }
                                }
                            }
                            if (prog == null) { resp.Skipped++; notes.Add(id + ": not found"); continue; }
                            if (string.Equals(la, "YES", StringComparison.OrdinalIgnoreCase))
                            { resp.Skipped++; notes.Add(id + ": has a lecturer assigned (re-point or unassign first)"); continue; }
                            int regs = DqScalar(conn, tx, "SELECT COUNT(*) FROM " + REG_TABLE + " WHERE TRIM(prog_id)=@p AND TRIM(courseID)=@c",
                                new MySqlParameter("@p", prog), new MySqlParameter("@c", course));
                            if (regs > 0) { resp.Skipped++; notes.Add(id + ": has " + regs + " registration(s) here"); continue; }
                            int res = DqScalar(conn, tx, "SELECT COUNT(*) FROM acad_results WHERE TRIM(progid)=@p AND TRIM(courseid)=@c",
                                new MySqlParameter("@p", prog), new MySqlParameter("@c", course));
                            if (res > 0) { resp.Skipped++; notes.Add(id + ": has " + res + " result(s) here"); continue; }

                            string snap = DqSnapshot(conn, tx, id);
                            using (MySqlCommand qc = new MySqlCommand(
                                "INSERT INTO acad_programmecourses_quarantine " +
                                "SELECT pc.*, 'DQ_PANEL', 'dq_panel', NOW() FROM acad_programmecourses pc WHERE pc.ID=@id", conn, tx))
                            { qc.Parameters.AddWithValue("@id", id); qc.ExecuteNonQuery(); }
                            using (MySqlCommand ac = new MySqlCommand(
                                "INSERT INTO acad_programmecourses_dq_audit (pc_id,action,old_progcode,new_progcode,snapshot,performed_by,performed_at) " +
                                "VALUES (@id,'QUARANTINE',@op,NULL,@snap,@u,NOW())", conn, tx))
                            {
                                ac.Parameters.AddWithValue("@id", id);
                                ac.Parameters.AddWithValue("@op", prog);
                                ac.Parameters.AddWithValue("@snap", snap);
                                ac.Parameters.AddWithValue("@u", user);
                                ac.ExecuteNonQuery();
                            }
                            using (MySqlCommand dc = new MySqlCommand("DELETE FROM acad_programmecourses WHERE ID=@id", conn, tx))
                            { dc.Parameters.AddWithValue("@id", id); dc.ExecuteNonQuery(); }
                            resp.Removed++;
                        }
                        tx.Commit();
                        resp.Success = true;
                        resp.Message = "Safe-removed " + resp.Removed + " row(s); skipped " + resp.Skipped + ".";
                        resp.Detail = string.Join("\n", notes.ToArray());
                        return resp;
                    }
                    catch (Exception exi) { try { tx.Rollback(); } catch { } resp.Message = "Transaction failed: " + exi.Message; return resp; }
                }
            }
        }
        catch (Exception ex) { resp.Message = "Request failed: " + ex.Message; return resp; }
    }

    [WebMethod(EnableSession = true)]
    [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
    public static DqActionResp DQ_RepointRow(DqRepointReq request)
    {
        DqActionResp resp = new DqActionResp();
        resp.Success = false; resp.Message = "";
        try
        {
            if (request == null || request.id <= 0 || string.IsNullOrEmpty(request.targetProgcode))
            { resp.Message = "Row and target programme are required."; return resp; }
            string target = request.targetProgcode.Trim();
            string user = DqUser();

            using (MySqlConnection conn = new MySqlConnection(ConnStrStatic))
            {
                conn.Open();
                DqEnsureTables(conn);

                string prog = null, course = null; int cur = 0, spec = 0, yr = 0, sem = 0;
                using (MySqlCommand c = new MySqlCommand(
                    "SELECT TRIM(progcode),TRIM(course_code),CurriculumID,IFNULL(specialisation_id,0),study_year,semester FROM acad_programmecourses WHERE ID=@id", conn))
                {
                    c.Parameters.AddWithValue("@id", request.id);
                    using (MySqlDataReader rd = c.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            prog = rd.IsDBNull(0) ? "" : rd.GetString(0);
                            course = rd.IsDBNull(1) ? "" : rd.GetString(1);
                            cur = rd.IsDBNull(2) ? 0 : Convert.ToInt32(rd.GetValue(2));
                            spec = rd.IsDBNull(3) ? 0 : Convert.ToInt32(rd.GetValue(3));
                            yr = rd.IsDBNull(4) ? 0 : Convert.ToInt32(rd.GetValue(4));
                            sem = rd.IsDBNull(5) ? 0 : Convert.ToInt32(rd.GetValue(5));
                        }
                    }
                }
                if (prog == null) { resp.Message = "Row not found."; return resp; }
                if (string.Equals(prog, target, StringComparison.OrdinalIgnoreCase))
                { resp.Message = "Row is already under that programme."; return resp; }

                // Target must be a programme where this course is actually taken.
                int usedThere = DqScalar(conn, null, "SELECT COUNT(*) FROM " + REG_TABLE + " WHERE TRIM(prog_id)=@t AND TRIM(courseID)=@c",
                    new MySqlParameter("@t", target), new MySqlParameter("@c", course));
                usedThere += DqScalar(conn, null, "SELECT COUNT(*) FROM acad_results WHERE TRIM(progid)=@t AND TRIM(courseid)=@c",
                    new MySqlParameter("@t", target), new MySqlParameter("@c", course));
                if (usedThere == 0)
                { resp.Message = "The course is not taken under '" + target + "', so re-pointing there is not allowed."; return resp; }

                // Collision guard: target must not already list this course in the same slot.
                int clash = DqScalar(conn, null,
                    "SELECT COUNT(*) FROM acad_programmecourses WHERE TRIM(course_code)=@c AND TRIM(progcode)=@t " +
                    "AND CurriculumID=@cur AND IFNULL(specialisation_id,0)=@spec AND study_year=@y AND semester=@s AND ID<>@id",
                    new MySqlParameter("@c", course), new MySqlParameter("@t", target), new MySqlParameter("@cur", cur),
                    new MySqlParameter("@spec", spec), new MySqlParameter("@y", yr), new MySqlParameter("@s", sem),
                    new MySqlParameter("@id", request.id));
                if (clash > 0)
                { resp.Message = "'" + target + "' already lists this course in the same slot. Use Safe-remove instead (this row is redundant)."; return resp; }

                using (MySqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        string snap = DqSnapshot(conn, tx, request.id);
                        using (MySqlCommand ac = new MySqlCommand(
                            "INSERT INTO acad_programmecourses_dq_audit (pc_id,action,old_progcode,new_progcode,snapshot,performed_by,performed_at) " +
                            "VALUES (@id,'REPOINT',@op,@np,@snap,@u,NOW())", conn, tx))
                        {
                            ac.Parameters.AddWithValue("@id", request.id);
                            ac.Parameters.AddWithValue("@op", prog);
                            ac.Parameters.AddWithValue("@np", target);
                            ac.Parameters.AddWithValue("@snap", snap);
                            ac.Parameters.AddWithValue("@u", user);
                            ac.ExecuteNonQuery();
                        }
                        using (MySqlCommand uc = new MySqlCommand("UPDATE acad_programmecourses SET progcode=@t WHERE ID=@id", conn, tx))
                        {
                            uc.Parameters.AddWithValue("@t", target);
                            uc.Parameters.AddWithValue("@id", request.id);
                            uc.ExecuteNonQuery();
                        }
                        tx.Commit();
                        resp.Success = true;
                        resp.Removed = 1;
                        resp.Message = "Re-pointed to '" + target + "'.";
                        return resp;
                    }
                    catch (Exception exi) { try { tx.Rollback(); } catch { } resp.Message = "Re-point failed: " + exi.Message; return resp; }
                }
            }
        }
        catch (Exception ex) { resp.Message = "Request failed: " + ex.Message; return resp; }
    }

    public class DqStatsResp { public bool Success { get; set; } public string Message { get; set; } public int Mismapped { get; set; } public int SubjectSlots { get; set; } }
    public class DqRow
    {
        public int ID { get; set; } public string Progcode { get; set; } public string CourseCode { get; set; }
        public string CourseName { get; set; } public int StudyYear { get; set; } public int Semester { get; set; }
        public bool LecturerAssigned { get; set; } public string UsedUnder { get; set; }
    }
    public class DqListResp { public bool Success { get; set; } public string Message { get; set; } public int Total { get; set; } public List<DqRow> Rows { get; set; } }
    public class DqSubjectRow
    {
        public string Prog { get; set; } public int Yr { get; set; } public int Sem { get; set; }
        public string Subject { get; set; } public string Code { get; set; } public string Ids { get; set; }
        public int Regs { get; set; } public int Res { get; set; }
    }
    public class DqSubjectResp { public bool Success { get; set; } public string Message { get; set; } public List<DqSubjectRow> Rows { get; set; } }
    public class DqIdsReq { public List<int> ids { get; set; } }
    public class DqRepointReq { public int id { get; set; } public string targetProgcode { get; set; } }
    public class DqActionResp { public bool Success { get; set; } public string Message { get; set; } public int Removed { get; set; } public int Skipped { get; set; } public string Detail { get; set; } }
}
