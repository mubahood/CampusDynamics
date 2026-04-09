using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;

/// <summary>
/// Centralised data-access helper for the Graduate / Masters module.
/// Provides thesis/supervisor CRUD, student listing with research data,
/// and report-data enrichment (injecting thesis_title + supervisor_name
/// into ResultsData when the stored procedure does not include them).
///
/// Connection: vacConnectionString → campus_dynamics (main DB).
///
/// Usage:
///   DataTable dt = GraduateHelper.GetStudentsWithThesis();
///   GraduateHelper.SaveThesisInfo("2020/FEB/BSE/1234", "My Thesis Title", 5);
///   GraduateHelper.EnrichTranscriptData(resultsDataSet, "2020/FEB/BSE/1234");
/// </summary>
public static class GraduateHelper
{
    // ───────────────────────── Connection ──────────────────────────────────

    private static string ConnStr
    {
        get
        {
            var cs = ConfigurationManager.ConnectionStrings["vacConnectionString"];
            if (cs == null || string.IsNullOrEmpty(cs.ConnectionString))
                throw new InvalidOperationException(
                    "Missing 'vacConnectionString' in web.config connectionStrings section.");
            return cs.ConnectionString;
        }
    }

    private static MySqlConnection OpenConnection()
    {
        var conn = new MySqlConnection(ConnStr);
        conn.Open();
        return conn;
    }

    /// <summary>Creates a named MySql parameter.</summary>
    public static MySqlParameter P(string name, object value)
    {
        return new MySqlParameter(name, value ?? DBNull.Value);
    }

    // ───────────────────────── Student Listing ────────────────────────────

    /// <summary>
    /// Returns graduate students with thesis/supervisor info joined in.
    /// Columns: regno, entryno, firstname, othername, gender, nationality,
    ///          studPhone, email, progname, progcode, thesis_title,
    ///          res_topic, supervior_id, supervisor_name, res_status
    /// </summary>
    public static DataTable GetStudentsWithThesis()
    {
        string sql = @"
            SELECT 
                s.regno,
                s.entryno,
                s.firstname,
                s.othername,
                s.gender,
                s.nationality,
                s.studPhone,
                s.email,
                p.progname,
                p.progcode,
                IFNULL(gr.res_topic, '') AS thesis_title,
                gr.res_topic,
                gr.supervior_id,
                IFNULL(sv.supervior_name, '') AS supervisor_name,
                IFNULL(gr.res_status, '') AS res_status,
                gr.id AS research_id
            FROM acad_student s
            INNER JOIN acad_programme p ON p.progcode = s.progid
            LEFT JOIN acad_graduate_research gr ON TRIM(gr.regno) = TRIM(s.regno)
            LEFT JOIN acad_superviors sv ON sv.Id = gr.supervior_id
            WHERE p.levelCode IN (5, 6, 7, 8)
            ORDER BY s.firstname, s.othername";

        return ExecuteDataTable(sql);
    }

    /// <summary>
    /// Search graduate students by name, regno, or programme.
    /// </summary>
    public static DataTable SearchStudents(string searchTerm)
    {
        string sql = @"
            SELECT 
                s.regno,
                s.entryno,
                s.firstname,
                s.othername,
                s.gender,
                s.nationality,
                s.studPhone,
                s.email,
                p.progname,
                p.progcode,
                IFNULL(gr.res_topic, '') AS thesis_title,
                gr.res_topic,
                gr.supervior_id,
                IFNULL(sv.supervior_name, '') AS supervisor_name,
                IFNULL(gr.res_status, '') AS res_status,
                gr.id AS research_id
            FROM acad_student s
            INNER JOIN acad_programme p ON p.progcode = s.progid
            LEFT JOIN acad_graduate_research gr ON TRIM(gr.regno) = TRIM(s.regno)
            LEFT JOIN acad_superviors sv ON sv.Id = gr.supervior_id
            WHERE p.levelCode IN (5, 6, 7, 8)
              AND (s.firstname LIKE @search
                   OR s.othername LIKE @search
                   OR s.regno LIKE @search
                   OR p.progname LIKE @search)
            ORDER BY s.firstname, s.othername";

        return ExecuteDataTable(sql, P("@search", "%" + (searchTerm ?? "") + "%"));
    }

