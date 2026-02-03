using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;

public partial class COOPERP_NewScreens_StudentsSpecialisation : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["vacConnectionString"].ConnectionString; }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadProgrammes();
            LoadEntryYears();
            LoadSessions();
            LoadSpecialisations();
            
            UpdateDisplayLabels();
            LoadStats();
            BindGrid();
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
    
    private void LoadEntryYears()
    {
        ddlEntryYear.Items.Clear();
        ddlEntryYear.Items.Add(new ListItem("-- Entry Year --", ""));
        
        int currentYear = DateTime.Now.Year;
        for (int i = currentYear; i >= currentYear - 15; i--)
        {
            ddlEntryYear.Items.Add(new ListItem(i.ToString(), i.ToString()));
        }
    }
    
    private void LoadSessions()
    {
        ddlSession.Items.Clear();
        ddlSession.Items.Add(new ListItem("-- All Sessions --", ""));
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            string sql = "SELECT DISTINCT Session FROM acad_studysessions ORDER BY Session";
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string session = reader["Session"].ToString();
                        ddlSession.Items.Add(new ListItem(session, session));
                    }
                }
            }
        }
    }
    
    private void LoadSpecialisations()
    {
        ddlNewSpecialisation.Items.Clear();
        ddlNewSpecialisation.Items.Add(new ListItem("-- Select Specialisation --", ""));
        
        string progFilter = ddlProgramme.SelectedValue;
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            string sql = @"SELECT spec_id, spec, prog_id FROM acad_specialisation 
                          WHERE spec != '-'";
            
            if (!string.IsNullOrEmpty(progFilter))
            {
                sql += " AND prog_id = @progId";
            }
            
            sql += " ORDER BY spec";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(progFilter))
                {
                    cmd.Parameters.AddWithValue("@progId", progFilter);
                }
                
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string specId = reader["spec_id"].ToString();
                        string specName = reader["spec"].ToString();
                        string progId = reader["prog_id"].ToString();
                        
                        string displayText = specName;
                        if (string.IsNullOrEmpty(progFilter))
                        {
                            displayText = "[" + progId + "] " + specName;
                        }
                        
                        ddlNewSpecialisation.Items.Add(new ListItem(displayText, specId));
                    }
                }
            }
        }
    }
    
    private void UpdateDisplayLabels()
    {
        if (string.IsNullOrEmpty(ddlProgramme.SelectedValue))
        {
            litProgrammeDisplay.Text = "All Programmes";
        }
        else
        {
            litProgrammeDisplay.Text = ddlProgramme.SelectedValue;
        }
    }
    
    private void LoadStats()
    {
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            string whereClause = BuildWhereClause();
            
            string sql = @"SELECT 
                           SUM(CASE WHEN s.specialisation IS NOT NULL AND s.specialisation != '-' AND s.specialisation != '' AND s.specialisation != '13' THEN 1 ELSE 0 END) as assigned,
                           SUM(CASE WHEN s.specialisation IS NULL OR s.specialisation = '-' OR s.specialisation = '' OR s.specialisation = '13' THEN 1 ELSE 0 END) as unassigned,
                           COUNT(*) as total
                           FROM acad_student s" + whereClause;
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddWhereParameters(cmd);
                
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        litAssigned.Text = (reader["assigned"] != DBNull.Value ? reader["assigned"].ToString() : "0");
                        litUnassigned.Text = (reader["unassigned"] != DBNull.Value ? reader["unassigned"].ToString() : "0");
                        litTotal.Text = (reader["total"] != DBNull.Value ? reader["total"].ToString() : "0");
                    }
                }
            }
        }
    }
    
    private string BuildWhereClause()
    {
        List<string> conditions = new List<string>();
        
        // Always show only relevant student statuses
        conditions.Add("s.new_status IN ('ACTIVE', 'ADMITTED', 'GRADUATED')");
        
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            conditions.Add("s.progid = @programme");
        
        if (!string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
            conditions.Add("s.entryyear = @entryYear");
        
        if (!string.IsNullOrEmpty(ddlSession.SelectedValue))
            conditions.Add("s.studsesion = @session");
        
        if (!string.IsNullOrEmpty(ddlStudStatus.SelectedValue))
            conditions.Add("s.new_status = @studStatus");
        
        if (ddlSpecStatus.SelectedValue == "assigned")
            conditions.Add("s.specialisation IS NOT NULL AND s.specialisation != '-' AND s.specialisation != '' AND s.specialisation != '13'");
        else if (ddlSpecStatus.SelectedValue == "unassigned")
            conditions.Add("(s.specialisation IS NULL OR s.specialisation = '-' OR s.specialisation = '' OR s.specialisation = '13')");
        
        if (conditions.Count > 0)
            return " WHERE " + string.Join(" AND ", conditions);
        
        return "";
    }
    
    private void AddWhereParameters(MySqlCommand cmd)
    {
        if (!string.IsNullOrEmpty(ddlProgramme.SelectedValue))
            cmd.Parameters.AddWithValue("@programme", ddlProgramme.SelectedValue);
        
        if (!string.IsNullOrEmpty(ddlEntryYear.SelectedValue))
            cmd.Parameters.AddWithValue("@entryYear", int.Parse(ddlEntryYear.SelectedValue));
        
        if (!string.IsNullOrEmpty(ddlSession.SelectedValue))
            cmd.Parameters.AddWithValue("@session", ddlSession.SelectedValue);
        
        if (!string.IsNullOrEmpty(ddlStudStatus.SelectedValue))
            cmd.Parameters.AddWithValue("@studStatus", ddlStudStatus.SelectedValue);
    }
    
    private void BindGrid()
    {
        string whereClause = BuildWhereClause();
        
        string sql = @"SELECT s.regno, s.firstname, s.othername, s.progid, s.entryyear, s.studsesion,
                       s.specialisation, s.new_status,
                       CONCAT(s.firstname, ' ', COALESCE(s.othername, '')) as student_name,
                       COALESCE(sp.spec, '-') as spec_name
                       FROM acad_student s
                       LEFT JOIN acad_specialisation sp ON s.specialisation = sp.spec_id" + whereClause +
                       " ORDER BY s.firstname, s.othername";
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                AddWhereParameters(cmd);
                
                using (MySqlDataAdapter da = new MySqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvStudents.DataSource = dt;
                    gvStudents.DataBind();
                }
            }
        }
    }
    
    protected string GetStatusClass(string status)
    {
        switch (status.ToUpper())
        {
            case "ACTIVE": return "active";
            case "ADMITTED": return "admitted";
            case "GRADUATED": return "graduated";
            case "DISCONTINUED": return "discontinued";
            case "SUSPENDED": return "suspended";
            default: return "";
        }
    }
    
    protected string GetSpecialisationBadge(object specId, object specName)
    {
        string spec = specId != null ? specId.ToString() : "";
        string name = specName != null ? specName.ToString() : "-";
        
        bool isAssigned = !string.IsNullOrEmpty(spec) && spec != "-" && spec != "13";
        string cssClass = isAssigned ? "spec-badge--assigned" : "spec-badge--unassigned";
        string displayName = isAssigned ? name : "Not Assigned";
        
        return string.Format("<span class='spec-badge {0}' title='{1}'>{2}</span>", cssClass, name, displayName);
    }
    
    protected bool IsSpecAssigned(object specId)
    {
        if (specId == null) return false;
        string spec = specId.ToString();
        return !string.IsNullOrEmpty(spec) && spec != "-" && spec != "13";
    }
    
    protected void gvStudents_HtmlDataCellPrepared(object sender, DevExpress.Web.ASPxGridViewTableDataCellEventArgs e)
    {
        // Ensure action cell allows overflow
        if (e.DataColumn.FieldName == "" && e.Cell.CssClass.Contains("cd-action-cell"))
        {
            e.Cell.Style["overflow"] = "visible";
            e.Cell.Style["position"] = "relative";
        }
    }
    
    #region Filter Events
    
    protected void ddlProgramme_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadSpecialisations();
        UpdateDisplayLabels();
        LoadStats();
        BindGrid();
    }
    
    protected void ddlEntryYear_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSession_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlSpecStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    protected void ddlStudStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    #endregion
    
    #region Individual Actions
    
    protected void btnAssign_Click(object sender, EventArgs e)
    {
        try
        {
            LinkButton btn = (LinkButton)sender;
            string regno = btn.CommandArgument;
            
            // Get student details
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = @"SELECT s.regno, s.firstname, s.othername, s.progid, s.specialisation, sp.spec as spec_name
                              FROM acad_student s
                              LEFT JOIN acad_specialisation sp ON s.specialisation = sp.spec_id
                              WHERE s.regno = @regno";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    
                    using (MySqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnStudentRegNo.Value = regno;
                            lblStudentName.Text = reader["firstname"].ToString() + " " + (reader["othername"] != DBNull.Value ? reader["othername"].ToString() : "");
                            lblStudentProg.Text = reader["progid"].ToString();
                            
                            string currentSpec = reader["spec_name"] != DBNull.Value ? reader["spec_name"].ToString() : "-";
                            string specId = reader["specialisation"] != DBNull.Value ? reader["specialisation"].ToString() : "";
                            lblCurrentSpec.Text = (specId != "-" && specId != "13" && !string.IsNullOrEmpty(specId)) ? currentSpec : "Not Assigned";
                            
                            // Load specialisations for this programme
                            LoadPopupSpecialisations(reader["progid"].ToString(), specId);
                        }
                    }
                }
            }
            
            popAssign.ShowOnPageLoad = true;
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message);
        }
    }
    
    private void LoadPopupSpecialisations(string progId, string currentSpecId)
    {
        ddlPopupSpec.Items.Clear();
        ddlPopupSpec.Items.Add(new ListItem("-- Select Specialisation --", ""));
        
        using (MySqlConnection conn = new MySqlConnection(ConnectionString))
        {
            conn.Open();
            
            string sql = @"SELECT spec_id, spec FROM acad_specialisation 
                          WHERE prog_id = @progId AND spec != '-'
                          ORDER BY spec";
            
            using (MySqlCommand cmd = new MySqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@progId", progId);
                
                using (MySqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string specId = reader["spec_id"].ToString();
                        string specName = reader["spec"].ToString();
                        
                        ListItem item = new ListItem(specName, specId);
                        ddlPopupSpec.Items.Add(item);
                        
                        if (specId == currentSpecId)
                        {
                            item.Selected = true;
                        }
                    }
                }
            }
        }
    }
    
    protected void btnSaveSpec_Click(object sender, EventArgs e)
    {
        try
        {
            string regno = hdnStudentRegNo.Value;
            string newSpecId = ddlPopupSpec.SelectedValue;
            
            if (string.IsNullOrEmpty(regno))
            {
                ShowMessage("Error: Student not identified.");
                return;
            }
            
            if (string.IsNullOrEmpty(newSpecId))
            {
                ShowMessage("Please select a specialisation.");
                popAssign.ShowOnPageLoad = true;
                return;
            }
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "UPDATE acad_student SET specialisation = @specId WHERE regno = @regno";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@specId", newSpecId);
                    cmd.Parameters.AddWithValue("@regno", regno);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ShowMessage("Specialisation updated successfully.");
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message);
        }
    }
    
    protected void btnClearSpec_Click(object sender, EventArgs e)
    {
        try
        {
            LinkButton btn = (LinkButton)sender;
            string regno = btn.CommandArgument;
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                string sql = "UPDATE acad_student SET specialisation = '-' WHERE regno = @regno";
                
                using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@regno", regno);
                    cmd.ExecuteNonQuery();
                }
            }
            
            ShowMessage("Specialisation cleared successfully.");
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message);
        }
    }
    
    #endregion
    
    #region Batch Actions
    
    protected void btnAssignSelected_Click(object sender, EventArgs e)
    {
        try
        {
            string newSpecId = ddlNewSpecialisation.SelectedValue;
            
            if (string.IsNullOrEmpty(newSpecId))
            {
                ShowMessage("Please select a specialisation to assign.");
                return;
            }
            
            List<object> selectedKeys = gvStudents.GetSelectedFieldValues("regno");
            
            if (selectedKeys.Count == 0)
            {
                ShowMessage("Please select at least one student.");
                return;
            }
            
            int successCount = 0;
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object key in selectedKeys)
                {
                    string regno = key.ToString();
                    
                    string sql = "UPDATE acad_student SET specialisation = @specId WHERE regno = @regno";
                    
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@specId", newSpecId);
                        cmd.Parameters.AddWithValue("@regno", regno);
                        
                        if (cmd.ExecuteNonQuery() > 0)
                        {
                            successCount++;
                        }
                    }
                }
            }
            
            gvStudents.Selection.UnselectAll();
            ShowMessage(string.Format("{0} student(s) updated successfully.", successCount));
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message);
        }
    }
    
    protected void btnBatchClear_Click(object sender, EventArgs e)
    {
        try
        {
            List<object> selectedKeys = gvStudents.GetSelectedFieldValues("regno");
            
            if (selectedKeys.Count == 0)
            {
                ShowMessage("Please select at least one student.");
                return;
            }
            
            int successCount = 0;
            
            using (MySqlConnection conn = new MySqlConnection(ConnectionString))
            {
                conn.Open();
                
                foreach (object key in selectedKeys)
                {
                    string regno = key.ToString();
                    
                    string sql = "UPDATE acad_student SET specialisation = '-' WHERE regno = @regno";
                    
                    using (MySqlCommand cmd = new MySqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@regno", regno);
                        
                        if (cmd.ExecuteNonQuery() > 0)
                        {
                            successCount++;
                        }
                    }
                }
            }
            
            gvStudents.Selection.UnselectAll();
            ShowMessage(string.Format("Specialisation cleared for {0} student(s).", successCount));
            LoadStats();
            BindGrid();
        }
        catch (Exception ex)
        {
            ShowMessage("Error: " + ex.Message);
        }
    }
    
    protected void btnRefresh_Click(object sender, EventArgs e)
    {
        LoadStats();
        BindGrid();
    }
    
    #endregion
    
    private void ShowMessage(string message)
    {
        litMessage.Text = message;
        popMessage.ShowOnPageLoad = true;
    }
}
