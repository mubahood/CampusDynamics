using System;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_NewCourses : Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        // GET listing endpoint: NewCourses.aspx?act=list returns the course catalogue
        // as JSON. The list renders client-side from this (no postback, with paging).
        if (!IsPostBack && string.Equals(Request.QueryString["act"], "list", StringComparison.OrdinalIgnoreCase))
        {
            EmitCoursesJson();
            return;
        }
    }

    // ---------------------------------------------------------------
    // GET endpoint — course catalogue as a JSON array.
    // ---------------------------------------------------------------
    private void EmitCoursesJson()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        try
        {
            DataTable dt = ExecuteQuery(
                "SELECT courseID, IFNULL(courseName,'') AS courseName, CreditUnit, ContactHr, LectureHr, " +
                "       PracticalHr, IFNULL(CoreStatus,'') AS CoreStatus, IFNULL(stat,'') AS stat, " +
                "       IFNULL(courseDescription,'') AS courseDescription " +
                "FROM acad_course WHERE courseID <> '' ORDER BY courseName");

            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                DataRow r = dt.Rows[i];
                if (i > 0) sb.Append(",");
                sb.Append("{")
                  .Append("\"code\":").Append(JS(r["courseID"].ToString().Trim())).Append(",")
                  .Append("\"name\":").Append(JS(r["courseName"].ToString())).Append(",")
                  .Append("\"credit\":").Append(Num(r["CreditUnit"])).Append(",")
                  .Append("\"contact\":").Append(Num(r["ContactHr"])).Append(",")
                  .Append("\"lecture\":").Append(Num(r["LectureHr"])).Append(",")
                  .Append("\"practical\":").Append(Num(r["PracticalHr"])).Append(",")
                  .Append("\"type\":").Append(JS(r["CoreStatus"].ToString().Trim())).Append(",")
                  .Append("\"stat\":").Append(JS(r["stat"].ToString().Trim())).Append(",")
                  .Append("\"description\":").Append(JS(r["courseDescription"].ToString()))
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

    // ---------------------------------------------------------------
    // Save (Insert or Update)
    // ---------------------------------------------------------------
    protected void btnSaveCourse_Click(object sender, EventArgs e)
    {
        string mode = (hdnModalMode.Value ?? "").Trim().ToUpper();

        string code = txtCourseId.Text.Trim();
        if (string.IsNullOrEmpty(code)) code = (Request.Form[txtCourseId.UniqueID] ?? "").Trim();
        string name = txtCourseName.Text.Trim();
        string type = ddlType.SelectedValue;
        string stat = ddlStatus.SelectedValue;
        string desc = txtDescription.Text.Trim();

        object credit    = ToDbDouble(txtCredit.Text);
        object contact   = ToDbDouble(txtContact.Text);
        object lecture   = ToDbDouble(txtLecture.Text);
        object practical = ToDbDouble(txtPractical.Text);

        if (string.IsNullOrEmpty(code))  { ToastError("Course Code is required."); return; }
        if (string.IsNullOrEmpty(name))  { ToastError("Course Name is required."); return; }

        try
        {
            if (mode == "NEW")
            {
                DataTable chk = ExecuteQuery(
                    "SELECT COUNT(*) AS cnt FROM acad_course WHERE courseID=@c",
                    new MySqlParameter("@c", code));
                if (Convert.ToInt32(chk.Rows[0]["cnt"]) > 0)
                { ToastError("A course with code '" + code + "' already exists."); return; }

                ExecuteNonQuery(@"
                    INSERT INTO acad_course
                        (courseID, courseName, CreditUnit, ContactHr, LectureHr, PracticalHr, CoreStatus, stat, courseDescription)
                    VALUES (@code, @name, @credit, @contact, @lecture, @practical, @type, @stat, @desc)",
                    new MySqlParameter("@code", code),
                    new MySqlParameter("@name", name),
                    new MySqlParameter("@credit", credit),
                    new MySqlParameter("@contact", contact),
                    new MySqlParameter("@lecture", lecture),
                    new MySqlParameter("@practical", practical),
                    new MySqlParameter("@type", string.IsNullOrEmpty(type) ? (object)"Core" : type),
                    new MySqlParameter("@stat", string.IsNullOrEmpty(stat) ? (object)"Active" : stat),
                    new MySqlParameter("@desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc));

                ToastSuccess("Course added successfully.");
            }
            else // EDIT
            {
                string original = (hdnEditCourseId.Value ?? "").Trim();
                if (string.IsNullOrEmpty(original)) original = code;

                ExecuteNonQuery(@"
                    UPDATE acad_course SET
                        courseName=@name, CreditUnit=@credit, ContactHr=@contact, LectureHr=@lecture,
                        PracticalHr=@practical, CoreStatus=@type, stat=@stat, courseDescription=@desc
                    WHERE courseID=@code",
                    new MySqlParameter("@name", name),
                    new MySqlParameter("@credit", credit),
                    new MySqlParameter("@contact", contact),
                    new MySqlParameter("@lecture", lecture),
                    new MySqlParameter("@practical", practical),
                    new MySqlParameter("@type", string.IsNullOrEmpty(type) ? (object)"Core" : type),
                    new MySqlParameter("@stat", string.IsNullOrEmpty(stat) ? (object)"Active" : stat),
                    new MySqlParameter("@desc", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc),
                    new MySqlParameter("@code", original));

                ToastSuccess("Course updated successfully.");
            }
        }
        catch (Exception ex)
        {
            ToastError("Error saving course: " + ex.Message);
        }
    }

    // ---------------------------------------------------------------
    // Delete
    // ---------------------------------------------------------------
    protected void btnDeleteCourse_Click(object sender, EventArgs e)
    {
        string code = (hdnEditCourseId.Value ?? "").Trim();
        if (string.IsNullOrEmpty(code)) return;
        try
        {
            ExecuteNonQuery("DELETE FROM acad_course WHERE courseID=@code",
                new MySqlParameter("@code", code));
            ToastSuccess("Course deleted.");
        }
        catch (Exception ex)
        {
            ToastError("Error deleting course: " + ex.Message);
        }
    }

    // ---------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------
    private void ToastSuccess(string msg)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "cbok",
            "cbToast('" + HttpUtility.JavaScriptStringEncode(msg) + "','success');", true);
    }
    private void ToastError(string msg)
    {
        // Re-open the modal so the user can correct input, and surface the error inside it.
        ScriptManager.RegisterStartupScript(this, GetType(), "cberr",
            "cbModalError('" + HttpUtility.JavaScriptStringEncode(msg) + "');" +
            "document.getElementById('courseModal').style.display='flex';", true);
    }

    private static object ToDbDouble(string s)
    {
        if (string.IsNullOrEmpty(s)) return DBNull.Value;
        double d;
        return double.TryParse(s.Trim(), out d) ? (object)d : (object)DBNull.Value;
    }

    // Numeric JSON token (null when the DB value is null/blank).
    private static string Num(object v)
    {
        if (v == null || v == DBNull.Value) return "null";
        double d;
        return double.TryParse(v.ToString(), out d)
            ? d.ToString(System.Globalization.CultureInfo.InvariantCulture)
            : "null";
    }

    private static string JS(string s) { return HttpUtility.JavaScriptStringEncode(s ?? "", true); }

    private DataTable ExecuteQuery(string sql, params MySqlParameter[] ps)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 30;
            if (ps != null) cmd.Parameters.AddRange(ps);
            conn.Open();
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                da.Fill(dt);
        }
        return dt;
    }

    private void ExecuteNonQuery(string sql, params MySqlParameter[] ps)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            cmd.CommandTimeout = 30;
            if (ps != null) cmd.Parameters.AddRange(ps);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
    }
}
