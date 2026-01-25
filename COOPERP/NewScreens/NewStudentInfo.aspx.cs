using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_NewStudentInfo : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilters();
        }
        // Always bind data (DevExpress grids need rebind on postback too for callbacks)
        BindStudentsGrid();
    }
    
    private void BindStudentsGrid()
    {
        gvStudents.DataSource = GetStudentsData();
        gvStudents.DataBind();
    }
    
    #region Filters Loading
    
    private void LoadFilters()
    {
        LoadFaculties();
        LoadEntryYears();
        LoadSessions();
    }
    
    private void LoadFaculties()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFilterFaculty.Items.Add(new ListItem(
                                reader["faculty_name"].ToString(),
                                reader["faculty_code"].ToString()
                            ));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadProgrammes(string facultyCode)
    {
        ddlFilterProgramme.Items.Clear();
        ddlFilterProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
        
        if (string.IsNullOrEmpty(facultyCode)) return;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT progcode, progname FROM acad_programme WHERE faculty_code = @faculty ORDER BY progname", conn))
                {
                    cmd.Parameters.AddWithValue("@faculty", facultyCode);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFilterProgramme.Items.Add(new ListItem(
                                reader["progname"].ToString(),
                                reader["progcode"].ToString()
                            ));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadEntryYears()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT DISTINCT entryyear FROM acad_student WHERE entryyear IS NOT NULL ORDER BY entryyear DESC", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string year = reader["entryyear"].ToString();
                            if (!string.IsNullOrEmpty(year))
                            {
                                ddlFilterEntryYear.Items.Add(new ListItem(year, year));
                            }
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadSessions()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT Session FROM acad_studysessions ORDER BY Session", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string session = reader["Session"].ToString();
                            ddlFilterSession.Items.Add(new ListItem(session, session));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    #endregion
    
    #region Data Loading
    
    private DataTable GetStudentsData()
    {
        DataTable dt = new DataTable();
        try
        {
            string sql = @"SELECT s.regno, s.entryno, s.firstname, s.othername, s.gender, s.dob, 
                           s.nationality, s.religion, s.studPhone, s.email, s.home_dist, 
                           s.progid, p.progname, s.specialisation, s.entryyear, s.intake, 
                           s.studsesion, s.studCampus, s.gradSystemID, s.photofile
                           FROM acad_student s
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           WHERE 1=1 ";
            
            // Apply filters
            if (!string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue))
            {
                sql += " AND s.progid = @progid ";
            }
            else if (!string.IsNullOrEmpty(ddlFilterFaculty.SelectedValue))
            {
                sql += " AND p.faculty_code = @faculty ";
            }
            
            if (!string.IsNullOrEmpty(ddlFilterEntryYear.SelectedValue))
            {
                sql += " AND s.entryyear = @entryyear ";
            }
            
            if (!string.IsNullOrEmpty(ddlFilterSession.SelectedValue))
            {
                sql += " AND s.studsesion = @session ";
            }
            
            sql += " ORDER BY s.entryyear DESC, s.firstname, s.othername";
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlFilterProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@progid", ddlFilterProgramme.SelectedValue);
                    
                    if (!string.IsNullOrEmpty(ddlFilterFaculty.SelectedValue))
                        cmd.Parameters.AddWithValue("@faculty", ddlFilterFaculty.SelectedValue);
                    
                    if (!string.IsNullOrEmpty(ddlFilterEntryYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@entryyear", int.Parse(ddlFilterEntryYear.SelectedValue));
                    
                    if (!string.IsNullOrEmpty(ddlFilterSession.SelectedValue))
                        cmd.Parameters.AddWithValue("@session", ddlFilterSession.SelectedValue);
                    
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading students: " + ex.Message);
        }
        return dt;
    }
    
    #endregion
    
    #region Filter Events
    
    protected void ddlFilterFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes(ddlFilterFaculty.SelectedValue);
    }
    
    protected void ddlFilterProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Grid will rebind automatically via Page_Load
    }
    
    protected void ddlFilterEntryYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Grid will rebind automatically via Page_Load
    }
    
    protected void ddlFilterSession_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Grid will rebind automatically via Page_Load
    }
    
    #endregion
    
    #region Grid Events
    
    protected void gvStudents_RowUpdating(object sender, DevExpress.Web.Data.ASPxDataUpdatingEventArgs e)
    {
        try
        {
            string sql = @"UPDATE acad_student SET 
                           firstname=@firstname, othername=@othername, gender=@gender, 
                           dob=@dob, nationality=@nationality, religion=@religion,
                           studPhone=@phone, email=@email, home_dist=@district,
                           progid=@progid, specialisation=@spec, entryyear=@entryyear,
                           intake=@intake, studsesion=@session, studCampus=@campus,
                           gradSystemID=@gradsystem
                           WHERE regno=@regno";
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", e.Keys["regno"]);
                    cmd.Parameters.AddWithValue("@firstname", e.NewValues["firstname"] ?? "");
                    cmd.Parameters.AddWithValue("@othername", e.NewValues["othername"] ?? "");
                    cmd.Parameters.AddWithValue("@gender", e.NewValues["gender"] ?? "");
                    cmd.Parameters.AddWithValue("@dob", e.NewValues["dob"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@nationality", e.NewValues["nationality"] ?? "");
                    cmd.Parameters.AddWithValue("@religion", e.NewValues["religion"] ?? "");
                    cmd.Parameters.AddWithValue("@phone", e.NewValues["studPhone"] ?? "");
                    cmd.Parameters.AddWithValue("@email", e.NewValues["email"] ?? "");
                    cmd.Parameters.AddWithValue("@district", e.NewValues["home_dist"] ?? "");
                    cmd.Parameters.AddWithValue("@progid", e.NewValues["progid"] ?? "");
                    cmd.Parameters.AddWithValue("@spec", e.NewValues["specialisation"] ?? "");
                    cmd.Parameters.AddWithValue("@entryyear", e.NewValues["entryyear"] ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@intake", e.NewValues["intake"] ?? "");
                    cmd.Parameters.AddWithValue("@session", e.NewValues["studsesion"] ?? "");
                    cmd.Parameters.AddWithValue("@campus", e.NewValues["studCampus"] ?? "");
                    cmd.Parameters.AddWithValue("@gradsystem", e.NewValues["gradSystemID"] ?? "");
                    
                    cmd.ExecuteNonQuery();
                }
            }
            
            e.Cancel = true;
            gvStudents.CancelEdit();
            BindStudentsGrid();
        }
        catch (Exception ex)
        {
            e.Cancel = true;
            throw new Exception("Error updating student: " + ex.Message);
        }
    }
    
    protected void gvStudents_RowDeleting(object sender, DevExpress.Web.Data.ASPxDataDeletingEventArgs e)
    {
        // Delete not allowed
        e.Cancel = true;
    }
    
    #endregion
}
