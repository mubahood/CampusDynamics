using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.IO;
using System.Text;
using System.Linq;

public partial class COOPERP_NewScreens_NewStudentInfo : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    // Shared specIdToUse between Curriculum and Validation tabs
    private int _sharedSpecIdToUse = 0;
    
    // Flag to ensure DB columns are created only once per app start
    private static bool _dbColumnsChecked = false;

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
        // Ensure validation columns exist in database (once per app start)
        EnsureValidationColumnsExist();
        
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
            else if (action == "PreviewBatchValidation")
            {
                HandlePreviewBatchValidation();
                return;
            }
            else if (action == "ApplyBatchValidation")
            {
                HandleApplyBatchValidation();
                return;
            }
            else if (action == "PreviewSummaryReport")
            {
                HandlePreviewSummaryReport();
                return;
            }
            else if (action == "ExportSummaryReport")
            {
                HandleExportSummaryReport();
                return;
            }
            else if (action == "ExportPerformanceReport")
            {
                HandleExportPerformanceReport();
                return;
            }
        }
        
        // Always reload programmes - ViewState is disabled so dropdowns lose items on postback
        LoadBatchProgrammes();
        
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
            // Set default photo URL for JavaScript use
            hdnDefaultPhotoUrl.Value = ResolveUrl("~/COOPERP/StudentInfo/photos/default.png");
            
            // Update page header based on status
            if (litPageTitle != null)
                litPageTitle.Text = PageTitle;
        }
        // Always bind data (DevExpress grids need rebind on postback too for callbacks)
        BindStudentsGrid();
    }
    
    /// <summary>
    /// Ensures the validation-related columns exist in acad_student table.
    /// Columns: has_passed, is_curriculum_fully_set, fail_reason
    /// </summary>
    private void EnsureValidationColumnsExist()
    {
        if (_dbColumnsChecked) return;
        _dbColumnsChecked = true;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Check and add columns if they don't exist
                string[] columns = new string[] { "has_passed", "is_curriculum_fully_set", "fail_reason" };
                string[] columnDefs = new string[] {
                    "VARCHAR(5) DEFAULT 'No'",
                    "VARCHAR(5) DEFAULT 'No'",
                    "TEXT DEFAULT NULL"
                };
                
                for (int i = 0; i < columns.Length; i++)
                {
                    string checkSql = @"SELECT COUNT(*) FROM information_schema.COLUMNS 
                                        WHERE TABLE_SCHEMA = DATABASE() 
                                        AND TABLE_NAME = 'acad_student' 
                                        AND COLUMN_NAME = @colName";
                    
                    using (MySqlCommand cmd = new MySqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@colName", columns[i]);
                        int exists = Convert.ToInt32(cmd.ExecuteScalar());
                        
                        if (exists == 0)
                        {
                            string alterSql = "ALTER TABLE acad_student ADD COLUMN " + columns[i] + " " + columnDefs[i];
                            using (MySqlCommand alterCmd = new MySqlCommand(alterSql, conn))
                            {
                                alterCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error ensuring validation columns: " + ex.Message);
        }
    }
    
    #region Batch Operations
    
    private void LoadBatchProgrammes()
    {
        try
        {
            ddlBatchProgramme.Items.Clear();
            ddlBatchProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
            
            ddlValidationProgramme.Items.Clear();
            ddlValidationProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
            
            ddlReportProgramme.Items.Clear();
            ddlReportProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT progcode, progname FROM acad_programme ORDER BY progname", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string progName = reader["progname"].ToString();
                            string progCode = reader["progcode"].ToString();
                            
                            ddlBatchProgramme.Items.Add(new ListItem(progName, progCode));
                            ddlValidationProgramme.Items.Add(new ListItem(progName, progCode));
                            // Include code in display for report dropdown: "CODE - Programme Name"
                            ddlReportProgramme.Items.Add(new ListItem(progCode + " - " + progName, progCode));
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
    
    /// <summary>
    /// Handles AJAX request to preview how many students will be affected by batch validation.
    /// Filters by programme and entry year if specified.
    /// </summary>
    private void HandlePreviewBatchValidation()
    {
        Response.ContentType = "application/json";
        
        try
        {
            string programme = Request.QueryString["programme"] ?? "";
            string entryYear = Request.QueryString["entryYear"] ?? "";
            string entryNumbers = Request.QueryString["entryNumbers"] ?? "";
            
            int count = GetBatchValidationCount(programme, entryYear, entryNumbers);
            
            Response.Write("{\"count\": " + count + "}");
        }
        catch (Exception ex)
        {
            Response.Write("{\"count\": 0, \"error\": \"" + ex.Message.Replace("\"", "'") + "\"}");
        }
        Response.End();
    }
    
    /// <summary>
    /// Handles AJAX request to apply batch validation to students.
    /// Validates each student's results against their curriculum and updates has_passed, is_curriculum_fully_set, fail_reason.
    /// </summary>
    private void HandleApplyBatchValidation()
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
            
            string programme = data.ContainsKey("programme") ? data["programme"].ToString() : "";
            string entryYear = data.ContainsKey("entryYear") ? data["entryYear"].ToString() : "";
            string entryNumbers = data.ContainsKey("entryNumbers") ? data["entryNumbers"].ToString() : "";
            
            int validated = ApplyBatchValidation(programme, entryYear, entryNumbers);
            
            Response.Write(serializer.Serialize(new { success = true, validated = validated }));
        }
        catch (Exception ex)
        {
            Response.Write("{\"success\": false, \"message\": \"" + ex.Message.Replace("\"", "'") + "\"}");
        }
        Response.End();
    }
    
    /// <summary>
    /// Gets count of students that would be affected by batch validation.
    /// Supports filtering by programme, entry year, or specific entry numbers (comma-separated).
    /// </summary>
    private int GetBatchValidationCount(string programme, string entryYear, string entryNumbers = "")
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            string sql = "SELECT COUNT(*) FROM acad_student WHERE 1=1";
            
            // If entry numbers specified, use them (ignore other filters)
            if (!string.IsNullOrEmpty(entryNumbers))
            {
                string[] entries = entryNumbers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (entries.Length > 0)
                {
                    List<string> paramNames = new List<string>();
                    for (int i = 0; i < entries.Length; i++)
                        paramNames.Add("@entry" + i);
                    sql += " AND entryno IN (" + string.Join(",", paramNames) + ")";
                    
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        for (int i = 0; i < entries.Length; i++)
                            cmd.Parameters.AddWithValue("@entry" + i, entries[i].Trim());
                        return Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }
            }
            
            if (!string.IsNullOrEmpty(programme))
                sql += " AND progid = @programme";
            if (!string.IsNullOrEmpty(entryYear))
                sql += " AND entryyear = @entryYear";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(programme))
                    cmd.Parameters.AddWithValue("@programme", programme);
                if (!string.IsNullOrEmpty(entryYear))
                    cmd.Parameters.AddWithValue("@entryYear", entryYear);
                
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }
    
    /// <summary>
    /// Applies batch validation to all matching students.
    /// For each student:
    /// 1. Gets their specialisation (or default for their programme)
    /// 2. Checks if curriculum is fully set (is_fully_set field)
    /// 3. Compares curriculum course count per semester vs actual results
    /// 4. Updates has_passed, is_curriculum_fully_set, fail_reason fields
    /// Supports filtering by programme, entry year, or specific entry numbers (comma-separated).
    /// </summary>
    private int ApplyBatchValidation(string programme, string entryYear, string entryNumbers = "")
    {
        int validatedCount = 0;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Get all students matching the filter
            string selectSql = @"SELECT s.regno, s.progid, s.specialisation 
                                 FROM acad_student s 
                                 WHERE 1=1";
            
            List<string> entryParams = new List<string>();
            string[] entries = null;
            
            // If entry numbers specified, use them (ignore other filters)
            if (!string.IsNullOrEmpty(entryNumbers))
            {
                entries = entryNumbers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        entryParams.Add("@entry" + i);
                    selectSql += " AND s.entryno IN (" + string.Join(",", entryParams) + ")";
                }
            }
            else
            {
                if (!string.IsNullOrEmpty(programme))
                    selectSql += " AND s.progid = @programme";
                if (!string.IsNullOrEmpty(entryYear))
                    selectSql += " AND s.entryyear = @entryYear";
            }
            
            DataTable students = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(selectSql, conn))
            {
                // Add parameters based on filter type
                if (!string.IsNullOrEmpty(entryNumbers) && entries != null && entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        cmd.Parameters.AddWithValue("@entry" + i, entries[i].Trim());
                }
                else
                {
                    if (!string.IsNullOrEmpty(programme))
                        cmd.Parameters.AddWithValue("@programme", programme);
                    if (!string.IsNullOrEmpty(entryYear))
                        cmd.Parameters.AddWithValue("@entryYear", entryYear);
                }
                
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(students);
                }
            }
            
            // Process each student
            foreach (DataRow student in students.Rows)
            {
                string regno = student["regno"].ToString();
                string progid = student["progid"].ToString();
                string specId = student["specialisation"] != DBNull.Value ? student["specialisation"].ToString() : "";
                
                // Validate this student
                ValidateSingleStudent(conn, regno, progid, specId);
                validatedCount++;
            }
        }
        
        return validatedCount;
    }
    
    /// <summary>
    /// Validates a single student's results against their curriculum.
    /// Updates has_passed, is_curriculum_fully_set, and fail_reason fields.
    /// 
    /// Relaxed validation rules:
    /// 1. Only CORE courses count towards the required curriculum total (electives excluded).
    /// 2. Semester 3 is always auto-passed (supplementary / short semester).
    /// 3. Future year+semester slots where the student has ZERO results are skipped
    ///    (student hasn't reached that point yet).
    /// 4. If a student has 6 or more total results in a given year+semester,
    ///    that slot is auto-passed regardless of the curriculum requirement.
    /// 5. Curriculum is now compared per study_year + semester (not semester alone).
    /// </summary>
    private void ValidateSingleStudent(MySqlConnection conn, string regno, string progid, string specId)
    {
        string hasPassed = "No";
        string isCurriculumFullySet = "No";
        List<string> failReasons = new List<string>();
        
        try
        {
            // Normalise specId: treat "-", "0", whitespace-only as empty (unassigned)
            specId = (specId ?? "").Trim();
            bool needDefault = string.IsNullOrEmpty(specId) || specId == "0" || specId == "-";
            
            // Step 1: Get specialisation ID (student's own or default for programme)
            if (needDefault)
            {
                specId = "";
                // Strategy 1: Find specialisation marked as default
                string defaultSpecSql = @"SELECT spec_id FROM acad_specialisation 
                                          WHERE prog_id = @progid AND is_default = 'Yes' 
                                          LIMIT 1";
                using (MySqlCommand cmd = new MySqlCommand(defaultSpecSql, conn))
                {
                    cmd.Parameters.AddWithValue("@progid", progid);
                    object result = cmd.ExecuteScalar();
                    specId = result != null ? result.ToString().Trim() : "";
                }
                
                // Strategy 2: Find specialisation named 'Default'
                if (string.IsNullOrEmpty(specId))
                {
                    string namedDefaultSql = @"SELECT spec_id FROM acad_specialisation 
                                              WHERE prog_id = @progid AND (spec = 'Default' OR spec LIKE '%Default%')
                                              ORDER BY spec_id LIMIT 1";
                    using (MySqlCommand cmd = new MySqlCommand(namedDefaultSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@progid", progid);
                        object result = cmd.ExecuteScalar();
                        specId = result != null ? result.ToString().Trim() : "";
                    }
                }
                
                // Strategy 3: Fall back to the first specialisation for this programme
                if (string.IsNullOrEmpty(specId))
                {
                    string firstSpecSql = @"SELECT spec_id FROM acad_specialisation 
                                            WHERE prog_id = @progid 
                                            ORDER BY spec_id LIMIT 1";
                    using (MySqlCommand cmd = new MySqlCommand(firstSpecSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@progid", progid);
                        object result = cmd.ExecuteScalar();
                        specId = result != null ? result.ToString().Trim() : "";
                    }
                }
            }
            
            // Step 2: Check if specialisation exists and is fully set
            if (!string.IsNullOrEmpty(specId))
            {
                string checkSpecSql = @"SELECT COALESCE(is_fully_set, 'No') AS is_fully_set FROM acad_specialisation WHERE spec_id = @specId";
                using (MySqlCommand cmd = new MySqlCommand(checkSpecSql, conn))
                {
                    cmd.Parameters.AddWithValue("@specId", specId);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        isCurriculumFullySet = result.ToString().Trim().Equals("Yes", StringComparison.OrdinalIgnoreCase) ? "Yes" : "No";
                    }
                }
            }
            
            if (string.IsNullOrEmpty(specId))
            {
                failReasons.Add("No curriculum defined for programme");
            }
            else if (isCurriculumFullySet != "Yes")
            {
                failReasons.Add("Curriculum not fully set");
            }
            else
            {
                // ============================================================
                // Step 3: Get CORE curriculum courses grouped by study_year + semester
                // Only CORE courses count towards the required total.
                // ============================================================
                string curriculumSql = @"SELECT study_year, semester, COUNT(*) as course_count 
                                         FROM acad_programmecourses 
                                         WHERE specialisation_id = @specId 
                                           AND UPPER(TRIM(course_type)) = 'CORE'
                                         GROUP BY study_year, semester 
                                         ORDER BY study_year, semester";
                
                // Key = "Y{study_year}S{semester}", Value = required CORE course count
                Dictionary<string, int> curriculumByYearSem = new Dictionary<string, int>();
                // Also track the raw year and semester for each key
                Dictionary<string, int[]> yearSemLookup = new Dictionary<string, int[]>();
                
                using (MySqlCommand cmd = new MySqlCommand(curriculumSql, conn))
                {
                    cmd.Parameters.AddWithValue("@specId", specId);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int yr = Convert.ToInt32(reader["study_year"]);
                            int sem = Convert.ToInt32(reader["semester"]);
                            string key = "Y" + yr + "S" + sem;
                            int count = Convert.ToInt32(reader["course_count"]);
                            curriculumByYearSem[key] = count;
                            yearSemLookup[key] = new int[] { yr, sem };
                        }
                    }
                }
                
                // ============================================================
                // Step 4: Get ALL student results grouped by studyyear + semester
                //         (total count — includes F grades — for the 6+ auto-pass rule)
                // ============================================================
                string allResultsSql = @"SELECT studyyear, semester, COUNT(*) as total_count 
                                         FROM acad_results 
                                         WHERE TRIM(regno) = @regno 
                                           AND grade IS NOT NULL
                                         GROUP BY studyyear, semester";
                
                Dictionary<string, int> totalResultsByYearSem = new Dictionary<string, int>();
                using (MySqlCommand cmd = new MySqlCommand(allResultsSql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int yr = Convert.ToInt32(reader["studyyear"]);
                            int sem = Convert.ToInt32(reader["semester"]);
                            string key = "Y" + yr + "S" + sem;
                            totalResultsByYearSem[key] = Convert.ToInt32(reader["total_count"]);
                        }
                    }
                }
                
                // ============================================================
                // Step 5: Get PASSED results grouped by studyyear + semester
                //         (grade IS NOT NULL and grade != 'F')
                // ============================================================
                string passedResultsSql = @"SELECT studyyear, semester, COUNT(*) as result_count 
                                            FROM acad_results 
                                            WHERE TRIM(regno) = @regno 
                                              AND grade IS NOT NULL 
                                              AND UPPER(TRIM(grade)) != 'F'
                                            GROUP BY studyyear, semester";
                
                Dictionary<string, int> passedResultsByYearSem = new Dictionary<string, int>();
                using (MySqlCommand cmd = new MySqlCommand(passedResultsSql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int yr = Convert.ToInt32(reader["studyyear"]);
                            int sem = Convert.ToInt32(reader["semester"]);
                            string key = "Y" + yr + "S" + sem;
                            passedResultsByYearSem[key] = Convert.ToInt32(reader["result_count"]);
                        }
                    }
                }
                
                // ============================================================
                // Step 6: Compare curriculum vs results per year+semester
                //         with relaxed rules
                // ============================================================
                bool allSemestersPassed = true;
                int validatedSlots = 0; // track how many slots were actually evaluated
                
                foreach (var kvp in curriculumByYearSem)
                {
                    string key = kvp.Key;
                    int required = kvp.Value;
                    int[] yrSem = yearSemLookup[key];
                    int year = yrSem[0];
                    int semester = yrSem[1];
                    
                    int totalResults = totalResultsByYearSem.ContainsKey(key) ? totalResultsByYearSem[key] : 0;
                    int passedResults = passedResultsByYearSem.ContainsKey(key) ? passedResultsByYearSem[key] : 0;
                    
                    // Rule 1: Semester 3 is always auto-passed (skip validation entirely)
                    if (semester == 3)
                    {
                        validatedSlots++;
                        continue; // auto-pass
                    }
                    
                    // Rule 2: Skip future slots where student has NO results at all
                    //         (student hasn't reached this year+semester yet)
                    if (totalResults == 0)
                    {
                        continue; // don't count, don't fail — future semester
                    }
                    
                    validatedSlots++;
                    
                    // Rule 3: If student has 6 or more total results in this slot,
                    //         auto-pass regardless of curriculum requirement
                    if (totalResults >= 6)
                    {
                        continue; // auto-pass — heavy course load
                    }
                    
                    // Rule 4: Normal comparison — passed results vs required CORE count
                    if (passedResults < required)
                    {
                        allSemestersPassed = false;
                        failReasons.Add("Y" + year + " Sem" + semester + ": " + passedResults + "/" + required + " core courses passed");
                    }
                }
                
                if (allSemestersPassed && validatedSlots > 0)
                {
                    hasPassed = "Yes";
                }
                else if (curriculumByYearSem.Count == 0)
                {
                    failReasons.Add("Curriculum has no CORE courses defined");
                }
                else if (validatedSlots == 0)
                {
                    // Student has no results in any curriculum slot yet
                    failReasons.Add("No results found for any curriculum semester");
                }
            }
        }
        catch (Exception ex)
        {
            failReasons.Add("Validation error: " + ex.Message);
        }
        
        // Step 7: Update the student record
        string failReason = failReasons.Count > 0 ? string.Join("; ", failReasons) : null;
        
        string updateSql = @"UPDATE acad_student 
                             SET has_passed = @hasPassed, 
                                 is_curriculum_fully_set = @isCurriculumFullySet, 
                                 fail_reason = @failReason 
                             WHERE regno = @regno";
        
        using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
        {
            cmd.Parameters.AddWithValue("@hasPassed", hasPassed);
            cmd.Parameters.AddWithValue("@isCurriculumFullySet", isCurriculumFullySet);
            cmd.Parameters.AddWithValue("@failReason", failReason != null ? (object)failReason : DBNull.Value);
            cmd.Parameters.AddWithValue("@regno", regno);
            cmd.ExecuteNonQuery();
        }
    }
    
    #endregion
    
    #region Summary Report Export Handlers
    
    /// <summary>
    /// Handles AJAX request to preview the count of students for summary report.
    /// </summary>
    private void HandlePreviewSummaryReport()
    {
        Response.Clear();
        Response.ContentType = "application/json";
        
        try
        {
            string programme = Request.QueryString["programme"] ?? "";
            string entryYear = Request.QueryString["entryYear"] ?? "";
            string studyYear = Request.QueryString["studyYear"] ?? "";
            string semester = Request.QueryString["semester"] ?? "";
            string entryNumbers = Request.QueryString["entryNumbers"] ?? "";
            
            int count = GetSummaryReportStudentCount(programme, entryYear, studyYear, semester, entryNumbers);
            
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Response.Write(serializer.Serialize(new { count = count }));
        }
        catch (Exception ex)
        {
            Response.Write("{\"count\": 0, \"error\": \"" + ex.Message.Replace("\"", "'").Replace("\r", " ").Replace("\n", " ") + "\"}");
        }
        
        try
        {
            Response.End();
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Expected - Response.End() always throws this
        }
    }
    
    /// <summary>
    /// Gets count of students who have results matching the filters.
    /// </summary>
    private int GetSummaryReportStudentCount(string programme, string entryYear, string studyYear, string semester, string entryNumbers)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Query to count students with results matching the filters
            string sql = @"SELECT COUNT(DISTINCT s.regno) 
                           FROM acad_student s
                           INNER JOIN acad_results r ON s.regno = r.regno
                           WHERE 1=1";
            
            List<string> entryParams = new List<string>();
            string[] entries = null;
            
            // If entry numbers specified, use them
            if (!string.IsNullOrEmpty(entryNumbers))
            {
                entries = entryNumbers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        entryParams.Add("@entry" + i);
                    sql += " AND s.entryno IN (" + string.Join(",", entryParams) + ")";
                }
            }
            
            // Always filter by programme, entry year, study year, and semester
            if (!string.IsNullOrEmpty(programme))
                sql += " AND s.progid = @programme";
            if (!string.IsNullOrEmpty(entryYear))
                sql += " AND s.entryyear = @entryYear";
            if (!string.IsNullOrEmpty(studyYear))
                sql += " AND r.studyyear = @studyYear";
            if (!string.IsNullOrEmpty(semester))
                sql += " AND r.semester = @semester";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(entryNumbers) && entries != null && entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        cmd.Parameters.AddWithValue("@entry" + i, entries[i].Trim());
                }
                
                if (!string.IsNullOrEmpty(programme))
                    cmd.Parameters.AddWithValue("@programme", programme);
                if (!string.IsNullOrEmpty(entryYear))
                    cmd.Parameters.AddWithValue("@entryYear", entryYear);
                if (!string.IsNullOrEmpty(studyYear))
                    cmd.Parameters.AddWithValue("@studyYear", studyYear);
                if (!string.IsNullOrEmpty(semester))
                    cmd.Parameters.AddWithValue("@semester", semester);
                
                object result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? Convert.ToInt32(result) : 0;
            }
        }
    }
    
    /// <summary>
    /// Handles the export of summary report as PDF.
    /// Generates a professional PDF with student details and their results.
    /// </summary>
    private void HandleExportSummaryReport()
    {
        try
        {
            string programme = Request.QueryString["programme"] ?? "";
            string entryYear = Request.QueryString["entryYear"] ?? "";
            string studyYear = Request.QueryString["studyYear"] ?? "";
            string semester = Request.QueryString["semester"] ?? "";
            string entryNumbers = Request.QueryString["entryNumbers"] ?? "";
            
            // Get students with their results
            DataTable reportData = GetSummaryReportData(programme, entryYear, studyYear, semester, entryNumbers);
            
            if (reportData.Rows.Count == 0)
            {
                Response.Clear();
                Response.ContentType = "text/html";
                Response.Write("<html><body><h3>No data found for the selected filters.</h3></body></html>");
                try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
                return;
            }
            
            // Generate PDF using DevExpress XtraPrinting
            GenerateSummaryReportPdf(reportData, studyYear, semester, entryYear);
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Expected when Response.End() is called - ignore
        }
        catch (Exception ex)
        {
            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write("<html><body><h3>Error generating report:</h3><p>" + Server.HtmlEncode(ex.Message) + "</p></body></html>");
            try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
        }
    }

    /// <summary>
    /// Handles the export of Performance Summary Report (CGPA-based categorization).
    /// Shows students categorized by: VC's List, Dean's List, Second Class Lower, Pass.
    /// </summary>
    private void HandleExportPerformanceReport()
    {
        try
        {
            string programme = Request.QueryString["programme"] ?? "";
            string entryYear = Request.QueryString["entryYear"] ?? "";
            string studyYear = Request.QueryString["studyYear"] ?? "";
            string semester = Request.QueryString["semester"] ?? "";
            string entryNumbers = Request.QueryString["entryNumbers"] ?? "";
            
            // Get students with CGPA data
            DataTable studentData = GetPerformanceReportData(programme, entryYear, studyYear, semester, entryNumbers);
            
            if (studentData.Rows.Count == 0)
            {
                Response.Clear();
                Response.ContentType = "text/html";
                Response.Write("<html><body><h3>No data found for the selected filters.</h3></body></html>");
                try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
                return;
            }
            
            // Get programme name
            string programmeName = GetProgrammeName(programme);
            
            // Generate Performance Report PDF
            GeneratePerformanceReportPdf(studentData, programmeName, entryYear, studyYear, semester);
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Expected when Response.End() is called - ignore
        }
        catch (Exception ex)
        {
            Response.Clear();
            Response.ContentType = "text/html";
            Response.Write("<html><body><h3>Error generating report:</h3><p>" + Server.HtmlEncode(ex.Message) + "</p></body></html>");
            try { Response.End(); } catch (System.Threading.ThreadAbortException) { }
        }
    }
    
    private string GetProgrammeName(string progCode)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT progname FROM acad_programme WHERE progcode = @code", conn))
            {
                cmd.Parameters.AddWithValue("@code", progCode);
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : progCode;
            }
        }
    }
    
    private DataTable GetPerformanceReportData(string programme, string entryYear, string studyYear, string semester, string entryNumbers)
    {
        DataTable dt = new DataTable();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Calculate CGPA for each student based on their results
            // Include has_passed and fail_reason from acad_student table
            string sql = @"SELECT 
                s.regno,
                s.entryno,
                CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) AS student_name,
                s.gender,
                p.progname,
                s.has_passed,
                s.fail_reason,
                ROUND(SUM(r.gradept * r.CreditUnits) / NULLIF(SUM(r.CreditUnits), 0), 2) AS cgpa
            FROM acad_student s
            INNER JOIN acad_results r ON s.regno = r.regno
            LEFT JOIN acad_programme p ON s.progid = p.progcode
            WHERE s.progid = @programme
              AND s.entryyear = @entryYear
              AND r.studyyear = @studyYear
              AND r.semester = @semester";
            
            List<string> entryParams = new List<string>();
            string[] entries = null;
            
            // If entry numbers specified, use them
            if (!string.IsNullOrEmpty(entryNumbers))
            {
                entries = entryNumbers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        entryParams.Add("@entry" + i);
                    sql += " AND s.entryno IN (" + string.Join(",", entryParams) + ")";
                }
            }
            
            sql += @" GROUP BY s.regno, s.entryno, s.firstname, s.othername, s.gender, p.progname, s.has_passed, s.fail_reason
                      HAVING cgpa IS NOT NULL AND cgpa >= 2.00
                      ORDER BY cgpa DESC";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@programme", programme);
                cmd.Parameters.AddWithValue("@entryYear", entryYear);
                cmd.Parameters.AddWithValue("@studyYear", studyYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                
                if (!string.IsNullOrEmpty(entryNumbers) && entries != null && entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        cmd.Parameters.AddWithValue("@entry" + i, entries[i].Trim());
                }
                
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }
        }
        
        return dt;
    }
    
    private void GeneratePerformanceReportPdf(DataTable data, string programmeName, string entryYear, string studyYear, string semester)
    {
        // Create DevExpress PrintingSystem
        DevExpress.XtraPrinting.PrintingSystem ps = new DevExpress.XtraPrinting.PrintingSystem();
        
        // Create custom link for PDF content
        DevExpress.XtraPrinting.Link pdfLink = new DevExpress.XtraPrinting.Link(ps);
        pdfLink.CreateDetailArea += (s, args) => {
            GeneratePerformanceReportContent(args.Graph, data, programmeName, entryYear, studyYear, semester);
        };
        
        // Set page settings for A4
        // A4 = 210mm x 297mm = 8.27" x 11.69"
        // Margins in hundredths of an inch: 50 = 0.5 inch
        ps.PageSettings.PaperKind = System.Drawing.Printing.PaperKind.A4;
        ps.PageSettings.Landscape = false;
        ps.PageSettings.LeftMargin = 50;
        ps.PageSettings.RightMargin = 50;
        ps.PageSettings.TopMargin = 50;
        ps.PageSettings.BottomMargin = 50;
        
        pdfLink.CreateDocument();
        
        // Export to PDF
        string fileName = string.Format("PerformanceSummary_{0}_{1}.pdf", entryYear.Replace("/", "-"), DateTime.Now.ToString("yyyyMMdd_HHmmss"));
        
        // Clear all response content and set proper headers for PDF
        Response.Clear();
        Response.Buffer = true;
        Response.ClearHeaders();
        Response.ClearContent();
        Response.ContentType = "application/pdf";
        Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
        Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
        
        using (System.IO.MemoryStream stream = new System.IO.MemoryStream())
        {
            ps.ExportToPdf(stream);
            byte[] pdfBytes = stream.ToArray();
            Response.AddHeader("Content-Length", pdfBytes.Length.ToString());
            Response.BinaryWrite(pdfBytes);
            Response.Flush();
        }
        
        try
        {
            Response.End();
        }
        catch (System.Threading.ThreadAbortException)
        {
            // Expected exception from Response.End() - ignore
        }
    }
    
    private void GeneratePerformanceReportContent(DevExpress.XtraPrinting.BrickGraphics gr, DataTable data, 
        string programmeName, string entryYear, string studyYear, string semester)
    {
        // Get university name and logo
        string universityName = GetUniversityName();
        string logoPath = Server.MapPath("~/COOPERP/images/welcomelogo.png");
        
        // Get academic year
        string academicYear = GetCurrentAcademicYear();
        
        // Colors
        System.Drawing.Color brandColor = System.Drawing.Color.FromArgb(23, 77, 164);
        System.Drawing.Color darkGray = System.Drawing.Color.FromArgb(51, 51, 51);
        System.Drawing.Color lightGray = System.Drawing.Color.FromArgb(102, 102, 102);
        System.Drawing.Color headerBg = System.Drawing.Color.FromArgb(52, 73, 94);
        System.Drawing.Color altRowColor = System.Drawing.Color.FromArgb(248, 248, 248);
        System.Drawing.Color borderColor = System.Drawing.Color.FromArgb(200, 200, 200);
        
        // Category colors
        System.Drawing.Color vcListColor = System.Drawing.Color.FromArgb(26, 84, 144);
        System.Drawing.Color deansListColor = System.Drawing.Color.FromArgb(46, 125, 50);
        System.Drawing.Color secondLowerColor = System.Drawing.Color.FromArgb(245, 124, 0);
        System.Drawing.Color passColor = System.Drawing.Color.FromArgb(198, 40, 40);
        
        // Fonts
        System.Drawing.Font uniNameFont = new System.Drawing.Font("Tahoma", 14, System.Drawing.FontStyle.Bold);
        System.Drawing.Font addressFont = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Regular);
        System.Drawing.Font titleFont = new System.Drawing.Font("Tahoma", 10, System.Drawing.FontStyle.Bold);
        System.Drawing.Font normalFont = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Regular);
        System.Drawing.Font boldNormalFont = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Bold);
        System.Drawing.Font categoryHeaderFont = new System.Drawing.Font("Tahoma", 9, System.Drawing.FontStyle.Bold);
        System.Drawing.Font tableHeaderFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Bold);
        System.Drawing.Font cellFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Regular);
        System.Drawing.Font smallFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Regular);
        System.Drawing.Font italicFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Italic);
        System.Drawing.Font summaryFont = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Bold);
        
        // Page width for content area - slightly increased for better margin balance
        float pageWidth = 555;
        float y = 0;
        
        // Categorize students by CGPA
        List<DataRow> vcListStudents = new List<DataRow>();
        List<DataRow> deansListStudents = new List<DataRow>();
        List<DataRow> secondLowerStudents = new List<DataRow>();
        List<DataRow> passStudents = new List<DataRow>();
        
        foreach (DataRow row in data.Rows)
        {
            decimal cgpa = row["cgpa"] != DBNull.Value ? Convert.ToDecimal(row["cgpa"]) : 0;
            if (cgpa >= 4.40m) vcListStudents.Add(row);
            else if (cgpa >= 3.60m) deansListStudents.Add(row);
            else if (cgpa >= 2.80m) secondLowerStudents.Add(row);
            else if (cgpa >= 2.00m) passStudents.Add(row);
        }
        
        // ========== HEADER SECTION - CLEAN LETTERHEAD STYLE ==========
        
        // University Name - Large, Centered, Bold
        DrawTextLine(gr, universityName, 0, y, pageWidth, 22, uniNameFont, brandColor, System.Drawing.StringAlignment.Center);
        y += 20;
        
        // Address line
        DrawTextLine(gr, "Mengo, Kampala, Uganda | Email: info@mru.ac.ug", 0, y, pageWidth, 12, addressFont, darkGray, System.Drawing.StringAlignment.Center);
        y += 14;
        
        // Programme Year Semester Academic Year - Bold Title Line
        string titleLine = string.Format("{0} YEAR {1} SEMESTER {2} {3}",
            programmeName.ToUpper(),
            !string.IsNullOrEmpty(studyYear) ? studyYear : "ALL",
            !string.IsNullOrEmpty(semester) ? semester : "ALL",
            academicYear);
        DrawTextLine(gr, titleLine, 0, y, pageWidth, 14, titleFont, darkGray, System.Drawing.StringAlignment.Center);
        y += 16;
        
        // Generated timestamp
        DrawTextLine(gr, "Generated: " + DateTime.Now.ToString("dddd, MMMM dd, yyyy - hh:mm tt"), 
            0, y, pageWidth, 11, smallFont, lightGray, System.Drawing.StringAlignment.Center);
        y += 14;

        // Horizontal line separator
        DevExpress.XtraPrinting.LineBrick lineBrick1 = new DevExpress.XtraPrinting.LineBrick();
        lineBrick1.ForeColor = brandColor;
        lineBrick1.LineStyle = System.Drawing.Drawing2D.DashStyle.Solid;
        lineBrick1.LineWidth = 2;
        lineBrick1.Sides = DevExpress.XtraPrinting.BorderSide.None;
        gr.DrawBrick(lineBrick1, new System.Drawing.RectangleF(0, y, pageWidth, 2));
        y += 8;
        
        // Introductory paragraph
        string introText = "On recommendation of the Faculty Board, the following results are hereby presented to the Senate Examinations Board for further consideration and onward presentation to the Senate for final approval in the categories indicated below:";
        y = DrawWrappedText(gr, introText, 0, y, pageWidth, normalFont, darkGray);
        y += 8;
        
        // ========== COLUMN WIDTHS - FULL PAGE WIDTH (555) ==========
        // Columns: #, REG NO, STUDENT NAME, GENDER, CGPA, STATUS, REASON
        float numWidth = 22;
        float regNoWidth = 130;
        float nameWidth = 145;
        float genderWidth = 45;
        float cgpaWidth = 40;
        float statusWidth = 50;
        float reasonWidth = pageWidth - numWidth - regNoWidth - nameWidth - genderWidth - cgpaWidth - statusWidth; // = 123
        float rowHeight = 20;
        
        // ========== DRAW EACH CATEGORY ==========
        
        // 1. VC's List (First Class)
        y = DrawPerformanceCategory(gr, vcListStudents, "1. VC'S LIST (FIRST CLASS)", vcListStudents.Count,
            "The following students obtained a CGPA between 4.40 and 5.00.",
            "No students meet the First Class criteria (CGPA 4.40 - 5.00)",
            vcListColor, y, pageWidth, rowHeight, categoryHeaderFont, tableHeaderFont, cellFont, normalFont, italicFont,
            numWidth, regNoWidth, nameWidth, genderWidth, cgpaWidth, statusWidth, reasonWidth,
            headerBg, altRowColor, borderColor);
        y += 10;
        
        // 2. Dean's List (Second Class Upper)
        y = DrawPerformanceCategory(gr, deansListStudents, "2. DEAN'S LIST (SECOND CLASS UPPER DIVISION)", deansListStudents.Count,
            "The following students obtained a CGPA between 3.60 and 4.39.",
            "No students meet the Second Class Upper criteria (CGPA 3.60 - 4.39)",
            deansListColor, y, pageWidth, rowHeight, categoryHeaderFont, tableHeaderFont, cellFont, normalFont, italicFont,
            numWidth, regNoWidth, nameWidth, genderWidth, cgpaWidth, statusWidth, reasonWidth,
            headerBg, altRowColor, borderColor);
        y += 10;
        
        // 3. Second Class Lower
        y = DrawPerformanceCategory(gr, secondLowerStudents, "3. SECOND CLASS LOWER DIVISION", secondLowerStudents.Count,
            "The following students obtained a CGPA between 2.80 and 3.59.",
            "No students in this category",
            secondLowerColor, y, pageWidth, rowHeight, categoryHeaderFont, tableHeaderFont, cellFont, normalFont, italicFont,
            numWidth, regNoWidth, nameWidth, genderWidth, cgpaWidth, statusWidth, reasonWidth,
            headerBg, altRowColor, borderColor);
        y += 10;
        
        // 4. Pass
        y = DrawPerformanceCategory(gr, passStudents, "4. PASS", passStudents.Count,
            "The following students obtained a CGPA between 2.00 and 2.79.",
            "No students in this category",
            passColor, y, pageWidth, rowHeight, categoryHeaderFont, tableHeaderFont, cellFont, normalFont, italicFont,
            numWidth, regNoWidth, nameWidth, genderWidth, cgpaWidth, statusWidth, reasonWidth,
            headerBg, altRowColor, borderColor);
        y += 15;
        
        // ========== OVERALL SUMMARY ==========
        DevExpress.XtraPrinting.LineBrick summaryLine = new DevExpress.XtraPrinting.LineBrick();
        summaryLine.ForeColor = brandColor;
        summaryLine.LineStyle = System.Drawing.Drawing2D.DashStyle.Solid;
        summaryLine.LineWidth = 1;
        summaryLine.Sides = DevExpress.XtraPrinting.BorderSide.None;
        gr.DrawBrick(summaryLine, new System.Drawing.RectangleF(0, y, pageWidth, 1));
        y += 8;
        
        string overallSummary = string.Format("OVERALL SUMMARY: First Class: {0} | Second Class Upper: {1} | Second Class Lower: {2} | Pass: {3} | TOTAL: {4}",
            vcListStudents.Count, deansListStudents.Count, secondLowerStudents.Count, passStudents.Count, data.Rows.Count);
        
        DevExpress.XtraPrinting.TextBrick summaryBrick = new DevExpress.XtraPrinting.TextBrick();
        summaryBrick.Text = overallSummary;
        summaryBrick.Font = summaryFont;
        summaryBrick.ForeColor = System.Drawing.Color.White;
        summaryBrick.BackColor = brandColor;
        summaryBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        summaryBrick.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 4, 4);
        summaryBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(summaryBrick, new System.Drawing.RectangleF(0, y, pageWidth, 22));
        y += 30;
        
        // ========== FOOTER ==========
        DevExpress.XtraPrinting.LineBrick footerLine = new DevExpress.XtraPrinting.LineBrick();
        footerLine.ForeColor = brandColor;
        footerLine.LineStyle = System.Drawing.Drawing2D.DashStyle.Solid;
        footerLine.LineWidth = 1;
        footerLine.Sides = DevExpress.XtraPrinting.BorderSide.None;
        gr.DrawBrick(footerLine, new System.Drawing.RectangleF(0, y, pageWidth, 1));
        y += 8;
        
        // University name centered
        DrawTextLine(gr, universityName, 0, y, pageWidth, 14, titleFont, brandColor, System.Drawing.StringAlignment.Center);
        y += 16;
        
        // Computer generated notice
        DrawTextLine(gr, "This is a computer-generated report. No signature required.", 0, y, pageWidth, 12, italicFont, lightGray, System.Drawing.StringAlignment.Center);
        y += 14;
        
        // Copyright
        string copyright = "© " + DateTime.Now.Year + " " + universityName + ". All Rights Reserved.";
        DrawTextLine(gr, copyright, 0, y, pageWidth, 12, smallFont, lightGray, System.Drawing.StringAlignment.Center);
    }
    
    private void DrawTextLine(DevExpress.XtraPrinting.BrickGraphics gr, string text, float x, float y, 
        float width, float height, System.Drawing.Font font, System.Drawing.Color color, System.Drawing.StringAlignment align)
    {
        DevExpress.XtraPrinting.TextBrick brick = new DevExpress.XtraPrinting.TextBrick();
        brick.Text = text;
        brick.Font = font;
        brick.ForeColor = color;
        brick.BackColor = System.Drawing.Color.Transparent;
        brick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        brick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(align);
        gr.DrawBrick(brick, new System.Drawing.RectangleF(x, y, width, height));
    }
    
    private float DrawWrappedText(DevExpress.XtraPrinting.BrickGraphics gr, string text, float x, float y, 
        float width, System.Drawing.Font font, System.Drawing.Color color)
    {
        DevExpress.XtraPrinting.TextBrick brick = new DevExpress.XtraPrinting.TextBrick();
        brick.Text = text;
        brick.Font = font;
        brick.ForeColor = color;
        brick.BackColor = System.Drawing.Color.Transparent;
        brick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        brick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Near);
        
        // Estimate height needed for wrapped text (approximately 12 pixels per line, ~80 chars per line)
        int estimatedLines = (int)Math.Ceiling(text.Length / 90.0);
        float height = estimatedLines * 14;
        
        gr.DrawBrick(brick, new System.Drawing.RectangleF(x, y, width, height));
        return y + height;
    }
    
    private float DrawPerformanceCategory(DevExpress.XtraPrinting.BrickGraphics gr, List<DataRow> students,
        string categoryTitle, int studentCount, string description, string emptyMessage,
        System.Drawing.Color categoryColor, float y, float pageWidth,
        float rowHeight, System.Drawing.Font categoryFont, System.Drawing.Font headerFont, System.Drawing.Font cellFont,
        System.Drawing.Font normalFont, System.Drawing.Font italicFont,
        float numWidth, float regNoWidth, float nameWidth, float genderWidth, float cgpaWidth, float statusWidth, float reasonWidth,
        System.Drawing.Color headerBg, System.Drawing.Color altRowColor, System.Drawing.Color borderColor)
    {
        // Category header: "1. VC'S LIST (FIRST CLASS) 0 STUDENTS"
        string headerText = string.Format("{0}   {1} STUDENTS", categoryTitle, studentCount);
        DevExpress.XtraPrinting.TextBrick categoryBrick = new DevExpress.XtraPrinting.TextBrick();
        categoryBrick.Text = headerText;
        categoryBrick.Font = categoryFont;
        categoryBrick.ForeColor = System.Drawing.Color.White;
        categoryBrick.BackColor = categoryColor;
        categoryBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        categoryBrick.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 3, 3);
        categoryBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Near);
        gr.DrawBrick(categoryBrick, new System.Drawing.RectangleF(0, y, pageWidth, 20));
        y += 22;
        
        // Description line
        DrawTextLine(gr, description, 0, y, pageWidth, 14, normalFont, System.Drawing.Color.FromArgb(51, 51, 51), System.Drawing.StringAlignment.Near);
        y += 16;
        
        if (students.Count == 0)
        {
            // Empty message in italics
            DrawTextLine(gr, emptyMessage, 0, y, pageWidth, 14, italicFont, System.Drawing.Color.Gray, System.Drawing.StringAlignment.Near);
            y += 16;
        }
        else
        {
            // Table header row - Columns: #, REG NO, NAME, GENDER, CGPA, STATUS, REASON
            float x = 0;
            DrawTableHeaderCell(gr, "#", x, y, numWidth, rowHeight, headerFont, headerBg, borderColor); x += numWidth;
            DrawTableHeaderCell(gr, "REG NO", x, y, regNoWidth, rowHeight, headerFont, headerBg, borderColor); x += regNoWidth;
            DrawTableHeaderCell(gr, "STUDENT NAME", x, y, nameWidth, rowHeight, headerFont, headerBg, borderColor); x += nameWidth;
            DrawTableHeaderCell(gr, "GENDER", x, y, genderWidth, rowHeight, headerFont, headerBg, borderColor); x += genderWidth;
            DrawTableHeaderCell(gr, "CGPA", x, y, cgpaWidth, rowHeight, headerFont, headerBg, borderColor); x += cgpaWidth;
            DrawTableHeaderCell(gr, "STATUS", x, y, statusWidth, rowHeight, headerFont, headerBg, borderColor); x += statusWidth;
            DrawTableHeaderCell(gr, "REASON", x, y, reasonWidth, rowHeight, headerFont, headerBg, borderColor);
            y += rowHeight;
            
            // Data rows
            int rowNum = 1;
            foreach (DataRow row in students)
            {
                x = 0;
                System.Drawing.Color rowBg = rowNum % 2 == 0 ? altRowColor : System.Drawing.Color.White;
                
                DrawTableDataCell(gr, rowNum.ToString(), x, y, numWidth, rowHeight, cellFont, rowBg, borderColor, System.Drawing.StringAlignment.Center); x += numWidth;
                DrawTableDataCell(gr, row["regno"].ToString(), x, y, regNoWidth, rowHeight, cellFont, rowBg, borderColor, System.Drawing.StringAlignment.Near); x += regNoWidth;
                DrawTableDataCell(gr, row["student_name"].ToString(), x, y, nameWidth, rowHeight, cellFont, rowBg, borderColor, System.Drawing.StringAlignment.Near); x += nameWidth;
                DrawTableDataCell(gr, row["gender"].ToString(), x, y, genderWidth, rowHeight, cellFont, rowBg, borderColor, System.Drawing.StringAlignment.Center); x += genderWidth;
                
                decimal cgpa = row["cgpa"] != DBNull.Value ? Convert.ToDecimal(row["cgpa"]) : 0;
                DrawTableDataCell(gr, cgpa.ToString("F2"), x, y, cgpaWidth, rowHeight, cellFont, rowBg, borderColor, System.Drawing.StringAlignment.Center); x += cgpaWidth;
                
                // Status column with color coding - has_passed is VARCHAR(5) with 'Yes' or 'No'
                string hasPassedValue = row["has_passed"] != DBNull.Value ? row["has_passed"].ToString() : "No";
                bool hasPassed = hasPassedValue.Equals("Yes", StringComparison.OrdinalIgnoreCase);
                string statusText = hasPassed ? "PASS" : "FAIL";
                System.Drawing.Color statusBgColor = hasPassed ? System.Drawing.Color.FromArgb(200, 230, 200) : System.Drawing.Color.FromArgb(255, 200, 200);
                System.Drawing.Color statusTextColor = hasPassed ? System.Drawing.Color.FromArgb(34, 139, 34) : System.Drawing.Color.FromArgb(178, 34, 34);
                DrawStatusCell(gr, statusText, x, y, statusWidth, rowHeight, cellFont, statusBgColor, statusTextColor, borderColor); x += statusWidth;
                
                // Reason column
                string failReason = row["fail_reason"] != DBNull.Value ? row["fail_reason"].ToString() : "";
                DrawTableDataCell(gr, failReason, x, y, reasonWidth, rowHeight, cellFont, rowBg, borderColor, System.Drawing.StringAlignment.Near);
                
                y += rowHeight;
                rowNum++;
            }
        }
        
        return y;
    }
    
    private void DrawStatusCell(DevExpress.XtraPrinting.BrickGraphics gr, string text, float x, float y, 
        float width, float height, System.Drawing.Font font, System.Drawing.Color bgColor, System.Drawing.Color textColor, System.Drawing.Color borderColor)
    {
        DevExpress.XtraPrinting.TextBrick brick = new DevExpress.XtraPrinting.TextBrick();
        brick.Text = text;
        brick.Font = font;
        brick.ForeColor = textColor;
        brick.BackColor = bgColor;
        brick.Sides = DevExpress.XtraPrinting.BorderSide.All;
        brick.BorderColor = borderColor;
        brick.BorderWidth = 1;
        brick.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 4, 4);
        brick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(brick, new System.Drawing.RectangleF(x, y, width, height));
    }
    
    private void DrawTableHeaderCell(DevExpress.XtraPrinting.BrickGraphics gr, string text, float x, float y, 
        float width, float height, System.Drawing.Font font, System.Drawing.Color bgColor, System.Drawing.Color borderColor)
    {
        DevExpress.XtraPrinting.TextBrick brick = new DevExpress.XtraPrinting.TextBrick();
        brick.Text = text;
        brick.Font = font;
        brick.ForeColor = System.Drawing.Color.White;
        brick.BackColor = bgColor;
        brick.Sides = DevExpress.XtraPrinting.BorderSide.All;
        brick.BorderColor = System.Drawing.Color.FromArgb(70, 90, 110);
        brick.BorderWidth = 1;
        brick.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 5, 5);
        brick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(brick, new System.Drawing.RectangleF(x, y, width, height));
    }
    
    private void DrawTableDataCell(DevExpress.XtraPrinting.BrickGraphics gr, string text, float x, float y, 
        float width, float height, System.Drawing.Font font, System.Drawing.Color bgColor, System.Drawing.Color borderColor, System.Drawing.StringAlignment align)
    {
        DevExpress.XtraPrinting.TextBrick brick = new DevExpress.XtraPrinting.TextBrick();
        brick.Text = text;
        brick.Font = font;
        brick.ForeColor = System.Drawing.Color.FromArgb(51, 51, 51);
        brick.BackColor = bgColor;
        brick.Sides = DevExpress.XtraPrinting.BorderSide.All;
        brick.BorderColor = borderColor;
        brick.BorderWidth = 1;
        brick.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 4, 4);
        brick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(align);
        gr.DrawBrick(brick, new System.Drawing.RectangleF(x, y, width, height));
    }

    /// <summary>
    /// Gets detailed student and results data for the summary report.
    /// </summary>
    private DataTable GetSummaryReportData(string programme, string entryYear, string studyYear, string semester, string entryNumbers)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Query to get student details and their results with specialization
            string sql = @"SELECT 
                            s.regno, 
                            s.entryno,
                            CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) AS student_name,
                            s.firstname,
                            s.othername,
                            s.entryyear,
                            s.progid,
                            p.progname,
                            s.specialisation AS spec_id,
                            CASE WHEN sp.spec IS NULL OR TRIM(sp.spec) = '' OR TRIM(sp.spec) = '-' THEN 'General' ELSE TRIM(sp.spec) END AS specialization,
                            r.courseid,
                            c.courseName AS course_title,
                            r.semester AS result_semester,
                            r.acad AS academic_year,
                            r.studyyear,
                            r.score,
                            r.grade,
                            r.gradept,
                            r.CreditUnits,
                            r.gpa
                           FROM acad_student s
                           INNER JOIN acad_results r ON s.regno = r.regno
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           LEFT JOIN acad_course c ON r.courseid = c.courseID
                           LEFT JOIN acad_specialisation sp ON s.specialisation = sp.spec_id
                           WHERE 1=1";
            
            List<string> entryParams = new List<string>();
            string[] entries = null;
            
            // If entry numbers specified, use them
            if (!string.IsNullOrEmpty(entryNumbers))
            {
                entries = entryNumbers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        entryParams.Add("@entry" + i);
                    sql += " AND s.entryno IN (" + string.Join(",", entryParams) + ")";
                }
            }
            
            // Always filter by programme, entry year, study year, and semester
            if (!string.IsNullOrEmpty(programme))
                sql += " AND s.progid = @programme";
            if (!string.IsNullOrEmpty(entryYear))
                sql += " AND s.entryyear = @entryYear";
            if (!string.IsNullOrEmpty(studyYear))
                sql += " AND r.studyyear = @studyYear";
            if (!string.IsNullOrEmpty(semester))
                sql += " AND r.semester = @semester";
            
            sql += " ORDER BY s.entryno, r.semester, r.courseid";
            
            DataTable dt = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(entryNumbers) && entries != null && entries.Length > 0)
                {
                    for (int i = 0; i < entries.Length; i++)
                        cmd.Parameters.AddWithValue("@entry" + i, entries[i].Trim());
                }
                
                if (!string.IsNullOrEmpty(programme))
                    cmd.Parameters.AddWithValue("@programme", programme);
                if (!string.IsNullOrEmpty(entryYear))
                    cmd.Parameters.AddWithValue("@entryYear", entryYear);
                if (!string.IsNullOrEmpty(studyYear))
                    cmd.Parameters.AddWithValue("@studyYear", studyYear);
                if (!string.IsNullOrEmpty(semester))
                    cmd.Parameters.AddWithValue("@semester", semester);
                
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            
            return dt;
        }
    }
    
    /// <summary>
    /// Gets the university name from acad_university table.
    /// </summary>
    private string GetUniversityName()
    {
        string universityName = "UNIVERSITY"; // Default fallback
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("SELECT university_name FROM acad_university LIMIT 1", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        universityName = result.ToString().ToUpper();
                    }
                }
            }
        }
        catch { }
        return universityName;
    }
    
    /// <summary>
    /// Gets the current academic year from acad_calender or derives from current date.
    /// </summary>
    private string GetCurrentAcademicYear()
    {
        string academicYear = "";
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                // Try to get from academic calendar
                using (MySqlCommand cmd = new MySqlCommand("SELECT academic_year FROM acad_calender WHERE is_current = 1 LIMIT 1", conn))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        academicYear = result.ToString();
                    }
                }
            }
        }
        catch { }
        
        // Fallback: derive from current date
        if (string.IsNullOrEmpty(academicYear))
        {
            int year = DateTime.Now.Year;
            int month = DateTime.Now.Month;
            // Academic year typically starts in August/September
            if (month >= 8)
                academicYear = string.Format("{0}/{1}", year, year + 1);
            else
                academicYear = string.Format("{0}/{1}", year - 1, year);
        }
        
        return academicYear;
    }
    
    /// <summary>
    /// Normalizes a specialization name so that equivalent text variants group together.
    /// Handles: case, separators (& → AND), whitespace, and parenthetical spacing.
    /// IMPORTANT: Subject order is preserved — "GEOGRAPHY AND HISTORY" is a different
    /// specialization from "HISTORY AND GEOGRAPHY" (first subject = primary/major).
    /// </summary>
    private string NormalizeSpecializationName(string name)
    {
        if (string.IsNullOrEmpty(name) || name.Trim().Length == 0)
            return "GENERAL";
        
        string n = name.Trim().ToUpper();
        
        // Treat dash, "0", "GENERAL", or any single non-letter character as no-specialization
        if (n == "GENERAL" || n == "-" || n == "0" || n == "N/A" || n == "NONE")
            return "GENERAL";
        
        // Replace & with AND (the canonical separator)
        n = n.Replace("&", " AND ");
        
        // Normalize spacing before parentheses: "RELIGION(" → "RELIGION ("
        n = n.Replace("(", " (");
        
        // Collapse multiple spaces to single space
        while (n.Contains("  "))
            n = n.Replace("  ", " ");
        
        n = n.Trim();
        
        // Trim individual parts but do NOT reorder — subject order is significant
        string[] parts = n.Split(new string[] { " AND " }, StringSplitOptions.RemoveEmptyEntries);
        for (int i = 0; i < parts.Length; i++)
            parts[i] = parts[i].Trim();
        
        return string.Join(" AND ", parts);
    }
    
    /// <summary>
    /// Gets curriculum validation info for a specialization, study year, and semester.
    /// Returns: spec_id, curriculum_course_count, is_fully_set, programme default spec_id if applicable
    /// </summary>
    private class CurriculumInfo
    {
        public string SpecId { get; set; }
        public int CurriculumCourseCount { get; set; }
        public bool IsFullySet { get; set; }
        public bool IsDefault { get; set; }
        public string SpecName { get; set; }
    }
    
    private CurriculumInfo GetCurriculumInfo(string specId, string progId, string studyYear, string semester)
    {
        CurriculumInfo info = new CurriculumInfo
        {
            SpecId = specId,
            CurriculumCourseCount = 0,
            IsFullySet = false,
            IsDefault = false,
            SpecName = ""
        };
        
        try
        {
            // Normalise specId: treat "-", "0", whitespace-only as empty (unassigned)
            string cleanSpecId = (specId ?? "").Trim();
            bool needDefault = string.IsNullOrEmpty(cleanSpecId) || cleanSpecId == "0" || cleanSpecId == "-";
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                if (needDefault)
                {
                    // Strategy 1: Find specialisation marked as default
                    string defaultSpecSql = @"SELECT spec_id, spec, COALESCE(is_fully_set, 'No') AS is_fully_set 
                                              FROM acad_specialisation 
                                              WHERE prog_id = @progId AND is_default = 'Yes' 
                                              LIMIT 1";
                    using (MySqlCommand cmd = new MySqlCommand(defaultSpecSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@progId", progId);
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                info.SpecId = reader["spec_id"].ToString().Trim();
                                info.SpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString().Trim() : "";
                                info.IsFullySet = reader["is_fully_set"] != DBNull.Value 
                                    && reader["is_fully_set"].ToString().Trim().Equals("Yes", StringComparison.OrdinalIgnoreCase);
                                info.IsDefault = true;
                            }
                        }
                    }
                    
                    // Strategy 2: Find specialisation named 'Default'
                    if (string.IsNullOrEmpty(info.SpecId) || info.SpecId == "0")
                    {
                        string namedDefaultSql = @"SELECT spec_id, spec, COALESCE(is_fully_set, 'No') AS is_fully_set 
                                                   FROM acad_specialisation 
                                                   WHERE prog_id = @progId AND (spec = 'Default' OR spec LIKE '%Default%')
                                                   ORDER BY spec_id LIMIT 1";
                        using (MySqlCommand cmd = new MySqlCommand(namedDefaultSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@progId", progId);
                            using (MySqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    info.SpecId = reader["spec_id"].ToString().Trim();
                                    info.SpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString().Trim() : "";
                                    info.IsFullySet = reader["is_fully_set"] != DBNull.Value 
                                        && reader["is_fully_set"].ToString().Trim().Equals("Yes", StringComparison.OrdinalIgnoreCase);
                                    info.IsDefault = true;
                                }
                            }
                        }
                    }
                    
                    // Strategy 3: Fall back to the first specialisation for this programme
                    if (string.IsNullOrEmpty(info.SpecId) || info.SpecId == "0")
                    {
                        string firstSpecSql = @"SELECT spec_id, spec, COALESCE(is_fully_set, 'No') AS is_fully_set 
                                                FROM acad_specialisation 
                                                WHERE prog_id = @progId 
                                                ORDER BY spec_id LIMIT 1";
                        using (MySqlCommand cmd = new MySqlCommand(firstSpecSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@progId", progId);
                            using (MySqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    info.SpecId = reader["spec_id"].ToString().Trim();
                                    info.SpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString().Trim() : "";
                                    info.IsFullySet = reader["is_fully_set"] != DBNull.Value 
                                        && reader["is_fully_set"].ToString().Trim().Equals("Yes", StringComparison.OrdinalIgnoreCase);
                                    info.IsDefault = true;
                                }
                            }
                        }
                    }
                }
                else
                {
                    // Student has a valid spec_id — look it up directly
                    string specSql = @"SELECT spec, COALESCE(is_fully_set, 'No') AS is_fully_set 
                                       FROM acad_specialisation WHERE spec_id = @specId";
                    using (MySqlCommand cmd = new MySqlCommand(specSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", cleanSpecId);
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                info.SpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString().Trim() : "";
                                info.IsFullySet = reader["is_fully_set"] != DBNull.Value 
                                    && reader["is_fully_set"].ToString().Trim().Equals("Yes", StringComparison.OrdinalIgnoreCase);
                            }
                        }
                    }
                    info.SpecId = cleanSpecId;
                }
                
                // Get curriculum course count for this spec + study_year + semester
                if (!string.IsNullOrEmpty(info.SpecId) && info.SpecId != "0")
                {
                    string countSql = @"SELECT COUNT(*) FROM acad_programmecourses 
                                        WHERE specialisation_id = @specId 
                                        AND study_year = @studyYear 
                                        AND semester = @semester";
                    using (MySqlCommand cmd = new MySqlCommand(countSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", info.SpecId);
                        cmd.Parameters.AddWithValue("@studyYear", studyYear);
                        cmd.Parameters.AddWithValue("@semester", semester);
                        object result = cmd.ExecuteScalar();
                        info.CurriculumCourseCount = result != null ? Convert.ToInt32(result) : 0;
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("GetCurriculumInfo error: " + ex.Message);
        }
        
        return info;
    }
    
    /// <summary>
    /// Generates a PDF summary report grouped by specialization with courses as columns.
    /// </summary>
    private void GenerateSummaryReportPdf(DataTable data, string studyYear, string semester, string entryYear)
    {
        string universityName = GetUniversityName();
        string progName = data.Rows.Count > 0 && data.Rows[0]["progname"] != DBNull.Value 
            ? data.Rows[0]["progname"].ToString() : "";
        
        // Get logo path
        string logoPath = Server.MapPath("~/COOPERP/images/welcomelogo.png");
        
        // Group by spec_id (the database primary key) to ensure each specialization
        // is displayed EXACTLY as it exists in acad_specialisation — no fabrication, no merging.
        // Students with no specialization (null/0/-/empty) group together under key "0".
        var specializationGroups = data.AsEnumerable()
            .GroupBy(r => {
                string sid = r["spec_id"] != DBNull.Value ? r["spec_id"].ToString().Trim() : "0";
                if (string.IsNullOrEmpty(sid) || sid == "-") sid = "0";
                return sid;
            })
            .OrderBy(g => g.Key == "0" ? 1 : 0)  // No-specialization group goes LAST
            .ThenBy(g => {
                // Sort named groups by their display name from the DB
                string raw = g.First()["specialization"] != DBNull.Value ? g.First()["specialization"].ToString().Trim() : "";
                return raw;
            })
            .ToList();
        
        using (DevExpress.XtraPrinting.PrintingSystem ps = new DevExpress.XtraPrinting.PrintingSystem())
        {
            DevExpress.XtraPrinting.Link link = new DevExpress.XtraPrinting.Link(ps);
            
            // Set paper to A4 Landscape with minimal margins
            link.PaperKind = System.Drawing.Printing.PaperKind.A4;
            link.Landscape = true;
            link.Margins = new System.Drawing.Printing.Margins(10, 10, 10, 10);
            
            link.CreateDetailArea += (sender, e) => {
                DevExpress.XtraPrinting.BrickGraphics gr = e.Graph;
                
                // Fonts - reduced sizes
                System.Drawing.Font uniNameFont = new System.Drawing.Font("Tahoma", 12, System.Drawing.FontStyle.Bold);
                System.Drawing.Font reportTitleFont = new System.Drawing.Font("Tahoma", 10, System.Drawing.FontStyle.Bold);
                System.Drawing.Font progNameFont = new System.Drawing.Font("Tahoma", 9, System.Drawing.FontStyle.Bold);
                System.Drawing.Font filterLabelFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Bold);
                System.Drawing.Font filterValueFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Regular);
                System.Drawing.Font subtitleFont = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Bold);
                System.Drawing.Font headerFont = new System.Drawing.Font("Tahoma", 6, System.Drawing.FontStyle.Bold);
                System.Drawing.Font cellFont = new System.Drawing.Font("Tahoma", 6, System.Drawing.FontStyle.Regular);
                System.Drawing.Font smallFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Regular);
                System.Drawing.Font dateFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Regular);
                
                // Colors
                System.Drawing.Color brandColor = System.Drawing.Color.FromArgb(23, 77, 164); // University blue
                System.Drawing.Color darkGray = System.Drawing.Color.FromArgb(51, 51, 51);
                System.Drawing.Color lightGray = System.Drawing.Color.FromArgb(102, 102, 102);
                System.Drawing.Color filterBgColor = System.Drawing.Color.FromArgb(248, 249, 250);
                System.Drawing.Color filterBorderColor = System.Drawing.Color.FromArgb(222, 226, 230);
                System.Drawing.Color headerBg = System.Drawing.Color.FromArgb(52, 73, 94);
                System.Drawing.Color specHeaderBg = System.Drawing.Color.FromArgb(44, 62, 80);
                System.Drawing.Color altRowColor = System.Drawing.Color.FromArgb(245, 245, 245);
                System.Drawing.Color borderColor = System.Drawing.Color.FromArgb(150, 150, 150);
                System.Drawing.Color lineColor = System.Drawing.Color.FromArgb(23, 77, 164);
                
                float y = 0;
                float pageWidth = 822; // A4 landscape (842) minus margins (20)
                float logoWidth = 120;
                float logoHeight = 40;
                
                // ========== PROFESSIONAL REPORT HEADER ==========
                
                // Logo on the left
                if (System.IO.File.Exists(logoPath))
                {
                    try
                    {
                        System.Drawing.Image logoImg = System.Drawing.Image.FromFile(logoPath);
                        DevExpress.XtraPrinting.ImageBrick logoBrick = new DevExpress.XtraPrinting.ImageBrick();
                        logoBrick.Image = logoImg;
                        logoBrick.SizeMode = DevExpress.XtraPrinting.ImageSizeMode.ZoomImage;
                        logoBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                        gr.DrawBrick(logoBrick, new System.Drawing.RectangleF(5, y + 5, logoWidth, logoHeight));
                    }
                    catch { }
                }
                
                // University Name - centered
                DevExpress.XtraPrinting.TextBrick uniNameBrick = new DevExpress.XtraPrinting.TextBrick();
                uniNameBrick.Text = universityName;
                uniNameBrick.Font = uniNameFont;
                uniNameBrick.ForeColor = brandColor;
                uniNameBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                uniNameBrick.BackColor = System.Drawing.Color.Transparent;
                uniNameBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(uniNameBrick, new System.Drawing.RectangleF(0, y + 5, pageWidth, 18));
                
                // Report Title - centered
                DevExpress.XtraPrinting.TextBrick reportTitleBrick = new DevExpress.XtraPrinting.TextBrick();
                reportTitleBrick.Text = "STUDENT RESULTS SUMMARY REPORT";
                reportTitleBrick.Font = reportTitleFont;
                reportTitleBrick.ForeColor = darkGray;
                reportTitleBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                reportTitleBrick.BackColor = System.Drawing.Color.Transparent;
                reportTitleBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(reportTitleBrick, new System.Drawing.RectangleF(0, y + 26, pageWidth, 16));
                
                y += 48;
                
                // Horizontal line separator
                DevExpress.XtraPrinting.LineBrick lineBrick1 = new DevExpress.XtraPrinting.LineBrick();
                lineBrick1.ForeColor = lineColor;
                lineBrick1.LineStyle = System.Drawing.Drawing2D.DashStyle.Solid;
                lineBrick1.LineWidth = 2;
                lineBrick1.Sides = DevExpress.XtraPrinting.BorderSide.None;
                gr.DrawBrick(lineBrick1, new System.Drawing.RectangleF(0, y, pageWidth, 2));
                y += 6;
                
                // ========== FILTER INFORMATION BOX ==========
                float filterBoxHeight = 38;
                float filterBoxY = y;
                
                // Filter background box
                DevExpress.XtraPrinting.TextBrick filterBgBrick = new DevExpress.XtraPrinting.TextBrick();
                filterBgBrick.Text = "";
                filterBgBrick.BackColor = filterBgColor;
                filterBgBrick.Sides = DevExpress.XtraPrinting.BorderSide.All;
                filterBgBrick.BorderColor = filterBorderColor;
                filterBgBrick.BorderWidth = 1;
                gr.DrawBrick(filterBgBrick, new System.Drawing.RectangleF(0, filterBoxY, pageWidth, filterBoxHeight));
                
                // Programme row
                float labelWidth = 80;
                float valueWidth = 320;
                float col1X = 10;
                float col2X = pageWidth / 2 + 10;
                float row1Y = filterBoxY + 5;
                float row2Y = filterBoxY + 20;
                
                // Programme Label
                DevExpress.XtraPrinting.TextBrick progLabelBrick = new DevExpress.XtraPrinting.TextBrick();
                progLabelBrick.Text = "Programme:";
                progLabelBrick.Font = filterLabelFont;
                progLabelBrick.ForeColor = darkGray;
                progLabelBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                progLabelBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(progLabelBrick, new System.Drawing.RectangleF(col1X, row1Y, labelWidth, 14));
                
                // Programme Value
                DevExpress.XtraPrinting.TextBrick progValueBrick = new DevExpress.XtraPrinting.TextBrick();
                progValueBrick.Text = progName;
                progValueBrick.Font = filterValueFont;
                progValueBrick.ForeColor = brandColor;
                progValueBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                progValueBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(progValueBrick, new System.Drawing.RectangleF(col1X + labelWidth, row1Y, valueWidth, 14));
                
                // Entry Year Label
                DevExpress.XtraPrinting.TextBrick entryLabelBrick = new DevExpress.XtraPrinting.TextBrick();
                entryLabelBrick.Text = "Entry Year:";
                entryLabelBrick.Font = filterLabelFont;
                entryLabelBrick.ForeColor = darkGray;
                entryLabelBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                entryLabelBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(entryLabelBrick, new System.Drawing.RectangleF(col2X, row1Y, labelWidth, 14));
                
                // Entry Year Value
                DevExpress.XtraPrinting.TextBrick entryValueBrick = new DevExpress.XtraPrinting.TextBrick();
                entryValueBrick.Text = !string.IsNullOrEmpty(entryYear) ? entryYear : "All";
                entryValueBrick.Font = filterValueFont;
                entryValueBrick.ForeColor = brandColor;
                entryValueBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                entryValueBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(entryValueBrick, new System.Drawing.RectangleF(col2X + labelWidth, row1Y, 100, 14));
                
                // Year of Study Label
                DevExpress.XtraPrinting.TextBrick studyLabelBrick = new DevExpress.XtraPrinting.TextBrick();
                studyLabelBrick.Text = "Year of Study:";
                studyLabelBrick.Font = filterLabelFont;
                studyLabelBrick.ForeColor = darkGray;
                studyLabelBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                studyLabelBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(studyLabelBrick, new System.Drawing.RectangleF(col1X, row2Y, labelWidth, 14));
                
                // Year of Study Value
                DevExpress.XtraPrinting.TextBrick studyValueBrick = new DevExpress.XtraPrinting.TextBrick();
                studyValueBrick.Text = !string.IsNullOrEmpty(studyYear) ? "Year " + studyYear : "All";
                studyValueBrick.Font = filterValueFont;
                studyValueBrick.ForeColor = brandColor;
                studyValueBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                studyValueBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(studyValueBrick, new System.Drawing.RectangleF(col1X + labelWidth, row2Y, 100, 14));
                
                // Semester Label
                DevExpress.XtraPrinting.TextBrick semLabelBrick = new DevExpress.XtraPrinting.TextBrick();
                semLabelBrick.Text = "Semester:";
                semLabelBrick.Font = filterLabelFont;
                semLabelBrick.ForeColor = darkGray;
                semLabelBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                semLabelBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(semLabelBrick, new System.Drawing.RectangleF(col2X, row2Y, labelWidth, 14));
                
                // Semester Value
                DevExpress.XtraPrinting.TextBrick semValueBrick = new DevExpress.XtraPrinting.TextBrick();
                semValueBrick.Text = !string.IsNullOrEmpty(semester) ? "Semester " + semester : "All";
                semValueBrick.Font = filterValueFont;
                semValueBrick.ForeColor = brandColor;
                semValueBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                semValueBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(semValueBrick, new System.Drawing.RectangleF(col2X + labelWidth, row2Y, 100, 14));
                
                // Generated Date on the right side of filter box
                DevExpress.XtraPrinting.TextBrick dateLabelBrick = new DevExpress.XtraPrinting.TextBrick();
                dateLabelBrick.Text = "Generated: " + DateTime.Now.ToString("dd MMM yyyy, HH:mm");
                dateLabelBrick.Font = dateFont;
                dateLabelBrick.ForeColor = lightGray;
                dateLabelBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                dateLabelBrick.BackColor = System.Drawing.Color.Transparent;
                dateLabelBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Far);
                gr.DrawBrick(dateLabelBrick, new System.Drawing.RectangleF(pageWidth - 200, row2Y, 190, 14));
                
                y = filterBoxY + filterBoxHeight + 8;
                
                // ========== SPECIALIZATION SECTIONS ==========
                foreach (var specGroup in specializationGroups)
                {
                    // Use the EXACT spec name from acad_specialisation — no fabrication
                    string specName;
                    if (specGroup.Key == "0")
                    {
                        specName = "NOT ASSIGNED";
                    }
                    else
                    {
                        // Get the spec name directly from the DB row (already TRIM'd in SQL)
                        specName = specGroup.First()["specialization"] != DBNull.Value 
                            ? specGroup.First()["specialization"].ToString().Trim() : "NOT ASSIGNED";
                        if (string.IsNullOrEmpty(specName) || specName == "General" || specName == "-")
                            specName = "NOT ASSIGNED";
                    }
                    
                    // Get programme and spec_id from the group key
                    string progId = specGroup.First()["progid"] != DBNull.Value ? specGroup.First()["progid"].ToString() : "";
                    string specId = specGroup.Key; // This is the actual spec_id from the database
                    
                    // Get curriculum validation info for this exact spec_id
                    CurriculumInfo curricInfo = GetCurriculumInfo(
                        specId != "0" ? specId : "", progId, studyYear, semester);
                    
                    // Get unique courses for this specialization
                    var courses = specGroup
                        .Select(r => new { 
                            Code = r["courseid"] != DBNull.Value ? r["courseid"].ToString() : "",
                            Title = r["course_title"] != DBNull.Value ? r["course_title"].ToString() : ""
                        })
                        .Where(c => !string.IsNullOrEmpty(c.Code))
                        .Distinct()
                        .OrderBy(c => c.Code)
                        .ToList();
                    
                    if (courses.Count == 0) continue;
                    
                    // Get unique students in this specialization
                    var students = specGroup
                        .GroupBy(r => r["entryno"].ToString())
                        .Select(g => new {
                            EntryNo = g.Key,
                            RegNo = g.First()["regno"] != DBNull.Value ? g.First()["regno"].ToString() : "",
                            Name = g.First()["student_name"] != DBNull.Value ? g.First()["student_name"].ToString() : "",
                            Results = g.ToList()
                        })
                        .OrderBy(s => s.Name)
                        .ToList();
                    
                    if (students.Count == 0) continue;
                    
                    // Calculate column widths - now including Status column
                    float snWidth = 22;
                    float nameWidth = 100;
                    float regWidth = 115;
                    float statusWidth = 55; // New status column
                    float fixedWidth = snWidth + nameWidth + regWidth + statusWidth;
                    float availableWidth = pageWidth - fixedWidth;
                    
                    // Min width for grade+score display like "C (60)"
                    int maxCourses = (int)(availableWidth / 48);
                    int displayedCourses = Math.Min(courses.Count, maxCourses);
                    
                    // Calculate course column width to fill remaining space exactly
                    float courseColWidth = displayedCourses > 0 ? availableWidth / displayedCourses : 48;
                    
                    // ========== SPECIALIZATION HEADER WITH CURRICULUM VALIDATION ==========
                    // Colors for badges
                    System.Drawing.Color successColor = System.Drawing.Color.FromArgb(39, 174, 96);  // Green
                    System.Drawing.Color warningColor = System.Drawing.Color.FromArgb(243, 156, 18); // Orange/Yellow
                    System.Drawing.Color dangerColor = System.Drawing.Color.FromArgb(192, 57, 43);   // Red
                    
                    // Build header text with curriculum info
                    string specHeaderText = "  " + specName + " (" + students.Count + " students)";
                    string curricText = "Curriculum: " + curricInfo.CurriculumCourseCount + " courses";
                    if (curricInfo.IsDefault) curricText += " [Default]";
                    
                    // Specialization Header - left part with name
                    DevExpress.XtraPrinting.TextBrick specHeader = new DevExpress.XtraPrinting.TextBrick();
                    specHeader.Text = specHeaderText;
                    specHeader.Font = subtitleFont;
                    specHeader.ForeColor = System.Drawing.Color.White;
                    specHeader.BackColor = specHeaderBg;
                    specHeader.Sides = DevExpress.XtraPrinting.BorderSide.None;
                    specHeader.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                    gr.DrawBrick(specHeader, new System.Drawing.RectangleF(0, y, pageWidth * 0.45f, 24));
                    
                    // Curriculum info text
                    DevExpress.XtraPrinting.TextBrick curricBrick = new DevExpress.XtraPrinting.TextBrick();
                    curricBrick.Text = curricText;
                    curricBrick.Font = smallFont;
                    curricBrick.ForeColor = System.Drawing.Color.FromArgb(200, 200, 200);
                    curricBrick.BackColor = specHeaderBg;
                    curricBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                    curricBrick.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                    curricBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                    gr.DrawBrick(curricBrick, new System.Drawing.RectangleF(pageWidth * 0.45f, y, pageWidth * 0.3f, 24));
                    
                    // Badge for curriculum status
                    string badgeText = curricInfo.IsFullySet ? "FULLY SET" : "NOT SET";
                    System.Drawing.Color badgeBgColor = curricInfo.IsFullySet ? successColor : warningColor;
                    if (curricInfo.CurriculumCourseCount == 0) 
                    { 
                        badgeText = "NO CURRICULUM"; 
                        badgeBgColor = dangerColor; 
                    }
                    
                    DevExpress.XtraPrinting.TextBrick badgeBrick = new DevExpress.XtraPrinting.TextBrick();
                    badgeBrick.Text = badgeText;
                    badgeBrick.Font = new System.Drawing.Font("Tahoma", 6, System.Drawing.FontStyle.Bold);
                    badgeBrick.ForeColor = System.Drawing.Color.White;
                    badgeBrick.BackColor = badgeBgColor;
                    badgeBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                    badgeBrick.Padding = new DevExpress.XtraPrinting.PaddingInfo(6, 6, 4, 4);
                    badgeBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                    gr.DrawBrick(badgeBrick, new System.Drawing.RectangleF(pageWidth * 0.75f, y, pageWidth * 0.15f, 24));
                    
                    // Right filler to complete the header bar
                    DevExpress.XtraPrinting.TextBrick rightFiller = new DevExpress.XtraPrinting.TextBrick();
                    rightFiller.Text = "";
                    rightFiller.BackColor = specHeaderBg;
                    rightFiller.Sides = DevExpress.XtraPrinting.BorderSide.None;
                    gr.DrawBrick(rightFiller, new System.Drawing.RectangleF(pageWidth * 0.9f, y, pageWidth * 0.1f, 24));
                    
                    y += 26;
                    
                    // Table Header Row - increased height
                    float x = 0;
                    float headerHeight = 24;
                    
                    // SN Header
                    DevExpress.XtraPrinting.TextBrick snHeader = new DevExpress.XtraPrinting.TextBrick();
                    snHeader.Text = "#";
                    snHeader.Font = headerFont;
                    snHeader.ForeColor = System.Drawing.Color.White;
                    snHeader.BackColor = headerBg;
                    snHeader.BorderColor = borderColor;
                    snHeader.Sides = DevExpress.XtraPrinting.BorderSide.All;
                    snHeader.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                    snHeader.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                    gr.DrawBrick(snHeader, new System.Drawing.RectangleF(x, y, snWidth, headerHeight));
                    x += snWidth;
                    
                    // Name Header
                    DevExpress.XtraPrinting.TextBrick nameHeader = new DevExpress.XtraPrinting.TextBrick();
                    nameHeader.Text = "Student Name";
                    nameHeader.Font = headerFont;
                    nameHeader.ForeColor = System.Drawing.Color.White;
                    nameHeader.BackColor = headerBg;
                    nameHeader.BorderColor = borderColor;
                    nameHeader.Sides = DevExpress.XtraPrinting.BorderSide.All;
                    nameHeader.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                    gr.DrawBrick(nameHeader, new System.Drawing.RectangleF(x, y, nameWidth, headerHeight));
                    x += nameWidth;
                    
                    // RegNo Header
                    DevExpress.XtraPrinting.TextBrick regHeader = new DevExpress.XtraPrinting.TextBrick();
                    regHeader.Text = "Reg No";
                    regHeader.Font = headerFont;
                    regHeader.ForeColor = System.Drawing.Color.White;
                    regHeader.BackColor = headerBg;
                    regHeader.BorderColor = borderColor;
                    regHeader.Sides = DevExpress.XtraPrinting.BorderSide.All;
                    regHeader.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                    gr.DrawBrick(regHeader, new System.Drawing.RectangleF(x, y, regWidth, headerHeight));
                    x += regWidth;
                    
                    // Course Headers
                    for (int i = 0; i < displayedCourses; i++)
                    {
                        DevExpress.XtraPrinting.TextBrick courseHeader = new DevExpress.XtraPrinting.TextBrick();
                        courseHeader.Text = courses[i].Code;
                        courseHeader.Font = headerFont;
                        courseHeader.ForeColor = System.Drawing.Color.White;
                        courseHeader.BackColor = headerBg;
                        courseHeader.BorderColor = borderColor;
                        courseHeader.Sides = DevExpress.XtraPrinting.BorderSide.All;
                        courseHeader.Padding = new DevExpress.XtraPrinting.PaddingInfo(4, 4, 6, 6);
                        courseHeader.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                        gr.DrawBrick(courseHeader, new System.Drawing.RectangleF(x, y, courseColWidth, headerHeight));
                        x += courseColWidth;
                    }
                    
                    // Status Header (new column)
                    DevExpress.XtraPrinting.TextBrick statusHeader = new DevExpress.XtraPrinting.TextBrick();
                    statusHeader.Text = "STATUS";
                    statusHeader.Font = headerFont;
                    statusHeader.ForeColor = System.Drawing.Color.White;
                    statusHeader.BackColor = headerBg;
                    statusHeader.BorderColor = borderColor;
                    statusHeader.Sides = DevExpress.XtraPrinting.BorderSide.All;
                    statusHeader.Padding = new DevExpress.XtraPrinting.PaddingInfo(4, 4, 6, 6);
                    statusHeader.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                    gr.DrawBrick(statusHeader, new System.Drawing.RectangleF(x, y, statusWidth, headerHeight));
                    
                    y += headerHeight;
                    
                    // Student Data Rows - increased height for grade+score
                    float rowHeight = 22;
                    int sn = 0;
                    foreach (var student in students)
                    {
                        sn++;
                        x = 0;
                        System.Drawing.Color rowBg = (sn % 2 == 0) ? altRowColor : System.Drawing.Color.White;
                        
                        // SN Cell
                        DevExpress.XtraPrinting.TextBrick snCell = new DevExpress.XtraPrinting.TextBrick();
                        snCell.Text = sn.ToString();
                        snCell.Font = cellFont;
                        snCell.BackColor = rowBg;
                        snCell.BorderColor = borderColor;
                        snCell.Sides = DevExpress.XtraPrinting.BorderSide.All;
                        snCell.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                        snCell.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                        gr.DrawBrick(snCell, new System.Drawing.RectangleF(x, y, snWidth, rowHeight));
                        x += snWidth;
                        
                        // Name Cell
                        string displayName = student.Name.Length > 24 ? student.Name.Substring(0, 24) + ".." : student.Name;
                        DevExpress.XtraPrinting.TextBrick nameCell = new DevExpress.XtraPrinting.TextBrick();
                        nameCell.Text = displayName;
                        nameCell.Font = cellFont;
                        nameCell.BackColor = rowBg;
                        nameCell.BorderColor = borderColor;
                        nameCell.Sides = DevExpress.XtraPrinting.BorderSide.All;
                        nameCell.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                        gr.DrawBrick(nameCell, new System.Drawing.RectangleF(x, y, nameWidth, rowHeight));
                        x += nameWidth;
                        
                        // RegNo Cell
                        DevExpress.XtraPrinting.TextBrick regCell = new DevExpress.XtraPrinting.TextBrick();
                        regCell.Text = student.RegNo;
                        regCell.Font = cellFont;
                        regCell.BackColor = rowBg;
                        regCell.BorderColor = borderColor;
                        regCell.Sides = DevExpress.XtraPrinting.BorderSide.All;
                        regCell.Padding = new DevExpress.XtraPrinting.PaddingInfo(5, 5, 6, 6);
                        gr.DrawBrick(regCell, new System.Drawing.RectangleF(x, y, regWidth, rowHeight));
                        x += regWidth;
                        
                        // Course Grade + Score Cells
                        int studentResultCount = 0;
                        int studentPassedCount = 0;
                        for (int i = 0; i < displayedCourses; i++)
                        {
                            string courseCode = courses[i].Code;
                            var result = student.Results.FirstOrDefault(r => 
                                r["courseid"] != DBNull.Value && r["courseid"].ToString() == courseCode);
                            
                            string displayText = "-";
                            System.Drawing.Color gradeColor = System.Drawing.Color.LightGray;
                            
                            if (result != null && result["grade"] != DBNull.Value)
                            {
                                string grade = result["grade"].ToString();
                                string score = result["score"] != DBNull.Value ? result["score"].ToString() : "";
                                
                                // Display as "C (60)" format
                                if (!string.IsNullOrEmpty(score))
                                    displayText = grade + " (" + score + ")";
                                else
                                    displayText = grade;
                                
                                gradeColor = (grade == "F") ? System.Drawing.Color.FromArgb(192, 57, 43) : System.Drawing.Color.Black;
                                
                                // Count results for status
                                studentResultCount++;
                                if (grade != "F") studentPassedCount++;
                            }
                            
                            DevExpress.XtraPrinting.TextBrick gradeCell = new DevExpress.XtraPrinting.TextBrick();
                            gradeCell.Text = displayText;
                            gradeCell.Font = cellFont;
                            gradeCell.ForeColor = gradeColor;
                            gradeCell.BackColor = rowBg;
                            gradeCell.BorderColor = borderColor;
                            gradeCell.Sides = DevExpress.XtraPrinting.BorderSide.All;
                            gradeCell.Padding = new DevExpress.XtraPrinting.PaddingInfo(4, 4, 6, 6);
                            gradeCell.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                            gr.DrawBrick(gradeCell, new System.Drawing.RectangleF(x, y, courseColWidth, rowHeight));
                            x += courseColWidth;
                        }
                        
                        // Status Cell - Determine if student passed based on curriculum
                        // IMPORTANT: Student can only be marked as PASSED if:
                        // 1. Curriculum is fully set (IsFullySet = true)
                        // 2. Curriculum has courses defined (CurriculumCourseCount > 0)
                        // 3. Student's passed count >= curriculum course count
                        bool studentPassed = false;
                        string statusText = "";
                        System.Drawing.Color statusBgColor;
                        System.Drawing.Color statusTextColor;
                        
                        if (curricInfo.CurriculumCourseCount > 0 && curricInfo.IsFullySet)
                        {
                            // Curriculum is fully set - can determine pass/fail
                            studentPassed = (studentPassedCount >= curricInfo.CurriculumCourseCount);
                            statusText = studentPassed ? "PASSED" : "FAILED";
                            statusText += " (" + studentPassedCount + "/" + curricInfo.CurriculumCourseCount + ")";
                            statusBgColor = studentPassed ? System.Drawing.Color.FromArgb(212, 237, 218) : System.Drawing.Color.FromArgb(248, 215, 218);
                            statusTextColor = studentPassed ? System.Drawing.Color.FromArgb(21, 87, 36) : System.Drawing.Color.FromArgb(114, 28, 36);
                        }
                        else if (curricInfo.CurriculumCourseCount > 0 && !curricInfo.IsFullySet)
                        {
                            // Curriculum exists but NOT fully set - cannot determine pass status
                            statusText = "PENDING (" + studentPassedCount + "/" + curricInfo.CurriculumCourseCount + ")";
                            statusBgColor = System.Drawing.Color.FromArgb(255, 243, 205); // Yellow/warning
                            statusTextColor = System.Drawing.Color.FromArgb(133, 100, 4);
                        }
                        else
                        {
                            // No curriculum defined - show results count only
                            statusText = "N/A (" + studentResultCount + ")";
                            statusBgColor = System.Drawing.Color.FromArgb(255, 243, 205);
                            statusTextColor = System.Drawing.Color.FromArgb(133, 100, 4);
                        }
                        
                        DevExpress.XtraPrinting.TextBrick statusCell = new DevExpress.XtraPrinting.TextBrick();
                        statusCell.Text = statusText;
                        statusCell.Font = new System.Drawing.Font("Tahoma", 5, System.Drawing.FontStyle.Bold);
                        statusCell.ForeColor = statusTextColor;
                        statusCell.BackColor = statusBgColor;
                        statusCell.BorderColor = borderColor;
                        statusCell.Sides = DevExpress.XtraPrinting.BorderSide.All;
                        statusCell.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 6, 6);
                        statusCell.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                        gr.DrawBrick(statusCell, new System.Drawing.RectangleF(x, y, statusWidth, rowHeight));
                        
                        y += rowHeight;
                    }
                    
                    y += 12; // Space between sections
                }
                
                // ========== SUMMARY STATISTICS SECTION ==========
                y += 10;
                
                // Calculate summary statistics
                int totalStudents = specializationGroups.Sum(g => g.Select(r => r["entryno"].ToString()).Distinct().Count());
                int totalSpecializations = specializationGroups.Count;
                
                // Summary box background
                float summaryBoxHeight = 85;
                DevExpress.XtraPrinting.TextBrick summaryBgBrick = new DevExpress.XtraPrinting.TextBrick();
                summaryBgBrick.Text = "";
                summaryBgBrick.BackColor = System.Drawing.Color.FromArgb(248, 249, 250);
                summaryBgBrick.Sides = DevExpress.XtraPrinting.BorderSide.All;
                summaryBgBrick.BorderColor = System.Drawing.Color.FromArgb(222, 226, 230);
                summaryBgBrick.BorderWidth = 1;
                gr.DrawBrick(summaryBgBrick, new System.Drawing.RectangleF(0, y, pageWidth, summaryBoxHeight));
                
                // Summary Title
                DevExpress.XtraPrinting.TextBrick summaryTitleBrick = new DevExpress.XtraPrinting.TextBrick();
                summaryTitleBrick.Text = "REPORT SUMMARY";
                summaryTitleBrick.Font = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Bold);
                summaryTitleBrick.ForeColor = brandColor;
                summaryTitleBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                summaryTitleBrick.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(summaryTitleBrick, new System.Drawing.RectangleF(10, y + 6, 150, 14));
                
                // Summary content - Row 1
                float summaryY = y + 22;
                float sumCol1X = 10;
                float sumCol2X = pageWidth / 3;
                float sumCol3X = (pageWidth / 3) * 2;
                
                // Total Students
                DevExpress.XtraPrinting.TextBrick statLabel1 = new DevExpress.XtraPrinting.TextBrick();
                statLabel1.Text = "Total Students:";
                statLabel1.Font = filterLabelFont;
                statLabel1.ForeColor = darkGray;
                statLabel1.Sides = DevExpress.XtraPrinting.BorderSide.None;
                statLabel1.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(statLabel1, new System.Drawing.RectangleF(sumCol1X, summaryY, 80, 12));
                
                DevExpress.XtraPrinting.TextBrick statValue1 = new DevExpress.XtraPrinting.TextBrick();
                statValue1.Text = totalStudents.ToString();
                statValue1.Font = new System.Drawing.Font("Tahoma", 9, System.Drawing.FontStyle.Bold);
                statValue1.ForeColor = brandColor;
                statValue1.Sides = DevExpress.XtraPrinting.BorderSide.None;
                statValue1.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(statValue1, new System.Drawing.RectangleF(sumCol1X + 80, summaryY, 60, 12));
                
                // Total Specializations
                DevExpress.XtraPrinting.TextBrick statLabel2 = new DevExpress.XtraPrinting.TextBrick();
                statLabel2.Text = "Specializations:";
                statLabel2.Font = filterLabelFont;
                statLabel2.ForeColor = darkGray;
                statLabel2.Sides = DevExpress.XtraPrinting.BorderSide.None;
                statLabel2.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(statLabel2, new System.Drawing.RectangleF(sumCol2X, summaryY, 80, 12));
                
                DevExpress.XtraPrinting.TextBrick statValue2 = new DevExpress.XtraPrinting.TextBrick();
                statValue2.Text = totalSpecializations.ToString();
                statValue2.Font = new System.Drawing.Font("Tahoma", 9, System.Drawing.FontStyle.Bold);
                statValue2.ForeColor = brandColor;
                statValue2.Sides = DevExpress.XtraPrinting.BorderSide.None;
                statValue2.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(statValue2, new System.Drawing.RectangleF(sumCol2X + 80, summaryY, 60, 12));
                
                // Report Period
                DevExpress.XtraPrinting.TextBrick statLabel3 = new DevExpress.XtraPrinting.TextBrick();
                statLabel3.Text = "Report Period:";
                statLabel3.Font = filterLabelFont;
                statLabel3.ForeColor = darkGray;
                statLabel3.Sides = DevExpress.XtraPrinting.BorderSide.None;
                statLabel3.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(statLabel3, new System.Drawing.RectangleF(sumCol3X, summaryY, 80, 12));
                
                string periodText = "Year " + studyYear + ", Sem " + semester;
                DevExpress.XtraPrinting.TextBrick statValue3 = new DevExpress.XtraPrinting.TextBrick();
                statValue3.Text = periodText;
                statValue3.Font = new System.Drawing.Font("Tahoma", 9, System.Drawing.FontStyle.Bold);
                statValue3.ForeColor = brandColor;
                statValue3.Sides = DevExpress.XtraPrinting.BorderSide.None;
                statValue3.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(statValue3, new System.Drawing.RectangleF(sumCol3X + 80, summaryY, 100, 12));
                
                // Legend section - Row 2
                summaryY += 18;
                DevExpress.XtraPrinting.TextBrick legendTitle = new DevExpress.XtraPrinting.TextBrick();
                legendTitle.Text = "Status Legend:";
                legendTitle.Font = filterLabelFont;
                legendTitle.ForeColor = darkGray;
                legendTitle.Sides = DevExpress.XtraPrinting.BorderSide.None;
                legendTitle.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(legendTitle, new System.Drawing.RectangleF(sumCol1X, summaryY, 70, 12));
                
                // PASSED badge
                DevExpress.XtraPrinting.TextBrick passedBadge = new DevExpress.XtraPrinting.TextBrick();
                passedBadge.Text = "PASSED";
                passedBadge.Font = new System.Drawing.Font("Tahoma", 5, System.Drawing.FontStyle.Bold);
                passedBadge.ForeColor = System.Drawing.Color.FromArgb(21, 87, 36);
                passedBadge.BackColor = System.Drawing.Color.FromArgb(212, 237, 218);
                passedBadge.Sides = DevExpress.XtraPrinting.BorderSide.None;
                passedBadge.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 2, 2);
                passedBadge.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(passedBadge, new System.Drawing.RectangleF(sumCol1X + 70, summaryY, 40, 12));
                
                DevExpress.XtraPrinting.TextBrick passedDesc = new DevExpress.XtraPrinting.TextBrick();
                passedDesc.Text = "= Fully Set & ≥ Req";
                passedDesc.Font = smallFont;
                passedDesc.ForeColor = lightGray;
                passedDesc.Sides = DevExpress.XtraPrinting.BorderSide.None;
                passedDesc.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(passedDesc, new System.Drawing.RectangleF(sumCol1X + 115, summaryY, 90, 12));
                
                // FAILED badge
                DevExpress.XtraPrinting.TextBrick failedBadge = new DevExpress.XtraPrinting.TextBrick();
                failedBadge.Text = "FAILED";
                failedBadge.Font = new System.Drawing.Font("Tahoma", 5, System.Drawing.FontStyle.Bold);
                failedBadge.ForeColor = System.Drawing.Color.FromArgb(114, 28, 36);
                failedBadge.BackColor = System.Drawing.Color.FromArgb(248, 215, 218);
                failedBadge.Sides = DevExpress.XtraPrinting.BorderSide.None;
                failedBadge.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 2, 2);
                failedBadge.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(failedBadge, new System.Drawing.RectangleF(sumCol2X - 30, summaryY, 38, 12));
                
                DevExpress.XtraPrinting.TextBrick failedDesc = new DevExpress.XtraPrinting.TextBrick();
                failedDesc.Text = "= Fully Set & < Req";
                failedDesc.Font = smallFont;
                failedDesc.ForeColor = lightGray;
                failedDesc.Sides = DevExpress.XtraPrinting.BorderSide.None;
                failedDesc.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(failedDesc, new System.Drawing.RectangleF(sumCol2X + 12, summaryY, 90, 12));
                
                // PENDING badge
                DevExpress.XtraPrinting.TextBrick pendingBadge = new DevExpress.XtraPrinting.TextBrick();
                pendingBadge.Text = "PENDING";
                pendingBadge.Font = new System.Drawing.Font("Tahoma", 5, System.Drawing.FontStyle.Bold);
                pendingBadge.ForeColor = System.Drawing.Color.FromArgb(133, 100, 4);
                pendingBadge.BackColor = System.Drawing.Color.FromArgb(255, 243, 205);
                pendingBadge.Sides = DevExpress.XtraPrinting.BorderSide.None;
                pendingBadge.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 2, 2);
                pendingBadge.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(pendingBadge, new System.Drawing.RectangleF(sumCol2X + 110, summaryY, 45, 12));
                
                DevExpress.XtraPrinting.TextBrick pendingDesc = new DevExpress.XtraPrinting.TextBrick();
                pendingDesc.Text = "= Not Fully Set";
                pendingDesc.Font = smallFont;
                pendingDesc.ForeColor = lightGray;
                pendingDesc.Sides = DevExpress.XtraPrinting.BorderSide.None;
                pendingDesc.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(pendingDesc, new System.Drawing.RectangleF(sumCol2X + 160, summaryY, 80, 12));
                
                // N/A badge
                DevExpress.XtraPrinting.TextBrick naBadge = new DevExpress.XtraPrinting.TextBrick();
                naBadge.Text = "N/A";
                naBadge.Font = new System.Drawing.Font("Tahoma", 5, System.Drawing.FontStyle.Bold);
                naBadge.ForeColor = System.Drawing.Color.FromArgb(133, 100, 4);
                naBadge.BackColor = System.Drawing.Color.FromArgb(255, 243, 205);
                naBadge.Sides = DevExpress.XtraPrinting.BorderSide.None;
                naBadge.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 2, 2);
                naBadge.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(naBadge, new System.Drawing.RectangleF(sumCol3X + 30, summaryY, 25, 12));
                
                DevExpress.XtraPrinting.TextBrick naDesc = new DevExpress.XtraPrinting.TextBrick();
                naDesc.Text = "= No Curriculum";
                naDesc.Font = smallFont;
                naDesc.ForeColor = lightGray;
                naDesc.Sides = DevExpress.XtraPrinting.BorderSide.None;
                naDesc.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(naDesc, new System.Drawing.RectangleF(sumCol3X + 60, summaryY, 90, 12));
                
                // Curriculum badges legend - Row 3
                summaryY += 18;
                DevExpress.XtraPrinting.TextBrick curricLegendTitle = new DevExpress.XtraPrinting.TextBrick();
                curricLegendTitle.Text = "Curriculum:";
                curricLegendTitle.Font = filterLabelFont;
                curricLegendTitle.ForeColor = darkGray;
                curricLegendTitle.Sides = DevExpress.XtraPrinting.BorderSide.None;
                curricLegendTitle.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(curricLegendTitle, new System.Drawing.RectangleF(sumCol1X, summaryY, 80, 12));
                
                // FULLY SET badge
                DevExpress.XtraPrinting.TextBrick fullySetBadge = new DevExpress.XtraPrinting.TextBrick();
                fullySetBadge.Text = "FULLY SET";
                fullySetBadge.Font = new System.Drawing.Font("Tahoma", 6, System.Drawing.FontStyle.Bold);
                fullySetBadge.ForeColor = System.Drawing.Color.White;
                fullySetBadge.BackColor = System.Drawing.Color.FromArgb(39, 174, 96);
                fullySetBadge.Sides = DevExpress.XtraPrinting.BorderSide.None;
                fullySetBadge.Padding = new DevExpress.XtraPrinting.PaddingInfo(4, 4, 2, 2);
                fullySetBadge.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(fullySetBadge, new System.Drawing.RectangleF(sumCol1X + 80, summaryY, 55, 12));
                
                DevExpress.XtraPrinting.TextBrick fullySetDesc = new DevExpress.XtraPrinting.TextBrick();
                fullySetDesc.Text = "= Complete";
                fullySetDesc.Font = smallFont;
                fullySetDesc.ForeColor = lightGray;
                fullySetDesc.Sides = DevExpress.XtraPrinting.BorderSide.None;
                fullySetDesc.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(fullySetDesc, new System.Drawing.RectangleF(sumCol1X + 140, summaryY, 80, 12));
                
                // NOT SET badge
                DevExpress.XtraPrinting.TextBrick notSetBadge = new DevExpress.XtraPrinting.TextBrick();
                notSetBadge.Text = "NOT SET";
                notSetBadge.Font = new System.Drawing.Font("Tahoma", 6, System.Drawing.FontStyle.Bold);
                notSetBadge.ForeColor = System.Drawing.Color.White;
                notSetBadge.BackColor = System.Drawing.Color.FromArgb(243, 156, 18);
                notSetBadge.Sides = DevExpress.XtraPrinting.BorderSide.None;
                notSetBadge.Padding = new DevExpress.XtraPrinting.PaddingInfo(4, 4, 2, 2);
                notSetBadge.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(notSetBadge, new System.Drawing.RectangleF(sumCol2X, summaryY, 50, 12));
                
                DevExpress.XtraPrinting.TextBrick notSetDesc = new DevExpress.XtraPrinting.TextBrick();
                notSetDesc.Text = "= Incomplete";
                notSetDesc.Font = smallFont;
                notSetDesc.ForeColor = lightGray;
                notSetDesc.Sides = DevExpress.XtraPrinting.BorderSide.None;
                notSetDesc.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(notSetDesc, new System.Drawing.RectangleF(sumCol2X + 55, summaryY, 80, 12));
                
                // NO CURRICULUM badge
                DevExpress.XtraPrinting.TextBrick noCurricBadge = new DevExpress.XtraPrinting.TextBrick();
                noCurricBadge.Text = "NO CURRICULUM";
                noCurricBadge.Font = new System.Drawing.Font("Tahoma", 6, System.Drawing.FontStyle.Bold);
                noCurricBadge.ForeColor = System.Drawing.Color.White;
                noCurricBadge.BackColor = System.Drawing.Color.FromArgb(192, 57, 43);
                noCurricBadge.Sides = DevExpress.XtraPrinting.BorderSide.None;
                noCurricBadge.Padding = new DevExpress.XtraPrinting.PaddingInfo(4, 4, 2, 2);
                noCurricBadge.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(noCurricBadge, new System.Drawing.RectangleF(sumCol3X, summaryY, 80, 12));
                
                DevExpress.XtraPrinting.TextBrick noCurricDesc = new DevExpress.XtraPrinting.TextBrick();
                noCurricDesc.Text = "= Not Defined";
                noCurricDesc.Font = smallFont;
                noCurricDesc.ForeColor = lightGray;
                noCurricDesc.Sides = DevExpress.XtraPrinting.BorderSide.None;
                noCurricDesc.BackColor = System.Drawing.Color.Transparent;
                gr.DrawBrick(noCurricDesc, new System.Drawing.RectangleF(sumCol3X + 85, summaryY, 80, 12));
                
                y += summaryBoxHeight + 8;
                
                // ========== PROFESSIONAL FOOTER ==========
                
                // Thin line above footer
                DevExpress.XtraPrinting.LineBrick footerLine = new DevExpress.XtraPrinting.LineBrick();
                footerLine.ForeColor = lineColor;
                footerLine.LineStyle = System.Drawing.Drawing2D.DashStyle.Solid;
                footerLine.LineWidth = 1;
                footerLine.Sides = DevExpress.XtraPrinting.BorderSide.None;
                gr.DrawBrick(footerLine, new System.Drawing.RectangleF(0, y, pageWidth, 1));
                y += 6;
                
                // Footer text
                string footerText = universityName + "  |  Student Results Summary Report  |  Generated: " + DateTime.Now.ToString("dd MMM yyyy, HH:mm");
                DevExpress.XtraPrinting.TextBrick footerBrick = new DevExpress.XtraPrinting.TextBrick();
                footerBrick.Text = footerText;
                footerBrick.Font = smallFont;
                footerBrick.ForeColor = System.Drawing.Color.Gray;
                footerBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
                footerBrick.BackColor = System.Drawing.Color.Transparent;
                footerBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
                gr.DrawBrick(footerBrick, new System.Drawing.RectangleF(0, y, pageWidth, 18));
            };
            
            link.CreateDocument();
            
            string fileName = string.Format("SummaryReport_{0}.pdf", DateTime.Now.ToString("yyyyMMdd_HHmmss"));
            
            // Clear all response content and set proper headers for PDF
            Response.Clear();
            Response.Buffer = true;
            Response.ClearHeaders();
            Response.ClearContent();
            Response.ContentType = "application/pdf";
            Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
            Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache);
            
            using (MemoryStream ms = new MemoryStream())
            {
                ps.ExportToPdf(ms);
                byte[] pdfBytes = ms.ToArray();
                Response.AddHeader("Content-Length", pdfBytes.Length.ToString());
                Response.BinaryWrite(pdfBytes);
                Response.Flush();
            }
            
            try
            {
                Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
                // Expected exception from Response.End() - ignore
            }
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
        LoadProgrammes("");
        LoadEntryYears();
        LoadSessions();
        LoadCampuses();
    }
    
    private void LoadFaculties()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT TRIM(faculty_code) AS faculty_code, TRIM(faculty_name) AS faculty_name FROM acad_faculty WHERE TRIM(faculty_name) <> '' ORDER BY faculty_name", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string name = reader["faculty_name"].ToString().Trim();
                            string code = reader["faculty_code"].ToString().Trim();
                            if (!string.IsNullOrEmpty(name) && !string.IsNullOrEmpty(code))
                                ddlFilterFaculty.Items.Add(new ListItem(name, code));
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
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql;
                MySqlCommand cmd;
                
                if (string.IsNullOrEmpty(facultyCode))
                {
                    sql = "SELECT TRIM(progcode) AS progcode, CONCAT(TRIM(progcode), ' - ', TRIM(progname)) AS progname FROM acad_programme WHERE TRIM(progcode) <> '' ORDER BY progname";
                    cmd = new MySqlCommand(sql, conn);
                }
                else
                {
                    sql = "SELECT TRIM(progcode) AS progcode, CONCAT(TRIM(progcode), ' - ', TRIM(progname)) AS progname FROM acad_programme WHERE TRIM(faculty_code) = @faculty ORDER BY progname";
                    cmd = new MySqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@faculty", facultyCode.Trim());
                }
                
                using (cmd)
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFilterProgramme.Items.Add(
                                reader["progname"].ToString(),
                                reader["progcode"].ToString().Trim()
                            );
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
                    "SELECT DISTINCT TRIM(entryyear) AS entryyear FROM acad_student WHERE entryyear IS NOT NULL AND TRIM(entryyear) <> '' ORDER BY entryyear DESC", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string year = reader["entryyear"].ToString().Trim();
                            if (!string.IsNullOrEmpty(year))
                                ddlFilterEntryYear.Items.Add(new ListItem(year, year));
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
                    "SELECT TRIM(Session) AS Session FROM acad_studysessions WHERE TRIM(Session) <> '' ORDER BY Session", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string session = reader["Session"].ToString().Trim();
                            if (!string.IsNullOrEmpty(session))
                                ddlFilterSession.Items.Add(new ListItem(session, session));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadCampuses()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(
                    "SELECT TRIM(campus_code) AS campus_code, TRIM(campus_name) AS campus_name FROM acad_campuses WHERE TRIM(campus_name) <> '' ORDER BY campus_name", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string name = reader["campus_name"].ToString().Trim();
                            string code = reader["campus_code"].ToString().Trim();
                            if (!string.IsNullOrEmpty(name) && !string.IsNullOrEmpty(code))
                                ddlFilterCampus.Items.Add(new ListItem(name, code));
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
                           s.progid, p.progcode, p.progname, s.specialisation, 
                           COALESCE(sp.spec, '-') AS spec_name,
                           s.entryyear, s.intake, 
                           s.studsesion, s.studCampus, s.gradSystemID, s.photofile, s.stud_status, s.new_status,
                           COALESCE(c.campus_name, s.studCampus, '-') AS campus_name,
                           COALESCE(s.has_passed, 'No') AS has_passed,
                           COALESCE(s.is_curriculum_fully_set, 'No') AS is_curriculum_fully_set,
                           s.fail_reason
                           FROM acad_student s
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           LEFT JOIN acad_specialisation sp ON s.specialisation = sp.spec_id
                           LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
                           WHERE 1=1 ";
            
            // --- Search filter: partial match across key columns ---
            string searchTerm = txtSearch != null ? txtSearch.Text.Trim() : "";
            if (!string.IsNullOrEmpty(searchTerm))
            {
                sql += @" AND (TRIM(s.firstname) LIKE @search 
                           OR TRIM(s.othername) LIKE @search 
                           OR TRIM(s.regno) LIKE @search 
                           OR TRIM(s.entryno) LIKE @search 
                           OR TRIM(s.studPhone) LIKE @search 
                           OR TRIM(s.email) LIKE @search
                           OR CONCAT(COALESCE(TRIM(s.firstname),''), ' ', COALESCE(TRIM(s.othername),'')) LIKE @search) ";
            }
            
            // --- Status filter (from query string or dropdown) ---
            string effectiveStatus = !string.IsNullOrEmpty(ddlFilterStatus.SelectedValue) 
                ? ddlFilterStatus.SelectedValue.Trim() 
                : StatusFilter;
            
            if (!string.IsNullOrEmpty(effectiveStatus) && effectiveStatus != "ALL")
            {
                sql += " AND TRIM(s.new_status) = @status ";
            }
            
            // --- Programme filter (DevExpress combobox) ---
            string selectedProgramme = ddlFilterProgramme.Value != null ? ddlFilterProgramme.Value.ToString().Trim() : "";
            
            if (!string.IsNullOrEmpty(selectedProgramme))
            {
                sql += " AND TRIM(s.progid) = @progid ";
            }
            else if (!string.IsNullOrEmpty(ddlFilterFaculty.SelectedValue))
            {
                sql += " AND TRIM(p.faculty_code) = @faculty ";
            }
            
            // --- Entry year filter ---
            if (!string.IsNullOrEmpty(ddlFilterEntryYear.SelectedValue))
            {
                sql += " AND TRIM(s.entryyear) = @entryyear ";
            }
            
            // --- Session filter ---
            if (!string.IsNullOrEmpty(ddlFilterSession.SelectedValue))
            {
                sql += " AND TRIM(s.studsesion) = @session ";
            }
            
            // --- Campus filter ---
            string selectedCampus = ddlFilterCampus != null ? ddlFilterCampus.SelectedValue : "";
            if (!string.IsNullOrEmpty(selectedCampus))
            {
                sql += " AND TRIM(s.studCampus) = @campus ";
            }
            
            sql += " ORDER BY s.entryyear DESC, s.firstname, s.othername";
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(searchTerm))
                        cmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");
                    
                    if (!string.IsNullOrEmpty(effectiveStatus) && effectiveStatus != "ALL")
                        cmd.Parameters.AddWithValue("@status", effectiveStatus.Trim());
                    
                    if (!string.IsNullOrEmpty(selectedProgramme))
                        cmd.Parameters.AddWithValue("@progid", selectedProgramme.Trim());
                    
                    if (!string.IsNullOrEmpty(ddlFilterFaculty.SelectedValue))
                        cmd.Parameters.AddWithValue("@faculty", ddlFilterFaculty.SelectedValue.Trim());
                    
                    if (!string.IsNullOrEmpty(ddlFilterEntryYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@entryyear", ddlFilterEntryYear.SelectedValue.Trim());
                    
                    if (!string.IsNullOrEmpty(ddlFilterSession.SelectedValue))
                        cmd.Parameters.AddWithValue("@session", ddlFilterSession.SelectedValue.Trim());
                    
                    if (!string.IsNullOrEmpty(selectedCampus))
                        cmd.Parameters.AddWithValue("@campus", selectedCampus.Trim());
                    
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
        
        // Update student count indicator
        UpdateStudentCount(dt.Rows.Count);
        
        return dt;
    }
    
    private void UpdateStudentCount(int count)
    {
        if (litStudentCount != null)
        {
            if (count == 0)
                litStudentCount.Text = "<span class='cd-filters__count'>No students found</span>";
            else
                litStudentCount.Text = string.Format("<span class='cd-filters__count'>{0} student{1}</span>", count, count == 1 ? "" : "s");
        }
    }
    
    #endregion
    
    #region Filter Events
    
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        // Grid will rebind automatically via Page_Load with the search term
    }
    
    protected void btnResetFilters_Click(object sender, EventArgs e)
    {
        // Clear search
        txtSearch.Text = "";
        
        // Reset all dropdowns
        ddlFilterStatus.SelectedIndex = 0;
        ddlFilterFaculty.SelectedIndex = 0;
        ddlFilterProgramme.Value = null;
        ddlFilterEntryYear.SelectedIndex = 0;
        ddlFilterSession.SelectedIndex = 0;
        ddlFilterCampus.SelectedIndex = 0;
        
        // Reset status filter
        StatusFilter = "";
        
        // Reload programmes (in case faculty had filtered them)
        LoadProgrammes("");
        
        // Update page title
        if (litPageTitle != null)
            litPageTitle.Text = "Student Records";
    }
    
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
    
    protected void ddlFilterCampus_SelectedIndexChanged(object sender, EventArgs e)
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
            LoadStudentCurriculum(regno);
            LoadStudentValidation(regno);
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
    
    private void LoadStudentCurriculum(string regno)
    {
        try
        {
            string progCode = "";
            string progName = "";
            string studentSpecId = "";
            string studentSpecName = "";
            int defaultSpecId = 0;
            bool isDefaultSpec = false;
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Step 1: Get student's programme and specialisation
                string sql = @"SELECT s.progid, s.specialisation, 
                               COALESCE(p.progname, '') AS progname,
                               COALESCE(sp.spec, '') AS spec_name,
                               COALESCE(sp.spec_id, 0) AS spec_id
                               FROM acad_student s
                               LEFT JOIN acad_programme p ON s.progid = p.progcode
                               LEFT JOIN acad_specialisation sp ON s.specialisation = sp.spec_id
                               WHERE s.regno = @regno
                               LIMIT 1";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            progCode = reader["progid"] != DBNull.Value ? reader["progid"].ToString() : "";
                            progName = reader["progname"] != DBNull.Value ? reader["progname"].ToString() : "";
                            studentSpecName = reader["spec_name"] != DBNull.Value ? reader["spec_name"].ToString() : "";
                            studentSpecId = reader["spec_id"] != DBNull.Value ? reader["spec_id"].ToString() : "0";
                        }
                    }
                }
                
                // Step 2: If student has no valid specialisation, get the default one for the programme
                int specIdToUse = 0;
                if (string.IsNullOrEmpty(studentSpecId) || studentSpecId == "0" || string.IsNullOrEmpty(studentSpecName) || studentSpecName == "-")
                {
                    // Get default specialisation for the programme
                    string defaultSql = @"SELECT spec_id, spec FROM acad_specialisation 
                                          WHERE prog_id = @progCode AND (spec = 'Default' OR spec LIKE '%Default%')
                                          ORDER BY spec_id LIMIT 1";
                    
                    using (MySqlCommand cmd = new MySqlCommand(defaultSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@progCode", progCode);
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                defaultSpecId = Convert.ToInt32(reader["spec_id"]);
                                studentSpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString() : "Default";
                                specIdToUse = defaultSpecId;
                                isDefaultSpec = true;
                            }
                        }
                    }
                    
                    // If no default found, try to get the first specialisation for this programme
                    if (specIdToUse == 0)
                    {
                        string firstSql = @"SELECT spec_id, spec FROM acad_specialisation 
                                            WHERE prog_id = @progCode 
                                            ORDER BY spec_id LIMIT 1";
                        
                        using (MySqlCommand cmd = new MySqlCommand(firstSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@progCode", progCode);
                            using (MySqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    defaultSpecId = Convert.ToInt32(reader["spec_id"]);
                                    studentSpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString() : "Default";
                                    specIdToUse = defaultSpecId;
                                    isDefaultSpec = true;
                                }
                            }
                        }
                    }
                }
                else
                {
                    specIdToUse = Convert.ToInt32(studentSpecId);
                    isDefaultSpec = false;
                }
                
                // Update header info
                litCurrProgramme.Text = !string.IsNullOrEmpty(progName) ? progName : "-";
                litCurrProgCode.Text = progCode;
                litCurrSpecialisation.Text = !string.IsNullOrEmpty(studentSpecName) ? studentSpecName : "Not Assigned";
                
                if (isDefaultSpec)
                {
                    litCurrSpecBadge.Text = " <span class='sp-curriculum-badge sp-curriculum-badge--default'>Default</span>";
                    litCurrSpecNote.Text = "Student has no assigned specialisation - showing default curriculum";
                }
                else
                {
                    litCurrSpecBadge.Text = " <span class='sp-curriculum-badge sp-curriculum-badge--assigned'>Assigned</span>";
                    litCurrSpecNote.Text = "";
                }
                
                // Step 3: Load curriculum courses for this specialisation
                _sharedSpecIdToUse = specIdToUse; // Save for Validation tab to use
                if (specIdToUse > 0)
                {
                    LoadCurriculumCourses(conn, specIdToUse);
                }
                else
                {
                    // No curriculum available
                    litCurrTotalCourses.Text = "0";
                    litCurrTotalCredits.Text = "0";
                    litCurrCoreCourses.Text = "0";
                    litCurrElectives.Text = "0";
                    litCurriculumContent.Text = "";
                    pnlNoCurriculum.Visible = true;
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading curriculum: " + ex.Message);
            litCurrProgramme.Text = "-";
            litCurrSpecialisation.Text = "-";
            litCurriculumContent.Text = "";
            pnlNoCurriculum.Visible = true;
        }
    }
    
    private void LoadCurriculumCourses(MySqlConnection conn, int specId)
    {
        try
        {
            // Get all courses for this specialisation
            string sql = @"SELECT pc.study_year, pc.semester, pc.course_code, pc.course_type,
                           COALESCE(c.courseName, '') AS courseName, 
                           COALESCE(c.CreditUnit, 3) AS CreditUnit
                           FROM acad_programmecourses pc
                           LEFT JOIN acad_course c ON pc.course_code = c.courseID
                           WHERE pc.specialisation_id = @specId
                           ORDER BY pc.study_year, pc.semester, pc.course_code";
            
            DataTable dtCourses = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dtCourses);
                }
            }
            
            if (dtCourses.Rows.Count == 0)
            {
                litCurrTotalCourses.Text = "0";
                litCurrTotalCredits.Text = "0";
                litCurrCoreCourses.Text = "0";
                litCurrElectives.Text = "0";
                litCurriculumContent.Text = "";
                pnlNoCurriculum.Visible = true;
                return;
            }
            
            pnlNoCurriculum.Visible = false;
            
            // Calculate totals
            int totalCourses = dtCourses.Rows.Count;
            int totalCredits = 0;
            int coreCourses = 0;
            int electives = 0;
            
            foreach (DataRow row in dtCourses.Rows)
            {
                int credits = row["CreditUnit"] != DBNull.Value ? Convert.ToInt32(row["CreditUnit"]) : 0;
                totalCredits += credits;
                
                string courseType = row["course_type"] != DBNull.Value ? row["course_type"].ToString().ToUpper() : "CORE";
                if (courseType == "ELECTIVE")
                    electives++;
                else
                    coreCourses++;
            }
            
            litCurrTotalCourses.Text = totalCourses.ToString();
            litCurrTotalCredits.Text = totalCredits.ToString();
            litCurrCoreCourses.Text = coreCourses.ToString();
            litCurrElectives.Text = electives.ToString();
            
            // Group by year and semester and build HTML
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            
            // Find max year
            int maxYear = 1;
            foreach (DataRow row in dtCourses.Rows)
            {
                int year = row["study_year"] != DBNull.Value ? Convert.ToInt32(row["study_year"]) : 1;
                if (year > maxYear) maxYear = year;
            }
            
            // Build curriculum grid by year
            for (int year = 1; year <= maxYear; year++)
            {
                sb.Append("<div class='sp-curriculum-year'>");
                sb.Append("<div class='sp-curriculum-year__header'>Year " + year + "</div>");
                
                // Loop through semesters 1-2
                for (int sem = 1; sem <= 2; sem++)
                {
                    // Get courses for this year/semester
                    DataRow[] semesterCourses = dtCourses.Select("study_year = " + year + " AND semester = " + sem);
                    
                    int semCredits = 0;
                    foreach (DataRow row in semesterCourses)
                    {
                        semCredits += row["CreditUnit"] != DBNull.Value ? Convert.ToInt32(row["CreditUnit"]) : 0;
                    }
                    
                    sb.Append("<div class='sp-curriculum-semester'>");
                    sb.Append("<div class='sp-curriculum-semester__header'>");
                    sb.Append("<span>Semester " + sem + "</span>");
                    sb.Append("<span class='sp-curriculum-semester__credits'>" + semCredits + " CU</span>");
                    sb.Append("</div>");
                    
                    if (semesterCourses.Length > 0)
                    {
                        foreach (DataRow row in semesterCourses)
                        {
                            string courseCode = row["course_code"].ToString();
                            string courseName = row["courseName"] != DBNull.Value ? row["courseName"].ToString() : "";
                            int credits = row["CreditUnit"] != DBNull.Value ? Convert.ToInt32(row["CreditUnit"]) : 0;
                            string courseType = row["course_type"] != DBNull.Value ? row["course_type"].ToString().ToUpper() : "CORE";
                            
                            string typeClass = courseType == "ELECTIVE" ? "sp-curriculum-course__type--elective" : "sp-curriculum-course__type--core";
                            
                            sb.Append("<div class='sp-curriculum-course'>");
                            sb.Append("<span class='sp-curriculum-course__code'>" + Server.HtmlEncode(courseCode) + "</span>");
                            sb.Append("<span class='sp-curriculum-course__name'>" + Server.HtmlEncode(courseName) + "</span>");
                            sb.Append("<span class='sp-curriculum-course__credits'>" + credits + " CU</span>");
                            sb.Append("<span class='sp-curriculum-course__type " + typeClass + "'>" + courseType + "</span>");
                            sb.Append("</div>");
                        }
                    }
                    else
                    {
                        sb.Append("<div class='sp-curriculum-empty'>No courses assigned</div>");
                    }
                    
                    sb.Append("</div>"); // End semester
                }
                
                sb.Append("</div>"); // End year
            }
            
            litCurriculumContent.Text = sb.ToString();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading curriculum courses: " + ex.Message);
            litCurriculumContent.Text = "";
            pnlNoCurriculum.Visible = true;
        }
    }
    
    /// <summary>
    /// VALIDATION TAB - Results Validation Against Curriculum
    /// =========================================================
    /// This method validates a student's academic results against their programme curriculum.
    /// 
    /// HOW IT WORKS:
    /// 1. Gets the student's programme and specialisation from acad_student table
    /// 2. If student has no assigned specialisation, uses the "Default" specialisation for the programme
    /// 3. If no Default exists, uses the first available specialisation for the programme
    /// 4. Loads curriculum courses from acad_programmecourses for the determined specialisation
    /// 5. Counts student's results from acad_results for each year/semester
    /// 6. Compares: If student results count >= curriculum courses count = PASS, else FAIL
    /// 
    /// PASS CRITERIA:
    /// - Each semester: Student must have results for AT LEAST as many courses as defined in curriculum
    /// - Overall: ALL semesters must pass for overall PASS status
    /// 
    /// TABLES USED:
    /// - acad_student: Student's programme (progid) and specialisation
    /// - acad_specialisation: Specialisation definitions (spec_id, prog_id, spec name)
    /// - acad_programmecourses: Curriculum courses per specialisation (study_year, semester, course_code)
    /// - acad_results: Student's actual results (regno, studyyear, semester, grade)
    /// 
    /// Created: February 2026
    /// </summary>
    private void LoadStudentValidation(string regno)
    {
        try
        {
            string progCode = "";
            string progName = "";
            string studentSpecId = "";
            string studentSpecName = "";
            string isFullySet = "No"; // Track if curriculum is fully set
            int defaultSpecId = 0;
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Step 1: Get student's programme and specialisation (including is_fully_set)
                string sql = @"SELECT s.progid, s.specialisation, 
                               COALESCE(p.progname, '') AS progname,
                               COALESCE(sp.spec, '') AS spec_name,
                               COALESCE(sp.spec_id, 0) AS spec_id,
                               COALESCE(sp.is_fully_set, 'No') AS is_fully_set
                               FROM acad_student s
                               LEFT JOIN acad_programme p ON s.progid = p.progcode
                               LEFT JOIN acad_specialisation sp ON s.specialisation = sp.spec_id
                               WHERE s.regno = @regno
                               LIMIT 1";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            progCode = reader["progid"] != DBNull.Value ? reader["progid"].ToString() : "";
                            progName = reader["progname"] != DBNull.Value ? reader["progname"].ToString() : "";
                            studentSpecName = reader["spec_name"] != DBNull.Value ? reader["spec_name"].ToString() : "";
                            studentSpecId = reader["spec_id"] != DBNull.Value ? reader["spec_id"].ToString() : "0";
                            isFullySet = reader["is_fully_set"] != DBNull.Value ? reader["is_fully_set"].ToString() : "No";
                        }
                    }
                }
                
                // Step 2: If student has no valid specialisation, get the default one for the programme
                int specIdToUse = 0;
                if (string.IsNullOrEmpty(studentSpecId) || studentSpecId == "0" || string.IsNullOrEmpty(studentSpecName) || studentSpecName == "-")
                {
                    // Get default specialisation for the programme (including is_fully_set)
                    string defaultSql = @"SELECT spec_id, spec, COALESCE(is_fully_set, 'No') AS is_fully_set FROM acad_specialisation 
                                          WHERE prog_id = @progCode AND (spec = 'Default' OR spec LIKE '%Default%')
                                          ORDER BY spec_id LIMIT 1";
                    
                    using (MySqlCommand cmd = new MySqlCommand(defaultSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@progCode", progCode);
                        using (MySqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                defaultSpecId = Convert.ToInt32(reader["spec_id"]);
                                studentSpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString() : "Default";
                                isFullySet = reader["is_fully_set"] != DBNull.Value ? reader["is_fully_set"].ToString() : "No";
                                specIdToUse = defaultSpecId;
                            }
                        }
                    }
                    
                    // If no default found, try to get the first specialisation for this programme
                    if (specIdToUse == 0)
                    {
                        string firstSql = @"SELECT spec_id, spec, COALESCE(is_fully_set, 'No') AS is_fully_set FROM acad_specialisation 
                                            WHERE prog_id = @progCode 
                                            ORDER BY spec_id LIMIT 1";
                        
                        using (MySqlCommand cmd = new MySqlCommand(firstSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@progCode", progCode);
                            using (MySqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    defaultSpecId = Convert.ToInt32(reader["spec_id"]);
                                    studentSpecName = reader["spec"] != DBNull.Value ? reader["spec"].ToString() : "Default";
                                    isFullySet = reader["is_fully_set"] != DBNull.Value ? reader["is_fully_set"].ToString() : "No";
                                    specIdToUse = defaultSpecId;
                                }
                            }
                        }
                    }
                }
                else
                {
                    specIdToUse = Convert.ToInt32(studentSpecId);
                }
                
                // Update header info
                litChkProgramme.Text = !string.IsNullOrEmpty(progName) ? progName : "-";
                litChkProgCode.Text = progCode;
                litChkSpecialisation.Text = !string.IsNullOrEmpty(studentSpecName) ? studentSpecName : "Not Assigned";
                
                // Show curriculum fully set badge
                if (isFullySet == "Yes")
                {
                    litChkSpecBadge.Text = " <span style='display:inline-block;background:#28a745;color:white;font-size:9px;padding:2px 6px;border-radius:3px;font-weight:600;vertical-align:middle;'>CURRICULUM SET</span>";
                }
                else
                {
                    litChkSpecBadge.Text = " <span style='display:inline-block;background:#dc3545;color:white;font-size:9px;padding:2px 6px;border-radius:3px;font-weight:600;vertical-align:middle;'>CURRICULUM NOT SET</span>";
                }
                litChkSpecNote.Text = "";
                
                // Step 3: Load and validate curriculum courses
                if (specIdToUse > 0)
                {
                    LoadValidationCourses(conn, specIdToUse, regno);
                }
                else
                {
                    // No curriculum available
                    litChkTotalCourses.Text = "0";
                    litChkTotalCredits.Text = "0";
                    litChkCoreCourses.Text = "0";
                    litChkElectives.Text = "0";
                    litCheckerContent.Text = "";
                    pnlNoChecker.Visible = true;
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading checker: " + ex.Message);
            litChkProgramme.Text = "-";
            litChkSpecialisation.Text = "-";
            litCheckerContent.Text = "";
            pnlNoChecker.Visible = true;
        }
    }
    
    /// <summary>
    /// Loads curriculum courses and compares against student results for validation.
    /// For each semester: counts curriculum courses vs student results to determine pass/fail.
    /// </summary>
    private void LoadValidationCourses(MySqlConnection conn, int specId, string regno)
    {
        try
        {
            // Get all curriculum courses for this specialisation
            string sql = @"SELECT pc.study_year, pc.semester, pc.course_code, pc.course_type,
                           COALESCE(c.courseName, '') AS courseName, 
                           COALESCE(c.CreditUnit, 3) AS CreditUnit
                           FROM acad_programmecourses pc
                           LEFT JOIN acad_course c ON pc.course_code = c.courseID
                           WHERE pc.specialisation_id = @specId
                           ORDER BY pc.study_year, pc.semester, pc.course_code";
            
            DataTable dtCourses = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@specId", specId);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dtCourses);
                }
            }
            
            if (dtCourses.Rows.Count == 0)
            {
                litChkTotalCourses.Text = "0";
                litChkTotalCredits.Text = "0";
                litChkCoreCourses.Text = "0";
                litChkElectives.Text = "0";
                litCheckerContent.Text = "";
                pnlNoChecker.Visible = true;
                return;
            }
            
            pnlNoChecker.Visible = false;
            
            // Get student's results count per semester
            string resultsSql = @"SELECT studyyear, semester, COUNT(*) AS results_count
                                  FROM acad_results
                                  WHERE regno = @regno AND grade IS NOT NULL AND grade != ''
                                  GROUP BY studyyear, semester";
            
            DataTable dtResults = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(resultsSql, conn))
            {
                cmd.Parameters.AddWithValue("@regno", regno);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dtResults);
                }
            }
            
            // Calculate totals
            int totalCourses = dtCourses.Rows.Count;
            int totalCredits = 0;
            int coreCourses = 0;
            int electives = 0;
            
            foreach (DataRow row in dtCourses.Rows)
            {
                int credits = row["CreditUnit"] != DBNull.Value ? Convert.ToInt32(row["CreditUnit"]) : 0;
                totalCredits += credits;
                
                string courseType = row["course_type"] != DBNull.Value ? row["course_type"].ToString().ToUpper() : "CORE";
                if (courseType == "ELECTIVE")
                    electives++;
                else
                    coreCourses++;
            }
            
            litChkTotalCourses.Text = totalCourses.ToString();
            litChkTotalCredits.Text = totalCredits.ToString();
            litChkCoreCourses.Text = coreCourses.ToString();
            litChkElectives.Text = electives.ToString();
            
            // Group by year and semester and build HTML
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            
            // Find max year
            int maxYear = 1;
            foreach (DataRow row in dtCourses.Rows)
            {
                int year = row["study_year"] != DBNull.Value ? Convert.ToInt32(row["study_year"]) : 1;
                if (year > maxYear) maxYear = year;
            }
            
            // Track overall pass/fail
            int semestersPassed = 0;
            int semestersFailed = 0;
            int semestersTotal = 0;
            
            // Build curriculum grid by year
            for (int year = 1; year <= maxYear; year++)
            {
                sb.Append("<div class='sp-curriculum-year'>");
                sb.Append("<div class='sp-curriculum-year__header'>Year " + year + "</div>");
                
                // Loop through semesters 1-2
                for (int sem = 1; sem <= 2; sem++)
                {
                    // Get courses for this year/semester
                    DataRow[] semesterCourses = dtCourses.Select("study_year = " + year + " AND semester = " + sem);
                    
                    if (semesterCourses.Length == 0) continue; // Skip if no curriculum courses
                    
                    semestersTotal++;
                    
                    int semCredits = 0;
                    foreach (DataRow row in semesterCourses)
                    {
                        semCredits += row["CreditUnit"] != DBNull.Value ? Convert.ToInt32(row["CreditUnit"]) : 0;
                    }
                    
                    // Get student results for this semester
                    DataRow[] resultRows = dtResults.Select("studyyear = " + year + " AND semester = " + sem);
                    int studentResults = resultRows.Length > 0 ? Convert.ToInt32(resultRows[0]["results_count"]) : 0;
                    
                    // Determine pass/fail
                    bool isPassed = studentResults >= semesterCourses.Length;
                    if (isPassed) semestersPassed++; else semestersFailed++;
                    
                    sb.Append("<div class='sp-curriculum-semester'>");
                    sb.Append("<div class='sp-curriculum-semester__header'>");
                    sb.Append("<span>Semester " + sem + "</span>");
                    sb.Append("<span class='sp-curriculum-semester__credits'>" + semCredits + " CU</span>");
                    sb.Append("</div>");
                    
                    // Compact single row with curriculum, results, and status
                    string statusBg = isPassed ? "#d4edda" : "#f8d7da";
                    string statusColor = isPassed ? "#28a745" : "#dc3545";
                    string statusIcon = isPassed ? "&#10004;" : "&#10008;";
                    string statusText = isPassed ? "PASS" : "FAIL";
                    
                    sb.Append("<div style='display:flex;align-items:center;justify-content:space-between;padding:6px 10px;font-size:11px;background:" + statusBg + ";'>");
                    sb.Append("<span><b style='color:#174DA4;'>Curriculum:</b> " + semesterCourses.Length + "</span>");
                    sb.Append("<span><b style='color:#666;'>Results:</b> " + studentResults + "</span>");
                    sb.Append("<span style='font-weight:700;color:" + statusColor + ";'>" + statusIcon + " " + statusText + "</span>");
                    sb.Append("</div>");
                    
                    sb.Append("</div>"); // End semester
                }
                
                sb.Append("</div>"); // End year
            }
            
            // Build overall status header - compact design
            string overallHtml = "";
            if (semestersTotal > 0)
            {
                if (semestersFailed == 0)
                {
                    overallHtml = "<div style='display:flex;align-items:center;justify-content:center;gap:10px;background:#d4edda;border:1px solid #28a745;padding:8px 16px;margin:0 0 12px 0;border-radius:4px;'><span style='color:#28a745;font-weight:700;font-size:13px;'>&#10004; OVERALL: PASS</span><span style='color:#155724;font-size:11px;'>(" + semestersPassed + "/" + semestersTotal + " semesters)</span></div>";
                }
                else
                {
                    overallHtml = "<div style='display:flex;align-items:center;justify-content:center;gap:10px;background:#f8d7da;border:1px solid #dc3545;padding:8px 16px;margin:0 0 12px 0;border-radius:4px;'><span style='color:#dc3545;font-weight:700;font-size:13px;'>&#10008; OVERALL: FAILED</span><span style='color:#721c24;font-size:11px;'>(" + semestersFailed + "/" + semestersTotal + " semesters need attention)</span></div>";
                }
            }
            
            litCheckerContent.Text = overallHtml + sb.ToString();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading checker courses: " + ex.Message);
            litCheckerContent.Text = "";
            pnlNoChecker.Visible = true;
        }
    }
    
    #endregion
}
