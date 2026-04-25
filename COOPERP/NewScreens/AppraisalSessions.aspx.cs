using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_AppraisalSessions : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return System.Configuration.ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // ─── Query-string helpers ──────────────────────────────────────────
    private int    QsPage   { get { int v; return int.TryParse(Request.QueryString["page"] ?? "1", out v) && v > 0 ? v : 1; } }
    private string QsSearch { get { return (Request.QueryString["q"]      ?? "").Trim(); } }
    private string QsStatus { get { return (Request.QueryString["status"] ?? "").Trim().ToUpper(); } }

    // ═══════════════════════════════════════════════════════════════════
    //  ONE-TIME SCHEMA MIGRATION
    // ═══════════════════════════════════════════════════════════════════
    private static bool _schemaChecked = false;

    private void EnsureDbSchema()
    {
        if (_schemaChecked) return;
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnStr))
            {
                conn.Open();

                // ── 1. appraisal_sessions ──────────────────────────────────
                CreateTableIfMissing(conn, "appraisal_sessions", @"
                    CREATE TABLE `appraisal_sessions` (
                        `session_id`         INT AUTO_INCREMENT PRIMARY KEY,
                        `session_title`      VARCHAR(255) NOT NULL,
                        `session_description` TEXT,
                        `period_start`       DATE NOT NULL,
                        `period_end`         DATE NOT NULL,
                        `deadline`           DATE NOT NULL,
                        `target_categories`  VARCHAR(255) NOT NULL DEFAULT 'ACADEMIC,ADMINISTRATIVE,SUPPORT',
                        `status`             VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
                        `created_by`         INT DEFAULT NULL,
                        `created_at`         DATETIME DEFAULT CURRENT_TIMESTAMP,
                        `updated_at`         DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // ── 2. appraisal_records ───────────────────────────────────
                CreateTableIfMissing(conn, "appraisal_records", @"
                    CREATE TABLE `appraisal_records` (
                        `record_id`                INT AUTO_INCREMENT PRIMARY KEY,
                        `session_id`               INT NOT NULL,
                        `employee_id`              INT NOT NULL,
                        `reviewer_id`              INT DEFAULT NULL,
                        `staff_category`           VARCHAR(20) NOT NULL DEFAULT 'ADMINISTRATIVE',
                        `status`                   VARCHAR(30) NOT NULL DEFAULT 'PENDING',
                        `employee_submitted_at`    DATETIME DEFAULT NULL,
                        `supervisor_submitted_at`  DATETIME DEFAULT NULL,
                        `section_b_self_total`     DECIMAL(5,2) DEFAULT NULL,
                        `section_b_supervisor_total` DECIMAL(5,2) DEFAULT NULL,
                        `section_c_total`          DECIMAL(5,2) DEFAULT NULL,
                        `raw_score`                DECIMAL(5,2) DEFAULT NULL,
                        `max_possible`             DECIMAL(5,2) DEFAULT NULL,
                        `final_percentage`         DECIMAL(5,2) DEFAULT NULL,
                        `classification`           VARCHAR(50) DEFAULT NULL,
                        `created_at`               DATETIME DEFAULT CURRENT_TIMESTAMP,
                        `updated_at`               DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        INDEX `idx_session` (`session_id`),
                        INDEX `idx_employee` (`employee_id`),
                        INDEX `idx_reviewer` (`reviewer_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // ── 3. appraisal_section_b ─────────────────────────────────
                CreateTableIfMissing(conn, "appraisal_section_b", @"
                    CREATE TABLE `appraisal_section_b` (
                        `entry_id`              INT AUTO_INCREMENT PRIMARY KEY,
                        `record_id`             INT NOT NULL,
                        `slot_number`           TINYINT NOT NULL,
                        `agreed_output`         TEXT,
                        `performance_indicators` TEXT,
                        `result_areas`          TEXT,
                        `self_rating`           TINYINT DEFAULT NULL,
                        `supervisor_rating`     TINYINT DEFAULT NULL,
                        `comments`              TEXT,
                        INDEX `idx_record` (`record_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // ── 4. appraisal_section_c ─────────────────────────────────
                CreateTableIfMissing(conn, "appraisal_section_c", @"
                    CREATE TABLE `appraisal_section_c` (
                        `entry_id`          INT AUTO_INCREMENT PRIMARY KEY,
                        `record_id`         INT NOT NULL,
                        `competency_code`   VARCHAR(10) NOT NULL,
                        `competency_name`   VARCHAR(255) NOT NULL,
                        `category_name`     VARCHAR(100) NOT NULL,
                        `rating`            TINYINT DEFAULT NULL,
                        `is_na`             TINYINT(1) NOT NULL DEFAULT 0,
                        `comment`           TEXT,
                        INDEX `idx_record` (`record_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // ── 5. appraisal_section_d ─────────────────────────────────
                CreateTableIfMissing(conn, "appraisal_section_d", @"
                    CREATE TABLE `appraisal_section_d` (
                        `entry_id`          INT AUTO_INCREMENT PRIMARY KEY,
                        `record_id`         INT NOT NULL,
                        `performance_gap`   TEXT,
                        `agreed_action`     TEXT,
                        `time_frame`        VARCHAR(100),
                        INDEX `idx_record` (`record_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // ── 6. appraisal_section_e ─────────────────────────────────
                CreateTableIfMissing(conn, "appraisal_section_e", @"
                    CREATE TABLE `appraisal_section_e` (
                        `entry_id`          INT AUTO_INCREMENT PRIMARY KEY,
                        `record_id`         INT NOT NULL,
                        `question_number`   TINYINT NOT NULL,
                        `question_text`     TEXT NOT NULL,
                        `response`          TEXT,
                        INDEX `idx_record` (`record_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // ── 7. appraisal_competency_templates ──────────────────────
                CreateTableIfMissing(conn, "appraisal_competency_templates", @"
                    CREATE TABLE `appraisal_competency_templates` (
                        `template_id`       INT AUTO_INCREMENT PRIMARY KEY,
                        `staff_category`    VARCHAR(20) NOT NULL,
                        `competency_code`   VARCHAR(10) NOT NULL,
                        `category_name`     VARCHAR(100) NOT NULL,
                        `competency_name`   VARCHAR(255) NOT NULL,
                        `description`       TEXT,
                        `sort_order`        INT NOT NULL DEFAULT 0,
                        INDEX `idx_category` (`staff_category`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

                // ── Seed competency templates if empty ─────────────────────
                SeedCompetencyTemplates(conn);
            }
        }
        catch { }
        _schemaChecked = true;
    }

    private void CreateTableIfMissing(MySqlConnection conn, string table, string createSql)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @t", conn))
        {
            cmd.Parameters.AddWithValue("@t", table);
            if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
            {
                using (MySqlCommand create = new MySqlCommand(createSql, conn))
                {
                    create.ExecuteNonQuery();
                }
            }
        }
    }

    private void AddColumnIfMissing(MySqlConnection conn, string table, string column, string definition)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            "SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @t AND COLUMN_NAME = @c", conn))
        {
            cmd.Parameters.AddWithValue("@t", table);
            cmd.Parameters.AddWithValue("@c", column);
            if (Convert.ToInt32(cmd.ExecuteScalar()) == 0)
            {
                using (MySqlCommand alter = new MySqlCommand(
                    string.Format("ALTER TABLE `{0}` ADD COLUMN `{1}` {2}", table, column, definition), conn))
                {
                    alter.ExecuteNonQuery();
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  SEED COMPETENCY TEMPLATES
    // ═══════════════════════════════════════════════════════════════════
    private void SeedCompetencyTemplates(MySqlConnection conn)
    {
        using (MySqlCommand chk = new MySqlCommand("SELECT COUNT(*) FROM appraisal_competency_templates", conn))
        {
            if (Convert.ToInt32(chk.ExecuteScalar()) > 0) return; // already seeded
        }

        // ── ACADEMIC STAFF (52 criteria) ───────────────────────────────
        int s = 0;
        // C1. Teaching Function (6)
        InsertTemplate(conn, "ACADEMIC", "C1.1", "Teaching Function", "Preparation of Schemes of Work and Lesson Plans", ++s);
        InsertTemplate(conn, "ACADEMIC", "C1.2", "Teaching Function", "Coverage of Approved Outlines", ++s);
        InsertTemplate(conn, "ACADEMIC", "C1.3", "Teaching Function", "Use of Recommended Text Books and Materials", ++s);
        InsertTemplate(conn, "ACADEMIC", "C1.4", "Teaching Function", "Uses a Variety of Methods in Teaching", ++s);
        InsertTemplate(conn, "ACADEMIC", "C1.5", "Teaching Function", "Practical Application of Theory", ++s);
        InsertTemplate(conn, "ACADEMIC", "C1.6", "Teaching Function", "Teaching Hours Delivery per Week", ++s);

        // C2. Administration (7)
        InsertTemplate(conn, "ACADEMIC", "C2.1", "Administration", "Keep Necessary Records", ++s);
        InsertTemplate(conn, "ACADEMIC", "C2.2", "Administration", "Usage of Available Facilities", ++s);
        InsertTemplate(conn, "ACADEMIC", "C2.3", "Administration", "Attention to Student Welfare", ++s);
        InsertTemplate(conn, "ACADEMIC", "C2.4", "Administration", "Managing Student Discipline", ++s);
        InsertTemplate(conn, "ACADEMIC", "C2.5", "Administration", "Budgetary Planning and Monitoring", ++s);
        InsertTemplate(conn, "ACADEMIC", "C2.6", "Administration", "Capacity to Handle and Manage Meetings", ++s);
        InsertTemplate(conn, "ACADEMIC", "C2.7", "Administration", "Meeting Deadlines (e.g. exams, reports)", ++s);

        // C3. Examinations (6)
        InsertTemplate(conn, "ACADEMIC", "C3.1", "Examinations", "Gives Assignments, Course Work and Tests per Semester", ++s);
        InsertTemplate(conn, "ACADEMIC", "C3.2", "Examinations", "Quality of Examination Papers", ++s);
        InsertTemplate(conn, "ACADEMIC", "C3.3", "Examinations", "Timely Submission of Examination Papers", ++s);
        InsertTemplate(conn, "ACADEMIC", "C3.4", "Examinations", "Timely Marking and Return of Answer Scripts", ++s);
        InsertTemplate(conn, "ACADEMIC", "C3.5", "Examinations", "Timely Submission of Results", ++s);
        InsertTemplate(conn, "ACADEMIC", "C3.6", "Examinations", "Invigilation and Supervision of Examinations", ++s);

        // C4. Research and Publications (7)
        InsertTemplate(conn, "ACADEMIC", "C4.1", "Research and Publications", "Published Research Papers/Articles", ++s);
        InsertTemplate(conn, "ACADEMIC", "C4.2", "Research and Publications", "Published Books/Chapters", ++s);
        InsertTemplate(conn, "ACADEMIC", "C4.3", "Research and Publications", "Work-in-Progress Research", ++s);
        InsertTemplate(conn, "ACADEMIC", "C4.4", "Research and Publications", "Presentation at Conferences/Seminars", ++s);
        InsertTemplate(conn, "ACADEMIC", "C4.5", "Research and Publications", "Innovation and Patents", ++s);
        InsertTemplate(conn, "ACADEMIC", "C4.6", "Research and Publications", "Membership of Professional Bodies", ++s);
        InsertTemplate(conn, "ACADEMIC", "C4.7", "Research and Publications", "Community Service and Outreach", ++s);

        // C5. Supervision (2)
        InsertTemplate(conn, "ACADEMIC", "C5.1", "Supervision", "Supervision of Students' Research Projects", ++s);
        InsertTemplate(conn, "ACADEMIC", "C5.2", "Supervision", "Supervision of Tutorials/Practicals", ++s);

        // C6. Training of Trainers (1)
        InsertTemplate(conn, "ACADEMIC", "C6.1", "Training of Trainers", "Mentoring and Development of Junior Staff", ++s);

        // C7. Relations (8)
        InsertTemplate(conn, "ACADEMIC", "C7.1", "Relations", "Interpersonal Relations", ++s);
        InsertTemplate(conn, "ACADEMIC", "C7.2", "Relations", "Team Work and Cooperation", ++s);
        InsertTemplate(conn, "ACADEMIC", "C7.3", "Relations", "Loyalty and Commitment", ++s);
        InsertTemplate(conn, "ACADEMIC", "C7.4", "Relations", "Dependability", ++s);
        InsertTemplate(conn, "ACADEMIC", "C7.5", "Relations", "Integrity and Ethical Conduct", ++s);
        InsertTemplate(conn, "ACADEMIC", "C7.6", "Relations", "Customer Care", ++s);
        InsertTemplate(conn, "ACADEMIC", "C7.7", "Relations", "Punctuality and Attendance", ++s);
        InsertTemplate(conn, "ACADEMIC", "C7.8", "Relations", "Adaptability and Flexibility", ++s);

        // C8. Skills (8)
        InsertTemplate(conn, "ACADEMIC", "C8.1", "Skills", "Communication Skills (Written)", ++s);
        InsertTemplate(conn, "ACADEMIC", "C8.2", "Skills", "Communication Skills (Verbal)", ++s);
        InsertTemplate(conn, "ACADEMIC", "C8.3", "Skills", "Computer and ICT Skills", ++s);
        InsertTemplate(conn, "ACADEMIC", "C8.4", "Skills", "Planning and Organisation", ++s);
        InsertTemplate(conn, "ACADEMIC", "C8.5", "Skills", "Time Management", ++s);
        InsertTemplate(conn, "ACADEMIC", "C8.6", "Skills", "Decision Making", ++s);
        InsertTemplate(conn, "ACADEMIC", "C8.7", "Skills", "Problem Solving", ++s);
        InsertTemplate(conn, "ACADEMIC", "C8.8", "Skills", "Initiative and Creativity", ++s);

        // C9. Competences (7)
        InsertTemplate(conn, "ACADEMIC", "C9.1", "Competences", "Professional Knowledge and Skills", ++s);
        InsertTemplate(conn, "ACADEMIC", "C9.2", "Competences", "Quality of Work and Results", ++s);
        InsertTemplate(conn, "ACADEMIC", "C9.3", "Competences", "Record Keeping", ++s);
        InsertTemplate(conn, "ACADEMIC", "C9.4", "Competences", "Financial Management and Accountability", ++s);
        InsertTemplate(conn, "ACADEMIC", "C9.5", "Competences", "Discretion and Confidentiality", ++s);
        InsertTemplate(conn, "ACADEMIC", "C9.6", "Competences", "Managing People (if applicable)", ++s);
        InsertTemplate(conn, "ACADEMIC", "C9.7", "Competences", "Continuous Professional Development", ++s);

        // ── ADMINISTRATIVE STAFF (22 criteria) ────────────────────────
        s = 0;
        InsertTemplate(conn, "ADMINISTRATIVE", "A1",  "Core Competencies", "Professional Knowledge/Skills", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A2",  "Core Competencies", "Planning, Organising & Coordinating", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A3",  "Core Competencies", "Managing People", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A4",  "Core Competencies", "Decision Making", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A5",  "Core Competencies", "Team Work", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A6",  "Core Competencies", "Initiative", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A7",  "Core Competencies", "Writing & Communication Skills", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A8",  "Core Competencies", "Integrity", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A9",  "Core Competencies", "Time Management & Meeting Deadlines", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A10", "Core Competencies", "Meetings", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A11", "Core Competencies", "Dependability", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A12", "Core Competencies", "Loyalty", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A13", "Core Competencies", "Financial Management & Accountability", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A14", "Core Competencies", "Quality of Work & Results", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A15", "Core Competencies", "Record Keeping", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A16", "Core Competencies", "Interpersonal Relations", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A17", "Core Competencies", "Verbal & Listening Skills", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A18", "Core Competencies", "Discretion & Confidentiality", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A19", "Core Competencies", "Punctuality & Attendance", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A20", "Core Competencies", "Computer Knowledge", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A21", "Core Competencies", "Customer Care", ++s);
        InsertTemplate(conn, "ADMINISTRATIVE", "A22", "Core Competencies", "Adaptability & Flexibility", ++s);

        // ── SUPPORT STAFF (25 criteria — placeholder, to be refined) ──
        s = 0;
        InsertTemplate(conn, "SUPPORT", "S1",  "Core Competencies", "Professional Knowledge/Skills", ++s);
        InsertTemplate(conn, "SUPPORT", "S2",  "Core Competencies", "Planning & Organisation", ++s);
        InsertTemplate(conn, "SUPPORT", "S3",  "Core Competencies", "Team Work", ++s);
        InsertTemplate(conn, "SUPPORT", "S4",  "Core Competencies", "Initiative", ++s);
        InsertTemplate(conn, "SUPPORT", "S5",  "Core Competencies", "Communication Skills", ++s);
        InsertTemplate(conn, "SUPPORT", "S6",  "Core Competencies", "Integrity", ++s);
        InsertTemplate(conn, "SUPPORT", "S7",  "Core Competencies", "Time Management", ++s);
        InsertTemplate(conn, "SUPPORT", "S8",  "Core Competencies", "Dependability", ++s);
        InsertTemplate(conn, "SUPPORT", "S9",  "Core Competencies", "Loyalty", ++s);
        InsertTemplate(conn, "SUPPORT", "S10", "Core Competencies", "Quality of Work", ++s);
        InsertTemplate(conn, "SUPPORT", "S11", "Core Competencies", "Record Keeping", ++s);
        InsertTemplate(conn, "SUPPORT", "S12", "Core Competencies", "Interpersonal Relations", ++s);
        InsertTemplate(conn, "SUPPORT", "S13", "Core Competencies", "Punctuality & Attendance", ++s);
        InsertTemplate(conn, "SUPPORT", "S14", "Core Competencies", "Customer Care", ++s);
        InsertTemplate(conn, "SUPPORT", "S15", "Core Competencies", "Adaptability & Flexibility", ++s);
        InsertTemplate(conn, "SUPPORT", "S16", "Core Competencies", "Safety & Hygiene Awareness", ++s);
        InsertTemplate(conn, "SUPPORT", "S17", "Core Competencies", "Equipment/Tool Handling", ++s);
        InsertTemplate(conn, "SUPPORT", "S18", "Core Competencies", "Respect for Authority", ++s);
        InsertTemplate(conn, "SUPPORT", "S19", "Core Competencies", "Willingness to Learn", ++s);
        InsertTemplate(conn, "SUPPORT", "S20", "Core Competencies", "Responsibility & Accountability", ++s);
        InsertTemplate(conn, "SUPPORT", "S21", "Core Competencies", "Physical Fitness for Duties", ++s);
        InsertTemplate(conn, "SUPPORT", "S22", "Core Competencies", "Cooperation with Colleagues", ++s);
        InsertTemplate(conn, "SUPPORT", "S23", "Core Competencies", "Problem Reporting", ++s);
        InsertTemplate(conn, "SUPPORT", "S24", "Core Competencies", "Resource Conservation", ++s);
        InsertTemplate(conn, "SUPPORT", "S25", "Core Competencies", "Dress Code & Personal Presentation", ++s);
    }

    private void InsertTemplate(MySqlConnection conn, string category, string code, string catName, string name, int order)
    {
        using (MySqlCommand cmd = new MySqlCommand(
            @"INSERT INTO appraisal_competency_templates (staff_category, competency_code, category_name, competency_name, sort_order)
              VALUES (@cat, @code, @catName, @name, @ord)", conn))
        {
            cmd.Parameters.AddWithValue("@cat", category);
            cmd.Parameters.AddWithValue("@code", code);
            cmd.Parameters.AddWithValue("@catName", catName);
            cmd.Parameters.AddWithValue("@name", name);
            cmd.Parameters.AddWithValue("@ord", order);
            cmd.ExecuteNonQuery();
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  PAGE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════
    protected void Page_Load(object sender, EventArgs e)
    {
        EnsureDbSchema();

        string ajax = Request.QueryString["ajax"];
        if (!string.IsNullOrEmpty(ajax))
        {
            HandleAjax(ajax);
            return;
        }

        if (!IsPostBack)
        {
            BindGrid();
            LoadStats();
            ShowFlashMessage();
        }
    }

    // ═══════════════════════════════════════════════════════════════════
    //  AJAX ROUTER
    // ═══════════════════════════════════════════════════════════════════
    private void HandleAjax(string action)
    {
        Response.ContentType = "application/json";
        try
        {
            switch (action)
            {
                case "get_session":      AjaxGetSession(); break;
                case "get_session_detail": AjaxGetSessionDetail(); break;
                case "generate_appraisals": AjaxGenerateAppraisals(); break;
                default:
                    Response.Write("{\"error\":\"Unknown action\"}");
                    break;
            }
        }
        catch (Exception ex)
        {
            Response.Write("{\"error\":\"" + EscapeJson(ex.Message) + "\"}");
        }
        Response.End();
    }

    // ─── AJAX: Get Session for Edit ────────────────────────────────────
    private void AjaxGetSession()
    {
        int id;
        if (!int.TryParse(Request.QueryString["id"], out id))
        { Response.Write("{\"error\":\"Invalid ID\"}"); return; }

        DataTable dt = ExecuteQuery(
            @"SELECT s.*, IFNULL(cr.emp_name,'System') AS created_by_name
              FROM appraisal_sessions s
              LEFT JOIN hrm_employee cr ON cr.empID = s.created_by
              WHERE s.session_id = @id",
            new MySqlParameter("@id", id));

        if (dt.Rows.Count == 0) { Response.Write("{\"error\":\"Not found\"}"); return; }

        DataRow r = dt.Rows[0];
        StringBuilder sb = new StringBuilder("{");
        bool first = true;
        foreach (DataColumn col in dt.Columns)
        {
            if (!first) sb.Append(",");
            first = false;
            string val = "";
            if (r[col] != null && r[col] != DBNull.Value)
            {
                if (col.DataType == typeof(DateTime))
                    val = ((DateTime)r[col]).ToString("yyyy-MM-dd");
                else
                    val = r[col].ToString();
            }
            sb.AppendFormat("\"{0}\":\"{1}\"", col.ColumnName, EscapeJson(val));
        }
        sb.Append("}");
        Response.Write(sb.ToString());
    }

    // ─── AJAX: Get Session Detail (with appraisal stats) ──────────────
    private void AjaxGetSessionDetail()
    {
        int id;
        if (!int.TryParse(Request.QueryString["id"], out id))
        { Response.Write("{\"error\":\"Invalid ID\"}"); return; }

        // Session info
        DataTable dtS = ExecuteQuery(
            @"SELECT s.*, IFNULL(cr.emp_name,'System') AS created_by_name
              FROM appraisal_sessions s
              LEFT JOIN hrm_employee cr ON cr.empID = s.created_by
              WHERE s.session_id = @id",
            new MySqlParameter("@id", id));

        if (dtS.Rows.Count == 0) { Response.Write("{\"error\":\"Not found\"}"); return; }
        DataRow sess = dtS.Rows[0];

        // Appraisal stats
        DataTable dtStats = ExecuteQuery(
            @"SELECT
                COUNT(*) AS total,
                COALESCE(SUM(CASE WHEN ar.status = 'PENDING' THEN 1 ELSE 0 END),0) AS pending,
                COALESCE(SUM(CASE WHEN ar.status IN ('EMPLOYEE_IN_PROGRESS','EMPLOYEE_SUBMITTED') THEN 1 ELSE 0 END),0) AS in_progress,
                COALESCE(SUM(CASE WHEN ar.status = 'COMPLETED' THEN 1 ELSE 0 END),0) AS completed,
                COALESCE(SUM(CASE WHEN ar.status = 'CANCELLED' THEN 1 ELSE 0 END),0) AS cancelled
              FROM appraisal_records ar
              WHERE ar.session_id = @id",
            new MySqlParameter("@id", id));

        DataRow st = dtStats.Rows[0];
        int total = SafeInt(st["total"]);
        int completed = SafeInt(st["completed"]);

        // Individual records
        DataTable dtRecs = ExecuteQuery(
            @"SELECT ar.record_id, ar.status, ar.staff_category,
                     ar.final_percentage, ar.classification,
                     e.emp_name, e.EMP_CODE,
                     IFNULL(rev.emp_name,'Unassigned') AS reviewer_name
              FROM appraisal_records ar
              INNER JOIN hrm_employee e ON e.empID = ar.employee_id
              LEFT JOIN hrm_employee rev ON rev.empID = ar.reviewer_id
              WHERE ar.session_id = @id
              ORDER BY e.emp_name",
            new MySqlParameter("@id", id));

        // Build JSON
        StringBuilder sb = new StringBuilder("{");
        sb.AppendFormat("\"session_id\":\"{0}\",", EscapeJson(sess["session_id"]));
        sb.AppendFormat("\"session_title\":\"{0}\",", EscapeJson(sess["session_title"]));
        sb.AppendFormat("\"status\":\"{0}\",", EscapeJson(sess["status"]));
        sb.AppendFormat("\"period_start\":\"{0}\",", FormatDate(sess["period_start"]));
        sb.AppendFormat("\"period_end\":\"{0}\",", FormatDate(sess["period_end"]));
        sb.AppendFormat("\"deadline\":\"{0}\",", FormatDate(sess["deadline"]));
        sb.AppendFormat("\"target_categories\":\"{0}\",", EscapeJson(sess["target_categories"]));
        sb.AppendFormat("\"created_by_name\":\"{0}\",", EscapeJson(sess["created_by_name"]));
        sb.AppendFormat("\"total\":{0},", total);
        sb.AppendFormat("\"pending\":{0},", SafeInt(st["pending"]));
        sb.AppendFormat("\"in_progress\":{0},", SafeInt(st["in_progress"]));
        sb.AppendFormat("\"completed\":{0},", completed);
        sb.AppendFormat("\"cancelled\":{0},", SafeInt(st["cancelled"]));
        sb.AppendFormat("\"progress_pct\":{0},", total > 0 ? Math.Round((double)completed / total * 100, 1) : 0);

        // Records array
        sb.Append("\"records\":[");
        bool first = true;
        foreach (DataRow r in dtRecs.Rows)
        {
            if (!first) sb.Append(",");
            first = false;
            sb.Append("{");
            sb.AppendFormat("\"record_id\":\"{0}\",", EscapeJson(r["record_id"]));
            sb.AppendFormat("\"emp_name\":\"{0}\",", EscapeJson(r["emp_name"]));
            sb.AppendFormat("\"EMP_CODE\":\"{0}\",", EscapeJson(r["EMP_CODE"]));
            sb.AppendFormat("\"staff_category\":\"{0}\",", EscapeJson(r["staff_category"]));
            sb.AppendFormat("\"reviewer_name\":\"{0}\",", EscapeJson(r["reviewer_name"]));
            sb.AppendFormat("\"status\":\"{0}\",", EscapeJson(r["status"]));
            string pct = (r["final_percentage"] != null && r["final_percentage"] != DBNull.Value)
                ? Convert.ToDecimal(r["final_percentage"]).ToString("F1") : "";
            sb.AppendFormat("\"final_percentage\":\"{0}\",", pct);
            string cls = (r["classification"] != null && r["classification"] != DBNull.Value)
                ? r["classification"].ToString() : "";
            sb.AppendFormat("\"classification\":\"{0}\"", EscapeJson(cls));
            sb.Append("}");
        }
        sb.Append("]}");
        Response.Write(sb.ToString());
    }

    // ─── AJAX: Generate Appraisals for a Session ──────────────────────
    private void AjaxGenerateAppraisals()
    {
        Response.ContentType = "application/json";
        int sessionId;
        if (!int.TryParse(Request.QueryString["id"], out sessionId))
        { Response.Write("{\"error\":\"Invalid session ID\"}"); return; }

        // Get session info
        DataTable dtSess = ExecuteQuery(
            "SELECT target_categories, status FROM appraisal_sessions WHERE session_id = @id",
            new MySqlParameter("@id", sessionId));

        if (dtSess.Rows.Count == 0) { Response.Write("{\"error\":\"Session not found\"}"); return; }

        string sessStatus = dtSess.Rows[0]["status"].ToString();
        if (sessStatus != "ACTIVE")
        { Response.Write("{\"error\":\"Session must be ACTIVE to generate appraisals\"}"); return; }

        string cats = dtSess.Rows[0]["target_categories"].ToString();

        // Check if already generated
        DataTable dtExist = ExecuteQuery(
            "SELECT COUNT(*) AS cnt FROM appraisal_records WHERE session_id = @id",
            new MySqlParameter("@id", sessionId));
        if (SafeInt(dtExist.Rows[0]["cnt"]) > 0)
        { Response.Write("{\"error\":\"Appraisals already generated for this session. Delete existing records first.\"}"); return; }

        // Build category filter
        string[] catArr = cats.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        List<string> catConditions = new List<string>();
        List<MySqlParameter> parms = new List<MySqlParameter>();
        parms.Add(new MySqlParameter("@sid", sessionId));

        for (int i = 0; i < catArr.Length; i++)
        {
            string cat = catArr[i].Trim().ToUpper();
            string pName = "@cat" + i;
            // Map category to EmpType values
            if (cat == "ACADEMIC")
                catConditions.Add("e.EmpType = 'Academic'");
            else if (cat == "ADMINISTRATIVE")
                catConditions.Add("e.EmpType = 'Non-Academic'");
            else if (cat == "SUPPORT")
                catConditions.Add("e.EmpType = 'Support'");
        }

        if (catConditions.Count == 0)
        { Response.Write("{\"error\":\"No valid target categories\"}"); return; }

        string catWhere = "(" + string.Join(" OR ", catConditions) + ")";

        // Get eligible employees
        string sql = string.Format(
            @"SELECT e.empID, e.EmpType, IFNULL(e.reviewer_id, e.supervisorID) AS rev_id
              FROM hrm_employee e
              WHERE IFNULL(e.to_be_appraised, 1) = 1
                AND IFNULL(e.employment_status, 'ACTIVE') IN ('ACTIVE','PROBATION')
                AND {0}
              ORDER BY e.emp_name", catWhere);

        DataTable dtEmps = ExecuteQuery(sql, parms.ToArray());

        int count = 0;
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            foreach (DataRow emp in dtEmps.Rows)
            {
                string empType = emp["EmpType"].ToString();
                string staffCat = "ADMINISTRATIVE";
                if (empType == "Academic") staffCat = "ACADEMIC";
                else if (empType == "Support") staffCat = "SUPPORT";

                object revIdVal = emp["rev_id"];
                string revParam = (revIdVal != null && revIdVal != DBNull.Value && SafeInt(revIdVal) > 0)
                    ? revIdVal.ToString() : "NULL";

                using (MySqlCommand cmd = new MySqlCommand(
                    string.Format(@"INSERT INTO appraisal_records (session_id, employee_id, reviewer_id, staff_category, status)
                      VALUES (@sid, @eid, {0}, @scat, 'PENDING')", revParam), conn))
                {
                    cmd.Parameters.AddWithValue("@sid", sessionId);
                    cmd.Parameters.AddWithValue("@eid", SafeInt(emp["empID"]));
                    cmd.Parameters.AddWithValue("@scat", staffCat);
                    cmd.ExecuteNonQuery();
                    count++;
                }
            }
        }

        Response.Write(string.Format("{{\"success\":true,\"count\":{0}}}", count));
    }

    // ═══════════════════════════════════════════════════════════════════
    //  FORM HANDLERS (POST-REDIRECT-GET)
    // ═══════════════════════════════════════════════════════════════════
    protected void btnCreateSession_Click(object sender, EventArgs e)
    {
        string title   = txtTitle.Text.Trim();
        string desc    = txtDescription.Text.Trim();
        string pStart  = txtPeriodStart.Text.Trim();
        string pEnd    = txtPeriodEnd.Text.Trim();
        string deadline = txtDeadline.Text.Trim();

        // Collect target categories
        List<string> cats = new List<string>();
        if (chkAcademic.Checked) cats.Add("ACADEMIC");
        if (chkAdministrative.Checked) cats.Add("ADMINISTRATIVE");
        if (chkSupport.Checked) cats.Add("SUPPORT");
        string targetCats = string.Join(",", cats);

        if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(pStart) || string.IsNullOrEmpty(pEnd) || string.IsNullOrEmpty(deadline))
        {
            ShowInlineError("Please fill in all required fields.");
            return;
        }

        ExecuteNonQuery(
            @"INSERT INTO appraisal_sessions (session_title, session_description, period_start, period_end, deadline, target_categories, status, created_by)
              VALUES (@title, @desc, @ps, @pe, @dl, @cats, 'DRAFT', @cb)",
            new MySqlParameter("@title", title),
            new MySqlParameter("@desc", desc),
            new MySqlParameter("@ps", pStart),
            new MySqlParameter("@pe", pEnd),
            new MySqlParameter("@dl", deadline),
            new MySqlParameter("@cats", targetCats),
            new MySqlParameter("@cb", DBNull.Value));

        RedirectWithFlash("Appraisal session created successfully.", true);
    }

    protected void btnEditSession_Click(object sender, EventArgs e)
    {
        int id;
        if (!int.TryParse(hfEditSessionId.Value, out id) || id <= 0)
        {
            ShowInlineError("Invalid session ID.");
            return;
        }

        string title   = txtEditTitle.Text.Trim();
        string desc    = txtEditDescription.Text.Trim();
        string pStart  = txtEditPeriodStart.Text.Trim();
        string pEnd    = txtEditPeriodEnd.Text.Trim();
        string deadline = txtEditDeadline.Text.Trim();

        List<string> cats = new List<string>();
        if (chkEditAcademic.Checked) cats.Add("ACADEMIC");
        if (chkEditAdministrative.Checked) cats.Add("ADMINISTRATIVE");
        if (chkEditSupport.Checked) cats.Add("SUPPORT");
        string targetCats = string.Join(",", cats);

        if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(pStart) || string.IsNullOrEmpty(pEnd) || string.IsNullOrEmpty(deadline))
        {
            ShowInlineError("Please fill in all required fields.");
            return;
        }

        ExecuteNonQuery(
            @"UPDATE appraisal_sessions
              SET session_title = @title, session_description = @desc,
                  period_start = @ps, period_end = @pe, deadline = @dl,
                  target_categories = @cats
              WHERE session_id = @id",
            new MySqlParameter("@title", title),
            new MySqlParameter("@desc", desc),
            new MySqlParameter("@ps", pStart),
            new MySqlParameter("@pe", pEnd),
            new MySqlParameter("@dl", deadline),
            new MySqlParameter("@cats", targetCats),
            new MySqlParameter("@id", id));

        RedirectWithFlash("Session updated successfully.", true);
    }

    protected void btnActivateSession_Click(object sender, EventArgs e)
    {
        int id;
        if (!int.TryParse(hfActionSessionId.Value, out id) || id <= 0) return;

        ExecuteNonQuery("UPDATE appraisal_sessions SET status = 'ACTIVE' WHERE session_id = @id AND status = 'DRAFT'",
            new MySqlParameter("@id", id));
        RedirectWithFlash("Session activated. You can now generate appraisals.", true);
    }

    protected void btnCloseSession_Click(object sender, EventArgs e)
    {
        int id;
        if (!int.TryParse(hfActionSessionId.Value, out id) || id <= 0) return;

        ExecuteNonQuery("UPDATE appraisal_sessions SET status = 'CLOSED' WHERE session_id = @id AND status = 'ACTIVE'",
            new MySqlParameter("@id", id));
        RedirectWithFlash("Session closed.", true);
    }

    protected void btnArchiveSession_Click(object sender, EventArgs e)
    {
        int id;
        if (!int.TryParse(hfActionSessionId.Value, out id) || id <= 0) return;

        ExecuteNonQuery("UPDATE appraisal_sessions SET status = 'ARCHIVED' WHERE session_id = @id AND status = 'CLOSED'",
            new MySqlParameter("@id", id));
        RedirectWithFlash("Session archived.", true);
    }

    protected void btnDeleteSession_Click(object sender, EventArgs e)
    {
        int id;
        if (!int.TryParse(hfActionSessionId.Value, out id) || id <= 0) return;

        // Only allow deleting DRAFT sessions with no records
        DataTable dt = ExecuteQuery("SELECT COUNT(*) AS cnt FROM appraisal_records WHERE session_id = @id",
            new MySqlParameter("@id", id));
        if (SafeInt(dt.Rows[0]["cnt"]) > 0)
        {
            RedirectWithFlash("Cannot delete session with existing appraisal records.", false);
            return;
        }

        ExecuteNonQuery("DELETE FROM appraisal_sessions WHERE session_id = @id AND status = 'DRAFT'",
            new MySqlParameter("@id", id));
        RedirectWithFlash("Session deleted.", true);
    }

    // ═══════════════════════════════════════════════════════════════════
    //  GRID BINDING
    // ═══════════════════════════════════════════════════════════════════
    private void BindGrid()
    {
        StringBuilder where = new StringBuilder("WHERE 1=1");
        List<MySqlParameter> parms = new List<MySqlParameter>();

        if (!string.IsNullOrEmpty(QsSearch))
        {
            where.Append(" AND s.session_title LIKE @q");
            parms.Add(new MySqlParameter("@q", "%" + QsSearch + "%"));
        }
        if (!string.IsNullOrEmpty(QsStatus))
        {
            where.Append(" AND s.status = @st");
            parms.Add(new MySqlParameter("@st", QsStatus));
        }

        string countSql = "SELECT COUNT(*) FROM appraisal_sessions s " + where.ToString();
        DataTable dtCount = ExecuteQuery(countSql, parms.ToArray());
        int totalRecords = SafeInt(dtCount.Rows[0][0]);

        int pageSize = 20;
        int totalPages = (int)Math.Ceiling((double)totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;
        int currentPage = QsPage;
        if (currentPage > totalPages) currentPage = totalPages;
        int offset = (currentPage - 1) * pageSize;

        string dataSql = string.Format(
            @"SELECT s.*,
                     IFNULL(cr.emp_name, 'System') AS created_by_name,
                     (SELECT COUNT(*) FROM appraisal_records ar WHERE ar.session_id = s.session_id) AS total_records,
                     (SELECT COUNT(*) FROM appraisal_records ar WHERE ar.session_id = s.session_id AND ar.status = 'COMPLETED') AS completed_records
              FROM appraisal_sessions s
              LEFT JOIN hrm_employee cr ON cr.empID = s.created_by
              {0}
              ORDER BY s.created_at DESC
              LIMIT {1} OFFSET {2}",
            where.ToString(), pageSize, offset);

        DataTable dtData = ExecuteQuery(dataSql, CloneParams(parms));

        // Render rows server-side
        StringBuilder html = new StringBuilder();
        if (dtData.Rows.Count == 0)
        {
            html.Append("<tr><td colspan='8' class='pa-empty-state'>");
            html.Append("<svg xmlns='http://www.w3.org/2000/svg' width='40' height='40' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='1.5'><rect x='3' y='4' width='18' height='18' rx='2' ry='2'/><line x1='16' y1='2' x2='16' y2='6'/><line x1='8' y1='2' x2='8' y2='6'/><line x1='3' y1='10' x2='21' y2='10'/></svg>");
            html.Append("<p>No appraisal sessions found.</p></td></tr>");
        }
        else
        {
            int rowNum = 0;
            foreach (DataRow r in dtData.Rows)
            {
                rowNum++;
                int sessId = SafeInt(r["session_id"]);
                string title = SafeVal(r["session_title"]);
                string createdBy = SafeVal(r["created_by_name"]);
                string status = SafeVal(r["status"]);
                int totalRecs = SafeInt(r["total_records"]);
                int completedRecs = SafeInt(r["completed_records"]);

                html.AppendFormat("<tr onclick='viewSession({0})' title='Click to view details'>", sessId);
                html.AppendFormat("<td class='pa-col-num'>{0}</td>", offset + rowNum);
                html.AppendFormat("<td><strong>{0}</strong><br/><span style='font-size:11px;color:#999;'>by {1}</span></td>",
                    HttpUtility.HtmlEncode(title), HttpUtility.HtmlEncode(createdBy));
                html.AppendFormat("<td style='white-space:nowrap;font-size:12px;'>{0} &mdash; {1}</td>",
                    FormatDateDisplay(r["period_start"]), FormatDateDisplay(r["period_end"]));
                html.AppendFormat("<td style='white-space:nowrap;font-size:12px;'>{0}</td>", FormatDateDisplay(r["deadline"]));
                html.AppendFormat("<td style='font-size:11px;'>{0}</td>", HttpUtility.HtmlEncode(SafeVal(r["target_categories"])));
                html.AppendFormat("<td><span class='pa-badge {0}'>{1}</span></td>",
                    GetStatusBadgeClass(r["status"]), HttpUtility.HtmlEncode(status));
                html.AppendFormat("<td>{0}</td>", GetProgressBar(r["total_records"], r["completed_records"]));
                html.AppendFormat("<td class='pa-col-actions' onclick='event.stopPropagation()'>" +
                    "<button type='button' class='hr-btn hr-btn--ghost hr-btn--sm' onclick='openEditModal({0})' title='Edit'>" +
                    "<svg xmlns='http://www.w3.org/2000/svg' width='13' height='13' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7'/><path d='M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z'/></svg>" +
                    "</button></td>", sessId);
                html.Append("</tr>");
            }
        }
        litGridBody.Text = html.ToString();

        // Store for pager
        ViewState["TotalRecords"] = totalRecords;
        ViewState["CurrentPage"] = currentPage;
        ViewState["TotalPages"] = totalPages;

        // Pager
        litPagerInfo.Text = string.Format("Showing {0}–{1} of {2}",
            totalRecords == 0 ? 0 : offset + 1,
            Math.Min(offset + pageSize, totalRecords),
            totalRecords);

        BuildPager(currentPage, totalPages);
    }

    private void LoadStats()
    {
        DataTable dt = ExecuteQuery(
            @"SELECT
                (SELECT COUNT(*) FROM appraisal_sessions) AS total_sessions,
                (SELECT COUNT(*) FROM appraisal_sessions WHERE status = 'ACTIVE') AS active_sessions,
                (SELECT COUNT(*) FROM appraisal_sessions WHERE status = 'DRAFT') AS draft_sessions,
                (SELECT COUNT(*) FROM appraisal_records) AS total_appraisals,
                (SELECT COUNT(*) FROM appraisal_records WHERE status = 'COMPLETED') AS completed_appraisals");

        if (dt.Rows.Count > 0)
        {
            DataRow r = dt.Rows[0];
            litStatTotal.Text     = SafeInt(r["total_sessions"]).ToString("N0");
            litStatActive.Text    = SafeInt(r["active_sessions"]).ToString("N0");
            litStatDraft.Text     = SafeInt(r["draft_sessions"]).ToString("N0");
            litStatAppraisals.Text = SafeInt(r["total_appraisals"]).ToString("N0");
            litStatCompleted.Text = SafeInt(r["completed_appraisals"]).ToString("N0");
        }
    }

    private void BuildPager(int current, int totalPages)
    {
        if (totalPages <= 1) { litPager.Text = ""; return; }

        StringBuilder sb = new StringBuilder();
        // Previous
        if (current > 1)
            sb.AppendFormat("<a href='{0}' class='pa-pager__btn'>&laquo;</a>", BuildFilterUrl("page=" + (current - 1)));
        else
            sb.Append("<span class='pa-pager__btn pa-pager__btn--disabled'>&laquo;</span>");

        int startPage = Math.Max(1, current - 2);
        int endPage = Math.Min(totalPages, current + 2);

        for (int i = startPage; i <= endPage; i++)
        {
            if (i == current)
                sb.AppendFormat("<span class='pa-pager__btn pa-pager__btn--active'>{0}</span>", i);
            else
                sb.AppendFormat("<a href='{0}' class='pa-pager__btn'>{1}</a>", BuildFilterUrl("page=" + i), i);
        }

        // Next
        if (current < totalPages)
            sb.AppendFormat("<a href='{0}' class='pa-pager__btn'>&raquo;</a>", BuildFilterUrl("page=" + (current + 1)));
        else
            sb.Append("<span class='pa-pager__btn pa-pager__btn--disabled'>&raquo;</span>");

        litPager.Text = sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════════
    private string BuildFilterUrl(string extra)
    {
        StringBuilder sb = new StringBuilder("AppraisalSessions.aspx?");
        if (!string.IsNullOrEmpty(QsSearch)) sb.AppendFormat("q={0}&", HttpUtility.UrlEncode(QsSearch));
        if (!string.IsNullOrEmpty(QsStatus)) sb.AppendFormat("status={0}&", HttpUtility.UrlEncode(QsStatus));
        if (!string.IsNullOrEmpty(extra)) sb.Append(extra);
        return sb.ToString().TrimEnd('&');
    }

    private string SafeVal(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        return val.ToString();
    }

    private int SafeInt(object val)
    {
        if (val == null || val == DBNull.Value) return 0;
        int result;
        return int.TryParse(val.ToString(), out result) ? result : 0;
    }

    private string FormatDate(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("yyyy-MM-dd");
        return val.ToString();
    }

    private string FormatDateDisplay(object val)
    {
        if (val == null || val == DBNull.Value) return "—";
        DateTime dt;
        if (DateTime.TryParse(val.ToString(), out dt))
            return dt.ToString("dd MMM yyyy");
        return val.ToString();
    }

    protected string GetStatusBadgeClass(object statusObj)
    {
        string s = SafeVal(statusObj).ToUpper();
        switch (s)
        {
            case "DRAFT": return "pa-badge--draft";
            case "ACTIVE": return "pa-badge--active";
            case "CLOSED": return "pa-badge--closed";
            case "ARCHIVED": return "pa-badge--archived";
            default: return "pa-badge--draft";
        }
    }

    protected string GetProgressBar(object totalObj, object completedObj)
    {
        int total = Convert.ToInt32(totalObj);
        int completed = Convert.ToInt32(completedObj);
        if (total == 0) return "<span class='pa-progress-empty'>No appraisals</span>";

        double pct = Math.Round((double)completed / total * 100, 1);
        string color = pct >= 75 ? "var(--success)" : pct >= 40 ? "var(--warning)" : pct > 0 ? "var(--brand)" : "var(--border)";
        return string.Format(
            "<div class='pa-progress'>" +
            "<div class='pa-progress__bar' style='width:{0}%;background:{1}'></div>" +
            "</div>" +
            "<span class='pa-progress__text'>{2}/{3} ({0}%)</span>",
            pct, color, completed, total);
    }

    private void ShowInlineError(string message)
    {
        string js = string.Format(
            "alert('{0}');", HttpUtility.JavaScriptStringEncode(message));
        ScriptManager.RegisterStartupScript(this, GetType(), "err_" + DateTime.Now.Ticks, js, true);
    }

    private void RedirectWithFlash(string message, bool success)
    {
        string url = BuildFilterUrl("msg=" + HttpUtility.UrlEncode(message) + "&ok=" + (success ? "1" : "0"));
        url = url.TrimEnd('&');
        Response.Redirect(url, true);
    }

    private void ShowFlashMessage()
    {
        string msg = (Request.QueryString["msg"] ?? "").Trim();
        if (string.IsNullOrEmpty(msg)) return;
        bool ok = (Request.QueryString["ok"] ?? "") == "1";
        string js = string.Format(
            "var b=document.createElement('div');" +
            "b.className='hr-flash-msg';" +
            "b.style.cssText='padding:12px 20px;margin-bottom:14px;border-radius:6px;font-size:13px;font-weight:500;" +
            "background:{0};color:#fff;display:flex;align-items:center;gap:8px;animation:modalSlide .3s ease-out;';" +
            "b.innerHTML='{1}<button onclick=\"this.parentNode.remove()\" style=\"margin-left:auto;background:none;border:none;color:#fff;font-size:18px;cursor:pointer;\">&times;</button>';" +
            "var card=document.querySelector('.cd-card');" +
            "if(card)card.parentNode.insertBefore(b,card);" +
            "setTimeout(function(){{if(b.parentNode)b.remove();}},6000);",
            ok ? "#28a745" : "#d32f2f",
            HttpUtility.JavaScriptStringEncode(msg));
        ScriptManager.RegisterStartupScript(this, GetType(), "flash_" + DateTime.Now.Ticks, js, true);
    }

    private string EscapeJson(object val)
    {
        if (val == null || val == DBNull.Value) return "";
        string s = val.ToString();
        StringBuilder sb = new StringBuilder(s.Length + 10);
        foreach (char c in s)
        {
            switch (c)
            {
                case '"':  sb.Append("\\\""); break;
                case '\\': sb.Append("\\\\"); break;
                case '\n': sb.Append("\\n");  break;
                case '\r': sb.Append("\\r");  break;
                case '\t': sb.Append("\\t");  break;
                default:
                    if (c < 0x20) sb.AppendFormat("\\u{0:X4}", (int)c);
                    else sb.Append(c);
                    break;
            }
        }
        return sb.ToString();
    }

    // ═══════════════════════════════════════════════════════════════════
    //  DATA ACCESS
    // ═══════════════════════════════════════════════════════════════════
    private DataTable ExecuteQuery(string sql, params MySqlParameter[] parms)
    {
        DataTable dt = new DataTable();
        using (MySqlConnection conn = new MySqlConnection(ConnStr))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (parms != null)
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd)) { da.Fill(dt); }
            }
        }
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
                    foreach (MySqlParameter p in parms) cmd.Parameters.Add(p);
                return cmd.ExecuteNonQuery();
            }
        }
    }

    private MySqlParameter[] CloneParams(List<MySqlParameter> parms)
    {
        MySqlParameter[] clone = new MySqlParameter[parms.Count];
        for (int i = 0; i < parms.Count; i++)
            clone[i] = new MySqlParameter(parms[i].ParameterName, parms[i].Value);
        return clone;
    }
}