    /// <summary>Returns all active supervisors for dropdown population.</summary>
    public static DataTable GetSupervisors()
    {
        return ExecuteDataTable(
            "SELECT Id, supervior_name, contact, category FROM acad_superviors WHERE status = 'ACTIVE' ORDER BY supervior_name");
    }

    /// <summary>Returns all supervisors (active + inactive) for management.</summary>
    public static DataTable GetAllSupervisors()
    {
        return ExecuteDataTable(
            "SELECT Id, supervior_name, contact, status, category FROM acad_superviors ORDER BY supervior_name");
    }

    // ───────────────────────── Thesis CRUD ────────────────────────────────

    /// <summary>
    /// Saves thesis info for a student. If a research record already exists
    /// for this student, it updates; otherwise inserts a new record.
    /// </summary>
    public static void SaveThesisInfo(string regno, string thesisTitle, int supervisorId)
    {
        // Check if a record already exists
        object existing = ExecuteScalar(
            "SELECT id FROM acad_graduate_research WHERE TRIM(regno) = @reg LIMIT 1",
            P("@reg", (regno ?? "").Trim()));

        if (existing != null && existing != DBNull.Value)
        {
            // Update existing record
            ExecuteNonQuery(
                @"UPDATE acad_graduate_research 
                  SET res_topic = @title, supervior_id = @sid
                  WHERE TRIM(regno) = @reg",
                P("@title", thesisTitle ?? ""),
                P("@sid", supervisorId > 0 ? (object)supervisorId : DBNull.Value),
                P("@reg", (regno ?? "").Trim()));
        }
        else
        {
            // Insert new record
            ExecuteNonQuery(
                @"INSERT INTO acad_graduate_research (res_topic, supervior_id, regno, res_status)
                  VALUES (@title, @sid, @reg, 'In Progress')",
                P("@title", thesisTitle ?? ""),
                P("@sid", supervisorId > 0 ? (object)supervisorId : DBNull.Value),
                P("@reg", (regno ?? "").Trim()));
        }
    }

    /// <summary>
    /// Saves thesis info with supervisor name as free text.
    /// Looks up or creates a supervisor record in acad_superviors.
    /// </summary>
    public static void SaveThesisInfoText(string regno, string thesisTitle, string supervisorName)
    {
        int supervisorId = 0;
        if (!string.IsNullOrEmpty((supervisorName ?? "").Trim()))
        {
            supervisorId = FindOrCreateSupervisor(supervisorName.Trim());
        }
        SaveThesisInfo(regno, thesisTitle, supervisorId);
    }

    /// <summary>
    /// Finds supervisor by name, or creates a new record. Returns the Id.
    /// </summary>
    public static int FindOrCreateSupervisor(string supervisorName)
    {
        if (string.IsNullOrEmpty((supervisorName ?? "").Trim()))
            return 0;

        string trimmed = supervisorName.Trim();

        // Look up by name (case-insensitive)
        object existing = ExecuteScalar(
            "SELECT Id FROM acad_superviors WHERE TRIM(supervior_name) = @name LIMIT 1",
            P("@name", trimmed));

        if (existing != null && existing != DBNull.Value)
            return Convert.ToInt32(existing);

        // Create new supervisor
        ExecuteNonQuery(
            @"INSERT INTO acad_superviors (supervior_name, contact, status, category)
              VALUES (@name, '', 'ACTIVE', '')",
            P("@name", trimmed));

        object newId = ExecuteScalar(
            "SELECT Id FROM acad_superviors WHERE TRIM(supervior_name) = @name LIMIT 1",
            P("@name", trimmed));

        return (newId != null && newId != DBNull.Value) ? Convert.ToInt32(newId) : 0;
    }

    /// <summary>
    /// Gets thesis info for a single student.
    /// Returns: thesis_title, supervisor_name, supervior_id, res_status, research_id
    /// </summary>
    public static DataRow GetThesisInfo(string regno)
    {
        DataTable dt = ExecuteDataTable(
            @"SELECT 
                IFNULL(gr.res_topic, '') AS thesis_title,
                IFNULL(sv.supervior_name, '') AS supervisor_name,
                IFNULL(gr.supervior_id, 0) AS supervior_id,
                IFNULL(gr.res_status, '') AS res_status,
                gr.id AS research_id
              FROM acad_graduate_research gr
              LEFT JOIN acad_superviors sv ON sv.Id = gr.supervior_id
              WHERE TRIM(gr.regno) = @reg
              LIMIT 1",
            P("@reg", (regno ?? "").Trim()));

        return dt.Rows.Count > 0 ? dt.Rows[0] : null;
    }

