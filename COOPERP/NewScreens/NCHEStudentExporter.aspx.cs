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
        : "Server=102.34.160.47;Database=campus_dynamics;Uid=dbmanager;Pwd=24thdecember1977;DefaultCommandTimeout=600";

    protected void Page_Load(object sender, EventArgs e)
    {
        // ALWAYS reload dropdowns on every postback - DevExpress requires items to be populated each time
        LoadFilterDropdowns();
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
            System.Diagnostics.Debug.WriteLine("CRITICAL: Error loading filter dropdowns: " + ex.Message);
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

            string sql = "SELECT DISTINCT TRIM(entryyear) AS entryyear FROM acad_student WHERE entryyear IS NOT NULL AND TRIM(entryyear) <> '' ORDER BY entryyear DESC LIMIT 50";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string year = reader["entryyear"].ToString();
                        ddlAcademicYear.Items.Add(new DevExpress.Web.ListEditItem(year, year));
                    }
                }
            }
        }
        catch { }
    }

    private void LoadProgrammes(MySqlConnection conn)
    {
        try
        {
            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new DevExpress.Web.ListEditItem("-- All Programmes --", ""));

            string sql = "SELECT TRIM(progcode) AS progcode, CONCAT(TRIM(progcode), ' - ', TRIM(progname)) AS progname FROM acad_programme WHERE TRIM(progcode) <> '' ORDER BY progname";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string progCode = reader["progcode"].ToString();
                        string progName = reader["progname"].ToString();
                        ddlProgramme.Items.Add(new DevExpress.Web.ListEditItem(progName, progCode));
                    }
                }
            }
        }
        catch { }
    }

    private void LoadStudyCentres(MySqlConnection conn)
    {
        try
        {
            ddlStudyCentre.Items.Clear();
            ddlStudyCentre.Items.Add(new DevExpress.Web.ListEditItem("-- All Centres --", ""));

            string sql = "SELECT DISTINCT TRIM(campus_code) AS campus_code, TRIM(campus_name) AS campus_name FROM acad_campuses WHERE TRIM(campus_name) <> '' ORDER BY campus_name";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["campus_code"].ToString();
                        string name = reader["campus_name"].ToString();
                        ddlStudyCentre.Items.Add(new DevExpress.Web.ListEditItem(name, code));
                    }
                }
            }
        }
        catch { }
    }

    /// <summary>
    /// Builds the WHERE clause for filtering students based on criteria
    /// </summary>
    private string BuildWhereClause()
    {
        List<string> conditions = new List<string>();

        if (ddlAcademicYear.Value != null && !string.IsNullOrEmpty(ddlAcademicYear.Value.ToString()))
            conditions.Add("s.entryyear = '" + MySqlHelper.EscapeString(ddlAcademicYear.Value.ToString()) + "'");

        if (ddlProgramme.Value != null && !string.IsNullOrEmpty(ddlProgramme.Value.ToString()))
            conditions.Add("s.progid = '" + MySqlHelper.EscapeString(ddlProgramme.Value.ToString()) + "'");

        if (ddlStudyCentre.Value != null && !string.IsNullOrEmpty(ddlStudyCentre.Value.ToString()))
            conditions.Add("s.studCampus = '" + MySqlHelper.EscapeString(ddlStudyCentre.Value.ToString()) + "'");

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
            System.Diagnostics.Debug.WriteLine("GetStudentData: WhereClause = " + whereClause);

            // Note: Using simple SELECT without ROW_NUMBER for better MySQL compatibility
            string sql = @"
                SELECT 
                    '' as sn,
                    CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) as names,
                    COALESCE(s.gender, '') as gender,
                    COALESCE(s.nationality, '') as national_id,
                    s.regno as reg_no,
                    p.progcode as progcode,
                    p.progname as progname,
                    'Degree' as award_level,
                    IF(TRIM(s.entryyear) <> '' AND TRIM(s.entryyear) IS NOT NULL, 
                        GREATEST(1, YEAR(NOW()) - CAST(TRIM(s.entryyear) AS UNSIGNED) + 1), 
                        '1') as year_study,
                    COALESCE(c.campus_name, s.studCampus, 'Main Campus') as study_centre
                FROM acad_student s
                LEFT JOIN acad_programme p ON s.progid = p.progcode
                LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
                " + whereClause + @"
                ORDER BY s.regno
            ";

            System.Diagnostics.Debug.WriteLine("GetStudentData: Executing query with connection: " + ConnectionString.Substring(0, 50) + "...");

            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.CommandTimeout = 30;
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                        System.Diagnostics.Debug.WriteLine("GetStudentData: Query returned " + dt.Rows.Count + " rows");
                        
                        // Number the rows in the application
                        int rowNum = 1;
                        foreach (DataRow row in dt.Rows)
                        {
                            row["sn"] = rowNum++;
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("ERROR in GetStudentData: " + ex.Message + " | Stack: " + ex.StackTrace);
        }

        return dt;
    }

    /// <summary>
    /// Preview the data that will be exported
    /// </summary>
    protected void BtnPreview_Click(object sender, EventArgs e)
    {
        System.Diagnostics.Debug.WriteLine("========== BtnPreview_Click Called ==========");
        try
        {
            System.Diagnostics.Debug.WriteLine("Getting student data...");
            DataTable dt = GetStudentData();

            if (dt != null)
            {
                System.Diagnostics.Debug.WriteLine("DataTable returned, Rows: " + dt.Rows.Count);
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("DataTable is NULL!");
            }

            if (dt != null && dt.Rows.Count > 0)
            {
                System.Diagnostics.Debug.WriteLine("Binding grid with " + dt.Rows.Count + " rows");
                gvPreview.DataSource = dt;
                gvPreview.DataBind();

                totalCount.InnerText = dt.Rows.Count.ToString();
                previewSection.Style["display"] = "block";
                System.Diagnostics.Debug.WriteLine("Preview section shown successfully");
            }
            else
            {
                System.Diagnostics.Debug.WriteLine("No data returned. Hiding preview section.");
                previewSection.Style["display"] = "none";
                totalCount.InnerText = "0";
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("ERROR in BtnPreview_Click: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("StackTrace: " + ex.StackTrace);
            totalCount.InnerText = "Error: " + ex.Message;
            previewSection.Style["display"] = "block";
        }
        System.Diagnostics.Debug.WriteLine("========== BtnPreview_Click Completed ==========");
    }

    /// <summary>
    /// Export data as CSV file
    /// </summary>
    protected void BtnExportCSV_Click(object sender, EventArgs e)
    {
        try
        {
            DataTable dt = GetStudentData();
            System.Diagnostics.Debug.WriteLine("CSV Export: Got " + dt.Rows.Count + " rows");

            if (dt == null || dt.Rows.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("CSV Export: No data to export");
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
                    row["gender"],
                    EscapeCSV(row["national_id"].ToString()),
                    row["reg_no"],
                    row["progcode"],
                    EscapeCSV(row["progname"].ToString()),
                    row["award_level"],
                    row["year_study"],
                    row["study_centre"]
                ));
            }

            // Send file to browser
            string filename = "NCHE_Students_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv";
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=" + filename);
            Response.AddHeader("Content-Type", "text/csv; charset=utf-8");
            Response.Charset = "utf-8";
            Response.Write(csv.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("ERROR in BtnExportCSV: " + ex.Message + " | Stack: " + ex.StackTrace);
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
            System.Diagnostics.Debug.WriteLine("Excel Export: Got " + dt.Rows.Count + " rows");

            if (dt == null || dt.Rows.Count == 0)
            {
                System.Diagnostics.Debug.WriteLine("Excel Export: No data to export");
                return;
            }

            // Export to Excel using manual method for compatibility
            string filename = "NCHE_Students_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".xls";
            
            // Use Response to stream Excel-compatible HTML table
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=" + filename);
            Response.AddHeader("Content-Type", "application/vnd.ms-excel");
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
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["gender"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["national_id"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["reg_no"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["progcode"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["progname"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["award_level"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["year_study"].ToString()) + "</Data></Cell>");
                html.Append("<Cell><Data ss:Type=\"String\">" + EscapeXml(row["study_centre"].ToString()) + "</Data></Cell>");
                html.AppendLine("</Row>");
            }
            
            html.AppendLine("</Table>");
            html.AppendLine("</Worksheet>");
            html.AppendLine("</Workbook>");
            
            System.Diagnostics.Debug.WriteLine("Excel Export: Writing " + html.Length + " bytes");
            Response.Write(html.ToString());
            Response.Flush();
            Response.End();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("ERROR in BtnExportExcel: " + ex.Message + " | Stack: " + ex.StackTrace);
        }
    }

    /// <summary>
    /// Clear all filter criteria
    /// </summary>
    protected void BtnClear_Click(object sender, EventArgs e)
    {
        ddlAcademicYear.Value = null;
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
