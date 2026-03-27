using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
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

    // ---------------------------------------------------------------
    protected void Page_Load(object sender, EventArgs e)
    {
        // Always reload faculty items — they aren't in ViewState.
        // Do this before event handlers fire so SelectedValue resolves correctly.
        LoadFacultyDropdown();
        string postedFaculty = Request.Form[ddlFaculty.UniqueID];
        if (!string.IsNullOrEmpty(postedFaculty))
            TrySelect(ddlFaculty, postedFaculty);

        if (!IsPostBack)
        {
            EnsureColumns();
            BindGrid();
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

    private void BindGrid()
    {
        string sql = @"
            SELECT p.progcode, p.progname,
                   IFNULL(p.abbrev,'') AS abbrev,
                   IFNULL(p.couselength,0) AS couselength,
                   IFNULL(p.maxduration,0) AS maxduration,
                   IFNULL(p.mincredit,0) AS mincredit,
                   IFNULL(p.faculty_code,'') AS faculty_code,
                   IFNULL(f.faculty_name,'') AS faculty_name,
                   IFNULL(p.levelCode,0) AS levelCode,
                   IFNULL(p.study_system,'') AS study_system,
                   IFNULL(p.is_fully_set,'No') AS is_fully_set,
                   IFNULL(s.spec_count,0) AS spec_count,
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
            LEFT JOIN (SELECT prog_id, COUNT(*) AS spec_count FROM acad_specialisation GROUP BY prog_id) s
                   ON p.progcode = s.prog_id
            ORDER BY p.progname";

        DataTable dt = ExecuteQuery(sql);
        gvMain.DataSource = dt;
        gvMain.DataBind();
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
                         faculty_code, levelCode, study_system, is_fully_set)
                    VALUES (@code, @name, @abbrev, @mincredit, @dur, @maxdur,
                            @faculty, @level, @study, @fully)",
                    new MySqlParameter("@code",    progcode),
                    new MySqlParameter("@name",    progname),
                    new MySqlParameter("@abbrev",  abbrev),
                    new MySqlParameter("@mincredit", minCredit),
                    new MySqlParameter("@dur",     duration),
                    new MySqlParameter("@maxdur",  maxDur),
                    new MySqlParameter("@faculty", faculty),
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
                ExecuteNonQuery(@"
                    UPDATE acad_programme SET
                        progname=@name, abbrev=@abbrev, mincredit=@mincredit,
                        couselength=@dur, maxduration=@maxdur,
                        faculty_code=@faculty, levelCode=@level,
                        study_system=@study, is_fully_set=@fully
                    WHERE progcode=@code",
                    new MySqlParameter("@name",    progname),
                    new MySqlParameter("@abbrev",  abbrev),
                    new MySqlParameter("@mincredit", minCredit),
                    new MySqlParameter("@dur",     duration),
                    new MySqlParameter("@maxdur",  maxDur),
                    new MySqlParameter("@faculty", faculty),
                    new MySqlParameter("@level",   level),
                    new MySqlParameter("@study",   studySys),
                    new MySqlParameter("@fully",   isFullySet),
                    new MySqlParameter("@code",    original));

                BindGrid();
                ResetModal();
                ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                    "closeProgModal();showToast('Programme updated successfully.','success');", true);
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

        TrySelect(ddlFaculty,     r["faculty_code"] != DBNull.Value ? r["faculty_code"].ToString() : "");
        TrySelect(ddlLevel,       r["levelCode"] != DBNull.Value ? r["levelCode"].ToString() : "");
        TrySelect(ddlDuration,    r["couselength"] != DBNull.Value ? r["couselength"].ToString() : "");
        TrySelect(ddlStudySystem, r["study_system"] != DBNull.Value ? r["study_system"].ToString() : "");
        TrySelect(ddlFullySet,    r["is_fully_set"] != DBNull.Value ? r["is_fully_set"].ToString() : "No");

        hdnModalMode.Value = "EDIT";

        BindGrid(); // keep grid fresh
        ScriptManager.RegisterStartupScript(this, GetType(), "openEdit",
            "openProgModal('EDIT','" + HttpUtility.JavaScriptStringEncode(progcode) + "');", true);
    }

    private void TrySelect(DropDownList ddl, string value)
    {
        ListItem item = ddl.Items.FindByValue(value);
        if (item != null) item.Selected = true;
    }

    // ---------------------------------------------------------------
    // Delete
    // ---------------------------------------------------------------
    protected void btnDeleteProgramme_Click(object sender, EventArgs e)
    {
        string progcode = hdnEditProgcode.Value.Trim();
        if (string.IsNullOrEmpty(progcode)) return;

        try
        {
            // Delete specialisations first (FK constraint)
            ExecuteNonQuery("DELETE FROM acad_specialisation WHERE prog_id=@code",
                new MySqlParameter("@code", progcode));
            ExecuteNonQuery("DELETE FROM acad_programme WHERE progcode=@code",
                new MySqlParameter("@code", progcode));

            BindGrid();
            ScriptManager.RegisterStartupScript(this, GetType(), "deleted",
                "showToast('Programme deleted.','danger');", true);
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "delerr",
                "showToast('Delete failed: " + HttpUtility.JavaScriptStringEncode(ex.Message) + "','danger');", true);
        }
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
