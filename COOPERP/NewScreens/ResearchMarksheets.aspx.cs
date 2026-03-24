using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using DevExpress.Web;
using MySql.Data.MySqlClient;
using System.Configuration;

public partial class COOPERP_NewScreens_ResearchMarksheets : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadFaculties();
            LoadAcademicYears();
            LoadCampuses();
            LoadStats();
            BindGrid();
        }
    }

    #region Data Loading

    private void LoadFaculties()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string query = "SELECT DISTINCT fax_code, faculty_name FROM acad_faculty ORDER BY faculty_name";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        ddlFaculty.Items.Clear();
                        ddlFaculty.Items.Add(new ListItem("-- All Faculties --", ""));
                        while (reader.Read())
                        {
                            ddlFaculty.Items.Add(new ListItem(reader["faculty_name"].ToString(), reader["fax_code"].ToString()));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading faculties: " + ex.Message, "error");
        }
    }

    private void LoadAcademicYears()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string query = "SELECT DISTINCT acad_year FROM academic_calendar ORDER BY acad_year DESC";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        ddlAcadYear.Items.Clear();
                        while (reader.Read())
                        {
                            ddlAcadYear.Items.Add(new ListItem(reader["acad_year"].ToString(), reader["acad_year"].ToString()));
                        }
                    }
                }
            }

            // Set current academic year
            string currentAcadYear = AcademicYearHelper.GetCurrentAcademicYear();
            if (!string.IsNullOrEmpty(currentAcadYear) && ddlAcadYear.Items.FindByValue(currentAcadYear) != null)
            {
                ddlAcadYear.SelectedValue = currentAcadYear;
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading academic years: " + ex.Message, "error");
        }
    }

    private void LoadCampuses()
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string query = "SELECT ID, campus_name FROM acad_campuses ORDER BY campus_name";
                using (MySqlCommand cmd = new MySqlCommand(query, conn))
                {
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        ddlCampus.Items.Clear();
                        ddlCampus.Items.Add(new ListItem("-- All Campuses --", "0"));
                        while (reader.Read())
                        {
                            ddlCampus.Items.Add(new ListItem(reader["campus_name"].ToString(), reader["ID"].ToString()));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading campuses: " + ex.Message, "error");
        }
    }

    // Academic year logic centralised in AcademicYearHelper

    private void LoadStats()
    {
        try
        {
            string acadYear = ddlAcadYear.SelectedValue;
            string semester = ddlSemester.SelectedValue;
            string faculty = ddlFaculty.SelectedValue;
            string campus = ddlCampus.SelectedValue;

            litAcadYearDisplay.Text = acadYear;
            litSemesterDisplay.Text = semester;

            // Initialize to 0 - research marksheets table may not exist
            litPendingCount.Text = "0";
            litSubmittedCount.Text = "0";
            litApprovedCount.Text = "0";
            litCapturedCount.Text = "0";
            
            // Note: Research marksheet stats functionality requires acad_researchexamsettings table
            // which may need to be created in your database
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading stats: " + ex.Message, "error");
        }
    }

    #endregion

    #region Grid Binding

    private void BindGrid()
    {
        // Create empty DataTable with expected columns for the grid
        DataTable dt = new DataTable();
        dt.Columns.Add("ID", typeof(int));
        dt.Columns.Add("courseID", typeof(string));
        dt.Columns.Add("course_name", typeof(string));
        dt.Columns.Add("classname", typeof(string));
        dt.Columns.Add("cyear", typeof(int));
        dt.Columns.Add("stream", typeof(string));
        dt.Columns.Add("intake", typeof(string));
        dt.Columns.Add("stud_session", typeof(string));
        dt.Columns.Add("InternalExaminerRatio", typeof(int));
        dt.Columns.Add("ExternalExaminerRatio", typeof(int));
        dt.Columns.Add("emp_name", typeof(string));
        dt.Columns.Add("dateCreated", typeof(DateTime));
        dt.Columns.Add("dateSubmitted", typeof(DateTime));
        dt.Columns.Add("sheet_status", typeof(string));
        dt.Columns.Add("prog_id", typeof(string));
        dt.Columns.Add("acad_year", typeof(string));
        dt.Columns.Add("semester", typeof(int));
        dt.Columns.Add("final_total", typeof(int));
        dt.Columns.Add("EntryYear", typeof(int));
        
        try
        {
            // Note: Research marksheets functionality requires acad_researchexamsettings table
            // which may need to be created in your database
            // For now, show empty grid with message
            ShowMessage("Research marksheets table not configured. Please contact system administrator.", "info");
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading marksheets: " + ex.Message, "error");
        }
        
        gvMarksheets.DataSource = dt;
        gvMarksheets.DataBind();
    }

    protected string GetStatusBadge(object status)
    {
        string statusStr = status != null ? status.ToString().ToUpper() : "NEW";
        string badgeClass = "rm-status-badge ";
        switch (statusStr)
        {
            case "SUBMITTED":
                badgeClass += "rm-status-badge--submitted";
                break;
            case "APPROVED":
                badgeClass += "rm-status-badge--approved";
                break;
            case "CAPTURED":
                badgeClass += "rm-status-badge--captured";
                break;
            case "REJECTED":
                badgeClass += "rm-status-badge--rejected";
                break;
            default:
                badgeClass += "rm-status-badge--pending";
                statusStr = "NEW";
                break;
        }
        return string.Format("<span class=\"{0}\">{1}</span>", badgeClass, statusStr);
    }

    #endregion

    #region Event Handlers

    protected void ddlFaculty_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }

    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }

    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }

    protected void ddlCampus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }

    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
        ShowMessage("Data refreshed successfully.", "success");
    }

    protected void btnApproveSelected_Click(object sender, EventArgs e)
    {
        try
        {
            List<object> selectedIds = gvMarksheets.GetSelectedFieldValues("ID");
            if (selectedIds.Count == 0)
            {
                ShowMessage("No marksheets selected.", "warning");
                return;
            }

            // Note: Research marksheets approval requires acad_researchexamsettings table
            ShowMessage("Research marksheets table not configured. Please contact system administrator.", "warning");

            gvMarksheets.Selection.UnselectAll();
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error approving marksheets: " + ex.Message, "error");
        }
    }

    protected void btnExportExcel_Click(object sender, EventArgs e)
    {
        try
        {
            gvExporter.WriteXlsToResponse("ResearchMarksheets_" + DateTime.Now.ToString("yyyyMMdd_HHmmss"));
        }
        catch (Exception ex)
        {
            ShowMessage("Error exporting: " + ex.Message, "error");
        }
    }

    protected void gvMarksheets_RowCommand(object sender, ASPxGridViewRowCommandEventArgs e)
    {
        if (e.CommandArgs.CommandName == "ViewDetails")
        {
            string id = e.CommandArgs.CommandArgument.ToString();
            
            // Get row data
            int visibleIndex = e.VisibleIndex;
            string courseID = gvMarksheets.GetRowValues(visibleIndex, "courseID").ToString();
            string progId = gvMarksheets.GetRowValues(visibleIndex, "prog_id").ToString();
            string acadYear = gvMarksheets.GetRowValues(visibleIndex, "acad_year").ToString();
            string semester = gvMarksheets.GetRowValues(visibleIndex, "semester").ToString();
            string cyear = gvMarksheets.GetRowValues(visibleIndex, "cyear").ToString();
            object entryYearObj = gvMarksheets.GetRowValues(visibleIndex, "EntryYear");
            string entryYear = entryYearObj != null ? entryYearObj.ToString() : "";
            object streamObj = gvMarksheets.GetRowValues(visibleIndex, "stream");
            string stream = streamObj != null ? streamObj.ToString() : "";
            object intakeObj = gvMarksheets.GetRowValues(visibleIndex, "intake");
            string intake = intakeObj != null ? intakeObj.ToString() : "";
            object sessionObj = gvMarksheets.GetRowValues(visibleIndex, "stud_session");
            string session = sessionObj != null ? sessionObj.ToString() : "";
            
            // Build URL with parameters
            string url = string.Format("ResearchMarkSheetDetails.aspx?id={0}&course={1}&prog={2}&year={3}&sem={4}&cyear={5}&entry={6}&stream={7}&intake={8}&session={9}",
                id, HttpUtility.UrlEncode(courseID), HttpUtility.UrlEncode(progId), 
                HttpUtility.UrlEncode(acadYear), semester, cyear,
                HttpUtility.UrlEncode(entryYear), HttpUtility.UrlEncode(stream),
                HttpUtility.UrlEncode(intake), HttpUtility.UrlEncode(session));
            
            popDetails.HeaderText = "Research Marksheet Details - " + courseID;
            popDetails.ContentUrl = url;
            popDetails.ShowOnPageLoad = true;
        }
    }

    #endregion

    #region Helper Methods

    private void ShowMessage(string message, string type)
    {
        pnlMessage.CssClass = "rm-message show rm-message--" + type;
        litMessage.Text = message;
        pnlMessage.Visible = true;
    }

    #endregion
}
