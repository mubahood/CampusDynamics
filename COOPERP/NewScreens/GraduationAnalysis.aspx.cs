using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Configuration;
using System.IO;
using System.Text;

public partial class COOPERP_NewScreens_GraduationAnalysis : System.Web.UI.Page
{
    private string connectionString = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFilters();
            LoadAnalysisData();
        }
    }

    protected void LoadFilters()
    {
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

            // Convocations (from graduands table)
            string sqlConv = "SELECT DISTINCT convocation FROM acad_graduands WHERE convocation IS NOT NULL ORDER BY convocation DESC";
            using (MySqlCommand cmd = new MySqlCommand(sqlConv, conn))
            {
                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    ddlConvocation.Items.Clear();
                    ddlConvocation.Items.Add(new ListItem("-- All --", ""));
                    while (dr.Read())
                    {
                        string conv = dr["convocation"].ToString();
                        ddlConvocation.Items.Add(new ListItem(conv, conv));
                    }
                }
            }

            // Set default convocation if available
            if (ddlConvocation.Items.Count > 1)
            {
                ddlConvocation.SelectedIndex = 1;
                litConvocationDisplay.Text = ddlConvocation.SelectedValue;
            }
            else
            {
                litConvocationDisplay.Text = "All";
            }
        }
    }

    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadProgrammes();
        LoadAnalysisData();
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
        LoadAnalysisData();
    }

    protected void ddlConvocation_SelectedIndexChanged(object sender, EventArgs e)
    {
        litConvocationDisplay.Text = string.IsNullOrEmpty(ddlConvocation.SelectedValue) ? "All" : ddlConvocation.SelectedValue;
        LoadAnalysisData();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadAnalysisData();
    }

    protected void LoadAnalysisData()
    {
        LoadFacultySummary();
        LoadProgrammeSummary();
        LoadClassSummary();
        LoadDetailedList();
        UpdateOverallStats();
    }

    private string GetWhereClause(string tableAlias = "g")
    {
        StringBuilder where = new StringBuilder("WHERE 1=1");
        
        if (!string.IsNullOrEmpty(ddlConvocation.SelectedValue))
        {
            where.AppendFormat(" AND {0}.convocation = @conv", tableAlias);
        }
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            where.AppendFormat(" AND {0}.progcode = @prog", tableAlias);
        }
        
        return where.ToString();
    }

    private void AddWhereParameters(MySqlCommand cmd)
    {
        if (!string.IsNullOrEmpty(ddlConvocation.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@conv", ddlConvocation.SelectedValue);
        }
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            cmd.Parameters.AddWithValue("@prog", ddlProgramme.SelectedValue);
        }
    }

    protected void LoadFacultySummary()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();
            
            string whereClause = GetWhereClause();
            string facultyFilter = "";
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                facultyFilter = " AND p.faculty_code = @fac";
            }

            string sql = string.Format(@"
                SELECT 
                    IFNULL(f.faculty_name, 'Unknown') AS faculty,
                    SUM(CASE WHEN s.gender IN ('M', 'Male') THEN 1 ELSE 0 END) AS male_count,
                    SUM(CASE WHEN s.gender IN ('F', 'Female') THEN 1 ELSE 0 END) AS female_count,
                    COUNT(*) AS total
                FROM acad_graduands g
                LEFT JOIN acad_student s ON g.regno = s.regno
                LEFT JOIN acad_programme p ON g.progcode = p.progcode
                LEFT JOIN acad_faculty f ON p.faculty_code = f.faculty_code
                {0} {1}
                GROUP BY f.faculty_name
                ORDER BY f.faculty_name", whereClause, facultyFilter);

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddWhereParameters(cmd);
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                {
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                }

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Add totals row
                    if (dt.Rows.Count > 0)
                    {
                        int totalMale = 0, totalFemale = 0, grandTotal = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            totalMale += Convert.ToInt32(row["male_count"]);
                            totalFemale += Convert.ToInt32(row["female_count"]);
                            grandTotal += Convert.ToInt32(row["total"]);
                        }

                        DataRow totalRow = dt.NewRow();
                        totalRow["faculty"] = "TOTAL";
                        totalRow["male_count"] = totalMale;
                        totalRow["female_count"] = totalFemale;
                        totalRow["total"] = grandTotal;
                        dt.Rows.Add(totalRow);
                    }

                    gvFacultySummary.DataSource = dt;
                    gvFacultySummary.DataBind();
                }
            }
        }
    }

    protected void LoadProgrammeSummary()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            string whereClause = GetWhereClause();
            string facultyFilter = "";
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                facultyFilter = " AND p.faculty_code = @fac";
            }

            string sql = string.Format(@"
                SELECT 
                    IFNULL(p.progname, g.progcode) AS prog_name,
                    SUM(CASE WHEN s.gender IN ('M', 'Male') THEN 1 ELSE 0 END) AS male_count,
                    SUM(CASE WHEN s.gender IN ('F', 'Female') THEN 1 ELSE 0 END) AS female_count,
                    COUNT(*) AS total
                FROM acad_graduands g
                LEFT JOIN acad_student s ON g.regno = s.regno
                LEFT JOIN acad_programme p ON g.progcode = p.progcode
                {0} {1}
                GROUP BY p.progname, g.progcode
                ORDER BY p.progname", whereClause, facultyFilter);

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddWhereParameters(cmd);
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                {
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                }

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Add totals row
                    if (dt.Rows.Count > 0)
                    {
                        int totalMale = 0, totalFemale = 0, grandTotal = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            totalMale += Convert.ToInt32(row["male_count"]);
                            totalFemale += Convert.ToInt32(row["female_count"]);
                            grandTotal += Convert.ToInt32(row["total"]);
                        }

                        DataRow totalRow = dt.NewRow();
                        totalRow["prog_name"] = "TOTAL";
                        totalRow["male_count"] = totalMale;
                        totalRow["female_count"] = totalFemale;
                        totalRow["total"] = grandTotal;
                        dt.Rows.Add(totalRow);
                    }

                    gvProgrammeSummary.DataSource = dt;
                    gvProgrammeSummary.DataBind();
                }
            }
        }
    }

    protected void LoadClassSummary()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            string whereClause = GetWhereClause();
            string facultyFilter = "";
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                facultyFilter = " AND p.faculty_code = @fac";
            }

            // First get total count
            string countSql = string.Format(@"
                SELECT COUNT(*) FROM acad_graduands g
                LEFT JOIN acad_programme p ON g.progcode = p.progcode
                {0} {1}", whereClause, facultyFilter);

            int totalGraduands = 0;
            using (MySqlCommand countCmd = new MySqlCommand(countSql, conn))
            {
                AddWhereParameters(countCmd);
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                {
                    countCmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                }
                totalGraduands = Convert.ToInt32(countCmd.ExecuteScalar());
            }

            string sql = string.Format(@"
                SELECT 
                    IFNULL(g.degclass, 'Unclassified') AS degclass,
                    SUM(CASE WHEN s.gender IN ('M', 'Male') THEN 1 ELSE 0 END) AS male_count,
                    SUM(CASE WHEN s.gender IN ('F', 'Female') THEN 1 ELSE 0 END) AS female_count,
                    COUNT(*) AS total
                FROM acad_graduands g
                LEFT JOIN acad_student s ON g.regno = s.regno
                LEFT JOIN acad_programme p ON g.progcode = p.progcode
                {0} {1}
                GROUP BY g.degclass
                ORDER BY 
                    CASE g.degclass 
                        WHEN 'First Class' THEN 1
                        WHEN 'Second Class Upper' THEN 2
                        WHEN 'Second Class Lower' THEN 3
                        WHEN 'Pass' THEN 4
                        ELSE 5
                    END", whereClause, facultyFilter);

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddWhereParameters(cmd);
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                {
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                }

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Add percentage column
                    dt.Columns.Add("percentage", typeof(decimal));
                    foreach (DataRow row in dt.Rows)
                    {
                        int classTotal = Convert.ToInt32(row["total"]);
                        row["percentage"] = totalGraduands > 0 ? (decimal)classTotal * 100 / totalGraduands : 0;
                    }

                    // Add totals row
                    if (dt.Rows.Count > 0)
                    {
                        int totalMale = 0, totalFemale = 0, grandTotal = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            totalMale += Convert.ToInt32(row["male_count"]);
                            totalFemale += Convert.ToInt32(row["female_count"]);
                            grandTotal += Convert.ToInt32(row["total"]);
                        }

                        DataRow totalRow = dt.NewRow();
                        totalRow["degclass"] = "TOTAL";
                        totalRow["male_count"] = totalMale;
                        totalRow["female_count"] = totalFemale;
                        totalRow["total"] = grandTotal;
                        totalRow["percentage"] = 100m;
                        dt.Rows.Add(totalRow);
                    }

                    gvClassSummary.DataSource = dt;
                    gvClassSummary.DataBind();
                }
            }
        }
    }

    protected void LoadDetailedList()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            string whereClause = GetWhereClause();
            string facultyFilter = "";
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                facultyFilter = " AND p.faculty_code = @fac";
            }

            string sql = string.Format(@"
                SELECT 
                    g.regno,
                    g.stud_name,
                    IFNULL(p.progname, g.progcode) AS prog_name,
                    g.cgpa,
                    g.degclass,
                    IFNULL(s.gender, '') AS gen,
                    g.grad_date,
                    g.convocation
                FROM acad_graduands g
                LEFT JOIN acad_student s ON g.regno = s.regno
                LEFT JOIN acad_programme p ON g.progcode = p.progcode
                {0} {1}
                ORDER BY g.stud_name", whereClause, facultyFilter);

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddWhereParameters(cmd);
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                {
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                }

                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvGraduandsDetail.DataSource = dt;
                    gvGraduandsDetail.DataBind();
                }
            }
        }
    }

    protected void UpdateOverallStats()
    {
        using (MySqlConnection conn = new MySqlConnection(connectionString))
        {
            conn.Open();

            string whereClause = GetWhereClause();
            string facultyFilter = "";
            if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
            {
                facultyFilter = " AND p.faculty_code = @fac";
            }

            string sql = string.Format(@"
                SELECT 
                    COUNT(*) AS total,
                    SUM(CASE WHEN s.gender IN ('M', 'Male') THEN 1 ELSE 0 END) AS male_count,
                    SUM(CASE WHEN s.gender IN ('F', 'Female') THEN 1 ELSE 0 END) AS female_count
                FROM acad_graduands g
                LEFT JOIN acad_student s ON g.regno = s.regno
                LEFT JOIN acad_programme p ON g.progcode = p.progcode
                {0} {1}", whereClause, facultyFilter);

            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddWhereParameters(cmd);
                if (!string.IsNullOrEmpty(ddlFaculty.SelectedValue))
                {
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                }

                using (MySqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        litTotalGraduands.Text = dr["total"].ToString();
                        litMaleCount.Text = dr["male_count"].ToString();
                        litFemaleCount.Text = dr["female_count"].ToString();
                    }
                }
            }
        }
    }

    protected void btnExportFacultyExcel_Click(object sender, EventArgs e)
    {
        ExportToExcel(gvFacultySummary, "GraduationAnalysis_Faculty");
    }

    protected void btnExportProgExcel_Click(object sender, EventArgs e)
    {
        ExportToExcel(gvProgrammeSummary, "GraduationAnalysis_Programme");
    }

    protected void btnExportClassExcel_Click(object sender, EventArgs e)
    {
        ExportToExcel(gvClassSummary, "GraduationAnalysis_Class");
    }

    protected void btnExportDetailExcel_Click(object sender, EventArgs e)
    {
        gvExporter.WriteXlsxToResponse("GraduationAnalysis_Detail_" + DateTime.Now.ToString("yyyyMMdd"));
    }

    protected void btnExportFullPDF_Click(object sender, EventArgs e)
    {
        // For now, redirect to a print-friendly view or export to PDF
        // This can be enhanced with a PDF library like iTextSharp
        ScriptManager.RegisterStartupScript(this, GetType(), "print", "window.print();", true);
    }

    private void ExportToExcel(GridView gv, string fileName)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.AddHeader("content-disposition", string.Format("attachment;filename={0}_{1}.xls", fileName, DateTime.Now.ToString("yyyyMMdd")));
        Response.Charset = "";
        Response.ContentType = "application/vnd.ms-excel";

        using (StringWriter sw = new StringWriter())
        {
            using (System.Web.UI.HtmlTextWriter hw = new System.Web.UI.HtmlTextWriter(sw))
            {
                gv.AllowPaging = false;
                gv.DataBind();

                // Style for export
                gv.HeaderRow.Style.Add("background-color", "#CCCCCC");
                gv.HeaderRow.Style.Add("font-weight", "bold");

                foreach (TableCell cell in gv.HeaderRow.Cells)
                {
                    cell.Style.Add("background-color", "#CCCCCC");
                }

                foreach (GridViewRow row in gv.Rows)
                {
                    row.BackColor = System.Drawing.Color.White;
                    foreach (TableCell cell in row.Cells)
                    {
                        cell.Style.Add("mso-number-format", "@");
                    }
                }

                gv.RenderControl(hw);
                Response.Output.Write(sw.ToString());
                Response.Flush();
                Response.End();
            }
        }
    }

    public override void VerifyRenderingInServerForm(Control control)
    {
        // Required for exporting GridView
    }
}
