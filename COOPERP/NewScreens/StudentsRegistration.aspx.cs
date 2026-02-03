using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_StudentsRegistration : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadAcademicYears();
            LoadProgrammes();
            
            // Set default academic year and semester
            string defaultYear = GetCurrentAcademicYear();
            if (ddlAcadYear.Items.FindByValue(defaultYear) != null)
                ddlAcadYear.SelectedValue = defaultYear;
            
            // Default to semester 1
            ddlSemester.SelectedValue = "1";
            
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
        }
    }
    
    private string GetCurrentAcademicYear()
    {
        int year = DateTime.Now.Year;
        int month = DateTime.Now.Month;
        
        // If we're in the second half of the year, the academic year is current/next
        if (month >= 8)
            return string.Format("{0}/{1}", year, year + 1);
        else
            return string.Format("{0}/{1}", year - 1, year);
    }
    
    private void LoadAcademicYears()
    {
        ddlAcadYear.Items.Clear();
        
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear + 1; i >= currentYear - 10; i--)
        {
            string acadYear = string.Format("{0}/{1}", i, i + 1);
            ddlAcadYear.Items.Add(new ListItem(acadYear, acadYear));
        }
    }
    
    private void LoadProgrammes()
    {
        ddlProgramme.Items.Clear();
        ddlProgramme.Items.Add(new ListItem("-- All Programmes --", ""));
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT progcode, progname FROM acad_programme ORDER BY progname";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string code = reader["progcode"].ToString();
                        string name = reader["progname"].ToString();
                        ddlProgramme.Items.Add(new ListItem(code + " - " + name, code));
                    }
                }
            }
        }
    }
    
    private void UpdateDisplayLabels()
    {
        litAcadYearDisplay.Text = ddlAcadYear.SelectedValue;
        litSemesterDisplay.Text = ddlSemester.SelectedValue;
    }
    
    private void LoadStats()
    {
        string acadYear = ddlAcadYear.SelectedValue;
        int semester = int.Parse(ddlSemester.SelectedValue);
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            // Count by status
            string sql = @"SELECT 
                           SUM(CASE WHEN regstatus = 'UNREGISTERED' THEN 1 ELSE 0 END) as unregistered,
                           SUM(CASE WHEN regstatus = 'REGISTERED' OR regstatus = 'LATE REGISTERED' THEN 1 ELSE 0 END) as registered,
                           SUM(CASE WHEN regstatus = 'CLEARED' THEN 1 ELSE 0 END) as cleared,
                           COUNT(*) as total
                           FROM acad_registration 
                           WHERE acad_year = @acadYear AND semester = @semester";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@acadYear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        litUnregistered.Text = (reader["unregistered"] != DBNull.Value ? reader["unregistered"].ToString() : "0");
                        litRegistered.Text = (reader["registered"] != DBNull.Value ? reader["registered"].ToString() : "0");
                        litCleared.Text = (reader["cleared"] != DBNull.Value ? reader["cleared"].ToString() : "0");
                        litTotal.Text = (reader["total"] != DBNull.Value ? reader["total"].ToString() : "0");
                    }
                }
            }
        }
    }
    
    private void BindGrid()
    {
        string acadYear = ddlAcadYear.SelectedValue;
        int semester = int.Parse(ddlSemester.SelectedValue);
        
        string sql = @"SELECT r.ID, r.regno, r.acad_year, r.semester, r.regstatus, r.studyyear,
                       r.id_cardStatus, r.residence_status, r.examClearance, r.examClearanceDate,
                       r.registeredBy, r.clearedBy,
                       CONCAT(s.firstname, ' ', COALESCE(s.othername, '')) as student_name,
                       s.progid as progcode
                       FROM acad_registration r
                       LEFT JOIN acad_student s ON r.regno = s.regno
                       WHERE r.acad_year = @acadYear AND r.semester = @semester";
        
        // Apply filters
        if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
            sql += " AND r.studyyear = @studyYear";
        
        if (!string.IsNullOrEmpty(ddlRegStatus.SelectedValue))
            sql += " AND r.regstatus = @regStatus";
        
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            sql += " AND s.progid = @programme";
        
        sql += " ORDER BY s.firstname, s.othername";
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@acadYear", acadYear);
                cmd.Parameters.AddWithValue("@semester", semester);
                
                if (!string.IsNullOrEmpty(ddlStudyYear.SelectedValue))
                    cmd.Parameters.AddWithValue("@studyYear", int.Parse(ddlStudyYear.SelectedValue));
                
                if (!string.IsNullOrEmpty(ddlRegStatus.SelectedValue))
                    cmd.Parameters.AddWithValue("@regStatus", ddlRegStatus.SelectedValue);
                
                if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    cmd.Parameters.AddWithValue("@programme", ddlProgramme.SelectedValue);
                
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvRegistration.DataSource = dt;
                    gvRegistration.DataBind();
                }
            }
        }
    }
    
    protected string GetStatusClass(string status)
    {
        switch (status.ToUpper())
        {
            case "UNREGISTERED": return "unregistered";
            case "REGISTERED": return "registered";
            case "CLEARED": return "cleared";
            case "DISCONTINUED": return "discontinued";
            case "LATE REGISTERED": return "late";
            case "HALTED": return "halted";
            case "DEAD YEAR": return "deadyear";
            default: return "";
        }
    }
    
    protected string GetClearanceClass(string status)
    {
        switch (status.ToUpper())
        {
            case "CLEARED": return "cleared";
            case "PRINTED": return "registered";
            case "UNCLEARED": return "unregistered";
            default: return "";
        }
    }
    
    // Filter change handlers
    protected void ddlAcadYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSemester_SelectedIndexChanged(object sender, EventArgs e)
    {
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStudyYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    protected void ddlRegStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        BindGrid();
    }
    
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    // Individual action buttons
    protected void btnRegister_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = int.Parse(btn.CommandArgument);
        
        RegisterStudent(id);
        ShowMessage("Student registered successfully.");
        LoadStats();
        BindGrid();
    }
    
    protected void btnClear_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = int.Parse(btn.CommandArgument);
        
        ClearStudent(id);
        ShowMessage("Student cleared for exams successfully.");
        LoadStats();
        BindGrid();
    }
    
    protected void btnUnregister_Click(object sender, EventArgs e)
    {
        LinkButton btn = (LinkButton)sender;
        int id = int.Parse(btn.CommandArgument);
        
        UnregisterStudent(id);
        ShowMessage("Student registration undone.");
        LoadStats();
        BindGrid();
    }
    
    // Batch actions
    protected void btnBatchRegister_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvRegistration.GetSelectedFieldValues("ID");
        int count = 0;
        
        foreach (object key in selectedKeys)
        {
            int id = Convert.ToInt32(key);
            if (RegisterStudent(id))
                count++;
        }
        
        gvRegistration.Selection.UnselectAll();
        ShowMessage(string.Format("{0} student(s) registered successfully.", count));
        LoadStats();
        BindGrid();
    }
    
    protected void btnBatchClear_Click(object sender, EventArgs e)
    {
        List<object> selectedKeys = gvRegistration.GetSelectedFieldValues("ID");
        int count = 0;
        
        foreach (object key in selectedKeys)
        {
            int id = Convert.ToInt32(key);
            if (ClearStudent(id))
                count++;
        }
        
        gvRegistration.Selection.UnselectAll();
        ShowMessage(string.Format("{0} student(s) cleared for exams.", count));
        LoadStats();
        BindGrid();
    }
    
    private bool RegisterStudent(int id)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"UPDATE acad_registration 
                               SET regstatus = 'REGISTERED', registeredBy = @user 
                               WHERE ID = @id AND regstatus = 'UNREGISTERED'";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@user", HttpContext.Current.User.Identity.Name);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch
        {
            return false;
        }
    }
    
    private bool ClearStudent(int id)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"UPDATE acad_registration 
                               SET regstatus = 'CLEARED', examClearance = 'CLEARED', 
                                   examClearanceDate = @date, clearedBy = @user 
                               WHERE ID = @id AND regstatus IN ('REGISTERED', 'LATE REGISTERED')";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.Parameters.AddWithValue("@date", DateTime.Now);
                    cmd.Parameters.AddWithValue("@user", HttpContext.Current.User.Identity.Name);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch
        {
            return false;
        }
    }
    
    private bool UnregisterStudent(int id)
    {
        try
        {
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"UPDATE acad_registration 
                               SET regstatus = 'UNREGISTERED', registeredBy = '-'
                               WHERE ID = @id AND regstatus = 'REGISTERED'";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }
        catch
        {
            return false;
        }
    }
    
    private void ShowMessage(string message)
    {
        litMessage.Text = message;
        popMessage.ShowOnPageLoad = true;
    }
    
    protected void gvRegistration_CustomButtonCallback(object sender, DevExpress.Web.ASPxGridViewCustomButtonCallbackEventArgs e)
    {
        // Handle custom button callbacks if needed
    }
    
    protected void gvRegistration_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        e.Cell.Style["vertical-align"] = "middle";
    }
}