    // ───────────────────────── Stats ──────────────────────────────────────

    /// <summary>
    /// Returns aggregate stats for the dashboard cards.
    /// Keys: total, withThesis, withSupervisor, inProgress, completed
    /// </summary>
    public static Dictionary<string, int> GetStats()
    {
        var result = new Dictionary<string, int>();
        string sql = @"
            SELECT 
                COUNT(DISTINCT s.regno) AS total,
                COUNT(DISTINCT CASE WHEN gr.res_topic IS NOT NULL AND TRIM(gr.res_topic) != '' THEN s.regno END) AS withThesis,
                COUNT(DISTINCT CASE WHEN gr.supervior_id IS NOT NULL THEN s.regno END) AS withSupervisor,
                COUNT(DISTINCT CASE WHEN gr.res_status = 'In Progress' THEN s.regno END) AS inProgress,
                COUNT(DISTINCT CASE WHEN gr.res_status = 'Completed' THEN s.regno END) AS completed
            FROM acad_student s
            INNER JOIN acad_programme p ON p.progcode = s.progid
            LEFT JOIN acad_graduate_research gr ON TRIM(gr.regno) = TRIM(s.regno)
            WHERE p.levelCode IN (5, 6, 7, 8)";

        DataTable dt = ExecuteDataTable(sql);
        if (dt.Rows.Count > 0)
        {
            DataRow row = dt.Rows[0];
            result["total"] = Convert.ToInt32(row["total"]);
            result["withThesis"] = Convert.ToInt32(row["withThesis"]);
            result["withSupervisor"] = Convert.ToInt32(row["withSupervisor"]);
            result["inProgress"] = Convert.ToInt32(row["inProgress"]);
            result["completed"] = Convert.ToInt32(row["completed"]);
        }
        return result;
    }

    // ───────────────────────── Report Enrichment ──────────────────────────

