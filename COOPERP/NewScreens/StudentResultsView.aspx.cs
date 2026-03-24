using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using DevExpress.Web;

public partial class COOPERP_NewScreens_StudentResultsView : System.Web.UI.Page
{
    private string connStr = ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString;
    private string currentRegNo = "";
    private string currentSemester = "";
    private string currentAcadYear = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        // Security check
        if (Session["UserID"] == null)
        {
            Response.Redirect("~/Default.aspx");
            return;
        }

        if (!IsPostBack)
        {
            // Check if regno passed in query string
            if (!string.IsNullOrEmpty(Request.QueryString["regno"]))
            {
                txtSearch.Text = Request.QueryString["regno"];
                LoadStudentProfile(Request.QueryString["regno"]);
            }
        }
    }

    #region Search Methods

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string searchTerm = txtSearch.Text.Trim();
        
        if (string.IsNullOrEmpty(searchTerm))
        {
            return;
        }

        // Check if it's an exact registration number match
        if (IsExactMatch(searchTerm))
        {
            LoadStudentProfile(searchTerm);
        }
        else
        {
            // Show search results
            SearchStudents(searchTerm);
        }
    }

    private bool IsExactMatch(string searchTerm)
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = "SELECT COUNT(*) FROM acad_student WHERE regno = @Search OR idno = @Search";
            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@Search", searchTerm);
            
            conn.Open();
            int count = Convert.ToInt32(cmd.ExecuteScalar());
            return count == 1;
        }
    }

    private void SearchStudents(string searchTerm)
    {
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT 
                s.regno,
                CONCAT(s.firstname, ' ', s.lastname) AS fullname,
                p.progname,
                s.yearofstudy,
                s.status
                FROM acad_student s
                LEFT JOIN acad_programme p ON p.progcode = s.programme
                WHERE s.regno LIKE @Search 
                   OR s.idno LIKE @Search
                   OR CONCAT(s.firstname, ' ', s.lastname) LIKE @Search
                   OR s.firstname LIKE @Search
                   OR s.lastname LIKE @Search
                LIMIT 20";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@Search", "%" + searchTerm + "%");
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            if (dt.Rows.Count == 0)
            {
                pnlNoStudent.Visible = true;
                pnlStudent.Visible = false;
                pnlSearchResults.Visible = false;
            }
            else if (dt.Rows.Count == 1)
            {
                LoadStudentProfile(dt.Rows[0]["regno"].ToString());
            }
            else
            {
                gvSearchResults.DataSource = dt;
                gvSearchResults.DataBind();
                
                pnlNoStudent.Visible = false;
                pnlStudent.Visible = false;
                pnlSearchResults.Visible = true;
            }
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        pnlNoStudent.Visible = true;
        pnlStudent.Visible = false;
        pnlSearchResults.Visible = false;
    }

    protected void gvSearchResults_RowCommand(object sender, ASPxGridViewRowCommandEventArgs e)
    {
        if (e.CommandArgs.CommandName == "ViewStudent")
        {
            string regno = e.CommandArgs.CommandArgument.ToString();
            LoadStudentProfile(regno);
        }
    }

    #endregion

    #region Student Profile

    private void LoadStudentProfile(string regno)
    {
        currentRegNo = regno;
        ViewState["CurrentRegNo"] = regno;
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT 
                s.regno,
                CONCAT(s.firstname, ' ', s.lastname) AS fullname,
                s.programme,
                p.progname,
                f.facname,
                s.yearofstudy,
                s.enrolldate,
                s.status,
                s.photo
                FROM acad_student s
                LEFT JOIN acad_programme p ON p.progcode = s.programme
                LEFT JOIN acad_faculty f ON f.faccode = p.faculty
                WHERE s.regno = @RegNo OR s.idno = @RegNo";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@RegNo", regno);
            
            conn.Open();
            MySqlDataReader reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                currentRegNo = reader["regno"].ToString();
                ViewState["CurrentRegNo"] = currentRegNo;
                
                litStudentName.Text = reader["fullname"].ToString();
                litRegNo.Text = reader["regno"].ToString();
                litProgramme.Text = reader["progname"] != DBNull.Value ? reader["progname"].ToString() : "-";
                litFaculty.Text = reader["facname"] != DBNull.Value ? reader["facname"].ToString() : "-";
                litYear.Text = reader["yearofstudy"] != DBNull.Value ? "Year " + reader["yearofstudy"].ToString() : "-";
                litEnrollDate.Text = reader["enrolldate"] != DBNull.Value ? Convert.ToDateTime(reader["enrolldate"]).ToString("dd MMM yyyy") : "-";
                litStatus.Text = reader["status"] != DBNull.Value ? reader["status"].ToString() : "-";
                
                // Photo
                if (reader["photo"] != DBNull.Value && !string.IsNullOrEmpty(reader["photo"].ToString()))
                {
                    imgStudent.ImageUrl = "~/patientimages/" + reader["photo"].ToString();
                }
                else
                {
                    imgStudent.ImageUrl = "~/images/default-avatar.png";
                }
                
                reader.Close();
                
                // Load academic years and results
                LoadAcademicYears();
                LoadCumulativeStats();
                LoadSemesters();
                LoadResults();
                
                pnlNoStudent.Visible = false;
                pnlStudent.Visible = true;
                pnlSearchResults.Visible = false;
            }
            else
            {
                pnlNoStudent.Visible = true;
                pnlStudent.Visible = false;
                pnlSearchResults.Visible = false;
            }
        }
    }

    private void LoadAcademicYears()
    {
        string regno = ViewState["CurrentRegNo"] == null ? "" : ViewState["CurrentRegNo"].ToString();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT DISTINCT acad_year FROM acad_examresults_faculty 
                            WHERE reg_no = @RegNo ORDER BY acad_year DESC";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@RegNo", regno);
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            ddlAcadYear.Items.Clear();
            ddlAcadYear.Items.Add(new ListItem("All Years", ""));
            
            foreach (DataRow row in dt.Rows)
            {
                ddlAcadYear.Items.Add(new ListItem(row["acad_year"].ToString(), row["acad_year"].ToString()));
            }
            
            if (ddlAcadYear.Items.Count > 1)
                ddlAcadYear.SelectedIndex = 1;
            
            currentAcadYear = ddlAcadYear.SelectedValue;
            ViewState["CurrentAcadYear"] = currentAcadYear;
        }
    }

    private void LoadCumulativeStats()
    {
        string regno = ViewState["CurrentRegNo"] == null ? "" : ViewState["CurrentRegNo"].ToString();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            // Calculate CGPA and total credits
            string query = @"SELECT 
                AVG(er.finalmark) AS avg_mark,
                SUM(CASE WHEN er.finalmark >= 50 THEN c.credit_hrs ELSE 0 END) AS credits_earned
                FROM acad_examresults_faculty er
                LEFT JOIN acad_course c ON c.courseid = er.course_id
                WHERE er.reg_no = @RegNo AND er.approved_by != '-' AND er.approved_by != 'HELD'";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@RegNo", regno);
            
            conn.Open();
            MySqlDataReader reader = cmd.ExecuteReader();
            
            if (reader.Read())
            {
                double avgMark = reader["avg_mark"] != DBNull.Value ? Convert.ToDouble(reader["avg_mark"]) : 0;
                int credits = reader["credits_earned"] != DBNull.Value ? Convert.ToInt32(reader["credits_earned"]) : 0;
                
                // Convert to GPA (assuming 4.0 scale)
                double gpa = ConvertToGPA(avgMark);
                
                litCGPA.Text = gpa.ToString("F2");
                litCredits.Text = credits.ToString();
            }
        }
    }

    private double ConvertToGPA(double mark)
    {
        // Standard conversion: A (75-100) = 4.0, B (65-74) = 3.0, C (55-64) = 2.0, D (50-54) = 1.0, F (<50) = 0
        if (mark >= 75) return 4.0;
        if (mark >= 70) return 3.5;
        if (mark >= 65) return 3.0;
        if (mark >= 60) return 2.5;
        if (mark >= 55) return 2.0;
        if (mark >= 50) return 1.5;
        return 0.0;
    }

    private void LoadSemesters()
    {
        string regno = ViewState["CurrentRegNo"] == null ? "" : ViewState["CurrentRegNo"].ToString();
        string acadYear = ViewState["CurrentAcadYear"] == null ? "" : ViewState["CurrentAcadYear"].ToString();
        string currentSem = ViewState["CurrentSemester"] == null ? "" : ViewState["CurrentSemester"].ToString();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT DISTINCT semester FROM acad_examresults_faculty 
                            WHERE reg_no = @RegNo";
            
            if (!string.IsNullOrEmpty(acadYear))
            {
                query += " AND acad_year = @AcadYear";
            }
            
            query += " ORDER BY semester";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@RegNo", regno);
            if (!string.IsNullOrEmpty(acadYear))
            {
                cmd.Parameters.AddWithValue("@AcadYear", acadYear);
            }
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            // Create semester tabs data
            DataTable tabs = new DataTable();
            tabs.Columns.Add("semester", typeof(string));
            tabs.Columns.Add("label", typeof(string));
            tabs.Columns.Add("is_active", typeof(string));

            // Add "All" tab
            DataRow allRow = tabs.NewRow();
            allRow["semester"] = "";
            allRow["label"] = "All Semesters";
            allRow["is_active"] = string.IsNullOrEmpty(currentSem) ? "1" : "0";
            tabs.Rows.Add(allRow);

            foreach (DataRow row in dt.Rows)
            {
                DataRow tabRow = tabs.NewRow();
                tabRow["semester"] = row["semester"].ToString();
                tabRow["label"] = "Semester " + row["semester"].ToString();
                tabRow["is_active"] = currentSem == row["semester"].ToString() ? "1" : "0";
                tabs.Rows.Add(tabRow);
            }

            rptSemesters.DataSource = tabs;
            rptSemesters.DataBind();
        }
    }

    protected void rptSemesters_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName == "SelectSemester")
        {
            currentSemester = e.CommandArgument.ToString();
            ViewState["CurrentSemester"] = currentSemester;
            LoadSemesters();
            LoadResults();
        }
    }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        currentAcadYear = ddlAcadYear.SelectedValue;
        ViewState["CurrentAcadYear"] = currentAcadYear;
        ViewState["CurrentSemester"] = "";
        LoadSemesters();
        LoadResults();
    }

    #endregion

    #region Results Loading

    private void LoadResults()
    {
        string regno = ViewState["CurrentRegNo"] == null ? "" : ViewState["CurrentRegNo"].ToString();
        string acadYear = ViewState["CurrentAcadYear"] == null ? "" : ViewState["CurrentAcadYear"].ToString();
        string semester = ViewState["CurrentSemester"] == null ? "" : ViewState["CurrentSemester"].ToString();
        
        using (MySqlConnection conn = new MySqlConnection(connStr))
        {
            string query = @"SELECT 
                er.id,
                er.course_id,
                c.coursename AS course_name,
                c.credit_hrs AS credit_hours,
                er.ca_mark,
                er.exam_mark,
                er.finalmark,
                CASE 
                    WHEN er.finalmark >= 75 THEN 'A'
                    WHEN er.finalmark >= 65 THEN 'B'
                    WHEN er.finalmark >= 55 THEN 'C'
                    WHEN er.finalmark >= 50 THEN 'D'
                    ELSE 'F'
                END AS grade,
                er.approved_by
                FROM acad_examresults_faculty er
                LEFT JOIN acad_course c ON c.courseid = er.course_id
                WHERE er.reg_no = @RegNo";

            if (!string.IsNullOrEmpty(acadYear))
            {
                query += " AND er.acad_year = @AcadYear";
            }

            if (!string.IsNullOrEmpty(semester))
            {
                query += " AND er.semester = @Semester";
            }

            query += " ORDER BY c.coursename";

            MySqlCommand cmd = new MySqlCommand(query, conn);
            cmd.Parameters.AddWithValue("@RegNo", regno);
            
            if (!string.IsNullOrEmpty(acadYear))
            {
                cmd.Parameters.AddWithValue("@AcadYear", acadYear);
            }
            
            if (!string.IsNullOrEmpty(semester))
            {
                cmd.Parameters.AddWithValue("@Semester", semester);
            }
            
            MySqlDataAdapter da = new MySqlDataAdapter(cmd);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvResults.DataSource = dt;
            gvResults.DataBind();

            // Calculate semester stats
            CalculateSemesterStats(dt);
        }
    }

    private void CalculateSemesterStats(DataTable results)
    {
        int totalCredits = 0;
        int passedCourses = 0;
        int failedCourses = 0;
        double totalPoints = 0;

        foreach (DataRow row in results.Rows)
        {
            int credits = row["credit_hours"] != DBNull.Value ? Convert.ToInt32(row["credit_hours"]) : 0;
            double mark = row["finalmark"] != DBNull.Value ? Convert.ToDouble(row["finalmark"]) : 0;
            string approvedBy = row["approved_by"] == null || row["approved_by"] == DBNull.Value ? "-" : row["approved_by"].ToString();

            // Only count released results
            if (approvedBy != "-" && approvedBy != "HELD")
            {
                totalCredits += credits;
                
                if (mark >= 50)
                {
                    passedCourses++;
                    totalPoints += ConvertToGPA(mark) * credits;
                }
                else
                {
                    failedCourses++;
                }
            }
        }

        litSemCredits.Text = totalCredits.ToString();
        litPassedCourses.Text = passedCourses.ToString();
        litFailedCourses.Text = failedCourses.ToString();
        
        double semGPA = totalCredits > 0 ? totalPoints / totalCredits : 0;
        litSemGPA.Text = semGPA.ToString("F2");
    }

    #endregion

    #region Helper Methods

    protected string GetMarkClass(object mark)
    {
        if (mark == null || mark == DBNull.Value) return "srv-mark-bar__fill--low";
        
        double m = Convert.ToDouble(mark);
        if (m >= 65) return "srv-mark-bar__fill--high";
        if (m >= 50) return "srv-mark-bar__fill--medium";
        return "srv-mark-bar__fill--low";
    }

    protected string GetGradeClass(object grade)
    {
        if (grade == null || grade == DBNull.Value) return "srv-grade--f";
        
        string g = grade.ToString().ToUpper();
        switch (g)
        {
            case "A": return "srv-grade--a";
            case "B": return "srv-grade--b";
            case "C": return "srv-grade--c";
            case "D": return "srv-grade--d";
            default: return "srv-grade--f";
        }
    }

    protected string GetStatusBadge(object approvedBy)
    {
        if (approvedBy == null || approvedBy == DBNull.Value) 
            return "<span class='srv-status srv-status--pending'>⏳ Pending</span>";
        
        string status = approvedBy.ToString();
        
        if (status == "-")
            return "<span class='srv-status srv-status--pending'>⏳ Pending</span>";
        else if (status == "HELD")
            return "<span class='srv-status srv-status--held'>⛔ Held</span>";
        else
            return "<span class='srv-status srv-status--released'>✓ Released</span>";
    }

    #endregion

    #region Export & Print

    protected void btnExport_Click(object sender, EventArgs e)
    {
        string regno = ViewState["CurrentRegNo"] == null ? "student" : ViewState["CurrentRegNo"].ToString();
        gvExporter.WriteXlsxToResponse("Results_" + regno + "_" + DateTime.Now.ToString("yyyyMMdd"));
    }

    protected void btnPrintTranscript_Click(object sender, EventArgs e)
    {
        string regno = ViewState["CurrentRegNo"] == null ? "" : ViewState["CurrentRegNo"].ToString();
        // Redirect to transcript report page
        Response.Redirect("~/COOPERP/XtraReports/StudentTranscript.aspx?regno=" + regno);
    }

    #endregion
}
