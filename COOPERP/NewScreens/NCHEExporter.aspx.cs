using System;
using System.Configuration;
using System.Data;
using System.Globalization;
using MySql.Data.MySqlClient;
using DevExpress.Web;

/// <summary>
/// NCHE Student Data Exporter
/// Implements NCHE/GR/U/78 (9 February 2026) - national student admission number data submission.
/// Exports 10 required columns: S/N, Names, Sex, National ID No., Institutional Reg. No.,
/// Programme Code, Programme Name, Award Level, Year of Study, Study Centre.
/// </summary>
public partial class COOPERP_NewScreens_NCHEExporter : System.Web.UI.Page
{
    private string ConnStr
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    // -- Page lifecycle --------------------------------------------------------

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            PopulateYearFilter();
            PopulateProgrammeFilter();
            PopulateCampusFilter();
        }
    }

    // -- Filter population -----------------------------------------------------

    private void PopulateYearFilter()
    {
        cmbAcadYear.Items.Add(new ListEditItem("All Years", ""));
        cmbAcadYear.SelectedIndex = 0;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"SELECT DISTINCT TRIM(entryyear) AS yr
                      FROM acad_student
                      WHERE entryyear IS NOT NULL AND TRIM(entryyear) != ''
                      ORDER BY yr DESC
                      LIMIT 20", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string yr = rdr["yr"].ToString().Trim();
                        if (!string.IsNullOrEmpty(yr))
                            cmbAcadYear.Items.Add(new ListEditItem(yr, yr));
                    }
                }
            }
        }
        catch { /* non-fatal - dropdown just stays with "All Years" */ }
    }

    private void PopulateProgrammeFilter()
    {
        cmbProgramme.Items.Add(new ListEditItem("All Programmes", ""));
        cmbProgramme.SelectedIndex = 0;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"SELECT progcode, TRIM(progname) AS progname
                      FROM acad_programme
                      ORDER BY progname", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string code = rdr["progcode"].ToString().Trim();
                        string name = rdr["progname"].ToString().Trim();
                        if (!string.IsNullOrEmpty(code))
                            cmbProgramme.Items.Add(new ListEditItem(name, code));
                    }
                }
            }
        }
        catch { }
    }

    private void PopulateCampusFilter()
    {
        cmbCampus.Items.Add(new ListEditItem("All Study Centres", ""));
        cmbCampus.SelectedIndex = 0;
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(
                    @"SELECT campus_code, TRIM(campus_name) AS campus_name
                      FROM acad_campuses
                      ORDER BY campus_name", conn))
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        string code = rdr["campus_code"].ToString().Trim();
                        string name = rdr["campus_name"].ToString().Trim();
                        if (!string.IsNullOrEmpty(code))
                            cmbCampus.Items.Add(new ListEditItem(name, code));
                    }
                }
            }
        }
        catch { }
    }

    // -- Data loading ----------------------------------------------------------

    /// <summary>
    /// Queries acad_student + acad_programme + acad_campuses and returns a DataTable
    /// with exactly the 10 NCHE-required columns plus an auto-incremented S/N.
    /// Award level is derived from the programme name prefix (most reliable approach
    /// across different DB configurations).
    /// National ID maps to acad_student.idno - ensure this column holds the government NIN.
    /// </summary>
    private DataTable LoadStudentData()
    {
        string status     = (cmbStatus.Value     ?? "ACTIVE").ToString().Trim().ToUpper();
        string acadYear   = (cmbAcadYear.Value   ?? "").ToString().Trim();
        string progCode   = (cmbProgramme.Value  ?? "").ToString().Trim();
        string awardLevel = (cmbAwardLevel.Value ?? "").ToString().Trim();
        string campus     = (cmbCampus.Value     ?? "").ToString().Trim();

        const string sql = @"
            SELECT
                TRIM(CONCAT(
                    IFNULL(s.firstname, ''),
                    CASE WHEN TRIM(IFNULL(s.othername,'')) != ''
                         THEN CONCAT(' ', TRIM(s.othername))
                         ELSE '' END
                )) AS full_name,

                CASE
                    WHEN UPPER(TRIM(IFNULL(s.gender,''))) IN ('M','MALE')   THEN 'Male'
                    WHEN UPPER(TRIM(IFNULL(s.gender,''))) IN ('F','FEMALE') THEN 'Female'
                    ELSE IFNULL(s.gender, '')
                END AS sex,

                IFNULL(s.idno, '') AS national_id,
                TRIM(IFNULL(s.regno, ''))    AS regno,
                TRIM(IFNULL(p.progcode, '')) AS progcode,
                IFNULL(p.progname, '')        AS progname,

                CASE
                    WHEN p.progname LIKE 'MASTER%'        OR p.progname LIKE 'Master%'       THEN 'Master''s Degree'
                    WHEN p.progname LIKE 'BACHELOR%'      OR p.progname LIKE 'Bachelor%'      THEN 'Bachelor''s Degree'
                    WHEN p.progname LIKE 'DOCTOR%'        OR p.progname LIKE 'Doctor%'
                      OR p.progname LIKE 'PHD%'           OR p.progname LIKE 'PhD%'           THEN 'Doctoral Degree'
                    WHEN p.progname LIKE 'POSTGRADUATE%'  OR p.progname LIKE 'Postgraduate%'  THEN 'Postgraduate Diploma'
                    WHEN p.progname LIKE 'DIPLOMA%'       OR p.progname LIKE 'Diploma%'       THEN 'Diploma'
                    WHEN p.progname LIKE 'CERTIFICATE%'   OR p.progname LIKE 'Certificate%'   THEN 'Certificate'
                    ELSE ''
                END AS award_level,

                IFNULL(s.yearofstudy, '') AS yearofstudy,
                IFNULL(cam.campus_name, IFNULL(TRIM(s.studCampus), '')) AS study_centre

            FROM acad_student s
            LEFT JOIN acad_programme p  ON TRIM(s.progid)     = TRIM(p.progcode)
            LEFT JOIN acad_campuses cam ON TRIM(s.studCampus) = TRIM(cam.campus_code)

            WHERE (@studStatus = 'ALL' OR UPPER(TRIM(IFNULL(s.new_status,''))) = @studStatus)
              AND (@progCode = ''  OR TRIM(s.progid)     = @progCode)
              AND (@campus   = ''  OR TRIM(s.studCampus) = @campus)
              AND (@acadYear = ''  OR TRIM(s.entryyear)  = @acadYear)

            ORDER BY p.progname, s.firstname, s.othername";

        var dt = new DataTable();
        try
        {
            using (var conn = new MySqlConnection(ConnStr))
            {
                conn.Open();
                using (var cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@studStatus", status);
                    cmd.Parameters.AddWithValue("@progCode",   progCode);
                    cmd.Parameters.AddWithValue("@campus",     campus);
                    cmd.Parameters.AddWithValue("@acadYear",   acadYear);

                    var da = new MySqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Trace.TraceError("NCHEExporter data load error: {0}", ex.Message);
            lblCount.Text = "<span style='color:#c0392b;font-size:12px;'>Database error loading data. Please contact the system administrator.</span>";
            return dt;
        }

        // Award-level filter is applied in-process (it's a derived/computed column)
        if (!string.IsNullOrEmpty(awardLevel))
        {
            var filtered = dt.Clone();
            foreach (DataRow row in dt.Rows)
            {
                if (row["award_level"].ToString().IndexOf(awardLevel, StringComparison.OrdinalIgnoreCase) >= 0)
                    filtered.ImportRow(row);
            }
            dt = filtered;
        }

        // Prepend S/N auto-increment column
        dt.Columns.Add("sn", typeof(int));
        dt.Columns["sn"].SetOrdinal(0);
        for (int i = 0; i < dt.Rows.Count; i++)
            dt.Rows[i]["sn"] = i + 1;

        return dt;
    }

    private void BindGrid(DataTable dt, bool previewOnly = true)
    {
        // For preview, cap at 200 rows to keep page responsive
        if (previewOnly && dt.Rows.Count > 200)
        {
            DataTable preview = dt.Clone();
            for (int i = 0; i < 200; i++)
                preview.ImportRow(dt.Rows[i]);
            gvNCHE.DataSource = preview;
        }
        else
        {
            gvNCHE.DataSource = dt;
        }
        gvNCHE.DataBind();
    }

    private void UpdateCountLabel(int total)
    {
        if (total == 0)
        {
            lblCount.Text = "<span style='color:#888;font-size:12px;'>No records matched the selected criteria.</span>";
            return;
        }
        lblCount.Text = string.Format(
            "<span style='display:flex;align-items:center;gap:8px;'>" +
            "<span style='font-size:22px;font-weight:700;color:#05275C;line-height:1;'>{0:N0}</span>" +
            "<span style='font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.4px;'>student{1} matched</span>" +
            "</span>",
            total, total == 1 ? "" : "s");
    }

    // -- Button handlers -------------------------------------------------------

    protected void btnLoad_Click(object sender, EventArgs e)
    {
        var dt = LoadStudentData();
        BindGrid(dt, previewOnly: true);
        UpdateCountLabel(dt.Rows.Count);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        var dt = LoadStudentData();

        if (dt.Rows.Count == 0)
        {
            BindGrid(dt, previewOnly: false);
            UpdateCountLabel(0);
            return;
        }

        // Bind full dataset to grid (no preview cap - export must include all rows)
        BindGrid(dt, previewOnly: false);
        UpdateCountLabel(dt.Rows.Count);

        string fileName = string.Format("NCHE_StudentData_MRU_{0}", DateTime.Now.ToString("yyyyMMdd_HHmm"));
        gvNCHE.WriteXlsxToResponse(fileName);
        // Response ends here - browser downloads the .xlsx file
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        cmbStatus.Value     = "ACTIVE";
        cmbAcadYear.Value   = "";
        cmbProgramme.Value  = "";
        cmbAwardLevel.Value = "";
        cmbCampus.Value     = "";
        gvNCHE.DataSource   = null;
        gvNCHE.DataBind();
        lblCount.Text = "";
    }
}