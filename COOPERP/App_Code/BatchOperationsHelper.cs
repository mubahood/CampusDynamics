using System;
using System.Data;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Script.Serialization;
using System.IO;
using MySql.Data.MySqlClient;

/// <summary>
/// Shared helper class for batch operations on students.
/// Used by NewStudentInfo and SystemValidationStats pages.
/// </summary>
public static class BatchOperationsHelper
{
    private static string ConnectionString
    {
        get
        {
            return ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
                ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
                : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";
        }
    }

    #region Batch Status Operations

    /// <summary>
    /// Gets count of students matching the batch status change criteria.
    /// </summary>
    public static int GetBatchStatusCount(string conditionType, string targetStatus, bool negate,
        string paymentDays, string entryYear, string programme, string currentStatus)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = BuildBatchStatusQuery(conditionType, negate, paymentDays, entryYear, programme, currentStatus, true);
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddBatchStatusParameters(cmd, conditionType, negate, paymentDays, entryYear, programme, currentStatus, targetStatus);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    /// <summary>
    /// Applies batch status change to students matching the criteria.
    /// </summary>
    public static int ApplyBatchStatusChange(string conditionType, string targetStatus, bool negate,
        string paymentDays, string entryYear, string programme, string currentStatus)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Get matching student regnos
            string selectSql = BuildBatchStatusQuery(conditionType, negate, paymentDays, entryYear, programme, currentStatus, false);
            
