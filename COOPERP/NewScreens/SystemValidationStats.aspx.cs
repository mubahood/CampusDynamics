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
                
                // Configured Specialisations
                int configuredSpecs = 0;
                using (MySqlCommand cmd = new MySqlCommand("SELECT COUNT(*) FROM acad_specialisation WHERE is_fully_set = 'Yes'", conn))
                {
                    configuredSpecs = Convert.ToInt32(cmd.ExecuteScalar());
                    lblConfiguredSpecs.Text = String.Format("{0:N0}", configuredSpecs);
                }

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
                
                // Curriculum Chart Data (Based on Specialisations - Fully Set vs Not Fully Set)
                int unconfiguredSpecs = totalSpecs - configuredSpecs;
                
                var curriculumChartData = new
                {
                    configured = configuredSpecs,
                    unconfigured = unconfiguredSpecs
                };
                hfCurriculumChartData.Value = serializer.Serialize(curriculumChartData);

                // ========== PROGRESS PERCENTAGES ==========
                
                // Programmes Configured Percentage
                int progPercent = totalProgrammes > 0 ? (configuredProgs * 100 / totalProgrammes) : 0;
                lblProgConfigPercent.Text = progPercent + "%";
                progBar.Style["width"] = progPercent + "%";
                
                // Specialisations Configured Percentage
                int specPercent = totalSpecs > 0 ? (configuredSpecs * 100 / totalSpecs) : 0;
                lblSpecConfigPercent.Text = specPercent + "%";
                specBar.Style["width"] = specPercent + "%";
                
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
                    WHERE s.is_fully_set IS NULL OR s.is_fully_set = '' OR s.is_fully_set = 'No'
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
}
