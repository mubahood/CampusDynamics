using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Data;
using DevExpress.Web;
using DevExpress.Export;
using DevExpress.XtraPrinting;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Text;

public partial class COOPERP_NewScreens_EnrollmentAnalysis : System.Web.UI.Page
{
    private string connStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadEntryYears();
            LoadFaculties();
            LoadProgrammes();
            LoadStats();
            LoadEnrollmentByYear();
            LoadEnrollmentByProgramme();
            PrepareChartData();
        }
    }

    #region Data Loading

    private void LoadEntryYears()
    {
        ddlEntryYear.Items.Clear();
        ddlEntryYear.Items.Add(new ListItem("-- All Years --", ""));
        
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 15; i--)
        {
            ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }
    }

    private void LoadFaculties()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = "SELECT DISTINCT faculty_code, faculty_name FROM acad_faculty ORDER BY faculty_name";
            MySqlCommand cmd = new MySqlCommand(sql, conn);

            try
            {
                MySqlDataReader dr = cmd.ExecuteReader();
                ddlFaculty.Items.Clear();
                ddlFaculty.Items.Add(new ListItem("-- All Faculties --", ""));
                while (dr.Read())
                {
                    ddlFaculty.Items.Add(new ListItem(dr["faculty_name"].ToString(), dr["faculty_code"].ToString()));
                }
            }
            catch
            {
                // Table may not exist
            }
        }
    }

    private void LoadProgrammes()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            string sql = "SELECT progcode, progname FROM acad_programme ORDER BY progname";
            
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                sql = "SELECT progcode, progname FROM acad_programme WHERE faculty_code = @faculty ORDER BY progname";
            }
            
            MySqlCommand cmd = new MySqlCommand(sql, conn);
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                cmd.Parameters.AddWithValue("@faculty", ddlFaculty.SelectedValue);
            }

            MySqlDataReader dr = cmd.ExecuteReader();
            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
            while (dr.Read())
            {
                ddlProgramme.Items.Add(new ListItem(
                    dr["progcode"].ToString() + " - " + dr["progname"].ToString(),
                    dr["progcode"].ToString()
                ));
            }
        }
    }

    private void LoadStats()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            string whereClause = BuildWhereClause();

            // Total students
            string sqlTotal = "SELECT COUNT(*) FROM acad_student s WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI')" + whereClause;
            MySqlCommand cmdTotal = new MySqlCommand(sqlTotal, conn);
            AddFilterParameters(cmdTotal);
            int total = Convert.ToInt32(cmdTotal.ExecuteScalar());
            litTotalStudents.Text = total.ToString("N0");

            // Male count
            string sqlMale = "SELECT COUNT(*) FROM acad_student s WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI') AND s.gender = 'Male'" + whereClause;
            MySqlCommand cmdMale = new MySqlCommand(sqlMale, conn);
            AddFilterParameters(cmdMale);
            int male = Convert.ToInt32(cmdMale.ExecuteScalar());
            litMale.Text = male.ToString("N0");
            hfMaleCount.Value = male.ToString();

            // Female count
            string sqlFemale = "SELECT COUNT(*) FROM acad_student s WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI') AND s.gender = 'Female'" + whereClause;
            MySqlCommand cmdFemale = new MySqlCommand(sqlFemale, conn);
            AddFilterParameters(cmdFemale);
            int female = Convert.ToInt32(cmdFemale.ExecuteScalar());
            litFemale.Text = female.ToString("N0");
            hfFemaleCount.Value = female.ToString();

            // New students this year — honours faculty/programme but NOT the year
            // filter (it is intrinsically "the current calendar year's intake").
            int currentYear = DateTime.Now.Year;
            string whereNoYear = BuildWhereClause(false);
            string sqlNew = "SELECT COUNT(*) FROM acad_student s WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI') AND s.entryyear = @currentYear" + whereNoYear;
            MySqlCommand cmdNew = new MySqlCommand(sqlNew, conn);
            cmdNew.Parameters.AddWithValue("@currentYear", currentYear);
            AddFilterParameters(cmdNew, false);
            int newStudents = Convert.ToInt32(cmdNew.ExecuteScalar());
            litNewStudents.Text = newStudents.ToString("N0");

            // Active programmes — distinct programmes actually enrolled in the
            // current filtered scope (so it reflects the filters).
            string sqlProgs = "SELECT COUNT(DISTINCT s.progid) FROM acad_student s WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI')" + whereClause;
            MySqlCommand cmdProgs = new MySqlCommand(sqlProgs, conn);
            AddFilterParameters(cmdProgs);
            int progs = Convert.ToInt32(cmdProgs.ExecuteScalar());
            litProgrammes.Text = progs.ToString("N0");
        }
    }

    private void LoadEnrollmentByYear()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            string whereClause = BuildWhereClause();

            string sql = @"SELECT s.entryyear,
                           SUM(CASE WHEN s.gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
                           SUM(CASE WHEN s.gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
                           COUNT(*) AS total
                           FROM acad_student s
                           WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI')" + whereClause + @"
                           GROUP BY s.entryyear
                           ORDER BY s.entryyear DESC
                           LIMIT 10";

            MySqlCommand cmd = new MySqlCommand(sql, conn);
            AddFilterParameters(cmd);

            DataTable dt = new DataTable();
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            da.Fill(dt);

            // Calculate total for percentage
            int grandTotal = 0;
            foreach (DataRow row in dt.Rows)
            {
                grandTotal += Convert.ToInt32(row["total"]);
            }

            // Add percentage column
            dt.Columns.Add("percentage", typeof(double));
            foreach (DataRow row in dt.Rows)
            {
                int rowTotal = Convert.ToInt32(row["total"]);
                row["percentage"] = grandTotal > 0 ? (double)rowTotal / grandTotal * 100 : 0;
            }

            rptEnrollmentByYear.DataSource = dt;
            rptEnrollmentByYear.DataBind();
        }
    }

    private void LoadEnrollmentByProgramme()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            string whereClause = BuildWhereClause();

            string sql = @"SELECT s.progid, p.progname,
                           SUM(CASE WHEN s.gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
                           SUM(CASE WHEN s.gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
                           COUNT(*) AS total
                           FROM acad_student s
                           LEFT JOIN acad_programme p ON s.progid = p.progcode
                           WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI')" + whereClause + @"
                           GROUP BY s.progid, p.progname
                           ORDER BY total DESC
                           LIMIT 15";

            MySqlCommand cmd = new MySqlCommand(sql, conn);
            AddFilterParameters(cmd);

            DataTable dt = new DataTable();
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            da.Fill(dt);

            // Calculate total for percentage
            int grandTotal = 0;
            foreach (DataRow row in dt.Rows)
            {
                grandTotal += Convert.ToInt32(row["total"]);
            }

            // Add percentage column
            dt.Columns.Add("percentage", typeof(double));
            foreach (DataRow row in dt.Rows)
            {
                int rowTotal = Convert.ToInt32(row["total"]);
                row["percentage"] = grandTotal > 0 ? (double)rowTotal / grandTotal * 100 : 0;
            }

            gvProgrammeEnrollment.DataSource = dt;
            gvProgrammeEnrollment.DataBind();
        }
    }

    private void PrepareChartData()
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();

            string whereClause = BuildWhereClause();

            string sql = @"SELECT s.entryyear, COUNT(*) AS total
                           FROM acad_student s
                           WHERE (s.stud_status = 'ACTIVE' AND s.new_status <> 'ALUMNI')" + whereClause + @"
                           GROUP BY s.entryyear
                           ORDER BY s.entryyear ASC
                           LIMIT 10";

            MySqlCommand cmd = new MySqlCommand(sql, conn);
            AddFilterParameters(cmd);

            DataTable dt = new DataTable();
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            da.Fill(dt);

            StringBuilder sbLabels = new StringBuilder();
            StringBuilder sbData = new StringBuilder();

            foreach (DataRow row in dt.Rows)
            {
                if (sbLabels.Length > 0) sbLabels.Append(",");
                if (sbData.Length > 0) sbData.Append(",");
                
                sbLabels.Append(row["entryyear"].ToString());
                sbData.Append(row["total"].ToString());
            }

            hfYearLabels.Value = sbLabels.ToString();
            hfYearData.Value = sbData.ToString();
        }
    }

    #endregion

    #region Helper Methods

    private string BuildWhereClause()
    {
        return BuildWhereClause(true);
    }

    // includeYear=false lets the "New this year" card ignore the year filter
    // while still honouring faculty + programme.
    private string BuildWhereClause(bool includeYear)
    {
        StringBuilder sb = new StringBuilder();

        if (includeYear && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
        {
            sb.Append(" AND s.entryyear = @entryyear");
        }

        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            sb.Append(" AND s.progid = @progid");
        }

        // Faculty is stored on acad_programme, not acad_student — filter by the
        // programmes belonging to the faculty. Applies to EVERY stat/table/chart.
        if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
        {
            sb.Append(" AND s.progid IN (SELECT progcode FROM acad_programme WHERE faculty_code = @faculty)");
        }

        return sb.ToString();
    }

    private void AddFilterParameters(MySqlCommand cmd)
    {
        AddFilterParameters(cmd, true);
    }

    private void AddFilterParameters(MySqlCommand cmd, bool includeYear)
    {
        if (includeYear && !string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@entryyear", int.Parse(ddlEntryYear.SelectedValue));
        }

        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@progid", ddlProgramme.SelectedValue);
        }

        if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@faculty", ddlFaculty.SelectedValue);
        }
    }

    #endregion

    #region Filter Events

    protected void ddlEntryYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        RefreshData();
    }

    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes();
        RefreshData();
    }

    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        RefreshData();
    }

    private void RefreshData()
    {
        LoadStats();
        LoadEnrollmentByYear();
        LoadEnrollmentByProgramme();
        PrepareChartData();
    }

    #endregion

    #region Actions

    protected void btnExport_Click(object sender, EventArgs e)
    {
        gveProgrammeEnrollment.WriteXlsxToResponse("EnrollmentByProgramme", new XlsxExportOptionsEx() { ExportType = ExportType.WYSIWYG });
    }

    #endregion
}
