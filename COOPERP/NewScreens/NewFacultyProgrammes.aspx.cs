using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_NewFacultyProgrammes : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    private static readonly string[] LEVEL_LABELS = {
        "Elementary", "Certificate", "Diploma", "Bachelors Degree",
        "Post Graduate Diploma", "Masters Degree", "Doctorate"
    };

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
                    if (parms != null)
                        foreach (var p in parms) cmd.Parameters.Add(p);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                        da.Fill(dt);
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
                if (parms != null)
                    foreach (var p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    /// <summary>
    /// Renames a programme code across ALL linked tables/databases via the atomic
    /// stored procedure acad_RenameProgrammeCode. The SP is all-or-nothing (rolls back
    /// on any error) and writes an audit row. A large programme can touch tens of
    /// thousands of rows, so a generous timeout is used. Throws on any failure.
    /// </summary>
    private void RenameProgrammeCode(string oldCode, string newCode)
    {
        string actor = (Session["username"] != null && Session["username"].ToString().Trim() != "")
            ? Session["username"].ToString().Trim() : "system";
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("CALL acad_RenameProgrammeCode(@o, @n, @a, 0)", conn))
            {
                cmd.CommandTimeout = 300;
                cmd.Parameters.AddWithValue("@o", oldCode);
                cmd.Parameters.AddWithValue("@n", newCode);
                cmd.Parameters.AddWithValue("@a", actor);
                cmd.ExecuteNonQuery();  // SP SIGNALs (throws) on any validation/data error
            }
        }
    }

    // ---------------------------------------------------------------
    protected void Page_Load(object sender, EventArgs e)
    {
        // GET listing endpoint: NewFacultyProgrammes.aspx?act=list returns the
        // programmes as JSON. The listing renders client-side from this (no postback).
        if (!IsPostBack && string.Equals(Request.QueryString["act"], "list", StringComparison.OrdinalIgnoreCase))
        {
            EmitProgrammesJson();
            return;
        }

        // POST endpoint: set a programme's online-application status (active / inactive).
        if (string.Equals(Request["act"], "setappstatus", StringComparison.OrdinalIgnoreCase))
        {
            HandleSetAppStatus();
            return;
        }

        // Reload dropdowns on every request (not in ViewState)
        LoadFacultyDropdown();
        LoadDepartmentDropdown();

        if (!IsPostBack)
        {
            EnsureColumns();
        }
        else
        {
            // On postback, restore the selected faculty + department from form data
            string postedFaculty = Request.Form[ddlFaculty.UniqueID] ?? "";
            if (!string.IsNullOrEmpty(postedFaculty))
            {
                TrySelect(ddlFaculty, postedFaculty);
            }
            string postedDept = Request.Form[ddlDepartment.UniqueID] ?? "";
            if (!string.IsNullOrEmpty(postedDept))
            {
                TrySelect(ddlDepartment, postedDept);
            }
        }
    }

    private void EnsureColumns()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                // is_fully_set
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='acad_programme' AND COLUMN_NAME='is_fully_set'", conn))
                {
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                    {
                        using (MySqlCommand alt = new MySqlCommand(
                            "ALTER TABLE acad_programme ADD COLUMN is_fully_set VARCHAR(10) DEFAULT 'No'", conn))
                            alt.ExecuteNonQuery();
                    }
                }
                // online_app_active — whether this programme is open for online applications
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='acad_programme' AND COLUMN_NAME='online_app_active'", conn))
                {
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                    {
                        using (MySqlCommand alt = new MySqlCommand(
                            "ALTER TABLE acad_programme ADD COLUMN online_app_active TINYINT(1) NOT NULL DEFAULT 1", conn))
                            alt.ExecuteNonQuery();
                    }
                }
                // department_id — every programme belongs to a department
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='acad_programme' AND COLUMN_NAME='department_id'", conn))
                {
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                    {
                        using (MySqlCommand alt = new MySqlCommand(
                            "ALTER TABLE acad_programme ADD COLUMN department_id INT NULL AFTER faculty_code", conn))
                            alt.ExecuteNonQuery();
                    }
                }
                // hrm_departments.faculty_code — a department belongs to a faculty
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                    "WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='hrm_departments' AND COLUMN_NAME='faculty_code'", conn))
                {
                    if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
                    {
                        using (MySqlCommand alt = new MySqlCommand(
                            "ALTER TABLE hrm_departments ADD COLUMN faculty_code CHAR(10) NULL", conn))
                            alt.ExecuteNonQuery();
                    }
                }
            }
        }
        catch { }
    }

    private void LoadFacultyDropdown()
    {
        DataTable dt = ExecuteQuery("SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name");
        ddlFaculty.Items.Clear();
        ddlFaculty.Items.Add(new ListItem("-- Select Faculty --", ""));
        foreach (DataRow r in dt.Rows)
            ddlFaculty.Items.Add(new ListItem(r["faculty_name"].ToString(), r["faculty_code"].ToString()));
    }

    private void LoadDepartmentDropdown()
    {
        ddlDepartment.Items.Clear();
        ddlDepartment.Items.Add(new ListItem("-- Select Department --", ""));
        DataTable dt = null;
        try
        {
            // Each option carries its faculty (data-fac) so the client can
            // filter departments to the selected faculty.
            dt = ExecuteQuery(
                "SELECT ID, dept_name, IFNULL(faculty_code,'') AS fc " +
                "FROM hrm_departments ORDER BY dept_name");
        }
        catch { dt = null; }
        if (dt == null) return;
        foreach (DataRow r in dt.Rows)
        {
            ListItem li = new ListItem(r["dept_name"].ToString(), r["ID"].ToString());
            li.Attributes["data-fac"] = r["fc"].ToString();
            ddlDepartment.Items.Add(li);
        }
    }

    // The listing now loads via the GET endpoint (?act=list) and re-fetches on every
    // page render, so server-side binding is no longer needed. Kept as a no-op so the
    // existing post-action callers stay valid and always trigger a fresh client load.
    private void BindGrid() { }

    private static string ProgrammesSql()
    {
        return @"
            SELECT p.progcode, p.progname,
                   IFNULL(p.abbrev,'') AS abbrev,
                   IFNULL(p.couselength,0) AS couselength,
                   IFNULL(p.maxduration,0) AS maxduration,
                   IFNULL(p.mincredit,0) AS mincredit,
                   IFNULL(p.faculty_code,'') AS faculty_code,
                   IFNULL(f.faculty_name,'') AS faculty_name,
                   IFNULL(d.dept_name,'') AS dept_name,
                   IFNULL(p.levelCode,0) AS levelCode,
                   IFNULL(p.study_system,'') AS study_system,
                   IFNULL(p.is_fully_set,'No') AS is_fully_set,
                   IFNULL(p.online_app_active,1) AS online_app_active,
                   IFNULL(s.spec_count,0) AS spec_count,
                   IFNULL(cc.course_count,0) AS course_count,
                   CASE IFNULL(p.levelCode,0)
                       WHEN 0 THEN 'Elementary'
                       WHEN 1 THEN 'Certificate'
                       WHEN 2 THEN 'Diploma'
                       WHEN 3 THEN 'Bachelors Degree'
                       WHEN 4 THEN 'Post Graduate Diploma'
                       WHEN 5 THEN 'Masters Degree'
                       WHEN 6 THEN 'Doctorate'
                       ELSE '' END AS level_label
            FROM acad_programme p
            LEFT JOIN acad_faculty f ON f.faculty_code = p.faculty_code
            LEFT JOIN hrm_departments d ON d.ID = p.department_id
            LEFT JOIN (SELECT prog_id, COUNT(*) AS spec_count FROM acad_specialisation GROUP BY prog_id) s
                   ON p.progcode = s.prog_id
            LEFT JOIN (SELECT pc.progcode, COUNT(*) AS course_count
                       FROM acad_programmecourses pc
                       INNER JOIN acad_course c ON pc.course_code = c.courseID
                       GROUP BY pc.progcode) cc
                   ON cc.progcode = p.progcode
            ORDER BY p.progname";
    }

    // GET endpoint — emits the programmes list as a JSON array and ends the response.
    private void EmitProgrammesJson()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        try
        {
            EnsureColumns(); // guarantee department_id / faculty_code exist before the query
            DataTable dt = ExecuteQuery(ProgrammesSql());
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow r = dt.Rows[i];
                if (i > 0) sb.Append(",");
                sb.Append("{")
                  .Append("\"code\":").Append(JS(r["progcode"].ToString())).Append(",")
                  .Append("\"name\":").Append(JS(r["progname"].ToString())).Append(",")
                  .Append("\"faculty\":").Append(JS(r["faculty_name"].ToString())).Append(",")
                  .Append("\"dept\":").Append(JS(r["dept_name"].ToString())).Append(",")
                  .Append("\"level\":").Append(Convert.ToInt32(r["levelCode"])).Append(",")
                  .Append("\"level_label\":").Append(JS(r["level_label"].ToString())).Append(",")
                  .Append("\"duration\":").Append(Convert.ToInt32(r["couselength"])).Append(",")
                  .Append("\"study_system\":").Append(JS(r["study_system"].ToString())).Append(",")
                  .Append("\"fully\":").Append(JS(r["is_fully_set"].ToString())).Append(",")
                  .Append("\"app_active\":").Append(Convert.ToInt32(r["online_app_active"])).Append(",")
                  .Append("\"spec_count\":").Append(Convert.ToInt32(r["spec_count"])).Append(",")
                  .Append("\"course_count\":").Append(Convert.ToInt32(r["course_count"]))
                  .Append("}");
            }
            sb.Append("]");
            Response.Write(sb.ToString());
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":" + JS(ex.Message) + "}");
        }
        Response.End();
    }

    // JSON string literal (quoted + escaped).
    private static string JS(string s) { return HttpUtility.JavaScriptStringEncode(s ?? "", true); }

    // POST endpoint — set a programme's online-application status (active=1 / inactive=0).
    // Inactive programmes are hidden from the eportal online-application dropdowns.
    private void HandleSetAppStatus()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        try
        {
            string code = (Request["code"] ?? "").Trim();
            string activeRaw = (Request["active"] ?? "").Trim();
            if (code.Length == 0)
            {
                Response.Write("{\"ok\":false,\"message\":" + JS("Programme code is required.") + "}");
                Response.End();
                return;
            }
            int active = (activeRaw == "1" || activeRaw.Equals("true", StringComparison.OrdinalIgnoreCase)) ? 1 : 0;

            EnsureColumns(); // guarantee online_app_active exists
            int rows;
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "UPDATE acad_programme SET online_app_active=@a WHERE TRIM(progcode)=TRIM(@c)", conn))
                {
                    cmd.Parameters.AddWithValue("@a", active);
                    cmd.Parameters.AddWithValue("@c", code);
                    rows = cmd.ExecuteNonQuery();
                }
            }
            if (rows <= 0)
            {
                Response.Write("{\"ok\":false,\"message\":" + JS("Programme not found.") + "}");
            }
            else
            {
                string msg = active == 1
                    ? "Online applications ENABLED for this programme."
                    : "Online applications DISABLED — this programme is now hidden from the eportal application form.";
                Response.Write("{\"ok\":true,\"active\":" + active + ",\"message\":" + JS(msg) + "}");
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"ok\":false,\"message\":" + JS(ex.Message) + "}");
        }
        Response.End();
    }

    // ---------------------------------------------------------------
    // Save (Insert or Update)
    // ---------------------------------------------------------------
    protected void btnSaveProgramme_Click(object sender, EventArgs e)
    {
        string mode = hdnModalMode.Value.Trim().ToUpper();

        // LOAD mode: populate modal fields for editing, re-open modal
        if (mode == "LOAD")
        {
            LoadForEdit(hdnEditProgcode.Value.Trim());
            return;
        }

        // Validate
        string progcode = txtProgcode.Text.Trim().ToUpper();
        string progname = txtProgname.Text.Trim();
        string abbrev   = txtAbbrev.Text.Trim();
        string faculty  = ddlFaculty.SelectedValue;
        if (string.IsNullOrEmpty(faculty))
            faculty = Request.Form[ddlFaculty.UniqueID] ?? "";
        string deptVal  = ddlDepartment.SelectedValue;
        if (string.IsNullOrEmpty(deptVal))
            deptVal = Request.Form[ddlDepartment.UniqueID] ?? "";
        int deptId;
        object deptParam = (int.TryParse(deptVal, out deptId) && deptId > 0) ? (object)deptId : (object)DBNull.Value;
        string levelVal = ddlLevel.SelectedValue;
        string durVal   = ddlDuration.SelectedValue;
        string studySys = ddlStudySystem.SelectedValue;
        string isFullySet = ddlFullySet.SelectedValue;
        string minCreditStr  = txtMinCredit.Text.Trim();
        string maxDurStr     = txtMaxDuration.Text.Trim();

        if (string.IsNullOrEmpty(progcode))
        { ShowModalError("Programme Code is required."); return; }
        if (string.IsNullOrEmpty(progname))
        { ShowModalError("Programme Name is required."); return; }
        if (string.IsNullOrEmpty(faculty))
        { ShowModalError("Please select a Faculty."); return; }
        if (deptParam == DBNull.Value)
        { ShowModalError("Please select a Department. Every programme must belong to a department."); return; }
        if (string.IsNullOrEmpty(levelVal))
        { ShowModalError("Please select an Academic Level."); return; }
        if (string.IsNullOrEmpty(durVal))
        { ShowModalError("Please select a Duration."); return; }
        if (string.IsNullOrEmpty(studySys))
        { ShowModalError("Please select a Study System."); return; }

        int duration = int.Parse(durVal);
        int level    = int.Parse(levelVal);
        double minCredit = 0; double.TryParse(minCreditStr, out minCredit);
        int maxDur = duration * 2; int.TryParse(maxDurStr, out maxDur); // default max = 2× normal

        try
        {
            if (mode == "NEW")
            {
                // Check duplicate code
                DataTable dtCheck = ExecuteQuery(
                    "SELECT COUNT(*) AS cnt FROM acad_programme WHERE progcode=@code",
                    new MySqlParameter("@code", progcode));
                if (dtCheck.Rows.Count > 0 && Convert.ToInt32(dtCheck.Rows[0]["cnt"]) > 0)
                { ShowModalError("Programme Code '" + progcode + "' already exists."); return; }

                ExecuteNonQuery(@"
                    INSERT INTO acad_programme
                        (progcode, progname, abbrev, mincredit, couselength, maxduration,
                         faculty_code, department_id, levelCode, study_system, is_fully_set)
                    VALUES (@code, @name, @abbrev, @mincredit, @dur, @maxdur,
                            @faculty, @dept, @level, @study, @fully)",
                    new MySqlParameter("@code",    progcode),
                    new MySqlParameter("@name",    progname),
                    new MySqlParameter("@abbrev",  abbrev),
                    new MySqlParameter("@mincredit", minCredit),
                    new MySqlParameter("@dur",     duration),
                    new MySqlParameter("@maxdur",  maxDur),
                    new MySqlParameter("@faculty", faculty),
                    new MySqlParameter("@dept",    deptParam),
                    new MySqlParameter("@level",   level),
                    new MySqlParameter("@study",   studySys),
                    new MySqlParameter("@fully",   isFullySet));

                BindGrid();
                ResetModal();
                ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                    "closeProgModal();showToast('Programme created successfully.','success');", true);
            }
            else // EDIT
            {
                string original = hdnEditProgcode.Value.Trim().ToUpper();
                bool codeChanged = !string.Equals(progcode, original, StringComparison.OrdinalIgnoreCase);

                if (codeChanged)
                {
                    // The new code must not collide with an existing programme.
                    DataTable dtChk = ExecuteQuery(
                        "SELECT COUNT(*) AS cnt FROM acad_programme WHERE progcode=@c",
                        new MySqlParameter("@c", progcode));
                    if (dtChk.Rows.Count > 0 && Convert.ToInt32(dtChk.Rows[0]["cnt"]) > 0)
                    { ShowModalError("Cannot change code: a programme with code '" + progcode + "' already exists."); return; }

                    // Atomic cascade rename of the code across EVERY linked table/database
                    // (students, results, fees, timetables, allocations, registrations, …).
                    // All-or-nothing: the SP rolls back on any error and audits the change.
                    RenameProgrammeCode(original, progcode);
                }

                // After a rename the row now carries the new code; key the field update on it.
                string keyCode = codeChanged ? progcode : original;
                ExecuteNonQuery(@"
                    UPDATE acad_programme SET
                        progname=@name, abbrev=@abbrev, mincredit=@mincredit,
                        couselength=@dur, maxduration=@maxdur,
                        faculty_code=@faculty, department_id=@dept, levelCode=@level,
                        study_system=@study, is_fully_set=@fully
                    WHERE progcode=@code",
                    new MySqlParameter("@name",    progname),
                    new MySqlParameter("@abbrev",  abbrev),
                    new MySqlParameter("@mincredit", minCredit),
                    new MySqlParameter("@dur",     duration),
                    new MySqlParameter("@maxdur",  maxDur),
                    new MySqlParameter("@faculty", faculty),
                    new MySqlParameter("@dept",    deptParam),
                    new MySqlParameter("@level",   level),
                    new MySqlParameter("@study",   studySys),
                    new MySqlParameter("@fully",   isFullySet),
                    new MySqlParameter("@code",    keyCode));

                BindGrid();
                ResetModal();
                string okMsg = codeChanged
                    ? "Programme updated. Code changed from " + original + " to " + progcode + " across all linked records."
                    : "Programme updated successfully.";
                ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                    "closeProgModal();showToast('" + HttpUtility.JavaScriptStringEncode(okMsg) + "','success');", true);
            }
        }
        catch (Exception ex)
        {
            ShowModalError("Error saving programme: " + ex.Message);
        }
    }

    private void LoadForEdit(string progcode)
    {
        if (string.IsNullOrEmpty(progcode)) return;

        DataTable dt = ExecuteQuery(
            "SELECT * FROM acad_programme WHERE progcode=@code",
            new MySqlParameter("@code", progcode));

        if (dt.Rows.Count == 0) return;

        DataRow r = dt.Rows[0];

        txtProgcode.Text    = r["progcode"].ToString();
        txtProgname.Text    = r["progname"].ToString();
        txtAbbrev.Text      = r["abbrev"] != DBNull.Value ? r["abbrev"].ToString() : "";
        txtMinCredit.Text   = r["mincredit"] != DBNull.Value ? r["mincredit"].ToString() : "";
        txtMaxDuration.Text = r["maxduration"] != DBNull.Value ? r["maxduration"].ToString() : "";

        string facCode = r["faculty_code"] != DBNull.Value ? r["faculty_code"].ToString().Trim() : "";
        string deptId  = r.Table.Columns.Contains("department_id") && r["department_id"] != DBNull.Value ? r["department_id"].ToString().Trim() : "";

        // Server-side selection (fallback) …
        TrySelect(ddlFaculty,     facCode);
        TrySelect(ddlDepartment,  deptId);
        TrySelect(ddlLevel,       r["levelCode"] != DBNull.Value ? r["levelCode"].ToString() : "");
        TrySelect(ddlDuration,    r["couselength"] != DBNull.Value ? r["couselength"].ToString() : "");
        TrySelect(ddlStudySystem, r["study_system"] != DBNull.Value ? r["study_system"].ToString() : "");
        TrySelect(ddlFullySet,    r["is_fully_set"] != DBNull.Value ? r["is_fully_set"].ToString() : "No");

        hdnModalMode.Value = "EDIT";

        // … and pass Faculty + Department to the client so the modal shows them reliably.
        ScriptManager.RegisterStartupScript(this, GetType(), "openEdit",
            "openProgModal('EDIT','" + HttpUtility.JavaScriptStringEncode(progcode) + "','"
                + HttpUtility.JavaScriptStringEncode(facCode) + "','"
                + HttpUtility.JavaScriptStringEncode(deptId) + "');", true);
    }

    private void TrySelect(DropDownList ddl, string value)
    {
        ddl.ClearSelection();
        ListItem item = ddl.Items.FindByValue(value);
        if (item != null)
            item.Selected = true;
    }


    // ---------------------------------------------------------------
    // Programme Structure popup
    // ---------------------------------------------------------------
    protected void btnOpenStructure_Click(object sender, EventArgs e)
    {
        string code = hdnStructureCode.Value.Trim();
        if (string.IsNullOrEmpty(code)) return;

        DataTable dt = ExecuteQuery(
            "SELECT progcode, progname FROM acad_programme WHERE progcode=@code",
            new MySqlParameter("@code", code));

        if (dt.Rows.Count == 0) return;

        string name = dt.Rows[0]["progname"].ToString();
        Session["prog"]     = code;
        Session["progname"] = name;

        popStructure.HeaderText = "Programme Structure: " + name + " [" + code + "]";
        popStructure.ContentUrl = ResolveUrl("~/COOPERP/Faculty/ProgrammeStructure.aspx");
        popStructure.ShowOnPageLoad = true;

        BindGrid();
    }

    // ---------------------------------------------------------------
    // Programme Courses — Load / Add / Delete
    // ---------------------------------------------------------------
    protected void btnLoadCourses_Click(object sender, EventArgs e)
    {
        string progcode = hdnCourseProgcode.Value.Trim();
        if (string.IsNullOrEmpty(progcode)) return;

        DataTable dtProg = ExecuteQuery(
            "SELECT progname FROM acad_programme WHERE progcode=@code",
            new MySqlParameter("@code", progcode));
        string progname = dtProg.Rows.Count > 0 ? dtProg.Rows[0]["progname"].ToString() : progcode;

        BuildCoursesTable(progcode);
        BindGrid();

        string courseJs = BuildCoursesJsArray();
        ScriptManager.RegisterStartupScript(this, GetType(), "openCM",
            courseJs + "openCourseModal('" + HttpUtility.JavaScriptStringEncode(progcode) +
            "','" + HttpUtility.JavaScriptStringEncode(progname) + "');", true);
    }

    protected void btnSaveCourse_Click(object sender, EventArgs e)
    {
        string progcode = hdnCourseProgcode.Value.Trim();
        string courseCode = hdnSelectedCourse.Value.Trim().ToUpper();
        string yearStr = Request.Form[ddlCourseYear.UniqueID] ?? "1";
        string semStr = Request.Form[ddlCourseSem.UniqueID] ?? "1";

        if (string.IsNullOrEmpty(progcode))
        { ShowCourseModalError("No programme selected."); return; }
        if (string.IsNullOrEmpty(courseCode))
        { ShowCourseModalError("Please search and select a course first."); return; }

        int year = 1, sem = 1;
        int.TryParse(yearStr, out year);
        int.TryParse(semStr, out sem);

        // Check course exists in acad_course
        DataTable dtExists = ExecuteQuery(
            "SELECT COUNT(*) AS cnt FROM acad_course WHERE courseID=@c",
            new MySqlParameter("@c", courseCode));
        if (dtExists.Rows.Count == 0 || Convert.ToInt32(dtExists.Rows[0]["cnt"]) == 0)
        { ShowCourseModalError("Course code '" + courseCode + "' does not exist in the system."); return; }

        // Check duplicate
        DataTable dtDup = ExecuteQuery(
            "SELECT COUNT(*) AS cnt FROM acad_programmecourses WHERE progcode=@p AND course_code=@c AND study_year=@y AND semester=@s",
            new MySqlParameter("@p", progcode),
            new MySqlParameter("@c", courseCode),
            new MySqlParameter("@y", year),
            new MySqlParameter("@s", sem));
        if (dtDup.Rows.Count > 0 && Convert.ToInt32(dtDup.Rows[0]["cnt"]) > 0)
        { ShowCourseModalError("This course is already assigned to Year " + year + ", Semester " + sem + "."); return; }

        try
        {
            ExecuteNonQuery(@"
                INSERT INTO acad_programmecourses (progcode, course_code, study_year, semester)
                VALUES (@p, @c, @y, @s)",
                new MySqlParameter("@p", progcode),
                new MySqlParameter("@c", courseCode),
                new MySqlParameter("@y", year),
                new MySqlParameter("@s", sem));

            hdnSelectedCourse.Value = "";
            BuildCoursesTable(progcode);
            BindGrid();

            DataTable dtPn = ExecuteQuery("SELECT progname FROM acad_programme WHERE progcode=@code",
                new MySqlParameter("@code", progcode));
            string pn = dtPn.Rows.Count > 0 ? dtPn.Rows[0]["progname"].ToString() : progcode;
            string js = BuildCoursesJsArray() +
                "openCourseModal('" + HttpUtility.JavaScriptStringEncode(progcode) +
                "','" + HttpUtility.JavaScriptStringEncode(pn) + "');" +
                "showToast('Course added successfully.','success');clearCourseSearch();";
            ScriptManager.RegisterStartupScript(this, GetType(), "courseAdded", js, true);
        }
        catch (Exception ex)
        {
            ShowCourseModalError("Error adding course: " + ex.Message);
        }
    }

    protected void btnDeleteCourse_Click(object sender, EventArgs e)
    {
        string idStr = hdnDeleteCourseId.Value.Trim();
        string progcode = hdnCourseProgcode.Value.Trim();

        int id = 0;
        if (!int.TryParse(idStr, out id) || id <= 0) return;

        try
        {
            ExecuteNonQuery("DELETE FROM acad_programmecourses WHERE ID=@id",
                new MySqlParameter("@id", id));

            BuildCoursesTable(progcode);
            BindGrid();

            DataTable dtPn = ExecuteQuery("SELECT progname FROM acad_programme WHERE progcode=@code",
                new MySqlParameter("@code", progcode));
            string pn = dtPn.Rows.Count > 0 ? dtPn.Rows[0]["progname"].ToString() : progcode;
            string js = BuildCoursesJsArray() +
                "openCourseModal('" + HttpUtility.JavaScriptStringEncode(progcode) +
                "','" + HttpUtility.JavaScriptStringEncode(pn) + "');" +
                "showToast('Course removed.','danger');";
            ScriptManager.RegisterStartupScript(this, GetType(), "courseDel", js, true);
        }
        catch (Exception ex)
        {
            ShowCourseModalError("Error removing course: " + ex.Message);
        }
    }

    private void BuildCoursesTable(string progcode)
    {
        DataTable dt = ExecuteQuery(@"
            SELECT pc.ID, pc.course_code, c.courseName AS course_name,
                   pc.study_year, pc.semester
            FROM acad_programmecourses pc
            INNER JOIN acad_course c ON pc.course_code = c.courseID
            WHERE pc.progcode = @prog
            ORDER BY pc.study_year ASC, pc.semester ASC, c.courseName ASC",
            new MySqlParameter("@prog", progcode));

        StringBuilder sb = new StringBuilder();
        if (dt.Rows.Count == 0)
        {
            sb.Append("<div class='pc-empty'>No courses assigned to this programme yet. Use the form above to add courses.</div>");
        }
        else
        {
            sb.AppendFormat("<div class='pc-count'>Showing <strong>{0}</strong> course(s)</div>", dt.Rows.Count);
            sb.Append("<div class='pc-table-wrap'><table class='pc-table'>");
            sb.Append("<thead><tr><th>#</th><th>Course Code</th><th>Course Name</th><th style='text-align:center;'>Year</th><th style='text-align:center;'>Sem</th><th style='width:40px;'></th></tr></thead>");
            sb.Append("<tbody>");
            int n = 0;
            foreach (DataRow r in dt.Rows)
            {
                n++;
                sb.AppendFormat("<tr><td style='color:#999;'>{0}</td>", n);
                sb.AppendFormat("<td><strong>{0}</strong></td>", HttpUtility.HtmlEncode(r["course_code"].ToString()));
                sb.AppendFormat("<td>{0}</td>", HttpUtility.HtmlEncode(r["course_name"].ToString()));
                sb.AppendFormat("<td style='text-align:center;'>{0}</td>", r["study_year"]);
                sb.AppendFormat("<td style='text-align:center;'>{0}</td>", r["semester"]);
                sb.AppendFormat("<td style='text-align:center;'><button type='button' class='pc-remove-btn' onclick=\"removeCourse({0})\" title='Remove'>&#10005;</button></td>", r["ID"]);
                sb.Append("</tr>");
            }
            sb.Append("</tbody></table></div>");
        }
        litCoursesTable.Text = sb.ToString();
    }

    private string BuildCoursesJsArray()
    {
        DataTable dt = ExecuteQuery("SELECT courseID, courseName FROM acad_course ORDER BY courseName");
        StringBuilder sb = new StringBuilder("window.__courses=[");
        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (i > 0) sb.Append(",");
            sb.AppendFormat("{{c:'{0}',n:'{1}'}}",
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["courseID"].ToString()),
                HttpUtility.JavaScriptStringEncode(dt.Rows[i]["courseName"].ToString()));
        }
        sb.Append("];");
        return sb.ToString();
    }

    private void ShowCourseModalError(string msg)
    {
        string progcode = hdnCourseProgcode.Value.Trim();
        BuildCoursesTable(progcode);
        BindGrid();

        DataTable dtPn = ExecuteQuery("SELECT progname FROM acad_programme WHERE progcode=@code",
            new MySqlParameter("@code", progcode));
        string pn = dtPn.Rows.Count > 0 ? dtPn.Rows[0]["progname"].ToString() : progcode;

        string js = BuildCoursesJsArray() +
            "openCourseModal('" + HttpUtility.JavaScriptStringEncode(progcode) +
            "','" + HttpUtility.JavaScriptStringEncode(pn) + "');" +
            "(function(){var r=document.getElementById('courseModalResult');" +
            "r.className='form-result error';r.style.display='block';" +
            "r.textContent=" + Newtonsoft_JsonEncode(msg) + ";})();";
        ScriptManager.RegisterStartupScript(this, GetType(), "crsErr", js, true);
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------
    private void ShowModalError(string message)
    {
        BindGrid();
        string js = "(function(){" +
            "document.getElementById('progModal').style.display='flex';" +
            "var r=document.getElementById('modalResult');" +
            "r.className='form-result error';r.style.display='block';" +
            "r.textContent=" + Newtonsoft_JsonEncode(message) + ";})();";
        ScriptManager.RegisterStartupScript(this, GetType(), "modErr", js, true);
    }

    private static string Newtonsoft_JsonEncode(string s)
    {
        // Simple JS string literal encoder
        return "'" + s.Replace("\\","\\\\").Replace("'","\\'").Replace("\r","").Replace("\n","\\n") + "'";
    }

    private void ResetModal()
    {
        txtProgcode.Text    = "";
        txtProgname.Text    = "";
        txtAbbrev.Text      = "";
        txtMinCredit.Text   = "";
        txtMaxDuration.Text = "";
        ddlFaculty.SelectedIndex     = 0;
        ddlLevel.SelectedIndex       = 0;
        ddlDuration.SelectedIndex    = 0;
        ddlStudySystem.SelectedIndex = 0;
        ddlFullySet.SelectedIndex    = 0;
        hdnModalMode.Value    = "";
        hdnEditProgcode.Value = "";
    }
}
