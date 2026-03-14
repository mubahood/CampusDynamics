<%@ Page Language="C#" %>
<%@ Import Namespace="MySql.Data.MySqlClient" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Configuration" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test NCHE Query</title>
</head>
<body>
    <h1>NCHE Query Test</h1>
    <pre>
<%
    string connStr = "server=102.34.160.47;User Id=dbmanager;password=24thdecember1977;Persist Security Info=True;database=campus_dynamics";
    
    try
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            conn.Open();
            Response.Write("✓ Connected to database<br/>");
            
            // Test 1: Total students
            string sql1 = "SELECT COUNT(*) FROM acad_student";
            using (MySqlCommand cmd = new MySqlCommand(sql1, conn))
            {
                int total = (int)cmd.ExecuteScalar();
                Response.Write(string.Format("✓ Total Students: {0}<br/>", total));
            }
            
            // Test 2: Programme count
            string sql2 = "SELECT COUNT(*) FROM acad_programme";
            using (MySqlCommand cmd = new MySqlCommand(sql2, conn))
            {
                int total = (int)cmd.ExecuteScalar();
                Response.Write(string.Format("✓ Total Programmes: {0}<br/>", total));
            }
            
            // Test 3: Sample NCHE query (first 5 rows)
            string sql3 = @"
                SELECT 
                    ROW_NUMBER() OVER (ORDER BY s.regno) as sn,
                    CONCAT(s.firstname, ' ', s.othername) as names,
                    s.gender,
                    s.nationality as national_id,
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
            
            DataTable dt = new DataTable();
            using (MySqlCommand cmd = new MySqlCommand(sql3, conn))
            {
                using (MySqlDataAdapter adapter = new MySqlDataAdapter(cmd))
                {
                    adapter.Fill(dt);
                }
            }
            
            Response.Write(string.Format("✓ NCHE Query returned {0} sample rows<br/><br/>", dt.Rows.Count));
            
            if (dt.Rows.Count > 0)
            {
                Response.Write("Sample Data:<br/>");
                foreach (DataRow row in dt.Rows)
                {
                    Response.Write(string.Format("{0}. {1} ({2}) - {3} - {4}<br/>", 
                        row["sn"], row["names"], row["gender"], row["progcode"], row["study_centre"]));
                }
            }
        }
    }
    catch (Exception ex)
    {
        Response.Write("✗ ERROR: " + ex.Message + "<br/>" + ex.StackTrace);
    }
%>
    </pre>
</body>
</html>
