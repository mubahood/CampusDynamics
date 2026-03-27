using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_NewProgrammeCourses : System.Web.UI.Page
{
    private string ConnStr
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

    // ---------------------------------------------------------------
    // Page Load
    // ---------------------------------------------------------------
    protected void Page_Load(object sender, EventArgs e)
    {
        // Always reload dropdowns (they are not in ViewState)
        LoadProgrammes();
        LoadSpecialisations();

        // Restore posted values
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

        BindGrid();
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
        // Load ALL specialisations; client-side JS filters by programme
        DataTable dt = ExecuteQuery(
            "SELECT spec_id, prog_id, spec FROM acad_specialisation WHERE spec != '-' ORDER BY spec");
        ddlSpecialisation.Items.Clear();
        ddlSpecialisation.Items.Add(new ListItem("-- Select Specialisation --", ""));
        foreach (DataRow r in dt.Rows)
            ddlSpecialisation.Items.Add(new ListItem(r["spec"].ToString(), r["spec_id"].ToString()));
    }

    private void BindGrid()
    {
        string sql = @"
            SELECT pc.ID, pc.progcode, p.progname,
                   pc.course_code, c.courseName, IFNULL(c.CreditUnit,0) AS CreditUnit,
                   pc.study_year, pc.semester,
                   IFNULL(pc.specialisation_id,0) AS specialisation_id,
                   IFNULL(sp.spec,'') AS spec_name,
                   IFNULL(pc.course_type,'CORE') AS course_type
            FROM acad_programmecourses pc
            LEFT JOIN acad_programme p ON pc.progcode = p.progcode
            LEFT JOIN acad_course c ON pc.course_code = c.courseID
            LEFT JOIN acad_specialisation sp ON pc.specialisation_id = sp.spec_id
            ORDER BY p.progname, pc.study_year, pc.semester, c.courseName";
        DataTable dt = ExecuteQuery(sql);
        gvMain.DataSource = dt;
        gvMain.DataBind();
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

    // ---------------------------------------------------------------
    // Save (Insert or Update)
    // ---------------------------------------------------------------
    protected void btnSave_Click(object sender, EventArgs e)
    {
        string mode = hdnModalMode.Value.Trim().ToUpper();
        string progcode   = Request.Form[ddlProgramme.UniqueID] ?? "";
        string specIdStr  = Request.Form[ddlSpecialisation.UniqueID] ?? "0";
        string courseCode = hdnSelectedCourse.Value.Trim();
        string yearStr    = Request.Form[ddlYear.UniqueID] ?? "1";
        string semStr     = Request.Form[ddlSemester.UniqueID] ?? "1";
        string courseType = Request.Form[ddlCourseType.UniqueID] ?? "CORE";

        if (string.IsNullOrEmpty(progcode))
        { ShowModalError("Please select a Programme."); return; }
        if (string.IsNullOrEmpty(specIdStr) || specIdStr == "0" || specIdStr == "")
        {
            // Try the dropdown value as fallback
            specIdStr = ddlSpecialisation.SelectedValue;
            if (string.IsNullOrEmpty(specIdStr) || specIdStr == "")
            { ShowModalError("Please select a Specialisation."); return; }
        }
        if (string.IsNullOrEmpty(courseCode))
        { ShowModalError("Please search and select a Course."); return; }

        int specId = 0; int.TryParse(specIdStr, out specId);
        int year = 1; int.TryParse(yearStr, out year);
        int sem = 1; int.TryParse(semStr, out sem);

        // Check course exists
        DataTable dtC = ExecuteQuery("SELECT COUNT(*) AS cnt FROM acad_course WHERE courseID=@c",
            new MySqlParameter("@c", courseCode));
        if (dtC.Rows.Count == 0 || Convert.ToInt32(dtC.Rows[0]["cnt"]) == 0)
        { ShowModalError("Course '" + courseCode + "' does not exist."); return; }

        try
        {
            if (mode == "EDIT")
            {
                int editId = 0;
                int.TryParse(hdnEditId.Value.Trim(), out editId);
                if (editId <= 0)
                { ShowModalError("Invalid record ID."); return; }

                // Duplicate check (exclude self)
                DataTable dtDup = ExecuteQuery(
                    @"SELECT COUNT(*) AS cnt FROM acad_programmecourses
                      WHERE progcode=@p AND course_code=@c AND specialisation_id=@sp
                        AND study_year=@y AND semester=@s AND ID!=@id",
                    new MySqlParameter("@p", progcode),
                    new MySqlParameter("@c", courseCode),
                    new MySqlParameter("@sp", specId),
                    new MySqlParameter("@y", year),
                    new MySqlParameter("@s", sem),
                    new MySqlParameter("@id", editId));
                if (dtDup.Rows.Count > 0 && Convert.ToInt32(dtDup.Rows[0]["cnt"]) > 0)
                { ShowModalError("This exact course assignment already exists."); return; }

                ExecuteNonQuery(
                    @"UPDATE acad_programmecourses SET
                        progcode=@p, course_code=@c, specialisation_id=@sp,
                        study_year=@y, semester=@s, course_type=@t
                      WHERE ID=@id",
                    new MySqlParameter("@p", progcode),
                    new MySqlParameter("@c", courseCode),
                    new MySqlParameter("@sp", specId),
                    new MySqlParameter("@y", year),
                    new MySqlParameter("@s", sem),
                    new MySqlParameter("@t", courseType),
                    new MySqlParameter("@id", editId));

                BindGrid();
                hdnSelectedCourse.Value = "";
                ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                    "closeModal();showToast('Course assignment updated.','success');", true);
            }
            else // NEW
            {
                // Duplicate check
                DataTable dtDup = ExecuteQuery(
                    @"SELECT COUNT(*) AS cnt FROM acad_programmecourses
                      WHERE progcode=@p AND course_code=@c AND specialisation_id=@sp
                        AND study_year=@y AND semester=@s",
                    new MySqlParameter("@p", progcode),
                    new MySqlParameter("@c", courseCode),
                    new MySqlParameter("@sp", specId),
                    new MySqlParameter("@y", year),
                    new MySqlParameter("@s", sem));
                if (dtDup.Rows.Count > 0 && Convert.ToInt32(dtDup.Rows[0]["cnt"]) > 0)
                { ShowModalError("This course is already assigned to this programme/specialisation/year/semester."); return; }

                ExecuteNonQuery(
                    @"INSERT INTO acad_programmecourses
                        (progcode, course_code, study_year, semester, CurriculumID, specialisation_id, course_type)
                      VALUES (@p, @c, @y, @s, 0, @sp, @t)",
                    new MySqlParameter("@p", progcode),
                    new MySqlParameter("@c", courseCode),
                    new MySqlParameter("@y", year),
                    new MySqlParameter("@s", sem),
                    new MySqlParameter("@sp", specId),
                    new MySqlParameter("@t", courseType));

                BindGrid();
                hdnSelectedCourse.Value = "";
                ScriptManager.RegisterStartupScript(this, GetType(), "saved",
                    "closeModal();showToast('Course added successfully.','success');", true);
            }
        }
        catch (Exception ex)
        {
            ShowModalError("Error: " + ex.Message);
        }
    }

    // ---------------------------------------------------------------
    // Load for Edit
    // ---------------------------------------------------------------
    protected void btnLoadEdit_Click(object sender, EventArgs e)
    {
        string idStr = hdnEditId.Value.Trim();
        int id = 0;
        if (!int.TryParse(idStr, out id) || id <= 0) return;

        DataTable dt = ExecuteQuery(
            @"SELECT pc.ID, pc.progcode, pc.course_code, c.courseName,
                     pc.study_year, pc.semester, pc.specialisation_id,
                     IFNULL(pc.course_type,'CORE') AS course_type
              FROM acad_programmecourses pc
              LEFT JOIN acad_course c ON pc.course_code = c.courseID
              WHERE pc.ID=@id",
            new MySqlParameter("@id", id));

        if (dt.Rows.Count == 0) return;

        DataRow r = dt.Rows[0];
        string progcode   = r["progcode"].ToString();
        string courseCode  = r["course_code"].ToString();
        string courseName  = r["courseName"] != DBNull.Value ? r["courseName"].ToString() : courseCode;
        string specId      = r["specialisation_id"] != DBNull.Value ? r["specialisation_id"].ToString() : "0";
        string studyYear   = r["study_year"].ToString();
        string semester    = r["semester"].ToString();
        string courseType  = r["course_type"].ToString();

        TrySelect(ddlProgramme, progcode);
        TrySelect(ddlSpecialisation, specId);
        TrySelect(ddlYear, studyYear);
        TrySelect(ddlSemester, semester);
        TrySelect(ddlCourseType, courseType);
        hdnSelectedCourse.Value = courseCode;
        hdnModalMode.Value = "EDIT";

        BindGrid();

        // Build JS to open the modal with pre-selected values
        string js = "openModal('EDIT','" + id + "');" +
            "setTimeout(function(){" +
            "sdSetValue('prog'," + JsEncode(progcode) + ");" +
            "sdSetData('spec',getSpecsForProg(" + JsEncode(progcode) + "));" +
            "sdSetValue('spec','" + HttpUtility.JavaScriptStringEncode(specId) + "');" +
            "document.getElementById('" + ddlYear.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(studyYear) + "';" +
            "document.getElementById('" + ddlSemester.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(semester) + "';" +
            "document.getElementById('" + ddlCourseType.ClientID + "').value=" + JsEncode(courseType) + ";" +
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
            BindGrid();
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
        BindGrid();

        // Restore dropdown posted values for the reopened modal
        string progcode  = Request.Form[ddlProgramme.UniqueID] ?? "";
        string specId    = Request.Form[ddlSpecialisation.UniqueID] ?? "";
        string yearVal   = Request.Form[ddlYear.UniqueID] ?? "1";
        string semVal    = Request.Form[ddlSemester.UniqueID] ?? "1";
        string typeVal   = Request.Form[ddlCourseType.UniqueID] ?? "CORE";
        string courseCode = hdnSelectedCourse.Value.Trim();
        string mode      = hdnModalMode.Value.Trim().ToUpper();

        // Look up course name if we have a code
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
        js.Append("sdSetValue('spec','" + HttpUtility.JavaScriptStringEncode(specId) + "');");
        js.Append("document.getElementById('" + ddlYear.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(yearVal) + "';");
        js.Append("document.getElementById('" + ddlSemester.ClientID + "').value='" + HttpUtility.JavaScriptStringEncode(semVal) + "';");
        js.Append("document.getElementById('" + ddlCourseType.ClientID + "').value=" + JsEncode(typeVal) + ";");
        if (!string.IsNullOrEmpty(courseCode))
            js.Append("selectCourse(" + JsEncode(courseCode) + "," + JsEncode(courseName) + ");");
        js.Append("var r=document.getElementById('modalResult');r.className='form-result error';r.style.display='block';");
        js.Append("r.textContent='" + HttpUtility.JavaScriptStringEncode(msg) + "';");
        js.Append("},50);");

        ScriptManager.RegisterStartupScript(this, GetType(), "modalErr", js.ToString(), true);
    }
}
