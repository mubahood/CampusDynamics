<%@ Page Language="C#" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Configuration" %>
<!DOCTYPE html>
<html>
<head>
    <title>NCHE Exporter Diagnostics</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 20px; border-radius: 4px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 2px solid #1f4e79; padding-bottom: 10px; }
        .test { margin: 20px 0; padding: 15px; border-left: 4px solid #ccc; background: #f9f9f9; }
        .test.pass { border-left-color: #28a745; background: #f0f8f4; }
        .test.fail { border-left-color: #dc3545; background: #fdf8f8; }
        .pass .status { color: #28a745; font-weight: bold; }
        .fail .status { color: #dc3545; font-weight: bold; }
        .code { background: #f4f4f4; padding: 10px; border-radius: 3px; font-family: monospace; font-size: 12px; margin: 10px 0; }
        pre { overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>NCHE Student Exporter - Diagnostics</h1>
        
        <%
            string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
            int testsPassed = 0;
            int testsFailed = 0;
            
            // Test 1: Database Connection
            Response.Write("<div class='test ");
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    Response.Write("pass'><div class='status'>✓ PASS:</div> Database Connection");
                    Response.Write("<div>Successfully connected to server 102.34.160.47, database: campus_dynamics</div>");
                    testsPassed++;
                }
            }
            catch (Exception ex)
            {
                Response.Write("fail'><div class='status'>✗ FAIL:</div> Database Connection");
                Response.Write("<div>ERROR: " + Server.HtmlEncode(ex.Message) + "</div>");
                testsFailed++;
            }
            Response.Write("</div>");
            
            // Test 2: Student Count
            Response.Write("<div class='test ");
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    string sql = "SELECT COUNT(*) FROM acad_student";
                    MySqlCommand cmd = new MySqlCommand(sql, conn);
                    long count = (long)cmd.ExecuteScalar();
                    
                    Response.Write("pass'><div class='status'>✓ PASS:</div> Student Count");
                    Response.Write("<div>Total students in database: <strong>" + count + "</strong></div>");
                    testsPassed++;
                }
            }
            catch (Exception ex)
            {
                Response.Write("fail'><div class='status'>✗ FAIL:</div> Student Count Query");
                Response.Write("<div>ERROR: " + Server.HtmlEncode(ex.Message) + "</div>");
                testsFailed++;
            }
            Response.Write("</div>");
            
            // Test 3: Programme Count
            Response.Write("<div class='test ");
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    string sql = "SELECT COUNT(*) FROM acad_programme";
                    MySqlCommand cmd = new MySqlCommand(sql, conn);
                    long count = (long)cmd.ExecuteScalar();
                    
                    Response.Write("pass'><div class='status'>✓ PASS:</div> Programme Count");
                    Response.Write("<div>Total programmes in database: <strong>" + count + "</strong></div>");
                    testsPassed++;
                }
            }
            catch (Exception ex)
            {
                Response.Write("fail'><div class='status'>✗ FAIL:</div> Programme Count Query");
                Response.Write("<div>ERROR: " + Server.HtmlEncode(ex.Message) + "</div>");
                testsFailed++;
            }
            Response.Write("</div>");
            
            // Test 4: Campus Count
            Response.Write("<div class='test ");
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    string sql = "SELECT COUNT(*) FROM acad_campuses";
                    MySqlCommand cmd = new MySqlCommand(sql, conn);
                    long count = (long)cmd.ExecuteScalar();
                    
                    Response.Write("pass'><div class='status'>✓ PASS:</div> Campus Count");
                    Response.Write("<div>Total campuses in database: <strong>" + count + "</strong></div>");
                    testsPassed++;
                }
            }
            catch (Exception ex)
            {
                Response.Write("fail'><div class='status'>✗ FAIL:</div> Campus Count Query");
                Response.Write("<div>ERROR: " + Server.HtmlEncode(ex.Message) + "</div>");
                testsFailed++;
            }
            Response.Write("</div>");
            
            // Test 5: NCHE Main Query
            Response.Write("<div class='test ");
            try
            {
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    string sql = @"
                        SELECT 
                            COUNT(*) as row_count,
                            COUNT(DISTINCT s.progid) as prog_count,
                            COUNT(DISTINCT s.studCampus) as campus_count
                        FROM acad_student s
                        LEFT JOIN acad_programme p ON s.progid = p.progcode
                        LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
                    ";
                    MySqlCommand cmd = new MySqlCommand(sql, conn);
                    MySqlDataReader reader = cmd.ExecuteReader();
                    
                    if (reader.Read())
                    {
                        int rows = reader.GetInt32(0);
                        int progs = reader.GetInt32(1);
                        int camps = reader.GetInt32(2);
                        
                        Response.Write("pass'><div class='status'>✓ PASS:</div> NCHE Main Query");
                        Response.Write("<div>");
                        Response.Write("Total rows to export: <strong>" + rows + "</strong><br/>");
                        Response.Write("Programmes found: <strong>" + progs + "</strong><br/>");
                        Response.Write("Campuses found: <strong>" + camps + "</strong><br/>");
                        Response.Write("</div>");
                        testsPassed++;
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("fail'><div class='status'>✗ FAIL:</div> NCHE Main Query");
                Response.Write("<div>ERROR: " + Server.HtmlEncode(ex.Message) + "</div>");
                testsFailed++;
            }
            Response.Write("</div>");
            
            // Test 6: Sample Records
            Response.Write("<div class='test ");
            try
            {
                DataTable dt = new DataTable();
                using (MySqlConnection conn = new MySqlConnection(connStr))
                {
                    conn.Open();
                    string sql = @"
                        SELECT 
                            '' as sn,
                            CONCAT(COALESCE(s.firstname, ''), ' ', COALESCE(s.othername, '')) as names,
                            s.gender,
                            s.nationality,
                            s.regno as reg_no,
                            p.progcode,
                            p.progname,
                            'Degree' as award_level,
                            COALESCE(s.intake, '1') as year_study,
                            COALESCE(c.campus_name, s.studCampus) as study_centre
                        FROM acad_student s
                        LEFT JOIN acad_programme p ON s.progid = p.progcode
                        LEFT JOIN acad_campuses c ON s.studCampus = c.campus_code
                        LIMIT 5
                    ";
                    MySqlCommand cmd = new MySqlCommand(sql, conn);
                    MySqlDataAdapter adapter = new MySqlDataAdapter(cmd);
                    adapter.Fill(dt);
                }
                
                if (dt.Rows.Count > 0)
                {
                    Response.Write("pass'><div class='status'>✓ PASS:</div> Sample Records (First 5)");
                    Response.Write("<div><table border='1' cellpadding='5' style='width: 100%; border-collapse: collapse;'>");
                    Response.Write("<tr style='background: #f0f0f0;'>");
                    foreach (DataColumn col in dt.Columns)
                    {
                        Response.Write("<th>" + col.ColumnName + "</th>");
                    }
                    Response.Write("</tr>");
                    
                    int rowNum = 1;
                    foreach (DataRow row in dt.Rows)
                    {
                        Response.Write("<tr>");
                        foreach (DataColumn col in dt.Columns)
                        {
                            if (col.ColumnName == "sn")
                                Response.Write("<td>" + (rowNum++) + "</td>");
                            else
                                Response.Write("<td>" + Server.HtmlEncode(row[col].ToString()) + "</td>");
                        }
                        Response.Write("</tr>");
                    }
                    Response.Write("</table></div>");
                    testsPassed++;
                }
                else
                {
                    Response.Write("fail'><div class='status'>✗ FAIL:</div> Sample Records");
                    Response.Write("<div>Query returned 0 rows</div>");
                    testsFailed++;
                }
            }
            catch (Exception ex)
            {
                Response.Write("fail'><div class='status'>✗ FAIL:</div> Sample Records Query");
                Response.Write("<div>ERROR: " + Server.HtmlEncode(ex.Message) + "</div>");
                testsFailed++;
            }
            Response.Write("</div>");
            
            // Summary
            Response.Write("<div class='test' style='margin-top: 30px; border: 2px solid #1f4e79;'>");
            Response.Write("<h2>Summary</h2>");
            Response.Write("<div>Tests Passed: <strong style='color: #28a745;'>" + testsPassed + "</strong></div>");
            Response.Write("<div>Tests Failed: <strong style='color: #dc3545;'>" + testsFailed + "</strong></div>");
            
            if (testsFailed == 0)
            {
                Response.Write("<div style='margin-top: 15px; padding: 10px; background: #f0f8f4; border: 1px solid #28a745; border-radius: 3px;'>");
                Response.Write("<strong style='color: #28a745;'>✓ All diagnostics passed!</strong><br/>");
                Response.Write("Your NCHE Student Exporter should work. Try clicking Preview in the exporter page.");
                Response.Write("</div>");
            }
            else
            {
                Response.Write("<div style='margin-top: 15px; padding: 10px; background: #fdf8f8; border: 1px solid #dc3545; border-radius: 3px;'>");
                Response.Write("<strong style='color: #dc3545;'>✗ Some tests failed!</strong><br/>");
                Response.Write("Please check the errors above and contact support if needed.");
                Response.Write("</div>");
            }
            Response.Write("</div>");
        %>
    </div>
</body>
</html>
