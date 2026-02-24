using System;
using System.Data;
using System.Text;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Collections.Generic;

public partial class COOPERP_NewScreens_SystemValidationStats : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle AJAX requests for batch operations
        string action = Request.QueryString["action"];
        if (!string.IsNullOrEmpty(action))
        {
            BatchOperationsHelper.ProcessAjaxRequest(action, Request, Response, ConnectionString);
            return;
        }

        if (!IsPostBack)
        {
            LoadValidationStats();
        }
    }

    private void LoadValidationStats()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            try
            {
                conn.Open();
                JavaScriptSerializer serializer = new JavaScriptSerializer();

                // ========== ACADEMIC SETUP COUNTS ==========
                
                // Total Programmes
                int totalProgrammes = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programme", conn))
                {
                    totalProgrammes = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalProgrammes.Text = String.Format("{0:N0}", totalProgrammes);
                }
                
                // Configured Programmes
                int configuredProgs = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programme WHERE is_fully_set = 'Yes'", conn))
                {
                    configuredProgs = Convert.ToInt32(cmd.ExecuteScalar());
                    lblConfiguredProgs.Text = String.Format("{0:N0}", configuredProgs);
                }
                
                // Total Students
                int totalStudents = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student", conn))
                {
                    totalStudents = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalStudents.Text = String.Format("{0:N0}", totalStudents);
                }
                
                // Total Courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_course", conn))
                {
                    lblTotalCourses.Text = String.Format("{0:N0}", Convert.ToInt32(cmd.ExecuteScalar()));
                }
                
                // Total Specialisations
                int totalSpecs = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation", conn))
                {
                    totalSpecs = Convert.ToInt32(cmd.ExecuteScalar());
                    lblTotalSpecs.Text = String.Format("{0:N0}", totalSpecs);
                }
                
                // Active Specialisations
                int activeSpecs = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation WHERE is_active = 'Active'", conn))
                {
                    activeSpecs = Convert.ToInt32(cmd.ExecuteScalar());
                    lblActiveSpecs.Text = String.Format("{0:N0}", activeSpecs);
                }
                
                // Inactive Specialisations
                int inactiveSpecs = totalSpecs - activeSpecs;
                lblInactiveSpecs.Text = String.Format("{0:N0}", inactiveSpecs);
                lblHealthInactiveCount.Text = String.Format("{0:N0}", inactiveSpecs);
                
                // Active + Fully Set  ← the only metric that counts toward readiness
                int activeFullySet = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation WHERE is_active = 'Active' AND is_fully_set = 'Yes'", conn))
                {
                    activeFullySet = Convert.ToInt32(cmd.ExecuteScalar());
                    lblActiveFullySet.Text = String.Format("{0:N0}", activeFullySet);
                    lblConfiguredSpecs.Text = String.Format("{0:N0}", activeFullySet);
                }
                
                // Active + Not Fully Set
                int activeNotFullySet = activeSpecs - activeFullySet;
                lblActiveNotFullySet.Text = String.Format("{0:N0}", activeNotFullySet);
                
                // Active Readiness Rate
                int activeReadinessRate = activeSpecs > 0 ? (activeFullySet * 100 / activeSpecs) : 0;
                lblActiveReadinessRate.Text = activeReadinessRate + "%";
                lblQsActiveReadiness.Text = activeReadinessRate + "%";
                
                // Keep configuredSpecs alias for any remaining calculations below
                int configuredSpecs = activeFullySet;

                // ========== VALIDATION METRICS ==========
                
                // Students Passed (has_passed = 'Yes')
                int passedStudents = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student WHERE has_passed = 'Yes'", conn))
                {
                    passedStudents = Convert.ToInt32(cmd.ExecuteScalar());
                    lblPassedStudents.Text = String.Format("{0:N0}", passedStudents);
                }
                
                // Students Failed (has_passed = 'No')
                int failedStudents = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student WHERE has_passed = 'No'", conn))
                {
                    failedStudents = Convert.ToInt32(cmd.ExecuteScalar());
                    lblFailedStudents.Text = String.Format("{0:N0}", failedStudents);
                }
                
                // Validated students (either passed or failed)
                int validatedStudents = passedStudents + failedStudents;
                lblValidatedStudents.Text = String.Format("{0:N0}", validatedStudents);
                
                // Pending Validation (has_passed is NULL or empty)
                int pendingValidation = totalStudents - validatedStudents;
                lblPendingValidation.Text = String.Format("{0:N0}", pendingValidation);
                
                // Students with curriculum not set
                int curriculumNotSet = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_student WHERE is_curriculum_fully_set IS NULL OR is_curriculum_fully_set = '' OR is_curriculum_fully_set = 'No'", conn))
                {
                    curriculumNotSet = Convert.ToInt32(cmd.ExecuteScalar());
                    lblCurriculumNotSet.Text = String.Format("{0:N0}", curriculumNotSet);
                }

                // ========== CHART DATA ==========
                
                // Validation Chart Data (Only Passed vs Failed - excluding pending)
                var validationChartData = new
                {
                    passed = passedStudents,
                    failed = failedStudents
                };
                hfValidationChartData.Value = serializer.Serialize(validationChartData);
                
                // Specialisation Status Chart Data (Active+Ready / Active+Pending / Inactive)
                var curriculumChartData = new
                {
                    activeReady   = activeFullySet,
                    activePending = activeNotFullySet,
                    inactive      = inactiveSpecs
                };
                hfCurriculumChartData.Value = serializer.Serialize(curriculumChartData);

                // ========== PROGRESS PERCENTAGES ==========
                
                // Programmes Configured Percentage
                int progPercent = totalProgrammes > 0 ? (configuredProgs * 100 / totalProgrammes) : 0;
                lblProgConfigPercent.Text = progPercent + "%";
                progBar.Style["width"] = progPercent + "%";
                
                // Specialisations Configured Percentage (active specs only)
                int specPercent = activeSpecs > 0 ? (activeFullySet * 100 / activeSpecs) : 0;
                lblSpecConfigPercent.Text = specPercent + "%";
                specBar.Style["width"] = specPercent + "%";
                
                // Inactive Specialisations Percentage (of total)
                int inactiveSpecPercent = totalSpecs > 0 ? (inactiveSpecs * 100 / totalSpecs) : 0;
                lblInactiveSpecPercent.Text = inactiveSpecPercent + "%";
                inactiveSpecBar.Style["width"] = inactiveSpecPercent + "%";
                
                // Students Validated Percentage
                int studentValidPercent = totalStudents > 0 ? (validatedStudents * 100 / totalStudents) : 0;
                lblStudentValidPercent.Text = studentValidPercent + "%";
                studentBar.Style["width"] = studentValidPercent + "%";
                
                // Pass Percentage (of validated)
                int passPercent = validatedStudents > 0 ? (passedStudents * 100 / validatedStudents) : 0;
                lblPassPercent.Text = passPercent + "%";
                passBar.Style["width"] = passPercent + "%";

                // ========== QUICK STATS ==========
                
                // Pass Rate (of validated)
                lblPassRate.Text = passPercent + "%";
                
                // Fail Rate (of validated)
                int failPercent = validatedStudents > 0 ? (failedStudents * 100 / validatedStudents) : 0;
                lblFailRate.Text = failPercent + "%";
                
                // Validation Rate
                lblValidationRate.Text = studentValidPercent + "%";

                // ========== COURSE STATISTICS ==========
                
                // Programme Courses
                int programmeCourses = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses", conn))
                {
                    programmeCourses = Convert.ToInt32(cmd.ExecuteScalar());
                    lblProgrammeCourses.Text = String.Format("{0:N0}", programmeCourses);
                }
                
                // Core Courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE course_type = 'CORE' OR course_type IS NULL", conn))
                {
                    lblCoreCourses.Text = String.Format("{0:N0}", Convert.ToInt32(cmd.ExecuteScalar()));
                }
                
                // Elective Courses
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_programmecourses WHERE course_type = 'ELECTIVE'", conn))
                {
                    lblElectiveCourses.Text = String.Format("{0:N0}", Convert.ToInt32(cmd.ExecuteScalar()));
                }
                
                // Exam Results
                int examResults = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_results", conn))
                {
                    examResults = Convert.ToInt32(cmd.ExecuteScalar());
                    lblExamResults.Text = String.Format("{0:N0}", examResults);
                }
                
                // Average Results per Student
                if (totalStudents > 0)
                {
                    double avgResults = (double)examResults / totalStudents;
                    lblAvgResultsPerStudent.Text = avgResults.ToString("0.0");
                }

                // ========== FAIL REASONS BREAKDOWN ==========
                
                DataTable dtFailReasons = new DataTable();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT 
                        CASE 
                            WHEN fail_reason IS NULL OR fail_reason = '' THEN 'Unknown'
                            WHEN fail_reason LIKE '%pending%' THEN 'Pending Courses'
                            WHEN fail_reason LIKE '%curriculum%' THEN 'Curriculum Issues'
                            WHEN fail_reason LIKE '%specialisation%' THEN 'Specialisation Issues'
                            ELSE SUBSTRING(fail_reason, 1, 30)
                        END as reason,
                        COUNT(*) as count
                    FROM acad_student 
                    WHERE has_passed = 'No' 
                    GROUP BY 
                        CASE 
                            WHEN fail_reason IS NULL OR fail_reason = '' THEN 'Unknown'
                            WHEN fail_reason LIKE '%pending%' THEN 'Pending Courses'
                            WHEN fail_reason LIKE '%curriculum%' THEN 'Curriculum Issues'
                            WHEN fail_reason LIKE '%specialisation%' THEN 'Specialisation Issues'
                            ELSE SUBSTRING(fail_reason, 1, 30)
                        END
                    ORDER BY count DESC 
                    LIMIT 6", conn))
                {
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtFailReasons);
                    }
                }
                rptFailReasons.DataSource = dtFailReasons;
                rptFailReasons.DataBind();

                // ========== TOP PROGRAMMES BY PASS RATE ==========
                
                DataTable dtTopProgrammes = new DataTable();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT 
                        p.prog as programme,
                        ROUND(
                            SUM(CASE WHEN s.has_passed = 'Yes' THEN 1 ELSE 0 END) * 100.0 / 
                            NULLIF(COUNT(CASE WHEN s.has_passed IN ('Yes', 'No') THEN 1 END), 0)
                        , 0) as passrate
                    FROM acad_programme p
                    INNER JOIN acad_student s ON s.progcode = p.progcode
                    WHERE s.has_passed IN ('Yes', 'No')
                    GROUP BY p.progcode, p.prog
                    HAVING COUNT(CASE WHEN s.has_passed IN ('Yes', 'No') THEN 1 END) > 0
                    ORDER BY passrate DESC
                    LIMIT 6", conn))
                {
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtTopProgrammes);
                    }
                }
                rptTopProgrammes.DataSource = dtTopProgrammes;
                rptTopProgrammes.DataBind();

                // ========== UNCONFIGURED PROGRAMMES ==========
                
                DataTable dtUnconfiguredProgs = new DataTable();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT progcode as code, prog as name 
                    FROM acad_programme 
                    WHERE is_fully_set IS NULL OR is_fully_set = '' OR is_fully_set = 'No'
                    ORDER BY prog
                    LIMIT 8", conn))
                {
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtUnconfiguredProgs);
                    }
                }
                
                rptUnconfiguredProgs.DataSource = dtUnconfiguredProgs;
                rptUnconfiguredProgs.DataBind();
                pnlNoUnconfiguredProgs.Visible = dtUnconfiguredProgs.Rows.Count == 0;

                // ========== UNCONFIGURED SPECIALISATIONS ==========
                
                DataTable dtUnconfiguredSpecs = new DataTable();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT s.spec as name, p.prog as programme,
                        COALESCE(c.course_count, 0) as courses
                    FROM acad_specialisation s 
                    LEFT JOIN acad_programme p ON s.prog_id = p.progcode
                    LEFT JOIN (SELECT specialisation_id, COUNT(*) as course_count 
                               FROM acad_programmecourses GROUP BY specialisation_id) c 
                        ON s.spec_id = c.specialisation_id
                    WHERE s.is_active = 'Active'
                      AND (s.is_fully_set IS NULL OR s.is_fully_set = '' OR s.is_fully_set = 'No')
                    ORDER BY p.prog, s.spec
                    LIMIT 8", conn))
                {
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtUnconfiguredSpecs);
                    }
                }
                
                rptUnconfiguredSpecs.DataSource = dtUnconfiguredSpecs;
                rptUnconfiguredSpecs.DataBind();
                pnlNoUnconfiguredSpecs.Visible = dtUnconfiguredSpecs.Rows.Count == 0;

                // ========== RECENT FAILURES ==========
                
                DataTable dtRecentFailures = new DataTable();
                using (MySqlCommand cmd = new MySqlCommand(
                    @"SELECT 
                        CONCAT(firstname, ' ', surname) as student,
                        CASE 
                            WHEN fail_reason IS NULL OR fail_reason = '' THEN 'Unknown'
                            ELSE SUBSTRING(fail_reason, 1, 25)
                        END as reason
                    FROM acad_student 
                    WHERE has_passed = 'No'
                    ORDER BY studentid DESC
                    LIMIT 10", conn))
                {
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtRecentFailures);
                    }
                }
                
                rptRecentFailures.DataSource = dtRecentFailures;
                rptRecentFailures.DataBind();
                pnlNoFailures.Visible = dtRecentFailures.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Validation Stats Error: " + ex.Message);
            }
        }
    }

    protected void btnValidateSpecializations_Click(object sender, EventArgs e)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Get all specializations with their course counts
                string selectSql = @"
                    SELECT 
                        s.spec_id,
                        s.spec as specName,
                        COALESCE(y1.count, 0) as y1Courses,
                        COALESCE(y2.count, 0) as y2Courses,
                        COALESCE(y3.count, 0) as y3Courses
                    FROM acad_specialisation s
                    LEFT JOIN (
                        SELECT specialisation_id, COUNT(*) as count 
                        FROM acad_programmecourses 
                        WHERE study_year = 1 
                        GROUP BY specialisation_id
                    ) y1 ON s.spec_id = y1.specialisation_id
                    LEFT JOIN (
                        SELECT specialisation_id, COUNT(*) as count 
                        FROM acad_programmecourses 
                        WHERE study_year = 2 
                        GROUP BY specialisation_id
                    ) y2 ON s.spec_id = y2.specialisation_id
                    LEFT JOIN (
                        SELECT specialisation_id, COUNT(*) as count 
                        FROM acad_programmecourses 
                        WHERE study_year = 3 
                        GROUP BY specialisation_id
                    ) y3 ON s.spec_id = y3.specialisation_id";
                
                List<string> toSetYes = new List<string>();
                List<string> toSetNo = new List<string>();
                
                using (MySqlCommand cmd = new MySqlCommand(selectSql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string specId = reader["spec_id"].ToString();
                            int y1 = Convert.ToInt32(reader["y1Courses"]);
                            int y2 = Convert.ToInt32(reader["y2Courses"]);
                            int y3 = Convert.ToInt32(reader["y3Courses"]);
                            
                            // Validation Rules:
                            // - Year 1 & Year 2 must have at least 5 courses each
                            // - Year 1, Year 2 & Year 3 must not exceed 12 courses each
                            bool isValid = (y1 >= 5 && y2 >= 5) && 
                                          (y1 <= 12 && y2 <= 12 && y3 <= 12);
                            
                            if (isValid)
                                toSetYes.Add(specId);
                            else
                                toSetNo.Add(specId);
                        }
                    }
                }
                
                // Update specializations
                int updatedToYes = 0;
                int updatedToNo = 0;
                
                if (toSetYes.Count > 0)
                {
                    string updateYesSql = "UPDATE acad_specialisation SET is_fully_set = 'Yes' WHERE spec_id IN (" +
                        string.Join(",", toSetYes.ConvertAll(id => "'" + id.Replace("'", "''") + "'")) + ")";
                    using (MySqlCommand cmd = new MySqlCommand(updateYesSql, conn))
                    {
                        updatedToYes = cmd.ExecuteNonQuery();
                    }
                }
                
                if (toSetNo.Count > 0)
                {
                    string updateNoSql = "UPDATE acad_specialisation SET is_fully_set = 'No' WHERE spec_id IN (" +
                        string.Join(",", toSetNo.ConvertAll(id => "'" + id.Replace("'", "''") + "'")) + ")";
                    using (MySqlCommand cmd = new MySqlCommand(updateNoSql, conn))
                    {
                        updatedToNo = cmd.ExecuteNonQuery();
                    }
                }
                
                // Show success message
                string message = string.Format("Specialization validation completed successfully!\\n\\n" +
                    "{0} specializations marked as Fully Set\\n" +
                    "{1} specializations marked as Not Fully Set", 
                    updatedToYes, updatedToNo);
                
                ClientScript.RegisterStartupScript(this.GetType(), "ValidationSuccess", 
                    "alert('" + message + "'); window.location.href=window.location.href;", true);
            }
        }
        catch (Exception ex)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "ValidationError", 
                "alert('Error validating specializations: " + ex.Message.Replace("'", "\\'") + "');", true);
        }
    }
}