    /// <summary>
    /// Enriches the transcript DataTable with thesis_title and supervisor_name
    /// columns. Called from report BeforePrint or from CertificateDataHelper.
    /// If the columns already exist in the DataTable (stored proc was updated),
    /// this method does nothing except fill in missing values.
    /// </summary>
    public static void EnrichTranscriptData(ResultsData DS, string regno)
    {
        try
        {
            DataTable dt = DS.acad_GetBatchStudentTranscriptData;
            if (dt == null) return;

            // Ensure columns exist
            if (!dt.Columns.Contains("thesis_title"))
                dt.Columns.Add("thesis_title", typeof(string));
            if (!dt.Columns.Contains("supervisor_name"))
                dt.Columns.Add("supervisor_name", typeof(string));

            // Query thesis/supervisor data
            DataRow thesisRow = GetThesisInfo(regno);

            string thesisTitle = "";
            string supervisorName = "";
            if (thesisRow != null)
            {
                thesisTitle = thesisRow["thesis_title"] != DBNull.Value
                    ? thesisRow["thesis_title"].ToString().Trim() : "";
                supervisorName = thesisRow["supervisor_name"] != DBNull.Value
                    ? thesisRow["supervisor_name"].ToString().Trim() : "";
            }

            // Fill in the data for all rows matching this regno
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                object regVal = dt.Rows[i]["regno"];
                string rowReg = (regVal != null && regVal != DBNull.Value)
                    ? regVal.ToString().Trim() : "";

                if (string.Equals(rowReg, (regno ?? "").Trim(), StringComparison.OrdinalIgnoreCase))
                {
                    object existingTitle = dt.Rows[i]["thesis_title"];
                    if (existingTitle == null || existingTitle == DBNull.Value
                        || string.IsNullOrEmpty(existingTitle.ToString().Trim()))
                    {
                        dt.Rows[i]["thesis_title"] = thesisTitle;
                    }

                    object existingSupervisor = dt.Rows[i]["supervisor_name"];
                    if (existingSupervisor == null || existingSupervisor == DBNull.Value
                        || string.IsNullOrEmpty(existingSupervisor.ToString().Trim()))
                    {
                        dt.Rows[i]["supervisor_name"] = supervisorName;
                    }
                }
            }
        }
        catch (Exception)
        {
            // Graceful degradation — reports still work without thesis data
        }
    }

    /// <summary>
    /// Enriches transcript data for ALL students in the dataset.
    /// Used when generating batch reports.
    /// </summary>
    public static void EnrichTranscriptDataBatch(ResultsData DS)
    {
        try
        {
            DataTable dt = DS.acad_GetBatchStudentTranscriptData;
            if (dt == null || dt.Rows.Count == 0) return;

            // Ensure columns exist
            if (!dt.Columns.Contains("thesis_title"))
                dt.Columns.Add("thesis_title", typeof(string));
            if (!dt.Columns.Contains("supervisor_name"))
                dt.Columns.Add("supervisor_name", typeof(string));

            // Collect unique regnos
            var regnos = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                object val = dt.Rows[i]["regno"];
                if (val != null && val != DBNull.Value && !string.IsNullOrEmpty(val.ToString().Trim()))
                    regnos.Add(val.ToString().Trim());
            }

            if (regnos.Count == 0) return;

            // Batch query for all thesis/supervisor data
            string inClause = "";
            int idx = 0;
            var parameters = new List<MySqlParameter>();
            foreach (string reg in regnos)
            {
                if (idx > 0) inClause += ", ";
                string pName = "@r" + idx;
                inClause += pName;
                parameters.Add(P(pName, reg));
                idx++;
            }

            string sql = String.Format(@"
                SELECT 
                    TRIM(gr.regno) AS regno,
                    IFNULL(gr.res_topic, '') AS thesis_title,
                    IFNULL(sv.supervior_name, '') AS supervisor_name
                FROM acad_graduate_research gr
                LEFT JOIN acad_superviors sv ON sv.Id = gr.supervior_id
                WHERE TRIM(gr.regno) IN ({0})", inClause);

            DataTable thesisData = ExecuteDataTable(sql, parameters.ToArray());

            // Build lookup
            var lookup = new Dictionary<string, DataRow>(StringComparer.OrdinalIgnoreCase);
            for (int i = 0; i < thesisData.Rows.Count; i++)
            {
                string key = thesisData.Rows[i]["regno"].ToString().Trim();
                if (!lookup.ContainsKey(key))
                    lookup[key] = thesisData.Rows[i];
            }

            // Apply to transcript rows
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                string rowReg = dt.Rows[i]["regno"] != null && dt.Rows[i]["regno"] != DBNull.Value
                    ? dt.Rows[i]["regno"].ToString().Trim() : "";

                DataRow thesisRow;
                if (!string.IsNullOrEmpty(rowReg) && lookup.TryGetValue(rowReg, out thesisRow))
                {
                    object existingTitle = dt.Rows[i]["thesis_title"];
                    if (existingTitle == null || existingTitle == DBNull.Value
                        || string.IsNullOrEmpty(existingTitle.ToString().Trim()))
                    {
                        dt.Rows[i]["thesis_title"] = thesisRow["thesis_title"];
                    }

                    object existingSup = dt.Rows[i]["supervisor_name"];
                    if (existingSup == null || existingSup == DBNull.Value
                        || string.IsNullOrEmpty(existingSup.ToString().Trim()))
                    {
                        dt.Rows[i]["supervisor_name"] = thesisRow["supervisor_name"];
                    }
                }
            }
        }
        catch (Exception)
        {
            // Graceful degradation
        }
    }

    // ───────────────────────── Low-level DB methods ───────────────────────

    private static DataTable ExecuteDataTable(string sql, params MySqlParameter[] parameters)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = OpenConnection())
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parameters != null)
            {
                foreach (var p in parameters) cmd.Parameters.Add(p);
            }
            using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
            {
                da.Fill(dt);
            }
        }
        return dt;
    }

    private static object ExecuteScalar(string sql, params MySqlParameter[] parameters)
    {
        using (MySqlConnection conn = OpenConnection())
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parameters != null)
            {
                foreach (var p in parameters) cmd.Parameters.Add(p);
            }
            return cmd.ExecuteScalar();
        }
    }

    private static int ExecuteNonQuery(string sql, params MySqlParameter[] parameters)
    {
        using (MySqlConnection conn = OpenConnection())
        using (MySqlCommand cmd = new MySqlCommand(sql, conn))
        {
            if (parameters != null)
            {
                foreach (var p in parameters) cmd.Parameters.Add(p);
            }
            return cmd.ExecuteNonQuery();
        }
    }
}
