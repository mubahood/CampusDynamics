using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_GraduationCentre : System.Web.UI.Page
{
    private string connectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilters();
            SetDefaultFilters();
            LoadGraduandsData();
        }
    }

    protected void LoadFilters()
    {
        // Load Faculties
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            // Faculties
            string sqlFaculty = "SELECT DISTINCT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name";
            using (MySqlCommand cmd = new MySqlCommand(sqlFaculty, conn))
            {
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlFaculty.Items.Clear();
                    ddlFaculty.Items.Add(new ListItem("-- All Faculties --", ""));
                    while (dr.Read())
                    {
                        ddlFaculty.Items.Add(new ListItem(dr["faculty_name"].ToString(), dr["faculty_code"].ToString()));
                    }
                }
            }

            // Entry Years (last 10 years)
            ddlEntryYear.Items.Clear();
            ddlEntryYear.Items.Add(new ListItem("-- All --", ""));
            int currentYear = DateTime.Now.Year;
            for (int i = currentYear; i >= currentYear - 10; i--)
            {
                ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
            }

            // Academic Years (generated programmatically)
            ddlAcadYear.Items.Clear();
            ddlAcadYear.Items.Add(new ListItem("-- All --", ""));
            for (int i = currentYear + 1; i >= currentYear - 10; i--)
            {
                string acadYear = string.Format("{0}/{1}", i, i + 1);
                ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
            }
        }
    }

    protected void SetDefaultFilters()
    {
        // Set default academic year to current
        string currentAcadYear = GetCurrentAcadYear();
        if (!string.IsNullOrEmpty(currentAcadYear) && ddlAcadYear.Items.FindByValue(currentAcadYear) != null)
        {
            ddlAcadYear.SelectedValue = currentAcadYear;
        }

        // Update display
        litAcadYearDisplay.Text = string.IsNullOrEmpty(ddlAcadYear.SelectedValue) ? "All" : ddlAcadYear.SelectedValue;
        litStudyYearDisplay.Text = string.IsNullOrEmpty(ddlStudyYear.SelectedValue) ? "All" : ddlStudyYear.SelectedValue;
    }

    private string GetCurrentAcadYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;
        
        // If we're in the second half of the year (August onwards), the academic year is current/next
        if (month >= 8)
            return string.Format("{0}/{1}", year, year + 1);
        else
            return string.Format("{0}/{1}", year - 1, year);
    }

    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes();
        LoadGraduandsData();
    }

    protected void LoadProgrammes()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();
            string sql = "SELECT progcode, progname FROM acad_programme WHERE 1=1";
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                sql += " AND faculty_code = @fac";
            }
            sql += " ORDER BY progname";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                {
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                }

                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlProgramme.Items.Clear();
                    ddlProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
                    while (dr.Read())
                    {
                        ddlProgramme.Items.Add(new ListItem(dr["progname"].ToString(), dr["progcode"].ToString()));
                    }
                }
            }
        }
    }

    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadGraduandsData();
    }

    protected void ddlEntryYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadGraduandsData();
    }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        litAcadYearDisplay.Text = string.IsNullOrEmpty(ddlAcadYear.SelectedValue) ? "All" : ddlAcadYear.SelectedValue;
        LoadGraduandsData();
    }

    protected void ddlStudyYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        litStudyYearDisplay.Text = string.IsNullOrEmpty(ddlStudyYear.SelectedValue) ? "All" : ddlStudyYear.SelectedValue;
        LoadGraduandsData();
    }

    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadGraduandsData();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadGraduandsData();
    }

    protected void LoadGraduandsData()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            // Build query to get students eligible for graduation with their current status
            // CGPA is retrieved from acad_graduands if already a graduand, otherwise shows as 0 (to be calculated when adding)
            // Study year comes from acad_registration table (MAX to get latest)
            string sql = @"
                SELECT 
                    s.regno,
                    CONCAT(s.firstname, ' ', IFNULL(s.othername, '')) AS stud_name,
                    p.progname AS prog_name,
                    s.entryyear AS entry_year,
                    IFNULL(r.study_year, 1) AS study_year,
                    IFNULL(g.cgpa, 0) AS cgpa,
                    CASE 
                        WHEN g.degclass IS NOT NULL THEN g.degclass
                        WHEN IFNULL(g.cgpa, 0) >= 3.6 THEN 'First Class'
                        WHEN IFNULL(g.cgpa, 0) >= 3.0 THEN 'Second Class Upper'
                        WHEN IFNULL(g.cgpa, 0) >= 2.5 THEN 'Second Class Lower'
                        WHEN IFNULL(g.cgpa, 0) >= 2.0 THEN 'Pass'
                        ELSE '-'
                    END AS award_class,
                    CASE 
                        WHEN IFNULL(r.study_year, 1) >= COALESCE(p.couselength, 3) THEN 'Completed'
                        ELSE 'In Progress'
                    END AS completion_status,
                    IFNULL(s.gender, '') AS gender,
                    IFNULL(s.nationality, '') AS nationality,
                    CASE WHEN g.regno IS NOT NULL THEN 'Yes' ELSE 'No' END AS is_graduand
                FROM acad_student s
                LEFT JOIN acad_programme p ON s.progid = p.progcode
                LEFT JOIN (SELECT regno, MAX(studyyear) AS study_year FROM acad_registration GROUP BY regno) r ON s.regno = r.regno
                LEFT JOIN acad_graduands g ON s.regno = g.regno
                WHERE (s.stud_status = 'Active' OR s.new_status = 'Active')";

            // Apply filters
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                sql += " AND p.faculty_code = @fac";
            }
            if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            {
                sql += " AND s.progid = @prog";
            }
            if (!string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
            {
                sql += " AND s.entryyear = @entry";
            }
            if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
            {
                sql += " AND r.study_year = @study";
            }
            if (ddlStatus.SelectedValue == "GRAD")
            {
                sql += " AND g.regno IS NOT NULL";
            }

            sql += " ORDER BY s.regno";

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                if (!string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
                    cmd.Parameters.AddWithValue("@entry", int.Parse(ddlEntryYear.SelectedValue));
                if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
                    cmd.Parameters.AddWithValue("@study", int.Parse(ddlStudyYear.SelectedValue));

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvGraduands.DataSource = dt;
                    gvGraduands.DataBind();

                    // Update stats
                    litTotalCount.Text = dt.Rows.Count.ToString();

                    int completedCount = 0;
                    int graduandsCount = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        if (row["completion_status"].ToString() == "Completed")
                            completedCount++;
                        if (row["is_graduand"].ToString() == "Yes")
                            graduandsCount++;
                    }
                    litCompletedCount.Text = completedCount.ToString();
                    litGraduandsCount.Text = graduandsCount.ToString();
                }
            }
        }
    }

    protected void btnAddGraduands_Click(object sender, EventArgs e)
    {
        var selectedKeys = gvGraduands.GetSelectedFieldValues("regno");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select at least one student.", "warning");
            return;
        }

        int addedCount = 0;
        string acadYear = !string.IsNullOrEmpty(ddlAcadYear.SelectedValue) ? ddlAcadYear.SelectedValue : GetCurrentAcadYear();
        string username = Session["username"] != null ? Session["username"].ToString() : "system";

        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            foreach (var key in selectedKeys)
            {
                string regno = key.ToString();

                // Check if already a graduand
                string checkSql = "SELECT COUNT(*) FROM acad_graduands WHERE regno = @regno";
                using (MySqlCommand checkCmd = new MySqlCommand(checkSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@regno", regno);
                    if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                        continue;
                }

                // Get student details (basic info without CGPA - CGPA will be calculated via stored procedure)
                // Study year from acad_registration table
                string detailSql = @"SELECT s.regno, CONCAT(s.firstname, ' ', IFNULL(s.othername, '')) AS stud_name, 
                                    s.progid, IFNULL(s.gender, '') AS gender, 
                                    IFNULL((SELECT MAX(studyyear) FROM acad_registration WHERE regno = s.regno), 1) AS study_year
                                    FROM acad_student s
                                    WHERE s.regno = @regno";

                DataTable dtStudent = new DataTable();
                using (MySqlCommand detailCmd = new MySqlCommand(detailSql, conn))
                {
                    detailCmd.Parameters.AddWithValue("@regno", regno);
                    using (MySqlDataAdapter da = new MySqlDataAdapter(detailCmd))
                    {
                        da.Fill(dtStudent);
                    }
                }

                if (dtStudent.Rows.Count > 0)
                {
                    DataRow row = dtStudent.Rows[0];
                    int studyYear = row["study_year"] != DBNull.Value ? Convert.ToInt32(row["study_year"]) : 1;
                    
                    // Calculate CGPA using stored procedure (get latest semester's CGPA)
                    decimal cgpa = 0;
                    try
                    {
                        using (MySqlCommand cmdCgpa = new MySqlCommand("acad_SemesterSummary", conn))
                        {
                            cmdCgpa.CommandType = CommandType.StoredProcedure;
                            cmdCgpa.Parameters.AddWithValue("@reg", regno);
                            cmdCgpa.Parameters.AddWithValue("@yr", studyYear);
                            cmdCgpa.Parameters.AddWithValue("@sem", 2); // Try semester 2 first
                            
                            using (MySqlDataReader reader = cmdCgpa.ExecuteReader())
                            {
                                if (reader.Read() && reader["cgpa"] != DBNull.Value)
                                {
                                    cgpa = Convert.ToDecimal(reader["cgpa"]);
                                }
                            }
                        }
                        
                        // If no CGPA from sem 2, try sem 1
                        if (cgpa == 0)
                        {
                            using (MySqlCommand cmdCgpa = new MySqlCommand("acad_SemesterSummary", conn))
                            {
                                cmdCgpa.CommandType = CommandType.StoredProcedure;
                                cmdCgpa.Parameters.AddWithValue("@reg", regno);
                                cmdCgpa.Parameters.AddWithValue("@yr", studyYear);
                                cmdCgpa.Parameters.AddWithValue("@sem", 1);
                                
                                using (MySqlDataReader reader = cmdCgpa.ExecuteReader())
                                {
                                    if (reader.Read() && reader["cgpa"] != DBNull.Value)
                                    {
                                        cgpa = Convert.ToDecimal(reader["cgpa"]);
                                    }
                                }
                            }
                        }
                    }
                    catch { /* CGPA calculation failed, will use 0 */ }
                    
                    string degClass = GetDegreeClass(cgpa);

                    // Insert graduand
                    string insertSql = @"INSERT INTO acad_graduands (regno, convocation, comp_date, grad_date, cgpa, degclass, stud_name, progcode, gen, created_by, created_date)
                                        VALUES (@regno, @acad, NOW(), NULL, @cgpa, @degclass, @stud_name, @progcode, @gen, @usr, NOW())";

                    using (MySqlCommand insertCmd = new MySqlCommand(insertSql, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@regno", regno);
                        insertCmd.Parameters.AddWithValue("@acad", acadYear);
                        insertCmd.Parameters.AddWithValue("@cgpa", cgpa);
                        insertCmd.Parameters.AddWithValue("@degclass", degClass);
                        insertCmd.Parameters.AddWithValue("@stud_name", row["stud_name"]);
                        insertCmd.Parameters.AddWithValue("@progcode", row["progid"]);
                        insertCmd.Parameters.AddWithValue("@gen", row["gender"]);
                        insertCmd.Parameters.AddWithValue("@usr", username);

                        try
                        {
                            insertCmd.ExecuteNonQuery();
                            addedCount++;
                        }
                        catch (Exception ex)
                        {
                            // Log error but continue
                            System.Diagnostics.Debug.WriteLine("Error adding graduand: " + ex.Message);
                        }
                    }
                }
            }
        }

        gvGraduands.Selection.UnselectAll();
        LoadGraduandsData();
        ShowMessage(string.Format("Successfully added {0} student(s) to graduands list.", addedCount), "success");
    }

    protected void btnRemoveGraduands_Click(object sender, EventArgs e)
    {
        var selectedKeys = gvGraduands.GetSelectedFieldValues("regno");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select at least one graduand to remove.", "warning");
            return;
        }

        int removedCount = 0;
        string username = Session["username"] != null ? Session["username"].ToString() : "system";

        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            foreach (var key in selectedKeys)
            {
                string regno = key.ToString();

                string deleteSql = "DELETE FROM acad_graduands WHERE regno = @regno";
                using (MySqlCommand deleteCmd = new MySqlCommand(deleteSql, conn))
                {
                    deleteCmd.Parameters.AddWithValue("@regno", regno);
                    int affected = deleteCmd.ExecuteNonQuery();
                    if (affected > 0)
                        removedCount++;
                }
            }
        }

        gvGraduands.Selection.UnselectAll();
        LoadGraduandsData();
        ShowMessage(string.Format("Successfully removed {0} student(s) from graduands list.", removedCount), "success");
    }

    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        gvExporter.WriteXlsxToResponse("GraduationCentre_" + DateTime.Now.ToString("yyyyMMdd"));
    }

    protected void btnPrintList_Click(object sender, EventArgs e)
    {
        // Print functionality - could open a print-friendly view
        ScriptManager.RegisterStartupScript(this, GetType(), "print", "window.print();", true);
    }

    private string GetDegreeClass(decimal cgpa)
    {
        if (cgpa >= 3.6m) return "First Class";
        if (cgpa >= 3.0m) return "Second Class Upper";
        if (cgpa >= 2.5m) return "Second Class Lower";
        if (cgpa >= 2.0m) return "Pass";
        return "Fail";
    }

    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "gc-message show gc-message--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }

    protected string GetStatusBadge(object status)
    {
        string statusStr = status != null ? status.ToString() : "";
        if (statusStr == "Completed")
            return "<span class='gc-status-badge gc-status-badge--completed'>Completed</span>";
        else
            return "<span class='gc-status-badge gc-status-badge--pending'>In Progress</span>";
    }

    protected string GetGraduandBadge(object isGraduand)
    {
        string str = isGraduand != null ? isGraduand.ToString() : "";
        if (str == "Yes")
            return "<span class='gc-status-badge gc-status-badge--graduated'>Yes</span>";
        else
            return "<span style='color:#6c757d;'>No</span>";
    }
}
