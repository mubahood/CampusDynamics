using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_ResultsUpdates : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        // Handle AJAX requests for Summary Report
        string action = Request.QueryString["action"];
        if (!string.IsNullOrEmpty(action))
        {
            HandleAjaxRequest(action);
            return;
        }
        
        if (!IsPostBack)
        {
            LoadFaculties();
            LoadAcademicYears();
            LoadProgrammes();
            LoadCourses();
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
        }
    }
    
    #region Summary Report AJAX Handlers
    
    private void HandleAjaxRequest(string action)
    {
        Response.Clear();
        
        switch (action)
        {
            case "GetProgrammes":
                HandleGetProgrammes();
                break;
            case "GetAcademicYears":
                HandleGetAcademicYears();
                break;
            case "PreviewSummaryReportStudents":
                HandlePreviewSummaryReportStudents();
                break;
            case "ExportSummaryReport":
                HandleExportSummaryReport();
                break;
            default:
                Response.ContentType = "application/json";
                Response.Write("{\"error\": \"Unknown action\"}");
                break;
        }
        
        if (action != "ExportSummaryReport")
            Response.End();
    }
    
    private void HandleGetProgrammes()
    {
        Response.ContentType = "application/json";
        
        try
        {
            List<object> programmes = new List<object>();
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT DISTINCT progcode, progname FROM acad_programme ORDER BY progname";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            programmes.Add(new { 
                                code = reader["progcode"].ToString(), 
                                name = reader["progname"].ToString() 
                            });
                        }
                    }
                }
            }
            
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Response.Write(serializer.Serialize(programmes));
        }
        catch (Exception ex)
        {
            Response.Write("[]");
        }
    }
    
    private void HandleGetAcademicYears()
    {
        Response.ContentType = "application/json";
        
        try
        {
            List<string> years = new List<string>();
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT DISTINCT acadyear FROM acad_examresults_faculty WHERE acadyear IS NOT NULL AND acadyear != '' ORDER BY acadyear DESC";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            years.Add(reader["acadyear"].ToString());
                        }
                    }
                }
            }
            
            // Add generated years as fallback
            int currentYear = DateTime.Now.Year;
            for (int i = currentYear + 1; i >= currentYear - 5; i--)
            {
                string acadYear = string.Format("{0}/{1}", i, i + 1);
                if (!years.Contains(acadYear))
                    years.Add(acadYear);
            }
            
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Response.Write(serializer.Serialize(years));
        }
        catch (Exception ex)
        {
            Response.Write("[]");
        }
    }
    
    private void HandlePreviewSummaryReportStudents()
    {
        Response.ContentType = "application/json";
        
        try
        {
            string programme = Request.QueryString["programme"] ?? "";
            string acadYear = Request.QueryString["acadYear"] ?? "";
            string semester = Request.QueryString["semester"] ?? "";
            string studyYear = Request.QueryString["studyYear"] ?? "";
            
            // Get CGPA-based student counts
            DataTable studentData = GetStudentCGPAData(programme, acadYear, semester, studyYear);
            
            int vcList = 0, deansList = 0, secondLower = 0, pass = 0;
            
            foreach (DataRow row in studentData.Rows)
            {
                decimal cgpa = row["cgpa"] != DBNull.Value ? Convert.ToDecimal(row["cgpa"]) : 0;
                
                if (cgpa >= 4.40m) vcList++;
                else if (cgpa >= 3.60m) deansList++;
                else if (cgpa >= 2.80m) secondLower++;
                else if (cgpa >= 2.00m) pass++;
            }
            
            var result = new {
                vcList = vcList,
                deansList = deansList,
                secondLower = secondLower,
                pass = pass,
                total = studentData.Rows.Count
            };
            
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Response.Write(serializer.Serialize(result));
        }
        catch (Exception ex)
        {
            Response.Write("{\"vcList\": 0, \"deansList\": 0, \"secondLower\": 0, \"pass\": 0, \"total\": 0, \"error\": \"" + ex.Message.Replace("\"", "'") + "\"}");
        }
    }
    
    private DataTable GetStudentCGPAData(string programme, string acadYear, string semester, string studyYear)
    {
        DataTable dt = new DataTable();
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Calculate CGPA for each student based on their results
            string sql = @"SELECT 
                s.regno,
                s.entryno,
                CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) AS student_name,
                s.gender,
                p.progname,
                ROUND(SUM(r.gradept * r.CreditUnits) / NULLIF(SUM(r.CreditUnits), 0), 2) AS cgpa
            FROM acad_student s
            INNER JOIN acad_examresults_faculty r ON s.regno = r.regno
            LEFT JOIN acad_programme p ON s.progid = p.progcode
            WHERE r.progid = @programme
              AND r.acadyear = @acadYear
              AND r.semester = @semester";
            
            if (!string.IsNullOrEmpty(studyYear))
                sql += " AND r.studyyear = @studyYear";
            
            sql += @" GROUP BY s.regno, s.entryno, s.firstname, s.othername, s.gender, p.progname
                      HAVING cgpa IS NOT NULL AND cgpa >= 2.00
                      ORDER BY cgpa DESC";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@programme", programme);
                cmd.Parameters.AddWithValue("@acadYear", acadYear);
                cmd.Parameters.AddWithValue("@semester", int.Parse(semester));
                
                if (!string.IsNullOrEmpty(studyYear))
                    cmd.Parameters.AddWithValue("@studyYear", int.Parse(studyYear));
                
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }
        }
        
        return dt;
    }
    
    private void HandleExportSummaryReport()
    {
        try
        {
            string programme = Request.QueryString["programme"] ?? "";
            string acadYear = Request.QueryString["acadYear"] ?? "";
            string semester = Request.QueryString["semester"] ?? "";
            string studyYear = Request.QueryString["studyYear"] ?? "";
            
            // Get data for PDF
            DataTable studentData = GetStudentCGPAData(programme, acadYear, semester, studyYear);
            
            if (studentData.Rows.Count == 0)
            {
                Response.ContentType = "text/html";
                Response.Write("<html><body><h3>No data found for the selected filters.</h3></body></html>");
                return;
            }
            
            // Get programme name
            string programmeName = GetProgrammeName(programme);
            
            // Generate PDF
            GenerateSummaryReportPdf(studentData, programmeName, acadYear, semester, studyYear);
        }
        catch (Exception ex)
        {
            Response.ContentType = "text/html";
            Response.Write("<html><body><h3>Error generating report:</h3><p>" + Server.HtmlEncode(ex.Message) + "</p></body></html>");
        }
    }
    
    private string GetProgrammeName(string progCode)
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand("SELECT progname FROM acad_programme WHERE progcode = @code", conn))
            {
                cmd.Parameters.AddWithValue("@code", progCode);
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : progCode;
            }
        }
    }
    
    private void GenerateSummaryReportPdf(DataTable data, string programmeName, string acadYear, string semester, string studyYear)
    {
        // Create DevExpress PrintingSystem
        DevExpress.XtraPrinting.PrintingSystem ps = new DevExpress.XtraPrinting.PrintingSystem();
        DevExpress.XtraPrinting.PrintableComponentLink link = new DevExpress.XtraPrinting.PrintableComponentLink(ps);
        
        // Create custom link for PDF content
        DevExpress.XtraPrinting.Link pdfLink = new DevExpress.XtraPrinting.Link(ps);
        pdfLink.CreateDetailArea += (s, args) => {
            GenerateSummaryReportContent(args.Graph, data, programmeName, acadYear, semester, studyYear);
        };
        
        // Set page settings
        ps.PageSettings.PaperKind = System.Drawing.Printing.PaperKind.A4;
        ps.PageSettings.Landscape = false;
        ps.PageSettings.LeftMargin = 50;
        ps.PageSettings.RightMargin = 50;
        ps.PageSettings.TopMargin = 40;
        ps.PageSettings.BottomMargin = 40;
        
        pdfLink.CreateDocument();
        
        // Export to PDF
        string fileName = string.Format("PerformanceSummary_{0}_{1}.pdf", acadYear.Replace("/", "-"), DateTime.Now.ToString("yyyyMMdd_HHmmss"));
        
        Response.Clear();
        Response.ContentType = "application/pdf";
        Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
        
        using (System.IO.MemoryStream stream = new System.IO.MemoryStream())
        {
            ps.ExportToPdf(stream);
            Response.BinaryWrite(stream.ToArray());
        }
        
        Response.End();
    }
    
    private void GenerateSummaryReportContent(DevExpress.XtraPrinting.BrickGraphics gr, DataTable data, 
        string programmeName, string acadYear, string semester, string studyYear)
    {
        // Define colors
        System.Drawing.Color brandColor = System.Drawing.Color.FromArgb(23, 77, 164); // #174DA4
        System.Drawing.Color vcListColor = System.Drawing.Color.FromArgb(26, 84, 144); // Blue
        System.Drawing.Color deansListColor = System.Drawing.Color.FromArgb(46, 125, 50); // Green
        System.Drawing.Color secondLowerColor = System.Drawing.Color.FromArgb(245, 124, 0); // Orange
        System.Drawing.Color passColor = System.Drawing.Color.FromArgb(198, 40, 40); // Red
        
        // Define fonts
        System.Drawing.Font titleFont = new System.Drawing.Font("Tahoma", 14, System.Drawing.FontStyle.Bold);
        System.Drawing.Font subtitleFont = new System.Drawing.Font("Tahoma", 10, System.Drawing.FontStyle.Regular);
        System.Drawing.Font sectionFont = new System.Drawing.Font("Tahoma", 11, System.Drawing.FontStyle.Bold);
        System.Drawing.Font headerFont = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Bold);
        System.Drawing.Font dataFont = new System.Drawing.Font("Tahoma", 8, System.Drawing.FontStyle.Regular);
        System.Drawing.Font smallFont = new System.Drawing.Font("Tahoma", 7, System.Drawing.FontStyle.Regular);
        
        float pageWidth = 495; // A4 width minus margins (approx)
        float yPos = 0;
        float rowHeight = 14;
        
        // Categorize students
        List<DataRow> vcListStudents = new List<DataRow>();
        List<DataRow> deansListStudents = new List<DataRow>();
        List<DataRow> secondLowerStudents = new List<DataRow>();
        List<DataRow> passStudents = new List<DataRow>();
        
        foreach (DataRow row in data.Rows)
        {
            decimal cgpa = row["cgpa"] != DBNull.Value ? Convert.ToDecimal(row["cgpa"]) : 0;
            
            if (cgpa >= 4.40m) vcListStudents.Add(row);
            else if (cgpa >= 3.60m) deansListStudents.Add(row);
            else if (cgpa >= 2.80m) secondLowerStudents.Add(row);
            else if (cgpa >= 2.00m) passStudents.Add(row);
        }
        
        // ===== HEADER SECTION =====
        // University name
        DevExpress.XtraPrinting.TextBrick uniNameBrick = new DevExpress.XtraPrinting.TextBrick();
        uniNameBrick.Text = "MOUNTAINS OF THE MOON UNIVERSITY";
        uniNameBrick.Font = titleFont;
        uniNameBrick.ForeColor = brandColor;
        uniNameBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        uniNameBrick.BackColor = System.Drawing.Color.Transparent;
        uniNameBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(uniNameBrick, new System.Drawing.RectangleF(0, yPos, pageWidth, 20));
        yPos += 22;
        
        // Report title
        DevExpress.XtraPrinting.TextBrick reportTitleBrick = new DevExpress.XtraPrinting.TextBrick();
        reportTitleBrick.Text = "STUDENT PERFORMANCE SUMMARY REPORT";
        reportTitleBrick.Font = sectionFont;
        reportTitleBrick.ForeColor = System.Drawing.Color.FromArgb(51, 51, 51);
        reportTitleBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        reportTitleBrick.BackColor = System.Drawing.Color.Transparent;
        reportTitleBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(reportTitleBrick, new System.Drawing.RectangleF(0, yPos, pageWidth, 16));
        yPos += 20;
        
        // Subtitle with filters
        string filterText = string.Format("Programme: {0}  |  Academic Year: {1}  |  Semester: {2}{3}",
            programmeName, acadYear, semester,
            !string.IsNullOrEmpty(studyYear) ? "  |  Year: " + studyYear : "");
        
        DevExpress.XtraPrinting.TextBrick filterBrick = new DevExpress.XtraPrinting.TextBrick();
        filterBrick.Text = filterText;
        filterBrick.Font = subtitleFont;
        filterBrick.ForeColor = System.Drawing.Color.FromArgb(102, 102, 102);
        filterBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        filterBrick.BackColor = System.Drawing.Color.Transparent;
        filterBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(filterBrick, new System.Drawing.RectangleF(0, yPos, pageWidth, 14));
        yPos += 18;
        
        // Horizontal line
        DevExpress.XtraPrinting.LineBrick line1 = new DevExpress.XtraPrinting.LineBrick();
        line1.LineStyle = System.Drawing.Drawing2D.DashStyle.Solid;
        line1.ForeColor = brandColor;
        gr.DrawBrick(line1, new System.Drawing.RectangleF(0, yPos, pageWidth, 2));
        yPos += 8;
        
        // ===== DRAW EACH CATEGORY =====
        // Column widths
        float numWidth = 25;
        float regNoWidth = 90;
        float entryNoWidth = 100;
        float nameWidth = 150;
        float genderWidth = 45;
        float cgpaWidth = 45;
        float progWidth = pageWidth - numWidth - regNoWidth - entryNoWidth - nameWidth - genderWidth - cgpaWidth;
        
        // 1. VC's LIST (FIRST CLASS)
        if (vcListStudents.Count > 0)
        {
            yPos = DrawCategorySection(gr, vcListStudents, "1. VC's LIST (FIRST CLASS)", "CGPA: 4.40 - 5.00",
                vcListColor, yPos, pageWidth, rowHeight, headerFont, dataFont, smallFont,
                numWidth, regNoWidth, entryNoWidth, nameWidth, genderWidth, cgpaWidth, progWidth);
            yPos += 10;
        }
        
        // 2. DEAN'S LIST (SECOND CLASS UPPER DIVISION)
        if (deansListStudents.Count > 0)
        {
            yPos = DrawCategorySection(gr, deansListStudents, "2. DEAN'S LIST (SECOND CLASS UPPER DIVISION)", "CGPA: 3.60 - 4.39",
                deansListColor, yPos, pageWidth, rowHeight, headerFont, dataFont, smallFont,
                numWidth, regNoWidth, entryNoWidth, nameWidth, genderWidth, cgpaWidth, progWidth);
            yPos += 10;
        }
        
        // 3. SECOND CLASS LOWER DIVISION
        if (secondLowerStudents.Count > 0)
        {
            yPos = DrawCategorySection(gr, secondLowerStudents, "3. SECOND CLASS LOWER DIVISION", "CGPA: 2.80 - 3.59",
                secondLowerColor, yPos, pageWidth, rowHeight, headerFont, dataFont, smallFont,
                numWidth, regNoWidth, entryNoWidth, nameWidth, genderWidth, cgpaWidth, progWidth);
            yPos += 10;
        }
        
        // 4. PASS
        if (passStudents.Count > 0)
        {
            yPos = DrawCategorySection(gr, passStudents, "4. PASS", "CGPA: 2.00 - 2.79",
                passColor, yPos, pageWidth, rowHeight, headerFont, dataFont, smallFont,
                numWidth, regNoWidth, entryNoWidth, nameWidth, genderWidth, cgpaWidth, progWidth);
            yPos += 10;
        }
        
        // ===== SUMMARY FOOTER =====
        yPos += 5;
        DevExpress.XtraPrinting.LineBrick line2 = new DevExpress.XtraPrinting.LineBrick();
        line2.LineStyle = System.Drawing.Drawing2D.DashStyle.Solid;
        line2.ForeColor = brandColor;
        gr.DrawBrick(line2, new System.Drawing.RectangleF(0, yPos, pageWidth, 2));
        yPos += 8;
        
        // Summary box
        DevExpress.XtraPrinting.TextBrick summaryBrick = new DevExpress.XtraPrinting.TextBrick();
        summaryBrick.Text = string.Format("TOTAL SUMMARY  |  VC's List: {0}  |  Dean's List: {1}  |  Second Lower: {2}  |  Pass: {3}  |  TOTAL: {4}",
            vcListStudents.Count, deansListStudents.Count, secondLowerStudents.Count, passStudents.Count, data.Rows.Count);
        summaryBrick.Font = new System.Drawing.Font("Tahoma", 9, System.Drawing.FontStyle.Bold);
        summaryBrick.ForeColor = System.Drawing.Color.White;
        summaryBrick.BackColor = brandColor;
        summaryBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        summaryBrick.Padding = new DevExpress.XtraPrinting.PaddingInfo(8, 8, 4, 4);
        summaryBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(summaryBrick, new System.Drawing.RectangleF(0, yPos, pageWidth, 20));
        yPos += 28;
        
        // Generated date footer
        DevExpress.XtraPrinting.TextBrick footerBrick = new DevExpress.XtraPrinting.TextBrick();
        footerBrick.Text = string.Format("Generated on: {0}  |  Mountains of the Moon University - Academic Registry", DateTime.Now.ToString("dd MMMM yyyy, HH:mm"));
        footerBrick.Font = smallFont;
        footerBrick.ForeColor = System.Drawing.Color.FromArgb(128, 128, 128);
        footerBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        footerBrick.BackColor = System.Drawing.Color.Transparent;
        footerBrick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(footerBrick, new System.Drawing.RectangleF(0, yPos, pageWidth, 12));
    }
    
    private float DrawCategorySection(DevExpress.XtraPrinting.BrickGraphics gr, List<DataRow> students,
        string categoryTitle, string cgpaRange, System.Drawing.Color categoryColor, float yPos, float pageWidth,
        float rowHeight, System.Drawing.Font headerFont, System.Drawing.Font dataFont, System.Drawing.Font smallFont,
        float numWidth, float regNoWidth, float entryNoWidth, float nameWidth, float genderWidth, float cgpaWidth, float progWidth)
    {
        // Category header with background
        DevExpress.XtraPrinting.TextBrick categoryBrick = new DevExpress.XtraPrinting.TextBrick();
        categoryBrick.Text = string.Format("{0}  ({1} students)  -  {2}", categoryTitle, students.Count, cgpaRange);
        categoryBrick.Font = new System.Drawing.Font("Tahoma", 9, System.Drawing.FontStyle.Bold);
        categoryBrick.ForeColor = System.Drawing.Color.White;
        categoryBrick.BackColor = categoryColor;
        categoryBrick.Sides = DevExpress.XtraPrinting.BorderSide.None;
        categoryBrick.Padding = new DevExpress.XtraPrinting.PaddingInfo(6, 6, 3, 3);
        gr.DrawBrick(categoryBrick, new System.Drawing.RectangleF(0, yPos, pageWidth, 16));
        yPos += 18;
        
        // Table header
        float xPos = 0;
        System.Drawing.Color headerBg = System.Drawing.Color.FromArgb(240, 240, 240);
        
        DrawHeaderCell(gr, "#", xPos, yPos, numWidth, rowHeight, headerFont, headerBg); xPos += numWidth;
        DrawHeaderCell(gr, "REG. NO", xPos, yPos, regNoWidth, rowHeight, headerFont, headerBg); xPos += regNoWidth;
        DrawHeaderCell(gr, "ENTRY NO", xPos, yPos, entryNoWidth, rowHeight, headerFont, headerBg); xPos += entryNoWidth;
        DrawHeaderCell(gr, "STUDENT NAME", xPos, yPos, nameWidth, rowHeight, headerFont, headerBg); xPos += nameWidth;
        DrawHeaderCell(gr, "GENDER", xPos, yPos, genderWidth, rowHeight, headerFont, headerBg); xPos += genderWidth;
        DrawHeaderCell(gr, "CGPA", xPos, yPos, cgpaWidth, rowHeight, headerFont, headerBg); xPos += cgpaWidth;
        DrawHeaderCell(gr, "PROGRAMME", xPos, yPos, progWidth, rowHeight, headerFont, headerBg);
        yPos += rowHeight;
        
        // Data rows
        int rowNum = 1;
        foreach (DataRow row in students)
        {
            xPos = 0;
            System.Drawing.Color rowBg = rowNum % 2 == 0 ? System.Drawing.Color.FromArgb(250, 250, 250) : System.Drawing.Color.White;
            
            DrawDataCell(gr, rowNum.ToString(), xPos, yPos, numWidth, rowHeight, dataFont, rowBg, System.Drawing.StringAlignment.Center); xPos += numWidth;
            DrawDataCell(gr, row["regno"].ToString(), xPos, yPos, regNoWidth, rowHeight, dataFont, rowBg, System.Drawing.StringAlignment.Near); xPos += regNoWidth;
            DrawDataCell(gr, row["entryno"].ToString(), xPos, yPos, entryNoWidth, rowHeight, dataFont, rowBg, System.Drawing.StringAlignment.Near); xPos += entryNoWidth;
            DrawDataCell(gr, row["student_name"].ToString(), xPos, yPos, nameWidth, rowHeight, dataFont, rowBg, System.Drawing.StringAlignment.Near); xPos += nameWidth;
            DrawDataCell(gr, row["gender"].ToString(), xPos, yPos, genderWidth, rowHeight, dataFont, rowBg, System.Drawing.StringAlignment.Center); xPos += genderWidth;
            
            decimal cgpa = row["cgpa"] != DBNull.Value ? Convert.ToDecimal(row["cgpa"]) : 0;
            DrawDataCell(gr, cgpa.ToString("F2"), xPos, yPos, cgpaWidth, rowHeight, dataFont, rowBg, System.Drawing.StringAlignment.Center); xPos += cgpaWidth;
            
            string progName = row["progname"] != DBNull.Value ? row["progname"].ToString() : "";
            if (progName.Length > 25) progName = progName.Substring(0, 22) + "...";
            DrawDataCell(gr, progName, xPos, yPos, progWidth, rowHeight, smallFont, rowBg, System.Drawing.StringAlignment.Near);
            
            yPos += rowHeight;
            rowNum++;
        }
        
        return yPos;
    }
    
    private void DrawHeaderCell(DevExpress.XtraPrinting.BrickGraphics gr, string text, float x, float y, 
        float width, float height, System.Drawing.Font font, System.Drawing.Color bgColor)
    {
        DevExpress.XtraPrinting.TextBrick brick = new DevExpress.XtraPrinting.TextBrick();
        brick.Text = text;
        brick.Font = font;
        brick.ForeColor = System.Drawing.Color.FromArgb(51, 51, 51);
        brick.BackColor = bgColor;
        brick.Sides = DevExpress.XtraPrinting.BorderSide.All;
        brick.BorderColor = System.Drawing.Color.FromArgb(200, 200, 200);
        brick.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 2, 2);
        brick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(System.Drawing.StringAlignment.Center);
        gr.DrawBrick(brick, new System.Drawing.RectangleF(x, y, width, height));
    }
    
    private void DrawDataCell(DevExpress.XtraPrinting.BrickGraphics gr, string text, float x, float y, 
        float width, float height, System.Drawing.Font font, System.Drawing.Color bgColor, System.Drawing.StringAlignment align)
    {
        DevExpress.XtraPrinting.TextBrick brick = new DevExpress.XtraPrinting.TextBrick();
        brick.Text = text;
        brick.Font = font;
        brick.ForeColor = System.Drawing.Color.FromArgb(51, 51, 51);
        brick.BackColor = bgColor;
        brick.Sides = DevExpress.XtraPrinting.BorderSide.All;
        brick.BorderColor = System.Drawing.Color.FromArgb(220, 220, 220);
        brick.Padding = new DevExpress.XtraPrinting.PaddingInfo(3, 3, 1, 1);
        brick.StringFormat = new DevExpress.XtraPrinting.BrickStringFormat(align);
        gr.DrawBrick(brick, new System.Drawing.RectangleF(x, y, width, height));
    }
    
    #endregion
    
    #region Data Loading
    
    private void LoadFaculties()
    {
        ddlFaculty.Items.Clear();
        ddlFaculty.Items.Add(new ListItem("-- All Faculties --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                using (MySqlCommand cmd = new MySqlCommand("SELECT fax_code, faculty_name FROM acad_faculty ORDER BY faculty_name", conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlFaculty.Items.Add(new ListItem(reader["faculty_name"].ToString(), reader["fax_code"].ToString()));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadAcademicYears()
    {
        ddlAcadYear.Items.Clear();
        ddlAcadYear.Items.Add(new ListItem("-- All --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT DISTINCT acadyear FROM acad_examresults_faculty WHERE acadyear IS NOT NULL AND acadyear != '' ORDER BY acadyear DESC";
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string yr = reader["acadyear"].ToString();
                            if (!string.IsNullOrEmpty(yr))
                                ddlAcadYear.Items.Add(new ListItem(yr, yr));
                        }
                    }
                }
            }
        }
        catch { }
        
        // Add generated years as fallback
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 5; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            if (ddlAcadYear.Items.FindByValue(acadYear) == null)
                ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
        }
        
        // Set default to current academic year
        string defaultYear = GetCurrentAcademicYear();
        if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
            ddlAcadYear.SelectedValue = defaultYear;
    }
    
    private string GetCurrentAcademicYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;
        if (month >= 8)
            return string.Format("{0}/{1}", year, year + 1);
        else
            return string.Format("{0}/{1}", year - 1, year);
    }
    
    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "SELECT progcode, progname FROM acad_programme";
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                    sql += " WHERE fax_code = @fax";
                sql += " ORDER BY progname";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                        cmd.Parameters.AddWithValue("@fax", ddlFaculty.SelectedValue);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ddlProgramme.Items.Add(new ListItem(reader["progname"].ToString(), reader["progcode"].ToString()));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void LoadCourses()
    {
        ddlCourse.Items.Clear();
        ddlCourse.Items.Add(new ListItem("-- All Courses --", ""));
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"SELECT DISTINCT e.course_id, c.courseName 
                    FROM acad_examresults_faculty e 
                    LEFT JOIN acad_course c ON e.course_id = c.courseID 
                    WHERE 1=1";
                
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    sql += " AND e.acadyear = @acad";
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    sql += " AND e.semester = @sem";
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    sql += " AND e.progid = @prog";
                
                sql += " ORDER BY c.courseName LIMIT 100";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string courseId = reader["course_id"].ToString();
                            string courseName = reader["courseName"] != DBNull.Value ? reader["courseName"].ToString() : courseId;
                            ddlCourse.Items.Add(new ListItem(string.Format("{0} - {1}", courseId, courseName), courseId));
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    private void UpdateDisplayLabels()
    {
        litAcadYearDisplay.Text = string.IsNullOrEmpty(ddlAcadYear.SelectedValue) ? "All" : ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = string.IsNullOrEmpty(ddlSemester.SelectedValue) ? "All" : ddlSemester.SelectedValue;
    }
    
    private void LoadStats()
    {
        litTotalCount.Text = "0";
        litPendingCount.Text = "0";
        litApprovedCount.Text = "0";
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<string> conditions = new List<string>();
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    conditions.Add("acadyear = @acad");
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    conditions.Add("semester = @sem");
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    conditions.Add("progid = @prog");
                if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                    conditions.Add("course_id = @course");
                
                string whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions.ToArray()) : "";
                
                string countSql = @"SELECT 
                    COUNT(*) as total,
                    SUM(CASE WHEN approved_by IS NOT NULL AND approved_by != '-' AND approved_by != '' THEN 1 ELSE 0 END) as approved,
                    SUM(CASE WHEN approved_by IS NULL OR approved_by = '-' OR approved_by = '' THEN 1 ELSE 0 END) as pending
                    FROM acad_examresults_faculty " + whereClause;
                
                using (MySqlCommand cmd = new MySqlCommand(countSql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                        cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litTotalCount.Text = (reader["total"] != DBNull.Value ? Convert.ToInt32(reader["total"]) : 0).ToString();
                            litApprovedCount.Text = (reader["approved"] != DBNull.Value ? Convert.ToInt32(reader["approved"]) : 0).ToString();
                            litPendingCount.Text = (reader["pending"] != DBNull.Value ? Convert.ToInt32(reader["pending"]) : 0).ToString();
                        }
                    }
                }
            }
        }
        catch { }
    }
    
    #endregion
    
    #region Grid Binding
    
    private DataTable CreateEmptyTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("ID", typeof(int));
        dt.Columns.Add("regno", typeof(string));
        dt.Columns.Add("student_name", typeof(string));
        dt.Columns.Add("course_id", typeof(string));
        dt.Columns.Add("course_name", typeof(string));
        dt.Columns.Add("prog_id", typeof(string));
        dt.Columns.Add("prog_name", typeof(string));
        dt.Columns.Add("acadyear", typeof(string));
        dt.Columns.Add("semester", typeof(int));
        dt.Columns.Add("ca_mark", typeof(decimal));
        dt.Columns.Add("exam_mark", typeof(decimal));
        dt.Columns.Add("total_mark", typeof(decimal));
        dt.Columns.Add("grade", typeof(string));
        dt.Columns.Add("gpa", typeof(decimal));
        dt.Columns.Add("approved_by", typeof(string));
        dt.Columns.Add("date_modified", typeof(DateTime));
        return dt;
    }
    
    private void BindGrid()
    {
        DataTable dt = CreateEmptyTable();
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                List<string> conditions = new List<string>();
                if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                    conditions.Add("e.acadyear = @acad");
                if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                    conditions.Add("e.semester = @sem");
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    conditions.Add("e.progid = @prog");
                if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                    conditions.Add("e.course_id = @course");
                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    conditions.Add("(e.regno LIKE @search OR s.firstname LIKE @search OR s.othername LIKE @search)");
                
                string whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions.ToArray()) : "";
                
                string sql = @"SELECT 
                    e.ID, e.regno, 
                    CONCAT(IFNULL(s.firstname,''), ' ', IFNULL(s.othername,'')) as student_name,
                    e.course_id, c.courseName as course_name,
                    e.progid as prog_id, p.progname as prog_name,
                    e.acadyear, e.semester,
                    e.cw_mark as ca_mark, e.ex_mark as exam_mark, e.total_mark, e.grade, e.gradept as gpa,
                    e.approved_by, NOW() as date_modified
                    FROM acad_examresults_faculty e
                    LEFT JOIN acad_course c ON e.course_id = c.courseID
                    LEFT JOIN acad_programme p ON e.progid = p.progcode
                    LEFT JOIN acad_student s ON e.regno = s.regno
                    " + whereClause + @"
                    ORDER BY e.acadyear DESC, e.semester, s.firstname, s.othername
                    LIMIT 500";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    if (!string.IsNullOrEmpty(ddlAcadYear.SelectedValue))
                        cmd.Parameters.AddWithValue("@acad", ddlAcadYear.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlSemester.SelectedValue))
                        cmd.Parameters.AddWithValue("@sem", int.Parse(ddlSemester.SelectedValue));
                    if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                        cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
                    if (!string.IsNullOrEmpty(ddlCourse.SelectedValue))
                        cmd.Parameters.AddWithValue("@course", ddlCourse.SelectedValue);
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        cmd.Parameters.AddWithValue("@search", "%" + txtSearch.Text.Trim() + "%");
                    
                    using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                    {
                        DataTable resultDt = new DataTable();
                        adapter.Fill(resultDt);
                        if (resultDt.Columns.Contains("ID"))
                            dt = resultDt;
                    }
                }
                
                if (dt.Rows.Count == 0)
                {
                    ShowMessage("No results found for the selected filters.", "warning");
                }
                else
                {
                    lblMessage.Text = string.Format("Showing {0} student results", dt.Rows.Count);
                    lblMessage.ForeColor = System.Drawing.Color.FromArgb(21, 87, 36);
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message, "error");
        }
        
        gvResults.DataSource = dt;
        gvResults.DataBind();
    }
    
    protected string GetStatusBadge(object approvedBy)
    {
        string status = (approvedBy != null && approvedBy != DBNull.Value) ? approvedBy.ToString() : "";
        bool isApproved = !string.IsNullOrEmpty(status) && status != "-";
        
        if (isApproved)
            return string.Format("<span class=\"ru-status-badge ru-status-badge--approved\">APPROVED</span>");
        else
            return string.Format("<span class=\"ru-status-badge ru-status-badge--pending\">PENDING</span>");
    }
    
    protected void gvResults_CustomColumnDisplayText(object sender, ASPxGridViewColumnDisplayTextEventArgs e)
    {
        // Custom formatting if needed
    }
    
    #endregion
    
    #region Event Handlers
    
    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes();
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadCourses();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void btnEditSelected_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResults.GetSelectedFieldValues(new string[] { "ID", "regno", "course_id", "student_name", "ca_mark", "exam_mark", "total_mark", "grade" });
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select a result to edit.", "warning");
            return;
        }
        
        if (selectedKeys.Count > 1)
        {
            ShowMessage("Please select only one result to edit at a time.", "warning");
            return;
        }
        
        // Get the first selected record
        object[] values = selectedKeys[0] as object[];
        if (values != null && values.Length >= 8)
        {
            hfResultID.Value = values[0].ToString();
            txtRegNo.Text = values[1] != null ? values[1].ToString() : "";
            txtCourse.Text = values[2] != null ? values[2].ToString() : "";
            litStudentName.Text = values[3] != null ? values[3].ToString() : "";
            txtCoursework.Text = values[4] != null ? values[4].ToString() : "";
            txtExam.Text = values[5] != null ? values[5].ToString() : "";
            txtTotal.Text = values[6] != null ? values[6].ToString() : "";
            txtGrade.Text = values[7] != null ? values[7].ToString() : "";
            
            pnlEdit.Visible = true;
            pnlEdit.CssClass = "ru-edit-panel show";
        }
    }
    
    protected void btnCancelEdit_Click(object sender, EventArgs e)
    {
        pnlEdit.Visible = false;
        pnlEdit.CssClass = "ru-edit-panel";
        hfResultID.Value = "";
    }
    
    protected void btnSaveUpdate_Click(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hfResultID.Value))
        {
            ShowMessage("No result selected for update.", "error");
            return;
        }
        
        // Validate marks
        decimal camark, exammark;
        if (!decimal.TryParse(txtCoursework.Text, out camark) || !decimal.TryParse(txtExam.Text, out exammark))
        {
            ShowMessage("Please enter valid numeric values for marks.", "error");
            return;
        }
        
        decimal total = camark + exammark;
        string grade = CalculateGrade(total);
        decimal gpa = CalculateGPA(grade);
        string username = HttpContext.Current.User.Identity.Name;
        string reason = txtReason.Text.Trim();
        string remark = ddlRemark.SelectedValue;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                // Log the original values first
                string logSql = @"INSERT INTO acad_results_audit (result_id, field_changed, old_value, new_value, changed_by, change_reason, change_date)
                    SELECT ID, 'MARKS', CONCAT(ca_mark, '/', exam_mark, '/', total_mark), @newvals, @user, @reason, NOW()
                    FROM acad_examresults_faculty WHERE ID = @id";
                
                try
                {
                    using (MySqlCommand logCmd = new MySqlCommand(logSql, conn))
                    {
                        logCmd.Parameters.AddWithValue("@newvals", string.Format("{0}/{1}/{2}", camark, exammark, total));
                        logCmd.Parameters.AddWithValue("@user", username);
                        logCmd.Parameters.AddWithValue("@reason", reason);
                        logCmd.Parameters.AddWithValue("@id", int.Parse(hfResultID.Value));
                        logCmd.ExecuteNonQuery();
                    }
                }
                catch { /* Audit table may not exist */ }
                
                // Update the result
                string updateSql = @"UPDATE acad_examresults_faculty 
                    SET cw_mark = @ca, ex_mark = @exam, total_mark = @total, grade = @grade, gradept = @gpa
                    WHERE ID = @id";
                
                using (MySqlCommand cmd = new MySqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@ca", camark);
                    cmd.Parameters.AddWithValue("@exam", exammark);
                    cmd.Parameters.AddWithValue("@total", total);
                    cmd.Parameters.AddWithValue("@grade", grade);
                    cmd.Parameters.AddWithValue("@gpa", gpa);
                    cmd.Parameters.AddWithValue("@id", int.Parse(hfResultID.Value));
                    cmd.ExecuteNonQuery();
                }
                
                ShowMessage("Result updated successfully.", "success");
                pnlEdit.Visible = false;
                pnlEdit.CssClass = "ru-edit-panel";
                gvResults.Selection.UnselectAll();
                BindGrid();
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error updating result: " + ex.Message, "error");
        }
    }
    
    protected void btnApproveSelected_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResults.GetSelectedFieldValues("ID");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select results to approve.", "warning");
            return;
        }
        
        string username = HttpContext.Current.User.Identity.Name;
        int approved = 0;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object idObj in selectedKeys)
                {
                    int id = Convert.ToInt32(idObj);
                    string sql = @"UPDATE acad_examresults_faculty 
                        SET approved_by = @user
                        WHERE ID = @id AND (approved_by IS NULL OR approved_by = '-' OR approved_by = '')";
                    
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@user", username);
                        cmd.Parameters.AddWithValue("@id", id);
                        approved += cmd.ExecuteNonQuery();
                    }
                }
            }
            
            ShowMessage(string.Format("{0} result(s) approved successfully.", approved), "success");
            gvResults.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error approving results: " + ex.Message, "error");
        }
    }
    
    protected void btnRevertSelected_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvResults.GetSelectedFieldValues("ID");
        if (selectedKeys.Count == 0)
        {
            ShowMessage("Please select results to revert.", "warning");
            return;
        }
        
        int reverted = 0;
        
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object idObj in selectedKeys)
                {
                    int id = Convert.ToInt32(idObj);
                    string sql = @"UPDATE acad_examresults_faculty 
                        SET approved_by = '-'
                        WHERE ID = @id";
                    
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        reverted += cmd.ExecuteNonQuery();
                    }
                }
            }
            
            ShowMessage(string.Format("{0} result(s) reverted to pending.", reverted), "success");
            gvResults.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error reverting results: " + ex.Message, "error");
        }
    }
    
    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        string acadYear = ddlAcadYear.SelectedValue;
        string semester = ddlSemester.SelectedValue;
        string fileName = string.Format("ResultsUpdates_{0}_Sem{1}_{2}", 
            string.IsNullOrEmpty(acadYear) ? "All" : acadYear.Replace("/", "-"), 
            string.IsNullOrEmpty(semester) ? "All" : semester,
            DateTime.Now.ToString("yyyyMMdd"));
        
        gvExporter.WriteXlsToResponse(fileName);
    }
    
    #endregion
    
    #region Helper Methods
    
    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "ru-message show ru-message--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }
    
    private string CalculateGrade(decimal total)
    {
        if (total >= 80) return "A";
        if (total >= 75) return "A-";
        if (total >= 70) return "B+";
        if (total >= 65) return "B";
        if (total >= 60) return "B-";
        if (total >= 55) return "C+";
        if (total >= 50) return "C";
        if (total >= 45) return "C-";
        if (total >= 40) return "D";
        return "E";
    }
    
    private decimal CalculateGPA(string grade)
    {
        switch (grade)
        {
            case "A": return 5.0m;
            case "A-": return 4.5m;
            case "B+": return 4.0m;
            case "B": return 3.5m;
            case "B-": return 3.0m;
            case "C+": return 2.5m;
            case "C": return 2.0m;
            case "C-": return 1.5m;
            case "D": return 1.0m;
            default: return 0.0m;
        }
    }
    
    #endregion
}