            List<string> regnos = new List<string>();
            using (MySqlCommand cmd = new MySqlCommand(selectSql, conn))
            {
                AddBatchStatusParameters(cmd, conditionType, negate, paymentDays, entryYear, programme, currentStatus, targetStatus);
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        regnos.Add(reader["regno"].ToString());
                    }
                }
            }
            
            if (regnos.Count == 0) return 0;
            
            // Update all matching students
            string updateSql = "UPDATE acad_student SET status = @targetStatus WHERE regno IN (";
            for (int i = 0; i < regnos.Count; i++)
            {
                if (i > 0) updateSql += ",";
                updateSql += "@r" + i;
            }
            updateSql += ")";
            
            using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
            {
                cmd.Parameters.AddWithValue("@targetStatus", targetStatus);
                for (int i = 0; i < regnos.Count; i++)
                {
                    cmd.Parameters.AddWithValue("@r" + i, regnos[i]);
                }
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private static string BuildBatchStatusQuery(string conditionType, bool negate, 
        string paymentDays, string entryYear, string programme, string currentStatus, bool countOnly)
    {
        string select = countOnly ? "SELECT COUNT(*)" : "SELECT regno";
        string sql = select + " FROM acad_student WHERE 1=1";
        
        // Don't update to same status
        sql += " AND status != @targetStatus";
        
        string condition = "";
        
        switch (conditionType)
        {
            case "payment":
                // Students who paid in last X days
                condition = @"regno IN (
                    SELECT DISTINCT payeeid FROM acad_accounts_ledger 
                    WHERE dc = 'CR' AND tran_date >= DATE_SUB(CURDATE(), INTERVAL @days DAY)
                )";
                break;
            case "entry_year":
                condition = "entryyear = @entryYear";
                break;
            case "programme":
                condition = "progcode = @programme";
                break;
            case "current_status":
                condition = "status = @currentStatus";
                break;
        }
        
        if (!string.IsNullOrEmpty(condition))
        {
            if (negate)
                sql += " AND NOT (" + condition + ")";
            else
                sql += " AND " + condition;
        }
        
        return sql;
    }

    private static void AddBatchStatusParameters(MySqlCommand cmd, string conditionType, bool negate,
        string paymentDays, string entryYear, string programme, string currentStatus, string targetStatus)
    {
        cmd.Parameters.AddWithValue("@targetStatus", targetStatus);
        
        switch (conditionType)
        {
            case "payment":
                cmd.Parameters.AddWithValue("@days", Convert.ToInt32(paymentDays));
                break;
            case "entry_year":
                cmd.Parameters.AddWithValue("@entryYear", entryYear);
                break;
            case "programme":
                cmd.Parameters.AddWithValue("@programme", programme);
                break;
            case "current_status":
                cmd.Parameters.AddWithValue("@currentStatus", currentStatus);
                break;
        }
    }

    #endregion

    #region Batch Validation Operations

    /// <summary>
    /// Gets count of students that would be affected by batch validation.
    /// </summary>
    public static int GetBatchValidationCount(string programme, string entryYear, string entryNumbers = "")
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            string sql = "SELECT COUNT(*) FROM acad_student WHERE 1=1";
            
            // If entry numbers specified, use them
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
                sql += " AND progcode = @programme";
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
    /// </summary>
    public static int ApplyBatchValidation(string programme, string entryYear, string entryNumbers = "")
    {
        int validatedCount = 0;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Get all students matching the filter
            string selectSql = @"SELECT s.regno, s.progcode, s.specialisation 
                                 FROM acad_student s 
                                 WHERE 1=1";
            
            List<string> entryParams = new List<string>();
            string[] entries = null;
            
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
                    selectSql += " AND s.progcode = @programme";
                if (!string.IsNullOrEmpty(entryYear))
                    selectSql += " AND s.entryyear = @entryYear";
            }
            
            DataTable students = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(selectSql, conn))
            {
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
                string progcode = student["progcode"].ToString();
                string specId = student["specialisation"] != DBNull.Value ? student["specialisation"].ToString() : "";
                
                ValidateSingleStudent(conn, regno, progcode, specId);
                validatedCount++;
            }
        }
        
        return validatedCount;
    }

    /// <summary>
    /// Validates a single student's results against their curriculum.
    /// </summary>
    public static void ValidateSingleStudent(MySqlConnection conn, string regno, string progcode, string specId)
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
                                          WHERE prog_id = @progcode AND is_default = 'Yes' 
                                          LIMIT 1";
                using (MySqlCommand cmd = new MySqlCommand(defaultSpecSql, conn))
                {
                    cmd.Parameters.AddWithValue("@progcode", progcode);
                    object result = cmd.ExecuteScalar();
                    specId = result != null ? result.ToString().Trim() : "";
                }
                
                // Strategy 2: Find specialisation named 'Default'
                if (string.IsNullOrEmpty(specId))
                {
                    string namedDefaultSql = @"SELECT spec_id FROM acad_specialisation 
                                              WHERE prog_id = @progcode AND (spec = 'Default' OR spec LIKE '%Default%')
                                              ORDER BY spec_id LIMIT 1";
                    using (MySqlCommand cmd = new MySqlCommand(namedDefaultSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@progcode", progcode);
                        object result = cmd.ExecuteScalar();
                        specId = result != null ? result.ToString().Trim() : "";
                    }
                }
                
                // Strategy 3: Fall back to the first specialisation for this programme
                if (string.IsNullOrEmpty(specId))
                {
                    string firstSpecSql = @"SELECT spec_id FROM acad_specialisation 
                                            WHERE prog_id = @progcode 
                                            ORDER BY spec_id LIMIT 1";
                    using (MySqlCommand cmd = new MySqlCommand(firstSpecSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@progcode", progcode);
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
                // Step 3: Validate results against curriculum per semester
                string curriculumSql = @"SELECT semester, COUNT(*) as course_count 
                                         FROM acad_programmecourses 
                                         WHERE specialisation_id = @specId 
                                         GROUP BY semester 
                                         ORDER BY semester";
                
                Dictionary<string, int> curriculumBySemester = new Dictionary<string, int>();
                using (MySqlCommand cmd = new MySqlCommand(curriculumSql, conn))
                {
                    cmd.Parameters.AddWithValue("@specId", specId);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string sem = reader["semester"].ToString();
                            int count = Convert.ToInt32(reader["course_count"]);
                            curriculumBySemester[sem] = count;
                        }
                    }
                }
                
                // Get student results grouped by semester (passed courses only)
                string resultsSql = @"SELECT semester, COUNT(*) as result_count 
                                      FROM acad_results 
                                      WHERE regno = @regno AND grade IS NOT NULL AND grade != 'F'
                                      GROUP BY semester";
                
                Dictionary<string, int> resultsBySemester = new Dictionary<string, int>();
                using (MySqlCommand cmd = new MySqlCommand(resultsSql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string sem = reader["semester"].ToString();
                            int count = Convert.ToInt32(reader["result_count"]);
                            resultsBySemester[sem] = count;
                        }
                    }
                }
                
                // Compare curriculum vs results per semester
                bool allSemestersPassed = true;
                foreach (var kvp in curriculumBySemester)
                {
                    string semester = kvp.Key;
                    int required = kvp.Value;
                    int passed = resultsBySemester.ContainsKey(semester) ? resultsBySemester[semester] : 0;
                    
                    if (passed < required)
                    {
                        allSemestersPassed = false;
                        failReasons.Add("Sem " + semester + ": " + passed + "/" + required + " courses passed");
                    }
                }
                
                if (allSemestersPassed && curriculumBySemester.Count > 0)
                {
                    hasPassed = "Yes";
                }
                else if (curriculumBySemester.Count == 0)
                {
                    failReasons.Add("Curriculum has no courses defined");
                }
            }
        }
        catch (Exception ex)
        {
            failReasons.Add("Validation error: " + ex.Message);
        }
        
        // Step 4: Update the student record
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

    #region Specialization Validator Operations

    /// <summary>
    /// Data class for specialization summary
    /// </summary>
    public class SpecializationSummary
    {
        public int SpecId { get; set; }
        public string SpecName { get; set; }
        public string ProgId { get; set; }
        public string ProgName { get; set; }
        public int Y1Courses { get; set; }
        public int Y2Courses { get; set; }
        public int Y3Courses { get; set; }
        public int Y4Courses { get; set; }
        public int StudentCount { get; set; }
        public string IsFullySet { get; set; }
    }

    /// <summary>
    /// Gets all specializations with course counts per year and student counts.
    /// </summary>
    public static List<SpecializationSummary> GetSpecializationSummary()
    {
        List<SpecializationSummary> result = new List<SpecializationSummary>();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Get all specializations with programme info
            string sql = @"SELECT s.spec_id, s.spec, s.prog_id, IFNULL(p.progname, s.prog_id) as progname, 
                                  IFNULL(s.is_fully_set, 'No') as is_fully_set
                           FROM acad_specialisation s
                           LEFT JOIN acad_programme p ON s.prog_id = p.progcode
                           ORDER BY p.progname, s.spec";
            
            Dictionary<int, SpecializationSummary> specs = new Dictionary<int, SpecializationSummary>();
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            using (MySqlDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    var spec = new SpecializationSummary
                    {
                        SpecId = Convert.ToInt32(reader["spec_id"]),
                        SpecName = reader["spec"].ToString(),
                        ProgId = reader["prog_id"].ToString(),
                        ProgName = reader["progname"].ToString(),
                        IsFullySet = reader["is_fully_set"].ToString(),
                        Y1Courses = 0,
                        Y2Courses = 0,
                        Y3Courses = 0,
                        Y4Courses = 0,
                        StudentCount = 0
                    };
                    specs[spec.SpecId] = spec;
                }
            }
            
            // Get course counts per year for each specialization
            string courseSql = @"SELECT specialisation_id, study_year, COUNT(*) as course_count
                                 FROM acad_programmecourses
                                 WHERE specialisation_id IS NOT NULL AND specialisation_id > 0
                                 GROUP BY specialisation_id, study_year";
            
            using (MySqlCommand cmd = new MySqlCommand(courseSql, conn))
            using (MySqlDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    int specId = Convert.ToInt32(reader["specialisation_id"]);
                    int studyYear = Convert.ToInt32(reader["study_year"]);
                    int count = Convert.ToInt32(reader["course_count"]);
                    
                    if (specs.ContainsKey(specId))
                    {
                        switch (studyYear)
                        {
                            case 1: specs[specId].Y1Courses = count; break;
                            case 2: specs[specId].Y2Courses = count; break;
                            case 3: specs[specId].Y3Courses = count; break;
                            case 4: specs[specId].Y4Courses = count; break;
                        }
                    }
                }
            }
            
            // Get student counts per specialization
            string studentSql = @"SELECT specialisation, COUNT(*) as student_count
                                  FROM acad_student
                                  WHERE specialisation IS NOT NULL AND specialisation != '' AND specialisation != '-'
                                  GROUP BY specialisation";
            
            using (MySqlCommand cmd = new MySqlCommand(studentSql, conn))
            using (MySqlDataReader reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    string specIdStr = reader["specialisation"].ToString();
                    int specId;
                    if (int.TryParse(specIdStr, out specId) && specs.ContainsKey(specId))
                    {
                        specs[specId].StudentCount = Convert.ToInt32(reader["student_count"]);
                    }
                }
            }
            
            result.AddRange(specs.Values);
        }
        
        return result;
    }

    /// <summary>
    /// Applies validation rules to all specializations and updates their is_fully_set status.
    /// Rules:
    /// - Year 1 & Year 2 must have at least 5 courses each
    /// - Year 1, Year 2 & Year 3 must not exceed 12 courses each
    /// </summary>
    public static Dictionary<string, int> ApplySpecializationValidation()
    {
        int updatedToYes = 0;
        int updatedToNo = 0;
        
        List<SpecializationSummary> specs = GetSpecializationSummary();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            foreach (var spec in specs)
            {
                // Apply validation rules
                bool isValid = true;
                
                // Rule 1: Year 1 must have at least 5 courses
                if (spec.Y1Courses < 5) isValid = false;
                
                // Rule 2: Year 2 must have at least 5 courses
                if (spec.Y2Courses < 5) isValid = false;
                
                // Rule 3: Year 1 must not exceed 12 courses
                if (spec.Y1Courses > 12) isValid = false;
                
                // Rule 4: Year 2 must not exceed 12 courses
                if (spec.Y2Courses > 12) isValid = false;
                
                // Rule 5: Year 3 must not exceed 12 courses
                if (spec.Y3Courses > 12) isValid = false;
                
                string newStatus = isValid ? "Yes" : "No";
                
                // Update if status changed
                if (spec.IsFullySet != newStatus)
                {
                    string updateSql = "UPDATE acad_specialisation SET is_fully_set = @status WHERE spec_id = @specId";
                    using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@status", newStatus);
                        cmd.Parameters.AddWithValue("@specId", spec.SpecId);
                        cmd.ExecuteNonQuery();
                    }
                    
                    if (newStatus == "Yes") updatedToYes++;
                    else updatedToNo++;
                }
            }
        }
        
        return new Dictionary<string, int>
        {
            { "updatedToYes", updatedToYes },
            { "updatedToNo", updatedToNo }
        };
    }

    #endregion

    #region Summary Report Operations

    /// <summary>
    /// Gets count of students who have results matching the filters.
    /// </summary>
    public static int GetSummaryReportStudentCount(string programme, string entryYear, string studyYear, string semester, string entryNumbers)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            string sql = @"SELECT COUNT(DISTINCT s.regno) 
                           FROM acad_student s
                           INNER JOIN acad_results r ON s.regno = r.regno
                           WHERE s.progcode = @programme";
            
            if (!string.IsNullOrEmpty(entryYear))
                sql += " AND s.entryyear = @entryYear";
            if (!string.IsNullOrEmpty(studyYear))
                sql += " AND r.studyyear = @studyYear";
            if (!string.IsNullOrEmpty(semester))
                sql += " AND r.semester = @semester";
            
            if (!string.IsNullOrEmpty(entryNumbers))
            {
                string[] entries = entryNumbers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                if (entries.Length > 0)
                {
                    List<string> paramNames = new List<string>();
                    for (int i = 0; i < entries.Length; i++)
                        paramNames.Add("@entry" + i);
                    sql += " AND s.entryno IN (" + string.Join(",", paramNames) + ")";
                }
            }
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@programme", programme);
                if (!string.IsNullOrEmpty(entryYear))
                    cmd.Parameters.AddWithValue("@entryYear", entryYear);
                if (!string.IsNullOrEmpty(studyYear))
                    cmd.Parameters.AddWithValue("@studyYear", studyYear);
                if (!string.IsNullOrEmpty(semester))
                    cmd.Parameters.AddWithValue("@semester", semester);
                
                if (!string.IsNullOrEmpty(entryNumbers))
                {
                    string[] entries = entryNumbers.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                    for (int i = 0; i < entries.Length; i++)
                        cmd.Parameters.AddWithValue("@entry" + i, entries[i].Trim());
                }
                
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }
    }

    #endregion

    #region Dropdown Data

    /// <summary>
    /// Gets all programmes for dropdown lists.
    /// </summary>
    public static DataTable GetProgrammes()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT progcode, CONCAT(progcode, ' - ', prog) as progname FROM acad_programme ORDER BY prog";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                DataTable dt = new DataTable();
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
                return dt;
            }
        }
    }

    /// <summary>
    /// Gets distinct entry years for dropdown lists.
    /// </summary>
    public static DataTable GetEntryYears()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT DISTINCT entryyear FROM acad_student WHERE entryyear IS NOT NULL ORDER BY entryyear DESC";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                DataTable dt = new DataTable();
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
                return dt;
            }
        }
    }

    #endregion

    #region AJAX Request Handlers

    /// <summary>
    /// Processes batch operation AJAX requests. Call from Page_Load.
    /// This overload accepts action and connectionString directly.
    /// </summary>
    public static void ProcessAjaxRequest(string action, HttpRequest request, HttpResponse response, string connectionString)
    {
        if (string.IsNullOrEmpty(action)) return;
        
        response.ContentType = "application/json";
        response.Clear();
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        
        bool handled = false;
        try
        {
            switch (action)
            {
                case "PreviewBatchStatus":
                    HandlePreviewBatchStatus(request, response, serializer);
                    handled = true;
                    break;
                    
                case "ApplyBatchStatus":
                    HandleApplyBatchStatus(request, response, serializer);
                    handled = true;
                    break;
                    
                case "PreviewBatchValidation":
                    HandlePreviewBatchValidation(request, response, serializer);
                    handled = true;
                    break;
                    
                case "ApplyBatchValidation":
                    HandleApplyBatchValidation(request, response, serializer);
                    handled = true;
                    break;
                    
                case "PreviewSummaryReport":
                    HandlePreviewSummaryReport(request, response, serializer);
                    handled = true;
                    break;
                    
                case "GetSpecSummary":
                    HandleGetSpecSummary(request, response, serializer);
                    handled = true;
                    break;
                    
                case "ApplySpecValidation":
                    HandleApplySpecValidation(request, response, serializer);
                    handled = true;
                    break;
            }
            
            // If action was not handled, return error
            if (!handled)
            {
                response.Write(serializer.Serialize(new { success = false, error = "Unknown action: " + action }));
                EndResponse(response);
            }
        }
        catch (Exception ex)
        {
            response.Write(serializer.Serialize(new { success = false, error = ex.Message }));
            EndResponse(response);
        }
    }

    /// <summary>
    /// Processes batch operation AJAX requests. Call from Page_Load.
    /// Returns true if request was handled, false otherwise.
    /// </summary>
    public static bool ProcessAjaxRequest(HttpRequest request, HttpResponse response)
    {
        string action = request.QueryString["action"];
        if (string.IsNullOrEmpty(action)) return false;
        
        response.ContentType = "application/json";
        JavaScriptSerializer serializer = new JavaScriptSerializer();
        
        try
        {
            switch (action)
            {
                case "PreviewBatchStatus":
                    HandlePreviewBatchStatus(request, response, serializer);
                    return true;
                    
                case "ApplyBatchStatus":
                    HandleApplyBatchStatus(request, response, serializer);
                    return true;
                    
                case "PreviewBatchValidation":
                    HandlePreviewBatchValidation(request, response, serializer);
                    return true;
                    
                case "ApplyBatchValidation":
                    HandleApplyBatchValidation(request, response, serializer);
                    return true;
                    
                case "PreviewSummaryReport":
                    HandlePreviewSummaryReport(request, response, serializer);
                    return true;
                    
                case "GetSpecSummary":
                    HandleGetSpecSummary(request, response, serializer);
                    return true;
                    
                case "ApplySpecValidation":
                    HandleApplySpecValidation(request, response, serializer);
                    return true;
            }
        }
        catch (Exception ex)
        {
            response.Write(serializer.Serialize(new { success = false, error = ex.Message }));
            EndResponse(response);
            return true;
        }
        
        return false;
    }

    private static void HandlePreviewBatchStatus(HttpRequest request, HttpResponse response, JavaScriptSerializer serializer)
    {
        string json;
        using (StreamReader reader = new StreamReader(request.InputStream))
        {
            json = reader.ReadToEnd();
        }
        
        Dictionary<string, object> data = serializer.Deserialize<Dictionary<string, object>>(json);
        
        string conditionType = data.ContainsKey("conditionType") ? data["conditionType"].ToString() : "";
        string targetStatus = data.ContainsKey("targetStatus") ? data["targetStatus"].ToString() : "";
        bool negate = data.ContainsKey("negate") && Convert.ToBoolean(data["negate"]);
        string paymentDays = data.ContainsKey("paymentDays") ? data["paymentDays"].ToString() : "";
        string entryYear = data.ContainsKey("entryYear") ? data["entryYear"].ToString() : "";
        string programme = data.ContainsKey("programme") ? data["programme"].ToString() : "";
        string currentStatus = data.ContainsKey("currentStatus") ? data["currentStatus"].ToString() : "";
        
        int count = GetBatchStatusCount(conditionType, targetStatus, negate, paymentDays, entryYear, programme, currentStatus);
        
        response.Write(serializer.Serialize(new { count = count }));
        EndResponse(response);
    }

    private static void HandleApplyBatchStatus(HttpRequest request, HttpResponse response, JavaScriptSerializer serializer)
    {
        string json;
        using (StreamReader reader = new StreamReader(request.InputStream))
        {
            json = reader.ReadToEnd();
        }
        
        Dictionary<string, object> data = serializer.Deserialize<Dictionary<string, object>>(json);
        
        string conditionType = data.ContainsKey("conditionType") ? data["conditionType"].ToString() : "";
        string targetStatus = data.ContainsKey("targetStatus") ? data["targetStatus"].ToString() : "";
        bool negate = data.ContainsKey("negate") && Convert.ToBoolean(data["negate"]);
        string paymentDays = data.ContainsKey("paymentDays") ? data["paymentDays"].ToString() : "";
        string entryYear = data.ContainsKey("entryYear") ? data["entryYear"].ToString() : "";
        string programme = data.ContainsKey("programme") ? data["programme"].ToString() : "";
        string currentStatus = data.ContainsKey("currentStatus") ? data["currentStatus"].ToString() : "";
        
        int updated = ApplyBatchStatusChange(conditionType, targetStatus, negate, paymentDays, entryYear, programme, currentStatus);
        
        response.Write(serializer.Serialize(new { success = true, updated = updated }));
        EndResponse(response);
    }

    private static void HandlePreviewBatchValidation(HttpRequest request, HttpResponse response, JavaScriptSerializer serializer)
    {
        string programme = request.QueryString["programme"] ?? "";
        string entryYear = request.QueryString["entryYear"] ?? "";
        string entryNumbers = request.QueryString["entryNumbers"] ?? "";
        
        int count = GetBatchValidationCount(programme, entryYear, entryNumbers);
        
        response.Write(serializer.Serialize(new { count = count }));
        EndResponse(response);
    }

    private static void HandleApplyBatchValidation(HttpRequest request, HttpResponse response, JavaScriptSerializer serializer)
    {
        string json;
        using (StreamReader reader = new StreamReader(request.InputStream))
        {
            json = reader.ReadToEnd();
        }
        
        Dictionary<string, object> data = serializer.Deserialize<Dictionary<string, object>>(json);
        
        string programme = data.ContainsKey("programme") ? data["programme"].ToString() : "";
        string entryYear = data.ContainsKey("entryYear") ? data["entryYear"].ToString() : "";
        string entryNumbers = data.ContainsKey("entryNumbers") ? data["entryNumbers"].ToString() : "";
        
        int validated = ApplyBatchValidation(programme, entryYear, entryNumbers);
        
        response.Write(serializer.Serialize(new { success = true, validated = validated }));
        EndResponse(response);
    }

    private static void HandlePreviewSummaryReport(HttpRequest request, HttpResponse response, JavaScriptSerializer serializer)
    {
        string programme = request.QueryString["programme"] ?? "";
        string entryYear = request.QueryString["entryYear"] ?? "";
        string studyYear = request.QueryString["studyYear"] ?? "";
        string semester = request.QueryString["semester"] ?? "";
        string entryNumbers = request.QueryString["entryNumbers"] ?? "";
        
        int count = GetSummaryReportStudentCount(programme, entryYear, studyYear, semester, entryNumbers);
        
        response.Write(serializer.Serialize(new { count = count }));
        EndResponse(response);
    }

    private static void HandleGetSpecSummary(HttpRequest request, HttpResponse response, JavaScriptSerializer serializer)
    {
        try
        {
            List<SpecializationSummary> specs = GetSpecializationSummary();
            
            // Convert to anonymous objects for JSON serialization
            var data = new List<object>();
            foreach (var spec in specs)
            {
                data.Add(new
                {
                    specId = spec.SpecId,
                    specName = spec.SpecName,
                    progId = spec.ProgId,
                    progName = spec.ProgName,
                    y1Courses = spec.Y1Courses,
                    y2Courses = spec.Y2Courses,
                    y3Courses = spec.Y3Courses,
                    y4Courses = spec.Y4Courses,
                    studentCount = spec.StudentCount,
                    isFullySet = spec.IsFullySet
                });
            }
            
            response.Write(serializer.Serialize(new { success = true, data = data }));
        }
        catch (Exception ex)
        {
            response.Write(serializer.Serialize(new { success = false, message = ex.Message }));
        }
        EndResponse(response);
    }

    private static void HandleApplySpecValidation(HttpRequest request, HttpResponse response, JavaScriptSerializer serializer)
    {
        try
        {
            var result = ApplySpecializationValidation();
            
            response.Write(serializer.Serialize(new { 
                success = true, 
                updatedToYes = result["updatedToYes"], 
                updatedToNo = result["updatedToNo"] 
            }));
        }
        catch (Exception ex)
        {
            response.Write(serializer.Serialize(new { success = false, message = ex.Message }));
        }
        EndResponse(response);
    }

    private static void EndResponse(HttpResponse response)
    {
        try { response.End(); }
        catch (System.Threading.ThreadAbortException) { /* Expected */ }
    }

    #endregion
}
