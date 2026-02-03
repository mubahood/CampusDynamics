using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.IO;

public partial class COOPERP_NewScreens_NewStudentInfo : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    // Status filter - can be set by query parameter or dropdown
    protected string StatusFilter
    {
        get
        {
            // First check ViewState (for postbacks)
            if (ViewState["StatusFilter"] != null)
                return ViewState["StatusFilter"].ToString();
            // Then check query string
            if (!string.IsNullOrEmpty(Request.QueryString["status"]))
                return Request.QueryString["status"].ToUpper();
            return "";
        }
        set { ViewState["StatusFilter"] = value; }
    }

    // Page title based on status
    protected string PageTitle
    {
        get
        {
            switch (StatusFilter)
            {
                case "ACTIVE": return "Active Students";
                case "ADMITTED": return "Admitted Students";
                case "ALUMNI": return "Alumni Students";
                case "ALL": return "All Students";
                default: return "Student Records";
            }
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle AJAX requests for batch operations
        string action = Request.QueryString["action"];
        if (!string.IsNullOrEmpty(action))
        {
            if (action == "PreviewBatchStatus")
            {
                HandlePreviewBatchStatus();
                return;
            }
            else if (action == "ApplyBatchStatus")
            {
                HandleApplyBatchStatus();
                return;
            }
        }
        
        if (!IsPostBack)
        {
            // Initialize status filter from query string
            if (!string.IsNullOrEmpty(Request.QueryString["status"]))
            {
                StatusFilter = Request.QueryString["status"].ToUpper();
                
                // Set the dropdown to match
                if (ddlFilterStatus.Items.FindByValue(StatusFilter) != null)
                    ddlFilterStatus.SelectedValue = StatusFilter;
            }
            
            LoadFilters();
            LoadBatchProgrammes(); // Load programmes for batch modal
            // Set default photo URL for JavaScript use
            hdnDefaultPhotoUrl.Value = ResolveUrl("~/COOPERP/StudentInfo/photos/default.png");
            
            // Update page header based on status
            if (litPageTitle != null)
                litPageTitle.Text = PageTitle;
        }
        // Always bind data (DevExpress grids need rebind on postback too for callbacks)
        BindStudentsGrid();
    }
    
    #region Batch Operations
    
    private void LoadBatchProgrammes()
    {
        try
        {
            ddlBatchProgramme.Items.Clear();
            ddlBatchProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT prog_code, prog_name FROM acad_programme ORDER BY prog_name", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlBatchProgramme.Items.Add(new ListItem(
                                reader["prog_name"].ToString(),
                                reader["prog_code"].ToString()
                            ));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void HandlePreviewBatchStatus()
    {
        Response.ContentType = "application/json";
        
        try
        {
            // Read JSON body
            string json;
            using (StreamReader reader = new StreamReader(Request.InputStream))
            {
                json = reader.ReadToEnd();
            }
            
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Dictionary<string, object> data = serializer.Deserialize<Dictionary<string, object>>(json);
            
            string conditionType = data["conditionType"].ToString();
            string targetStatus = data["targetStatus"].ToString();
            bool negate = data.ContainsKey("negate") && Convert.ToBoolean(data["negate"]);
            
            int count = GetBatchAffectedCount(conditionType, negate, data);
            
            Response.Write(serializer.Serialize(new { count = count }));
        }
        catch (Exception ex)
        {
            Response.Write("{\"count\": 0, \"error\": \"" + ex.Message.Replace("\"", "'") + "\"}");
        }
        Response.End();
    }
    
    private void HandleApplyBatchStatus()
    {
        Response.ContentType = "application/json";
        
        try
        {
            // Read JSON body
            string json;
            using (StreamReader reader = new StreamReader(Request.InputStream))
            {
                json = reader.ReadToEnd();
            }
            
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Dictionary<string, object> data = serializer.Deserialize<Dictionary<string, object>>(json);
            
            string conditionType = data["conditionType"].ToString();
            string targetStatus = data["targetStatus"].ToString();
            bool negate = data.ContainsKey("negate") && Convert.ToBoolean(data["negate"]);
            
            int updated = ApplyBatchStatusChange(conditionType, targetStatus, negate, data);
            
            Response.Write(serializer.Serialize(new { success = true, updated = updated }));
        }
        catch (Exception ex)
        {
            Response.Write("{\"success\": false, \"message\": \"" + ex.Message.Replace("\"", "'") + "\"}");
        }
        Response.End();
    }
    
    private int GetBatchAffectedCount(string conditionType, bool negate, Dictionary<string, object> data)
    {
        // For payment condition, we need a special query that joins with accounts DB
        if (conditionType == "payment")
        {
            return GetPaymentAffectedCount(negate, data);
        }
        
        string whereClause = BuildBatchWhereClause(conditionType, negate, data);
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT COUNT(*) FROM acad_student WHERE " + whereClause;
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddBatchParameters(cmd, conditionType, data);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }
    
    private int GetPaymentAffectedCount(bool negate, Dictionary<string, object> data)
    {
        int days = Convert.ToInt32(data["paymentDays"]);
        
        // Query the accounts database for students who made payments (CR transactions)
        // The fin_ledger table has accountcode which stores the student's regno
        // transactionType 'CR' = credit = payment received
        string accountsConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
            ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
            : "Server=localhost;Database=campus_dynamics_accounts;Uid=root;Pwd=24thdecember1977;";
        
        using (MySqlConnection conn = new MySqlConnection(accountsConnStr))
        {
            conn.Open();
            string sql;
            
            if (negate)
            {
                // Students who DID NOT pay in the period
                sql = @"SELECT COUNT(*) 
                        FROM campus_dynamics.acad_student s
                        WHERE s.regno NOT IN (
                            SELECT DISTINCT l.accountcode 
                            FROM fin_ledger l 
                            WHERE l.transactionType = 'CR' 
                            AND l.transactionDate >= DATE_SUB(CURDATE(), INTERVAL @days DAY)
                        )";
            }
            else
            {
                // Students who DID pay in the period
                sql = @"SELECT COUNT(DISTINCT s.regno) 
                        FROM campus_dynamics.acad_student s
                        INNER JOIN fin_ledger l ON l.accountcode = s.regno
                        WHERE l.transactionType = 'CR' 
                        AND l.transactionDate >= DATE_SUB(CURDATE(), INTERVAL @days DAY)";
            }
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@days", days);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }
    
    private int ApplyBatchStatusChange(string conditionType, string targetStatus, bool negate, Dictionary<string, object> data)
    {
        // For payment condition, we need a special approach
        if (conditionType == "payment")
        {
            return ApplyPaymentStatusChange(targetStatus, negate, data);
        }
        
        string whereClause = BuildBatchWhereClause(conditionType, negate, data);
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "UPDATE acad_student SET new_status = @targetStatus WHERE " + whereClause;
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@targetStatus", targetStatus);
                AddBatchParameters(cmd, conditionType, data);
                return cmd.ExecuteNonQuery();
            }
        }
    }
    
    private int ApplyPaymentStatusChange(string targetStatus, bool negate, Dictionary<string, object> data)
    {
        int days = Convert.ToInt32(data["paymentDays"]);
        
        string accountsConnStr = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
            ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
            : "Server=localhost;Database=campus_dynamics_accounts;Uid=root;Pwd=24thdecember1977;";
        
        using (MySqlConnection conn = new MySqlConnection(accountsConnStr))
        {
            conn.Open();
            string sql;
            
            if (negate)
            {
                // Update students who DID NOT pay in the specified period
                sql = @"UPDATE campus_dynamics.acad_student s
                        SET s.new_status = @targetStatus
                        WHERE s.regno NOT IN (
                            SELECT DISTINCT l.accountcode 
                            FROM fin_ledger l 
                            WHERE l.transactionType = 'CR' 
                            AND l.transactionDate >= DATE_SUB(CURDATE(), INTERVAL @days DAY)
                        )";
            }
            else
            {
                // Update students who DID pay in the specified period
                sql = @"UPDATE campus_dynamics.acad_student s
                        SET s.new_status = @targetStatus
                        WHERE s.regno IN (
                            SELECT DISTINCT l.accountcode 
                            FROM fin_ledger l 
                            WHERE l.transactionType = 'CR' 
                            AND l.transactionDate >= DATE_SUB(CURDATE(), INTERVAL @days DAY)
                        )";
            }
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@targetStatus", targetStatus);
                cmd.Parameters.AddWithValue("@days", days);
                return cmd.ExecuteNonQuery();
            }
        }
    }
    
    private string BuildBatchWhereClause(string conditionType, bool negate, Dictionary<string, object> data)
    {
        string op = negate ? "!=" : "=";
        
        switch (conditionType)
        {
            case "entry_year":
                return "entryyear " + op + " @entryYear";
                
            case "programme":
                return "progid " + op + " @programme";
                
            case "current_status":
                return "new_status " + op + " @currentStatus";
                
            default:
                return "1=0"; // Safety - no records if unknown condition
        }
    }
    
    private void AddBatchParameters(MySqlCommand cmd, string conditionType, Dictionary<string, object> data)
    {
        switch (conditionType)
        {
            case "entry_year":
                cmd.Parameters.AddWithValue("@entryYear", data["entryYear"].ToString());
                break;
                
            case "programme":
                cmd.Parameters.AddWithValue("@programme", data["programme"].ToString());
                break;
                
            case "current_status":
                cmd.Parameters.AddWithValue("@currentStatus", data["currentStatus"].ToString());
                break;
        }
    }
    
    #endregion
    
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
                           s.progid, p.progcode, p.progname, s.specialisation, s.entryyear, s.intake, 
                           s.studsesion, s.studCampus, s.gradSystemID, s.photofile, s.stud_status, s.new_status,
                           COALESCE(c.campus_name, s.studCampus, '-') AS campus_name
                           FROM acad_student s
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
                           WHERE 1=1 ";
            
            // Apply status filter (from query string or dropdown) - uses new_status column
            string effectiveStatus = !string.IsNullOrEmpty(ddlFilterStatus.SelectedValue) 
                ? ddlFilterStatus.SelectedValue 
                : StatusFilter;
            
            if (!string.IsNullOrEmpty(effectiveStatus) && effectiveStatus != "ALL")
            {
                sql += " AND s.new_status = @status ";
            }
            
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
                    if (!string.IsNullOrEmpty(effectiveStatus) && effectiveStatus != "ALL")
                        cmd.Parameters.AddWithValue("@status", effectiveStatus);
                    
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
    
    protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Store the selected status in ViewState
        StatusFilter = ddlFilterStatus.SelectedValue;
        
        // Update page title
        if (litPageTitle != null)
            litPageTitle.Text = PageTitle;
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
                           gradSystemID=@gradsystem, new_status=@newstatus
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
                    cmd.Parameters.AddWithValue("@newstatus", e.NewValues["new_status"] ?? "ADMITTED");
                    
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
    
    #region Student Profile Loading
    
    protected void btnLoadProfile_Click(object sender, EventArgs e)
    {
        string regno = hdnSelectedRegno.Value;
        if (string.IsNullOrEmpty(regno))
            return;
        
        try
        {
            LoadStudentBioData(regno);
            LoadStudentResults(regno);
            LoadFacultyRegistrations(regno);
            LoadCourseRegistrations(regno);
            LoadFeesLedger(regno);
            
            // Show the popup - set ShowOnPageLoad for postback scenario
            popStudentProfile.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error in btnLoadProfile_Click: " + ex.Message);
        }
    }
    
    private void LoadStudentBioData(string regno)
    {
        try
        {
            // Simple query - just get student data with programme and campus
            string sql = @"SELECT s.*, 
                           COALESCE(p.progname, '') AS progname, 
                           COALESCE(p.progcode, '') AS progcode,
                           COALESCE(c.campus_name, s.studCampus, '-') AS campus_name
                           FROM acad_student s
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
                           WHERE s.regno = @regno
                           LIMIT 1";
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Profile Header
                            string firstName = GetSafeString(reader, "firstname");
                            string otherName = GetSafeString(reader, "othername");
                            string fullName = (firstName + " " + otherName).Trim();
                            
                            litStudentName.Text = !string.IsNullOrEmpty(fullName) ? fullName : "-";
                            litRegNo.Text = GetSafeString(reader, "entryno", regno);
                            litProgramme.Text = GetSafeString(reader, "progname", "-");
                            litSpecialisation.Text = GetSafeString(reader, "specialisation", "-");
                            litEntryYear.Text = GetSafeString(reader, "entryyear", "-");
                            litSession.Text = GetSafeString(reader, "studsesion", "-");
                            litCampus.Text = GetSafeString(reader, "campus_name", "-");
                            litIntake.Text = GetSafeString(reader, "intake", "-");
                            
                            // Profile Photo
                            string photoFile = GetSafeString(reader, "photofile");
                            if (!string.IsNullOrEmpty(photoFile))
                                imgProfilePhoto.ImageUrl = ResolveUrl("~/COOPERP/StudentInfo/photos/" + photoFile);
                            else
                                imgProfilePhoto.ImageUrl = ResolveUrl("~/COOPERP/StudentInfo/photos/default.png");
                            
                            // Bio Data - Personal
                            litBioRegNo.Text = GetSafeString(reader, "entryno", "-");
                            litBioEntryNo.Text = GetSafeString(reader, "regno", "-");
                            litBioFullName.Text = !string.IsNullOrEmpty(fullName) ? fullName : "-";
                            litBioGender.Text = GetSafeString(reader, "gender", "-");
                            
                            if (reader["dob"] != DBNull.Value)
                            {
                                try
                                {
                                    DateTime dob = Convert.ToDateTime(reader["dob"]);
                                    litBioDOB.Text = dob.ToString("dd MMMM yyyy");
                                }
                                catch
                                {
                                    litBioDOB.Text = "-";
                                }
                            }
                            else
                            {
                                litBioDOB.Text = "-";
                            }
                            
                            litBioNationality.Text = GetSafeString(reader, "nationality", "-");
                            litBioReligion.Text = GetSafeString(reader, "religion", "-");
                            litBioDistrict.Text = GetSafeString(reader, "home_dist", "-");
                            litBioEntryMethod.Text = GetSafeString(reader, "entryMethod", "-");
                            
                            // Bio Data - Contact
                            litBioPhone.Text = GetSafeString(reader, "studPhone", "-");
                            litBioEmail.Text = GetSafeString(reader, "email", "-");
                            
                            // Bio Data - Academic
                            string progCode = GetSafeString(reader, "progcode");
                            string progName = GetSafeString(reader, "progname");
                            litBioProgramme.Text = !string.IsNullOrEmpty(progCode) ? progCode + " - " + progName : "-";
                            litBioSpecialisation.Text = GetSafeString(reader, "specialisation", "-");
                            litBioEntryYear.Text = GetSafeString(reader, "entryyear", "-");
                            litBioIntake.Text = GetSafeString(reader, "intake", "-");
                            litBioSession.Text = GetSafeString(reader, "studsesion", "-");
                            litBioCampus.Text = GetSafeString(reader, "campus_name", "-");
                            litBioGradingSystem.Text = GetSafeString(reader, "gradSystemID", "-");
                            
                            litBioDuration.Text = "-"; // Duration not available in current schema
                            
                            litBioHall.Text = GetSafeString(reader, "studentHall", "-");
                        }
                        else
                        {
                            // No student found - set defaults
                            litStudentName.Text = "Student Not Found";
                            litRegNo.Text = regno;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading bio data: " + ex.Message);
            litStudentName.Text = "Error Loading Data";
            litRegNo.Text = ex.Message;
        }
    }
    
    private string GetSafeString(MySqlDataReader reader, string fieldName, string defaultValue = "")
    {
        try
        {
            int ordinal = reader.GetOrdinal(fieldName);
            if (!reader.IsDBNull(ordinal))
            {
                return reader.GetValue(ordinal).ToString();
            }
        }
        catch { }
        return defaultValue;
    }
    
    private void LoadStudentResults(string regno)
    {
        try
        {
            // Get all results using stored procedure - loop through all year/semester combinations
            DataTable dtAllResults = new DataTable();
            dtAllResults.Columns.Add("studyyear", typeof(int));
            dtAllResults.Columns.Add("semester", typeof(int));
            dtAllResults.Columns.Add("courseid", typeof(string));
            dtAllResults.Columns.Add("coursename", typeof(string));
            dtAllResults.Columns.Add("CreditUnits", typeof(decimal));
            dtAllResults.Columns.Add("score", typeof(decimal));
            dtAllResults.Columns.Add("grade", typeof(string));
            dtAllResults.Columns.Add("gradept", typeof(decimal));
            dtAllResults.Columns.Add("gpa", typeof(decimal));
            dtAllResults.Columns.Add("acad", typeof(string));
            
            int passed = 0;
            int failed = 0;
            decimal totalCredits = 0;
            decimal lastGPA = 0;
            decimal lastCGPA = 0;
            string lastAwardClass = "-";
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Loop through years 1-6 and semesters 1-3 to get all results
                for (int yr = 1; yr <= 6; yr++)
                {
                    for (int sem = 1; sem <= 3; sem++)
                    {
                        // Get semester results
                        using (MySqlCommand cmd = new MySqlCommand("acad_GetSemesterResults", conn))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.AddWithValue("@reg", regno);
                            cmd.Parameters.AddWithValue("@yr", yr);
                            cmd.Parameters.AddWithValue("@sem", sem);
                            
                            using (MySqlDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    DataRow row = dtAllResults.NewRow();
                                    row["studyyear"] = yr;
                                    row["semester"] = sem;
                                    row["courseid"] = reader["courseid"] != DBNull.Value ? reader["courseid"].ToString() : "";
                                    row["coursename"] = reader["coursename"] != DBNull.Value ? reader["coursename"].ToString() : "";
                                    row["CreditUnits"] = reader["CreditUnits"] != DBNull.Value ? Convert.ToDecimal(reader["CreditUnits"]) : 0;
                                    row["score"] = reader["score"] != DBNull.Value ? Convert.ToDecimal(reader["score"]) : 0;
                                    row["grade"] = reader["grade"] != DBNull.Value ? reader["grade"].ToString() : "";
                                    row["gradept"] = reader["gradept"] != DBNull.Value ? Convert.ToDecimal(reader["gradept"]) : 0;
                                    row["gpa"] = reader["gpa"] != DBNull.Value ? Convert.ToDecimal(reader["gpa"]) : 0;
                                    row["acad"] = reader["acad"] != DBNull.Value ? reader["acad"].ToString() : "";
                                    dtAllResults.Rows.Add(row);
                                    
                                    // Count passed/failed
                                    string grade = row["grade"].ToString();
                                    decimal credits = Convert.ToDecimal(row["CreditUnits"]);
                                    if (!string.IsNullOrEmpty(grade) && grade != "F" && grade != "X" && grade != "NE" && grade != "I")
                                    {
                                        passed++;
                                        totalCredits += credits;
                                    }
                                    else if (grade == "F" || grade == "X")
                                    {
                                        failed++;
                                    }
                                }
                            }
                        }
                        
                        // Get semester summary to get GPA, CGPA and Award Class
                        if (dtAllResults.Select(string.Format("studyyear = {0} AND semester = {1}", yr, sem)).Length > 0)
                        {
                            using (MySqlCommand cmdSum = new MySqlCommand("acad_SemesterSummary", conn))
                            {
                                cmdSum.CommandType = CommandType.StoredProcedure;
                                cmdSum.Parameters.AddWithValue("@reg", regno);
                                cmdSum.Parameters.AddWithValue("@yr", yr);
                                cmdSum.Parameters.AddWithValue("@sem", sem);
                                
                                using (MySqlDataReader reader = cmdSum.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        lastGPA = reader["gpa"] != DBNull.Value ? Convert.ToDecimal(reader["gpa"]) : 0;
                                        lastCGPA = reader["cgpa"] != DBNull.Value ? Convert.ToDecimal(reader["cgpa"]) : 0;
                                        lastAwardClass = reader["awardClass"] != DBNull.Value ? reader["awardClass"].ToString() : "-";
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Set summary stats
            litGPA.Text = lastGPA.ToString("F2");
            litCoursesPassed.Text = passed.ToString();
            litCoursesFailed.Text = failed.ToString();
            litTotalCredits.Text = totalCredits.ToString("0");
            
            if (dtAllResults.Rows.Count == 0)
            {
                pnlNoResults.Visible = true;
                rptResultsSemesters.Visible = false;
                litCGPA.Text = "0.00";
                litAwardClass.Text = "-";
            }
            else
            {
                pnlNoResults.Visible = false;
                rptResultsSemesters.Visible = true;
                
                // Group results by year/semester
                var semesterGroups = new List<object>();
                DataView view = new DataView(dtAllResults);
                DataTable distinctSemesters = view.ToTable(true, "studyyear", "semester");
                distinctSemesters.DefaultView.Sort = "studyyear ASC, semester ASC";
                
                foreach (DataRowView semRowView in distinctSemesters.DefaultView)
                {
                    DataRow semRow = semRowView.Row;
                    int year = Convert.ToInt32(semRow["studyyear"]);
                    int semester = Convert.ToInt32(semRow["semester"]);
                    
                    DataRow[] courseRows = dtAllResults.Select(string.Format("studyyear = {0} AND semester = {1}", year, semester));
                    if (courseRows.Length == 0) continue;
                    
                    var courses = new List<object>();
                    decimal semGP = 0;
                    decimal semCredits = 0;
                    
                    foreach (DataRow courseRow in courseRows)
                    {
                        decimal credits = Convert.ToDecimal(courseRow["CreditUnits"]);
                        decimal gp = Convert.ToDecimal(courseRow["gradept"]);
                        
                        semGP += gp * credits;
                        semCredits += credits;
                        
                        courses.Add(new {
                            course_code = courseRow["courseid"],
                            course_title = courseRow["coursename"],
                            credits = credits,
                            mark = courseRow["score"],
                            grade = courseRow["grade"],
                            gp = gp
                        });
                    }
                    
                    decimal semGPA = semCredits > 0 ? semGP / semCredits : 0;
                    
                    semesterGroups.Add(new {
                        year = year,
                        semester = semester,
                        gpa = semGPA,
                        courses = courses
                    });
                }
                
                litCGPA.Text = lastCGPA.ToString("F2");
                litAwardClass.Text = !string.IsNullOrEmpty(lastAwardClass) ? lastAwardClass : "-";
                
                rptResultsSemesters.DataSource = semesterGroups;
                rptResultsSemesters.DataBind();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading results: " + ex.Message);
            pnlNoResults.Visible = true;
            rptResultsSemesters.Visible = false;
        }
    }
    
    private void LoadFacultyRegistrations(string regno)
    {
        try
        {
            // acad_registration table columns: ID, regno, acad_year, semester, regstatus, studyyear, 
            // id_cardStatus, residence_status, reg_CardStatus, examClearance, examClearanceDate, clearedBy, registeredBy
            string sql = @"SELECT acad_year as academic_year, semester, studyyear as study_year, 
                           regstatus as remarks, examClearanceDate as reg_date, 
                           CASE WHEN examClearance = 'YES' THEN 1 ELSE 0 END as exam_clearance, 
                           CASE WHEN reg_CardStatus = 'YES' THEN 1 ELSE 0 END as reg_clearance
                           FROM acad_registration
                           WHERE regno = @regno
                           ORDER BY acad_year DESC, semester DESC";
            
            DataTable dt = new DataTable();
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
            
            if (dt.Rows.Count == 0)
            {
                pnlNoRegistrations.Visible = true;
                rptRegistrations.Visible = false;
            }
            else
            {
                pnlNoRegistrations.Visible = false;
                rptRegistrations.Visible = true;
                rptRegistrations.DataSource = dt;
                rptRegistrations.DataBind();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading registrations: " + ex.Message);
            pnlNoRegistrations.Visible = true;
            rptRegistrations.Visible = false;
        }
    }
    
    private void LoadCourseRegistrations(string regno)
    {
        try
        {
            // acad_course_registration columns: ID, regno, courseID, acad_year, semester, course_status, prog_id, stud_session
            string sql = @"SELECT cr.acad_year as academic_year, cr.semester, cr.courseID as course_code, 
                           c.CourseTitle as course_title, COALESCE(c.CreditUnits, 0) as credits,
                           COALESCE(cr.course_status, 'REGISTERED') as course_type, NULL as reg_date
                           FROM acad_course_registration cr
                           LEFT JOIN acad_courses c ON cr.courseID = c.CourseCode
                           WHERE cr.regno = @regno
                           ORDER BY cr.acad_year DESC, cr.semester DESC, cr.courseID";
            
            DataTable dtCourseReg = new DataTable();
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtCourseReg);
                    }
                }
            }
            
            if (dtCourseReg.Rows.Count == 0)
            {
                pnlNoCourseReg.Visible = true;
                rptCourseRegSemesters.Visible = false;
            }
            else
            {
                pnlNoCourseReg.Visible = false;
                rptCourseRegSemesters.Visible = true;
                
                // Group by academic year/semester
                var semesterGroups = new List<object>();
                DataView view = new DataView(dtCourseReg);
                DataTable distinctSemesters = view.ToTable(true, "academic_year", "semester");
                
                foreach (DataRow semRow in distinctSemesters.Rows)
                {
                    string acadYear = semRow["academic_year"] != DBNull.Value ? semRow["academic_year"].ToString() : "";
                    int semester = semRow["semester"] != DBNull.Value ? Convert.ToInt32(semRow["semester"]) : 0;
                    
                    DataRow[] courseRows = dtCourseReg.Select(string.Format("academic_year = '{0}' AND semester = {1}", acadYear, semester));
                    
                    var courses = new List<object>();
                    foreach (DataRow courseRow in courseRows)
                    {
                        courses.Add(new {
                            course_code = courseRow["course_code"],
                            course_title = courseRow["course_title"],
                            credits = courseRow["credits"],
                            course_type = courseRow["course_type"],
                            reg_date = courseRow["reg_date"]
                        });
                    }
                    
                    semesterGroups.Add(new {
                        academic_year = acadYear,
                        semester = semester,
                        course_count = courses.Count,
                        courses = courses
                    });
                }
                
                rptCourseRegSemesters.DataSource = semesterGroups;
                rptCourseRegSemesters.DataBind();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading course registrations: " + ex.Message);
            pnlNoCourseReg.Visible = true;
            rptCourseRegSemesters.Visible = false;
        }
    }
    
    // Helper methods for formatting in repeater
    protected string FormatAmount(object amount)
    {
        if (amount == null || amount == DBNull.Value)
            return "-";
        
        try
        {
            decimal val = Convert.ToDecimal(amount);
            return val > 0 ? val.ToString("N0") : "-";
        }
        catch
        {
            return "-";
        }
    }
    
    protected string FormatBalance(object balance)
    {
        if (balance == null || balance == DBNull.Value)
            return "0";
        
        try
        {
            decimal val = Convert.ToDecimal(balance);
            return val.ToString("N0");
        }
        catch
        {
            return "0";
        }
    }
    
    // Connection string for accounts database (different from main database)
    private string AccountsConnectionString = ConfigurationManager.ConnectionStrings["accountsConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["accountsConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics_accounts;Uid=root;Pwd=24thdecember1977;";
    
    private void LoadFeesLedger(string regno)
    {
        try
        {
            // Use stored procedure fin_GetStudentLedger from the accounts database
            // It returns: formated_date, voucherNo, particulars, dr_amount, cr_amount, curr_balance, teller
            DataTable dtFees = new DataTable();
            using (MySqlConnection conn = new MySqlConnection(AccountsConnectionString))
            {
                conn.Open();
                // Call stored procedure using CALL syntax
                using (MySqlCommand cmd = new MySqlCommand("CALL fin_GetStudentLedger(@reg)", conn))
                {
                    cmd.Parameters.AddWithValue("@reg", regno);
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtFees);
                    }
                }
            }
            
            if (dtFees.Rows.Count == 0)
            {
                pnlNoFees.Visible = true;
                rptFeesLedger.Visible = false;
                litTotalInvoiced.Text = "0";
                litTotalPaid.Text = "0";
                litBalance.Text = "0";
            }
            else
            {
                pnlNoFees.Visible = false;
                rptFeesLedger.Visible = true;
                
                // Calculate totals from the stored procedure results
                decimal totalDebit = 0;
                decimal totalCredit = 0;
                decimal lastBalance = 0;
                
                // Create a new DataTable with proper column names for display
                DataTable displayTable = new DataTable();
                displayTable.Columns.Add("trans_date", typeof(string));
                displayTable.Columns.Add("reference", typeof(string));
                displayTable.Columns.Add("description", typeof(string));
                displayTable.Columns.Add("debit", typeof(decimal));
                displayTable.Columns.Add("credit", typeof(decimal));
                displayTable.Columns.Add("running_balance", typeof(decimal));
                
                foreach (DataRow srcRow in dtFees.Rows)
                {
                    DataRow newRow = displayTable.NewRow();
                    
                    // Map stored procedure columns to display columns
                    newRow["trans_date"] = srcRow.Table.Columns.Contains("formated_date") && srcRow["formated_date"] != DBNull.Value 
                        ? srcRow["formated_date"].ToString() : "";
                    newRow["reference"] = srcRow.Table.Columns.Contains("voucherNo") && srcRow["voucherNo"] != DBNull.Value 
                        ? srcRow["voucherNo"].ToString() : "";
                    newRow["description"] = srcRow.Table.Columns.Contains("particulars") && srcRow["particulars"] != DBNull.Value 
                        ? srcRow["particulars"].ToString() : "";
                    
                    decimal debit = 0;
                    decimal credit = 0;
                    
                    if (srcRow.Table.Columns.Contains("dr_amount") && srcRow["dr_amount"] != DBNull.Value)
                    {
                        decimal.TryParse(srcRow["dr_amount"].ToString(), out debit);
                    }
                    if (srcRow.Table.Columns.Contains("cr_amount") && srcRow["cr_amount"] != DBNull.Value)
                    {
                        decimal.TryParse(srcRow["cr_amount"].ToString(), out credit);
                    }
                    
                    newRow["debit"] = debit;
                    newRow["credit"] = credit;
                    
                    // Get curr_balance from stored procedure
                    if (srcRow.Table.Columns.Contains("curr_balance") && srcRow["curr_balance"] != DBNull.Value)
                    {
                        decimal.TryParse(srcRow["curr_balance"].ToString(), out lastBalance);
                    }
                    newRow["running_balance"] = lastBalance;
                    
                    totalDebit += debit;
                    totalCredit += credit;
                    
                    displayTable.Rows.Add(newRow);
                }
                
                litTotalInvoiced.Text = totalDebit.ToString("N0");
                litTotalPaid.Text = totalCredit.ToString("N0");
                litBalance.Text = lastBalance.ToString("N0");
                
                rptFeesLedger.DataSource = displayTable;
                rptFeesLedger.DataBind();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading fees ledger: " + ex.Message);
            pnlNoFees.Visible = true;
            rptFeesLedger.Visible = false;
        }
    }
    
    #endregion
}
