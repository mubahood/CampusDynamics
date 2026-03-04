using System;
using System.Data;
using System.Web.UI;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.Text;
using System.Collections.Generic;
using System.Web;

public partial class COOPERP_NewScreens_NCHEStudentExporter : System.Web.UI.Page
{
    private string ConnectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"] != null
        ? ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString
        : "Server=localhost;Database=campus_dynamics;Uid=root;Pwd=24thdecember1977;";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilterDropdowns();
        }
    }

    /// <summary>
    /// Loads all filter dropdown values from the database
    /// </summary>
    private void LoadFilterDropdowns()
    {
        MySqlConnection conn = null;
        try
        {
            conn = new MySqlConnection(ConnectionString);
            conn.Open();

            // Load Academic Years
            LoadAcademicYears(conn);

            // Load Programmes
            LoadProgrammes(conn);

            // Load Study Centres
            LoadStudyCentres(conn);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading filter dropdowns: " + ex.Message);
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                "alert('Warning: Some filter options may not be available. Error: " + ex.Message.Replace("'", "\"") + "');", true);
        }
        finally
        {
            if (conn != null)
            {
                conn.Close();
                conn.Dispose();
            }
        }
    }

    private void LoadAcademicYears(MySqlConnection conn)
    {
        try
        {
            ddlAcademicYear.Items.Clear();
            ddlAcademicYear.Items.Add(new DevExpress.Web.ListEditItem("-- All Years --", ""));

            string sql = "SELECT DISTINCT acad_year FROM acad_student WHERE acad_year IS NOT NULL AND acad_year != '' ORDER BY acad_year DESC LIMIT 50";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read() && count < 50)
                    {
                        string year = reader["acad_year"].ToString().Trim();
                        if (!string.IsNullOrEmpty(year))
                        {
                            ddlAcademicYear.Items.Add(new DevExpress.Web.ListEditItem(year, year));
                            count++;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading academic years: " + ex.Message);
            // Entry Year will show only "-- All Years --" if query fails
        }
    }

    private void LoadProgrammes(MySqlConnection conn)
    {
        try
        {
            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new DevExpress.Web.ListEditItem("-- All Programmes --", ""));

            string sql = @"SELECT DISTINCT p.prog_id, p.prog_name 
                          FROM acad_programme p
                          WHERE EXISTS (SELECT 1 FROM acad_student s WHERE s.prog_id = p.prog_id)
                          ORDER BY p.prog_name
                          LIMIT 500";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read() && count < 500)
                    {
                        string progId = reader["prog_id"].ToString().Trim();
                        string progName = reader["prog_name"].ToString().Trim();
                        if (!string.IsNullOrEmpty(progId) && !string.IsNullOrEmpty(progName))
                        {
                            ddlProgramme.Items.Add(new DevExpress.Web.ListEditItem(progName, progId));
                            count++;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading programmes: " + ex.Message);
            // Programme will show only "-- All Programmes --" if query fails
        }
    }

    private void LoadStudyCentres(MySqlConnection conn)
    {
        try
        {
            ddlStudyCentre.Items.Clear();
            ddlStudyCentre.Items.Add(new DevExpress.Web.ListEditItem("-- All Centres --", ""));

            string sql = @"SELECT DISTINCT study_centre FROM acad_student 
                          WHERE study_centre IS NOT NULL AND study_centre != ''
                          ORDER BY study_centre
                          LIMIT 100";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 10;
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    int count = 0;
                    while (reader.Read() && count < 100)
                    {
                        string centre = reader["study_centre"].ToString().Trim();
                        if (!string.IsNullOrEmpty(centre))
                        {
                            ddlStudyCentre.Items.Add(new DevExpress.Web.ListEditItem(centre, centre));
                            count++;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error loading study centres: " + ex.Message);
            // Study Centre will show only "-- All Centres --" if query fails
        }
    }

    /// <summary>
    /// Builds the WHERE clause for filtering students based on criteria
    /// </summary>
    private string BuildWhereClause()
    {
        List<string> conditions = new List<string>();

        if (ddlAcademicYear.Value != null && !string.IsNullOrEmpty(ddlAcademicYear.Value.ToString()))
            conditions.Add("s.acad_year = '" + MySqlHelper.EscapeString(ddlAcademicYear.Value.ToString()) + "'");

        if (ddlStatus.Value != null && !string.IsNullOrEmpty(ddlStatus.Value.ToString()))
            conditions.Add("s.new_status = '" + MySqlHelper.EscapeString(ddlStatus.Value.ToString()) + "'");

        if (ddlProgramme.Value != null && !string.IsNullOrEmpty(ddlProgramme.Value.ToString()))
            conditions.Add("s.prog_id = '" + MySqlHelper.EscapeString(ddlProgramme.Value.ToString()) + "'");

        // Award Level filter removed - made optional per requirement

        if (ddlStudyCentre.Value != null && !string.IsNullOrEmpty(ddlStudyCentre.Value.ToString()))
            conditions.Add("s.study_centre = '" + MySqlHelper.EscapeString(ddlStudyCentre.Value.ToString()) + "'");

        if (ddlYearOfStudy.Value != null && !string.IsNullOrEmpty(ddlYearOfStudy.Value.ToString()))
            conditions.Add("s.year_of_study = " + MySqlHelper.EscapeString(ddlYearOfStudy.Value.ToString()));

        return conditions.Count > 0 ? " WHERE " + string.Join(" AND ", conditions) : "";
    }

    /// <summary>
    /// Gets the filtered student data for NCHE export
    /// </summary>
    private DataTable GetStudentData()
    {
        DataTable dt = new DataTable();

        try
        {
            string whereClause = BuildWhereClause();

            string sql = @"
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY s.regno) as sn,
                    CONCAT(COALESCE(s.first_name, ''), ' ', COALESCE(s.middle_name, ''), ' ', COALESCE(s.last_name, '')) as names,
                    COALESCE(s.gender, '') as sex,
                    COALESCE(s.national_id, '') as national_id,
                    s.regno as reg_no,
                    p.prog_code,
                    p.prog_name,
                    COALESCE(p.award_level, 'Degree') as award_level,
                    COALESCE(s.year_of_study, '1') as year_study,
                    COALESCE(s.study_centre, 'Main Campus') as study_centre
                FROM acad_student s
                LEFT JOIN acad_programme p ON s.prog_id = p.prog_id
                " + whereClause + @"
                ORDER BY s.regno
            ";

            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Error getting student data: " + ex.Message);
        }

        return dt;
    }

    /// <summary>
    /// Preview the data that will be exported
    /// </summary>
    protected void BtnPreview_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = GetStudentData();

            if (dt.Rows.Count > 0)
            {
                gvPreview.DataSource = dt;
                gvPreview.DataBind();

                totalCount.InnerText = dt.Rows.Count.ToString();
                previewSection.Style["display"] = "block";
            }
            else
            {
                previewSection.Style["display"] = "none";
                totalCount.InnerText = "0";
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                    "alert('No students found matching the selected criteria.');", true);
            }
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                "alert('Error: " + ex.Message + "');", true);
        }
    }

    /// <summary>
    /// Export data as CSV file
    /// </summary>
    protected void BtnExportCSV_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = GetStudentData();

            if (dt.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                    "alert('No students found matching the selected criteria.');", true);
                return;
            }

            // Build CSV content
            StringBuilder csv = new StringBuilder();

            // Header row
            csv.AppendLine("S/N,Names,Sex,National ID No.,Institutional Reg. NO,Programme code,Programme name,Award level,Year of study,Study centre");

            // Data rows
            foreach (DataRow row in dt.Rows)
            {
                csv.AppendLine(string.Format("\"{0}\",\"{1}\",\"{2}\",\"{3}\",\"{4}\",\"{5}\",\"{6}\",\"{7}\",\"{8}\",\"{9}\"",
                    row["sn"],
                    EscapeCSV(row["names"].ToString()),
                    row["sex"],
                    EscapeCSV(row["national_id"].ToString()),
                    row["reg_no"],
                    row["prog_code"],
                    EscapeCSV(row["prog_name"].ToString()),
                    row["award_level"],
                    row["year_study"],
                    row["study_centre"]
                ));
            }

            // Send file to browser
            string filename = "NCHE_Students_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv";
            Response.Clear();
            Response.AddHeader("content-disposition", "attachment;filename=" + filename);
            Response.AddHeader("Content-Type", "text/csv; charset=utf-8");
            Response.Write(csv.ToString());
            Response.End();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                "alert('Error exporting CSV: " + ex.Message + "');", true);
        }
    }

    /// <summary>
    /// Export data as Excel file
    /// </summary>
    protected void BtnExportExcel_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = GetStudentData();

            if (dt.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                    "alert('No students found matching the selected criteria.');", true);
                return;
            }

            // Export to Excel using manual method for compatibility
            string filename = "NCHE_Students_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".xlsx";
            
            // Use Response to stream Excel-compatible HTML table
            Response.Clear();
            Response.AddHeader("content-disposition", "attachment;filename=" + filename);
            Response.AddHeader("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            Response.Charset = "UTF-8";
            Response.ContentEncoding = System.Text.Encoding.UTF8;
            
            // Build HTML table that Excel can read
            StringBuilder html = new StringBuilder();
            html.AppendLine("<?xml version=\"1.0\"?>");
            html.AppendLine("<?mso-application progid=\"Excel.Sheet\"?>");
            html.AppendLine("<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:html=\"http://www.w3.org/TR/REC-html40\">");
            html.AppendLine("<DocumentProperties xmlns=\"urn:schemas-microsoft-com:office:office\"><Title>NCHE Student Export</Title></DocumentProperties>");
            html.AppendLine("<Styles>");
            html.AppendLine("<Style ss:ID=\"Default\" ss:Name=\"Normal\"></Style>");
            html.AppendLine("<Style ss:ID=\"Header\" ss:Name=\"Header\"><Interior ss:Color=\"#D9E1F2\" ss:Pattern=\"Solid\"/><Font ss:Bold=\"1\"/></Style>");
            html.AppendLine("</Styles>");
            html.AppendLine("<Worksheet ss:Name=\"Students\">");
            html.AppendLine("<Table>");
            
            // Add header row
            html.Append("<Row ss:StyleID=\"Header\">");
            html.Append("<Cell><Data ss:Type=\"String\">S/N</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Names</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Sex</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">National ID No.</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Institutional Reg. NO</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Programme code</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Programme name</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Award level</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Year of study</Data></Cell>");
            html.Append("<Cell><Data ss:Type=\"String\">Study centre</Data></Cell>");
            html.AppendLine("</Row>");
            
            // Add data rows
            foreach (DataRow row in dt.Rows)
            {
                html.Append("<Row>");
                html.Append("<Cell><Data ss:Type=\"Number\">" + EscapeXml(row["sn"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["names"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["sex"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["national_id"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["reg_no"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["prog_code"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["prog_name"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["award_level"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["year_study"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["study_centre"].ToString()) + "</Data></Cell>");
                html.AppendLine("</Row>");
            }
            
            html.AppendLine("</Table>");
            html.AppendLine("</Worksheet>");
            html.AppendLine("</Workbook>");
            
            Response.Write(html.ToString());
            Response.End();
        }
        catch (Exception ex)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", 
                "alert('Error exporting Excel: " + ex.Message + "');", true);
        }
    }

    /// <summary>
    /// Clear all filter criteria
    /// </summary>
    protected void BtnClear_Click(object sender, EventArgs e)
    {
        ddlAcademicYear.Value = null;
        ddlStatus.Value = null;
        ddlProgramme.Value = null;
        ddlStudyCentre.Value = null;
        ddlYearOfStudy.Value = null;
        previewSection.Style["display"] = "none";
    }

    /// <summary>
    /// Helper method to escape CSV fields containing quotes or commas
    /// </summary>
    private string EscapeCSV(string value)
    {
        if (string.IsNullOrEmpty(value))
            return "";
        
        return value.Replace("\"", "\"\"");
    }

    /// <summary>
    /// Helper method to escape XML special characters for Excel export
    /// </summary>
    private string EscapeXml(string value)
    {
        if (string.IsNullOrEmpty(value))
            return "";
        
        return value
            .Replace("&", "&amp;")
            .Replace("<", "&lt;")
            .Replace(">", "&gt;")
            .Replace("\"", "&quot;")
            .Replace("'", "&apos;");
    }
}
